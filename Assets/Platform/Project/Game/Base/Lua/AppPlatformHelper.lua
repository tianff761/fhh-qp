--与平台交互帮助类
AppPlatformHelper = {
}

local this = AppPlatformHelper
--是否可以加入房间
local isJoinRoom = true

--窗口变化
function AppPlatformHelper.OnWindowResize()
    LogError(">> AppPlatformHelper.OnWindowResize.")
    SendEvent(CMD.Game.WindowResize)
end

--App的焦点切换
function AppPlatformHelper.OnApplicationFocus(hasFocus)

end

--Unity Pause处理
function AppPlatformHelper.OnApplicationPause(pauseStatus)
    Event.Brocast(CMD.Game.ApplicationPause, pauseStatus)
    if not pauseStatus then
        if UserData.IsLogin() then
            if Network.CheckNetworkIsConnected() then
                this.CheckCode()
            else
                AddMsg(CMD.Game.Reauthentication, this.OnReauthentication)
            end
        end
    end
end

--Android返回键按下
function AppPlatformHelper.OnEscapeKeyDown()
    if not Alert.isOpen then
        Alert.Prompt("是否退出游戏吗？", this.OnExitAppAlertCallback)
    end
end

--退出游戏
function AppPlatformHelper.OnExitAppAlertCallback()
    AppPlatformHelper.QuitGame()
end

--退出游戏，统一退出游戏的方法口
function AppPlatformHelper.QuitGame()
    PlatformHelper.QuitGame()
end

--显示Toast
function AppPlatformHelper.ShowToast(msg)
    msg = tostring(msg)
    if msg ~= nil then
        Toast.Show(msg)
    end
end

--==============================================================================================]
function AppPlatformHelper.OnReauthentication()
    RemoveMsg(CMD.Game.Reauthentication, this.OnReauthentication)
    this.CheckCode()
end

--==================================================原生功能=====================================
--是否显示复制成功（用于清空粘贴板时，不显示提示用）
local isShowCopySucceed = true
--复制文本
function AppPlatformHelper.CopyText(text)
    if text == "" then
        isShowCopySucceed = false
    end
    PlatformHelper.CopyText(text)
end

--复制文本回调
function AppPlatformHelper.CopyTextCallback(result)
    if isShowCopySucceed then
        Toast.Show("复制成功！")
    end
    isShowCopySucceed = true
end

-------------------------------------------获取剪切板文字-------------------------------------------
--获取粘贴板文本
function AppPlatformHelper.GetCopyText(tag)
    PlatformHelper.GetCopyText(tostring(tag))
end

--获取粘贴板文本回调
function AppPlatformHelper.GetCopyTextCallback(result)
    if string.find(result, "\n") ~= nil or string.find(result, "\r") ~= nil then
        return
    end
    result = string.gsub(result, " ", "")
    result = string.gsub(result, "	", "")
    result = string.gsub(result, "{tag=\"1\",text=\"", "")
    result = string.gsub(result, "\"}", "")
    result = string.gsub(result, "\\", "")
    if IsString(result) and not string.IsNullOrEmpty(result) then
        this.CheckGetCopyText(result)
    end
end

--检查是否能获取剪切板的东西
function AppPlatformHelper.CheckIsGetCopyTextOnLobby()
    if GameSceneManager.IsLobbyScene() then
        --检测是否拥有口令,1:获取剪切板时用于验证的tag
        this.GetCopyText(1)
    end
end

function AppPlatformHelper.CheckGetCopyText(str)
    local roomCode = SubStringUTF8(str, 13, 18)
    local num = tonumber(roomCode)
    if IsNumber(num) then
        if (num >= 100000 and num <= 999999) then
            this.CopyText("")
            Alert.Prompt("是否加入房间:" .. num, function()
                BaseTcpApi.CheckAndJoinRoom(roomCode)
            end)
            return
        end
    else
        local type = SubStringUTF8(str, 13, 17)
        if type == "guild" then
            this.CopyText("")
            Global.inviteRoomCode = SubStringUTF8(str, 13, 23)
            coroutine.start(this.HandleInviteCode)
        end
    end
