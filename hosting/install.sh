#!/usr/bin/ bash
set -euo pipefail

ssh $1 "mkdir -p /root/absolventenfeier"
scp app.env $1:/root/absolventenfeier/app.env
scp db.env $1:/root/absolventenfeier/db.env
scp docker-compose.yml $1:/root/absolventenfeier/docker-compose.yml

scp -r setup/ $1: && ssh $1 "cd ~/setup; chmod +x setup.sh; ./setup.sh"
scp -r nginx/absolventenfeier/ $1:/var/www/
scp nginx/nginx.conf $1:/etc/nginx/sites-available/default && ssh $1 "sudo service nginx restart"
