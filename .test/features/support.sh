# add `tp` script to path
if [[ ":$PATH:" != *":$PWD/bin:"* ]]
then
    PATH="$PWD/bin:$PATH"
fi

# also import library functions from the `tp` script
. bin/tp



function tpt_extract_tp_outputs {
  echo "$1" \
    | grep -E '^\S*\[TP\]\S*\s+' \
    | sed -E -e 's/^\S*\[TP\]\S*\s+//'
}



function tpt_extract_command_outputs {
  echo "$1" \
    | grep -E --invert-match '^\S*\[TP\]\S*\s+' \
    | grep -E --invert-match '^\S*\$\S*\s+'
}



function tpt_extract_commands {
  echo "$1" \
    | grep -E '^\S*\$\S*\s+' \
    | sed -E -e 's/^\S*\$\S*\s+//' \
      || true
}



function tpt_extract_cn {
  tp cert show "$1" \
    | sed -n -E 's/^\s+Subject:.*CN=(\S+).*/\1/p'
}
