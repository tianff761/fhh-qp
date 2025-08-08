PdkRoomPanel = ClassPanel("PdkRoomPanel")
local this = PdkRoomPanel
PdkRoomPanel.players = {} --玩家UI集合

PdkRoomPanel.tablePokers = {}

this.isInitOffset = true
function PdkRoomPanel:OnInitUI()
    -- self:AdaptContent()
    this = self

    this.bg = self.transform:Find("Bg")
    UIUtil.SetBackgroundAdaptation(this.bg.gameObject)
    this.content = self.transform:Find("Content")
    this.leftBtns = this.content:Find("LeftBtns")
    this.ruleBtn = this.leftBtns:Find("RuleBtn"):GetComponent("Button")
    --顶部按钮
    this.topBtns = this.content:Find("TopBtns")
    this.settingBtn = this.topBtns:Find("SettingBtn"):GetComponent("Button")
    this.gpsBtn = this.topBtns:Find("GpsBtn"):GetComponent("Button")
    --右边按钮
    this.rightBtns = this.content:Find("RightBtns")
    this.voiceBtnSpeech = this.rightBtns:Find("VoiceBtn"):GetComponent("ButtonSpeech")
    this.chatBtn = this.rightBtns:Find("ChatBtn"):GetComponent("Button")
    --中间按钮
    this.copyAndInvite = this.content:Find("CopyAndInvite")
    this.copyBtn = this.copyAndInvite:Find("CopyBtn")
    this.inviteBtn = this.copyAndInvite:Find("InviteBtn")
    this.changeRoomBtn = this.copyAndInvite:Find("ChangeRoomBtn")
    --房间信息
    this.playTypeNode = this.content:Find("RoomInfo/PlayType")
    this.ownerText = this.content:Find("RoomInfo/OwnerText"):GetComponent("Text")
    --站点
    this.tipsInfo = this.content:Find("TipsInfo")
    this.tipsText = this.tipsInfo:Find("TipsTxt"):GetComponent("Text")
    --操作按钮
    this.tiShiBtn = this.content:Find("Operation/TiShiBtn"):GetComponent("Button")
    this.outCardBtn = this.content:Find("Operation/OutCardBtn"):GetComponent("Button")
    this.passBtn = this.content:Find("Operation/PassBtn"):GetComponent("Button")
    --左上角信息
    this.stateInfoTrans = this.content:Find("StateInfo")
    this.roomIDText = this.stateInfoTrans:Find("RoomIDText"):GetComponent("Text")
    this.roundText = this.stateInfoTrans:Find("RoundText"):GetComponent("Text")
    this.energyValueGO = this.stateInfoTrans:Find("Energy/Value").gameObject
    this.energyValueImage = this.energyValueGO:GetComponent(TypeImage)
    this.energyNoActiveGO = this.stateInfoTrans:Find("EnergyNoActive").gameObject
    this.timeText = this.content:Find("StateInfo/TimeTxt"):GetComponent("Text")
    --信号和Ping值
    this.iconSignalTran = this.stateInfoTrans:Find("IconSignal")
    this.iconSignalValueGO = this.iconSignalTran:Find("IconSignalValue").gameObject
    this.iconSignalValueImage = this.iconSignalValueGO:GetComponent(TypeImage)

    this.iconWifiTran = this.stateInfoTrans:Find("IconWifi")
    this.iconWifiValueGO = this.iconWifiTran:Find("IconWifiValue").gameObject
    this.iconWifiValueImage = this.iconWifiValueGO:GetComponent(TypeImage)
    this.pingTxt = this.stateInfoTrans:Find("PingTxt"):GetComponent(TypeText)
    --玩家
    local player = nil
    for i = 1, 4 do
        player = this.content:Find("Players/Player" .. i)
        this.players[i] = AddLuaComponent(player.gameObject, "PdkPlayer")
    end
    --计时闹钟
    this.clockTimer = AddLuaComponent(this.content:Find("Timer").gameObject, "PdkClockTimer")
    --打出的牌 箭头
    -- this.arrows = this.content:Find("Arrows").gameObject
    --桌面上面的牌Node
    this.tableCardNode = this.content:Find("TableCardNode")
    --挂在特效的节点
    this.effNode = this.content:Find("EffNode")

    --设置UI的偏移
    this.CheckAndUpdateUIOffset()

    this.bankerIcon = this.content:Find("BankerIcon")  --庄家

    this.onHook = this.content:Find("OnHook")  --托管
    this.cancelOnHookBtn = this.onHook:Find("CancelButton"):GetComponent("Button") --取消托管按钮

    AddLuaComponent(this.content:Find("SelfHandCardCtrl").gameObject, "PdkSelfHandCardCtrl") --手牌控制器
