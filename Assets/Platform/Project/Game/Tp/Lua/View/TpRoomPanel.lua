TpRoomPanel = ClassPanel("TpRoomPanel")
TpRoomPanel.Instance = nil
local this = TpRoomPanel

--初始属性数据
function TpRoomPanel:InitProperty()
    --是否初始化偏移
    this.isInitOffset = false
    --玩家显示对象
    this.playerItems = nil
    --需要根据玩家数来更换集合
    this.lightItems = nil
    --是否可以点击语音按钮
    this.isCanClick = true
    --语音Y轴偏移量
    this.speechTouchY = 0
    --服务器时间Timer
    this.serverTimeTimer = nil
    --电量等级
    this.energyLevel = nil
    --是否为Wifi
    this.isWifi = nil
    --网络等级
    this.netLevel = nil
    --网络类型检测Timer
    this.checkNetTypeTimer = nil
    --坐下按钮点击时间
    this.sitDownClickTime = 0
    --游戏局数
    this.gameIndex = nil

    --显示人数
    this.lastPlayerTotal = nil
end

--UI初始化
function TpRoomPanel:OnInitUI()
    this = self
    this:InitProperty()

    local tablecloth = this:Find("Tablecloth")
    this.tableclothImage = tablecloth:GetComponent(TypeImage)
    UIUtil.SetBackgroundAdaptation(tablecloth.gameObject)

    this.effectNode = this:Find("EffectNode")
    this.chipNode = this:Find("ChipNode")
    TpAnimMgr.InitChip(this.chipNode)

    --处理玩家显示项
    this.playerContent = this:Find("Players")
    this.playerItemPrefab = this.playerContent:Find("Item").gameObject
    UIUtil.SetActive(this.playerItemPrefab, false)
    this.playerItems = {}
    local playerItem = nil
    local temp = nil
    for i = 1, TpMaxPlayerTotal do
        temp = CreateGO(this.playerItemPrefab, this.playerContent, "Player-" .. i)
        --
        playerItem = TpPlayerItem.New()
        playerItem:Init(i, temp)
        --
        table.insert(this.playerItems, playerItem)
    end
    this.playerPositionDict = {}
    local positionNode = this:Find("Position")
    for i = 6, 9 do
        local tempNode = positionNode:Find(tostring(i))
        local list = {}
        for j = 1, i do
            table.insert(list, tempNode:Find(tostring(j)).position)
        end
        this.playerPositionDict[i] = list
    end
    this.lightItemDict = {}
    local light = this:Find("Light")
    for i = 6, 9 do
        local lightItems = {}
        this.lightItemDict[i] = lightItems
        local temp = light:Find(tostring(i))
        lightItems.gameObject = temp.gameObject
        lightItems.list = {}
        for j = 1, i do
            local item = {}
            item.transform = temp:Find(tostring(j))
            item.gameObject = item.transform.gameObject
            item.lastDisplay = nil
            table.insert(lightItems.list, item)
        end
    end

    --设置牌图集
    local spriteAtlas = this:Find("CardAtlas"):GetComponent("UISpriteAtlas")
    TpResourcesMgr.SetCardSprites(spriteAtlas.sprites)
    --设置状态图集
    spriteAtlas = this:Find("StausAtlas"):GetComponent("UISpriteAtlas")
    TpResourcesMgr.SetStatusSprites(spriteAtlas.sprites)

    --注意名字不要出现相同的
    spriteAtlas = this:Find("RoomAtlas"):GetComponent("UISpriteAtlas")
    TpResourcesMgr.SetSprites(spriteAtlas.sprites)

    --左上
    local topLeft = this:Find("TopLeft")
    this.tipsLabel = topLeft:Find("TipsText"):GetComponent(TypeText)
    this.menuBtn = topLeft:Find("MenuBtn").gameObject
    this.menuUpGo = topLeft:Find("MenuBtn/Up").gameObject
    this.roomLabel = topLeft:Find("RoomText"):GetComponent(TypeText)

    --右上
    local topRight = this:Find("TopRight")
    this.energyValueImage = topRight:Find("Energy/Value"):GetComponent(TypeImage)
    this.timeLabel = topRight:Find("TimeText"):GetComponent(TypeText)

    --上
    local topRight = this:Find("Top")

    --中心
    local center = this:Find("Center")
    this.playWayLabel = center:Find("PlayWayText"):GetComponent(TypeText)
    this.nameLabel = center:Find("NameText"):GetComponent(TypeText)
    this.ruleLabel = center:Find("RuleText"):GetComponent(TypeText)
    this.difenLabel = center:Find("DiFenText"):GetComponent(TypeText)

    local poolTips = this:Find("PoolTips")
    this.poolTipsGo = poolTips.gameObject
    this.poolTipsLabel = poolTips:Find("Text"):GetComponent(TypeText)

    local poolNode = this:Find("PoolNode")
    this.poolItemContent = poolNode
    this.poolItemPrefab = poolNode:Find("Item").gameObject
    UIUtil.SetActive(this.poolItemPrefab, false)
    local temp = poolNode:Find("Main")
    this.poolItems = {}
    local item = {}
    item.transform = temp
    item.gameObject = temp.gameObject
    item.label = temp:Find("Text"):GetComponent(TypeText)
    table.insert(this.poolItems, item)

    --处理飞筹码的坐标
    TpAnimMgr.betPosition = RectTransformUtility.WorldToScreenPoint(UIConst.uiCamera, poolNode.position)
    --处理发牌的坐标
    TpAnimMgr.dealCardPosition = TpAnimMgr.betPosition

    --左下
    local bottomLeft = this:Find("BottomLeft")

    --右下
    local bottomRight = this:Find("BottomRight")
    this.chatBtn = bottomRight:Find("ChatBtn").gameObject
    this.quitBtn = bottomRight:Find("QuitBtn").gameObject

    local bottom = this:Find("Bottom")
        
    local menuNode = this:Find("MenuNode")
    this.menuNodeGo = menuNode.gameObject
    this.ruleBtn = menuNode:Find("RuleBtn").gameObject
    this.settingBtn = menuNode:Find("SettingBtn").gameObject
    this.quitBtn2 = menuNode:Find("QuitBtn").gameObject

    --
    --初始打牌管理
    TpPlayCardMgr.Initialize(this.playerItems, this:Find("Cards"))

    this.watchingGo = this:Find("Watching").gameObject
    this.waitingGo = this:Find("Waiting").gameObject

    this.startBtn = this:Find("StartBtn").gameObject
    

    -- --信号和Ping值
    this.stateInfoTrans = this:Find("StateInfo")
    this.iconSignalTran = this.stateInfoTrans:Find("IconSignal")
    this.iconSignalValueGO = this.iconSignalTran:Find("IconSignalValue").gameObject
    this.iconSignalValueSpriteAtlas = this.iconSignalValueGO:GetComponent("UISpriteAtlas")
    this.iconSignalValueImage = this.iconSignalValueGO:GetComponent(TypeImage)

    this.iconWifiTran = this.stateInfoTrans:Find("IconWifi")
    this.iconWifiValueGO = this.iconWifiTran:Find("IconWifiValue").gameObject
    this.iconWifiValueGOSpriteAtlas = this.iconWifiValueGO:GetComponent("UISpriteAtlas")
    this.iconWifiValueImage = this.iconWifiValueGO:GetComponent(TypeImage)
    this.pingTxt = this.stateInfoTrans:Find("PingTxt"):GetComponent(TypeText)

    this.AddUIListenerEvent()

    --设置UI的偏移
    --this.CheckAndUpdateUIOffset()
