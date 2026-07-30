FROM ghcr.io/astral-sh/uv:0.12.0-python3.14-alpine@sha256:9c2e8c54545d6402b1b6995e6bfb3969afccf9f2380b1d5d0cec0756e8aec1a3

WORKDIR /app

COPY script.py .

RUN apk add curl jq
ENV PYTHONUNBUFFERED=1
ENV VIRTUAL_ENV=/app/venv
RUN uv venv && uv pip install aiohttp prometheus_client

ENTRYPOINT ["uv", "run", "script.py"]
