TpOperationPanel = ClassPanel("TpOperationPanel")
TpOperationPanel.Instance = nil
--
local this = TpOperationPanel
--操作数据的索引
local OperateDataIndex = {
    Bet1 = 1,
    Bet2 = 2,
    Bet3 = 3,
    Gen = 4,
    AllIn = 5,
    GiveUp = 6,
    Check = 7,
}

--灰色
local ColorGray = Color(220 / 255, 220 / 255, 220 / 255)
--白色
local ColorWhite = Color(1, 1, 1)

--
--初始属性数据
function TpOperationPanel:InitProperty()
    --是否初始化偏移
    this.isInitOffset = false
    --总金币，包含了已经下注的
    this.totalGold = 0
    --
    this.lastGameStatus = nil
    --
    this.tempPosition = Vector2(0, 0)
    --下注按钮字典，用于下注分查找
    this.betBtnDict = {}
end

--UI初始化
function TpOperationPanel:OnInitUI()
    this = self
    --初始属性数据
    self:InitProperty()

    --显示列表
    this.displayList = {}

    local bottom = self:Find("Bottom")

    this.bet1Btn = bottom:Find("Bet1Btn").gameObject
    this.bet1BtnLabel = bottom:Find("Bet1Btn/Text"):GetComponent(TypeText)
    this.bet1Button = this.bet1Btn:GetComponent(TypeButton)

    this.bet2Btn = bottom:Find("Bet2Btn").gameObject
    this.bet2BtnLabel = bottom:Find("Bet2Btn/Text"):GetComponent(TypeText)
    this.bet2Button = this.bet2Btn:GetComponent(TypeButton)

    this.bet3Btn = bottom:Find("Bet3Btn").gameObject
    this.bet3BtnLabel = bottom:Find("Bet3Btn/Text"):GetComponent(TypeText)
    this.bet3Button = this.bet3Btn:GetComponent(TypeButton)

    this.allInBtn = bottom:Find("AllInBtn").gameObject

    this.giveUpBtn = bottom:Find("GiveUpBtn").gameObject
    this.genBtn = bottom:Find("GenBtn").gameObject
    this.genBtnLabel = bottom:Find("GenBtn/Text"):GetComponent(TypeText)
    this.genButton = this.genBtn:GetComponent(TypeButton)

    this.checkBtn = bottom:Find("CheckBtn").gameObject
    -------------------------------
    --回放指示手指
    local hand = self:Find("Hand")
    this.handGo = hand.gameObject
    this.handTransform = hand
    this.handTweener = this.handGo:GetComponent("TweenScale")

    this.SetHandDisplay(false)

    --设置UI的偏移
    this.CheckAndUpdateUIOffset()
    --事件
    this.AddUIListenerEvent()
    --
    this.HideAll()
end

--当面板开启开启时
function TpOperationPanel:OnOpened()
    this.AddListenerEvent()
    this.Check()
end

--当面板关闭时调用
function TpOperationPanel:OnClosed()
    this.RemoveListenerEvent()
    this.lastGameStatus = nil
    this.HideAll()
    this.StopCheckTimer()
end

--根据屏幕是否为2比1设置偏移
function TpOperationPanel.CheckAndUpdateUIOffset()
    if this.isInitOffset == false then
        this.isInitOffset = true
        local offsetX = Global.GetOffsetX()
    end
end

------------------------------------------------------------------
--
--关闭
function TpOperationPanel.Close()
    PanelManager.Close(TpPanelConfig.Operation)
end

--
function TpOperationPanel.AddListenerEvent()
    AddEventListener(CMD.Game.Tp.PlaybackOperate, this.OnPlaybackOperate)
    AddEventListener(CMD.Game.Tp.OperateCheck, this.OnOperateCheck)
    AddEventListener(CMD.Game.Tp.Settlement, this.OnSettlement)
    AddEventListener(CMD.Game.Tp.Reset, this.OnReset)
