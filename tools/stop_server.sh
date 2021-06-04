#!/usr/bin/env bash
##!/bin/bash

# go to working dir
pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
cd "$pwd" || exit 1

# Load Variables
source ../common/get_instance_id.sh

printf "\nStopping your server ....\n"
docker stop fms-${instance_id} || {
  printf "error while stopping fms container\n"
  exit 1
}

printf "\ndone\n"
exit 0