end

--当面板开启时
function TpRoomPanel:OnOpened(argsData)
    TpRoomPanel.Instance = self
    this.AddListenerEvent()

    --更新固定显示
    --this.UpdateRoomDisplay()
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
    --更新桌布
    this.UpdateTablecloth()
    --
    this.SetMenuNodeDisplay(false)
    --
    this.Reset()

    --通知Room面板已经打开
    SendEvent(CMD.Game.Tp.DeskPanelOpened)
end

--当面板关闭时调用
function TpRoomPanel:OnClosed()
    --
    TpRoomPanel.Instance = nil
    --
    this.chatPlayers = nil
    --停止获取电量
    --AppPlatformHelper.StopGetBatteryStateOnRoom()
    --聊天管理器卸载
    ChatModule.UnInit()
    --
    this.RemoveListenerEvent()
    this.StopServerTimeTimer()
    this.StopCheckNetTypeTimer()
    this.Clear()
end

------------------------------------------------------------------
--
function TpRoomPanel.AddListenerEvent()
    --电量监听
    AddEventListener(CMD.Game.BatteryState, this.OnBatteryState)
    AddEventListener(CMD.Game.Ping, this.OnNetPing)
    AddEventListener(CMD.Game.WindowResize, this.OnWindowResize)
end
--
function TpRoomPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Game.BatteryState, this.OnBatteryState)
    RemoveEventListener(CMD.Game.Ping, this.OnNetPing)
    RemoveEventListener(CMD.Game.WindowResize, this.OnWindowResize)
end

--UI相关事件
function TpRoomPanel.AddUIListenerEvent()
    this:AddOnClick(this.menuBtn, this.OnMenuBtnClick)
    this:AddOnClick(this.startBtn, this.OnStartBtnClick)
    this:AddOnClick(this.ruleBtn, this.OnRuleBtnClick)
    this:AddOnClick(this.settingBtn, this.OnSettingBtnClick)
    this:AddOnClick(this.quitBtn, this.OnQuitBtnClick)
    this:AddOnClick(this.quitBtn2, this.OnQuitBtnClick)
    
    --
    --注册语音事件
    --ChatModule.RegisterVoiceEvent(this.speechBtn)
    --注册聊天按钮
    ChatModule.RegisterChatTextEvent(this.chatBtn)
    for i = 1, #this.playerItems do
        local item = this.playerItems[i]
        this:AddOnClick(item.headBtn, function() this.OnPlayerHeadClick(item) end)
    end
end
------------------------------------------------------------------
--
--根据屏幕是否为2比1设置偏移
function TpRoomPanel.CheckAndUpdateUIOffset()
    if this.isInitOffset == false then
        this.isInitOffset = true
        local offsetX = Global.GetOffsetX()
    end
end

------------------------------------------------------------------
--
--重置玩家显示
function TpRoomPanel.ResetPlayerDisplay()
    for i = 1, TpMaxPlayerTotal do
        this.playerItems[i]:Reset()
    end
end

--清除玩家显示
function TpRoomPanel.ClearPlayerDisplay()
    for i = 1, TpMaxPlayerTotal do
        this.playerItems[i]:Clear()
    end
end

--界面重置，用于小局
function TpRoomPanel.Reset()
    LogError(">> TpRoomPanel.Reset > ======== > Reset.")
    TpPlayCardMgr.Reset()
    --
    this.ResetPlayerDisplay()
    this.ResetPoolDisplay()
    this.SetPoolTipsDisplay(false)
    this.SetWatchingDisplay(false)
    this.SetQuitBtnDisplay(false)
    this.SetStartBtnDisplay(false)
    this.StopSettlementChipTimer()
    TpAnimMgr.ClearChip()
end

--界面清除，用于退出
function TpRoomPanel.Clear()
    this.gameIndex = nil
    this.lastPlayerTotal = nil
    this.lastGameStatus = nil
    this.Reset()
    TpPlayCardMgr.Clear()
    this.ClearPlayerDisplay()
end

------------------------------------------------------------------

--检查玩家总数更新，并调整Item位置等相关修改
function TpRoomPanel.CheckPlayerTotalUpdate()
    LogError(">> TpRoomPanel.CheckPlayerTotalUpdate", this.lastPlayerTotal , TpDataMgr.playerTotal)
    if this.lastPlayerTotal ~= TpDataMgr.playerTotal then
        this.lastPlayerTotal = TpDataMgr.playerTotal

        local list = this.playerPositionDict[this.lastPlayerTotal]

        local item = nil
        for i = 1, this.lastPlayerTotal do
            item = this.playerItems[i]
            item:SetPosition(list[i])
            item:UpdatePositionDisplay()
        end

        for i = this.lastPlayerTotal + 1, TpMaxPlayerTotal do
            this.playerItems[i]:Clear()
        end

        --光
        this.lightItems = nil
        for k, v in pairs(this.lightItemDict) do
            if k == this.lastPlayerTotal then
                this.lightItems = v
            else
                UIUtil.SetActive(v.gameObject, false)
            end
        end
        if this.lightItems == nil then
            this.lightItems = this.lightItemDict[9]
        end
        UIUtil.SetActive(this.lightItems.gameObject, true)
        for i = 1, #this.lightItems.list do
            this.SetLightDisplay(i, false)
        end
    end
end

------------------------------------------------------------------
--
--电量设置
function TpRoomPanel.OnBatteryState(value)
    this.UpdateEnergyValue(value)
