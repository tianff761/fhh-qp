MahjongRoomPanel = ClassPanel("MahjongRoomPanel")
MahjongRoomPanel.Instance = nil
local this = MahjongRoomPanel

--初始属性数据
function MahjongRoomPanel:InitProperty()
    --是否初始化偏移
    this.isInitOffset = false
    --玩家显示对象
    this.playerItems = nil
    --是否可以点击语音按钮
    this.isCanClick = true
    --语音Y轴偏移量
    this.speechTouchY = 0
    --服务器时间Timer
    this.serverTimeTimer = nil
    --托管时间
    this.opertionTime = 90
    --最新更新托管时间
    this.lastUpdateOpertionTime = 0
    --保存的倒计时
    this.lastCountDown = nil
    --倒计时Timer
    this.operateCountDownTimer = nil
    --取消托管间隔时间
    this.cancelTrustInterval = 0
    --主玩家的托管状态
    this.mainPlayerTrust = 0
    --电量等级
    this.energyLevel = nil
    --是否为Wifi
    this.isWifi = nil
    --网络等级
    this.netLevel = nil
    --网络类型检测Timer
    this.checkNetTypeTimer = nil
    --打牌的玩家ID
    this.opPlayerId = nil
    --打牌的牌ID
    this.opCardId = nil
    --排名按钮点击时间
    this.rankingBtnClickTime = 0
end

--UI初始化
function MahjongRoomPanel:OnInitUI()
    this = self
    this:InitProperty()

    local tablecloth = this:Find("Tablecloth")
    this.tableclothImage = tablecloth:GetComponent(TypeImage)
    UIUtil.SetBackgroundAdaptation(tablecloth.gameObject)

    local effectNodeTrans = this:Find("EffectNode")
    this.centerEffectNode = effectNodeTrans:Find("CenterNode")

    --处理玩家显示项
    local playersTrans = this:Find("Players")
    this.playerItems = {}
    local playerTrans = nil
    local playerItem = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerTrans = playersTrans:Find(tostring(i))
        playerItem = MahjongPlayerItem.New()
        playerItem:SetRoot(i, playerTrans)
        --特殊处理播放特效的节点
        playerItem.effectNodeTrans = effectNodeTrans:Find("Node" .. i)
        this.playerItems[i] = playerItem
    end
    local moveMasterTrans = playersTrans:Find("MoveMasterIcon")
    this.moveMasterPosition = moveMasterTrans.localPosition
    this.moveMasterGO = moveMasterTrans.gameObject

    --设置打牌节点
    MahjongPlayCardMgr.SetRoot(this.transform)

    -- --设置麻将牌图集
    -- local spriteAtlas = this:Find("CardAtlas"):GetComponent("UISpriteAtlas")
    -- MahjongResourcesMgr.SetCardSprites(spriteAtlas.sprites)

    --设置麻将牌图集  --最新版资源
    local spriteAtlas = this:Find("CardAtlas"):GetComponent("UISpriteAtlas")
    MahjongResourcesMgr.SetCardSprites(spriteAtlas.sprites)

    --设置麻将牌底框图集  --最新版资源
    local frameAtlas = this:Find("CardFrameAtlas"):GetComponent("UISpriteAtlas")
    MahjongResourcesMgr.SetCardFrameSprite(frameAtlas.sprites)
    

    --设置房间Icon图集
    spriteAtlas = this:Find("Atlas"):GetComponent("UISpriteAtlas")
    MahjongResourcesMgr.SetSprites(spriteAtlas.sprites)
    --注意名字不要出现相同的
    spriteAtlas = this:Find("RoomAtlas"):GetComponent("UISpriteAtlas")
    MahjongResourcesMgr.SetSprites(spriteAtlas.sprites)

    --按钮
    local buttonGroupTrans = this:Find("ButtonGroup")

    local center = buttonGroupTrans:Find("Center")
    this.copyBtn = center:Find("CopyBtn").gameObject
    this.inviteBtn = center:Find("InviteBtn").gameObject
    --this.backBtn = center:Find("BackBtn").gameObject
    this.changeBtn = center:Find("ChangeBtn").gameObject
    --
    this.topRight = buttonGroupTrans:Find("TopRight")

    this.gpsBtn = this.topRight:Find("GpsBtn").gameObject
    --
    this.bottomRight = buttonGroupTrans:Find("BottomRight")
    this.rankingBtn = this.bottomRight:Find("RankingBtn").gameObject
    this.huTipsBtn = this.bottomRight:Find("HuTipsBtn").gameObject
    this.chatBtn = this.bottomRight:Find("ChatBtn").gameObject
    this.speechBtn = this.bottomRight:Find("SpeechBtn").gameObject
    this.rulesBtn = this.bottomRight:Find("RulesBtn").gameObject

    --左上角信息
    this.stateInfoTrans = this.transform:Find("StateInfo")
    this.energyValueGO = this.stateInfoTrans:Find("Energy/Value").gameObject
    this.energyValueImage = this.energyValueGO:GetComponent(TypeImage)
    this.energyNoActiveGO = this.stateInfoTrans:Find("EnergyNoActive").gameObject
    this.timeTxt = this.stateInfoTrans:Find("TimeTxt"):GetComponent(TypeText)

    --左上角信息布局
    this.leftInfoLayout = this.transform:Find("LeftInfoLayout")
    this.setupBtn = this.leftInfoLayout:Find("SetupBtn").gameObject
    --房间信息
    local roomInfoTrans = this.leftInfoLayout:Find("RoomInfo")
    this.roomInfoTrans = roomInfoTrans
    this.roomCodeTxt = roomInfoTrans:Find("RoomCodeTxt"):GetComponent(TypeText)
    this.multipleTxt = roomInfoTrans:Find("MultipleText"):GetComponent(TypeText)
    this.totalTxt = roomInfoTrans:Find("TotalText"):GetComponent(TypeText)
    --
    this.surplus = this.leftInfoLayout:Find("Surplus")
    this.surplusTxt = this.leftInfoLayout:Find("Surplus/Text"):GetComponent(TypeText)


    --信号和Ping值
    this.iconSignalTran = this.stateInfoTrans:Find("IconSignal")
    this.iconSignalValueGO = this.iconSignalTran:Find("IconSignalValue").gameObject
    this.iconSignalValueSpriteAtlas = this.iconSignalValueGO:GetComponent("UISpriteAtlas")
    this.iconSignalValueImage = this.iconSignalValueGO:GetComponent(TypeImage)

    this.iconWifiTran = this.stateInfoTrans:Find("IconWifi")
    this.iconWifiValueGO = this.iconWifiTran:Find("IconWifiValue").gameObject
    this.iconWifiValueGOSpriteAtlas = this.iconWifiValueGO:GetComponent("UISpriteAtlas")
    this.iconWifiValueImage = this.iconWifiValueGO:GetComponent(TypeImage)

    this.pingTxt = this.stateInfoTrans:Find("PingTxt"):GetComponent(TypeText)

    --房间提示信息，主要是显示版本号和线路
    this.tipsInfo = this:Find("TipsInfo")
    this.tipsTxt = this.tipsInfo:Find("TipsTxt"):GetComponent(TypeText)
    --打出牌的箭头
    this.arrow = this:Find("Animation/Arrow").gameObject
    --牌桌中间信息
    local directionTrans = this:Find("Direction")
    this.timePoints = {}
    this.timePointsTweener = {}
    for i = 1, 4 do
        local temp = directionTrans:Find("TimePoint" .. i).gameObject
        this.timePoints[i] = temp
        this.timePointsTweener[i] = temp:GetComponent("TweenAlpha")
    end
    this.redImage = directionTrans:Find("RedImage").gameObject
    this.timeImage1 = directionTrans:Find("TimeImage1"):GetComponent("Image")
    this.timeImage2 = directionTrans:Find("TimeImage2"):GetComponent("Image")
    --房间规则
    this.ruleText = directionTrans:Find("RuleText"):GetComponent(TypeText)

    --托管
    local trustTrans = this:Find("Trust")
    this.trustGO = trustTrans.gameObject
    this.trustTxt = trustTrans:Find("Text"):GetComponent(TypeText)
    this.trustCancelBtn = trustTrans:Find("CancelButton").gameObject

    --艺术字
    local fontsTrans = this:Find("Fonts")
    local decrease = fontsTrans:Find("Decrease")
    local increase = fontsTrans:Find("Increase")
    MahjongGlobal.FontDecrease = decrease:GetComponent(TypeText).font
    MahjongGlobal.FontIncrease = increase:GetComponent(TypeText).font

    ---末尾杠选牌（飞小鸡特殊玩法）
    this.LastShowCardTrans = this:Find("LastShowCard")
    this.LastShowCardImg1 = this.LastShowCardTrans:Find("Card1/CardIcon"):GetComponent("ShapeImage")
    this.LastShowCardImg2 = this.LastShowCardTrans:Find("Card2/CardIcon"):GetComponent("ShapeImage")

    this.AddUIListenerEvent()

    --设置UI的偏移
    --this.CheckAndUpdateUIOffset()
