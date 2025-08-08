SDBPlayerItem = {
    ------------------UI
    gameObject = nil,
    transform = nil,

    blastCardEff = nil,
    bianShuEff = nil,
    ------------------属性
    --激活
    isActive = false,
    --下标
    index = 0,
    ------------------数据
    --玩家id
    playerId = nil,
    --手牌
    handCardsItems = {},
    --当前下注飞行中的金币
    betScoreGoldItems = {},
    --当前正在飞行的牌
    curSendCard = nil,
    ------------------保存缓存
    --是否播放准备动画
    isPlayReadyAni = false,
    ------------------
    --静态数据
    --推注图标移动到的位置
    tuiZhuMove = Vector3.New(-54, 70, 0),
    --初始推注图标坐标
    tuizhuInitPos = Vector3.New(-54, 0, 0),
    ------------------ 发牌动画
    --发牌第一阶段timer
    sendCardTimer = nil,
    --发牌第二阶段timer
    sendCardTimer2 = nil,
    --发牌回调
    sendCardComplete = nil,
    --当前正在发的牌UI（手牌）
    curCardItem = nil,
    --当前正在发的牌数据(花色及点数)
    curCardData = nil,
    --发牌中timer
    cardingTimer = nil,
}

local meta = { __index = SDBPlayerItem }
function SDBPlayerItem.New(transform, index)
    local o = {}
    setmetatable(o, meta)
    o.transform = transform
    o:InitProperty(index)
    o:InitItemUI()
    o:InitCards()
    return o
end

--初始属性数据
function SDBPlayerItem:InitProperty(index)
    self.isActive = false
    self.playerId = nil
    self.isPlayReadyAni = false
    self.index = index
end

function SDBPlayerItem:SetIsPlayReadyAni()
    self.isPlayReadyAni = false
end

--初始化UI
function SDBPlayerItem:InitItemUI()
    self.gameObject = self.transform.gameObject
    self.chatGo = self.transform:Find("Chat/ChatBox").gameObject
    self.faceGO = self.transform:Find("Chat/FaceImage").gameObject
    self.chatText = self.chatGo.transform:Find("Text"):GetComponent(TypeText)
    self.group = self.transform:Find("Group")
    self.headGroup = self.group:Find("HeadGroup")
    self.headImage = self.group:Find("HeadGroup/HeadIcon"):GetComponent("Image")
    self.goldItem = self.group:Find("HeadGroup/HeadBox/GoldItem")
    self.bgBtn = self.group:Find("HeadGroup/Bg")
    self.imgReady = self.group:Find("HeadGroup/ImgReady")
    self.imgOffline = self.group:Find("ImgOffline")
    self.nameText = self.group:Find("HeadGroup/Name"):GetComponent("Text")
    self.idTxt = self.group:Find("HeadGroup/ID"):GetComponent("Text")
    self.scoreGoldImage = self.group:Find("HeadGroup/Score/GoldImage")
    self.scoreText = self.group:Find("HeadGroup/Score"):GetComponent("Text")
    self.bankTag = self.group:Find("HeadGroup/BankTag")
    self.addScore = self.group:Find("ScoreChange/Add")
    self.addScoreText = self.group:Find("ScoreChange/Add/Text"):GetComponent("Text")
    self.subScore = self.group:Find("ScoreChange/Sub")
    self.subScoreText = self.group:Find("ScoreChange/Sub/Text"):GetComponent("Text")
    self.bankeBox = self.group:Find("HeadGroup/BankeBox")
    self.loseImage = self.group:Find("HeadGroup/LoseImage")
    self.luckyImage = self.group:Find("HeadGroup/LuckyImage")
    self.completeImage = self.group:Find("HeadGroup/CompleteImage")
    self.lookOnImage = self.group:Find("HeadGroup/LookOnImage")
    ------------------------------下注分---------------------------
    self.goldMultiple = self.transform:Find("GoldMultiple")
    self.goldIcon = self.goldMultiple:Find("IconGold")
    self.goldMultipleText = self.goldIcon:Find("GoldText"):GetComponent("Text")
    self.goldMultipleGoldNode = self.goldMultiple:Find("GoldNode")
    ------------------------------显示------------------------------
    self.showGroup = self.transform:Find("ShowGroup")
    self.robZhuangMultiple = self.showGroup:Find("RobZhuangMultiple")
    self.scoreMultiple = self.showGroup:Find("ScoreMultiple")
    self.imgTuizu = self.showGroup:Find("ImgTuizu")
    ------------------------------手牌-------------------------------
    self.cards = {}
    self.cards.transform = self.transform:Find("Cards")
    self.cards.gameObject = self.cards.transform.gameObject
    for j = 1, 5 do
        self.cards[j] = self.cards.transform:Find(j .. "/card")
    end
    self.pointImage = self.cards.transform:Find("Points"):GetComponent("Image")
    -----------------------------亮牌结果-------------------------------------
    self.ResultType = self.transform:Find("Type")
