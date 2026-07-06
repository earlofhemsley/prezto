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

# trigger an ec2 rotation
asg_refresh() {
  if [[ -z "${AWS_ACCESS_KEY_ID}" || -z "${AWS_SECRET_ACCESS_KEY}" || -z "${AWS_SESSION_TOKEN}" ]]; then
    echo "must assume the aws role first. source assumeRole"
    return 1
  fi

  local prefs_json="{ \"AutoScalingGroupName\": \"crzr_asg\", \
    \"Preferences\": {
      \"MinHealthyPercentage\": 100, \
      \"InstanceWarmup\": 0, \
      \"SkipMatching\": true, \
      \"AutoRollback\": false, \
      \"ScaleInProtectedInstances\": \"Ignore\", \
      \"StandbyInstances\": \"Ignore\", \
      \"MaxHealthyPercentage\": 110 } \
    }"

  local cmd="aws autoscaling start-instance-refresh --cli-input-json '${prefs_json}'"
  resp=$(eval "${cmd}")
  exit_code=$?

  if [[ "$exit_code" != "0" ]]; then
    echo "failed to start instance refresh."
    return 1
  fi

  local id=$(echo "${resp}" | jq '.InstanceRefreshId')

  watch -n 10 "aws autoscaling describe-instance-refreshes \
    --auto-scaling-group-name crzr_asg \
    --query \"InstanceRefreshes[?InstanceRefreshId=='${id}'].{status: Status, PctComplete: PercentageComplete}\" \
    --output table"
}
