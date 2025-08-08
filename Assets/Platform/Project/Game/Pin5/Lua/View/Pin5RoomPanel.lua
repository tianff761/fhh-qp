Pin5RoomPanel = ClassPanel("Pin5RoomPanel")
local this = Pin5RoomPanel

local transform
--当前玩家item
local curPlayerItems = nil
local selfCtrl = nil

this.HideType = 0

function Pin5RoomPanel:OnInitUI()
    self:InitPanel()
    self.ctrl = require(Pin5CtrlNames.Room)
    self.ctrl:Init(transform)
    selfCtrl = self.ctrl
    SendMsg(Pin5Action.Pin5LoadEnd, 2)
    self:AddClickEvent()
end

function Pin5RoomPanel:InitPanel()
    transform = self.transform

    Pin5Const.RoomTopNode = transform:Find("Top")

    -- 左上角的房间信息
    local roomInfoUI = {}
    roomInfoUI.transform = transform:Find("TopLeft")
    roomInfoUI.gameObject = roomInfoUI.gameObject
    roomInfoUI.roomCodeGo = roomInfoUI.transform:Find("RoomCode").gameObject
    roomInfoUI.roomCodeText = roomInfoUI.roomCodeGo:GetComponent("Text")
    roomInfoUI.gameTypeText = roomInfoUI.transform:Find("GameType"):GetComponent("Text")
    roomInfoUI.juShuGo = roomInfoUI.transform:Find("JuShu").gameObject
    roomInfoUI.juShuText = roomInfoUI.juShuGo:GetComponent("Text")
    roomInfoUI.diFenText = roomInfoUI.transform:Find("DiFen"):GetComponent("Text")


    roomInfoUI.verNetTran = roomInfoUI.transform:Find("VerNet")
    roomInfoUI.verNetTxt = roomInfoUI.verNetTran:Find("Text"):GetComponent("Text")
    this.roomInfoUI = roomInfoUI
    ------------------------------右上角信息-----------------------
    --其他显示信息
    this.timeText = transform:Find("TopRight/TimeTxt"):GetComponent(TypeText)
    this.stateInfoTrans = transform:Find("TopRight/StateInfo")
    local stateInfoImages = this.stateInfoTrans:GetComponent("UISpriteAtlas").sprites:ToTable()
    this.stateInfoImages = {}
    for i = 1, #stateInfoImages do
        this.stateInfoImages[stateInfoImages[i].name] = stateInfoImages[i]
    end

    --电量
    this.energyGO = this.stateInfoTrans:Find("Energy").gameObject 
    this.energyValueGO = this.stateInfoTrans:Find("Energy/Value").gameObject
    this.energyValueImage = this.energyValueGO:GetComponent(TypeImage)
    this.energyValueRedGO = this.stateInfoTrans:Find("Energy/ValueRed").gameObject
    this.energyValueRedImage = this.energyValueRedGO:GetComponent(TypeImage)
    this.energyNoActiveGO = this.stateInfoTrans:Find("EnergyNoActive").gameObject
    --流量信号
    this.iconSignalTran = this.stateInfoTrans:Find("IconSignal")
    this.iconSignalValueGO = this.iconSignalTran:Find("IconSignalValue").gameObject
    this.iconSignalValueImage = this.iconSignalValueGO:GetComponent(TypeImage)
    --Wifi信号
    this.iconWifiTran = this.stateInfoTrans:Find("IconWifi")
    this.iconWifiValueGO = this.iconWifiTran:Find("IconWifiValue").gameObject
    this.iconWifiValueImage = this.iconWifiValueGO:GetComponent(TypeImage)
    this.pingTxt = this.stateInfoTrans:Find("PingTxt"):GetComponent(TypeText)


    this.rightTop = transform:Find("RightTop")

    this.menu = this.rightTop:Find("Menu")
    this.menuDwon = this.menu:Find("Dwon").gameObject
    this.menuUp = this.menu:Find("Up").gameObject
    this.menuItems = this.menu:Find("Items")

    this.itemMaskBtn = this.menu:Find("MenuMaskBtn").gameObject
    ----------------------------菜单栏-------------------------------
    this.leaveBtn = this.menuItems:Find("LeaveBtnCol/LeaveBtn")
    this.disableLeaveBtn = this.menuItems:Find("LeaveBtnCol/DisableLeaveBtn").gameObject

    this.ruleBtn = this.menuItems:Find("RuleBtn")
    this.WatcherListBtn = this.menuItems:Find("WatcherListBtn")


    --不可点击
    this.dismiss = this.menuItems:Find("DismissBtnCol")
    this.dismissBtn = this.dismiss:Find("DismissBtn")
    this.disableDismissBtn = this.dismiss:Find("DisableDismissBtn").gameObject
    --不可点击
    this.setBtn = this.menuItems:Find("SetBtn")
    this.Retrospect = this.menuItems:Find("RetrospectBtnCol")
    this.retrospectBtn = this.Retrospect:Find("RetrospectBtn")
    this.disableRetrospectBtn = this.Retrospect:Find("DisableRetrospectBtn").gameObject
    --不可点击
    ------------------------------按钮--------------------------
    this.btns = transform:Find("Btns")
    ------------------------------坐下和开始------------------------
    local beginning = this.btns:Find("Start")
    this.startBtn = beginning:Find("StartBtn").gameObject
    this.startButton = this.startBtn:GetComponent(TypeButton)
    this.sitDownBtn = beginning:Find("SitDownBtn").gameObject
    this.readyBtn = beginning:Find("ReadyBtn").gameObject
    this.noStartBtn = beginning:Find("StartBtn/NoStartBtn").gameObject
    --
    this.autoFlip = this.btns:Find("AutoFlip")
    this.autoFlipToggle = this.autoFlip:GetComponent("Toggle")
    this.autoFlipToggle.isOn = Pin5RoomData.isAutoFlipCard or (PlayerPrefs.GetInt("AutoFlip") == 1 and true or false)
    ------------------------------复制和邀请-----------------------
    this.copyInvite = this.btns:Find("CopyInvite")
    this.copyBtn = this.copyInvite:Find("CopyBtn")
    ------------------------------聊天和语音以及准备----------------
    this.chatVoice = this.btns:Find("ChatVoice")
    this.chatBtn = this.chatVoice:Find("ChatBtn")
    this.voiceBtn = this.chatVoice:Find("VoiceBtn")
    this.voiceSpeech = this.voiceBtn:GetComponent("ButtonSpeech")
    --------------------------观看与等待----------------------------
    this.watchShow = this.btns:Find("WatchShow")
    this.watchGo = this.watchShow:Find("Watch").gameObject
    this.waitGo = this.watchShow:Find("Wait").gameObject
    this.quitBtn = this.watchShow:Find("Watch/QuitButton").gameObject
    ------------------------------其他按钮-------------------------


    ---------------------------------------------------------------
    local tips = transform:Find("Tips")
    this.tipsGo = tips.gameObject
    this.tipsLabel = tips:Find("Label"):GetComponent(TypeText)

    ------------------------------玩家-----------------------------
    local playerItems = transform:Find("PlayerItems")
    this.playerItems = {}
    --获取十人的
    for i = 1, 10 do
        local playerItem = Pin5PlayerItem.New(playerItems:Find("Player" .. i), i)
        table.insert(this.playerItems, playerItem)
    end

    this.CoinEffect = transform:Find("CoinEffect")
    this.CoinEffectText = this.CoinEffect:GetComponent(TypeText)

    local atlas = this.rightTop:GetComponent(TypeSpriteAtlas)
    this.tableSprites = atlas.sprites:ToTable()
    this.awardPoolBtnTran = this.rightTop:Find("AwardPoolButton")
    local columnParent = this.awardPoolBtnTran:Find("text")
    this.awardPoolBtn = this.awardPoolBtnTran:GetComponent(TypeButton)
    this.awardColumnTab = {}
    for i = columnParent.childCount - 1, 0, -1 do
        table.insert(this.awardColumnTab, columnParent:GetChild(i))
    end