end

function PdkRoomPanel:OnOpened(data)
    GameSceneManager.SwitchGameSceneEnd(GameSceneType.Room)
    AddLuaComponent(this.content:Find("Resources").gameObject, "PdkResourcesCtrl") --资源控制器
    AddLuaComponent(self.gameObject, "PdkRoomCtrl")
    this.AddListener()
    PdkRoomCtrl.Init()
    this.SetVersionAndLine()
    --获取电量
    AppPlatformHelper.StartGetBatteryStateOnRoom()
    --网络相关
    this.CheckUpdateNetPing()
    --时间
    this.SetTime()
end

--退出房间
function PdkRoomPanel:OnClosed()
    AppPlatformHelper.StopGetBatteryStateOnRoom()
    this.StopCheckNetTypeTimer()
    this.RemoveListener()
    Scheduler.unscheduleGlobal(this.countDownHandle)
end

--添加按钮点击事件
function PdkRoomPanel.AddListener()
    this:AddOnClick(this.settingBtn, PdkRoomCtrl.OnSettingClick)
    this:AddOnClick(this.gpsBtn, PdkRoomCtrl.OnGpsClick)
    this:AddOnClick(this.ruleBtn, PdkRoomCtrl.OnRuleClick)
    this:AddOnClick(this.copyBtn, PdkRoomCtrl.OnCopyBtnClick)
    this:AddOnClick(this.inviteBtn, PdkRoomCtrl.OnInviteBtnClick)
    this:AddOnClick(this.changeRoomBtn, PdkRoomCtrl.OnChangeRoomClick)
    -- this:AddOnClick(this.readyBtn, PdkRoomCtrl.OnReadyClick)
    this:AddOnClick(this.tiShiBtn, PdkRoomCtrl.OnTipsClick)
    this:AddOnClick(this.outCardBtn, PdkRoomCtrl.OnOutCardClick)
    this:AddOnClick(this.passBtn, PdkRoomCtrl.OnPassClick)
    this:AddOnClick(this.cancelOnHookBtn, PdkRoomCtrl.OnCancelOnHookClick)
    --注册聊天按钮
    ChatModule.RegisterVoiceEvent(this.voiceBtnSpeech)
    ChatModule.RegisterChatTextEvent(this.chatBtn.gameObject)
    AddMsg(CMD.Game.Pdk.CanPopCard, this.IsCardType)
    AddMsg(CMD.Game.Pdk.DealCardEnd, PdkRoomCtrl.SetBanker)
    --电量监听
    AddEventListener(CMD.Game.BatteryState, this.OnBatteryState)
    AddEventListener(CMD.Game.Ping, this.OnNetPing)

    for i = 1, 4 do
        this:AddOnClick(this.players[i].headBtn, HandlerArgs(PdkRoomCtrl.OnPlayerItemClick, i))
    end
end

function PdkRoomPanel.RemoveListener()
    RemoveMsg(CMD.Game.Pdk.CanPopCard, this.IsCardType)
    RemoveMsg(CMD.Game.Pdk.DealCardEnd, PdkRoomCtrl.SetBanker)

    RemoveEventListener(CMD.Game.BatteryState, this.OnBatteryState)
    RemoveEventListener(CMD.Game.Ping, this.OnNetPing)
end

--初始化玩家信息或更新
function PdkRoomPanel.PlayerInit(index, info)
    this.players[index]:Init(info)
    if index == 1 then
        PdkSelfHandCardCtrl.CreateHandPoker(info.pokers)
    else
        if PdkRoomModule.isPlayback then
            this.CreateCard(index, info.pokers)
        else
            if info.pokerNum > 0 then
                this.ShowCardNum(index, true)
            end
        end
    end
    --手牌数量
    this.UpdateCardNum(index, info.pokerNum)
