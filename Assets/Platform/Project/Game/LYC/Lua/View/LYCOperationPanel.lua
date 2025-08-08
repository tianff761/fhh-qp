LYCOperationPanel = ClassPanel("LYCOperationPanel");
local this = LYCOperationPanel
local compareCardTimer = nil
local laoDelayTimer = nil
local zhaKaiDelayTimer = nil
local mSelf = nil
local tongShaTimer = nil
--所有下注item
local allBetStateItems = {}
--推注item
local tuiZhuItem = {}
--当前操作牌
local curCards = nil

local clickInterval = 0.8 * 1000

local rubOnComplete = nil

--启动事件--
function LYCOperationPanel:OnInitUI()
    mSelf = self
    self:InitPanel()
    SendMsg(LYCAction.LYCLoadEnd, 3)
    Log(">>>>>>>>>>>>>>>>>>>       加载操作结束")

    self:AddClickEvent()
end

function LYCOperationPanel:InitPanel()
    local transform = self.transform
    --下注界面
    self.BetState = transform:Find("BetState")
    self.BetStateItem = self.BetState:Find("betItem").gameObject
    self.pushNoitItem = self.BetState:Find("pushItem").gameObject
    self.BetStateDouble = self.BetState:Find("Double")
    self.BetStateBolusitem = self.BetState:Find("bolusitem")

    --操作按钮
    self.BombButton = transform:Find("BombButton")
    self.BombButtonText = self.BombButton:Find("Text")
    self.OperationBtns = transform:Find("OperationBtns")
    --self.showCardBtn = self.OperationBtns:Find("ShowCardButton").gameObject
    --self.tipCardBtn = self.OperationBtns:Find("TipCardButton").gameObject
    self.LaoCardButton = self.OperationBtns:Find("LaoCardButton").gameObject
    self.DoNotLaoCardButton = self.OperationBtns:Find("DoNotLaoCardButton").gameObject
    --self.filpCardBtn = self.OperationBtns:Find("FilpCardButton").gameObject

    --抢庄倍数
    self.RobZhuangMulriple = {}
    self.RobZhuangMulriple.transform = transform:Find("RobZhuangMulriple")
    self.RobZhuangMulriple.gameObject = self.RobZhuangMulriple.transform.gameObject
    for i = -1, 4 do
        local item = {}
        item.obj = self.RobZhuangMulriple.transform:Find(i).gameObject
        item.num = item.obj.transform:Find("Text"):GetComponent("Text")
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
function LYCOperationPanel:AddClickEvent()
    --self:AddOnClick(self.showCardBtn, this.OnClickShowCardButton)
    --self:AddOnClick(self.tipCardBtn, this.OnClickTipCardButton)
    self:AddOnClick(self.LaoCardButton, this.OnClickLaoCardButton)
    self:AddOnClick(self.DoNotLaoCardButton, this.OnClickDoNotLaoCardButton)
    self:AddOnClick(self.BombButton, this.OnClickBombButton)
    --self:AddOnClick(self.filpCardBtn, this.OnClickFilpCardButton)

    AddMsg(LYCAction.LYCHideOperate, this.ResetOperation)

    for i = -1, 4 do
        self:AddOnClick(self.RobZhuangMulriple[i].obj, HandlerArgs(this.OnClickRubZhuangReslult, self.RobZhuangMulriple[i].obj))
    end
end

--初始化面板--
function LYCOperationPanel:OnOpened()

end

--重置操作界面
function LYCOperationPanel.ResetOperation()
    if mSelf == nil then
        return
    end
    this.HideBetState()
    this.HideRobZhuangReslult()
end

--小局重置
function LYCOperationPanel.Reset()
    --关闭比牌
    LYCOperationPanel.HideCompareCardTongSha()
end

