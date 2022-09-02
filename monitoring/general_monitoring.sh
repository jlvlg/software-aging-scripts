#!/bin/bash

echo Cont MemUsed MemFree MemShared MemBuffer SwapUsed SwapFree DiskUsed DiskFree DiskPerc CpuNice CpuSys CpuIO CpuSoft CpuIdle NetRecBytes NetRecPack NetTransBytes NetTransPack Data Hora
echo Cont MemUsed MemFree MemShared MemBuffer SwapUsed SwapFree DiskUsed DiskFree DiskPerc CpuNice CpuSys CpuIO CpuSoft CpuIdle NetRecBytes NetRecPack NetTransBytes NetTransPack Data Hora > log.txt

cont=0

# For some reason in kubuntu mpstat displayed the time in 24 hours format and it messed up the data collection.
# Setting up this environment variable sets mpstat to ISO format. This should make it compatible with other systems.
export S_TIME_FORMAT=ISO

while [ $cont -lt 5 ]; do
    mem=$(free | grep Mem | awk '{print $3, $4, $5, $6}')
    swap=$(free | grep Swap | awk '{print $3, $4}')
    disco=$(df | grep nvme0n1p6 | awk '{print $3, $4, $5}' | sed 's/%//g')
    rede1=($(cat /proc/net/dev | grep wlp2s0 | awk '{print $2, $3, $10, $11}'))
    cpu=$(mpstat 1 1 | grep all | awk '{print $4, $5, $6, $8, $12}')

    data=$(date +'%d-%m-%Y %H:%M:%S')

    cont=$((cont + 1))

    sleep 4

    rede2=($(cat /proc/net/dev | grep wlp2s0 | awk '{print $2, $3, $10, $11}'))

    echo $cont $mem $swap $disco $cpu $((rede2[0] - rede1[0])) $((rede2[1] - rede1[1])) $((rede2[2] - rede1[2])) $((rede2[3] - rede1[3])) $data
    echo $cont $mem $swap $disco $cpu $((rede2[0] - rede1[0])) $((rede2[1] - rede1[1])) $((rede2[2] - rede1[2])) $((rede2[3] - rede1[3])) $data >> log.txt
done
