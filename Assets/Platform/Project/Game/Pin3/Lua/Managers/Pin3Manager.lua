Pin3Manager = ClassLuaComponent("Pin3Manager")
--Pin3UserInfoCtrl对象存储
Pin3Manager.userInfoCtrls = nil
--跟注次数
Pin3Manager.genZhuTimes = 0
local this = Pin3Manager

Pin3Manager.SelfBasicInfoScale = 0.8

--静态数据初始化(面板没打开时的一些数据初始化)
function Pin3Manager.Init(args)
    --设置按钮点击声音
    SetBtnClickCallback(Audio.PlayClickAudio)

    --播放背景音乐
    Pin3AudioManager.PlayBGM()

    Pin3Data.Init(args)

    Pin3NetworkManager.Init()

    --房间面板打开
    PanelManager.Open(Pin3Panels.Pin3Battle, args)
end

function Pin3Manager.Uninit()
    Pin3NetworkManager.Uninit()
    Pin3Data.Uninit()
    Pin3Utils.Uninit()
end

--动态数据初始化(面板完全打开后的一些数据初始化)
function Pin3Manager:Awake()
    this = self

    --工具初始化
    Pin3Utils.Init(Pin3BattlePanel.GetTransform())

    if Pin3Data.isPlayback then
        --回放没有加入房间的过程，故直接关闭Waiting
        Waiting.Hide()
        Pin3PlaybackManager.BeginPlayback()
    else
        --发送加入房间完成协议
        Pin3NetworkManager.SendJoinedRoom()
    end

    this.InitChatManager()
end

--初始化房间信息
function Pin3Manager.InitRoomInfo()
    --更新房间面板显示
    Pin3BattlePanel.UpdateTableInfo()
    Pin3BattlePanel.InitJiaZhuBtns()

    --初始化玩家信息控制组件
    local userInfoCtrls = {}
    local tempPos = nil
    local tempUserInfoTran = nil
    local tempUserInfoCtrl = nil

    for i = 1, Pin3Data.totalUserNum do
        tempPos = Pin3BattlePanel.GetPosByUIIdx(i)
        if tempPos ~= nil then
            tempUserInfoTran = tempPos:Find("UserInfo")
            if tempUserInfoTran ~= nil then
                tempUserInfoCtrl = GetLuaComponent(tempUserInfoTran.gameObject, "Pin3UserInfoCtrl")
                if tempUserInfoCtrl ~= nil then
                    LogError("<color=aqua>userInfoCtrls</color>", userInfoCtrls.uid)
                    userInfoCtrls[i] = tempUserInfoCtrl
                else
                    DestroyObj(tempUserInfoTran.gameObject)
                    userInfoCtrls[i] = Pin3Utils.NewUserInfoGo(tempPos, i)
                end
            else
                userInfoCtrls[i] = Pin3Utils.NewUserInfoGo(tempPos, i)
            end
        end
    end
    local uid = Pin3Data.GetSelfUidInGame()
    local selfSeatId = Pin3Data.GetSeatNum(uid)
    LogError("selfSeatId", selfSeatId)
    --设置每个玩家信息控制组件计算服务器逻辑座位
    if selfSeatId ~= nil then
        local idx = 1
        for i = selfSeatId, Pin3Data.totalUserNum do
            userInfoCtrls[idx]:SetSeatId(i)
            idx = idx + 1
        end

        for i = 1, selfSeatId - 1 do
            userInfoCtrls[idx]:SetSeatId(i)
            idx = idx + 1
        end
    else
        Log("没有查找到自己的玩家数据", Pin3Data.uid)
        return nil
    end

    for k, v in pairs(userInfoCtrls) do
        LogError("userInfoCtrls", v.seatId)
    end

    --为每个玩家信息控制组件绑定玩家数据
    local userIds = Pin3Data.GetAllUserIds()
    LogError("userIds", userIds)
    for _, uid in pairs(userIds) do
        for _, userCtrl in pairs(userInfoCtrls) do
            if userCtrl.seatId == Pin3Data.GetSeatNum(uid) then
                userCtrl:BindUserInfo(uid)
            end
        end
    end

    this.userInfoCtrls = userInfoCtrls

    --如果是发牌状态
    if Pin3Data.gameStatus == Pin3GameStatus.FaPaiBaDi or
            Pin3Data.gameStatus == Pin3GameStatus.WaitingUserPerform or
            Pin3Data.gameStatus == Pin3GameStatus.JieSuan then
        this.FaPai(false)
        for i, userCtrl in pairs(this.userInfoCtrls) do
            --如果玩家有牌，恢复牌显示
            userCtrl:SetCardIds(true)
        end
    end

    for i, userCtrl in pairs(this.userInfoCtrls) do
        --刷新玩家信息
        this.UpdateUserInfo(userCtrl.uid)
    end
    Pin3BattlePanel.ShowOperBtns()
    Pin3BattlePanel.JudgeShowSitdownBtn()
    this.UpdateChatPlayers()
    ChatModule.SetIsCanSend(true)
