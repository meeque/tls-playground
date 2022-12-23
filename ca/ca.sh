#!/bin/bash
set -e -o pipefail



function reset {
  local ca_name="$1"

  if [[ "${ca_name}" ]]
  then
    (
      cd "${ca_base_dir}"
      cd "${ca_name}"

      find . -type d -and -not -name '.' | xargs rm -r 2>/dev/null || true
      find . -type f -and -not -name 'ca-req.config' | xargs rm 2>/dev/null || true

      mkdir 'newcerts'
      mkdir 'private'
      chmod go-rwx 'private'
      touch db.txt
      echo -n D78B3C0000000001 > serial

      set -x
      openssl req -new -config ca-req.config -newkey rsa:4096 -passout env:TP_PASS -keyout private/ca-key.pem -out ca-csr.pem
      openssl x509 -req -in ca-csr.pem -days 90 -signkey private/ca-key.pem -passin env:TP_PASS -out ca-cert.pem
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
      local csr_file_path="$( cd "$(dirname "${csr_file}")" ; pwd -P )/$(basename "${csr_file}")"
      if [[ "${cert_link}" ]]
      then
        local cert_link_path="$( cd "$(dirname "${cert_link}")" ; pwd -P )/$(basename "${cert_link}")"
      fi

      (
        cd "${ca_base_dir}"
        local new_serial=$(<"${ca_name}/serial")
        local new_cert_file_path="$( pwd -P )/${ca_name}/newcerts/${new_serial}.pem"
        echo "Signing CSR ${new_serial} from file '${csr_file_path}'..."

        (
          set -x
          openssl ca -config ca.conf -name "${ca_name}" -batch -passin env:TP_PASS -in "${csr_file_path}"
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



function request {
  local ca_name="$1"
  local config_file="$2"

  if [[ "${ca_name}" ]]
  then
    if [[ "${config_file}" ]]
    then
      local config_file_path="$( cd "$(dirname "${config_file}")" ; pwd -P )/$(basename "${config_file}")"
      local config_file_basepath="$(dirname ${config_file_path})"
      local config_name="$(basename ${config_file_path})"
      local config_name="$( echo "${config_name}" | sed -e 's/[.]config$//' )"
      local reqest_file_path="${config_file_basepath}/${config_name}-csr.pem"
      local key_file_path="${config_file_basepath}/private/${config_name}-key.pem"
      local cert_link_path="${config_file_basepath}/${config_name}-cert.pem"

      echo "${config_file_basepath}" ' >>> ' "${config_name}"

      mkdir -p "${config_file_basepath}/private"
      chmod og-rwx "${config_file_basepath}/private"
      rm "${reqest_file_path}" 2>/dev/null || true
      rm "${key_file_path}" 2>/dev/null || true
      rm "${cert_link_path}" 2>/dev/null || true
      (
        set -x
        openssl req -new -config "${config_file_path}" -newkey rsa:2048 -passout env:TP_PASS -keyout "${key_file_path}" -out "${reqest_file_path}"
      )

      sign "${ca_name}" "${reqest_file_path}" "${cert_link_path}"
    else
      echo "No certificate request config file name specified. Specify the config file to request and sign!"
      exit 1
    fi
  else
    echo "No CA name specified. Specify the CA to sign with!"
    exit 1
  fi
}



function pkcs8 {
  local key_file="$1"

  if [[ "${key_file}" ]]
  then
    local key_name="$( echo "${key_file}" | sed -e 's/[.]pem$//' )"
    local pkcs8_file="${key_name}-pkcs8.der"

    (
      set -x
      openssl pkcs8 -topk8 -in "${key_file}" -passin env:TP_PASS -outform DER -out "${pkcs8_file}" -nocrypt
    )
  else
    echo "No key file name specified. Specify the key file to convert to PKCS8!"
    exit 1
  fi
}



function pkcs12 {
  local cert_file="$1"

  if [[ "${cert_file}" ]]
  then
    local cert_file_path="$(dirname ${cert_file})"
    local cert_name="$(basename ${cert_file})"
    local cert_name="$( echo "${cert_name}" | sed -e 's/[.]pem$//' | sed -e 's/-cert$//' )"
    local key_file="${cert_file_path}/private/${cert_name}-key.pem"
    local pkcs12_file="${cert_file_path}/private/${cert_name}.pfx"

    (
      set -x
      openssl pkcs12 -export -in "${cert_file}" -inkey "${key_file}" -passin env:TP_PASS -out "${pkcs12_file}" -aes256 -passout env:TP_PASS
    )
  else
    echo "No certificate file name specified. Specify the certificate file to convert to PKCS12!"
    exit 1
  fi
}



function clean {
  cd "${ca_base_dir}"
  cd ..

  find . -type f -and '(' -name '*.pem' -or -name '*.der' -or -name '*.pfx' ')' | xargs rm 2>/dev/null || true
  find ca -type f -and '(' -name 'serial' -or -name 'serial.*' -or -name 'db.txt' -or -name 'db.txt.*' ')' | xargs rm 2>/dev/null || true
  find . -type l -and '(' -name '*.pem' -or -name '*.der' -or -name '*.pfx' ')' | xargs rm 2>/dev/null || true
  find . -type d -and -empty -and '(' -name 'private' -or -name 'newcerts' ')' | xargs rmdir 2>/dev/null || true
}



export TP_PASS="${TP_PASS:=1234}"

ca_base_dir="$( cd "$(dirname "$0")" ; pwd -P )"



command="$1"
shift

case "$command" in
  'reset' | 'sign' | 'request' | 'pkcs8' | 'pkcs12' | 'clean' )
    "$command" "$@"
    ;;
  * )
    echo "Unsupported command '$command'."
    exit 1
    ;;
esac
