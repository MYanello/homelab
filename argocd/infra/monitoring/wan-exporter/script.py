import json
import os
import time
import urllib.request

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


def query_vm():
    url = f"{VM_URL}/api/v1/query?query=wan_ip_info"
    try:
        resp = urllib.request.urlopen(url, timeout=5)
        data = json.loads(resp.read())
        for r in data.get("data", {}).get("result", []):
            ip = r.get("metric", {}).get("ip", "").strip()
            if ip:
                ts = r.get("value", ["", "0"])[1]
                return ip, float(ts)
    except Exception as e:
        print(f"VM query failed: {e}")
    return "", time.time()


def fetch_ip():
    req = urllib.request.Request(
        "https://ifconfig.co",
        headers={"Accept": "application/json", "User-Agent": "curl/8.21"},
    )
    resp = urllib.request.urlopen(req, timeout=10)
    return json.loads(resp.read())


def main():
    print("Starting WAN IP exporter")

    prev_ip, change_time = query_vm()
    if prev_ip:
        wan_ip.info({"ip": prev_ip})
        print(f"Restored IP: {prev_ip}")
    last_change.set(change_time)

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
                prev_ip = ip
        except Exception as e:
            print(f"Scrape error: {e}")
        time.sleep(INTERVAL)


if __name__ == "__main__":
    main()
