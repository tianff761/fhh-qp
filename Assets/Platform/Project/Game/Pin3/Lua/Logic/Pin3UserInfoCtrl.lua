Pin3UserInfoCtrl = ClassLuaComponent("Pin3UserInfoCtrl")
Pin3UserInfoCtrl.uid = nil --用户ID
Pin3UserInfoCtrl.uiIdx = 0 --前端座位索引
Pin3UserInfoCtrl.seatId = 0 --服务器座位Id
Pin3UserInfoCtrl.isBindUserInfo = false --是否绑定玩家数据
--所有基础信息的父节点
Pin3UserInfoCtrl.basicInfoTran = nil
Pin3UserInfoCtrl.headIconImg = nil
Pin3UserInfoCtrl.idText = nil
Pin3UserInfoCtrl.nameText = nil
Pin3UserInfoCtrl.timeInfoImg = nil
Pin3UserInfoCtrl.scoreText = nil
Pin3UserInfoCtrl.yzText = nil
Pin3UserInfoCtrl.offlineImg = nil
Pin3UserInfoCtrl.qiPaiImg = nil
Pin3UserInfoCtrl.shuImg = nil
Pin3UserInfoCtrl.kanPaiImg = nil
Pin3UserInfoCtrl.readyTag = nil
Pin3UserInfoCtrl.zhuangTag = nil
Pin3UserInfoCtrl.pangGuanTag = nil
Pin3UserInfoCtrl.biPaiBtn = nil
Pin3UserInfoCtrl.shouPaiParents = {}
Pin3UserInfoCtrl.cardObjs = {}
Pin3UserInfoCtrl.shuText = nil
Pin3UserInfoCtrl.yinText = nil
Pin3UserInfoCtrl.paiXingText = nil
Pin3UserInfoCtrl.winAnimNode = nil
Pin3UserInfoCtrl.operText = nil
Pin3UserInfoCtrl.JiazhuImg = nil
Pin3UserInfoCtrl.GengzhuImg = nil
Pin3UserInfoCtrl.goldIcon = nil
Pin3UserInfoCtrl.fkIcon = nil
Pin3UserInfoCtrl.yzGoldIcon = nil
Pin3UserInfoCtrl.yzFkIcon = nil
function Pin3UserInfoCtrl:Awake()
    self.uid = 0
    self.isBindUserInfo = false
    UIUtil.SetActive(self.gameObject, false)

    self.basicInfoTran = self:Find("BasicInfo"):GetComponent(TypeRectTransform)
    self.headIconImg = self.basicInfoTran:Find("HeadMask/HeadIcon"):GetComponent(typeof(Image))
    self.idText = self.basicInfoTran:Find("IdInfo/Uid")
    self.nameText = self.basicInfoTran:Find("Name")
    self.timeInfoImg = self.basicInfoTran:Find("TimeInfo"):GetComponent(typeof(Image))
    self.offlineImg = self.basicInfoTran:Find("OfflineTag")
    self.qiPaiImg = self.basicInfoTran:Find("QiPaiTag")
    self.qiPaiImage = self.basicInfoTran:Find("QiPaiTag/Image"):GetComponent(TypeImage)
    self.shuImg = self.basicInfoTran:Find("ShuTag")
    self.kanPaiImg = self:Find("HandCards/KanPaiTag")
    self.readyTag = self.basicInfoTran:Find("ZhunBeiTag")
    self.zhuangTag = self.basicInfoTran:Find("ZhuangIcon")
    self.pangGuanTag = self.basicInfoTran:Find("PangGuanTag")
    self.scoreText = self:Find("ScoreInfo/Score")
    self.yzText = self:Find("YzInfo/Score")
    self.biPaiBtn = self:Find("BiPaiBtn")
    self.operText = self.basicInfoTran:Find("OperText")
    self.JiazhuImg = self.basicInfoTran:Find("JiazhuImg")
    self.GengzhuImg = self.basicInfoTran:Find("GengzhuImg")

    self.shouPaiParents = {}
    local parents = self:Find("HandCards/Cards")
    if not IsNull(parents) then
        local childCount = parents.childCount
        local child = nil
        if childCount > 0 then
            for i = 0, childCount - 1 do
                child = parents:GetChild(i)
                table.insert(self.shouPaiParents, child)
            end
        end
    end

    if self.biPaiBtn ~= nil then
        self:AddOnClick(self.biPaiBtn, function()
            Pin3Manager.OnClickUserInfoBiPaiBtn(self.uid)
        end)
    end

    self.shuText = self:Find("JieSuanTexts/ShuText"):GetComponent(TypeRectTransform)
    self.yinText = self:Find("JieSuanTexts/YinText"):GetComponent(TypeRectTransform)
    self.paiXingText = self:Find("HandCards/PaiXing/Text")
    self.winAnimNode = self:Find("WinAnimNode")
    self.goldIcon = self:Find("ScoreInfo/GoldIcon")
    self.fkIcon = self:Find("ScoreInfo/FkIcon")
    self.yzGoldIcon = self:Find("YzInfo/GoldIcon")
    self.yzFkIcon = self:Find("YzInfo/FkIcon")

    self.cardTypeAtlas = self:Find("CardTypeAtlas"):GetComponent(TypeSpriteAtlas).sprites:ToTable()
    self.paiXingImg = self:Find("HandCards/PaiXing"):GetComponent(TypeImage)

    self:Reset()
