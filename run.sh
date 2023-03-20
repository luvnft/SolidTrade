#!/usr/bin/env bash

# Converts to all lower. If not docker compose will not be very happy.
branch_name=${1,,}
environment_name=solidtrade-$branch_name
credentials_folder=$environment_name

# Select general development folder for feature branches
if [[ "$branch_name" != "stable" && "$branch_name" != "staging" ]]; then
  credentials_folder="solidtrade-development"
fi

# Copy configuration and credentials 
cp ~/projects/Rose-Linode/env/${credentials_folder}/.env '.'
cp ~/projects/Rose-Linode/env/${credentials_folder}/server/appsettings.credentials.json './server/WebAPI/Configuration'

# We do not require ngrok for production. This is why we scale down to 0.
# We also scale the api up to one, because its scaled to 0 by default for development.
docker compose --project-name $environment_name up -d --build --force-recreate --scale ngrok=0 --scale api=1
