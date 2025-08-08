PdkRoomCtrl = ClassLuaComponent("PdkRoomCtrl")
local this = PdkRoomCtrl
this.intervalTime = 1

function PdkRoomCtrl:Awake()
    this = self
    PdkAudioCtrl.PlayBgMusic()
end

function PdkRoomCtrl.Init()
    this.Clear()
    if PdkRoomModule.isPlayback then
        Waiting.Hide()
        PdkRoomPanel.HidePlayBackElement()
        PdkPlayBackCtrl.BeginPlayback()
    else
        PdkRoomPanel.ShowAllElement()
        PdkRoomPanel.ShowChangeRoomBtn(false)--PdkRoomModule.IsClubRoom())
        PdkRoomModule.SendJoinedRoom()
    end
end

--初始化房间信息
function PdkRoomCtrl.InitRoom(data)
    --初始化玩家信息
    -- for k, v in pairs(PdkRoomModule.players) do
    --     PdkRoomPanel.PlayerInit(k, v)
    -- end

    for i = 1, 4 do
        local playerData = PdkRoomModule.players[i]
        if playerData ~= nil then
            PdkRoomPanel.PlayerInit(i, playerData)
        else
            PdkRoomPanel.PlayerExit(i)
        end
    end
    PdkRoomCtrl.UpdateChatPlayerInfos()
    --初始化房房号、房主、局数信息
    PdkRoomPanel.SetRoomID(PdkRoomModule.roomId)
    -- PdkRoomPanel.SetOwner(PdkRoomModule.GetPlayerInfoById(PdkRoomModule.ownerId).playerName)
    PdkRoomPanel.SetRoomRound(PdkRoomModule.nowjs, PdkRoomModule.maxjs)
    PdkRoomPanel.SetPlayType(PdkRoomModule.playWayType)
    --初始化桌面牌
    if data.tablePokerMsg.pokerType ~= PdkPokerType.None then
        PdkRoomPanel.ShowTableCard(data.tablePokerMsg.pokers)
        PdkRoomModule.pokerTypeMsg = data.tablePokerMsg.pokerTypeMsg
        PdkRoomModule.SetBiggerPokers(data.tablePokerMsg.pokerTypeMsg, PdkSelfHandCardCtrl.GetHandPokers())
    end
    if not PdkRoomModule.isDisRoomIng and PanelManager.IsOpened(PdkPanelConfig.Dissovle) then
        PanelManager.Close(PdkPanelConfig.Dissovle)
    end
    --更新房间状态
    this.UpdateRoomInfo()
    this.InitChat()
    if PdkRoomModule.IsGoldRoom() then
        PdkRoomPanel.ShowGoldRoomBtn()
    else
        if not PdkRoomModule.isPlayback then
            --同步获取获取GPS
            -- this.StartCheckGps()
        end
    end
    if not PdkRoomModule.isPlayback then
        PdkRoomPanel.ShowOnHookBtn(PdkRoomModule.isTuoGuan)
    end
end

--初始化聊天系统
function PdkRoomCtrl.InitChat()
    if PdkRoomModule.isPlayback then
        return
    end
    --显示聊天气泡
    ChatModule.SetChatCallback(this.ShowTalkText)
    --设置聊天气泡方法显示回调(发聊天的玩家id，显示时间长度)
    ChatModule.SetVoiceCallback(this.ShowChatVoiceBubble)
    local config = {
        audioBundle = PdkBundleName.Audio,
        textChatConfig = PdkBroadcast.TextChat,
        languageType = LanguageType.putonghua
    }
    ChatModule.SetChatConfig(config)
    ChatModule.Init(PanelConfig.RoomChat, PanelConfig.RoomUserInfo)
end

