Network = {
    ----------------------------------
    isUseDun = false,
    ----------登录相关--------
    --是否登录，登录后才能进行心跳发送，网络只要断了，登录就失效
    isLogin = false,
    --是否网络连接，用于方法使用变量
    isConnected = false,
    --是否可以检测网络，包括心跳，主动断开网络就不进行检测
    isCanCheckNetwork = false,
    --发送登录协议时间，用于判断登录是否超时处理，单位毫秒
    lastSendLoginTime = 0,
    ----------连接相关--------
    --连接网络检测计数器
    connectCheckTimer = nil,
    --连接次数计数
    connectCount = 0,
    --连接时间
    connectTime = 0,
    ----------------------------------
    ----------心跳相关--------
    --是否显示心跳日志
    isHeartbearLog = true,
    --是否发送了心跳
    isHeartbeatSend = false,
    --发送心跳时间，单位毫秒
    heartbeatLastSendTime = 0,
    --接收心跳时间，单位毫秒
    heartbeatLastRecvTime = 0,
    --心跳检测发送时间，用于处理发送间隔
    heartbeatLastCheckTime = 0,
    ----------------------------------
    ----------ping值相关--------
    --ping值Timer
    checkPingTimer = nil,
    --ping值检测时心跳发送时间
    pingCheckSendTime = 0,
    --ping值的间隔
    pingInterval = 200,
    --ping值的时间差
    pingDiffTime = 0,
    --ping值的检测时间
    pingCheckTime = 0,
    ----------------------------------
    ----------服务器信息相关--------
    --服务器地址
    serverIp = "",
    --服务器端口
    serverPort = 0,
    ----------------------------------
    ----------协议超时相关--------
    --注册的超时协议，key:发送协议，value:封装对象
    timeOutProtocal = {},
    ----------------------------------
    ----------其他--------
    --App暂停时间，单位毫秒
    appPauseTimems = 0,
}

local this = Network

--连接最大次数
local ConnectMaxTimes = 5
--心跳发送时间ms
local HeartbeatSendInterval = 2675
--心跳检测时间ms
local HeartbeatCheckInterval = 5675
--登录超时时间，毫秒
local LoginTimeoutTime = 5000
--协议超时时间，毫秒
local ProtocalTimeoutTime = 8000

--临时毫秒时间
local tempTimems = 0
--临时秒时间
local tempTime = 0
--临时的连接日志时间
local tempConnectLogTime = 0

------------------------------------------------------------------
--
--1.检测网络是否连接
--2.在网络连接的情况下检测心跳
--
------------------------------------------------------------------
--
--网络初始化
function Network.Init()
    AddMsg(CMD.Game.ApplicationPause, this.OnApplicationPause)
    --协议超时检测
    Scheduler.scheduleGlobal(this.InternalCheckProtocalTimeout, 1)
    --心跳发送检测
    Scheduler.scheduleGlobal(this.InternalCheckAndSendHeartbeat, 2)
    --网络检测
    Scheduler.scheduleGlobal(this.OnInternalNetworkCheckTimer, 0.2)
    --启动网络Socket连接检测
    this.StartCheckConnectTimer()

    this.ReconnectNetWork = function()
        networkMgr:Close()
        networkMgr:Connect()
        --Scheduler.unscheduleGlobal(this.Timer)
        --this.Timer = Scheduler.scheduleOnceGlobal(this.RequestNewConfigTxt, 2)
    end
end

--
function Network.OnApplicationPause(pauseStatus)
    Log(">> Network.Init > 后台切换 > pauseStatus, isLogin > ", pauseStatus, this.isLogin)
    if this.isLogin then
        if pauseStatus then
            this.appPauseTimems = os.timems()
        else
            --切出桌面时间超过指定时间就直接断开网络，然后等待重连
            if os.timems() - this.appPauseTimems > 3000 then
                this.Disconnect()
            end
        end
    end
end

--网络检测
function Network.OnInternalNetworkCheckTimer()
    if this.isCanCheckNetwork then
        --检测网络是否连接上，检测登录是否超时，检测心跳是否超时
        if not this.InternalCheckNetworkIsConnected() then
            this.isGetPort = false
            this.InternalConnect()
        end
    end
end

