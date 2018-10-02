#! /bin/sh

SIZE=$1
[ "$SIZE" != "" ] || SIZE=1

# Hack to make .env work in stack deploy mode...
source <(cat .env | sed -e "s+^\([^# ]\)+export \1+g")
export DOCKER_HOST=tcp://ymslanda.innovationgarage.tech:2375

docker build --tag ymslanda.innovationgarage.tech:5000/spark-master:$SPARK_MASTER_VERSION master
docker push ymslanda.innovationgarage.tech:5000/spark-master:$SPARK_MASTER_VERSION

{
    cat <<EOF
version: '3'
services:
  spark-master:
    hostname: spark-master
    image: ymslanda.innovationgarage.tech:5000/spark-master:${SPARK_MASTER_VERSION}
    ports:
      - "8080:8080"
      - "7077:7077"
    environment:
      INIT_DAEMON_STEP: setup_spark
      SPARK_PUBLIC_DNS: ymslanda.innovationgarage.tech
    volumes:
      - /ymslanda:/ymslanda
EOF

    for ((idx=1;idx<=SIZE;idx++)); do
        ((port=8180+idx))
        cat <<EOF
  spark-worker-$idx:
    hostname: spark-worker-$idx
    image: bde2020/spark-worker:2.3.1-hadoop2.7
    depends_on:
      - spark-master
    ports:
      - "$port:$port"
    environment:
      SPARK_MASTER: "spark://spark-master:7077"
      SPARK_WORKER_WEBUI_PORT: "$port"
      SPARK_PUBLIC_DNS: ymslanda.innovationgarage.tech
    volumes:
      - /ymslanda:/ymslanda
EOF
    done  
} > docker-compose.yml

docker stack deploy -c docker-compose.yml spark-cluster