end

function Pin3UserInfoCtrl:Init(uiIdx)
    self.uiIdx = uiIdx
end

function Pin3UserInfoCtrl:SetSeatId(seatId)
    self.seatId = seatId
end

--绑定用户信息到用户控制组件
function Pin3UserInfoCtrl:BindUserInfo(uid)
    UIUtil.SetActive(self.gameObject, true)
    self.uid = uid
    self.isBindUserInfo = true
    self:UpdateUnchangableInfo()
end

--解除用户信息到用户控制组件的绑定
function Pin3UserInfoCtrl:UnBindUserInfo()
    UIUtil.SetActive(self.gameObject, false)
    self.uid = nil
    self.isBindUserInfo = false
end

--获取胜利动画节点
function Pin3UserInfoCtrl:GetWinAnimNode()
    UIUtil.SetAsLastSibling(self.winAnimNode)
    return self.winAnimNode
end

--金币动画
function Pin3UserInfoCtrl:GoldAnim(gold)
    --LogError("<color=aqua>GoldAnim</color>", gold)
    local goldTran = Pin3BattlePanel.GetGoldTran(gold, self.uid)
    if goldTran ~= nil then
        goldTran:SetParent(self.transform)
        UIUtil.SetAnchoredPosition(goldTran, 0, 0)
        Pin3BattlePanel.AddYzGoldTran(goldTran)
    else
        Log("==>GoldAnim没有icon", gold)
    end
end

--添加牌
function Pin3UserInfoCtrl:AddCardObj(cardObj, idx)
    if self.isBindUserInfo then
        local pos = self.shouPaiParents[idx]
        ClearChildren(pos)
        cardObj:SetParent(pos)
        self.cardObjs[idx] = cardObj
    end
end

--清除手牌
function Pin3UserInfoCtrl:ClearCardObjs()
    for _, parent in pairs(self.shouPaiParents) do
        self:SetPaiXing()
        ClearChildren(parent)
    end
    self.cardObjs = {}
end

--如果有牌的Id，给所有牌设置Id
function Pin3UserInfoCtrl:SetCardIds(isShow)
    if self.isBindUserInfo then
        local cardIds = Pin3Data.GetCardIds(self.uid)
        local isSetId = false
        local cardObj = nil
        if GetTableSize(cardIds) == 3 then
            for i, id in pairs(cardIds) do
                if id ~= nil and id > 0 then
                    cardObj = self.cardObjs[i]
                    if cardObj ~= nil then
                        isSetId = true
                        cardObj:SetCardId(id)
                    end
                end
            end
        end
        if isShow == true and isSetId then
            self:ShowCards()
        end
    end
