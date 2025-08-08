AppConfig = {}

--防护盾类型None表示不开
AppConfig.ShieldType = Global.ShieldType.None--Global.ShieldType.YunDun

--语音上传类型
AppConfig.VoiceUpType = Global.VoidUploadType.QiNiu

--是否是IOS审核版
AppConfig.IsShenHeVersion = false

--登录类型
AppConfig.LoginType = LoginType.Test

--是否开启自动登录
AppConfig.IsAutoLogin = true

--是否开启日志
AppConfig.IsLogEnabled = true

--是否开启代码调试，作用是预处理面板脚本
AppConfig.IsScriptDebugEnabled = false

--多点触碰
AppConfig.MultiTouchEnabled = false

--是否开启Reporter
AppConfig.IsReporterEnabled = false

AppConfig.WeChatAppId = "wxe309b5962d55d781"
AppConfig.WeChatAppSecret = "1ccf96314b1c07b9795fd442f753da75"

---原机ID SourceID 卡号
AppConfig.ChaoJiDunYuanJiMa = {
    serverTcp = "",
    card = "",
}

--云盾
AppConfig.YunDun = {
    accessKey = "",
    uuid = ""
}

--云盾2
AppConfig.CloudShield = {
    accessKey = ""
}

AppConfig.ResourceFolderName = "Config"
--
--------------------------------------------------------------服务器地址配置---------------------------------------------------------
--
--================================================================
--
--修改配置时，只需要修改正式配置，即正式服务器列表配置的IP和回放Url，然后就是账号的Url：AppConfig.AccountUrl，只需要修改这2个地方就可以修改为正式的了
--
--================================================================
--正式服务器列表
AppConfig.ServerList = {
    { name = "正式服", address = "6xuqep4g.cnmnmsl.top", port = 6092, playbackPort = 8092, PlaybackDataUrl = "http://5gzb8p43.cnmnmsl.top:8092/playback/record/" },
}

--测试服务器列表
AppConfig.TestServerList = {
    -- { name = "内网测试服", address = "6xuqep4g.cnmnmsl.top", port = 6092, playbackPort = 8092, PlaybackDataUrl = "http://5gzb8p43.cnmnmsl.top:8092/playback/record/" },
    { name = "正式服", address = "218.244.136.238", port = 6090, playbackPort = 8090, PlaybackDataUrl = "http://3.0.147.160:8090/record/" },
}
--账号Http API地址
AppConfig.AccountUrl = { name = "正式", address = "218.244.136.238", port = 6200 }
--AppConfig.AccountUrl = { name = "正式", address = "192.168.10.206", port = 6200 }
--账号测试Http API地址
--内网测试服
--AppConfig.AccountTestUrl = "http://192.168.10.104:18200/?type=reg&cmd="
---------------------------------------------------------------------------------------------------------------------------------------
--大厅下载链接
AppConfig.LobbyDownloadUrl = ""
--游戏下载分享链接
AppConfig.GameDownloadUrls = {}

--分享的图片下载链接
AppConfig.ShareImageDwonUrl = ""

--错误日志上传地址
AppConfig.LogUploadUrl = ""

--请求俱乐部二维码
AppConfig.ReqGuildCode = "http://www.xxx.com/getXXLCode"

--微信ID
AppConfig.WeChatID1 = "xxx01"

--头像下载地址
AppConfig.headDownUrl = "https://xxx.com/head/"
--聊天图片下载地址
AppConfig.chatImageDownUrl = "https://xxx.com/chat/"

--获取下载链接
function AppConfig.GetDownUrl()
    if GameSceneManager.currGameScene.type == GameSceneType.Lobby then
        return AppConfig.LobbyDownloadUrl
    end

    if GameSceneManager.currGameScene.type == GameSceneType.Room then
        local url = AppConfig.GameDownloadUrls[GameManager.GetCurGameType()]
        if url ~= nil then
            return url
        else
            return AppConfig.LobbyDownloadUrl
        end
    end
end

--获取账号API地址
function AppConfig.GetAccountUrl(callback)
    if AppConfig.LoginType == LoginType.Test then
        if not IsNil(callback) then
            callback(AppConfig.AccountTestUrl)
        end
    else
        local url = "http://" .. AppConfig.AccountUrl.address .. ":" .. AppConfig.AccountUrl.port .. "/?type=reg&cmd="
        callback(url)
    end
end

--获取回放地址
function AppConfig.CheckGetPlaybackUrl(url, callback)
    if AppConfig.LoginType == LoginType.Test then
        if not IsNil(callback) then
            callback(url)
        end
    else
        if AppConfig.ShieldType == Global.ShieldType.None or GlobalData.ServerConfigData.playbackPort == nil then
            if not IsNil(callback) then
                callback(url)
            end
        else
            AppPlatformHelper.GetShieldPort(url, GlobalData.ServerConfigData.playbackPort, function(mIp, mPort)
                if not IsNil(callback) then
                    local url = "http://" .. mIp .. ":" .. mPort .. "/record/"
                    callback(url)
                end
            end)
        end
    end
end