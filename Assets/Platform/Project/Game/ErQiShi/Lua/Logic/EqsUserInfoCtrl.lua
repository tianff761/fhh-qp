EqsUserInfoCtrl = ClassLuaComponent("EqsUserInfoCtrl")
EqsUserInfoCtrl.leftCardLineCtrls = {} --{EqsUserInfoCtrl, EqsUserInfoCtrl, EqsUserInfoCtrl}
EqsUserInfoCtrl.chuPaiCells = {} --{transform,transform,transform......}

EqsUserInfoCtrl.pengPaiIdx = 0

EqsUserInfoCtrl.initBasicInfos  = false
EqsUserInfoCtrl.uid             = nil --用户ID
EqsUserInfoCtrl.headIcon        = nil
EqsUserInfoCtrl.frameId         = nil
EqsUserInfoCtrl.score           = 0
EqsUserInfoCtrl.name            = ""
EqsUserInfoCtrl.isFz            = false --是否是房主
EqsUserInfoCtrl.ip              = ""
EqsUserInfoCtrl.sex             = 0 
EqsUserInfoCtrl.uiIdx           = 0 --前端座位索引
EqsUserInfoCtrl.seatId          = 0 --座位ID，后端的
EqsUserInfoCtrl.status          = 0 --用户状态
EqsUserInfoCtrl.address         = "" 
EqsUserInfoCtrl.jingDu          = 0 --经度
EqsUserInfoCtrl.weiDu           = 0 --纬度


EqsUserInfoCtrl.fingerTipSchedule   = nil
EqsUserInfoCtrl.fingerSchedule2     = nil
EqsUserInfoCtrl.fingerSchedule1     = nil

EqsUserInfoCtrl.clockTipSchedule    = nil
EqsUserInfoCtrl.clockPos            = nil
EqsUserInfoCtrl.chuPaiTips          = nil

--小家摸牌
EqsUserInfoCtrl.xiaoJiaMoPaiTran    = nil
--是否是小家
EqsUserInfoCtrl.isXiaoJia           = false

--战绩回放手牌控制
EqsUserInfoCtrl.cardsCtrl           = nil
--战绩回放执行点击操作的手指
EqsUserInfoCtrl.playbackFingerTran  = nil
--战绩回放状态按钮集合
EqsUserInfoCtrl.playbackOperBtnsTran = nil

--当前状态
EqsUserInfoCtrl.curStatus           = 0
EqsUserInfoCtrl.headIconImg         = nil
EqsUserInfoCtrl.headFrameImg        = nil

EqsUserInfoCtrl.autoPlayTag         = nil
--扣金币动画节点
EqsUserInfoCtrl.cutCoinAnimTran_Add     = nil
EqsUserInfoCtrl.cutCoinAnimTran_Sub     = nil
function EqsUserInfoCtrl:Init(uiIdx)
    self.pengPaiIdx = 0
    self.gameObject:SetActive(false)
    self.headIconImg = self.transform:Find("BasicInfo/HeadMask/HeadIcon"):GetComponent(typeof(Image))
    self.uiIdx = uiIdx
    self.initBasicInfos = false
    self.uid = nil
    self.headIcon = nil
    self.frameId = 0
    self.score = 0
    self.name = nil
    self.isFz = false
    self.ip = ""
    self.sex = 0
    self.status = 0
    self:SetVisible(false)
    --单局结算断线重连时时，不重新初始化
    if not PanelManager.IsOpened(EqsPanels.DanJuJieSuan) then
        self:InitCells()
    end
    self.chuPaiTips = self:Find('ChuPaiTips')
    if self.chuPaiTips then
        self.chuPaiTips.gameObject:SetActive(false)
    end
    self:SetZhuangTagVisible(false)
    self:SetAutoPlayTagVisible(false)
    self:SetLoadingTagVisible(false)
    self.xiaoJiaMoPaiTran = self:Find('XiaoJiaPaiInfo/CardMoPai')
    if self.xiaoJiaMoPaiTran ~= nil then
        self.xiaoJiaMoPaiTran.parent.gameObject:SetActive(false)
        self.xiaoJiaMoPaiTran.gameObject:SetActive(false)
    end

    self.playbackFingerTran = self.transform:Find("PlayBackBtns/Finger")
    self.playbackOperBtnsTran = self.transform:Find("PlayBackBtns/PlaybackOperationBtns")
    self:HideAllPlaybackBtns()
    
    self.cutCoinAnimTran_Add = self:Find("BasicInfo/GoldAnimText_Add")
    self.cutCoinAnimTran_Sub = self:Find("BasicInfo/GoldAnimText_Sub")
end

function EqsUserInfoCtrl:SetVisible(visible)
    if visible ~= nil and visible == true then
        self.gameObject:SetActive(true)
    else
        self.gameObject:SetActive(false)
    end
end

--设置用户从网络获取的基本信息  user包含字段：uid,userName,icon,sex,seatId,score,isOwner,ip,status,online
function EqsUserInfoCtrl:SetBasicInfo(user)
    self.uid = user.uid
    self.headIcon = user.icon
    self.frameId = user.frameId
    self.score = tonumber(user.score)
    self.name = user.userName
    self.isFz = user.isOwner
    self.ip = user.ip
    self.sex = user.sex
    self.status = user.status
    self:SetName(self.name)
    self:SetUid(self.uid)
    self:SetHeadIcon(self.headIcon, self.frameId)
    self:SetScore(self.score)
    self:SetVisible(true)
    self:SetLeftCardCount(0)
    self.initBasicInfos = true
    self:SetHeadIconOnclick()
    self:SetOfflineTagVisible(not user.online)
    UIUtil.SetActive(self.gameObject, true)
    --不在此处设置状态，初始化完基本信息后设置状态
   -- self:SetStatus(self.status)
    self:SetAutoPlayTagVisible(user.auto)
    if IsBool(user.loading) then
        self:SetLoadingTagVisible(not user.loading)
    else
        self:SetLoadingTagVisible(not user.loading)
    end
    if self:IsSelf() then
        --这三个状态时，未发牌，不做断线重连处理
        if self.status == EqsUserStatus.WaitJoin or self.status == EqsUserStatus.Preparing or self.status == EqsUserStatus.Prepared then
            UserData.SetIsReconnectTag(false)
        end
    end

    self:SetGoldIcon()

    UIUtil.SetActive(self.cutCoinAnimTran_Add, false)
    UIUtil.SetActive(self.cutCoinAnimTran_Sub, false)
    
    if BattleModule.userNum == 3 then
        self.clockPos = EqsBattlePanel.GetTransform():Find("Content/ClockContainer/Player3/ClockPos" .. tostring(self.uiIdx))
        self.effectPos = EqsBattlePanel.GetTransform():Find("Content/ClockContainer/Player3/EffectPos" .. tostring(self.uiIdx))
    elseif BattleModule.userNum == 4 then
        self.clockPos = EqsBattlePanel.GetTransform():Find("Content/ClockContainer/Player4/ClockPos" .. tostring(self.uiIdx))
        self.effectPos = EqsBattlePanel.GetTransform():Find("Content/ClockContainer/Player4/EffectPos" .. tostring(self.uiIdx))
    elseif BattleModule.userNum == 2 then
        self.clockPos = EqsBattlePanel.GetTransform():Find("Content/ClockContainer/Player2/ClockPos" .. tostring(self.uiIdx))
        self.effectPos = EqsBattlePanel.GetTransform():Find("Content/ClockContainer/Player2/EffectPos" .. tostring(self.uiIdx))
    end

    if BattleModule.isPlayback then
        self.cardsCtrl = PlaybackOthersHandCards.New()
        self.cardsCtrl:Init(self.transform:Find("PlayBackHandCards"), self.uid, self.uiIdx, self)
        if self.cardsCtrl.transform ~= nil then
            self.cardsCtrl.transform.gameObject:SetActive(BattleModule.isPlayback)
        end
    end
