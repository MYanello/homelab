FROM harbor.yanello.net/ghcr/astral-sh/uv:0.12.19-python3.14-alpine@sha256:b165481b747c340b4b3b820f6e453c3aea939c8b583cbfc01c4e99ec61181bc2

WORKDIR /app

COPY pyproject.toml .

RUN apk add curl jq
ENV PYTHONUNBUFFERED=1
RUN uv sync

COPY script.py .
ENTRYPOINT ["uv", "run", "script.py"]
