LYCPlayerItem = {
    ------------------UI
    gameObject = nil,
    transform = nil,

    commonEff = nil,
    --牌型动画
    cardTypeAni = nil,
    ------------------属性
    --激活
    isActive = false,
    --下标
    index = 0,
    ------------------数据
    --=玩家数据对象
    PlayerData = nil,
    --玩家id
    playerId = nil,
    --手牌
    handCardsItems = nil,
    --当前下注飞行中的金币
    betScoreGoldItems = nil,
    --当前正在飞行的牌
    curSendCards = nil,
    ------------------保存缓存
    --是否播放准备动画
    isPlayReadyAni = false,
    ------------------
    --静态数据
    --推注图标移动到的位置
    tuiZhuMove = Vector3.New(-52, 66, 0),
    --初始推注图标坐标
    tuizhuInitPos = Vector3.New(-52, 0, 0),
    ------------------ 发牌动画
    --发牌回调
    sendCardComplete = nil,
    --发牌列表
    sendCardList = nil,
    --发牌列表Timer
    sendCardListTimer = nil,
    --发牌延迟（毫秒）
    sendCardDelay = 0,
    --上次发牌时间(毫秒)
    sendCardLastTime = 0,

    --本局是否收缩过牌
    shrinkType = LYCShrinkType.None,

    --炸弹item显示坐标
    bomb_pos = nil,
    --捞腌菜动画item
    laoEffectItem = nil,
    --捞腌菜动画
    lycLaoItemAnim = nil,
    --庄家是否正在播放捞腌菜动画
    isPlayZJLaoEffect = false,
    --玩家本人是否正在播放捞腌菜动画
    isPlaySelfLaoEffect = false,
}

local meta = { __index = LYCPlayerItem }
function LYCPlayerItem.New(transform, index)
    local o = {}
    setmetatable(o, meta)
    o.transform = transform
    o.handCardsItems = {}
    o.cardTypeAni = {}
    o:InitProperty(index)
    o:InitItemUI()
    o:InitCards()
    o.sendCardList = {}
    o.betScoreGoldItems = {}
    o.curSendCards = {}

    return o
end

--初始属性数据
function LYCPlayerItem:InitProperty(index)
    self.isActive = false
    self.playerId = nil
    self.isPlayReadyAni = false
    self.index = index
end

function LYCPlayerItem:SetIsPlayReadyAni()
    self.isPlayReadyAni = false
end

--初始化UI
function LYCPlayerItem:InitItemUI()
    self.gameObject = self.transform.gameObject
    self.chatGo = self.transform:Find("Chat/ChatBox").gameObject
    self.faceGO = self.transform:Find("Chat/FaceImage").gameObject
    self.chatText = self.chatGo.transform:Find("Text"):GetComponent(TypeText)
    self.group = self.transform:Find("Group")
    self.headGroup = self.group:Find("HeadGroup")
    self.headImage = self.group:Find("HeadGroup/Head/Mask/Icon"):GetComponent("Image")
    self.goldItem = self.group:Find("HeadGroup/Head/Frame/GoldItem")
    self.bgBtn = self.group:Find("HeadGroup/Bg")
    self.imgReady = self.group:Find("HeadGroup/ImgReady")
    self.imgOffline = self.group:Find("ImgOffline")
    self.nameText = self.group:Find("HeadGroup/Name"):GetComponent("Text")
    self.idTxt = self.group:Find("HeadGroup/ID"):GetComponent("Text")
    self.scoreGoldImage = self.group:Find("HeadGroup/Score/GoldImage")
    self.scoreText = self.group:Find("HeadGroup/Score"):GetComponent("Text")
    self.bankTag = self.group:Find("HeadGroup/BankTag")
    self.addScore = self.group:Find("ScoreChange/Add")
    self.addScoreText = self.group:Find("ScoreChange/Add/AddText"):GetComponent("Text")
    self.subScore = self.group:Find("ScoreChange/Sub")
    self.subScoreText = self.group:Find("ScoreChange/Sub/SubText"):GetComponent("Text")
    self.bankeBox = self.group:Find("HeadGroup/BankeBox")
    self.lookOnImage = self.group:Find("HeadGroup/LookOnImage")
    ------------------------------下注分---------------------------
    self.goldMultiple = self.transform:Find("GoldMultiple")
    self.goldIcon = self.goldMultiple:Find("IconGold")
    self.goldBg = self.goldIcon:Find("Golds"):GetComponent(TypeImage)
    self.goldMultipleText = self.goldIcon:Find("GoldText"):GetComponent("Text")
    self.goldMultipleGoldNode = self.goldMultiple:Find("GoldNode")
    ------------------------------显示------------------------------
    self.showGroup = self.transform:Find("ShowGroup")
    self.robZhuangMultiple = self.showGroup:Find("RobZhuangMultiple")
    self.scoreMultiple = self.showGroup:Find("ScoreMultiple")
    self.imgTuizu = self.showGroup:Find("ImgTuizu")
    self.imgTuizued = self.showGroup:Find("ImgTuizued")
    self.ImgZhaKai = self.showGroup:Find("ImgZhaKai")
    self.ImgDoNotLao = self.showGroup:Find("ImgDoNotLao")
    self.ImgLao = self.showGroup:Find("ImgLao")
    self.ImgWin = self.transform:Find("Cards/ImgWin")
    self.ImgFail = self.transform:Find("Cards/ImgFail")
    self.ImgBalance = self.transform:Find("Cards/ImgBalance")
    ------------------------------手牌-------------------------------
    self.cards = {}
    self.cards.transform = self.transform:Find("Cards")
    self.cards.gameObject = self.cards.transform.gameObject
    for j = 1, 5 do
        self.cards[j] = self.cards.transform:Find(j .. "/card")
    end

    self.pointImageBg = self.cards.transform:Find("PointsBg"):GetComponent("Image")
    self.pointImage = self.cards.transform:Find("PointsBg/Points"):GetComponent("Image")
    self.pointMultiplyGo = self.cards.transform:Find("PointsBg/PointsMultiply").gameObject
    -- self.pointMultiplyNum = self.cards.transform:Find("PointsBg/PointsMultiply/PointsMultiplyNum"):GetComponent("Text")
    self.pointsYanImg = self.cards.transform:Find("PointsBg/PointsMultiply/PointsYanImg"):GetComponent("Image")
    -----------------------------亮牌结果-------------------------------------
    self.ResultType = self.transform:Find("Type")

    self.laoEffectNode = self.transform:Find("LaoEffectNode")

    self.BiPaiBtn = self.transform:Find("BiPaiBtn")
    self.BiPaiBtn:GetComponent(TypeButton).onClick:AddListener(function()
        UIUtil.SetActive(self.BiPaiBtn, false)
        LYCApiExtend.SendPlayerBiPai(self.playerId)
    end)
    self.ResultImgPosX = self.ImgWin.transform.localPosition.x
    self.MoveDistance = self.cards[2].parent.localPosition.x - self.cards[1].parent.localPosition.x

    local headRectTrans = self.group:Find("HeadGroup/Head"):GetComponent(TypeRectTransform)
    self.bomb_pos = headRectTrans.anchoredPosition