end

function EqsUserInfoCtrl:IsCreator()
    return self.isFz == true
end

function EqsUserInfoCtrl:SetLocation(weiDu, jingDu)
    self.jingDu = jingDu
    self.weiDu = weiDu
   -- Log("设置GPS", self.jingDu, self.weiDu)
end

function EqsUserInfoCtrl:SetStatus(status, operations)
    Log("设置状态：", self.uid, status, operations, BattleModule.curJuShu)
    self:SetPreparedTagVisible(false)
    self:SetChangedTagVisible(false)
    self:SetChangingTagVisible(false)
    Scheduler.unscheduleGlobal(self.huanBtnDelayShow)
    self.status = status
    if self:IsSelf() then
        --设置隐藏各种状态，当要显示某些按钮时，根据后面状态显示
        EqsBattlePanel.HideAllOperationBtns()
        BattleModule.isSelectingHsz = false
        EqsBattlePanel.HideWaitingBtns()
        BattleModule.SetOperations(operations)
        if self.status ~= EqsUserStatus.Changing then
            EqsBattlePanel.SetChangeBtnVisible(false)
            EqsBattlePanel.SetChangeBtnAnim(false)
        end
        --处理关闭准备弹窗
        if PanelManager.IsOpened(PanelConfig.RoomGps) and status ~= EqsUserStatus.Preparing then
            SendEvent(CMD.Game.RoomGpsReadyFinished)
        end

        if status > EqsUserStatus.Preparing then
              --关闭单局结算
              PanelManager.Close(EqsPanels.DanJuJieSuan)   
        end
        if status <= EqsUserStatus.Changed then
            SelfHandEqsCardsCtrl.SetIsSyscByTempIds(false)
            SelfHandEqsCardsCtrl.SetTempIds(nil)
        end
        self:UnscheduleFingerTips()
        if status == EqsUserStatus.WaitJoin then
            EqsBattlePanel.ShowWaitingBtns()
        elseif status == EqsUserStatus.Preparing then
            if BattleModule.IsFkFlowRoom() then
                if not BattleModule.isStarted then
                    PanelManager.Open(PanelConfig.RoomGps, BattleModule.GetGpsMapData())
                end
            else
                if not BattleModule.isStarted and not PanelManager.IsOpened(EqsPanels.DanJuJieSuan) then
                    PanelManager.Open(PanelConfig.RoomGps, BattleModule.GetGpsMapData())
                end
            end
        elseif status == EqsUserStatus.Prepared then   
            self:SetPreparedTagVisible(true) 
            BattleModule.InitNextJuShu() 
        elseif status == EqsUserStatus.Changing then --发完牌后，设置换按钮隐藏和显示。理由：防止其他玩家选择换时，重新设置自己状态时，会隐藏1s
            BattleModule.isSelectingHsz = true
            self:SetChangingTagVisible(true)
        elseif status == EqsUserStatus.Changed then    
            self:SetChangedTagVisible(true)
        elseif status == EqsUserStatus.Waiting then        
        elseif status == EqsUserStatus.Operating then 
            self:setStatusOperations(status, operations)       
        elseif status == EqsUserStatus.ChuPai then--不解析自己出牌 
            SelfHandEqsCardsCtrl.SetIsSyscByTempIds(true)
            self:ScheduleClock()
            self:ScheduleFinger()
        elseif status == EqsUserStatus.Hu then --胡牌特效       
        end
    else
        if status == EqsUserStatus.WaitJoin         then
        elseif status == EqsUserStatus.Preparing    then
            self:SetZhuangTagVisible(false)
        elseif status == EqsUserStatus.Prepared     then   
            --准备时，隐藏闹钟
            self:UnscdeduleClock()
            if not IsNull(self.clockPos) then
                UIUtil.SetActive(self.clockPos, false)
            end
            self:SetPreparedTagVisible(true)     
        elseif status == EqsUserStatus.Changing     then        
            self:SetChangingTagVisible(true)
        elseif status == EqsUserStatus.Changed      then        
            self:SetChangedTagVisible(true)
        elseif status == EqsUserStatus.Waiting      then        
        elseif status == EqsUserStatus.Operating    then        
        elseif status == EqsUserStatus.ChuPai       then 
            self:ScheduleClock()
        elseif status == EqsUserStatus.Hu           then        
        end
    end
end

function EqsUserInfoCtrl:setStatusOperations(status, operations)
    if self:IsSelf() then
        if status == EqsUserStatus.Operating and IsTable(operations) then
            Scheduler.unscheduleGlobal(self.baiHandle)
            local hasKai = false
            local baiCount = 0
            local baiOperation = nil
            for _, oper in pairs(operations) do
                EqsBattlePanel.SetOperationBtn(oper.oper)
                if oper.oper == EqsOperation.Kai then  hasKai = true end
                if oper.oper == EqsOperation.BaiPai then   
                    baiCount = baiCount + 1
                    baiOperation = oper
                end
            end

            --有开时，必须隐藏过按钮
            if hasKai then EqsBattlePanel.SetGuoBtnVisible(false) end

            --摆个数大于1，弹摆窗口
            if baiCount > 1 then
                PanelManager.Open(EqsPanels.BaiPanel, operations)
            elseif baiCount == 1 then
                SelfHandEqsCardsCtrl.SetDraggable(false, 2)
                --延时1s执行，等待吃动画
                self.baiHandle = Scheduler.scheduleOnceGlobal(function() 
                    --发送摆牌指令
                    BattleModule.SendOperationType(baiOperation.oper)
                end, 1)
            end
        end
    end
