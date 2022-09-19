#!/bin/bash

function add_container() {
    pull_time=0
    instantiate_time=0

    if ! lxc image list | grep -q $imagem; then
        start=$(date +%s%N)
        if ! lxc image copy $imagemsrc:$imagem local: --alias $imagem >/dev/null 2>/tmp/ERROR; then
            errcount=$((errcount + 1))
            get_date_time
            echo "Falha ao fazer o download da imagem $imagem,$(</tmp/ERROR),$current_date,$current_time" >>$log_erro
            return 1
        fi
        pull_time=$(($(date +%s%N) - start))
    fi

    start=$(date +%s%N)
    if ! container=$(lxc launch -q $imagem 2>/tmp/ERROR); then
        errcount=$((errcount + 1))
        get_date_time
        echo "Falha ao instanciar a imagem $imagem,$(</tmp/ERROR),$current_date,$current_time" >>$log_erro
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
    image_removal_time=0

    start=$(date +%s%N)
    if ! lxc stop $container >/dev/null 2>/tmp/ERROR; then
        errcount=$((errcount + 1))
        get_date_time
        echo "Falha ao parar o container,$(</tmp/ERROR),$current_date,$current_time" >>$log_erro
        return 1
    fi
    stop_time=$(($(date +%s%N) - start))

    start=$(date +%s%N)
    if ! lxc delete $container >/dev/null 2>/tmp/ERROR; then
        errcount=$((errcount + 1))
        get_date_time
        echo "Falha ao remover o container,$(</tmp/ERROR),$current_date,$current_time" >>$log_erro
        return 1
    fi
    container_removal_time=$(($(date +%s%N) - start))

    start=$(date +%s%N)
    if ! lxc image delete $imagem >/dev/null 2>/tmp/ERROR; then
        errcount=$((errcount + 1))
        get_date_time
        echo "Falha ao remover imagem $imagem,$(</tmp/ERROR),$current_date,$current_time" >>$log_erro
        return 1
    fi
    image_removal_time=$(($(date +%s%N) - start))

    return 0
}
