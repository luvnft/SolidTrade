#!/bin/sh
mkdir ./flutter-sdk && cd ./flutter-sdk

# Add flutter
git clone -b flutter-2.8-candidate.20 https://github.com/flutter/flutter.git

# Add flutter to path
export PATH="$PATH:`pwd`/flutter/bin"

cd ../client/

echo "--------"

ls

echo "--------"

# Create directory if it doesn't exist
mkdir -p ./assets/config

# Write out the environment variable configuration as a json file
echo $APP_CONFIG | base64 --decode > ./assets/config/app_config.json

ls ./lib/


echo "--------"

# Generate mappings
flutter pub run build_runner build

ls ./lib/

# Build web app
if [ "$1" = "production" ]; 
then
  flutter build web --release -t lib/main/main_prod.dart --no-sound-null-safety
else
  flutter build web --release -t lib/main/main_staging.dart --no-sound-null-safety
fi