----------------------------------
--
--内部检测发送心跳
function Network.InternalCheckAndSendHeartbeat()
    tempTimems = os.timems()
    if tempTimems - this.heartbeatLastCheckTime > HeartbeatSendInterval then
        this.SendHeartbeat(tempTimems)
    end

end

--发送心跳
function Network.SendHeartbeat(currMs)
    if currMs == nil then
        currMs = os.timems()
    end
    this.isHeartbeatSend = true
    this.heartbeatLastCheckTime = currMs
    if this.pingCheckSendTime == 0 then
        this.pingCheckSendTime = currMs
        this.pingCheckTime = currMs
    end

    if this.isLogin then
        this.pingInterval = math.random(150, 200)
        if this.heartbeatLastSendTime == 0 then
            this.heartbeatLastSendTime = currMs
        end
        this.SendJsonObj(CMD.Tcp.C2S_Heartbeat, { userId = UserData.GetUserId() })
    end
end

----------------------------------
--
--检测一次Ping值
function Network.InternalCheckPingOnce(currMs)
    --发送心跳的过程中才进行检测，如果是正常心跳，Ping值会在收到心跳的时候更新
    --发送了心跳，没有收到才会在该方法处理，即this.isHeartbeatSend为true
    if this.isHeartbeatSend then
        this.pingDiffTime = currMs - this.pingCheckTime
        if this.pingDiffTime > this.pingInterval then
            --处理间隔时间
            this.pingCheckTime = this.pingCheckTime + this.pingInterval
            if this.pingInterval < 2000 then
                --添加检测间隔
                this.pingInterval = this.pingInterval + math.random(100, 200)
            end
            --处理ping值
            this.pingDiffTime = currMs - this.pingCheckSendTime
            Network.HandlePing(this.pingDiffTime)
        end
    end
end

--启动内部检测Ping值
function Network.StartInternalCheckPingTimer()
    if this.checkPingTimer == nil then
        this.checkPingTimer = Timing.New(this.OnInternalCheckPingTimer, 0.066)
    end
    this.checkPingTimer:Start()
end

--停止内部检测Ping值
function Network.StopInternalCheckPingTimer()
    if this.checkPingTimer ~= nil then
        this.checkPingTimer:Stop()
    end
end

--处理内部检测Ping值
function Network.OnInternalCheckPingTimer()
    this.InternalCheckPingOnce(os.timems())
end

--处理Ping值
function Network.HandlePing(pingTime)
    pingTime = pingTime / 2
    pingTime = Functions.TernaryOperator(pingTime > 460, 460, pingTime)
    pingTime = Functions.TernaryOperator(pingTime < 30, 30, pingTime)
    SendMsg(CMD.Game.Ping, math.floor(pingTime))
end

------------------------------------------------------------------
--
--连接建立时
function Network.OnConnected()
    LogWarn(">> Network.OnConnected > 网络连接成功.")
    --LogUpload("ljs")
    --连接上时设置心跳接收时间，便于处理心跳检测和Ping值
    this.heartbeatLastRecvTime = os.timems()
    --连接上时清除检测协议超时时间
    this.ClearProtocalSendTime()
    this.StopCheckConnectTimer()
    this.StartCheckConnectTimer()
    --分派事件
    SendMsg(CMD.Game.OnConnected)
end

--连接失败
function Network.OnConnectFailed()
    LogWarn(">> Network.OnConnectFailed")
    this.isLogin = false
    SendMsg(CMD.Game.OnDisconnected)
    Network.ShowWaiting("您的网络不稳定...")
end

--连接关闭
function Network.OnConnectClosed()
    LogWarn(">> Network.OnConnectClosed")
    this.isLogin = false
    SendMsg(CMD.Game.OnDisconnected)
    Network.ShowWaiting("您的网络不稳定....")
end

------------------------------------------------------------------
--
--显示Waiting提示
function Network.ShowWaiting(text)
    Log(">> Network.ShowWaiting > ", text)
    Waiting.Show(text, WaitingLevel.Network)
end

--隐藏Waiting提示
function Network.HideWaiting()
    Waiting.Hide(WaitingLevel.Network)
end

------------------------------------------------------------------
--
--检测网络是否正常，即是否登录，对外接口
function Network.CheckNetworkIsConnected()
    return this.isLogin
end