end


--当面板开启时
function MahjongRoomPanel:OnOpened(argsData)
    MahjongRoomPanel.Instance = self
    this.AddListenerEvent()
    --听牌提示
    MahjongDataMgr.isTingTips = MahjongUtil.GetTingPaiTiShi()

    --更新固定显示
    this.UpdateRoomDisplay()
    --更新按钮显示
    this.UpdateButtonDisplayByOpend()
    --服务器时间
    this.CheckUpdateServerTime()
    --网络相关
    this.CheckUpdateNetPing()
    --开始获取当前电量
    AppPlatformHelper.StartGetBatteryStateOnRoom()
    --初始化聊天管理器
    this.InitChatManager()
    
    --通知Room面板已经打开
    SendEvent(CMD.Game.Mahjong.DeskPanelOpened)
end

--当面板关闭时调用
function MahjongRoomPanel:OnClosed()

    --LogError(2)

    --
    MahjongRoomPanel.Instance = nil
    --停止获取电量
    AppPlatformHelper.StopGetBatteryStateOnRoom()
    --聊天管理器卸载
    ChatModule.UnInit()

    --
    this.RemoveListenerEvent()
    this.StopServerTimeTimer()
    this.StopOperateCountDownTimer()
    this.StopCheckNetTypeTimer()
    this.Reset()
end

------------------------------------------------------------------
--
function MahjongRoomPanel.AddListenerEvent()
    --电量监听
    AddEventListener(CMD.Game.BatteryState, this.OnBatteryState)
    AddEventListener(CMD.Game.Ping, this.OnNetPing)
end
--
function MahjongRoomPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Game.BatteryState, this.OnBatteryState)
    RemoveEventListener(CMD.Game.Ping, this.OnNetPing)
end

--UI相关事件
function MahjongRoomPanel.AddUIListenerEvent()
    this:AddOnClick(this.setupBtn, this.OnSetupBtnClick)
    this:AddOnClick(this.gpsBtn, this.OnGpsBtnClick)
    this:AddOnClick(this.rankingBtn, this.OnRankingBtnClick)
    this:AddOnClick(this.huTipsBtn, this.OnHuTipsBtnClick)
    this:AddOnClick(this.rulesBtn, this.OnRulesBtnClick)
    this:AddOnClick(this.inviteBtn, this.OnInviteBtnClick)
    this:AddOnClick(this.copyBtn, this.OnCopyBtnClick)
    this:AddOnClick(this.changeBtn, this.OnChangeBtnClick)
    this:AddOnClick(this.trustCancelBtn, this.OnTrustCancelBtnClick)
    --
    --注册语音事件
    ChatModule.RegisterVoiceEvent(this.speechBtn)
    --注册聊天按钮
    ChatModule.RegisterChatTextEvent(this.chatBtn)
    for i = 1, 4 do
        this:AddOnClick(this.playerItems[i].headBtn, HandlerArgs(this.OnPlayerItemClick, i))
    end
end
------------------------------------------------------------------
--
--根据屏幕是否为2比1设置偏移
function MahjongRoomPanel.CheckAndUpdateUIOffset()
    if this.isInitOffset == false then
        this.isInitOffset = true

        local offsetX = Global.GetOffsetX()

        --玩家头像偏移
        UIUtil.AddAnchoredPositionX(this.playerItems[1].nodeGO, offsetX)
        UIUtil.AddAnchoredPositionX(this.playerItems[2].nodeGO, -offsetX)
        UIUtil.AddAnchoredPositionX(this.playerItems[3].nodeGO, -offsetX)
        UIUtil.AddAnchoredPositionX(this.playerItems[4].nodeGO, offsetX)

        --左上角信息
        UIUtil.AddAnchoredPositionX(this.roomInfoTrans, offsetX)
        UIUtil.AddAnchoredPositionX(this.stateInfoTrans, offsetX)

        --右上角信息
        UIUtil.AddAnchoredPositionX(this.tipsInfo, offsetX)

        --右边的按钮组
        UIUtil.AddAnchoredPositionX(this.topRight, -offsetX)
        UIUtil.AddAnchoredPositionX(this.bottomRight, -offsetX)
    end
end

------------------------------------------------------------------
--内部重置
function MahjongRoomPanel.InternalReset()
    --关闭一些UI
    this.HideOutCardArrow()
    this.StopOperateCountDown()
    this.StopCheckPlayerHuTimer()
    UIUtil.SetActive(this.moveMasterGO, false)
    this.mainPlayerTrust = 0
    this.surplusTxt.text = "0"
    UIUtil.SetActive(this.huTipsBtn, false)
    UIUtil.SetActive(this.trustGO, false)
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        this.playerItems[i]:Reset()
    end
end

--界面重置，用于结算处理
function MahjongRoomPanel.Reset()
    this.InternalReset()
end

--匹配清除信息
function MahjongRoomPanel.ClearByMatch()
    this.multipleTxt.text = ""
    this.totalTxt.text = ""
    --玩家1不处理
    for i = 2, Mahjong.ROOM_MAX_PLAYER_NUM do
        this.playerItems[i]:Clear()
    end
end

--界面清除
function MahjongRoomPanel.Clear()
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        this.playerItems[i]:Clear()
    end
end

--更新桌布
function MahjongRoomPanel.UpdateTablecloth(id)
    if id == nil then
        id = MahjongUtil.GetTableclothId()
    end

    LogError(" 当前桌布最新资源只有一张，暂不支持更换 ")
    local sprite = MahjongResourcesMgr.GetSprite("MahjongDeskBackground" .. id)
    if sprite ~= nil then
        -- this.tableclothImage.sprite = sprite
    end
end

--牌局规则 --隐藏不显示
function MahjongRoomPanel.UpdateRule()
    -- local ruleInfoData = Mahjong.ParseMahjongRule(MahjongDataMgr.rules, MahjongDataMgr.gpsType)
    -- this.ruleText.text = ruleInfoData.rule
end


------------------------------------------------------------------
--
--电量设置
function MahjongRoomPanel.OnBatteryState(value)
    this.UpdateEnergyValue(value)
end

--网络Ping值更新
function MahjongRoomPanel.OnNetPing(value)
    this.UpdateNetPing(value)
end

------------------------------------------------------------------
--
function MahjongRoomPanel.OnSetupBtnClick()
    PanelManager.Open(MahjongPanelConfig.Setup)
end

--
function MahjongRoomPanel.OnGpsBtnClick()
    PanelManager.Open(PanelConfig.RoomGps, MahjongUtil.GetGpsPanelData())
end

--
function MahjongRoomPanel.OnRankingBtnClick()
    if Time.realtimeSinceStartup - this.rankingBtnClickTime < 2 then
        Toast.Show("请稍后...")
        return
    end
    this.rankingBtnClickTime = Time.realtimeSinceStartup
    MahjongCommand.SendMatchScore()
end

--
function MahjongRoomPanel.OnHuTipsBtnClick()
    if MahjongDataMgr.IsTingTips() and MahjongDataMgr.HuTips.huData ~= nil then
        PanelManager.Open(MahjongPanelConfig.HuTips, MahjongDataMgr.HuTips.huData)
    end
end
--
function MahjongRoomPanel.OnRulesBtnClick()
    PanelManager.Open(MahjongPanelConfig.Rule)
end
--
function MahjongRoomPanel.OnInviteBtnClick()
    local strData = Functions.ParseGameRule(GameType.Mahjong, MahjongDataMgr.rules, MahjongDataMgr.gpsType, " ")
    local text = "幺鸡麻将，游戏：" .. strData.playWayName
    text = text .. "，局数：" .. strData.juShuTips
    text = text .. "，玩法：" .. strData.rule .. "，等你来挑战"
    local data = {
        roomCode = MahjongDataMgr.roomId,
        title = "【幺鸡麻将游戏】房间号：" .. MahjongDataMgr.roomId,
        content = text,
        type = 1
    }
    PanelManager.Open(PanelConfig.RoomInvite, data)
