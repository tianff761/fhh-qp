EqsBattleCtrl = ClassLuaComponent("EqsBattleCtrl")
EqsBattleCtrl.curChuPaiUid = nil --当前出牌用户的uid
EqsBattleCtrl.curChuPaiCard = nil --当前出牌用户出的牌对象
local this = EqsBattleCtrl
--自己换三张的牌
EqsBattleCtrl.hszCardsQueue = nil
--是否可以点击语音按钮
EqsBattleCtrl.isCanClick = true
--语音Y轴偏移量
EqsBattleCtrl.speechTouchY = 0

function EqsBattleCtrl:Awake()
    this = self
    BattleModule.isReinitBattle = true
end

--取消所有出牌提示
function EqsBattleCtrl.CancelAllScheduleClocks()
    if IsTable(BattleModule.userInfoCtrls) then
        for _, userInfoCtrl in pairs(BattleModule.userInfoCtrls) do
            userInfoCtrl:UnscdeduleClock()
        end
    end
end

--添加换三张的牌
function EqsBattleCtrl.AddHszCards(eqsCard)
    if this.hszCardsQueue == nil then
        this.hszCardsQueue = Queue.New()
    end
    local count = this.hszCardsQueue:Count()
    Log("添加换三张牌：", eqsCard:GetUid(), count)
    if count >= 3 then
        for i = 3, count do
            local card = this.hszCardsQueue:Dequeue()
            if card ~= nil and not IsNull(card.transform) then
                card:SetHuanVisible(false)
            end
        end
    end
    eqsCard:SetHuanVisible(true)
    this.hszCardsQueue:Enqueue(eqsCard)
    if this.hszCardsQueue:Count() >= 3 then
        EqsBattlePanel.SetChangeBtnAnim(true)
    end
end

function EqsBattleCtrl.RemoveHszCards(eqsCard)
    eqsCard:SetHuanVisible(false)
    local items = this.hszCardsQueue:Items()
    for k, card in pairs(items) do
        if card == eqsCard then
            table.remove(items, k)
            break
        end
    end
    if this.hszCardsQueue:Count() < 3 then
        EqsBattlePanel.SetChangeBtnAnim(false)
    end
end

function EqsBattleCtrl.GetHszQueue()
    return this.hszCardsQueue
end

--执行换三张操作
function EqsBattleCtrl.PerformHsz(selectedCards)
    if #selectedCards ~= 3 then
        LogError("换三张牌错误111：", selectedCards)
        return
    end
    local newEqsCards = {}
    table.insert(newEqsCards, EqsCardsManager.GetCardByUid(selectedCards[1]))
    table.insert(newEqsCards, EqsCardsManager.GetCardByUid(selectedCards[2]))
    table.insert(newEqsCards, EqsCardsManager.GetCardByUid(selectedCards[3]))

    if #newEqsCards ~= 3 then
        LogError("换三张牌错误222：", selectedCards)
        return
    end
    for i = 1, 10 do
        local oldCard = this.hszCardsQueue:Dequeue()
        if oldCard ~= nil then
            local loc = oldCard:GetLocation()
            local pos = oldCard.transform.localPosition
            local scale = oldCard.transform.localScale
            EqsCardsManager.RecycleCard(oldCard, false)
            local newCard = newEqsCards[i]
            SelfHandEqsCardsCtrl.AddCardToCell(newCard, loc.x, loc.y, false, true)
            newCard.transform.localPosition = pos
            newCard.transform.localScale = scale
        else
            break
        end
    end
    for _, card in pairs(newEqsCards) do
        this.hszCardsQueue:Enqueue(card)
    end

    SelfHandEqsCardsCtrl.SetDraggable(false, 3)

    --所有动画回退到初始状态
    DOTween.RewindAll(true)
    for _, userInfo in pairs(BattleModule.userInfoCtrls) do
        userInfo:SetChangedTagVisible(false)
        userInfo:PlayHszAnim(this.transform)
    end
    return
end

function EqsBattleCtrl.Init()
    EqsCardsManager.Init(this.transform)
    if BattleModule.isPlayback then
        this.InitPlayback()
    else
        BattleModule.SendJoinedRoom()
    end
end

--同步自己的手牌位置给所有牌
function EqsBattleCtrl.SyscCardPositions()
    if PanelManager.IsOpened(EqsPanels.DanJuJieSuan) then
        Log("单局结算已打开，不同步牌位置")
        return
    end
    local pos = SelfHandEqsCardsCtrl.GetAllCardPositions()
    local obj = {
        type = EqsBroadcast.BroadcastType.CardPositions,
        from = BattleModule.uid,
        pos = pos
    }
    BattleModule.SendBroadcast(obj)
end

--初始化房间信息
function EqsBattleCtrl.InitRoomInfo(data)
    local userCtrls = this.InitEqsUserInfoCtrls(data.users)
    -- LogError("userCtrls", userCtrls)
    EqsBattlePanel.SetRuleText(BattleModule.rules)
    EqsBattlePanel.SetTopDisplay(true)
    if BattleModule.IsFkFlowRoom() then
        --LogError("<color=aqua>1111111111111</color>")
        EqsBattlePanel.SetFkRoomTopInfo(data.juShu, data.circle, BattleModule.rules[EqsRuleType.QuanShu], BattleModule.roomId)
    else
        --LogError("<color=aqua>2222222222222</color>")
        EqsBattlePanel.SetGoldRoomTopInfo(BattleModule.GetRule(EqsRuleType.TeaBaseScore), BattleModule.roomId, BattleModule.curCircle, UserData.IsReconnect())
        EqsBattlePanel.ShowGoldRoomNum()
    end

    --更新聊天玩家数据
    BattleModule.UpdateChatPlayers(userCtrls)
    -- LogError("UpdateChatPlayers userCtrls", userCtrls)
    --设置听牌提示
    EqsBattlePanel.SetTingPaiTiShi()
    return userCtrls
