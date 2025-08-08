LuckyWheelPanel = ClassPanel("LuckyWheelPanel")
LuckyWheelPanel.Instance = nil
local this = nil
--是否可以关闭
local isClose = true
--关闭timer
local isCloseStartTimer = nil
--是否在旋转
local isRoating = false
--旋转价格
local rotatePrice = 50
--抽奖开始旋转时间 
local startTime = 0
--当前区域，累加
local curArea = 0
--旋转角度
local rotateAugle = -720
--加速时间
local speedUpTime = 2
--减速时间
local cutTime = 2.5
--当前时间
local curTime = 0
--开始值
local startValue = 0
--上次的速度
local lastSpeeh = 0
--加速timer
local speedUpTimer = nil
--匀速timer
local constantSpeedTimer = nil
--减速timer
local speedCutTimer = nil
--当前转动模式
local moduleType

local playLightOutTimer = nil

local ModuleType = {
    stop = 0, --停止中 
    speehUp = 1, --加速
    constantSpeed = 2, --匀速
    speehCut = 3, --减速
}

local StartRotateAugle = 0  --开始旋转时的角度

local animationCurves

local LuckyWheelConfig = {
    [1] = { type = LuckyWheelType.thanks, value = "" },
    [2] = { type = LuckyWheelType.coin, value = "10元宝" },
    [3] = { type = LuckyWheelType.coin, value = "20元宝" },
    [4] = { type = LuckyWheelType.coin, value = "38元宝" },
    [5] = { type = LuckyWheelType.coin, value = "66元宝" },
    [6] = { type = LuckyWheelType.coin, value = "118元宝" },
    [7] = { type = LuckyWheelType.coin, value = "228元宝" },
    [8] = { type = LuckyWheelType.coin, value = "388元宝" }
}

--根据下标获取角度
function LuckyWheelPanel.GetAngularByIndex(index)
    local min = (index - 1) * 45 - 45 / 2
    local max = (index - 1) * 45 + 45 / 2
    return min, max
end

function LuckyWheelPanel:OnInitUI()
    this = self
    self:InitPanel()
    self:InitUIEvent()
    self:SetPrizeData()
    self.consumeText.text = "x" .. rotatePrice

    self.outBorderWheelHelper.onAreaChange = this.OnAreaChange
    animationCurves = self.outBorderWheelHelper.animationCurves
end

function LuckyWheelPanel:InitPanel()
    local content = self.transform:Find("Content")

    self.outBorder = content:Find("OutBorder")

    self.outLight = self.outBorder:Find("OutLight")

    self.outBorderWheelHelper = self.outBorder:GetComponent("UIWheelHelper")

    self.arrows = self.outBorder:Find("Arrows")

    self.drawPrizeBtn = self.outBorder:Find("ArrowsBtn")

    self.closeBtn = self.transform:Find("Content/Background/CloseButton")

    self.consumeText = self.outBorder:Find("ExpendText"):GetComponent("Text")

    self.inBorder = content:Find("InBorder")

    self.wheelAnimator = self.outBorder:Find("WheelAniator")
    self.wheelAnimatorCom = self.wheelAnimator:Find("Armature"):GetComponent("UnityArmatureComponent")

    self.lightArmature = content:Find("Background/Image/Armature"):GetComponent("UnityArmatureComponent")

    self.props = content:Find("OutBorder/Props")
    self.prizes = {}
    for i = 1, 8 do
        self.prizes[i] = self.props:Find(i)
    end

    self.Light = self.outBorder:Find("Light")
    self.light1 = self.Light:Find("Light1")
    self.light2 = self.Light:Find("Light2")
    self.light3 = self.Light:Find("Light3")
end

--每次打开都调用一次
function LuckyWheelPanel:OnOpened()
    this.isOpenPanel = true
    self:AddListenerEvent()
    self:PlayLightOut()
    DragonBonesUtil.Play(self.lightArmature, "DaiJi")
end

function LuckyWheelPanel:InitUIEvent()
    --开始抽奖
    this:AddOnClick(self.drawPrizeBtn, this.OnStartDrawPrizeBtnClick)
    this:AddOnClick(self.closeBtn, this.OnClickCloseBtn)
