# dcw - docker cli wrapper for Mac OS
![](https://upload.wikimedia.org/wikipedia/commons/7/79/Docker_%28container_engine%29_logo.png)

A docker-compose CLI wrapper for the people who try to use docker-compose in Mac OS.

## Sub command

### init
Show the alias of using dcw.

### up
Launch one or several containers refer to the compose file name.

### down
Shutdown one or several containers refer to the compose file name.

### up-all
Create all containers refer to the compose files.

### down-all
Shutdown all containers refer to the compose files.

### ps
Show containers status which is launched by docker-compose.
* For all
`dcw ps`
* For one
`dcw ps ansible`
* For one and continuous refresh
`dcw ps -f ansible`

### list
List all compose files name.

### cat
Display the content of a specific original compose file.

### in
Auto select terminal(zsh, bash, sh) and exec it to go in a container.

### backup
Backup the images, so you can filter which one should be reserved.

### validate
Validate the compose file.
* Validate all compose files: `dcw validate`
* Validate specific compose file: `dcw validate ansible`

**When you modify the docker-compose file, but you are not sure if it is legal, you should check with `dcw validate` first instead of deploying it.**

### clean-disk
Clean the disk occupied by docker images for Mac OS.

## Instructions for specific application
### jenkins
![](https://wiki.jenkins.io/download/attachments/2916393/logo.png?version=1&modificationDate=1302753947000&api=v2)
* images:
    - master:
        jenkins/jenkins:lts
    - agent:
        centos_jdk8
* dcw up jenkins
    - account:
        - admin/admin

* dcw ps jenkins
    ~~+ adjust the Jenkins node information based on the query results of IPs~~
    **No need to do this any more, since docker-compose support service communicating with each other by the serivce name which define in one docker-compose file, but you still need to config the host of salves when you first up the jenkins cluster**
* the way of managing node is using the SSH:
    - root/admin

#### ansible
![](https://upload.wikimedia.org/wikipedia/commons/2/24/Ansible_logo.svg)
* images:
    + master:
        centos_jupyter
    + slave:
        centos:7-dev
* dcw up ansible
    + jupyter portal:
        + password: admin

* dcw ps ansible
    ~~+ adjust the /etc/ansible/hosts of ansible master based on the query results of IPs~~
    **No need to do this any more, since docker-compose support service communicating with each other by the serivce name which define in one docker-compose file, even you first up the ansible cluster**
* the way of managing node is using the SSH:
    + root/admin

#### jupyter
![](https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Jupyter_logo.svg/640px-Jupyter_logo.svg.png)
* images:
    + centos_jupyter
* dcw up jupyter
    + jupyter portal:
        + password: admin

#### gocd
![](https://impaddo.com/assets/uploads/2017/08/Logo-gocd.png)
* images:
    + centos_gocd_server:0.1
    + centos_gocd_agent:0.1
* dcw up jupyter
* by sharing the same file, the agent could know the ip of master, so you no need to care about agent how to find the master.

### gitlab
![](https://about.gitlab.com/images/press/logo/svg/gitlab-logo-gray-rgb.svg)
* The server will prompt you to change the password of `root` when you first login, I suggest to change to root/iamadmin
