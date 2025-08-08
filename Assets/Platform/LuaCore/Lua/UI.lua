--================================================================
--================================================================
--
--提示框类型
AlertType = {
    Prompt = 0,
    OK = 1,
}

--提示框级别
AlertLevel = {
    Normal = 0,
    Error = 1,
    System = 2,
}
--
--Alert提示
Alert = {}
--Alert UI配置
Alert.panelConfig = nil
--是否打开
Alert.isOpen = false
--当前打开的面板配置
Alert.openPanelConfig = nil

function Alert.SetPanelConfig(panelConfig)
    Alert.panelConfig = panelConfig
end

--显示提示框,单按钮提示，使用默认按钮文字可以只需传前2个参数
function Alert.Show(message, okCallback, okBtnTxt, level)
    if message == nil then
        return
    end
    local data = {
        message = message,
        type = AlertType.OK,
        okCallback = okCallback,
        okBtnTxt = okBtnTxt,
        level = level
    }
    Alert.OpenAlertPanel(data)
end

--双按钮提示，使用默认按钮文字可以不用传，或者传nil
function Alert.Prompt(message, okCallback, cancelCallback, okBtnTxt, cancelBtnTxt, level, title)
    if message == nil then
        return
    end
    local data = {
        message = message,
        type = AlertType.Prompt,
        okCallback = okCallback,
        cancelCallback = cancelCallback,
        okBtnTxt = okBtnTxt,
        cancelBtnTxt = cancelBtnTxt,
        level = level,
        title = title,
    }
    Alert.OpenAlertPanel(data)
end

--打开提示面板
function Alert.OpenAlertPanel(data)
    if Alert.panelConfig ~= nil then
        if Alert.openPanelConfig ~= nil and Alert.openPanelConfig ~= Alert.panelConfig then
            PanelManager.Close(Alert.openPanelConfig)
        end

        Alert.isOpen = true
        Alert.openPanelConfig = Alert.panelConfig
        PanelManager.Open(Alert.panelConfig, data)
    end
end

function Alert.Hide()
    Alert.isOpen = false
    if Alert.panelConfig ~= nil then
        PanelManager.Close(Alert.panelConfig)
    end
end

--================================================================
--================================================================
--
--Toast提示
Toast = {}
--Alert UI配置
Toast.panelConfig = nil

function Toast.SetPanelConfig(panelConfig)
    Toast.panelConfig = panelConfig
end

function Toast.Show(message, keepTime)
    if message == nil then
        return
    end
    local data = {
        message = message,
        keepTime = keepTime
    }
    if Toast.panelConfig ~= nil then
        PanelManager.Open(Toast.panelConfig, data)
    end
end

function Toast.Hide()
    if Toast.panelConfig ~= nil then
        PanelManager.Close(Toast.panelConfig)
    end
end

--================================================================
--================================================================
--
--持久提示等级
WaitingLevel = {
    Normal = 0,
    Network = 1,
    System = 2,
}

--持久提示
Waiting = {}
--Waiting UI配置
Waiting.panelConfig = nil
--是否打开
Waiting.isOpen = false
--显示等级
Waiting.level = WaitingLevel.Normal
--隐藏Timer
Waiting.hideTimer = nil
--显示时间
Waiting.showTime = 0
--显示时间的检测Timer
Waiting.showTimeCheckTimer = nil
--显示时间的检测间隔，毫秒
Waiting.showTimeCheckInterval = 200
--最大的显示时间，毫秒
Waiting.keepTime = 20000

function Waiting.SetPanelConfig(panelConfig)
    Waiting.panelConfig = panelConfig
end

--弹出提示，keepTime单位秒
function Waiting.Show(message, level, keepTime)
    if level == nil then
        level = WaitingLevel.Normal
    end

    if Waiting.isOpen and Waiting.level > level then
        return
    end

    if message == nil then
        return
    end

    if Waiting.panelConfig ~= nil then
        local data = {
            type = 2,
            message = message
        }
        if IsNumber(keepTime) then
            Waiting.keepTime = keepTime * 1000
        else
            Waiting.keepTime = 20000
        end
        Waiting.StopShowTimeCheckTimer()
        Waiting.StartHideTimer()
        Waiting.isOpen = true
        if Waiting.showTime < 1 then
            Waiting.showTime = os.timems()
        end
        PanelManager.Open(Waiting.panelConfig, data)
    end
end