end

function LuckyWheelPanel:AddListenerEvent()
    AddMsg(CMD.Tcp_S2C_LuckyWheel, this.OnDrawPrizeEvent)
    AddMsg(CMD.Game.OnConnected, this.OnConnected)
end

function LuckyWheelPanel.RemoveListenerEvent()
    RemoveMsg(CMD.Tcp_S2C_LuckyWheel, this.OnDrawPrizeEvent)
    RemoveMsg(CMD.Game.OnConnected, this.OnConnected)
end

--播放外闪光
function LuckyWheelPanel:PlayLightOut()
    playLightOutTimer = Scheduler.scheduleGlobal(function()
        local eag = self.outLight.transform.localEulerAngles
        self.outLight.transform.localEulerAngles = Vector3(eag.x, eag.y, eag.z + 45)
    end, 0.6)
end

--设置奖品数据
function LuckyWheelPanel:SetPrizeData()
    for i = 1, #LuckyWheelConfig do
        local image = this.prizes[i]:Find("Image"):GetComponent("Image")
        image:SetNativeSize()
        this.prizes[i]:Find("Count"):GetComponent("Text").text = LuckyWheelConfig[i].value
    end
end

function LuckyWheelPanel.OnStartDrawPrizeBtnClick()
    if not isRoating then
        if UserData.GetGift() < rotatePrice then
            Alert.Show("礼券不足，无法抽奖")
            return
        end

        --用于计时器
        if networkMgr:IsConnected() then
            isRoating = true
            BaseTcpApi.SendLuckyWheel()
            this.StartTimerDraw()
            this.StartTimerIsClose()
            this.StartRotate()

            DragonBonesUtil.Play(this.lightArmature, "YunXing")
        else
            Toast.Show("网络异常无法进行抽奖")
        end

        if playLightOutTimer ~= nil then
            Scheduler.unscheduleGlobal(playLightOutTimer)
            playLightOutTimer = nil
        end
    else
        Toast.Show("正在抽奖中，请不要重复操作")
    end
end

function LuckyWheelPanel.OnDrawPrizeEvent(arg)
    local time = this.StopTimerDraw()
    coroutine.start(function()
        coroutine.wait(time)
        Waiting.Hide()
        this.handleDrawPrize(arg)
    end)
end

function LuckyWheelPanel.handleDrawPrize(arg)
    if arg.code == 0 then
        local data = arg.data
        if data == nil then
            this.CloseRotate(true)
            LogError("抽奖成功，但是返回的参数 为 空")
            Alert.Show("抽奖失败，请稍后重试")
            this.StopTimerIsClose()
            return
        end
        local uid = data.id
        if uid == nil then
            LogError("抽奖成功，但是返回的奖励id 为 空")
            this.CloseRotate(true)
            Alert.Show("抽奖失败，请稍后重试")
            this.StopTimerIsClose()
            return
        end
        if LuckyWheelConfig[uid].type == LuckyWheelType.phone then
            uid = 1
        end

        this.EndRotate(uid)

        UserData.SetGift(data.gift)

        SendMsg(CMD.Game.UpdateMoney)
    elseif arg.code == 18101 then
        this.CloseRotate(true)
        Alert.Show("礼券不足，无法抽奖")
        this.StopTimerIsClose()
    else
        this.CloseRotate(true)
        Alert.Show("抽奖失败，请稍后重试")
        this.StopTimerIsClose()
    end
end

--当区域改变时 旋转中
function LuckyWheelPanel.OnAreaChange(index)
    curArea = curArea + 1
    local v3 = this.Light.localEulerAngles
    local jd = this.GetRotationAngle(index)
    this.Light.localEulerAngles = Vector3.New(v3.x, v3.y, jd)

    if curArea == 1 then
        UIUtil.SetActive(this.light1, true)
        UIUtil.SetActive(this.light2, true)
        UIUtil.SetActive(this.light3, false)
    elseif curArea == 2 then
        UIUtil.SetActive(this.light1, true)
        UIUtil.SetActive(this.light2, true)
        UIUtil.SetActive(this.light3, true)
    end
end

