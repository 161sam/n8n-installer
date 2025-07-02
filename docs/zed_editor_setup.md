# Zed Editor Integration

The installer allows you to configure Zed as your primary development editor.
This lightweight editor offers collaborative features and AI assistance.

## Selecting the Editor

During the interactive service wizard a prompt appears asking if you want to
configure a development editor. Choose **Zed Editor (Native)** when prompted.
You can also run the selection later:

```bash
python scripts/editor_selection.py
```

This command generates an installation script under `editor-config/`. Execute
it with sudo privileges to install Zed system wide.

## Launching Zed

Once installed, launch the editor from your terminal:

```bash
zed ~/Projects/
```

Your projects directory is prepared by the installer inside `~/Projects/`.

For additional options visit the [official Zed documentation](https://zed.dev/docs/).
