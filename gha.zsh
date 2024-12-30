# deploy few into various environments
# only works in the axon-ui git repo
# this could be improved to change directory into that repo first, but meh. not a big deal
# this could also be improved by not allowing a deployment into staging and prod unless the branch is master
few_deploy() {
    local ENV=ag1
    if [ "$1" != "" ]; then
        if [[ "$1" != "ag1" && "$1" != "staging" && "$1" != "prod" ]]; then
            echo "invalid environments. valid environments are ag1, staging, and prod"
            return 0
        fi
        ENV="$1"
    fi
    gh workflow run ais-${ENV}-pipeline.yaml -r $(git branch --show-current) -F packages=vr-few
}
