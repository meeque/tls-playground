#!/bin/bash
set -e -o pipefail



# top-level TP commands

function tp_main {

    # setup environment
    tp_main_env_global
    tp_main_env_defaults
    tp_main_env_check

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
        'cert' | 'ca' | 'acme' | 'server' | 'clean' )
            "tp_${tp_command}" "$@"
            return $?
            ;;
        * )
            echo "[TP] Unsupported TLS Playground command '${tp_command}'."
            return 1
            ;;
    esac
}

function tp_main_env_global {
    export TP_WORK_DIR="$( pwd -P )"
    export TP_BASE_DIR="$( cd "$(dirname "$0")"; pwd -P )"
}

function tp_main_env_defaults {
    # TODO move closer to commands that actually use these env-vars?
    # TODO validate CLI args, too? e.g. for file naming conventions and file existence?
    export TP_PASS="${TP_PASS:=1234}"
    export TP_SERVER_DOMAIN="${TP_SERVER_DOMAIN:=localhost}"
    export TP_SERVER_LISTEN_ADDRESS="${TP_SERVER_LISTEN_ADDRESS:=127.0.0.1}"
    export TP_SERVER_HTTP_PORT="${TP_SERVER_HTTP_PORT:=8080}"
    export TP_SERVER_HTTPS_PORT="${TP_SERVER_HTTPS_PORT:=8443}"
    export TP_ACME_SERVER_URL="${TP_ACME_SERVER_URL:=https://acme-staging-v02.api.letsencrypt.org/directory}"
    export TP_ACME_ACCOUNT_EMAIL="${TP_ACME_ACCOUNT_EMAIL:=webmaster@tls-playground.example}"
}

function tp_main_env_check {
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




# TP cert sub-commands

function tp_cert {
    local command="$1"
    shift || true

    case "${command}" in
        'show' | 'fingerprint' | 'request' | 'selfsign' | 'pkcs8' | 'pkcs12' | 'clean' )
            "tp_cert_${command}" "$@"
            ;;
        * )
            echo "[TP] Unsupported certificate command '${command}'."
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
    echo
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
    echo
}

function tp_cert_request {
    local config_file="$1"

    if [[ -z "${config_file}" ]]
    then
        echo "[TP] No certificate request config file name specified. Specify the config file to request and sign!"
        return 1
    fi

    local config_file_path="$( cd "${TP_WORK_DIR}"; cd "$(dirname "${config_file}")" ; pwd -P )/$(basename "${config_file}")"
    local config_file_basepath="$(dirname ${config_file_path})"
    local config_name="$(basename ${config_file_path})"
    local config_name="$( echo "${config_name}" | sed -e 's/[.]cert[.]conf$//' )"
    local reqest_file_path="${config_file_basepath}/${config_name}.csr.pem"
    local key_file_path="${config_file_basepath}/private/${config_name}.key.pem"
    local cert_link_path="${config_file_basepath}/${config_name}.cert.pem"

    # TODO extract clean-up code to separate sub-command
    # TODO also clean up chain and fullchain files
    mkdir -p "${config_file_basepath}/private"
    chmod og-rwx "${config_file_basepath}/private"
    rm -f "${reqest_file_path}" "${key_file_path}" "${cert_link_path}"

    echo "[TP] Using OpenSSL CSR config file '${config_file_path}':"
    echo
    cat "${config_file_path}"
    echo

    echo "[TP] Generating key-pair and CSR based on config file '${config_file_path}'..."
    echo
    (
        set -x
        openssl req -new -config "${config_file_path}" -newkey rsa:2048 -passout env:TP_PASS -keyout "${key_file_path}" -out "${reqest_file_path}"
    )
    echo
    echo "[TP] New private key in '${key_file_path}'."
    echo "[TP] New CSR in '${reqest_file_path}'."

    # TODO also create and link chain and fullchain files
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

    local csr_file="$( echo "${config_file}" | sed -e 's/[.]cert[.]conf$/.csr.pem/' )"
    local key_file="$( echo "${config_file}" | sed --regexp-extended -e 's_(^|/)([^/]+)[.]cert[.]conf$_\1private/\2.key.pem_' )"
    local cert_file="$( echo "${config_file}" | sed -e 's/[.]cert[.]conf$/.cert.pem/' )"

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
    local cert_name="$( echo "${cert_name}" | sed -e 's/[.]cert[.]pem$//' )"
    local key_file="${cert_file_path}/private/${cert_name}.key.pem"
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

function tp_cert_clean {
    local path="$1"

    if [[ -z "${path}" ]]
    then
        local path="${TP_BASE_DIR}"
    fi

    echo "[TP] Cleaning up certificates and related files in '${path}'..."
    (
        cd "${path}"
        find . -type f -and '(' -name '*.pem' -or -name '*.der' -or -name '*.pfx' ')' | xargs rm -f
        find . -type l -and '(' -name '*.pem' -or -name '*.der' -or -name '*.pfx' ')' | xargs rm -f
        find . -type d -and -empty -and -name 'private' | xargs rm -f
    )
}



# TP CA sub-commands

function tp_ca {
    local command="$1"
    shift || true

    case "${command}" in
        'init' | 'sign' | 'clean' )
            "tp_ca_${command}" "$@"
            ;;
        * )
            echo "[TP] Unsupported CA command '${command}'."
            return 1
            ;;
    esac
}