--单纯的判断是否网络连接
function Network.IsNetworkConnected()
    return networkMgr:IsConnected()
end

--单纯的判断是否为登录连接
function Network.IsLoginConnected()
    if not networkMgr:IsConnected() then
        this.isConnected = false
    else
        --登录后才判断心跳数据接收时间是否正常
        if this.isLogin then
            tempTimems = os.timems()
            if tempTimems - this.heartbeatLastRecvTime > HeartbeatCheckInterval then
                Log(">> Network.IsLoginConnected > ", HeartbeatCheckInterval, tempTimems, this.heartbeatLastRecvTime)
                this.isConnected = false
            else
                this.isConnected = true
            end
        else
            this.isConnected = false
        end
    end
    return this.isConnected
end

--内部检测网络是否正常，包括了心跳检测，检测网络的唯一入口，该方法被Timer定时调用
function Network.InternalCheckNetworkIsConnected()
    --网络异常，直接重连
    if not networkMgr:IsConnected() then
        this.isConnected = false
    else
        --登录后才判断心跳数据接收时间是否正常
        if this.isLogin then
            tempTimems = os.timems()
            if tempTimems - this.heartbeatLastRecvTime > HeartbeatCheckInterval then
                Log(">> Network.InternalCheckNetworkIsConnected > Heartbeat Timeout.")
                this.isConnected = false
            else
                this.isConnected = true
            end
        else
            --处理登录协议超时
            tempTimems = os.timems()
            if tempTimems - this.lastSendLoginTime > LoginTimeoutTime then
                Log(">> Network.InternalCheckNetworkIsConnected > Login Timeout.")
                this.isConnected = false
            else
                this.isConnected = true
            end
        end
    end
    return this.isConnected
end

------------------------------------------------------------------
--
--注册超时检测协议，如果发送给服务器的协议，超时一定时间没有返回，主动断开socket。
--c2sProtocal：客户端发送给服务器的协议     
--s2cProtocal：服务器发给客户端的协议   s2cProtocal值为nil时，相当于取消注册协议
function Network.RegisterTimeOutProtocal(c2sProtocal, s2cProtocal)
    if not IsNil(c2sProtocal) then
        if s2cProtocal == nil then
            this.timeOutProtocal[c2sProtocal] = nil
        else
            local temp = this.timeOutProtocal[c2sProtocal]
            if temp == nil then
                temp = {}
                this.timeOutProtocal[c2sProtocal] = temp
            end
            temp.s2cProtocal = s2cProtocal
            temp.sendTime = 0
        end
    end
end

--检测保存协议发送时间
function Network.CheckProtocalSendTime(c2sProtocal)
    local temp = this.timeOutProtocal[c2sProtocal]
    if temp ~= nil then
        temp.sendTime = os.timems()
        Log(">> Network.CheckProtocalSendTime > c2sProtocal = ", c2sProtocal)
    end
end

--删除协议发送时间
function Network.RemoveProtocalSendTime(s2cProtocal)
    --添加协议发送时间
    for c2sCmd, temp in pairs(this.timeOutProtocal) do
        if temp ~= nil and temp.s2cProtocal == s2cProtocal then
            temp.sendTime = 0
            Log(">> Network.RemoveProtocalSendTime > s2cProtocal = ", s2cProtocal)
        end
    end
end

--去掉所有协议超时发送时间
function Network.ClearProtocalSendTime()
    for c2sCmd, temp in pairs(this.timeOutProtocal) do
        if temp ~= nil then
            temp.sendTime = 0
        end
    end
    Log(">> Network.ClearProtocalSendTime > Clear.")
end


----------------------------------
--
--执行一次协议超时检测
function Network.InternalCheckProtocalTimeout()
    if this.IsNetworkConnected() then
        tempTimems = os.timems()
        for c2sProtocal, temp in pairs(this.timeOutProtocal) do
            if temp ~= nil and temp.sendTime > 0 and tempTimems - temp.sendTime > ProtocalTimeoutTime then
                Log(">> Network.InternalCheckProtocalTimeout > 协议超时 > ", c2sProtocal)
                this.Disconnect()
                --("协议超时" .. c2sProtocal)
                break
            end
        end
    end
end

------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
--
--网络连接，连接的唯一入口
function Network.Connect()
    this.connectCount = 0
    this.isLogin = false
    this.isCanCheckNetwork = true
    this.InternalConnect()
