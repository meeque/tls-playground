#!/bin/bash
set -e -o pipefail



address_regexp=
port_regexp=''



function check-env {
  local status=0
  [[ "${TP_HTTP_LISTEN_ADDRESS}" =~ ^([*]|[0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3})$ ]] \
      || { status=1; echo "[TP] Variable TP_HTTP_LISTEN_ADDRESS with value '${TP_HTTP_LISTEN_ADDRESS}' does not look like an IP address!"; }
  [[ "${TP_HTTP_LISTEN_PORT}" =~ ^[0-9]{1,5}$ ]] \
      || { status=1; echo "[TP] Variable TP_HTTP_LISTEN_PORT with value '${TP_HTTP_LISTEN_PORT}' does not look like a network port number!"; }
  [[ "${TP_HTTPS_LISTEN_ADDRESS}" =~ ^([*]|[0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3})$ ]] \
      || { status=1; echo "[TP] Variable TP_HTTPS_LISTEN_ADDRESS with value '${TP_HTTPS_LISTEN_ADDRESS}' does not look like an IP address!"; }
  [[ "${TP_HTTPS_LISTEN_PORT}" =~ ^[0-9]{1,5}$ ]] \
      || { status=1; echo "[TP] Variable TP_HTTPS_LISTEN_PORT with value '${TP_HTTPS_LISTEN_PORT}' does not look like a network port number!"; }
  return "${status}"
}



function configure {
  cd "${server_nginx_base_dir}"

  check-env || return

  for config_file_template in $( find . -type f -and -name '*.tmpl' )
  do
    config_file="$( echo "${config_file_template}" | sed -e 's/.tmpl$//' )"
    echo -n "[TP] Generating ${config_file}... "
    cat "${config_file_template}" \
        | envsubst 'TP_HTTP_LISTEN_ADDRESS,TP_HTTP_LISTEN_ADDRESS,TP_HTTPS_LISTEN_ADDRESS,TP_HTTPS_LISTEN_PORT' \
        > "${config_file}"
    echo "done."
  done
}



function clean {
  cd "${server_nginx_base_dir}"
  find . -type f -and '(' -name '*.conf' -or -name '*.config' ')' | xargs rm -f  2>/dev/null || true
}



export TP_PASS="${TLS_PLAYGROUND_PASS:=1234}"
export TP_HTTP_LISTEN_ADDRESS="${TP_HTTP_LISTEN_ADDRESS:=127.0.0.1}"
export TP_HTTP_LISTEN_PORT="${TP_HTTP_LISTEN_PORT:=8080}"
export TP_HTTPS_LISTEN_ADDRESS="${TP_HTTPS_LISTEN_ADDRESS:=127.0.0.1}"
export TP_HTTPS_LISTEN_PORT="${TP_HTTPS_LISTEN_PORT:=8443}"

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

