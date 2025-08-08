SDBRoomPanel = ClassPanel("SDBRoomPanel")
local this = SDBRoomPanel

local transform
--当前玩家item
local curPlayerItems = nil
local selfCtrl = nil

this.HideType = 0

function SDBRoomPanel:OnInitUI()
    self:InitPanel()
    self.ctrl = require(SDBCtrlNames.Room)
    self.ctrl:Init(transform)
    selfCtrl = self.ctrl
    SendMsg(SDBAction.SDBLoadEnd, 2)
    Log(">>>>>>>>>>>>>>>>>>>       加载房间结束")
    self:AddClickEvent()
end

function SDBRoomPanel:InitPanel()
    transform = self.transform
    -- 左上角的房间信息
    local roomInfoUI = {}
    roomInfoUI.transform = transform:Find("TopLeft")
    roomInfoUI.gameObject = roomInfoUI.gameObject
    roomInfoUI.roomCodeGo = roomInfoUI.transform:Find("RoomCode").gameObject
    roomInfoUI.roomCodeText = roomInfoUI.roomCodeGo:GetComponent("Text")
    roomInfoUI.gameTypeText = roomInfoUI.transform:Find("GameType"):GetComponent("Text")
    roomInfoUI.modeGo = roomInfoUI.transform:Find("Mode")
    roomInfoUI.modeText = roomInfoUI.transform:Find("Mode"):GetComponent("Text")
    roomInfoUI.juShuGo = roomInfoUI.transform:Find("JuShu").gameObject
    roomInfoUI.juShuText = roomInfoUI.juShuGo:GetComponent("Text")
    roomInfoUI.bolusGo = roomInfoUI.transform:Find("Bolus").gameObject
    roomInfoUI.bolusText = roomInfoUI.bolusGo:GetComponent("Text")
    roomInfoUI.mulripleGo = roomInfoUI.transform:Find("Mulriple")
    roomInfoUI.mulripleText = roomInfoUI.transform:Find("Mulriple"):GetComponent("Text")
    roomInfoUI.verNetTran = roomInfoUI.transform:Find("VerNet")
    roomInfoUI.verNetTxt = roomInfoUI.verNetTran:Find("Text"):GetComponent("Text")
    roomInfoUI.BetInfoGO = roomInfoUI.transform:Find("Bet")
    roomInfoUI.BetInfoText = roomInfoUI.BetInfoGO:GetComponent("Text")
    this.roomInfoUI = roomInfoUI
    ------------------------------右上角信息-----------------------
    this.rightTop = transform:Find("RightTop")
    --其他显示信息
    this.stateInfoTrans = this.rightTop:Find("StateInfo")
    --电量
    this.energyValueGO = this.stateInfoTrans:Find("Energy/Value").gameObject
    this.energyValueImage = this.energyValueGO:GetComponent(TypeImage)
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

    this.timeText = this.stateInfoTrans:Find("TimeTxt"):GetComponent(TypeText)

    this.menu = this.rightTop:Find("Menu")
    this.menuDwon = this.menu:Find("Dwon")
    this.menuUp = this.menu:Find("Up")
    this.menuItems = this.menu:Find("Items")

    this.itemMaskBtn = this.menu:Find("MenuMaskBtn").gameObject
    ----------------------------菜单栏-------------------------------
    this.leaveBtn = this.menuItems:Find("LeaveBtnCol/LeaveBtn")
    this.disableLeaveBtn = this.menuItems:Find("LeaveBtnCol/DisableLeaveBtn").gameObject
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
    this.startBtn = beginning:Find("StartBtn")
    this.sitDownBtn = beginning:Find("SitDownBtn")
    this.readyBtn = beginning:Find("ReadyBtn")
    this.noStartBtn = this.startBtn:Find("NoStartBtn")
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
    this.watch = this.watchShow:Find("watch").gameObject
    this.wait = this.watchShow:Find("wait").gameObject
    ------------------------------其他按钮-------------------------
    this.ruleBtn = this.btns:Find("RuleBtn")
    ---------------------------------------------------------------
    this.imgTips = transform:Find("ImgTips")
    this.imgTipsText = this.imgTips:Find("Text"):GetComponent("Text")
    this.gameCountDown = transform:Find("GameCountDown")
    this.gameCountDownText = this.gameCountDown:GetComponent(TypeText)
    ------------------------------玩家-----------------------------
    this.playerItems = {}
    this.playerItems.transform = transform:Find("PlayerItems")
    this.playerItems.gameObject = this.playerItems.transform.gameObject

    --获取八人的
    for i = 1, 8 do
        local playerUI = this.GetPlayertab(i, this.playerItems.transform)
        table.insert(this.playerItems, playerUI)
    end
