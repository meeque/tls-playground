@Then CN in CSR file `{csr_file}` should match CN in certificate config file `{config_file}`

  local config_cn="$( tp_util_get_config_values "${config_file}" 'CN' '.*' )"
  [[ -n ${config_cn} ]] || fail "could not find a CN field in config file \`${config_file}\`" || return 1

  local csr_cn="$( tp cert show "${csr_file}" | grep -E '^(\s)+Subject:' | grep -o -E 'CN=(\S)+' | sed -e 's/^CN=//' )"
  [[ -n "${csr_cn}" ]] || fail "could not find a CN field in CSR file \`${csr_file}\`" || return 1

  [[ "${csr_cn}" == "${config_cn}" ]] || fail "CN in CSR is \`${csr_cn}\`, but CN in certificate config is \`${config_cn}\`" || return 1



@Then CN in certificate file `{cert_file}` should match CN in CSR file `{csr_file}`

  local csr_cn="$( tp cert show "${csr_file}" | grep -E '^(\s)+Subject:' | grep -o -E 'CN=(\S)+' | sed -e 's/^CN=//' )"
  [[ -n "${csr_cn}" ]] || fail "could not find a CN field in CSR file \`${csr_file}\`" || return 1

  local cert_cn="$( tp cert show "${cert_file}" | grep -E '^(\s)+Subject:' | grep -o -E 'CN=(\S)+' | sed -e 's/^CN=//' )"
  [[ -n ${cert_cn} ]] || fail "could not find a CN field in certificate file \`${cert_file}\`" || return 1

  [[ "${cert_cn}" == "${csr_cn}" ]] || fail "CN in certificate is \`${cert_cn}\`, but CN in CSR is \`${csr_cn}\`" || return 1
