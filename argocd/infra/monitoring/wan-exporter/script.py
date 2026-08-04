import base64
import hashlib
import ipaddress
import json
import logging
import os
import time
import urllib.request
from datetime import datetime

from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives.asymmetric.rsa import RSAPrivateKey
from prometheus_client import Gauge, Info, start_http_server

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%S",
)
logger = logging.getLogger(__name__)

wan_ip = Info("wan_ip", "Current public IP")
last_scrape = Gauge("wan_last_scrape", "Timestamp of last successful scrape")
last_change = Gauge("wan_ip_last_change", "Timestamp of last IP change")

fields = (
    "ip",
    "country",
    "country_iso",
    "region_name",
    "city",
    "zip_code",
    "latitude",
    "longitude",
    "asn",
    "asn_org",
    "hostname",
    "time_zone",
)

VM_URL = os.getenv(
    "VM_URL",
    "http://vmsingle-victoria-metrics-k8s-stack.monitoring.svc.cluster.local:8428",
)
PORT = int(os.getenv("PORT", 9101))
INTERVAL = int(os.getenv("INTERVAL", 120))
NTFY_URL = f"ntfy.sh/{os.getenv('NTFY_TOPIC')}"


def query_vm() -> tuple[dict, float]:
    url = f"{VM_URL}/api/v1/query?query=wan_ip_info"
    result, ts = {}, time.time()

    try:
        resp = urllib.request.urlopen(url, timeout=5)
        data = json.loads(resp.read())
        for r in data.get("data", {}).get("result", []):
            result = r.get("metric", {})
            if result:
                break
        resp = urllib.request.urlopen(
            f"{VM_URL}/api/v1/query?query=wan_ip_last_change", timeout=5
        )
        data = json.loads(resp.read())
        for r in data.get("data", {}).get("result", []):
            v = float(r.get("value", ["", str(ts)])[1])
            # only trust timestamps from 2024 onward
            if v > 1_700_000_000:
                ts = v
            break
    except Exception:
        logger.exception("VM query failed")
    return result, ts


def fetch_ip():
    req = urllib.request.Request(
        "https://ifconfig.co",
        headers={"Accept": "application/json", "User-Agent": "curl/8.21"},
    )
    resp = urllib.request.urlopen(req, timeout=10)
    return json.loads(resp.read())


def notify(title: str, message: str) -> None:
    try:
        req = urllib.request.Request(
            NTFY_URL,
            data=message.encode(),
            headers={"Title": title, "Tags": "globe"},
            method="POST",
        )
        urllib.request.urlopen(req, timeout=5)
    except Exception:
        logger.exception("ntfy failed")


def _oci_sign(
    method: str, path: str, body: bytes, private_key_pem: str, key_id: str, host: str
) -> dict[str, str]:
    date = time.strftime("%a, %d %b %Y %H:%M:%S GMT", time.gmtime())
    headers: dict = {"Date": date, "Host": host}
    signed_headers = "(request-target) date host"

    if body:
        headers["x-content-sha256"] = hashlib.sha256(body).hexdigest()
        headers["Content-Length"] = str(len(body))
        headers["Content-Type"] = "application/json"
        signed_headers = (
            "(request-target) date host x-content-sha256 content-length content-type"
        )

    signing_lines = []
    for h in signed_headers.split():
        if h == "(request-target)":
            signing_lines.append(f"(request-target): {method.lower()} {path}")
        elif h == "date":
            signing_lines.append(f"date: {headers['Date']}")
        elif h == "host":
            signing_lines.append(f"host: {headers['Host']}")
        elif h == "x-content-sha256":
            signing_lines.append(f"x-content-sha256: {headers['x-content-sha256']}")
        elif h == "content-length":
            signing_lines.append(f"content-length: {headers['Content-Length']}")
        elif h == "content-type":
            signing_lines.append(f"content-type: {headers['Content-Type']}")

    signing_string = "\n".join(signing_lines)
    private_key = serialization.load_pem_private_key(
        private_key_pem.encode(), password=None
    )
    if not isinstance(private_key, RSAPrivateKey):
        raise TypeError("ORACLE_API_KEY must be an RSA private key")
    signature = private_key.sign(
        signing_string.encode(), padding.PKCS1v15(), hashes.SHA256()
    )
    sig_b64 = base64.b64encode(signature).decode()

    headers["Authorization"] = (
        f'Signature version="1",'
        f'keyId="{key_id}",'
        f'algorithm="rsa-sha256",'
        f'headers="{signed_headers}",'
        f'signature="{sig_b64}"'
    )
    return headers