end

--获取玩家预设体
function SDBRoomPanel.GetPlayertab(i, parent)
    local transform = parent:Find("Player" .. i)
    return SDBPlayerItem.New(transform, i)
end

--增加点击事件
function SDBRoomPanel:AddClickEvent()
    --规则按钮
    this:AddOnClick(this.ruleBtn.gameObject, selfCtrl.OnClickRule)
    --复制按钮
    this:AddOnClick(this.copyBtn.gameObject, selfCtrl.OnClickFuzhi)
    --聊天按钮
    this:AddOnClick(this.chatBtn.gameObject, selfCtrl.OnClickChat)
    --语音
    ChatModule.RegisterVoiceEvent(this.voiceBtn.gameObject)
    --开始游戏按钮
    this:AddOnClick(this.startBtn.gameObject, selfCtrl.OnClickStartBtn)
    --坐下按钮
    this:AddOnClick(this.sitDownBtn.gameObject, selfCtrl.OnClickReady)
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
    this:AddOnClick(this.dismissBtn.gameObject, selfCtrl.OnClickDismissBtn)
    --点击设置按钮
    this:AddOnClick(this.setBtn.gameObject, selfCtrl.OnClickSetBtn)
    --点击回顾按钮
    this:AddOnClick(this.retrospectBtn.gameObject, selfCtrl.OnClickRetrospectBtn)
    --点击头像显示玩家信息
    self:AddClickPlayerIconEvent()
end

--挂载点击玩家头像弹窗事件
function SDBRoomPanel:AddClickPlayerIconEvent()
    --绑定玩家头像按钮事件
    for i = 1, #this.playerItems do
        local item = this.playerItems[i].bgBtn.gameObject
        this:AddOnClick(item, HandlerArgs(selfCtrl.OnClickPlayerHead, item, this.playerItems[i]))
    end
end

-- 初始化面板--
function SDBRoomPanel:OnOpened()
    self:InitData()
    selfCtrl:OnCreate()
    --播放背景音
    this.PlayMusice()
    --获取网络
    this.CheckUpdateNetPing()
    --设置站点及版本号
    this.SetVerNetTxt()
    --初始化聊天管理器
    SDBRoom.InitChatManager()
    --开启电量
    AppPlatformHelper.StartGetBatteryStateOnRoom()
end

--初始化界面
function SDBRoomPanel:InitData()
    --是否是金币场
    if SDBRoomData.IsGoldGame() then
        --主动开启
        UIUtil.SetActive(this.copyInvite, false)
        UIUtil.SetActive(this.dismiss, true)
        UIUtil.SetActive(this.roomInfoUI.bolusGo, false)
        UIUtil.SetActive(this.startBtn, false)
        UIUtil.SetActive(this.roomInfoUI.BetInfoGO, true)
        UIUtil.SetActive(this.roomInfoUI.modeGo, false)
        UIUtil.SetActive(this.roomInfoUI.mulripleGo, false)
    else
        UIUtil.SetActive(this.dismiss, true)
        UIUtil.SetActive(this.roomInfoUI.bolusGo, true)
    end
    UIUtil.SetActive(this.roomInfoUI.juShuGo, true)


    --是否是回放
    if SDBRoomData.isPlayback then
        UIUtil.SetActive(this.chatVoice, false)
        UIUtil.SetActive(this.copyInvite, false)
        UIUtil.SetActive(this.menu, false)
    else
        UIUtil.SetActive(this.menu, true)
    end
end