end

--
function TpOperationPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Game.Tp.PlaybackOperate, this.OnPlaybackOperate)
    RemoveEventListener(CMD.Game.Tp.OperateCheck, this.OnOperateCheck)
    RemoveEventListener(CMD.Game.Tp.Settlement, this.OnSettlement)
    RemoveEventListener(CMD.Game.Tp.Reset, this.OnReset)
end

--UI相关事件
function TpOperationPanel.AddUIListenerEvent()
    this:AddOnClick(this.bet1Btn, this.OnBet1BtnClick)
    this:AddOnClick(this.bet2Btn, this.OnBet2BtnClick)
    this:AddOnClick(this.bet3Btn, this.OnBet3BtnClick)
    this:AddOnClick(this.allInBtn, this.OnAllInBtnClick)
    this:AddOnClick(this.giveUpBtn, this.OnGiveUpBtnClick)
    this:AddOnClick(this.genBtn, this.OnGenBtnClick)
    this:AddOnClick(this.checkBtn, this.OnCheckBtnClick)

    this.handTweener:AddLuaFinished(this.OnHandTweenerCompleted)
end

------------------------------------------------------------------
--

--回放操作
function TpOperationPanel.OnPlaybackOperate(opType, betScore)
    this.HandlePlaybackOperate(opType, betScore)
end

--检测
function TpOperationPanel.OnOperateCheck()
    this.Check()
end

--小结算
function TpOperationPanel.OnSettlement()

end

--小局重置
function TpOperationPanel.OnReset()
    this.lastGameStatus = nil
end

------------------------------------------------------------------
--

--
function TpOperationPanel.OnBet1BtnClick()
    this.SendOperate(OperateDataIndex.Bet1)
    this.HideByOperate()
end

--
function TpOperationPanel.OnBet2BtnClick()
    this.SendOperate(OperateDataIndex.Bet2)
    this.HideByOperate()
end

--
function TpOperationPanel.OnBet3BtnClick()
    this.SendOperate(OperateDataIndex.Bet3)
    this.HideByOperate()
end

--
function TpOperationPanel.OnAllInBtnClick()
    this.SendOperate(OperateDataIndex.AllIn)
    this.HideByOperate()
end

--
function TpOperationPanel.OnGiveUpBtnClick()
    this.SendOperate(OperateDataIndex.GiveUp)
    this.HideByOperate()
end

--
function TpOperationPanel.OnGenBtnClick()
    this.SendOperate(OperateDataIndex.Gen)
    this.HideByOperate()
end

function TpOperationPanel.OnCheckBtnClick()
    this.SendOperate(OperateDataIndex.Check)
    this.HideByOperate()
end

--手动画播放完成
function TpOperationPanel.OnHandTweenerCompleted()
    this.HideAll()
end

--================================================================
--
--隐藏所有
function TpOperationPanel.HideAll()
    this.CheckBet1BtnDisplay(false)
    this.CheckBet2BtnDisplay(false)
    this.CheckBet3BtnDisplay(false)
    this.CheckAllInBtnDisplay(false)
    this.CheckGiveUpBtnDisplay(false)
    this.CheckGenBtnDisplay(false)
    this.CheckCheckBtnDisplay(false)
    this.SetHandDisplay(false)
end

--检查按钮显示
function TpOperationPanel.CheckGameObjectDisplay(index, btnGo, active)
    if this.displayList[index] ~= active then
        this.displayList[index] = active
        if active == true then
            UIUtil.SetActive(btnGo, true)
        else
            UIUtil.SetActive(btnGo, false)
        end
    end
end

--是否显示
function TpOperationPanel.IsGameObjectDisplay(index)
    return this.displayList[index] == true
end

--下注按钮1
function TpOperationPanel.CheckBet1BtnDisplay(active)
    this.CheckGameObjectDisplay(1, this.bet1Btn, active)
