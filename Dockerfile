FROM python:3.12-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# PyPI is the official distribution. Rebuild with --no-cache to resolve latest again.
ARG SPECIFY_VERSION=latest
RUN if [ "$SPECIFY_VERSION" = latest ]; then \
      pip install --no-cache-dir --upgrade specify-cli; \
    else \
      pip install --no-cache-dir "specify-cli==$SPECIFY_VERSION"; \
    fi \
    && specify --help

ENV HOME=/tmp/specify-home \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1
RUN mkdir -p /tmp/specify-home && chmod 1777 /tmp/specify-home
WORKDIR /workspace
ENTRYPOINT ["specify"]
CMD ["--help"]