end

--更新玩家信息或更新
function PdkRoomPanel.PlayerJoin(index, info)
    this.players[index]:Join(info)
end

function PdkRoomCtrl.UpdatePlayerStatus()
    -- body
end

--玩家退出
function PdkRoomPanel.PlayerExit(index)
    this.players[index]:Exit()
end

--是否进入中
function PdkRoomPanel.ShowJoing(index, isShow)
    this.players[index]:ShowJoing(isShow)
end

--玩家是否有准备
function PdkRoomPanel.PlayerReady(index, info)
    this.players[index]:ShowReady(info)
end

--玩家是否托管
function PdkRoomPanel.PlayerTuoGuan(index, isShow)
    this.players[index]:ShowTuoGuan(isShow)
end

--设置庄家
function PdkRoomPanel.ShowBanker(index, isShow)
    if index == 1 then
        this.players[index]:ShowBanker(isShow, true)
    else
        this.players[index]:ShowBanker(isShow, false)
    end
end

--显示玩家文本说话
function PdkRoomPanel.ShowTalkText(index, isTalk, str)
    this.players[index]:ShowTalkText(isTalk, str)
end

--玩家语音说话
function PdkRoomPanel.ShowTalkEff(index, isShow)
    this.players[index]:ShowTalkEff(isShow)
end

--玩家扎鸟
function PdkRoomPanel.ShowZhaNiao(index, isShow)
    this.players[index]:ShowZhaNiao(isShow)
end

--设置庄家
function PdkRoomPanel.SetBanker(index)
    this.bankerIcon:SetParent(this.content)
    UIUtil.SetLocalPosition(this.bankerIcon, 0, 50, 0)
    UIUtil.SetActive(this.bankerIcon.gameObject, true)
    this.bankerIcon:SetParent(this.players[index].headBox.transform)
    --播放显示庄家音效
    PdkAudioCtrl.PlayBanker()
    Scheduler.scheduleOnceGlobal(function()
        local image = this.bankerIcon:GetComponent("Image")
        image:DOFade(0, 1)
        local moveTween = this.bankerIcon:DOLocalMove(Vector3(0, 0, 0), 1, false)
        moveTween:OnComplete(function()
            UIUtil.SetActive(this.bankerIcon.gameObject, false)
            UIUtil.SetImageColor(image, 1, 1, 1, 1)
            this.ShowBanker(index, true)
        end)
    end, 1)
end

--发牌给玩家
function PdkRoomPanel.DealCard(index, info)
    this.players[index]:DealCard()
end

--显示手牌图标
function PdkRoomPanel.ShowCardNum(index, isShow)
    this.players[index]:ShowCardNum(isShow)
end

--更新玩家手牌数量
function PdkRoomPanel.UpdateCardNum(index, info)
    this.players[index]:UpdateCardNum(info)
end

--分数动画
function PdkRoomPanel.ScoreAnim(index, score, totalScore)
    this.players[index]:ScoreAnim(score, totalScore)
end

--更新玩家分数显示
function PdkRoomPanel.SetScoreNum(index, score)
    this.players[index]:SetScoreNum(score)
end

