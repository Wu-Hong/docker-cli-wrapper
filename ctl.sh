#!/bin/bash

# jump to the directory where the .env file is located to prevent docker-compose can not find environment variables
cd $(dirname $0)/
source ./set-vars.sh
source ./utilities.sh

CTL_TYPE=$1
echo "======================================"
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
        # support for all compose file
        for file_path in $(ls ${COMPOSE_FILE_DIR}/*.yaml)
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
elif [ ${CTL_TYPE} = "list" ] ; then
    echo "The following are all compose file:"
    for file_path in $(ls ${COMPOSE_FILE_DIR}/*.yaml)
    do
        ele=`basename ${file_path} .yaml`
        echo ${ele}
    done
elif [ ${CTL_TYPE} = "cat" ] ; then
    filename=$2
    display_compose_file_by_filename ${filename}
elif [ ${CTL_TYPE} = "in" ] ; then
    filename=$2
    container_name=`get_containers_name ${filename}`
    if [ -z "${container_name}" ]; then
        log "ERROR: The container corresponding to the docker-compose(${filename}) is not running"
        exit
    fi
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
elif [ ${CTL_TYPE} = "logs" ] ; then
    filename=$2
    container_name=`get_containers_name ${filename}`
    if [ -z "${container_name}" ]; then
        log "ERROR: The container corresponding to the docker-compose(${filename}) is not running"
        exit
    fi
    docker logs ${container_name}
elif [ ${CTL_TYPE} = "images" ] ; then
    log "INFO: All images in the os: "
    docker images --format="table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.ID}}\t{{.CreatedAt}}"
    echo
    log "INFO: The images belong to dcw (Dockerfile path: ${SCRIPT_DIR}/images): "
    find ${SCRIPT_DIR}/images -name build.sh | xargs -I {} bash -c "cat {} | sed -e 's/.*\(-t.* \).*/\1/g' -e 's/-t //g'"
elif [ ${CTL_TYPE} = "reboot" ] ; then
    files=$2
    arr=(${files//,/ })
    if [ "${arr}" = "" ]; then
        help
    fi
    down arr
    echo "reboot ..."
    sleep 5
    up arr
elif [ ${CTL_TYPE} = "backup" ] ; then
    docker images --format="{{.Repository}}:{{.Tag}}" > "${BACKUP_IMAGES_CONFIG_FILE}"
    cat ${BACKUP_IMAGES_CONFIG_FILE}
elif [ ${CTL_TYPE} = "validate" ] ; then
    filename=$2
    docker-compose -f ${COMPOSE_FILE_DIR}/${filename}.yaml config
elif [ ${CTL_TYPE} = "clean-disk" ] ; then
    # this command is suit for mac, so you need judge firstly
    is_mac=`docker info | grep "Operating System" | grep -i mac | wc -l`
    if [ ${is_mac} -ge 1 ] ; then
        # read the backup_images.ini and clean the docker images
        backup_images_list=`read_file_line_by_line "${BACKUP_IMAGES_CONFIG_FILE}" | xargs`
        bash "${SCRIPT_DIR}/third-party/clean-docker-for-mac.sh" ${backup_images_list}
    else
        log "INFO: the os is not mac os, no need to clean disk."
    fi
elif [ ${CTL_TYPE} = "clean-images" ] ; then
    key_word=$2
    if [ "${key_word}" = "" ]; then
        help
    fi
    clean_images ${key_word}
elif [ ${CTL_TYPE} = "svc" ] ; then
    svc=$2
    subcmd=$3
    if [ ${svc} = "ss" ] ; then
        if [ ${subcmd} = "qr" ] ; then
            protocol="ss://"
            ip=`ipconfig getifaddr en0`
            encryptMethod="aes-256-cfb"
            password="nBhc3N3b3JkQGhvc3R"
            port=`cat ${ENV_FILE} | grep SS_PORT | sed 's/SS_PORT=//g'`
            echo ip:${ip} port:${port} password:${password} encrypt:${encryptMethod}
            # echo -n "ss://"`echo -n aes-256-cfb:nBhc3N3b3JkQGhvc3R@${ip}:30019 | base64` | qr
            echo -n ${protocol}`echo -n ${encryptMethod}:${password}@${ip}:${port} | base64` | qr
        fi
    elif [ ${svc} = "es" ] ; then
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
echo "======================================"
