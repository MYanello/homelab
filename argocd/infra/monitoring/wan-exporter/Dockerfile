FROM ghcr.io/astral-sh/uv:0.12.12-python3.14-alpine@sha256:a555287bdaf438f1867ac813878f98ceb8e0b8c6c54f9aced48d46ea8e23857b

WORKDIR /app

COPY pyproject.toml .

RUN apk add curl jq
ENV PYTHONUNBUFFERED=1
RUN uv sync

COPY script.py .
ENTRYPOINT ["uv", "run", "script.py"]
