LYCRoomPanel = ClassPanel("LYCRoomPanel")
local this = LYCRoomPanel

local transform
--当前玩家item
local curPlayerItems = nil
local selfCtrl = nil

this.HideType = 0

function LYCRoomPanel:OnInitUI()
    self:InitPanel()
    self.ctrl = require(LYCCtrlNames.Room)
    self.ctrl:Init(transform)
    selfCtrl = self.ctrl
    self.bombItemList = {}
    SendMsg(LYCAction.LYCLoadEnd, 2)
    Log(">>>>>>>>>>>>>>>>>>>       加载房间结束")
    self:AddClickEvent()
end

function LYCRoomPanel:InitPanel()
    transform = self.transform
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
    roomInfoUI.maBaoText = roomInfoUI.transform:Find("MaBao"):GetComponent("Text")
    roomInfoUI.QZFSText = roomInfoUI.transform:Find("QZFS/Text"):GetComponent("Text")

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

    -- 不可点击
    -- 解散房间
    -- this.dismiss = this.menuItems:Find("DismissBtnCol")
    -- this.dismissBtn = this.dismiss:Find("DismissBtn")
    -- this.disableDismissBtn = this.dismiss:Find("DisableDismissBtn").gameObject
    
    -- 上局回顾
    -- this.Retrospect = this.menuItems:Find("RetrospectBtnCol")
    -- this.retrospectBtn = this.Retrospect:Find("RetrospectBtn")
    -- this.disableRetrospectBtn = this.Retrospect:Find("DisableRetrospectBtn").gameObject

    ----------------------------左上角菜单栏-------------------------------
    this.topMenu = transform:Find("TopMenu")
    this.menu = this.topMenu:Find("Menu")
    this.menuDwon = this.menu:Find("Dwon")
    this.menuUp = this.menu:Find("Up")
    this.itemMaskBtn = this.menu:Find("MenuMaskBtn").gameObject

    this.menuItems = this.menu:Find("Items")
    this.setBtn = this.menuItems:Find("SetBtn")
    this.menuItems = this.menu:Find("Items")

    this.leaveBtn = this.menuItems:Find("LeaveBtnCol/LeaveBtn")
    this.disableLeaveBtn = this.menuItems:Find("LeaveBtnCol/DisableLeaveBtn").gameObject

    this.ruleBtn = this.menuItems:Find("RuleBtn")
    this.WatcherListBtn = this.menuItems:Find("WatcherListBtn")


    ------------------------------按钮--------------------------
    this.btns = transform:Find("Btns")
    ------------------------------坐下和开始------------------------
    local beginning = this.btns:Find("Start")
    this.startBtn = beginning:Find("StartBtn")
    this.SitDownBtn = beginning:Find("SitDownBtn")
    this.readyBtn = beginning:Find("ReadyBtn")
    this.noStartBtn = this.startBtn:Find("NoStartBtn")
    this.autoFlip = this.btns:Find("AutoFlip")
    this.autoFlipToggle = this.autoFlip:GetComponent("Toggle")
    this.autoFlipToggle.isOn = LYCRoomData.isAutoFlipCard or (PlayerPrefs.GetInt("AutoFlip") == 1 and true or false)
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
    this.watch = this.watchShow:Find("Watch").gameObject
    this.wait = this.watchShow:Find("Wait").gameObject

    ---------------------------------------------------------------
    this.imgTips = transform:Find("ImgTips")
    this.imgTipsText = this.imgTips:Find("Text"):GetComponent(TypeText)
    this.gameCountDown = transform:Find("GameCountDown")
    this.gameCountDownText = this.gameCountDown:GetComponent(TypeText)
    this.clockGo = transform:Find("Clock").gameObject
    this.clockText = transform:Find("Clock/Countdown"):GetComponent(TypeText)
    this.clockLabel = transform:Find("Clock/Label"):GetComponent(TypeText)

    ------------------------------玩家-----------------------------
    this.playerItems = {}
    this.playerItems.transform = transform:Find("PlayerItems")
    this.playerItems.gameObject = this.playerItems.transform.gameObject
    this.CoinEffect = transform:Find("CoinEffect")
    this.CoinEffectText = this.CoinEffect:GetComponent(TypeText)

    --获取十人的
    for i = 1, 10 do
        local playerUI = this.GetPlayertab(i, this.playerItems.transform)
        table.insert(this.playerItems, playerUI)
    end

    local atlas = this.topMenu:GetComponent(TypeSpriteAtlas)
    this.tableSprites = atlas.sprites:ToTable()
    this.awardPoolBtnTran = this.topMenu:Find("AwardPoolButton")
    local columnParent = this.awardPoolBtnTran:Find("text")
    this.awardPoolBtn = this.awardPoolBtnTran:GetComponent(TypeButton)
    this.awardColumnTab = {}
    for i = columnParent.childCount - 1, 0, -1 do
        table.insert(this.awardColumnTab, columnParent:GetChild(i))
    end

    this.effectNode = transform:Find("EffectNode")

    this.bombItem = transform:Find("EffectNode/BombItem")
    this.bombItemAnim = this.bombItem:GetComponent(TypeSkeletonGraphic)

    this.lycLaoItem = transform:Find("EffectNode/LYCLaoItem")
    this.lycLaoItemAnim = this.lycLaoItem:GetComponent(TypeSkeletonGraphic)
