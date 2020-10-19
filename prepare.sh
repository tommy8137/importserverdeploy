#!/bin/bash
set -e

BASEDIR=$(dirname "$0")
ENV_FILE=$2
# 要不要先把docker image build成離線版
BUILD_OFFLINE_DOCKER_TARS=${3:-false}

echo '========================='
echo ${ENV_FILE}
echo ${BUILD_OFFLINE_DOCKER_TARS}
echo '========================='


if [ "$BUILD_OFFLINE_DOCKER_TARS" == true ]; then
    echo "BUILD_OFFLINE_DOCKER_TARS is true."
fi
if [ "$BUILD_OFFLINE_DOCKER_TARS" == false ]; then
    echo "BUILD_OFFLINE_DOCKER_TARS is false."
fi

help() {
cat <<EOF
******************************************
                    menu                        
******************************************
bash prepare.sh [number] [dev.env|qt.env|prd.env|test.env] [BUILD_OFFLINE_DOCKER_TARS: true|false] 
1. pack up web service
2. pack up pipe service
3. pack up db service
4. pack up flaskdemo service
5. pack up sync service
6. pack up bigdata service
******************************************
EOF
}

case "$1" in
1)
    echo "===================== pack up web service ====================="
    # -r readonly
    declare -r SERVICE_FOLDER=web
    declare -r SERVICE_TAR_NAME=web.tar
    # -a 將後面名為 variable 的變數定義成為陣列
    readarray -t IMAGE_LIST_ARRAY < ${BASEDIR}/imageConfig/WEBAPP_IMAGES_LIST.config
    ;;
2)
    echo "===================== pack up pipe service ====================="
    # -r readonly
    declare -r SERVICE_FOLDER=pipe
    declare -r SERVICE_TAR_NAME=pipe.tar
    # -a 將後面名為 variable 的變數定義成為陣列
    readarray -t IMAGE_LIST_ARRAY < ${BASEDIR}/imageConfig/PIPE_IMAGES_LIST.config
    ;;  
3)
    echo "===================== pack up db service ====================="
    # -r readonly
    declare -r SERVICE_FOLDER=db
    declare -r SERVICE_TAR_NAME=db.tar
    # -a 將後面名為 variable 的變數定義成為陣列
    readarray -t IMAGE_LIST_ARRAY < ${BASEDIR}/imageConfig/DB_IMAGES_LIST.config
    ;;     
4)
    echo "===================== pack up demo service ====================="
    # -r readonly
    declare -r SERVICE_FOLDER=flaskdemo
    declare -r SERVICE_TAR_NAME=flaskdemo.tar
    # -a 將後面名為 variable 的變數定義成為陣列
    readarray -t IMAGE_LIST_ARRAY < ${BASEDIR}/imageConfig/FLASKDEMO_IMAGES_LIST.config
    ;;       
5)
    echo "===================== pack up sync service ====================="
    # -r readonly
    declare -r SERVICE_FOLDER=sync
    declare -r SERVICE_TAR_NAME=sync.tar
    # -a 將後面名為 variable 的變數定義成為陣列
    readarray -t IMAGE_LIST_ARRAY < ${BASEDIR}/imageConfig/SYNC_IMAGES_LIST.config
    ;; 
6)
    echo "===================== pack up bigdata service ====================="
    # -r readonly
    declare -r SERVICE_FOLDER=bigdata
    declare -r SERVICE_TAR_NAME=bigdata.tar
    # -a 將後面名為 variable 的變數定義成為陣列
    readarray -t IMAGE_LIST_ARRAY < ${BASEDIR}/imageConfig/BIGDATA_IMAGES_LIST.config
    ;; 
*)
    help
    exit 1
    ;;
esac