--旋转完成
function LuckyWheelPanel.EndRotateComplete(index)
    UIUtil.SetActive(this.light3, false)
    UIUtil.SetActive(this.light2, false)

    this.StopTimerIsClose()
    --谢谢惠顾，不显示中奖动画
    if index ~= 1 then
        AudioManager.PlaySound("base/sound", "wheelFinsh")
        this.PlayWinningAnimation(index)
        Scheduler.scheduleOnceGlobal(HandlerArgs(this.PlayAnimation, index), 1)
    else
        this.PlayAnimation(index)
    end
    BaseTcpApi.SendGetRedPointInfo()
    
    DragonBonesUtil.Play(this.lightArmature, "DaiJi")
end

function LuckyWheelPanel.PlayWinningAnimation(index)
    local v3 = this.wheelAnimator.localEulerAngles
    local jd = this.GetRotationAngle(index)

    this.wheelAnimator.localEulerAngles = Vector3.New(v3.x, v3.y, jd)
    UIUtil.SetActive(this.wheelAnimator, true)
    this.wheelAnimatorCom.animation:Play()
end

function LuckyWheelPanel.PlayAnimation(index)
    if index ~= 1 then
        this.wheelAnimatorCom.animation:Stop()
    end
    UIUtil.SetActive(this.wheelAnimator, false)

    isRoating = false

    if LuckyWheelConfig[index].type == LuckyWheelType.thanks then
        Alert.Show("很遗憾，请下次再来！")
    else
        local type = LuckyWheelConfig[index].type
        local num = LuckyWheelConfig[index].value
        PanelManager.Open(PanelConfig.WheelTip, { {[tostring(type)] = num } }, true)
    end
end

--还原
function LuckyWheelPanel.ResetToBegininBorder()
    UIUtil.SetActive(this.Light, false)
end

--获取旋转角度
function LuckyWheelPanel.GetRotationAngle(index)
    return -360 - 45 * (index - 1)
end

function LuckyWheelPanel.Close()
    PanelManager.Destroy(PanelConfig.LuckyWheel, true)
end

function LuckyWheelPanel.OnClickCloseBtn()
    if not isClose then
        Toast.Show("正在抽奖中，请稍后！")
    else
        this.Close()
    end
end

function LuckyWheelPanel.OnTest()
    local arg = { code = 0, apiCode = 0 }
    arg.data = { id = GetRandom(1, 8) }

    this.OnDrawPrizeEvent(arg)
end

function LuckyWheelPanel.StartTimerDraw()
    startTime = os.timems()
end

function LuckyWheelPanel.StopTimerDraw()
    local tTime = os.timems()
    local cha = tTime - startTime
    local time = 0
    if cha < speedUpTime * 1000 then
        time = speedUpTime * 1000 - cha
    end
    return time / 1000
end

function LuckyWheelPanel.OnConnected()
    if isRoating then
        this.Close()
        Alert.Show("网络异常，若中奖抽奖结果将发送至邮件")
    end
end

--开始旋转
function LuckyWheelPanel.StartRotate()
    UIUtil.SetActive(this.Light, true)
    UIUtil.SetActive(this.light1, true)
    UIUtil.SetActive(this.light2, false)
    UIUtil.SetActive(this.light3, false)

    StartRotateAugle = this.arrows.localEulerAngles.z

    this.SpeedUp()
    Scheduler.scheduleOnceGlobal(function()
        if speedUpTimer ~= nil then
            speedUpTimer:Stop()
            speedUpTimer = nil
        end
        if moduleType == ModuleType.speehUp then
            --切换为匀速
            this.ConstantSpeed()
        end
    end, speedUpTime)
end

--关闭旋转
function LuckyWheelPanel.CloseRotate(isRecovery)
    moduleType = ModuleType.stop

    isRoating = false
    if speedUpTimer ~= nil then
        speedUpTimer:Stop()
        speedUpTimer = nil
    end

    if constantSpeedTimer ~= nil then
        constantSpeedTimer:Stop()
        constantSpeedTimer = nil
    end

    if speedCutTimer ~= nil then
        speedCutTimer:Stop()
        speedCutTimer = nil
    end

    if playLightOutTimer ~= nil then
        Scheduler.unscheduleGlobal(playLightOutTimer)
        playLightOutTimer = nil
    end

    if isRecovery then
        this.arrows.localEulerAngles = Vector3(0, 0, StartRotateAugle)
    end
    UIUtil.SetActive(this.Light, false)
