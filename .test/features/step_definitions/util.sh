@Given {file_role} file `{file_path}`

  run "ls \"${file_path}\""
  [[ "${LAST_EXIT_CODE}" == '0' ]] || fail "Expected file \"${file_path}\" does not exits."



@When I run `tp {command} {arg}`

  run "tp ${command} \"${arg}\""



@Then the command should succeed

  [[ "${LAST_EXIT_CODE}" == '0' ]] || fail "Expected a commmand to run successfully, but it ran with exit code ${LAST_EXIT_CODE}."



@Then `tp` should generate {file_role} file `{file_path}`
  run "ls \"${file_path}\""
  [[ "${LAST_EXIT_CODE}" == '0' ]] || fail "Expected file \"${file_path}\" does not exits."