end

--内部网络连接，由于内部有Timer检测处理，所以需要添加控制，即
function Network.InternalConnect()
    --连接次数为0，表示第一次连接，即在连接中就不进行处理
    if this.connectCount == 0 then
        --LogUpload("lw")
        this.connectTime = tempTime
        this.connectCount = 1
        --设置服务器信息
        this.InternalHandleConnect()
        --连接检测，并重新开始启动Timer
        this.StartCheckConnectTimer()
    end
end

------------------------------------------------------------------
--
--内部网络连接
function Network.InternalHandleConnect(callback)
    this.heartbeatLastRecvTime = os.timems()
    if this.isUseDun then
        Log(">> Network.InternalHandleConnect > Dun > ", this.serverIp, this.serverPort)
        this.tempCallback = callback
        AppPlatformHelper.GetShieldPort(this.serverIp, this.serverPort, this.OnGetShieldPortCallback)
    else
        Log(">> Network.InternalHandleConnect > ", this.serverIp, this.serverPort)
        AppConst.SocketAddress = this.serverIp
        AppConst.SocketPort = this.serverPort
        if callback ~= nil then
            callback()
        else
            this.ReconnectNetWork()
        end
    end
end

--获取盾回调
function Network.OnGetShieldPortCallback(ip, port)
    AppConst.SocketAddress = ip
    AppConst.SocketPort = port
    if this.tempCallback ~= nil then
        local tempCallback = this.tempCallback
        this.tempCallback = nil
        tempCallback()
    else
        this.ReconnectNetWork()
    end
end

------------------------------------------------------------------
--
--启动或者重启连接检测
function Network.StartCheckConnectTimer()
    if this.connectCheckTimer == nil then
        this.connectCheckTimer = Timing.New(this.OnCheckConnectTimer, 2)
    end
    this.connectCheckTimer:Restart()
end

--停止连接检测
function Network.StopCheckConnectTimer()
    LogWarn(">> Network.StopCheckConnectTimer > Stop")
    this.connectCount = 0
    if this.connectCheckTimer ~= nil then
        this.connectCheckTimer:Stop()
        this.connectCheckTimer = nil
    end
end

--连接检测是否运行
function Network.IsConnectTimerRunning()
    if this.connectCheckTimer ~= nil then
        return this.connectCheckTimer.running
    end
    return false
end

--处理网络Socket连接检测
function Network.OnCheckConnectTimer()
    if this.isCanCheckNetwork then
        this.HandleCheckConnect()
    end
end

--处理网络Socket连接检测
function Network.HandleCheckConnect()
    --
    if not this.InternalCheckNetworkIsConnected() then
        --
        LogWarn(">> Network.OnCheckConnectTimer > 检测网络中 > ", this.connectCount, ConnectMaxTimes)
        --
        if this.connectCount < ConnectMaxTimes then
            --连接次数小于最大连接时，正常重连处理
            ---您的网络不稳定...
            Network.ShowWaiting("正在连接服务器...")
            --
            LogWarn(">> Network.OnCheckConnectTimer > 连接网络中 > ", this.connectCount, ConnectMaxTimes, AppConst.SocketAddress, AppConst.SocketPort)
            --
            --连接次数为2时，再进行重连之前关闭一次Socket，然后重连；连接次数有0,1,2,3,4共5次，即2为中间一次
            if this.connectCount == 2 then
                networkMgr:Close()
            end
            this.InternalHandleConnect()
        elseif this.connectCount == ConnectMaxTimes then
            --连接次数等于最大连接时，提示网络相关
            --
            LogWarn(">> Network.OnCheckConnectTimer > 连接网络达到最大次数 > ", this.connectCount, ConnectMaxTimes, AppConst.SocketAddress, AppConst.SocketPort)
            --
            Alert.Prompt("当前所在网络环境不稳定，请先连接到稳定的网络后再重试。", function()
                this.ShowWaiting("正在连接服务器...")
                this.Connect()
            end, function()
                Network.HideWaiting()
                --AppPlatformHelper.QuitGame()
            end, "", "", AlertLevel.System)
        end
        --
        --连接次数加1
        this.connectCount = this.connectCount + 1
    end
end

