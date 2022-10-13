#!/bin/bash

imagem="ubuntu"
imagemsrc="docker.io/"
repetitions=0
errcount=0

function is_number() {
    local re='^[0-9]+$'
    if ! [[ $1 =~ $re ]]; then
        return 1
    fi
    return 0
}

while getopts 'r:i:s:' flag; do
    case $flag in
    i) imagem=$OPTARG ;;
    s) imagemsrc=$OPTARG ;;
    r)
        if ! is_number $OPTARG; then
            echo "script usage $(basename $0) -d [-r <integer>] [-i <image name>] [-s <image sorce>]" >&2
            exit 1
        fi

        repetitions=$OPTARG
        ;;
    ?)
        echo "script usage $(basename $0) -d [-r <integer>] [-i <image name>] [-s <image source>]" >&2
        exit 1
        ;;
    esac
done
shift "$((OPTIND - 1))"

function get_date_time() {
    date_time=($(date +"%F %H-%M-%S"))
    current_date=${date_time[0]}
    current_time=${date_time[1]}
}

function progress {
    _progrees=$((($1 * 10000 / $2) / 100))
    _done=$((($_progrees * 6) / 10))
    _left=$((60 - $_done))
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")
    RED='\033[0;31m'
    BLUE='\033[0;34m'
    NC='\033[0m'
    if [ $errcount -gt 0 ]; then
        printf "\r$1 / $2 : ${RED}${_fill// /#}${_empty// /-} ${_progrees}%%${NC} ${errcount} errors"
    else
        printf "\r$1 / $2 : ${BLUE}${_fill// /#}${_empty// /-} ${_progrees}%%${NC}"
    fi
}

for script in "$@"; do
    echo $script | grep -q "rmi"
    rmi=$?

    mkdir -p "logs/$script"
    get_date_time

    log_erro="logs/$script/log-erro-$script-$imagem-${current_date}_$current_time.csv"
    log_arquivo="logs/$script/log-$script-$imagem-${current_date}_$current_time.csv"

    if [ $rmi -eq 0 ]; then
        echo "count,pull_time,instantiate_time,stop_time,container_removal_time,image_removal_time,date,time" >$log_arquivo
    else
        echo "count,instantiate_time,stop_time,container_removal_time,date,time" >$log_arquivo
    fi

    echo "message,reason,date,time" >$log_erro

    count=0

    scriptstart=$(date +%s)
    hasError=0

    if [ $repetitions -eq 0 ]; then
        if [ $rmi -eq 0 ]; then
            repetitions=300
        else
            repetitions=2400
        fi
    fi

    source "./scripts/$script.sh"

    echo "Iniciando o teste $script.sh com $repetitions repetições"
    progress $count $repetitions
    while [ $count -lt $repetitions ]; do

        if add_container; then
            if [ $rmi -eq 0 ]; then
                sleep 80
            else
                sleep 10
            fi
            if remove_container; then
                get_date_time
                if [ $rmi -eq 0 ]; then
                    echo "$count,$pull_time,$instantiate_time,$stop_time,$container_removal_time,$image_removal_time,$current_date,$current_time" >>$log_arquivo
                else
                    echo "$count,$instantiate_time,$stop_time,$container_removal_time,$current_date,$current_time" >>$log_arquivo
                fi
            fi
        fi
        if [ $rmi -eq 0 ]; then
            sleep 160
        else
            sleep 20
        fi
        if [ $hasError -eq 1 ]; then
            get_date_time
            echo "Algum erro aconteceu,$(</tmp/ERROR),$current_date,$current_time" >>$log_erro
            errcount=$((errcount + 1))
            hasError=0
        else
          count=$((count + 1))
        fi
        progress $count $repetitions
    done
    printf "\n"
    echo "Teste finalizado com $errcount erros em $(($(date +%s) - scriptstart)) segundos"
    echo ""
    errcount=0
done

echo "Todos os testes finalizados"
