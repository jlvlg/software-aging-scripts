#!/bin/bash

function add_container() {
    pull_time=0
    instantiate_time=0

    if ! podman images | grep -q $imagem; then
        start=$(date +%s%N)
        if ! podman pull $imagem >/dev/null 2>&1; then
            errcount=$((errcount + 1))
            get_date_time
            echo "Falha ao fazer o download da imagem $imagem,$current_date,$current_time" >>$log_erro
            return 1
        fi
        pull_time=$(($(date +%s%N) - start))
    fi

    start=$(date +%s%N)
    if ! container=$(podman run -d $imagem); then
        errcount=$((errcount + 1))
        get_date_time
        echo "Falha ao instanciar a imagem $imagem,$current_date,$current_time" >>$log_erro
        return 1
    fi
    instantiate_time=$(($(date +%s%N) - start))

    return 0
}

function remove_container() {
    stop_time=0
    container_removal_time=0
    image_removal_time=0

    start=$(date +%s%N)
    if ! podman stop $container >/dev/null 2>&1; then
        errcount=$((errcount + 1))
        get_date_time
        echo "Falha ao parar o container,$current_date,$current_time" >>$log_erro
        return 1
    fi
    stop_time=$(($(date +%s%N) - start))

    start=$(date +%s%N)
    if ! podman rm $container >/dev/null 2>&1; then
        errcount=$((errcount + 1))
        get_date_time
        echo "Falha ao remover o container,$current_date,$current_time" >>$log_erro
        return 1
    fi
    container_removal_time=$(($(date +%s%N) - start))

    start=$(date +%s%N)
    if ! podman rmi $imagem >/dev/null 2>&1; then
        errcount=$((errcount + 1))
        get_date_time
        echo "Falha ao remover imagem $imagem,$current_date,$current_time" >>$log_erro
        return 1
    fi
    image_removal_time=$(($(date +%s%N) - start))

    return 0
}
