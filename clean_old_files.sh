#! /bin/bash

# 加入 shopt -s -o nounset，要求必須要事先定義（或宣告）變數，才可以使用
shopt -s -o nounset
BASEDIR=$(dirname "$0")
DestDir=$BASEDIR

# usage bash ./clean_old_files.sh [service-name] [release-tag]
# ex: bash ./clean_old_files.sh pipe 2019_dev
# ex: bash ./clean_old_files.sh web 2019_dev
MATCHING_RULES=WiEProcure__${1}__
MATCHING_FILE_TAG=WiEProcure__${1}__${2}.tar.gz

echo "------------------- delete old package -------------------"
for file in $DestDir/${MATCHING_RULES}*.tar.gz
do 
    if [ $file = $DestDir/$MATCHING_FILE_TAG ]
    then
        echo "do not delete ${file}"
    else
        echo "delete $file"
        rm $file
    fi
done
echo "------------------- delete old package DONE.-------------------"
# A=find . ! -name $MATCHING_FILE_TAG -type f # -exec rm -f {} +
# # B="find . -type f -name \"WiEProcure__pipe__*.tar.gz'\""

