@Given TP demo server `{server}` is running with self-signed certificates

  run "tp server clean ${server}"
  (( LAST_EXIT_CODE == 0 )) \
    || fail "Precondition commmand \`tp server clean ${server}\` has failed." \
    || return 1

  run "tp server init ${server}"
  (( LAST_EXIT_CODE == 0 )) \
    || fail "Precondition commmand \`tp server init ${server}\` has failed." \
    || return 1

  run "tp server start ${server}"
  (( LAST_EXIT_CODE == 0 )) \
    || fail "Precondition commmand \`tp server start ${server}\` has failed." \
    || return 1

  defer "tp server stop ${server}"