end

function Pin3Manager.GetUserInfoCtrlByUid(uid)
    for _, userCtrl in pairs(this.userInfoCtrls) do
        if userCtrl.isBindUserInfo and userCtrl.uid == uid then
            return userCtrl
        end
    end
    return nil
end

function Pin3Manager.GetUserInfoCtrlBySeatId(seatId)
    for _, userCtrl in pairs(this.userInfoCtrls) do
        if userCtrl.seatId == seatId then
            return userCtrl
        end
    end
    return nil
end

--刷新用户信息
function Pin3Manager.UpdateUserInfo(uid)
    --LogError("==>UpdateUserInfo", uid, GetTableString(Pin3Data))
    if not this.userInfoCtrls then
        return
    end
    local userCtrl = this.GetUserInfoCtrlByUid(uid)
    if userCtrl ~= nil then
        if userCtrl.isBindUserInfo then
            userCtrl:UpdateChangableInfo()
            --刷新自己的数据
            if userCtrl:IsSelf() then
                Pin3BattlePanel.SetPrepareBtnVisible(false)
                Pin3BattlePanel.SetLiangPaiBtnVisible(false)
                if Pin3Data.gameStatus == Pin3GameStatus.WaitingPrepare and not Pin3Data.IsObserver then
                    LogError("<color=aqua>Pin3Data.uid</color>", Pin3Data.uid, "Pin3Data.ownerId", Pin3Data.ownerId)
                    if Pin3Data.isOwner then
                        Pin3BattlePanel.SetStartGameBtnVisible(Pin3Data.GetIsPrepare(uid) ~= true)
                    else
                        Pin3BattlePanel.SetPrepareBtnVisible(Pin3Data.GetIsPrepare(uid) ~= true)
                    end
                elseif Pin3Data.gameStatus == Pin3GameStatus.JieSuan then
                    Pin3BattlePanel.SetLiangPaiBtnVisible(Pin3Data.GetShuStatus(uid) == 1)
                end
            end

            --玩家离开房间判断
            if not Pin3Data.GetIsInRoom(uid) then
                Toast.Show(tostring(Pin3Data.GetUserName(uid) .. "已离开房间"))
                Pin3Data.RemoveUserData(uid)
                this.PlayerLeaveJudgeHasEmptySeat(uid)
                userCtrl:UnBindUserInfo()
                this.UpdateChatPlayers()
            end
        end
    else
        --新加入房间玩家
        if Pin3Data.GetIsInRoom(uid) then
            userCtrl = this.GetUserInfoCtrlBySeatId(Pin3Data.GetSeatNum(uid))
            if userCtrl ~= nil then
                userCtrl:BindUserInfo(uid)
                this.UpdateUserInfo(uid)
                this.UpdateChatPlayers()
            end
        end
    end
end