end
--
function MahjongRoomPanel.OnCopyBtnClick()
    local strData = Functions.ParseGameRule(GameType.Mahjong, MahjongDataMgr.rules, MahjongDataMgr.gpsType, " ")
    local text = "【幺鸡麻将游戏】房间号：" .. MahjongDataMgr.roomId
    text = text .. "，幺鸡麻将，游戏：" .. strData.playWayName
    text = text .. "，局数：" .. strData.juShuTips
    text = text .. "，玩法：" .. strData.rule .. "，等你来挑战"
    AppPlatformHelper.CopyText(text)
    PanelManager.Open(PanelConfig.RoomCopy)
end

--亲友圈换房间
function MahjongRoomPanel.OnChangeBtnClick()
    if MahjongDataMgr.roomType == RoomType.Club then
        local args = {
            clubId = MahjongDataMgr.groupId,
            roomId = MahjongDataMgr.roomId,
            ruleString = ObjToJson(MahjongDataMgr.rules),
            gameType = GameType.Mahjong,
            returnToLobbyCallback = MahjongRoomMgr.ExitRoom,
            quitRoomCallback = MahjongCommand.SendQuitRoom
        }
        PanelManager.Open(PanelConfig.RoomChange, args)
    else
        Log(">> MahjongRoomPanel.OnChangeBtnClick > Not Club")
    end
end

--托管取消
function MahjongRoomPanel.OnTrustCancelBtnClick()
    if Time.realtimeSinceStartup - this.cancelTrustInterval < 0.8 then
        return
    end
    this.cancelTrustInterval = Time.realtimeSinceStartup
    MahjongCommand.SendCancelTrust()
end


--玩家显示项点击
function MahjongRoomPanel.OnPlayerItemClick(index)
    if MahjongDataMgr.isPlayback then
        return
    end

    local playerData = MahjongDataMgr.playerDatas[index]
    --Log("==========OnPlayerItemClick====", playerData)
    if playerData == nil then
        LogError(">> MahjongRoomPanel > OnPlayerItemClick > playerData is nil")
        return
    end

    --获取分数场准入
    local limitScore = 0
    if MahjongDataMgr.IsGoldRoom() then
        limitScore = tonumber(MahjongDataMgr.zhunru)
        if limitScore == nil then
            limitScore = 0
        end
    end

    local arg = {
        name = playerData.name, --姓名
        sex = playerData.gender, --性别 1男 2 女
        id = playerData.id, --玩家id
        gold = playerData.gold,
        limitScore = limitScore, --分数场准入分数
        moneyType = MahjongDataMgr.moneyType, --货币类型
        headUrl = playerData.headUrl, --头像链接
        headFrame = playerData.headFrame, --头像框
        address = GPSModule.GetGpsDataByPlayerId(playerData.id).address
    }
    
    LogError(" 麻将--游戏内不显示点击玩家头像界面 ")
    -- PanelManager.Open(PanelConfig.RoomUserInfo, arg)
end

------------------------------------------------------------------
--更新房间显示
function MahjongRoomPanel.UpdateRoomDisplay()
    if MahjongDataMgr.isPlayback then
        this.tipsTxt.text = ""
    else
        local lineStr = nil
        if MahjongDataMgr.serverLine == nil then
            lineStr = "0"
        else
            lineStr = math.floor(MahjongDataMgr.serverLine % 100)
            if lineStr < 10 then
                lineStr = tostring(lineStr)
            else
                lineStr = tostring(lineStr)
            end
        end

        local temp = "" .. Functions.GetResVersionStr(GameType.Mahjong)
        temp = temp .. "." .. lineStr
        this.tipsTxt.text = temp
    end
end

--外部调用
--进入房间更新房间信息显示
function MahjongRoomPanel.UpdateRoomByJoinRoom()
    this.roomCodeTxt.text = tostring(MahjongDataMgr.roomId)
    this.multipleTxt.text = MahjongDataMgr.multiple .. "番"
    this.surplusTxt.text = "0"
    --更新桌布
    this.UpdateTablecloth()
    this.InternalUpdateGameIndex()
    this.UpdateButtonDisplay()
    this.CheckUpdateServerTime()
    this.UpdatePlayerScoreDisplay()
    this.UpdateRule()
    --更新玩家显示
    this.UpdatePlayerDisplay()
    --设置托管
    -- if MahjongDataMgr.playerTotal == 2 then
    --     this.trustTxt.text = "无操作60秒将进入托管，自动打牌"
    -- else
    --     this.trustTxt.text = "无操作60秒将进入托管，5秒自动打牌，若多次进入托管，时间将会递减"
    -- end
end

--游戏开始更新房间信息显示
function MahjongRoomPanel.UpdateRoomByGameBegin()
    this.roomCodeTxt.text = tostring(MahjongDataMgr.roomId)
    this.InternalUpdateGameIndex()
    this.UpdateSurplusCards()
    this.UpdateButtonDisplay()
    this.UpdatePlayerDisplayByGameBegin()
    this.UpdateMainPlayerTrust()
    --比赛
    if MahjongDataMgr.IsMatchRoom() and MahjongDataMgr.isAllReady then
        MahjongDataMgr.isAllReady = false
        local index = tonumber(MahjongDataMgr.gameIndex)
        PanelManager.Open(MahjongPanelConfig.JushuTips, index)
    end
end

--更新操作相关的显示，包括定缺、剩余牌、Table状态、胡牌
function MahjongRoomPanel.UpdateRoomByOperate()
    this.UpdateSurplusCards()
    local isNewHu = false
    local playerData = nil
    local playerItem = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerData = MahjongDataMgr.playerDatas[i]
        playerItem = this.playerItems[i]
        if playerItem ~= nil and playerData ~= nil then
            --更新Table状态
            this.UpdatePlayerTableStateBySingle(playerItem, playerData)
            this.UpdatePlayerTrustBySingle(playerItem, playerData)
            --检测是否有新的胡牌
            if isNewHu == false then
                isNewHu = this.CheckPlayerNewHuBySingle(playerItem, playerData)
            end
        end
    end
    --处理定缺
    this.CheckAndUpdateDingQue()

    if MahjongDataMgr.isPlayback then
        --
    else
        --处理主玩家托管
        this.UpdateMainPlayerTrust()
    end

    if isNewHu then
        this.StartCheckPlayerHuTimer()
    else
        this.UpdatePlayerHuDisplay()
    end
end

--更新剩余牌
function MahjongRoomPanel.UpdateSurplusCards()
    local surplus = tonumber(MahjongDataMgr.surplusCards)
    if surplus == nil then
        surplus = 0
    end
    --this.surplusTxt.text = "剩" .. tostring(surplus) .. "张"
    this.surplusTxt.text = tostring(surplus)
end

--更新玩家显示，在游戏没有开始的时候更新使用
--需要更新：1.玩家名称、头像等线上；2.玩家在线状态；3.玩家准备状态；
function MahjongRoomPanel.UpdatePlayerDisplay()
    local playerData = nil
    local playerItem = nil

    --更新所有玩家信息
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerData = MahjongDataMgr.playerDatas[i]
        playerItem = this.playerItems[i]
        if playerItem ~= nil then
            if playerData == nil then
                playerItem:Hide()
            else
                playerItem:Show()
                this.UpdatePlayerItemBySingle(playerItem, playerData)
                this.UpdatePlayerOnlineBySingle(playerItem, playerData)
                this.UpdatePlayerJoinBySingle(playerItem, playerData)
                this.UpdatePlayerReadyBySingle(playerItem, playerData)
            end
        end
    end
    this.HandleCheckPlayerHeadImage()
end

--处理检测玩家头像
function MahjongRoomPanel.HandleCheckPlayerHeadImage()
    local playerData = nil
    local playerItem = nil
    local tempPlayers = {}
    local tempPlayer = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerData = MahjongDataMgr.playerDatas[i]
        playerItem = this.playerItems[i]
        if playerItem ~= nil and playerItem.isActive and playerData ~= nil then
            --{seatIndex = 0, id = 0, image = nil, headUrl = nil}
            tempPlayer = { seatIndex = playerData.seatIndex, id = playerData.id, image = playerItem.headImage, headUrl = playerData.headUrl }
            table.insert(tempPlayers, tempPlayer)
        end
    end
    if #tempPlayers > 0 then
        RoomUtil.StartCheckPlayerHeadImage(tempPlayers)
    end
