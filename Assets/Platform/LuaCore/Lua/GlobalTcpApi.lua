--全局Tcp监听处理
GlobalTcpApi = {}
local this = GlobalTcpApi

function GlobalTcpApi.Init()
    AddEventListener(CMD.Game.OnConnected, this.OnGameConnected)
    --
    AddEventListener(CMD.Tcp.S2C_Login, this.OnLogin)
    AddEventListener(CMD.Tcp.Push_OtherLogin, this.OnPushOtherLogin)
    AddEventListener(CMD.Tcp.Push_SystemTips, this.OnSystemTips)
    AddEventListener(CMD.Tcp.Push_SystemError, this.OnPushSystemError)
    --
    -- Network.RegisterTimeOutProtocal(CMD.Tcp.C2S_Login, CMD.Tcp.S2C_Login)
end

--================================================================
--
--处理网络数据
function GlobalTcpApi.HandleNetworkData(cmd, jsonObj)
    if not IsNumber(jsonObj.code) then
        Alert.Show("严重数据错误，将回到登录界面", this.OnReloginAlert, nil, AlertLevel.System)
        return
    end

    if jsonObj.code == SystemErrorCode.SystemError10001 then
        Alert.Show("数据错误，请重新登录", this.OnReloginAlert, nil, AlertLevel.System)
    elseif jsonObj.code == SystemErrorCode.FengHao10018 then
        --info，封号信息
        --acDueTime，封号结束时间
        --处理封号
        Network.Disconnect(true)
        local msg = nil
        if jsonObj.data ~= nil and jsonObj.data.acDueTime ~= nil then
            --时间转换是用的秒单位，减一秒是用于显示前一天
            msg = "此账号涉嫌违规操作，被封禁至" .. tostring(os.date("%Y年%m月%d日 %H时%M分%S秒", jsonObj.data.acDueTime / 1000 - 1))
        else
            msg = SystemError.GetText(SystemErrorCode.FengHao10018)
        end
        Alert.Show(msg, this.OnReloginAlert, nil, AlertLevel.System)
    else
        --分派事件出去
        SendMsg(cmd, jsonObj)
    end
end

--回到登录提示
function GlobalTcpApi.OnReloginAlert()
    Waiting.ForceHide()
    SendEvent(CMD.Game.LogoutAndOpenLogin)
end

--直接退出应用提示
function GlobalTcpApi.OnDirectQuitAlert()
    AppPlatformHelper.QuitGame()
end

--退出应用提示
function GlobalTcpApi.OnQuitAppAlert()
    SendEvent(CMD.Game.LogoutAndQuitApp)
end

--获取Base资源版本号数值
function GlobalTcpApi.GetBaseVersion()
    local temp = VersionManager.Instance:GetGameLocalVersionNum("Base")
    if temp < 1 then
        return 10001
    else
        return temp
    end
end

--================================================================
--
--处理系统提示
function GlobalTcpApi.OnSystemTips(data)
    if data.code == SystemTipsErrorCode.SysError then
        Network.Disconnect(true)
        Alert.Show("应用发生异常，请重新打开应用", this.OnDirectQuitAlert, nil, AlertLevel.System)
    elseif data.code == SystemTipsErrorCode.LoginInvalidByOtherLogin then
        Network.Disconnect(true)
        Alert.Prompt("其他设备正在登录您的账号，请您重新登录！", this.OnReloginAlert, this.OnQuitAppAlert, nil, nil, AlertLevel.System,"警告")
    end
end

--处理系统错误
function GlobalTcpApi.OnPushSystemError(data)
    if data.code == SystemErrorCode.ServerMaintenance then
        --服务器维护中
        Network.Disconnect(true)
        Alert.Show("服务器维护中，请稍后", this.OnReloginAlert, nil, AlertLevel.System)
    end
end