--显示玩家打的牌
function PdkRoomPanel.PlayerOutCard(index, info)
    -- this.players[index]:CreateOutPoker(info)
    --根据牌显示的位置 显示箭头
    -- this.ShowArrows(pos)
    PdkRoomPanel.HideTableCard()
    if index == 1 and not PdkRoomModule.isPlayback then
        PdkSelfHandCardCtrl.OutPoker(info, this.tableCardNode)
        PdkSelfHandCardCtrl.UpdateCtrl(true)
    else
        local rotation = 0
        local playerData = PdkRoomModule.GetPlayerInfoBySeat(index)
        if playerData ~= nil then
            if playerData.seatDir == PdkSeatDirection.Right then
                rotation = 90
            elseif playerData.seatDir == PdkSeatDirection.Left then
                rotation = -90
            elseif playerData.seatDir == PdkSeatDirection.Top then
                rotation = 0
            elseif playerData.seatDir == PdkSeatDirection.Self then
                rotation = 0
            end
        else
            LogError("玩家信息不存在：", index)
        end
        -- UIUtil.SetActive(this.tableCardNode.gameObject, false)
        UIUtil.SetLocalScale(this.tableCardNode, 0, 0, 0)
        local poker = nil
        local id = nil
        local length = #info
        local radian = 1.4
        local curRadian = (16 * radian - (radian / 2) * (16 - length)) / length
        if curRadian > 1.5 then
            curRadian = 1.5
        end
        local startValue = (length - 1) / 2 * curRadian
        for i = 1, length do
            id = info[i]
            poker = PdkResourcesCtrl.GetPoker(PdkPrefabName.PlayerOutPoker, this.tableCardNode)
            UIUtil.SetLocalScale(poker.transform, 1, 1, 1)
            UIUtil.SetLocalPosition(poker, 0, -2500, 0)
            poker.transform:Find("Image"):GetComponent("Image").sprite = PdkResourcesCtrl.pokerAtlas[id]
            local value = startValue - (i - 1) * curRadian
            UIUtil.SetRotation(poker.transform, 0, 0, value)
        end
        this.tableCardNode:SetParent(this.players[index].headBox.transform)
        UIUtil.SetLocalPosition(this.tableCardNode, 0, 0, 0)
        this.tableCardNode:SetParent(this.content)
        UIUtil.SetRotation(this.tableCardNode, 0, 0, rotation)
        local moveTween = this.tableCardNode:DOLocalMove(Vector3(0, 50, 0), 0.3, false)
        this.tableCardNode:DOScale(Vector3(0.58, 0.58, 0), 0.3)
        this.tableCardNode:DOLocalRotate(Vector3(0, 0, 0), 0.3, DG.Tweening.RotateMode.Fast)

        -- if PdkRoomModule.isPlayback then
        --     PdkRoomPanel.RemoveHandPoker(index, info)
        -- end
    end
end

function PdkRoomPanel.ShowTableCard(pokers)
    local length = #pokers
    local radian = 1.4
    local curRadian = (16 * radian - (radian / 2) * (16 - length)) / length
    if curRadian > 1.5 then
        curRadian = 1.5
    end
    local startValue = (length - 1) / 2 * curRadian
    local poker = nil
    local id = nil
    for i = 1, length do
        id = pokers[i]
        poker = PdkResourcesCtrl.GetPoker(PdkPrefabName.PlayerOutPoker, this.tableCardNode)
        UIUtil.SetLocalScale(poker.transform, 1, 1, 1)
        UIUtil.SetLocalPosition(poker, 0, -2500, 0)
        poker.transform:Find("Image"):GetComponent("Image").sprite = PdkResourcesCtrl.pokerAtlas[id]
        local value = startValue - (i - 1) * curRadian
        UIUtil.SetRotation(poker.transform, 0, 0, value)
    end
    UIUtil.SetLocalScale(this.tableCardNode, 0.58, 0.58, 1)
    UIUtil.SetLocalPosition(this.tableCardNode, 0, 50, 0)
end

--播放玩家打牌特效
function PdkRoomPanel.PlayEffect(index, cardType)
    LogError("播放特效", cardType)
    -- this.players[index]:ShowEffect(cardType)
    PdkEffectCtrl.PlayEffect(cardType, this.effNode, index)
    UIUtil.SetAsLastSibling(this.effNode)
end

--显示箭头
function PdkRoomPanel.ShowArrows(pos)
    UIUtil.SetActive(this.arrows, true)
    UIUtil.SetPosition(this.arrows, pos.x, pos.y + (105 * this.arrows.transform.lossyScale.y), pos.z)
end

--显示玩家要不起
function PdkRoomPanel.ShowPass(index, info)
    this.players[index]:ShowPass(info)
end

--创建玩家手牌
function PdkRoomPanel.CreateCard(index, info)
    this.players[index]:CreateHandPoker(info)
end