--销毁时自动调用
function LYCOperationPanel:OnDestroy()
    if compareCardTimer ~= nil then
        compareCardTimer:Stop()
    end
    compareCardTimer = nil

    if laoDelayTimer ~= nil then
        laoDelayTimer:Stop()
    end
    laoDelayTimer = nil
    
    if zhaKaiDelayTimer ~= nil then
        zhaKaiDelayTimer:Stop()
    end
    zhaKaiDelayTimer = nil
    
    -- mSelf = nil

    RemoveMsg(LYCAction.LYCHideOperate, this.ResetOperation)

    if tongShaTimer ~= nil then
        tongShaTimer:Stop()
    end
    tongShaTimer = nil

    allBetStateItems = {}
    tuiZhuItem = {}
    curCards = nil
    mSelf = nil
end

-------------------------------------显示隐藏UI
--开关操作按钮界面 isFlip:是否翻牌类型
function LYCOperationPanel.SetOperationBtnActive(isShow, isFlip)
    --if isShow then
    --    if IsNil(isFlip) then
    --        isFlip = LYCRoomData.GetSelfHandCardFiveFlip()
    --    end
    --    --UIUtil.SetActive(mSelf.showCardBtn, not isFlip)
    --    --UIUtil.SetActive(mSelf.tipCardBtn, not isFlip)
    --
    --    UIUtil.SetActive(mSelf.noRubCardBtn, not LYCRoomData.isRubCard)
    --end
    --UIUtil.SetActive(mSelf.OperationBtns.gameObject, isShow)
    if not isShow then
        --LogError("<color=aqua>SetOperationBtnActive false</color>")
        this.SetLaoPaiBtnActive(isShow)
        LYCRoomPanel.SetAllPlayerItemsBiPaiBtnActive(isShow)
        this.SetBombButtonActive(isShow)
    end
end

--单独设置捞牌和不牌按钮显示
function LYCOperationPanel.SetLaoPaiBtnActiveShow(isShowLao, isShowNoLao)
    --其他玩家正在播放捞腌菜动画，主玩家延时2秒显示按钮
    if LYCRoomPanel.GetPlaySelfLaoEffect() then
        if laoDelayTimer == nil then
            laoDelayTimer = Timing.New(
                function ()
                    laoDelayTimer:Stop()
                    laoDelayTimer = nil
                    UIUtil.SetActive(mSelf.OperationBtns.gameObject, true)
                    UIUtil.SetActive(mSelf.LaoCardButton, isShowLao and not LYCRoomData.IsObserver())
                    UIUtil.SetActive(mSelf.DoNotLaoCardButton, isShowNoLao and not LYCRoomData.IsObserver())
                end
            , 2)
        end
        laoDelayTimer:Start()
    else
        UIUtil.SetActive(mSelf.OperationBtns.gameObject, true)
        UIUtil.SetActive(mSelf.LaoCardButton, isShowLao and not LYCRoomData.IsObserver())
        UIUtil.SetActive(mSelf.DoNotLaoCardButton, isShowNoLao and not LYCRoomData.IsObserver())
    end
end

function LYCOperationPanel.SetLaoPaiBtnActive(isShow)
    --LogError("<color=aqua>SetLaoPaiBtnActive</color>", isShow)
    UIUtil.SetActive(mSelf.OperationBtns.gameObject, isShow)
    UIUtil.SetActive(mSelf.LaoCardButton, isShow and not LYCRoomData.IsObserver())
    UIUtil.SetActive(mSelf.DoNotLaoCardButton, isShow and not LYCRoomData.IsObserver())
end

---@param active boolean 显示
function LYCOperationPanel.SetBombButtonActive(active)
    --LogError("<color=aqua>SetBombButtonActive</color>", isShow)
    --自动炸开，玩家操作炸开按钮隐藏
    if active then
        --其他玩家正在播放捞腌菜动画，主玩家延时2秒炸开
        if LYCRoomPanel.GetPlaySelfLaoEffect() then
            if zhaKaiDelayTimer == nil then
                zhaKaiDelayTimer = Timing.New(
                    function ()
                        zhaKaiDelayTimer:Stop()
                        zhaKaiDelayTimer = nil
                        this.OnClickBombButton()
                    end
                , 2)
            end
            zhaKaiDelayTimer:Start()
        else
            this.OnClickBombButton()
        end
    end

    -- UIUtil.SetActive(mSelf.BombButton, active)
    -- local countdownText = countdown
    -- if active and countdown then
    --     Scheduler.scheduleOnceGlobal(function()
    --         countdownText = countdownText - 1
    --         UIUtil.SetText(mSelf.BombButtonText, "炸 开(" .. countdownText .. ")")
    --     end, countdown)
    -- end
