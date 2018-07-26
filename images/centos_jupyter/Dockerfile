FROM centos:7
COPY ./get-pip.py /root/get-pip.py
RUN yum install -y \
  openssh-server \
  openssh-clients \
  iproute \
  which \
  net-tools \
  lsof \
  vim-enhanced \ 
  gcc \
  python-devel \
  && python /root/get-pip.py \
  && python -m pip install jupyter