end

--隐藏玩家手牌
function LYCPlayerItem:HidePlayerHand()
    -- local playerData = LYCRoomData.playerDatas[i]
    -- playerData:HideAllCard()
end

--还原玩家UI
function LYCPlayerItem:ResetPlayerUI()
    Log("还原玩家ui", self.playerId)
    UIUtil.SetActive(self.imgTuizu.gameObject, false)
    UIUtil.SetActive(self.imgTuizued.gameObject, false)
    UIUtil.SetActive(self.addScore.gameObject, false)
    UIUtil.SetActive(self.subScore.gameObject, false)
    UIUtil.SetActive(self.bankeBox.gameObject, false)
    UIUtil.SetActive(self.bankTag.gameObject, false)
    UIUtil.SetActive(self.robZhuangMultiple.gameObject, false)
    UIUtil.SetActive(self.scoreMultiple.gameObject, false)
    UIUtil.SetActive(self.pointImage.gameObject, false)
    UIUtil.SetActive(self.pointImageBg.gameObject, false)
    for i = 1, 5 do
        UIUtil.SetActive(self.cards[i].gameObject, false)
    end
    UIUtil.SetActive(self.lookOnImage.gameObject, false)

    self:HideBetPoints()
    self:HideBalanceUI()
    self:SetNativeCards()
    self:SetPointImageActive(false)
    self:SetPlayerBombImgTagActive(false)
    self:SetPlayerLaoImgTagActive(false)
    self:SetPlayerDoNotLaoImgTagActive(false)
    self:SetPlayerLYCBiPaiResult(false)
end

--隐藏结算界面UI
function LYCPlayerItem:HideBalanceUI()
    UIUtil.SetActive(self.addScore.gameObject, false)
    UIUtil.SetActive(self.subScore.gameObject, false)
end

--隐藏item
function LYCPlayerItem:HideItem()
    if self.playerId == nil then
        return
    end
    self:SetActive(false)
end

function LYCPlayerItem:ClearData()
    self.playerId = nil
    self.isPlayReadyAni = false
    self.isPlayZJLaoEffect = false
    self.isPlaySelfLaoEffect = false
    self:Reset()
end

function LYCPlayerItem:Clear()
    -- Log(">>>>>>>>>>>>    清理item", self.gameObject.name)
    self:HideItem()
    self:SetOfflineActive(false)
    self:ResetPlayerUI()
    self:RestoreHead()
    self:ClearData()
    self.curSendCards = {}
    if self.animTimer ~= nil then
        self.animTimer:Stop()
        self.animTimer = nil
    end
end

function LYCPlayerItem:Reset()
    self.sendCardList = {}
    --当前正在飞行的牌
    Scheduler.unscheduleGlobal(self.sendCardListTimer)
    self.sendCardListTimer = nil
end

--还原头像
function LYCPlayerItem:RestoreHead()
    self.headImage.sprite = BaseResourcesMgr.headNoneSprite
end

--初始化牌信息 --传入牌UI的table
function LYCPlayerItem:InitCards()

    LogError("初始化牌信息 ------------------------------------- ", self.cards)
    self.handCardsItems = {}
    for i = 1, #self.cards do
        if i >= 4 then
            LogError("初始化牌信息 ----------- 数据出错")
            -- break
        end
        local card = LYCPokerCard:New()
        card:Init(self.cards[i].gameObject)
        table.insert(self.handCardsItems, card)
    end
end