end

--获取玩家预设体
function Pin5RoomPanel.GetPlayerItem(i, parent)
    local transform = parent:Find("Player" .. i)
    return Pin5PlayerItem.New(transform, i)
end

--增加点击事件
function Pin5RoomPanel:AddClickEvent()
    --规则按钮
    this:AddOnClick(this.ruleBtn.gameObject, selfCtrl.OnClickRule)
    --观战列表弹窗按钮
    this:AddOnClick(this.WatcherListBtn.gameObject, selfCtrl.OnClickWatcherListBtn)
    --复制按钮
    this:AddOnClick(this.copyBtn.gameObject, selfCtrl.OnClickFuzhi)
    --聊天按钮
    -- ChatModule.RegisterChatTextEvent(this.chatBtn.gameObject)
    this:AddOnClick(this.chatBtn.gameObject, selfCtrl.OnClickChat)
    --语音
    ChatModule.RegisterVoiceEvent(this.voiceBtn.gameObject)
    --开始游戏按钮
    this:AddOnClick(this.startBtn, selfCtrl.OnClickStartBtn)
    --坐下按钮
    this:AddOnClick(this.sitDownBtn, selfCtrl.OnClickSitDownBtn)
    --准备按钮
    this:AddOnClick(this.readyBtn, selfCtrl.OnClickReady)
    --点击展开菜单栏
    this:AddOnClick(this.menuDwon, selfCtrl.OnClickDownMenu)
    --点击关闭菜单栏
    this:AddOnClick(this.menuUp, selfCtrl.OnClickUpMenu)
    --点击item按钮
    this:AddOnClick(this.itemMaskBtn, selfCtrl.OnClickUpMenu)
    --点击离开按钮
    this:AddOnClick(this.leaveBtn.gameObject, selfCtrl.OnClickLeaveBtn)
    --点击离开按钮
    this:AddOnClick(this.quitBtn, selfCtrl.OnClickLeaveBtn)
    --点击离开置灰按钮
    this:AddOnClick(this.disableLeaveBtn, selfCtrl.OnClickGreyLeaveBtn)

    --点击解散按钮
    this:AddOnClick(this.dismissBtn.gameObject, selfCtrl.OnClickDismissBtn)
    --点击设置按钮
    this:AddOnClick(this.setBtn.gameObject, selfCtrl.OnClickSetBtn)
    --点击回顾按钮
    this:AddOnClick(this.retrospectBtn.gameObject, selfCtrl.OnClickRetrospectBtn)
    --点击头像显示玩家信息
    self:AddClickPlayerIconEvent()
    ------------------------------------------
    --自动翻牌
    self:AddOnToggle(self.autoFlipToggle, selfCtrl.OnAutoFlipToggle)
    ---奖池按钮
    this:AddOnClick(this.awardPoolBtnTran, selfCtrl.OnAwardPoolBtnClick)