function tp_ca_init {
    local ca_name="$1"

    if [[ -z "${ca_name}" ]]
    then
        echo "[TP] No CA name specified. Proceeding to initialize all CAs..."
        for ca_name in $( find "${TP_BASE_DIR}/ca" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort )
        do
            echo
            tp_ca_init "${ca_name}"
        done
        return $?
    fi

    tp_ca_clean "${ca_name}"
    echo "[TP] Creating scaffolding for CA '${ca_name}'..."
    (
        cd "${TP_BASE_DIR}/ca/${ca_name}"
        mkdir 'newcerts'
        mkdir 'private'
        chmod go-rwx 'private'
        touch db.txt
        # TODO use distinct serial ranges for individual cas
        echo -n D78B3C0000000001 > serial
    )

    echo "[TP] Preparing root certificate for CA '${ca_name}'..."
    tp_cert_selfsign "${TP_BASE_DIR}/ca/${ca_name}/ca-root.cert.conf"
}

function tp_ca_sign {
    local ca_name="$1"
    local cert_config_or_csr="$2"
    local cert_link="$3"
    # TODO remove support for the cert_link argument, always deduce from naming conventions instead!

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

    if [[ "${cert_config_or_csr}" =~ [.]cert[.]conf$ ]]
    then
        local config_file="${cert_config_or_csr}"
        local csr_file="$( echo "${config_file}" | sed -e 's/[.]cert[.]conf$/.csr.pem/' )"

        echo "[TP] Preparing CSR to sign, based on config file '${config_file}'..."
        tp_cert_request "${config_file}"
    else
        local csr_file="${cert_config_or_csr}"
        echo "[TP] Preparing to sign existing CSR..."
    fi

    local csr_file_path="$( cd "${TP_WORK_DIR}"; cd "$(dirname "${csr_file}")" ; pwd -P )/$(basename "${csr_file}")"
    if [[ "${cert_link}" ]]
    then
        local cert_link_path="$( cd "${TP_WORK_DIR}"; cd "$(dirname "${cert_link}")" ; pwd -P )/$(basename "${cert_link}")"
    else
        local cert_link_path="$( echo "${csr_file_path}" | sed -e 's/[.]csr[.]pem$/.cert.pem/' )"
    fi

    (
        cd "${TP_BASE_DIR}/ca/"
        local new_serial=$(<"${ca_name}/serial")
        local new_cert_file_path="$( pwd -P )/${ca_name}/newcerts/${new_serial}.pem"

        echo "[TP] Signing CSR from '${csr_file_path}' with CA ${ca_name} at serial ${new_serial}..."
        echo
        (
            set -x
            openssl ca -config 'ca.conf' -name "${ca_name}" -batch -notext -passin env:TP_PASS -in "${csr_file_path}"
        )
        echo
        echo "[TP] New certificate in '${new_cert_file_path}'."

        echo
        tp_cert_show "${new_cert_file_path}"
        echo
        tp_cert_fingerprint "${new_cert_file_path}"

        # TODO also generate and link full cert-chain
        # TODO extract cert link behavior to a separate utility function? also needed for ACME certs

        if [[ "${cert_link_path}" ]]
        then
            # TODO use relative paths in symlinks, because absolute paths break in container bind mounts
            ln -sf "${new_cert_file_path}" "${cert_link_path}"
            echo
            echo "[TP] Also linked certificate into '${cert_link_path}'."
        fi
    )
}

