#!/bin/bash

function add_container() {
  instantiate_time=0

  if ! docker images | grep -q $imagem; then
    if ! docker pull $imagemsrc >/dev/null 2>/tmp/ERROR; then
      hasError=1
      return 1
    fi
  fi

  start=$(date +%s%N)
  if ! container=$(docker run -d $imagemsrc 2>/tmp/ERROR); then
    hasError=1
    return 1
  fi
  instantiate_time=$(($(date +%s%N) - start))

  return 0
}

function remove_container() {
  stop_time=0
  container_removal_time=0

  start=$(date +%s%N)
  if ! docker stop $container >/dev/null 2>/tmp/ERROR; then
    hasError=1
    return 1
  fi
  stop_time=$(($(date +%s%N) - start))

  start=$(date +%s%N)
  if ! docker rm $container >/dev/null 2>/tmp/ERROR; then
    hasError=1
    return 1
  fi
  container_removal_time=$(($(date +%s%N) - start))

  return 0
}