end

--下注按钮2
function TpOperationPanel.CheckBet2BtnDisplay(active)
    this.CheckGameObjectDisplay(2, this.bet2Btn, active)
end

--下注按钮3
function TpOperationPanel.CheckBet3BtnDisplay(active)
    this.CheckGameObjectDisplay(3, this.bet3Btn, active)
end

--AllIn按钮
function TpOperationPanel.CheckAllInBtnDisplay(active)
    this.CheckGameObjectDisplay(4, this.allInBtn, active)
end

--弃牌按钮
function TpOperationPanel.CheckGiveUpBtnDisplay(active)
    this.CheckGameObjectDisplay(5, this.giveUpBtn, active)
end

--跟按钮
function TpOperationPanel.CheckGenBtnDisplay(active)
    this.CheckGameObjectDisplay(6, this.genBtn, active)
end

--Check按钮
function TpOperationPanel.CheckCheckBtnDisplay(active)
    this.CheckGameObjectDisplay(7, this.checkBtn, active)
end

--================================================================
--
--操作后隐藏，并启动定时器来检查是否操作成功
function TpOperationPanel.HideByOperate()
    this.HideAll()
    this.StartCheckTimer()
end

function TpOperationPanel.StartCheckTimer()
    if this.checkTimer == nil then
        this.checkTimer = Timing.New(this.OnCheckTimer, 2)
    end
    this.checkTimer:Restart()
end

function TpOperationPanel.StopCheckTimer()
    if this.checkTimer ~= nil then
        this.checkTimer:Stop()
    end
end

function TpOperationPanel.OnCheckTimer()
    this.Check()
end

--检查操作项
-- playerId 
-- opList [{ --操作列表
--  op   操作枚举
--  ig    数值
--  can   能否进行该操作 0显示灰1显示亮
-- }]
--数据顺序：3个加注，跟注，ALLIN，弃牌，Check
function TpOperationPanel.Check()
    this.HideAll()
    this.StopCheckTimer()
    this.betBtnDict = {}
    LogError(">> TpOperationPanel.Check", TpDataMgr.gameStatus, TpDataMgr.operateId, TpDataMgr.userId)
    --
    if TpDataMgr.opList == nil or TpDataMgr.operateId ~= TpDataMgr.userId then
        return
    end
    LogError(">> TpOperationPanel.Check > 1")
    local mainPlayerData = TpDataMgr.GetMainPlayerData()
    if mainPlayerData ~= nil then
        LogError(">> TpOperationPanel.Check > 2")
        --
        if TpDataMgr.gameStatus == TpGameStatus.Round1 
            or TpDataMgr.gameStatus == TpGameStatus.Round2
            or TpDataMgr.gameStatus == TpGameStatus.Round3 then
            --3个下注状态，才能操作
            LogError(">> TpOperationPanel.Check > 3")
            this.opList = TpDataMgr.opList

            local isCanBet1 = this.IsOpCan(this.opList[OperateDataIndex.Bet1])
            local isCanBet2 = this.IsOpCan(this.opList[OperateDataIndex.Bet2])
            local isCanBet3 = this.IsOpCan(this.opList[OperateDataIndex.Bet3])
            --如果3个加注不能操作，则表示3个加注按钮不够显示
            if not isCanBet1 and not isCanBet2 and not isCanBet3 then
                this.CheckBet1BtnDisplay(false)
                this.CheckBet2BtnDisplay(false)
                this.CheckBet3BtnDisplay(false)
            else
                this.CheckBet1BtnDisplay(true)
                this.CheckBet2BtnDisplay(true)
                this.CheckBet3BtnDisplay(true)

                this.bet1Button.interactable = isCanBet1
                this.SetTextColor(this.bet1BtnLabel, isCanBet1)
                this.bet2Button.interactable = isCanBet2
                this.SetTextColor(this.bet2BtnLabel, isCanBet2)
                this.bet3Button.interactable = isCanBet3
                this.SetTextColor(this.bet3BtnLabel, isCanBet3)

                local betScore1 = this.GetOpValue(this.opList[OperateDataIndex.Bet1])
                local betScore2 = this.GetOpValue(this.opList[OperateDataIndex.Bet2])
                local betScore3 = this.GetOpValue(this.opList[OperateDataIndex.Bet3])

                this.bet1BtnLabel.text = betScore1
                this.bet2BtnLabel.text = betScore2
                this.bet3BtnLabel.text = betScore3

                if isCanBet1 then
                    this.betBtnDict[betScore1] = this.bet1Btn
                end
                if isCanBet2 then
                    this.betBtnDict[betScore2] = this.bet2Btn
                end
                if isCanBet3 then
                    this.betBtnDict[betScore3] = this.bet3Btn
                end
            end

            --如果Check可以操作，则不处理跟操作
            local isCanCheck = this.IsOpCan(this.opList[OperateDataIndex.Check])
            if isCanCheck then
                this.CheckCheckBtnDisplay(true)
                this.CheckGenBtnDisplay(false)
            else
                this.CheckCheckBtnDisplay(false)
                this.CheckGenBtnDisplay(true)
                local temp = this.IsOpCan(this.opList[OperateDataIndex.Gen])
                this.genButton.interactable = temp
                this.SetTextColor(this.genBtnLabel, temp)
                this.genBtnLabel.text = this.GetOpValue(this.opList[OperateDataIndex.Gen])
            end

            this.CheckAllInBtnDisplay(true)
            this.CheckGiveUpBtnDisplay(true)
        end
    end