end
-------------------------------------------邀请码-------------------------------------------
function AppPlatformHelper.CheckCode()
    isJoinRoom = true
    --邀请码检测
    this.CheckInviteCode()
    --粘贴板的房间号检测
    if isJoinRoom then
        this.CheckIsGetCopyTextOnLobby()
    end
    isJoinRoom = true
end

--获取邀请码
function AppPlatformHelper.GetRoomCode()
    --获取邀请码
    PlatformHelper.GetRoomCode()
end

--获取邀请码返回
function AppPlatformHelper.GetRoomCodeCallback(result)
    Global.inviteRoomCode = result
    Log(">> AppPlatformHelper.GetRoomCodeCallback > result = " .. result)
end

--检查邀请码
function AppPlatformHelper.CheckInviteCode()
    if GameSceneManager.currGameScene == nil then
        return
    end

    this.GetRoomCode()
    coroutine.start(this.HandleInviteCode)
end

function AppPlatformHelper.HandleInviteCode()
    coroutine.wait(0.5)

    if Global.inviteRoomCode == nil or Global.inviteRoomCode == "" or Global.inviteRoomCode == "empty_room_code" then
        return
    end

    local inviteRoomCode = tostring(Global.inviteRoomCode)
    Global.inviteRoomCode = ""

    local len = string.len(inviteRoomCode)
    if len < 5 then
        PlatformHelper.ClearRoomCode()
        return
    end

    local inviteType = string.sub(inviteRoomCode, 1, 5)

    if inviteType == "club_" then
        local clubId = string.sub(inviteRoomCode, 6)
        --申请加入俱乐部
        -- SendTcpMsg(CMD.Tcp_C2S_CLUB_APPLY_JOIN, {userId = UserData.GetUserId(), clubId = clubId, optionType = 0})
    elseif inviteType == "guild" then
        local guildId = string.sub(inviteRoomCode, 6)
        TeaApi.SendApplyJoinGuild(guildId)  --发送加入公会
    else
        if GameSceneManager.IsLobbyScene() then
            this.HandleInviteRoomCodeAtLobby(inviteRoomCode)
        elseif GameSceneManager.IsRoomScene() then
            this.HandleinviteRoomCodeAtRoom()
        else
            if UserData.IsLogin() and Network.CheckNetworkIsConnected() then
                this.HandleinviteRoomCodeAtLogin(inviteRoomCode)
            else
                return
            end
        end
    end

    PlatformHelper.ClearRoomCode()
end

--处理在大厅时的邀请码
function AppPlatformHelper.HandleInviteRoomCodeAtLobby(inviteRoomCode)
    if string.len(inviteRoomCode) >= 6 then
        local roomNum = tonumber(inviteRoomCode)
        BaseTcpApi.CheckAndJoinRoom(roomNum)
        isJoinRoom = false
    end
end

--处理在房间时的邀请码
function AppPlatformHelper.HandleinviteRoomCodeAtRoom()
    Toast.Show("请在大厅接受房间邀请")
end

--处理在登录界面时的邀请码
function AppPlatformHelper.HandleinviteRoomCodeAtLogin(inviteRoomCode)
    local roomId = UserData.GetRoomId()
    if roomId <= 0 then
        local roomNum = tonumber(inviteRoomCode)
        if string.len(inviteRoomCode) == 6 and roomNum ~= nil then
            BaseTcpApi.CheckAndJoinRoom(roomNum)
            isJoinRoom = false
        end
    end
end
-------------------------------------------获取邀请码End-------------------------------------------
--打开某个APP
function AppPlatformHelper.OpenOtherApp(platformType)
    PlatformHelper.OpenOtherApp(platformType)
end

