#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")";pwd)
SHELL_DIR=${SCRIPT_DIR}/src/main/shell
PYTHON_DIR=${SCRIPT_DIR}/src/main/python
ENV_FILE=${SCRIPT_DIR}/.env
COMPOSE_FILE_DIR=${SCRIPT_DIR}/compose
BACKUP_IMAGES_CONFIG_FILE=${SCRIPT_DIR}/backup_images.ini
