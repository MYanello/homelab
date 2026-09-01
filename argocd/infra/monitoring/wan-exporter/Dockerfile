FROM ghcr.io/astral-sh/uv:0.12.8-python3.14-alpine@sha256:65b922d2241d4c54318c4140d5e380d10e75c608dae409a750c587aa466da077

WORKDIR /app

COPY pyproject.toml .

RUN apk add curl jq
ENV PYTHONUNBUFFERED=1
RUN uv sync

COPY script.py .
ENTRYPOINT ["uv", "run", "script.py"]
