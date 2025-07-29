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
redef LogAscii::use_json = T;
redef LogAscii::json_timestamps = JSON::TS_EPOCH;
EOF

# KIBANA CONFIG (NO xpack.security.enabled HERE)
sudo tee /mnt/big/Docker/corelight/kibana.yml >/dev/null <<'EOF'
server.publicBaseUrl: "http://localhost:5601"
elasticsearch.hosts: ["http://elasticsearch:9200"]

xpack.security.encryptionKey: "some-32+ char random string"
xpack.encryptedSavedObjects.encryptionKey: "another-32+ char string"
xpack.reporting.encryptionKey: "another-32+ char string"

EOF

# FILEBEAT CONFIG (ZEEK + SURICATA -> ES)
sudo tee /mnt/big/Docker/corelight/filebeat.yml >/dev/null <<'EOF'
filebeat.inputs:
  - type: log
    enabled: true
    paths: ["/logs/zeek/*.log"]
    json.keys_under_root: true
    json.add_error_key: true
    fields: { log_type: zeek }

  - type: log
    enabled: true
    paths: ["/logs/suricata/eve.json"]
    json.keys_under_root: true
    json.add_error_key: true
    fields: { log_type: suricata }

processors:
  - timestamp:
      when: { equals: { fields.log_type: zeek } }
      field: ts
      layouts: ["UNIX"]
      target_field: "@timestamp"
      ignore_failure: true
  - timestamp:
      when: { equals: { fields.log_type: suricata } }
      field: timestamp
      layouts: ["RFC3339","2006-01-02T15:04:05Z07:00"]
      target_field: "@timestamp"
      ignore_failure: true

output.elasticsearch:
  hosts: ["http://elasticsearch:9200"]
  index: "corelight-%{[fields.log_type]}-%{+yyyy.MM.dd}"

setup.ilm.enabled: false
setup.kibana.host: "http://kibana:5601"
logging.level: info

setup.template.name: "corelight"
setup.template.pattern: "corelight-*"

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