end

--获取玩家预设体
function LYCRoomPanel.GetPlayertab(i, parent)
    local transform = parent:Find("Player" .. i)
    return LYCPlayerItem.New(transform, i)
end

--增加点击事件
function LYCRoomPanel:AddClickEvent()
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
    this:AddOnClick(this.startBtn.gameObject, selfCtrl.OnClickStartBtn)
    --坐下按钮
    this:AddOnClick(this.SitDownBtn.gameObject, selfCtrl.OnClickSitDownBtn)
    --准备按钮
    this:AddOnClick(this.readyBtn.gameObject, selfCtrl.OnClickReady)
    --点击展开菜单栏
    this:AddOnClick(this.menuDwon.gameObject, selfCtrl.OnClickDownMenu)
    --点击关闭菜单栏
    this:AddOnClick(this.menuUp.gameObject, selfCtrl.OnClickUpMenu)
    --点击item按钮
    this:AddOnClick(this.itemMaskBtn, selfCtrl.OnClickUpMenu)
    --点击离开按钮
    this:AddOnClick(this.leaveBtn.gameObject, selfCtrl.OnClickLeaveBtn)
    --点击解散按钮
    -- this:AddOnClick(this.dismissBtn.gameObject, selfCtrl.OnClickDismissBtn)
    --点击设置按钮
    this:AddOnClick(this.setBtn.gameObject, selfCtrl.OnClickSetBtn)
    --点击回顾按钮
    -- this:AddOnClick(this.retrospectBtn.gameObject, selfCtrl.OnClickRetrospectBtn)
    --点击头像显示玩家信息
    self:AddClickPlayerIconEvent()
    ------------------------------------------
    --自动翻牌
    self:AddOnToggle(self.autoFlipToggle, selfCtrl.OnAutoFlipToggle)
    ---奖池按钮
    this:AddOnClick(this.awardPoolBtnTran, selfCtrl.OnAwardPoolBtnClick)

end

--挂载点击玩家头像弹窗事件
function LYCRoomPanel:AddClickPlayerIconEvent()
    --绑定玩家头像按钮事件
    for i = 1, #this.playerItems do
        local item = this.playerItems[i].bgBtn.gameObject
        this:AddOnClick(item, HandlerArgs(selfCtrl.OnClickPlayerHead, item, this.playerItems[i]))
    end
end

