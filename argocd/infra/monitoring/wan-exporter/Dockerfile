FROM harbor.yanello.net/ghcr/astral-sh/uv:0.12.15-python3.14-alpine@sha256:5722f48fd41005cf9ab51096fd17cd810dfd42c45490f70be7639ff2ef7960ba

WORKDIR /app

COPY pyproject.toml .

RUN apk add curl jq
ENV PYTHONUNBUFFERED=1
RUN uv sync

COPY script.py .
ENTRYPOINT ["uv", "run", "script.py"]