end

--更新玩家游戏开始时的显示更新
--需要更新：1.分数；2.庄家图标；3.玩家准备状态（所有玩家都准备了）；4.Table状态（选牌、定缺）；5.定缺图标；6.胡牌图标；
function MahjongRoomPanel.UpdatePlayerDisplayByGameBegin()
    --处理定缺
    if MahjongDataMgr.isNeedDingQue == true then
        MahjongDataMgr.isAllDingQue = MahjongDataMgr.CheckIsAllDingQue()
    end

    local playerData = nil
    local playerItem = nil
    local isGoldRoom = MahjongDataMgr.IsGoldRoom()
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerData = MahjongDataMgr.playerDatas[i]
        playerItem = this.playerItems[i]
        if playerItem ~= nil and playerData ~= nil then
            if isGoldRoom then
                --如果是分数场，需要在更新下玩家的头像
                playerItem:Show()
                this.UpdatePlayerItemBySingle(playerItem, playerData)
            end
            this.UpdatePlayerScoreBySingle(playerItem, playerData)
            this.UpdatePlayerZhuangBySingle(playerItem, playerData)
            this.UpdatePlayerJoinBySingle(playerItem, playerData)
            this.UpdatePlayerReadyBySingle(playerItem, playerData)
            this.UpdatePlayerTableStateBySingle(playerItem, playerData)
            this.UpdatePlayerHuBySingle(playerItem, playerData)
            this.UpdatePlayerDingQueBySingle(playerItem, playerData)
            this.UpdatePlayerTrustBySingle(playerItem, playerData)
        end
    end
    this.HandleCheckPlayerHeadImage()
end

--更新玩家准备
function MahjongRoomPanel.UpdatePlayerReady()
    local playerData = nil
    local playerItem = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerData = MahjongDataMgr.playerDatas[i]
        playerItem = this.playerItems[i]
        if playerItem ~= nil and playerData ~= nil then
            this.UpdatePlayerReadyBySingle(playerItem, playerData)
        end
    end
    this.UpdateButtonDisplayByReady()
end

--更新玩家Table状态
function MahjongRoomPanel.UpdatePlayerTableState()
    local playerData = nil
    local playerItem = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerData = MahjongDataMgr.playerDatas[i]
        playerItem = this.playerItems[i]
        if playerItem ~= nil and playerData ~= nil then
            this.UpdatePlayerTableStateBySingle(playerItem, playerData)
        end
    end
end

--清除，用于换牌动画播放时，处理
function MahjongRoomPanel.ClearPlayerTableState()
    local playerData = nil
    local playerItem = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerData = MahjongDataMgr.playerDatas[i]
        playerItem = this.playerItems[i]
        if playerItem ~= nil and playerData ~= nil then
            playerData.tState = MahjongPlayerTableState.None
            this.UpdatePlayerTableStateBySingle(playerItem, playerData)
        end
    end
end

--清除庄显示
function MahjongRoomPanel.ClearPlayerZhuang()
    local playerItem = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerItem = this.playerItems[i]
        if playerItem ~= nil then
            UIUtil.SetActive(playerItem.masterGO, false)
        end
    end
end

--检测和更新定缺的处理
function MahjongRoomPanel.CheckAndUpdateDingQue()
    --不需要定缺就不进行处理
    if MahjongDataMgr.isNeedDingQue ~= true then
        return
    end
    if MahjongDataMgr.isAllDingQue == true then
        if MahjongDataMgr.isPlayback then
            this.CheckAndClearDingQueByPlayback()
        else
            this.UpdatePlayerDingQueDisplay()
        end
        return
    end
    MahjongDataMgr.isAllDingQue = MahjongDataMgr.CheckIsAllDingQue()
    if MahjongDataMgr.isAllDingQue == true then
        local playerData = nil
        local playerItem = nil
        for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
            playerData = MahjongDataMgr.playerDatas[i]
            playerItem = this.playerItems[i]
            if playerItem ~= nil and playerData ~= nil then
                this.PlayDingQueAnim(playerItem, playerData)
            end
        end
    end
end

--检测清除定缺，在回放中处理，立即隐藏定缺图标和飞定缺动画
function MahjongRoomPanel.CheckAndClearDingQueByPlayback()
    MahjongDataMgr.isAllDingQue = MahjongDataMgr.CheckIsAllDingQue()
    if MahjongDataMgr.isAllDingQue == false then
        local playerItem = nil
        for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
            playerItem = this.playerItems[i]
            if playerItem ~= nil and playerItem.isActive then
                playerItem:ClearDingQue()
            end
        end
    end
end


--更新胡牌图标显示
function MahjongRoomPanel.UpdatePlayerHuDisplay()
    local playerData = nil
    local playerItem = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerData = MahjongDataMgr.playerDatas[i]
        playerItem = this.playerItems[i]
        if playerItem ~= nil and playerData ~= nil then
            this.UpdatePlayerHuBySingle(playerItem, playerData)
        end
    end
end

--更新分数显示
function MahjongRoomPanel.UpdatePlayerScoreDisplay()
    local playerData = nil
    local playerItem = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerData = MahjongDataMgr.playerDatas[i]
        playerItem = this.playerItems[i]
        if playerItem ~= nil and playerData ~= nil then
            this.UpdatePlayerScoreBySingle(playerItem, playerData)
        end
    end
end

--更新定缺图标显示
function MahjongRoomPanel.UpdatePlayerDingQueDisplay()
    local playerData = nil
    local playerItem = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerData = MahjongDataMgr.playerDatas[i]
        playerItem = this.playerItems[i]
        if playerItem ~= nil and playerData ~= nil then
            this.UpdatePlayerDingQueBySingle(playerItem, playerData)
        end
    end
end

------------------------------------------------------------------
--更新单个玩家的UI显示
function MahjongRoomPanel.UpdatePlayerItemBySingle(playerItem, playerData)
    playerItem.idTxt.text = playerData.id
    --如果玩家名字为nil则显示空串
    if playerData.name == nil then
        playerItem.nameTxt.text = ""
    else
        playerItem.nameTxt.text = playerData.name
    end
    if MahjongDataMgr.moneyType == MoneyType.Gold then
        -- UIUtil.SetActive(playerItem.iconBagGO, false)
        -- UIUtil.SetActive(playerItem.iconGoldGO, true)
        playerItem.scoreTxt.text = tostring(playerData.gold)
    else
        -- UIUtil.SetActive(playerItem.iconBagGO, true)
        -- UIUtil.SetActive(playerItem.iconGoldGO, false)
        playerItem.scoreTxt.text = tostring(playerData.score)
    end
    --处理头像即头像框
    this.InternalUpdatePlayerHead(playerItem, playerData)
end

--更新单个玩家的分数显示
function MahjongRoomPanel.UpdatePlayerScoreBySingle(playerItem, playerData)
    if MahjongDataMgr.moneyType == MoneyType.Gold then
        playerItem.scoreTxt.text = tostring(playerData.gold)
    else
        playerItem.scoreTxt.text = tostring(playerData.score)
    end
end

--更新玩家的在线状态，通过玩家的座位
function MahjongRoomPanel.UpdatePlayerOnlineByIndex(seatIndex)
    --主玩家不处理
    if seatIndex > 1 then
        local playerData = MahjongDataMgr.playerDatas[seatIndex]
        local playerItem = this.playerItems[seatIndex]
        if playerItem ~= nil then
            this.UpdatePlayerOnlineBySingle(playerItem, playerData)
        end
    end
end

--更新单个玩家的在线状态
function MahjongRoomPanel.UpdatePlayerOnlineBySingle(playerItem, playerData)
    --主玩家自己不处理
    if playerData.id ~= MahjongDataMgr.userId then
        --在线标识，0离线、1在线
        playerItem:SetOnline(playerData.online)
    end
end

--更新单个玩家的庄图标
function MahjongRoomPanel.UpdatePlayerZhuangBySingle(playerItem, playerData)
    if MahjongDataMgr.zhuang == playerData.id then
        if playerItem.masterGO.activeSelf ~= true then
            MahjongAnimMgr.PlayZhuangAnim(this.moveMasterGO, this.moveMasterPosition, playerItem.masterGO)
        end
    end