end

--设置推注面板的激活状态
function LYCOperationPanel.SetBolusActive(isShow)
    UIUtil.SetActive(mSelf.Bolus.gameObject, isShow)
end

--设置下注激活状态
function LYCOperationPanel.SetBetState(isShow)
    UIUtil.SetActive(mSelf.BetState.gameObject, isShow)
end

--显示比牌
function LYCOperationPanel.ShowCompareCard(funs)
    if mSelf == nil then
        return
    end

    if compareCardTimer ~= nil then
        return
    end
    compareCardTimer = Timer.New(function()
        compareCardTimer = nil
        UIUtil.SetActive(mSelf.compareCard, false)
        if funs ~= nil then
            funs()
        end
    end, 2, 1)
    compareCardTimer:Start()
    UIUtil.SetActive(mSelf.compareCard, true)
end

--显示通杀
function LYCOperationPanel.ShowTongSha()
    if mSelf ~= nil then
        if tongShaTimer ~= nil then
            return
        end
        tongShaTimer = Timer.New(function()
            tongShaTimer = nil
            UIUtil.SetActive(mSelf.tongSha, false)
        end, 1, 1)
        tongShaTimer:Start()
        UIUtil.SetActive(mSelf.tongSha, true)
        UIUtil.SetActive(mSelf.tongShaEffect, true)
    end
end

--关闭比牌通杀界面
function LYCOperationPanel.HideCompareCardTongSha()
    UIUtil.SetActive(mSelf.compareCard, false)
    UIUtil.SetActive(mSelf.tongSha, false)
    UIUtil.SetActive(mSelf.tongShaEffect, false)
end

--显示抢庄Reslult  --传入是否有倍数
function LYCOperationPanel.ShowRobZhuangReslult(value)
    local isNilValue = #value and #value == 0 --没有倍数，默认不抢
    for i = -1, #mSelf.RobZhuangMulriple do
        --兼容不传value 值时，默认全显示
        local isActive = false
        local num = nil
        --服务器没发倍数的话，则默认显示不抢
        if isNilValue then     
            isActive = i == 0
        else
            --不抢按钮
            if i == 0 then
                isActive = true
            --倍数按钮
            elseif i > 0 and i <= #value then
                num = value[i]
                isActive = true
            end
        end
        
        local item = mSelf.RobZhuangMulripleGray[i]
        if not IsNil(item) then
            --UIUtil.SetActive(item, not isActive)
        end

        UIUtil.SetActive(mSelf.RobZhuangMulriple[i].obj, isActive)

        if num ~= nil then
            mSelf.RobZhuangMulriple[i].num.text = num.."倍"
        end

        if i == -1 then
            UIUtil.SetActive(mSelf.RobZhuangMulriple[i].obj, false)
        end
    end

    UIUtil.SetActive(mSelf.RobZhuangMulriple.gameObject, true)
end

--隐藏抢庄Reslult
function LYCOperationPanel.HideRobZhuangReslult()
    if mSelf.transform == nil then
        return
    end
    UIUtil.SetActive(mSelf.RobZhuangMulriple.gameObject, false)
end

