#!/bin/bash

function add_container() {
    instantiate_time=0

    if ! docker images | grep -q $imagem; then
        if ! docker pull $imagem >/dev/null 2>&1; then
            errcount=$((errcount + 1))
            get_date_time
            echo "Falha ao fazer o download da imagem $imagem,$current_date,$current_time" >>$log_erro
            return 1
        fi
    fi

    start=$(date +%s%N)
    if ! container=$(docker run -d $imagem); then
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

    start=$(date +%s%N)
    if ! docker stop $container >/dev/null 2>&1; then
        errcount=$((errcount + 1))
        get_date_time
        echo "Falha ao parar o container,$current_date,$current_time" >>$log_erro
        return 1
    fi
    stop_time=$(($(date +%s%N) - start))

    start=$(date +%s%N)
    if ! docker rm $container >/dev/null 2>&1; then
        errcount=$((errcount + 1))
        get_date_time
        echo "Falha ao remover o container,$current_date,$current_time" >>$log_erro
        return 1
    fi
    container_removal_time=$(($(date +%s%N) - start))

    return 0
}
