#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")";pwd)
ENV_FILE=${SCRIPT_DIR}/.env
COMPOSE_FILE_DIR=${SCRIPT_DIR}/compose
BACKUP_IMAGES_CONFIG_FILE=${SCRIPT_DIR}/backup_images.ini