end

--显示牌正面
function Pin3UserInfoCtrl:ShowCards()
    Log("显示牌", self.uid)
    if self.isBindUserInfo then
        for _, cardObj in pairs(self.cardObjs) do
            cardObj:ShowForwardByAnim()
        end
    end
    self:SetPaiXing()
end

--设置牌输效果
function Pin3UserInfoCtrl:SetCardLostEffect()
    if self.isBindUserInfo then
        for _, cardObj in pairs(self.cardObjs) do
            cardObj:SetBlackEffect()
        end
        Log("==>SetCardLostEffect", GetTableSize(self.cardObjs))
    end
end

--设置牌型
function Pin3UserInfoCtrl:SetPaiXing()
    if self.isBindUserInfo then
        local px = Pin3Data.GetPaiXing(self.uid)
        -- Log("显示排型", self.uid, px)
        if Pin3PaiXingConfig[px] ~= nil then
            if self:IsSelf() and self.paiXingText.parent.gameObject.activeSelf == false then
                Scheduler.scheduleOnceGlobal(function()
                    if px == 1 then
                        Pin3AudioManager.PlayAudio(Pin3AudioType.SanPaiText)
                    elseif px == 2 then
                        Pin3AudioManager.PlayAudio(Pin3AudioType.DuiZiText)
                    elseif px == 3 then
                        Pin3AudioManager.PlayAudio(Pin3AudioType.ShunZiText)
                    elseif px == 4 then
                        Pin3AudioManager.PlayAudio(Pin3AudioType.TongHua)
                    elseif px == 5 then
                        Pin3AudioManager.PlayAudio(Pin3AudioType.TongHuaShun)
                    elseif px == 6 then
                        Pin3AudioManager.PlayAudio(Pin3AudioType.FeiJiText)
                    end
                end, 0.5)
            end
            self.paiXingImg.sprite = self.cardTypeAtlas[px]
            UIUtil.SetActive(self.paiXingText.parent, true)
            UIUtil.SetText(self.paiXingText, tostring(Pin3PaiXingConfig[px]))
        else
            UIUtil.SetActive(self.paiXingText.parent, false)
        end
    end
end

--更新不变的信息
function Pin3UserInfoCtrl:UpdateUnchangableInfo()
    if not self.isBindUserInfo then
        return
    end
    UIUtil.SetActive(self.gameObject, true)
    UIUtil.SetText(self.idText, tostring(self.uid))
    UIUtil.SetText(self.nameText, tostring(Pin3Data.GetUserName(self.uid)))
    self:SetHeadIcon()
    self:SetHeadIconOnclick()
    --UIUtil.SetActive(self.goldIcon, not Pin3Data.IsFkRoom())
    --UIUtil.SetActive(self.yzGoldIcon, not Pin3Data.IsFkRoom())
    UIUtil.SetActive(self.fkIcon, Pin3Data.IsFkRoom())
    UIUtil.SetActive(self.yzFkIcon, Pin3Data.IsFkRoom())
end

