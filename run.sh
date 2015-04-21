#!/bin/bash
docker run --rm -i -t  -p 5000:80 -v /Users/alasarr/dev/mirador:/var/www/mirador -v  /Users/alasarr/dev/phpCommonCode:/var/www/phpCommonCode -v /Users/alasarr/dev/Docker-mirador:/var/docker mirador

