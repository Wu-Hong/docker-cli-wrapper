#!/bin/bash

function init()
{
    echo -e "please excute: \nalias dcw=${SCRIPT_DIR}/ctl.sh"
}

function echo_red()
{
    local content=${*}
    echo -e "\033[31;40m${content}\033[0m"
}

function echo_green()
{
    local content=${*}
    echo -e "\033[32;40m${content}\033[0m"
}

function log()
{
    local content="-> [`date '+%Y-%m-%d %H:%M:%S'`] - ${*}"
    local input=${*}
    case ${input%:*} in
        INFO)
            echo_green ${content}
            ;;
        ERROR)
            echo_red ${content}
            ;;
        *)
            echo_green ${content}
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
    exit 1
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

function get_containers_name() # filename
{
    local filename=$1
    docker-compose -p ${filename} -f ${COMPOSE_FILE_DIR}/${filename}.yaml ps \
        | awk '{print $1}' \
        | grep -v Name \
        | grep -v -e '-----------------------' \
        | grep -v -e '->' # Resolve that the port mapping part is too long and wraps, causing the container name to be wrong.
}

function ps()
{
    for filename in ${arr[@]}
    do
        log "INFO: container info of [${COMPOSE_FILE_DIR}/${filename}.yaml]: "
        get_containers_name ${filename} | xargs -I {} bash -c 'docker ps -a --filter="name={}" --format="table {{.Names}}\t{{.CreatedAt}}\t{{.Status}}\t{{.Ports}}" && docker inspect --format=" ↳ {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" {}'
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

function clean_none_images()
{
    # clean the none images
    docker rmi `docker images | grep -E '<none>.*<none>' | awk '{print $3}'`
}

function clean_images() # images_key_word
{
    local key_word=$1
    docker rmi `docker images | grep "${key_word}" | awk '{print $3}'`
    clean_none_images
}

function clean_volume()
{
    docker volume prune
}
