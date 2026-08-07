FROM ghcr.io/astral-sh/uv:0.12.3-python3.14-alpine@sha256:8caaf73b05ffd22c8789b2dc7c93849422225e9f9942b4f373ea5c7d2543a7bb

WORKDIR /app

COPY script.py .

RUN apk add curl jq
ENV PYTHONUNBUFFERED=1
ENV VIRTUAL_ENV=/app/venv
RUN uv venv && uv pip install aiohttp cryptography prometheus_client

ENTRYPOINT ["uv", "run", "script.py"]
