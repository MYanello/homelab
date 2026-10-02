FROM harbor.yanello.net/ghcr/astral-sh/uv:0.12.21-python3.14-alpine@sha256:ef0ce7dbd530e9726b5004c53ba36e84df6d3e6ef99198788cb53cc0433fd4b4

WORKDIR /app

COPY pyproject.toml .

RUN apk add curl jq
ENV PYTHONUNBUFFERED=1
RUN uv sync

COPY script.py .
ENTRYPOINT ["uv", "run", "script.py"]