---检测有玩家离开时是否有空位
function Pin3Manager.PlayerLeaveJudgeHasEmptySeat(uid)
    for k, v in pairs(Pin3Data.userDatas) do
        LogError("<color=aqua>userDatas[i]</color>", v.uid)
    end
    LogError("Pin3Data.userDatas", GetTableSize(Pin3Data.userDatas), Pin3Data.parsedRules.playerTotal)
    if GetTableSize(Pin3Data.userDatas) < Pin3Data.parsedRules.playerTotal and Pin3Data.IsObserver then
        Pin3BattlePanel.SetSitdownBtnActive(true)
    end
end

--执行操作
function Pin3Manager.PerformOper()
    Pin3BattlePanel.UpdateTableInfo()
    local uid = Pin3Data.IsObserver and Pin3Data.DefaultObservedPlayerID or Pin3Data.operUid
    local userCtrl = this.GetUserInfoCtrlByUid(uid)
    if userCtrl ~= nil then
        if Pin3Data.operType == Pin3UserOperType.KanPai then
            --看牌
            userCtrl:SetCardIds(true)
            userCtrl:UpdateChangableInfo()
            if userCtrl:IsSelf() then
                Pin3BattlePanel.ShowOperBtns()
            end
            Pin3AudioManager.PlayAudio(Pin3AudioType.KanPaiText)
        elseif Pin3Data.operType == Pin3UserOperType.QiPai then
            --弃牌
            if not Pin3Data.GetIsKanPai(uid) then
                userCtrl:SetCardIds(true)
            end
            userCtrl:UpdateChangableInfo()
            Pin3AudioManager.PlayAudio(Pin3AudioType.QiPaiText)
            if userCtrl:IsSelf() then
                Pin3BattlePanel.HideOperBtns()
            end
        elseif Pin3Data.operType == Pin3UserOperType.LiangPai then
            --亮牌
            userCtrl:SetCardIds(true)
            Pin3Data.SetIsLiangPai(userCtrl.uid, true)
        elseif Pin3Data.operType == Pin3UserOperType.BiPai then
            --比牌
            Scheduler.unscheduleGlobal(this.biPaiHandle)
            if Pin3Data.isGuZhuYiZhi and Pin3Data.gzyzAnimTimes <= 0 then
                Pin3AudioManager.PlayAudio(Pin3AudioType.GuZhuYiZhi)
                Pin3Data.gzyzAnimTimes = Pin3Data.gzyzAnimTimes + 1
                Pin3AnimManager.Play(Pin3AnimType.Gzyz, nil, nil, true)
                LockScreen(1)
                this.biPaiHandle = Scheduler.scheduleOnceGlobal(function()
                    this.BiPaiAnim()
                end, 1)
            else
                Pin3AudioManager.PlayAudio(Pin3AudioType.BiPaiText)
                this.BiPaiAnim()
            end
            if Pin3Data.curYz ~= nil and tonumber(Pin3Data.curYz) > 0 then
                userCtrl:GoldAnim(Pin3Data.curYz)
            end
        elseif Pin3Data.operType == Pin3UserOperType.GenZhu or Pin3Data.operType == Pin3UserOperType.JiaZhu then
            --跟注或加注
            userCtrl:UpdateChangableInfo()
            LogError("Pin3Data.curYz", Pin3Data.curYz)
            if Pin3Data.curYz ~= nil and tonumber(Pin3Data.curYz) > 0 then
                userCtrl:GoldAnim(Pin3Data.curYz)
            end
            if Pin3Data.operType == Pin3UserOperType.GenZhu then
                this.genZhuTimes = this.genZhuTimes + 1
                if this.genZhuTimes == 1 then
                    Pin3AudioManager.PlayAudio(Pin3AudioType.GenZhuText1)
                elseif this.genZhuTimes == 2 then
                    Pin3AudioManager.PlayAudio(Pin3AudioType.GenZhuText2)
                elseif this.genZhuTimes == 3 then
                    Pin3AudioManager.PlayAudio(Pin3AudioType.GenZhuText3)
                else
                    Pin3AudioManager.PlayAudio(Pin3AudioType["GenZhuText" .. tostring(GetRandom(1, 30000) % 3 + 1)])
                end
            elseif Pin3Data.operType == Pin3UserOperType.JiaZhu then
                Pin3AudioManager.PlayAudio(Pin3AudioType.JiaZhuText)
            end
        end
    else
        --强制比牌(轮数结束后所有玩家强制比牌)，此时没有operUid
        if Pin3Data.operType == Pin3UserOperType.ForceBiPai then
            Pin3BattlePanel.ShowTips("轮次结束，即将进入结算")
            for _, userCtrl in pairs(this.userInfoCtrls) do
                userCtrl:UpdateChangableInfo()
            end
        end
    end