end

--网络Ping值更新
function TpRoomPanel.OnNetPing(value)
    this.UpdateNetPing(value)
end

--窗口变化
function TpRoomPanel.OnWindowResize()
    for i = 1, #this.playerItems do
        this.playerItems[i]:Resize()
    end
end

------------------------------------------------------------------
--
function TpRoomPanel.OnSettingBtnClick()
    PanelManager.Open(TpPanelConfig.Setup)
    this.SetMenuNodeDisplay(false)
end

--
function TpRoomPanel.OnMenuBtnClick()
    this.SetMenuNodeDisplay(not this.lastMenuNodeDisplay)
end

function TpRoomPanel.OnStartBtnClick()
    if this.startBtnClickTime == nil then
        this.startBtnClickTime = 0
    end
    if this.startBtnClickTime < Time.realtimeSinceStartup then
        this.startBtnClickTime = Time.realtimeSinceStartup + 1
        TpCommand.SendStartGame()
    end
end

--
function TpRoomPanel.OnRuleBtnClick()
    PanelManager.Open(TpPanelConfig.Rule, GameType.Tp, TpDataMgr.rules)
    this.SetMenuNodeDisplay(false)
end

--
function TpRoomPanel.OnQuitBtnClick()
    this.SetMenuNodeDisplay(false)
    if TpDataMgr.isPlayback then
        return
    end
    local mainPlayerData = TpDataMgr.GetMainPlayerData()
    if mainPlayerData ~= nil and mainPlayerData.seatIndex > 0 and TpDataMgr.IsRoomBegin() then
        Toast.Show("游戏进行中，无法退出房间")
        return
    end
    TpCommand.SendQuitRoom()
end


--玩家显示项点击
function TpRoomPanel.OnPlayerHeadClick(item)
    if TpDataMgr.isPlayback then
        return
    end
    local playerData = TpDataMgr.GetPlayerDataByLocalIndex(item.index)
    if playerData == nil then
        LogError(">> TpRoomPanel > OnPlayerItemClick > playerData is nil")
        return
    end
    LogError(" 德扑--游戏内不显示点击玩家头像界面 ")
    -- PanelManager.Open(PanelConfig.RoomUserInfo, playerData)
end

------------------------------------------------------------------
--更新桌布
function TpRoomPanel.UpdateTablecloth(id)
    -- if id == nil then
    --     id = TpUtil.GetTableclothId()
    -- end
    -- local sprite = TpResourcesMgr.GetSprite("TpDeskBackground" .. id)
    -- if sprite ~= nil then
    --     this.tableclothImage.sprite = sprite
    -- end
end

--更新房间显示
function TpRoomPanel.UpdateRoomDisplay()
    -- if TpDataMgr.isPlayback then
    --     this.tipsLabel.text = ""
    -- else
    --     local lineStr = nil
    --     if TpDataMgr.serverLine == nil then
    --         lineStr = "0"
    --     else
    --         lineStr = math.floor(TpDataMgr.serverLine % 100)
    --         if lineStr < 10 then
    --             lineStr = tostring(lineStr)
    --         else
    --             lineStr = tostring(lineStr)
    --         end
    --     end

    --     local temp = "" .. Functions.GetResVersionStr(GameType.Tp)
    --     temp = temp .. "." .. lineStr
    --     this.tipsLabel.text = temp
    -- end
    --
end

--更新房间桌子显示
function TpRoomPanel.UpdateRoomTableDisplay()
    --this.playWayLabel.text = TpConfig.GetPlayWayNameByType(TpDataMgr.playWayType)
    --this.nameLabel.text = "房间号:" .. TpDataMgr.roomId
    --
    local temp = "%s 房间号:%s 局数:%s/%s"
    this.roomLabel.text = string.format(temp, TpDataMgr.playWayName, TpDataMgr.roomId, TpDataMgr.gameIndex, TpDataMgr.gameTotal)
    --
    this.tipsLabel.text = this.GetDeskRuleTxt()
end

--获取房间桌子规则文本
function TpRoomPanel.GetDeskRuleTxt()
    if this.deskRuleText == nil or this.lastQianZhu ~= TpDataMgr.qianZhu or this.lastLimit ~= TpDataMgr.limit then
        local temp = "前注:%s(%s)"
        local tempLimit = ""
        if TpDataMgr.limit == 0 then
            tempLimit = "不封顶"
        else
            tempLimit = TpDataMgr.limit .. "倍封顶"
        end
        this.deskRuleText = string.format(temp, TpDataMgr.qianZhu, tempLimit)
    end
    return this.deskRuleText
end

------------------------------------------------------------------
--
--设置开始按钮显示
function TpRoomPanel.SetStartBtnDisplay(display)
    if this.lastStartBtnDisplay ~= display then
        this.lastStartBtnDisplay = display
        UIUtil.SetActive(this.startBtn, display)
    end
end

--设置观战中显示
function TpRoomPanel.SetWatchingDisplay(display)
    if this.lastWatchingDisplay ~= display then
        this.lastWatchingDisplay = display
        UIUtil.SetActive(this.watchingGo, display)
    end
end

--设置等待中显示
function TpRoomPanel.SetWaitingDisplay(display)
    if this.lastWaitingDisplay ~= display then
        this.lastWaitingDisplay = display
        UIUtil.SetActive(this.waitingGo, display)
    end
end

--设置桌面退出按钮显示
function TpRoomPanel.SetQuitBtnDisplay(display)
    if this.lastQuitBtnDisplay ~= display then
        this.lastQuitBtnDisplay = display
        UIUtil.SetActive(this.quitBtn, display)
    end
end

--设置菜单节点显示
function TpRoomPanel.SetMenuNodeDisplay(display)
    if this.lastMenuNodeDisplay ~= display then
        this.lastMenuNodeDisplay = display
        UIUtil.SetActive(this.menuNodeGo, display)
        UIUtil.SetActive(this.menuUpGo, display)
    end
end

--设置池文本显示
function TpRoomPanel.SetPoolTipsDisplay(display)
    if this.lastPoolTipsDisplay ~= display then
        this.lastPoolTipsDisplay = display
        UIUtil.SetActive(this.poolTipsGo, display)
    end
end

--设置光显示
function TpRoomPanel.SetLightDisplay(index, display)
    local item = this.lightItems.list[index]
    if item ~= nil then
        if item.lastDisplay ~= display then
            item.lastDisplay = display
            UIUtil.SetActive(item.gameObject, display)
        end
    end
end

------------------------------------------------------------------

