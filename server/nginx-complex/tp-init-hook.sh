
echo "[TP] Configuring trusted CAs for client certificates that the 'nginx-complex' demo server accepts..."
local trusted_clients_cas_file="${TP_BASE_DIR}/server/nginx-complex/virtual/server2/tls/trusted-clients-cas.certs.pem"
:> "${trusted_clients_cas_file}"

for ca_name in $( tp_ca_list )
do
    local ca_root_cert="${TP_BASE_DIR}/ca/${ca_name}/ca-root.cert.pem"
    if [[ -f "${ca_root_cert}" ]]
    then
        echo "[TP] Adding root certificate of CA '${ca_name}' to trusted clients CAs file '${trusted_clients_cas_file}'..."
        cat "${ca_root_cert}" >> "${trusted_clients_cas_file}"
    else
        echo "[TP] Looks like CA '${ca_name}' is not initialized. Omitting it from trusted clients CAs file!"
    fi
done

# trusted certs file may still be empty, if TLS Playground CAs have not been initialized yet
# if so, install a self-signed fallback cert, because nginx does not accept an empty trusted certs file
if [[ ! -s ${trusted_clients_cas_file} ]]
then
    echo
    echo "[TP] Looks like no trusted clients CAs are available. Using self-signed fallback certificate instead..."
    local fallback_cert_path="${TP_BASE_DIR}/server/nginx-complex/virtual/server2/tls/trusted-clients-fallback"
    tp_cert_selfsign "${fallback_cert_path}.cert.conf"
    echo "[TP] Adding self-signed fallback certificate to trusted clients CAs file '${trusted_clients_cas_file}'..."
    cat "${fallback_cert_path}.cert.pem" > "${trusted_clients_cas_file}"
fi
