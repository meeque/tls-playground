@Given all sample certificates have been cleaned

  run "tp cert clean"
  (( LAST_EXIT_CODE == 0 )) \
    || fail "Precondition commmand \`tp cert clean\` has failed."



@Then CNs in CSR `{csr_file}` and config `{config_file}` should match

  local config_cn="$( tp_util_get_config_values "${config_file}" 'CN' '.*' )"
  [[ -n ${config_cn} ]] \
    || fail "could not find a CN field in config file \`${config_file}\`" \
    || return 1

  local csr_cn="$( tpt_extract_cn "${csr_file}" )"
  [[ -n "${csr_cn}" ]] \
    || fail "could not find a CN field in CSR file \`${csr_file}\`" \
    || return 1

  [[ "${csr_cn}" == "${config_cn}" ]] \
    || fail "CN in CSR is \`${csr_cn}\`, but CN in certificate config is \`${config_cn}\`"



@Then CNs in certificate `{cert_file}` and CSR `{csr_file}` should match

  local csr_cn="$( tpt_extract_cn "${csr_file}" )"
  [[ -n "${csr_cn}" ]] \
    || fail "could not find a CN field in CSR file \`${csr_file}\`" \
    || return 1

  local cert_cn="$( tpt_extract_cn "${cert_file}" )"
  [[ -n ${cert_cn} ]] \
    || fail "could not find a CN field in certificate file \`${cert_file}\`" \
    || return 1

  [[ "${cert_cn}" == "${csr_cn}" ]] \
    || fail "CN in certificate is \`${cert_cn}\`, but CN in CSR is \`${csr_cn}\`"
