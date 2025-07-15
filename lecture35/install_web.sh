#!/bin/bash
apt update && apt upgrade -y
apt install -y nginx unzip curl

systemctl enable nginx
systemctl start nginx

cat > /etc/nginx/conf.d/status.conf <<EOF
server {
    listen 80;
    location /status {
        stub_status;
        allow 127.0.0.1;
        allow 10.0.0.0/8;
        deny all;
    }
}
EOF

nginx -t && systemctl reload nginx

cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
tar -xzf node_exporter-1.8.1.linux-amd64.tar.gz
cp node_exporter-1.8.1.linux-amd64/node_exporter /usr/local/bin/
useradd -rs /bin/false nodeusr

cat > /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
After=network.target
[Service]
User=nodeusr
ExecStart=/usr/local/bin/node_exporter
[Install]
WantedBy=default.target
EOF

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

wget https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v0.11.0/nginx-prometheus-exporter_0.11.0_linux_amd64.tar.gz
tar -xzf nginx-prometheus-exporter_0.11.0_linux_amd64.tar.gz
cp nginx-prometheus-exporter /usr/local/bin/

cat > /etc/systemd/system/nginx-exporter.service <<EOF
[Unit]
Description=NGINX Prometheus Exporter
After=network.target
[Service]
ExecStart=/usr/local/bin/nginx-prometheus-exporter -nginx.scrape-uri http://localhost/status
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable nginx-exporter
systemctl start nginx-exporter
