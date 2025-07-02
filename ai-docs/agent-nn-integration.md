# Agent-NN Integration

The installer now includes the [Agent-NN](https://github.com/EcoSphereNetwork/Agent-NN) framework. It provides a dispatcher, registry, session manager, vector store and several worker services.

## Usage

1. Set `AGENTNN_HOSTNAME` in your `.env` file and add `agent-nn` to `COMPOSE_PROFILES`.
2. Start the services with `docker compose up -d` or run the installation script.
3. Access the API at `agentnn.yourdomain.com` via Caddy.

To use the n8n node provided by Agent-NN, navigate to `integrations/n8n-agentnn` in the Agent-NN repository, run `npm install && npx tsc`, and copy the files from `dist/` to your `~/.n8n/custom` directory.
