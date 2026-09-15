FROM harbor.yanello.net/ghcr/astral-sh/uv:0.12.13-python3.14-alpine@sha256:eb47c391d3a252d9d912270dd2b5e234af5493e92039fedb483f1dd1cb5659ce

WORKDIR /app

COPY pyproject.toml .

RUN apk add curl jq
ENV PYTHONUNBUFFERED=1
RUN uv sync

COPY script.py .
ENTRYPOINT ["uv", "run", "script.py"]
