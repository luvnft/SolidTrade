#!/bin/sh

cd client

# Install flutter
git clone -b 3.7.10 https://github.com/flutter/flutter/ flutter-sdk
export PATH="$PATH:`pwd`/flutter-sdk/bin"

flutter doctor

# Create config directory if it doesn't exist
mkdir -p ./assets/config

# Create configuration file
echo $App_Config | base64 -di > ./assets/config/config.yml

VERSION="v4.32.1"
BINARY="yq_linux_amd64"

yum install wget
wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY} -O yq
chmod +x yq

branch=$(echo $VERCEL_GIT_COMMIT_REF | cut -d'/' -f2)
apiUrl="solidtrade.$branch.api.rosemite.dev"

echo "Using $apiUrl as base api url"

# Update base api url
./yq -i ".baseUrl = \"$apiUrl\"" ./assets/config/config.yml

# Install dependencies
flutter pub get

# Generate mappings
flutter pub run build_runner build --delete-conflicting-outputs

# Build app
if [ "$branch" = "stable" ]; then
  flutter build web --release -t lib/app/main_prod.dart
elif [ "$branch" = "staging" ]; then
  flutter build web --release -t lib/app/main_staging.dart
else
  flutter build web --release -t lib/app/main_dev.dart
fi
