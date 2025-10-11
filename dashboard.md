# Network Monitoring Dashboard Guide

## Overview
This monitoring setup provides **real-time visibility** into the health and performance of the MitchellNET network infrastructure using **Prometheus**, **Grafana**, **Node Exporter**, **SNMP Exporter**, and **Blackbox Exporter** — all running in Docker containers on the  Ubuntu-based 2019 iMac server.

The stack allows you to track:
- System resource usage (CPU, RAM, Disk, Network)
- Device uptime and availability (via ICMP ping and SNMP)
- Network infrastructure performance (routers, switches, printers, IoT devices)
- Historical data trends through Grafana dashboards

---

## 1. Components Overview

### 🧠 Prometheus
Prometheus collects and stores time-series metrics from all exporters. It scrapes metrics every 15 seconds and retains them in a local database (`prometheus_data` volume).  
**Access URL:** [http://localhost:9090](http://localhost:9090)

Prometheus scrapes metrics from:
- **Itself** (`localhost:9090`)
- **Node Exporter** (system metrics)
- **SNMP Exporter** (network devices via SNMP)
- **Blackbox Exporter** (ICMP ping checks)

---

### 📊 Grafana
Grafana visualizes data collected by Prometheus through customizable dashboards. You can monitor device uptime, bandwidth usage, CPU load, and other performance indicators.  
**Access URL:** [http://192.168.10:3000](http://192.168.2.10:3000)

**Default login:**
- **Username:** `admin`
- **Password:** (set in `docker-compose.yml`)

Once logged in:
1. Navigate to **Connections → Data Sources → Prometheus** (should be preconfigured if provisioning is set up).
2. Open the **Dashboards** menu to explore or import network monitoring templates.
3. Use dashboard variables to filter by device or job name.

---

### ⚙️ Node Exporter
Monitors the host server’s hardware and OS metrics.  
**Metrics include:** CPU load, memory usage, disk I/O, filesystem stats, and network throughput.  
**Prometheus job:** `node_exporter`  
**Target:** `node-exporter:9100`

---

### 🌐 SNMP Exporter
Collects metrics from SNMP-enabled devices (routers, switches, printers, IoT devices, etc.).  
**Prometheus job:** `snmp_exporter`  
**Metrics path:** `/snmp`  
**Configured Devices:**  
| Device | IP Address | Description |
|---------|-------------|-------------|
| Bell Home Hub 3000 | 192.168.2.1 | Main internet gateway |
| TP-Link AC1200 | 192.168.2.2 | Wi-Fi access point (Archer A6) |
| TP-Link AC1750 | 192.168.2.3 | Wi-Fi access point (Archer C7) |
| Wavlink AC1200 | 192.168.2.4 | Mesh repeater |
| iMac Server (Ubuntu) | 192.168.2.10 | Host system |
| Raspberry Pi 4 | 192.168.2.21 | IoT node / test device |
| Tormach 770 S3 | 192.168.2.47 | CNC Mill |
| Tormach 15L Slant Pro | 192.168.2.48 | CNC Lathe |
| Brother MFC-J5855DW | 192.168.2.179 | Network printer |
| Bambu Labs Carbon X1 | 192.168.2.92 | 3D printer |
| Living Room TV | 192.168.2.206 | Smart TV |

---

### 📡 Blackbox Exporter
Performs network-level reachability checks (ping probes) for all listed devices.  
**Prometheus job:** `blackbox`  
**Metrics path:** `/probe`  

This module helps detect whether a device is **reachable** on the network and how long it takes to respond (latency).

---

## 2. Viewing Data in Grafana

### Example Dashboards
- **Node Exporter Overview:** See CPU, memory, and disk stats of the iMac server.
- **SNMP Devices Status:** Monitor uptime, interface throughput, and packet errors.
- **Network Reachability:** See ICMP ping results for all devices with color-coded availability.

### How to Import Dashboards
1. In Grafana, go to **Dashboards → Import**.
2. Use one of Grafana’s community dashboard IDs (e.g., `1860` for Node Exporter Full).
3. Set **Prometheus** as the data source.

### Example Visualization Ideas
- **Green = online**, **Red = offline**
- **Latency over time chart**
- **Per-device uptime panels**
- **Printer ink levels (if available over SNMP)**

---

## 3. Interpreting Metrics

| Metric Type | Exporter | What It Means |
|--------------|-----------|---------------|
| `up` | All | 1 = target reachable, 0 = unreachable |
| `node_cpu_seconds_total` | Node Exporter | CPU time spent in each mode |
| `node_memory_MemAvailable_bytes` | Node Exporter | Available memory |
| `ifInOctets` / `ifOutOctets` | SNMP Exporter | Bytes received/sent by an interface |
| `probe_success` | Blackbox Exporter | 1 = ping success, 0 = failure |
| `probe_duration_seconds` | Blackbox Exporter | Latency (ping time) |

---

## 4. Maintenance and Management

### Reload Prometheus Config
If you update `prometheus.yml`, reload the configuration without restarting the container:
```bash
curl -X POST http://localhost:9090/-/reload
```

### Restart a Service
```bash
docker compose restart prometheus
```

### Check Logs
```bash
docker logs prometheus --tail 50
docker logs grafana --tail 50
```

---

## 5. Backup and Data Retention
- **Prometheus Data:** Stored in the `prometheus_data` Docker volume.
- **Grafana Data:** Stored in the `grafana_data` Docker volume.
- Regularly back up these volumes to preserve dashboards and historical metrics.

---

## Summary
This is a complete **private network monitoring stack** that visualizes and alerts on the status of the MitchellNET network. It’s modular, extensible, and fully contained within the local environment — no internet connectivity required.

Monitor confidently knowing that the **data stays private** while maintaining **enterprise-grade observability** for the MitchellNET network.
