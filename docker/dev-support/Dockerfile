FROM debian:9

ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN apt-get update -y && apt upgrade -y

RUN apt-get install -y \
    systemd jq make netcat-openbsd lsof python3  python3-pip unzip  \
    git python-dev libffi-dev gcc libc-dev apt-transport-https \
    ca-certificates curl gnupg-agent software-properties-common

# Install common Dojo scripts
ENV DOJO_VERSION=0.6.2
RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  sudo git ca-certificates && \
  git clone --depth 1 -b ${DOJO_VERSION} https://github.com/kudulab/dojo.git /tmp/dojo_git &&\
  /tmp/dojo_git/image_scripts/src/install.sh && \
  rm -r /tmp/dojo_git

ENV PS1='\[\033[01;32m\]\u@\h\[\033[00m\](dojo):\[\033[01;34m\]\w\[\033[00m\]\$ '

RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