--移除玩家手牌
function PdkRoomPanel.RemoveHandPoker(index, info)
    this.players[index]:RemoveHandPoker(info)
end

--清除玩家手牌
function PdkRoomPanel.ClearHandPoker(index)
    this.players[index]:ClearHandPoker()
end

--玩家剩余的牌
function PdkRoomPanel.CreateRemainPoker(index, info)
    this.players[index]:CreateRemainPoker(info)
end

--清除桌面打出来的牌
function PdkRoomPanel.HideTableCard()
    local count = this.tableCardNode.childCount
    local pokers = {}
    if count > 0 then
        for i = 0, count - 1 do
            local poker = this.tableCardNode:GetChild(i).gameObject
            table.insert(pokers, poker)
            -- PdkResourcesCtrl.PutPoker(this.tableCardNode:GetChild(i).gameObject)
        end
    end

    for i = 1, #pokers do
        PdkResourcesCtrl.PutPoker(pokers[i])
    end
end

--显示倒计时
function PdkRoomPanel.ShowClock(isShow, index, info)
    if isShow then
        this.clockTimer.transform:SetParent(this.players[index].timerNode)
        this.clockTimer.transform.localPosition = Vector3.zero
        this.clockTimer:BeginDaoJiShi(info)
    else
        this.clockTimer:StopDaoJiShi()
    end
    UIUtil.SetActive(this.clockTimer.gameObject, isShow)
end

--获取玩家UI节点
function PdkRoomPanel.GetPlayerNodeBySeat(index)
    return this.players[index]
end

--设置站点线路
function PdkRoomPanel.SetVersionAndLine()
    --Ver:1.0.1 站点:02
    local lineStr = nil
    if PdkRoomModule.serverPort == nil then
        lineStr = "0"
    else
        lineStr = math.floor(PdkRoomModule.serverPort % 100)
        if lineStr < 10 then
            lineStr = tostring(lineStr)
        else
            lineStr = tostring(lineStr)
        end
    end

    local temp = "Ver:" .. Functions.GetResVersionStr(GameType.PaoDeKuai)
    temp = temp .. "." .. lineStr
    this.tipsText.text = temp
end

--设置房间ID
function PdkRoomPanel.SetRoomID(id)
    this.roomIDText.text = "房间号:" .. id
end

--设置房主名称
function PdkRoomPanel.SetOwner(name)
    this.ownerText.text = "房主:" .. name
end

--设置局数
function PdkRoomPanel.SetRoomRound(nowjs, maxjs)
    this.roundText.text = "局数:" .. nowjs .. "/" .. maxjs
end

--设置玩法
function PdkRoomPanel.SetPlayType(playType)
    HideChildren(this.playTypeNode)
    local icon = nil
    if playType == PdkPlayType.SCErRen or playType == PdkPlayType.SCSanRen or playType == PdkPlayType.SCSiRen then
        icon = this.playTypeNode:Find("SCPDK")
    elseif playType == PdkPlayType.LSSanRen or playType == PdkPlayType.LSSiRen then
        icon = this.playTypeNode:Find("LSPDK")
    end
    if not IsNil(icon) then
        UIUtil.SetActive(icon.gameObject, true)
    end
end

--开始按钮显示
function PdkRoomPanel.ShowStartBtn(isShow)
    UIUtil.SetActive(this.readyBtn.gameObject, isShow)
end

--复制房号和邀请好友按钮
function PdkRoomPanel.ShowCopyAndInviteBtn(isShow)
    --UIUtil.SetActive(this.copyAndInvite.gameObject, isShow)
end

--显示换桌按钮
function PdkRoomPanel.ShowChangeRoomBtn(isShow)
    UIUtil.SetActive(this.changeRoomBtn.gameObject, isShow)
end

--提示按钮显示
function PdkRoomPanel.ShowTiShiBtn(isShow)
    UIUtil.SetActive(this.tiShiBtn.gameObject, isShow)
end

--出牌按钮显示和激活
function PdkRoomPanel.ShowOutCardBtn(isShow, isOut)
    if isShow ~= nil then
        UIUtil.SetActive(this.outCardBtn.gameObject, isShow)
    end
    if isOut == nil then
        isOut = true
    end
    this.outCardBtn.interactable = isOut