end

--更新单个玩家的进入状态
function MahjongRoomPanel.UpdatePlayerJoinBySingle(playerItem, playerData)
    if not MahjongDataMgr.IsRoomBegin() then
        UIUtil.SetActive(playerItem.stateJoiningGO, playerData.join ~= MahjongJoinType.Join)
    else
        UIUtil.SetActive(playerItem.stateJoiningGO, false)
    end
end

--更新单个玩家的准备状态
function MahjongRoomPanel.UpdatePlayerReadyBySingle(playerItem, playerData)
    --主玩家准备了，才显示其他玩家的准备状态，防止游戏结束后重连后，准备状态图标显示错误问题
    if MahjongDataMgr.gameState == MahjongGameStateType.Waiting and MahjongDataMgr.isAllSeat and MahjongDataMgr.IsReady() then
        local temp = playerData.ready ~= MahjongReadyType.Ready
        UIUtil.SetActive(playerItem.stateNotReadyGO, temp)
        if temp then
            --如果显示了未准备状态图标，则不显示进入中状态图标
            UIUtil.SetActive(playerItem.stateJoiningGO, false)
        end
    else
        UIUtil.SetActive(playerItem.stateNotReadyGO, false)
    end
end

--更新单个玩家的Table状态
function MahjongRoomPanel.UpdatePlayerTableStateBySingle(playerItem, playerData)
    if playerItem.tableState == playerData.tState then
        return
    end
    playerItem.tableState = playerData.tState

    local isChangedCard = playerData.tState == MahjongPlayerTableState.ChangedCard
    UIUtil.SetActive(playerItem.stateXuanPai, isChangedCard)
    local isDingQueEnd = playerData.tState == MahjongPlayerTableState.DingQueEnd
    UIUtil.SetActive(playerItem.stateDingQue, isDingQueEnd)
    UIUtil.SetActive(playerItem.stateGO, isChangedCard or isDingQueEnd)
end

--更新单个玩家的定缺状态
function MahjongRoomPanel.UpdatePlayerDingQueBySingle(playerItem, playerData)
    if MahjongDataMgr.isAllDingQue == false then
        this.InternalUpdatePlayerDingQueBySingle(playerItem, 0)
        return
    end
    --如果播放动画，且时间小于1.9秒内就不更新图标
    if playerItem.isPlayDingQueAnim then
        if os.time() - playerItem.playDingQueAnimTime > 1.9 then
            playerItem.isPlayDingQueAnim = false
            playerItem.playDingQueAnimTime = 0
            UIUtil.SetActive(playerItem.moveDingQueGO, false)
        end
        if playerItem.isPlayDingQueAnim ~= true then
            this.InternalUpdatePlayerDingQueBySingle(playerItem, playerData.dingQue)
        end
    else
        this.InternalUpdatePlayerDingQueBySingle(playerItem, playerData.dingQue)
    end
end

--更新单个玩家的定缺状态
function MahjongRoomPanel.InternalUpdatePlayerDingQueBySingle(playerItem, dingQue)
    if playerItem.dingQue == dingQue then
        return
    end
    playerItem.dingQue = dingQue
    if playerItem.dingQue > 0 then
        UIUtil.SetActive(playerItem.dingQueGO, true)
        playerItem.dingQueImage.sprite = MahjongResourcesMgr.GetSprite("IconDQ" .. playerItem.dingQue)
    else
        UIUtil.SetActive(playerItem.dingQueGO, false)
    end
end

--更新单个玩家的托管状态
function MahjongRoomPanel.UpdatePlayerTrustBySingle(playerItem, playerData)
    if playerData.trust == playerItem.trust then
        return
    end
    playerItem.trust = playerData.trust
    UIUtil.SetActive(playerItem.trustGO, playerItem.trust == 1)
end

--检测是否有新的胡牌
function MahjongRoomPanel.CheckPlayerNewHuBySingle(playerItem, playerData)
    if playerData.huType ~= nil and playerData.huType > 0 then
        return playerData.huType ~= playerItem.huType
    end
    return false
end

--更新单个玩家的胡牌图标
function MahjongRoomPanel.UpdatePlayerHuBySingle(playerItem, playerData)
    if playerData.huType == playerItem.huType then
        return
    end
    Log(">> MahjongRoomPanel.UpdatePlayerHuBySingle > ", playerData.huType)
    playerItem.huType = playerData.huType
    if playerData.huType ~= nil and playerData.huType > 0 then
        playerItem:SetHuDisplay(true)
        if playerData.huType == MahjongHuEffectsType.ZiMo or playerData.huType == MahjongHuEffectsType.GangShangHua then
            -- playerItem.huImage.sprite = MahjongResourcesMgr.GetSprite("SsZiMo" .. playerData.huIndex)
            playerItem:SetPlayEffect("YH_"..playerData.huIndex.."zimo", 1)
        else
            -- playerItem.huImage.sprite = MahjongResourcesMgr.GetSprite("SsHu" .. playerData.huIndex)
            playerItem:SetPlayEffect("YH_"..playerData.huIndex.."hu", 0.65)
        end
        --playerItem.huImage:SetNativeSize()--由于有组件控制了大小，这里就不用调用了
        -- if MahjongDataMgr.isYaoJiPlayWay and playerData.huFan ~= nil then
        --     playerItem:SetHuLabelDisplay(true)
        --     playerItem.huLabel.text = GetS("(%s倍)", this.GetHuMultiple(playerData.huFan))
        -- else
        --     playerItem:SetHuLabelDisplay(false)
        -- end
        playerItem:SetHuLabelDisplay(false)
    else
        playerItem:SetHuDisplay(false)
    end
end

--获取胡的倍数
function MahjongRoomPanel.GetHuMultiple(huFan)
    huFan = huFan or 0
    local temp = MahjongMultipleMappingDict[huFan]
    if temp ~= nil then
        return temp
    else
        return 1
    end
end

------------------------------------------------------------------
--内部调用
--更新玩家头像--ko
function MahjongRoomPanel.InternalUpdatePlayerHead(playerItem, playerData)
    if playerData.id == playerItem.playerId then
        return
    end
    playerItem.playerId = playerData.id
    local arg = { playerItem = playerItem, playerId = playerItem.playerId }
    Functions.SetHeadImage(playerItem.headImage, playerData.headUrl, this.OnHeadImageLoadCompleted, arg)

    --处理头像框
    if playerData.headFrame ~= nil then
        Functions.SetHeadFrame(playerItem.headFrame, playerData.headFrame)
    end
end

--加载头像图片完成
function MahjongRoomPanel.OnHeadImageLoadCompleted(arg)
    if arg.playerItem ~= nil and arg.playerItem.playerId == arg.playerId then
        netImageMgr:SetImage(arg.playerItem.headImage, arg.headUrl)
    end
end

--更新局数
function MahjongRoomPanel.InternalUpdateGameIndex()
    local index = tonumber(MahjongDataMgr.gameIndex)
    if index == nil then
        index = 0
    end
    local total = MahjongDataMgr.gameTotal

    if MahjongDataMgr.IsGoldRoomInfinite() then
        this.totalTxt.text = index .. "局"
    else
        this.totalTxt.text = index .. "/" .. total
    end
end

--界面打开的时候处理按钮显示
function MahjongRoomPanel.UpdateButtonDisplayByOpend()
    UIUtil.SetActive(this.rulesBtn, true)
    UIUtil.SetActive(this.copyBtn, false)
    UIUtil.SetActive(this.inviteBtn, false)
    UIUtil.SetActive(this.changeBtn, false)
    UIUtil.SetActive(this.huTipsBtn, false)
    UIUtil.SetActive(this.LastShowCardTrans, false)
    UIUtil.SetActive(this.bottomRight.gameObject, not MahjongDataMgr.isPlayback)
    
    if MahjongDataMgr.isPlayback then
        UIUtil.SetActive(this.setupBtn, false)
        UIUtil.SetActive(this.chatBtn, false)
        --UIUtil.SetActive(this.gpsBtn, false)
        UIUtil.SetActive(this.speechBtn, false)
        --UIUtil.SetActive(this.rankingBtn, false)
    else
        UIUtil.SetActive(this.setupBtn, true)
        --UIUtil.SetActive(this.chatBtn, true)
        --分数场不显示GPS 语音 不能自定义输入文字
        if MahjongDataMgr.moneyType == MoneyType.Gold then
            --UIUtil.SetActive(this.gpsBtn, false)
            UIUtil.SetActive(this.speechBtn, false)
        else
            --UIUtil.SetActive(this.gpsBtn, true)
            -- UIUtil.SetActive(this.speechBtn, true)
        end
        --UIUtil.SetActive(this.rankingBtn, MahjongDataMgr.IsMatchRoom())
    end
