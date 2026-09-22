@Given all TP CAs have been cleaned

  run "tp ca clean"
  (( LAST_EXIT_CODE == 0 )) \
    || fail "Precondition commmand \`tp ca clean\` has failed."
