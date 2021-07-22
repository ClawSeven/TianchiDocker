#! /usr/bin/fish

set flink_path "/opt/flink"
function run_taskmanager
    ulimit -Sv 8240000
    /usr/lib/jvm/java-11-openjdk-amd64/bin/java \
        -Xmx800m -XX:-UseCompressedOops -XX:MaxMetaspaceSize=256m \
        -XX:ActiveProcessorCount=2 \
        -Dlog.file="/host/tm.log" \
        -Dos.name=Linux \
        -Dlog4j.configurationFile=file:$flink_path/conf/log4j.properties \
        -Dlogback.configurationFile=file:$flink_path/conf/logback.xml \
        -Dorg.apache.flink.shaded.netty4.io.netty.eventLoopThreads=1 \
        -classpath $flink_path/lib/flink-table-blink_2.11-1.11.3.jar:$flink_path/lib/flink-table_2.11-1.11.3.jar:$flink_path/lib/flink-dist_2.11-1.11.3.jar:$flink_path/lib/log4j-1.2-api-2.12.1.jar:$flink_path/lib/log4j-slf4j-impl-2.12.1.jar:$flink_path/lib/log4j-api-2.12.1.jar:$flink_path/lib/flink-csv-1.11.3.jar:$flink_path/lib/flink-json-1.11.3.jar:$flink_path/lib/flink-shaded-zookeeper-3.4.14.jar:$flink_path/lib/log4j-core-2.12.1.jar org.apache.flink.runtime.taskexecutor.TaskManagerRunner \
        --configDir $flink_path/conf \
        -D taskmanager.memory.network.max=64mb \
        -D taskmanager.memory.network.min=64mb \
        -D taskmanager.memory.managed.size=128mb \
        -D taskmanager.cpu.cores=1.0 \
        -D taskmanager.memory.task.heap.size=256mb \
    &
end

function run_jobmanager
    ulimit -Sv 8240000
    /usr/lib/jvm/java-11-openjdk-amd64/bin/java \
        -Xmx800m -XX:-UseCompressedOops -XX:MaxMetaspaceSize=256m \
        -XX:ActiveProcessorCount=2 \
        -Dlog.file="/host/jm.log" \
        -Dos.name=Linux \
        -Dlog4j.configurationFile=file:$flink_path/conf/log4j.properties \
        -Dlogback.configurationFile=file:$flink_path/conf/logback.xml \
        -classpath $flink_path/lib/flink-table-blink_2.11-1.11.3.jar:$flink_path/lib/flink-table_2.11-1.11.3.jar:$flink_path/lib/flink-dist_2.11-1.11.3.jar:$flink_path/lib/log4j-1.2-api-2.12.1.jar:$flink_path/lib/log4j-slf4j-impl-2.12.1.jar:$flink_path/lib/log4j-api-2.12.1.jar:$flink_path/lib/flink-csv-1.11.3.jar:$flink_path/lib/flink-json-1.11.3.jar:$flink_path/lib/flink-shaded-zookeeper-3.4.14.jar:$flink_path/lib/log4j-core-2.12.1.jar org.apache.flink.runtime.entrypoint.StandaloneSessionClusterEntrypoint \
        --configDir $flink_path/conf \
        --executionMode cluster \
    &
end

function submit_task
    ulimit -Sv 4240000
    /usr/lib/jvm/java-11-openjdk-amd64/bin/java \
        -Xmx800m -XX:-UseCompressedOops -XX:MaxMetaspaceSize=256m \
        -XX:ActiveProcessorCount=2 \
        -Dlog.file="/host/task.log" \
        -Dos.name=Linux \
        -Dlog4j.configurationFile=file:$flink_path/conf/log4j.properties \
        -Dlogback.configurationFile=file:$flink_path/conf/logback.xml \
        -classpath $flink_path/lib/flink-table-blink_2.11-1.11.3.jar:$flink_path/lib/flink-table_2.11-1.11.3.jar:$flink_path/lib/flink-dist_2.11-1.11.3.jar:$flink_path/lib/log4j-1.2-api-2.12.1.jar:$flink_path/lib/log4j-slf4j-impl-2.12.1.jar:$flink_path/lib/log4j-api-2.12.1.jar:$flink_path/lib/flink-csv-1.11.3.jar:$flink_path/lib/flink-json-1.11.3.jar:$flink_path/lib/flink-shaded-zookeeper-3.4.14.jar:$flink_path/lib/log4j-core-2.12.1.jar org.apache.flink.client.cli.CliFrontend \
        run $flink_path/examples/streaming/WordCount.jar \
    &
end

set arg $argv[1]
switch $arg
    case jm
        run_jobmanager
    case tm
        run_taskmanager
    case task
        submit_task
end