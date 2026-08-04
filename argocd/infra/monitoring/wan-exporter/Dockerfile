FROM ghcr.io/astral-sh/uv:0.12.1-python3.14-alpine@sha256:a92cb3e5b08ef6237b3eab883e062e69064dd5ef444dd9b0c2f24910b6e054f3

WORKDIR /app

COPY script.py .

RUN apk add curl jq
ENV PYTHONUNBUFFERED=1
ENV VIRTUAL_ENV=/app/venv
RUN uv venv && uv pip install aiohttp cryptography prometheus_client

ENTRYPOINT ["uv", "run", "script.py"]
