# deploy few into various environments
# only works in the axon-ui git repo
# this could be improved to change directory into that repo first, but meh. not a big deal
# this could also be improved by not allowing a deployment into staging and prod unless the branch is master

validate_input() {
    ENV=ag1
    if [ "$1" != "" ]; then
        if [[ "$1" != "ag1" && "$1" != "staging" && "$1" != "prod" ]]; then
            echo "invalid environments. valid environments are ag1, staging, and prod"
            return 1
        fi
        ENV="$1"
    fi
    return 0
}



few_deploy() {
  validate_input $1
  RESULT=$?
  if [ $((RESULT)) -eq 0 ]; then
    gh workflow run ais-${ENV}-pipeline.yaml -r $(git branch --show-current) -F packages=vr-few
  fi
  sleep 3
  xdg-open $(gh run list --workflow=ais-${ENV}-pipeline.yaml --json url -q '.[0].url')
}

view_deploy() {
  validate_input $1
  RESULT=$?
  if [ $((RESULT)) -eq 0 ]; then
    xdg-open $(gh run list --workflow=ais-${ENV}-pipeline.yaml --json url -q '.[0].url')
  fi
}

alias viewpr="gh pr view --web"

npr() {
  local title=""
  local reviewers=()
  local modifier=1

  # Parse options: -t requires an argument; -d and -w are flags.
  while getopts ":t:dwa" opt; do
    case $opt in
      t)
        title="$OPTARG"
        ;;
      d)
        reviewers+=("dloman")
        ;;
      w)
        reviewers+=("dwild")
        ;;
      a)
        reviewers+=("abirutis")
        ;;
      \?)
        modifier=2
        ;;
      :)
        echo "Option -$OPTARG requires an argument." >&2
        return 1
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
  local cmd="gh pr create -a lhemsley -t \"$title\" $reviewers_arg $@"
  echo "$cmd"
  eval "$cmd"
}

