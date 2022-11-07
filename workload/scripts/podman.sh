#!/bin/bash

function add_container() {
  instantiate_time=0

  if ! podman images | grep -q $imagem; then
    if ! podman pull $imagemsrc >/dev/null 2>/tmp/ERROR; then
      hasError=1
      return 1
    fi
  fi

  start=$(date +%s%N)
  if ! container=$(podman run -d $imagemsrc 2>/tmp/ERROR); then
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
  if ! podman stop $container >/dev/null 2>/tmp/ERROR; then
    hasError=1
    return 1
  fi
  stop_time=$(($(date +%s%N) - start))

  start=$(date +%s%N)
  if ! podman rm $container >/dev/null 2>/tmp/ERROR; then
    hasError=1
    return 1
  fi
  container_removal_time=$(($(date +%s%N) - start))

  return 0
}
