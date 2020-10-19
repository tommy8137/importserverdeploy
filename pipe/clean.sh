#!/bin/bash

readonly HOME="/home/swpc-user"
readonly DATAPROCESS_DIR="${HOME}/dataprocess"
readonly DATAPROCESS_MESSAGE_DIR="${DATAPROCESS_DIR}/Message"
readonly DATAPROCESS_ZIP_DIR="${DATAPROCESS_DIR}/back"
readonly KEEPDAYS="60"
readonly EXPIRETIME="0"
readonly logpath="backuplog"

check_exit_code() {
  local code=$1

  if [ ${code} -gt 0 ]; then
    echo "[fail]"
    cat ${LOG}
    exit ${code}
  elif [ ${code} -eq 0 ]; then
    echo "[ ok ]"
  fi
}

spinner() {
  local pid=$1
  local delay=0.75
  local spinstr='|/-\'
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

check_dir() {
  local DIRECTORY=$1
  local BUK_DIR=$2

  if [ -d "${DIRECTORY}" ] && [ -d "${BUK_DIR}" ]; then
    echo true
  else 
    echo false
  fi
}

remove_expire_file() {
  # local save_date=$(date +%Y-%m-%d)
  local save_date=$(date -d "$(date +%Y-%m-%d)-1 day" +%Y-%m-%d)
    
  mkdir -p ${DATAPROCESS_ZIP_DIR}/${save_date}
  # mkdir -p ${save_date}_temp/

  for F in $(find ${DATAPROCESS_MESSAGE_DIR}/${save_date} -mindepth 1 -maxdepth 1 -type d) ; do
    find_expire_files $F ${F#$DATAPROCESS_DIR/}
  done

  remove_temp
  remove_date_dir $save_date
}

find_expire_files() {
  # local save_date=$(date +%Y-%m-%d)
  local save_date=$(date -d "$(date +%Y-%m-%d)-1 day" +%Y-%m-%d)
  local dir=$1
  local temp_dir=${save_date}_temp/$2
  
  {
    # echo $dir
    topic=${dir#$DATAPROCESS_MESSAGE_DIR/$save_date/}

    for P in $(find ${dir} -mindepth 1 -maxdepth 1 -type d) ; do
      # find ${dir} -type f -print -exec sh -c "mkdir -p $temp_dir && mv {} $temp_dir" \;
      partition=${P#$DATAPROCESS_MESSAGE_DIR/$save_date/$topic/}
      echo $dir $temp_dir $partition
      find ${dir}/${partition} -type f -print -exec sh -c "mkdir -p $temp_dir/${partition} && mv {} $temp_dir/${partition}" \;
    done
    # find ${dir} -type f -print -exec sh -c "mkdir -p $temp_dir && mv {} $temp_dir" \;
    # topic=$(echo $temp_dir | cut -d/ -f4)
    zip_message_move $topic $save_date
  }&
  spinner $!
  wait $!
}

zip_message_move() {
  local topic=$1
  local save_date=$2

  echo "========= zip and move ==========="
  {
    echo "========= zip and move ==========="
    cd ${save_date}_temp/Message/${save_date}
    zip -r ${topic}_DataProcess.zip ./*
    mv ${topic}_DataProcess.zip ${DATAPROCESS_ZIP_DIR}/${save_date}/
    rm -rf ${topic}
  } >> $logpath &
  spinner $!
  wait $!
}

remove_temp() {
  # local save_date=$(date +%Y-%m-%d)
  local save_date=$(date -d "$(date +%Y-%m-%d)-1 day" +%Y-%m-%d)
  {
    rm -rf ${save_date}_temp/ 
  }&
  spinner $!
  wait $!
}

remove_expire_zip() {
  echo "======== remove expire zip from ${DATAPROCESS_ZIP_DIR} =====" >> $logpath
  {
    find ${DATAPROCESS_ZIP_DIR}/ -mtime +${KEEPDAYS} -type f -print -delete
  } >> $logpath &
  spinner $!
  wait $!
}

remove_date_dir(){
  remove_date=$1
  rm -rf ${DATAPROCESS_MESSAGE_DIR}/${remove_date}
}
##
# main()
##
main() {
  
  if [ $(check_dir ${DATAPROCESS_MESSAGE_DIR} ${DATAPROCESS_ZIP_DIR}) = "true" ]; then
    echo "=== $(date +%Y-%m-%d) ===" >> $logpath
    remove_expire_file
    remove_expire_zip
    echo "========= done ===========" >> $logpath
  else
    echo "[ERROR] without dir" 
  fi
}
main