end

--隐藏玩家手牌
function SDBPlayerItem:HidePlayerHand()
    -- local playerData = SDBRoomData.playerDatas[i]
    -- playerData:HideAllCard()
end

--还原玩家UI
function SDBPlayerItem:ResetPlayerUI()
    UIUtil.SetActive(self.imgTuizu.gameObject, false)
    UIUtil.SetActive(self.addScore.gameObject, false)
    UIUtil.SetActive(self.subScore.gameObject, false)
    UIUtil.SetActive(self.bankeBox.gameObject, false)
    UIUtil.SetActive(self.robZhuangMultiple.gameObject, false)
    UIUtil.SetActive(self.scoreMultiple.gameObject, false)
    UIUtil.SetActive(self.pointImage.gameObject, false)
    for i = 1, 5 do
        UIUtil.SetActive(self.cards[i].gameObject, false)
    end
    UIUtil.SetActive(self.bankTag.gameObject, false)
    UIUtil.SetActive(self.bankeBox.gameObject, false)
    UIUtil.SetActive(self.luckyImage.gameObject, false)
    UIUtil.SetActive(self.loseImage.gameObject, false)
    UIUtil.SetActive(self.completeImage.gameObject, false)
    -- UIUtil.SetActive(self.imgOffline.gameObject, false)
    UIUtil.SetActive(self.lookOnImage.gameObject, false)
    self:HideBetPoints()
    self:HideBalanceUI()
end

--隐藏结算界面UI
function SDBPlayerItem:HideBalanceUI()
    UIUtil.SetActive(self.addScore.gameObject, false)
    UIUtil.SetActive(self.subScore.gameObject, false)
end

--隐藏item
function SDBPlayerItem:HideItem()
    if self.playerId == nil then
        return
    end
    self:SetActive(false)
end

function SDBPlayerItem:ClearData()
    self.playerId = nil
    self.isPlayReadyAni = false
end

function SDBPlayerItem:Clear()
    Log(">>>>>>>>>>>>    清理item", self.gameObject.name)
    self:HideItem()
    self:SetOfflineActive(false)
    self:ResetPlayerUI()
    self:RestoreHead()
    self:ClearData()
end

--还原头像
function SDBPlayerItem:RestoreHead()
    self.headImage.sprite = BaseResourcesMgr.headNoneSprite
end

--初始化牌信息 --传入牌UI的table
function SDBPlayerItem:InitCards()
    self.handCardsItems = {}
    for i = 1, #self.cards do
        local card = SDBPokerCard:New()
        card:Init(self.cards[i].gameObject)
        table.insert(self.handCardsItems, card)
    end
end