function SDBRoomPanel.PlayMusice()
    local musicType = GetLocal(SDBAction.SDBBackMusic, 1)
    AudioManager.PlayBackgroud(SDBBundleName.sdbMusic, SDBMusics[tonumber(musicType)])
end

--更新菜单按钮
function SDBRoomPanel.UpdateMenuInfo()
    --判断是否已开局
    if SDBRoomData.gameIndex > 0 then
        --是否在观战
        if SDBRoomData.GetSelfIsLookGaming() then
            UIUtil.SetActive(this.dismissBtn, false)
            UIUtil.SetActive(this.disableDismissBtn, true)
            UIUtil.SetActive(this.leaveBtn, true)
            UIUtil.SetActive(this.disableLeaveBtn, false)
        else
            UIUtil.SetActive(this.dismissBtn, true)
            UIUtil.SetActive(this.disableDismissBtn, false)
            UIUtil.SetActive(this.leaveBtn, false)
            UIUtil.SetActive(this.disableLeaveBtn, true)
        end

        --第一局不能查看回顾
        if SDBRoomData.gameIndex > 1 then
            UIUtil.SetActive(this.retrospectBtn, true)
            UIUtil.SetActive(this.disableRetrospectBtn, false)
        end

        --金币场兼容
        if SDBRoomData.IsGoldGame() and not SDBRoomData.isCardGameStarted then
            UIUtil.SetActive(this.leaveBtn, true)
            UIUtil.SetActive(this.disableLeaveBtn, false)
        end
    else
        local selfIsOwner = SDBRoomData.MainIsOwner()
        UIUtil.SetActive(this.dismissBtn, selfIsOwner)
        UIUtil.SetActive(this.disableDismissBtn, not selfIsOwner)
        if SDBRoomData.clubId ~= 0 and SDBRoomData.clubId ~= nil then
            UIUtil.SetActive(this.leaveBtn, true)
            UIUtil.SetActive(this.disableLeaveBtn, false)
        else
            UIUtil.SetActive(this.leaveBtn, not selfIsOwner)
            UIUtil.SetActive(this.disableLeaveBtn, selfIsOwner)
        end
        UIUtil.SetActive(this.retrospectBtn, false)
        UIUtil.SetActive(this.disableRetrospectBtn, true)
    end
end
--========================================================================================玩家UI相关
--隐藏所有玩家手牌
function SDBRoomPanel.ResetAllPlayerHandle()
    for i = 1, #SDBRoomData.playerDatas do
        local playerData = SDBRoomData.playerDatas[i]
        playerData:HideAllCard()
    end
end

--初始化玩家UI
function SDBRoomPanel.InitPlayerUI()
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
function SDBRoomPanel.ShowZhuangImage()
    --设置庄家
    if SDBRoomData.BankerPlayerId ~= nil then
        for _, playerData in ipairs(SDBRoomData.playerDatas) do
            local playerItem = SDBRoomData.GetPlayerUIById(playerData.id)
            if not IsNil(playerItem) then
                if SDBRoomData.BankerPlayerId == playerData.id then
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
function SDBRoomPanel.GetPlayerItem(index)
    local curPlayer = this.GetAllPlayerItems()
    local name = "Player" .. index
    for i = 1, #curPlayer do
        if curPlayer[i].gameObject.name == name then
            return curPlayer[i]
        end
    end
end

--获取所有玩家item
function SDBRoomPanel.GetAllPlayerItems()
    return this.playerItems
end

--获取没有玩家的items
function SDBRoomPanel.GetEmptyItems()
    local playerItems = {}
    for i, v in ipairs(this.GetAllPlayerItems()) do
        if not IsNil(v.playerId) and v.playerId <= 0 then
            table.insert(playerItems, v)
        end
    end
    return playerItems
end

-- 展示下注分
function SDBRoomPanel.ShowXiaZhuGold()
    for i = 1, #SDBRoomData.playerDatas do
        local playerData = SDBRoomData.playerDatas[i]
        if playerData ~= nil then
            if playerData.xiaZhuScore ~= nil and playerData.xiaZhuScore > 0 then
                this.ShowBetPoints(playerData.id, playerData.xiaZhuScore)
            end
        end
    end
end

