#!/bin/bash
echo "Restarting SNMP Exporter container..."
docker stop snmp-exporter 2>/dev/null
docker rm snmp-exporter 2>/dev/null
docker run -d   --name snmp-exporter   -p 9116:9116   prom/snmp-exporter:latest
echo "SNMP Exporter is now running on port 9116."