end

--挂载点击玩家头像弹窗事件
function Pin5RoomPanel:AddClickPlayerIconEvent()
    --绑定玩家头像按钮事件
    for i = 1, #this.playerItems do
        local item = this.playerItems[i].headBtn
        this:AddOnClick(item, HandlerArgs(selfCtrl.OnClickPlayerHead, item, this.playerItems[i]))
    end
end

-- 初始化面板--
function Pin5RoomPanel:OnOpened()
    self:InitData()
    selfCtrl:OnCreate()
    --播放背景音
    this.PlayMusice()
    --获取网络
    this.CheckUpdateNetPing()
    --设置站点及版本号
    this.SetVerNetTxt()
    --初始化聊天管理器
    Pin5Room.InitChatManager()
    --开启电量
    AppPlatformHelper.StartGetBatteryStateOnRoom()
end

--初始化界面
function Pin5RoomPanel:InitData()
    --是否是金币场
    if Pin5RoomData.IsGoldGame() then
        --主动开启
        UIUtil.SetActive(this.copyInvite, false)
        -- UIUtil.SetActive(this.dismiss, false)
        -- UIUtil.SetActive(this.roomInfoUI.juShuGo, false)
        this.SetStartBtnDisplay(false)
    else
        -- UIUtil.SetActive(this.dismiss, true)
        -- UIUtil.SetActive(this.roomInfoUI.juShuGo, true)
    end
    --是否是回放
    UIUtil.SetActive(this.menu, true)

    --是否禁止语音
    UIUtil.SetActive(this.voiceBtn, Pin5RoomData.isSpeech)
end

function Pin5RoomPanel.PlayMusice()
    local musicType = GetLocal(Pin5Action.Pin5BackMusic, 3)
    AudioManager.PlayBackgroud(Pin5BundleName.pin5Music, Pin5Musics[tonumber(musicType)])
end

