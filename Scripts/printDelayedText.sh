#!/bin/sh

printDelayedText(){

  local delay="0.035"

  for ((i = 0; i < ${#1}; i++)); do
    printf "%c" "${1:$i:1}"
    sleep "$delay"
  done
  echo


}


