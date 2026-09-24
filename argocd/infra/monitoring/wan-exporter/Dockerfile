FROM harbor.yanello.net/ghcr/astral-sh/uv:0.12.18-python3.14-alpine@sha256:95e4e621673cb57665d273bb34652e1c452233afc109c1bd83af694ae4f1ab57

WORKDIR /app

COPY pyproject.toml .

RUN apk add curl jq
ENV PYTHONUNBUFFERED=1
RUN uv sync

COPY script.py .
ENTRYPOINT ["uv", "run", "script.py"]
