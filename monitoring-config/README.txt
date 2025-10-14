MONITORING CONFIGURATION (MitchellNET)

Services:
  - Grafana:        http://192.168.2.10:3000
  - Prometheus:     http://192.168.2.10:9090
  - Node Exporter:  http://192.168.2.10:9100
  - SNMP Exporter:  http://192.168.2.10:9116
  - Blackbox:       http://192.168.2.10:9115

Setup Steps:
1. Copy prometheus.yml into your Prometheus config directory or bind mount it.
   Typical path (Docker-based setup):
     /etc/prometheus/prometheus.yml
   or inside your Prometheus Docker volume (often mounted at):
     /home/andrew/prometheus/prometheus.yml
2. Restart Prometheus:
   docker restart prometheus
3. In Grafana → Connections → Data Sources → Import, upload grafana-datasource.json.
4. (Optional) To restart SNMP Exporter anytime:
   bash snmp-exporter-docker-run.sh
5. Verify Prometheus targets:
   http://192.168.2.10:9090/targets
   All should show as “UP”.