--聊天模块需要的数据和头像设置数据
function PdkRoomCtrl.UpdateChatPlayerInfos()
    local playerInfos = {}
    local headPlayers = {}
    local tempPlayer = nil
    for k, v in pairs(PdkRoomModule.players) do
        playerInfos[v.playerId] = {
            name = v.playerName,
            gender = v.sex,
            emotionNode = PdkRoomPanel.GetPlayerNodeBySeat(k).emotionNode1,
            animNode = PdkRoomPanel.GetPlayerNodeBySeat(k).emotionNode2
        }

        tempPlayer = { seatIndex = k, id = v.playerId, image = PdkRoomPanel.GetPlayerNodeBySeat(k).headImage, headUrl = v.playerHead }
        table.insert(headPlayers, tempPlayer)
    end
    ChatModule.SetPlayerInfos(playerInfos)
    RoomUtil.StartCheckPlayerHeadImage(headPlayers)
end

--有玩家加入或退出
function PdkRoomCtrl.UpdatePlayer(data)
    if PdkRoomModule.IsSelfByID(data.playerId) then
        if data.type == 0 then
            if PdkRoomModule.isSendQuitRoomMsg then
                if not PanelManager.IsOpened(PanelConfig.RoomChange) then
                    Toast.Show("您已退出房间")
                    this.ExitRoom()
                end
            else
                Toast.Show("您已退出房间")
                this.ExitRoom()
            end
            return
        end
    end
    --计算本地座位号
    local index = PdkRoomModule.GetPlayerLocalSeat(data.seatNum)
    if data.type == 0 then
        PdkRoomPanel.PlayerExit(index)
    elseif data.type == 1 or data.type == 2 then
        PdkRoomPanel.PlayerJoin(index, data)
        PdkRoomPanel.ShowOnHookBtn(PdkRoomModule.isTuoGuan)
    end
    PdkRoomCtrl.UpdateChatPlayerInfos()
end

--玩家准备状态
function PdkRoomCtrl.PlayerReady(data)
    local index = PdkRoomModule.GetPlayerLocalSeat(data.seatNum)
    PdkRoomPanel.PlayerReady(index, data.isZhunBei > 0)
    if PdkRoomModule.IsSelfBySeat(data.seatNum) and PanelManager.IsOpened(PdkPanelConfig.SingleRecord) then
        PanelManager.Close(PdkPanelConfig.SingleRecord)
    end
end

--更新玩家分数
function PdkRoomCtrl.UpdatePlayerScore()
    local isPlayAudio = false
    for k, v in pairs(PdkRoomModule.players) do
        if v.deductGold ~= nil and v.deductGold ~= 0 then
            isPlayAudio = true
            PdkRoomPanel.ScoreAnim(k, v.deductGold, v.score)
            v.deductGold = 0
        else
            if PdkRoomModule.IsGoldRoom() then
                PdkRoomPanel.SetScoreNum(k, v.score)
            end
        end
    end
    if isPlayAudio then
        PdkAudioCtrl.PlayBombCoin()
    end
end

--单局结算
function PdkRoomCtrl.SingleRecord(data)
    --更新玩家分数
    -- local index = nil
    -- local player = nil
    -- local info = nil
    for i = 1, #data.list do
        local info = data.list[i]
        local playerData = PdkRoomModule.GetPlayerInfoById(info.playerId)
        if playerData ~= nil then
            local index = PdkRoomModule.GetPlayerLocalSeat(playerData.seatNum)
            PdkRoomPanel.SetScoreNum(index, info.totalScore)
        else
            LogError("玩家信息不存在：", info.playerId)
        end
    end
    --单局结算面板
    -- if PdkRoomModule.singleRecordIndex ~= data.nowjs  then
    --     PanelManager.Open(PdkPanelConfig.SingleRecord, data)
    -- end
    local isOpen = PanelManager.IsOpened(PdkPanelConfig.SingleRecord)
    if PdkRoomModule.IsOver() then
        if not isOpen then
            PanelManager.Open(PdkPanelConfig.SingleRecord, data)
        end
    else
        if not (PdkRoomModule.isZhunBei) and not isOpen then
            PanelManager.Open(PdkPanelConfig.SingleRecord, data)
        end
    end

    -- if PdkRoomModule.IsGoldRoom() then
    --     PdkRoomCtrl.StopCheckGps()
    -- end
end

