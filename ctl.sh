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

function read_file_line_by_line()
{
    filepath=$1
    for line in `cat ${filepath}`
    do
        echo ${line}
    done
}

function display_compose_file_by_filename()
{
    filename=$1
    cat ${compose_file_dir}/${filename}.yaml
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
elif [ ${ctl_type} = "list" ] ; then
    log "INFO: The following are all compose file"
    for file_path in $(ls ${compose_file_dir}/*.yaml)
    do
        ele=`basename ${file_path} .yaml`
        echo ${ele}
    done
elif [ ${ctl_type} = "describe" ] ; then
    filename=$2
    display_compose_file_by_filename ${filename}
elif [ ${ctl_type} = "backup-images" ] ; then
    docker images --format="{{.Repository}}:{{.Tag}}" > "${script_dir}/reserved_images.ini"
elif [ ${ctl_type} = "clean-disk" ] ; then
    # this command is suit for mac, so you need judge firstly
    is_mac=`docker info | grep "Operating System" | grep -i mac | wc -l`
    if [ ${is_mac} -ge 1 ] ; then
        # read the reserved_images.ini and clean the docker images
        reserved_images_list=`read_file_line_by_line "${script_dir}/reserved_images.ini" | xargs`
        echo         "\"${script_dir}/utils/clean-docker-for-mac.sh\" ${reserved_images_list}"
    else
        log "INFO: the os is not mac os, no need to clean disk."
    fi
else
    help
fi
