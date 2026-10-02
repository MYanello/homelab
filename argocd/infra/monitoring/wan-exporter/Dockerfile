FROM harbor.yanello.net/ghcr/astral-sh/uv:0.12.22-python3.14-alpine@sha256:b8fa3140d3609e14bed5c02a9149e46062df1ffd735b2a977f98be3b894e2166

WORKDIR /app

COPY pyproject.toml .

RUN apk add curl jq
ENV PYTHONUNBUFFERED=1
RUN uv sync

COPY script.py .
ENTRYPOINT ["uv", "run", "script.py"]