--给玩家发牌并更新玩家的手牌数量
function PdkRoomCtrl.DealCard(data)
    -- local index = nil
    --找到庄家位置 设置庄家
    -- PdkRoomPanel.ShowBanker(index, true)
    -- PdkRoomPanel.SetBanker(index)
    --给每个玩家发牌
    -- local info = nil
    -- local playerData = nil
    for i = 1, #data.list do
        local info = data.list[i]
        local playerData = PdkRoomModule.GetPlayerInfoById(info.playerId)
        local index = PdkRoomModule.GetPlayerLocalSeat(playerData.seatNum)
        if playerData ~= nil then
            if PdkRoomModule.IsSelfByID(info.playerId) then
                PdkSelfHandCardCtrl.DealCard(info.pokers)
                Log("给自己发牌")
            else
                --显示手牌数量图标 和 更新数量
                PdkRoomPanel.ShowCardNum(index, true)
                PdkRoomPanel.DealCard(index, info.pokers)
                PdkRoomPanel.UpdateCardNum(index, info.pokerNum)
                Log("更新其他玩家手牌", index)
            end
        else
            LogError("玩家信息不存在：", info.playerId)
        end
    end
end

--设置庄家
function PdkRoomCtrl.SetBanker()
    local index = PdkRoomModule.GetPlayerLocalSeat(PdkRoomModule.bankerSeat)
    PdkRoomPanel.SetBanker(index)
end

--根据房间状态更新房间UI
function PdkRoomCtrl.UpdateRoomInfo()
    PdkRoomPanel.ShowCopyAndInviteBtn(false)
    if PdkRoomModule.gameStatus == PdkGameStatus.Leisure then
        PdkRoomPanel.ShowCopyAndInviteBtn(true)
        if PanelManager.IsOpened(PanelConfig.RoomGps) then
            PanelManager.Close(PanelConfig.RoomGps)
        end
    elseif PdkRoomModule.gameStatus == PdkGameStatus.WaitReady then
        -- PdkRoomPanel.ShowStartBtn(true)
        --PdkRoomModule.IsFangKaRoom() and 
        if PdkRoomModule.IsInitRoom() and not PdkRoomModule.isZhunBei then
            PanelManager.Open(PanelConfig.RoomGps, PdkRoomModule.GetGpsData())
        end
    elseif PdkRoomModule.gameStatus == PdkGameStatus.ContendBanker then
    elseif PdkRoomModule.gameStatus == PdkGameStatus.Strat then
        --游戏开始 如果结算没有关闭 则关闭（弱网情况）
        if PanelManager.IsOpened(PdkPanelConfig.SingleRecord) then
            PanelManager.Close(PdkPanelConfig.SingleRecord)
        end
        -- --如果是分数场
        -- if PdkRoomModule.IsGoldRoom() then
        --     PanelManager.Close(PanelConfig.GoldMatch)
        -- end
        --更新游戏局数
        PdkRoomPanel.SetRoomRound(PdkRoomModule.nowjs, PdkRoomModule.maxjs)
        --游戏开始 关闭GPS界面
        SendEvent(CMD.Game.RoomGpsReadyFinished)
        -- --游戏开始 隐藏开始按钮
        -- PdkRoomPanel.ShowStartBtn(false)
        --隐藏玩家准备按钮
        for k, v in pairs(PdkRoomModule.players) do
            PdkRoomPanel.PlayerReady(k, false)
            PdkRoomPanel.ShowJoing(k, false)
        end
    elseif PdkRoomModule.gameStatus == PdkGameStatus.Result then
    elseif PdkRoomModule.gameStatus == PdkGameStatus.Over then
    end
end

