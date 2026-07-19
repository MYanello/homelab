import asyncio
import os
import time

import aiohttp
from aiohttp.client import ClientTimeout
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

DEFAULT_PORT = 9101
DEFAULT_INTERVAL = 120


async def update(interval: int):
    async with aiohttp.ClientSession() as session:
        prev_ip = ""
        while True:
            try:
                async with session.get(
                    "https://ifconfig.co",
                    timeout=ClientTimeout(5),
                    headers={"Accept": "application/json"},
                ) as resp:
                    data = await resp.json()
                    out = {k: str(data.get(k, "")) for k in fields}
                    ip = out.get("ip", "")
                    wan_ip.info(out)
                    last_scrape.set(time.time())
                    if ip != prev_ip:
                        last_change.set(time.time())
                        print(f"Got new IP: {ip}")
                        prev_ip = ip
            except Exception as e:
                print(f"Error getting IP: {e}")
                pass
            await asyncio.sleep(interval)


if __name__ == "__main__":
    print("Starting WAN IP exporter service")
    port = int(os.getenv("PORT", DEFAULT_PORT))
    start_http_server(port)
    interval = int(os.getenv("INTERVAL", DEFAULT_INTERVAL))
    asyncio.run(update(interval))
