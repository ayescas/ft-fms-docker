#!/usr/bin/env bash
##!/bin/bash

# go to working dir
pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
cd "$pwd" || exit 1
parent_dir=$(dirname "${pwd}")

# parse config
function get_setting() {
  grep -Ev '^\s*$|^\s*\#' "$2" | grep -E "\s*$1\s*=" | sed 's/.*=//; s/^ //g'
}

function check_setting() {
  if [[ $(wc -l <<<"$1") -gt 1 ]]; then
    echo "multiple values found, 1 expected" >&2
    exit 1
  fi
}

# get settings from config
project_id=$(get_setting "ID" ../.env)
check_setting "$project_id"
[ -z "$project_id" ] && { printf "error: project ID empty!\nrun setup_project to set an ID.\n"; exit 1; }

## stop that nasty service
#printf "\nNow stopping httpd service ....\n"
#docker exec fms-${project_id} touch "/opt/FileMaker/FileMaker Server/HTTPServer/stop" || {
#  printf "error while stopping httpd service\n"
#  exit 1
#}

printf "\nDone. Now stopping your server ....\n"
docker stop fms-${project_id} || {
  printf "error while stopping fms container\n"
  exit 1
}

printf "\ndone\n"
exit 0