--通知出牌
function PdkRoomCtrl.NoticeOutCard(data)
    PdkRoomPanel.ShowTiShiBtn(false)
    PdkRoomPanel.ShowOutCardBtn(false)
    PdkRoomPanel.ShowPassBtn(false)
    PdkRoomModule.isFirst = false
    local index = PdkRoomModule.GetPlayerLocalSeat(data.seatNum)
    -- local player = PdkRoomModule.GetPlayerInfoBySeat(index)
    if data.isShow == 1 then
        local time = 20
        if PdkRoomModule.IsGoldRoom() then
            time = data.countDown
        end
        PdkRoomPanel.ShowClock(true, index, time)
        if PdkRoomModule.IsSelfBySeat(data.seatNum) then
            PdkRoomModule.isFirst = data.isFirst == 1
            PdkRoomModule.isOutCard = true
            PdkRoomPanel.ShowTiShiBtn(not (PdkRoomModule.isFirst))
            PdkRoomPanel.ShowOutCardBtn(true)
            PdkRoomPanel.ShowPassBtn(not (PdkRoomModule.isBiChu) and not (PdkRoomModule.isFirst))
            -- PdkRoomModule.SetBiggerPoker(nil)
        end
        --如果有第一个出牌 则清掉桌面上的牌
        if data.isFirst == 1 then
            PdkRoomModule.pokerTypeMsg = { PdkPokerType.None }
            PdkRoomPanel.HideTableCard()
        end
    end
end

--显示玩家文本说话
function PdkRoomCtrl.ShowTalkText(playerId, duration, str)
    --根据ID获取玩家座位号
    local index = PdkRoomModule.GetPlayerSeatById(playerId)
    --对应座位号显示文本
    PdkRoomPanel.ShowTalkText(index, true, str)
    Scheduler.scheduleOnceGlobal(
            function()
                PdkRoomPanel.ShowTalkText(index, false)
            end,
            duration
    )
end

--开始播放语音
function PdkRoomCtrl.ShowChatVoiceBubble(playerId, duration)
    --根据ID获取玩家座位号
    local index = PdkRoomModule.GetPlayerSeatById(tonumber(playerId))
    --对应座位号显示语音气泡
    PdkRoomPanel.ShowTalkEff(index, true)
    Scheduler.scheduleOnceGlobal(
            function()
                PdkRoomPanel.ShowTalkEff(index, false)
            end,
            duration
    )
end

--玩家出牌
function PdkRoomCtrl.PlayerOutCard(data)
    PdkRoomPanel.ShowClock(false)
    --显示玩家出的牌
    local index = PdkRoomModule.GetPlayerLocalSeat(data.seatNum)
    --显示打出的牌
    PdkRoomPanel.PlayerOutCard(index, data.pokers)
    --更新手牌
    PdkRoomPanel.UpdateCardNum(index, data.pokerNum)
    --播放特效
    PdkRoomPanel.PlayEffect(index, data.pokerTypeMsg[1])
    local value = nil
    if data.pokerTypeMsg[1] == PdkPokerType.Single or data.pokerTypeMsg[1] == PdkPokerType.Double then
        value = PdkPokerLogic.GetIdPoint(data.pokers[1])
    end
    --播放音效
    local playerData = PdkRoomModule.GetPlayerInfoBySeat(index)
    if playerData ~= nil then
        PdkAudioCtrl.PlayCardSound(playerData.playerSex, data.pokerTypeMsg[1], value)
        --播放报单音效
        if data.pokerNum == 1 then
            PdkAudioCtrl.PlayBaoDan(playerData.playerSex)
        end
    else
        LogError("玩家信息不存在：", index)
    end
    PdkRoomModule.pokerTypeMsg = data.pokerTypeMsg
    PdkRoomModule.SetBiggerPokers(data.pokerTypeMsg, PdkSelfHandCardCtrl.GetHandPokers())
    --自己出牌则隐藏按钮
    if PdkRoomModule.IsSelfBySeat(data.seatNum) then
        PdkRoomModule.isFirst = false
        PdkRoomModule.isOutCard = false
        PdkRoomPanel.ShowTiShiBtn(false)
        PdkRoomPanel.ShowOutCardBtn(false)
        PdkRoomPanel.ShowPassBtn(false)
    end
end

--玩家过牌
function PdkRoomCtrl.PlayerPassCard(data)
    PdkRoomPanel.ShowClock(false)
    local index = PdkRoomModule.GetPlayerLocalSeat(data.seatNum)
    local playerData = PdkRoomModule.GetPlayerInfoBySeat(index)
    PdkRoomPanel.ShowPass(index, true)
    if playerData ~= nil then
        PdkAudioCtrl.PlayPass(playerData.playerSex)
    else
        LogError("玩家信息不存在：", index)
    end
    if PdkRoomModule.IsSelfBySeat(data.seatNum) then
        PdkRoomPanel.ShowTiShiBtn(false)
        PdkRoomPanel.ShowOutCardBtn(false)
        PdkRoomPanel.ShowPassBtn(false)
    end
