#!/bin/bash


function check_if_dependencies_are_present() {
    local dependencies="$@"
    local err_counter=0

    for dependency in ${dependencies[@]}; do
      if ! command -v $dependency &> /dev/null; then
        echo error: $dependency not found
        err_counter=$(( $err_counter + 1 ))
      fi
    done

    if [[ $err_counter -gt 0 ]]; then
      exit 127
    fi
}


function create_required_directories() {
    for dir in $@; do
      mkdir -p "${PREFIX:-.}/${dir}"
    done
}


function application_delimiter() {
    local char="${1:--}"

    echo "# $(printf "%0.s${char}" {1..76}) #"
}


display_center(){
    # courtesy https://superuser.com/questions/823883/how-to-justify-and-center-text-in-bash
    columns=80
    while IFS= read -r line; do
        printf "%*s\n" $(( (${#line} + columns) / 2)) "$line"
    done < "$1"
}
