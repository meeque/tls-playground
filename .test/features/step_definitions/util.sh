@When I run `{command} {arg}`

  run "${command} \"${arg}\""



@Then the command should succeed

  [[ "${LAST_EXIT_CODE}" == '0' ]] || fail "The previous command ran with a non-zero exit code, indicating failure"



@Then the command should fail

  [[ "${LAST_EXIT_CODE}" != '0' ]] || fail "The previous command ran with a zero exit code, indicating success"



@Then the command should print {number} lines of text

  num="$( echo "${LAST_STDOUT}" | wc -l )"
  [[ "${num}" -eq "${number}" ]] || fail "Printed ${num} lines of text"



@Then the command should print no text

  [[ -z "${LAST_STDOUT}" ]] || fail "Did print more text than expected"



@Then the command should print "{output}"

  [[ "${LAST_STDOUT}" == "${output}" ]] || fail "Did not print the expected text"



@Then TP should run command `{command}`

  tpt_extract_commands "${LAST_STDOUT}" | grep -q -F "${command}" || fail "Could not find the command logged in TP outputs"



@Then TP should print "{output}"

  tpt_extract_tp_outputs "${LAST_STDOUT}" | grep -q -F "${output}" || fail "Could not find the expected text"



@Then a sub-command should print "{output}"

  tpt_extract_command_outputs "${LAST_STDOUT}" | grep -q -F "${output}" || fail "Could not find the expected text"



@Then a sub-command should print error "{error}"

  tpt_extract_command_outputs "${LAST_STDERR}" | grep -q -F "${error}" || fail "Could not find the expected text"



@Then {file_role} file `{file_path}` should exist

  run "ls \"${file_path}\""
  [[ "${LAST_EXIT_CODE}" == '0' ]] || fail "Expected file does not exit."



@Then {file_role} file `{file_path}` should NOT exist

  run "ls \"${file_path}\""
  [[ "${LAST_EXIT_CODE}" != '0' ]] || fail "Unexpected file exits."



@Then {number} files in `{directory}` should match wildcard pattern `{pattern}`

  num="$( find "${directory}" -name "${pattern}" | wc -l )"
  [[ "${num}" -eq "${number}" ]] || fail "${num} files matched the pattern"
