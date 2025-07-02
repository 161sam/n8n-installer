#!/bin/bash

# Proxmox LXD Container Deployment for n8n-installer
# Creates a lightweight LXD container and installs the workspace

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
}

check_environment() {
  if [ ! -d /etc/pve ]; then
    log_error "This script must run on a Proxmox host"
    exit 1
  fi
  if ! command -v lxc >/dev/null; then
    log_error "LXD is not installed. Please install it first"
    exit 1
  fi
}

create_container() {
  local name=$1
  local memory=$2
  local cpus=$3
  local disk=$4

  log_info "Launching container $name"
  lxc launch images:ubuntu/24.04 "$name" \
    -c limits.memory="${memory}MB" \
    -c limits.cpu="$cpus" \
    -c root.size="${disk}GB"
  log_success "Container created"
}

prepare_container() {
  local name=$1
  log_info "Installing docker and cloning repository"
  lxc exec "$name" -- bash -c "apt-get update && apt-get install -y docker.io docker-compose git"
  lxc exec "$name" -- bash -c "git clone https://github.com/161sam/n8n-installer /opt/n8n-installer"
  log_success "Container prepared"
  echo
  echo "Attach with: lxc exec $name -- bash"
  echo "Then run: sudo bash /opt/n8n-installer/scripts/install.sh"
}

main() {
  check_environment

  local name=${1:-n8n-lxd}
  local memory=${2:-4096}
  local cpus=${3:-2}
  local disk=${4:-20}

  create_container "$name" "$memory" "$cpus" "$disk"
  prepare_container "$name"
}

main "$@"