--检查房间显示，包含了局数、游戏状态，操作ID这几个变量的检查变化
function TpRoomPanel.CheckRoomDisplay()
    if this.gameIndex ~= TpDataMgr.gameIndex then
        local temp = this.gameIndex 
        this.gameIndex = TpDataMgr.gameIndex
        --第一次不处理重置
        if temp ~= nil then
            --需要重置一些信息
            TpRoomMgr.Reset()
            --
            SendEvent(CMD.Game.Tp.Reset)
        end
        --更新桌子信息显示
        this.UpdateRoomTableDisplay()
    end
end

------------------------------------------------------------------
--外部调用
--更新显示通过进入游戏
function TpRoomPanel.UpdateDisplayByEnterGame()
    --
    this.CheckPlayerTotalUpdate()
    --
    this.CheckRoomDisplay()
    --
    this.CheckUpdateServerTime()
    --
    --
    TpPlayCardMgr.CheckUpdateByEnterGame()
    --
    this.UpdateGameStatusDisplay()
    --更新玩家显示
    this.UpdatePlayerDisplay()
    --处理倒计时
    this.UpdatePlayerCountdownDisplay()
    --
    this.UpdatePlayerOperateTypeDisplay()
    --
    this.CheckUpdateStartBtnDisplay()
    this.CheckUpdateWatchingDisplay()
    this.CheckUpdateQuitBtnDisplay()
    --
    TpPlayCardMgr.CheckUpdateCardsDisplay()
    --
    this.UpdatePlayerSettlementChipDisplay()
    --
end

--更新显示通过推送游戏状态
function TpRoomPanel.UpdateDisplayByGameStatus()
    --
    this.CheckRoomDisplay()
    --
    --
    TpPlayCardMgr.CheckUpdateByGameStatus()
    --
    this.UpdateGameStatusDisplay()
    --
    --
    this.UpdatePlayerDisplayByGameStatus()
    --处理倒计时
    this.UpdatePlayerCountdownDisplay()
    --
    this.UpdatePlayerOperateTypeDisplay()
    --
    this.CheckUpdateStartBtnDisplay()
    this.CheckUpdateWatchingDisplay()
    this.CheckUpdateQuitBtnDisplay()
    --
    TpPlayCardMgr.CheckUpdateCardsDisplay()
    --
    this.UpdatePlayerSettlementChipDisplay()
    --
    this.UpdatePlayerScoreDisplay()
    --#region
    this.UpdateBankerDisplay()
end

--更新显示通过坐下
function TpRoomPanel.UpdateDisplayBySitDown()
    --
    TpPlayCardMgr.CheckUpdateBySitDown()
    --
    --先暴力显示玩家相关
    --this.UpdatePlayerDisplay()
    --处理倒计时
    this.UpdatePlayerCountdownDisplay()
    --
    this.UpdatePlayerOperateTypeDisplay()
    --
    this.CheckUpdateStartBtnDisplay()
    this.CheckUpdateWatchingDisplay()
    this.CheckUpdateQuitBtnDisplay()
end

--更新显示，通过操作
function TpRoomPanel.UpdateDisplayByOperate()
    --
    TpPlayCardMgr.CheckUpdateByOperate()
    --
    this.UpdatePlayerOperateTypeDisplay()
    this.UpdatePlayerScoreDisplay()
    this.UpdatePlayerBetChipDisplay()
end

--更新显示，通过发牌
function TpRoomPanel.UpdateDisplayByDeal()
    TpPlayCardMgr.CheckUpdateByDeal()
end

--更新游戏状态
function TpRoomPanel.UpdateGameStatusDisplay()
    if this.lastGameStatus ~= TpDataMgr.gameStatus then
        this.lastGameStatus = TpDataMgr.gameStatus

        if this.lastGameStatus < TpGameStatus.DealPoker1 then
            this.SetWaitingDisplay(true)
        else
            this.SetWaitingDisplay(false)
        end

        --将上一阶段的玩家信息中的下注金额置为0
        TpDataMgr.ResetBetAmount()
    end
end


--更新庄位显示
function TpRoomPanel.UpdateBankerDisplay()
    local playerItem = nil
    local playerData = nil

    for i = 1, TpDataMgr.playerTotal do
        playerItem = this.playerItems[i]
        playerData = TpDataMgr.GetPlayerDataByLocalIndex(i)
        if playerItem ~=nil and playerData ~= nil then
            this.UpdatePlayerZhuangBySingle(playerItem, playerData)
        end
    end
end

--更新玩家显示，在游戏没有开始的时候更新使用
--需要更新：1.玩家名称、头像等线上；2.玩家在线状态；3.玩家准备状态；
function TpRoomPanel.UpdatePlayerDisplay()
    local playerData = nil
    local playerItem = nil

    --更新所有玩家信息
    for i = 1, TpDataMgr.playerTotal do
        playerData = TpDataMgr.GetPlayerDataByLocalIndex(i)
        playerItem = this.playerItems[i]
        if playerItem ~= nil then
            if playerData == nil then
                playerItem:Clear()
            else
                playerItem:SetInfoDisplay(true)
                this.UpdatePlayerItemBySingle(playerItem, playerData)
                this.UpdatePlayerOnlineBySingle(playerItem, playerData)
                this.UpdatePlayerReadyBySingle(playerItem, playerData)
                this.UpdatePlayerScoreBySingle(playerItem, playerData)
                this.UpdatePlayerSetBetChipBySingle(playerItem, playerData)
                this.UpdatePlayerZhuangBySingle(playerItem, playerData)
            end
        end
    end
    this.HandleCheckPlayerHeadImage()
    this.UpdateChatPlayers()
end

--更新玩家通过游戏状态更新
function TpRoomPanel.UpdatePlayerDisplayByGameStatus()
    -- local playerData = nil
    -- local playerItem = nil
    -- --更新所有玩家信息
    -- for i = 1, TpDataMgr.playerTotal do
    --     playerData = TpDataMgr.GetPlayerDataByLocalIndex(i)
    --     playerItem = this.playerItems[i]
    --     if playerItem ~= nil and playerData ~= nil then

    --     end
    -- end
end

