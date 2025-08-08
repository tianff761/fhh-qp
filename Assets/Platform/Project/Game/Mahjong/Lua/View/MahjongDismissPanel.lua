MahjongDismissPanel = ClassPanel("MahjongDismissPanel")
MahjongDismissPanel.Instance = nil
--
local this = nil

--选择中文本颜色
local ColorSelecting = Color(232 / 255, 15 / 255, 15 / 255, 1)
--同意文本颜色
local ColorArgee = Color(63 / 255, 115 / 255, 51 / 255, 1)
--拒绝文本颜色
local ColorRefuse = Color(232 / 255, 15 / 255, 15 / 255, 1)

--
--初始属性数据
function MahjongDismissPanel:InitProperty()
    --已经选择的玩家
    this.selectedPlayer = nil
    --倒计时Timer
    this.countDownTimer = nil
    this.countDownTime = 0
    --用于存储比较显示
    this.lastCountDownTime = -1
    --更新倒计时时间
    this.updateCountDownTime = 0
    --延迟关闭Timer
    this.delayCloseTimer = nil
end

--UI初始化
function MahjongDismissPanel:OnInitUI()
    this = self
    this:InitProperty()

    local nodeTrans = self:Find("Content/Node")

    this.agreeBtn = nodeTrans:Find("AgreeButton").gameObject
    this.rejectBtn = nodeTrans:Find("RejectButton").gameObject

    local textNodeTrans = nodeTrans:Find("TextNode")
    this.textNode = textNodeTrans.gameObject
    this.countDownTxt = textNodeTrans:Find("CountDownTxt"):GetComponent(TypeText)

    this.tipsTxt = nodeTrans:Find("TipsText"):GetComponent(TypeText)

    this.items = {}
    local itemsTrans = nodeTrans:Find("Items")
    for i = 1, 4 do
        local itemTrans = itemsTrans:Find(tostring(i))
        local item = {}
        item.gameObject = itemTrans.gameObject

        item.stateFrame = itemTrans:Find("StateFrame"):GetComponent(TypeImage)
        item.headImage = itemTrans:Find("HeadMask/Head"):GetComponent(TypeImage)
        item.headFrame = itemTrans:Find("HeadFrame"):GetComponent(TypeImage)
        item.nameTxt = itemTrans:Find("NameText"):GetComponent(TypeText)
        item.stateTxt = itemTrans:Find("StateText"):GetComponent(TypeText)
        item.stateTxt.text = ""
        this.items[i] = item
    end

    local spriteAtlasImages = nodeTrans:Find("StateAtlas"):GetComponent("UISpriteAtlas").sprites:ToTable()
    this.stateImages = {}
    for i = 1, #spriteAtlasImages do
        this.stateImages[spriteAtlasImages[i].name] = spriteAtlasImages[i]
    end
    this.AddUIListenerEvent()
end


--当面板开启开启时
function MahjongDismissPanel:OnOpened(argData)
    MahjongDismissPanel.Instance = self
    this.AddListenerEvent()
    MahjongDataMgr.isDismissing = true
    this.UpdateData(argData)
end

--当面板关闭时调用
function MahjongDismissPanel:OnClosed()
    MahjongDismissPanel.Instance = nil
    MahjongDataMgr.isDismissing = false
    this.selectedPlayer = nil
    this.StopCountDownTimer()
    this.StopDelayCloseTimer()
    this.countDownTime = 0
    this.lastCountDownTime = -1
    this.updateCountDownTime = 0
    this.RemoveListenerEvent()
    for i = 1, 4 do
        local item = this.items[i]
        if item ~= nil then
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

------------------------------------------------------------------
--
--关闭
function MahjongDismissPanel.Close()
    PanelManager.Close(MahjongPanelConfig.Dismiss)
end

--
function MahjongDismissPanel.AddListenerEvent()

end
--
function MahjongDismissPanel.RemoveListenerEvent()

end

--UI相关事件
function MahjongDismissPanel.AddUIListenerEvent()
    this:AddOnClick(this.agreeBtn, this.OnAgreeBtnClick)
    this:AddOnClick(this.rejectBtn, this.OnRejectBtnClick)
end

------------------------------------------------------------------
--
function MahjongDismissPanel.OnAgreeBtnClick()
    MahjongCommand.SendDismissOperate(1)
end
--
function MahjongDismissPanel.OnRejectBtnClick()
    MahjongCommand.SendDismissOperate(2)
end

------------------------------------------------------------------
--
--状态，0未处理，1同意，2拒绝
function MahjongDismissPanel.UpdateData(argData)
    if argData == nil or argData.players == nil then
        this.Close()
        return
    end

    --是否解散结束
    local isDismissEnd = true
    --是否有玩家拒绝
    local isHaveReject = false
    local length = #argData.players
    local player = nil
    local playerData = nil
    local applyId = argData.applyId
    --申请人名称
    local candidateName = nil
    for i = 1, length do
        player = argData.players[i]
        if player ~= nil then
            --显示按钮
            if player.id == MahjongDataMgr.userId then
                if player.state == 0 then
                    UIUtil.SetActive(this.agreeBtn, true)
                    UIUtil.SetActive(this.rejectBtn, true)
                else
                    UIUtil.SetActive(this.agreeBtn, false)
                    UIUtil.SetActive(this.rejectBtn, false)
                end
            end

            if player.state ~= 1 then
                isDismissEnd = false
            end
            if player.state == 2 then
                isHaveReject = true
            end
            playerData = MahjongDataMgr.GetPlayerDataById(player.id)
            playerData.dismissState = player.state
            this.UpdateSelectedPlayer(playerData)

            --判断申请人名称
            if player.id == applyId then
                candidateName = playerData.name
            end
        end
    end

    --提示文本
    if candidateName ~= nil then
        this.tipsTxt.text = "玩家<color=#FF0000>" .. candidateName .. "</color>申请房间解散，等待其他玩家操作"
    else
        this.tipsTxt.text = "玩家申请房间解散，等待其他玩家操作"
    end

    --更新UI显示
    this.UpdatePlayerDisplay()

    --如果是解散或者有人拒绝，延迟关闭界面
    if isDismissEnd or isHaveReject then
        this.StopCountDownTimer()
        this.StartDelayCloseTimer()
    else
        this.StopDelayCloseTimer()
        this.UpdateCountDown(argData.countDown)
    end