--给UI设置玩家基本信息
function LYCPlayerItem:SetUIByPlayerData(playerId)
    --不把playerData存下来是因为playerData中存了playerItem，playerItem中再存playerData的话，容易出现死循环
    local playerData = LYCRoomData.GetPlayerDataById(playerId)
    if playerData == nil then
        LogError(">> LYCPlayerItem > SetUIByPlayerData > playerData is nil by playerId = ", playerId)
        return
    end
    --设置元宝数量 分数
    if LYCRoomData.IsGoldGame() then
        self:SetScoreText(tonumber(playerData.gold))
    else
        self:SetScoreText(playerData.playerScore)
    end

    --更新准备状态
    self:UpdatellReadyImge(playerData.state == LYCPlayerState.READY or playerData.state == LYCPlayerState.WAITING_START, true)
    --激活该gameobject
    self:SetActive(true)
    --当前玩家id与要改变的玩家id不同时
    if self.playerId ~= playerId then
        --玩家item
        LogError("<color=aqua>玩家视图和数据对象绑定</color>", playerId)
        playerData.item = self
        self.PlayerData = playerData
        --设置值之前先还原
        self:ResetPlayerUI()
        --设置玩家id
        self:SetPlayerId(playerId)
        --修改名字
        self:SetName(playerData.name)
        --修改id
        self:SetID(playerData.id)
        --更新是否是元宝图标
        UIUtil.SetActive(self.scoreGoldImage, LYCRoomData.IsGoldGame())
    end
    --设置头像
    Functions.SetHeadImage(self.headImage, Functions.CheckJoinPlayerHeadUrl(playerData.playerHead))
    --更新离线图标
    self:SetOfflineActive(not playerData.isOffline)
end

function LYCPlayerItem:SetActive(active)
    self.isActive = active
    UIUtil.SetActive(self.gameObject, active)
end

--设置玩家id
function LYCPlayerItem:SetPlayerId(playerId)
    if IsNil(playerId) then
        return
    end
    self.playerId = playerId
end

--设置名字
function LYCPlayerItem:SetName(name)
    if string.IsNullOrEmpty(name) then
        return
    end
    -- self.nameText.text = SubStringName(name)
    self.nameText.text = name
end

--设置id
function LYCPlayerItem:SetID(id)
    self.idTxt.text = id
end

--设置分数
function LYCPlayerItem:SetScoreText(score)
    if IsNil(score) then
        return
    end
    --LogError("score", score)
    score = math.NewToNumber(score)

    if LYCRoomData.IsGoldGame() then
        self.scoreText.text = score--CutNumber(score)
    else
        self.scoreText.text = score
    end
end

--更新准备 -- isCheckPlayAnim 是否检测播放准备动画
function LYCPlayerItem:UpdatellReadyImge(active, isCheckPlayAnim)
    UIUtil.SetActive(self.imgReady.gameObject, active)
    if active then
        if isCheckPlayAnim then
            self:CheckPlayReadyAnim()
        end
        --隐藏观战中
        self:SetLookOnImageActive(false)
    end
end

--检测是否播放准备动画
function LYCPlayerItem:CheckPlayReadyAnim()
    if self.isPlayReadyAni == false then
        LYCRoomAnimator.PlayReadyAnim(self.imgReady)
        self.isPlayReadyAni = true
    end
end

--设置庄图标激活状态
function LYCPlayerItem:SetZhuangImageActive(active)
    UIUtil.SetActive(self.bankTag.gameObject, active)
    UIUtil.SetActive(self.bankeBox.gameObject, active)
end

--显示显示抢庄倍数
function LYCPlayerItem:ShowRobZhuangMultiple(robZhuangState)
    --自由抢庄模式
    if LYCRoomData.gameType ~= LYCPlayType.RandomQiangZhuang then
        local state = "multiple_" .. robZhuangState
        local scoremultipleImage = self.scoreMultiple:GetComponent("Image")
        scoremultipleImage.sprite = LYCResourcesMgr.GetShowPng(state)
        scoremultipleImage:SetNativeSize()
        UIUtil.SetActive(self.scoreMultiple.gameObject, true)
    end
end

--隐藏抢庄倍数图标
function LYCPlayerItem:HideRobZhuangMultiple()
    UIUtil.SetActive(self.scoreMultiple.gameObject, false)
end

--显示抢庄枪几
function LYCPlayerItem:ShowRobZhuangNum(robZhuangState)
    Log(">> LYCPlayerItem > ShowRobZhuangNum > id = ", self.playerId, " rob = ", robZhuangState)
    --自由抢庄模式
    local state = "rob_" .. robZhuangState
    LogError("LYCRoomData.gameType", type(LYCRoomData.gameType), LYCRoomData.gameType, LYCRoomData.gameType ~= LYCPlayType.RandomQiangZhuang)
    UIUtil.SetActive(self.robZhuangMultiple.gameObject, true)
    local robzhuangImage = self.robZhuangMultiple:GetComponent("Image")
    robzhuangImage.sprite = LYCResourcesMgr.GetShowPng(state)
    robzhuangImage:SetNativeSize()
    self.robZhuangMultiple:GetComponent("Image"):SetNativeSize()
end

--隐藏抢庄抢几
function LYCPlayerItem:HideRobZhuangNum()
    UIUtil.SetActive(self.robZhuangMultiple.gameObject, false)
end

--显示下注分
function LYCPlayerItem:ShowBetPoints(xiaZhuScore)
    if LYCFuntions.IsNilOrZero(xiaZhuScore) then
        self:HideBetPoints()
        return
    end
    if not IsNil(xiaZhuScore) then
        -- self.goldMultipleText.text = xiaZhuScore * LYCRoomData.diFen
        self.goldMultipleText.text = xiaZhuScore
    end
    UIUtil.SetActive(self.goldIcon.gameObject, true)
end

--隐藏下注分
function LYCPlayerItem:HideBetPoints()
    UIUtil.SetActive(self.goldIcon.gameObject, false)
end