def update_oracle(ip: str) -> None:
    if not ip:
        logger.warning("Oracle: empty IP, skipping")
        return

    region = os.getenv("ORACLE_REGION", "us-ashburn-1")
    host = f"iaas.{region}.oraclecloud.com"
    endpoint = f"https://{host}"

    api_key = os.getenv("ORACLE_API_KEY")
    fingerprint = os.getenv("ORACLE_FINGERPRINT")
    tenancy_ocid = os.getenv("ORACLE_TENANCY_OCID")
    user_ocid = os.getenv("ORACLE_USER_OCID")
    security_list_id = os.getenv("ORACLE_SECURITY_LIST_ID")

    if (
        not api_key
        or not fingerprint
        or not tenancy_ocid
        or not user_ocid
        or not security_list_id
    ):
        logger.warning("Oracle: incomplete credentials, skipping update")
        return

    key_id = f"{tenancy_ocid}/{user_ocid}/{fingerprint}"

    try:
        path = f"/20160918/securityLists/{security_list_id}"

        req_headers = _oci_sign("GET", path, b"", api_key, key_id, host)
        req = urllib.request.Request(f"{endpoint}{path}", headers=req_headers)
        resp = urllib.request.urlopen(req, timeout=10)
        data: dict = json.loads(resp.read())

        ingress_rules = list(data.get("ingressSecurityRules", []))
        updated = False
        prefix = "32"
        for rule in ingress_rules:
            if rule.get("protocol") == "all":
                prefix = (
                    "32"
                    if isinstance(ipaddress.ip_address(ip), ipaddress.IPv4Address)
                    else "128"
                )
                rule["source"] = f"{ip}/{prefix}"
                updated = True
                break

        if not updated:
            logger.warning("Oracle: no all-traffic ingress rule found in security list")
            return

        put_body: dict = {
            "ingressSecurityRules": ingress_rules,
            "egressSecurityRules": data.get("egressSecurityRules", []),
        }
        for field in ("definedTags", "freeformTags", "displayName"):
            if field in data:
                put_body[field] = data[field]

        body_bytes = json.dumps(put_body).encode()
        req_headers = _oci_sign("PUT", path, body_bytes, api_key, key_id, host)
        req = urllib.request.Request(
            f"{endpoint}{path}", data=body_bytes, headers=req_headers, method="PUT"
        )
        resp = urllib.request.urlopen(req, timeout=10)
        logger.info(f"Oracle: security list updated to allow {ip}/{prefix}")
    except Exception:
        logger.exception("Oracle update failed")


def main():
    logger.info("Starting WAN IP exporter")

    previous, change_time = query_vm()
    prev_ip = previous.get("ip")
    if previous:
        wan_ip.info(previous)
        if change_time:
            last_change.set(change_time)
            logger.info(
                f"Restored IP: {previous.get('ip')}; last change: {datetime.fromtimestamp(change_time).isoformat(timespec='seconds')}"
            )
        else:
            logger.info(f"Restored IP: {previous.get('ip')}; last change unknown")
    start_http_server(PORT)

    while True:
        try:
            data = fetch_ip()
            out = {k: str(data.get(k, "")) for k in fields}
            ip = out.get("ip", "")
            wan_ip.info(out)
            last_scrape.set(time.time())
            if ip != prev_ip:
                change_time = time.time()
                last_change.set(change_time)
                logger.info(f"IP changed: {ip}")
                notify("WAN IP changed", f"{prev_ip or 'unknown'} -> {ip}")
                update_oracle(ip)
                prev_ip = ip
        except Exception:
            logger.exception("Scrape error")
        time.sleep(INTERVAL)


if __name__ == "__main__":
    main()