end

--更新房间操作状态
function Pin3Manager.UpdateTableOperStatus()
    --倒数第二轮提示
    if Pin3Data.curLunShu + 2 == Pin3Data.GetRule(Pin3RuleType.maxLunShu) then
        Pin3BattlePanel.ShowTips("两轮后系统将从庄家下一位开始逆时针比牌")
    else
        Pin3BattlePanel.ShowTips(nil)
    end
    if Pin3Data.gameStatus == Pin3GameStatus.FaPaiBaDi then
        this.FaPai(true)
    elseif Pin3Data.gameStatus == Pin3GameStatus.WaitingPrepare then
        Pin3Data.ResetAllUserData()
        Pin3BattlePanel.ResetForNext()
        for _, userInfoCtrl in pairs(this.userInfoCtrls) do
            if userInfoCtrl.isBindUserInfo then
                userInfoCtrl:Reset()
            end
        end
        this.genZhuTimes = 0
    elseif Pin3Data.gameStatus == Pin3GameStatus.WaitingUserPerform then
        Pin3BattlePanel.ShowOperBtns()
        if not Pin3Data.IsFkRoom() then
            if Pin3Data.operUid == Pin3Data.uid and tonumber(Pin3Data.GetGoldNum(Pin3Data.uid)) <= tonumber(Pin3Data.GetRule(Pin3RuleType.minTips)) then
                Toast.Show("您的元宝数量较低，请慎重操作！")
            end
        end
    elseif Pin3Data.gameStatus == Pin3GameStatus.JieSuan then
        Pin3BattlePanel.HideOperBtns()
        Pin3BattlePanel.UpdateClock("结算中", 3)
        --Pin3BattlePanel.ShowTips("结算中，下一局即将开始......")
    end
    Pin3BattlePanel.UpdateTableInfo()
    for _, userInfoCtrl in pairs(this.userInfoCtrls) do
        if userInfoCtrl.isBindUserInfo then
            this.UpdateUserInfo(userInfoCtrl.uid)
        end
    end
    --Log("==>UpdateTableOperStatus", GetTableString(Pin3Data))
end

function Pin3Manager.ResetAllUserCtrl()
    Pin3Data.ResetAllUserData()
    Pin3BattlePanel.ResetForNext()
    if this.userInfoCtrls then
        for _, userInfoCtrl in pairs(this.userInfoCtrls) do
            if userInfoCtrl.isBindUserInfo then
                userInfoCtrl:Reset()
                userInfoCtrl:UnBindUserInfo()
            end
        end
    end
end