--隐藏
function Waiting.Hide(level)
    --Log(">> Waiting > ======== > Hide")
    if level == nil then
        level = WaitingLevel.Normal
    end
    if not Waiting.isOpen or Waiting.level > level then
        return
    end
    Waiting.CheckHide()
end

--强制隐藏，不判断等级
function Waiting.ForceHide()
    --Log(">> Waiting > ======== > ForceHide")
    Waiting.CheckHide()
end

--内部隐藏，直接隐藏Waiting的UI
function Waiting.InternalHide()
    Log(">> Waiting > ======== > InternalHide > Hide Waiting.")
    Waiting.StopHideTimer()
    Waiting.isOpen = false
    Waiting.level = WaitingLevel.Normal
    Waiting.showTime = 0
    if Waiting.panelConfig ~= nil then
        PanelManager.Close(Waiting.panelConfig)
    end
end

--启动隐藏Timer，处理最大显示时间
function Waiting.StartHideTimer()
    Log(">> Waiting > ======== > StartHideTimer")
    if Waiting.hideTimer == nil then
        Waiting.hideTimer = Timing.New(Waiting.OnHideTimer, 1)
    end
    Waiting.hideTimer:Restart()
end

--停止隐藏Timer
function Waiting.StopHideTimer()
    --Log(">> Waiting > ======== > StopHideTimer")
    if Waiting.hideTimer ~= nil then
        Waiting.hideTimer:Stop()
    end
end

--处理隐藏Timer
function Waiting.OnHideTimer()
    if os.timems() - Waiting.showTime > Waiting.keepTime then
        Waiting.InternalHide()
    end
end

------------------------------------------------------------------
--处理检测，处理最少显示时间
function Waiting.CheckHide()
    --Log(">> Waiting > ======== > CheckHide > showTime = ", Waiting.showTime)
    if os.timems() - Waiting.showTime > Waiting.showTimeCheckInterval then
        Waiting.StopShowTimeCheckTimer()
        Waiting.InternalHide()
    else
        Waiting.StartShowTimeCheckTimer()
    end
end

--启动检测Waiting
function Waiting.StartShowTimeCheckTimer()
    if Waiting.showTimeCheckTimer == nil then
        Waiting.showTimeCheckTimer = Timing.New(Waiting.OnShowTimeCheckTimer, 0.067)
    end
    Log(">> Waiting > ======== > StartShowTimeCheckTimer > Start")
    Waiting.showTimeCheckTimer:Restart()
end

--停止检测Waiting
function Waiting.StopShowTimeCheckTimer()
    Log(">> Waiting > ======== > StopShowTimeCheckTimer > Stop")
    if Waiting.showTimeCheckTimer ~= nil then
        Waiting.showTimeCheckTimer:Stop()
    end
end

--处理检测Waiting
function Waiting.OnShowTimeCheckTimer()
    --Log(">> Waiting > ======== > OnShowTimeCheckTimer > showTime = ", Waiting.showTime)
    if os.timems() - Waiting.showTime > Waiting.showTimeCheckInterval then
        Waiting.StopShowTimeCheckTimer()
        Waiting.InternalHide()
    end
end

--================================================================
--================================================================
--
--遮罩
Mask = {}
--Mask UI配置
Mask.panelConfig = nil
--隐藏Timer
Mask.hideTimer = nil

function Mask.SetPanelConfig(panelConfig)
    Mask.panelConfig = panelConfig
end

function Mask.Show()
    if Mask.panelConfig ~= nil then
        Mask.StartHideTimer()
        PanelManager.Open(Mask.panelConfig)
    end
end

function Mask.Hide()
    --Log(">> Mask.Hide")
    Mask.StopHideTimer()
    if Mask.panelConfig ~= nil then
        PanelManager.Close(Mask.panelConfig)
    end
end

--启动隐藏Timer
function Mask.StartHideTimer()
    --Log(">> Mask.StartHideTimer")
    if Mask.hideTimer == nil then
        Mask.hideTimer = Timing.New(Mask.OnHideTimer, 1)
    end
    Mask.hideTimer:Restart()
end

--停止隐藏Timer
function Mask.StopHideTimer()
    --Log(">> Mask.StopHideTimer")
    if Mask.hideTimer ~= nil then
        Mask.hideTimer:Stop()
    end
end

--处理隐藏Timer
function Mask.OnHideTimer()
    Mask.Hide()
end


--================================================================
--================================================================