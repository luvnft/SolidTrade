#!/usr/bin/env bash

# We do not require ngrok for production. This is why we scale down to 0.
docker-compose up --scale ngrok=0