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

    if [ "${2}" != "" ]; then
      if [[ "${2}" != "few" && "${2}" != "net-test" ]]; then
        echo "invalid application. valid apps are few and net-test"
        return 1
      fi
      APP="${2}"
    fi

    return 0
}



ui_deploy() {
  validate_input $1 $2
  RESULT=$?
  if [ $((RESULT)) -eq 0 ]; then
    gh workflow run ais-${ENV}-pipeline.yaml -r $(git branch --show-current) -F packages=vr-"${APP}"
  fi
  sleep 3
  xdg-open $(gh run list --workflow=ais-${ENV}-pipeline.yaml -e workflow_dispatch -u lhemsley --json url -q '.[0].url')
}

view_deploy() {
  validate_input $1
  RESULT=$?
  if [ $((RESULT)) -eq 0 ]; then
    xdg-open $(gh run list --workflow=ais-${ENV}-pipeline.yaml -e workflow_dispatch -u lhemsley --json url -q '.[0].url')
  fi
}

alias prv="gh pr view --web"

npr() {
  local title=""
  local reviewers=()
  local args=()

  while [[ $# -gt 0 ]]; do
    case $1 in
      -t)
        title=$2
        shift 2
        ;;
      -a)
        reviewers+=("dloman" "dwild" "abirutis")
        shift
        ;;
      -v)
        reviewers+=("vr/vrpod4")
        shift
        ;;
      -l)
        reviewers+=("dloman")
        shift
        ;;
      -w)
        reviewers+=("dwild")
        shift
        ;;
      -b)
        reviewers+=("abirutis")
        shift
        ;;
      *)
        args+=("$1")
        shift
        ;;
    esac
  done



  # Ensure a title was provided.
  if [[ -z "$title" ]]; then
    echo "Error: No title provided. Use -t \"<title>\" to set the PR title."
    return 1
  fi

  local reviewers_arg=""
  if [[ "${#reviewers[@]}" -gt 0 ]]; then
    reviewers_arg="-r $(IFS=,; echo "${reviewers[*]}")"
  fi

  # Construct and execute the gh command.
  local cmd="gh pr create -t \"${title}\" ${reviewers_arg} ${args[@]}"
  echo "$cmd"
  eval "$cmd"

  echo $(gh pr view --json url -q .url) | xclip -sel clip
  echo "url copied. now opening in browser"

  gh pr view --web
}