--发牌
function Pin3Manager.FaPai(isAnim)
    this.genZhuTimes = 0
    LockScreen(1)
    --牌移动到玩家手中时间
    local cardMoveToUserTime = 0.2
    --每个玩家3张手牌移动间隔
    local cardInterval = 0.02
    --每个玩家手牌移动间隔
    local userInterval = 0.05
    --金币投入动画时间
    local coinTime = 0.2
    if not isAnim then
        cardMoveToUserTime = 0
        cardInterval = 0
        userInterval = 0
        coinTime = 0
    end
    local faPaiFun = function()
        local fpTran = Pin3BattlePanel.GetFaPaiTran()
        for i, userCtrl in pairs(this.userInfoCtrls) do
            if userCtrl.isBindUserInfo and Pin3Data.GetIsPrepare(userCtrl.uid) then
                userCtrl:GoldAnim(Pin3Data.GetRule(Pin3RuleType.baseScore))
                Scheduler.scheduleOnceGlobal(function()
                    for j = 1, 3 do
                        local idx = j
                        local tempUserCtrl = userCtrl
                        if not IsNull(tempUserCtrl.gameObject) then
                            Pin3AudioManager.PlayByPin3AudioType(Pin3AudioType.FaPai)
                            Scheduler.scheduleOnceGlobal(function()
                                local tempCardObj = Pin3Utils.NewCard(fpTran)
                                if not IsNull(tempUserCtrl.gameObject) then
                                    tempUserCtrl:AddCardObj(tempCardObj, idx)
                                    tempCardObj:SetAnchoredPosition(0, 0, isAnim, cardMoveToUserTime)
                                    UIUtil.SetLocalScale(tempCardObj.gameObject, 1, 1, 1)
                                end
                            end, (j - 1) * cardInterval)
                        end
                    end
                end, (i - 1) * userInterval)
            end
        end
    end

    Scheduler.unscheduleGlobal(this.faPaiDelayHandle)
    if isAnim then
        this.faPaiDelayHandle = Scheduler.scheduleOnceGlobal(faPaiFun, 1.5)
        Pin3AnimManager.Play(Pin3AnimType.StartGame)
        Pin3AudioManager.PlayAudio(Pin3AudioType.StartGame)
    else
        faPaiFun()
    end
end

