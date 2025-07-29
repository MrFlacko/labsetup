## Paths that will be used
# /mnt/big/Docker/corelight/
#   filebeat.yml
#   zeek-local.zeek
#   zeek-logs/            (data)
#   suricata-logs/        (data)
#   elasticsearch-data/   (data)

sudo mkdir -p /mnt/big/Docker/corelight/{zeek-logs,suricata-logs,elasticsearch-data}

# KERNEL REQ FOR ES
sudo sysctl -w vm.max_map_count=262144

# ZEEK JSON CONFIG
sudo tee /mnt/big/Docker/corelight/zeek-local.zeek >/dev/null <<'EOF'
@load policy/tuning/json-logs
EOF

# KIBANA CONFIG (NO xpack.security.enabled HERE)
# random charactors gets rid of the openssl warnings
sudo tee /mnt/big/Docker/corelight/kibana.yml >/dev/null <<'EOF'
server.publicBaseUrl: "http://localhost:5601"
elasticsearch.hosts: ["http://elasticsearch:9200"]

xpack.security.encryptionKey: aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
xpack.encryptedSavedObjects.encryptionKey: bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
xpack.reporting.encryptionKey: cccccccccccccccccccccccccccccccc

EOF

# FILEBEAT CONFIG (ZEEK + SURICATA -> ES)
sudo tee /mnt/big/Docker/corelight/filebeat.yml >/dev/null <<'EOF'
filebeat.modules:
  - module: zeek
    connection:
      enabled: true
      var.paths: ["/logs/zeek/conn.log*"]
    dns:
      enabled: true
      var.paths: ["/logs/zeek/dns.log*"]
    http:
      enabled: true
      var.paths: ["/logs/zeek/http.log*"]
    ssl:
      enabled: true
      var.paths: ["/logs/zeek/ssl.log*"]
    notice:
      enabled: true
      var.paths: ["/logs/zeek/notice.log*"]
    files:
      enabled: true
      var.paths: ["/logs/zeek/files.log*"]
    # add more Zeek logs as you like (weird, x509, etc.)

  - module: suricata
    eve:
      enabled: true
      var.paths: ["/logs/suricata/eve.json*"]

# Keep defaults so dashboards/pipelines load correctly
output.elasticsearch:
  hosts: ["http://elasticsearch:9200"]

setup.kibana.host: "http://kibana:5601"
setup.ilm.enabled: true
strict.perms: false
logging.level: info
EOF

# PERMISSIONS (ES needs uid 1000; logs OK as root)
sudo chown -R 1000:1000 /mnt/big/Docker/corelight/elasticsearch-data
sudo chown -R root:root  /mnt/big/Docker/corelight/{zeek-logs,suricata-logs}
sudo chmod go-w /mnt/big/Docker/corelight/filebeat.yml
sudo chmod -R 775 /mnt/big/Docker/corelight

### ONCE RUNNING. Do these commands###
# Create the Data View
curl -s -X POST http://localhost:5601/api/data_views/data_view \
  -H 'kbn-xsrf: true' -H 'Content-Type: application/json' \
  -d '{"data_view":{"title":"corelight-*","name":"Corelight","timeFieldName":"@timestamp"}}'

# Create a 30-day ILM policy
curl -X PUT http://localhost:9200/_ilm/policy/corelight-30d \
  -H 'Content-Type: application/json' -d '{"policy":{"phases":{"hot":{"actions":{}},"delete":{"min_age":"30d","actions":{"delete":{}}}}}}'

# Attach it to a template for corelight-* (new indices will use it)
curl -X PUT http://localhost:9200/_index_template/corelight-template \
  -H 'Content-Type: application/json' -d '{
    "index_patterns":["corelight-*"],
    "data_stream": { },
    "template": { "settings": { "index.lifecycle.name": "corelight-30d" } }
}'

# This command can take 5 minutes to load dashboards
docker exec -it filebeat filebeat setup --dashboards

