QiNiuApiMgr = {
    COPY_BYTES_BUFFER = 40 * 1024 * 1024; --40 KB
    AccessKey = "";
    SecretKey = "";
    UploadHost = "";--华东地区
    Bucket = "";
    Host = ""; -- 域名
    voiceDataPath = ""
}
local isInit = false

--初始化七牛云
function QiNiuApiMgr.Init(localPath)
    QiniuApi.COPY_BYTES_BUFFER = QiNiuApiMgr.COPY_BYTES_BUFFER
    QiniuApi.AccessKey = QiNiuApiMgr.AccessKey
    QiniuApi.SecretKey = QiNiuApiMgr.SecretKey
    QiniuApi.UploadHost = QiNiuApiMgr.UploadHost
    QiniuApi.Bucket = QiNiuApiMgr.Bucket
    QiniuApi.Host = QiNiuApiMgr.Host

    QiNiuApiMgr.voiceDataPath = localPath;
    QiniuApi.Init(QiNiuApiMgr.voiceDataPath);
end

--上传七牛云
function QiNiuApiMgr.UploadFileRequest(strfilepath, filename, OnVoiceUploadFileCallback)
    QiniuApi.Upload(strfilepath, filename, OnVoiceUploadFileCallback);
end

--下载七牛云
function QiNiuApiMgr.DownLoadFileRequest(filename, OnVoiceDownFileCallback)
    QiniuApi.Download(filename, OnVoiceDownFileCallback)
end

return QiNiuApiMgr