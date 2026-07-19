import json
import os
import time
import urllib.request
from datetime import datetime

from prometheus_client import Gauge, Info, start_http_server

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
    except Exception as e:
        print(f"VM query failed: {e}")
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
    except Exception as e:
        print(f"ntfy failed: {e}")


def main():
    print("Starting WAN IP exporter")

    previous, change_time = query_vm()
    prev_ip = previous.get("ip")
    if previous:
        wan_ip.info(previous)
        if change_time:
            last_change.set(change_time)
            print(
                f"Restored IP: {previous.get('ip')}; last change: {datetime.fromtimestamp(change_time).isoformat(timespec='seconds')}"
            )
        else:
            print(f"Restored IP: {previous.get('ip')}; last change unknown")
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
                print(f"IP changed: {ip}")
                notify("WAN IP changed", f"{prev_ip or 'unknown'} -> {ip}")
                prev_ip = ip
        except Exception as e:
            print(f"Scrape error: {e}")
        time.sleep(INTERVAL)


if __name__ == "__main__":
    main()