--更新变化信息
function Pin3UserInfoCtrl:UpdateChangableInfo()
    if not self.isBindUserInfo then
        return
    end
    if Pin3Data.IsFkRoom() then
        UIUtil.SetText(self.scoreText, tostring(Pin3Data.GetGoldNum(self.uid)))
    else
        ---取消cutNum
        UIUtil.SetText(self.scoreText, tostring(Pin3Data.GetGoldNum(self.uid)))
    end
    UIUtil.SetText(self.yzText, tostring(Pin3Data.GetYzGold(self.uid)))
    UIUtil.SetActive(self.offlineImg, not Pin3Data.GetIsOnline(self.uid))
    UIUtil.SetActive(self.zhuangTag, Pin3Data.curZhuangId == self.uid)
    self:SetBiPaiBtnVisible(false)

    local operType = Pin3Data.GetOperType(self.uid)
    if operType == Pin3UserOperType.GenZhu then
        UIUtil.SetActive(self.GengzhuImg, true)
        UIUtil.SetActive(self.JiazhuImg, false)
        --UIUtil.SetText(self.operText, "跟注")
    elseif operType == Pin3UserOperType.JiaZhu then
        UIUtil.SetActive(self.GengzhuImg, false)
        UIUtil.SetActive(self.JiazhuImg, true)
        --UIUtil.SetText(self.operText, "加注")
    else
        UIUtil.SetActive(self.JiazhuImg, false)
        UIUtil.SetActive(self.GengzhuImg, false)
        --UIUtil.SetText(self.operText, "")
    end

    local shuStatus = Pin3Data.GetShuStatus(self.uid)
    --Log("==>UpdateChangableInfo", self.uid, shuStatus, Pin3Data.GetIsKanPai(self.uid))
    UIUtil.SetActive(self.kanPaiImg, Pin3Data.GetIsKanPai(self.uid) and shuStatus == 0)
    if shuStatus ~= nil and shuStatus >= 1 then
        self:SetCardLostEffect()
    end
    local isQiPai = shuStatus == 1
    if self.qiPaiImg.gameObject.activeSelf ~= isQiPai then
        UIUtil.SetActive(self.qiPaiImg, isQiPai)
        if isQiPai == true then
            UIUtil.SetLocalScale(self.qiPaiImg.gameObject, 1.5, 1.5, 1.5)
            self.qiPaiImg:DOScale(Vector3.one, 0.3)
            if Pin3Data.isPlayback then
                local qiPaiType = Pin3Data.GetQiPaiType(self.uid)
                if qiPaiType == 0 then
                    UIUtil.SetImageColor(self.qiPaiImage, 1, 0, 0)
                else
                    UIUtil.SetImageColor(self.qiPaiImage, 1, 1, 1)
                end
            else
                UIUtil.SetImageColor(self.qiPaiImage, 1, 1, 1)
            end
        end
    end
    local isShu = shuStatus == 2
    if self.shuImg.gameObject.activeSelf ~= isShu then
        UIUtil.SetActive(self.shuImg, isShu)
        if isShu == true then
            UIUtil.SetLocalScale(self.shuImg.gameObject, 1.5, 1.5, 1.5)
            self.shuImg:DOScale(Vector3.one, 0.3)
        end
    end

    local gameStatus = Pin3Data.gameStatus
    if gameStatus ~= Pin3GameStatus.WaitingPrepare then
        UIUtil.SetActive(self.pangGuanTag, Pin3Data.GetIsPrepare(self.uid) == false)
    else
        UIUtil.SetActive(self.pangGuanTag, false)
    end
    UIUtil.SetActive(self.readyTag, false)
    UIUtil.SetActive(self.kanPaiImg, false)
    if gameStatus == Pin3GameStatus.WaitingPrepare then
        UIUtil.SetActive(self.readyTag, Pin3Data.GetIsPrepare(self.uid) == true)
        if self:IsSelf() then
            self.timeInfoImg:DOKill()
            self.timeInfoImg.fillAmount = Pin3Data.curDaoJiShi / Pin3Data.totalDaoJiShi
            Log("==>fillAmount", Pin3Data.curDaoJiShi, Pin3Data.totalDaoJiShi)
            self.timeInfoImg:DOFillAmount(0, Pin3Data.curDaoJiShi):SetEase(DG.Tweening.Ease.Linear)

            if Pin3Data.GetIsPrepare(self.uid) == true then
                --Pin3BattlePanel.ShowTips("游戏即将开始......")
            else
                --Pin3BattlePanel.ShowTips("请点击准备")
            end
        else
            self.timeInfoImg:DOKill()
            self.timeInfoImg.fillAmount = 0
        end
    elseif gameStatus == Pin3GameStatus.WaitingUserPerform then
        UIUtil.SetActive(self.kanPaiImg, Pin3Data.GetIsKanPai(self.uid) and shuStatus == 0)
        --操作中
        if Pin3Data.GetOperStatus(self.uid) == 1 then
            if Pin3Data.operType ~= Pin3UserOperType.KanPai then
                self.timeInfoImg:DOKill()
                self.timeInfoImg.fillAmount = Pin3Data.curDaoJiShi / Pin3Data.totalDaoJiShi
                self.timeInfoImg:DOFillAmount(0, Pin3Data.curDaoJiShi):SetEase(DG.Tweening.Ease.Linear)
            end
        else
            self.timeInfoImg:DOKill()
            self.timeInfoImg.fillAmount = 0
        end
    else
        self.timeInfoImg:DOKill()
        self.timeInfoImg.fillAmount = 0
    end

    local jieSuanGold = Pin3Data.GetJieSuanGold(self.uid)
    jieSuanGold = tonumber(jieSuanGold)
    if jieSuanGold and jieSuanGold ~= 0 then
        if jieSuanGold > 0 then
            UIUtil.SetText(self.yinText, "+" .. tostring(jieSuanGold))
            if not self.yinText.gameObject.activeSelf then
                UIUtil.SetAnchoredPosition(self.yinText, 0, 0)
                self.yinText:DOAnchorPosY(5, 0.5):SetEase(DG.Tweening.Ease.Linear)
            end
            UIUtil.SetActive(self.shuText, false)
            UIUtil.SetActive(self.yinText, true)
            self:WinAnim()
            if self:IsSelf() then
                Scheduler.scheduleOnceGlobal(function()
                    Pin3AudioManager.PlayAudio(Pin3AudioType.Win)
                end, 0.5)
            end
        else
            UIUtil.SetText(self.shuText, tostring(jieSuanGold))
            if not self.shuText.gameObject.activeSelf then
                UIUtil.SetAnchoredPosition(self.shuText, 0, 0)
                self.shuText:DOAnchorPosY(5, 0.5):SetEase(DG.Tweening.Ease.Linear)
            end
            UIUtil.SetActive(self.shuText, true)
            UIUtil.SetActive(self.yinText, false)
            if self:IsSelf() then
                Scheduler.scheduleOnceGlobal(function()
                    Pin3AudioManager.PlayAudio(Pin3AudioType.Lost)
                end, 0.5)
            end
        end
    else
        UIUtil.SetText(self.shuText, "0")
        UIUtil.SetText(self.yinText, "0")
        UIUtil.SetActive(self.shuText, false)
        UIUtil.SetActive(self.yinText, false)
    end