-- 初始化面板--
function LYCRoomPanel:OnOpened()
    self:InitData()
    selfCtrl:OnCreate()
    --播放背景音
    this.PlayMusice()
    --获取网络
    this.CheckUpdateNetPing()
    --设置站点及版本号
    this.SetVerNetTxt()
    --初始化聊天管理器
    LYCRoom.InitChatManager()
    --开启电量
    AppPlatformHelper.StartGetBatteryStateOnRoom()
end

--初始化界面
function LYCRoomPanel:InitData()
    --是否是金币场
    if LYCRoomData.IsGoldGame() then
        --主动开启
        UIUtil.SetActive(this.copyInvite, false)
        -- UIUtil.SetActive(this.dismiss, false)
        -- UIUtil.SetActive(this.roomInfoUI.juShuGo, false)
        UIUtil.SetActive(this.startBtn, false)
    else
        -- UIUtil.SetActive(this.dismiss, true)
        -- UIUtil.SetActive(this.roomInfoUI.juShuGo, true)
    end
    --是否是回放
    UIUtil.SetActive(this.menu, true)

    --是否禁止语音
    UIUtil.SetActive(this.voiceBtn, LYCRoomData.isSpeech)
end

function LYCRoomPanel.PlayMusice()
    local musicType = GetLocal(LYCAction.LYCBackMusic, 3)
    AudioManager.PlayBackgroud(LYCBundleName.lycMusic, LYCMusics[tonumber(musicType)])
end

--更新菜单按钮
function LYCRoomPanel.UpdateMenuInfo()
    if LYCRoomData.IsClubRoom() or LYCRoomData.IsTeaRoom() or LYCRoomData.IsUnionRoom() then
        if LYCRoomData.IsFangKaFlow() then
            local InGame = not LYCRoomData.IsObserver() and not LYCRoomData.GetSelfIsWaiting()
            -- UIUtil.SetActive(this.dismiss, LYCRoomData.IsGameStarted() and not InGame)
            -- UIUtil.SetActive(this.dismissBtn, LYCRoomData.IsGameStarted() and not InGame)
            -- UIUtil.SetActive(this.disableDismissBtn, false)
            UIUtil.SetActive(this.disableLeaveBtn, LYCRoomData.IsGameStarted())
            --LogError("not LYCRoomData.IsGameStarted() or not InGame", not LYCRoomData.IsGameStarted() or not InGame)
            UIUtil.SetActive(this.leaveBtn, not LYCRoomData.IsGameStarted() or not InGame)
        else
            -- UIUtil.SetActive(this.dismiss, false)
            UIUtil.SetActive(this.disableLeaveBtn, not LYCRoomData.GetSelfIsExitRoom())
            UIUtil.SetActive(this.leaveBtn, LYCRoomData.GetSelfIsExitRoom())
        end
    else
        --判断是否已开局
        if LYCRoomData.IsGameStarted() then
            --是否在观战
            if LYCRoomData.GetSelfIsWaiting() then
                -- UIUtil.SetActive(this.dismiss, false)
                -- UIUtil.SetActive(this.dismissBtn, false)
                -- UIUtil.SetActive(this.disableDismissBtn, true)
                UIUtil.SetActive(this.disableLeaveBtn, false)
                UIUtil.SetActive(this.leaveBtn, true)
            else
                -- UIUtil.SetActive(this.dismiss, true)
                -- UIUtil.SetActive(this.dismissBtn, true)
                -- UIUtil.SetActive(this.disableDismissBtn, false)
                UIUtil.SetActive(this.disableLeaveBtn, true)
                UIUtil.SetActive(this.leaveBtn, false)
            end
        else
            local selfIsOwner = LYCRoomData.MainIsOwner()
            UIUtil.SetActive(this.disableLeaveBtn, selfIsOwner)
            -- UIUtil.SetActive(this.dismiss, selfIsOwner)
            -- UIUtil.SetActive(this.dismissBtn, selfIsOwner)
            -- UIUtil.SetActive(this.disableDismissBtn, not selfIsOwner)
            UIUtil.SetActive(this.leaveBtn, not selfIsOwner)
        end
    end

    -- --金币场兼容
    -- if LYCRoomData.IsGoldGame() then
    --     if LYCRoomData.GetSelfIsNoReady() then
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
    --     if LYCRoomData.IsGameStarted() then
    --         local selfData = LYCRoomData.GetSelfData()
    --         --是否在观战
    --         if selfData.state == LYCPlayerState.WAITING then
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
    --         local selfIsOwner = LYCRoomData.MainIsOwner()
    --         UIUtil.SetActive(this.dismissBtn, selfIsOwner)
    --         UIUtil.SetActive(this.disableDismissBtn, not selfIsOwner)

    --         if LYCRoomData.clubId ~= 0 and LYCRoomData.clubId ~= nil then
    --             UIUtil.SetActive(this.leaveBtn, true)
    --             UIUtil.SetActive(this.disableLeaveBtn, false)
    --         else
    --             UIUtil.SetActive(this.leaveBtn, not selfIsOwner)
    --             UIUtil.SetActive(this.disableLeaveBtn, selfIsOwner)
    --         end

    --     end
    -- end

    --是否禁止语音
    UIUtil.SetActive(this.voiceBtn, LYCRoomData.isSpeech)