end

--初始化游戏玩家数据   users:user对象的数组，包含字段：userId,userName,icon,sex,seatId,score,isOwner,ip,status,online
function EqsBattleCtrl.InitEqsUserInfoCtrls(users)
    local userInfos = {}
    local playerContainer = EqsBattlePanel.InitUserParent(BattleModule.userNum)
    for i = 1, BattleModule.userNum do
        local tran = playerContainer.transform:Find("UserInfo" .. tostring(i))
        if tran then
            --断线重连也走此流程，所有要先获取
            local ctrl = GetLuaComponent(tran.gameObject, "EqsUserInfoCtrl")
            if ctrl == nil then
                ctrl = AddLuaComponent(tran.gameObject, "EqsUserInfoCtrl")
            end
            userInfos[i] = ctrl
            userInfos[i]:Init(i)
        end
    end

    for _, user in pairs(users) do
        if user.uid == BattleModule.uid then
            selfUser = user
            break
        end
    end
    --设置每个玩家的服务器逻辑座位
    if selfUser ~= nil then
        local idx = 1
        for i = selfUser.seatId, BattleModule.userNum do
            userInfos[idx].seatId = i
            idx = idx + 1
        end

        for i = 1, selfUser.seatId - 1 do
            userInfos[idx].seatId = i
            idx = idx + 1
        end
    else
        Log("没有查找到自己的玩家数据", BattleModule.uid)
        return nil
    end

    --为每个玩家设置自己的座位数据
    for _, user in pairs(users) do
        for _, userCtrl in pairs(userInfos) do
            if userCtrl.seatId == user.seatId then
                userCtrl:SetBasicInfo(user)
            end
        end
    end
    return userInfos
end

--发牌
function EqsBattleCtrl.FaPai(data)
    EqsBattlePanel.SetHuPaiTipsBtnVisible(false)
    if not BattleModule.IsFkFlowRoom() then
        local selfUser = nil
        for _, userCtrl in pairs(BattleModule.userInfoCtrls) do
            UIUtil.SetActive(userCtrl.gameObject, true)
            if userCtrl:IsSelf() then
                selfUser = userCtrl
            end
        end
        if not UserData.IsReconnect() then
            EqsBattlePanel.ShowGoldRoomNum()
            SelfHandEqsCardsCtrl.SetDraggable(false, 3)
            if selfUser:GetStatus() ~= EqsUserStatus.Preparing then
                Scheduler.scheduleOnceGlobal(function()
                    PanelManager.Open(EqsPanels.EqsSuiJiQuan, BattleModule.curCircle, EqsBattlePanel.GetSuiJiQuanCard())
                end, 1)
            end
        end
        PanelManager.Close(PanelConfig.GoldMatch)
    end
    this.ClearChuPaiInfo()
    this.ClearHsz()
    SelfHandEqsCardsCtrl.RecycleAllCards()
    EqsBattlePanel.SetLeftCard(data.leftCount)
    for _, userCard in pairs(data.userCard) do
        local userInfoCtrl = BattleModule.GetUserInfoByUid(userCard.uid)
        if userInfoCtrl ~= nil then
            userInfoCtrl:SetZhuangTagVisible(userCard.uid == data.zhuangId)
            userInfoCtrl:SetLoadingTagVisible(false)
            --解析手牌
            userInfoCtrl:SetLeftCardCount(userCard.handCards)
            if userInfoCtrl:IsSelf() then
                --表示自己
                local cards = {}
                for _, cardId in pairs(userCard.handCards) do
                    table.insert(cards, EqsCardsManager.GetCardByUid(cardId))
                end
                SelfHandEqsCardsCtrl.SetTempIds(userCard.handCards)
                TryCatchCall(function()
                    SelfHandEqsCardsCtrl.AddCards(cards)
                end)
                BattleModule.tingPaiIds = userCard.tips
            end

            --解析左手牌
            TryCatchCall(function()
                userInfoCtrl:ParseLeftCard(userCard.leftCards)
            end)
            --解析出牌
            TryCatchCall(function()
                userInfoCtrl:ParseChuPai(userCard.chuPai)
            end)
            --解析操作项
            TryCatchCall(function()
                userInfoCtrl:SetStatus(userCard.status, userCard.opers)
            end)

            TryCatchCall(function()
                --解析右手牌 只做断线重连操作，isHu:true 胡牌状态时，表示玩家胡的牌，不是玩家出的牌 (注：自己翻牌自己胡时，false)
                --Log("userCard:", userCard)
                if IsBool(userCard.isHu) and userCard.isHu ~= true then
                    userInfoCtrl:ParseRightCard(userCard.rightCard)
                end
                --解析换三张已选牌userCard.selectCard 数组，三张牌, 在已选牌完成解析
                if userInfoCtrl.status == EqsUserStatus.Changed and userInfoCtrl:IsSelf() then
                    this.hszCardsQueue = Queue.New()
                    local card = SelfHandEqsCardsCtrl.GetEqsCardByUId(userCard.selectCard[1])
                    if card ~= nil then
                        this.AddHszCards(card)
                    end

                    card = SelfHandEqsCardsCtrl.GetEqsCardByUId(userCard.selectCard[2])
                    if card ~= nil then
                        this.AddHszCards(card)
                    end

                    card = SelfHandEqsCardsCtrl.GetEqsCardByUId(userCard.selectCard[3])
                    if card ~= nil then
                        this.AddHszCards(card)
                    end

                    if this.hszCardsQueue:Count() ~= 3 then
                        LogError("解析换三张错误：", userCard.selectCard, data, this.hszCardsQueue:Count())
                    end
                end

                if userInfoCtrl:IsSelf() then
                    --LogError("设置换三张按钮。。。。。",userInfoCtrl.uid, userInfoCtrl.status, UserData.IsReconnect())
                    --换牌状态，断线重连时，延时显示换按钮
                    if userInfoCtrl.status == EqsUserStatus.Changing then
                        if not UserData.IsReconnect() then
                            Scheduler.scheduleOnceGlobal(function()
                                EqsBattlePanel.SetChangeBtnVisible(true)
                                EqsBattlePanel.SetChangeBtnAnim(false)
                            end, 1)
                        else
                            EqsBattlePanel.SetChangeBtnVisible(true)
                            EqsBattlePanel.SetChangeBtnAnim(false)
                        end
                    else
                        EqsBattlePanel.SetChangeBtnVisible(false)
                        EqsBattlePanel.SetChangeBtnAnim(false)
                    end
                end
            end)
            userInfoCtrl:ShowBuDa(userCard.buDa)
        end
    end
    if BattleModule.IsFkFlowRoom() then
        SelfHandEqsCardsCtrl.SetQuanTag()
    else
        if UserData.IsReconnect() then
            SelfHandEqsCardsCtrl.SetQuanTag()
        end
    end
    UserData.SetIsReconnectTag(false)

    TryCatchCall(this.CancelRecommendChuPaiTip)
    TryCatchCall(this.SetRecommendChuPaiTip)
