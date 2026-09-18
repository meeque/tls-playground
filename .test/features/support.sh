# import library functions from the tp script
. ../bin/tp



function tpt_extract_commands {
  echo "$1" \
    | grep -E '^\S+\$\S+\s+' || true \
    | sed -E -e 's/^\S+\$\S+\s+//'
}
