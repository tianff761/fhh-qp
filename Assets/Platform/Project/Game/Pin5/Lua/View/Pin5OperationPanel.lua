Pin5OperationPanel = ClassPanel("Pin5OperationPanel");
local this = Pin5OperationPanel
local compareCardTimer = nil
local tongShaTimer = nil
--所有下注item
local allBetStateItems = {}
--推注item
local tuiZhuItems = {}

--启动事件--
function Pin5OperationPanel:OnInitUI()
    this = self
    self:InitPanel()
    SendMsg(Pin5Action.Pin5LoadEnd, 3)
    self:AddClickEvent()
end

function Pin5OperationPanel:InitPanel()
    local transform = self.transform
    --下注界面
    self.betStateNode = transform:Find("BetState")
    self.betStateNodeGo = self.betStateNode.gameObject
    self.betItemPrefab = self.betStateNode:Find("BetItem").gameObject
    self.pushItemPrefab = self.betStateNode:Find("PushItem").gameObject

    --操作按钮
    self.OperationBtns = transform:Find("OperationBtns")
    self.operationBtnsNode = self.OperationBtns.gameObject
    self.showCardBtn = self.OperationBtns:Find("ShowCardButton").gameObject
    self.tipCardBtn = self.OperationBtns:Find("TipCardButton").gameObject
    self.rubCardBtn = self.OperationBtns:Find("RubCardButton").gameObject
    self.noRubCardBtn = self.rubCardBtn.transform:Find("NoRubCardBtn").gameObject
    self.filpCardBtn = self.OperationBtns:Find("FilpCardButton").gameObject

    --抢庄倍数
    self.RobZhuangMulriple = {}
    self.RobZhuangMulriple.transform = transform:Find("RobZhuangMulriple")
    self.RobZhuangMulriple.gameObject = self.RobZhuangMulriple.transform.gameObject
    for i = -1, 4 do
        local item = self.RobZhuangMulriple.transform:Find(i)
        self.RobZhuangMulriple[i] = item
    end

    --抢庄倍数
    self.RobZhuangMulripleGray = {}
    --置灰的倍数按钮
    for i = 1, 4 do
        local item = self.RobZhuangMulriple.transform:Find(i .. "-1")
        self.RobZhuangMulripleGray[i] = item
    end

    self.compareCard = transform:Find("CompareCard").gameObject
    self.tongSha = transform:Find("TongSha").gameObject
    self.tongShaEffect = transform:Find("TongSha/Effect").gameObject

    self.rubCardPanel = transform:Find("PokerFlipCard")

    self.curHandCards = {}
    self.curHandCards.transform = self.rubCardPanel:Find("CurHandCards")
    self.curHandCards.gameObject = self.curHandCards.transform.gameObject
    for i = 1, 4 do
        table.insert(self.curHandCards, self.curHandCards.transform:Find(i):GetComponent("Image"))
    end

    local cardGroup = self.rubCardPanel:Find("CardGroup")
    self.rubPokerRubCard = cardGroup:GetComponent("PokerFlipCard")
    self.rubPokerRubCard:Init(UIConst.uiCamera)
end

--添加点击事件
function Pin5OperationPanel:AddClickEvent()
    self:AddOnClick(self.showCardBtn, this.OnClickShowCardButton)
    self:AddOnClick(self.tipCardBtn, this.OnClickTipCardButton)
    self:AddOnClick(self.rubCardBtn, this.OnClickRubCardButton)
    self:AddOnClick(self.filpCardBtn, this.OnClickFilpCardButton)

    AddMsg(Pin5Action.Pin5HideOperate, this.ResetOperation)

    for i = -1, 4 do
        self:AddOnClick(self.RobZhuangMulriple[i].gameObject,
            HandlerArgs(this.OnClickRubZhuangReslult, self.RobZhuangMulriple[i].gameObject))
    end
end

--初始化面板--
function Pin5OperationPanel:OnOpened()

end

--重置操作界面
function Pin5OperationPanel.ResetOperation()
    if this == nil then
        return
    end
    this.HideBetState()
    this.HideRobZhuangReslult()
end

--小局重置
function Pin5OperationPanel.Reset()
    --关闭比牌
    Pin5OperationPanel.HideCompareCardTongSha()