end

function EqsUserInfoCtrl:PerformOperation(operation)
    Log("执行操作：", self.uid, operation)
    if operation.oper == EqsOperation.HanSanZhang then
        if self:IsSelf() then
            EqsBattlePanel.HideAllOperationBtns()
        end
    elseif operation.oper == EqsOperation.Hu then
        SelfHandEqsCardsCtrl.SetIsSyscByTempIds(false)
        self:PlayEffect(EffectType.EqsHu)
    elseif operation.oper == EqsOperation.Kai then
        self:PlayEffect(EffectType.EqsKai)
        EqsBattleCtrl.ClearChuPaiInfo()
        if not self:IsSelf() then
            self:ScheduleClock()
        end
    elseif operation.oper == EqsOperation.BaYu then
        self:PlayEffect(EffectType.EqsYu)
    elseif operation.oper == EqsOperation.Dui then
        self:PlayEffect(EffectType.EqsDui)
        EqsBattleCtrl.ClearChuPaiInfo()
        if not self:IsSelf() then
            self:ScheduleClock()
        end
    elseif operation.oper == EqsOperation.Chi then
        self:PlayEffect(EffectType.EqsEat)
        EqsBattleCtrl.ClearChuPaiInfo()
        if not self:IsSelf() then
            self:ScheduleClock()
        end
    elseif operation.oper == EqsOperation.BaiPai then
        self:PlayEffect(EffectType.EqsBai)
    elseif operation.oper == EqsOperation.ChuPai then --出牌
        self:ChuPai(EqsTools.GetTargetId(operation))
        if not self:IsSelf() then
            self:ScheduleClock()
        end
    elseif operation.oper == EqsOperation.FanPai then --翻牌
        self:FanPai(EqsTools.GetTargetId(operation))
        self:ScheduleClock()
    end
    EqsSoundManager.PlayOperationAudio(operation.oper,self.sex)
end

EqsUserInfoCtrl.hszSchedule = nil
--播放换三张动画
function EqsUserInfoCtrl:PlayHszAnim(tran)
    local waitTime = 0.6
    local scale = Vector3(0.7, 0.7, 0.7)
    local tagetPos = tran.position + Vector3(0, 2, 0)
    if self:IsSelf() then
        local idx = 0
        local queue = EqsBattleCtrl.GetHszQueue()
        if queue ~= nil and queue:Items() ~= nil then
            for _, card in pairs(queue:Items()) do
                local card = card
                card:SetHuanVisible(false)
                Scheduler.scheduleOnceGlobal(function ()
                    card.transform:DOScale(scale, 0.25) 
                    card.transform:DOMove(tagetPos, 0.3,true):OnComplete(function ()
                        card.transform:DOMove(tagetPos, waitTime,true):OnComplete(function ()
                            card.transform:DOLocalMove(Vector3(0,0,0), 0.3, true)
                            card:SetChangedHuanVisible(true)
                            card.transform:DOScale(Vector3(1, 1, 1), 0.25)
                        end)
                    end)
                end,idx * 0.05)
                idx = idx + 1
            end
        end
    else
        local idx = 0
        for i = 1, 3 do
            Scheduler.scheduleOnceGlobal(function ()
                local cardBg = NewObject(EqsBattlePanel.GetCardBg().gameObject)
                cardBg.transform:SetParent(self.transform)
                cardBg.transform.localPosition = Vector3(0,0,0)
                cardBg.transform.localScale = Vector3(0.3,0.3,0.3)
                cardBg.transform:DOMove(tagetPos, 0.3, true) 
                cardBg.gameObject:SetActive(true)
                cardBg.transform:DOScale(scale, 0.25) 
                cardBg.transform:DOMoveZ(tagetPos.z, 0.3,true):OnComplete(function ()
                    local curY = cardBg.transform.localPosition.y
                    if i == 1 then
                        cardBg.transform:DOLocalMoveY(curY + 30, 0.1, true):OnComplete(function ()
                            cardBg.transform:DOLocalMoveY(curY, 0.1, true):OnComplete(function ()
                                cardBg.transform:DOLocalMoveY(curY + 30, 0.1, true):OnComplete(function ()
                                    cardBg.transform:DOLocalMoveY(curY, 0.1, true)
                                end)
                            end)
                        end)
                    elseif i == 2 then 
                        cardBg.transform:DOLocalMoveY(curY - 30, 0.1, true):OnComplete(function ()
                            cardBg.transform:DOLocalMoveY(curY, 0.1, true):OnComplete(function ()
                                cardBg.transform:DOLocalMoveY(curY - 30, 0.1, true):OnComplete(function ()
                                    cardBg.transform:DOLocalMoveY(curY, 0.1, true)
                                end)
                            end)
                        end)
                    end
                    cardBg.transform:DOMoveZ(tagetPos.z, waitTime,true):OnComplete(function ()
                        cardBg.transform:DOScale( Vector3(0.3,0.3,0.3), 0.25) 
                        cardBg.transform:DOLocalMove(Vector3(0,0,0), 0.3, true):OnComplete(function ()
                            cardBg.gameObject:SetActive(false)
                        end)
                    end)
                end)
            end, idx * 0.05)
            idx = idx + 1
        end
    end
end

function EqsUserInfoCtrl:InitCells()
    self.leftCardLineCtrls = {}
    local line = nil
    --初始化碰牌Cell:6列，每列4个
    for i = 1, 6 do
        line = self:Find("PengPaiInfo/Line" .. i)
        self.leftCardLineCtrls[i] = AddLuaComponent(line.gameObject, "LeftCardLineCtrl")
        self.leftCardLineCtrls[i]:Init()
    end

    --初始化出牌Cell
    self.chuPaiCells = {}
    local chuPaiInfo = self.transform:Find("ChuPaiInfo")
    local childCount = chuPaiInfo.childCount
    for i = 0, childCount - 1 do
        self.chuPaiCells[i] = self.transform:Find("ChuPaiInfo/Cell" .. i)
    end
end

function EqsUserInfoCtrl:SetName(name)
    local text = self.transform:Find("BasicInfo/Name"):GetComponent(typeof(Text))
    text.text = tostring(name)
end

function EqsUserInfoCtrl:SetUid(uid)
    local text = self.transform:Find("BasicInfo/Uid"):GetComponent(typeof(Text))
    text.text = tostring(uid)
end

function EqsUserInfoCtrl:SetScore(score)
   -- Log("设置分数：", self.uid, score)
    if IsNull(self.transform) then
        return 
    end
    local text = self.transform:Find("BasicInfo/Score"):GetComponent(typeof(Text))
    if BattleModule.IsGoldRoom() then
        text.text = tostring(score)
    else
        text.text = tostring(score)
    end
end

