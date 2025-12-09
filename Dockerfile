FROM debian:buster-slim

RUN apt update && apt upgrade -y && \
    apt install -y \
    libvips-tools \
    aria2 \
    curl \
    wget \
    tzdata \
    jq \
    python3 \
    python3-dev \
    python3-venv \
    ffmpeg \
    libreoffice \
    supervisor

WORKDIR /app
RUN chmod 777 /app

ENV VIRTUAL_ENV=/app/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir \
    lxml \
    requests \
    webdavclient3

RUN mkdir -p /aria2/data && \
    chmod 777 /aria2/data

RUN mkdir -p /app/data/avatar /app/data/temp /app/data/uploads && \
    touch /app/data/cloudreve.db /app/data/cache_persist.bin && \
    chmod -R 777 /app/data

COPY aicd ./aicd
RUN chmod +x ./aicd

COPY conf.ini /app/conf.ini
COPY sync_data.sh /app/sync_data.sh
RUN chmod +x /app/sync_data.sh

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

CMD ["/bin/sh", "-c", "./sync_data.sh & sleep 30 && ./start.sh"]