--显示下注分
function SDBRoomPanel.ShowBetPoints(playerId, xiaZhuScore)
    local playerItem = SDBRoomData.GetPlayerUIById(playerId)
    if playerItem ~= nil then
        playerItem:ShowBetPoints(xiaZhuScore)
        playerItem:SetTuiZhuImageActive(false)
    else
        LogWarn(">> 显示下注分错误 >> playerItem is nil , playerId = ", playerId)
    end
end

--关闭所有玩家的准备提示
function SDBRoomPanel.HideAllReadyImge()
    for i = 1, #SDBRoomData.playerDatas do
        local playerItem = SDBRoomData.GetPlayerUIById(SDBRoomData.playerDatas[i].id)
        if playerItem ~= nil then
            playerItem:UpdatellReadyImge(false, false)
        end
    end
end

--设置玩家当前点数   --类型，点数 --是否播放音效特效
function SDBRoomPanel.SetCardsPoint(playerId, type, point, isPlayEffAndSound)
    local playerItem = SDBRoomData.GetPlayerUIById(playerId)
    if playerItem == nil then
        LogError(">> SDBRoomPanel > SetCardsPoint > item is nil")
        return
    end
    if IsNil(type) or IsNil(point) or tonumber(type) == -1 or tonumber(point) <= 0 then
        playerItem:SetPointImageActive(false)
        return
    end

    local playerData = SDBRoomData.GetPlayerDataById(playerId)
    if not IsNil(playerData) then
        --设置点数图片
        playerItem:SetPointImage(type, point)
        if SDBRoomData.BankerPlayerId ~= playerData.id then
            playerItem:PlayWinorLoseAnim(type)
        end

        --是否播放音效以及特效
        if isPlayEffAndSound then
            playerItem:PlayResultEffect(type)
            --播放结果音效
            SDBResourcesMgr.PlayCardPointSound(playerData.id, point, type)
        end
    end
end
--===========================================================================房间按钮
--显示开始游戏按钮
function SDBRoomPanel.ShowStartBtn()
    UIUtil.SetLocalPosition(this.startBtn.gameObject, 0, -210, 0)
    UIUtil.SetActive(this.startBtn.gameObject, true)
end

--隐藏开始按钮
function SDBRoomPanel.HideStartBtn()
    UIUtil.SetActive(this.startBtn.gameObject, false)
end

--设置开始按钮的是否可以点击
function SDBRoomPanel.SetStartBtnInteractable(isCan)
    UIUtil.SetActive(this.noStartBtn.gameObject, not isCan)
    this.startBtn:GetComponent("Button").interactable = isCan
end

--开始按钮移动动画
function SDBRoomPanel.PlayStartBtnMove()
    if this.startBtn.gameObject.activeSelf == false then
        return
    end
    if this.startBtn.transform.localPosition.x ~= 0 then
        this.startBtn.transform:DOLocalMove(Vector3.New(0, -210, 0), 0.5, false)
    end
end

--显示坐下游戏按钮   --开始按钮的位置是否是居中 --是否播放动画
function SDBRoomPanel.ShowSitDownBtn(isCenter, isAni, isSetActive)
    if isSetActive == nil then
        isSetActive = true
    end
    if SDBRoomData.isSitDown then
        isCenter = true
    end
    if isCenter then
        UIUtil.SetLocalPosition(this.sitDownBtn.gameObject, 0, -210, 0)
    else
        UIUtil.SetLocalPosition(this.sitDownBtn.gameObject, 150, -210, 0)
    end
    if isAni and not SDBRoomData.isSitDown then
        SDBRoomData.isSitDown = true
        this.sitDownBtn.transform:DOLocalMove(Vector3.New(0, -210, 0), 0.5, false)
    end

    if SDBRoomData.gameIndex > 0 then
        UIUtil.SetLocalPosition(this.sitDownBtn.gameObject, 0, -210, 0)
    end

    if isSetActive then
        UIUtil.SetActive(SDBRoomPanel.sitDownBtn.gameObject, true)
    end
end

