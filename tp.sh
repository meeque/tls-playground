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
    export TP_BASE_DIR="$( realpath --relative-to '.' "$(dirname "$0")/" )"
}

function tp_main_env_defaults {
    # TODO do not hard-code the passphrase. instead try to load it from a file, if the envar is empty. if the file is missing, generate a new passphrase and store it in the file
    export TP_PASS="${TP_PASS:=1234}"

    # TODO move closer to commands that actually use these env-vars?
    # TODO validate CLI args, too? e.g. for file naming conventions and file existence?
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
    local cert_config_or_csr="$1"

    if [[ -z "${cert_config_or_csr}" ]]
    then
        echo "[TP] No certificate config file name specified. Specify the config file for the CSR!"
        return 1
    fi

    tp_util_names 'names' "${cert_config_or_csr}"

    if [[ "${names[suffix]}" == 'csr.pem' ]]
    then
        # TODO check if the file actually exists
        echo "[TP] CSR aleady exiss in '${cert_config_or_csr}'. Doing nothing."
        return 0
    elif [[ "${names[suffix]}" != 'cert.conf' ]]
    then
        echo "[TP] Creating a CSR from file '${cert_config_or_csr}' is not supported!"
        echo "[TP] Specify a certificate configuration (.cert.conf) file!"
        return 1
    fi

    # TODO clean up chain and fullchain files? if they exist they wouldn't match the new key afterwards
    mkdir -p "${names[dir]}/private"
    chmod og-rwx "${names[dir]}/private"

    echo "[TP] Using OpenSSL certificate config file '${names[cert_conf_path]}':"
    echo
    cat "${names[cert_conf_path]}"
    echo

    echo "[TP] Generating key-pair and CSR..."
    echo
    (
        set -x
        openssl req -new -config "${names[cert_conf_path]}" -newkey rsa:2048 -passout env:TP_PASS -keyout "${names[key_pem_path]}" -out "${names[csr_pem_path]}"
    )
    echo
    echo "[TP] New private key in '${names[key_pem_path]}'."
    echo "[TP] New CSR in '${names[csr_pem_path]}'."
}