function tp_ca_clean {
    local ca_name="$1"

    if [[ -z "${ca_name}" ]]
    then
        echo "[TP] No CA name specified. Proceeding to clean all CAs..."
        for ca_name in $( find "${TP_BASE_DIR}/ca" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort )
        do
            tp_ca_clean "${ca_name}"
        done
        return $?
    fi

    echo "[TP] Cleaning transient files of CA '${ca_name}'..."
    (
        cd "${TP_BASE_DIR}/ca/${ca_name}"
        find . -type d -and '(' -name 'newcerts' -or -name 'private' ')' | xargs rm -rf
        find . -type f -and -not '(' -name '*.conf' -or -name '*.md' ')' | xargs rm -f
    )
}



# TP ACME sub-commands

function tp_acme {
    local command="$1"
    shift || true

    case "${command}" in
        'init' | 'account' | 'challenges' | 'sign' | 'revoke' | 'clean' )
            "tp_acme_${command}" "$@"
            ;;
        * )
            echo "[TP] Unsupported ACME command '${command}'."
            return 1
            ;;
    esac
}

function tp_acme_init {
    echo "[TP] Initializing ACME and Certbot..."
    tp_util_template "${TP_BASE_DIR}/acme/certbot/cli.ini.tmpl" TP_BASE_DIR TP_ACME_SERVER_URL TP_ACME_ACCOUNT_EMAIL
    tp_server_nginx_init "${TP_BASE_DIR}/acme/challenges-nginx"
}

function tp_acme_account {
    local command="$1"
    shift || true

    case "${command}" in
        'register' | 'unregister' )
            "tp_acme_account_${command}"
            ;;
        * )
            echo "[TP] Unsupported ACME account command '${command}'."
            return 1
            ;;
    esac
}

function tp_acme_account_register {
     certbot --config "${TP_BASE_DIR}/acme/certbot/cli.ini" register
}

function tp_acme_account_unregister {
     certbot --config "${TP_BASE_DIR}/acme/certbot/cli.ini" unregister
}

function tp_acme_challenges {
    local command="$1"
    shift || true

    case "${command}" in
        'run' | 'start' | 'stop' )
            "tp_server_nginx_${command}" "${TP_BASE_DIR}/acme/challenges-nginx"
            ;;
        * )
            echo "[TP] Unsupported ACME challenges command '${command}'."
            return 1
            ;;
    esac
}

function tp_acme_sign {
    # TODO this implementation uses custom CSR and webroot challenge
    # TODO implement alternative with manual challenge
    # TODO implement alternative with Certbot-managed keys and csr (using a proper certbot lineage)

    local cert_config_or_csr="$1"

    if [[ -z "${cert_config_or_csr}" ]]
    then
        echo "[TP] Nothing to sign. Specify a certificate config file or a CSR!"
        return 1
    fi

    # TODO copied from tp_ca_sign, extract to utility function?
    if [[ "${cert_config_or_csr}" =~ [.]cert[.]conf$ ]]
    then
        local config_file="${cert_config_or_csr}"
        local csr_file="$( echo "${config_file}" | sed -e 's/[.]cert[.]conf$/.csr.pem/' )"

        echo "[TP] Preparing CSR to sign, based on config file '${config_file}'..."
        tp_cert_request "${config_file}"
    else
        local csr_file="${cert_config_or_csr}"
        echo "[TP] Preparing to sign existing CSR..."
    fi

    # calculate certificate file paths
    local cert_file="$( echo "${csr_file}" | sed -e 's/[.]csr[.]pem$/.cert.pem/' )"
    local chain_file="$( echo "${csr_file}" | sed -e 's/[.]csr[.]pem$/.chain.pem/' )"
    local fullchain_file="$( echo "${csr_file}" | sed -e 's/[.]csr[.]pem$/.fullchain.pem/' )"

    # clean old certificate files, because Certbot refuses to overwrite them
    rm -f "${cert_file}" "${chain_file}" "${fullchain_file}"

    echo "[TP] Signing CSR from '${csr_file}' with ACME..."
    echo
    (
        set -x
        certbot \
            --config "${TP_BASE_DIR}/acme/certbot/cli.ini" \
            certonly \
            --csr "${csr_file}" \
            --cert-path "${cert_file}" \
            --chain-path "${chain_file}" \
            --fullchain-path "${fullchain_file}" \
    )
    echo
    echo "[TP] New certificate in '${cert_file}'."

    echo
    tp_cert_show "${cert_file}"
    echo
    tp_cert_fingerprint "${cert_file}"
}