end
--========================================================================================玩家UI相关
--隐藏所有玩家手牌
function LYCRoomPanel.ResetAllPlayerHandle()
    for i = 1, #LYCRoomData.playerDatas do
        local playerData = LYCRoomData.playerDatas[i]
        playerData:HideAllCard()
    end
end

--初始化玩家UI
function LYCRoomPanel.InitPlayerUI()
    if curPlayerItems == nil then
        curPlayerItems = this.GetAllPlayerItems()
    end
    for i = 1, #curPlayerItems do
        local item = curPlayerItems[i]
        if item.playerId ~= nil then
            item:ResetPlayerUI()
        end
    end
end

--显示庄图标
function LYCRoomPanel.ShowZhuangImage()
    --设置庄家
    if LYCRoomData.BankerPlayerId ~= nil then
        for _, playerData in ipairs(LYCRoomData.playerDatas) do
            local playerItem = LYCRoomData.GetPlayerUIById(playerData.id)
            if not IsNil(playerItem) then
                if LYCRoomData.BankerPlayerId == playerData.id and LYCRoomData.IsGameStarted() then
                    playerItem:SetZhuangImageActive(true)
                    playerData:ShowRobZhuangMultiple()
                else
                    playerItem:SetZhuangImageActive(false)
                    playerData:HideRobZhuangMultiple()
                end
            end
        end
    end
end

--获取玩家item
function LYCRoomPanel.GetPlayerItem(index)
    local curPlayer = this.GetAllPlayerItems()
    local name = "Player" .. index
    for i = 1, #curPlayer do
        if curPlayer[i].gameObject.name == name then
            return curPlayer[i]
        end
    end
end

--获取所有玩家item
function LYCRoomPanel.GetAllPlayerItems()
    return this.playerItems
end

--获取没有玩家的items
function LYCRoomPanel.GetEmptyItems()
    local playerItems = {}
    for i, v in ipairs(this.GetAllPlayerItems()) do
        if not IsNil(v.playerId) and v.playerId <= 0 then
            table.insert(playerItems, v)
        end
    end
    return playerItems
end

-- 展示下注分
function LYCRoomPanel.ShowXiaZhuGold()
    for i = 1, #LYCRoomData.playerDatas do
        local playerData = LYCRoomData.playerDatas[i]
        if playerData ~= nil then
            if playerData.xiaZhuScore ~= nil and playerData.xiaZhuScore > 0 then
                this.ShowBetPoints(playerData.id, playerData.xiaZhuScore)
            end
        end
    end

    --显示推注状态
