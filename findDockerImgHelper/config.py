# -*- coding: utf-8 -*
import os
gitlab_api_base = "https://gitlab.devpack.cc/api/v4/projects"



# 預設用release branch部署
SWITCH_WEB_BRANCH = os.environ.get('SWITCH_WEB_BRANCH', 'release')


WEB_SERVICE_INFO = [
    {
        "tag_url": "{0}/e-procure%2Fwi-procurement/repository/branches/{1}".format(gitlab_api_base, SWITCH_WEB_BRANCH),
        "image_name": "repo.devpack.cc/e-procure/wi-procurement-{0}".format(SWITCH_WEB_BRANCH),
        "docker_compose_image_variable": 'WEBAPP_IMAGE',
        "repo_id": "e-procure%2Fwi-procurement",
        "ref": SWITCH_WEB_BRANCH
    },
]

# WEB_RELEASE_INFO = [
#     {
#         "tag_url": "{0}/e-procure%2Fwi-procurement/repository/branches/release".format(gitlab_api_base),
#         "image_name": "repo.devpack.cc/e-procure/wi-procurement-release",
#         "docker_compose_image_variable": 'WEBAPP_IMAGE',
#         "repo_id": "e-procure%2Fwi-procurement",
#         "ref": "release"
#     },
# ]

# WEB_SERVICE_INFO = WEB_RELEASE_INFO
# # dev環境如果有特別指定master的話
# if SWITCH_WEB_BRANCH == 'master':
#     WEB_SERVICE_INFO = WEB_MASTER_INFO


print('===============================')
print(SWITCH_WEB_BRANCH)
print(WEB_SERVICE_INFO)
print('===============================')


SYNC_SERVICE_INFO = [
    {
        "tag_url": "{0}/e-procure%2Fdb-sync/repository/branches/master".format(gitlab_api_base),
        "image_name": "repo.devpack.cc/e-procure/db-sync",
        "docker_compose_image_variable": 'DBSYNC_IMAGE',
        "repo_id": "e-procure%2Fdb-sync",
        "ref": "master"
    },
    {
        "tag_url": "{0}/e-procure%2Fftp/repository/branches/master".format(gitlab_api_base),
        "image_name": "repo.devpack.cc/e-procure/ftp",
        "docker_compose_image_variable": 'FTP_IMAGE',
        "repo_id": "e-procure%2Fftp",
        "ref": "master"
    },
    {
        "tag_url": "{0}/e-procure%2Fbw-mrp/repository/branches/master".format(gitlab_api_base),
        "image_name": "repo.devpack.cc/e-procure/bw-mrp",
        "docker_compose_image_variable": 'BWMRP_IMAGE',
        "repo_id": "e-procure%2Fbw-mrp",
        "ref": "master"
    },
]

PIPE_SERVICE_INFO = [
    {
        "tag_url": "{0}/e-procure%2Fdata-process/repository/branches/master".format(gitlab_api_base),
        "image_name": "repo.devpack.cc/e-procure/data-process",
        "docker_compose_image_variable": 'DATA_PROCESS_IMAGE',
        "repo_id": "e-procure%2Fdata-process",
        "ref": "master"
    },
    {
        "tag_url": "{0}/e-procure%2Fhealth-monitor/repository/branches/master".format(gitlab_api_base),
        "image_name": "repo.devpack.cc/e-procure/health-monitor",
        "docker_compose_image_variable": 'HEALTH_MONITOR_IMAGE',
        "repo_id": "e-procure%2Fhealth-monitor",
        "ref": "master"
    },
]

DB_SERVICE_INFO = [
    {
        "tag_url": "{0}/e-procure%2Fpostgres/repository/branches/master".format(gitlab_api_base),
        "image_name": "repo.devpack.cc/e-procure/postgres",
        "docker_compose_image_variable": 'POSTGRES_IMAGE',
        "repo_id": "e-procure%2Fpostgres",
        "ref": "master"
    }
]

HAPROXY_CONFIG_PATH = [
    {
        "tag_url": "{0}/e-procure%2Fhaproxy/repository/branches/master".format(gitlab_api_base),
        "image_name": "repo.devpack.cc/e-procure/haproxy",
        "docker_compose_image_variable": 'HAPROXY_IMAGE',
        "repo_id": "e-procure%2Fhaproxy",
        "ref": "master"
    }
]

FLASKDEMO_CONFIG_PATH = [
    {
        "tag_url": "{0}/e-procure%2Fflaskdemo/repository/branches/master".format(gitlab_api_base),
        "image_name": "repo.devpack.cc/e-procure/flaskdemo",
        "docker_compose_image_variable": 'FLASKDEMO_IMAGE',
        "repo_id": "e-procure%2Fflaskdemo",
        "ref": "master"
    }
]

service_definition = [
    # web
    {
        "name": "WEBAPP_CONFIG_PATH",
        "path": "./imageConfig/WEBAPP_IMAGES_LIST.config",
        "info": WEB_SERVICE_INFO
    },
    # db sync相關
    {
        "name": "SYNC_CONFIG_PATH",
        "path": "./imageConfig/SYNC_IMAGES_LIST.config",
        "info": SYNC_SERVICE_INFO
    },
    # kafka相關
    {
        "name": "PIPE_CONFIG_PATH",
        "path": "./imageConfig/PIPE_IMAGES_LIST.config",
        "info": PIPE_SERVICE_INFO
    },
    # 資料庫
    {
        "name": "DB_CONFIG_PATH",
        "path": "./imageConfig/DB_IMAGES_LIST.config",
        "info": DB_SERVICE_INFO
    },
    # 測試用
    {
        "name": "FLASKDEMO_CONFIG_PATH",
        "path": "./imageConfig/FLASKDEMO_IMAGES_LIST.config",
        "info": FLASKDEMO_CONFIG_PATH
    },
    # haproxy
    {
        "name": "HAPROXY_CONFIG_PATH",
        "path": "./imageConfig/HAPROXY_IMAGES_LIST.config",
        "info": HAPROXY_CONFIG_PATH
    }
]