end

--退出房间
function PdkRoomCtrl.ExitRoom()
    local args = { gameType = GameType.PaoDeKuai }
    if PdkRoomModule.isPlayback then
        args.openType = DefaultOpenType.Record
        args.recordType = PdkRoomModule.recordType
        if PdkRoomModule.recordType == 2 then
            args.groupId = PdkRoomModule.groupId
        end
    else
        -- PdkRoomCtrl.StopCheckGps()
        args.openType = PdkRoomModule.roomType
        args.groupId = PdkRoomModule.groupId
        args.playWayType = PdkRoomModule.playWayType
    end
    GameSceneManager.SwitchGameScene(GameSceneType.Lobby, GameType.PaoDeKuai, args)
end

--创建玩家手牌
function PdkRoomCtrl.CreateRemainPoker(data)
    PdkRoomPanel.HideTableCard()
    local zhaNiao = nil
    local index = nil
    --给每个玩家发牌
    local info = nil
    for i = 1, #data.list do
        info = data.list[i]
        index = PdkRoomModule.GetPlayerLocalSeat(info.seatNum)
        if info.isZhaNiao == 1 then
            zhaNiao = index
        end
        if index ~= 1 then
            PdkRoomPanel.CreateRemainPoker(index, info.pokers)
        end
    end
    if not IsNil(zhaNiao) then
        PdkRoomPanel.ShowZhaNiao(zhaNiao, true)
    end
end

function PdkRoomCtrl.PlayerSeePoker()
    if PdkRoomModule.isSeePoker then
        PdkSelfHandCardCtrl.ShowPoker()
    end
end

--更新站点显示
function PdkRoomCtrl.UpdateLine()
    PdkRoomPanel.SetVersionAndLine()
end

--结算初始化信息
function PdkRoomCtrl.Clear()
    PdkRoomPanel.Clear()
    PdkSelfHandCardCtrl.Clear()
    PdkEffectCtrl.ClearEff()
end

function PdkRoomCtrl.Reset()
    --重置房间UI
    PdkRoomPanel.Reset()
end
---------------------------------------按钮的绑定事件-------------------------------------------
--玩家准备
function PdkRoomCtrl.OnReadyClick()
    PdkRoomModule.SendPlayerReady()
end

--解散或退出房间发送消息
function PdkRoomCtrl.OnExitRoomClick()
    if PdkRoomModule.IsStart() then
        Alert.Prompt(
                "正在游戏中，是否解散房间？",
                function()
                    PdkRoomModule.SendDissolveRoom()
                end
        )
    else
        local tip = ""
        if PdkRoomModule.IsOwner() and not PdkRoomModule.IsClubRoom() then
            tip = "是否解散房间？"
        else
            tip = "是否退出房间？"
        end
        Alert.Prompt(
                tip,
                function()
                    PdkRoomModule.SendExitRoom()
                end
        )
    end
end

--设置面板
function PdkRoomCtrl.OnSettingClick()
    PanelManager.Open(PdkPanelConfig.Setup)
end

--规则面板
function PdkRoomCtrl.OnRuleClick()
    PanelManager.Open(PdkPanelConfig.Rule)
end

--GPS面板
function PdkRoomCtrl.OnGpsClick()
    PanelManager.Open(PanelConfig.RoomGps, PdkRoomModule.GetGpsData())
end

--复制房号
function PdkRoomCtrl.OnCopyBtnClick()
    local strData = Functions.ParseGameRule(GameType.PaoDeKuai, PdkRoomModule.rules, " ")
    local text = "【九洲悟空竞技麻将】房间号：" .. PdkRoomModule.roomId
    text = text .. "，跑得快，游戏：" .. strData.playWayName
    text = text .. "，局数：" .. strData.juShuTxt
    text = text .. "，玩法：" .. strData.rule .. "，等你来挑战"
    AppPlatformHelper.CopyText(text)
    PanelManager.Open(PanelConfig.RoomCopy)
