# Mosquitto MQTT Broker Setup on Ubuntu Server (Dockerized)
This README details the architecture, configuration, and usage of the Mosquitto MQTT broker running as a Docker container on your Ubuntu server (iMac).

## 1. Architecture Overview
Your Mosquitto MQTT broker is deployed using Docker Compose, providing a containerized, isolated, and easily manageable environment.

* Host System: Ubuntu Server running on a 2019 iMac.
* Containerization: Docker is used to run Mosquitto in a lightweight, self-contained environment.
* Orchestration: docker-compose.yml defines the Mosquitto service, its dependencies (like volumes), and network settings.
* Persistent Data: All critical Mosquitto data (configuration, message persistence, logs) are stored in dedicated directories on the host system, ensuring data is preserved even if the container is removed or updated.

### Directory Structure on your iMac Server:

The core files for your Mosquitto setup are located in: ```/home/andrew/mosquitto/```

Within this directory, you will find:

* ```docker-compose.yml```: Defines the Docker service.
* ```config/```: Contains the mosquitto.conf file.
* ```data/```: Stores Mosquitto's persistent message data (e.g., retained messages, queued messages for offline clients).
* ```log/```: Stores Mosquitto's log files.

## 2. Configuration Details
```docker-compose.yml```
This file, located at ```/home/andrew/mosquitto/docker-compose.yml```, defines the Mosquitto service:

```
version: '3.8'

services:
  mosquitto:
    image: eclipse-mosquitto:latest
    container_name: mosquitto
    restart: unless-stopped
    ports:
      - "1883:1883"  # MQTT standard port (TCP)
      - "9001:9001"  # MQTT over WebSockets (optional, useful for web apps)
    volumes:
      - ./config:/mosquitto/config # For mosquitto.conf
      - ./data:/mosquitto/data     # For persistent message data
      - ./log:/mosquitto/log       # For logs
    healthcheck:
      test: ["CMD", "sh", "-c", "mosquitto_pub -h localhost -p 1883 -t $$SYS/broker/version -m test || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### Key points:

* ```image```: eclipse-mosquitto:latest: Uses the latest stable Mosquitto Docker image.
* ```container_name```: mosquitto: Assigns a friendly name for easy management.
* ```restart```: unless-stopped: Ensures the container automatically restarts if it crashes or if the server reboots.
* ```ports```: Maps the standard MQTT port (1883) and WebSocket port (9001) from the host to the container.
* ```volumes```: Mounts the config, data, and log subdirectories from your host (/home/andrew/mosquitto/) into the corresponding paths inside the container, ensuring data persistence.

```mosquitto.conf```
This file, located at ```/home/andrew/mosquitto/config/mosquitto.conf``, controls Mosquitto's behaviour:

```
# mosquitto.conf - Basic configuration for Docker container

# Allow anonymous connections
# This is for easy testing on your local network.
# For any production environment or if exposed to the internet,
# set this to 'false' and configure proper authentication below.
allow_anonymous true

# Port to listen on for MQTT over TCP
listener 1883

# Optional: Listener for MQTT over WebSockets
# Uncomment the following two lines if you need MQTT over WebSockets
# (e.g., for web-based MQTT clients).
# listener 9001
# protocol websockets

# Persistence settings
# This ensures that messages (retained messages, queued messages)
# are saved to disk and restored across broker restarts.
persistence true
persistence_location /mosquitto/data/

# Log settings
# Logs will be written to /mosquitto/log/mosquitto.log inside the container,
# which is mapped to your host's ~/mosquitto/log/mosquitto.log.
log_dest file /mosquitto/log/mosquitto.log
log_type error
log_type warning
log_type notice
log_type information
connection_messages true # Log client connection/disconnection events
log_timestamp true       # Prepend a timestamp to log messages
```

Security Warning: The allow_anonymous true setting permits any client to connect without authentication. This is suitable for a trusted local network or testing environments only. For production or if the broker is exposed to the internet, you must change allow_anonymous to false and configure user authentication (e.g., with password_file and acl_file).

## 3. Usage

### Starting and Stopping the Broker
Navigate to the Mosquitto Docker project directory:

```cd /home/andrew/mosquitto```

* Start the Mosquitto container (detached mode):
```
docker compose up -d
```
This will pull the image (if not present) and start the container in the background.

* Stop the Mosquitto container:
```
docker compose stop
```
* Stop and remove the container (but keep volumes/data):
```
docker compose down
```
* View container logs:
```
docker logs mosquitto
```
* Check container status:
```
docker ps
```

### Autostart on Server Reboot
The Mosquitto broker is configured to automatically start when your iMac Ubuntu server reboots. This is due to:

1. Docker daemon being configured as a ```systemd``` service (default Ubuntu installation).
2. The ```restart: unless-stopped``` policy in your ```docker-compose.yml``` file.

## 4. MQTT Client Usage (Publishing and Subscribing)
You can interact with your Mosquitto broker using MQTT client tools. The ```mosquitto-clients``` package provides command-line utilities (```mosquitto_pub``` and ```mosquitto_sub```) which are excellent for testing.

### Install Mosquitto Clients (if not already installed on your server)

```
sudo apt update
sudo apt install -y mosquitto-clients
```

### Connect from the iMac Ubuntu Server (localhost)
Since the Mosquitto container's ports are mapped to your host, you can connect to localhost.

* To Subscribe to a Specific Topic:
Open a terminal session and run:

```
mosquitto_sub -h localhost -p 1883 -t "my/sensor/data" -v
```

* ```-h localhost```: Connects to the broker on the same machine.
* ```-p 1883```: Specifies the MQTT port.
* ```-t "my/sensor/data"```: The topic to subscribe to.
* ```-v```: Verbose mode, shows the topic along with the message.

To Publish to a Specific Topic:
Open a separate terminal session and run:
```
mosquitto_pub -h localhost -p 1883 -t "my/sensor/data" -m "Temperature: 25.5C"
```
* ```-m "..."```: The message payload.

You should see "Temperature: 25.5C" appear in your subscriber terminal.

### Subscribe to All Topics (Handy for Testing/Monitoring)
MQTT supports wildcards in subscriptions. The # (hash) symbol is a multi-level wildcard that matches any number of topic levels.

* To Subscribe to ALL Topics:
Open a terminal session and run:
```
mosquitto_sub -h localhost -p 1883 -t "#" -v
```

* ```-t "#"```: This tells the broker to send all messages on all topics to this subscriber.
* Note: By default, system topics (which start with ```$SYS/```) are not included when subscribing to ```#```. If you want to see system topics as well, you would need to subscribe to ```$SYS/#``` separately, or add it as another ```-t``` argument: ```mosquitto_sub -h localhost -p 1883 -t "#" -t "$SYS/#" -v```.

**Important**: Subscribing to all topics can generate a very high volume of messages on a busy broker. Use this primarily for debugging and monitoring purposes.

### Connect from Other Machines on Your Network
If you want to connect to your Mosquitto broker from another computer on your local network (e.g., your Mac Studio, a Raspberry Pi, or an IoT device), replace ```localhost``` with the IP address of your iMac Ubuntu server.

Example (from another machine, assuming iMac IP is ```192.168.2.10```):
```
mosquitto_sub -h 192.168.2.10 -p 1883 -t "home/+/status" -v
```