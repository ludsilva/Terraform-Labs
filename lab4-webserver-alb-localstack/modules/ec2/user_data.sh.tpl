#!/bin/bash
apt-get update -y
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx
echo "<h1>Ihuuu! Welcome Nginx web server!</h1>" | tee /var/www/html/index.html
