#!/bin/bash
apt update && apt upgrade -y
apt install -y docker.io docker-compose unzip curl

mkdir -p /home/ubuntu/monitoring/{prometheus,grafana,loki}
cd /home/ubuntu/monitoring

cat > docker-compose.yml <<EOF
version: '3.7'
services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - 9090:9090
    networks:
      - monitoring
  grafana:
    image: grafana/grafana
    volumes:
      - ./grafana:/var/lib/grafana
    ports:
      - 3000:3000
    networks:
      - monitoring
  loki:
    image: grafana/loki:2.9.4
    command: -config.file=/etc/loki/loki-config.yml
    ports:
      - 3100:3100
    volumes:
      - ./loki:/loki
      - ./loki/loki-config.yml:/etc/loki/loki-config.yml
    networks:
      - monitoring
  promtail:
    image: grafana/promtail:2.9.4
    command: -config.file=/etc/promtail/promtail-config.yml
    volumes:
      - /var/log:/var/log
      - ./loki/promtail-config.yml:/etc/promtail/promtail-config.yml
    networks:
      - monitoring
networks:
  monitoring:
    driver: bridge
EOF

cat > prometheus/prometheus.yml <<EOF
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['10.0.1.211:9100']
  - job_name: 'nginx'
    static_configs:
      - targets: ['10.0.1.211:9113']
EOF

cat > loki/loki-config.yml <<EOF
auth_enabled: false
server:
  http_listen_port: 3100
  grpc_listen_port: 9095
  log_level: info
  chunk_target_size: 1048576
ingester:
  lifecycler:
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
  chunk_idle_period: 3m
  max_chunk_age: 1h
  chunk_retain_period: 30s
  wal:
    enabled: true
    dir: /loki/wal
limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h
schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h
storage_config:
  boltdb_shipper:
    active_index_directory: /loki/index
    cache_location: /loki/boltdb-cache
    shared_store: filesystem
  filesystem:
    directory: /loki/chunks
compactor:
  working_directory: /loki/compactor
  shared_store: filesystem
EOF

cat > loki/promtail-config.yml <<EOF
server:
  http_listen_port: 9080
  grpc_listen_port: 0
positions:
  filename: /tmp/positions.yaml
clients:
  - url: http://localhost:3100/loki/api/v1/push
scrape_configs:
  - job_name: varlogs
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          __path__: /var/log/syslog
EOF

docker-compose up -d
