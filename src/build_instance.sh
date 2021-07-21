#!/bin/bash
set -e

BLUE='\033[1;34m'
NC='\033[0m'
occlum_glibc=/opt/occlum/glibc/lib/

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" >/dev/null 2>&1 && pwd )"

occlum new occlum_instance
cd occlum_instance

# Copy files into Occlum Workspace and build
if [ ! -L "image/bin/python3" ];then
    mkdir -p image/opt
    cp -rf ../python-occlum image/opt/python-occlum
    ln -s /opt/python-occlum/bin/python3 image/bin/python3
    cp -f $occlum_glibc/libdl.so.2 image/$occlum_glibc
    cp -f $occlum_glibc/libutil.so.1 image/$occlum_glibc
    cp -f $occlum_glibc/librt.so.1 image/$occlum_glibc
    cp -f $occlum_glibc/libm.so.6 image/$occlum_glibc
    cp -f $occlum_glibc/libnss_files.so.2 image/$occlum_glibc
    mkdir -p image/usr/lib/jvm
    cp /lib/x86_64-linux-gnu/libz.so.1 image/lib
    cp -r /usr/lib/jvm/java-11-openjdk-amd64 image/usr/lib/jvm
    cp -rf ../flink-1.11.3 image/opt/flink
    cp -rf ../hosts image/etc/
    cp ../fish image/usr/bin
    cp ../busybox image/usr/bin
    new_json="$(jq '.resource_limits.user_space_size = "1500MB" |
    .resource_limits.max_num_of_threads = 256 |
    .resource_limits.kernel_space_heap_size="1500MB" |
    .process.default_heap_size = "128MB" |
    .process.default_stack_size = "4MB" |
    .process.default_mmap_size = "1000MB" |
    .env.default = [ "LD_LIBRARY_PATH=/usr/lib/jvm/java-11-openjdk-amd64/lib/server:/usr/lib/jvm/java-11-openjdk-amd64/lib:/usr/lib/jvm/java-11-openjdk-amd64/../lib:/lib", "FLINK_CONF_DIR=/opt/flink/conf", "PYTHONHOME=/opt/python-occlum" ]' Occlum.json)" && \
    echo "${new_json}" > Occlum.json
fi

# Build occlum instance
Occlum build
