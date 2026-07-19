FROM ghcr.io/astral-sh/uv:0.11.29-python3.14-alpine

WORKDIR /app

COPY script.py .

RUN apk add curl
ENV PYTHONUNBUFFERED=1
ENV VIRTUAL_ENV=/app/venv
RUN uv venv && uv pip install aiohttp prometheus_client

ENTRYPOINT ["uv", "run", "script.py"]