end

--数据：{"code":0,"data":{"id2":522,"targetId":521,"id3":0,"from":2,"id1":523,"oper":45}}
--执行结果，只返回给自己。当自己执行：换三张、胡、开、对、吃、过时，返回给自己
function EqsBattleCtrl.OnPerformOperationResult(data)
    Scheduler.unscheduleGlobal(this.schedule772)
    BattleModule.SetIsPerform772(true)
    this.schedule772 = Scheduler.scheduleOnceGlobal(function()
        BattleModule.SetIsPerform772(false)
    end, 2)
    local userCtrl = BattleModule.GetUserInfoByUid(BattleModule.uid)
    if userCtrl ~= nil then
        userCtrl:UnscheduleFingerTips()
        if userCtrl:IsSelf() then
            EqsBattlePanel.HideAllOperationBtns()
            EqsBattlePanel.SetChangeBtnVisible(false)
        end
    end

    this.CancelRecommendChuPaiTip()

    if data.data.code == EqsStatusCode.SUCCESS then
        --操作执行成功
        Log("----------------->操作成功：", data, this.curChuPaiCard)
        --如果当前出牌为空时，添加一张牌到出牌区域
        if this.curChuPaiCard == nil then
            if data.data.oper.oper == EqsOperation.ChuPai then
                if this.curChuPaiUid ~= BattleModule.uid then
                    this.ClearChuPaiInfo()
                end
                local eqsCard = EqsCardsManager.GetCardByUid(EqsTools.GetTargetId(data.data.oper))
                this.SetChuPaiInfo(eqsCard, BattleModule.uid, false, true)
                SelfHandEqsCardsCtrl.AddChuPaiToChuPaiRect(eqsCard)
                eqsCard.transform.localPosition = Vector3.zero

            end
        end

        if BattleModule.tingPaiIds ~= nil and BattleModule.IsRecommendCardid(EqsTools.GetEqsCardId(EqsTools.GetTargetId(data.data.oper))) then
            EqsBattlePanel.SetHuPaiTipsBtnVisible(true)
        end
    else
        if data.data.code == EqsStatusCode.SHANG_TU_XIA_XIE then
            if this.curChuPaiCard ~= nil then
                Toast.Show("上吐下泻，出牌失败")
                --执行失败，如果自己出牌，则要回收牌
                if data.data.oper.oper == EqsOperation.ChuPai then
                    SelfHandEqsCardsCtrl.SetDraggable(false, 0.5)
                    local card = this.curChuPaiCard
                    Scheduler.scheduleOnceGlobal(function()
                        SelfHandEqsCardsCtrl.AddCard(card)
                    end, 0.31)
                    Scheduler.scheduleOnceGlobal(function()
                        SelfHandEqsCardsCtrl.DealAllLineCards()
                    end, 0.4)
                    this.curChuPaiCard = nil
                    this.curChuPaiUid = ""
                end
            end
            if userCtrl:IsSelf() then
                userCtrl:ScheduleClock()
                userCtrl:ScheduleFinger()
            end
        elseif data.data.code == EqsStatusCode.WAITING_OTHERS_OPER then
            --等待其他玩家操作
        else
            Network.Disconnect()
        end
    end
    --关闭自己点击吃或者摆返回后的面板
    PanelManager.Close(EqsPanels.ChiPanel)
    PanelManager.Close(EqsPanels.BaiPanel)
end