end

--准备后按钮更新
function MahjongRoomPanel.UpdateButtonDisplayByReady()
    if MahjongDataMgr.moneyType == MoneyType.Gold then
        UIUtil.SetActive(this.copyBtn, false)
        UIUtil.SetActive(this.inviteBtn, false)
        UIUtil.SetActive(this.changeBtn, false)
    else
        if not MahjongDataMgr.IsReady() and not MahjongDataMgr.IsRoomBegin() then
            UIUtil.SetActive(this.copyBtn, true)
            UIUtil.SetActive(this.inviteBtn, true)
            UIUtil.SetActive(this.changeBtn, MahjongDataMgr.roomType == RoomType.Club)
        else
            UIUtil.SetActive(this.copyBtn, false)
            UIUtil.SetActive(this.inviteBtn, false)
            UIUtil.SetActive(this.changeBtn, false)
        end
    end
end

--更新按钮的显示
function MahjongRoomPanel.UpdateButtonDisplay()
    UIUtil.SetActive(this.rulesBtn, true)
    if MahjongDataMgr.isPlayback then
        UIUtil.SetActive(this.copyBtn, false)
        UIUtil.SetActive(this.inviteBtn, false)
        UIUtil.SetActive(this.changeBtn, false)
        UIUtil.SetActive(this.setupBtn, false)
        --UIUtil.SetActive(this.gpsBtn, false)
        UIUtil.SetActive(this.huTipsBtn, false)
        UIUtil.SetActive(this.chatBtn, false)
        UIUtil.SetActive(this.speechBtn, false)
    else
        if MahjongDataMgr.moneyType == MoneyType.Gold then
            UIUtil.SetActive(this.copyBtn, false)
            UIUtil.SetActive(this.inviteBtn, false)
            UIUtil.SetActive(this.changeBtn, false)
        else
            if not MahjongDataMgr.IsReady() and not MahjongDataMgr.IsRoomBegin() then
                UIUtil.SetActive(this.copyBtn, true)
                UIUtil.SetActive(this.inviteBtn, true)
                UIUtil.SetActive(this.changeBtn, MahjongDataMgr.roomType == RoomType.Club)
            else
                UIUtil.SetActive(this.copyBtn, false)
                UIUtil.SetActive(this.inviteBtn, false)
                UIUtil.SetActive(this.changeBtn, false)
            end
        end

        --分数场不显示语音
        if MahjongDataMgr.moneyType == MoneyType.Gold then
            UIUtil.SetActive(this.speechBtn, false)
            --UIUtil.SetActive(this.gpsBtn, false)
        else
            -- UIUtil.SetActive(this.speechBtn, true)
            --UIUtil.SetActive(this.gpsBtn, true)
        end

        UIUtil.SetActive(this.setupBtn, true)
        --UIUtil.SetActive(this.chatBtn, true)
        this.CheckHuTipsBtnDisplay()
    end
end

--更新胡提示按钮显示
function MahjongRoomPanel.CheckHuTipsBtnDisplay()
    if MahjongDataMgr.IsTingTips() and MahjongDataMgr.IsGameBegin() and MahjongDataMgr.HuTips.huData ~= nil then
        UIUtil.SetActive(this.huTipsBtn, true)
    else
        UIUtil.SetActive(this.huTipsBtn, false)
    end
end

------------------------------------------------------------------
--更新所有玩家的在线状态
function MahjongRoomPanel.UpdatePlayerOnline()
    local playerData = nil
    local playerItem = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerData = MahjongDataMgr.playerDatas[i]
        playerItem = this.playerItems[i]
        if playerData ~= nil and playerItem ~= nil then
            this.UpdatePlayerOnlineBySingle(playerItem, playerData)
        end
    end
end

--更新主玩家的托管，包括头像上的状态图标
function MahjongRoomPanel.UpdateTrustByCancel()
    local playerData = MahjongDataMgr.playerDatas[1]
    local playerItem = this.playerItems[1]
    if playerData ~= nil and playerItem ~= nil then
        this.UpdatePlayerTrustBySingle(playerItem, playerData)
    end
    this.UpdateMainPlayerTrust()
end


--更新主玩家的托管
function MahjongRoomPanel.UpdateMainPlayerTrust()
    local playerData = MahjongDataMgr.playerDatas[1]
    if playerData ~= nil then
        if this.mainPlayerTrust == playerData.trust then
            return
        end
        this.mainPlayerTrust = playerData.trust
        UIUtil.SetActive(this.trustGO, this.mainPlayerTrust == 1)
        if this.mainPlayerTrust == 1 then
            UIUtil.SetActive(this.trustGO, true)
        else
            UIUtil.SetActive(this.trustGO, false)
        end
    end
end


--更新扣除分数
function MahjongRoomPanel.UpdateDeductGold()
    local playerData = nil
    local playerItem = nil
    local isFound = false
    local isPlayScoreAnim = MahjongDataMgr.IsMatchRoom()
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerData = MahjongDataMgr.playerDatas[i]
        playerItem = this.playerItems[i]
        if playerData ~= nil and playerItem ~= nil then
            --更新分数或者分数
            MahjongRoomPanel.UpdatePlayerScoreBySingle(playerItem, playerData)
            --播放动画
            if playerData.deductGold ~= 0 then
                --播放分数分数动画
                playerItem:PlayGoldAnim(playerData.deductGold)
                --播放分数动画
                if isPlayScoreAnim then
                    playerItem:PlayScoreAnim(math.floor(playerData.deductGold / MahjongDataMgr.baseScore))
                end
                --设置是否有变化
                isFound = true
                --处理完了就把数据重置了
                playerData.deductGold = 0
            end
        end
    end

    if isFound then
        MahjongAudioMgr.PlayCoin()
    end
end

------------------------------------------------------------------
--
--定缺动画
function MahjongRoomPanel.PlayDingQueAnim(playerItem, playerData)
    if playerItem.isPlayDingQueAnim then
        return
    end
    playerItem.isPlayDingQueAnim = true
    playerItem.playDingQueAnimTime = os.time()
    --设置定缺动画的图标
    playerItem.moveDingQueImage.sprite = MahjongResourcesMgr.GetSprite("IconFlyDQ" .. playerData.dingQue)
    UIUtil.SetLocalPosition(playerItem.moveDingQueGO, playerItem.moveDingQuePosition)
    UIUtil.SetLocalScale(playerItem.moveDingQueGO, 2, 2, 2)
    UIUtil.SetActive(playerItem.moveDingQueGO, true)

    Scheduler.scheduleOnceGlobal(HandlerArgs(this.OnPlayDingQueAnimWait, playerItem, playerData), 0.5)
end

--定缺播放动画等待处理
function MahjongRoomPanel.OnPlayDingQueAnimWait(playerItem, playerData)
    if playerItem ~= nil then
        if playerItem.isPlayDingQueAnim then
            --移动
            playerItem.moveDingQueTrans:DOMove(playerItem.dingQueTrans.position, 0.5, false):OnComplete(function()
                playerItem.isPlayDingQueAnim = false
                playerItem.playDingQueAnimTime = 0
                UIUtil.SetActive(playerItem.moveDingQueGO, false)
                this.UpdatePlayerDingQueBySingle(playerItem, playerData)
            end)
            --缩小
            playerItem.moveDingQueTrans:DOScale(Vector3.New(1, 1, 1), 0.5)
        else
            playerItem.playDingQueAnimTime = 0
            UIUtil.SetActive(playerItem.moveDingQueGO, false)
            this.UpdatePlayerDingQueBySingle(playerItem, playerData)
        end
    end
end

------------------------------------------------------------------
--获取播放特效的节点
function MahjongRoomPanel.GetEffectNode(seatIndex, operateCode)
    local playerItem = this.playerItems[seatIndex]
    if playerItem ~= nil and operateCode ~= nil and operateCode <= 1002 then
        return playerItem.effectNodeTrans
    else
        return this.centerEffectNode
    end
