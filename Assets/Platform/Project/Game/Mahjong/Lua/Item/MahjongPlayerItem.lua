--玩家UI显示对象
MahjongPlayerItem = {
    ------------------UI
    gameObject = nil,
    transform = nil,
    ------------------属性
    --激活
    isActive = false,
    --序号
    index = 0,

    --玩家ID，用于判断是否为同一玩家，避免重复处理UI
    playerId = 0,
    --玩家的Table状态，避免重复处理UI
    tableState = 0,
    --玩家的胡牌类型，避免胡牌图标重复处理
    huType = nil,
    --托管状态
    trust = nil,
    --定缺，避免重复处理UI
    dingQue = -1,
    --是否播放定缺动画
    isPlayDingQueAnim = false,
    --播放定缺动画时间
    playDingQueAnimTime = 0,
    --上一次存储的在线状态
    lastOnline = -1,
    --倒计时Timer
    countdownTimer = nil,
    --离线时间
    offlineTime = 0,

    --分数分数动画Timer
    goldScoreTimer = nil,

}

local meta = { __index = MahjongPlayerItem }

function MahjongPlayerItem.New()
    local obj = {}
    setmetatable(obj, meta)
    return obj
end

--设置根
function MahjongPlayerItem:SetRoot(index, transform)
    self.index = index
    self.transform = transform
    self.gameObject = transform.gameObject

    local nodeTrans = transform:Find("Node")
    self.nodeGO = nodeTrans.gameObject
    --
    local headTrans = nodeTrans:Find("Head")
    self.headBtn = headTrans.gameObject
    self.headImage = headTrans:Find("HeadMask/Image"):GetComponent(TypeImage)
    self.headFrame = headTrans:Find("HeadFrame"):GetComponent(TypeImage)
    local offlineTrans = headTrans:Find("Offline")
    self.offlineGO = offlineTrans.gameObject
    self.offlineTxt = offlineTrans:Find("OfflineText"):GetComponent(TypeText)
    self.iconBagGO = headTrans:Find("IconBag").gameObject
    self.iconGoldGO = headTrans:Find("IconGold").gameObject
    self.nameTxt = headTrans:Find("NameText"):GetComponent(TypeText)
    self.idTxt = headTrans:Find("IDText"):GetComponent(TypeText)
    self.scoreTxt = headTrans:Find("ScoreText"):GetComponent(TypeText)
    --
    self.dingQueTrans = nodeTrans:Find("Flag/DingQue")
    self.dingQueGO = self.dingQueTrans.gameObject
    self.dingQueImage = self.dingQueGO:GetComponent(TypeImage)
    self.masterGO = nodeTrans:Find("Flag/Master").gameObject
    self.trustGO = nodeTrans:Find("FlagTrust").gameObject
    self.faceAnimNode = nodeTrans:Find("FaceAnimNode")
    self.headAnimNode = nodeTrans:Find("HeadAnimNode")

    local scoreAnimTrans = nodeTrans:Find("ScoreAnimText")
    self.scoreAnimGO = scoreAnimTrans.gameObject
    self.scoreAnimTxt = scoreAnimTrans:GetComponent(TypeText)
    self.scorePositionTweener = scoreAnimTrans:GetComponent(TypeTweenPosition)
    self.scoreAlphaTweener = scoreAnimTrans:GetComponent(TypeTweenAlpha)
    self.scorePositionTweener.onFinished = function() self:OnScorePositionTween() end
    --
    self.goldScoreGo = transform:Find("Score/Text").gameObject
    self.goldScoreTxt = self.goldScoreGo:GetComponent(TypeText)
    self.goldScoreTweener = self.goldScoreGo:GetComponent(TypeTweenScale)
    --
    self.chatFrameGO = nodeTrans:Find("ChatFrame").gameObject
    self.chatTxt = nodeTrans:Find("ChatFrame/Text"):GetComponent(TypeText)
    self.stateNotReadyGO = nodeTrans:Find("StateNotReady").gameObject
    self.stateJoiningGO = nodeTrans:Find("StateJoining").gameObject

    local stateTrans = transform:Find("State")
    self.stateGO = stateTrans.gameObject
    self.stateXuanPai = stateTrans:Find("XuanPai").gameObject
    self.stateDingQue = stateTrans:Find("DingQue").gameObject

    local hu = transform:Find("Hu")
    self.huGO = hu.gameObject
    self.huImage = hu:Find("HuIcon"):GetComponent(TypeImage)
    self.huAnim = hu:Find("HuAnim"):GetComponent(TypeSkeletonGraphic)
    
    local huLabel = hu:Find("Text")
    self.huLabelGO = huLabel.gameObject
    self.huLabel = huLabel:GetComponent(TypeText)
    self.moveDingQueTrans = transform:Find("MoveDingQueIcon")
    self.moveDingQuePosition = self.moveDingQueTrans.localPosition
    self.moveDingQueGO = self.moveDingQueTrans.gameObject
    self.moveDingQueImage = self.moveDingQueTrans:GetComponent(TypeImage)
end

--隐藏
function MahjongPlayerItem:Hide()
    if self.isActive == false then
        return
    end
    self.isActive = false

    UIUtil.SetActive(self.gameObject, false)

    self:ClearOffline()

    UIUtil.SetActive(self.chatFrameGO, false)

    self:Reset()
end

--显示
function MahjongPlayerItem:Show()
    self.isActive = true
    UIUtil.SetActive(self.gameObject, true)
end