end

--清楚结算文本
function Pin3UserInfoCtrl:ClearJieSuanTexts()
    if self.shuText ~= nil then
        UIUtil.SetActive(self.shuText, false)
        UIUtil.SetActive(self.yinText, false)
    end
end

function Pin3UserInfoCtrl:WinAnim()
    local goTran = Pin3AnimManager.Play(Pin3AnimType.Win, self:GetWinAnimNode(), nil, false)
    UIUtil.SetLocalScale(goTran, 100, 100, 100)
    Scheduler.scheduleOnceGlobal(function()
        if not IsNull(goTran) then
            DestroyObj(goTran.gameObject)
        end
    end, 2)
end

function Pin3UserInfoCtrl:SetHeadIcon()
    local iconUrl = Pin3Data.GetHeadIcon(self.uid)
    Functions.SetHeadImage(self.headIconImg, Functions.CheckJoinPlayerHeadUrl(iconUrl))
    Scheduler.unscheduleGlobal(self.setRoleSchedule1)
    self.setIconSchedule1 = Scheduler.scheduleOnceGlobal(function()
        if not Functions.IsSetHeadImage(self.headIconImg) then
            Functions.SetHeadImage(self.headIconImg, Functions.CheckJoinPlayerHeadUrl(iconUrl))
        end
    end, 5)
    Scheduler.unscheduleGlobal(self.setRoleSchedule2)
    self.setIconSchedule2 = Scheduler.scheduleOnceGlobal(function()
        if not Functions.IsSetHeadImage(self.headIconImg) then
            Functions.SetHeadImage(self.headIconImg, Functions.CheckJoinPlayerHeadUrl(iconUrl))
        end
    end, 10)
