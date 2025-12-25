# iMac Ubuntu Server Setup
This document outlines the current configuration and key features of your Ubuntu server running on your 2019 iMac, primarily focusing on remote access and web hosting capabilities.

1. Operating System & Hardware
   * OS: Ubuntu 24.04.2 LTS
   * Hardware: 2019 iMac (acting as a server)

2. Remote Access (SSH) Configuration

Your SSH access is currently configured as follows:

* SSH Port: SSH is running on the default port 22.
   * To connect: ```ssh andrew@192.168.2.10```
   * Root Login Disabled: Direct login as the ```root``` user is disabled. Always log in with your ```andrew``` user and use ```sudo``` for administrative tasks.
   * Password Authentication Enabled: You can currently log in using your password.
   * Login Banner: A custom login banner is displayed upon successful SSH connection, providing a welcome message and security notice. This banner is configured in ```/etc/ssh/sshd_config``` and the message content is in ```/etc/issue.net```. IO used [this](https://patorjk.com/software/taag/#p=display&f=RubiFont&t=MitchellNet) online editor and the ```RubiFont``` to make the MitchellNET logo.

3. Network Configuration
The server has been assigned a fixed IP address for consistent access:

* Static IP Address: 192.168.2.10
* Configuration Method: Netplan (via /etc/netplan/00-installer-config.yaml)

4. Docker Environment
Docker and Docker Compose (v2) are installed and configured for containerized applications:

* Docker Engine: Installed and running.
* Docker Compose (v2): Installed as a plugin for the docker CLI (accessed via docker compose, no hyphen).
* Docker Group: Your user (andrew) is part of the docker group, allowing you to run Docker commands without sudo.

5. Secure Web Server (Nginx Docker Container)
A secure Nginx web server is running in a Docker container, configured to serve static HTML, CSS, and JavaScript files over HTTPS.

* Purpose: To host your web pages securely.
* Container Name: my-secure-web-server
* HTTPS Port: The server is accessible via HTTPS on port 443.
* SSL Certificate: Uses a self-signed SSL certificate located on the host at /home/andrew/web_server/ssl/. Browsers will show a warning due to it being self-signed, but the connection is encrypted.
* Configuration: Nginx is configured using default.conf located on the host at /home/andrew/web_server/nginx/conf.d/.

## Web Content Directory
Your web server content (HTML, CSS, JavaScript, images, etc.) is located on the host machine at:

```/home/andrew/web_server/html/```

This directory is mounted directly into the Nginx container, so any changes you make here will be immediately reflected by the web server.

## Docker Compose Management

The Nginx web server is managed using Docker Compose.

* docker-compose.yml location: /home/andrew/web_server/docker-compose.yml
* To start the web server:
```
cd /home/andrew/web_server/
docker compose up -d
```

* To stop the web server:
```
cd /home/andrew/web_server/
docker compose down
```
* To restart the web server (e.g., after Nginx config changes):
```
cd /home/andrew/web_server/
docker compose restart nginx
```
6. Updating Web Content via SFTP
You can easily upload and manage your web pages using SFTP:

    * SFTP Client: Use any SFTP client (e.g., FileZilla, Cyberduck, WinSCP, or command-line sftp).
    * Connection Details:
    ** Host: 192.168.2.10
    ** Username: andrew
    ** Password: Your Ubuntu server password (or use your SSH key if configured in your SFTP client).
    ** Port: 22 (default SSH port).
    ** Protocol: SFTP (SSH File Transfer Protocol).
    ** Target Directory: Once connected, navigate to /home/andrew/web_server/html/ on the remote server. Upload your HTML, CSS, JS, and image files here.

7. Future Expansion
This setup provides a solid foundation for more complex applications:

    * Python App with SQL: In the future, you can add Docker containers for your Python application and a SQL database (e.g., PostgreSQL, MySQL) to the same docker-compose.yml file. Nginx can then be configured as a reverse proxy to direct specific API requests to your Python application.

8. Important Notes & Troubleshooting
   * Firewall: Ensure your server's firewall (UFW) allows incoming connections on port 443 (for HTTPS) and your SSH port (22).
   * Self-Signed Certificate: Remember the browser warnings are expected due to the self-signed SSL certificate. For a production environment, consider obtaining a certificate from a trusted Certificate Authority (e.g., Let's Encrypt).
   * /srv Directory Issue: We encountered a persistent and unusual "read-only file system" error when trying to use /srv/web_server. Moving the project to /home/andrew/web_server resolved this, indicating a specific (though undiagnosed) interaction issue with the /srv path on your system. Stick to /home/andrew/web_server for your web content.

9. Steps to Improve Security
To further enhance the security of your server, consider implementing the following:

* Change Default SSH Port:
Changing the default SSH port from 22 to a non-standard port (e.g., 2222, or any port between 1024 and 65535 not in use) significantly reduces automated scanning attempts.
   1. Edit /etc/ssh/sshd_config:
```
sudo nano /etc/ssh/sshd_config
```
   2. Find the line #Port 22, uncomment it, and change 22 to your desired port (e.g., Port 2222).
   3. Save and exit nano (Ctrl+X, Y, Enter).
   4. Allow the new port through your firewall (UFW):
```
sudo ufw allow <your_new_port>/tcp
sudo ufw delete allow 22/tcp # Optional: to close port 22
sudo ufw reload
```
   5. Restart the SSH service:
```
sudo systemctl restart sshd
```
   6. Update your SSH client connection command to use the new port: ssh -p <your_new_port> andrew@192.168.2.10

* Disable Password Authentication (Use SSH Keys Only):
This is the most secure method for SSH access, as it relies on cryptographic keys instead of passwords, which are vulnerable to brute-force attacks.

   1. Generate SSH Key Pair on your local machine (if you haven't already):
```
ssh-keygen -t rsa -b 4096
```
Follow prompts, set a strong passphrase for your private key.
   2. Copy Public Key to Server:
```
ssh-copy-id -p <your_ssh_port> andrew@192.168.2.10
```
(Replace <your_ssh_port> with your custom port, or omit -p if still using 22). You will be prompted for your andrew user's password on the server one last time.
   3. Test SSH Key Login: Open a new terminal and try to connect using your key. Ensure it works before disabling password authentication.
```
ssh -p <your_ssh_port> andrew@192.168.2.10
```
   4. Disable Password Authentication in /etc/ssh/sshd_config:
```
sudo nano /etc/ssh/sshd_config
```
   5. Find the line #PasswordAuthentication yes, uncomment it, and change yes to no.
```
PasswordAuthentication no
```
   6. Save and exit nano (Ctrl+X, Y, Enter).
   7. Restart the SSH service:
```
sudo systemctl restart sshd
```
   8. Immediately test your SSH key login again from a new terminal to ensure you haven't locked yourself out.
