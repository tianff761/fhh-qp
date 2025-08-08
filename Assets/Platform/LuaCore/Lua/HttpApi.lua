HttpApiCode = {
    --成功
    Success = 0,
    --失败
    Failed = 1,
    --超时
    Timeout = 2,
}

--Http请求的HttpApi相关
HttpApi = {}
--
local this = HttpApi
--是否打印心跳日志
HttpApi.isLogHeartbeat = true
--网络请求的Token
HttpApi.token = ""
--
--当前请求是否后台请求
HttpApi.isBackground = false
--当前请求是否自动提示
HttpApi.isAutoTips = false
--当前请求是都自动重连
HttpApi.isAutoReconnect = false
--提示文本信息
HttpApi.tipsMsg = nil
--重连计数
HttpApi.reconnectCount = 0
--当前请求的命名号
HttpApi.cmd = 0
--当前发送数据对象
HttpApi.dataObj = nil
--请求时间
HttpApi.time = 0
--请求返回数据
HttpApi.responseData = nil
--是否显示了Watting提示
HttpApi.isShowWatting = false
--
--提示Timer
HttpApi.tipsTimer = nil
--------------------------------
--------------------------------
--类似静态变量
--开启提示的最小时间
HttpApi.TipsOpenMinInterval = 0.8
--关闭提示的最小时间
HttpApi.TipsCloseMinInterval = 1.2
--重连总数
HttpApi.ReconnectTotal = 3
--错误提示字符串
HttpApi.ErrorTips = "当前所在的网络环境不稳定，请更换到稳定的网络后再尝试。"
--超时时间
HttpApi.HttpTimeout = 15
--------------------------------
--------------------------------
--请求中的协议，用来避免重复请求
HttpApi.requestingCmds = {}

--初始化
function HttpApi.Init()
    HttpApiHelper.LuaCallback = HttpApi.OnResponse
end

--设置Token
function HttpApi.SetToken(token)
    HttpApi.token = token
    if HttpApi.token == nil then
        HttpApi.token = ""
    end
end

--服务器成功返回对象{cmd:1000,err:成功,code:0,data:{}}
--apiCode为HttpApi方面的错误码，有成功、失败、超时使用时优先判断该错误码，再判断服务器的错误码
function HttpApi.OnResponse(cmd, apiCode, str)
    local jsonObj = nil
    if apiCode == HttpApiCode.Success then
        if str ~= nil and str ~= "" then
            jsonObj = JsonToObj(str)
        else
            jsonObj = {}
            jsonObj.cmd = cmd + 1
        end
        if CMD.Http.S2C_Heartbeat == jsonObj.cmd then
            if this.isLogHeartbeat then
                LogWarn(">> Http > 接收心跳数据 > ", jsonObj)
            end
        else
            Log(">> Http > 接收数据 > ", jsonObj.cmd, jsonObj)
        end
        jsonObj.apiCode = apiCode
        this.HandleHttpApiSuccess(cmd, jsonObj)
    else
        jsonObj = {}
        jsonObj.apiCode = apiCode
        jsonObj.cmd = cmd + 1
        jsonObj.apiError = str
        LogWarn(">> HttpApi.OnRequest > Error > jsonObj =  ", jsonObj)
        this.HandleHttpApiFail(cmd, jsonObj)
    end
end

--请求
--cmd 命令号
--dataObj 数据对象
--isBackground 是否后台请求
--isAutoTips 是否自动提示，后台请求的不受影响，不提示也不隐藏提示
--isAutoReconnect 是否自动重连，在API错误的时候，自动重连，后台请求的不受影响
function HttpApi.Request(cmd, dataObj, isBackground, isAutoTips, isAutoReconnect, tipsMsg)
    Log(">> HttpApi.Request > ", cmd, isBackground, isAutoTips, isAutoReconnect)
    if true then
        return 
    end 
    if this.requestingCmds[cmd] ~= nil then
        Log(">> HttpApi.Request > ================ > Requesting > ", cmd)
        return
    end

    this.requestingCmds[cmd] = cmd

    if isBackground == nil then
        isBackground = false
    end
    --处理Token
    if cmd ~= CMD.Http.C2S_Login then
        
        if isBackground == true then
            --如果是后台运行的，需要缓存下来，防止重复请求
        else
            --如果Token为空，且请求不是后台运行的，则需要保存数据，便于登录完成后继续请求
            this.cmd = cmd
            this.dataObj = dataObj
            this.isBackground = false
            --如果是协议替换，自动提示需要判断上一个协议的，不为True才进行新的赋值
            if not this.isAutoTips then
                if isAutoTips == nil then
                    isAutoTips = false
                end
                this.isAutoTips = isAutoTips
            end
            --
            if isAutoReconnect == nil then
                isAutoReconnect = false
            end
            this.isAutoReconnect = isAutoReconnect
            this.tipsMsg = tipsMsg
        end

        if string.IsNullOrEmpty(HttpApi.token) then
            SendEvent(CMD.Game.S2C_Session_Invalidation)
            return
        end
    end

    this.InternalRequest(cmd, dataObj)

    --不是后台运行的，则需要启动提示处理
    if isBackground ~= true and isAutoTips == true then
        this.StartTipsTimer()
        Log(">> HttpApi.Request > Mask.Show . ")
        Mask.Show()
    end
end