--处理检测玩家头像
function TpRoomPanel.HandleCheckPlayerHeadImage()
    local playerData = nil
    local playerItem = nil
    local tempPlayers = {}
    local tempPlayer = nil
    for i = 1, TpDataMgr.playerTotal do
        playerData = TpDataMgr.GetPlayerDataByLocalIndex(i)
        playerItem = this.playerItems[i]
        if playerItem ~= nil and playerData ~= nil then
            --{seatIndex = 0, id = 0, image = nil, headUrl = nil}
            tempPlayer = { seatIndex = playerData.seatIndex, id = playerData.id, image = playerItem.headImage, headUrl = playerData.headUrl }
            table.insert(tempPlayers, tempPlayer)
        end
    end
    if #tempPlayers > 0 then
        RoomUtil.StartCheckPlayerHeadImage(tempPlayers)
    end
end

--更新玩家准备
function TpRoomPanel.UpdatePlayerReadyDisplay()
    local playerData = nil
    local playerItem = nil
    for i = 1, TpDataMgr.playerTotal do
        playerData = TpDataMgr.GetPlayerDataByLocalIndex(i)
        playerItem = this.playerItems[i]
        if playerItem ~= nil and playerData ~= nil then
            this.UpdatePlayerReadyBySingle(playerItem, playerData)
        end
    end
    this.UpdateButtonDisplayByReady()
end

--更新玩家的操作状态
function TpRoomPanel.UpdatePlayerOperateTypeDisplay()
    local isOperateCountdown = TpDataMgr.gameStatus == TpGameStatus.Round1 or TpDataMgr.gameStatus == TpGameStatus.Round2 or TpDataMgr.gameStatus == TpGameStatus.Round3

    local playerData = nil
    local playerItem = nil
    for i = 1, TpDataMgr.playerTotal do
        playerData = TpDataMgr.GetPlayerDataByLocalIndex(i)
        playerItem = this.playerItems[i]
        if playerItem ~= nil and playerData ~= nil then
            if isOperateCountdown and TpDataMgr.operateId == playerData.id then
                playerItem:UpdateOperateType(playerData.operateType, true)
            else
                playerItem:UpdateOperateType(playerData.operateType, false)
            end
        end
    end

end

--更新玩家倒计时显示，包括操作
function TpRoomPanel.UpdatePlayerCountdownDisplay()
    local isOperateCountdown = TpDataMgr.gameStatus == TpGameStatus.Round1 or TpDataMgr.gameStatus == TpGameStatus.Round2 or TpDataMgr.gameStatus == TpGameStatus.Round3
    local playerData = nil
    local playerItem = nil
    for i = 1, TpDataMgr.playerTotal do
        playerData = TpDataMgr.GetPlayerDataByLocalIndex(i)
        playerItem = this.playerItems[i]
        if playerItem ~= nil then
            if playerData ~= nil then
                --操作玩家
                if isOperateCountdown and TpDataMgr.operateId == playerData.id then
                    playerItem:UpdateCountdown(TpDataMgr.countdown, TpDataMgr.countdownTotal)
                    this.SetLightDisplay(i, true)
                else
                    playerItem:UpdateCountdown(0)
                    this.SetLightDisplay(i, false)
                end
            else
                playerItem:UpdateCountdown(0)
                this.SetLightDisplay(i, false)
            end
        end
    end
end

--更新玩家下注筹码
function TpRoomPanel.UpdatePlayerBetChipDisplay()
    LogError(">> TpRoomPanel.UpdatePlayerBetChipDisplay")
    if TpDataMgr.gameStatus == TpGameStatus.Round1 
        or TpDataMgr.gameStatus == TpGameStatus.Round2
        or TpDataMgr.gameStatus == TpGameStatus.Round3 then
        --播放下注
        local playerData = nil
        local playerItem = nil
        for i = 1, TpDataMgr.playerTotal do
            playerData = TpDataMgr.GetPlayerDataByLocalIndex(i)
            playerItem = this.playerItems[i]
            if playerItem ~= nil and playerData ~= nil then
                this.UpdatePlayerPlayBetChipBySingle(playerItem, playerData)
            end
        end
    end
end

--更新播放单个玩家下注筹码
function TpRoomPanel.UpdatePlayerPlayBetChipBySingle(playerItem, playerData)
    playerItem:PlayBetChip(playerData.betScore)
end


--更新玩家结算筹码
function TpRoomPanel.UpdatePlayerSettlementChipDisplay()
    LogError(">> TpRoomPanel.UpdatePlayerSettlementChipDisplay")
    if this.lastSettlementChipGameStatus ~= TpDataMgr.gameStatus then
        this.lastSettlementChipGameStatus = TpDataMgr.gameStatus
        if TpDataMgr.gameStatus == TpGameStatus.DealPoker1 
            or TpDataMgr.gameStatus == TpGameStatus.DealPoker2
            or TpDataMgr.gameStatus == TpGameStatus.DealPoker3 then
            --检测结算筹码
            this.CheckSettlementChip(false)
        elseif TpDataMgr.gameStatus == TpGameStatus.GameResult then
            --检测结算筹码
            this.CheckSettlementChip(true)
        elseif TpDataMgr.gameStatus == TpGameStatus.ReadyWait then
            LogError(">> TpRoomPanel.UpdatePlayerSettlementChipDisplay > ReadyWait.")
            this.StopSettlementChipTimer()
        end
    end
end

--如果有人下注，才进行处理结算筹码动画
function TpRoomPanel.CheckSettlementChip(isGameResult)
    LogError(">> TpRoomPanel.CheckSettlementChip", isGameResult)
    local isBetChip = false
    local playerData = nil
    local playerItem = nil
    for i = 1, TpDataMgr.playerTotal do
        playerData = TpDataMgr.GetPlayerDataByLocalIndex(i)
        playerItem = this.playerItems[i]
        if playerItem ~= nil and playerData ~= nil then
            if playerItem:IsBetChip() then
                isBetChip = true
                break
            end
        end
    end
    --有人下注
    if isBetChip then
        this.isFlyChipToPool = true
        this.flyChipToPoolTime = Time.realtimeSinceStartup + 0.4 + 0.2
        
        this.isUpdatePoolDisplay = true
        this.updatePoolDisplayTime = Time.realtimeSinceStartup + 0.4 + 0.2 + 0.4
    else
        this.isFlyChipToPool = false
        this.isUpdatePoolDisplay = false
    end

    if isGameResult then
        this.isPoolToPlayer = true
        if isBetChip then
            this.poolToPlayerTime = Time.realtimeSinceStartup + 0.4 + 0.2 + 0.4 + 0.2
        else
            this.poolToPlayerTime = Time.realtimeSinceStartup + 0.2 + 0.4 + 0.2
        end
    else
        this.isPoolToPlayer = false
    end

    if not this.isUpdatePoolDisplay then
        --更新池显示
        this.UpdatePoolDisplay()
    end
    
    if isBetChip or isGameResult then
        this.StartSettlementChipTimer()
    else
        this.StopSettlementChipTimer()
    end
