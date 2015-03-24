#!/bin/bash
## Initial

. config/func
. config/conf

#Sets var nonopts
declare -a nonopts
parse_options "$@"
set -- "${nonopts[@]}"

if [ -z "$1" ] || [ "$1" = "help" ]; then
  ${GREEN}
  echo "Please specify a command."
  ${RESET}
  show_usage
  exit 1
fi



command_seq=$COMMANDS_SEQUENCE

if [ "$1" == "test" ]; then
  shift 1
  self
elif [ "$1" == "update_creds" ]; then
  shift 1
  update_credentials

else
  echo "Invalid selection."
  show_usage
fi
