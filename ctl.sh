#!/bin/bash

# jump to the directory where the .env file is located to prevent docker-compose can not find environment variables
cd $(dirname $0)/
source ./set-vars.sh
source ${SHELL_DIR}/utilities.sh

CTL_TYPE=$1
if [ $# -lt 1 ] ; then
    help
elif [ ${CTL_TYPE} = "init" ] ; then
    init
elif [ ${CTL_TYPE} = "up" ] ; then
    files=$2
    arr=(${files//,/ })
    if [ "${arr}" = "" ]; then
        help
    fi
    up arr
elif [ ${CTL_TYPE} = "down" ] ; then
    files=$2
    arr=(${files//,/ })
    if [ "${arr}" = "" ]; then
        help
    fi
    down arr
elif [ ${CTL_TYPE} = "up-all" ] ; then
    arr=""
    for file_path in $(ls ${COMPOSE_FILE_DIR}/*.yaml)
    do
        ele=`basename ${file_path} .yaml`
        arr="$arr $ele"
    done
    up arr
elif [ ${CTL_TYPE} = "down-all" ] ; then
    arr=""
    for file_path in $(ls ${COMPOSE_FILE_DIR}/*.yaml)
    do
        ele=`basename ${file_path} .yaml`
        arr="$arr $ele"
    done
    down arr
elif [ ${CTL_TYPE} = "ps" ] ; then
    param=$2
    arr=""
    if [ ! -n "${param}" ]; then
        docker ps -a --format="table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" --no-trunc
    elif [ ${param} = "-a" ] ; then
        # ps all compose file
        for file_path in $(ls ${COMPOSE_FILE_DIR}/*.yaml)
        do
            ele=`basename ${file_path} .yaml`
            arr="$arr $ele"
        done
        ps arr
    elif [ ${param} = "-c" ] ; then
        filename=$3
        arr="$arr ${filename}"
        ps arr
    elif [ ${param} = "-f" ] ; then
        # support for only one compose file
        filename=$3
        containers=`get_containers_name ${filename}`
        while true
        do
            for container in ${containers}
            do
                docker ps -a --filter="name=${container}" --format="table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" --no-trunc
            done
            echo_green "---"
            sleep 2
        done
    fi
elif [ ${CTL_TYPE} = "list" ] ; then
    echo "The following are all compose file:"
    for file_path in $(ls ${COMPOSE_FILE_DIR}/*.yaml)
    do
        ele=`basename ${file_path} .yaml`
        echo ${ele}
    done
elif [ ${CTL_TYPE} = "search" ] ; then
    keyword=$2
    arr=""
    for file_path in $(ls ${COMPOSE_FILE_DIR}/*.yaml)
    do
        ele=`basename ${file_path} .yaml`
        arr="$arr $ele"
    done
    python ${PYTHON_DIR}/fuzzyfinder.py "\"${arr}\"" "\"${keyword}\""
elif [ ${CTL_TYPE} = "cat" ] ; then
    filename=$2
    display_compose_file_by_filename ${filename}
elif [ ${CTL_TYPE} = "in" ] ; then
    container_name=$2
    log "INFO: Checking which shell the container supports"
    arr="zsh bash sh"
    final_termial=""
    for terminal in ${arr[@]}
    do
        docker exec ${container_name} ls -l /bin/${terminal}
        if [ $? -eq 0 ] ; then
            final_termial=${terminal}
            break
        else
            continue
        fi
    done
    log "INFO: The shell supported is ${terminal}"
    docker exec -it -e LINES=$(tput lines) -e COLUMNS=$(tput cols) ${container_name} ${terminal}
elif [ ${CTL_TYPE} = "images" ] ; then
    echo_green "The images were built by dcw (Dockerfile path: ${SCRIPT_DIR}/images): "
    find ${SCRIPT_DIR}/images -name build.sh | xargs -I {} bash -c "cat {} | sed -e 's/.*\(-t.* \).*/\1/g' -e 's/-t //g'"
elif [ ${CTL_TYPE} = "reboot" ] ; then
    files=$2
    arr=(${files//,/ })
    if [ "${arr}" = "" ]; then
        help
    fi
    down arr
    sleep_time=5
    log "INFO: Start to up after ${sleep_time} seconds..."
    sleep ${sleep_time}
    up arr
elif [ ${CTL_TYPE} = "backup" ] ; then
    docker images --format="{{.Repository}}:{{.Tag}}" > "${BACKUP_IMAGES_CONFIG_FILE}"
    cat ${BACKUP_IMAGES_CONFIG_FILE}
elif [ ${CTL_TYPE} = "validate" ] ; then
    param=$2
    if [ ! -n "${param}" ]; then
        # validate for all compose file, if one is failed then stop
        for file_path in $(ls ${COMPOSE_FILE_DIR}/*.yaml)
        do
            filename=`basename ${file_path} .yaml`
            echo_green "--- ${COMPOSE_FILE_DIR}/${filename}.yaml"
            docker-compose -f ${COMPOSE_FILE_DIR}/${filename}.yaml config
            if [ $? -ne 0 ] ; then
                log "ERROR: The docker-compose file ${COMPOSE_FILE_DIR}/${filename}.yaml is written incorrectly!"
                exit 1
            fi
        done
    else
        filename=${param}
        docker-compose -f ${COMPOSE_FILE_DIR}/${filename}.yaml config
    fi
elif [ ${CTL_TYPE} = "clean" ] ; then
    param=$2
    if [ ${param} = "all" ] ; then
        clean_all
    elif [ ${param} = "exited" ] ; then
        clean_exited_containers
    else
        help
    fi
elif [ ${CTL_TYPE} = "stash" ] ; then
    param=$2
    if [ ${param} = "save" ] ; then
        # read the backup_images.ini and clean the docker images
        backup_images_list=`read_file_line_by_line "${BACKUP_IMAGES_CONFIG_FILE}" | xargs`
        echo "=> Saving the specified images"
        for image in ${backup_images_list}; do
            echo "==> Saving ${image}"
            tar=$(echo -n ${image} | base64)
            docker save -o ${BACKUP_IMAGES_DIR}/${tar}.tar ${image}
            echo "==> Done."
        done
    elif [ ${param} = "pop" ] ; then
        echo "=> Loading saved images"
        for image in ${backup_images_list}; do
            echo "==> Loading ${image}"
            tar=$(echo -n ${image} | base64)
            docker load -q -i ${BACKUP_IMAGES_DIR}/${tar}.tar || exit 1
            echo "==> Done."
        done
    else
        help
    fi
elif [ ${CTL_TYPE} = "svc" ] ; then
    svc=$2
    subcmd=$3
    if [ ${svc} = "es" ] ; then
        if [ ${subcmd} = "qr" ] ; then
            protocol="http://"
            ip=`ipconfig getifaddr en0`
            port=`cat ${ENV_FILE} | grep EMBYSERVER_PORT1 | sed 's/EMBYSERVER_PORT1=//g'`
            echo ${protocol}${ip}:${port}
            echo -n ${protocol}${ip}:${port} | qr
        fi
    fi
else
    help
fi
