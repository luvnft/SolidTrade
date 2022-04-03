#!/bin/sh

cat /etc/os-release

sudo apt-get install xz-utils

# Load flutter sdk
curl https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_2.10.3-stable.tar.xz --output flutter-sdk.tar.xz

ls

tar -xf ./flutter-sdk.tar.xz

ls ./flutter/bin

# Add flutter to path
export PATH="$PATH:`pwd`/flutter/bin"

cd ../client/

# Create directory if it doesn't exist
mkdir -p ./assets/config

# Write out the environment variable configuration as a json file
echo $App_Config | base64 -di > ./assets/config/app_config.json

# Write out firebase credentials as js file
echo $Firebase_Credentials | base64 -di > ./web/credentials.js

# Install dependencies
flutter pub get

# Generate mappings
flutter pub run build_runner build

# Build web app
if [ "$Deployment" = "Production" ];
then
  flutter build web --release -t lib/main/main_prod.dart
else
  flutter build web --release -t lib/main/main_staging.dart
fi