end


--启动结算筹码计时器
function TpRoomPanel.StartSettlementChipTimer()
    LogError(">> TpRoomPanel.StartSettlementChipTimer")
    if this.settlementChipTimer == nil then
        this.settlementChipTimer = UpdateTimer.New(this.OnSettlementChipTimer)
    end
    this.settlementChipTimer:Start()
end

--停止结算筹码计时器
function TpRoomPanel.StopSettlementChipTimer()
    if this.settlementChipTimer ~= nil then
        this.settlementChipTimer:Stop()
    end
end

--处理结算筹码计时器
function TpRoomPanel.OnSettlementChipTimer()

    local isLoop = false

    if this.isFlyChipToPool then
        isLoop = true
        if Time.realtimeSinceStartup > this.flyChipToPoolTime then
            this.isFlyChipToPool = false
            this.UpdatePlayerSettlementChip()
        end
    end

    if this.isUpdatePoolDisplay then
        isLoop = true
        if Time.realtimeSinceStartup > this.updatePoolDisplayTime then
            this.isUpdatePoolDisplay = false
            --更新池显示
            this.UpdatePoolDisplay()
        end
    end

    if this.isPoolToPlayer then
        isLoop = true
        if Time.realtimeSinceStartup > this.poolToPlayerTime then
            this.isPoolToPlayer = false
            this.CheckUpdatePlayerSingleSettlementChip()
        end
    end
    
    if not isLoop then
        this.StopSettlementChipTimer()
    end
end

--更新结算筹码
function TpRoomPanel.UpdatePlayerSettlementChip()
    LogError(">> TpRoomPanel.UpdatePlayerSettlementChip")

    local playerData = nil
    local playerItem = nil
    for i = 1, TpDataMgr.playerTotal do
        playerData = TpDataMgr.GetPlayerDataByLocalIndex(i)
        playerItem = this.playerItems[i]
        if playerItem ~= nil and playerData ~= nil then
            this.UpdatePlayerPlaySettlementChipBySingle(playerItem, playerData)
        end
    end
end


--处理结算筹码
function TpRoomPanel.CheckUpdatePlayerSingleSettlementChip()
    LogError(">> TpRoomPanel.UpdatePlayerSingleSettlementChip", this.lastSettlementChipGameStatus)
    if this.lastSettlementChipGameStatus == TpGameStatus.GameResult then
        this.UpdatePlayerSingleSettlementChip()
    end
end

--更新小局结算筹码
function TpRoomPanel.UpdatePlayerSingleSettlementChip()
    TpAnimMgr.ClearChip()
    --隐藏池
    this.SetPoolTipsDisplay(false)
    this.ResetPoolDisplay()

    LogError(">> TpRoomPanel.UpdatePlayerSingleSettlementChip")
    local playerData = nil
    local playerItem = nil
    for i = 1, TpDataMgr.playerTotal do
        playerData = TpDataMgr.GetPlayerDataByLocalIndex(i)
        playerItem = this.playerItems[i]
        if playerItem ~= nil and playerData ~= nil then
            --处理结算金币相关
            playerItem:SetSettlementGold(playerData.gold, playerData.winGold)
            playerData.winGold = 0
        end
    end
    --TpAudioMgr.PlayCoin()
end

--更新播放单个玩家结算筹码
function TpRoomPanel.UpdatePlayerPlaySettlementChipBySingle(playerItem, playerData)
    playerItem:PlaySettlementChip(playerData.betScore)
end

--更新单个玩家下注筹码
function TpRoomPanel.UpdatePlayerSetBetChipBySingle(playerItem, playerData)
    playerItem:UpdateBetChip(playerData.betScore)
end

--更新显示，通过结算
function TpRoomPanel.UpdateDisplayBySingleSettlement(data)
    local playerData = nil
    local playerItem = nil
    for i = 1, TpDataMgr.playerTotal do
        playerData = TpDataMgr.GetPlayerDataByLocalIndex(i)
        playerItem = this.playerItems[i]
        if playerData ~= nil and playerItem ~= nil then
            if not playerData.isGiveUp and playerData.handCards ~= nil then
                playerItem:SetSettlementCards(playerData.handCards, playerData.px)
            end
        end
    end
end

--更新分数显示
function TpRoomPanel.UpdatePlayerScoreDisplay()
    local playerData = nil
    local playerItem = nil
    for i = 1, TpDataMgr.playerTotal do
        playerData = TpDataMgr.GetPlayerDataByLocalIndex(i)
        playerItem = this.playerItems[i]
        if playerItem ~= nil and playerData ~= nil then
            this.UpdatePlayerScoreBySingle(playerItem, playerData)
        end
    end
end

--更新池显示，要放在最后执行，因为在播放飞筹码动画时，不立即更新
function TpRoomPanel.UpdatePoolDisplay()
    LogError(">> TpRoomPanel.UpdatePoolDisplay")
    local total = 0
    if TpDataMgr.betPool ~= nil then
        total = total + TpDataMgr.betPool  
    end
    if TpDataMgr.sidePool ~= nil then
        for i = 1, #TpDataMgr.sidePool do
            total = total + TpDataMgr.sidePool[i]  
        end
    end
    if this.lastPoolTotal ~= total then
        this.lastPoolTotal = total
        --
        if this.lastPoolTotal > 0 then
            this.SetPoolTipsDisplay(true)
            this.poolTipsLabel.text = "底池：" .. this.lastPoolTotal
            --主池
            local item = this.GetPoolItem(1)
            this.SetPoolItemDisplay(item, true)
            item.label.text = TpDataMgr.betPool
            --边池
            if TpDataMgr.sidePool ~= nil then
                for i = 1, #TpDataMgr.sidePool do
                    item = this.GetPoolItem(i + 1)
                    this.SetPoolItemDisplay(item, true)
                    item.label.text = TpDataMgr.sidePool[i]
                end
            end
        else
            this.SetPoolTipsDisplay(false)
            this.ResetPoolDisplay()
        end
    end
end

------------------------------------------------------------------
--更新单个玩家的UI显示
function TpRoomPanel.UpdatePlayerItemBySingle(playerItem, playerData)
    --设置玩家基本信息
    playerItem:SetPlayerInfo(playerData.id, playerData.name)
    --处理头像即头像框
    this.CheckUpdatePlayerHead(playerItem, playerData)
