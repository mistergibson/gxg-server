#!/bin/bash
source /etc/profile
rm ./Public/www/javascript/gxg.js
minify ../gxg-web-client/gxg.js > ./Public/www/javascript/gxg.js