--更新菜单按钮
function Pin5RoomPanel.UpdateMenuInfo()
    UIUtil.SetActive(this.dismiss, false)
    if Pin5RoomData.IsClubRoom() or Pin5RoomData.IsTeaRoom() or Pin5RoomData.IsUnionRoom() then
        if Pin5RoomData.IsFangKaFlow() then
            local InGame = not Pin5RoomData.IsObserver() and not Pin5RoomData.GetSelfIsWaiting()
            -- UIUtil.SetActive(this.dismiss, Pin5RoomData.IsGameStarted() and not InGame)
            UIUtil.SetActive(this.dismissBtn, Pin5RoomData.IsGameStarted() and not InGame)
            UIUtil.SetActive(this.disableDismissBtn, false)
            UIUtil.SetActive(this.disableLeaveBtn, Pin5RoomData.IsGameStarted() and InGame)
            --LogError("not Pin5RoomData.IsGameStarted() or not InGame", not Pin5RoomData.IsGameStarted() or not InGame)
            UIUtil.SetActive(this.leaveBtn, not Pin5RoomData.IsGameStarted() or not InGame)
        else
            -- UIUtil.SetActive(this.dismiss, false)
            UIUtil.SetActive(this.disableLeaveBtn, not Pin5RoomData.GetSelfIsExitRoom())
            UIUtil.SetActive(this.leaveBtn, Pin5RoomData.GetSelfIsExitRoom())
        end
    else
        --判断是否已开局
        if Pin5RoomData.IsGameStarted() then
            --是否在观战
            if Pin5RoomData.GetSelfIsWaiting() then
                -- UIUtil.SetActive(this.dismiss, false)
                UIUtil.SetActive(this.dismissBtn, false)
                UIUtil.SetActive(this.disableDismissBtn, true)
                UIUtil.SetActive(this.disableLeaveBtn, false)
                UIUtil.SetActive(this.leaveBtn, true)
            else
                -- UIUtil.SetActive(this.dismiss, true)
                UIUtil.SetActive(this.dismissBtn, true)
                UIUtil.SetActive(this.disableDismissBtn, false)
                UIUtil.SetActive(this.disableLeaveBtn, true)
                UIUtil.SetActive(this.leaveBtn, false)
            end
        else
            local selfIsOwner = Pin5RoomData.MainIsOwner()
            UIUtil.SetActive(this.disableLeaveBtn, selfIsOwner)
            -- UIUtil.SetActive(this.dismiss, selfIsOwner)
            UIUtil.SetActive(this.dismissBtn, selfIsOwner)
            UIUtil.SetActive(this.disableDismissBtn, not selfIsOwner)
            UIUtil.SetActive(this.leaveBtn, not selfIsOwner)
        end
    end

    -- --金币场兼容
    -- if Pin5RoomData.IsGoldGame() then
    --     if Pin5RoomData.GetSelfIsNoReady() then
    --         UIUtil.SetActive(this.leaveBtn, true)
    --         UIUtil.SetActive(this.disableLeaveBtn, false)
    --     else
    --         UIUtil.SetActive(this.leaveBtn, false)
    --         UIUtil.SetActive(this.disableLeaveBtn, true)
    --     end

    --     UIUtil.SetActive(this.dismissBtn, false)
    --     UIUtil.SetActive(this.disableDismissBtn, false)
    -- else
    --     --判断是否已开局
    --     if Pin5RoomData.IsGameStarted() then
    --         local selfData = Pin5RoomData.GetSelfData()
    --         --是否在观战
    --         if selfData.state == Pin5PlayerState.WAITING then
    --             UIUtil.SetActive(this.dismissBtn, false)
    --             UIUtil.SetActive(this.disableDismissBtn, true)
    --             UIUtil.SetActive(this.leaveBtn, true)
    --             UIUtil.SetActive(this.disableLeaveBtn, false)
    --         else
    --             UIUtil.SetActive(this.dismissBtn, true)
    --             UIUtil.SetActive(this.disableDismissBtn, false)
    --             UIUtil.SetActive(this.leaveBtn, false)
    --             UIUtil.SetActive(this.disableLeaveBtn, true)
    --         end
    --     else
    --         local selfIsOwner = Pin5RoomData.MainIsOwner()
    --         UIUtil.SetActive(this.dismissBtn, selfIsOwner)
    --         UIUtil.SetActive(this.disableDismissBtn, not selfIsOwner)

    --         if Pin5RoomData.clubId ~= 0 and Pin5RoomData.clubId ~= nil then
    --             UIUtil.SetActive(this.leaveBtn, true)
    --             UIUtil.SetActive(this.disableLeaveBtn, false)
    --         else
    --             UIUtil.SetActive(this.leaveBtn, not selfIsOwner)
    --             UIUtil.SetActive(this.disableLeaveBtn, selfIsOwner)
    --         end

    --     end
    -- end

    --是否禁止语音
    UIUtil.SetActive(this.voiceBtn, Pin5RoomData.isSpeech)


end
--========================================================================================玩家UI相关
--隐藏所有玩家手牌
function Pin5RoomPanel.ResetAllPlayerHandle()
    for i = 1, #Pin5RoomData.playerDatas do
        local playerData = Pin5RoomData.playerDatas[i]
        playerData:HideAllCard()
    end
end

--初始化玩家UI
function Pin5RoomPanel.InitPlayerUI()
    if curPlayerItems == nil then
        curPlayerItems = this.GetAllPlayerItems()
    end
    for i = 1, #curPlayerItems do
        local item = curPlayerItems[i]
        if item.playerId ~= nil then
            item:Reset()
        end
    end
end