--打开某个APP返回
function AppPlatformHelper.OpenAppCallback(result)
    local code = tonumber(result)
    if code == nil then
        --Log("返回错误,开启失败")
        return
    end
    if code == -1 then
        --成功了
        return
    end

    if code == PlatformType.WECHAT then
        Alert.Show("请先安装微信")
    elseif code == PlatformType.QQ then
        Alert.Show("请先安装QQ")
    elseif code == PlatformType.ZHIFUBAO then
        Alert.Show("请先安装支付宝")
    end
end


-------------------------------------------电量-------------------------------------------
--获取电量
function AppPlatformHelper.GetBatteryState()
    PlatformHelper.GetBatteryState(1)
end

--获取电量回调
function AppPlatformHelper.GetBatteryStateCallback(state)
    Log(">>>>>>>>>>>>>>>获取到电量：>", state)
    if string.IsNullOrEmpty(state) then
        SendEvent(CMD.Game.BatteryState, 0)
        return
    end
    state = string.gsub(state, "%%", "")
    if not string.IsNullOrEmpty(state) then
        local num = tonumber(state)
        if IsNumber(num) then
            SendEvent(CMD.Game.BatteryState, num)
        end
    else
        SendEvent(CMD.Game.BatteryState, 0)
    end
end

--执行当在房间场景时，每隔20秒获取一次当前电量
local getBatterScheduler = nil
function AppPlatformHelper.StartGetBatteryStateOnRoom()
    if not GameSceneManager.IsRoomScene() then
        return
    end
    if getBatterScheduler ~= nil then
        Scheduler.unscheduleGlobal(getBatterScheduler)
        getBatterScheduler = nil
    end
    this.GetBatteryState()
    getBatterScheduler = Scheduler.scheduleGlobal(function()
        this.GetBatteryState()
    end, 60)
end

function AppPlatformHelper.StopGetBatteryStateOnRoom()
    if getBatterScheduler ~= nil then
        Scheduler.unscheduleGlobal(getBatterScheduler)
        getBatterScheduler = nil
    end
end
-------------------------------------------登录分享-------------------------------------------
--分享回调
function AppPlatformHelper.ShareCallback(result)
    Log(">> Game > ShareCallback > result = ", result)

    SendMsg(CMD.Game.ShareComplete)

    if result == nil then
        -- Toast.Show("分享失败")
        return
    end
    local shareData = JsonToObj(result)

    if shareData == nil then
        -- Toast.Show("分享失败")
        return
    end

    local platformName = ""
    if shareData.platformType == PlatformType.WECHAT then
        platformName = "微信"
    elseif shareData.platformType == PlatformType.XIANLIAO then
        platformName = "闲聊"
    end

    if shareData.code == ShareCode.NoApp then
        Toast.Show("请先安装" .. platformName)
    elseif shareData.code == ShareCode.Cancel then
        -- Toast.Show("您取消了" .. platformName .. "分享")
    elseif shareData.code == ShareCode.Failed then
        Toast.Show(platformName .. "分享失败")
        if shareData.errCode ~= 0 then
            --其他错误信息
            --Log(">> Game > ShareCallback > errCode = " .. shareData.errCode)
        end
    elseif shareData.code == AuthCode.Success then
        -- Toast.Show(platformName .. "分享成功")
    end
end

--授权回调
function AppPlatformHelper.AuthCallback(result)
    Log(">> AppPlatformHelper > AuthCallback > result = ", result)

    if not GameSceneManager.IsLoginScene() then
        Log(">> AppPlatformHelper > AuthCallback > not login scene")
        return
    end

    local authData = JsonToObj(result)

    if authData == nil then
        Toast.Show("授权失败")
        return
    end
    local platformName = ""
    if authData.platformType == PlatformType.WECHAT then
        platformName = "微信"
    elseif authData.platformType == PlatformType.XIANLIAO then
        platformName = "闲聊"
    end
    if authData.code == AuthCode.NoApp then
        Toast.Show("请先安装" .. platformName)
    elseif authData.code == AuthCode.Cancel then
        Toast.Show("您取消了" .. platformName .. "授权")
    elseif authData.code == AuthCode.Failed then
        Toast.Show(platformName .. "授权失败")
        if authData.errCode ~= 0 then
            --其他错误信息
            Log(">> AppPlatformHelper > AuthCallback > errCode = " .. authData.errCode)
        end
    elseif authData.code == AuthCode.Success then
        --授权成功，显示遮罩
        Waiting.Show(platformName .. "登录中...")
    end
