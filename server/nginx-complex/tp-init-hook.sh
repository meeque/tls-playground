
tp_msg "Configuring trusted CAs for client certificates that the 'nginx-complex' demo server accepts..."
local trusted_clients_cas_file="${tp_base_dir}/server/nginx-complex/virtual/server2/tls/trusted-clients-cas.certs.pem"
:> "${trusted_clients_cas_file}"

for ca_name in 'ca4all' 'ca4clients'
do
    local ca_root_cert="${tp_base_dir}/ca/${ca_name}/ca-root.cert.pem"
    if [[ -f "${ca_root_cert}" ]]
    then
        tp_msg "Adding root certificate of CA '${ca_name}' to trusted clients CAs file '${trusted_clients_cas_file}'..."
        cat "${ca_root_cert}" >> "${trusted_clients_cas_file}"
    else
        tp_msg "Looks like CA '${ca_name}' is not initialized. Omitting it from trusted clients CAs file!"
    fi
done

# trusted certs file may still be empty, if TLS Playground CAs have not been initialized yet
# if so, install a self-signed fallback cert, because nginx does not accept an empty trusted certs file
if [[ ! -s ${trusted_clients_cas_file} ]]
then
    echo
    tp_msg "Looks like no trusted clients CAs are available. Using self-signed fallback certificate instead..."
    local fallback_cert_path="${tp_base_dir}/server/nginx-complex/virtual/server2/tls/trusted-clients-fallback"
    tp_cert_selfsign "${fallback_cert_path}.cert.conf"
    tp_msg "Adding self-signed fallback certificate to trusted clients CAs file '${trusted_clients_cas_file}'..."
    cat "${fallback_cert_path}.cert.pem" > "${trusted_clients_cas_file}"
fi
