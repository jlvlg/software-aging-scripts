#!/bin/bash

array_containers=()
array_images=()

imagem="swift"

function get_date_time() {
    date_time=($(date +"%F %T"))
    current_date=${date_time[0]}
    current_time=${date_time[1]}
}

function add_container() {
    if ! docker images | grep -q $imagem
    then
        start=$(date +%s%N)
        docker pull $imagem
        end=$(date +%s%N)
        pull_time=$((end-start))

        start=$(date +%s%N)
        container=$(docker run -d $imagem)
        end=$(date +%s%N)
        instantiate_time=$((end-start))
    fi
        array_containers+=($container)
}

function remove_container() {
    for t in ${array_containers[@]}
    do
        start=$(date +%s%N)
        if ! docker stop $t; then
			return $?
		fi
        end=$(date +%s%N)
        stop_time=$((end-start))

        start=$(date +%s%N)
        if ! docker rm $t; then
			return $?
		fi
        end=$(date +%s%N)
        container_removal_time=$((end-start))

        start=$(date +%s%N)
        if ! docker rmi $imagem; then
			return $?
		fi
        end=$(date +%s%N)
        image_removal_time=$((end-start))
    done
    array_containers=()
    return 0
}

get_date_time
log_arquivo="log-w-rmi-$imagem-$current_date-$current_time.csv"
echo "pull_time;instantiate_time;stop_time;container_removal_time;image_removal_time;date;time" > $log_arquivo
count=0
while [ $count -lt 10 ]
do
    add_container
    count=$((count+1))
    sleep 10
    if ! remove_container; then
        get_date_time
        echo "Falha ao remover o container;$current_date;$current_time" >> log_erro.csv
        break
    fi
    get_date_time
    echo "$pull_time;$instantiate_time;$stop_time;$container_removal_time;$image_removal_time;$current_date;$current_time" >> $log_arquivo
    sleep 20
done
