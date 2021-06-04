#!/usr/bin/env bash
##!/bin/bash

# go to working dir
pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
cd "$pwd" || exit 1
parent_dir=$(dirname "${pwd}")

# md5 command
md5-sum() {
  if command -v md5sum >/dev/null 2>&1; then
    md5sum "$@"
  elif command -v md5 >/dev/null 2>&1; then
    md5 "$@"
  else
    printf "Error: no md5 command found\n"
    exit 1
  fi
}

# Load Variables
source ../common/settings.sh
source ../common/paths.sh

# check directories
printf "\n\e[36mChecking directories on host...\e[39m\n"
no_dirs=0
for ((i = 1; i < "${#paths[@]}"; i += 2)); do
  if [[ ! -d "$parent_dir/fms-data${paths[$i]}" ]]; then
    no_dirs=1
    printf "\e[31mError:\e[39m missing directory %s/fms-data%s\n" "$parent_dir" "${paths[$i]}"
  fi
done

[ $no_dirs -eq 1 ] && exit 1

# todo reuse or remove old stuff
[ -n "$project_id" ] && {
  printf "Found project name: %s\n" "${project_id}"
  old_volumes=$(docker volume ls -q --filter="name=${project_id}$")
  if [ -n "$old_volumes" ]; then
    ./remove_project.sh || exit 1
  fi
}

# set project id
#while [ $is_valid -eq 0 ] && [ $old_container -eq 1 ]; do
printf "Please enter a project name or leave empty for an automatic ID to be assigned to this instance: "
read -r user_input

case $user_input in
"")
  # todo while valid (check if exists)
  project_id=$(uuidgen | md5-sum "$@" | cut -c-12) # | cut -c-12
  echo "id: " "$project_id"
  ;;
(*[!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_.-]*)
  echo >&2 "That ID is not allowed. Please use only characters [a-zA-Z0-9_.-]"
  exit 1
  ;;
*)
  project_id=$user_input
  # todo while valid (check if exists)
  ;;
esac

# write to .env
echo "ID=${project_id}" >../.env

# Reset variables
source ../common/settings.sh
source ../common/paths.sh

# create bind volumes
printf "\n\e[36mcreating volumes...\e[39m\n"
for ((i = 0; i < "${#paths[@]}"; i += 2)); do
  docker volume create --driver local -o o=bind -o type=none -o device="$parent_dir/fms-data${paths[$i + 1]}" "${paths[$i]}" || {
    printf "error while creating docker volumes"
    exit 1
  }
done

printf "\ndone\n"
exit 0