end

--邀请按钮
function PdkRoomCtrl.OnInviteBtnClick()
    local strData = Functions.ParseGameRule(GameType.PaoDeKuai, PdkRoomModule.rules, " ")
    local text = "跑得快，游戏：" .. strData.playWayName
    text = text .. "，局数：" .. strData.juShuTxt
    text = text .. "，玩法：" .. strData.rule .. "，等你来挑战"
    local data = {
        roomCode = PdkRoomModule.roomId,
        title = "【九洲悟空竞技麻将】房间号：" .. PdkRoomModule.roomId,
        content = text,
        type = 1
    }
    PanelManager.Open(PanelConfig.RoomInvite, data)
end

--提示按钮
function PdkRoomCtrl.OnTipsClick()
    if IsNil(PdkRoomModule.tipPokers) or GetTableSize(PdkRoomModule.tipPokers) == 0 then
        return
    end
    PdkSelfHandCardCtrl.DownHandPokers()
    local bigLenght = #PdkRoomModule.tipPokers
    PdkRoomModule.tipIndex = PdkRoomModule.tipIndex + 1
    if PdkRoomModule.tipIndex > bigLenght then
        PdkRoomModule.tipIndex = 1
    end
    PdkRoomCtrl.UpHandPokers(PdkRoomModule.tipPokers[PdkRoomModule.tipIndex])
end

--点击切换房间
function PdkRoomCtrl.OnChangeRoomClick()
    if PdkRoomModule.IsClubRoom() then
        local args = {
            clubId = PdkRoomModule.groupId,
            roomId = PdkRoomModule.roomId,
            ruleString = ObjToJson(PdkRoomModule.rules),
            gameType = GameType.PaoDeKuai,
            returnToLobbyCallback = this.ExitRoom,
            quitRoomCallback = PdkRoomModule.SendExitRoom
        }
        PanelManager.Open(PanelConfig.RoomChange, args)
    else
        Log("非亲友圈房间，不能打开")
    end
end

--玩家显示项点击
function PdkRoomCtrl.OnPlayerItemClick(index)
    if PdkRoomModule.isPlayback then
        return
    end

    local playerData = PdkRoomModule.players[index]
    if playerData == nil then
        LogError(">>>>>> PdkRoomCtrl > OnPlayerItemClick > playerData is nil")
        return
    end

    local limitScore = 0
    if PdkRoomModule.IsGoldRoom() then
        limitScore = PdkRoomModule.GetRule(PdkRuleType.ZhunRu)
    end

    local arg = {
        name = playerData.playerName, --姓名
        sex = playerData.playerSex, --性别 1男 2 女
        id = playerData.playerId, --玩家id
        gold = playerData.score,
        limitScore = limitScore, --分数场准入分数
        moneyType = PdkRoomModule.moneyType, --货币类型
        headUrl = playerData.playerHead, --头像链接
        headFrame = playerData.playerTxk, --头像框
        address = GPSModule.GetGpsDataByPlayerId(playerData.playerId).address
    }
    LogError(" 跑得快--游戏内不显示点击玩家头像界面 ")
    -- ChatModule.OpenRoomUserInfoPanel(arg)
end

--弹起扑克
function PdkRoomCtrl.UpHandPokers(pokers)
    PdkSelfHandCardCtrl.UpHandPokers(pokers)
end

local function getFeiJiDaiDuiMin(pokersValue)
    -- 取3张的牌
    local feiji = {}
    local last_add = 0
    for i = 1, #pokersValue - 2 do
        if PdkPokerLogic.GetIdWeight(pokersValue[i]) == PdkPokerLogic.GetIdWeight(pokersValue[i + 2]) then
            if last_add ~= PdkPokerLogic.GetIdWeight(pokersValue[i]) then
                last_add = PdkPokerLogic.GetIdWeight(pokersValue[i])
                table.insert(feiji, PdkPokerLogic.GetIdWeight(pokersValue[i]))
            end
        end
    end

    local need = #pokersValue / 5
    for i = 1, #feiji do
        if feiji[i] == feiji[i + need - 1] + need - 1 then
            return feiji[i + need - 1]
        end
    end
    return 0;
