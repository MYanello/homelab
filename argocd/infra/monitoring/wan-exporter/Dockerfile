FROM ghcr.io/astral-sh/uv:0.13.1-python3.14-alpine@sha256:513b826406ed7efc2604acdf4935266e020283ce17e2ea96509cd4f1a68b9f1a

WORKDIR /app

COPY pyproject.toml .

RUN apk add curl jq
ENV PYTHONUNBUFFERED=1
RUN uv sync

COPY script.py .
ENTRYPOINT ["uv", "run", "script.py"]
