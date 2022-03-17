#!/bin/sh
mkdir ./flutter-sdk && cd ./flutter-sdk

# Add Flutter
git clone -b flutter-2.8-candidate.20 https://github.com/flutter/flutter.git

# Add flutter to path
export PATH="$PATH:`pwd`/flutter/bin"

cd ../client/

# Create directory if it doesn't exist
mkdir -p ./assets/config

echo "---------------------"

echo $home

echo $test_home

echo $Firebase_Credentials

echo $App_Config

echo "---------------------"

# Write out the environment variable configuration as a json file
echo $App_Config | base64 --decode > ./assets/config/app_config.json

# Write out firebase credentials as js file
echo $Firebase_Credentials | base64 --decode > ./web/credentials.js

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