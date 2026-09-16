@Then CN in CSR file `{csr_file}` should match CN in certificate config file `{config_file}`
  . ../bin/tp
  config_cn="$( tp_util_get_config_values "${config_file}" 'CN' '.*' )"
  csr_cn="$( tp cert show "${csr_file}" | grep -E '^(\s)+Subject:' | grep -o -E 'CN=(\S)+' | sed -e 's/^CN=//' )"
  [[ "${csr_cn}" == "${config_cn}" ]] || fail "CN in CSR is \`${csr_cn}\`, but CN in certificate config is \`${config_cn}\`"

@Then CN in certificate file `{cert_file}` should match CN in CSR file `{csr_file}`
  . ../bin/tp
  csr_cn="$( tp cert show "${csr_file}" | grep -E '^(\s)+Subject:' | grep -o -E 'CN=(\S)+' | sed -e 's/^CN=//' )"
  cert_cn="$( tp cert show "${cert_file}" | grep -E '^(\s)+Subject:' | grep -o -E 'CN=(\S)+' | sed -e 's/^CN=//' )"
  [[ "${cert_cn}" == "${csr_cn}" ]] || fail "CN in certificate is \`${cert_cn}\`, but CN in CSR is \`${csr_cn}\`"
