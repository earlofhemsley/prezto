alias prv="gh pr view --web"

npr() {
  local title=""
  local reviewers=()
  local modifier=1

  # Parse options: -t requires an argument; -d and -w are flags.
  while getopts ":t:djp" opt; do
    case $opt in
      t)
        title="$OPTARG"
        ;;
      d)
        reviewers+=("drewstableboi")
        ;;
      j)
        reviewers+=("jonathanbutler7")
        ;;
      p)
        reviewers+=("jordanpaxman")
        ;;
      \?)
        modifier=2
        ;;
      :)
        # do nothing
        ;;
    esac
  done

  shift $((OPTIND - modifier))

  # Ensure a title was provided.
  if [[ -z "$title" ]]; then
    echo "Error: No title provided. Use -t \"<title>\" to set the PR title."
    return 1
  fi

  # Build the reviewers argument if any reviewers were selected.
  local reviewers_arg=""
  if [ ${#reviewers[@]} -gt 0 ]; then
    # Join reviewers with commas.
    reviewers_arg="-r $(IFS=,; echo "${reviewers[*]}")"
  fi

  # Construct and execute the gh command.
  local cmd="gh pr create -t \"$title\" $reviewers_arg $@"
  echo "$cmd"
  eval "$cmd"

  gh pr view --web
}

