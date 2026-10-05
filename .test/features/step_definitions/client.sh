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



@Given TP demo server `{server}` is running with certificates from TP demo CA `{ca}`

  run "tp ca clean ${ca}"
  (( LAST_EXIT_CODE == 0 )) \
    || fail "Precondition commmand \`tp ca clean ${ca}\` has failed." \
    || return 1

  run "tp server clean ${server}"
  (( LAST_EXIT_CODE == 0 )) \
    || fail "Precondition commmand \`tp server clean ${server}\` has failed." \
    || return 1

  run "tp ca init ${ca}"
  (( LAST_EXIT_CODE == 0 )) \
    || fail "Precondition commmand \`tp ca init ${ca}\` has failed." \
    || return 1

  run "tp server init --ca=${ca} ${server}"
  (( LAST_EXIT_CODE == 0 )) \
    || fail "Precondition commmand \`tp server init --ca=${ca} ${server}\` has failed." \
    || return 1

  run "tp server start ${server}"
  (( LAST_EXIT_CODE == 0 )) \
    || fail "Precondition commmand \`tp server start ${server}\` has failed." \
    || return 1

  defer "tp server stop ${server}"