end


------------------------------------------------------------------
--显示某个玩家的聊天气泡
function MahjongRoomPanel.OnShowChatBubble(playerId, duration, str, voiceResource)
    if IsNil(playerId) or IsNil(str) then
        LogError("MahjongRoomPanel>>> OnShowChatBubble  传入的玩家，或者显示的str 为nil")
        return
    end
    local playerData = MahjongDataMgr.GetPlayerDataById(playerId)
    if playerData == nil then
        LogError("MahjongRoomPanel>>> OnShowChatBubble  playerData 为nil")
        return
    end
    local playerUI = this.playerItems[playerData.seatIndex]

    if playerUI ~= nil then
        Functions.SetChatText(playerUI.chatFrameGO, playerUI.chatTxt, str)
        Audio.PlaySound("mahjong/quick", voiceResource)
        --定时关闭
        Scheduler.scheduleOnceGlobal(function()
            UIUtil.SetActive(playerUI.chatFrameGO, false)
        end, duration)
    end
end

------------------------------------------------------------------
--检测更新服务器时间
function MahjongRoomPanel.CheckUpdateServerTime()
    this.StartServerTimeTimer()
    this.UpdateServerTimeDisplay()
end

--由于时间只显示到分钟，所有每10秒处理一次
function MahjongRoomPanel.StartServerTimeTimer()
    if this.serverTimeTimer == nil then
        this.serverTimeTimer = Timing.New(this.OnServerTimeTimer, 10)
        this.serverTimeTimer:Start()
    end
end

function MahjongRoomPanel.StopServerTimeTimer()
    if this.serverTimeTimer ~= nil then
        this.serverTimeTimer:Stop()
        this.serverTimeTimer = nil
    end
end

function MahjongRoomPanel.OnServerTimeTimer()
    this.UpdateServerTimeDisplay()
end

--设置更新服务器时间显示
function MahjongRoomPanel.UpdateServerTimeDisplay()
    TryCatchCall(this.OnUpdateServerTimeDisplay)
end

function MahjongRoomPanel.OnUpdateServerTimeDisplay()

    if MahjongDataMgr.serverTimeStamp == nil then
        return
    end

    local temp = Time.realtimeSinceStartup - MahjongDataMgr.serverUpdateTime
    temp = temp + MahjongDataMgr.serverTimeStamp

    temp = this.GetDateByTimeStamp(temp)

    this.timeTxt.text = temp
end

function MahjongRoomPanel.GetDateByTimeStamp(timeStamp)
    --return os.date("%Y-%m-%d %H:%M", timeStamp)
    return os.date("%m-%d %H:%M", timeStamp)
end
------------------------------------------------------------------
--
--设置电量
function MahjongRoomPanel.UpdateEnergyValue(value)
    local num = value / 100
    this.energyValueImage.fillAmount = num

    local level = Functions.CheckEnergyLevel(value)
    if this.energyLevel == level then
        return
    end
    this.energyLevel = level
    if this.energyLevel == EnergyLevel.None then
        UIUtil.SetActive(this.energyNoActiveGO, true)
        UIUtil.SetActive(this.energyValueGO, false)
    else
        UIUtil.SetActive(this.energyNoActiveGO, false)
        UIUtil.SetActive(this.energyValueGO, true)
        if this.energyLevel == EnergyLevel.Low then
            UIUtil.SetImageColor(this.energyValueImage, 1, 0, 0)
        else
            UIUtil.SetImageColor(this.energyValueImage, 1, 1, 1)
        end
    end
end

--检测更新网络Ping值
function MahjongRoomPanel.CheckUpdateNetPing()
    --初始设置30
    this.UpdateNetPing(30)
    --初始更新下网络类型
    this.UpdateNetType()
    --
    this.StartCheckNetTypeTimer()
end

--启动检测网络类型
function MahjongRoomPanel.StartCheckNetTypeTimer()
    if this.checkNetTypeTimer == nil then
        this.checkNetTypeTimer = Timing.New(this.StartCheckNetTypeTimer, 10)
    end
    this.checkNetTypeTimer:Start()
end

--停止检测网络类型
function MahjongRoomPanel.StopCheckNetTypeTimer()
    if this.checkNetTypeTimer ~= nil then
        this.checkNetTypeTimer:Stop()
    end
end

--处理检测网络类型
function MahjongRoomPanel.OnCheckNetTypeTimer()
    this.UpdateNetType()
end

--更新网络类型
function MahjongRoomPanel.UpdateNetType()
    local isWifi = Util.IsWifi
    if this.isWifi == isWifi then
        return
    end

    this.isWifi = isWifi

    if this.isWifi then
        UIUtil.SetActive(this.iconWifiTran, true)
        UIUtil.SetActive(this.iconSignalTran, false)
    else
        UIUtil.SetActive(this.iconWifiTran, false)
        UIUtil.SetActive(this.iconSignalTran, true)
    end
end

--更新网络Ping值
function MahjongRoomPanel.UpdateNetPing(value)
    --
    this.pingTxt.text = tostring(value)
    --
    local level = Functions.CheckNetLevel4(value)
    --这样判断是不重复处理UI
    if this.netLevel == level then
        return
    end
    this.netLevel = level

    local netImage = nil
    local sprites
    if this.isWifi then
        netImage = this.iconWifiValueImage
        sprites = this.iconWifiValueGOSpriteAtlas.sprites:ToTable()
    else
        netImage = this.iconSignalValueImage
        sprites = this.iconSignalValueSpriteAtlas.sprites:ToTable()
    end

    netImage.sprite = sprites[level + 1]
    if this.netLevel == NetLevel.Good then
        UIUtil.SetTextColor(this.pingTxt, 0, 1, 0)
    elseif this.netLevel == NetLevel.General then
        UIUtil.SetTextColor(this.pingTxt, 1, 1, 0)
    else
        UIUtil.SetTextColor(this.pingTxt, 1, 0, 0)
    end
end

------------------------------------------------------------------
--
--更新中间倒计时和箭头指示
function MahjongRoomPanel.UpdateTimePoint(seatIndex, opertionTime)
    --索引位置不对
    if seatIndex < 1 or seatIndex > 4 then
        seatIndex = 1
    end

    --更新时间
    this.UpdateOperateTime(opertionTime)

    --只显示一个，避免可能同时显示多个
    local length = #this.timePoints
    for i = 1, length do
        if i == seatIndex then
            UIUtil.SetActive(this.timePoints[i], true)
        else
            UIUtil.SetActive(this.timePoints[i], false)
        end
    end

    local tweener = this.timePointsTweener[seatIndex]
    tweener:ResetToBeginning()
    tweener:PlayForward()

    this.BenginOperateCountDown()
end

--保存操作时间
function MahjongRoomPanel.UpdateOperateTime(opertionTime)
    if this.opertionTime < 0 then
        this.opertionTime = 0
    end
    if this.opertionTime > 99 then
        this.opertionTime = 99
    end
    this.opertionTime = opertionTime
    this.lastUpdateOpertionTime = Time.realtimeSinceStartup
end

--设置倒计时
function MahjongRoomPanel.BenginOperateCountDown()
    if this.opertionTime < 0 then
        this.opertionTime = 0
    end
    if this.opertionTime > 99 then
        this.opertionTime = 99
    end
    this.UpdateOperateCountDown(math.ceil(this.opertionTime))
    this.StartOperateCountDownTimer()
end

function MahjongRoomPanel.StartOperateCountDownTimer()
    if this.operateCountDownTimer == nil then
        this.operateCountDownTimer = Timing.New(this.OnOperateCountDownTimer, 0.2)
    end
    this.operateCountDownTimer:Restart()
end

function MahjongRoomPanel.StopOperateCountDownTimer()
    if this.operateCountDownTimer ~= nil then
        this.operateCountDownTimer:Stop()
    end
    this.operateCountDownTimer = nil
end

function MahjongRoomPanel.OnOperateCountDownTimer()
    if MahjongDataMgr.isDismissing then
        this.lastUpdateOpertionTime = Time.realtimeSinceStartup
    else
        local tempTime = Time.realtimeSinceStartup
        local diffTime = tempTime - this.lastUpdateOpertionTime
        this.lastUpdateOpertionTime = tempTime
        this.opertionTime = this.opertionTime - diffTime
        if this.opertionTime < 0 then
            this.opertionTime = 0
        end
        if this.opertionTime > 99 then
            this.opertionTime = 99
        end

        this.UpdateOperateCountDown(math.ceil(this.opertionTime))
    end