--给UI设置玩家基本信息
function SDBPlayerItem:SetUIByPlayerData(playerId)
    --不把playerData存下来是因为playerData中存了playerItem，playerItem中再存playerData的话，容易出现死循环
    local playerData = SDBRoomData.GetPlayerDataById(playerId)
    if playerData == nil then
        LogError(">> SDBPlayerItem > SetUIByPlayerData > playerData is nil by playerId = ", playerId)
        return
    end
    --设置分数
    self:SetScoreText(playerData.playerScore)
    --更新准备状态
    self:UpdatellReadyImge(playerData.state == PlayerState.Ready, true)
    --激活该gameobject
    self:SetActive(true)
    --当前玩家id与要改变的玩家id不同时
    if self.playerId ~= playerId then
        --玩家item
        playerData.item = self
        --设置值之前先还原
        self:ResetPlayerUI()
        --设置玩家id
        self:SetPlayerId(playerId)
        --修改名字
        self:SetName(SubStringName(playerData.name))
        --修改id
        self:SetID(playerData.id)
        --更新是否是元宝图标
        UIUtil.SetActive(self.scoreGoldImage, SDBRoomData.IsGoldGame())
    end
    --设置头像
    Functions.SetHeadImage(self.headImage, Functions.CheckJoinPlayerHeadUrl(playerData.playerHead))
    --更新离线图标
    self:SetOfflineActive(playerData.isOffline)
end

function SDBPlayerItem:SetActive(active)
    self.isActive = active
    UIUtil.SetActive(self.gameObject, active)
end

--设置玩家id
function SDBPlayerItem:SetPlayerId(playerId)
    if IsNil(playerId) then
        return
    end
    self.playerId = playerId
end

--设置名字
function SDBPlayerItem:SetName(name)
    if string.IsNullOrEmpty(name) then
        return
    end
    self.nameText.text = SubStringName(name)
end

--设置id
function SDBPlayerItem:SetID(id)
    self.idTxt.text = id
end

--设置分数
function SDBPlayerItem:SetScoreText(score)
    if IsNil(score) then
        return
    end

    if SDBRoomData.IsGoldGame() then
        self.scoreText.text = CutNumber(score)
    else
        self.scoreText.text = score
    end
end

--更新准备 -- isCheckPlayAnim 是否检测播放准备动画
function SDBPlayerItem:UpdatellReadyImge(active, isCheckPlayAnim)
    UIUtil.SetActive(self.imgReady.gameObject, active)
    if active and isCheckPlayAnim then
        self:CheckPlayReadyAnim()
    end
    if active then
        --隐藏观战中
        self:SetLookOnImageActive(false)
        --隐藏完成
        self:HideAllCardTypeState()
    end
end

--检测是否播放准备动画
function SDBPlayerItem:CheckPlayReadyAnim()
    if self.isPlayReadyAni == false then
        SDBRoomAnimator.PlayReadyAnim(self.imgReady)
        self.isPlayReadyAni = true
    end
end

--设置庄图标激活状态
function SDBPlayerItem:SetZhuangImageActive(active)
    UIUtil.SetActive(self.bankTag.gameObject, active)
    UIUtil.SetActive(self.bankeBox.gameObject, active)
end

--显示显示抢庄倍数
function SDBPlayerItem:ShowRobZhuangMultiple(robZhuangState)
    --自由抢庄模式
    local state = "multiple_" .. robZhuangState
    local scoremultipleImage = self.scoreMultiple:GetComponent("Image")
    scoremultipleImage.sprite = SDBResourcesMgr.GetShowPng(state)
    scoremultipleImage:SetNativeSize()
    UIUtil.SetActive(self.scoreMultiple.gameObject, true)
end

--隐藏抢庄倍数图标
function SDBPlayerItem:HideRobZhuangMultiple()
    UIUtil.SetActive(self.scoreMultiple.gameObject, false)
end

--显示抢庄枪几
function SDBPlayerItem:ShowRobZhuangNum(robZhuangState)
    Log(">> SDBPlayerItem > ShowRobZhuangNum > id = ", self.playerId, " rob = ", robZhuangState)
    --自由抢庄模式
    local state = "rob_" .. robZhuangState
    local robzhuangImage = self.robZhuangMultiple:GetComponent("Image")
    robzhuangImage.sprite = SDBResourcesMgr.GetShowPng(state)
    robzhuangImage:SetNativeSize()
    self.robZhuangMultiple:GetComponent("Image"):SetNativeSize()
    UIUtil.SetActive(self.robZhuangMultiple.gameObject, true)
