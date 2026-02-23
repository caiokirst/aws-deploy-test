set -e
set -o pipefail

exec > >(tee /var/log/user-data-setup.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "[INFO] Starting security monitoring infrastructure provisioning..."

dnf update -y
dnf install -y rsyslog jq
systemctl enable rsyslog
systemctl start rsyslog
echo "[INFO] Basic system logging (rsyslog) configured."

dnf install -y docker
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

DOCKER_CONFIG=${DOCKER_CONFIG:-/usr/local/lib/docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
ln -s $DOCKER_CONFIG/cli-plugins/docker-compose /usr/bin/docker-compose
echo "[INFO] Docker and Docker Compose installed successfully."

mkdir -p /opt/wazuh
cd /opt/wazuh

cat << 'EOF' > docker-compose.yml
version: '3.8'
services:
  wazuh.indexer:
    image: wazuh/wazuh-indexer:4.7.2
    hostname: wazuh.indexer
    environment:
      - "OPENSEARCH_INITIAL_ADMIN_PASSWORD=SecretPass123!"
    volumes:
      - wazuh-indexer-data:/usr/share/wazuh-indexer/data
    healthcheck:
      test: ["CMD", "curl", "-k", "-f", "https://localhost:9200"]
      interval: 15s
      timeout: 5s
      retries: 5
    restart: always

  wazuh.manager:
    image: wazuh/wazuh-manager:4.7.2
    hostname: wazuh.manager
    depends_on:
      wazuh.indexer:
        condition: service_healthy
    environment:
      - INDEXER_URL=https://wazuh.indexer:9200
      - INDEXER_USERNAME=admin
      - INDEXER_PASSWORD=SecretPass123!
    volumes:
      - wazuh-manager-data:/var/ossec/data
      - wazuh-manager-logs:/var/ossec/logs
    healthcheck:
      test: ["CMD", "/var/ossec/bin/wazuh-control", "status"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: always

  wazuh.dashboard:
    image: wazuh/wazuh-dashboard:4.7.2
    hostname: wazuh.dashboard
    ports:
      - "443:5601"
    depends_on:
      wazuh.manager:
        condition: service_healthy
    environment:
      - INDEXER_USERNAME=admin
      - INDEXER_PASSWORD=SecretPass123!
    volumes:
      - wazuh-dashboard-config:/usr/share/wazuh-dashboard/data
    restart: always

volumes:
  wazuh-indexer-data:
  wazuh-manager-data:
  wazuh-manager-logs:
  wazuh-dashboard-config:
EOF

echo "[INFO] Starting Wazuh via Docker Compose..."

sysctl -w vm.max_map_count=262144

docker-compose up -d

echo "[INFO] Provisioning completed successfully!"