end

--登录回调
function AppPlatformHelper.LoginCallback(result)
    Log(">> AppPlatformHelper > LoginCallback > result = ", result)

    if not GameSceneManager.IsLoginScene() then
        Log(">> AppPlatformHelper > LoginCallback > not login scene")
        return
    end

    local userInfo = JsonToObj(result)

    if userInfo == nil then
        Toast.Show("登录失败")
        return
    end

    local platformName = ""
    if userInfo.platformType == PlatformType.WECHAT then
        platformName = "微信"
    elseif userInfo.platformType == PlatformType.XIANLIAO then
        platformName = "闲聊"
    end

    if userInfo.code == ResponseCode.Timeout then
        Toast.Show(platformName .. "登录超时")
        Waiting.ForceHide()
        return
    elseif userInfo.code == ResponseCode.Failed then
        --失败的话，可以还可以进行其他判断，比如网络、或者error字段
        if userInfo.errMsg ~= nil and userInfo.errMsg ~= "" then
            Toast.Show(userInfo.errMsg)
        else
            if userInfo.errCode == 40125 then
                --微信改变
                Alert.Prompt("微信授权登录有更新，请重新下载安装！", this.OnWeChatLoginErrorAlert)
            else
                Toast.Show(platformName .. "登录失败")
                Log(">> AppPlatformHelper > LoginCallback > errCode = " .. userInfo.errCode)
            end
        end
        Waiting.ForceHide()
        return
    end

    if not IsEditorOrPcPlatform() then
        --成功，存储数据，进行登录
        SetLocal(LocalDatas.UserInfoData, result)
    end

    --通知登录界面登录
    SendEvent(CMD.Game.AuthLogin, userInfo)
end

--微信
function AppPlatformHelper.OnWeChatLoginErrorAlert()
    Application.OpenURL(AppConfig.LobbyDownloadUrl)
end

local windowsLoginCallback = nil
--PC登录处理
function AppPlatformHelper.WindowsLogin(wWebViewApi, callback)
    windowsLoginCallback = callback
    wWebViewApi:NavigateCodeUrl()
end

--获取二维码
function AppPlatformHelper.GetWeChatCodeTexturn(imageUrl)
    if not IsNil(windowsLoginCallback) then
        coroutine.start(function()
            local www = WWW(imageUrl)
            coroutine.www(www)
            if www.error == nil and not IsNil(www.texture) then
                if not IsNil(windowsLoginCallback) then
                    windowsLoginCallback(www.texture)
                end
                windowsLoginCallback = nil
            else
                Log(www.error)
            end
        end)
    end
end


--========================================盾================================
--是否初始化盾
local isShieldInit = false
--盾的回调字典，端口转字符串为Key
local shieldCallbackDict = {}

--初始化盾
function AppPlatformHelper.InitShield()
    Log(">> AppPlatformHelper >> InitShield.")
    if not IsNil(AppConfig.ShieldType) and AppConfig.ShieldType > 0 then
        Log(">> AppPlatformHelper >> InitShield > 1.")
        if isShieldInit == false then
            if AppConst.IsInitDun then--C#已经初始化了，就不用再初始化了
                isShieldInit = true
            else
                local data = {}
                data.dataType = Global.DataType.ShieldInit
                data.shieldType = AppConfig.ShieldType
                
                if AppConfig.ShieldType == Global.ShieldType.ChaoJiDun then

                elseif AppConfig.ShieldType == Global.ShieldType.YunDun then
                    data.accessKey = AppConfig.YunDun.accessKey
                    data.uuid = AppConfig.YunDun.uuid
                elseif AppConfig.ShieldType == Global.ShieldType.CloudShield then
                    data.accessKey = AppConfig.CloudShield.accessKey
                end
                isShieldInit = true
                PlatformHelper.HandleData(ObjToJson(data))
            end
        end
    end