--设置可推注图标状态
function LYCPlayerItem:SetTuiZhuImageActive(active)
    if not IsBool(active) then
        active = false
    end
    UIUtil.SetActive(self.imgTuizu.gameObject, false)
end

--设置已推注图标状态
function LYCPlayerItem:SetTuiZhuedActive(active)
    if not IsBool(active) then
        active = false
    end
    if active then
        self:SetTuiGoldImage()
    else
        self:SetNormalGoldImage()
    end
    UIUtil.SetActive(self.imgTuizued.gameObject, active)
end

--更新玩家离线图标
function LYCPlayerItem:SetOfflineActive(active)
    if not IsBool(active) then
        active = false
    end
    UIUtil.SetActive(self.imgOffline.gameObject, active)
end

--设置牌型
---@param isBalance boolean 是否是结算 pin5用于区分提示还是结算用
---@param special number LYC特殊牌型 COMM = 0--无 SHUANGYAN = 1--双腌  SANYAN = 2--三腌  ZHADAN = 3--炸弹
function LYCPlayerItem:SetCardTypeAni(imgType, sountType, multiply, isBalance, special)
    --LogError("设置牌型", imgType)
    imgType = special == 3 and "10" or imgType
    local sprite = LYCResourcesMgr.GetResultSprite(imgType)

    self.pointImage.sprite = sprite
    self.pointImage:SetNativeSize()

    UIUtil.SetActive(self.pointMultiplyGo.gameObject, false)
    if special == 1 or special == 2 then
        UIUtil.SetActive(self.pointMultiplyGo.gameObject, true)
        self.pointsYanImg.sprite = LYCResourcesMgr.GetResultSprite("yan"..special)
        self.pointsYanImg:SetNativeSize()
    end
    -- UIUtil.SetActive(self.pointMultiplyGo.gameObject, multiply ~= "bei11")
    -- 倍数暂时不要了，换成双腌，三腌，五腌
    -- if multiply ~= "bei11" then
    --     local length = string.len(multiply)
    --     self.pointMultiplyNum.text = "x"..string.sub(multiply, 5, length)
    --     -- self.pointMultiplyImage.sprite = LYCResourcesMgr.GetResultSprite(multiply)
    --     -- self.pointMultiplyImage:SetNativeSize()
    -- end
    --self.pointImageBg.sprite = LYCResourcesMgr.GetResultBgSprite(imgType)
    --self.pointImageBg:SetNativeSize()
    self:SetPointImageActive(true)
    self:PlayResultEffect(imgType)
    LYCResourcesMgr.PlayLYCCardTypeSound(sountType, special)
end

---判断是否播放牌型动画和音效
function LYCPlayerItem:JudgeCardTypeAniPlayHandler(imgType, sountType, multiply, isBalance, special)
    --LogError("isBalance", isBalance, "self.CardTypeAniPlayed", self.CardTypeAniPlayed)
    if isBalance and self.CardTypeAniPlayed then
        --LogError("<color=aqua>结算已播放还原</color>")
        self.CardTypeAniPlayed = false
    elseif (isBalance and not self.CardTypeAniPlayed) then
        --LogError("<color=aqua>结算播放</color>")
        self:SetCardTypeAni(imgType, sountType, multiply, isBalance, special)
    elseif not isBalance then
        --LogError("<color=aqua>亮牌播放</color>")
        self.CardTypeAniPlayed = true
        self:SetCardTypeAni(imgType, sountType, multiply, isBalance, special)
    end
end


--设置点数图片激活
function LYCPlayerItem:SetPointImageActive(active)
    UIUtil.SetActive(self.pointImage.gameObject, active)
    UIUtil.SetActive(self.pointImageBg.gameObject, active)
end

--显示输赢分数
function LYCPlayerItem:ShowChangeScore(scroe)
    if scroe >= 0 then
        self.addScore.transform.localPosition = Vector3.New(0, 40, 0)
        self.addScoreText.text = "+" .. scroe
        self.addScore.gameObject:SetActive(true)
    else
        self.subScore.transform.localPosition = Vector3.New(0, 40, 0)
        self.subScoreText.text = scroe
        self.subScore.gameObject:SetActive(true)
    end
end

--显示观战中,现在不显示旁观字体
function LYCPlayerItem:SetLookOnImageActive(active)
    UIUtil.SetActive(self.lookOnImage.gameObject, false)
    -- UIUtil.SetActive(self.lookOnImage.gameObject, active)
end

--显示牌的卡槽
function LYCPlayerItem:ShowCardsSlot()
    UIUtil.SetActive(self.cards.gameObject, true)
end

--隐藏牌的卡槽
function LYCPlayerItem:HideCardsSlot()
    UIUtil.SetActive(self.cards.gameObject, false)
end

--关闭要牌中
function LYCPlayerItem:StopYaoPaiZhongAni()
    if self.yaoPaiZhongEff ~= nil then
        UIUtil.SetActive(self.yaoPaiZhongEff, false)
    end
end

--显示聊天内容
function LYCPlayerItem:ShowChatText(duration, text)
    Functions.SetChatText(self.chatGo, self.chatText, text)
    --定时关闭
    Scheduler.scheduleOnceGlobal(function()
        UIUtil.SetActive(self.chatGo, false)
    end, duration)
end

