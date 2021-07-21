# base stage:
# runtime image
FROM ubuntu:18.04 as base

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends gnupg wget python ca-certificates jq make cmake gdb git libfuse-dev libtool tzdata openjdk-11-jdk && \
    echo 'deb [arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu bionic main' | tee /etc/apt/sources.list.d/intel-sgx.list && \
    wget -qO - https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add - && \
    echo 'deb [arch=amd64] https://occlum.io/occlum-package-repos/debian bionic main' | tee /etc/apt/sources.list.d/occlum.list && \
    wget -qO - https://occlum.io/occlum-package-repos/debian/public.key | apt-key add - && \
    apt-get update && \
    apt-get install -y occlum libsgx-uae-service libsgx-dcap-ql&& \
    mkdir -p /var/run/aesmd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/occlum/build/bin:/usr/local/occlum/bin:$PATH"


# developing image
WORKDIR /root

RUN git clone https://github.com/occlum/occlum.git && \
    cp -r /root/occlum/demos /root/demos && \
    rm -rf /root/occlum && \
    cd /root && \
    mkdir tianchi && \
    cp /root/demos/flink/hosts /root/tianchi

WORKDIR /root/tianchi
RUN wget https://archive.apache.org/dist/flink/flink-1.11.3/flink-1.11.3-bin-scala_2.11.tgz && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    tar -xvzf flink-1.11.3-bin-scala_2.11.tgz && \
    rm -rf flink-1.11.3-bin-scala_2.11.tgz
RUN bash ./Miniconda3-latest-Linux-x86_64.sh -b -p ./miniconda && \
    rm -rf ./Miniconda3-latest-Linux-x86_64.sh && \
    ./miniconda/bin/conda create --prefix ./python-occlum -y python=3.7 streamz=0.5.2 matplotlib=3.1.2 requests=2.22.0 six=1.12.0 numpy=1.18.1 networkx=2.4 pytest=5.3.5 apscheduler=3.6.3 google-api-core=1.16.0 psutil=5.6.3 pandas=0.24.2 tensorflow=1.15.0 pymysql=0.9.3 scikit-learn=0.21.2 colorlog=4.0.2 flask-admin=1.5.4 flask-swagger=0.2.13 json-merge-patch=0.2 sqlalchemy=1.3.23 tenacity=6.2.0 termcolor=1.1.0 text-unidecode=1.3 pyarrow=0.15.1 babel=2.9.1

COPY build_instance.sh /root/tianchi
COPY fish /root/tianchi
COPY busy_box /root/tianchi
