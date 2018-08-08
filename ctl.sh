#!/bin/bash
script_dir=$(cd "$(dirname "$0")";pwd)
compose_file_dir=${script_dir}/compose
ctl_type=$1
files=$2

function init()
{
    echo -e "please excute: \nalias dcw=${script_dir}/ctl.sh"
}

function log()
{
    echo "-> [${USER}][`date '+%Y-%m-%d %H:%M:%S'`] - ${*}"
}

function help()
{
    echo -e "USAGE: $0 [sub-cmd] [compose filename]\n"
    echo "sub-cmd:"
    cat ${script_dir}/ctl.sh | grep -v grep | grep '${ctl_type} = ' | awk '{print $5}' | xargs -I {} echo "    "{}
    echo
    echo "work dir:"
    echo ${script_dir}
    echo
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
        log "INFO: container info of [${compose_file_dir}/${filename}.yaml]: "
        # docker-compose -p ${filename} -f ${compose_file_dir}/${filename}.yaml ps
        docker-compose -p ${filename} -f ${compose_file_dir}/${filename}.yaml ps | awk '{print $1}' | grep -v Name | grep -v -e '-----------------------' | xargs -I {} bash -c 'docker ps --filter="name={}" --format="table {{.Names}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}" --no-trunc && docker inspect --format=" ┖-> IP: {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" {}'
        # docker ps | grep ${filename} | awk '{print $1}' | xargs -I {} docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}, {{json .Name}}, {{json .Id}}' {}
        echo
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
    filepath=${compose_file_dir}/${filename}.yaml
    log "INFO: filepath: ${filepath}"
    cat ${filepath}
}

# jump to the directory where the .env file is located to prevent docker-compose can not find environment variables, this is a pair(pushd & popd)
pushd ${script_dir}
echo "======================================"
if [ $# -lt 1 ] ; then
    help
elif [ ${ctl_type} = "init" ] ; then
    init
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
    param=$2
    arr=""
    if [ ! -n "${param}" ]; then
        # support for all compose file
        for file_path in $(ls ${compose_file_dir}/*.yaml)
        do
            ele=`basename ${file_path} .yaml`
            arr="$arr $ele"
        done
        ps arr
    else
        # support for only one compose file
        if [ ${param} = "-f" ] ; then
            filename=$3
            while true
            do
                docker ps --format="table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}" --no-trunc | grep ${filename}.*_1
                sleep 1
            done
        else
            arr="$arr $param"
            ps arr
        fi
    fi
elif [ ${ctl_type} = "list" ] ; then
    echo "The following are all compose file:"
    for file_path in $(ls ${compose_file_dir}/*.yaml)
    do
        ele=`basename ${file_path} .yaml`
        echo ${ele}
    done
elif [ ${ctl_type} = "cat" ] ; then
    filename=$2
    display_compose_file_by_filename ${filename}
elif [ ${ctl_type} = "in" ] ; then
    container_name=$2
    docker exec -it ${container_name} bash
elif [ ${ctl_type} = "once" ] ; then
    image_name=$2
    docker run --rm -it ${image_name} bash
elif [ ${ctl_type} = "images" ] ; then
    echo "the following images are those exist in the os: "
    docker images --format="table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.ID}}\t{{.CreatedAt}}"
    echo -e "\nthe following images are those we can build: "
    find ${script_dir}/images -name build.sh | xargs -I {} cat {}
elif [ ${ctl_type} = "reboot" ] ; then
    arr=(${files//,/ })
    if [ "${arr}" = "" ]; then
        help
    fi
    down arr
    echo "reboot ..."
    sleep 5
    up arr
elif [ ${ctl_type} = "backup" ] ; then
    docker images --format="{{.Repository}}:{{.Tag}}" > "${script_dir}/reserved_images.ini"
    cat ${script_dir}/reserved_images.ini
elif [ ${ctl_type} = "validate" ] ; then
    filename=$2
    docker-compose -f ${compose_file_dir}/${filename}.yaml config
elif [ ${ctl_type} = "clean-disk" ] ; then
    # this command is suit for mac, so you need judge firstly
    is_mac=`docker info | grep "Operating System" | grep -i mac | wc -l`
    if [ ${is_mac} -ge 1 ] ; then
        # read the reserved_images.ini and clean the docker images
        reserved_images_list=`read_file_line_by_line "${script_dir}/reserved_images.ini" | xargs`
        bash "${script_dir}/utils/clean-docker-for-mac.sh" ${reserved_images_list}
    else
        log "INFO: the os is not mac os, no need to clean disk."
    fi
else
    help
fi
echo "======================================"
popd