end

--获取ip与port
function AppPlatformHelper.GetShieldPort(host, port, callback)
    --Log(">>> AppPlatformHelper >> GetShieldPort >> host = ", host, " port = ", port)
    --这个地方不用判断是否开启了盾，因为在初始化就检测了
    if not isShieldInit then
        callback(host, port)
        return
    end
    local key = tostring(port)
    local data = { host = host, port = port, callback = callback }
    shieldCallbackDict[key] = data

    data = {}
    data.dataType = Global.DataType.ShieldGet
    data.shieldType = AppConfig.ShieldType
    data.key = key
    data.host = host
    data.port = port
    PlatformHelper.HandleData(ObjToJson(data))
end

--数据处理
function AppPlatformHelper.OnHandleDataCallback(content)
    LogError(">> AppPlatformHelper > OnHandleDataCallback > content = ", content)
    local data = JsonToObj(content)
    if data.dataType == Global.DataType.ShieldInit then
        this.HandleShieldInit(data)
    elseif data.dataType == Global.DataType.ShieldGet then
        this.HandleShieldGet(data)
    end
end


--处理盾初始化
function AppPlatformHelper.HandleShieldInit(data)
    if data.code == 0 then
        --初始化成功
        isShieldInit = true
    else
        isShieldInit = false
        Alert.Show("游戏运行错误：" .. data.code, function()
            this.QuitGame()
        end)
    end
end

--处理盾获取
function AppPlatformHelper.HandleShieldGet(data)
    local key = data.key
    local temp = shieldCallbackDict[key]
    if temp ~= nil then
        shieldCallbackDict[key] = nil
        if data.code == 0 then
            temp.callback("127.0.0.1", data.port)
        else
            temp.callback(temp.host, temp.port)
        end
    end
end

--==========================GPS相关=================================
--==                         获取手机是否开启GPS
local checkIsOpenDeviceGPSCallback = nil
--检测手机设备是否开启GPS
function AppPlatformHelper.CheckAndroidIsOpenDeviceGPS(callback)
    checkIsOpenDeviceGPSCallback = callback
    PlatformHelper.GetIsOpenAppGPS()
end

--检测手机是否开启GPS回调
function AppPlatformHelper.GetIsOpenAppGPSCallback(arg)
    Log(">>>> AppPlatformHelper > GetIsOpenAppGPSCallback > ", arg)
    if checkIsOpenDeviceGPSCallback ~= nil then
        checkIsOpenDeviceGPSCallback(arg == "0")
    end
    checkIsOpenDeviceGPSCallback = nil
end

--==                         获取应用是否拥有GPS权限
local checkIsOpenAppGPSCallback = nil
--获取应用是否拥有GPS权限
function AppPlatformHelper.CheckAndroidIsOpenAppGPS(callback)
    checkIsOpenAppGPSCallback = callback
    PlatformHelper.GetIsAppGPSEnable()
end

--获取应用是否拥有GPS权限回调
function AppPlatformHelper.GetIsAppGPSEnableCallback(arg)
    Log(">>>> AppPlatformHelper > GetIsAppGPSEnableCallback > ", arg)
    if checkIsOpenAppGPSCallback ~= nil then
        checkIsOpenAppGPSCallback(arg == "0")
    end
    checkIsOpenAppGPSCallback = nil
end

function AppPlatformHelper.GetOriginGpsCallback(Latitude, Longitude)
    LogError("<color=aqua>Latitude, Longitude</color>", Latitude, Longitude)
    GPSModule.CheckGpsCallback(Latitude, Longitude)
end

--==                         获取应用是否拥有某个权限
--权限太多了，用的时候去百度
local permissionsType = {
    location = "android.permission.ACCESS_FINE_LOCATION",
}

