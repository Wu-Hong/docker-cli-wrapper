[[toc]]

# dcw - docker cli wrapper for MacOS
![](https://upload.wikimedia.org/wikipedia/commons/7/79/Docker_%28container_engine%29_logo.png)

A docker-compose CLI wrapper for the people who try to use docker-compose in Mac OS.

## Sub Commands

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

## Instructions for Specific Service
### jenkins
~~+ adjust the Jenkins node information based on the query results of IPs~~
**No need to do this any more, since docker-compose support service communicating with each other by the serivce name which define in one docker-compose file, but you still need to config the host of salves when you first up the jenkins cluster**

### ansible
~~+ adjust the /etc/ansible/hosts of ansible master based on the query results of IPs~~
**No need to do this any more, since docker-compose support service communicating with each other by the serivce name which define in one docker-compose file, even you first up the ansible cluster**

### gocd
By sharing the same file, the agent could know the ip of master, so you no need to care about agent how to find the master.

## Roadmap
### aria2
- can not work now

#### gocd
- theory

#### nginx
- can not work now

### migrate the repo to cpm
- cpm = compose package manager
- clean code
- up/down/update