end

function Pin3UserInfoCtrl:SetHeadIconOnclick()
    if Pin3Data.isPlayback == false then
        local limitScore = Pin3Data.GetRule(Pin3RuleType.zhuiRu)
        if limitScore == nil then
            limitScore = 0
        end
        self:AddOnClick(self.basicInfoTran, function()
            local arg = {
                name = Pin3Data.GetUserName(self.uid), --姓名
                sex = 1, --性别 1男 2 女
                id = self.uid, --玩家id
                gold = Pin3Data.GetGoldNum(self.uid), --金豆数量
                moneyType = MoneyType.Fangka, --货币类型
                limitScore = limitScore, --金豆场准入分数
                headUrl = Pin3Data.GetHeadIcon(self.uid), --头像链接
                headFrame = Pin3Data.GetFrameId(self.uid), --头像框
                canSend = not (Pin3Data.GetRule(Pin3RuleType.CantChat) == 1), --是否可以发送聊天信息
                address = GPSModule.GetGpsDataByPlayerId(self.uid).address
            }
            LogError(" 拼三--游戏内不显示点击玩家头像界面 ")
            -- ChatModule.OpenRoomUserInfoPanel(arg)
        end)
    end
end

function Pin3UserInfoCtrl:IsSelf()
    return self.uid == Pin3Data.uid
end

--设置比牌按钮显示隐藏
function Pin3UserInfoCtrl:SetBiPaiBtnVisible(visible)
    if self.biPaiBtn ~= nil then
        UIUtil.SetActive(self.biPaiBtn, visible)
    end
end

--重置下一盘数据
function Pin3UserInfoCtrl:Reset()
    self:ClearCardObjs()
    UIUtil.SetActive(self.shuText, false)
    UIUtil.SetActive(self.yinText, false)
end

--文本
Pin3UserInfoCtrl.chatText = nil
Pin3UserInfoCtrl.chatTranform = nil
Pin3UserInfoCtrl.chatKuang = nil
function Pin3UserInfoCtrl:SayText(str, duration)
    if not IsNumber(duration) and duration < 0.01 then
        duration = 1
    end
    if self.chatKuang == nil then
        self.chatKuang = self:Find("TextChat")
    end
    if self.chatTranform == nil then
        self.chatTranform = self.chatKuang:Find("TextChat")
    end
    if self.chatText == nil then
        self.chatText = self.chatTranform:Find("Text"):GetComponent("Text")
    end

    UIUtil.SetActive(self.chatKuang, true)

    Functions.SetChatText(self.chatTranform, self.chatText, str)
    Scheduler.scheduleOnceGlobal(function()
        UIUtil.SetActive(self.chatTranform, false)
    end, duration)
end

--表情
Pin3UserInfoCtrl.emotionParent = nil
function Pin3UserInfoCtrl:GetSayEmotionRoot()
    if self.emotionParent == nil then
        self.emotionParent = self:Find("TextChat/EmotionChat")
    end
    return self.emotionParent
end

--播放聊天气泡
function Pin3UserInfoCtrl:PlayVoiceBubble()
    -- VoiceChat
    if self.voiceBubble == nil then
        self.voiceBubble = self.transform:Find("VoiceChat")
    end
    UIUtil.SetActive(self.voiceBubble, true)
end

--停止播放聊天气泡
function Pin3UserInfoCtrl:StopVoiceBubble()
    if self.voiceBubble == nil then
        self.voiceBubble = self.transform:Find("VoiceChat")
    end
    UIUtil.SetActive(self.voiceBubble, false)
end