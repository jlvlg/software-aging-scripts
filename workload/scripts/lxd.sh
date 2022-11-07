#!/bin/bash

function add_container() {
  instantiate_time=0

  if ! lxc image list | grep -q $imagem; then
    if ! lxc image copy $imagemsrc local: --alias $imagem >/dev/null 2>/tmp/ERROR; then
      hasError=1
      return 1
    fi
  fi

  start=$(date +%s%N)
  if ! container=$(lxc launch -q $imagem 2>/tmp/ERROR); then
    hasError=1
    return 1
  fi
  instantiate_time=$(($(date +%s%N) - start))
  IFS=' ' read -ra _container <<<"$container"
  container=${_container[3]}

  return 0
}

function remove_container() {
  stop_time=0
  container_removal_time=0

  start=$(date +%s%N)
  if ! lxc stop $container >/dev/null 2>/tmp/ERROR; then
    hasError=1
    return 1
  fi
  stop_time=$(($(date +%s%N) - start))

  start=$(date +%s%N)
  if ! lxc delete $container >/dev/null 2>/tmp/ERROR; then
    hasError=1
    return 1
  fi
  container_removal_time=$(($(date +%s%N) - start))

  return 0
}