--数据格式中的data对象：{"code":0,"data":{"oper":{"id2":522,"targetId":521,"id3":0,"from":2,"id1":523,"oper":45},"users":[{"handCards":[111,112,311,222,213,420,621,721,722,713,821,911,1021,1022,521,522,523,1011,1012,1013,1023],"uid":100004,"rightCard":1021,"leftCards":[{"id2":522,"targetId":521,"id3":0,"from":2,"id1":511,"oper":46},{"id2":623,"targetId":621,"id3":624,"from":2,"id1":622,"oper":43},{"id2":723,"targetId":721,"id3":0,"from":2,"id1":722,"oper":45}],"handCount":18}],"operUid":100004}}
--执行操作：换三张、胡、开、对、吃、过，成功时，返回给房间所有玩家
function EqsBattleCtrl.OnPerformOperation(data)
    --处理执行操作
    SelfHandEqsCardsCtrl.SetDraggable(false, 0.1)
    local userCtrl = BattleModule.GetUserInfoByUid(data.operUid)
    if userCtrl ~= nil and data.oper ~= nil then
        userCtrl:PerformOperation(data.oper)
        if userCtrl:IsSelf() then
            PanelManager.Close(EqsPanels.ChiPanel)
            if data.oper.oper == EqsOperation.Dui or data.oper.oper == EqsOperation.Chi or
                    data.oper.oper == EqsOperation.Hu or data.oper.oper == EqsOperation.Kai then
                EqsBattlePanel.SetHuPaiTipsBtnVisible(false)
            end
        else
            if data.oper.oper ~= EqsOperation.Guo then
                PanelManager.Close(EqsPanels.ChiPanel)
            end
        end
    end
    --自己有点开吃面板，如果别人有队，点击了，操作级高于吃，此时小时吃面板
    --设置剩余牌
    EqsBattlePanel.SetLeftCard(data.leftCount)
    if data.leftCount == 2 then
        this.SyscCardPositions()
    end

    local userCtrl = nil
    if GetTableSize(data.userCard) > 0 then
        --处理执行换三张逻辑
        local playHsz = this.CheckHsz(data.userCard)
        if playHsz then
            for _, user in pairs(data.userCard) do
                userCtrl = BattleModule.GetUserInfoByUid(user.uid)
                if userCtrl ~= nil and userCtrl:IsSelf() then
                    this.PerformHsz(user.selectCard)--新换的换三张牌
                end
            end
        end

        --如果执行换三张逻辑，则延时解析玩家数据
        local delayTime = 0
        if playHsz then
            delayTime = 3.5
        end

        Scheduler.unscheduleGlobal(this.parseDataSchedule)
        this.parseDataSchedule = Scheduler.scheduleOnceGlobal(function()
            --解析玩家牌和操作状态相关
            for _, user in pairs(data.userCard) do
                userCtrl = BattleModule.GetUserInfoByUid(user.uid)
                if userCtrl ~= nil then
                    userCtrl:SetLeftCardCount(user.handCards)

                    --解析右手牌
                    TryCatchCall(function()
                        userCtrl:ParseLeftCard(user.leftCards)
                    end)

                    --解析所有出过得牌
                    TryCatchCall(function()
                        userCtrl:ParseChuPai(user.chuPai)
                    end)

                    --解析玩家操作状态
                    TryCatchCall(function()
                        userCtrl:SetStatus(user.status, user.opers)
                    end)

                    if userCtrl:IsSelf() then
                        BattleModule.tingPaiIds = user.tips
                    end

                    --同步手牌(如果玩家的操作导致牌减少如：对、碰、开、出牌、摆等，此处同步)
                    TryCatchCall(function()
                        if userCtrl:IsSelf() then
                            if playHsz then
                                --执行了换三张后，重新排列牌
                                local cards = {}
                                for _, cardId in pairs(user.handCards) do
                                    table.insert(cards, EqsCardsManager.GetCardByUid(cardId))
                                end
                                SelfHandEqsCardsCtrl.SetTempIds(user.handCards)
                                SelfHandEqsCardsCtrl.AddCards(cards, true)
                                SelfHandEqsCardsCtrl.SetQuanTag()
                            else
                                --重新同步牌
                                SelfHandEqsCardsCtrl.SetTempIds(user.handCards)
                                SelfHandEqsCardsCtrl.CheckAndSyncCards(user.handCards)
                            end
                        end
                    end)

                    userCtrl:ShowBuDa(user.buDa)
                end
            end
            EqsBattleCtrl.SetYuCards()
        end, delayTime)
    end
    TryCatchCall(this.SetRecommendChuPaiTip)
end

function EqsBattleCtrl.OnBroadcast(data)
    local userCtrl = BattleModule.GetUserInfoByUid(data.from)
    if userCtrl ~= nil then
        if data.type == EqsBroadcast.BroadcastType.TextChat then
            -- userCtrl:SayText(data.key, EqsBroadcast.BroadcastType.TextChat)
        elseif data.type == EqsBroadcast.BroadcastType.EmotionChat then
            -- userCtrl:SayEmotion(data.key)
        elseif data.type == EqsBroadcast.BroadcastType.Speak then
            -- data.shareFileID, oId,data.time
            -- userCtrl:Speak(data.fileName, data.from, data.speekTime)
        elseif data.type == EqsBroadcast.BroadcastType.ChatAnim then
            -- userCtrl:ChatAnim(data)
        elseif data.type == EqsBroadcast.BroadcastType.Gps then
            userCtrl:SetLocation(data.wd, data.jd)
            --如果GPS面板打开，则更新界面
            if PanelManager.IsOpened(PanelConfig.RoomGps) then
                SendEvent(CMD.Game.RoomGpsPlayerUpdate, BattleModule.GetGpsUserData())
            end
        elseif data.type == EqsBroadcast.BroadcastType.InuptChat then
            -- userCtrl:SayText(data.text, EqsBroadcast.BroadcastType.InuptChat)
        elseif data.type == EqsBroadcast.BroadcastType.CardPositions then
            BattleModule.StoreDanJuJieSuanCardPosition(data.pos, data.from)
        end
    else
        LogWarn("EqsBattleCtrl.OnBroadcast,userCtrl不存在", data)
    end
end

function EqsBattleCtrl.OnServerNotice(data)
    Log("服务器通知", data)
    --type：1 离线在线通知    2 同步牌位置
    if data.type == 1 then
        --服务器通知协议 data:{"type":1, "arg":{"uid":100002, "isOnline":true}}
        if IsTable(data.arg) then
            local userCtrl = BattleModule.GetUserInfoByUid(data.arg.uid)
            if userCtrl ~= nil then
                userCtrl:SetOfflineTagVisible(not data.arg.isOnline)
            end
        end
    elseif data.type == 2 then
        this.SyscCardPositions()
    end
end