function EqsUserInfoCtrl:CutGold(cutGold, totalGold)
    if BattleModule.IsGoldRoom() then
        if tonumber(cutGold) == 0 then
            self:SetScore(totalGold)
        else 
            local cutCoinAnimTran = tonumber(cutGold) >= 0 and self.cutCoinAnimTran_Add or self.cutCoinAnimTran_Sub
            local originX = cutCoinAnimTran.localPosition.x
            UIUtil.SetText(cutCoinAnimTran, Functions.TernaryOperator(tonumber(cutGold) >= 0, "+"..tostring(cutGold), tostring(cutGold)))
            UIUtil.SetActive(cutCoinAnimTran, true)
            cutCoinAnimTran.localPosition = Vector3(originX, -40, 0)
            local v3 = Vector3(originX, 100, 0)
            cutCoinAnimTran:DOLocalMove(v3, 1.5):OnComplete(function ()
                Scheduler.scheduleOnceGlobal(function()  
                    UIUtil.SetActive(cutCoinAnimTran, false)
                    self:SetScore(totalGold)
                end, 1)
            end)   
        end
        
    end
end

function EqsUserInfoCtrl:SetHeadIcon(iconUrl, frameId)
    local imgobj = self.transform:Find("BasicInfo/HeadMask/HeadIcon"):GetComponent(typeof(Image))
    Functions.SetHeadImage(imgobj, iconUrl)

    -- imgobj = self.transform:Find("BasicInfo/HeadMask/HeadIcon/HeadIconBoard/"):GetComponent(typeof(Image))
    -- Functions.SetHeadFrame(imgobj, frameId)
end

function EqsUserInfoCtrl:SetHeadIconOnclick()
    if BattleModule.isPlayback == false then
        local limitScore = BattleModule.GetRule(EqsRuleType.TeaInGold)
        if limitScore == nil then
           limitScore = 0
        end
        self:AddOnClick(self.transform:Find("BasicInfo"), function()
            local arg = {
                name = self.name, --姓名
                sex = self.sex, --性别 1男 2 女
                id = self.uid, --玩家id
                gold = self.score, --分数数量
                moneyType = MoneyType.Fangka, --货币类型
                limitScore = limitScore,--分数场准入分数
                headUrl = self.headIcon, --头像链接
                headFrame = self.frameId, --头像框
                address = GPSModule.GetGpsDataByPlayerId(self.uid).address
            }
            LogError(" 二七十--游戏内不显示点击玩家头像界面 ")
            -- PanelManager.Open(PanelConfig.RoomUserInfo, arg)
        end)
    end
end

function EqsUserInfoCtrl:IsReadyTagVisible()
    local tag = self.transform:Find("BasicInfo/ReadyTag")
    if tag ~= nil and tag.gameObject.activeSelf == true then
        return true
    end
    return false
end

function EqsUserInfoCtrl:SetPreparedTagVisible(visible)
    local tag = self.transform:Find("BasicInfo/ReadyTag")
    tag.gameObject:SetActive(visible)
end

function EqsUserInfoCtrl:SetLoadingTagVisible(visible)
    local tag = self.transform:Find("BasicInfo/LoadingTag")
    UIUtil.SetActive(tag, visible)
end

function EqsUserInfoCtrl:SetChangedTagVisible(visible)
   -- Log("SetChangedTagVisible:", self.uid, "  rd:", visible, self.transform.name)
    local tag = self.transform:Find("BasicInfo/YiXuanPaiTag")
    if tag ~= nil then
        tag.gameObject:SetActive(visible)
    end
end

function EqsUserInfoCtrl:SetChangingTagVisible(visible)
  --  Log("SetChangingTagVisible:", self.uid, "  rd:", visible, self.transform.name)
    local tag = self.transform:Find("BasicInfo/XuanPanZhong")
    if tag ~= nil then
        tag.gameObject:SetActive(visible)
    end
end

function EqsUserInfoCtrl:SetGoldIcon()
    -- local tag = self.transform:Find("BasicInfo/GoldIcon")
    -- UIUtil.SetActive(tag, BattleModule.IsGoldRoom())
end

--设置庄标记
function EqsUserInfoCtrl:SetZhuangTagVisible(visible)
  --  Log("设置庄家：", self.uid, visible)
    local tag = self.transform:Find("BasicInfo/ZhuangTag")
    tag.gameObject:SetActive(visible == true)
end

function EqsUserInfoCtrl:SetAutoPlayTagVisible(visible)
    if visible == nil then
        visible = false
    end
   -- Log("设置托管：", visible, self.uid)
    if self:IsSelf() then
        local tag = EqsBattlePanel.GetAutoPlayTran()
        UIUtil.SetActive(tag, visible)
        if visible == true then
            local maskBtn = tag:Find("MaskBtn")
            local cancleBtn = tag:Find("CancelButton")
            self:AddOnClick(maskBtn, function ()
                BattleModule.SendAutoPlay(false)
            end)
            UIUtil.SetActive(cancleBtn, not BattleModule.isPlayback)
        end
    else
        local tag = self:Find("BasicInfo/AutoPlayTag")
        if tag ~= nil then
            UIUtil.SetActive(tag, visible)
        end
    end
end

--设置离线标记
function EqsUserInfoCtrl:SetOfflineTagVisible(visible)
    local tag = self.transform:Find("BasicInfo/OffLineTag")
    local isUpdateTime = false
    if visible == true and tag.gameObject.activeSelf == false then
        isUpdateTime = true
    end
    tag.gameObject:SetActive(visible == true)
    if isUpdateTime then
        Scheduler.unscheduleGlobal(self.offlineTimeSchedule)
        if self.offlineTime == nil or self.offlineTime < 0 then
            self.offlineTime = 0
        end
        local text = tag:Find("Text")
        UIUtil.SetText(text, "离线\n00:00")
        self.offlineTimeSchedule = Scheduler.scheduleGlobal(function ()
            if IsNull(text) then
                Scheduler.unscheduleGlobal(self.offlineTimeSchedule)
                return 
            end
            self.offlineTime = self.offlineTime + 1
            local min = tostring(math.floor(self.offlineTime / 60))
            if #min == 1 then
                min = "0"..min
            elseif #min <= 0 then
                min = "00"
            end
            local sec = tostring(self.offlineTime % 60)
            if #sec == 1 then
                sec = "0"..sec
            elseif #sec <= 0 then
                sec = "00"
            end
            UIUtil.SetText(text, "离线\n"..min..":"..sec.."")
        end, 1)
    end
    if visible == false then
        Scheduler.unscheduleGlobal(self.offlineTimeSchedule)
        self.offlineTime = -1
    end
end

