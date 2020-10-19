1. 打版號 

```
export RELEASE_TAG=v0.0(20190000.000-T)  
export PRIVATE_TOKEN=[gitlab token]
# 看要不要寫commit訊息
python ./findDockerImgHelper/create_tag.py
```


2. 跑CICD (QT跑qt branch，PRD跑prd branch)
改CICD的變數之後，跑CICD