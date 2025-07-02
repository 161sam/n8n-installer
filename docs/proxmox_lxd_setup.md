# Running n8n-installer in a Proxmox LXD Container

This guide shows how to deploy the Docker based stack inside a lightweight LXD container on a Proxmox host.

1. **Install LXD** on your Proxmox server if it is not already available.
2. Execute `./proxmox-lxd-deployment.sh` as root. The script creates a container called `n8n-lxd` with sensible defaults (2 CPUs, 4GB RAM, 20GB disk).
3. The container is started and Docker is installed automatically. The repository is cloned to `/opt/n8n-installer` inside the container.
4. Attach to the container with `lxc exec n8n-lxd -- bash` and run:
   ```bash
   sudo bash /opt/n8n-installer/scripts/install.sh
   ```
5. Follow the interactive wizard to configure your domain and select services.
6. Once installation completes you can reach your instance via the configured sub‑domains (e.g., `n8n.yourdomain.com`).

If LXD is unavailable you can fall back to the VM deployment script `proxmox-vm-deployment.sh` which provisions a full virtual machine.
