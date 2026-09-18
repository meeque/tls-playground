@When I run `tp {command} {arg}`

  run "tp ${command} \"${arg}\""



@Then the command should succeed

  [[ "${LAST_EXIT_CODE}" == '0' ]] || fail "The previous command ran with a non-zero exit code, indicating failure"



@Then the command should fail

  [[ "${LAST_EXIT_CODE}" != '0' ]] || fail "The previous command ran with a zero exit code, indicating success"



@Then TP should have run command `{command}`

  tpt_extract_commands "${LAST_STDOUT}" | grep -F "${command}" > /dev/null || fail "Could not find the command logged in TP outputs"



@Then TP should have printed "{output}"

  tpt_extract_tp_outputs "${LAST_STDOUT}" | grep -F "${output}" > /dev/null || fail "Could not find the expected text"



@Then a nested command should have printed error "{output}"

  tpt_extract_command_outputs "${LAST_STDERR}" | grep -F "${output}" > /dev/null || fail "Could not find the expected text"



@Then {file_role} file `{file_path}` should exist

  run "ls \"${file_path}\""
  [[ "${LAST_EXIT_CODE}" == '0' ]] || fail "Expected file does not exit."



@Then {file_role} file `{file_path}` should NOT exist

  run "ls \"${file_path}\""
  [[ "${LAST_EXIT_CODE}" != '0' ]] || fail "Unexpected file exits."