end

--显示下注分
function LYCRoomPanel.ShowBetPoints(playerId, xiaZhuScore)
    local playerItem = LYCRoomData.GetPlayerUIById(playerId)
    if playerItem ~= nil then
        playerItem:ShowBetPoints(xiaZhuScore)
        playerItem:SetTuiZhuImageActive(false)
    else
        LogWarn(">> 显示下注分错误 >> playerItem is nil , playerId = ", playerId)
    end
end

--关闭所有玩家的准备提示
function LYCRoomPanel.HideAllReadyImge()
    for i = 1, #LYCRoomData.playerDatas do
        local playerItem = LYCRoomData.GetPlayerUIById(LYCRoomData.playerDatas[i].id)
        if playerItem ~= nil then
            playerItem:UpdatellReadyImge(false, false)
        end
    end
end

--===========================================================================房间按钮
--显示开始游戏按钮
function LYCRoomPanel.ShowStartBtn(isCentre)
    local y = this.startBtn.transform.localPosition.y
    if isCentre then
        UIUtil.SetLocalPosition(this.startBtn.gameObject, 0, y, 0)
    else
        UIUtil.SetLocalPosition(this.startBtn.gameObject, -120, y, 0)
    end
    UIUtil.SetActive(this.startBtn.gameObject, true)
end

--隐藏开始按钮
function LYCRoomPanel.HideStartBtn()
    UIUtil.SetActive(this.startBtn.gameObject, false)
end

--设置开始按钮的是否可以点击
function LYCRoomPanel.SetStartBtnInteractable(isCan)
    LogError("SetStartBtnInteractable", isCan)
    UIUtil.SetActive(this.noStartBtn.gameObject, not isCan)
    this.startBtn:GetComponent("Button").interactable = isCan
end

function LYCRoomPanel.ShowSitDownBtn()
    LogError("ShowSitDownBtn")
    UIUtil.SetActive(this.SitDownBtn.gameObject, true)
end

function LYCRoomPanel.HideSitDownBtn()
    LogError("HideSitDownBtn")
    UIUtil.SetActive(this.SitDownBtn.gameObject, false)
end

--显示准备按钮
function LYCRoomPanel.ShowReadyBtn(isCentre, boolean)
    LogError("ShowReadyBtn")
    isCentre = true
    local y = this.readyBtn.transform.localPosition.y
    if isCentre then
        UIUtil.SetLocalPosition(this.readyBtn.gameObject, 0, y, 0)
    else
        UIUtil.SetLocalPosition(this.readyBtn.gameObject, 120, y, 0)
    end
    ---既不是旁观者，也不是小局准备
    local activeCondition = true and not LYCRoomData.IsObserver() and not LYCRoomData.IsGameStarted()
    UIUtil.SetActive(this.readyBtn.gameObject, activeCondition)
end

--关闭准备按钮
function LYCRoomPanel.HideReadyBtn()
    UIUtil.SetActive(this.readyBtn.gameObject, false)
end

--显示自动翻牌
function LYCRoomPanel.ShowAutoFlip()
    UIUtil.SetActive(this.autoFlip.gameObject, true and not LYCRoomData.IsObserver())
end

--隐藏自动翻牌
function LYCRoomPanel.HideAutoFlip()
    UIUtil.SetActive(this.autoFlip.gameObject, false)
end
--===========================================================================房间显示值
------------------------------------------------------------------
--
--设置电量
function LYCRoomPanel.UpdateEnergyValue(value)
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
function LYCRoomPanel.CheckUpdateNetPing()
    --初始更新下网络类型
    this.UpdateNetType()

    this.UpdateNetPing(30)
    --
    this.StartCheckNetTypeTimer()
end