--================================================================
--
--网络连接上，发送登录
function GlobalTcpApi.OnGameConnected()
    local data = {
        openId = GlobalData.platform.openId,
        uuId = GlobalData.platform.unionId,
        userName = GlobalData.platform.nickName,
        sex = GlobalData.platform.gender,
        imgurl = GlobalData.platform.headUrl,
        dev = GlobalData.platform.deviceType,
        devId = GlobalData.platform.deviceId,
        isUpdate = GlobalData.platform.isUpdateHead,
        appVer = AppConst.AppVerNum,
        version = this.GetBaseVersion(),
        accountType = GlobalData.platform.accountType,
        phoneNum = GlobalData.platform.phoneNum,
        pwd = GlobalData.platform.password,
        ip = UserData.GetIP()
    }
    SendTcpMsg(CMD.Tcp.C2S_Login, data)
end

--发送登录数据  dev:DeviceType的枚举
function GlobalTcpApi.SendLogin()
    Network.Connect()
end

--处理登录协议
function GlobalTcpApi.OnLogin(data)
    -- Waiting.ForceHide()
    --重连登录返回后才隐藏网络层Waiting，第一次登录会在大厅关闭
    if UserData.IsLogin() then
        Network.HideWaiting()
    end

    if data.code == 0 then
        --成功后，需要把该值设置0
        GlobalData.platform.isUpdateHead = 0

        UserData.userId = data.data.userId
        UserData.token = data.data.token

        UserData.SetRoomCard(data.data.fk)
        UserData.SetGift(data.data.gift)
        UserData.SetGold(data.data.gold)
        UserData.SetRoomId(data.data.roomId)
        UserData.SetName(data.data.username)
        UserData.SetGender(data.data.sex)
        UserData.SetHeadUrl(data.data.imgurl)
        UserData.SetDeviceType(data.data.dev)
        -- UserData.SetFrameId(data.data.txk)
        UserData.SetBindPhone(data.data.phonenum)
        UserData.SetGuildId(data.data.guildId)
        UserData.SetLoginTime(data.data.time)
        UserData.SetTaskType(data.data.isReceive == 1)
        --有房间号，表示断线重连进入房间
        UserData.SetIsReconnectTag(data.data.roomId > 0)
        --设置头像是否处于审核中
        UserData.SetHeadAuditing(data.data.iConAuditState == 1)

        --登录成功后通知网络层，设置登录标识
        Network.SetLogin()
        --
        if UserData.IsLogin() then
            SendEvent(CMD.Game.Reauthentication)
        else
            SendEvent(CMD.Game.Login)
        end
        UserData.SetIsLogin(true)

    elseif data.code == SystemErrorCode.LowVersion then
        --版本号过低，需要更新，断掉网络
        Network.Disconnect(true)
        Alert.Show(SystemError.GetText(data.code), this.OnQuitAppAlert, nil, AlertLevel.System)
    elseif data.code == SystemErrorCode.PhoneError10101 then
        Network.Disconnect(true)
        Alert.Show(SystemError.GetText(data.code), this.OnReloginAlert, nil, AlertLevel.System)
    elseif data.code == SystemErrorCode.PhoneUnregistered10102 then
        Network.Disconnect(true)
        Alert.Show(SystemError.GetText(data.code), this.OnReloginAlert, nil, AlertLevel.System)
    elseif data.code == SystemErrorCode.PhonePasswordError10103 then
        Network.Disconnect(true)
        Alert.Show(SystemError.GetText(data.code), this.OnReloginAlert, nil, AlertLevel.System)
    else
        Network.Disconnect(true)
        Waiting.ForceHide()
        Alert.Show(SystemError.GetText(data.code), nil, nil, AlertLevel.System)
    end
end

--登录顶号
function GlobalTcpApi.OnPushOtherLogin(data)
    Network.Disconnect(true)
    Alert.Prompt("其他设备正在登录您的账号，请您重新登录！", this.OnReloginAlert, this.OnQuitAppAlert, nil, nil, AlertLevel.System,"警告")
end