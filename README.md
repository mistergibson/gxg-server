GxG Server

Requirements:

JRuby (any recent version)
Thus far it has only been tested on Ubuntu Server

Installation:

git clone as usual

chown -R www-data:www-data gxg-server

cd gxg-server

sudo ./install.rb

sudo -u www-data ./setup.rb

Note: you can either run ./console OR ./server start BUT NOT BOTH. So:

sudo -u www-data ./console

OR

sudo -u www-data ./server start


Note: GxG Server is *intended* to sit behind a proxy server. Here is an example configuration for Apache 2:

ProxyPassMatch "/ws" ws://127.0.0.1:32767/ws

ProxyPass / http://127.0.0.1:32767/

ProxyPassReverse / http://127.0.0.1:32767/
