# aliases surrounding kubernetes that i find useful

alias kcl="kubectl"
alias k_up="kubectl scale --replicas=1 --all=true deployments -n vrbe"
alias k_down="kubectl scale --replicas=0 --all=true deployments -n vrbe"
alias w_vrbe="watch -n 1 \"kubectl get pods -n vrbe\""
alias w_deps="watch -n 1 \"kubectl get pods -n vrbe-deps\""

vld() {
  local dir="/mnt/c/Users/lhemsley/git/ghes/vr/axonvr_azure"

  local apps=(auth laud content training telemetry)
  if [ $# -ge 1 ]; then
    apps=("${@:*apps}") #detects intersection in arguments and valid apps
  fi

  "${dir}/scripts/docker/login.sh"

  kubectl config use-context kind-vrbe-local

  echo "building dependencies for common"
  helm dependency build "${dir}/charts/common" 2>&1 > /dev/null
  echo ""

  for app in "${apps[@]}"; do
    echo "===${app}==="

    echo "building dependencies for ${app}"
    helm dependency build "${dir}/charts/${app}" 2>&1 > /dev/null

    echo "upgrading ${app} in the cluster"
    helm upgrade --install "${app}" "${dir}/charts/${app}" -f "${dir}/charts/${app}/values-local.yaml" -n vrbe 2>&1 > /dev/null

    echo "rollout restart on ${app} executed"
    kubectl rollout restart "deployments/vrbe-${app}-deploy" -n vrbe 2>&1 > /dev/null

    echo ""
  done
}