end

--隐藏抢庄抢几
function SDBPlayerItem:HideRobZhuangNum()
    UIUtil.SetActive(self.robZhuangMultiple.gameObject, false)
end

--显示下注分
function SDBPlayerItem:ShowBetPoints(xiaZhuScore)
    if SDBFuntions.IsNilOrZero(xiaZhuScore) then
        self:HideBetPoints()
        return
    end
    if not IsNil(xiaZhuScore) then
        self.goldMultipleText.text = xiaZhuScore * SDBRoomData.diFen
    end
    UIUtil.SetActive(self.goldIcon.gameObject, true)
end

--隐藏下注分
function SDBPlayerItem:HideBetPoints()
    UIUtil.SetActive(self.goldIcon.gameObject, false)
end

--设置可推注图标状态
function SDBPlayerItem:SetTuiZhuImageActive(active)
    UIUtil.SetLocalPosition(self.imgTuizu, self.tuiZhuMove.x, self.tuiZhuMove.y, self.tuiZhuMove.z)
    UIUtil.SetActive(self.imgTuizu.gameObject, active)
end

-- 更新推注状态
function SDBPlayerItem:UpdateTuiZhuImage()
    self.imgTuizu.transform.localPosition = self.tuizhuInitPos
    self:SetTuiZhuImageActive(true)
    self.imgTuizu.transform:DOLocalMove(self.tuiZhuMove, 1, false)
end

--更新玩家离线图标
function SDBPlayerItem:SetOfflineActive(active)
    UIUtil.SetActive(self.imgOffline.gameObject, active)
end

--设置点数图片(爆点，几点这样的)
function SDBPlayerItem:SetPointImage(type, point)
    local sprite = nil
    if type == 2 then
        sprite = SDBResourcesMgr.GetResultSprite(SDBPointType[point])
    else
        local resultType = SDBCardType[type]
        if self.playerId == SDBRoomData.BankerPlayerId then
            --判断是否庄家翻倍规则
            if type > 2 and not SDBRoomData.isBankerDoubleWin then
                resultType = resultType .. "_0"
            end
        end
        sprite = SDBResourcesMgr.GetResultSprite(resultType)
    end

    self.pointImage.sprite = sprite
    self.pointImage:SetNativeSize()

    local active = tonumber(point) ~= -1 and tonumber(type) ~= -1
    self:SetPointImageActive(active)
end

--设置点数图片激活
function SDBPlayerItem:SetPointImageActive(active)
    UIUtil.SetActive(self.pointImage.gameObject, active)
end

--显示输赢分数
function SDBPlayerItem:ShowChangeScore(scroe)
    if scroe >= 0 then
        self.addScore.transform.localPosition = Vector3.New(0, 80, 0)
        self.addScoreText.text = "+" .. scroe
        self.addScore.gameObject:SetActive(true)
    else
        self.subScore.transform.localPosition = Vector3.New(0, 80, 0)
        self.subScoreText.text = scroe
        self.subScore.gameObject:SetActive(true)
    end
end

--显示完成Image
function SDBPlayerItem:ShowCompleteImage(isPlayAni)
    UIUtil.SetActive(self.completeImage.gameObject, true)
    if isPlayAni then
        SDBRoomAnimator.PlayScaleEaseAnim(self.completeImage)
    end
end

--显示观战中
function SDBPlayerItem:SetLookOnImageActive(active)
    UIUtil.SetActive(self.lookOnImage.gameObject, active)
end

--显示牌的卡槽
function SDBPlayerItem:ShowCardsSlot()
    UIUtil.SetActive(self.cards.gameObject, true)
end