--检测显示庄图标
function Pin5RoomPanel.CheckBankerTagByAllPlayer()
    local list = this.playerItems
    local playerItem = nil
    for i = 1, #list do
        playerItem = list[i]
        if playerItem.playerId ~= nil and Pin5RoomData.IsGameStarted() and playerItem.playerId == Pin5RoomData.BankerPlayerId then
            playerItem:SetImgBankerTagDisplay(true)
        else
            playerItem:SetImgBankerTagDisplay(false)
        end
    end
end

--获取玩家item
function Pin5RoomPanel.GetPlayerItem(index)
    local curPlayer = this.GetAllPlayerItems()
    local name = "Player" .. index
    for i = 1, #curPlayer do
        if curPlayer[i].gameObject.name == name then
            return curPlayer[i]
        end
    end
end

--获取所有玩家item
function Pin5RoomPanel.GetAllPlayerItems()
    return this.playerItems
end

--获取没有玩家的items
function Pin5RoomPanel.GetEmptyItems()
    local playerItems = {}
    for i, v in ipairs(this.GetAllPlayerItems()) do
        if not IsNil(v.playerId) and v.playerId <= 0 then
            table.insert(playerItems, v)
        end
    end
    return playerItems
end

-- 展示下注分
function Pin5RoomPanel.ShowXiaZhuGold()
    for i = 1, #Pin5RoomData.playerDatas do
        local playerData = Pin5RoomData.playerDatas[i]
        if playerData ~= nil then
            if playerData.xiaZhuScore ~= nil and playerData.xiaZhuScore > 0 then
                this.ShowBetPoints(playerData.id, playerData.xiaZhuScore)
            end
        end
    end

    --显示推注状态
end

--显示下注分
function Pin5RoomPanel.ShowBetPoints(playerId, xiaZhuScore)
    local playerItem = Pin5RoomData.GetPlayerItemById(playerId)
    if playerItem ~= nil then
        playerItem:ShowBetPoints(xiaZhuScore)
        playerItem:SetTuiZhuImageActive(false)
    else
        LogWarn(">> 显示下注分错误 >> playerItem is nil , playerId = ", playerId)
    end
end

--关闭所有玩家的准备提示
function Pin5RoomPanel.HideAllReadyImge()
    for i = 1, #Pin5RoomData.playerDatas do
        local playerItem = Pin5RoomData.GetPlayerItemById(Pin5RoomData.playerDatas[i].id)
        if playerItem ~= nil then
            playerItem:SetReadyDisplay(false)
        end
    end
end

--===========================================================================房间按钮

--设置开始按钮显示
function Pin5RoomPanel.SetStartBtnDisplay(display)
    if this.lastStartBtnDisplay ~= display then
        this.lastStartBtnDisplay = display
        UIUtil.SetActive(this.startBtn, display)
    end
end

--显示开始游戏按钮
function Pin5RoomPanel.ShowStartBtn(isCentre)
    LogError(">> Pin5RoomPanel.ShowStartBtn")
    this.SetStartBtnDisplay(true)
end

--隐藏开始按钮
function Pin5RoomPanel.HideStartBtn()
    LogError(">> Pin5RoomPanel.HideStartBtn")
    this.SetStartBtnDisplay(false)
end

--设置不能开始按钮显示
function Pin5RoomPanel.SetNotStartBtnDisplay(display)
    if this.lastNotStartBtnDisplay ~= display then
        this.lastNotStartBtnDisplay = display
        UIUtil.SetActive(this.noStartBtn, display)
    end
end

--设置开始按钮的是否可以点击
function Pin5RoomPanel.SetStartBtnInteractable(interactable)
    LogError(">> Pin5RoomPanel.SetStartBtnInteractable > interactable = ", interactable)
    this.SetNotStartBtnDisplay(not interactable)
    this.startButton.interactable = interactable
end

--设置坐下按钮显示
function Pin5RoomPanel.SetSitDownBtnDisplay(display)
    if this.lastSitDownBtnDisplay ~= display then
        this.lastSitDownBtnDisplay = display
        UIUtil.SetActive(this.sitDownBtn, display)
    end
end

--显示坐下按钮
function Pin5RoomPanel.ShowSitDownBtn()
    -- LogError(">> Pin5RoomPanel.ShowSitDownBtn")
    this.SetSitDownBtnDisplay(true)
end

--隐藏坐下按钮
function Pin5RoomPanel.HideSitDownBtn()
    -- LogError(">> Pin5RoomPanel.HideSitDownBtn")
    this.SetSitDownBtnDisplay(false)
end

--设置准备按钮显示
function Pin5RoomPanel.SetReadyBtnDisplay(display)
    if this.lastReadyBtnDisplay ~= display then
        this.lastReadyBtnDisplay = display
        UIUtil.SetActive(this.readyBtn, display)
    end
end

