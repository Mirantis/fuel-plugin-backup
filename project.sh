#!/bin/bash
## Initial

. project/func
. project/conf

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

if [ "$1" == "backup" ]; then
  shift 1
  backup
elif [ "$1" == "purge" ]; then
  shift 1
  purge
elif [ "$1" == "restore" ]; then
  shift 1
  restore
else
  echo "Invalid selection."
  show_usage
fi
