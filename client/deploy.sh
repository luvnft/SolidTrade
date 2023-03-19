#!/bin/sh

# Add Flutter
git clone -b 3.7.3 https://github.com/flutter/flutter/ flutter-sdk
export PATH="$PATH:`pwd`/flutter-sdk/bin"

flutter doctor

echo "$VERCEL_GIT_COMMIT_REF"
echo "$VERCEL_GIT_COMMIT_REF"
echo "$VERCEL_GIT_COMMIT_REF"

# Create config directory if it doesn't exist
mkdir -p ./assets/config

# Create configuration file
echo $App_Config | base64 -di > ./assets/config/config.yml

VERSION="v4.32.1"
BINARY="yq_linux_amd64"

yum install wget
wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY} -O yq
chmod +x yq

# Update base api url
./yq e '.baseUrl = "urlhere"' ./assets/config/config.yml > ./assets/config/config.yml

# Install dependencies
flutter pub get

# Generate mappings
flutter pub run build_runner build --delete-conflicting-outputs

# Build app
flutter build web --release
