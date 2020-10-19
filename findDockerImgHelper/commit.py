# -*- coding: utf-8 -*
import requests
import os, sys
from config import service_definition


DEBUG=False

# 不做DEBUG，就把FLASKDEMO_CONFIG_PATH的資料刪掉
if DEBUG: 
    SERVICE_DEFINITION = service_definition
else:
    SERVICE_DEFINITION = [x for x in service_definition if not ('FLASKDEMO_CONFIG_PATH' == x.get('name'))]


try:  
   PRIVATE_TOKEN = os.environ['PRIVATE_TOKEN']
except KeyError: 
   print("Please set the environment variable PRIVATE_TOKEN")
   sys.exit(1)


def write_config_helper(service_info, write_to, env, release_tag):
    lines =[]
    headers = {'PRIVATE-TOKEN': PRIVATE_TOKEN}
    if env == "dev":
        for item in service_info:
            r1 = requests.get(item['tag_url'], headers=headers)
            web_commit = r1.json()['commit']['id']
            lines.append("{0}={1}:{2}".format(
                item['docker_compose_image_variable'],
                item['image_name'],
                web_commit[0:5]
            ))

    if env == "qt" or env == "prd" or env == 'qas':
        for item in service_info:
            r1 = requests.get('https://gitlab.devpack.cc/api/v4/projects/{0}/repository/tags/{1}'.format(item["repo_id"], release_tag), headers=headers)
            print(r1.json())
            web_commit = r1.json()["commit"]["id"]
            lines.append("{0}={1}:{2}".format(
                item['docker_compose_image_variable'],
                item['image_name'],
                web_commit[0:5]
            ))

    if os.path.exists('./{0}'.format(write_to)):
        os.remove('./{0}'.format(write_to))

    with open('./{0}'.format(write_to), 'a') as f1:
        for docker_image in lines:
            f1.write(docker_image + os.linesep)


def write_lpp_config():
    # lpp 是認最新的tag來作部署的
    lines =[]
    headers = {'PRIVATE-TOKEN': PRIVATE_TOKEN}
    lpp_config = {
        "image_name": "repo.devpack.cc/e-procure/lpp",
        "docker_compose_image_variable": 'LPP_IMAGE',
        "repo_id": "e-procure%2Flpp",
    }
    url = "https://gitlab.devpack.cc/api/v4/projects/{0}/repository/tags".format(lpp_config["repo_id"])
    r1 = requests.get(url, headers=headers, params={'order_by': 'updated', 'sort': 'desc' })
    if (r1.status_code != 200):
        sys.exit(1)
    lpp_newest_tag_name = r1.json()[0]['name']
    lines.append("{0}={1}:{2}".format(
        lpp_config['docker_compose_image_variable'],
        lpp_config['image_name'],
        lpp_newest_tag_name
    ))
    write_to = "./imageConfig/BIGDATA_IMAGES_LIST.config"
    print('lpp_newest_tag_name: {0}'.format(lpp_newest_tag_name))
    if os.path.exists('./{0}'.format(write_to)):
        os.remove('./{0}'.format(write_to))

    with open('./{0}'.format(write_to), 'a') as f1:
        for docker_image in lines:
            f1.write(docker_image + os.linesep)


def gen_release_docs(use_env, release_tag):
    '''
    產生一份文件描述這次所有服務使用的tag資訊
    '''
    if os.path.exists('./imageConfig/TM_USE.txt'):
        os.remove('./imageConfig/TM_USE.txt')

    with open('./imageConfig/TM_USE.txt', 'a') as f1:
        f1.write("******************************************" + os.linesep)
        f1.write("**         RELEASE_TAG: {0}           ".format(release_tag) + os.linesep)
        f1.write("**         ENV_FILE: {0}              ".format(use_env) + os.linesep)
        f1.write("******************************************" + os.linesep)
        f1.write(os.linesep)
        f1.write(os.linesep)
        for item in SERVICE_DEFINITION:
            f1.write("================{}================".format(item['name']) + os.linesep)
            with open(item['path']) as f:
                content = f.readlines()
                for line in content:
                    f1.write(line)
            f1.write(os.linesep)
            f1.write(os.linesep)
            f1.write(os.linesep)

        ####################################### Lpp 另外處理 #######################################
        f1.write("================{}================".format("BIGDATA_CONFIG_PATH") + os.linesep)
        with open("./imageConfig/BIGDATA_IMAGES_LIST.config") as f:
            content = f.readlines()
            for line in content:
                f1.write(line)
        f1.write(os.linesep)
        f1.write(os.linesep)
        f1.write(os.linesep)
        ####################################### Lpp 另外處理 END #######################################

def main(use_env, release_tag):
    '''
    dev環境是取各個repo的latest的git commit hash來部署
    qt環境是取各個repo的指定的某個tag對應到的git commit hash來部署
    prd環境是取各個repo的指定的某個tag對應到的git commit hash來部署
    qas環境是取各個repo的指定的某個tag對應到的git commit hash來部署
    '''
    if use_env == 'dev.env':
        for item in SERVICE_DEFINITION:
            write_config_helper(item["info"], item["path"], "dev", release_tag)
    if use_env == 'qt.env':
        for item in SERVICE_DEFINITION:
            write_config_helper(item["info"], item["path"], "qt", release_tag)
    if use_env == 'prd.env':
        for item in SERVICE_DEFINITION:
            write_config_helper(item["info"], item["path"], "prd", release_tag)
    if use_env == 'qas.env':
        for item in SERVICE_DEFINITION:
            write_config_helper(item["info"], item["path"], "qas", release_tag)

    ####################################### Lpp 另外處理 #######################################
    write_lpp_config()
    ####################################### Lpp 另外處理 END #######################################
    

'''
export PRIVATE_TOKEN=[GITLAB-API-TOKEN]

使用方法：python ./findDockerImgHelper/commit.py [enf-file-name] [git-release-tag]
[enf-file-name]: dev.env | qt.env | prd.env | qas.env
[git-release-tag]: 在dev環境不會用到，在qt和prd環境會依據此tag去抓取對應到的git commit，有了git commit可以再對應到docker image
ex: $ python commit.py dev.env v2.0_test
'''

use_env = sys.argv[1] if len(sys.argv) > 1 else 'dev.env'
release_tag_name = sys.argv[2] if len(sys.argv) > 2 else 'testing_tag'
main(use_env, release_tag_name)
gen_release_docs(use_env, release_tag_name)