function tp_acme_revoke {
    local cert_file="$1"

    # TODO also provide --key-path arg, if corresponding private key is available
    #      this may be necessary after acme account changed (or if authorizations expired?)

    echo "[TP] Revoking certificate in '${cert_file}' with ACME..."
    echo
    (
        set -x
        certbot \
            --config "${TP_BASE_DIR}/acme/certbot/cli.ini" \
            revoke \
            --cert-path "${cert_file}" \
    )
    echo
    echo "[TP] Revoked certificate from '${cert_file}'."
}

function tp_acme_clean {
    echo "[TP] Cleaning transient ACME and Certbot files..."
    rm -f "${TP_BASE_DIR}/acme/certbot/cli.ini"
    find "${TP_BASE_DIR}/acme/certbot/conf" -mindepth 1 -maxdepth 1 -type d -and -not -name 'accounts' | xargs rm -rf
    rm -rf "${TP_BASE_DIR}/acme/certbot/lib"
    rm -rf "${TP_BASE_DIR}/acme/certbot/log"
    tp_server_nginx_clean "${TP_BASE_DIR}/acme/challenges-nginx"
}

# TODO show how to use certbot without own csr
# TODO show how to use certbot with manual challange
#ln -sf ../../../../acme/certbot/live/play.meeque.de/fullchain.pem server-nginx/servers/server0/tls/server.fullchain.pem
#ln -sf ../../../../../acme/certbot/live/play.meeque.de/privkey.pem server-nginx/servers/server0/tls/private/server.key.pem



# TP server sub-commands

function tp_server {
    local command="$1"
    shift || true

    case "${command}" in
        'init' | 'clean' )
            "tp_server_${command}" "$@"
            ;;
        'run' | 'start' | 'stop' )
            "tp_server_nginx_${command}" "${TP_BASE_DIR}/server-nginx"
            ;;
        * )
            echo "[TP] Unsupported demo server command '${command}'."
            return 1
            ;;
    esac
}

function tp_server_init {
    local cert_issuer="$1"

    echo "[TP] Initializing nginx-based demo server..."
    tp_server_nginx_init "${TP_BASE_DIR}/server-nginx"

    echo "[TP] Creating server certificates for nginx-based demo server..."
    if [[ -z "${cert_issuer}" ]]
    then
        echo "[TP] No certificate issuer specified. Assuming 'selfsign'."
        local cert_issuer="selfsign"
    fi
    if [[ ! "${cert_issuer}" =~ ^selfsign|ca|acme$ ]]
    then
        echo "[TP] Unsupported certificate issuer '$cert_issuer'."
        return 1
    fi
    for config_file in $( find "${TP_BASE_DIR}/server-nginx" -path '*/tls/*' -name '*.cert.conf' )
    do
        "tp_server_cert_${cert_issuer}" "${config_file}"
    done

    echo "[TP] Configuring trusted CAs for client certificates that the nginx-based demo server accepts..."
    local trusted_certs_file="${TP_BASE_DIR}/server-nginx/servers/server2/tls/trusted-clients-cas.certs.pem"
    :> "${trusted_certs_file}"

    for ca_name in $( find "${TP_BASE_DIR}/ca" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort )
    do
        local ca_root_cert="${TP_BASE_DIR}/ca/${ca_name}/ca-root.cert.pem"
        if [[ -f "${ca_root_cert}" ]]
        then
            echo "[TP] Adding root certificate of CA '${ca_name}' to trusted CAs file '${trusted_certs_file}'..."
            cat "${ca_root_cert}" >> "${trusted_certs_file}"
        else
            echo "[TP] Looks like CA '${ca_name}' is not initialized. Omitting it from trusted CAs file '${trusted_certs_file}'!"
        fi
    done

    # TODO install some dummy cert, if trusted certs file still empty, because nginx does not accept an empty file
}

