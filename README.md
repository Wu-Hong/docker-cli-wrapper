# dcw

---

## summary

A docker-compose CLI wrapper for the people who try to use docker-compose in mac.

---

## sub command

#### init

show the alias of using dcw.

eg.

```shell
$ dcw init
~/Workspace/docker-cli-wrapper ~/Workspace/docker-cli-wrapper
======================================
please excute: alias dcw=/Users/howu/Workspace/docker-cli-wrapper/ctl.sh
======================================
~/Workspace/docker-cli-wrapper
```

#### up

launch one or several containers refer to the compose file name.

eg.

```shell
$ dcw up java9
~/Workspace/docker-cli-wrapper ~/Workspace/docker-cli-wrapper
======================================
-> [howu][2018-07-26 16:28:44] - INFO: up, file path: /Users/howu/Workspace/docker-cli-wrapper/compose/java9.yaml
Creating network "java9_default" with the default driver
Creating java9_java9_1 ... done
======================================
~/Workspace/docker-cli-wrapper
```

#### down

shutdown one or several containers refer to the compose file name.

eg.

```shell
$ dcw down java9
~/Workspace/docker-cli-wrapper ~/Workspace/docker-cli-wrapper
======================================
-> [howu][2018-07-26 16:30:42] - INFO: down, file path: /Users/howu/Workspace/docker-cli-wrapper/compose/java9.yaml
Stopping java9_java9_1 ... done
Removing java9_java9_1 ... done
Removing network java9_default
======================================
~/Workspace/docker-cli-wrapper
```

#### up-all

create all containers refer to the compose files.

#### down-all

shutdown all containers refer to the compose file.

#### ps

show containers status which is launched by docker-compose.

eg.

```shell
$ dcw ps
~/Workspace/docker-cli-wrapper ~/Workspace/docker-cli-wrapper
======================================
-> [howu][2018-07-26 16:31:12] - INFO: container info of [/Users/howu/Workspace/docker-cli-wrapper/compose/ansible.yaml]:
NAMES               CREATED AT                      STATUS              IMAGE               PORTS
ansible_agent1_1    2018-07-26 16:24:04 +0800 CST   Up 7 minutes        centos:7-dev        0.0.0.0:30007->8080/tcp
IP:172.19.0.4
NAMES               CREATED AT                      STATUS              IMAGE               PORTS
ansible_agent2_1    2018-07-26 16:24:04 +0800 CST   Up 7 minutes        centos:7-dev        0.0.0.0:30008->8080/tcp
IP:172.19.0.3
NAMES               CREATED AT                      STATUS              IMAGE               PORTS
ansible_agent3_1    2018-07-26 16:24:04 +0800 CST   Up 7 minutes        centos:7-dev        0.0.0.0:30009->8080/tcp
IP:172.19.0.5
NAMES               CREATED AT                      STATUS              IMAGE                PORTS
ansible_master_1    2018-07-26 16:24:04 +0800 CST   Up 7 minutes        centos_jupyter:0.1   0.0.0.0:30006->8080/tcp
IP:172.19.0.2

-> [howu][2018-07-26 16:31:13] - INFO: container info of [/Users/howu/Workspace/docker-cli-wrapper/compose/centos.yaml]:
NAMES               CREATED AT                      STATUS              IMAGE               PORTS
centos_centos_1     2018-07-26 16:11:02 +0800 CST   Up 20 minutes       centos:7-dev        0.0.0.0:30003->30003/tcp
IP:172.18.0.2

-> [howu][2018-07-26 16:31:14] - INFO: container info of [/Users/howu/Workspace/docker-cli-wrapper/compose/java9.yaml]:

-> [howu][2018-07-26 16:31:15] - INFO: container info of [/Users/howu/Workspace/docker-cli-wrapper/compose/jupyter.yaml]:

-> [howu][2018-07-26 16:31:16] - INFO: container info of [/Users/howu/Workspace/docker-cli-wrapper/compose/nginx.yaml]:

-> [howu][2018-07-26 16:31:16] - INFO: container info of [/Users/howu/Workspace/docker-cli-wrapper/compose/python3.6.5.yaml]:

======================================
~/Workspace/docker-cli-wrapper
```

#### list

list all compose file name.

eg.

```shell
$ dcw list
~/Workspace/docker-cli-wrapper ~/Workspace/docker-cli-wrapper
======================================
The following are all compose file:
ansible
centos
java9
jupyter
nginx
python3.6.5
======================================
~/Workspace/docker-cli-wrapper
```

#### describe

display the content of a specific compose file.

eg.

```shell
$ dcw describe java9
~/Workspace/docker-cli-wrapper ~/Workspace/docker-cli-wrapper
======================================
-> [howu][2018-07-26 16:32:52] - INFO: filepath: /Users/howu/Workspace/docker-cli-wrapper/compose/java9.yaml
version: '3.0'
services:
  java9:
    ports:
    - "${JAVA9_PORT}:${JAVA9_PORT}"
    volumes:
    - ${VOLUME_HOME}/java:/home/java
    - ${VOLUME_HOME}/.bashrc:/root/.bashrc
    image: java:9-jdk
    command:
    - /bin/sh
    - -c
    - "${INIT_COMMAND}"
    restart: always
======================================
~/Workspace/docker-cli-wrapper
```

#### in

exec bash to go in a container.

#### backup

backup the images, so you can filter which one should be reserved.

#### validate

validate the compose file.

eg.

```shell
$ dcw validate java9
~/Workspace/docker-cli-wrapper ~/Workspace/docker-cli-wrapper
======================================
services:
  java9:
    command:
    - /bin/sh
    - -c
    - 'while true; do echo [`whoami`][`date ''+%Y-%m-%d %H:%M:%S''`]: the container
      is alive; sleep 10; done'
    image: java:9-jdk
    ports:
    - 30001:30001/tcp
    restart: always
    volumes:
    - /Users/howu/Workspace/docker-cli-wrapper/volume/java:/home/java:rw
    - /Users/howu/Workspace/docker-cli-wrapper/volume/.bashrc:/root/.bashrc:rw
version: '3.0'

======================================
~/Workspace/docker-cli-wrapper
```

#### clean-disk

clean the disk for mac os.

---

## special instructions for the following applications:

#### jenkins:

- images:

    + master:
        jenkins/jenkins:lts
    + agent:
        centos_jdk8

- dcw up jenkins

    + account:
        + admin/admin

- dcw ps jenkins

    + adjust the Jenkins node information based on the query results of IPs

- the way of managing node is using the SSH:

    + root/admin

#### ansible:

- images:

    + master:
        centos_jupyter
    + slave:
        centos:7-dev

- dcw up ansible

    + jupyter portal:
        + password: admin

- dcw ps ansible

    + adjust the /etc/ansible/hosts of ansible master based on the query results of IPs

- the way of managing node is using the SSH:

    + root/admin

#### jupyter

- images:

    + centos_jupyter

- dcw up jupyter

    + jupyter portal:
        + password: admin

#### gocd

- images:

    + centos_gocd_server:0.1
    + centos_gocd_agent:0.1

- dcw up jupyter

- by sharing the same file, the agent could know the ip of master, so you no need to care about agent how to find the master.

---

## TODO:

#### gocd

- theory

#### local search engine

- package name ???

### nginx

- can not work

### gitlab

- support for git server
- refer: https://docs.gitlab.com/omnibus/docker/

## wordpress

## ruby
