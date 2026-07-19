FROM ghcr.io/astral-sh/uv:0.11.29-python3.14-alpine

WORKDIR /app

COPY script.py .

ENV VIRTUAL_ENV=/app/venv
RUN uv venv && uv pip install aiohttp prometheus_client

ENTRYPOINT ["uv", "run", "script.py"]
