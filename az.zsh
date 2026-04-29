
#cloud first arg, subscription next arg
azsub() {

  if [ "$#" -lt 2 ]; then
    echo "requires two args. first is cloud (AzureUSGovernment AzureCloud), second is subscription name (US1, US2)"
    return 1
  fi

  if [[ "$1" != "AzureUSGovernment" && "$1" != "AzureCloud" ]]; then
    echo "first arg must be cloud (AzureUSGovernment / AzureCloud)"
    return 1
  fi

  az cloud set --name "$1" > /dev/null 2>&1

  az account set --subscription "$(az account list --query "[?contains(name, '${2}')].id" -o tsv)"

  echo "azure subscription changed to $(az account show --query name)"
}