--初始化下一局 房卡场
function EqsBattleCtrl.OnInitNext(data)
    Log("EqsBattleCtrl.OnInitNext")
    SelfHandEqsCardsCtrl.SetIsSyscByTempIds(false)
    BattleModule.curCircle = data.circle
    if BattleModule.IsFkFlowRoom() then
        EqsBattlePanel.SetFkRoomTopInfo(data.juShu, data.circle, BattleModule.rules[EqsRuleType.QuanShu], BattleModule.roomId)
    end
    if IsTable(data.users) then
        for _, user in pairs(data.users) do
            local userCtrl = BattleModule.GetUserInfoByUid(user.uId)
            if userCtrl ~= nil then
                userCtrl:SetStatus(user.status)
                userCtrl:SetZhuangTagVisible(user.uId == data.zhuangId)
            end
        end
    end
end

--分数场初始化下一局
function EqsBattleCtrl.OnInitNextInCoinRoom()
    this.Reset()
    for _, userCtrl in pairs(BattleModule.userInfoCtrls) do
        if not userCtrl:IsSelf() then
            UIUtil.SetActive(userCtrl.gameObject, false)
        end
    end
    EqsBattlePanel.SetGoldRoomTopInfo("", "", 1, false)
    EqsBattlePanel.SetLeftCard(0)
    EqsBattlePanel.SetRuleText()
    SelfHandEqsCardsCtrl.Reset()
end

--检测是否可以换三张 所有玩家都是换三张完成状态，则执行换三张动画
function EqsBattleCtrl.CheckHsz(userCard)
    local userCtrl = nil
    if GetTableSize(userCard) > 0 then
        --所有玩家都是换三张完成状态，则执行换三张动画
        local playHsz = true
        for _, user in pairs(userCard) do
            userCtrl = BattleModule.GetUserInfoByUid(user.uid)
            if userCtrl ~= nil then
                if userCtrl.status ~= EqsUserStatus.Changed then
                    playHsz = false
                    break
                end
            else
                playHsz = false
                break
            end
        end
        return playHsz
    end
    return false
end

--设置所有小牌特效   EffectType 枚举
function EqsBattleCtrl.SetAllSmallCardsEffect(cardid, effectType)
    -- Log("设置特效：", cardid, effectType)
    if BattleModule.userInfoCtrls ~= nil then
        for _, userInfo in pairs(BattleModule.userInfoCtrls) do
            userInfo:SetAllSmallCardsEffect(cardid, effectType)
        end
    end
end

--send772:自己出牌时发送772   addChuPai：当前出牌存在时，是否添加到出牌列表
function EqsBattleCtrl.SetChuPaiInfo(card, uid, send772, playSound)
    this.ClearChuPaiInfo()
    this.curChuPaiCard = card
    this.curChuPaiUid = uid

    local userInfo = BattleModule.GetUserInfoByUid(uid)
    if card ~= nil then
        card:SetActive(false)
        card:SetQuanTag()
        EqsSoundManager.PlayChuPaiAudio(card:GetUid(), userInfo.sex)
    end

    if send772 ~= nil and send772 == true then
        local oper = EqsTools.GetOperation(EqsOperation.ChuPai, card:GetUid(), 0, 0, 0, 0)
        BattleModule.SendOperation(oper)
    end
end

--删除出牌信息,addChuPai：当前出牌存在时，是否添加到出牌列表
function EqsBattleCtrl.ClearChuPaiInfo(notAnim)
    if this.curChuPaiCard ~= nil then
        EqsCardsManager.RecycleCard(this.curChuPaiCard, false, notAnim)
    end
    this.curChuPaiCard = nil
    this.curChuPaiUid = ""
    ClearChildren(EqsBattlePanel.GetChuPaiRect():Find('ChuPaiPos'))
end

function EqsBattleCtrl.QuitRoom()
    this.Reset()
    EqsTools.ReturnToLobby()
    Scheduler.unscheduleGlobal(this.autoPlaySchedule)
end

function EqsBattleCtrl.ClearHsz()
    Log("清除换三张")
    for i = 1, 5 do
        if this.hszCardsQueue ~= nil then
            local card = this.hszCardsQueue:Dequeue()
            if card ~= nil then
                EqsCardsManager.RecycleCard(card, false)
            end
        end
    end
    this.hszCardsQueue = nil
end

--重置牌局
function EqsBattleCtrl.Reset()
    this.ClearChuPaiInfo(true)
    if IsTable(BattleModule.userInfoCtrls) then
        for _, userInfo in pairs(BattleModule.userInfoCtrls) do
            userInfo:Reset()
        end
    end
    BattleModule.ClearYuCardUids()
end

function EqsBattleCtrl.SetYuCards()
    for _, userCtrl in pairs(BattleModule.userInfoCtrls) do
        userCtrl:SetYuCards()
    end
end

--设置听牌时出牌提示
function EqsBattleCtrl.SetRecommendChuPaiTip()
    if not BattleModule.isOpenTingPai then
        return
    end
    local selfUser = BattleModule.GetUserInfoByUid(BattleModule.uid)
    local eqsCard = nil
    local tweenAlpha = nil
    local img = nil
    if selfUser ~= nil and selfUser.status == EqsUserStatus.ChuPai then
        for x = 1, 10 do
            for y = 1, 4 do
                eqsCard = SelfHandEqsCardsCtrl.GetEqsCard(x, y)
                if not IsNull(eqsCard) then
                end
                if not IsNull(eqsCard) and BattleModule.IsRecommendCardid(eqsCard.cId) then
                    img = eqsCard.transform:Find("Card"):GetComponent(typeof(Image))
                    img.color = Color(1, 1, 0.5, 1)
                    tweenAlpha = eqsCard.transform:Find("Card"):GetComponent(typeof(TweenAlpha))
                    if not IsNull(tweenAlpha) then
                        tweenAlpha.enabled = true
                    end
                end
            end
        end
    end