end

--结束旋转
function LuckyWheelPanel.EndRotate(index)
    local min, max = this.GetAngularByIndex(index)
    local ro = Util.Random(min + 5, max - 5)
    local jd = -360 * 2 - ro
    if constantSpeedTimer ~= nil then
        constantSpeedTimer:Stop()
        constantSpeedTimer = nil
    end
    this.SpeedCut(HandlerArgs(this.EndRotateComplete, index), jd)
end

--加速
function LuckyWheelPanel.SpeedUp()
    curArea = 0
    moduleType = ModuleType.speehUp
    startValue = this.arrows.localEulerAngles.z
    curTime = 0
    speedUpTimer = Scheduler.scheduleUpdateGlobal(function()
        curTime = curTime + Time.deltaTime
        local t = animationCurves[0]:Evaluate(curTime * (1 / speedUpTime))
        this.arrows.localEulerAngles = Vector3(0, 0, startValue + t * rotateAugle);
        lastSpeeh = startValue + t * rotateAugle;
    end)
end

--匀速
function LuckyWheelPanel.ConstantSpeed()
    curArea = 0
    moduleType = ModuleType.constantSpeed
    startValue = this.arrows.localEulerAngles.z
    curTime = 0
    constantSpeedTimer = Scheduler.scheduleUpdateGlobal(function()
        curTime = curTime + Time.deltaTime
        local t = animationCurves[1]:Evaluate(curTime)
        this.arrows.localEulerAngles = Vector3(0, 0, startValue + t * rotateAugle)
        if (1 - t < 0.001) then
            startValue = this.arrows.localEulerAngles.z;
            curTime = 0
            curArea = 0
        end
    end)
end

--减速
function LuckyWheelPanel.SpeedCut(callback, augle)
    curArea = 2
    moduleType = ModuleType.speehCut
    startValue = this.arrows.localEulerAngles.z
    curTime = 0
    speedCutTimer = Scheduler.scheduleUpdateGlobal(function()
        curTime = curTime + Time.deltaTime
        local t = animationCurves[2]:Evaluate(curTime * (1 / cutTime))
        this.arrows.localEulerAngles = Vector3(0, 0, startValue + t * (augle - startValue))
        if curTime > cutTime then
            speedCutTimer:Stop()
            speedCutTimer = nil

            moduleType = ModuleType.stop

            if callback ~= nil then
                callback()
            end
        end
    end)
end

function LuckyWheelPanel.StartTimerIsClose()
    this.StopTimerIsClose()
    isClose = false
    isCloseStartTimer = Scheduler.scheduleOnceGlobal(function()
        this.StopTimerIsClose()
    end, 5)
end

function LuckyWheelPanel.StopTimerIsClose()
    isClose = true
    if isCloseStartTimer ~= nil then
        isCloseStartTimer:Stop()
        isCloseStartTimer = nil
    end
end

--关闭回掉
function LuckyWheelPanel:OnClosed()
    this.isOpenPanel = false
    this.RemoveListenerEvent()
    this.ResetToBegininBorder()
    isRoating = false
    this.arrows.localEulerAngles = Vector3.New(0, 0, 0)

    curTime = 0
    lastSpeeh = 0
    if speedUpTimer ~= nil then
        speedUpTimer:Stop()
        speedUpTimer = nil
    end
    if constantSpeedTimer ~= nil then
        constantSpeedTimer:Stop()
        constantSpeedTimer = nil
    end
    if speedCutTimer ~= nil then
        speedCutTimer:Stop()
        speedCutTimer = nil
    end

    if playLightOutTimer ~= nil then
        Scheduler.unscheduleGlobal(playLightOutTimer)
        playLightOutTimer = nil
    end

    this.StopTimerIsClose()
    isClose = true
end

--处理销毁时，资源的引用清除，便于释放资源
function LuckyWheelPanel:OnDestroy()

end