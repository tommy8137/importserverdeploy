# 注意！！！！qt和prd都不應該做CICD測試，這樣會提早migrate到qt和prd。          
如果一定要測試要修改`dev.env, qt.env, prd.env`這三個檔案的`DATAPROCESS_ENV`參數還有`POSTGRES`相關的參數。    
因為kafka會根據這個參數接收資料，如果沒有改成其他參數，會變成測試機收到資料但是不寫入kafka，這樣會讓正式營運的機器漏資料！！！    
因為migrate做下去會把qt和prd的server用壞！一定要把postgres相關的參數換掉才行！！！！     