--隐藏牌的卡槽
function SDBPlayerItem:HideCardsSlot()
    UIUtil.SetActive(self.cards.gameObject, false)
end

--显示要牌中动画
function SDBPlayerItem:PlayYaoPaiZhongAni()
    if self.yaoPaiZhongEff == nil then
        local prefab = SDBLoadResPanel.GetYaoPaiZhongEff()
        self.yaoPaiZhongEff = CreateGO(prefab, self.headGroup, "YaoPaiZhongEff")
        UIUtil.SetLocalPosition(self.yaoPaiZhongEff, 0, 0, 0)
    end
    UIUtil.SetActive(self.yaoPaiZhongEff, true)
end

--关闭要牌中
function SDBPlayerItem:StopYaoPaiZhongAni()
    if self.yaoPaiZhongEff ~= nil then
        UIUtil.SetActive(self.yaoPaiZhongEff, false)
    end
end

--显示聊天内容
function SDBPlayerItem:ShowChatText(duration, text)
    Functions.SetChatText(self.chatGo, self.chatText, text)
    --定时关闭
    Scheduler.scheduleOnceGlobal(function()
        UIUtil.SetActive(self.chatGo, false)
    end, duration)
end

--隐藏所有玩家头上的点数状态(输，幸运，完成等)
function SDBPlayerItem:HideAllCardTypeState()
    UIUtil.SetActive(self.luckyImage.gameObject, false)
    UIUtil.SetActive(self.loseImage.gameObject, false)
    UIUtil.SetActive(self.completeImage.gameObject, false)
end

-----------------------------------
function SDBPlayerItem:PlayBankerEff(OnCompleted)
    if self.banker == nil then
        local prefab = SDBLoadResPanel.GetBankerEff()
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
end

--播放获胜动画
function SDBPlayerItem:PlayWinAni()
    if self.winEff == nil then
        local prefab = SDBLoadResPanel.GetWinEff()
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
--card 牌数据 count 第几张牌, sendCardComplete 发牌完成回调
function SDBPlayerItem:SendCard(card, count, sendCardComplete)
    self.sendCardComplete = sendCardComplete
    self.curCardItem = self.handCardsItems[count]
    self.curCardData = card

    self:StartSendCardingTimer()

    SDBRoomAnimator.sendCarding = true

    --设置当前的牌 
    if IsNil(self.curSendCard) then
        self.curSendCard = CreateGO(SDBConst.deckCardItem.gameObject, SDBConst.deckCardItem.parent, 'deing')
    else
        self.curSendCard.transform:SetParent(SDBConst.deckCardItem.parent)
    end

    self.curSendCard.transform:DOKill()
    UIUtil.SetActive(self.curSendCard, true)
    --初始化发的牌
    self:RestoreFlyCardItem()
    self.curCardItem:SetPoints("-1", false)
    ---! 放大
    if self.playerId == SDBRoomData.mainId then
        self.curSendCard.transform:DOScale(Vector3.New(0.8, 0.8, 1), 0.15)
    else
        self.curSendCard.transform:DOScale(Vector3.New(0.67, 0.67, 1), 0.15)
    end

    self.sendCardTimer = Scheduler.scheduleOnceGlobal(HandlerArgs(self.OnCompleteDoScale, self), 0.15)
end

function SDBPlayerItem:OnCompleteDoScale()
    local v3 = self.curCardItem.transform.localPosition
    ---! 移动
    local tweener = self.curSendCard.transform:DOLocalMove(Vector2.New(v3.x, v3.y), 0.15, true)
    tweener:SetEase(DG.Tweening.Ease.OutSine)
    tweener:SetDelay(0.05)
    tweener:OnStart(function()
        -- 发牌声音
        SDBResourcesMgr.PlayFaPaiGameSound()
    end)

    --传入玩家id，item>克隆出来的牌，cardUI>当前牌的UI , i>当前循环的下标，cards 当前所有牌的点数, curCardsItem>当前所有克隆出来的飞的牌的Obj
    self.sendCardTimer2 = Scheduler.scheduleOnceGlobal(HandlerArgs(self.OnCompleteSendCards, self), 0.15)