--设置小家
function EqsUserInfoCtrl:SetIsXiaoJia(isXj)
  --  Log("设置小家：", isXj)
    self.isXiaoJia = isXj == true
    if self.cardsCtrl ~= nil then
        self.cardsCtrl.isXiaoJia = self.isXiaoJia
    end
    if self:IsSelf() then
        SelfHandEqsCardsCtrl.isXiaoJia = self.isXiaoJia
    end
end

--rules:{"id2":522,"targetId":521,"id3":0,"from":2,"id1":511,"oper":46}组成的数组
function EqsUserInfoCtrl:ParseLeftCard(rules)
    for i, lineCtrl in pairs(self.leftCardLineCtrls) do
        if rules[i] ~= nil then
            self.pengPaiIdx = i
            lineCtrl:AddOperationGroup(rules[i], self)
        else
            lineCtrl:Reset()
        end
    end
end

--断线重连解析出牌 
function EqsUserInfoCtrl:ParseRightCard(rightCard)
    Log("ParseRightCard", self.uid, rightCard, type(rightCard))
    if IsNumber(rightCard) then
        local card = EqsCardsManager.GetCardByUid(rightCard)
        if card ~= nil then
            EqsBattleCtrl.SetChuPaiInfo(card, self.uid, false, false)
            if self:IsSelf() then
                SelfHandEqsCardsCtrl.AddChuPaiToChuPaiRect(card)
            else
                local pos = self.transform:Find("BasicInfo/ChuPaiPos")
                card.transform:SetParent(pos)
                card.transform.localPosition = Vector3.zero
                card.transform.localRotation = Vector2(0, 0, 0)
            end
        end
    else
        self:ClearChuPaiPos()
    end
end

--解析用户出牌
function EqsUserInfoCtrl:ParseChuPai(cardids)
    local cell = nil
    local cellCardUid = 0
    for idx, id in pairs(cardids) do
        cell = self.chuPaiCells[idx]
        if cell ~= nil then
            cellCardUid = EqsTools.GetCellCardUid(cell)
            if cellCardUid ~= id then
                if cellCardUid > 0 then
                    EqsTools.RecycleSmallCardCell(cell)
                end
                EqsTools.AddSmallCardToCell(id, cell)
            end
        end
    end

    local beginIdx = #cardids + 1
    local endIdx   = #self.chuPaiCells
    for i = beginIdx, endIdx do
        EqsTools.RecycleSmallCardCell(self.chuPaiCells[i])
    end
end

--用户出牌  不处理自己出牌。自己出牌流程：772回复出牌失败时，回收已出牌   回放时，此处自己出牌
function EqsUserInfoCtrl:ChuPai(cardUid, gChuPaiPos)
    Log("出牌：", self.uid, cardUid)
    if not self:IsSelf() then
        --获取出牌出牌位置
        local pos = self.transform:Find("BasicInfo/ChuPaiPos")
        if BattleModule.isPlayback then
            pos = self.transform:Find("BasicInfo/PlayBackChuPaiPos")
        end
       
        local time = EqsTools.GetTime(0.3)
        if self.isXiaoJia then
        else
            --从自己头像位置出牌到出牌区域
            local card = EqsCardsManager.GetCardByUid(cardUid)
            EqsBattleCtrl.SetChuPaiInfo(card, self.uid, false, true)
            local fromGpos = self.transform.position
            --回放
            if BattleModule.isPlayback and gChuPaiPos then
                if gChuPaiPos.x ~= 0 and gChuPaiPos.y ~= 0 then
                    fromGpos = gChuPaiPos
                end
            end
            card.transform.position = fromGpos
            card.transform:SetParent(pos)
            card.transform.localScale = Vector3(0.2, 0.2, 0.2)
            card.isActive = false
            card.transform:DOScale(Vector3(1, 1, 1), time)
            card.transform:DOLocalMove(Vector3.zero, time, false)
            card.transform.localRotation = Quaternion.Euler(0, 0, -90)
            card.transform:DOLocalRotate(Vector3(0, 0, 0), time, DG.Tweening.RotateMode.Fast)
        end
    end
end

--用户翻牌  小家时，为用户摸牌[直接同步牌，此处不处理]
function EqsUserInfoCtrl:FanPai(cardUid)
    if self.isXiaoJia and not self:IsSelf() then
        return 
    end
    if cardUid == 0 then
        LogError("牌ID错误：", self.uid, cardUid)
        return 
    end
    if self:IsSelf() then
        local eqsCard = EqsCardsManager.GetCardByUid(cardUid)
        eqsCard.isFanPai = false
        EqsBattleCtrl.SetChuPaiInfo(eqsCard, self.uid, false, true)
        SelfHandEqsCardsCtrl.AddFanPaiToChuPaiRect(eqsCard, true)
    else
        local pos = self.transform:Find("BasicInfo/ChuPaiPos")
        if BattleModule.isPlayback then
            pos = self.transform:Find("BasicInfo/PlayBackChuPaiPos")
        end
    
        local time = EqsTools.GetTime(0.3)
        --从翻牌位置翻牌到出牌区域
        local card = EqsCardsManager.GetCardByUid(cardUid)
        if card ~= nil then
            EqsBattleCtrl.SetChuPaiInfo(card, self.uid, false, true)
            local fromGpos = EqsBattlePanel.GetFanPaiGPos()
            card.transform.position = fromGpos
            card.transform:SetParent(pos)
            card.transform.localScale = Vector3(0.2, 0.2, 0.2)
            card.isActive = false
            card.transform:DOScale(Vector3(1, 1, 1), time)
            card.transform:DOLocalMove(Vector3.zero, time, false)
            card.transform.localRotation = Quaternion.Euler(0, 0, 90)
            card.transform:DOLocalRotate(Vector3(0, 0, 0), time, DG.Tweening.RotateMode.Fast)
        else
            LogError("翻牌错误", cardUid, self.uid)
        end
    end
end


function EqsUserInfoCtrl:SetYuCards()
    for _, cell in pairs(self.chuPaiCells) do
        EqsTools.SetCellCardYuTag(cell)
    end

    for _, line in pairs(self.leftCardLineCtrls) do
        line:SetYuTag()
    end
end

function EqsUserInfoCtrl:PlaybackOthersChuPai(cardUid)
    local card = self.cardsCtrl:GetCardByCardUid(cardUid)
    if card ~= nil then
        self:ChuPai(cardUid, card.transform.position)
    else
        self:ChuPai(cardUid)
    end
end

