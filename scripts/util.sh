#!/bin/bash


function check_if_dependencies_are_present() {
    local dependencies="$@"
    local err_counter=0

    for dependency in ${dependencies[@]}; do
      if ! command -v $dependency  &> /dev/null; then
        echo error: $dependency not found
        err_counter=$(( $err_counter + 1 ))
      fi
    done

    if [[ $err_counter -gt 0 ]]; then
      exit 127
    fi
}