end

--取消听牌时出牌提示
function EqsBattleCtrl.CancelRecommendChuPaiTip()
    Log("取消所有推荐出牌提示")
    local selfUser = BattleModule.GetUserInfoByUid(BattleModule.uid)
    local eqsCard = nil
    local tweenAlpha = nil
    local cardImg = nil
    if selfUser ~= nil then
        local color = Color(1, 1, 1)
        for x = 1, 10 do
            for y = 1, 4 do
                eqsCard = SelfHandEqsCardsCtrl.GetEqsCard(x, y)
                if not IsNull(eqsCard) then
                    cardImg = eqsCard.transform:Find("Card")
                    tweenAlpha = cardImg:GetComponent("TweenAlpha")
                    if not IsNull(tweenAlpha) then
                        tweenAlpha.enabled = false
                    end
                    cardImg:GetComponent("Image").color = color
                end
            end
        end
    end
end

--设置听牌内容
function EqsBattleCtrl.SetTingPaiContent(clickCardId)
    Log("设置听牌提示：", clickCardId, BattleModule.isOpenTingPai, BattleModule.tingPaiIds)
    if not BattleModule.isOpenTingPai then
        return
    end
    local canHuGroups = BattleModule.tingPaiIds
    local canHuGroup = nil
    if IsTable(canHuGroups) and IsNumber(clickCardId) then
        for _, canHu in pairs(canHuGroups) do
            if canHu.pushCard == clickCardId then
                canHuGroup = canHu.canHu
                break
            end
        end
        local text = "听牌："
        Log("设置听牌提示：", clickCardId, canHuGroup)
        if IsTable(canHuGroup) then
            --最多胡11张牌
            local item = nil
            local itemData = nil
            local tingPaiTran = EqsBattlePanel.GetTingPaiTran()
            local idTran = nil
            local itemCardImg = nil
            for i = 1, 11 do
                item = tingPaiTran:Find(string.format("HuPaiItem%d", i))
                itemData = canHuGroup[i]
                if not IsNull(item) then
                    if itemData ~= nil then
                        UIUtil.SetActive(item, true)
                        idTran = EqsCardsManager.GetSmallCardByUid(itemData.huValue)
                        itemCardImg = item:Find("CardImg")
                        if itemCardImg.childCount > 0 then
                            EqsCardsManager.RecycleSmallCard(itemCardImg:GetChild(0), false)
                            ClearChildren(itemCardImg)
                        end
                        idTran:SetParent(itemCardImg)
                        idTran.localPosition = Vector3.zero

                        UIUtil.SetText(item:Find("HuShu"), tostring(itemData.huNum))
                        UIUtil.SetText(item:Find("FenShu"), tostring(itemData.score))
                    else
                        UIUtil.SetActive(item, false)
                    end
                end
            end
            this.SetTingPaiVisible(true)
        end
    end
end

--显示隐藏听牌节点
function EqsBattleCtrl.SetTingPaiVisible(visible)
    Log("SetTingPaiVisible", visible)
    Scheduler.unscheduleGlobal(this.tingPaiScheulde)
    UIUtil.SetActive(EqsBattlePanel.GetTingPaiTran(), visible)
end

-----------------------------------------所有点击事件------------------------------------------------
--点击点击邀请
function EqsBattleCtrl.OnClickInviteBtn()
    local text = "贰柒拾，游戏：" .. BattleModule.parsedRules.playWayName
    text = text .. "，圈数：" .. BattleModule.parsedRules.juShuTxt
    text = text .. "，玩法：" .. BattleModule.parsedRules.rule .. "，等你来挑战"
    local data = {
        roomCode = BattleModule.roomId,
        title = "【贰柒拾游戏】房间号：" .. BattleModule.roomId,
        content = text,
        type = 1,
    }
    PanelManager.Open(PanelConfig.RoomInvite, data)
end

--点击复制房间信息并分享
function EqsBattleCtrl.OnClickCopyRoomInfoBtn()
    local text = "【贰柒拾游戏】房间号：" .. BattleModule.roomId
    text = text .. "，贰柒拾，游戏：" .. BattleModule.parsedRules.playWayName
    text = text .. "，圈数：" .. BattleModule.parsedRules.juShuTxt
    text = text .. "，玩法：" .. BattleModule.parsedRules.rule .. "，等你来挑战"
    AppPlatformHelper.CopyText(text)
    PanelManager.Open(PanelConfig.RoomCopy)
end

--点击切换房间
function EqsBattleCtrl.OnClickChangeRoomBtn()
    if BattleModule.IsClubRoom() then
        local args = {
            clubId = BattleModule.clubId,
            roomId = BattleModule.roomId,
            ruleString = BattleModule.lastRulesStr,
            gameType = GameType.ErQiShi,
            returnToLobbyCallback = EqsTools.ReturnToLobby,
            quitRoomCallback = BattleModule.SendQuitRoom
        }
        PanelManager.Open(PanelConfig.RoomChange, args)
    else
        Log("非亲友圈房间，不能打开")
    end
end

--点击换三张
function EqsBattleCtrl.OnClickChangeBtn()
    TryCatchCall(function()
        if this.hszCardsQueue:Count() == 3 then
            local cards = this.hszCardsQueue:Items()
            local oper = EqsTools.GetOperation(EqsOperation.HanSanZhang, cards[1]:GetUid(), -1, cards[2]:GetUid(), cards[3]:GetUid(), 0)
            BattleModule.SendOperation(oper)
        else
            Toast.Show("请选择换三张牌")
        end
    end)
end

--点击设置
function EqsBattleCtrl.OnClickSettingBtn()
    PanelManager.Open(EqsPanels.EqsSetting)
end