--设置战绩回放操作项，参数意义同：EqsUserInfo:SetState(status, operation, delayTime)
function EqsUserInfoCtrl:SetPlaybackState(status, operation)
  --  Log('EqsUserInfo:SetPlaybackState:', status, self.uid, operation)
    self:HideAllPlaybackBtns()
    self.status = status
    if status == EqsUserStatus.Operating and GetTableSize(operation) > 0 then
        for _, oper in pairs(operation) do
            self:ShowPlaybackOperBtn(oper.oper)
        end
    end
    self:SetChangingTagVisible(false)
    self:SetChangedTagVisible(false)
    if status == EqsUserStatus.Changing then
        self:SetChangingTagVisible(true)
    elseif status == EqsUserStatus.Changed then
        self:SetChangedTagVisible(true)
    else
      
    end
end

function EqsUserInfoCtrl:HideAllPlaybackBtns()
  --  Log("隐藏所有回放操作按钮：", self.uid)
    self.playbackFingerTran.gameObject:SetActive(false)
    self.playbackOperBtnsTran.gameObject:SetActive(false)
    local childCount = self.playbackOperBtnsTran.childCount
    if childCount > 0 then
        for i = 0, childCount - 1 do
            local tran = self.playbackOperBtnsTran:GetChild(i)
            tran.gameObject:SetActive(false)
        end
    end
end

function EqsUserInfoCtrl:ShowPlaybackOperBtn(operType)
  --  Log("显示按钮：", operType)
    self.playbackOperBtnsTran.gameObject:SetActive(true)
    if tonumber(operType) == EqsOperation.Kai then
        self.playbackOperBtnsTran:Find("GuoBtn").gameObject:SetActive(false)
        self.playbackOperBtnsTran:Find("KaiBtn").gameObject:SetActive(true)
    elseif tonumber(operType) == EqsOperation.Dui then
        self.playbackOperBtnsTran:Find("GuoBtn").gameObject:SetActive(true)
        self.playbackOperBtnsTran:Find("DuiBtn").gameObject:SetActive(true)
    elseif tonumber(operType) == EqsOperation.Chi then
        self.playbackOperBtnsTran:Find("GuoBtn").gameObject:SetActive(true)
        self.playbackOperBtnsTran:Find("ChiBtn").gameObject:SetActive(true)
    elseif tonumber(operType) == EqsOperation.Hu then
        self.playbackOperBtnsTran:Find("GuoBtn").gameObject:SetActive(true)
        self.playbackOperBtnsTran:Find("HuBtn").gameObject:SetActive(true)
    elseif tonumber(operType) == EqsOperation.HanSanZhang then
        self.playbackOperBtnsTran:Find("HuanBtn").gameObject:SetActive(true)
    end
end

function EqsUserInfoCtrl:ClickPlaybackBtn(operType, callback)
    local btn = nil
    if tonumber(operType) == EqsOperation.Kai then
        btn = self.playbackOperBtnsTran:Find("KaiBtn")
    elseif tonumber(operType) == EqsOperation.Dui then
        btn = self.playbackOperBtnsTran:Find("DuiBtn")
    elseif tonumber(operType) == EqsOperation.Chi then
        btn = self.playbackOperBtnsTran:Find("ChiBtn")
    elseif tonumber(operType) == EqsOperation.Hu then
        btn = self.playbackOperBtnsTran:Find("HuBtn")
    elseif tonumber(operType) == EqsOperation.Guo then
        btn = self.playbackOperBtnsTran:Find("GuoBtn")
    elseif tonumber(operType) == EqsOperation.HanSanZhang then
        btn = self.playbackOperBtnsTran:Find("HuanBtn")
    end
    if btn ~= nil then
        Log("用户点击xx:", self.uid, operType, btn.gameObject.name, tostring(self.playbackFingerTran))
        Scheduler.scheduleOnceGlobal(HandlerByStatic(self, self.HideAllPlaybackBtns), 0.4)
        self.playbackFingerTran.gameObject:SetActive(true)
        self.playbackFingerTran:SetParent(btn)
        self.playbackFingerTran.localPosition = Vector3.zero
        self.playbackFingerTran.localScale = Vector3(3, 3, 3)
        if callback == nil then
            self.playbackFingerTran:DOScale(Vector3(1, 1, 1), 0.15)
        else
            self.playbackFingerTran:DOScale(Vector3(1, 1, 1), 0.15):OnComplete(callback)
        end

        local img = btn:GetComponent(typeof(Image))
        Scheduler.scheduleOnceGlobal(function()
            img.color = Color(0.7, 0.7, 0.7, 1)
        end, 0.1)
        Scheduler.scheduleOnceGlobal(function()
            img.color = Color(1, 1, 1, 1)
        end, 0.2)
    else
        Log("用户点击xx:", self.uid, operType, tostring(self.playbackFingerTran))
        if callback ~= nil then
            callback()
        end
    end
end

--设置选中换三张牌效果
function EqsUserInfoCtrl:PlaybackSelectedHsz(cardid1, cardid2, cardid3)
    Log("选中换三张", self.uid, cardid1, cardid2, cardid3, BattleModule.isPlayback)
    if BattleModule.isPlayback then
        if self:IsSelf() then
            SelfHandEqsCardsCtrl.OnPlaybackCancelAllEffect()
            SelfHandEqsCardsCtrl.OnHszEffect(cardid1, cardid2, cardid3, 0)
        else
            self.cardsCtrl:CancleAllEffect()
            self.cardsCtrl:OnSelectedHsz(cardid1, cardid2, cardid3, 0)
        end
    end
end
--设置替换后换三张牌的效果
function EqsUserInfoCtrl:PlaybackChangedHsz(cardid1, cardid2, cardid3)
    Log("换牌后换三张", self.uid, cardid1, cardid2, cardid3, BattleModule.isPlayback)
    if BattleModule.isPlayback then
        if self:IsSelf() then
            SelfHandEqsCardsCtrl.OnPlaybackCancelAllEffect()
            SelfHandEqsCardsCtrl.OnHszEffect(cardid1, cardid2, cardid3, 1)
        else
            self.cardsCtrl:CancleAllEffect()
            self.cardsCtrl:OnSelectedHsz(cardid1, cardid2, cardid3, 1)
        end
    end
end

function EqsUserInfoCtrl:GetStatus(status)
    return self.status
end

--设置当前手牌张数
function EqsUserInfoCtrl:SetLeftCardCount(handCards)
    local text = self.transform:Find("BasicInfo/HandCardNum/Num")
    if text ~= nil then
        local lable = text:GetComponent(typeof(Text))
        if lable ~= nil then
            if IsTable(handCards) then
                lable.text = tostring(GetTableSize(handCards))
            else
                lable.text = tostring(handCards)
            end
        end
    end

    if self.isXiaoJia and not BattleModule.isPlayback then
        self.xiaoJiaMoPaiTran.parent.gameObject:SetActive(true)
    end
end

function EqsUserInfoCtrl:IsSelf()
    return self.uid == BattleModule.uid
end

