# Network Monitoring System README

This document outlines the architecture, components, monitored targets, and usage instructions for the Docker-based network monitoring system deployed on the Ubuntu server at ```192.168.2.10```.

## 1. Architecture Overview
This network monitoring system utilizes a standard open-source stack comprising Prometheus for data collection and storage, and Grafana for data visualization. Various "exporters" are employed to gather metrics from diverse sources and present them in a format compatible with Prometheus.

The data flow within the system is as follows:
1. Exporters: Lightweight agents (Node Exporter, Blackbox Exporter, SNMP Exporter) run on, or probe, target systems to collect specific types of metrics.
2. Prometheus: Periodically "scrapes" (pulls) these metrics from the exporters, stores them in its time-series database, and enables powerful querying capabilities.
3. Grafana: Connects to Prometheus as a data source, facilitating the creation and display of interactive dashboards to visualize the collected metrics.

## 2. Component Details
Each component fulfills a specific role within the monitoring pipeline:

* Prometheus (```prom/prometheus:latest```)
    * Role: The central monitoring server. It is responsible for discovering targets, scraping metrics via HTTP endpoints, storing them in its time-series database, and evaluating alerting rules.
    * Access: Accessible via ```http://192.168.2.10:9090```
* Grafana (```grafana/grafana:latest```)
    * Role: The visualization layer. It queries data from Prometheus and provides the functionality to build, view, and share rich, interactive dashboards.
    * Access: Accessible via ```http://192.168.2.10:3000```
* Node Exporter (```prom/node-exporter:latest```)
    * Role: Collects host-level metrics (CPU, memory, disk I/O, network I/O, system load, etc.) from the operating system where it runs. In this setup, it monitors the Ubuntu server itself.
    * Metrics Endpoint: ```http://192.168.2.10:9100/metrics```
* Blackbox Exporter (```prom/blackbox-exporter:latest```)
    * Role: Probes network endpoints using various protocols (HTTP, HTTPS, ICMP, TCP) to assess their availability and response times. This is used for "blackbox" monitoring, which tests external reachability without requiring an agent on the target.
* SNMP Exporter (```prom/snmp-exporter:latest```)
    * Role: Translates SNMP (Simple Network Management Protocol) data from network devices (e.g., routers, switches, printers) into Prometheus-compatible metrics.
    
## 3. Important Files and Locations
The monitoring system's configuration is primarily managed through a ```docker-compose.yml``` file, which orchestrates the containers, and Prometheus's configuration file. All paths are absolute, starting from the root of the file system.
* ```/home/andrew/network-monitoring/docker-compose.yml```
    * Description: This file defines and orchestrates all Docker services (containers) for the monitoring stack. It specifies Docker images, container names, port mappings, and network configurations.
* ```/home/andrew/network-monitoring/prometheus/prometheus.yml```
    * Description: This is the main configuration file for the Prometheus server. It defines the targets Prometheus should scrape, the scraping intervals, and any relabeling rules.
    * Key Sections:global: Defines global scrape and evaluation intervals.scrape_configs: Defines individual jobs for scraping metrics from different sources.
* ```/home/andrew/network-monitoring/grafana/provisioning/datasources/datasource.yml```
    * Description: This file is used by Grafana to automatically provision data sources upon startup, ensuring Prometheus is configured as a data source./
* ```home/andrew/network-monitoring/snmp_exporter/snmp.yml```
    * Description: This is the configuration file for the SNMP Exporter, defining the SNMP modules and community strings used for querying network devices.
* ```/home/andrew/network-monitoring/snmp-exporter-internal-config.yml```
    * Description: This file likely contains internal configuration for the SNMP Exporter, possibly defining additional modules or authentication details.
* ```/home/andrew/network-monitoring/snmp.yml```
    * Description: This file, located at the root of the ```/home/andrew/network-monitoring/``` directory, might be an additional SNMP configuration or a legacy file. Its specific purpose should be verified if it's referenced by any service.