end

--要不起按钮显示
function PdkRoomPanel.ShowPassBtn(isShow)
    UIUtil.SetActive(this.passBtn.gameObject, isShow)
end

--托管按钮显示
function PdkRoomPanel.ShowOnHookBtn(isShow)
    UIUtil.SetActive(this.onHook.gameObject, isShow)
end

--语音按钮显示
function PdkRoomPanel.ShowVoiceBtn(isShow)
    UIUtil.SetActive(this.voiceBtnSpeech.gameObject, isShow)
end

--Gps按钮显示
function PdkRoomPanel.ShowGpsBtn(isShow)
    UIUtil.SetActive(this.gpsBtn.gameObject, isShow)
end

--隐藏分数场按钮
function PdkRoomPanel.ShowGoldRoomBtn()
    --UIUtil.SetActive(this.copyAndInvite.gameObject, false)
    UIUtil.SetActive(this.voiceBtnSpeech.gameObject, false)
    UIUtil.SetActive(this.gpsBtn.gameObject, false)
end

--显示所有元素
function PdkRoomPanel.ShowAllElement()
    --UIUtil.SetActive(this.copyAndInvite.gameObject, true)
    UIUtil.SetActive(this.voiceBtnSpeech.gameObject, true)
    UIUtil.SetActive(this.gpsBtn.gameObject, true)
    UIUtil.SetActive(this.settingBtn.gameObject, true)
    --UIUtil.SetActive(this.chatBtn.gameObject, true)
    UIUtil.SetActive(this.tipsInfo.gameObject, true)
end

--隐藏回放按钮
function PdkRoomPanel.HidePlayBackElement()
    --UIUtil.SetActive(this.copyAndInvite.gameObject, false)
    UIUtil.SetActive(this.voiceBtnSpeech.gameObject, false)
    UIUtil.SetActive(this.gpsBtn.gameObject, false)
    UIUtil.SetActive(this.settingBtn.gameObject, false)
    UIUtil.SetActive(this.chatBtn.gameObject, false)
    UIUtil.SetActive(this.tipsInfo.gameObject, false)
end

--是否可以出牌
function PdkRoomPanel.IsCardType(isActive)
    this.ShowOutCardBtn(nil, isActive)
end

--重置房间信息
function PdkRoomPanel.Reset()
    for i = 1, #this.players do
        this.players[i]:Reset()
    end
    -- HideChildren(this.tableCardNode)
    PdkRoomPanel.HideTableCard()
    PdkSelfHandCardCtrl.Clear()
    ClearChildren(this.effNode)
    UIUtil.SetActive(this.onHook.gameObject, false)
    -- UIUtil.SetActive(this.readyBtn.gameObject, false)
    UIUtil.SetActive(this.tiShiBtn.gameObject, false)
    UIUtil.SetActive(this.outCardBtn.gameObject, false)
    UIUtil.SetActive(this.passBtn.gameObject, false)
    -- UIUtil.SetActive(this.clockTimer.gameObject, false)
    this.ShowClock(false)
end

function PdkRoomPanel.Clear()
    for i = 1, #this.players do
        this.players[i]:Exit()
    end
    -- HideChildren(this.tableCardNode)
    PdkRoomPanel.HideTableCard()
    ClearChildren(this.effNode)
    UIUtil.SetActive(this.onHook.gameObject, false)
    -- UIUtil.SetActive(this.readyBtn.gameObject, false)
    UIUtil.SetActive(this.tiShiBtn.gameObject, false)
    UIUtil.SetActive(this.outCardBtn.gameObject, false)
    UIUtil.SetActive(this.passBtn.gameObject, false)
    -- UIUtil.SetActive(this.clockTimer.gameObject, false)
    this.ShowClock(false)
    -- UIUtil.SetActive(this.arrows, false)
end

