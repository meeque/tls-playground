#!/bin/bash
set -e -o pipefail



# top-level TP commands

function tp_main {

    # set directories
    export TP_WORK_DIR="$( pwd -P )"
    export TP_BASE_DIR="$( cd "$(dirname "$0")"; pwd -P )"

    # set env defaults
    tp_main_env_defaults

    # parse arguments
    local tp_arguments="$( getopt --options 'c:' --longoptions 'ca:' --name 'tp.sh' -- "$@" )"
    eval set -- ${tp_arguments}

    # process arguments
    while true
    do
        case "$1" in
            -c|--ca)
                export TP_CA="$2"
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
        'cert' | 'ca' | 'acme' | 'server' | 'all' )
            "tp_${tp_command}" "$@"
            return $?
            ;;
        * )
            echo "[TP] Unsupported command '${tp_command}'."
            return 1
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
    export TP_ACME_ACCOUNT_EMAIL="${TP_ACME_ACCOUNT_EMAIL:=webmaster@tls-playground.example}"
}




# TP cert sub-commands

function tp_cert {
    local command="$1"
    shift || true

    case "${command}" in
        'show' | 'fingerprint' | 'request' | 'selfsign' | 'pkcs8' | 'pkcs12' )
            "tp_cert_${command}" "$@"
            ;;
        * )
            echo "[TP] Unsupported cert command '$command'."
            return 1
            ;;
    esac
}

function tp_cert_show {
    local cert_file="$1"
    # TODO alternatively show CSRs and keys, based on naming conventions

    if [[ -z "${cert_file}" ]]
    then
        echo "[TP] No certificate specified. Specify the certificate file to show!"
        return 1
    fi

    echo "[TP] Showing contents of certificate in '${cert_file}'..."
    echo
    (
        set -x
        openssl x509 -in "${cert_file}" -noout -text
    )
}

function tp_cert_fingerprint {
    local cert_file="$1"
    # TODO alternatively calculate fingerprints of CSRs and keys, based on naming conventions?

    if [[ -z "${cert_file}" ]]
    then
        echo "[TP] No certificate specified. Specify the certificate file whose fingerprint to calculate!"
        return 1
    fi

    # TODO support configurable list of hash algs
    echo "[TP] Calculating fingerprint of certificate in '${cert_file}'..."
    echo
    (
        set -x
        openssl x509 -in "${cert_file}" -noout -fingerprint -sha256
    )
}

function tp_cert_request {
    local config_file="$1"

    if [[ -z "${config_file}" ]]
    then
        echo "[TP] No certificate request config file name specified. Specify the config file to request and sign!"
        return 1
    fi

    # TODO print config file

    local config_file_path="$( cd "${TP_WORK_DIR}"; cd "$(dirname "${config_file}")" ; pwd -P )/$(basename "${config_file}")"
    local config_file_basepath="$(dirname ${config_file_path})"
    local config_name="$(basename ${config_file_path})"
    local config_name="$( echo "${config_name}" | sed -e 's/[.]config$//' )"
    local reqest_file_path="${config_file_basepath}/${config_name}-csr.pem"
    local key_file_path="${config_file_basepath}/private/${config_name}-key.pem"
    local cert_link_path="${config_file_basepath}/${config_name}-cert.pem"

    mkdir -p "${config_file_basepath}/private"
    chmod og-rwx "${config_file_basepath}/private"
    rm "${reqest_file_path}" 2>/dev/null || true
    rm "${key_file_path}" 2>/dev/null || true
    rm "${cert_link_path}" 2>/dev/null || true

    echo "[TP] Generating key-pair and CSR based on config file '${config_file_path}'..."
    echo
    (
        set -x
        openssl req -new -config "${config_file_path}" -newkey rsa:2048 -passout env:TP_PASS -keyout "${key_file_path}" -out "${reqest_file_path}"
    )
    echo
    echo "[TP] New private key in '${key_file_path}'."
    echo "[TP] New CSR in '${reqest_file_path}'."
}