end

--设置按钮文本颜色
function TpOperationPanel.SetTextColor(label, interactable)
    if interactable then
        label.color = ColorWhite
    else
        label.color = ColorGray
    end
end

--检测操作是否可以操作
function TpOperationPanel.IsOpCan(opData)
    if opData == nil or opData.can == 0 then
        return false
    end
    return true
end

--获取操作数据中的操作值
function TpOperationPanel.GetOpValue(opData)
    if opData ~= nil then
        return opData.ig
    end
    return 0
end

--获取发送操作数据中的操作值
function TpOperationPanel.SendOperate(index)
    if TpDataMgr.isPlayback then
        return
    end
    if this.opList ~= nil then
        local opData = this.opList[index]
        if opData ~= nil then
            TpCommand.SendOperate(opData.op, opData.ig or 0)
        end
    end
end

--================================================================
--
--处理回放的操作
function TpOperationPanel.HandlePlaybackOperate(opType, betScore)
    LogError(">> TpOperationPanel.HandlePlaybackOperate", opType, betScore)
    if TpDataMgr.isPlayback == false then
        return
    end
    if opType == TpOperateType.Bet then
        this.ShowPlaybackHand(this.betBtnDict[tonumber(betScore)])
    elseif opType == TpOperateType.Gen then
        this.ShowPlaybackHand(this.genBtn)
    elseif opType == TpOperateType.AllIn then
        this.ShowPlaybackHand(this.allInBtn)
    elseif opType == TpOperateType.GiveUp then
        this.ShowPlaybackHand(this.giveUpBtn)
    elseif opType == TpOperateType.Check then
        this.ShowPlaybackHand(this.checkBtn)
    end
end

--显示回放手
function TpOperationPanel.ShowPlaybackHand(targetGameObject)
    if targetGameObject ~= nil then
        this.SetHandDisplay(true)
        this.handTransform.position = targetGameObject.transform.position
        this.handTweener:ResetToBeginning()
        this.handTweener:PlayForward()
    end
end

--手引导相关
function TpOperationPanel.SetHandDisplay(display)
    if this.lastHandDisplay ~= display then
        this.lastHandDisplay = display
        UIUtil.SetActive(this.handGo, display)
    end
end
