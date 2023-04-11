#!/bin/bash

# Get ngrok container url
container_id=$(docker ps | grep "solidtrade.*ngrok" | xargs)
container_id=$(echo $container_id | cut -d' ' -f1)

echo "The container ID is: $container_id"

# Get the URL from the container logs
url=$(docker logs $container_id 2>&1 | grep "https://.*ngrok.*" | tail -n1 | sed 's/.*url=https:\/\/\(.*\)/\1/')

echo "The URL is: $url"

cp assets/config/config.example.yml assets/config/config.yml
sed -i "s/^baseUrl:.*/baseUrl: $url/" assets/config/config.yml

echo "config.yml updated successfully!"
echo "Happy coding!"