------------------------------------------------------------------
--断开连接，是否断开心跳检测
function Network.Disconnect(isStopCheckNetwork)
    --断开网络，设置登录标识
    this.isLogin = false
    --清除协议超时处理
    if IsBool(isStopCheckNetwork) and isStopCheckNetwork == true then
        --停止Ping值检测
        this.StopInternalCheckPingTimer()
        --停止网络检测
        this.isCanCheckNetwork = false
    end
    Log(">> Network.Disconnect > isStopCheckNetwork = ", isStopCheckNetwork)
    networkMgr:Close()
    SendMsg(CMD.Game.OnDisconnected)
end

--
--设置已经登录
function Network.SetLogin()
    Log(">> Network.SetLogin > Start.")
    --设置登录标识
    this.isLogin = true
    --登录成功后重置连接次数，便于下次重连处理
    this.connectCount = 0
    --设置一次发送心跳时间
    this.heartbeatLastRecvTime = os.timems()
    --发送一次心跳
    this.SendHeartbeat()
    --启动Ping值检测
    this.StartInternalCheckPingTimer()
end

------------------------------------------------------------------
--
--设置是否使用盾
function Network.SetIsUseDun(isUseDun)
    this.isUseDun = isUseDun
end

--设置服务器信息
function Network.SetServer(ip, port)
    if IsString(ip) and IsNumber(port) and not string.IsNullOrEmpty(ip) and port > 1000 then
        this.serverIp = ip
        this.serverPort = port
    else
        LogError(">> Network.SetServer > 网络地址设置参数错误：", ip, port)
    end
end

------------------------------------------------------------------
--
--发送消息 
function Network.Send(cmd, jsonString)
    if cmd == CMD.Tcp.C2S_Heartbeat then
        if this.isHeartbearLog then
            LogWarn(">> Network.Send > 心跳数据发送：", jsonString)
        end
    else
        --处理日志打印
        if AppConfig.IsLogEnabled then
            Log(">> Network.Send > 发送数据：", cmd, jsonString)
        end
    end

    if cmd == CMD.Tcp.C2S_Login then
        --登录协议，并存储发送时间用于判断登录超时
        this.lastSendLoginTime = os.timems()
        if this.IsNetworkConnected() then
            networkMgr:Send(cmd, jsonString)
        end
    else
        --有效的登录才进行其他协议数据发送和协议超时检测
        if this.IsLoginConnected() then
            networkMgr:Send(cmd, jsonString)
            this.CheckProtocalSendTime(cmd)
        else
            Log(">> Network.Send > 数据发送失败，网络错误：", cmd, jsonString)
        end
    end

end

--发送消息
function Network.SendJsonObj(cmd, jsonObj)
    if jsonObj == nil then
        jsonObj = ""
    end
    local data = {}
    data.data = jsonObj
    local jsonString = ObjToJson(data)
    Network.Send(cmd, jsonString)
end

------------------------------------------------------------------
--
--Socket消息处理
function Network.OnSocket(networkData)
    --
    networkData:Parse()
    --
    local jsonString = networkData.json
    if jsonString ~= nil and jsonString ~= "" then
        --
        if networkData.cmd == CMD.Tcp.S2C_Heartbeat then
            if this.isHeartbearLog then
                LogWarn("Tcp心跳接收：", jsonString)
            end

            --处理Ping值
            this.isHeartbeatSend = false
            this.heartbeatLastRecvTime = os.timems()
            LogWarn(">> Network.OnSocket > heartbeatLastRecvTime = ", this.heartbeatLastRecvTime)
            if this.heartbeatLastSendTime ~= 0 then
                Network.HandlePing(this.heartbeatLastRecvTime - this.heartbeatLastSendTime)
            end
            this.heartbeatLastSendTime = 0
            this.pingCheckSendTime = 0
        else
            --处理日志打印
            if AppConfig.IsLogEnabled then
                Log(">> Tcp数据接收：", networkData.cmd, jsonString)
            end
        end

        local jsonObj = JsonToObj(jsonString)
        --
        GlobalTcpApi.HandleNetworkData(networkData.cmd, jsonObj)
        --去掉协议
        this.RemoveProtocalSendTime(networkData.cmd)
    else
        LogWarn(">> Network.OnSocket > data == nil > ", networkData.cmd)
    end
end