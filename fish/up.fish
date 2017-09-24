
set UP_DIR_CMD 'cd'
# Usage: up partial-parent-dir-component
function up
  if test (count $argv) -ne 1
    echo 'Usage:' (status current-function) 'parent-dir'
    return 1
  end

  # Just use the search term if it is rooted.
  if string match -q '/*' "$argv[1]"
    echo "$UP_DIR_CMD $argv[1]"
    return 0
  end

  set -l result (dirsearch_up_first "$PWD" "$argv[1]")
  if test $status -eq 0
    echo "$UP_DIR_CMD $result"
    return 0
  end

  return 1
end
function pup
  set -l old_dir_cmd "$UP_DIR_CMD"
  set UP_DIR_CMD 'pushd'
  up "$argv"
  set -l ret_val "$status"
  set UP_DIR_CMD "$old_dir_cmd"
  return $ret_val
end
function oup
  set -l old_dir_cmd "$UP_DIR_CMD"
  set UP_DIR_CMD 'open'
  up "$argv"
  set -l ret_val "$status"
  set UP_DIR_CMD "$old_dir_cmd"
  return $ret_val
end
complete -c up --no-files -xa '(dirlist_up)'
complete -c pup -w up
complete -c oup -w up

# TODO: Swap to "string lower $str" once fish 2.7 is released.
function to_lower --argument str
  echo "$str" | tr [:lower:] [:upper:]
end

# args: [cur_dir=$PWD]
function dirlist_up --argument cur_dir
  if test -z "$cur_dir"
    set cur_dir "$PWD"
  end
  set -l components (string split '/' "$cur_dir")
  set -e components[1] # Delete first element, as it will be an empty string.

  set -l path ''
  for component in $components
    set -l path "$path/$component"
    echo "$path"
  end
end

# args: search_term [cur_dir=$PWD]
function dirsearch_up_first --argument search_term cur_dir
  if test -z "$cur_dir"
    set cur_dir "$PWD"
  end
  set -l components (string split '/' "$cur_dir")
  set -e components[1] # Delete first element, as it will be an empty string.

  # Try case sensitive.
  set -l path ''
  for component in $components
    set -l path "$path/$component"
    if string match -q "*$search_term*" "$component"
      echo $path
      return 0
    end
  end

  # Backup: case insensitive.
  set -l search_term (to_lower "$search_term")
  set -l path ''
  for component in $components
    set -l path "$path/$component"
    if string match -q "*$search_term*" (to_lower "$component")
      echo $path
      return 0
    end
  end

  return 1
end