## 4. Running Processes (Docker Containers)
The following Docker containers are running on the Ubuntu server at 192.168.2.10, collectively forming the network monitoring system:

| Container Name    | Image                         | Exposed Ports (Host -> Container) | Role                                                                      |
| ----------------- | ----------------------------- | --------------------------------- | ------------------------------------------------------------------------- |
| grafana           | grafana/grafana:latest        | 3000 -> 3000/tcp                  | Provides the web UI for data visualization and dashboards.                |
| prometheus        | prom/prometheus:latest        | 9090 -> 9090/tcp                  | The core monitoring server, responsible for scraping and storing metrics. |
| snmp-exporter     | prom/snmp-exporter:latest     | 9116 -> 9116/tcp                  | Translates SNMP data from network devices into Prometheus metrics.        | 
| blackbox-exporter | prom/blackbox-exporter:latest | 9115 -> 9115/tcp                  | Probes network endpoints for availability and response time.              |
| node-exporter     | prom/node-exporter:latest     | 9100 -> 9100/tcp                  | Collects host-level metrics from the Ubuntu server itself.                |

## 5. Monitored Targets
Based on the ```prometheus.yml``` configuration, the following targets are currently being monitored:
* Ubuntu Server (Host-Level Metrics):
    * Method: Monitored by ```node-exporter```.
    * Metrics: CPU usage, memory utilization, disk I/O, network traffic, system load, filesystem usage, process statistics, and more.
    * Prometheus Job: ```node_exporter``` (targets ```node-exporter:9100```)
* Network Endpoints (Reachability/Latency):
    * Method: Probed by ```blackbox-exporter``` using the ```icmp``` module (ping).
    * Targets:
        * ```example.com```
        * ```google.com```
        * ```192.168.1.1``` (typically a router/gateway)
        * ```your_internal_server``` (placeholder; should be replaced with an actual internal server IP/hostname)
    * Prometheus Job: ```blackbox``` (targets ```blackbox-exporter:9115```)