function tp_cert_selfsign {
    local config_file="$1"

    if [[ -z "${config_file}" ]]
    then
        echo "[TP] No certificate request config file name specified. Specify a config file for your self-signed certificate!"
        return 1
    fi

    echo "[TP] Preparing CSR for self-signed certificate, based on config file '${config_file}'..."
    tp_cert_request "${config_file}"

    local csr_file="$( echo "${config_file}" | sed -e 's/[.]config$/-csr.pem/' )"
    local key_file="$( echo "${config_file}" | sed --regexp-extended -e 's_(^|/)([^/]+)[.]config$_\1private/\2-key.pem_' )"
    local cert_file="$( echo "${config_file}" | sed -e 's/[.]config$/-cert.pem/' )"

    echo "[TP] Signing CSR '${csr_file}' with it's own private key..."
    echo
    (
        set -x
        openssl x509 -req -in "${csr_file}" -days 90 -signkey "${key_file}" -passin env:TP_PASS -out "${cert_file}"
    )
    echo "[TP] New certificate in '${cert_file}'."

    echo
    tp_cert_show "${cert_file}"
    echo
    tp_cert_fingerprint "${cert_file}"
}

function tp_cert_pkcs8 {
    local key_file="$1"

    if [[ -z "${key_file}" ]]
    then
        echo "[TP] No key file name specified. Specify the key file to convert to PKCS8!"
        return 1
    fi

    local key_name="$( echo "${key_file}" | sed -e 's/[.]pem$//' )"
    local pkcs8_file="${key_name}-pkcs8.der"

    echo "[TP] Converting private key '${key_file}' to PKCS8 format..."
    echo
    (
        set -x
        openssl pkcs8 -topk8 -in "${key_file}" -passin env:TP_PASS -outform DER -out "${pkcs8_file}" -nocrypt
    )
    echo
    echo "[TP] PKCS8 private key in '${pkcs8_file}'."
}

function tp_cert_pkcs12 {
    local cert_file="$1"

    if [[ -z "${cert_file}" ]]
    then
        echo "[TP] No certificate specified. Specify the certificate to bundled to PKCS12!"
        return 1
    fi

    local cert_file_path="$(dirname ${cert_file})"
    local cert_name="$(basename ${cert_file})"
    local cert_name="$( echo "${cert_name}" | sed -e 's/[.]pem$//' | sed -e 's/-cert$//' )"
    local key_file="${cert_file_path}/private/${cert_name}-key.pem"
    local pkcs12_file="${cert_file_path}/private/${cert_name}.pfx"

    echo "[TP] Bundling certificate '${cert_file}' and private key '${key_file}' to PKCS12..."
    echo
    (
        set -x
        openssl pkcs12 -export -in "${cert_file}" -inkey "${key_file}" -passin env:TP_PASS -out "${pkcs12_file}" -aes256 -passout env:TP_PASS
    )
    echo
    echo "[TP] PKCS12 bundle in '${pkcs12_file}'."
}



# TP ca sub-commands

function tp_ca {
    local command="$1"
    shift || true

    case "${command}" in
        'init' | 'sign' | 'clean' )
            "tp_ca_${command}" "$@"
            ;;
        * )
            echo "[TP] Unsupported ca command '$command'."
            return 1
            ;;
    esac
}

function tp_ca_init {
    local ca_name="$1"

    if [[ -z "${ca_name}" ]]
    then
        echo "[TP] No CA name specified. Specify the CA to reset!"
        return 1
    fi

    (
        cd "${TP_BASE_DIR}/ca/${ca_name}"

        find . -type d -and -not -name '.' | xargs rm -r 2>/dev/null || true
        find . -type f -and -not -name 'ca-req.config' | xargs rm 2>/dev/null || true

        mkdir 'newcerts'
        mkdir 'private'
        chmod go-rwx 'private'
        touch db.txt
        # TODO use distinct serial ranges for individual cas
        echo -n D78B3C0000000001 > serial

        # TODO [TP] add explanatory messages
        # TODO delegate to some self-signed cert sub-command
        set -x
        openssl req -new -config ca-req.config -newkey rsa:4096 -passout env:TP_PASS -keyout private/ca-key.pem -out ca-csr.pem
        openssl x509 -req -in ca-csr.pem -days 90 -signkey private/ca-key.pem -passin env:TP_PASS -out ca-cert.pem
    )
}

