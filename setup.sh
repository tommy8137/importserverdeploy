#!/bin/bash

# SETUP FOR CENTOS

# Usage: bash ./setup.sh [vm_password]
VM_PASSWORD=$1

# echo "-------------------"
# echo ${VM_PASSWORD}
# echo "-------------------"


setup_docker() {
    if ! docker -v &> /dev/null
    then
        # sudo usermod -aG docker your-user
        echo "==================== Install required packages ===================="
        echo ${VM_PASSWORD} | sudo -S yum install -y yum-utils device-mapper-persistent-data lvm2
        echo "==================== Set up the stable repository ===================="
        echo ${VM_PASSWORD} | sudo -S yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        echo "==================== Install the latest version of Docker CE and containerd ===================="
        echo ${VM_PASSWORD} | sudo -S yum install -y docker-ce docker-ce-cli containerd.io
        # sudo yum install docker-ce-<VERSION_STRING> docker-ce-cli-<VERSION_STRING> containerd.io
        echo "==================== Start docker ===================="
        echo ${VM_PASSWORD} | sudo -S systemctl start docker
        echo ${VM_PASSWORD} | sudo -S systemctl enable docker
        echo "==================== docker hello-world ===================="
        echo ${VM_PASSWORD} | sudo -S docker run hello-world
        echo "==================== give docker permission ===================="
        # 要從新登入才會生效
        echo ${VM_PASSWORD} | sudo -S usermod -aG docker $(whoami)
    else
        CURRENT_DOCKER_VERSION="$(docker -v | awk -F '[ ,]+' '{ print $3 }')"
        echo "Good. docker version $CURRENT_DOCKER_VERSION is already installed"
    fi
}

setup_docker_compose() {
<<COMMENT
################################ 測試用 ################################
# 確認docker-compose有沒有安裝
ls -al /usr/local/bin/docker-compose
ls -al /usr/bin/docker-compose
ls -al /usr/local/bin/


# 移除docker-compose
sudo rm /usr/local/bin/docker-compose
sudo rm /usr/bin/docker-compose

# 裝舊版
echo ${PASSWORD} | sudo -S curl -L "https://github.com/docker/compose/releases/download/1.14.0-rc2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
echo ${PASSWORD} | sudo -S chmod 755 /usr/local/bin/docker-compose
echo ${PASSWORD} | sudo -S ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# [ERROR] docker-compose: error while loading shared libraries: libz.so.1: failed to map segment from shared object: Operation not permitted
https://github.com/docker/compose/issues/1339
[解法]sudo mount /tmp -o remount,exec

################################ 測試用 end ################################
COMMENT


    DOCKER_COMPOSE_VERSION=1.23.2
    # 沒有docker-compose就安裝
    if ! docker-compose --version &> /dev/null
    then
        echo "==================== intstall docker-compose first ===================="
        echo ${VM_PASSWORD} | sudo -S curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        echo "==================== chmod give x ===================="
        echo ${VM_PASSWORD} | sudo -S chmod 755 /usr/local/bin/docker-compose
        echo "==================== link docker-compose to /usr/bin/docker-compose ===================="
        echo ${VM_PASSWORD} | sudo -S ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
        echo "check docker-compose version"
        docker-compose --version
    else
        CURRENT_DOCKER_COMPOSE_VERSION="$(docker-compose -v | awk -F '[ ,]+' '{ print $3 }')"
        # 版本不對就重裝
        if [ ${CURRENT_DOCKER_COMPOSE_VERSION} != ${DOCKER_COMPOSE_VERSION} ]; then
            echo "This version is ${CURRENT_DOCKER_COMPOSE_VERSION},but we need ${DOCKER_COMPOSE_VERSION}"
            echo "==================== intstall docker-compose ===================="3
            # remove old docker-compose
            echo "==================== remove old docker-compose ===================="
            echo ${VM_PASSWORD} | sudo -S rm -f /usr/local/bin/docker-compose
            echo ${VM_PASSWORD} | sudo -S rm -f /usr/bin/docker-compose
            echo "==================== install docker-compose ===================="
            echo ${VM_PASSWORD} | sudo -S curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            echo "==================== chmod give x ===================="
            echo ${VM_PASSWORD} | sudo -S chmod 755 /usr/local/bin/docker-compose
            # link to new docker-compose
            echo "==================== link docker-compose to /usr/bin/docker-compose ===================="
            echo ${VM_PASSWORD} | sudo -S ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
            echo "check docker-compose version"
            docker-compose --version
        else
            echo "Good. docker-compose version $CURRENT_DOCKER_COMPOSE_VERSION is already installed"
        fi
    fi
}


setup_ntpd() {
    # ntpq -p 可以看到校正時間的狀況
    # https://szlin.me/2016/07/19/%E4%BD%BF%E7%94%A8-ntpd-%E4%BE%86%E6%9B%BF%E6%8F%9B-ntpdate-%E4%BB%A5%E5%AE%8C%E6%88%90%E6%A0%A1%E6%99%82%E7%9A%84%E5%B7%A5%E4%BD%9C/

    # 確認ntp是否安裝了
    yum list installed ntp
    if [ $? -eq 0 ]; then
        echo "---------------------- ntp already installed. skipping step ----------------------"
    else
        echo "---------------------- Install ntp and enable it...... ----------------------"
        echo ${VM_PASSWORD} | sudo -S yum list installed ntp -y
        echo ${VM_PASSWORD} | sudo -S yum install ntp -y
        echo ${VM_PASSWORD} | sudo -S systemctl start ntpd
        echo ${VM_PASSWORD} | sudo -S systemctl enable ntpd
    fi

}

# (要root權限才能執行，暫時不考慮使用)
# setup_crontab() {
# <<COMMENT
# 使用`tail -f /var/log/cron`可以查看cronjob是否執行(要用root權限)
      # 分鐘 小時 日期 月份 週
#     $ chmod 755 /home/swpc-user/WiEProcureV/pipe/clean.sh
# -rwxr-xr-x. 1 swpc-user swpc-user     1334 Mar 21 12:56 clean.sh*
#     $ sudo crontab -e
#     # modify 
#     1 0 * * * /home/swpc-user/WiEProcureV/pipe/clean.sh
# COMMENT

#     # sudo crontab -u root -l
#     LIST=`crontab -l`

#     if echo "$LIST" | grep -q "1\ 0\ \*\ \*\ \*\ /home/swpc-user/WiEProcureV/pipe/clean.sh"; then
#     echo "The back job had been added.";

#     else
#         crontab -l | { cat; echo "1 0 * * * /home/swpc-user/WiEProcureV/pipe/clean.sh"; } | crontab -
#     fi
# }

# 安裝docker
setup_docker
# 安裝docker-compose
echo "---------------------- STEP. setup_docker_compose ---------------------- "
setup_docker_compose
echo "------------------------------------------------------------------------- "
# 安裝對時系統
echo "---------------------- STEP. setup_ntpd ---------------------- "
setup_ntpd
echo "------------------------------------------------------------------------- "

# (要root權限才能執行，暫時不考慮使用)
# echo "STEP. setup_crontab"
# setup_crontab
