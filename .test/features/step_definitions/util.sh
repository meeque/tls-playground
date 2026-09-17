@When I run `tp {command} {arg}`

  run "tp ${command} \"${arg}\""



@Then the command should succeed

  [[ "${LAST_EXIT_CODE}" == '0' ]] || fail "Expected a commmand to run successfully, but it ran with exit code ${LAST_EXIT_CODE}."



@Then {file_role} file `{file_path}` should exist

  run "ls \"${file_path}\""
  [[ "${LAST_EXIT_CODE}" == '0' ]] || fail "Expected file does not exit."


@Then {file_role} file `{file_path}` should not exist

  run "ls \"${file_path}\""
  [[ "${LAST_EXIT_CODE}" != '0' ]] || fail "Unexpected file exits."