--显示准备按钮
function SDBRoomPanel.ShowReadyBtn()
    local selfData = SDBRoomData.GetSelfData()
    if selfData ~= nil then
        local gameState = SDBRoomData.gameState
        if not SDBRoomData.isPlayback and (selfData.state == PlayerState.LookOn or selfData.state == PlayerState.Stand) then
            UIUtil.SetActive(this.readyBtn.gameObject, true)
        else
            UIUtil.SetActive(this.readyBtn.gameObject, false)
            LogWarn(">>>>>>>>>>>>>>>>>>>>>>>>> 显示准备按钮失败，状态不正确")
        end
    else
        LogWarn(">>>>>>>>>>>>>>>>>>>>>>>>> 显示准备按钮失败，自己状态获取失败")
    end
end

--还原坐下/准备按钮
function SDBRoomPanel.ShowSitOrReadyBtn()
    -- UIUtil.SetActive(this.sitDownBtn.gameObject, true)
    UIUtil.SetActive(this.readyBtn.gameObject, true)
end

--关闭坐下与准备按钮
function SDBRoomPanel.HideSitDown()
    UIUtil.SetActive(this.readyBtn.gameObject, false)
    UIUtil.SetActive(this.sitDownBtn.gameObject, false)
end

--关闭准备按钮
function SDBRoomPanel.HideReadyBtn()
    UIUtil.SetActive(this.readyBtn.gameObject, false)
end
--===========================================================================房间显示值
------------------------------------------------------------------
--
--设置电量
function SDBRoomPanel.UpdateEnergyValue(value)
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
function SDBRoomPanel.CheckUpdateNetPing()
    --初始设置30
    this.UpdateNetPing(30)
    --初始更新下网络类型
    this.UpdateNetType()
    --
    this.StartCheckNetTypeTimer()
end

--启动检测网络类型
function SDBRoomPanel.StartCheckNetTypeTimer()
    if this.checkNetTypeTimer == nil then
        this.checkNetTypeTimer = Timing.New(this.OnCheckNetTypeTimer, 10)
    end
    this.checkNetTypeTimer:Start()
end

--停止检测网络类型
function SDBRoomPanel.StopCheckNetTypeTimer()
    if this.checkNetTypeTimer ~= nil then
        this.checkNetTypeTimer:Stop()
    end
end

--处理检测网络类型
function SDBRoomPanel.OnCheckNetTypeTimer()
    this.UpdateNetType()
end

--更新网络类型
function SDBRoomPanel.UpdateNetType()
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
function SDBRoomPanel.UpdateNetPing(value)
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
        spriteName = "IconWifi-" .. level
    else
        netImage = this.iconSignalValueImage
        spriteName = "IconSignal-" .. level
    end
    
    Log(">> SDBRoomPanel > UpdateNetPing > ", spriteName)
    netImage.sprite = ResourcesManager.LoadSpriteBySynch(BundleName.Room, spriteName)

    if this.netLevel == NetLevel.Good then
        UIUtil.SetTextColor(this.pingTxt, 0, 1, 0)
    elseif this.netLevel == NetLevel.General then
        UIUtil.SetTextColor(this.pingTxt, 1, 1, 0)
    else
        UIUtil.SetTextColor(this.pingTxt, 1, 0, 0)
    end
end

--设置站点以及版本号
function SDBRoomPanel.SetVerNetTxt()
    local lineStr = nil
    local serverLine = SDBRoomData.roomData.line
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

    local temp = "Res:" .. Functions.GetResVersionStr(GameType.SDB)
    temp = temp .. " Line:" .. lineStr
    this.roomInfoUI.verNetTxt.text = temp
end

--设置时间
function SDBRoomPanel.SetTime()
    if not IsNil(this.timeText) then
        local timestamp = os.time()
        local time = os.date("%Y-%m-%d %H:%M", timestamp)
        this.timeText.text = time
    end
end

--设置房间号
function SDBRoomPanel.SetRoomCodeText(data)
    this.roomInfoUI.roomCodeText.text = "  " .. data
end

--设置游戏类型
function SDBRoomPanel.SetGameTypeText(data)
    this.roomInfoUI.gameTypeText.text = "  " .. data
end

--设置模式
function SDBRoomPanel.SetModeText(data)
    this.roomInfoUI.modeText.text = "  " .. data
