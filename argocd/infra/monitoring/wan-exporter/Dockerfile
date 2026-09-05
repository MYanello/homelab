FROM ghcr.io/astral-sh/uv:0.12.10-python3.14-alpine@sha256:706cd9faf6d3fa7476fc470463bfca625d4b3ea5e46d6dc166ec1fb8ad3976e6

WORKDIR /app

COPY pyproject.toml .

RUN apk add curl jq
ENV PYTHONUNBUFFERED=1
RUN uv sync

COPY script.py .
ENTRYPOINT ["uv", "run", "script.py"]