--比牌
function Pin3Manager.BiPaiAnim()
    Log("==>BiPai", GetTableString(Pin3Data))
    local len = GetTableSize(Pin3Data.fightIds)
    if len > 0 then
        if len == 2 then
            --LockScreen(3.2)
            --1.执行Vs动画
            local tempAnimTran = Pin3AnimManager.Play(Pin3AnimType.ShowVs, nil, nil, true)

            --2.人物头像飞到Vs动画相应位置
            local leftNode = tempAnimTran:Find("bg00")
            local rightNode = tempAnimTran:Find("bg001")
            local userCtrl1 = this.GetUserInfoCtrlByUid(Pin3Data.fightIds[1])
            local userCtrl2 = this.GetUserInfoCtrlByUid(Pin3Data.fightIds[2])
            local origin1Parent = userCtrl1.basicInfoTran.parent
            local origin2Parent = userCtrl2.basicInfoTran.parent
            local shuNode = nil
            local delayTime = 0.5
            --飞头像动画
            Scheduler.unscheduleGlobal(this.flyHeadHandle1)
            this.flyHeadHandle1 = Scheduler.scheduleOnceGlobal(function()
                if userCtrl1.uiIdx >= 1 and userCtrl1.uiIdx <= 4 then
                    userCtrl1.basicInfoTran:SetParent(rightNode)
                    userCtrl2.basicInfoTran:SetParent(leftNode)
                    if userCtrl1.uid == Pin3Data.winIds[1] then
                        shuNode = leftNode
                    elseif userCtrl2.uid == Pin3Data.winIds[1] then
                        shuNode = rightNode
                    end
                    userCtrl2.basicInfoTran:DOLocalMove(Vector3(0, -0.1, 0), 0.3):SetEase(DG.Tweening.Ease.Linear)
                    userCtrl1.basicInfoTran:DOLocalMove(Vector3(0, 0.15, 0), 0.3):SetEase(DG.Tweening.Ease.Linear)
                else
                    userCtrl1.basicInfoTran:SetParent(leftNode)
                    userCtrl2.basicInfoTran:SetParent(rightNode)
                    userCtrl1.basicInfoTran:DOLocalMove(Vector3(0, -0.1, 0), 0.3):SetEase(DG.Tweening.Ease.Linear)
                    userCtrl2.basicInfoTran:DOLocalMove(Vector3(0, 0.15, 0), 0.3):SetEase(DG.Tweening.Ease.Linear)
                    if userCtrl1.uid == Pin3Data.winIds[1] then
                        shuNode = rightNode
                    elseif userCtrl2.uid == Pin3Data.winIds[1] then
                        shuNode = leftNode
                    end
                end
                local selfScale = 0.8
                if userCtrl1:IsSelf() then
                    userCtrl1.basicInfoTran:DOScale(Vector3(selfScale, selfScale, selfScale), 0.3)
                elseif userCtrl2:IsSelf() then
                    userCtrl2.basicInfoTran:DOScale(Vector3(selfScale, selfScale, selfScale), 0.3)
                end
            end, delayTime)

            --3.输家闪电动画
            delayTime = delayTime + 0.4
            Scheduler.unscheduleGlobal(this.leiHandle)
            this.leiHandle = Scheduler.scheduleOnceGlobal(function()
                local go = Pin3AnimManager.Play(Pin3AnimType.Lei, shuNode)
                if shuNode == rightNode then
                    UIUtil.SetRotation(go, 0, 0, 0)
                    UIUtil.SetLocalPosition(go, 0, 8, 0)
                else
                    UIUtil.SetLocalPosition(go, 0, 8, 0)
                end
                Pin3AudioManager.PlayAudio(Pin3AudioType.ShanDian)
            end, delayTime)


            --4.玩家头像复位动画及Vs消失动画
            delayTime = delayTime + 2
            Scheduler.unscheduleGlobal(this.flyHeadHandle2)
            this.flyHeadHandle2 = Scheduler.scheduleOnceGlobal(function()
                for _, userCtrl in pairs(this.userInfoCtrls) do
                    userCtrl:UpdateChangableInfo()
                    userCtrl:SetBiPaiBtnVisible(false)
                end

                userCtrl1.basicInfoTran:SetParent(origin1Parent)
                userCtrl2.basicInfoTran:SetParent(origin2Parent)
                userCtrl1.basicInfoTran:DOAnchorPos(Vector3.zero, 0.3):SetEase(DG.Tweening.Ease.Linear)
                userCtrl2.basicInfoTran:DOAnchorPos(Vector3.zero, 0.3):SetEase(DG.Tweening.Ease.Linear)
                UIUtil.SetSiblingIndex(userCtrl1.basicInfoTran, 1)
                UIUtil.SetSiblingIndex(userCtrl2.basicInfoTran, 1)
                local selfBasicInfoScaleVector3 = Vector3(this.SelfBasicInfoScale, this.SelfBasicInfoScale, this.SelfBasicInfoScale)
                if userCtrl1:IsSelf() then
                    userCtrl1.basicInfoTran:DOScale(selfBasicInfoScaleVector3, 0.3)
                end
                if userCtrl2:IsSelf() then
                    userCtrl2.basicInfoTran:DOScale(selfBasicInfoScaleVector3, 0.3)
                end
                --Pin3AnimManager.PlayNodeAnim(tempAnimTran.gameObject, Pin3AnimType.HideVs, nil, true)
            end, delayTime)
        else
        end
    end
end

--退出房间  1.正常退出  2.被踢出  3.房间解散   4.金币不足被踢出，5游戏结束
function Pin3Manager.QuitRoom(type)
    local tipText = ""
    if type == 1 then
        --tipText = "退出房间成功"
    elseif type == 2 then
        tipText = "您已被踢出房间"
    elseif type == 3 then
        tipText = "房间已解散"
    elseif type == 4 then
        tipText = "余额不足，您已被踢出房间"
    elseif type == 5 then
        tipText = "游戏已结束"
    end
    local quitCallback = function()
        local args = { gameType = GameType.Pin3 }
        if Pin3Data.isPlayback then
            args.openType = DefaultOpenType.Record
            args.recordType = Pin3Data.recordType
            if Pin3Data.recordType == 2 then
                args.groupId = Pin3Data.groupId
            end
        else
            if Pin3Data.roomType == RoomType.Tea then
                args.openType = DefaultOpenType.Tea
                args.groupId = Pin3Data.groupId
            else
                args.openType = DefaultOpenType.Lobby
                args.groupId = 0
            end
        end
        GameSceneManager.SwitchGameScene(GameSceneType.Lobby, GameType.Pin3, args)
    end
    if not string.IsNullOrEmpty(tipText) then
        Alert.Show(tipText, function()
            quitCallback()
        end)
    else
        quitCallback()
    end