end

--重置飞牌
function SDBPlayerItem:RestoreFlyCardItem()
    ---! 玩家手牌
    local item = self.curSendCard
    item.transform.anchoredPosition = Vector3.zero
    item.transform.anchorMax = Vector2.New(0.5, 0.5)
    item.transform.sizeDelta = Vector2.New(104, 140)
    item.transform.localScale = Vector3.New(0.4, 0.4, 1)
    item.transform:SetParent(self.curCardItem.transform.parent)
    --设置牌背
    item:GetComponent('Image').sprite = SDBResourcesMgr.GetCardBack()
    item:SetActive(true)
end

--发牌结束
function SDBPlayerItem:OnCompleteSendCards()
    local playerData = SDBRoomData.GetPlayerDataById(self.playerId)
    self:StopSendCardingTimer()

    UIUtil.SetActive(self.curSendCard, false)

    playerData:ShowCardsSlot()
    playerData:CheckCards()

    --发牌结束回调
    if self.sendCardComplete ~= nil then
        --检查点数
        self.sendCardComplete()
        self.sendCardComplete = nil
    end

    SDBRoomAnimator.sendCarding = false
end

--容错，一秒后无论如何，都可以继续要牌，将发牌中置为false
function SDBPlayerItem:StartSendCardingTimer()
    self:StopSendCardingTimer()

    self.cardingTimer = Scheduler.scheduleOnceGlobal(function()
        SDBRoomAnimator.sendCarding = false
        self.cardingTimer = nil
    end, 1)
end

function SDBPlayerItem:StopSendCardingTimer()
    Scheduler.unscheduleGlobal(self.cardingTimer)
end

--中断发牌动画
function SDBPlayerItem:BreakSendCardAnimation(isSendCardComplete)
    Scheduler.unscheduleGlobal(self.sendCardTimer)
    Scheduler.unscheduleGlobal(self.sendCardTimer2)

    SDBRoomAnimator.sendCarding = false
    self:StopSendCardingTimer()

    if not IsNil(self.curSendCard) then
        UIUtil.SetActive(self.curSendCard, false)
    end

    if isSendCardComplete and not IsNil(self.sendCardComplete) then
        self.sendCardComplete()
        self.sendCardComplete = nil
    end
end
-----------------------------------
--播放点数音效
function SDBPlayerItem:PlayPointSound(playerData, type, point)
    --播放结果音效
    SDBResourcesMgr.PlayCardPointSound(playerData.id, point, type)
end

--播放输赢动画
function SDBPlayerItem:PlayWinorLoseAnim(type)
    --播放幸运或者失败的动画
    if type == 1 then
        if not self.loseImage.gameObject.activeSelf then
            UIUtil.SetActive(self.loseImage.gameObject, true)
            SDBRoomAnimator.PlayScaleEaseAnim(self.loseImage)
        end
    elseif type > 2 then
        if not self.luckyImage.gameObject.activeSelf then
            UIUtil.SetActive(self.luckyImage.gameObject, true)
            SDBRoomAnimator.PlayScaleEaseAnim(self.luckyImage)
        end
    end
end

--输赢分数动画
function SDBPlayerItem:SetPayChangeScore(scroe)
    if scroe >= 0 then
        self.addScore.transform.localPosition = Vector3.New(0, 0, 0)
        self.addScoreText.text = "+" .. scroe
        self.addScore.gameObject:SetActive(true)
        self.addScore.transform:DOLocalMove(Vector3.New(0, 80, 0), 2, false)
    else
        self.subScore.transform.localPosition = Vector3.New(0, 0, 0)
        self.subScoreText.text = scroe
        self.subScore.gameObject:SetActive(true)
        self.subScore.transform:DOLocalMove(Vector3.New(0, 80, 0), 2, false)
    end
end