local getIsAppAnyEnableCallback = nil
--获取应用是否拥有某个权限
function AppPlatformHelper.GetIsAppAnyEnable(callback)
    if IsAndroidPlatform() then
        getIsAppAnyEnableCallback = callback
        PlatformHelper.GetIsAppAnyEnable(permissionsType.location)
    end
end

--获取应用是否拥有某个权限回调
function AppPlatformHelper.GetIsAppAnyEnableCallback(arg)
    Log(">>>> AppPlatformHelper > GetIsAppAnyEnableCallback > ", arg)
    if getIsAppAnyEnableCallback ~= nil then
        getIsAppAnyEnableCallback(arg == "0")
    end
    getIsAppAnyEnableCallback = nil
end

--==                         开启app应用详情界面
--开启app应用详情界面
function AppPlatformHelper.OpenAppDetail()
    if IsAndroidPlatform() then
        PlatformHelper.OpenAppDetail()
    end
end

--==                         跳转到手机设置GPS界面
--跳转到手机设置GPS界面
function AppPlatformHelper.OpenDeviceSetting()
    PlatformHelper.OpenDeviceSetting()
end

--截图获取(只有安卓能够直接获取到图片)
function AppPlatformHelper.OnScreenShotListen(imagePath)
    Log(">>>>>>>>>>>>>>>>>> 检测到截图了")
end

--Gps信息回调
function AppPlatformHelper.OnGpsLocation(info)
    --GPSModule.SetGpsData(info)
end

--保存图片到手机相册(传入图片，以及名字)
function AppPlatformHelper.SaveImageToPhone(image, fileName)
    PlatformHelper.SaveImageToPhone(image, fileName)
end

--显示平台原生toast
function AppPlatformHelper.SaveImageResult(content)
    if content == "1" then
        Toast.Show("保存成功")
    else
        Toast.Show("保存失败")
    end
end

function AppPlatformHelper.ShowPlatformToast(content)
    PlatformHelper.ShowPlatformToast(content)
end

----------------------获取相册图片相关
local getImagePathCallback
--获取相册图片路径
function AppPlatformHelper.GetImagePathByPhoto(callback)
    Log(">>>>>>>>>>>>AppPlatformHelper.GetImagePathByPhoto>>>>>>>>>>>>>>>获取相册图片路径")
    getImagePathCallback = callback
    PlatformHelper.GetImagePathByPhoto()
end

--获取相册图片路径回调
function AppPlatformHelper.GetImagePathByPhotoCallback(imagePath)
    Log(">>>>>>>>>>>>AppPlatformHelper.GetImagePathByPhotoCallback>>>>>>>>>>>>>>>获取相册图片路径回调", imagePath)
    if string.IsNullOrEmpty(imagePath) then
        Toast.Show("读取相册图片失败")
        return
    end
    if not IsNil(getImagePathCallback) then
        getImagePathCallback(imagePath)
    end
    getImagePathCallback = nil
end

------------------------上传图片相关
--
----缓存本地地址
local imageLocalPath = Application.persistentDataPath .. "/tempImages/";

--上传图片到资源空间
function AppPlatformHelper.UploadImage(imagePath, callback)
    if string.IsNullOrEmpty(imagePath) then
        return
    end
    local fileName = os.timems()
    local fullFileName = fileName .. ".jpg"
    FileUtils.CheckCrateDir(imageLocalPath)

    --上传前先进行压缩
    ImageHepler.Compress(imagePath, imageLocalPath .. fullFileName)

    Scheduler.scheduleOnceGlobal(function()
        TencentApiMgr.CustomUploadFileRequest("cnwb-1300923411", "/hlcnqp/headimages/", imageLocalPath .. fullFileName, fullFileName, function(code, key)
            Log(">>>>>>>>>>>>>>> code ：", code, " key :", key)
            if tonumber(code) == 0 then
                --上传成功
                if callback ~= nil then
                    callback(fileName)
                    callback = nil
                end
            else
                --上传失败
                Toast.Show("头像上传失败，请稍后再试")
            end
            FileUtils.DeleteFile(imageLocalPath .. fullFileName)
        end)
    end, 0.2)
end