end

--断线重连
function Pin3Manager.OnReauthentication()
    if not Pin3Data.isPlayback then
        UserData.SetIsReconnectTag(true)
        BaseTcpApi.SendCheckIsInRoom(UserData.GetRoomId(), function(data)
            if data.code == 0 then
                if data.data.roomId > 0 then
                    Pin3Data.port = data.data.line
                    Pin3NetworkManager.SendJoinedRoom()
                    PanelManager.Close(PanelConfig.GoldMatch)
                end
            end
        end, GameType.Pin3, nil, this.QuitRoom)
    end
    if IsTable(ChatModule) then
        ChatModule.SetIsCanSend(true)
    end
end

--单局结算
function Pin3Manager.OnDanJuJieSuan()
    for _, userCtrl in pairs(this.userInfoCtrls) do
        if userCtrl.isBindUserInfo then
            this.UpdateUserInfo(userCtrl.uid)
            --结算如果有牌，显示
            userCtrl:SetCardIds(true)
        end
    end
end
-----------------------------------按钮点击-----------------------------------------------------
--点击设置
function Pin3Manager.OnClickSettingBtn()
    PanelManager.Open(Pin3Panels.Pin3Setting)
end

--点击GPS
function Pin3Manager.OnClickGpsBtn()
    PanelManager.Open(PanelConfig.RoomGps, Pin3Data.GetGpsMapData())
end

--点击规则
function Pin3Manager.OnClickRuleBtn()
    PanelManager.Open(Pin3Panels.Pin3Rule)
end

--弃牌
function Pin3Manager.OnClickQiPaiBtn()
    if Pin3Data.isPlayback then
        return
    end
    Pin3NetworkManager.SendOper(Pin3UserOperType.QiPai)
end

--看牌
function Pin3Manager.OnClickKanPaiBtn()
    if Pin3Data.isPlayback then
        return
    end
    Pin3NetworkManager.SendOper(Pin3UserOperType.KanPai)
    UIUtil.SetActive(Pin3BattlePanel.kanPaiBtn, false)
end

--比牌
function Pin3Manager.OnClickBiPaiBtn()
    if Pin3Data.isPlayback then
        return
    end
    --游戏中玩家Id
    local gameUids = {}
    for _, userCtrl in pairs(this.userInfoCtrls) do
        if userCtrl.isBindUserInfo and not userCtrl:IsSelf() then
            if Pin3Data.GetIsPrepare(userCtrl.uid) and Pin3Data.GetShuStatus(userCtrl.uid) == 0 then
                table.insert(gameUids, userCtrl.uid)
            end
        end
    end
    local len = GetTableSize(gameUids)
    if len > 0 then
        Log("==>OnClickBiPaiBtn", gameUids, GetTableString(Pin3Data))
        if len == 1 then
            this.OnClickUserInfoBiPaiBtn(gameUids[1])
        else
            for _, userCtrl in pairs(this.userInfoCtrls) do
                if userCtrl.isBindUserInfo then
                    if not userCtrl:IsSelf() and Pin3Data.GetShuStatus(userCtrl.uid) == 0 and Pin3Data.GetIsPrepare(userCtrl.uid) then
                        userCtrl:SetBiPaiBtnVisible(true)
                    end
                end
            end
        end
    end
end

--和玩家比牌
function Pin3Manager.OnClickUserInfoBiPaiBtn(uid)
    if Pin3Data.isPlayback then
        return
    end
    Pin3NetworkManager.SendOper(Pin3UserOperType.BiPai, uid)
end

