FROM centos:7
COPY ./jdk-8u181-linux-x64.rpm /root/jdk-8u181-linux-x64.rpm
RUN yum install -y \
  openssh-server \
  openssh-clients \
  iproute \
  which \
  net-tools \
  lsof \
  vim-enhanced \ 
  wget \
  git \
  && yum localinstall -y /root/jdk-8u181-linux-x64.rpm