-----------------------------------
function LYCPlayerItem:PlayBankerEff(OnCompleted)
    if self.banker == nil then
        local prefab = LYCLoadResPanel.GetBankerEff()
        self.banker = CreateGO(prefab, self.group, "Banker")
        UIUtil.SetLocalPosition(self.banker, 0, 0, 0)
        self.blink = self.banker.transform:Find("blink")
        self.bankerBlinkEffect = self.blink:Find("effect")
        self.bankerffect = self.banker.transform:Find("Bankerffect")
    end

    local anim = self.bankerffect:GetComponent("UISpriteAnimation")
    anim.onCompleted = OnCompleted
    UIUtil.SetActive(self.bankerffect.gameObject, true)
    UIUtil.SetActive(self.blink.gameObject, true)
    UIUtil.SetActive(self.bankerBlinkEffect.gameObject, true)
    UIUtil.SetActive(self.banker.gameObject, true)
    LYCResourcesMgr.PlayGameSound(LYCGameEffSoundType.BecomeBanker)
end

--播放获胜动画
function LYCPlayerItem:PlayWinAni()
    if self.winEff == nil then
        local prefab = LYCLoadResPanel.GetWinEff()
        self.winEff = CreateGO(prefab, self.group, "Win")

        UIUtil.SetLocalPosition(self.winEff, 0, 0, 0)

        self.winplayer = self.winEff.transform:Find("winplayer")
        self.xingxing = self.winEff.transform:Find("xingxing")
    end

    UIUtil.SetActive(self.winEff.gameObject, true)
    UIUtil.SetActive(self.winplayer.gameObject, true)
    UIUtil.SetActive(self.xingxing.gameObject, true)
end
------------------------------------发牌-------------------
--cards:{card:11,index=1,sendCardComplete}
function LYCPlayerItem:SendCards(cards, delay)
    --if self.playerId == LYCRoomData.mainId then
    --    self:SendSelfCards(cards, delay)
    --else
    self:SendOtherCards(cards, delay)
    --end
end

--自己发牌
function LYCPlayerItem:SendSelfCards(cards, delay)
    if #cards == 0 then
        return
    end

    for i = 1, #cards do
        if i >= 4 then
            LogError("自己发牌 ----------------- 数据出错")
            -- break
        end
        table.insert(self.sendCardList, cards[i])
    end

    if IsNumber(delay) then
        self.sendCardDelay = delay * 1000
    end

    if not IsNil(self.sendCardListTimer) then
        return
    end

    local curTime = 0
    LogError("co")
    self.sendCardListTimer = Scheduler.scheduleGlobal(function()
        curTime = os.timems()
        if curTime - self.sendCardLastTime > self.sendCardDelay then
            self.sendCardLastTime = curTime
            self:SendCard(self.sendCardList[1].card, self.sendCardList[1].index, self.sendCardList[1].sendCardComplete)
            table.remove(self.sendCardList, 1)
        end

        if #self.sendCardList == 0 then
            Scheduler.unscheduleGlobal(self.sendCardListTimer)
            self.sendCardListTimer = nil
        end
    end, 0.049)
end

--其他人发牌
function LYCPlayerItem:SendOtherCards(cards)
    coroutine.start(function()
        for i = 1, #cards do
            coroutine.wait(0.05)
            self:SendCard(cards[i].card, cards[i].index, cards[i].sendCardComplete)
        end
    end)
end

--card 牌数据 count 第几张牌, sendCardComplete 发牌完成回调
function LYCPlayerItem:SendCard(card, count, sendCardComplete)
    Log("> LYCPlayerItem > SendCard > card = ", card, " count = ", count)

    if count >= 4 then
        LogError(" 发送手牌刷新 ---------- 数据出错")
        -- return
    end
    local curCardItem = self.handCardsItems[count]
    local curSendCard = nil
    LYCRoomAnimator.sendCarding = true

    for i = 1, #self.curSendCards do
        if not self.curSendCards[i].isActive then
            curSendCard = self.curSendCards[i]
            break
        end
    end

    --设置当前的牌
    if IsNil(curSendCard) then
        local tempCard = CreateGO(LYCConst.deckCardItem.gameObject, LYCConst.deckCardItem.parent, 'deing')
        curSendCard = { isActive = false, cardItem = tempCard }
        table.insert(self.curSendCards, curSendCard)
    end

    curSendCard.cardItem.transform:DOKill()
    self:RestoreFlyCardItem(curSendCard.cardItem)
    curSendCard.isActive = true

    --初始化发的牌
    curCardItem:SetPoints("-1", false)
    --还原牌坐标
    curCardItem:RestoreUpPositionY()

    ---! 放大
    local doScaleV3 = Vector3.New(0.67, 0.67, 1)
    if self.playerId == LYCRoomData.mainId then
        doScaleV3 = Vector3.New(0.8, 0.8, 1)
    end

    --local doScale = curSendCard.cardItem.transform:DOScale(doScaleV3, 0.2)
    --doScale:OnComplete(function()
    curSendCard.cardItem.transform.localScale = Vector3.New(0, 0, 1)
    local curCardItemTrans = curCardItem.transform
    local parent = curCardItemTrans.parent
    curCardItemTrans:SetParent(LYCConst.deckCardItem.parent)
    local v3 = curCardItemTrans.localPosition
    curCardItemTrans:SetParent(parent)

    ---! 移动
    local tweener = DOTween.Sequence()
    local curSendCardTrans = curSendCard.cardItem.transform
    tweener:Append(curSendCardTrans:DOLocalMove(Vector2.New(v3.x, v3.y), 0.2, true))
    tweener:Join(curSendCardTrans:DOScale(doScaleV3, 0.2))
    tweener:Join(curSendCardTrans:DOLocalRotate(Vector3(0, 0, -360), 0.2, DG.Tweening.RotateMode.FastBeyond360))

    tweener:SetEase(DG.Tweening.Ease.Linear)--(DG.Tweening.Ease.OutSine)
    tweener:OnStart(self.PlayFaPaiGameSound)

    tweener:OnComplete(function()
        UIUtil.SetActive(curSendCard.cardItem, false)

        curSendCard.isActive = false

        self:ShowCardsSlot()

        curCardItem:SetPoints(card, true)

        --发牌结束回调
        if sendCardComplete ~= nil then
            --检查点数
            sendCardComplete()
            sendCardComplete = nil
        end
        LYCRoomAnimator.sendCarding = false
    end)
    --end)
