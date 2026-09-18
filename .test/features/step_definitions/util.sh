@When I run `tp {command} {arg}`

  run "tp ${command} \"${arg}\""



@Then the command should succeed

  [[ "${LAST_EXIT_CODE}" == '0' ]] || fail "The previous command ran with a non-zero exit code, indicating failure"

@Then the command should fail

  [[ "${LAST_EXIT_CODE}" != '0' ]] || fail "The previous command ran with a zero exit code, indicating success"



@Then {file_role} file `{file_path}` should exist

  run "ls \"${file_path}\""
  [[ "${LAST_EXIT_CODE}" == '0' ]] || fail "Expected file does not exit."


@Then {file_role} file `{file_path}` should NOT exist

  run "ls \"${file_path}\""
  [[ "${LAST_EXIT_CODE}" != '0' ]] || fail "Unexpected file exits."