--显示准备按钮
function Pin5RoomPanel.ShowReadyBtn(isCenter)
    -- LogError(">> Pin5RoomPanel.ShowReadyBtn")
    ---既不是旁观者，也不是小局准备
    local display = true and not Pin5RoomData.IsObserver() and not Pin5RoomData.IsGameStarted()
    this.SetReadyBtnDisplay(display)
end

--关闭准备按钮
function Pin5RoomPanel.HideReadyBtn()
    -- LogError(">> Pin5RoomPanel.HideReadyBtn")
    this.SetReadyBtnDisplay(false)
end

--显示自动翻牌
function Pin5RoomPanel.ShowAutoFlip()
    UIUtil.SetActive(this.autoFlip.gameObject, true and not Pin5RoomData.IsObserver())
end

--隐藏自动翻牌
function Pin5RoomPanel.HideAutoFlip()
    UIUtil.SetActive(this.autoFlip.gameObject, false)
end
--===========================================================================房间显示值
------------------------------------------------------------------
--
--设置电量
function Pin5RoomPanel.UpdateEnergyValue(value)
    local num = value / 100
    this.energyValueImage.fillAmount = num

    local level = Functions.CheckEnergyLevel(value)
    if this.energyLevel == level then
        return
    end
    this.energyLevel = level
    if this.energyLevel == EnergyLevel.None then
        UIUtil.SetActive(this.energyNoActiveGO, true)
        UIUtil.SetActive(this.energyGO, false)
    else
        UIUtil.SetActive(this.energyNoActiveGO, false)
        UIUtil.SetActive(this.energyGO, true)
        if this.energyLevel == EnergyLevel.Low then
            UIUtil.SetActive(this.energyValueGO, false)
            UIUtil.SetActive(this.energyValueRedGO, true)
            --UIUtil.SetImageColor(this.energyValueImage, 1, 0, 0)
        else
            UIUtil.SetActive(this.energyValueGO, true)
            UIUtil.SetActive(this.energyValueRedGO, false)
            --UIUtil.SetImageColor(this.energyValueImage, 1, 1, 1)
        end
    end
end

--检测更新网络Ping值
function Pin5RoomPanel.CheckUpdateNetPing()
    --初始更新下网络类型
    this.UpdateNetType()

    this.UpdateNetPing(30)
    --
    this.StartCheckNetTypeTimer()
end

--启动检测网络类型
function Pin5RoomPanel.StartCheckNetTypeTimer()
    if this.checkNetTypeTimer == nil then
        this.checkNetTypeTimer = Timing.New(this.OnCheckNetTypeTimer, 10)
    end
    this.checkNetTypeTimer:Start()
end

--停止检测网络类型
function Pin5RoomPanel.StopCheckNetTypeTimer()
    if this.checkNetTypeTimer ~= nil then
        this.checkNetTypeTimer:Stop()
    end
end

--处理检测网络类型
function Pin5RoomPanel.OnCheckNetTypeTimer()
    this.UpdateNetType()
end

--更新网络类型
function Pin5RoomPanel.UpdateNetType()
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
function Pin5RoomPanel.UpdateNetPing(value)
    --
    if IsNil(this.pingTxt) then
        return
    end
    this.pingTxt.text = tostring(value)
    --
    local level = Functions.CheckNetLevel(value)
    --这样判断是不重复处理UI
    if this.netLevel == level then
        return
    end
    this.netLevel = level
    local netImage = nil
    local spriteName = nil
    if this.isWifi then
        netImage = this.iconWifiValueImage
        spriteName = "xzdd_ui_panel_device_wifi_wifi-" .. level
    else
        netImage = this.iconSignalValueImage
        spriteName = "xzdd_ui_panel_device_wifi_4G-" .. level
    end

    --Log(">> Pin5RoomPanel > UpdateNetPing > ", spriteName, this.stateInfoImages)
    netImage.sprite = this.stateInfoImages[spriteName]

    if this.netLevel == NetLevel.Good then
        UIUtil.SetTextColor(this.pingTxt, 0, 1, 0)
    elseif this.netLevel == NetLevel.General then
        UIUtil.SetTextColor(this.pingTxt, 1, 1, 0)
    else
        UIUtil.SetTextColor(this.pingTxt, 1, 0, 0)
    end
end

--设置站点以及版本号
function Pin5RoomPanel.SetVerNetTxt()
    local lineStr = nil
    local serverLine = Pin5RoomData.roomData.line
    if serverLine == nil then
        lineStr = "0"
    else
        lineStr = math.floor(serverLine % 100)
        if lineStr < 10 then
            lineStr = "0" .. lineStr
        else
            lineStr = tostring(lineStr)
        end
    end

    local temp = "Res:" .. Functions.GetResVersionStr(GameType.Pin5)
    temp = temp .. " Line:" .. lineStr
    this.roomInfoUI.verNetTxt.text = temp
