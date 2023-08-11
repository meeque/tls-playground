
tp_msg "Cleaning trusted CAs file for client certificates that the 'nginx-complex' demo server accepted..."
local trusted_clients_cas_file="${tp_base_dir}/server/nginx-complex/virtual/server2/tls/trusted-clients-cas.certs.pem"

if [[ -f "${trusted_clients_cas_file}" ]]
then
    rm "${trusted_clients_cas_file}"
fi
