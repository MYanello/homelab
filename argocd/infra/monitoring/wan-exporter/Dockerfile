FROM ghcr.io/astral-sh/uv:0.12.2-python3.14-alpine@sha256:eb40da5b3fb618bb41be0f34326fc74c0798a46e38f9b92fd8ed94b204fef977

WORKDIR /app

COPY script.py .

RUN apk add curl jq
ENV PYTHONUNBUFFERED=1
ENV VIRTUAL_ENV=/app/venv
RUN uv venv && uv pip install aiohttp cryptography prometheus_client

ENTRYPOINT ["uv", "run", "script.py"]