function tp_server_clean {
    echo "[TP] Cleaning transient files of nginx-based demo server..."
    tp_server_nginx_clean "${TP_BASE_DIR}/server-nginx"
    tp_cert_clean "${TP_BASE_DIR}/server-nginx"
}

function tp_server_cert_selfsign {
    local config_file="$1"
    tp_cert_selfsign "${config_file}"
}

function tp_server_cert_ca {
    local config_file="$1"
    tp_ca_sign ca1 "${config_file}"
}

function tp_server_cert_acme {
    local config_file="$1"
    tp_acme_sign "${config_file}"
}

function tp_server_nginx_init {
    local server_dir="$1"

    for config_file_template in $( find "${server_dir}" -type f -and -name '*.tmpl' )
    do
        tp_util_template "${config_file_template}" TP_SERVER_DOMAIN TP_SERVER_LISTEN_ADDRESS TP_SERVER_HTTP_PORT TP_SERVER_HTTPS_PORT
    done

    mkdir -p "${server_dir}/var/logs"
}

function tp_server_nginx_run {
    local server_dir="$1"
    echo "[TP] Running nginx server at '${server_dir}' in the foreground..."
    nginx -p "${server_dir}" -c 'nginx.conf' -g 'daemon off;'
}

function tp_server_nginx_start {
    local server_dir="$1"
    echo "[TP] Starting nginx server at '${server_dir}' in the background..."
    nginx -p "${server_dir}" -c 'nginx.conf' -g 'daemon on;'
}

function tp_server_nginx_stop {
    local server_dir="$1"
    echo "[TP] Stopping nginx server at '${server_dir}'..."
    nginx -p "${server_dir}" -c 'nginx.conf' -s 'stop'
}

function tp_server_nginx_clean {
    local server_dir="$1"

    if [[ -f "${server_dir}/var/nginx.pid" ]]
    then
        echo "[TP] Looks like server in '${server_dir}' is still running. Aborting clean-up! Stop the server or remove its .pid file before trying again!"
        return 1
    fi

    for config_file_template in $( find "${server_dir}" -type f -and -name '*.tmpl' )
    do
        tp_util_template_clean "${config_file_template}"
    done

    rm -rf "${server_dir}/var"
}



# TP clean command

function tp_clean {
    echo "[TP] Cleaning up everything..."
    # TODO also clean demo clients
    tp_server_clean
    tp_acme_clean
    tp_ca_clean
}



# general TP utility functions

function tp_util_template {
    if [[ $# -le 1 ]]
    then
        echo "[TP] Template util needs at least 2 arguments, one template file and multiple template variable names!"
        return 1
    fi

    local template_file="$1"
    local target_file="$( echo "${template_file}" | sed -e 's/[.]tmpl$//' )"

    shift || true
    local var_names_array=( "$@" )
    local var_names_string=''
    for var_name in "${var_names_array[@]}"
    do
        var_names_string+='${'"${var_name}"'}'
    done

    echo -n "[TP] Generating file ${target_file} from template... "
    cat "${template_file}" | envsubst "${var_names_string}" > "${target_file}"
    echo "done."
}

function tp_util_template_clean {
    local template_file="$1"
    local target_file="$( echo "${template_file}" | sed -e 's/[.]tmpl$//' )"
    rm -f "${target_file}"
}



# TP entry point
tp_main "$@"