end

function LYCPlayerItem.PlayFaPaiGameSound()
    -- 发牌声音
    coroutine.start(function()
        LYCResourcesMgr.PlayFaPaiGameSound()
    end)
end

--重置飞牌
function LYCPlayerItem:RestoreFlyCardItem(item)
    ---! 玩家手牌
    item.transform.anchoredPosition = Vector3.zero
    item.transform.anchorMax = Vector2.New(0.5, 0.5)
    item.transform.sizeDelta = Vector2.New(104, 140)
    item.transform.localScale = Vector3.New(0.4, 0.4, 1)
    --设置牌背
    item:GetComponent('Image').sprite = LYCResourcesMgr.GetCardBack()
    item:SetActive(true)
end

-----------------------------------
--输赢分数动画
function LYCPlayerItem:SetPayChangeScore(score)
    if tonumber(score) >= 0 then
        self.addScore.transform.localPosition = Vector3.New(0, -40, 0)
        self.addScoreText.text = "+" .. score
        self.addScore.gameObject:SetActive(true)
        self.addScore.transform:DOLocalMove(Vector3.New(0, 20, 0), 2, false)
    else
        self.subScore.transform.localPosition = Vector3.New(0, -40, 0)
        self.subScoreText.text = score
        self.subScore.gameObject:SetActive(true)
        self.subScore.transform:DOLocalMove(Vector3.New(0, 20, 0), 2, false)
    end
end

--播放亮牌特效
function LYCPlayerItem:PlayResultEffect(type)
    if self.commonEff == nil then
        local obj = LYCResourcesMgr.GetCardAni(LYCAniCardComType)
        self.commonEff = CreateGO(obj, self.ResultType, LYCAniCardComType)
        UIUtil.SetLocalPosition(self.commonEff, 0, 0, 0)

        local size = self.index == 1 and 2 or 1
        UIUtil.SetLocalScale(self.commonEff.gameObject, size, size, 1)
    end
    UIUtil.SetActive(self.commonEff, true)
end

--设置推注（码宝）图标
function LYCPlayerItem:SetTuiGoldImage()
    -- if self.goldType and self.goldType == 2 then
    --     return
    -- end
    self.goldBg.sprite = LYCResourcesMgr.GetShowPng("game_coin_tui")
    self.goldType = 2
end

--设置飞金币图标
function LYCPlayerItem:SetGoldImageByGoldType(image)
    if self.goldType then
        if self.goldType == 1 then
            image.sprite = LYCResourcesMgr.GetShowPng("game_coin")
        else
            image.sprite = LYCResourcesMgr.GetShowPng("game_coin_tui")
        end
    end
end

--设置普通推注图标
function LYCPlayerItem:SetNormalGoldImage()
    -- if self.goldType and self.goldType == 1 then
    --     return
    -- end
    self.goldBg.sprite = LYCResourcesMgr.GetShowPng("game_coin")
    self.goldType = 1
end

--飞金币动画
function LYCPlayerItem:FlyGold(callback)
    local perfab = self.goldItem.gameObject
    local goldM = self.goldMultipleGoldNode
    --播放飞金币音效
    LYCResourcesMgr.PlayGameSound(LYCGameEffSoundType.EFFFLYCOINS)
    local count = 5
    for i = 1, count do
        local item = LYCResourcesMgr.GetFlyGoldItem(perfab, perfab.transform.parent)
        self:SetGoldImageByGoldType(item.image)
        UIUtil.SetActive(item.gameObject, true)
        item.transform.localPosition = Vector3.zero
        --item.transform.localScale = Vector3(2, 2, 2)
        item.transform:SetParent(goldM)
        ---! 移动
        local tweener = item.transform:DOLocalMove(Vector2.zero, 0.5, true)
        local Ease = DG.Tweening.Ease
        tweener:SetEase(Ease.OutSine)
        tweener:SetDelay(0.05 * i)
        --飞金币回调
        tweener:OnComplete(function()
            if LYCFuntions.GetActive(item) then
                if i == 1 then
                    if not IsNil(callback) then
                        callback()
                    end
                end
                LYCResourcesMgr.RecycleFlyGoldItem(item)
            end
            self.betScoreGoldItems[i] = nil
        end)
    end
end

function LYCPlayerItem:StopFlyGold()
    for _, item in pairs(self.betScoreGoldItems) do
        LYCResourcesMgr.RecycleFlyGoldItem(item)
    end
    self.betScoreGoldItems = {}
end
-----------------------------------------------------------
--设置所有牌
function LYCPlayerItem:ShowAllCard(cards)
    if not IsTable(cards) then
        return
    end
    --手牌
    for i = 1, #self.handCardsItems do
        self.handCardsItems[i]:Reset()
        self.handCardsItems[i]:HideCard()
    end

    --显示手牌
    for i = 1, #cards do
        if i >= 4 then
            LogError("显示手牌 ------------------ 数据出错")
            -- break
        end
        self.handCardsItems[i]:SetPoints(cards[i])
    end

    if #cards > 0 then
        --显示卡槽 --里面只有激活方法，重复调用消耗不计
        self:ShowCardsSlot()
    end
