#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")";pwd)
ENV_FILE=${SCRIPT_DIR}/.env
COMPOSE_FILE_DIR=${SCRIPT_DIR}/compose
BACKUP_IMAGES_CONFIG_FILE=${SCRIPT_DIR}/backup_images.ini
CTL_TYPE=$1
FILES=$2

function init()
{
    echo -e "please excute: \nalias dcw=${SCRIPT_DIR}/ctl.sh"
}

function log()
{
    local content="-> [`date '+%Y-%m-%d %H:%M:%S'`] - ${*}"
    local input=${*}
    case ${input%:*} in
        INFO)
            echo -e "\033[32;40m${content}\033[0m"
            ;;
        ERROR)
            echo -e "\033[31;40m${content}\033[0m"
            ;;
        *)
            echo -e "\033[32;40m${content}\033[0m"
    esac
}


function help()
{
    echo -e "USAGE: $0 [sub-cmd] [compose filename]\n"
    echo "sub-cmd:"
    cat ${SCRIPT_DIR}/ctl.sh | grep -v grep | grep '${CTL_TYPE} = ' | awk '{print $5}' | xargs -I {} echo "    "{}
    echo
    echo "work dir:"
    echo ${SCRIPT_DIR}
    echo
}

function up()
{
    for filename in ${arr[@]}
    do
        log "INFO: up, file path: ${COMPOSE_FILE_DIR}/${filename}.yaml"
        docker-compose -p ${filename} -f ${COMPOSE_FILE_DIR}/${filename}.yaml up -d
    done
}

function down()
{
    for filename in ${arr[@]}
    do
        log "INFO: down, file path: ${COMPOSE_FILE_DIR}/${filename}.yaml"
        docker-compose -p ${filename} -f ${COMPOSE_FILE_DIR}/${filename}.yaml down --remove-orphans
    done
}

function ps()
{
    for filename in ${arr[@]}
    do
        log "INFO: container info of [${COMPOSE_FILE_DIR}/${filename}.yaml]: "
        # docker-compose -p ${filename} -f ${COMPOSE_FILE_DIR}/${filename}.yaml ps
        docker-compose -p ${filename} -f ${COMPOSE_FILE_DIR}/${filename}.yaml ps | awk '{print $1}' | grep -v Name | grep -v -e '-----------------------' | xargs -I {} bash -c 'docker ps --filter="name={}" --format="table {{.Names}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}" --no-trunc && docker inspect --format=" ┖-> IP: {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" {}'
        # docker ps | grep ${filename} | awk '{print $1}' | xargs -I {} docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}, {{json .Name}}, {{json .Id}}' {}
        echo
    done
}

function read_file_line_by_line()
{
    local filepath=$1
    for line in `cat ${filepath}`
    do
        echo ${line}
    done
}

function display_compose_file_by_filename()
{
    local filename=$1
    local filepath=${COMPOSE_FILE_DIR}/${filename}.yaml
    log "INFO: filepath: ${filepath}"
    cat ${filepath}
}

# jump to the directory where the .env file is located to prevent docker-compose can not find environment variables, this is a pair(pushd & popd)
pushd ${SCRIPT_DIR}
echo "======================================"
if [ $# -lt 1 ] ; then
    help
elif [ ${CTL_TYPE} = "init" ] ; then
    init
elif [ ${CTL_TYPE} = "up" ] ; then
    arr=(${FILES//,/ })
    if [ "${arr}" = "" ]; then
        help
    fi
    up arr
elif [ ${CTL_TYPE} = "down" ] ; then
    arr=(${FILES//,/ })
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
    container_name=$2
    docker exec -it -e LINES=$(tput lines) -e COLUMNS=$(tput cols) ${container_name} bash
    if [ $? = 126 ] ;then
        docker exec -it -e LINES=$(tput lines) -e COLUMNS=$(tput cols) ${container_name} sh
    fi
elif [ ${CTL_TYPE} = "once" ] ; then
    image_name=$2
    docker run --rm -it ${image_name} bash
elif [ ${CTL_TYPE} = "images" ] ; then
    echo "the following images are those exist in the os: "
    docker images --format="table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.ID}}\t{{.CreatedAt}}"
    echo -e "\nthe following images are those we can build (path: ${SCRIPT_DIR}/images): "
    find ${SCRIPT_DIR}/images -name build.sh | xargs -I {} bash -c "cat {} | sed -e 's/.*\(-t.* \).*/\1/g' -e 's/-t //g'"
elif [ ${CTL_TYPE} = "reboot" ] ; then
    arr=(${FILES//,/ })
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
        # clean the none images
        docker rmi `docker images | grep -E '<none>.*<none>' | awk '{print $3}'`
        # read the backup_images.ini and clean the docker images
        backup_images_list=`read_file_line_by_line "${BACKUP_IMAGES_CONFIG_FILE}" | xargs`
        bash "${SCRIPT_DIR}/utils/clean-docker-for-mac.sh" ${backup_images_list}
    else
        log "INFO: the os is not mac os, no need to clean disk."
    fi
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
    fi
else
    help
fi
echo "======================================"
popd