--回收出牌信息
function EqsUserInfoCtrl:ClearChuPaiPos()
    if IsNull(self.transform) then
        return
    end
    local pos = self.transform:Find("BasicInfo/ChuPaiPos")
    if pos ~= nil then
        local count = pos.childCount
        for i = 0, count - 1 do
            EqsCardsManager.RecycleCardTran(pos:GetChild(i))
        end
    end
end

--战绩回放时自己出牌 
function EqsUserInfoCtrl:PlaybackSelfChuPai(cardid, isPlaybackSelfChuPai)
    Log("PlaybackSelfChuPai：", cardid, self.uid, isPlaybackSelfChuPai)
    if self:IsSelf() then
        if isPlaybackSelfChuPai then
            local eqsCard = SelfHandEqsCardsCtrl.GetEqsCardById(tonumber(cardid))
            if eqsCard == nil then --上一步时为空
                eqsCard = EqsCardsManager.GetCardByUid(cardid)
                if eqsCard ~= nil then
                    eqsCard.transform.position = self.transform.position
                else
                    LogError("PlaybackSelfChuPai：", cardid, self.uid, isPlaybackSelfChuPai)
                    return 
                end
            end
            EqsBattleCtrl.SetChuPaiInfo(eqsCard, self.uid, false, true)
            SelfHandEqsCardsCtrl.AddChuPaiToChuPaiRect(eqsCard)
            if not self.isXiaoJia then
                SelfHandEqsCardsCtrl.DealLinesMove()
            end
        end
    else
        Log("PlaybackSelfChuPai：", cardid, self.uid)
    end
end

function EqsUserInfoCtrl:XiaoJiaMoPai(cardId)
    EqsBattleCtrl.ClearChuPaiInfo()
    local card = EqsCardsManager.GetCardByUid(cardId)
    if card ~= nil then
        if self:IsSelf() then
            SelfHandEqsCardsCtrl.AddCard(card)
        else
            if self.xiaoJiaMoPaiTran then
                self.xiaoJiaMoPaiTran.gameObject:SetActive(true)
            end
        end
    else
        Log("小家四人模式摸牌没有牌:rightcard=", cardId)
    end
end

--播放特效 type:EffectType对象
EqsUserInfoCtrl.effectPos = nil
function EqsUserInfoCtrl:PlayEffect(type)
    if self.effectPos ~= nil then
        EffectMgr.PlayEffect(type, self.effectPos)
    end
end

function EqsUserInfoCtrl:ClearAllLeftCardCtrls()
    Log("回收所有左手牌：", self.uid, GetTableSize(self.leftCardLineCtrls))
    self.pengPaiIdx = 0
    --回收所有碰牌
    for _, lineCtrl in pairs(self.leftCardLineCtrls) do
        lineCtrl:Reset()
    end
end

function EqsUserInfoCtrl:ClearAllChuPai()
    for _, cell in pairs(self.chuPaiCells) do
        EqsTools.RecycleSmallCardCell(cell)
    end
end

function EqsUserInfoCtrl:ClearHandCards()
    if self:IsSelf() then
        SelfHandEqsCardsCtrl.RecycleAllCards()
    end
end

--重置下一盘数据
function EqsUserInfoCtrl:Reset()
    --初始化索引
    self:ClearAllLeftCardCtrls()
    self:ClearAllChuPai()
    --回收所有手牌
    self:ClearHandCards()
    self:SetIsXiaoJia(false)

    self:ClearChuPaiPos()

    self:SetZhuangTagVisible(false)
    self:SetAutoPlayTagVisible(false)
    self:SetLeftCardCount(0)

    UIUtil.SetActive(EqsBattlePanel.GetClock(), false)
    self:UnscdeduleClock()
    self:UnscheduleFingerTips()
end


function EqsUserInfoCtrl:ScheduleClock()
    self:UnscdeduleClock()
    local clockTran = EqsBattlePanel.GetClock()
   -- Log("调度闹钟：", self.uid, BattleModule.isPlayback, clockTran)
    if BattleModule.isPlayback then
        return
    end
    if clockTran == nil then
        return
    end
    clockTran.gameObject:SetActive(true)

    if self.clockPos ~= nil then
        UIUtil.SetActive(self.clockPos, true)
        clockTran:SetParent(self.clockPos)
        clockTran.localPosition = Vector3.zero
    end
    local time = 15
    local timeText = clockTran:Find("Text"):GetComponent("Text")
    timeText.text = tostring(time)
    EqsBattleCtrl.CancelAllScheduleClocks()                                                                                                                                           
    self.clockTipSchedule = Scheduler.scheduleGlobal(
        function()
            if not IsNull(clockTran) then
                time = time - 1
                clockTran.gameObject:SetActive(true)
                if time <= 0 then
                    timeText.text = tostring(time)
                    self:UnscdeduleClock()
                    self.clockTipSchedule = nil
                else
                    timeText.text = tostring(time)
                end
            end
        end,
        1
    )
end

function EqsUserInfoCtrl:ScheduleFinger()
    if BattleModule.isPlayback then
        return
    end
    if self:IsSelf() then
        self:UnscheduleFingerTips()
        Log("调度手指：", self.uid)
        self.fingerTipSchedule = Scheduler.scheduleOnceGlobal(
        function()
            self.chuPaiTips.gameObject:SetActive(true)
            local finger = self.chuPaiTips:Find('Finger')
            UIUtil.DOFade(self.chuPaiTips, 1, 0.2)
            finger.localRotation = UnityEngine.Quaternion.Euler(0, 0, -40)
            finger.transform:DOLocalRotate(Vector3(0, 0, -80), 0.7, DG.Tweening.RotateMode.Fast)
            self.fingerSchedule2 = Scheduler.scheduleGlobal(function()
                if IsNull(finger) then
                    Scheduler.unscheduleGlobal(self.fingerSchedule2)
                    return 
                end
                finger.localRotation = UnityEngine.Quaternion.Euler(0, 0, -40)
                finger.transform:DOLocalRotate(Vector3(0, 0, -80), 0.7, DG.Tweening.RotateMode.Fast)
                self.fingerSchedule1 = Scheduler.scheduleOnceGlobal(function()
                    if IsNull(finger) then
                        Scheduler.unscheduleGlobal(self.fingerSchedule1)
                        return 
                    end
                    finger.transform:DOLocalRotate(Vector3(0, 0, -40), 0.1, DG.Tweening.RotateMode.Fast)
                end, 1.8)
            end, 2)
        end,
        4
        )
    end
end

function EqsUserInfoCtrl:UnscdeduleClock()
   -- Log("关闭闹钟调度", self.uid)
    Scheduler.unscheduleGlobal(self.clockTipSchedule)
end