function tp_ca_sign {
    local ca_name="$1"
    local cert_config_or_csr="$2"
    local cert_link="$3"

    if [[ -z "${ca_name}" ]]
    then
        echo "[TP] No CA name specified. Specify the CA to sign with!"
        return 1
    fi

    if [[ -z "${cert_config_or_csr}" ]]
    then
        echo "[TP] Nothing to sign. Specify a certificate config file or a CSR!"
        return 1
    fi

    if [[ "${cert_config_or_csr}" =~ [.]config$ ]]
    then
        local config_file="${cert_config_or_csr}"
        local csr_file="$( echo "${config_file}" | sed -e 's/[.]config$/-csr.pem/' )"

        echo "[TP] Preparing CSR to sign, based on config file '${config_file}'..."
        tp_cert_request "${config_file}"
    else
        local csr_file="${cert_config_or_csr}"
        echo "[TP] Preparing to sign existing CSR..."
    fi

    local csr_file_path="$( cd "${TP_WORK_DIR}"; cd "$(dirname "${csr_file}")" ; pwd -P )/$(basename "${csr_file}")"
    # TODO determine link by naming convention instead
    if [[ "${cert_link}" ]]
    then
        local cert_link_path="$( cd "${TP_WORK_DIR}"; cd "$(dirname "${cert_link}")" ; pwd -P )/$(basename "${cert_link}")"
    fi

    (
        cd "${TP_BASE_DIR}/ca/"
        local new_serial=$(<"${ca_name}/serial")
        local new_cert_file_path="$( pwd -P )/${ca_name}/newcerts/${new_serial}.pem"

        echo "[TP] Signing CSR from '${csr_file_path}' with CA ${ca_name} at serial ${new_serial}..."
        echo
        (
            set -x
            openssl ca -config "ca.conf" -name "${ca_name}" -batch -notext -passin env:TP_PASS -in "${csr_file_path}"
        )
        echo
        echo "[TP] New certificate in '${new_cert_file_path}'."

        echo
        tp_cert_show "${new_cert_file_path}"
        echo
        tp_cert_fingerprint "${new_cert_file_path}"

        if [[ "${cert_link}" ]]
        then
            # TODO use relative paths in symlinks, because absolute paths break in container bind mounts
            ln -sf "${new_cert_file_path}" "${cert_link_path}"
            echo
            echo "[TP] Also linked certificate into '${cert_link_path}'."
        fi
    )
}

function tp_ca_clean {
    (
        cd "${TP_BASE_DIR}"

        find . -type f -and '(' -name '*.pem' -or -name '*.der' -or -name '*.pfx' ')' | xargs rm 2>/dev/null || true
        find ca -type f -and '(' -name 'serial' -or -name 'serial.*' -or -name 'db.txt' -or -name 'db.txt.*' ')' | xargs rm 2>/dev/null || true
        find . -type l -and '(' -name '*.pem' -or -name '*.der' -or -name '*.pfx' ')' | xargs rm 2>/dev/null || true
        find . -type d -and -empty -and '(' -name 'private' -or -name 'newcerts' ')' | xargs rmdir 2>/dev/null || true
    )
}



# TODO TP acme sub-commands
#
#certbot --config acme/certbot/cli.ini certonly --domains "$TP_SERVER_DOMAIN"
#ln -sf ../../../../acme/certbot/live/play.meeque.de/fullchain.pem server-nginx/servers/server0/tls/server-cert.pem
#ln -sf ../../../../../acme/certbot/live/play.meeque.de/privkey.pem server-nginx/servers/server0/tls/private/server-key.pem
# TODO show how to use certbot with own CSR
# TODO show how to use certbot with manual challange



# TP entry point
tp_main "$@"