--显示下注按钮 flag 0/1/2 普通押注/码宝/走水
function LYCOperationPanel.ShowBetState(xiaZhuStr, tuiZhuStr, Restricts, flag)
    --关闭所有的下注选项
    for i = 1, #allBetStateItems do
        UIUtil.SetActive(allBetStateItems[i], false)
    end
    --关闭所有的推注选项
    for i = 1, #tuiZhuItem do
        UIUtil.SetActive(tuiZhuItem[i], false)
    end

    mSelf.SetBetState(true)
    --显示下注分数选项
    --押注或走水，分数为最后一位
    for i = 1, #xiaZhuStr do
        --码宝分数小于普通押注分数的话，就不显示码宝按钮
        if i == #xiaZhuStr and flag == 1 and xiaZhuStr[i] <= xiaZhuStr[i - 1] then
            -- LogError("  码宝分数和普通押注分数相同的话，就不显示码宝按钮 ++++++++++++++++  ",xiaZhuStr[i], xiaZhuStr[i - 1])
            break
        end
        local item
        if allBetStateItems[i] == nil then
            item = CreateGO(mSelf.BetStateItem.gameObject, mSelf.BetState, i)
            item.transform.localPosition = Vector3.New(item.transform.localPosition.x, item.transform.localPosition.y, 0)
            allBetStateItems[i] = item
            this:AddOnClick(item, HandlerArgs(this.OnClickXiaZhu, item))
        else
            item = allBetStateItems[i]
        end
        local image = item:GetComponent(TypeImage)
        image.sprite = LYCResourcesMgr.GetShowPng("game_coin")
        if i == #xiaZhuStr then
            if flag == 1 then
                image.sprite = LYCResourcesMgr.GetShowPng("BetItem_MaBao")
            elseif flag == 2 then
                image.sprite = LYCResourcesMgr.GetShowPng("BetItem_ZouShui")
            end
        end
        
        if item ~= nil then
            --检查限制分数，取消点击事件
            this.CheckRestrict(item, xiaZhuStr[i], Restricts)
            --设置下注信息
            -- item.transform:Find("Text"):GetComponent("Text").text = xiaZhuStr[i] * LYCRoomData.diFen
            item.transform:Find("Text"):GetComponent("Text").text = xiaZhuStr[i]
            item.name = xiaZhuStr[i]
            UIUtil.SetActive(item.gameObject, true)
        end
    end

    -- this.ShowTuiZhu(tuiZhuStr, Restricts)
end

-- --显示推注信息
-- function LYCOperationPanel.ShowTuiZhu(tuiZhuStr, Restricts)
--     for i = 1, #tuiZhuStr do
--         local item
--         if tuiZhuItem[i] == nil then
--             item = CreateGO(mSelf.pushNoitItem.gameObject, mSelf.BetState, i)
--             item.transform.localPosition = Vector3.New(item.transform.localPosition.x, item.transform.localPosition.y, 0)
--             tuiZhuItem[i] = item
--             this:AddOnClick(item, HandlerArgs(this.OnClickXiaZhu, item))
--         else
--             item = tuiZhuItem[i]
--         end

--         if item ~= nil then
--             --设置下注信息
--             --检查限制分数，取消点击事件
--             this.CheckRestrict(item, tuiZhuStr[i], Restricts)
--             item.transform:Find("Text"):GetComponent("Text").text = tuiZhuStr[i] * LYCRoomData.diFen
--             item.name = tuiZhuStr[i]
--             item.transform:SetAsLastSibling()
--             UIUtil.SetActive(item.gameObject, true)
--         end
--     end
-- end

--隐藏下注按钮
function LYCOperationPanel.HideBetState()
    if mSelf == nil then
        LogError("<<<<<<<<<<<<             LYCOperationPanel.HideBetState  mself is nil")
        return
    end
    mSelf.SetBetState(false)
end


--显示操作面板
function LYCOperationPanel.Show()
    if mSelf.gameObject == nil then
        return
    end
    UIUtil.SetActive(mSelf.gameObject, true)
end

--显示搓牌界面
function LYCOperationPanel.ShowRubCard(dianshu, cards, callback)
    UIUtil.SetActive(mSelf.rubCardPanel, true)

    for i = 1, #mSelf.curHandCards do
        if cards[i] ~= "-1" and cards[i] ~= nil then
            mSelf.curHandCards[i].sprite = LYCResourcesMgr.GetHandleCardSprite(cards[i])
        end
    end

    local pBack = Pin5ResourcesMgr.GetRubCardBack()
    local pFront = Pin5ResourcesMgr.GetRubCardSprite(dianshu)
    -- local point = Pin5ResourcesMgr.GetRubCardSprite(dianshu .. "_1")
    this.rubPokerRubCard:SetPoker(pBack, pFront, callback)