end

--设置时间
function Pin5RoomPanel.SetTime()
    if not IsNil(this.timeText) then
        local timestamp = os.time()
        local time = os.date("%Y-%m-%d %H:%M", timestamp)
        this.timeText.text = time
    end
end

--设置房间号
function Pin5RoomPanel.SetRoomCodeText(data)
    this.roomInfoUI.roomCodeText.text = data
end

--设置游戏类型
function Pin5RoomPanel.SetGameTypeText(data)
    this.roomInfoUI.gameTypeText.text = "  " .. data
end

--设置局数
function Pin5RoomPanel.SetJuShuText(gameIndex, gameTotal)
    if gameTotal == -1 then
        this.roomInfoUI.juShuText.text = "--"
    else
        this.roomInfoUI.juShuText.text = gameIndex .. "/" .. gameTotal
    end
end

--设置底分
function Pin5RoomPanel.SetDiFenText(data)
    if data == nil then
        this.roomInfoUI.diFenText.text = "--"
    else
        this.roomInfoUI.diFenText.text = data
    end
end

--设置提示信息
function Pin5RoomPanel.SetImgTipsText(str)
    if Pin5RoomData.isPlayback then
        return
    end
end

--设置游戏倒计时
function Pin5RoomPanel.SetGameCountDownText(str)

end

--设置Tips显示
function Pin5RoomPanel.SetTipsDisplay(display)
    if this.lastTipsDisplay ~= display then
        this.lastTipsDisplay = display
        UIUtil.SetActive(this.tipsGo, display)
    end
end

--更新倒计时
function Pin5RoomPanel.UpdateClockText(countDown, msg)
    this.SetTipsDisplay(countDown > 0)
    -- this.tipsLabel.text = msg .. countDown
    this.tipsLabel.text =  countDown
end

--设置菜单栏的激活状态
function Pin5RoomPanel.SetMenuItemsActive(isShow)
    UIUtil.SetActive(this.menuItems.gameObject, isShow)
    UIUtil.SetActive(this.itemMaskBtn.gameObject, isShow)
end

--关闭所有的抢庄倍数
function Pin5RoomPanel.CloseRobBankerMultiple()
    for _, playerData in ipairs(Pin5RoomData.playerDatas) do
        playerData:HideRobBankerMultiple()
    end
end

--设置旁观显示
function Pin5RoomPanel.SetWatchDisplay(display)
    if this.lastWatchDisplay ~= display then
        this.lastWatchDisplay = display
        UIUtil.SetActive(this.watchGo, display)
    end
end

--设置等待显示
function Pin5RoomPanel.SetWaitDisplay(display)
    if this.lastWaitDisplay ~= display then
        this.lastWaitDisplay = display
        UIUtil.SetActive(this.waitGo, display)
    end
end

--开关观察显示
function Pin5RoomPanel.ShowWatch()
    this.SetWatchDisplay(true)
    this.SetWaitDisplay(false)
end

--开关等待显示
function Pin5RoomPanel.ShowWait()
    this.SetWatchDisplay(false)
    this.SetWaitDisplay(true)
end

--坐下后开局隐藏观察图标
function Pin5RoomPanel.HideWatchShow()
    if not Pin5RoomData.IsObserver() then
        this.SetWatchDisplay(false)
        this.SetWaitDisplay(false)
    end
end

--显示复制与邀请按钮
function Pin5RoomPanel.ShowCopyInvite()
    if not Pin5RoomData.IsGoldGame() and not Pin5RoomData.isPlayback then
        UIUtil.SetActive(this.copyInvite, true)
    end
end

--隐藏复制与邀请按钮
function Pin5RoomPanel.HideCopyInvite()
    UIUtil.SetActive(this.copyInvite, false)
end

--显示语音与聊天框
function Pin5RoomPanel.ShowChatVoice()
    if not Pin5RoomData.IsGoldGame() and not Pin5RoomData.isPlayback then
        UIUtil.SetActive(this.chatVoice, true)
    end
end

--隐藏语音与聊天框
function Pin5RoomPanel.HideChatVoice()
    UIUtil.SetActive(this.chatVoice, false)
end

---更新奖池文字显示
---@param num number 需要显示的数字
function Pin5RoomPanel.UpdateAwardPoolText(num)
    local charTab = this.GetCharTableFromNumber(num)
    this.AnimCo = coroutine.start(function()
        for i = 1, #charTab do
            coroutine.wait(0.15)
            this.RollAwardPoolSingleColumnText(i, charTab[i])
        end
    end)