--跟注
function Pin3Manager.OnClickGenZhuBtn()
    if Pin3Data.isPlayback then
        return
    end
    local gold = 0
    if Pin3Data.GetIsKanPai(Pin3Data.uid) then
        gold = Pin3Data.curDanZhuGold * 2
    else
        gold = Pin3Data.curDanZhuGold
    end
    Pin3NetworkManager.SendOper(Pin3UserOperType.GenZhu, nil, gold)
end

--加注
function Pin3Manager.OnClickJiaZhuBtn(goldNum)
    if Pin3Data.isPlayback then
        return
    end
    Pin3BattlePanel.SetJiaZhuBtnsDisplay(false)
    Pin3NetworkManager.SendOper(Pin3UserOperType.JiaZhu, nil, goldNum)
end

--亮牌
function Pin3Manager.OnClickLiangPaiBtn()
    if Pin3Data.isPlayback then
        return
    end
    Pin3NetworkManager.SendOper(Pin3UserOperType.LiangPai)
end

--准备
function Pin3Manager.OnClickPrepare()
    if Pin3Data.isPlayback then
        return
    end
    if Pin3Data.IsFkRoom() then
        Pin3NetworkManager.SendPrepare()
    else
        if tonumber(Pin3Data.GetGoldNum(Pin3Data.uid)) < Pin3Data.GetRule(Pin3RuleType.zhuiRu) then
            Toast.Show("金豆不足")
        else
            Pin3NetworkManager.SendPrepare()
        end
    end
end

--自动押注
function Pin3Manager.OnClickAutoYzToggle(isOn)
    if Pin3Data.isPlayback then
        return
    end
    if not Pin3BattlePanel.IsUiUpdateToggle() then
        if isOn then
            Pin3NetworkManager.SendAutoYaZhu(1)
        else
            Pin3NetworkManager.SendAutoYaZhu(0)
        end
    end
end
-----------------------------------按钮点击end-----------------------------------------------------
-----------------------------------聊天模块--------------------------------------------------------
--初始化聊天系统
function Pin3Manager.InitChatManager()
    if Pin3Data.isPlayback then
        return
    end

    --显示聊天气泡
    ChatModule.SetChatCallback(this.ShowChatBubble)
    --显示聊天语音气泡
    ChatModule.SetVoiceCallback(this.ShowChatVoiceBubble)
    local config = {
        audioBundle = Pin3BundleNames.chatBundle,
        textChatConfig = Pin3QuickLanguage,
        languageType = LanguageType.sichuan,
        canSend = true
    }
    ChatModule.SetChatConfig(config)

    --初始化基本信息
    ChatModule.Init(PanelConfig.RoomChat, PanelConfig.RoomUserInfo)
end

--玩家聊天数据更新
function Pin3Manager.UpdateChatPlayers()
    if Pin3Data.isPlayback then
        return
    end
    local players = {}
    local uid = 0
    for _, userCtrl in pairs(this.userInfoCtrls) do
        if userCtrl.isBindUserInfo then
            uid = userCtrl.uid
            players[uid] = {}
            players[uid].emotionNode = userCtrl:GetSayEmotionRoot()
            players[uid].animNode = userCtrl.basicInfoTran
            players[uid].gender = Pin3Data.GetSex(uid)
            players[uid].name = Pin3Data.GetUserName(uid)
        end
    end
    ChatModule.SetPlayerInfos(players)
end

--回调显示文本
function Pin3Manager.ShowChatBubble(playerId, duration, str)
    local player = this.GetUserInfoCtrlByUid(tonumber(playerId))
    player:SayText(str, duration)
end

--回调显示语音气泡
function Pin3Manager.ShowChatVoiceBubble(playerId, duration)
    local player = this.GetUserInfoCtrlByUid(tonumber(playerId))
    player:PlayVoiceBubble()

    Scheduler.scheduleOnceGlobal(
            function()
                player:StopVoiceBubble()
            end,
            duration
    )
end
-----------------------------------聊天模块end-----------------------------------------------------
--
--清除回放相关
function Pin3Manager.ClearByPlayback()
    this.ResetAllUserCtrl()
end

return Pin3Manager