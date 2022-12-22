#!/bin/bash
set -e -o pipefail


# TODO centralize all scripts here?


# ACME stuff
#
#certbot --config acme/certbot/cli.ini certonly --domains "$TP_SERVER_DOMAIN"
#ln -sf ../../../../acme/certbot/live/play.meeque.de/fullchain.pem server-nginx/servers/server0/tls/server-cert.pem
#ln -sf ../../../../../acme/certbot/live/play.meeque.de/privkey.pem server-nginx/servers/server0/tls/private/server-key.pem