end

--更新选择的玩家
function MahjongDismissPanel.UpdateSelectedPlayer(playerData)
    if this.selectedPlayer == nil then
        this.selectedPlayer = {}
    end
    local length = #this.selectedPlayer
    local temp = nil
    local isFound = false
    for i = 1, length do
        temp = this.selectedPlayer[i]
        if temp.id == playerData.id then
            --更新
            isFound = true
            this.selectedPlayer[i] = playerData
            break
        end
    end
    if not isFound then
        table.insert(this.selectedPlayer, playerData)
    end
end

--停止或者关闭延迟计时器
function MahjongDismissPanel.StartDelayCloseTimer()
    if this.delayCloseTimer == nil then
        this.delayCloseTimer = Timing.New(this.OnDelayCloseTimer, 0.5)
    end
    this.delayCloseTimer:Restart()
end

--停止或者关闭延迟计时器
function MahjongDismissPanel.StopDelayCloseTimer()
    if this.delayCloseTimer ~= nil then
        this.delayCloseTimer:Stop()
        this.delayCloseTimer = nil
    end
end

--延迟关闭
function MahjongDismissPanel.OnDelayCloseTimer()
    this.StopDelayCloseTimer()
    --延迟关闭，时间要小于小结界面的弹出时间
    this.Close()
end

--更新玩家的显示
function MahjongDismissPanel.UpdatePlayerDisplay()
    if this.selectedPlayer == nil then
        this.selectedPlayer = {}
    end
    local playerTotal = MahjongDataMgr.playerTotal
    local length = #this.selectedPlayer
    local item = nil
    local playerData = nil
    local stateFrameIndex = 0
    for i = 1, 4 do
        item = this.items[i]
        playerData = this.selectedPlayer[i]
        if i <= playerTotal then
            if playerData ~= nil then
                UIUtil.SetActive(item.gameObject, true)
                if playerData.dismissState == 1 then
                    -- item.stateTxt.text = "同意解散"
                    -- item.stateTxt.color = ColorArgee
                    stateFrameIndex = 2
                elseif playerData.dismissState == 2 then
                    -- item.stateTxt.text = "拒绝解散"
                    -- item.stateTxt.color = ColorRefuse
                    stateFrameIndex = 3
                else
                    -- item.stateTxt.text = "选择中..."
                    -- item.stateTxt.color = ColorSelecting
                    stateFrameIndex = 4
                end
                item.stateFrame.sprite = this.stateImages["ui_jsfj_diban_"..stateFrameIndex]
                --玩家头像
                Functions.SetHeadImage(item.headImage, playerData.headUrl)
                Functions.SetHeadFrame(item.headFrame, playerData.headFrame)
                item.nameTxt.text = playerData.name
            else
                UIUtil.SetActive(item.gameObject, false)
            end
        else
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

--更新准备倒计时
function MahjongDismissPanel.UpdateCountDown(countDown)
    if not IsNumber(countDown) then
        this.countDownTime = 0
    else
        this.countDownTime = countDown
        if this.countDownTime < 0 then
            this.countDownTime = 0
        end
        this.StartCountDownTimer()
    end
    this.UpdateCountDownTxt()
end

--更新倒计时文本显示
function MahjongDismissPanel.UpdateCountDownTxt()
    local time = math.ceil(this.countDownTime)
    if this.lastCountDownTime ~= time then
        this.lastCountDownTime = time
        this.countDownTxt.text = tostring(time)
    end
end

------------------------------------------------------------------
--
--启动倒计时Timer
function MahjongDismissPanel.StartCountDownTimer()
    if this.countDownTimer == nil then
        this.countDownTimer = Timing.New(this.OnCountDownTimer, 0.2)
    end
    this.updateCountDownTime = Time.realtimeSinceStartup
    this.countDownTimer:Restart()
end

--停止倒计时Timer
function MahjongDismissPanel.StopCountDownTimer()
    if this.countDownTimer ~= nil then
        this.countDownTimer:Stop()
        this.countDownTimer = nil
    end
end

local tempCountDownTime = 0
local tempCountDownDiffTime = 0
--处理倒计时Timer，该方法不能直接调用
function MahjongDismissPanel.OnCountDownTimer()
    tempCountDownTime = Time.realtimeSinceStartup
    tempCountDownDiffTime = tempCountDownTime - this.updateCountDownTime

    if tempCountDownDiffTime < 0 then
        tempCountDownDiffTime = 0
    end
    this.updateCountDownTime = tempCountDownTime
    this.countDownTime = this.countDownTime - tempCountDownDiffTime

    if this.countDownTime < 0 then
        this.countDownTime = 0
        this.StopCountDownTimer()
        --倒计时结束，直接关闭面板
        this.Close()
    end
    this.UpdateCountDownTxt()
end