end

--隐藏搓牌界面
function LYCOperationPanel.HideRubCard()
    UIUtil.SetActive(mSelf.rubCardPanel, false)
end
-------------------------------------点击按钮
--点击是否抢庄
function LYCOperationPanel.OnClickRubZhuangReslult(obj)
    if LYCRoomData.isPlayback then
        return
    end
    local num = tonumber(obj.name)
    if num == 0 then
        LYCResourcesMgr.PlayGameOperSound(LYCGameSoundType.NOROB, LYCRoomData.mainId)
    else
        LYCResourcesMgr.PlayGameOperSound(LYCGameSoundType.ROB, LYCRoomData.mainId)
    end

    if num == -1 then
        num = 1
    end

    LYCApiExtend.SendRobBanker(num)
    this.HideRobZhuangReslult()
end

--检查是否时被限制的分数
function LYCOperationPanel.CheckRestrict(item, betScore, Restricts)
    if Restricts == nil or item == nil or betScore == nil then
        return
    end
    for i = 1, #Restricts do
        if tonumber(Restricts[i]) == tonumber(betScore) then
            item:GetComponent("Button").interactable = false
            return
        end
    end
    item:GetComponent("Button").interactable = true
end

--点击下注
function LYCOperationPanel.OnClickXiaZhu(item)
    if LYCRoomData.isPlayback or LYCRoomData.isGameOver then
        return
    end
    LYCApiExtend.SendBetState(tonumber(item.name))
end

--点击亮牌
function LYCOperationPanel.OnClickShowCardButton(go)
    if LYCRoomData.isPlayback or LYCRoomData.isGameOver then
        return
    end
    --发送亮牌行为
    LYCApiExtend.SendShowCard()
end

--点击提示
function LYCOperationPanel.OnClickTipCardButton(go)
    if LYCRoomData.isPlayback or LYCRoomData.isGameOver then
        return
    end
    --发送提示牌行为
    LYCApiExtend.SendTipCard()
end

--点击搓牌
function LYCOperationPanel.OnClickLaoCardButton()
    --if LYCRoomData.isPlayback or LYCRoomData.isGameOver then
    --    return
    --end
    --local selfData = LYCRoomData.GetSelfData()
    ----发送搓牌行为
    --this.ShowRubCard(selfData.fiveCard, selfData.handCards, HandlerArgs(this.OnRubCardComplete, selfData))
    LYCApiExtend.SendPlayerLaoPai(true)
    this.SetOperationBtnActive(false)
end

function LYCOperationPanel.OnClickDoNotLaoCardButton()
    LYCApiExtend.SendPlayerLaoPai(false)
    this.SetOperationBtnActive(false)
end

function LYCOperationPanel.OnClickBombButton()
    LYCApiExtend.SendPlayerBomb(true)
    this.SetOperationBtnActive(false)
end

--点击翻牌
function LYCOperationPanel.OnClickFilpCardButton()
    if LYCRoomData.isPlayback or LYCRoomData.isGameOver then
        return
    end

    --this.SetOperationBtnActive(false)
    local selfData = LYCRoomData.GetSelfData()
    selfData.item:PlayFlopAni(5, selfData.fiveCard, function()
        if LYCRoomData.gameState == LYCGameState.WATCH_CARD and LYCRoomData.GetSelfData().state == LYCPlayerState.OPTION then
            --this.SetOperationBtnActive(true, false)
        end
    end)
end

--搓牌回调
function LYCOperationPanel.OnRubCardComplete(selfData)
    Scheduler.scheduleOnceGlobal(function()
        --this.SetOperationBtnActive(false)
        selfData.item:PlayFlopAni(5, selfData.fiveCard, function()
            if LYCRoomData.gameState == LYCGameState.WATCH_CARD and LYCRoomData.GetSelfData().state == LYCPlayerState.OPTION then
                --this.SetOperationBtnActive(true, false)
            end
        end)
        this.HideRubCard()
    end, 1)
end