#!/bin/bash
set -e -o pipefail



function configure {
  cd "${server_nginx_base_dir}"

  for config_file_template in $( find . -type f -and -name '*.tmpl' )
  do
    config_file="$( echo "${config_file_template}" | sed -e 's/.tmpl$//' )"
    echo "[TP] Generating ${config_file}"...
    # TODO so far we're just copying, but need to template with envsubst
    cp "${config_file_template}" "${config_file}"
    echo "[TP]done."
  done
}



function clean {
  cd "${server_nginx_base_dir}"
  find . -type f -and '(' -name '*.conf' -or -name '*.config' ')' | xargs rm -f  2>/dev/null || true
}



export TLS_PLAYGROUND_PASS="${TLS_PLAYGROUND_PASS:=1234}"
export TLS_PLAYGROUND_HTTP_LISTEN_PORT="${TLS_PLAYGROUND_PASS:=8080}"
export TLS_PLAYGROUND_HTTPS_LISTEN_PORT="${TLS_PLAYGROUND_PASS:=8443}"
export TLS_PLAYGROUND_HTTPS_LISTEN_ADDRESS="${TLS_PLAYGROUND_PASS:=127.0.0.1}"


server_nginx_base_dir="$( cd "$(dirname "$0")" ; pwd -P )"



command="$1"
shift

case "$command" in
  'configure' | 'clean' )
    "$command" "$@"
    ;;
  * )
    echo "[TP] Unsupported command '$command'."
    exit 1
    ;;
esac