--启动检测网络类型
function LYCRoomPanel.StartCheckNetTypeTimer()
    if this.checkNetTypeTimer == nil then
        this.checkNetTypeTimer = Timing.New(this.OnCheckNetTypeTimer, 10)
    end
    this.checkNetTypeTimer:Start()
end

--停止检测网络类型
function LYCRoomPanel.StopCheckNetTypeTimer()
    if this.checkNetTypeTimer ~= nil then
        this.checkNetTypeTimer:Stop()
    end
end

--处理检测网络类型
function LYCRoomPanel.OnCheckNetTypeTimer()
    this.UpdateNetType()
end

--更新网络类型
function LYCRoomPanel.UpdateNetType()
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
function LYCRoomPanel.UpdateNetPing(value)
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

    Log(">> LYCRoomPanel > UpdateNetPing > ", spriteName, this.stateInfoImages)
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
function LYCRoomPanel.SetVerNetTxt()
    local lineStr = nil
    local serverLine = LYCRoomData.roomData.line
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

    local temp = "Res:" .. Functions.GetResVersionStr(GameType.LYC)
    temp = temp .. " Line:" .. lineStr
    this.roomInfoUI.verNetTxt.text = temp
end

--设置时间
function LYCRoomPanel.SetTime()
    if not IsNil(this.timeText) then
        local timestamp = os.time()
        local time = os.date("%Y-%m-%d %H:%M", timestamp)
        this.timeText.text = time
    end
end

--设置房间号
function LYCRoomPanel.SetRoomCodeText(data)
    this.roomInfoUI.roomCodeText.text = data
end

--设置游戏类型
function LYCRoomPanel.SetGameTypeText(data)
    this.roomInfoUI.gameTypeText.text = data
end

--设置局数
function LYCRoomPanel.SetJuShuText(gameIndex, gameTotal)
    if gameTotal == -1 then
        this.roomInfoUI.juShuText.text = "--"
    else
        this.roomInfoUI.juShuText.text = gameIndex .. "/" .. gameTotal
    end
end

--设置底分
function LYCRoomPanel.SetDiFenText(data)
    if data == nil then
        this.roomInfoUI.diFenText.text = "--"
    else
        this.roomInfoUI.diFenText.text = data
    end
end

--设置码宝次数
function LYCRoomPanel.SetMaBaoText(data)
    if data == nil then
        this.roomInfoUI.maBaoText.text = "--"
    else
        this.roomInfoUI.maBaoText.text = tonumber(data) == 0 and "不限" or data.."次"
    end
end

--设置抢庄分数
function LYCRoomPanel.SetQZFSText(data)
    if data == nil then
        this.roomInfoUI.QZFSText.text = ""
    else
        this.roomInfoUI.QZFSText.text = string.format("低于%s分不能抢庄", data) 
    end
end

--设置提示信息
function LYCRoomPanel.SetImgTipsText(str)
    if LYCRoomData.isPlayback then
        return
    end

    if IsNil(str) then
        str = ""
    end
    if not IsNil(this.imgTipsText) then
        this.imgTipsText.text = str
        UIUtil.SetActive(this.imgTips.gameObject, not string.IsNullOrEmpty(str))
    end
end

--设置游戏倒计时
function LYCRoomPanel.SetGameCountDownText(str)
    this.gameCountDownText.text = str
    UIUtil.SetActive(this.gameCountDown, not string.IsNullOrEmpty(str))
end

function LYCRoomPanel.SetClockActive(bool)
    UIUtil.SetActive(this.clockGo, bool)
end

function LYCRoomPanel.UpdateClockText(countDown, label)
    --LogError("countDown", countDown, countDown > 0)
    UIUtil.SetActive(this.clockGo, countDown > 0)
    this.clockLabel.text = label
    this.clockText.text = countDown
end

--设置菜单栏的激活状态
function LYCRoomPanel.SetMenuItemsActive(isShow)
    UIUtil.SetActive(this.menuItems.gameObject, isShow)
    UIUtil.SetActive(this.itemMaskBtn.gameObject, isShow)