function tp_cert_selfsign {
    local cert_config_or_csr="$1"

    if [[ -z "${cert_config_or_csr}" ]]
    then
        echo "[TP] Nothing to self-sign. Specify a certificate config file or a CSR!"
        return 1
    fi

    tp_cert_request "${cert_config_or_csr}"
    tp_util_names 'names' "${cert_config_or_csr}"

    echo "[TP] Signing CSR with it's own private key..."
    echo
    (
        set -x
        openssl x509 -req -in "${names[csr_pem_path]}" -days 90 -signkey "${names[key_pem_path]}" -passin env:TP_PASS -out "${names[cert_pem_path]}"
    )
    echo
    echo "[TP] New certificate in '${names[cert_pem_path]}'."
    :> "${names[chain_pem_path]}"
    echo "[TP] New (empty) certificate chain in '${names[chain_pem_path]}'."
    cp "${names[cert_pem_path]}" "${names[fullchain_pem_path]}"
    echo "[TP] New (single-entry) certificate full-chain in '${names[fullchain_pem_path]}'."

    echo
    tp_cert_show "${names[cert_pem_path]}"
    echo
    tp_cert_fingerprint "${names[cert_pem_path]}"
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

function tp_cert_link {
    source="$1"
    target="$2"

    tp_util_names "source_names" "${source}"
    tp_util_names "target_names" "${target}"
    echo "XXX source: ${source_names[cert_pem_path]}"
    echo "XXX target: ${target_names[cert_pem_path]}"

    ln -sf "${source_names[cert_pem_path]}" "${target_names[cert_pem_path]}"
    echo "[TP] Linked new certificate into '${target_names[cert_pem_path]}'."
    ln -sf "${source_names[chain_pem_path]}" "${target_names[chain_pem_path]}"
    echo "[TP] Linked new certificate chain into '${target_names[chain_pem_path]}'."
    ln -sf "${source_names[fullchain_pem_path]}" "${target_names[fullchain_pem_path]}"
    echo "[TP] Linked new certificate full-chain into '${target_names[fullchain_pem_path]}'."
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
        for ca_name in $( tp_ca_list )
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

    if [[ -z "${ca_name}" ]]
    then
        echo "[TP] No CA name specified. Specify the CA to sign with!"
        return 1
    elif [[ ! -d "${TP_BASE_DIR}/ca/${ca_name}" ]]
    then
        echo "[TP] CA with name '${ca_name}' does not exist!"
        echo "[TP] Try one of the following instead:"
        tp_ca_list
        return 1
    fi

    if [[ -z "${cert_config_or_csr}" ]]
    then
        echo "[TP] Nothing to sign. Specify a certificate config file or a CSR!"
        return 1
    fi

    tp_cert_request "${cert_config_or_csr}"

    tp_util_names 'target_names' "${cert_config_or_csr}"
    tp_util_names 'ca_names' "${TP_BASE_DIR}/ca/${ca_name}/ca-root.cert.pem"
    local new_serial=$(<"${ca_names[dir]}/serial")
    tp_util_names 'new_names' "${TP_BASE_DIR}/ca/${ca_name}/newcerts/${new_serial}.pem"

    local csr_pem_rel_path="$( realpath --relative-to "${TP_BASE_DIR}/ca/" "${target_names[csr_pem_path]}" )"

    echo "[TP] Signing CSR from '${target_names[csr_pem_path]}' with CA ${ca_name} at serial ${new_serial}..."
    echo
    (
        cd "${TP_BASE_DIR}/ca/"
        set -x
        openssl ca -config 'ca.conf' -name "${ca_name}" -batch -passin env:TP_PASS -in "${csr_pem_rel_path}" -notext
    )
    echo
    cat "${new_names[file_path]}" > "${new_names[cert_pem_path]}"
    echo "[TP] New certificate in '${new_names[cert_pem_path]}'."
    cat "${ca_names[fullchain_pem_path]}" > "${new_names[chain_pem_path]}"
    echo "[TP] New certificate chain in '${new_names[chain_pem_path]}'."
    cat "${new_names[cert_pem_path]}" "${ca_names[fullchain_pem_path]}" > "${new_names[fullchain_pem_path]}"
    echo "[TP] New certificate full-chain in '${new_names[fullchain_pem_path]}'."

    echo
    tp_cert_show "${new_names[cert_pem_path]}"
    echo
    tp_cert_fingerprint "${new_names[cert_pem_path]}"

    echo
    tp_cert_link "$( realpath --relative-to "${target_names[dir]}/" "${new_names[file_path]}" )" "$( realpath --relative-to . "${target_names[file_path]}" )"
}

function tp_ca_clean {
    local ca_name="$1"

    if [[ -z "${ca_name}" ]]
    then
        echo "[TP] No CA name specified. Proceeding to clean all CAs..."
        for ca_name in $( find "${TP_BASE_DIR}/ca" -mindepth 1 -maxdepth 1 -type d  -exec basename '{}' ';' | sort )
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

function tp_ca_list {
    find "${TP_BASE_DIR}/ca" -mindepth 1 -maxdepth 1 -type d  -exec basename '{}' ';' | sort
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
    tp_util_template "${TP_BASE_DIR}/acme/certbot/cli.ini.tmpl" TP_ACME_SERVER_URL TP_ACME_ACCOUNT_EMAIL
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
        echo "[TP] Nothing to sign with ACME. Specify a certificate config file or a CSR!"
        return 1
    fi

    tp_cert_request "${cert_config_or_csr}"
    tp_util_names 'names' "${cert_config_or_csr}"

    # clean old certificate files, because Certbot refuses to overwrite them
    rm -f "${names[cert_pem_path]}" "${names[chain_pem_path]}" "${names[fullchain_pem_path]}"

    echo "[TP] Signing CSR from '${names[csr_pem_path]}' with ACME..."
    echo
    (
        # TODO change into TP base-dir or acme-dir, since paths in cli.ini are relative
        set -x
        certbot \
            --config "${TP_BASE_DIR}/acme/certbot/cli.ini" \
            certonly \
            --csr "${names[csr_pem_path]}" \
            --cert-path "${names[cert_pem_path]}" \
            --chain-path "${names[chain_pem_path]}" \
            --fullchain-path "${names[fullchain_pem_path]}" \
    )
    echo
    echo "[TP] New certificate in '${names[cert_pem_path]}'."
    echo "[TP] New certificate chain in '${names[chain_pem_path]}'."
    echo "[TP] New certificate full-chain in '${names[fullchain_pem_path]}'."

    echo
    tp_cert_show "${names[cert_pem_path]}"
    echo
    tp_cert_fingerprint "${names[cert_pem_path]}"
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
    find acme/certbot -mindepth 1 -type d -and -not -path '*/conf' -and -not -path '*/conf/accounts' | xargs rm -rf
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

    echo
    echo "[TP] Configuring trusted CAs for client certificates that the nginx-based demo server accepts..."
    local trusted_certs_file="${TP_BASE_DIR}/server-nginx/servers/server2/tls/trusted-clients-cas.certs.pem"
    :> "${trusted_certs_file}"

    for ca_name in $( find "${TP_BASE_DIR}/ca" -mindepth 1 -maxdepth 1 -type d  -exec basename '{}' ';' | sort )
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

function tp_util_names {
    local varname="$1"
    local file_path="$2"

    if [[ -z "${varname}" ]]
    then
        echo "[TP] No variable name given to store file naming information!"
        return 1
    fi

    if [[ -z "${file_path}" ]]
    then
        echo "[TP] No file path given to extract naming information from!"
        return 1
    fi

    declare -A -g "${varname}"
    declare -n varref="${varname}"

    # TODO nomalize dir path
    local dir="$( dirname "${file_path}" )"
    local file="$( basename "${file_path}" )"
    local name="$( echo "${file}" | sed -e 's/[.].*$//' )"
    local suffix="$( echo "${file}" | sed --regexp-extended -e 's/^[^.]*[.]?//' )"
    local path="${dir}/${name}"

    varref=(
        # name components
        [name]="${name}"
        [suffix]="${suffix}"
        [dir]="${dir}"
        [path]="${path}"

        # file base names
        [cert_conf_file]="${name}.cert.conf"
        [key_pem_file]="${name}.key.pem"
        [csr_pem_file]="${name}.csr.pem"
        [cert_pem_file]="${name}.cert.pem"
        [chain_pem_file]="${name}.chain.pem"
        [fullchain_pem_file]="${name}.fullchain.pem"

        # file paths (dir + base name)
        [file_path]="${file_path}"
        [cert_conf_path]="${path}.cert.conf"
        [key_pem_path]="${dir}/private/${name}.key.pem"
        [csr_pem_path]="${path}.csr.pem"
        [cert_pem_path]="${path}.cert.pem"
        [chain_pem_path]="${path}.chain.pem"
        [fullchain_pem_path]="${path}.fullchain.pem"
    )
}

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

# if this script is NOT being sourced, run tp_main
# (in bash, return from outside a function only succeeds, when the script is being sourced)
if ! ( return 0 2>/dev/null )
then
    tp_main "$@"
fi

