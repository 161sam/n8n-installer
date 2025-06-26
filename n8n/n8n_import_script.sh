#!/bin/sh

# Exit immediately if neither import flag is set to true
if [ "$RUN_N8N_IMPORT" != "true" ] && [ "$RUN_MODULARIUM_IMPORT" != "true" ]; then
  echo 'Skipping n8n import based on environment variables.'
  exit 0
fi

set -e

if [ "$RUN_N8N_IMPORT" = "true" ]; then
  echo 'Importing credentials...'
  find /backup/credentials -maxdepth 1 -type f -not -name '.gitkeep' -print -exec sh -c '
    echo "Attempting to import credential file: $1";
    n8n import:credentials --input="$1" || echo "Error importing credential file: $1"
  ' sh {} \;

  echo 'Importing community workflows...'
  find /backup/workflows -maxdepth 1 -type f -not -name '.gitkeep' -print -exec sh -c '
    echo "Attempting to import workflow file: $1";
    n8n import:workflow --input="$1" || echo "Error importing workflow file: $1"
  ' sh {} \;
fi

if [ "$RUN_MODULARIUM_IMPORT" = "true" ]; then
  echo 'Importing Modularium workflows...'
  find /modularium-workflows -maxdepth 1 -type f -not -name '.gitkeep' -print -exec sh -c '
    echo "Attempting to import workflow file: $1";
    n8n import:workflow --input="$1" || echo "Error importing workflow file: $1"
  ' sh {} \;
fi

