FROM ghcr.io/astral-sh/uv:0.13.7-python3.14-alpine@sha256:df6ea28f3caf5eb77ebae34d38e9b177b41a4e58ee963b1cbc5c8c1c92710238

WORKDIR /app

COPY pyproject.toml .

RUN apk add curl jq
ENV PYTHONUNBUFFERED=1
RUN uv sync

COPY script.py .
ENTRYPOINT ["uv", "run", "script.py"]
