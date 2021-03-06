FROM node:10.11.0-stretch

USER root

RUN apt-get update && apt-get install -y apt-utils

RUN apt-get update && apt-get install -y \
    build-essential \
    sudo \
    gcc-multilib \
    cmake \
    libxcb-xfixes0-dev \
    g++ \
    pkg-config \
    jq \
    libcurl4-openssl-dev \
    libelf-dev \
    libdw-dev \
    binutils-dev \
    libiberty-dev \
    python \
    zlib1g-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN echo "deb http://deb.debian.org/debian stretch-backports main contrib non-free # available after stretch release" >> /etc/apt/sources.list && \
    apt-get update && apt-get -y upgrade && apt-get install -y clang-6.0 && rm -rf /var/lib/apt/lists/*

RUN npm install -g node-gyp && npm install -g forever && npm install -g forever-service

RUN usermod -aG sudo node \
    && echo "node ALL=(root) NOPASSWD: /usr/local/bin/forever-service, /usr/sbin/service webapi stop, /usr/sbin/service webapi start" >> /etc/sudoers

USER node

RUN cd /tmp &&  wget https://sh.rustup.rs -O rust.sh && bash rust.sh -y && rm rust.sh

ENV PATH="/home/node/.cargo/bin:${PATH}"

RUN rustup component add rustfmt-preview && rustup target add i686-unknown-linux-gnu

USER node

# Get q-server repo at point
ARG TON_Q_SERVER_GITHUB_REPO=https://github.com/tonlabs/ton-q-server
ENV TON_Q_SERVER_GITHUB_REPO=${TON_Q_SERVER_GITHUB_REPO}

ARG TON_Q_SERVER_GITHUB_COMMIT_ID=master
ENV TON_Q_SERVER_GITHUB_COMMIT_ID=${TON_Q_SERVER_GITHUB_COMMIT_ID}

RUN git clone "${TON_Q_SERVER_GITHUB_REPO}" /tmp/ton-q-server \
    && cd /tmp/ton-q-server \
    && git checkout "${TON_Q_SERVER_GITHUB_COMMIT_ID}" \
    && cp -a . /home/node

WORKDIR /home/node

RUN npm install --production
EXPOSE 4000
ENTRYPOINT ["node", "index.js"]