* Network Devices (SNMP Data):
    * Method: Monitored by ```snmp-exporter``` using the ```if_mib``` module (interface MIB).
    * Target: ```192.168.2.10:161``` (Currently configured to probe the Ubuntu server's IP address on the standard SNMP port. Other SNMP-enabled devices can be added here.)
    * Prometheus Job: ```snmp_exporter``` (targets ```snmp-exporter:9116```)
* Prometheus Server Internal Metrics:
    * Method: Prometheus monitors its own internal performance and operational metrics.
    * Prometheus Job: ```prometheus``` (targets ```localhost:9090``` from Prometheus's perspective)
    
## 6. How to View and Use the Monitoring System

### A. Accessing Grafana (Dashboards & Visualization)

1. Open a web browser and navigate to: ```http://192.168.2.10:3000```
2. Log in:
    * Username: admin
    * Password: The administrator password set during setup (MyGerafanaPassword!).
3. View Dashboards:
    * Once logged in, click on the "Dashboards icon" (four squares) in the left sidebar.
    * Select "Browse".
    * Locate and click on the desired dashboard (e.g., "Node Exporter Full" for host metrics).
    * On the dashboard, verify the "instance" dropdown (if present) is set to the correct target (e.g., ```node-exporter:9100```) to view specific device metrics.
    
### B. Accessing Prometheus UI (Raw Metrics & Targets)
1. Open a web browser and navigate to: ```http://192.168.2.10:9090```
2. View Scrape Targets:
    * In the top navigation bar, click on "Status" then select "Targets".
    * This page displays all configured scrape jobs and their current status (UP or DOWN), indicating successful or unsuccessful data collection.
3. Query Metrics:
    * Navigate to the "Graph" tab.
    * In the expression input box, enter PromQL queries to explore raw metrics (e.g., ```node_memory_MemFree_bytes```, ```probe_success```, ```snmp_ifInOctets```).
    * Click "Execute" to view the results.
### C. Managing Docker Containers
To manage the running containers (e.g., restarting a service after a configuration change), access the server's terminal:
1. Open a terminal on the Ubuntu server.
2. Navigate to the monitoring system's directory: ```cd /home/andrew/network-monitoring```
3. Restart a specific service (e.g., Prometheus after ```prometheus.yml``` changes): ```docker restart prometheus```
4. Restart all services (if using ```docker-compose```): ```docker-compose restart```
5. View running containers: ```docker ps```

### 7. Adding New Devices to Monitor
To expand the monitoring system to include new devices, follow these general steps:
1. Identify the Monitoring Method: Determine how the new device will be monitored.
    * Host-level metrics (Linux/Windows servers): Use Node Exporter.
    * Network device metrics (routers, switches, printers): Use SNMP Exporter.
    * Website/Service Uptime (ping, HTTP checks): Use Blackbox Exporter.
2. Configure the Exporter (if necessary):
    * Node Exporter: Deploy Node Exporter on the target server. If it's another Docker host, Node Exporter can be run in a container, exposing port 9100. If it's a bare-metal server, install Node Exporter directly. Ensure its metrics endpoint is accessible from the Prometheus server.
    * SNMP Exporter: If the device requires a custom SNMP module not already defined in ```/home/andrew/network-monitoring/snmp_exporter/snmp.yml```, it may need to be added. Verify if ```/home/andrew/network-monitoring/snmp-exporter-internal-config.yml``` is used for module definitions.
    * Blackbox Exporter: No additional configuration is needed for the exporter itself; simply add targets to Prometheus.
3. Update Prometheus Configuration (```/home/andrew/network-monitoring/prometheus/prometheus.yml```):
    * Edit the ```prometheus.yml``` file to add a new ```scrape_configs``` job for the new device.
    * Example: Adding a new Linux server (Node Exporter target)
    ```
    # ... existing scrape_configs ...

    - job_name: 'new_linux_server_node'
    static_configs:
      - targets: ['<NEW_SERVER_IP>:9100'] # Replace with the actual IP and Node Exporter port
        labels:
          instance: 'new-linux-server' # A descriptive name
    ```
    * Example: Adding a new network device (SNMP Exporter target)# ... existing scrape_configs ...
    ```
    - job_name: 'new_network_device_snmp'
    metrics_path: /snmp
    params:
      module: [if_mib] # Or other relevant SNMP modules
      auth: [public_v2] # Or the device's SNMP community string
    static_configs:
      - targets:
          - <NEW_DEVICE_IP>:161 # Replace with the actual IP and SNMP port
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: snmp-exporter:9116 # Point to the SNMP Exporter container
    ```
    * Example: Adding a new website/service for uptime monitoring (Blackbox Exporter target)# ... existing scrape_configs ...
    ```
    - job_name: 'new_website_uptime'
    metrics_path: /probe
    params:
      module: [icmp] # Or http, tcp, etc.
    static_configs:
      - targets:
          - <NEW_WEBSITE_OR_IP> # Replace with the actual URL or IP
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: blackbox-exporter:9115 # Point to the Blackbox Exporter container
    ```
4. Restart Prometheus:
After modifying ```prometheus.yml```, restart the Prometheus Docker container for changes to take effect:
    ```
    cd /home/andrew/network-monitoring
    docker restart prometheus
    ```
5. Verify in Prometheus UI:
    * Access ```http://192.168.2.10:9090/targets``` and confirm the new target is ```UP```.
6. Create/Update Grafana Dashboards:
    * In Grafana (```http://192.168.2.10:3000```), new dashboards can be created or existing ones modified to include metrics from newly added devices.
    * If using a pre-built dashboard (like Node Exporter Full), the new instance should automatically appear in the "instance" dropdown once Prometheus starts scraping it.