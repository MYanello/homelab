FROM ghcr.io/astral-sh/uv:0.11.29-python3.14-alpine@sha256:7a6d8c4ff34812917124c77a8559458488f09d5e52e7646c04599f007956966c

WORKDIR /app

COPY script.py .

RUN apk add curl jq
ENV PYTHONUNBUFFERED=1
ENV VIRTUAL_ENV=/app/venv
RUN uv venv && uv pip install aiohttp prometheus_client

ENTRYPOINT ["uv", "run", "script.py"]
