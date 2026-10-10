FROM ghcr.io/astral-sh/uv:0.13.0-python3.14-alpine@sha256:9d9939d9d43f7d0d4814eeeb4aa65a4afde878a86875bc8521d443967c49db21

WORKDIR /app

COPY pyproject.toml .

RUN apk add curl jq
ENV PYTHONUNBUFFERED=1
RUN uv sync

COPY script.py .
ENTRYPOINT ["uv", "run", "script.py"]