end

--更新单个玩家的分数显示
function TpRoomPanel.UpdatePlayerScoreBySingle(playerItem, playerData)
    playerItem:UpdateGold(playerData.gold)
end

--更新单个玩家的在线状态
function TpRoomPanel.UpdatePlayerOnlineBySingle(playerItem, playerData)
    --主玩家始终在线
    if playerData.id == TpDataMgr.userId then
        playerItem:SetOnline(true)
    else
        playerItem:SetOnline(playerData.isOnline)
    end
end

--更新单个玩家的庄图标
function TpRoomPanel.UpdatePlayerZhuangBySingle(playerItem, playerData)
    playerItem:SetMasterDisplay(TpDataMgr.zhuangId == playerData.id)
end

--更新单个玩家的准备状态
function TpRoomPanel.UpdatePlayerReadyBySingle(playerItem, playerData)
    --由于该游戏不显示准备，所以这里先屏蔽了
    -- if TpDataMgr.gameStatus == TpGameStatus.ReadyWait then
    --     playerItem:SetReadyDisplay(playerData.isReady == true)
    -- else
    --     playerItem:SetReadyDisplay(false)
    -- end
end

------------------------------------------------------------------
--
--检查显示桌面开始按钮
function TpRoomPanel.CheckUpdateStartBtnDisplay()
    if not TpDataMgr.IsRoomBegin() and TpDataMgr.IsRoomOwner() and TpDataMgr.gameIndex <= 1 then
        this.SetStartBtnDisplay(true)
    else
        this.SetStartBtnDisplay(false)
    end
end

--检查显示观战中
function TpRoomPanel.CheckUpdateWatchingDisplay()
    local mainPlayerData = TpDataMgr.GetMainPlayerData()
    if mainPlayerData == nil or mainPlayerData.seatIndex < 1 then
        this.SetWatchingDisplay(true)
    else
        this.SetWatchingDisplay(false)
    end
end

--检查显示桌面退出按钮
function TpRoomPanel.CheckUpdateQuitBtnDisplay()
    local mainPlayerData = TpDataMgr.GetMainPlayerData()
    if mainPlayerData ~= nil and mainPlayerData.seatIndex > 0 and TpDataMgr.IsRoomBegin()then
        this.SetQuitBtnDisplay(false)
    else
        if TpDataMgr.gameIndex <= 1 then
            this.SetQuitBtnDisplay(true)
        end
    end
end

--界面打开的时候处理按钮显示
function TpRoomPanel.UpdateButtonDisplayByOpend()
    if TpDataMgr.isPlayback then
        UIUtil.SetActive(this.chatBtn, false)
        --UIUtil.SetActive(this.speechBtn, false)
    else
        -- UIUtil.SetActive(this.chatBtn, true)
        --UIUtil.SetActive(this.speechBtn, true)
    end
end

--准备后按钮更新
function TpRoomPanel.UpdateButtonDisplayByReady()

end

------------------------------------------------------------------
--内部调用
--更新玩家头像--ko
function TpRoomPanel.CheckUpdatePlayerHead(playerItem, playerData)
    if playerData.headUrl == playerItem.headUrl then
        return
    end
    playerItem.headUrl = playerData.headUrl
    local arg = { playerItem = playerItem, headUrl = playerData.headUrl }
    Functions.SetHeadImage(playerItem.headImage, playerData.headUrl, this.OnHeadImageLoadCompleted, arg)
end

--加载头像图片完成
function TpRoomPanel.OnHeadImageLoadCompleted(arg)
    if arg.playerItem ~= nil and arg.playerItem.headUrl == arg.headUrl then
        netImageMgr:SetImage(arg.playerItem.headImage, arg.headUrl)
    end
end

------------------------------------------------------------------
--更新所有玩家的在线状态
function TpRoomPanel.UpdatePlayerOnline()
    local playerData = nil
    local playerItem = nil
    for i = 1, TpDataMgr.playerTotal do
        playerData = TpDataMgr.GetPlayerDataByLocalIndex(i)
        playerItem = this.playerItems[i]
        if playerData ~= nil and playerItem ~= nil then
            this.UpdatePlayerOnlineBySingle(playerItem, playerData)
        end
    end
end

--更新扣除分数
function TpRoomPanel.UpdateDeductGold()
    local playerData = nil
    local playerItem = nil
    local isDeductGold = false

    for i = 1, TpDataMgr.playerTotal do
        playerData = TpDataMgr.GetPlayerDataByLocalIndex(i)
        playerItem = this.playerItems[i]
        if playerData ~= nil and playerItem ~= nil then
            --更新分数或者分数
            TpRoomPanel.UpdatePlayerScoreBySingle(playerItem, playerData)
            --播放动画
            if playerData.deductGold ~= 0 then
                --播放分数分数动画
                playerItem:PlayScoreAnim(playerData.deductGold)
                --设置是否有变化
                isDeductGold = true
                --处理完了就把数据重置了
                playerData.deductGold = 0
            end
        end
    end

    if isDeductGold then
        TpAudioMgr.PlayCoin()
    end
end

------------------------------------------------------------------
--获取播放特效的节点
function TpRoomPanel.GetEffectNode(seatIndex)
    local playerItem = this.playerItems[TpUtil.GetLocalIndexByServerIndex(seatIndex)]
    if playerItem ~= nil then
        return playerItem.effectNode
    else
        return this.effectNode
    end
end

------------------------------------------------------------------
--显示某个玩家的聊天气泡
function TpRoomPanel.OnShowChatBubble(playerId, duration, str, voiceResource)
    if IsNil(playerId) or IsNil(str) then
        LogError(">> TpRoomPanel.OnShowChatBubble > param == nil")
        return
    end
    local playerData = TpDataMgr.GetPlayerDataById(playerId)
    if playerData == nil then
        LogError(">> TpRoomPanel.OnShowChatBubble > playerData == nil")
        return
    end
    local playerItem = this.playerItems[TpUtil.GetLocalIndexByServerIndex(playerData.seatIndex)]
    if playerItem ~= nil then
        Functions.SetChatText(playerItem.chatFrameGo, playerItem.chatLabel, str)
        Audio.PlaySound("Tp/quick", voiceResource)
        --定时关闭
        Scheduler.scheduleOnceGlobal(function()
            UIUtil.SetActive(playerItem.chatFrameGo, false)
        end, duration)
    end
end

------------------------------------------------------------------
--检测更新服务器时间
function TpRoomPanel.CheckUpdateServerTime()
    this.StartServerTimeTimer()
    this.UpdateServerTimeDisplay()