--重置，用于小结结束
function MahjongPlayerItem:Reset()
    self.tableState = 0
    self.huType = nil
    self.trust = nil
    self.playerId = 0
    self.lastOnline = -1

    self:ClearDingQue()

    UIUtil.SetActive(self.masterGO, false)
    UIUtil.SetActive(self.trustGO, false)

    --UIUtil.SetActive(self.stateNotReadyGO, false)
    --UIUtil.SetActive(self.stateJoiningGO, false)
    UIUtil.SetActive(self.stateGO, false)
    UIUtil.SetActive(self.stateDingQue, false)
    UIUtil.SetActive(self.stateXuanPai, false)

    UIUtil.SetActive(self.huGO, false)

    UIUtil.SetActive(self.scoreAnimGO, false)
end

--清除
function MahjongPlayerItem:Clear()
    self:ClearGoldAnim()
    self:Hide()
end

--清除定缺相关信息
function MahjongPlayerItem:ClearDingQue()
    self.dingQue = -1
    self.isPlayDingQueAnim = false
    self.playDingQueAnimTime = 0
    UIUtil.SetActive(self.dingQueGO, false)
    UIUtil.SetActive(self.moveDingQueGO, false)
end

--设置在线标识，0离线、1在线
function MahjongPlayerItem:SetOnline(online)
    if self.lastOnline ~= online then
        self.offlineTime = os.time()
    end
    self.lastOnline = online
    if online == 0 then
        UIUtil.SetActive(self.offlineGO, true)
        if self.offlineTime == 0 then
            self.offlineTime = os.time()
        end
        self:StartOfflineCountdown()
        self:OnOfflineCountdown()
    else
        self:ClearOffline()
    end
end

--清除离线相关
function MahjongPlayerItem:ClearOffline()
    UIUtil.SetActive(self.offlineGO, false)
    self:StopOfflineCountdown()
end

--启动离线倒计时Timer
function MahjongPlayerItem:StartOfflineCountdown()
    if self.countdownTimer == nil then
        self.countdownTimer = Timing.New(function() self:OnOfflineCountdown() end, 1)
    end
    self.countdownTimer:Start()
end

--停止离线倒计时Timer
function MahjongPlayerItem:StopOfflineCountdown()
    if self.countdownTimer ~= nil then
        self.countdownTimer:Stop()
    end
end

--处理离线倒计时Timer
function MahjongPlayerItem:OnOfflineCountdown()
    local temp = os.time() - self.offlineTime
    --最高为59:59
    if temp > 3599 then
        temp = 3599
        self.offlineTxt.text = "59:59"
        self:StopOfflineCountdown()
    else
        local minute = math.floor(temp / 60)
        if minute < 10 then
            minute = "0" .. minute
        end
        local second = temp % 60
        if second < 10 then
            second = "0" .. second
        end
        self.offlineTxt.text = minute .. ":" .. second
    end
end

--播放分数分数动画
function MahjongPlayerItem:PlayGoldAnim(deductGold)
    UIUtil.SetActive(self.goldScoreGo, true)
    local goldTxt = ""
    if deductGold < 0 then
        goldTxt = tostring(deductGold)
        self.goldScoreTxt.font = MahjongGlobal.FontDecrease
    else
        goldTxt = "+" .. tostring(deductGold)
        self.goldScoreTxt.font = MahjongGlobal.FontIncrease
    end
    self.goldScoreTxt.text = goldTxt
    self.goldScoreTweener.duration = 0.6
    self.goldScoreTweener:ResetToBeginning()
    self.goldScoreTweener:PlayForward()
    self:StartGoldScoreTimer()
end

--清除分数分数动画
function MahjongPlayerItem:ClearGoldAnim()
    self:StopGoldScoreTimer()
    UIUtil.SetActive(self.goldScoreGo, false)
end

--开始分数分数Timer
function MahjongPlayerItem:StartGoldScoreTimer()
    if self.goldScoreTimer == nil then
        self.goldScoreTimer = Timing.New(function() self:OnGoldScoreTimer() end, 1.4)
    end
    self.goldScoreTimer:Restart()
end

--停止分数分数Timer
function MahjongPlayerItem:StopGoldScoreTimer()
    if self.goldScoreTimer ~= nil then
        self.goldScoreTimer:Stop()
    end
end

--处理分数分数Timer
function MahjongPlayerItem:OnGoldScoreTimer()
    self:ClearGoldAnim()
end

--播放头像处的分数播放
function MahjongPlayerItem:PlayScoreAnim(value)
    local temp = ""
    if value < 0 then
        temp = tostring(value)
    else
        temp = "+" .. tostring(value)
    end
    self.scoreAnimTxt.text = temp
    UIUtil.SetActive(self.scoreAnimGO, true)

    self.scorePositionTweener:ResetToBeginning()
    self.scorePositionTweener:PlayForward()

    self.scoreAlphaTweener:ResetToBeginning()
    self.scoreAlphaTweener:PlayForward()
end

function MahjongPlayerItem:OnScorePositionTween()
    UIUtil.SetActive(self.scoreAnimGO, false)
end

--设置hu显示
function MahjongPlayerItem:SetHuDisplay(display)
    if self.lastHuDisplay ~= display then
        self.lastHuDisplay = display
        UIUtil.SetActive(self.huGO, display)
    end
end

--设置hu文本显示
function MahjongPlayerItem:SetHuLabelDisplay(display)
    --LogError(">> MahjongPlayerItem:SetHuLabelDisplay", display)
    if self.lastHuLabelDisplay ~= display then
        self.lastHuLabelDisplay = display
        UIUtil.SetActive(self.huLabelGO, display)
    end
end
--设置胡牌播放动画
function MahjongPlayerItem:SetPlayEffect(animName, size)
    local temp = self.huAnim.SkeletonData:FindAnimation(animName)
    if temp ~= nil then
        self.huAnim.AnimationState:SetAnimation(0, animName, true)
    end
    UIUtil.SetLocalScale(self.huAnim.gameObject, size, size, 1)
end
