#!/bin/bash
set -e -o pipefail



function reset {
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
      touch db.txt

      set -x
      openssl req -new -config ca-req.config -newkey rsa:4096 -passout env:TLS_PLAYGROUND_PASS -keyout private/ca-key.pem -out ca-csr.pem
      openssl x509 -req -in ca-csr.pem -days 90 -signkey private/ca-key.pem -passin env:TLS_PLAYGROUND_PASS -out ca-cert.pem
    )
  else
    echo "No CA name specified. Specify the CA to reset!"
    exit 1
  fi
}



function sign {
  local ca_name="$1"
  local csr_file="$2"
  local cert_link="$3"

  if [[ "${ca_name}" ]]
  then
    if [[ "${csr_file}" ]]
    then
      local csr_file_path="$( pwd -P )/${csr_file}"
      if [[ "${cert_link}" ]]
      then
        local cert_link_path="$( pwd -P )/${cert_link}"
      fi

      (
        cd "${ca_base_dir}"
        local new_serial=$(<"${ca_name}/serial")
        local new_cert_file_path="$( pwd -P )/${ca_name}/newcerts/${new_serial}.pem"
        echo "Signing CSR ${new_serial} from file '${csr_file_path}'..."

        (
          set -x
          openssl ca -config ca.conf -name ca1 -batch -passin env:TLS_PLAYGROUND_PASS -in "${csr_file_path}"
        )

        echo "Newly signed certificate is now available at '${new_cert_file_path}'."
        if [[ "${cert_link}" ]]
        then
          ln -sf "${new_cert_file_path}" "${cert_link_path}"
          echo "Also linked signed certificate to '${cert_link_path}'."
        fi
      )
    else
      echo "No CSR file name specified. Specify the CSR file to sign!"
      exit 1
    fi
  else
    echo "No CA name specified. Specify the CA to sign with!"
    exit 1
  fi
}



export TLS_PLAYGROUND_PASS="${TLS_PLAYGROUND_PASS:=1234}"

ca_base_dir="$( cd "$(dirname "$0")" ; pwd -P )"



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
