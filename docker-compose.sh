#! /usr/bin/env bash

export IMAGE=$1
sudo curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo IMAGE=$IMAGE docker-compose -f docker-compose.yaml up --detach