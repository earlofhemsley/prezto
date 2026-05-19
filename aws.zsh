#!/usr/bin/env zsh

# open a db tunnel
tunnel() {
  if [[ -z "${AWS_ACCESS_KEY_ID}" || -z "${AWS_SECRET_ACCESS_KEY}" || -z "${AWS_SESSION_TOKEN}" ]]; then
    echo "must assume the aws role first. source assumeRole"
    return 1
  fi

  local lport=5434

  if [ $# -gt 0 ]; then
    lport="${1}"
  fi

  if ! [[ "${lport}" =~ ^[0-9]+$ ]]; then
    echo "first arg reps the integer port you're binding. must be an int. use better input or omit args to use 5434"
    return 1
  fi

  local ip
  ip=$(aws ec2 describe-instances --query "Reservations[].Instances[].NetworkInterfaces[].Association.PublicIp" --output text)
  ssh -L "${lport}":crzr-rds-db.c9muwimqk2jq.us-east-1.rds.amazonaws.com:5432 ec2-user@"${ip}"
}

# watch service deployment events
ww () {
    watch -n 1 "aws ecs describe-services --cluster hound_cluster --service ${1} --query 'services[0].events[].message' --output table"
}
