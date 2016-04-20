#!/bin/bash

filepath=/usr/local/openresty/conf/nginx.conf

inotifywait -m -e close_write $filepath --format "%w" |while read FILE; do
	/usr/local/openresty/nginx/sbin/nginx -s reload  -c  /usr/local/openresty/conf/nginx.conf
done