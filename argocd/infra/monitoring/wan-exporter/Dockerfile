FROM ghcr.io/astral-sh/uv:0.12.7-python3.14-alpine@sha256:1f178a7bcca4ada7464ca87f17a0a27a9f077ee1e22e47d8937259502871f074

WORKDIR /app

COPY pyproject.toml .

RUN apk add curl jq
ENV PYTHONUNBUFFERED=1
RUN uv sync

COPY script.py .
ENTRYPOINT ["uv", "run", "script.py"]