end

--销毁时自动调用
function Pin5OperationPanel:OnDestroy()
    if compareCardTimer ~= nil then
        compareCardTimer:Stop()
    end
    compareCardTimer = nil

    RemoveMsg(Pin5Action.Pin5HideOperate, this.ResetOperation)

    if tongShaTimer ~= nil then
        tongShaTimer:Stop()
    end
    tongShaTimer = nil

    allBetStateItems = {}
    tuiZhuItems = {}
end

-------------------------------------显示隐藏UI
--开关操作按钮界面 isFlip:是否翻牌类型
function Pin5OperationPanel.SetOperationBtnActive(isShow, isFlip)
    if isShow then
        if IsNil(isFlip) then
            isFlip = Pin5RoomData.GetSelfHandCardFiveFlip()
        end

        -- UIUtil.SetActive(this.showCardBtn, not isFlip)
        -- UIUtil.SetActive(this.tipCardBtn, not isFlip)
        -- UIUtil.SetActive(this.rubCardBtn, isFlip and not Pin5RoomData.IsObserver())
        -- UIUtil.SetActive(this.filpCardBtn, isFlip and not Pin5RoomData.IsObserver())

        -- UIUtil.SetActive(this.noRubCardBtn, not Pin5RoomData.isRubCard)

        UIUtil.SetActive(this.rubCardBtn, not Pin5RoomData.IsObserver())
        UIUtil.SetActive(this.noRubCardBtn, not Pin5RoomData.isRubCard)
        UIUtil.SetActive(this.showCardBtn, not Pin5RoomData.IsObserver())
    end

    this.SetOperationBtnsDisplay(isShow)
end

function Pin5OperationPanel.SetOperationBtnsDisplay(display)
    if this.lastOperationBtnsDisplay ~= display then
        this.lastOperationBtnsDisplay = display
        UIUtil.SetActive(this.operationBtnsNode, display)
    end
end

--设置推注面板的激活状态
function Pin5OperationPanel.SetBolusDisplay(display)
    if this.lastBolusDisplay ~= display then
        this.lastBolusDisplay = display
        UIUtil.SetActive(this.Bolus.gameObject, display)
    end
end

--设置下注激活状态
function Pin5OperationPanel.SetBetStateDisplay(display)
    if this.lastBetStateDisplay ~= display then
        this.lastBetStateDisplay = display
        UIUtil.SetActive(this.betStateNodeGo, display)
    end
end

--显示比牌
function Pin5OperationPanel.ShowCompareCard(funs)
    if this == nil then
        return
    end

    if compareCardTimer ~= nil then
        return
    end
    compareCardTimer = Timer.New(function()
        compareCardTimer = nil
        UIUtil.SetActive(this.compareCard, false)
        if funs ~= nil then
            funs()
        end
    end, 2, 1)
    compareCardTimer:Start()
    UIUtil.SetActive(this.compareCard, true)
end

--显示通杀
function Pin5OperationPanel.ShowTongSha()
    if this ~= nil then
        if tongShaTimer ~= nil then
            return
        end
        tongShaTimer = Timer.New(function()
            tongShaTimer = nil
            UIUtil.SetActive(this.tongSha, false)
        end, 1, 1)
        tongShaTimer:Start()
        UIUtil.SetActive(this.tongSha, true)
        UIUtil.SetActive(this.tongShaEffect, true)
    end
end

--关闭比牌通杀界面
function Pin5OperationPanel.HideCompareCardTongSha()
    UIUtil.SetActive(this.compareCard, false)
    UIUtil.SetActive(this.tongSha, false)
    UIUtil.SetActive(this.tongShaEffect, false)
end

--显示抢庄Reslult  --传入是否有倍数
function Pin5OperationPanel.ShowRobZhuangReslult(value)
    local isNilValue = #value and #value == 0
    local isObserver = Pin5RoomData.IsObserver() --是否是观战者
    for i = -1, #this.RobZhuangMulriple do
        --兼容不传value 值时，默认全显示
        local isActive = false
        if isNilValue then
            isActive = true
        else
            for _, v in ipairs(value) do
                --LogError("i", i, "v", v)
                if i == v then
                    isActive = true
                    break
                end
            end
        end

        local item = this.RobZhuangMulripleGray[i]
        if not IsNil(item) then
            UIUtil.SetActive(item, not isActive and not isObserver)
        end
        --LogError("this.RobZhuangMulriple[i].gameObject", i, isActive)
        UIUtil.SetActive(this.RobZhuangMulriple[i].gameObject, isActive and not isObserver)

        if i > Pin5RoomData.multipleValue or i == -1 then
            UIUtil.SetActive(this.RobZhuangMulriple[i].gameObject, false)
        end
    end

    UIUtil.SetActive(this.RobZhuangMulriple.gameObject, true)