function EqsUserInfoCtrl:UnscheduleFingerTips()
   -- Log("关闭手指调度", self.uid)
    Scheduler.unscheduleGlobal(self.fingerTipSchedule)
    Scheduler.unscheduleGlobal(self.fingerSchedule1)
    Scheduler.unscheduleGlobal(self.fingerSchedule2)
    if self.chuPaiTips ~= nil then
        self.chuPaiTips.gameObject:SetActive(false)
    end
end

--文本
EqsUserInfoCtrl.chatText = nil
EqsUserInfoCtrl.chatTranform = nil
EqsUserInfoCtrl.chatKuang = nil
function EqsUserInfoCtrl:SayText(str,duration)
    if self.chatKuang == nil then
        self.chatKuang = self:Find("ChatKuang")
    end
    if self.chatTranform == nil then
        self.chatTranform = self.chatKuang:Find("TextChat")
    end
    if self.chatText == nil then
        self.chatText =  self.chatTranform:Find("Text"):GetComponent("Text")
    end

    UIUtil.SetActive(self.chatKuang, true)

    Functions.SetChatText(self.chatTranform, self.chatText,str)
    Scheduler.scheduleOnceGlobal(function ()
        UIUtil.SetActive(self.chatTranform,false)
    end,duration)
end

--表情
EqsUserInfoCtrl.emotionParent = nil
function EqsUserInfoCtrl:GetSayEmotionRoot()
    if self.emotionParent == nil then
        self.emotionParent = self:Find("ChatKuang/EmotionChat")
    end
    return self.emotionParent
end

--播放聊天气泡
function EqsUserInfoCtrl:PlayVoiceBubble()
    -- voiceqipao
    if self.voiceBubble == nil then
        self.voiceBubble = self.transform:Find("voiceqipao")
    end
    UIUtil.SetActive(self.voiceBubble, true)
end

--停止播放聊天气泡
function EqsUserInfoCtrl:StopVoiceBubble()
    if self.voiceBubble == nil then
        self.voiceBubble = self.transform:Find("voiceqipao")
    end
    UIUtil.SetActive(self.voiceBubble, false)
end

local moveTime = 0.8
local animTime = 2
function EqsUserInfoCtrl:moveAnim(toCtrl, movingObj, animObj)
    local fromCtrl = self
    UIUtil.SetActive(movingObj, true)
    UIUtil.SetActive(animObj, false)
    local toPos = toCtrl.headIconImg.transform.position
    movingObj.transform.position = fromCtrl.headIconImg.transform.position
    animObj.transform.position = toPos
    movingObj.transform:DOMove(toPos, moveTime, true):OnComplete(function ()
        UIUtil.SeetActive(movingObj, false)
        UIUtil.StActive(animObj, true)
        animObj.transform.localScale = Vector3.one
        local uiSpriteAnimation = animObj.transform:Find("Item"):GetComponent("UISpriteAnimation")
        if uiSpriteAnimation ~= nil then
            uiSpriteAnimation:Play()
        else
            Log("不存在帧动画组件", animObj)
        end
        Scheduler.scheduleOnceGlobal(function() 
            UIUtil.SetActive(movingObj, false)
            UIUtil.SetActive(animObj, false)
            DestroyObj(movingObj)
            DestroyObj(animObj)
        end,animTime)
    end)
end

--自己接收动画表情的玩家
function EqsUserInfoCtrl:ChatAnim(data)
    if GetTableSize(BattleModule.userInfoCtrls) > 1 then
        local gamePanel = EqsBattlePanel.GetTransform()
        local itemData = EqsBroadcast.ChatAnim[data.key]
        local chatAnims = ResourcesManager.LoadPrefabBySynch(EqsBroadcast.chatAnimBundleName,EqsBroadcast.chatAnimAssetName)
        if itemData ~= nil and chatAnims ~= nil then
            local itemMove  = chatAnims.transform:Find(itemData.moveItem)
            local itemAnim  = chatAnims.transform:Find(itemData.animItem)
            local movingObj = nil
            local animObj   = nil
            local toPos = nil
            if itemMove ~= nil and itemAnim ~= nil then
                if  IsTable(data.to) then
                    for _, uid in pairs(data.to) do
                        movingObj = NewObject(itemMove.gameObject, gamePanel)
                        animObj = NewObject(itemAnim.gameObject, gamePanel)
                        local toUser = BattleModule.GetUserInfoByUid(uid)
                        if toUser ~= nil then
                            self:moveAnim(toUser, movingObj,animObj)
                        else
                            Log("toUser不存在")
                        end
                    end
                else
                    Log("fromUser不存在，或者to格式不对")
                end
                EqsSoundManager.PlayAudioByFull(itemData.audioBundle, itemData.audioName)
            else
                Log("不存在执行动画表情的资源", data, self.uid)    
            end
        else
            Log("不存在EqsUserInfoCtrl:ChatAnim", itemData, selfUserCtrl, chatAnims, data, self.uid)
        end
    else
        Log("只有一个玩家，不执行动画聊天", data, self.uid)
    end
end

--num:8,12,16,20
function EqsUserInfoCtrl:ShowBuDa(num)
    if num == nil then
        return 
    end
    local tran = EqsBattlePanel.GetBuDas()
    local count = tran.childCount
    if count > 0 then
        for i = 0, count - 1 do
            tran:GetChild(i).gameObject:SetActive(false)
        end
    end
    local prefix = ""
    if BattleModule.userNum == 3 then
        if self.uiIdx == 1 then
            prefix = "h"
        else
            prefix = "s"
        end
    else
        if self.uiIdx == 1 or self.uiIdx == 3 then
            prefix = "h"
        else
            prefix = "s"
        end
    end
    local tag = tran:Find("BuDa" .. tostring(num) .. prefix)
    if tag ~= nil then
        tag.gameObject:SetActive(true)
        local oldParent = tran.parent
        tran:SetParent(self.effectPos)
        tran.anchoredPosition = Vector3.zero
        tag.localScale = Vector3(4, 4, 4)
        tag:DOScale(Vector3(1, 1, 1), 0.2)
        Scheduler.scheduleOnceGlobal(function()
            tran:SetParent(oldParent)
            tag.gameObject:SetActive(false)
        end, 1)
    end
    Log("显示不打", self.uid, self.uiIdx, tag, tran, self.effectPos)
    EqsSoundManager.PlayBaKuai(num,self.sex)
end


function EqsUserInfoCtrl:SetAllSmallCardsEffect(cardid, effectType)
    for _, cell in pairs(self.chuPaiCells) do
        EqsTools.SetCellCardEffect(cell, effectType, cardid)
    end

    for _, lineCtrl in pairs(self.leftCardLineCtrls) do
        lineCtrl:SetEffect(effectType, cardid)
    end
end
