TencentApiMgr = {
    appid = "1300923411";--设置腾讯云账户的账户标识 APPID
    region = "ap-chengdu"; --设置一个默认的存储桶地域
    secretId = "AKIDra3FCsu4oKdgW752MSKr9C0Y7RXOIapp"; --"云 API 密钥 SecretId";
    secretKey = "ugEtM5aswmeHbgYCZMvRlrnVzkbH0Seb"; --"云 API 密钥 SecretKey";
    bucket = "cnvoice-1300923411"; --存储桶，格式：BucketName-APPID
    bucketPath = "/hlcnqp/voice/";
    voiceDataPath = "";
}

local this = TencentApiMgr

local isInit = false

--初始化腾讯云
function TencentApiMgr.Init(localPath)
    this.voiceDataPath = localPath .. "Tencent/"
    if isInit then
        TencentBucketApi.UninitTecentBucket()
    end
    isInit = true
    TencentBucketApi.InitTecentBucket(this.region, this.secretId, this.secretKey, this.bucket);
end

--上传腾讯云
function TencentApiMgr.UploadFileRequest(localfilePath, filename, OnVoiceUploadFileCallback)
    TencentBucketApi.UploadFile(this.bucketPath, filename, localfilePath, OnVoiceUploadFileCallback)
end

--下载腾讯云
function TencentApiMgr.DownLoadFileRequest(filename, OnVoiceDownFileCallback)
    TencentBucketApi.DownloadFile(this.bucketPath, filename, this.voiceDataPath, filename, OnVoiceDownFileCallback)
end

--获取语音缓存地址
function TencentApiMgr.GetVoiceDataPath()
    return this.voiceDataPath
end


----------------------------------------------
--自定义上传腾讯云bucket:空间名,bucketPath:空间前缀,localfilePath:文件路径(文件目录+文件名),filename:文件名,OnVoiceUploadFileCallback:上传回调
function TencentApiMgr.CustomUploadFileRequest(bucket, bucketPath, localfilePath, filename, OnVoiceUploadFileCallback)
    Log(">>>>>TencentApiMgr.CustomUploadFileRequest>>>>>>")
    if isInit then
        TencentBucketApi.UninitTecentBucket()
    end
    isInit = true

    TencentBucketApi.InitTecentBucket(this.region, this.secretId, this.secretKey, bucket);

    Scheduler.scheduleOnceGlobal(function()
        TencentBucketApi.UploadFile(bucketPath, filename, localfilePath, OnVoiceUploadFileCallback)
    end, 0.5)
end

return TencentApiMgr