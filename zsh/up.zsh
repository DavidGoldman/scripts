
UP_DIR_CMD='cd'
# Usage: up partial-parent-dir-component
up() {
  if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 parent-dir"
    return 1
  fi

  # Just use the search term if it is rooted.
  if [[ "$1" == "/"* ]]; then
    echo "$UP_DIR_CMD $1"
    return 0
  fi

  local result=$(dirsearch_up_first "$1")
  if [[ "$?" -eq 0 ]];  then
    echo "$UP_DIR_CMD $result"
    return 0
  fi

  return 1
}
pup() {
  local old_dir_cmd="$UP_DIR_CMD"
  UP_DIR_CMD='pushd'
  up "$@"
  local ret_val=$?
  UP_DIR_CMD="$old_dir_cmd"
  return $ret_val
}
oup() {
  local old_dir_cmd="$UP_DIR_CMD"
  UP_DIR_CMD='open'
  up "$@"
  local ret_val=$?
  UP_DIR_CMD="$old_dir_cmd"
  return $ret_val
}
# Save previous non-rooted search term
# to be able to cycle through.
__UP_COMPL_LAST_TERM=''
_up_tab_completion() {
  local args
  read -cA args
  shift args
  if [[ "${#args[@]}" -eq 1 ]]; then
    if [[ "${args[1]}" == "/"* ]]; then
      args[1]="${__UP_COMPL_LAST_TERM}"
    else
      __UP_COMPL_LAST_TERM="${args[1]}"
    fi
    _dirsearch_up_all "$PWD" "${args[1]}" reply
  else
    reply=()
  fi
}
compctl -U -K _up_tab_completion up
compctl -U -K _up_tab_completion pup
compctl -U -K _up_tab_completion oup

# args (cur_dir, search_term?, *out_arr)
_dirsearch_up_all() {
  if [[  $# -ne 3 ]]; then
    echo "Usage: $0 cur_dir, search_term, *out_var"
    return 1
  fi
  local components=(${(s:/:)1})

  local search_term="$2:l"
  local out_var="$3"
  eval "$out_var=()"

  local path=''
  for component in $components; do
    path="$path/$component"
    if [[ "${component:l}" == *"${search_term}"* ]]; then
      eval "$out_var+=(\$path)"
    fi
  done

  return 0
}

# args search_term [cur_dir=$PWD]
dirsearch_up_first() {
  if [[ -z "$2" ]]; then
    2="$PWD"
  fi
  local search_term="$1"
  local cur_dir="$2"
  local components=(${(s:/:)cur_dir})

  # Try case sensitive. Note the %% to go forwards.
  for component in $components; do
    if [[ $component == *"${search_term}"* ]]; then
      echo "${cur_dir%%$component*}${component}"
      return 0
    fi
  done

  # Backup: case insensitive. Note the %% to go forwards.
  search_term=$search_term:l
  for component in $components; do
    if [[ "${component:l}" == *"${search_term}"* ]]; then
      echo "${cur_dir%%$component*}${component}"
      return 0
    fi
  done

  return 1
}

# args search_term [cur_dir=$PWD]
dirsearch_up_last() {
  if [[ -z "$2" ]]; then
    2="$PWD"
  fi
  local search_term="$1"
  local cur_dir="$2"
  local components=(${(s:/:)cur_dir})

  # Try case sensitive. The (Oa) reverses the order.
  # Note the % to delete the shortest match.
  for component in ${(Oa)components}; do
    if [[ $component == *"${search_term}"* ]]; then
      echo "${cur_dir%$component*}${component}"
      return 0
    fi
  done

  # Backup: case insensitive. The (Oa) reverses the order.
  # Note the % to delete the shortest match.
  search_term=$search_term:l
  for component in ${(Oa)components}; do
    if [[ "${component:l}" == *"${search_term}"* ]]; then
      echo "${cur_dir%$component*}${component}"
      return 0
    fi
  done

  return 1
}