--点击规则
function EqsBattleCtrl.OnClickGpsBtn()
    PanelManager.Open(PanelConfig.RoomGps, BattleModule.GetGpsMapData())
end

--点击托管规则
function EqsBattleCtrl.OnClickTuoGuanBtn()
    EqsBattlePanel.SetTuoGuanIsVisable(true)
end
--关闭托管提示
function EqsBattleCtrl.OnCloseTuoGuanTipsBtn()
    EqsBattlePanel.SetTuoGuanIsVisable(false)
end

function EqsBattleCtrl.OnClickHuBtn()
    BattleModule.SendOperationType(EqsOperation.Hu)
    EqsBattlePanel.HideAllOperationBtns()
end

--点击开
function EqsBattleCtrl.OnClickKaiBtn()
    BattleModule.SendOperationType(EqsOperation.Kai)
    EqsBattlePanel.HideAllOperationBtns()
end

--点击对
function EqsBattleCtrl.OnClickDuiBtn()
    BattleModule.SendOperationType(EqsOperation.Dui)
    EqsBattlePanel.HideAllOperationBtns()
end

--点击吃  吃所有按钮关闭，在弹窗界面点击吃
function EqsBattleCtrl.OnClickChiBtn()
    PanelManager.Open(EqsPanels.ChiPanel, BattleModule.operations)
end

--点击过
function EqsBattleCtrl.OnClickGuoBtn()
    BattleModule.SendOperationType(EqsOperation.Guo)
    if EqsBattlePanel.IsHuBtnVisible() then
        EqsBattlePanel.SetHuPaiTipsBtnVisible(false)
    end
    EqsBattlePanel.HideAllOperationBtns()
end

--点击听牌Toggle
function EqsBattleCtrl.OnClickTingPaiToggle(isOn)
    if not isOn then
        Alert.Show("您未开启听牌提示，请在创建房间时，勾选听牌提示选项。当开启听牌提示时，如果出某张牌后有叫时，会推荐出有叫的牌；同时，会提示能胡的牌，胡牌的胡数和分数。")
    end
end

--点击胡牌提示按钮
function EqsBattleCtrl.OnClickHuPaitipsBtn()
    if BattleModule.GetRule(EqsRuleType.TingPaiTiShi) == 1 then
        this.SetTingPaiVisible(true)
        Scheduler.unscheduleGlobal(this.tingPaiScheulde)
        this.tingPaiScheulde = Scheduler.scheduleOnceGlobal(function()
            this.SetTingPaiVisible(false)
        end, 1.5)
    else
        EqsBattlePanel.SetHuPaiTipsBtnVisible(false)
    end
end

--点击回放下一步
local clickTime = 0
function EqsBattleCtrl.OnClickNextStepBtn()
    if not BattleModule.playbackAutoPlay then
        local now = os.timems()
        if clickTime < 100 then
            this.PlayNextStep()
            clickTime = now
        else
            if now - clickTime > 500 then
                this.PlayNextStep()
                clickTime = now
            else
                Log("点击太快", now - clickTime)
            end
        end
    else
        this.OnClickPauseBtn()
        this.PlayNextStep()
    end
end

--点击回放上一步
function EqsBattleCtrl.OnClickLastStepBtn()
    if not BattleModule.playbackAutoPlay then
        local now = os.timems()
        if clickTime < 100 then
            this.PlayLastStep()
            clickTime = now
        else
            if now - clickTime > 500 then
                this.PlayLastStep()
                clickTime = now
            else
                Log("点击太快", now - clickTime)
            end
        end
    else
        this.OnClickPauseBtn()
        this.PlayLastStep()
    end
end

--点击回放暂停
function EqsBattleCtrl.OnClickPauseBtn()
    this.SetAutoPlayback(false)
    Scheduler.unscheduleGlobal(this.autoPlaySchedule)
end

--点击回放播放
function EqsBattleCtrl.OnClickPlayBtn()
    this.SetAutoPlayback(true)
    Scheduler.unscheduleGlobal(this.autoPlaySchedule)
    this.autoPlaySchedule = Scheduler.scheduleGlobal(function()
        if not this.PlayNextStep() then
            Scheduler.unscheduleGlobal(this.autoPlaySchedule)
            this.autoPlaySchedule = nil
            this.SetAutoPlayback(false)
        end
    end, 1)
end

--点击回放退出
function EqsBattleCtrl.OnClickExitBtn()
    Alert.Prompt("是否退出回放？", function()
        this.isClickExit = true
        if this.autoPlaySchedule ~= nil then
            Scheduler.unscheduleGlobal(this.autoPlaySchedule)
            this.autoPlaySchedule = nil
        end
        this.QuitRoom()
    end)
end

--============================================语音======================================
--注册语音事件 
function EqsBattleCtrl.AddVoiceMsg(talkingBtn)
    ChatModule.RegisterVoiceEvent(talkingBtn.gameObject)
end
-----------------------------------------所有点击事件end---------------------------------------------

-----------------------------------------回放逻辑---------------------------------------------
EqsBattleCtrl.curPlaybackStep = 1
EqsBattleCtrl.totalPlaybackStep = 0
EqsBattleCtrl.autoPlaySchedule = nil --自动播放调度
function EqsBattleCtrl.InitPlaybackRoom()
    --取回放第一条数据初始化房间信息
    local roomData = BattleModule.playbackData[1]
    BattleModule.InitRoom(roomData)
    roomData = this.DealPlaybackStepData(roomData)
    this.FaPai(roomData)

    this.OnPerformPlaybackOperation(roomData)

end
function EqsBattleCtrl.InitPlayback()
    this.totalPlaybackStep = GetTableSize(BattleModule.playbackData)
    if this.totalPlaybackStep > 0 then
        Log("初始化回放数据")
        this.InitPlaybackRoom()
    else
        Alert.Prompt("没有回放数据，退出房间？", function()
            this.QuitRoom()
        end)
    end