end

--倒计时暂定10到0
function MahjongRoomPanel.UpdateOperateCountDown(time)
    if this.lastCountDown == time then
        return
    end

    this.lastCountDown = time
    UIUtil.SetActive(this.redImage, time < 10)
    local temp = math.floor(time / 10)
    this.timeImage1.sprite = MahjongResourcesMgr.GetSprite("Num" .. temp)
    temp = time % 10
    this.timeImage2.sprite = MahjongResourcesMgr.GetSprite("Num" .. temp)
end

--停止倒计时
function MahjongRoomPanel.StopOperateCountDown()
    this.StopOperateCountDownTimer()
    this.timeImage1.sprite = MahjongResourcesMgr.GetSprite("Num0")
    this.timeImage2.sprite = MahjongResourcesMgr.GetSprite("Num0")
    UIUtil.SetActive(this.redImage, false)
    local length = #this.timePoints
    for i = 1, length do
        UIUtil.SetActive(this.timePoints[i], false)
    end
end

------------------------------------------------------------------
--更新打出牌的箭头指示
function MahjongRoomPanel.UpdateOutCardArrow(type, playerId, cardId)
    if type == MahjongOperateCode.CHU_PAI then
        this.opPlayerId = playerId
        this.opCardId = cardId
    end

    if this.opCardId == nil or this.opCardId < 1 then
        this.HideOutCardArrow()
    else
        local playerData = MahjongDataMgr.GetPlayerDataById(this.opPlayerId)
        local player = MahjongPlayCardMgr.GetPlayerByIndex(playerData.seatIndex)
        if player == nil then
            this.HideOutCardArrow()
        else
            local outCardItem = player.outCard:GetLastItem()
            this.UpdateOutCardArrowPos(outCardItem, player)
        end
    end
end

--获取1/3 号位出牌坐标的微差值
function MahjongRoomPanel.GetOutCargDeviation(outCardItem, player)
    local deviation_x = 0 
    local deviation_y = 0
    --1号位出牌父节点修改了大小，按照第一行出牌原比例进行缩放，所以出牌标记出现微差
    if player.seatIndex == MahjongSeatIndex.Seat1 then 
        if outCardItem.row > 1 then
            if outCardItem.column <= 5 then
                deviation_x = -(6 - outCardItem.column) * outCardItem.row
            elseif outCardItem.column >= 7 then
                deviation_x = (outCardItem.column - 6) * outCardItem.row
            end
            deviation_y = (outCardItem.row - 1) * -50
            if outCardItem.row == 3 then
                deviation_y = deviation_y - 2
            elseif outCardItem.row == 4 then
                deviation_y = deviation_y - 6
            end
        end
    elseif player.seatIndex == MahjongSeatIndex.Seat3 then
        -- 2人麻将
        -- 1行 --  10 8  6  4  2   -2  -4  -6  -8  -10
        -- 2行 --  8  6  4  2      -2  -4  -6  -8
        -- 4行 -- -8 -6 -4 -2       2   4   6   8
        if MahjongDataMgr.playerTotal == 2 then
            if outCardItem.row == 1 then
                deviation_x = (6 - outCardItem.column) * 2
            elseif outCardItem.row == 2 or outCardItem.row == 4 then
                if outCardItem.column <= 4 then
                    deviation_x = (5 - outCardItem.column) * 2
                elseif outCardItem.column >= 8 then
                    deviation_x = (7 - outCardItem.column) * 2
                end
                if outCardItem.row == 4 then
                    deviation_x = -deviation_x
                end
            end
        else
            --四人麻将
            --2行 -- 6 4 2  -2 -4 -6
            if outCardItem.row > 1 then
                if outCardItem.column <= 3 then
                    deviation_x = -(4 - outCardItem.column) * outCardItem.row
                elseif outCardItem.column >= 7 then
                    deviation_x = (outCardItem.column - 6) * outCardItem.row
                end
            end
        end
        deviation_y = (outCardItem.row - 1) * 40 + 2
    end
    return deviation_x, deviation_y
end

---配合MahjongOutCard 163行的UpdateOutCardsPos的出牌放大效果延迟 1.5s
function MahjongRoomPanel.UpdateOutCardArrowPos(outCardItem, player)
    if outCardItem ~= nil and outCardItem.cardData and outCardItem.cardData.id == this.opCardId then

        local outCardItem_x = outCardItem.x
        local outCardItem_y = outCardItem.y
        --2号位出牌箭头坐标计算必须为绝对值
        if player.seatIndex == MahjongSeatIndex.Seat2 then
            outCardItem_x = math.abs(outCardItem_x)
        end
        local x = player.outCard.x + outCardItem_x
        local y = player.outCard.y + outCardItem_y

        local offsetData = MahjongOutCardArrowOffset[player.seatIndex]
        x = x + offsetData.x
        y = y + offsetData.y

        local deviation_x, deviation_y = this.GetOutCargDeviation(outCardItem, player)
        x = x + deviation_x
        y = y + deviation_y
        this.ShowOutCardArrow(x, y)
    else
        this.HideOutCardArrow()
    end
end

--隐藏箭头
function MahjongRoomPanel.HideOutCardArrow()
    if this.arrow ~= nil then
        UIUtil.SetActive(this.arrow, false)
    end
end

--显示箭头，在指定坐标处显示箭头
function MahjongRoomPanel.ShowOutCardArrow(x, y)
    if this.arrow ~= nil then
        UIUtil.SetActive(this.arrow, true)
        UIUtil.SetAnchoredPosition(this.arrow, x, y)
    end
end

------------------------------------------------------------------
--胡牌图标延迟显示功能
--启动胡牌后检测Timer
function MahjongRoomPanel.StartCheckPlayerHuTimer()
    if this.checkPlayerHuTimer == nil then
        --时间需要比结算时间低，否则在小结界面弹出是就显示不出
        this.checkPlayerHuTimer = Timing.New(this.OnCheckPlayerHuTimer, 1.2)
        this.checkPlayerHuTimer:Start()
    end
end

--停止胡牌后检测Timer
function MahjongRoomPanel.StopCheckPlayerHuTimer()
    if this.checkPlayerHuTimer ~= nil then
        this.checkPlayerHuTimer:Stop()
        this.checkPlayerHuTimer = nil
    end
end

--处理胡牌后检测Timer
function MahjongRoomPanel.OnCheckPlayerHuTimer()
    this.StopCheckPlayerHuTimer()
    Log(">> Mahjong > MahjongRoomPanel.OnCheckPlayerHuTimer.")
    this.UpdatePlayerHuDisplay()
end
------------------------------------------------------------------
--
--初始化聊天系统
function MahjongRoomPanel.InitChatManager()
    if MahjongDataMgr.isPlayback then
        return
    end

    --当前游戏参数
    ChatModule.SetChatCallback(this.OnShowChatBubble)
    local config = {
        audioBundle = MahjongBundleName.Quick,
        textChatConfig = MahjongChatLabelArr,
        languageType = LanguageType.putonghua,
    }
    ChatModule.SetChatConfig(config)

    --初始化基本信息
    ChatModule.Init(PanelConfig.RoomChat, PanelConfig.RoomUserInfo)
end

--玩家数据更新
function MahjongRoomPanel.UpdateChatPlayers()
    if MahjongDataMgr.isPlayback then
        return
    end
    local players = {}
    local playerData = nil
    local playerItem = nil
    local temp = nil
    for i = 1, Mahjong.ROOM_MAX_PLAYER_NUM do
        playerData = MahjongDataMgr.playerDatas[i]
        playerItem = this.playerItems[i]
        if playerData ~= nil and playerItem ~= nil then
            temp = {}
            players[playerData.id] = temp
            temp.emotionNode = playerItem.faceAnimNode
            temp.animNode = playerItem.headAnimNode
            temp.gender = playerData.gender
            temp.name = playerData.name
        end
    end
    ChatModule.SetPlayerInfos(players)
end

function MahjongRoomPanel.UpdateLastShowCard(card1, card2)
    UIUtil.SetActive(this.LastShowCardTrans, true)
    this.LastShowCardImg1.sprite = MahjongResourcesMgr.GetCardSprite(card1)
    this.LastShowCardImg2.sprite = MahjongResourcesMgr.GetCardSprite(card2)
end