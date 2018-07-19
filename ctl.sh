#!/bin/bash
script_dir=$(cd "$(dirname "$0")";pwd)
compose_file_dir=${script_dir}/compose
ctl_type=$1
files=$2

function log()
{
    echo "-> [${USER}][`date '+%Y-%m-%d %H:%M:%S'`] - ${*}"
}

function help()
{
    log "USAGE: $0 [type: up, down, up-all, down-all] [files: the suffix of compose file must be .yaml]"
}

function up()
{
    for filename in ${arr[@]}
    do
        log "INFO: up, file path: ${compose_file_dir}/${filename}.yaml"
        docker-compose -p ${filename} -f ${compose_file_dir}/${filename}.yaml up -d
    done
}

function down()
{
    for filename in ${arr[@]}
    do
        log "INFO: down, file path: ${compose_file_dir}/${filename}.yaml"
        docker-compose -p ${filename} -f ${compose_file_dir}/${filename}.yaml down --remove-orphans
    done
}

function ps()
{
    for filename in ${arr[@]}
    do
        docker-compose -p ${filename} -f ${compose_file_dir}/${filename}.yaml ps | tail -1 | grep -v -e "----------"
    done
}

if [ $# -lt 1 ] ; then
    help
elif [ ${ctl_type} = "up" ] ; then
    arr=(${files//,/ })
    if [ "${arr}" = "" ]; then
        help
    fi
    up arr
elif [ ${ctl_type} = "down" ] ; then
    arr=(${files//,/ })
    if [ "${arr}" = "" ]; then
        help
    fi
    down arr
elif [ ${ctl_type} = "up-all" ] ; then
    arr=""
    for file_path in $(ls ${compose_file_dir}/*.yaml)
    do
        ele=`basename ${file_path} .yaml`
        arr="$arr $ele"
    done
    up arr
elif [ ${ctl_type} = "down-all" ] ; then
    arr=""
    for file_path in $(ls ${compose_file_dir}/*.yaml)
    do
        ele=`basename ${file_path} .yaml`
        arr="$arr $ele"
    done
    down arr
elif [ ${ctl_type} = "ps" ] ; then
    arr=""
    for file_path in $(ls ${compose_file_dir}/*.yaml)
    do
        ele=`basename ${file_path} .yaml`
        arr="$arr $ele"
    done
    ps arr
elif [ ${ctl_type} = "clean-disk" ] ; then
    settings=~/Library/Group\ Containers/group.com.docker/settings.json
    dimg=$(sed -En 's/.*diskPath.*:.*"(.*)".*/\1/p' < "$settings")
    echo "$dimg"
else
    help
fi
