@When I run `{command}`

  run "${command}"



@Then the command should succeed

  (( LAST_EXIT_CODE == 0 )) \
    || fail "The previous command ran with a non-zero exit code, indicating failure"



@Then the command should fail

  (( LAST_EXIT_CODE != 0 )) \
    || fail "The previous command ran with a zero exit code, indicating success"



@Then the command should print {number} lines of text

  num="$( echo "${LAST_STDOUT}" | wc -l )"
  [[ "${num}" -eq "${number}" ]] \
    || fail "Printed ${num} lines of text"



@Then the command should print no text

  [[ -z "${LAST_STDOUT}" ]] \
    || fail "Did print more text than expected"



@Then the command should print "{output}"

  [[ "${LAST_STDOUT}" == "${output}" ]] \
    || fail "Did not print the expected text"



@Then TP should run command `{command}`

  tpt_extract_commands "${LAST_STDOUT}" \
    | grep -q -F "${command}" \
      || fail "Could not find the command logged in TP outputs"



@Then TP should print "{output}"

  tpt_extract_tp_outputs "${LAST_STDOUT}" \
    | grep -q -F "${output}" \
      || fail "Could not find the expected text"



@Then a sub-command should print "{output}"

  tpt_extract_command_outputs "${LAST_STDOUT}" \
    | grep -q -F "${output}" \
      || fail "Could not find the expected text"



@Then a sub-command should print error "{error}"

  tpt_extract_command_outputs "${LAST_STDERR}" \
    | grep -q -F "${error}" \
      || fail "Could not find the expected text"



@Then {file_role} file `{file_path}` should exist

  [[ -f "${file_path}" ]] \
    || fail "Expected regular file does not exist."



@Then {file_role} file `{file_path}` should NOT exist

  [[ ! -e "${file_path}" ]] \
    || fail "Unexpected $( stat -c '%F' "${file_path}" ) exists at given path."



@Then {file_role} directory `{file_path}` should exist

  [[ -d "${file_path}" ]] \
    || fail "Expected directory does not exist."



@Then {file_role} directory `{file_path}` should NOT exist

  [[ ! -e "${file_path}" ]] \
    || fail "Unexpected $( stat -c '%F' "${file_path}" ) exists at given path."



@Then file `{file_path}` should be empty

  [[ -f "${file_path}" ]] \
    || fail "Expected file does not exist." || return
  [[ ! -s "${file_path}" ]] \
    || fail "File is not empty."



@Then files `{file_path_1}` and `{file_path_2}` should have identical contents

  [[ -f "${file_path_1}" ]] \
    || fail "Expected file at '${file_path_1}' does not exist." || return
  [[ -f "${file_path_2}" ]] \
    || fail "Expected file at '${file_path_2}' does not exist." || return
  cmp -s "${file_path_1}" "${file_path_2}" \
    || fail "File contents do not match."



@Then file `{file_path_1}` should be the concatenation of files `{file_path_2}` and `{file_path_3}`

  [[ -f "${file_path_1}" ]] \
    || fail "Expected file at '${file_path_1}' does not exist." || return
  [[ -f "${file_path_2}" ]] \
    || fail "Expected file at '${file_path_2}' does not exist." || return
  [[ -f "${file_path_3}" ]] \
    || fail "Expected file at '${file_path_3}' does not exist." || return
  cmp -s "${file_path_1}" <( cat "${file_path_2}" "${file_path_3}" ) \
    || fail "File contents are not a concatenation as expected."



@Then {number} files in `{directory}` should match wildcard pattern `{pattern}`

  num="$(
    find "${directory}" -name "${pattern}" \
      | wc -l
  )"
  [[ "${num}" -eq "${number}" ]] \
    || fail "${num} files matched the pattern"
