#!/bin/bash
set -e -o pipefail


function reset {
  local ca_base_dir="$( cd "$(dirname "$0")" ; pwd -P )"
  local ca_name="$1"

  if [[ "${ca_name}" ]]
  then
    (
      cd "${ca_base_dir}"
      cd "${ca_name}"

      find . -type d -and -not -name '.' | xargs rm -r
      find . -type f -and -not -name 'serial' -and -not -name 'ca-req.config' | xargs rm

      mkdir 'newcerts'
      mkdir 'private'
      chmod go-rwx 'private'

      (
        set -x
        openssl req -new -config ca-req.config -newkey rsa:4096 -passout env:TLS_PLAYGROUND_PASS -keyout private/ca-key.pem -out ca-csr.pem
        openssl x509 -req -in ca-csr.pem -days 90 -signkey private/ca-key.pem -passin env:TLS_PLAYGROUND_PASS -out ca-cert.pem
      )
    )
  else
    echo "No CA name specified. Specify the CA to reset!"
    exit 1
  fi
}



export TLS_PLAYGROUND_PASS="${TLS_PLAYGROUND_PASS:=1234}"

command="$1"
shift

case "$command" in
  'reset' | 'sign' )
    "$command" "$@"
    ;;
  * )
    echo "Unsupported command '$command'."
    ;;
esac