end

--由于时间只显示到分钟，所有每10秒处理一次
function TpRoomPanel.StartServerTimeTimer()
    if this.serverTimeTimer == nil then
        this.serverTimeTimer = Timing.New(this.OnServerTimeTimer, 10)
        this.serverTimeTimer:Start()
    end
end

function TpRoomPanel.StopServerTimeTimer()
    if this.serverTimeTimer ~= nil then
        this.serverTimeTimer:Stop()
        this.serverTimeTimer = nil
    end
end

function TpRoomPanel.OnServerTimeTimer()
    this.UpdateServerTimeDisplay()
end

--设置更新服务器时间显示
function TpRoomPanel.UpdateServerTimeDisplay()
    TryCatchCall(this.OnUpdateServerTimeDisplay)
end

--更新服务器时间显示
function TpRoomPanel.OnUpdateServerTimeDisplay()
    if TpDataMgr.serverTimeStamp == nil then
        return
    end
    local temp = Time.realtimeSinceStartup - TpDataMgr.serverUpdateTime
    temp = temp + TpDataMgr.serverTimeStamp
    temp = TpUtil.GetMdhmByTimeStamp(temp / 1000)

    this.timeLabel.text = temp
end

------------------------------------------------------------------
--
--设置电量
function TpRoomPanel.UpdateEnergyValue(value)
    local num = value / 100
    this.energyValueImage.fillAmount = num

    local level = Functions.CheckEnergyLevel(value)
    if this.energyLevel == level then
        return
    end
    this.energyLevel = level
    if this.energyLevel == EnergyLevel.None then
        UIUtil.SetImageColor(this.energyValueImage, 1, 0, 0)
    else
        if this.energyLevel == EnergyLevel.Low then
            UIUtil.SetImageColor(this.energyValueImage, 1, 0, 0)
        else
            UIUtil.SetImageColor(this.energyValueImage, 1, 1, 1)
        end
    end
end

--检测更新网络Ping值
function TpRoomPanel.CheckUpdateNetPing()
    --初始设置30
    this.UpdateNetPing(30)
    --初始更新下网络类型
    this.UpdateNetType()
    --
    this.StartCheckNetTypeTimer()
end

--启动检测网络类型
function TpRoomPanel.StartCheckNetTypeTimer()
    if this.checkNetTypeTimer == nil then
        this.checkNetTypeTimer = Timing.New(this.StartCheckNetTypeTimer, 10)
    end
    this.checkNetTypeTimer:Start()
end

--停止检测网络类型
function TpRoomPanel.StopCheckNetTypeTimer()
    if this.checkNetTypeTimer ~= nil then
        this.checkNetTypeTimer:Stop()
    end
end

--处理检测网络类型
function TpRoomPanel.OnCheckNetTypeTimer()
    this.UpdateNetType()
end

--更新网络类型
function TpRoomPanel.UpdateNetType()
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
function TpRoomPanel.UpdateNetPing(value)
    -- --
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
--初始化聊天系统
function TpRoomPanel.InitChatManager()
    if TpDataMgr.isPlayback then
        return
    end

    LogError(">> TpRoomPanel.InitChatManager")

    --当前游戏参数
    ChatModule.SetChatCallback(this.OnShowChatBubble)
    local config = {
        audioBundle = TpBundleName.Quick,
        textChatConfig = TpChatLabelArr,
        languageType = LanguageType.putonghua,
    }
    ChatModule.SetChatConfig(config)

    --初始化基本信息
    ChatModule.Init(PanelConfig.RoomChat, PanelConfig.RoomUserInfo)
end

--玩家数据更新
function TpRoomPanel.UpdateChatPlayers()
    if TpDataMgr.isPlayback then
        return
    end
    if this.chatPlayers ~= nil then
        --检查玩家是否有变化
        local temp = nil
        local isChanged = false
        local count = 0
        for i = 1, #TpDataMgr.playerDatas do
            temp = TpDataMgr.playerDatas[i]
            if temp.seatIndex > 0 then
                count = count + 1
            end
        end
        local length = #this.chatPlayers
        if length == count then
            --人数相等，需要比较ID和座位号
            local temp2 = nil
            local isExist = false
            for i = 1, length do
                temp = this.chatPlayers[i]
                isExist = false
                for j = 1, #TpDataMgr.playerDatas do
                    temp2 = TpDataMgr.playerDatas[j]
                    if temp.id == temp2.id and temp.seatIndex == temp2.seatIndex then
                        isExist = true
                        break
                    end
                end
                if not isExist then
                    isChanged = true
                    break
                end
            end
        else
            isChanged = true
        end
        if not isChanged then
            return
        end
        LogError(">> TpRoomPanel.UpdateChatPlayers > Changed.")
    end

    this.chatPlayers = {}
    local players = {}
    local playerData = nil
    local playerItem = nil
    local temp = nil
    for i = 1, TpDataMgr.playerTotal do
        playerData = TpDataMgr.GetPlayerDataByLocalIndex(i)
        playerItem = this.playerItems[i]
        if playerData ~= nil and playerItem ~= nil then
            temp = {}
            temp.id = playerData.id
            temp.seatIndex = playerData.seatIndex
            temp.gender = playerData.gender
            temp.name = playerData.name
            temp.emotionNode = playerItem.faceAnimNode
            temp.animNode = playerItem.headAnimNode
            players[playerData.id] = temp
            table.insert(this.chatPlayers, temp)
        end
    end
    ChatModule.SetPlayerInfos(players)
end

--================================================================
--重置池显示
function TpRoomPanel.ResetPoolDisplay()
    LogError(">> TpRoomPanel.ResetPoolDisplay")
    this.lastPoolTotal = nil
    for i = 1, #this.poolItems do
        this.SetPoolItemDisplay(this.poolItems[i], false)
    end
end

--设置池显示项显示
function TpRoomPanel.SetPoolItemDisplay(item, display)
    if item.lastDisplay ~= display then
        item.lastDisplay = display
        UIUtil.SetActive(item.gameObject, display)
    end
end

--获取池显示项
function TpRoomPanel.GetPoolItem(index)
    local item = this.poolItems[index]
    if item == nil then
        item = {}
        item.gameObject = CreateGO(this.poolItemPrefab, this.poolItemContent, tostring(index))
        item.transform = item.gameObject.transform
        item.label = item.transform:Find("Text"):GetComponent(TypeText)
        table.insert(this.poolItems, item)
    end
    return item
end

--================================================================