--播放亮牌特效
function SDBPlayerItem:PlayResultEffect(type)
    if type == nil or type == 2 then
        return
    end

    if type == 1 then
        if self.blastCardEff == nil then
            self.blastCardEff = CreateGO(SDBLoadResPanel.GetBlastCardEff(), self.ResultType, "BlastCardEff")
            UIUtil.SetLocalPosition(self.blastCardEff, 0, 0, 0)
        end

        UIUtil.SetActive(self.blastCardEff, true)
        --爆牌音效
        SDBResourcesMgr.PlayGameSound(SDBGameEffSoundType.EFFBOOBM)
    else
        if self.bianShuEff == nil then
            self.bianShuEff = CreateGO(SDBLoadResPanel.GetDianShuEff(), self.ResultType, "DianShuEff")
            UIUtil.SetLocalPosition(self.bianShuEff, 0, 0, 0)
        end
        UIUtil.SetActive(self.bianShuEff.gameObject, true)
    end
end

--飞金币动画
function SDBPlayerItem:FlyGold(callback)
    local perfab = self.goldItem.gameObject
    local goldM = self.goldMultipleGoldNode
    --播放飞金币音效
    SDBResourcesMgr.PlayGameSound(SDBGameEffSoundType.EFFFLYCOINS)
    local count = 5
    for i = 1, count do
        local item = SDBResourcesMgr.GetFlyGoldItem(perfab, perfab.transform.parent)
        UIUtil.SetActive(item, true)
        item.transform.localPosition = Vector3.zero
        item.transform:SetParent(goldM)
        ---! 移动
        local tweener = item.transform:DOLocalMove(Vector2.New(0, 0), 0.5, true)
        local Ease = DG.Tweening.Ease
        tweener:SetEase(Ease.OutSine)
        tweener:SetDelay(0.05 * i)
        --飞金币回调
        tweener:OnComplete(function()
            if SDBFuntions.GetActive(item) then
                if i == 1 then
                    if not IsNil(callback) then
                        callback()
                    end
                end
                SDBResourcesMgr.RecycleFlyGoldItem(item)
            end
            self.betScoreGoldItems[i] = nil
        end)
        self.betScoreGoldItems[i] = item
    end
end

function SDBPlayerItem:StopFlyGold()
    for _, item in pairs(self.betScoreGoldItems) do
        SDBResourcesMgr.RecycleFlyGoldItem(item)
    end
    self.betScoreGoldItems = {}
end

-----------------------------------------------------------
--设置所有牌
function SDBPlayerItem:ShowAllCard(cards)
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
        self.handCardsItems[i]:SetPoints(cards[i])
    end

    if #cards > 0 then
        --显示卡槽 --里面只有激活方法，重复调用消耗不计
        self:ShowCardsSlot()
    end
end

--播放玩家的牌的翻牌动画
function SDBPlayerItem:PlayFlopAni(cardStr)
    if SDBRoomData.isCardGameStarted == false then
        return
    end
    for i = 1, #cardStr do
        self.handCardsItems[i]:PlayFlopAni(cardStr[i])
    end
end

--清空扑克设置
function SDBPlayerItem:ResetPokerData()
    for i = 1, #self.handCardsItems do
        self.handCardsItems[i]:Reset()
    end
end

--隐藏玩家的所有牌
function SDBPlayerItem:HideAllCard()
    for i = 1, #self.handCardsItems do
        self.handCardsItems[i]:HideCard()
    end
end

--检查牌
function SDBPlayerItem:CheckCards(handCards)
    for i = 1, #self.handCardsItems do
        if handCards[i] == nil then
            self.handCardsItems[i]:HideCard()
        else
            self.handCardsItems[i]:SetPoints(handCards[i])
        end
    end
end

--隐藏某张牌
function SDBPlayerItem:HideOneCard(index)
    if not IsNil(self.handCardsItems[index]) then
        self.handCardsItems[index]:HideCard()
    end
end

return SDBPlayerItem