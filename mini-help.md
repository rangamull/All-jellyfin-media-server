## **4. Installation with VPN (no-Nvidia)**

> [!WARNING]  
> If you use this method, fill in the `.env` file located in `compose_files/VPN`.

Standard installation with a `VPN`:

To start the installation, execute :

```bash
cd compose_files/VPN-Only
sudo docker docker-compose -f docker-compose-surfshark-vpn.yaml up -d
sudo docker-compose -f docker-compose-surfshark-vpn.yaml restart
```

# **Accessing Applications**

Once the applications are deployed, you can access them using the following addresses :

> [!IMPORTANT]  
> Replace `localhost` with the IP address of your machine or remote server if needed.


* Jellyfin : http://localhost:8096
* Jellyseer : http://localhost:5055
* Sonarr : http://localhost:8989
* Radarr : http://localhost:7878
* Jackett : http://localhost:9117
* Prowlarr : http://localhost:9696
* qBittorrent : http://localhost:8080

Gluetun (Nord VPN) will be automatically configured to be used with the applications.


7Rd2x5sxk