end

--隐藏抢庄Reslult
function Pin5OperationPanel.HideRobZhuangReslult()
    if this.transform == nil then
        return
    end
    UIUtil.SetActive(this.RobZhuangMulriple.gameObject, false)
end

--显示下注按钮
function Pin5OperationPanel.ShowBetState(xiaZhuStr, tuiZhuStr, Restricts)
    this.SetBetStateDisplay(true)

    this.CheckShowBetBtn(xiaZhuStr, Restricts)
    this.CheckShowTuiZhuBtn(tuiZhuStr, Restricts)
end

--检测显示下注按钮
function Pin5OperationPanel.CheckShowBetBtn(xiaZhuStr, Restricts)
    local dataLength = #xiaZhuStr
    local item = nil
    local data = nil
    --显示下注分数选项
    for i = 1, dataLength do
        item = allBetStateItems[i]
        data = xiaZhuStr[i]
        if item == nil then
            item = {}
            item.gameObject = CreateGO(this.betItemPrefab, this.betStateNode, "BET-" .. tostring(i))
            item.transform = item.gameObject.transform
            item.button = item.gameObject:GetComponent(TypeButton)
            item.label = item.transform:Find("Text"):GetComponent(TypeText)
            this:AddOnClick(item.gameObject, HandlerArgs(this.OnBetBtnClick, item))
            table.insert(allBetStateItems, item)
        end
        item.data = data
        --检查限制分数，取消点击事件
        this.CheckRestrict(item, data, Restricts)
        --设置下注信息
        item.label.text = data * Pin5RoomData.diFen
        UIUtil.SetActive(item.gameObject, true)
    end

    for i = dataLength + 1, #allBetStateItems do
        item = allBetStateItems[i]
        if item.data ~= nil then
            item.data = nil
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

--检测显示推注按钮
function Pin5OperationPanel.CheckShowTuiZhuBtn(tuiZhuStr, Restricts)
    local dataLength = #tuiZhuStr
    local item = nil
    local data = nil
    --显示推注分数选项
    for i = 1, dataLength do
        item = tuiZhuItems[i]
        data = tuiZhuStr[i]
        if item == nil then
            item = {}
            item.gameObject = CreateGO(this.pushItemPrefab, this.betStateNode, "PUSH-" .. tostring(i))
            item.transform = item.gameObject.transform
            item.button = item.gameObject:GetComponent(TypeButton)
            item.label = item.transform:Find("Text"):GetComponent(TypeText)
            this:AddOnClick(item.gameObject, HandlerArgs(this.OnBetBtnClick, item))
            table.insert(tuiZhuItems, item)
        end
        item.data = data
        --检查限制分数，取消点击事件
        this.CheckRestrict(item, data, Restricts)
        --设置下注信息
        item.label.text = data * Pin5RoomData.diFen
        item.transform:SetAsLastSibling()
        UIUtil.SetActive(item.gameObject, true)
    end

    for i = dataLength + 1, #tuiZhuItems do
        item = tuiZhuItems[i]
        if item.data ~= nil then
            item.data = nil
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

--隐藏下注按钮
function Pin5OperationPanel.HideBetState()
    if this == nil then
        LogError("<<<<<<<<<<<<             Pin5OperationPanel.HideBetState  this is nil")
        return
    end
    this.SetBetStateDisplay(false)
end

--显示操作面板
function Pin5OperationPanel.Show()
    if this.gameObject == nil then
        return
    end
    UIUtil.SetActive(this.gameObject, true)
end

