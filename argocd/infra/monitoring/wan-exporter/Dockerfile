FROM ghcr.io/astral-sh/uv:0.12.5-python3.14-alpine@sha256:56b2e7ad659cd4b8d3abb5e67556a1e7ac53adf3a13eb8c292696df9c1e70b67

WORKDIR /app

COPY pyproject.toml .

RUN apk add curl jq
ENV PYTHONUNBUFFERED=1
RUN uv sync

COPY script.py .
ENTRYPOINT ["uv", "run", "script.py"]