--内部方法，外部不调用
function HttpApi.InternalRequest(cmd, dataObj)
    --添加最新token
    dataObj.token = HttpApi.token
    --
    local jsonObj = { type = "logic" }
    jsonObj.cmd = cmd
    jsonObj.data = dataObj
    local jsonString = ObjToJson(jsonObj)

    if CMD.Http.C2S_Heartbeat == cmd then
        if this.isLogHeartbeat then
            LogWarn(">> HttpApi.InternalRequest > Heartbeat")
        end
    end
    Log(">> Http > 发送数据 > ", jsonString)
    --设置超时时间
    HttpApiHelper.HttpTimeout = math.random(HttpApi.HttpTimeout - 2, HttpApi.HttpTimeout + 2)
    HttpApiHelper.Request(cmd, jsonString)
end

--处理API成功返回
function HttpApi.HandleHttpApiSuccess(cmd, jsonObj)

    Log(">> HttpApi.HandleHttpApiSuccess > ", cmd, this.cmd)
end

--回到登录提示
function HttpApi.OnReloginAlert()
    this.ClearRequestCache()
    Mask.Hide()
    Waiting.ForceHide()
    SendEvent(CMD.Game.LogoutAndOpenLogin)
end

--退出应用提示
function HttpApi.OnQuitAppAlert()
    SendEvent(CMD.Game.LogoutAndQuitApp)
end

--处理API失败返回
function HttpApi.HandleHttpApiFail(cmd, jsonObj)
    --处理
    Log(">> HttpApi.HandleHttpApiFail > ", this.cmd, cmd, this.isBackground, this.isAutoTips, this.isAutoReconnect)
    if this.cmd == cmd then
        if this.isBackground ~= true then
            if this.isAutoReconnect then
                if this.reconnectCount < HttpApi.ReconnectTotal then
                    --重连
                    this.reconnectCount = this.reconnectCount + 1
                    this.InternalRequest(this.cmd, this.dataObj)
                else
                    --停止计时器
                    this.StopTipsTimer()
                    if this.isAutoTips then
                        Mask.Hide()
                        Waiting.Hide(WaitingLevel.Network)
                    end
                    --清空请求数据
                    this.ClearRequestCache()
                    --重连次数过大，分派事件
                    this.SendEvent(cmd, jsonObj)
                end
            else
                this.StopTipsTimer()
                if this.isAutoTips then
                    Mask.Hide()
                    Waiting.Hide(WaitingLevel.Network)
                end
                this.ClearRequestCache()
                --不重连，直接分派事件
                this.SendEvent(cmd, jsonObj)
            end
        else
            this.ClearRequestingCmd(cmd)
        end
    else
        --指令不同，直接分派事件
        this.SendEvent(cmd, jsonObj)
    end
end

--分派数据
function HttpApi.SendEvent(cmd, jsonObj)
    this.ClearRequestingCmd(cmd)
    SendEvent(jsonObj.cmd, jsonObj)
end

--清除请求中的协议
function HttpApi.ClearRequestingCmd(cmd)
    this.requestingCmds[cmd] = nil
end


--处理API返回
function HttpApi.HandleApiResponse()
    local temp = Time.realtimeSinceStartup - this.time
    if temp > HttpApi.TipsCloseMinInterval then
        if this.responseData ~= nil then
            --成功处理数据
            this.HandleSuccessResponse()
        end
    elseif temp > HttpApi.TipsOpenMinInterval then
        if this.isShowWatting == false then
            this.isShowWatting = true
            if not Waiting.isOpen then
                if this.tipsMsg ~= nil then
                    Waiting.Show(this.tipsMsg, WaitingLevel.Network)
                else
                    Waiting.Show("数据处理中...", WaitingLevel.Network)
                end
            end
        end
    else
        --在小于开启时间就收到服务器数据
        if this.responseData ~= nil then
            --成功处理数据
            this.HandleSuccessResponse()
        end
    end
end

--处理成功返回数据
function HttpApi.HandleSuccessResponse()
    Log(">> HttpApi.HandleSuccessResponse > ", this.cmd, this.isAutoTips)

    --停止计时器
    this.StopTipsTimer()
    --处理提示
    if this.isAutoTips then
        Mask.Hide()
        Waiting.Hide(WaitingLevel.Network)
    end
    local jsonObj = this.responseData
    --清除数据
    this.ClearRequestCache()
    SendEvent(jsonObj.cmd, jsonObj)
end


--启动提示Timer
function HttpApi.StartTipsTimer()
    if this.tipsTimer == nil then
        this.tipsTimer = UpdateTimer.New(this.OnTipsTimer)
    end
    if not this.tipsTimer.running then
        this.tipsTimer:Start()
        this.time = Time.realtimeSinceStartup
    end

end

--停止提示Timer
function HttpApi.StopTipsTimer()
    Log(">> HttpApi.StopTipsTimer > ", this.cmd)
    if this.tipsTimer ~= nil then
        this.tipsTimer:Stop()
    end
end

--提示Timer处理
function HttpApi.OnTipsTimer()
    this.HandleApiResponse()
end

--清除请求缓存
function HttpApi.ClearRequestCache()
    this.isBackground = false
    this.isAutoTips = false
    this.isAutoReconnect = false
    this.reconnectCount = 0
    this.cmd = 0
    this.dataObj = nil
    this.time = 0
    this.responseData = nil
    this.isShowWatting = false
    this.tipsMsg = nil
end