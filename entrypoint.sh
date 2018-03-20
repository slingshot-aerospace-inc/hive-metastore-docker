#!/bin/bash

# Stolen from https://github.com/big-data-europe/docker-hive/blob/master/entrypoint.sh (it's pretty awesome, i really like this method of configuring hive)

#export CORE_CONF_fs_defaultFS=${CORE_CONF_fs_defaultFS:-hdfs://`hostname -f`:8020}

function addProperty() {
  local path=$1
  local name=$2
  local value=$3

  local entry="<property><name>$name</name><value>${value}</value></property>"
  local escapedEntry=$(echo $entry | sed 's/\//\\\//g')
  sed -i "/<\/configuration>/ s/.*/${escapedEntry}\n&/" $path
}

function configure() {
    local path=$1
    local module=$2
    local envPrefix=$3

    local var
    local value

    echo "Configuring $module"
    for c in `printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix=$envPrefix`; do
        name=`echo ${c} | perl -pe 's/___/-/g; s/__/_/g; s/_/./g'`
        var="${envPrefix}_${c}"
        value=${!var}
        echo " - Setting $name=$value"
        addProperty $path $name "$value"
    done
}

# Hadoop Home env var comes from dockerfile and env
#configure ${HADOOP_HOME}/etc/hadoop/core-site.xml core CORE_CONF
configure ${HADOOP_HOME}/etc/hadoop/hive-site.xml hive HIVE_SITE_CONF

# k, now run whatever was our CMD
exec $@