end

--设置局数
function SDBRoomPanel.SetJuShuText(data)
    this.roomInfoUI.juShuText.text = "  " .. data
end

--设置底分
function SDBRoomPanel.SetBaseScore(data)
    this.roomInfoUI.BetInfoText.text = "  " .. data
end

--设置推注
function SDBRoomPanel.SetBolusText(data)
    this.roomInfoUI.bolusText.text = "  " .. data
end

--设置倍率
function SDBRoomPanel.SetMulripleText(data)
    this.roomInfoUI.mulripleText.text = "  " .. data
end

--设置提示信息
function SDBRoomPanel.SetImgTipsText(str)
    if SDBRoomData.isPlayback then
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
function SDBRoomPanel.SetGameCountDownText(str)
    this.gameCountDownText.text = str
    UIUtil.SetActive(this.gameCountDown, not string.IsNullOrEmpty(str))
end

--设置菜单栏的激活状态
function SDBRoomPanel.SetMenuItemsActive(isShow)
    UIUtil.SetActive(this.menuItems.gameObject, isShow)
    UIUtil.SetActive(this.itemMaskBtn.gameObject, isShow)
end

--设置庄动画激活状态
function SDBRoomPanel.SetBankerAniActive()
    local playerData = SDBRoomData.GetPlayerDataById(SDBRoomData.BankerPlayerId)
    local playerItem = SDBRoomData.GetPlayerUIById(SDBRoomData.BankerPlayerId)
    if not IsNil(playerItem) and (SDBRoomData.gameState == SDBGameState.BetState or SDBRoomData.gameState == SDBGameState.RobBanker) then
        playerItem:PlayBankerEff(this.ShowZhuangImage)
    end
    if playerData ~= nil then
        --显示抢庄倍数
        playerData:ShowRobZhuangMultiple()
    end
end

--关闭所有的抢庄倍数
function SDBRoomPanel.CloseRobZhuangMultiple()
    for _, playerData in ipairs(SDBRoomData.playerDatas) do
        playerData:HideRobZhuangMultiple()
    end
end

--开关观察显示
function SDBRoomPanel.ShowWatch()
    UIUtil.SetActive(this.watch, true)
    UIUtil.SetActive(this.wait, false)
end

--开关等待显示
function SDBRoomPanel.ShowWait()
    UIUtil.SetActive(this.watch, false)
    UIUtil.SetActive(this.wait, true)
end

--坐下后开局隐藏观察图标
function SDBRoomPanel.HideWatchShow()
    UIUtil.SetActive(this.watch, false)
    UIUtil.SetActive(this.wait, false)
end

--显示复制与邀请按钮
function SDBRoomPanel.ShowCopyInvite()
    if not SDBRoomData.IsGoldGame() and not SDBRoomData.isPlayback then
        UIUtil.SetActive(this.copyInvite, true)
    end
end

--隐藏复制与邀请按钮
function SDBRoomPanel.HideCopyInvite()
    UIUtil.SetActive(this.copyInvite, false)
end

--显示语音与聊天框
function SDBRoomPanel.ShowChatVoice()
    if not SDBRoomData.IsGoldGame() and not SDBRoomData.isPlayback then
        UIUtil.SetActive(this.chatVoice, true)
    end
end

--隐藏语音与聊天框
function SDBRoomPanel.HideChatVoice()
    UIUtil.SetActive(this.chatVoice, false)
end
------------------------------------------------------------------------------------------------------
--重置牌局
function SDBRoomPanel.Reset()
    if transform == nil then
        return
    end
    --关闭所有玩家的要牌中动画
    for i = 1, #SDBRoomData.playerDatas do
        SDBRoomAnimator.StopYaoPaiZhongAni(SDBRoomData.playerDatas[i].id)
    end
    --初始化玩家UI
    this.InitPlayerUI()
end

--当销毁时
function SDBRoomPanel:OnDestroy()
    transform = nil
    --当前玩家item
    curPlayerItems = nil

    ChatModule.UnInit()

    selfCtrl:OnDestroy()
    selfCtrl = nil
end
------------------------------------------------------------------------------