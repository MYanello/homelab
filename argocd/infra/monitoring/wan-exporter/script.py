import asyncio
import time

import aiohttp
from aiohttp.client import ClientTimeout
from prometheus_client import Gauge, Info, start_http_server

wan_ip = Info("wan_ip", "Current public IP")
last_ip = Gauge("wan_last_scrape", "Timestamp of last successful scrape")
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


async def update():
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
                    ip = data.get("ip", "unknown")
                    wan_ip.info({k: str(data.get(k, "")) for k in fields})
                    last_ip.set(time.time())
                    if ip != prev_ip:
                        last_change.set(time.time())
                        print(f"Got new IP: {ip}")
                        prev_ip = ip
            except Exception as e:
                print(f"Error getting IP: {e}")
                pass
            await asyncio.sleep(120)


if __name__ == "__main__":
    print("Starting WAN IP exporter service")
    start_http_server(9101)
    asyncio.run(update())
