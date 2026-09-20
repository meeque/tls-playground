# import library functions from the tp script
. ../bin/tp



function tpt_extract_tp_outputs {
  echo "$1" \
    | grep -E '^\S+\[TP\]\S+\s+' \
    | sed -E -e 's/^\S+\[TP\]\S+\s+//'
}



function tpt_extract_command_outputs {
  echo "$1" \
    | grep -E --invert-match '^\S+\[TP\]\S+\s+' \
    | grep -E --invert-match '^\S+\$\S+\s+'
}



function tpt_extract_commands {
  echo "$1" \
    | grep -E '^\S+\$\S+\s+' \
    | sed -E -e 's/^\S+\$\S+\s+//' \
      || true
}



function tpt_extract_cn {
  tp cert show "$1" \
    | grep -E '^\s+Subject:' \
    | grep -o -E 'CN=\S+' \
    | sed -e 's/^CN=//'
}
