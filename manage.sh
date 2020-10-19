#!/bin/bash

set -e

BASEDIR=$(dirname "$0")
echo "$BASEDIR"

# 導入環境變數 -a: all-export
set -a
. ${BASEDIR}/VersionInfo
set +a

DOCKER_COMPOSE_FILE=docker-compose.yml

help() {
    cat <<EOF
******************************************
                    menu                        
******************************************
1. install service
2. stop service
3. start service
4. restart service
5. stop and remove service
6. service status
7. use custom docker-compose command (use 'bash manage.sh 7 "config --services"' find service name)
8. start single service. [service-name] 
******************************************
EOF
}

# ex: sh ./manage.sh 1
# ex: sh ./manage.sh 2
# sh ./manage.sh 6 rm, sh ./manage.sh 6 "stop redis"  超過兩個參數要放在雙引號裡面
case "$1" in
1)
    echo "install service..."
    if [ "$BUILD_OFFLINE_DOCKER_TARS" == true ]; then
        echo "load docker tar first"
        docker load --input ${BASEDIR}/${SERVICE_TAR_NAME}
    fi
    docker-compose -f ${BASEDIR}/${DOCKER_COMPOSE_FILE} up -d
    echo "-----------------------------------------------------"
    echo "service status..."
    docker-compose ps
    echo "-----------------------------------------------------"
    echo "remove unused images"
    echo "y" | docker image prune -a
    echo "-----------------------------------------------------"
    ;;
2)
    echo "stop service"
    docker-compose -f ${BASEDIR}/${DOCKER_COMPOSE_FILE} stop
    echo "-----------------------------------------------------"
    docker-compose ps
    ;;
3)
    echo "start service"
    docker-compose -f ${BASEDIR}/${DOCKER_COMPOSE_FILE} up -d
    echo "-----------------------------------------------------"
    docker-compose ps
    ;;
4)
    echo "restart service"
    docker-compose -f ${BASEDIR}/${DOCKER_COMPOSE_FILE} restart
    echo "-----------------------------------------------------"
    docker-compose ps
    ;;
5)
    echo "stop and remove service"
    docker-compose -f ${BASEDIR}/${DOCKER_COMPOSE_FILE} down
    echo "-----------------------------------------------------"
    docker-compose ps
    ;;
6)
    echo "service status"
    docker-compose -f ${BASEDIR}/${DOCKER_COMPOSE_FILE} ps
    ;;
7)
    # sh ./manage.sh 6 |||
    # ex: sh ./manage.sh 6 rm, sh ./manage.sh 6 "stop redis"  超過兩個參數要放在雙引號裡面
    echo "use docker-compose command"
    docker-compose -f ${BASEDIR}/${DOCKER_COMPOSE_FILE} $2
    ;;
8)
    echo "start single service"
    # ex: sh ./manage.sh 7 web , sh ./manage.sh 7 redis
    docker-compose -f ${BASEDIR}/${DOCKER_COMPOSE_FILE} up -d $2
    echo "-----------------------------------------------------"
    docker-compose ps
    ;;
*)
    help
    exit 1
    ;;
esac
