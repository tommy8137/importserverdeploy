# 每個月(release前)要把bwmrp的檔案搬到QT和SIT讓客戶可以測試

# 切到OA LAN進入PRD機器
```bash
# 建立資料夾
rm -rf /home/swpc-user/tmpBWMrpFile
mkdir /home/swpc-user/tmpBWMrpFile
# 切成root
sudo -i
# 進到放mrp檔案的路徑找到最新的檔案
cd /project/ftp/epuser/
find . -type f | xargs ls -ltr | tail -n 1 | awk -F './' '{print $NF}' | xargs -I{} cp {} /home/swpc-user/tmpBWMrpFile/
# 確認檔案有搬過去而且是最新日期
ls -al /home/swpc-user/tmpBWMrpFile
# 改權限
chown -R swpc-user:swpc-user /home/swpc-user/tmpBWMrpFile
```

# 切到RD LAN，進入cicd runner (192.168.101.58)，這台可以同時連OA和RD Lan
```bash
# 重新建立資料夾
rm -rf /home/swpc-user/tmpBWMrpFile
mkdir /home/swpc-user/tmpBWMrpFile
ls -al /home/swpc-user/tmpBWMrpFile
# 把檔案scp回來 /home/swpc-user/tmpBWMrpFile
scp -r swpc-user@10.34.3.106:/home/swpc-user/tmpBWMrpFile/* /home/swpc-user/tmpBWMrpFile
ls -al /home/swpc-user/tmpBWMrpFile
# 把檔案放到sit(192.168.100.207)和pvt(192.168.100.209) 
scp -r ./tmpBWMrpFile/* swpc-user@192.168.100.207:/home/swpc-user/tmpBWMrpFile
scp -r ./tmpBWMrpFile/* swpc-user@192.168.100.209:/home/swpc-user/tmpBWMrpFile
```

# 切到207 和209
```bash
# 切成root
sudo -i
# 把權限改成ftp
chown -R ftp:ftp /home/swpc-user/tmpBWMrpFile/*
ls -al /home/swpc-user/tmpBWMrpFile/
# 把檔案搬到對的位置
mv /home/swpc-user/tmpBWMrpFile/* /project/ftp/epuser/
ls -al /project/ftp/epuser/
```


## 立即執行
```bash
# 改config執行時間
docker exec -it wiprocure_bw_mrp sh
vi config.js
'''
// 禮拜幾，幾點，幾分
  time: {
    dayOfWeek: 4,
    dailyHour: 09,
    dailyMinute: 20,
  },
'''


# 重啟服務
cd WiEProcureV/sync/
bash manage.sh 7 "restart bwMrp"

# 看log，時間到有沒有執行
docker logs -f wiprocure_bw_mrp 

# 如果有執行再把它改回來
# 改config執行時間
docker exec -it wiprocure_bw_mrp sh
vi config.js
'''
// 禮拜幾，幾點，幾分
  time: {
    dayOfWeek: 3,
    dailyHour: 0,
    dailyMinute: 1,
  },
'''
# 重啟服務
cd WiEProcureV/sync/
bash manage.sh 7 "restart bwMrp"
```

