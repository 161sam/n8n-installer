#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PKGROOT="$SCRIPT_DIR/pkgroot"

# Clean previous build
rm -rf "$PKGROOT"
mkdir -p "$PKGROOT/DEBIAN"
mkdir -p "$PKGROOT/opt/n8n-installer"
mkdir -p "$PKGROOT/usr/local/bin"

# Copy DEBIAN control files
cp "$SCRIPT_DIR/DEBIAN/control" "$PKGROOT/DEBIAN/control"
cp "$SCRIPT_DIR/DEBIAN/postinst" "$PKGROOT/DEBIAN/postinst"
chmod 755 "$PKGROOT/DEBIAN/postinst"

# Copy project excluding git and packaging folder
rsync -a --exclude '.git' --exclude 'packaging' "$ROOT_DIR/" "$PKGROOT/opt/n8n-installer/"

# Wrapper executable
cat <<'EOS' > "$PKGROOT/usr/local/bin/n8n-installer"
#!/bin/bash
cd /opt/n8n-installer
sudo bash ./scripts/install.sh
EOS
chmod +x "$PKGROOT/usr/local/bin/n8n-installer"

# Build package
cd "$SCRIPT_DIR"
dpkg-deb --build pkgroot n8n-installer.deb