end

function Pin5RoomPanel.RollAwardPoolSingleColumnText(index, numChar)
    local animTime = 0.5 --滚动一次的动画时间
    local highLerpTime, lowLerpTime = 4, 4 --插值次数
    local lowTrans = this.awardColumnTab[index]:Find("low")
    local lowImg = lowTrans:GetComponent(TypeImage)
    local highTrans = this.awardColumnTab[index]:Find("high")
    local highImg = highTrans:GetComponent(TypeImage)
    lowTrans:DOLocalMoveY(-26, animTime / 2):SetEase(Ease.Linear):OnComplete(function()
        lowTrans.localPosition = Vector3.New(0, 26, 0);
        lowLerpTime = this.SetLerpNumSprite(lowLerpTime, lowImg, numChar)
        lowTrans:DOLocalMoveY(-26, animTime):SetEase(Ease.Linear):SetLoops(3):OnStepComplete(function()
            lowLerpTime = this.SetLerpNumSprite(lowLerpTime, lowImg, numChar)
        end)    :OnComplete(function()
            lowTrans.localPosition = Vector3.New(0, 26, 0);
            lowImg.sprite = this.tableSprites[tonumber(numChar) + 1]
            lowImg:SetNativeSize()
            lowTrans:DOLocalMoveY(0, animTime / 2)
        end)
    end);
    highTrans:DOLocalMoveY(-26, animTime):SetEase(Ease.Linear):OnComplete(function()
        highTrans.localPosition = Vector3.New(0, 26, 0);
        highLerpTime = this.SetLerpNumSprite(highLerpTime, highImg, numChar)
        highTrans:DOLocalMoveY(-26, animTime):SetEase(Ease.Linear):SetLoops(3):OnStepComplete(function()
            highLerpTime = this.SetLerpNumSprite(highLerpTime, highImg, numChar)
        end)
    end);
end

function Pin5RoomPanel.SetLerpNumSprite(lerpTime, img, numChar)
    local spriteIndex = math.Round(math.Lerp(0, numChar, lerpTime))
    spriteIndex = spriteIndex == 0 and 1 or spriteIndex
    img.sprite = this.tableSprites[1]
    img:SetNativeSize()
    lerpTime = lerpTime - 1
    return lerpTime
end

---获取数字的每一位组合成的字符table(倒置顺序)
function Pin5RoomPanel.GetCharTableFromNumber(num)
    local numStr = tostring(num)
    local numLen = string.len(numStr)
    local charTab = {}
    for i = numLen, 1, -1 do
        table.insert(charTab, string.sub(numStr, i, i))
    end
    return charTab
end

---@param num boolean 金币特效显示数字
function Pin5RoomPanel.ShowCoinEffect(num)
    coroutine.start(function()
        UIUtil.SetActive(this.CoinEffect, true)
        this.CoinEffectText.text = num
        coroutine.wait(3)
        UIUtil.SetActive(this.CoinEffect, false)
    end)
end

--播放庄动画
function Pin5RoomPanel.PlayZhuangAnim()
    -- if this.zhuangAnimGo ~= nil then
    --     DestroyObj(this.zhuangAnimGo)
    -- end
    -- this.zhuangAnimGo = CreateGO(this.clockZhuangAnimPrefab, this.clockContent)
    -- local temp = this.zhuangAnimGo.transform
    -- temp.localPosition = Vector3(0, 86, 0)
    -- UIUtil.SetActive(this.zhuangAnimGo, true)
end

--停止庄动画
function Pin5RoomPanel.StopZhuangAnim()
    if this.zhuangAnimGo ~= nil then
        DestroyObj(this.zhuangAnimGo)
    end
    this.zhuangAnimGo = nil
end



------------------------------------------------------------------------------------------------------
--重置牌局
function Pin5RoomPanel.Reset()
    if transform == nil then
        return
    end
    --初始化玩家UI
    this.InitPlayerUI()
    --隐藏自动翻牌
    this.HideAutoFlip()
end

--清空数据
function Pin5RoomPanel.Clear()
    if transform == nil then
        return
    end
    for i = 1, #this.playerItems do
        this.playerItems[i]:Clear()
    end
end

--(修改为Disable 不然再来一局会报错)       当销毁时
function Pin5RoomPanel:OnDisable()
    transform = nil
    --当前玩家item
    curPlayerItems = nil

    Pin5RoomData.UpdateAwardPoolCoinNum(0)
    ChatModule.UnInit()

    coroutine.stop(this.AnimCo)

    selfCtrl:OnDestroy()
    selfCtrl = nil
end
------------------------------------------------------------------------------        