end

--设置庄动画激活状态
function LYCRoomPanel.SetBankerAniActive()
    local playerData = LYCRoomData.GetPlayerDataById(LYCRoomData.BankerPlayerId)
    local playerItem = LYCRoomData.GetPlayerUIById(LYCRoomData.BankerPlayerId)
    if not IsNil(playerItem) then
        playerItem:PlayBankerEff(this.ShowZhuangImage)
    end
    if playerData ~= nil then
        --显示抢庄倍数
        playerData:ShowRobZhuangMultiple()
    end
end

--关闭所有的抢庄倍数
function LYCRoomPanel.CloseRobZhuangMultiple()
    for _, playerData in ipairs(LYCRoomData.playerDatas) do
        playerData:HideRobZhuangMultiple()
    end
end

--开关观察显示
function LYCRoomPanel.ShowWatch()
    UIUtil.SetActive(this.watch, true)
    UIUtil.SetActive(this.wait, false)
end

--开关等待显示
function LYCRoomPanel.ShowWait()
    UIUtil.SetActive(this.watch, false)
    UIUtil.SetActive(this.wait, false)
end

--坐下后开局隐藏观察图标
function LYCRoomPanel.HideWatchShow()
    if not LYCRoomData.IsObserver() then
        UIUtil.SetActive(this.watch, false)
        UIUtil.SetActive(this.wait, false)
    end
end

--显示复制与邀请按钮
function LYCRoomPanel.ShowCopyInvite()
    if not LYCRoomData.IsGoldGame() and not LYCRoomData.isPlayback then
        UIUtil.SetActive(this.copyInvite, true)
    end
end

--隐藏复制与邀请按钮
function LYCRoomPanel.HideCopyInvite()
    UIUtil.SetActive(this.copyInvite, false)
end

--显示语音与聊天框
function LYCRoomPanel.ShowChatVoice()
    if not LYCRoomData.IsGoldGame() and not LYCRoomData.isPlayback then
        UIUtil.SetActive(this.chatVoice, true)
    end
end

--隐藏语音与聊天框
function LYCRoomPanel.HideChatVoice()
    UIUtil.SetActive(this.chatVoice, false)
end

---更新奖池文字显示
---@param num number 需要显示的数字
function LYCRoomPanel.UpdateAwardPoolText(num)
    local charTab = this.GetCharTableFromNumber(num)
    this.AnimCo = coroutine.start(function()
        for i = 1, #charTab do
            coroutine.wait(0.15)
            this.RollAwardPoolSingleColumnText(i, charTab[i])
        end
    end)
end

function LYCRoomPanel.RollAwardPoolSingleColumnText(index, numChar)
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

function LYCRoomPanel.SetLerpNumSprite(lerpTime, img, numChar)
    local spriteIndex = math.Round(math.Lerp(0, numChar, lerpTime))
    spriteIndex = spriteIndex == 0 and 1 or spriteIndex
    img.sprite = this.tableSprites[1]
    img:SetNativeSize()
    lerpTime = lerpTime - 1
    return lerpTime
end

---获取数字的每一位组合成的字符table(倒置顺序)
function LYCRoomPanel.GetCharTableFromNumber(num)
    local numStr = tostring(num)
    local numLen = string.len(numStr)
    local charTab = {}
    for i = numLen, 1, -1 do
        table.insert(charTab, string.sub(numStr, i, i))
    end
    return charTab
end

---@param num boolean 金币特效显示数字
function LYCRoomPanel.ShowCoinEffect(num)
    coroutine.start(function()
        UIUtil.SetActive(this.CoinEffect, true)
        this.CoinEffectText.text = num
        coroutine.wait(3)
        UIUtil.SetActive(this.CoinEffect, false)
    end)
end

