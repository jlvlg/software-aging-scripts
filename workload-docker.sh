#!/bin/bash

imagem="swift"
remove_image="false"
repetitions=0
array_containers=()

function is_number() {
    local re='^[0-9]+$'
    if ! [[ $1 =~ $re ]] ; then
        return 1
    fi
    return 0
}

while getopts 'ri:n:' flag; do
    case $flag in
        n) imagem=$OPTARG ;;
        i) 
            if ! is_number $OPTARG ; then 
                echo "script usage $(basename $0) [-r] [-i <integer>] [-n <image name>]" >&2
                exit 1
            fi

            repetitions=$OPTARG 
            ;;
        r) remove_image="true" ;;
        ?) 
            echo "script usage $(basename $0) [-r] [-i <integer>] [-n <image name>]" >&2
            exit 1
            ;;
    esac
done

function get_date_time() {
    date_time=($(date +"%F %T"))
    current_date=${date_time[0]}
    current_time=${date_time[1]}
}

function add_container() {
    if ! docker images | grep -q $imagem; then
        start=$(date +%s%N)
        if ! docker pull $imagem >/dev/null 2>&1; then
            get_date_time
            echo "Falha ao fazer o download da imagem $imagem,$current_date,$current_time" | tee -a $log_erro
            return 1
        fi
        pull_time=$(($(date +%s%N) - start))
    fi

    start=$(date +%s%N)
    if ! container=$(docker run -d $imagem); then
        get_date_time
        echo "Falha ao instanciar a imagem $imagem,$current_date,$current_time" | tee -a $log_erro
        return 1
    fi
    instantiate_time=$(($(date +%s%N) - start))

    array_containers+=($container)
    return 0
}

function remove_container() {
    for t in ${array_containers[@]}; do
        start=$(date +%s%N)
        if ! docker stop $t >/dev/null 2>&1; then
            get_date_time
            echo "Falha ao parar o container,$current_date,$current_time" | tee -a $log_erro
			return 1
		fi
        stop_time=$(($(date +%s%N) - start))

        start=$(date +%s%N)
        if ! docker rm $t >/dev/null 2>&1; then
            get_date_time
            echo "Falha ao remover o container,$current_date,$current_time" | tee -a $log_erro
			return 1
		fi
        container_removal_time=$(($(date +%s%N) - start))

        if [ $remove_image = "true" ]; then
            start=$(date +%s%N)
            if ! docker rmi $imagem >/dev/null 2>&1; then
                get_date_time
                echo "Falha ao remover imagem $imagem,$current_date,$current_time" | tee -a $log_erro
                return 1
            fi
            image_removal_time=$(($(date +%s%N) - start))
        fi
    done
    array_containers=()
    return 0
}

mkdir -p logs
get_date_time

log_erro="logs/log-erro-docker-$imagem-$current_date-$current_time.csv"
message="instantiate_time,stop_time,container_removal_time"

if [ $remove_image = "true" ]; then
    log_arquivo="logs/log-docker-rmi-$imagem-$current_date-$current_time.csv"
    message="pull_time,$message,image_removal_time"
else
    log_arquivo="logs/log-$imagem-$current_date-$current_time.csv"
fi

echo "count,$message,date,time" | tee $log_arquivo
echo "reason,date,time" > $log_erro

count=0

if [ $repetitions -eq 0 ]; then
    if [ $remove_image = "true" ]; then
        repetitions=300
    else
        repetitions=2400
    fi
fi

while [ $count -lt $repetitions ]; do
    count=$((count+1))
    if add_container; then
        if [ $remove_image = "true" ]; then
            sleep 80
        else
            sleep 10
        fi
        if remove_container; then
            get_date_time
            message="$instantiate_time,$stop_time,$container_removal_time"
            if [ $remove_image = "true" ]; then
                message="$pull_time,$message,$image_removal_time"
            fi
            echo "$count,$message,$current_date,$current_time" | tee -a $log_arquivo
        fi
    fi
    if [ $remove_image =  "true" ]; then
        sleep 160
    else
        sleep 20
    fi
done