######################## 寫入版本資訊 ########################
write_version_info() {   
    echo "===================== write VersionInfo ====================="
    # 如果檔案已經存在先刪掉
    echo ${BASEDIR}/${SERVICE_FOLDER}/VersionInfo
    if [ -f ${BASEDIR}/${SERVICE_FOLDER}/VersionInfo ] ; then
        rm ${BASEDIR}/${SERVICE_FOLDER}/VersionInfo
    fi

    # 寫release版號
    echo "export PACK_DATE='$(date)'" >> ${BASEDIR}/${SERVICE_FOLDER}/VersionInfo
    DATETIME=`date "+%Y-%m-%d %H:%M:%S"`
    echo "export PACK_DATETIME='${DATETIME}'" >> ${BASEDIR}/${SERVICE_FOLDER}/VersionInfo
    echo "export RELEASE_TAG='${RELEASE_TAG}'" >> ${BASEDIR}/${SERVICE_FOLDER}/VersionInfo
    echo "export ENV_FILE=${ENV_FILE}" >> ${BASEDIR}/${SERVICE_FOLDER}/VersionInfo
    echo "export SERVICE_TAR_NAME=${SERVICE_TAR_NAME}" >> ${BASEDIR}/${SERVICE_FOLDER}/VersionInfo
    echo "export BUILD_OFFLINE_DOCKER_TARS=${BUILD_OFFLINE_DOCKER_TARS}" >> ${BASEDIR}/${SERVICE_FOLDER}/VersionInfo
    
    # LPP 的prd的port要另外處理
    if [ "${SERVICE_FOLDER}" = "bigdata" ]
    then
        if [ "${ENV_FILE}" = "prd.env" ]
            then
                echo "export HOST_LPP_PORT=80" >> ${BASEDIR}/${SERVICE_FOLDER}/VersionInfo
            else
                echo "export HOST_LPP_PORT=8004" >> ${BASEDIR}/${SERVICE_FOLDER}/VersionInfo
            fi
    fi

    # 寫所有用到的docker image & 版號
    for ENTRY in ${IMAGE_LIST_ARRAY[@]}; do
        # echo $ENTRY
        echo "export ${ENTRY}"
    done >> ${BASEDIR}/${SERVICE_FOLDER}/VersionInfo
    # 印出來看看
    echo "========================== VersionInfo =============================="
    cat ${BASEDIR}/${SERVICE_FOLDER}/VersionInfo
    echo "========================================================"
}


######################## 把image打包 ########################
prepare_docker_images_tar() {
    ######################## 把image拉下來 ########################
    echo "===================== pull docker images ====================="
    for i in "${IMAGE_LIST_ARRAY[@]}"
    do
    echo "$i"
    docker pull $(echo ${i} | awk -F'=' '{print $2}')
    done


    echo "===================== build image list into a tar file ====================="

    # 把"="前面的key去掉。ex: MULTI_SERVER_IMAGE=something:v1 ---> something:v1
    declare -a NEW_IMAGE_LIST_ARRAY
    for i in "${!IMAGE_LIST_ARRAY[@]}"
    do
    NEW_IMAGE_LIST_ARRAY[$i]=$(echo ${IMAGE_LIST_ARRAY[i]} | awk -F'=' '{print $2}')
    done

    docker save -o ${BASEDIR}/${SERVICE_FOLDER}/${SERVICE_TAR_NAME} ${NEW_IMAGE_LIST_ARRAY}
}


######################## 把service包成tar檔 ########################
prepare_service_package_tar() {
    ######################## 把manage.sh包進去 ########################
    echo "===================== pack up manage.sh & setup.sh ====================="
    cp manage.sh ${BASEDIR}/${SERVICE_FOLDER}/
    cp setup.sh ${BASEDIR}/${SERVICE_FOLDER}/


    ######################## 把service包成tar檔 ########################
    echo "===================== pack up service start ====================="
    tar -czvf WiEProcure__${SERVICE_FOLDER}__${RELEASE_TAG}.tar.gz ${BASEDIR}/${SERVICE_FOLDER}
    # tar -czvf WiEProcure__${SERVICE_FOLDER}.tar.gz ${BASEDIR}/${SERVICE_FOLDER}
    echo "===================== pack up service finish ====================="
}


write_version_info
# prepare_docker_images_tar
if [ "$BUILD_OFFLINE_DOCKER_TARS" == true ]; then
    echo "prepare_docker_images_tar"
    prepare_docker_images_tar
fi
prepare_service_package_tar