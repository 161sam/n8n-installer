# Building the n8n-installer Debian package

This directory contains files to create a simple `.deb` package for the
n8n-installer project. The resulting package copies the repository to
`/opt/n8n-installer` and runs the included installation scripts to set up
required dependencies.

## Build the package

Run the `build.sh` script inside `packaging/deb`:

```bash
cd packaging/deb
./build.sh
```

After the script finishes, you will have `n8n-installer.deb` in the same
folder which can be installed with `dpkg -i`.
