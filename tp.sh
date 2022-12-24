#!/bin/bash
set -e -o pipefail



# TP main

function tp_main {

    # set env defaults
    tp_main_env_defaults

    # use the directory where this script is located as base
    tp_base_dir="$( cd "$(dirname "$0")"; pwd -P )"

    # parse arguments
    tp_arguments=$( getopt -o 'c:' --long 'ca:' -n 'tp.sh' -- "$@" )
    eval set -- "${tp_arguments}"

    # process arguments
    while true
    do
        case "$1" in
            -c|--ca)
                tp_ca="$2"
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "[TP] Unknown option argument $1. Ignoring."
                ;;
        esac
        shift
    done

    # dispatch command
    tp_command="$1"
    shift || true

    case "${tp_command}" in
        'ca' | 'acme' | 'server' | 'all' )
            "tp_${tp_command}" "$@"
            exit $?
            ;;
        * )
            echo "[TP] Unsupported command '${tp_command}'."
            exit 1
            ;;
    esac
}

function tp_main_env_defaults {
    export TP_PASS="${TP_PASS:=1234}"
    export TP_SERVER_DOMAIN="${TP_SERVER_DOMAIN:=localhost}"
    export TP_SERVER_LISTEN_ADDRESS="${TP_SERVER_LISTEN_ADDRESS:=127.0.0.1}"
    export TP_SERVER_HTTP_PORT="${TP_SERVER_HTTP_PORT:=8080}"
    export TP_SERVER_HTTPS_PORT="${TP_SERVER_HTTPS_PORT:=8443}"
    export TP_ACME_SERVER_URL="${TP_ACME_SERVER_URL:=https://acme-staging-v02.api.letsencrypt.org/directory}"
    export TP_ACME_ACCOUNT_EMAIL="${TP_ACME_ACCOUNT_EMAIL:=webmaster@example.net}"
}



# TP ca



# TP acme
#
#certbot --config acme/certbot/cli.ini certonly --domains "$TP_SERVER_DOMAIN"
#ln -sf ../../../../acme/certbot/live/play.meeque.de/fullchain.pem server-nginx/servers/server0/tls/server-cert.pem
#ln -sf ../../../../../acme/certbot/live/play.meeque.de/privkey.pem server-nginx/servers/server0/tls/private/server-key.pem



# TP entry point
tp_main "$@"