--设置房间时间
function PdkRoomPanel.SetTime()
    -- this.timeText.text = time
    this.timeText.text = tostring(--[[os.date("%Y")) .. "-" .. tostring(os.date("%m")) .. "-" .. tostring(os.date("%d")) .. " " ..]] tostring(os.date("%H")) .. ":" .. tostring(os.date("%M")))
    this.countDownHandle = Scheduler.scheduleGlobal(
            function()
                if IsNull(this.timeText) then
                    this:UnscheduleAll()
                else
                    this.timeText.text = tostring(--[[os.date("%Y")) .. "-" .. tostring(os.date("%m")) .. "-" .. tostring(os.date("%d")) .. " " .. ]]tostring(os.date("%H")) .. ":" .. tostring(os.date("%M")))
                end
            end,
            15
    )
end

--电量设置
function PdkRoomPanel.OnBatteryState(value)
    this.UpdateEnergyValue(value)
end

--网络Ping值更新
function PdkRoomPanel.OnNetPing(value)
    this.UpdateNetPing(value)
end

--设置电量
function PdkRoomPanel.UpdateEnergyValue(value)
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


--更新网络类型
function PdkRoomPanel.UpdateNetType()
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
function PdkRoomPanel.UpdateNetPing(value)
    --
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

    netImage.sprite = ResourcesManager.LoadSpriteBySynch(BundleName.Room, spriteName)

    if this.netLevel == NetLevel.Good then
        UIUtil.SetTextColor(this.pingTxt, 0, 1, 0)
    elseif this.netLevel == NetLevel.General then
        UIUtil.SetTextColor(this.pingTxt, 1, 1, 0)
    else
        UIUtil.SetTextColor(this.pingTxt, 1, 0, 0)
    end
end

--检测更新网络Ping值
function PdkRoomPanel.CheckUpdateNetPing()
    --初始设置30
    this.UpdateNetPing(30)
    --初始更新下网络类型
    this.UpdateNetType()
    --
    this.StartCheckNetTypeTimer()
end

--启动检测网络类型
function PdkRoomPanel.StartCheckNetTypeTimer()
    if this.checkNetTypeTimer == nil then
        this.checkNetTypeTimer = Timing.New(this.StartCheckNetTypeTimer, 10)
    end
    this.checkNetTypeTimer:Start()
end
--停止检测网络类型
function PdkRoomPanel.StopCheckNetTypeTimer()
    if this.checkNetTypeTimer ~= nil then
        this.checkNetTypeTimer:Stop()
    end
end

--根据屏幕是否为2比1设置偏移
function PdkRoomPanel.CheckAndUpdateUIOffset()
    if this.isInitOffset == false then
        this.isInitOffset = true
        local offsetX = Global.GetOffsetX()
        --左上角信息
        UIUtil.AddAnchoredPositionX(this.stateInfoTrans, offsetX)
        --右上角信息
        UIUtil.AddAnchoredPositionX(this.tipsInfo, -offsetX)
        --左上交按钮
        UIUtil.AddAnchoredPositionX(this.leftBtns, offsetX)
        --顶部按钮
        UIUtil.AddAnchoredPositionX(this.topBtns, -offsetX)
        --右边的按钮组
        UIUtil.AddAnchoredPositionX(this.rightBtns, -offsetX)
    end
end

function PdkRoomPanel:AdaptContent()
    local content = self:Find("Content"):GetComponent("RectTransform")

    local offMax = content.offsetMax;
    local offMin = content.offsetMin;
    local designWH = 16 / 9 --设计宽高比
    local curWH = ScenemMgr.width / ScenemMgr.height  --当前宽高比
    if curWH < designWH then
        local y = 180 * designWH * ScenemMgr.height / ScenemMgr.width
        offMax.y = y * content.offsetMax.y / math.abs(content.offsetMax.y);
        content.offsetMax = offMax;

        offMin = content.offsetMin;
        offMin.y = y * content.offsetMin.y / math.abs(content.offsetMin.y);
        content.offsetMin = offMin;
    else
        local x = 320 * curWH / designWH
        offMax.x = x * content.offsetMax.x / math.abs(content.offsetMax.x);
        content.offsetMax = offMax;

        offMin = content.offsetMin;
        offMin.x = x * content.offsetMin.x / math.abs(content.offsetMin.x);
        content.offsetMin = offMin;
    end
end
