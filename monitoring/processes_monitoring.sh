#!/bin/bash

cont=0
export S_TIME_FORMAT=ISO

echo UserPerc SystemPerc GuestPerc WaitPerc CPUPerc Data Hora
echo UserPerc SystemPerc GuestPerc WaitPerc CPUPerc Data Hora > log_pid.txt

while [ $cont -lt 5 ]; do
    processo_id=$(ps aux | grep /usr/bin/bash | tail -2 | head -1 | awk '{print $2}')
    processo_uso=$(pidstat | grep $processo_id | awk '{print $4, $5, $6, $7, $8}')

    data=$(date +'%d-%m-%Y %H:%M:%S')

    cont=$((cont + 1))

    sleep 5

    echo $processo_uso $data
    echo $processo_uso $data >> log_pid.txt
done
