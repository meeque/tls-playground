#!/bin/bash
set -e -o pipefail



address_regexp=
port_regexp=''



function check-env {
  local status=0

  [[ "${TP_SERVER_DOMAIN}" =~ ^([-a-zA-Z0-9]+[.])*[-a-zA-Z0-9]+$ ]] \
      || { status=1; echo "[TP] Variable TP_SERVER_DOMAIN with value '${TP_SERVER_DOMAIN}' does not look like a DNS domain name!"; }
  [[ "${TP_SERVER_LISTEN_ADDRESS}" =~ ^([*]|[0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3})$ ]] \
      || { status=1; echo "[TP] Variable TP_SERVER_LISTEN_ADDRESS with value '${TP_SERVER_LISTEN_ADDRESS}' does not look like an IP address!"; }
  [[ "${TP_SERVER_HTTP_PORT}" =~ ^[0-9]{1,5}$ ]] \
      || { status=1; echo "[TP] Variable TP_SERVER_HTTP_PORT with value '${TP_SERVER_HTTP_PORT}' does not look like a network port number!"; }
  [[ "${TP_SERVER_HTTPS_PORT}" =~ ^[0-9]{1,5}$ ]] \
      || { status=1; echo "[TP] Variable TP_SERVER_HTTPS_PORT with value '${TP_SERVER_HTTPS_PORT}' does not look like a network port number!"; }

  [[ "${TP_ACME_SERVER_URL}" =~ ^https:[/][/]([-a-zA-Z0-9]+[.])*[-a-zA-Z0-9]+(:[0-9]{1,5})?([/][-a-zA-Z0-9.+*_~]*)*$ ]] \
      || { status=1; echo "[TP] Variable TP_ACME_SERVER_URL with value '${TP_ACME_SERVER_URL}' does not look like an absolute https url! Please note that user-info, query string, fragment, or exotic path characters are not allowed here!"; }
  [[ "${TP_ACME_ACCOUNT_EMAIL}" =~ ^[-a-zA-Z0-9._%+]+@([-a-zA-Z0-9]+[.])*[-a-zA-Z0-9]+$ ]] \
      || { status=1; echo "[TP] Variable TP_ACME_ACCOUNT_EMAIL with value '${TP_ACME_ACCOUNT_EMAIL}' does not look like an email address!"; }

  return "${status}"
}



function configure {
  cd "${server_nginx_base_dir}"
  cd ..

  check-env || return

  for config_file_template in $( find . -type f -and -name '*.tmpl' )
  do
    config_file="$( echo "${config_file_template}" | sed -e 's/.tmpl$//' )"
    echo -n "[TP] Generating ${config_file}... "
    cat "${config_file_template}" \
        | envsubst '${TP_SERVER_DOMAIN},${TP_SERVER_LISTEN_ADDRESS},${TP_SERVER_HTTP_PORT},${TP_SERVER_HTTPS_PORT},${TP_ACME_SERVER_URL},${TP_ACME_ACCOUNT_EMAIL}' \
        > "${config_file}"
    echo "done."
  done
}



function clean {
  cd "${server_nginx_base_dir}"
  find . -type f -and '(' -name '*.conf' -or -name '*.config' ')' | xargs rm -f  2>/dev/null || true
}



export TP_PASS="${TP_PASS:=1234}"
export TP_SERVER_DOMAIN="${TP_SERVER_DOMAIN:=localhost}"
export TP_SERVER_LISTEN_ADDRESS="${TP_SERVER_LISTEN_ADDRESS:=127.0.0.1}"
export TP_SERVER_HTTP_PORT="${TP_SERVER_HTTP_PORT:=8080}"
export TP_SERVER_HTTPS_PORT="${TP_SERVER_HTTPS_PORT:=8443}"
export TP_ACME_SERVER_URL="${TP_ACME_SERVER_URL:=https://acme-staging-v02.api.letsencrypt.org/directory}"
export TP_ACME_ACCOUNT_EMAIL="${TP_ACME_ACCOUNT_EMAIL:=webmaster@example.net}"

server_nginx_base_dir="$( cd "$(dirname "$0")" ; pwd -P )"



command="$1"
shift

case "${command}" in
  'check-env' | 'configure' | 'clean' )
    "${command}" "$@"
    ;;
  * )
    echo "[TP] Unsupported command '$command'."
    exit 1
    ;;
esac

