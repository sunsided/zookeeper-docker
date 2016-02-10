#!/usr/bin/env bash

set -eo pipefail

# install the required files
apt-get update
apt-get -y install git ant

# install zookeper
mkdir -p $ZOOKEEPER_PATH
cd $ZOOKEEPER_PATH

# fetch Zookeeper
git clone --branch release-3.5.1 --depth 1  https://github.com/apache/zookeeper.git .
rm -rf .git

# jar it up
ant jar

# cleanup
apt-get -y remove git ant
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# update configuration
cp $ZOOKEEPER_PATH/conf/zoo_sample.cfg $ZOOKEEPER_PATH/conf/zoo.cfg
echo "standaloneEnabled=false" >> $ZOOKEEPER_PATH/conf/zoo.cfg
echo "dynamicConfigFile=$ZOOKEEPER_PATH/conf/zoo.cfg.dynamic" >> $ZOOKEEPER_PATH/conf/zoo.cfg
