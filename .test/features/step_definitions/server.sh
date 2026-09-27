@Given all TP demo servers have been cleaned

  run "tp server clean"
  (( LAST_EXIT_CODE == 0 )) \
    || fail "Precondition commmand \`tp server clean\` has failed."