end


--出牌
function PdkRoomCtrl.OnOutCardClick()
    if os.time() - PdkRoomModule.lastSendTime < this.intervalTime then
        Toast.Show("请不要频繁点击")
        return
    end
    PdkRoomModule.lastSendTime = os.time()
    local pokers = PdkSelfHandCardCtrl.GetAllUpPoker()
    --table.sort(
    --    pokers,
    --    function(a, b)
    --        return a.weight < b.weight
    --    end
    --)
    local values = {}
    for i = 1, #pokers do
        table.insert(values, pokers[i].value)
    end
    PdkPokerLogic.SortIdsShengXu(values)
    local pokerType = PdkPokerLogic.CalculatePokerType(values)
    LogError("+++++++++++++++++++++++++++++跑得快牌型为", pokerType)
    PdkPokerLogic.SortIdsJiangXu(values)
    local daPokerType = {}
    if not PdkPokerLogic.IsPdkPokerType(pokerType) then
        Toast.Show(PdkErrorMessage[PdkErrorCode.YOU_NOT_SHOW_THIS])
        return
    end
    local lenght = GetTableSize(values)
    table.insert(daPokerType, pokerType)
    if (pokerType == PdkPokerType.Single or pokerType == PdkPokerType.Double or pokerType == PdkPokerType.Three or pokerType == PdkPokerType.Four) then
        table.insert(daPokerType, PdkPokerLogic.GetIdWeight(values[1]))
    elseif (pokerType == PdkPokerType.Straight or pokerType == PdkPokerType.DoubleStraight or pokerType == PdkPokerType.Airplane) then
        -- table.insert(daPokerType, pokerType)
        table.insert(daPokerType, PdkPokerLogic.GetIdWeight(values[lenght]))
        if pokerType == PdkPokerType.DoubleStraight then
            lenght = math.floor(lenght / 2)
        elseif pokerType == PdkPokerType.Airplane then
            lenght = math.floor(lenght / 3)
        end
        table.insert(daPokerType, lenght)
    elseif (pokerType == PdkPokerType.Bomb) then
        -- table.insert(daPokerType, pokerType)
        if PdkPokerLogic.GetIdWeight(values[1]) ~= PdkPoker.PdkPokerWeight.One then
            table.insert(daPokerType, PdkPokerLogic.GetIdWeight(values[1]))
            table.insert(daPokerType, lenght)
        else ---此次3A炸弹为最大
            table.insert(daPokerType, PdkPokerLogic.GetIdWeight(values[1]))
            table.insert(daPokerType, lenght + 1)
        end
    elseif (pokerType == PdkPokerType.ThreeAndTwo or pokerType == PdkPokerType.BombAndDouble) then
        table.insert(daPokerType, PdkPokerLogic.GetIdWeight(values[3]))
        table.insert(daPokerType, 1)
    elseif (pokerType == PdkPokerType.BombAndThree) then
        table.insert(daPokerType, PdkPokerLogic.GetIdWeight(values[4]))
        table.insert(daPokerType, 1)
    elseif (pokerType == PdkPokerType.AirplaneAndTwo) then
        table.insert(daPokerType, getFeiJiDaiDuiMin(values))
        table.insert(daPokerType, lenght / 5)
    end
    if not PdkPokerLogic.ComparPokerType(PdkRoomModule.pokerTypeMsg, daPokerType) then
        Toast.Show(PdkErrorMessage[PdkErrorCode.YOU_NOT_SHOW_THIS])
        return
    end

    --判断是否是黑桃五先出
    if PdkRoomModule.IsHeiWuFirstOut() then
        local isHave = false
        --检测是否有黑桃五
        for i = 1, #values do
            if values[i] == 53 then
                isHave = true
                break
            end
        end
        if not isHave then
            Toast.Show(PdkErrorMessage[PdkErrorCode.MUST_SHOW_POKER])
            return
        end
    end
    --判断是否是黑桃三先出
    if PdkRoomModule.IsHeiSanFirstOut(values) then
        local isHave = false
        --检测是否有黑桃三
        for i = 1, #values do
            if values[i] == 33 then
                isHave = true
                break
            end
        end
        if not isHave then
            Toast.Show(PdkErrorMessage[PdkErrorCode.MUST_SHOW_POKER])
            return
        end
    end
    --判断下家是否是报单 并且 自己出的单牌
    if PdkRoomModule.IsBaoDan() and pokerType == PdkPokerType.Single then
        if not PdkSelfHandCardCtrl.IsSelfMaxSinglePoker(values[1]) then
            Toast.Show(PdkErrorMessage[PdkErrorCode.NEXT_ONE_POKER])
            return
        end
    end
    --判断是否是乐山跑得快 并且 炸弹是否可拆
    if PdkRoomModule.IsLSGame() then
        local isChai = PdkPokerLogic.CheckChaiZhaDan(PdkSelfHandCardCtrl.GetHandPokers(), values)
        if not isChai then
            Toast.Show(PdkErrorMessage[PdkErrorCode.CAN_NOT_CHAI_BOOM])
            return
        end
    end
    if GetTableSize(values) > 0 then
        Log(">>>>>>>>>>>>>>PdkRoomCtrl.OnOutCardClick>>>>>>>>>>>>>>我出的牌", ObjToJson(values))
        PdkRoomModule.SendPlayerOutCard(pokerType, values)
        PdkRoomPanel.ShowClock(false)
        PdkRoomModule.isFirst = false
        PdkRoomModule.isOutCard = false
        PdkRoomPanel.ShowTiShiBtn(false)
        PdkRoomPanel.ShowOutCardBtn(false)
        PdkRoomPanel.ShowPassBtn(false)
        --显示打出的牌
        PdkRoomPanel.PlayerOutCard(1, values)
        --更新牌数
        PdkRoomPanel.UpdateCardNum(1, PdkSelfHandCardCtrl.GetHandPokerCount())
        --播放特效
        PdkRoomPanel.PlayEffect(1, pokerType)
        local value = nil
        if pokerType == PdkPokerType.Single or pokerType == PdkPokerType.Double then
            value = PdkPokerLogic.GetIdPoint(values[1])
        end
        --播放音效
        local playerData = PdkRoomModule.GetPlayerInfoBySeat(1)
        if playerData ~= nil then
            PdkAudioCtrl.PlayCardSound(playerData.playerSex, pokerType, value)
            --播放报单音效
            if PdkSelfHandCardCtrl.GetHandPokerCount() == 1 then
                PdkAudioCtrl.PlayBaoDan(playerData.playerSex)
            end
        else
            LogError("玩家信息不存在：", 1)
        end
    end
