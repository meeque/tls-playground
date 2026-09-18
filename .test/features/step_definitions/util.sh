@When I run `tp {command} {arg}`

  run "tp ${command} \"${arg}\""



@Then the command should succeed

  [[ "${LAST_EXIT_CODE}" == '0' ]] || fail "The previous command ran with a non-zero exit code, indicating failure"



@Then the command should fail

  [[ "${LAST_EXIT_CODE}" != '0' ]] || fail "The previous command ran with a zero exit code, indicating success"



@Then TP should have run command `{command}`

  prefixed_command_lines="$( echo "${LAST_STDOUT}" | grep -E '^\S+\$\S+\s+' )"
  plain_command_lines="$( echo "${prefixed_command_lines}" | sed -E -e 's/^\S+\$\S+\s+//' )"
  echo "${plain_command_lines}" | grep -F "${command}" > /dev/null || fail "Could not find the command logged in TP outputs"


@Then {file_role} file `{file_path}` should exist

  run "ls \"${file_path}\""
  [[ "${LAST_EXIT_CODE}" == '0' ]] || fail "Expected file does not exit."


@Then {file_role} file `{file_path}` should NOT exist

  run "ls \"${file_path}\""
  [[ "${LAST_EXIT_CODE}" != '0' ]] || fail "Unexpected file exits."