end

--播放玩家的牌的翻牌动画
function LYCPlayerItem:PlayFlopAllAni(cardList)
    --LogError("LYCPlayerItem:PlayFlopAllAni", LYCRoomData.isCardGameStarted)
    --if LYCRoomData.isCardGameStarted == false then
    --    return
    --end
    for i = 1, #cardList do
        if i >= 4 then
            LogError("播放玩家的牌的翻牌动画 ------------------ 数据出错")
            -- break
        end
        self:PlayFlopAni(i, cardList[i])
    end
end

--播放玩家的牌的翻牌动画
function LYCPlayerItem:PlayFlopAni(index, card, callback)
    --LogError("self.handCardsItems", self.handCardsItems)
    self.handCardsItems[index]:PlayFlopAni(card, function()
        local playerData = LYCRoomData.GetPlayerDataById(self.playerId)
        playerData.handCards[index] = card

        if callback ~= nil then
            callback()
        end
    end)
end

--清空扑克设置
function LYCPlayerItem:ResetPokerData()
    for i = 1, #self.handCardsItems do
        self.handCardsItems[i]:Reset()
    end
end

--隐藏玩家的所有牌
function LYCPlayerItem:HideAllCard()
    for i = 1, #self.handCardsItems do
        self.handCardsItems[i]:HideCard()
    end
end

--检查牌
function LYCPlayerItem:CheckCards(handCards)
    for i = 1, #self.handCardsItems do
        if handCards[i] == nil then
            self.handCardsItems[i]:HideCard()
        else
            self.handCardsItems[i]:SetPoints(handCards[i])
        end
    end
end

--隐藏某张牌
function LYCPlayerItem:HideOneCard(index)
    if not IsNil(self.handCardsItems[index]) then
        self.handCardsItems[index]:HideCard()
    end
end

--还原牌排序
function LYCPlayerItem:SetNativeCards()
    if self.playerId ~= LYCRoomData.mainId then
        return
    end
    self.shrinkType = LYCShrinkType.None
    for i = -2, 2 do --只处理前三张牌
    -- for i = -2, 0 do
        self.handCardsItems[i + 3]:RestoreUpPositionY()
        self.handCardsItems[i + 3]:SetParentLocalPosition(Vector3(i * LYCMainPlayerCardInv.Normal, 0, 0))
    end
end

--收缩牌排序
function LYCPlayerItem:SetShrinkCards()
    --if self.playerId ~= LYCRoomData.mainId or self.shrinkType == LYCShrinkType.Shrink then
    --    return
    --end
    --self.shrinkType = LYCShrinkType.Shrink
    --for i = -2, 2 do
    --    self.handCardsItems[i + 3]:SetParentLocalPosition(Vector3(i * LYCMainPlayerCardInv.Shrink, 0, 0))
    --end
end

--三二牌排序
function LYCPlayerItem:SetThreeBinaryCards()
    if self.playerId ~= LYCRoomData.mainId or self.shrinkType == LYCShrinkType.shrinkType then
        return
    end
    self.shrinkType = LYCShrinkType.ThreeBinary
    local x = 0
    for i = -2, 2 do --只处理前三张牌
    -- for i = -2, 0 do
        x = i * LYCMainPlayerCardInv.Shrink
        if i > 0 then
            x = x + LYCMainPlayerCardInv.ThreeBinary
        end
        self.handCardsItems[i + 3]:SetParentLocalPosition(Vector3(x, 0, 0))
    end
end

--提起第五张牌
function LYCPlayerItem:UpFiveCard(isPlayAni)
    local playerData = LYCRoomData.GetPlayerDataById(self.playerId)
    local handCard = nil
    for i = 1, #self.handCardsItems do
        handCard = self.handCardsItems[i]
        if handCard.point == playerData.fiveCard then
            if self.playerId == LYCRoomData.mainId then
                handCard:DOLocalMoveUpPositionY(38, isPlayAni)
            else
                handCard:DOLocalMoveUpPositionY(18, isPlayAni)
            end
            handCard:SetAvtiveFiveCardTip(true)
        else
            handCard:RestoreUpPositionY()
        end
    end
end