end

--玩家不要
function PdkRoomCtrl.OnPassClick()
    if os.time() - PdkRoomModule.lastSendTime < this.intervalTime then
        Toast.Show("请不要频繁点击")
        return
    end
    PdkRoomModule.lastSendTime = os.time()
    PdkRoomModule.SendPlayerPass()
end

--玩家取消托管
function PdkRoomCtrl.OnCancelOnHookClick()
    if os.time() - PdkRoomModule.lastSendTime < this.intervalTime then
        Toast.Show("请不要频繁点击")
        return
    end
    PdkRoomModule.lastSendTime = os.time()
    PdkRoomModule.SendCancelOnHook()
end

-- --获取GPS
-- function PdkRoomCtrl.StartCheckGps()
--     local funGps = function()
--         Log("开始获取GPS")
--         GpsHelper.Check(function(lat, lng)
--             if lat > 0.0001 or lng > 0.0001 then
--                 PdkRoomModule.SendGpsData(lat, lng)
--             end
--         end)
--     end
--     funGps()
--     this.StopCheckGps()
--     this.checkGps = Scheduler.scheduleGlobal(funGps, 120)
-- end

-- function PdkRoomCtrl.StopCheckGps()
--     Log("GPS Stop")
--     Scheduler.unscheduleGlobal(this.checkGps)
-- end