end

function EqsBattleCtrl.PlayNextStep()
    local isContinue = false
    if this.curPlaybackStep >= this.totalPlaybackStep then
        Toast.Show("牌局已经结束")
        isContinue = false
    else
        this.curPlaybackStep = this.curPlaybackStep + 1
        local stepData = BattleModule.playbackData[this.curPlaybackStep]
        Log("获取执行数据：", stepData)
        stepData = this.DealPlaybackStepData(stepData)
        this.OnPerformPlaybackOperation(stepData)
        isContinue = true
    end
    return isContinue
end

function EqsBattleCtrl.PlayLastStep()
    if this.curPlaybackStep <= 1 then
        Toast.Show("牌局已经到达开始")
    else
        this.ClearChuPaiInfo()
        this.curPlaybackStep = this.curPlaybackStep - 1
        local stepData = BattleModule.playbackData[this.curPlaybackStep]
        Log("获取执行数据：", stepData)
        stepData = this.DealPlaybackStepData(stepData)
        this.OnPerformPlaybackOperation(stepData)
    end
end

function EqsBattleCtrl.DealPlaybackStepData(stepData)
    if stepData['users'] ~= nil then
        stepData['userCard'] = stepData['users']
        stepData['users'] = nil
    end
    return stepData
end

function EqsBattleCtrl.OnPerformPlaybackOperation(data)
    local funParseUsers = function()
        --设置剩余牌
        EqsBattlePanel.SetLeftCard(data.leftCard)

        if GetTableSize(data.userCard) > 0 then
            for _, user in pairs(data.userCard) do
                local userCtrl = BattleModule.GetUserInfoByUid(user.uid)
                if userCtrl ~= nil then
                    userCtrl:SetLeftCardCount(user.handCards)
                    userCtrl:SetScore(tonumber(user.score))
                    --解析右手牌
                    userCtrl:ParseLeftCard(user.leftCards)

                    --解析所有出过得牌
                    userCtrl:ParseChuPai(user.chuPai)

                    userCtrl:SetPlaybackState(user.status, user.opers)
                    if user.auto ~= nil then
                        userCtrl:SetAutoPlayTagVisible(user.auto)
                    else
                        userCtrl:SetAutoPlayTagVisible(false)
                    end

                    --同步手牌(如果玩家的操作导致牌减少如：对、碰、开、出牌、摆等，此处同步)
                    if userCtrl:IsSelf() then
                        local cards = {}
                        for _, cardId in pairs(user.handCards) do
                            table.insert(cards, EqsCardsManager.GetCardByUid(cardId))
                        end
                        SelfHandEqsCardsCtrl.AddCards(cards)
                    else
                        userCtrl.cardsCtrl:AddCards(user.handCards)
                    end
                    userCtrl:ShowBuDa(user.buDa)
                end
            end
            EqsBattleCtrl.SetYuCards()
        end
    end

    local userCtrl = BattleModule.GetUserInfoByUid(data.operUid)
    if userCtrl ~= nil and data.oper ~= nil then
        Log("玩家执行操作：", data.operUid, data.oper)
        --出牌特殊操作
        if data.oper.oper == EqsOperation.ChuPai then
            if userCtrl:IsSelf() then
                userCtrl:PlaybackSelfChuPai(EqsTools.GetTargetId(data.oper), true)
            else
                userCtrl:PlaybackOthersChuPai(EqsTools.GetTargetId(data.oper))
            end
            funParseUsers()
        elseif data.oper.oper == EqsOperation.FanPai then
            userCtrl:PerformOperation(data.oper)
            funParseUsers()
        elseif data.oper.oper == EqsOperation.HanSanZhang then
            funParseUsers()
            Log("执行换三张：", userCtrl.uid)
            if GetTableSize(data.userCard) > 0 then
                for _, user in pairs(data.userCard) do
                    if GetTableSize(user.selectCard) == 3 then
                        local ctrl = BattleModule.GetUserInfoByUid(user.uid)
                        if ctrl.status == EqsUserStatus.Changed then
                            ctrl:PlaybackSelectedHsz(user.selectCard[1], user.selectCard[2], user.selectCard[3])
                        elseif ctrl.status == EqsUserStatus.Waiting then
                            ctrl:PlaybackChangedHsz(user.selectCard[1], user.selectCard[2], user.selectCard[3])
                        end
                    else
                        Log("解析回放换三张错误", user)
                    end
                end
            end
        else
            --循环外执行操作，循环内只执行其他玩家的点击动作
            userCtrl:ClickPlaybackBtn(data.oper.oper, function()
                userCtrl:PerformOperation(data.oper)
                funParseUsers()
            end)
        end
    else
        funParseUsers()
    end

    if GetTableSize(data.userCard) > 0 then
        for _, user in pairs(data.userCard) do
            local userCtrl = BattleModule.GetUserInfoByUid(user.uid)
            if userCtrl ~= nil then
                --循环外执行操作，循环内只执行其他玩家的点击动作
                if userCtrl.uid ~= data.operUid and IsNumber(user.currOper) and (user.currOper == EqsOperation.Hu or
                        user.currOper == EqsOperation.Kai or
                        user.currOper == EqsOperation.Dui or
                        user.currOper == EqsOperation.Chi or
                        user.currOper == EqsOperation.Guo)
                then
                    userCtrl:ClickPlaybackBtn(user.currOper)
                end
            end
        end
    end
end

function EqsBattleCtrl.SetAutoPlayback(autoPlayback)
    BattleModule.playbackAutoPlay = autoPlayback == true
    EqsBattlePanel.SetAutoPlayback()
end
-----------------------------------------回放逻辑end---------------------------------------------

return EqsBattleCtrl