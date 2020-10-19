# -*- coding: utf-8 -*
import requests
import os, sys
from config import service_definition

'''
step1:
   export RELEASE_TAG=[版號]
   # ex: export RELEASE_TAG=20190318_ttt_
   export PRIVATE_TOKEN=[gitlab token]
step2:
   python ./findDockerImgHelper/create_tag.py
'''

# TAG_NAME = '20190318_ttt_'

try:  
   TAG_NAME = os.environ['RELEASE_TAG']
except KeyError: 
   print("Please set the environment variable RELEASE_TAG")
   sys.exit(1)

try:  
   PRIVATE_TOKEN = os.environ['PRIVATE_TOKEN']
except KeyError: 
   print("Please set the environment variable PRIVATE_TOKEN")
   sys.exit(1)



for definition in service_definition:
    if "info" in definition:
        for info_item in definition["info"]:
            try:     
                headers = {'PRIVATE-TOKEN': PRIVATE_TOKEN}
                url = "https://gitlab.devpack.cc/api/v4/projects/{0}/repository/tags".format(info_item["repo_id"])
                r1 = requests.post(url, 
                headers=headers, 
                data = {
                    'tag_name': TAG_NAME, 
                    'ref': info_item["ref"], 
                    'message': 'test', 
                    'release_description': 'test'
                })
                print("url {0}. response status_code: {1}, response: {2}".format(url, r1.status_code, r1.json()))
                if (r1.status_code != 201):
                    sys.exit(1)
            except Exception as e:
                print("except")
                print(e)