--显示搓牌界面
function Pin5OperationPanel.ShowRubCard(dianshu, cards, callback)
    UIUtil.SetActive(this.rubCardPanel, true)

    for i = 1, #this.curHandCards do
        if cards[i] ~= "-1" and cards[i] ~= nil then
            this.curHandCards[i].sprite = Pin5ResourcesMgr.GetHandleCardSprite(cards[i])
        end
    end

    local pBack = Pin5ResourcesMgr.GetRubCardBack()
    local pFront = Pin5ResourcesMgr.GetRubCardSprite(dianshu)
    -- local point = Pin5ResourcesMgr.GetRubCardSprite(dianshu .. "_1")
    this.rubPokerRubCard:SetPoker(pBack, pFront, callback)
end

--隐藏搓牌界面
function Pin5OperationPanel.HideRubCard()
    UIUtil.SetActive(this.rubCardPanel, false)
end

-------------------------------------点击按钮
--点击是否抢庄
function Pin5OperationPanel.OnClickRubZhuangReslult(obj)
    if Pin5RoomData.isPlayback then
        return
    end
    local num = tonumber(obj.name)
    if num == 0 then
        Pin5ResourcesMgr.PlayGameOperSound(Pin5GameSoundType.NOROB, Pin5RoomData.mainId)
    else
        Pin5ResourcesMgr.PlayGameOperSound(Pin5GameSoundType.ROB, Pin5RoomData.mainId)
    end

    if num == -1 then
        num = 1
    end

    Pin5ApiExtend.SendRobBanker(num)
    this.HideRobZhuangReslult()
end

--检查是否时被限制的分数
function Pin5OperationPanel.CheckRestrict(item, betScore, Restricts)
    if Restricts == nil or item == nil or betScore == nil then
        return
    end
    for i = 1, #Restricts do
        if tonumber(Restricts[i]) == tonumber(betScore) then
            item.button.interactable = false
            return
        end
    end
    item.button.interactable = true
end

--点击下注
function Pin5OperationPanel.OnBetBtnClick(item)
    if Pin5RoomData.isPlayback or Pin5RoomData.isGameOver then
        return
    end
    Pin5ApiExtend.SendBetState(tonumber(item.data))
end

--点击亮牌
function Pin5OperationPanel.OnClickShowCardButton(go)
    if Pin5RoomData.isPlayback or Pin5RoomData.isGameOver then
        return
    end
    --发送亮牌行为
    Pin5ApiExtend.SendShowCard()
end

--点击提示
function Pin5OperationPanel.OnClickTipCardButton(go)
    if Pin5RoomData.isPlayback or Pin5RoomData.isGameOver then
        return
    end
    --发送提示牌行为
    Pin5ApiExtend.SendTipCard()
end

--点击搓牌
function Pin5OperationPanel.OnClickRubCardButton()
    if Pin5RoomData.isPlayback or Pin5RoomData.isGameOver then
        return
    end
    local selfData = Pin5RoomData.GetSelfData()
    --发送搓牌行为
    this.ShowRubCard(selfData.fiveCard, selfData.handCards, HandlerArgs(this.OnRubCardComplete, selfData))
end

--点击翻牌
function Pin5OperationPanel.OnClickFilpCardButton()
    if Pin5RoomData.isPlayback or Pin5RoomData.isGameOver then
        return
    end

    this.SetOperationBtnActive(false)
    local selfData = Pin5RoomData.GetSelfData()
    selfData.item:PlayFlopAnim(5, selfData.fiveCard, function()
        if Pin5RoomData.gameState == Pin5GameState.WATCH_CARD and Pin5RoomData.GetSelfData().state == Pin5PlayerState.OPTION then
            this.SetOperationBtnActive(true, false)
        end
    end)
end

--搓牌回调，20240509修改为搓牌完成直接亮牌
function Pin5OperationPanel.OnRubCardComplete(selfData)
    Scheduler.scheduleOnceGlobal(function()
        this.SetOperationBtnActive(false)
        -- selfData.item:PlayFlopAnim(5, selfData.fiveCard, function()
        --     if Pin5RoomData.gameState == Pin5GameState.WATCH_CARD and Pin5RoomData.GetSelfData().state == Pin5PlayerState.OPTION then
        --         this.SetOperationBtnActive(true, false)
        --     end
        -- end)
        Pin5ApiExtend.SendShowCard()
        this.HideRubCard()
    end, 1)
end