function LYCRoomPanel.SetAllPlayerItemsBiPaiBtnActive(bool)
    --LogError("<color=aqua>SetAllPlayerItemsBiPaiBtnActive</color>", bool)
    --主玩家不是庄家，不显示比牌按钮
    if not LYCRoomData.MainIsBanker() then
        return
    end
    for i = 1, #this.playerItems do
        this.playerItems[i]:SetBiPaiBtn(bool)
    end
end

--设置庄家是否正在播放捞腌菜动画
function LYCRoomPanel.SetAllPlayerItemsIsPlayLaoEffect(bool)
    for i = 1, #this.playerItems do
        this.playerItems[i]:SetIsPlayLaoEffect(bool)
    end
end

--获取其他玩家是否正在播放捞腌菜动画
function LYCRoomPanel.GetPlaySelfLaoEffect()
    for i = 1, #this.playerItems do
        if this.playerItems[i]:IsPlaySelfLaoEffect() then
            return true
        end
    end
    return false
end

--播放炸弹动画
function LYCRoomPanel.PlayBombEffect(playerId)
    -- local isBankerBomb = playerId == LYCRoomData.BankerPlayerId
    -- local playerData = nil
    -- local bombPoslist = {}
    -- for i = 1, #LYCRoomData.playerDatas do
    --     playerData = LYCRoomData.playerDatas[i]
    --     table.insert(bombPoslist, playerData.item.bomb_pos)
    -- end
    -- local data = nil
    -- local item = nil
    -- for i = 1, #bombPoslist do
    -- end
    UIUtil.SetActive(this.bombItem.gameObject, true)
    this.SetPlayEffect(this.bombItemAnim, "zhadan", false)
    if this.animTimer == nil then
        this.animTimer = Timing.New(
            function ()
                this.animTimer:Stop()
                this.animTimer = nil
                this.SetPlayEffect(this.bombItemAnim, "baozha", false)
            end
        , 0.1)
    end
    this.animTimer:Start()
end

function LYCRoomPanel.SetPlayEffect(item, animName, loop)
    local temp = item.SkeletonData:FindAnimation(animName)
    if temp ~= nil then
        item.AnimationState:SetAnimation(0, animName, loop)
    end
end

-- --获取炸弹item
-- function LYCRoomPanel.CreateBombItem(index)
--     local item = {}
--     item.gameObject = CreateGO(this.bombItem, this.effectNode, "BombItem"..index)
--     item.transform = item.gameObject.transform
--     return item
-- end

--播放捞牌动画
function LYCRoomPanel.PlayLaoEffect(playerData, LaoCard)
    playerData.item:SetPlayLaoEffect(this.lycLaoItem, LaoCard)
end
----------------------------------------------------------------------------------------

-----------------
--重置牌局
function LYCRoomPanel.Reset()
    if transform == nil then
        return
    end
    --关闭所有玩家的要牌中动画
    --LogError("玩家数量", #LYCRoomData.playerDatas)
    for i = 1, #LYCRoomData.playerDatas do
        LYCRoomAnimator.StopYaoPaiZhongAni(LYCRoomData.playerDatas[i].id)
    end
    this.animTimer = nil
    UIUtil.SetActive(this.bombItem.gameObject, false)
    --初始化玩家UI
    this.InitPlayerUI()
    --隐藏自动翻牌
    this.HideAutoFlip()
end

--清空数据
function LYCRoomPanel.Clear()
    if transform == nil then
        return
    end
    for i = 1, #this.playerItems do
        this.playerItems[i]:Clear()
    end
end

--(修改为Disable 不然再来一局会报错)       当销毁时
function LYCRoomPanel:OnDisable()
    transform = nil
    --当前玩家item
    curPlayerItems = nil

    LYCRoomData.UpdateAwardPoolCoinNum(0)
    ChatModule.UnInit()

    coroutine.stop(this.AnimCo)

    selfCtrl:OnDestroy()
    selfCtrl = nil
end
------------------------------------------------------------------------------