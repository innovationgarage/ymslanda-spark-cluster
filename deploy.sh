#! /bin/sh

# Hack to make .env work in stack deploy mode...
source <(cat .env | sed -e "s+^\([^# ]\)+export \1+g")
export DOCKER_HOST=tcp://ymslanda.innovationgarage.tech:2375

docker build --tag ymslanda.innovationgarage.tech:5000/spark-master:$SPARK_MASTER_VERSION master
docker push ymslanda.innovationgarage.tech:5000/spark-master:$SPARK_MASTER_VERSION
docker stack deploy -c docker-compose.yml spark-cluster