---炸开玩家不能比牌
function LYCPlayerItem:SetBiPaiBtn(bool)
    self.isShowBiPai = false
    if not IsNil(self.PlayerData) then
        local playerData = LYCRoomData.GetPlayerDataById(self.playerId)
        if bool then
            bool = (self.PlayerData.isBiPai == nil or not self.PlayerData.isBiPai) and not self.PlayerData.isZhaKai and bool and not (LYCRoomData.isCardGameStarted and self.PlayerData.state == LYCPlayerState.WAITING)
            -- bool = not self.PlayerData.isZhaKai and bool and not (LYCRoomData.isCardGameStarted and self.PlayerData.state == LYCPlayerState.WAITING)
            --短线重连时，已经必过的牌直接显示手牌
            if self.PlayerData.isBiPai == true and playerData ~= nil and #playerData.handCards > 0 then
                self:PlayFlopAllAni(playerData.handCards)
            end
        end

        self.isShowBiPai = bool 
        --庄家正在播放捞腌菜动画时不显示按钮
        if not self.isPlayZJLaoEffect and not self.isPlaySelfLaoEffect then
            -- Log("  没有手牌的玩家不显示比牌按钮  --------- ", self.playerId, playerData == nil)
            --没有手牌的玩家不显示比牌按钮
            if bool and (playerData == nil or #playerData.handCards == 0) then
                LogError("没有手牌的玩家不显示比牌按钮")
                return
            end
            -- UIUtil.SetActive(self.BiPaiBtn, false) --隐藏比牌按钮
            UIUtil.SetActive(self.BiPaiBtn, bool)
        end
        -- UIUtil.SetActive(self.BiPaiBtn, false) --比牌按钮资源为空，就不显示按钮
    end
end

---玩家炸开显示
function LYCPlayerItem:SetPlayerBombImgTagActive(bool)
    UIUtil.SetActive(self.ImgZhaKai, bool)
end

---玩家捞牌显示
function LYCPlayerItem:SetPlayerLaoImgTagActive(bool)
    UIUtil.SetActive(self.ImgLao, bool)
end

---玩家不捞牌显示
function LYCPlayerItem:SetPlayerDoNotLaoImgTagActive(bool)
    if bool then
        self.isPlaySelfLaoEffect = false
        --主玩家是庄家选择不捞牌，且庄家是否捞牌为true时，强制修正为false
        if self.playerId == LYCRoomData.BankerPlayerId and self.isPlayZJLaoEffect then
            -- LogError(" 主玩家是庄家选择不捞牌，且庄家是否捞牌为true时，强制修正为false")
            LYCRoomPanel.SetAllPlayerItemsIsPlayLaoEffect(false)
        end
    end
    UIUtil.SetActive(self.ImgDoNotLao, bool)
end

---比牌结果显示
---@param active boolean 控制结果节点显示
---@param resultNum number  1表示赢 0表示平 -1 表示输
function LYCPlayerItem:SetPlayerLYCBiPaiResult(active, resultNum)
    if active and LYCRoomData.BankerPlayerId ~= self.playerId then
        UIUtil.SetActive(self.ImgWin, resultNum == 1)
        UIUtil.SetActive(self.ImgFail, resultNum == -1)
        UIUtil.SetActive(self.ImgBalance, resultNum == 0)
        self:MainPlayerBiPaiResultPositionAdapter(resultNum)
    else
        UIUtil.SetActive(self.ImgWin, false)
        UIUtil.SetActive(self.ImgFail, false)
        UIUtil.SetActive(self.ImgBalance, false)
    end
end

function LYCPlayerItem:MainPlayerBiPaiResultPositionAdapter(resultNum)
    local transform = resultNum == 1 and self.ImgWin or (resultNum == 0 and self.ImgBalance or self.ImgFail)
    if self.playerId == LYCRoomData.mainId then
        LogError("self.PlayerData.isLao", self.PlayerData.isLao)
        local posX = self.PlayerData.isLao and self.ResultImgPosX or self.ResultImgPosX - self.MoveDistance
        LogError("posX", posX)
        transform.localPosition = Vector3.New(posX, transform.localPosition.y, 0)
    end
end

--庄家是否正在播放捞腌菜动画
function LYCPlayerItem:SetIsPlayLaoEffect(isBool)
    self.isPlayZJLaoEffect = isBool
end

--玩家本人是否正在播放捞腌菜动画
function LYCPlayerItem:IsPlaySelfLaoEffect()
    return self.isPlaySelfLaoEffect
end

--设置播放捞腌菜动画显示
function LYCPlayerItem:SetPlayLaoEffect(lycLaoItem, LaoCard)
    if self.laoEffectItem == nil then
        self.laoEffectItem = CreateGO(lycLaoItem, self.laoEffectNode)
        self.lycLaoItemAnim = self.laoEffectItem.transform:GetComponent(TypeSkeletonGraphic)
        UIUtil.SetAnchoredPosition(self.laoEffectItem, 0, 0)
    end
    UIUtil.SetActive(self.laoEffectItem, true)
    local temp = self.lycLaoItemAnim.SkeletonData:FindAnimation("animation")
    if temp ~= nil then
        self.lycLaoItemAnim.AnimationState:SetAnimation(0, "animation", false)
    end

    self.isPlaySelfLaoEffect = true

    -- ---庄家播放捞腌菜动画时，所有玩家 isPlayZJLaoEffect 为true，防止其他玩家显示比牌按钮
    -- if self.playerId == LYCRoomData.BankerPlayerId then
    --     LYCRoomPanel.SetAllPlayerItemsIsPlayLaoEffect(true)
    --     LYCRoomPanel.SetAllPlayerItemsBiPaiBtnActive(false)
    -- end
    if self.animTimer == nil then
        self.animTimer = Timing.New(
            function ()
                self.animTimer:Stop()
                self.animTimer = nil
                
                --庄家播放捞腌菜动画后，如果处于比牌阶段，则其余玩家显示比牌按钮
                if self.isShowBiPai == true then
                    if self.playerId == LYCRoomData.BankerPlayerId then
                        -- LYCRoomPanel.SetAllPlayerItemsIsPlayLaoEffect(false)
                        -- LYCRoomPanel.SetAllPlayerItemsBiPaiBtnActive(true)
                    else
                        UIUtil.SetActive(self.BiPaiBtn, self.isShowBiPai)
                    end
                end
                self.isPlaySelfLaoEffect = false
                UIUtil.SetActive(self.laoEffectItem, false)
                self:SendCard(LaoCard, 3, function()
                    self:PlayFlopAni(3, LaoCard)
                end)
                LYCResourcesMgr.PlayLYCGameSound("laoyizhang")
            end
        , 1.5)
    end
    self.animTimer:Start()
end

return LYCPlayerItem