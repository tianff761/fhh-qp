EqsBattlePanel = ClassPanel("EqsBattlePanel")
EqsBattlePanel.users2Parent = nil          --2个玩家的父节点
EqsBattlePanel.users3Parent = nil          --3个玩家的父节点
EqsBattlePanel.users4Parent = nil          --4个玩家的父节点
EqsBattlePanel.usersParent = nil          --当前房间所有玩家的父节点
EqsBattlePanel.clockTran = nil          --倒计时
EqsBattlePanel.chuPaiRect = nil          --出牌区域
EqsBattlePanel.fPPosTran = nil          --发牌位置
EqsBattlePanel.ruleText = nil          --房间背景游戏规则
EqsBattlePanel.leftCardNumText = nil          --剩余牌
EqsBattlePanel.cardBgTran = nil          --换三张用的牌背面
EqsBattlePanel.pingText = nil          --ping值
EqsBattlePanel.energyValueImage = nil          --电量值显示
EqsBattlePanel.versionInfo = nil          --版本信息
EqsBattlePanel.dataText = nil          --日期文本
EqsBattlePanel.buDas = nil          --所有不打父节点


--所有游戏中按钮
EqsBattlePanel.inviteBtn = nil           --邀请按钮
EqsBattlePanel.copyRoomInfoBtn = nil           --复制房间号按钮
EqsBattlePanel.changeRoomBtn = nil           --改变房间按钮
EqsBattlePanel.changeBtn = nil           --换三张按钮
EqsBattlePanel.settingBtn = nil
EqsBattlePanel.gpsBtn = nil           --功能改为打开GPS界面
EqsBattlePanel.chatBtn = nil
EqsBattlePanel.talkingBtn = nil
EqsBattlePanel.huBtn = nil
EqsBattlePanel.kaiBtn = nil
EqsBattlePanel.duiBtn = nil
EqsBattlePanel.chiBtn = nil
EqsBattlePanel.guoBtn = nil
EqsBattlePanel.tuoGuanTipsImg = nil
EqsBattlePanel.closeTuoguanTipsBtn = nil
EqsBattlePanel.huPaiTipsBtn = nil

EqsBattlePanel.autoPlayTran = nil

--返回大厅按钮，分数娱乐场使用
EqsBattlePanel.returnToLobbyBtn = nil

--回放按钮
EqsBattlePanel.playbackBtns = nil
EqsBattlePanel.lastStepBtn = nil
EqsBattlePanel.nextStepBtn = nil
EqsBattlePanel.pauseBtn = nil
EqsBattlePanel.playBtn = nil
EqsBattlePanel.exitBtn = nil

EqsBattlePanel.suiJiQuanCard = nil

--3人玩家顶部信息显示父节点
EqsBattlePanel.topPlayer3 = nil
--4人玩家顶部信息显示父节点
EqsBattlePanel.topPlayer4 = nil
--三人听牌提示toggle
EqsBattlePanel.tingPaiToggle3 = nil
--四人人听牌提示toggle
EqsBattlePanel.tingPaiToggle4 = nil
--听牌文本
EqsBattlePanel.tingPaiTran = nil

local this = EqsBattlePanel
EqsBattlePanel.adaptFullScreen = false
function EqsBattlePanel:Awake()
    this = self
    -- this.AdaptFullScreen()
end

function EqsBattlePanel:OnOpened(args)
    LogUpload("jrfj" .. UserData.GetRoomId())
    GameSceneManager.SwitchGameSceneEnd(GameSceneType.Room)
    self:InitArgs()
    BattleModule.Init(args)
    this.InitPanel()
    AddLuaComponent(self.gameObject, "EqsBattleCtrl")

    --设置声音
    EqsSoundManager.PlayBg()
    SetBtnClickCallback(function()
        EqsSoundManager.PlayAudio(EqsAudioNames.BtnClick)
    end)

    --初始化监听语音操作事件
    EqsBattleCtrl.AddVoiceMsg(self.talkingBtn)
    --开始获取电量数据
    AppPlatformHelper.StartGetBatteryStateOnRoom()

    self.SetVersionInfo()

    --匹配场游戏结束后，在游戏里面继续匹配时，打开面板即关闭匹配界面和结算界面
    PanelManager.Close(PanelConfig.GoldMatch)
    PanelManager.Close(EqsPanels.DanJuJieSuan)

    Scheduler.scheduleOnceGlobal(function()
        EqsBattleCtrl.Init()
    end, 0.1)
end

function EqsBattlePanel:OnDestroy()
    AppPlatformHelper.StopGetBatteryStateOnRoom()
end

function EqsBattlePanel:InitArgs()
    local content = self:Find('Content')
    self.users2Parent = content:Find('Player2Container')
    self.users3Parent = content:Find('Player3Container')
    self.users4Parent = content:Find('Player4Container')
    self.chuPaiRect = content:Find("ChuPaiRect"):GetComponent('RectTransform')
    self.fPPosTran = content:Find("FpPos")
    self.ruleText = content:Find('DisplayTexts/Rules'):GetComponent(typeof(Text))
    self.leftCardNumText = content:Find('DisplayTexts/LeftCard/Text'):GetComponent(typeof(Text))
    self.cardBgTran = content:Find("CardBg")
    self.pingText = content:Find("DisplayTexts/RightUp/NetworkTime"):GetComponent(typeof(Text))
    self.versionInfo = content:Find("DisplayTexts/RightUp/VersionInfo"):GetComponent(typeof(Text))
    self.energyValueImage = content:Find("DisplayTexts/RightUp/energy/Image"):GetComponent("Image")
    self.signalImage = content:Find("DisplayTexts/RightUp/Signal/SignalValue"):GetComponent("Image")
    self.dayTime = content:Find("DisplayTexts/RightUp/DayTime"):GetComponent(typeof(Text))
    
    self.buDas = content:Find("BuDaContainer")
    self.inviteBtn = content:Find("Btns/WaitingBtns/InviteFriendBtn")
    self.copyRoomInfoBtn = content:Find('Btns/WaitingBtns/CopyRoomInfoBtn')
    self.changeRoomBtn = content:Find("Btns/WaitingBtns/ChangeRoomBtn")
    self.changeBtn = content:Find('Btns/HuanSanZhuangBtn')
    self.settingBtn = content:Find('Btns/SettingBtn')
    self.gpsBtn = content:Find('Btns/RuleBtn')
    self.chatBtn = content:Find('Btns/ChatBtn')
    self.talkingBtn = content:Find('Btns/TalkingBtn')
    self.huBtn = content:Find("Btns/OperationBtns/HuBtn")
    self.kaiBtn = content:Find("Btns/OperationBtns/KaiBtn")
    self.duiBtn = content:Find("Btns/OperationBtns/DuiBtn")
    self.chiBtn = content:Find("Btns/OperationBtns/ChiBtn")
    self.guoBtn = content:Find("Btns/OperationBtns/GuoBtn")
    self.huPaiTipsBtn = content:Find("Btns/HuPaiTipBtn")
    --托管提示
    self.tuoGuanTipsImg = content:Find("Btns/TuoGuanImg")
    self.TuoGuanTipsBtn = content:Find("Btns/TuoGuanImg/TuoGuanTipsBtn")
    self.tuoGuanTips = content:Find("Btns/TuoGuanImg/TuoGuanTips")
    self.closeTuoguanTipsBtn = content:Find("Btns/TuoGuanImg/TuoGuanTips/CloseTuoTips")

    self.returnToLobbyBtn = content:Find("Btns/ReturnLobbyBtn")

    self.playbackBtns = content:Find("PlaybackBtns")
    self.nextStepBtn = self.playbackBtns:Find("NextStepBtn")
    self.lastStepBtn = self.playbackBtns:Find("LastStepBtn")
    self.pauseBtn = self.playbackBtns:Find("PauseBtn")
    self.playBtn = self.playbackBtns:Find("PlayBtn")
    self.exitBtn = self.playbackBtns:Find("ExitBtn")

    self.topPlayer3 = content:Find("DisplayTexts/Player3Pos")
    self.topPlayer4 = content:Find("DisplayTexts/Player4Pos")

    self.tingPaiToggle3 = self.topPlayer3:Find("TingPaiToggle")
    self.tingPaiToggle4 = self.topPlayer4:Find("TingPaiToggle")
    self.tingPaiTran = content:Find("TingPaiContainer")

    --目前只有乐山贰柒拾匹配场
    self.suiJiQuanCard = self.topPlayer3:Find("GoldRoom/QuanText/Card")

    self.autoPlayTran = content:Find("AutoPlay")

    if self.clockTran == nil then
        self.clockTran = content:Find("ClockContainer/Clock")
    end
end

function EqsBattlePanel.GetTingPaiTran()
    return this.tingPaiTran
end

function EqsBattlePanel.AdaptFullScreen()
    if UnityEngine.Screen.width / UnityEngine.Screen.height > 1.95 then
        --根节点
        local rect = this.transform:GetComponent("RectTransform")
        rect.offsetMin = FullScreenAdapt
        rect.offsetMax = FullScreenAdapt * -1

        --背景 
        rect = this.transform:Find("Content/ShenSeBg"):GetComponent("RectTransform")
        rect.offsetMin = FullScreenAdapt * -1
        rect.offsetMax = FullScreenAdapt

        rect = this.transform:Find("Content/LanSeBg"):GetComponent("RectTransform")
        rect.offsetMin = FullScreenAdapt * -1
        rect.offsetMax = FullScreenAdapt

        rect = this.transform:Find("Content/QianSeBg"):GetComponent("RectTransform")
        rect.offsetMin = FullScreenAdapt * -1
        rect.offsetMax = FullScreenAdapt

        this.adaptFullScreen = true
    end

    local rect = this.transform:Find('Content/DisplayTexts/Player4Pos/FkRoom'):GetComponent("RectTransform")
    if this.adaptFullScreen then
        rect.anchoredPosition = rect.anchoredPosition + Vector2(-25, 0)
    else
        rect.anchoredPosition = rect.anchoredPosition + Vector2(25, 0)
    end
end

function EqsBattlePanel.SetHuPaiTipsBtnVisible(visible)
    Log("SetHuPaiTipsBtnVisible", visible, BattleModule.isOpenTingPai)
    UIUtil.SetActive(this.huPaiTipsBtn, visible and BattleModule.isOpenTingPai)
end

function EqsBattlePanel.GetSuiJiQuanCard()
    return this.suiJiQuanCard
end

function EqsBattlePanel.GetChuPaiRect()
    return this.chuPaiRect
end

function EqsBattlePanel.GetCardBg()
    return this.cardBgTran
end

function EqsBattlePanel.GetAutoPlayTran()
    return this.autoPlayTran
end

function EqsBattlePanel.GetClock()
    return this.clockTran
end

function EqsBattlePanel.GetBuDas()
    return this.buDas
end

function EqsBattlePanel.GetTransform()
    return this.transform
end

--是否初始化
function EqsBattlePanel.SetTopDisplay(isInit)
    if isInit == true then
        if BattleModule.userNum == 3 then
            UIUtil.SetActive(this.topPlayer3, true)
            UIUtil.SetActive(this.topPlayer4, false)

            this.transform:Find('Content/ShenSeBg/Kuang3').gameObject:SetActive(true)
            this.transform:Find('Content/ShenSeBg/Kuang4').gameObject:SetActive(false)

            this.transform:Find('Content/QianSeBg/Kuang3').gameObject:SetActive(true)
            this.transform:Find('Content/QianSeBg/Kuang4').gameObject:SetActive(false)

            this.transform:Find('Content/LanSeBg/Kuang3').gameObject:SetActive(true)
            this.transform:Find('Content/LanSeBg/Kuang4').gameObject:SetActive(false)
        elseif BattleModule.userNum == 2 or BattleModule.userNum == 4 then
            UIUtil.SetActive(this.topPlayer3, false)
            UIUtil.SetActive(this.topPlayer4, true)

            this.transform:Find('Content/ShenSeBg/Kuang3').gameObject:SetActive(false)
            this.transform:Find('Content/ShenSeBg/Kuang4').gameObject:SetActive(true)

            this.transform:Find('Content/QianSeBg/Kuang3').gameObject:SetActive(false)
            this.transform:Find('Content/QianSeBg/Kuang4').gameObject:SetActive(true)

            this.transform:Find('Content/LanSeBg/Kuang3').gameObject:SetActive(false)
            this.transform:Find('Content/LanSeBg/Kuang4').gameObject:SetActive(true)
        end
        if BattleModule.IsFkFlowRoom() then
            UIUtil.SetActive(this.topPlayer3:Find("FkRoom"), true)
            UIUtil.SetActive(this.topPlayer3:Find("GoldRoom"), false)
            UIUtil.SetActive(this.topPlayer4:Find("FkRoom"), true)
            UIUtil.SetActive(this.topPlayer4:Find("GoldRoom"), false)
        else
            UIUtil.SetActive(this.topPlayer3:Find("FkRoom"), false)
            UIUtil.SetActive(this.topPlayer3:Find("GoldRoom"), true)
            UIUtil.SetActive(this.topPlayer4:Find("FkRoom"), false)
            UIUtil.SetActive(this.topPlayer4:Find("GoldRoom"), true)
        end
    else
        UIUtil.SetActive(this.topPlayer3, false)
        UIUtil.SetActive(this.topPlayer4, false)

        --默认不显示房间号和圈牌
        UIUtil.SetActive(this.topPlayer3:Find("GoldRoom/RoomNum"), false)
        UIUtil.SetActive(this.topPlayer3:Find("GoldRoom/QuanText/Card"), false)
    end
end
--3人、4人、2人  其中:2人和4人背景相同
function EqsBattlePanel.SetPlayerCount(count)
    if tonumber(count) == 3 then
        this.transform:Find('Content/ShenSeBg/Kuang3').gameObject:SetActive(true)
        this.transform:Find('Content/ShenSeBg/Kuang4').gameObject:SetActive(false)

        this.transform:Find('Content/QianSeBg/Kuang3').gameObject:SetActive(true)
        this.transform:Find('Content/QianSeBg/Kuang4').gameObject:SetActive(false)

        this.transform:Find('Content/LanSeBg/Kuang3').gameObject:SetActive(true)
        this.transform:Find('Content/LanSeBg/Kuang4').gameObject:SetActive(false)
        this.transform:Find('Content/DisplayTexts/Player3Pos/FkRoom'):GetComponent("RectTransform")
    elseif tonumber(count) == 4 or tonumber(count) == 2 then
        this.transform:Find('Content/ShenSeBg/Kuang3').gameObject:SetActive(false)
        this.transform:Find('Content/ShenSeBg/Kuang4').gameObject:SetActive(true)

        this.transform:Find('Content/QianSeBg/Kuang3').gameObject:SetActive(false)
        this.transform:Find('Content/Content/QianSeBg/Kuang4').gameObject:SetActive(true)

        this.transform:Find('Content/LanSeBg/Kuang3').gameObject:SetActive(false)
        this.transform:Find('Content/LanSeBg/Kuang4').gameObject:SetActive(true)


    else
        LogError(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>人数设置错误：", count)
    end

end
function EqsBattlePanel.GetTopDisplayNode()
    if BattleModule.userNum == 3 then
        return this.topPlayer3
    elseif BattleModule.userNum == 2 or BattleModule.userNum == 4 then
        return this.topPlayer4
    end
end

function EqsBattlePanel.InitPanel()
    if BattleModule.isPlayback then
        this:AddOnClick(this.nextStepBtn, EqsBattleCtrl.OnClickNextStepBtn)
        this:AddOnClick(this.lastStepBtn, EqsBattleCtrl.OnClickLastStepBtn)
        this:AddOnClick(this.pauseBtn, EqsBattleCtrl.OnClickPauseBtn)
        this:AddOnClick(this.playBtn, EqsBattleCtrl.OnClickPlayBtn)
        this:AddOnClick(this.exitBtn, EqsBattleCtrl.OnClickExitBtn)
        this.SetAutoPlayback()
        this.HideWaitingBtns()
        UIUtil.SetActive(this.playbackBtns.gameObject, true)
    else
        this:AddOnClick(this.inviteBtn, EqsBattleCtrl.OnClickInviteBtn)
        this:AddOnClick(this.copyRoomInfoBtn, EqsBattleCtrl.OnClickCopyRoomInfoBtn)
        this:AddOnClick(this.changeRoomBtn, EqsBattleCtrl.OnClickChangeRoomBtn)
        this:AddOnClick(this.changeBtn, EqsBattleCtrl.OnClickChangeBtn)
        this:AddOnClick(this.settingBtn, EqsBattleCtrl.OnClickSettingBtn)
        this:AddOnClick(this.gpsBtn, EqsBattleCtrl.OnClickGpsBtn)
        this:AddOnClick(this.huBtn, EqsBattleCtrl.OnClickHuBtn)
        this:AddOnClick(this.kaiBtn, EqsBattleCtrl.OnClickKaiBtn)
        this:AddOnClick(this.duiBtn, EqsBattleCtrl.OnClickDuiBtn)
        this:AddOnClick(this.chiBtn, EqsBattleCtrl.OnClickChiBtn)
        this:AddOnClick(this.guoBtn, EqsBattleCtrl.OnClickGuoBtn)
        this:AddOnClick(this.TuoGuanTipsBtn, EqsBattleCtrl.OnClickTuoGuanBtn)
        this:AddOnClick(this.closeTuoguanTipsBtn, EqsBattleCtrl.OnCloseTuoGuanTipsBtn)
        this:AddOnClick(this.huPaiTipsBtn, EqsBattleCtrl.OnClickHuPaitipsBtn)
        this:AddOnClick(this.tingPaiToggle3:Find("TpTipBtn"), function()
            EqsBattleCtrl.OnClickTingPaiToggle(this.tingPaiToggle3:GetComponent(typeof(Toggle)).isOn)
        end)
        this:AddOnClick(this.tingPaiToggle4:Find("TpTipBtn"), function()
            EqsBattleCtrl.OnClickTingPaiToggle(this.tingPaiToggle4:GetComponent(typeof(Toggle)).isOn)
        end)

        this:AddOnClick(this.returnToLobbyBtn, EqsTools.ReturnToLobby)
        UIUtil.SetActive(this.playbackBtns.gameObject, false)
        --注册聊天按钮
        ChatModule.RegisterChatTextEvent(this.chatBtn.gameObject)
    end
    this.HideAllOperationBtns()
    this.HideWaitingBtns()
    --自己手牌放置位置初始化     
    local selfHandCard = this.transform:Find("Content/SelfHandCardPanel")
    local handCards = AddLuaComponent(selfHandCard.gameObject, "SelfHandEqsCardsCtrl")
    handCards:Init(this.fPPosTran.position)


    --初始化背景
    local bgid = GetLocal(EqsLocalKey.EqsTableColor, "2")

    this.SetBg(bgid)

    --设置默认值
    this.SetRuleText("")
    this.SetTime()
    this.SetLeftCard(0)

    --预加载
    ResourcesManager.PreloadPrefabs(EqsPanels.bundleName, { EqsPanels.chiPanel, EqsPanels.baiPanel })

    if BattleModule.isPlayback then
        UIUtil.SetActive(this.settingBtn, false)
        UIUtil.SetActive(this.gpsBtn, false)
        UIUtil.SetActive(this.chatBtn, false)
        UIUtil.SetActive(this.talkingBtn, false)
        UIUtil.SetActive(this.tuoGuanTipsImg, false)
    end

    if not BattleModule.IsFkFlowRoom() then
        UIUtil.SetActive(this.talkingBtn, false)
        UIUtil.SetActive(this.gpsBtn, false)
        if BattleModule.isPlayback then
            UIUtil.SetActive(this.tuoGuanTipsImg, false)
        else
            -- UIUtil.SetActive(this.tuoGuanTipsImg, true)
        end
    end
    this.SetTopDisplay(false)
    this.SetHuPaiTipsBtnVisible(false)

    if not BattleModule.IsFkFlowRoom() or BattleModule.isPlayback then
        UIUtil.SetActive(this.tingPaiToggle3, false)
        UIUtil.SetActive(this.tingPaiToggle4, false)
    end
end

function EqsBattlePanel.InitUserParent(userNum)
    this.users2Parent.gameObject:SetActive(false)
    this.users3Parent.gameObject:SetActive(false)
    this.users4Parent.gameObject:SetActive(false)
    if userNum == 3 then
        this.usersParent = this.users3Parent
    elseif userNum == 2 then
        this.usersParent = this.users2Parent
    elseif userNum == 4 then
        this.usersParent = this.users4Parent
    end
    this.usersParent.gameObject:SetActive(true)
    this.SetDate()
    return this.usersParent
end

function EqsBattlePanel.GetUsersParent()
    return this.usersParent
end

function EqsBattlePanel.SetAutoPlayback()
    if this.transform ~= nil then
        UIUtil.SetActive(this.playBtn.gameObject, BattleModule.playbackAutoPlay == false)
        UIUtil.SetActive(this.pauseBtn.gameObject, BattleModule.playbackAutoPlay == true)
    end
end

function EqsBattlePanel.IsHuBtnVisible()
    return this.huBtn.gameObject.activeSelf
end

function EqsBattlePanel.SetTingPaiTiShi()
    UIUtil.SetToggle(this.tingPaiToggle4, BattleModule.isOpenTingPai)
    UIUtil.SetToggle(this.tingPaiToggle3, BattleModule.isOpenTingPai)
end


--设置房间规则文字  {ruleId=rulevalue}
function EqsBattlePanel.SetRuleText(rules)
    this.ruleText.text = EqsTools.GetRulesText1(rules)
end

function EqsBattlePanel.SetTime()
    local time = this:Find("Content/DisplayTexts/RightUp/Time"):GetComponent("Text")
    time.text = tostring(os.date("%H")) .. ":" .. tostring(os.date("%M"))
    this:Schedule(function()
        if IsNull(time) then
            this:UnscheduleAll()
        else
            time.text = tostring(os.date("%H")) .. ":" .. tostring(os.date("%M"))
        end
    end, 15)
end

function EqsBattlePanel.SetDate()
    local funSetData = function()
        -- if not BattleModule.IsFkFlowRoom() then
        --     if BattleModule.userNum == 3 then
        --         this.dataText = this.transform:Find('Content/DisplayTexts/Player3Pos/GoldRoom/Date'):GetComponent("Text")
        --     end
        -- else
        --     if BattleModule.userNum == 3 then
        --         this.dataText = this.transform:Find('Content/DisplayTexts/Player3Pos/FkRoom/TopText/JuShuText/Date'):GetComponent("Text")
        --     elseif BattleModule.userNum == 2 or BattleModule.userNum == 4 then
        --         this.dataText = this.transform:Find('Content/DisplayTexts/Player4Pos/FkRoom/TopText/JuShuText/Date'):GetComponent("Text")
        --     end
        -- end
        -- UIUtil.SetActive(this.dataText.gameObject, true)
        if this.dayTime ~= nil then
            if BattleModule.isPlayback and IsNumber(BattleModule.playbackTime) and BattleModule.playbackTime > 100000 then
                this.dayTime.text = os.date("%Y-%m-%d %H:%M:%S", BattleModule.playbackTime / 1000)
            else
                this.dayTime.text = os.date("%Y-%m-%d")
            end
        end
    end
    funSetData()
    this:Schedule(function()
        funSetData()
    end, 60)
end

--设置底分
function EqsBattlePanel.SetGoldRoomTopInfo(baseScore, roomId, circle, isShow)
    local node = this.GetTopDisplayNode()
    if node == nil then
        Log("获取顶部信息显示节点失败1")
        return
    end
    UIUtil.SetActive(node:Find("FkRoom"), false)
    UIUtil.SetActive(node:Find("GoldRoom"), true)

    --开始时隐藏房间号，待游戏开始再显示
    UIUtil.SetActive(node:Find("GoldRoom/RoomNum"), isShow)
    UIUtil.SetActive(this.suiJiQuanCard, isShow)

    UIUtil.SetText(node:Find("GoldRoom/RoomNum"), "房号:"..tostring(roomId))
    UIUtil.SetText(node:Find("GoldRoom/BaseScoreText"), tostring(baseScore))

    this.SetQuanCard(circle)
end

function EqsBattlePanel.SetQuanCard(quanNum)
    local card = EqsCardsManager.GetSmallCardByUid(tostring(quanNum) .. "21")
    if card ~= nil then
        this.suiJiQuanCard:GetComponent("Image").sprite = card:GetComponent("Image").sprite
        EqsCardsManager.RecycleSmallCard(card, false)
    end
end

function EqsBattlePanel.ShowGoldRoomNum()
    local node = this.GetTopDisplayNode()
    if node == nil then
        Log("获取顶部信息显示节点失败2")
        return
    end
    --开始时隐藏房间号，待游戏开始再显示
    UIUtil.SetActive(node:Find("GoldRoom/RoomNum"), true)
end

--设置局数和圈数文字
function EqsBattlePanel.SetFkRoomTopInfo(juShuNum, circleNum, TotalCircle, roomNum)
    Log("设置文字：", juShuNum, circleNum, TotalCircle, roomNum)
    BattleModule.curJuShu = juShuNum
    local node = this.GetTopDisplayNode()
    if node == nil then
        Log("获取顶部信息显示节点失败1")
        return
    end

    local lable = string.format("第%s局/%s圈/圈%s", tostring(juShuNum), EqsTools.NumberToChinese(tonumber(circleNum)), EqsTools.NumberToChinese(tonumber(TotalCircle)))
    UIUtil.SetText(node:Find('FkRoom/JuShuText'), lable)
    UIUtil.SetText(node:Find('FkRoom/RoomNum'), "房号:"..tostring(roomNum))
end

function EqsBattlePanel.SetPing(ping)
    --更新网络环境
    this.UpdateNetType()
    --更新网络信号强度
    this.UpdateNetPing(ping)
end

--更新网络类型
function EqsBattlePanel.UpdateNetType()
    local isWifi = Util.IsWifi

    if this.isWifi == isWifi then
        return
    end

    this.isWifi = isWifi
    local spriteName = ""

    if this.isWifi then
        spriteName = "xzdd_ui_panel_device_wifi_wifi-0"
    else
        spriteName = "xzdd_ui_panel_device_wifi_4G-0"
    end

    this.signalImage.sprite = ResourcesManager.LoadSpriteBySynch(BundleName.Room, spriteName)
end

function EqsBattlePanel.UpdateNetPing(value)
    if string.IsNullOrEmpty(value) then
        return
    end
    this.pingText.text = tostring(value)

    local netLevel = Functions.CheckNetLevel(value)
    if this.netLevel == netLevel then
        return
    end
    this.netLevel = netLevel

    local spriteName = ""
    if this.isWifi then
        spriteName = "xzdd_ui_panel_device_wifi_wifi-"
    else
        spriteName = "xzdd_ui_panel_device_wifi_4G-"
    end

    if this.netLevel == NetLevel.Good then
        spriteName = spriteName .. "3"
        UIUtil.SetTextColor(this.pingText, 0, 1, 0)
    elseif this.netLevel == NetLevel.General then
        spriteName = spriteName .. "2"
        UIUtil.SetTextColor(this.pingText, 1, 1, 0)
    elseif this.netLevel == NetLevel.Bad then
        spriteName = spriteName .. "1"
        UIUtil.SetTextColor(this.pingText, 1, 0, 0)
    end

    this.signalImage.sprite = ResourcesManager.LoadSpriteBySynch(BundleName.Room, spriteName)
end

function EqsBattlePanel.SetVersionInfo()
    if BattleModule.isPlayback then
        UIUtil.SetActive(this.versionInfo.gameObject, false)
    else
        --Log("...............", BattleModule.port, Functions.GetResVersionStr(GameType.ErQiShi))
        -- UIUtil.SetActive(this.versionInfo.gameObject, true)
        local info = Functions.GetResVersionStr(GameType.ErQiShi) .. "."
        if BattleModule.port == nil or BattleModule.port <= 0 then
            info = info .. "0"
        else
            local line = tostring(BattleModule.port % 100)
            -- if #line == 1 then
            --     line = "0"..line
            -- end
            info = info .. line
        end
        this.versionInfo.text = info
    end
end

--设置电量
function EqsBattlePanel.SetEnergyValue(value)
    if IsNil(value) or IsNil(this.energyValueImage) then
        return
    end
    local num = value / 100
    if num < 0.2 then
        this.energyValueImage.color = Color(1, 0, 0, 1)
    else
        this.energyValueImage.color = Color(1, 1, 1, 1)
    end
    this.energyValueImage.fillAmount = num
end

function EqsBattlePanel.GetFanPaiGPos()
    return this.fPPosTran.position
end
--bgID: 1 深色      2 浅色      3 蓝色
function EqsBattlePanel.SetBg(bgID)
    bgID = tonumber(bgID)
    if this.transform ~= nil then
        local shenSe = this.transform:Find('Content/ShenSeBg')
        local qianSe = this.transform:Find('Content/QianSeBg')
        local lanSe = this.transform:Find('Content/LanSeBg')
        shenSe.gameObject:SetActive(false)
        qianSe.gameObject:SetActive(false)
        lanSe.gameObject:SetActive(false)

        if bgID == 1 then
            shenSe.gameObject:SetActive(true)
            --this.ruleText.transform:GetComponent(typeof(Shadow)).effectColor = Color(0.9765, 0.8706, 0.8, 1)--f9decc
            --this.ruleText.color = Color(0.447, 0.22745, 0.06667, 1)--723a11
        elseif bgID == 2 then
            qianSe.gameObject:SetActive(true)
            --this.ruleText.transform:GetComponent(typeof(Shadow)).effectColor = Color(1, 0.953, 0.8706, 1)--0a3349
            --this.ruleText.color = Color(0.447, 0.22745, 0.06667, 1)--0a3349
        elseif bgID == 3 then
            lanSe.gameObject:SetActive(true)
            --this.ruleText.transform:GetComponent(typeof(Shadow)).effectColor = Color(0.2314, 0.4745, 0.2863, 1)--fff3de
            --this.ruleText.color = Color(0.039, 0.2, 0.286, 1)--723a11
        end
    end
end

--隐藏邀请和复制房间号按钮
function EqsBattlePanel.HideWaitingBtns()
    UIUtil.SetActive(this.inviteBtn.gameObject, false)
    UIUtil.SetActive(this.copyRoomInfoBtn.gameObject, false)
    UIUtil.SetActive(this.changeRoomBtn.gameObject, false)
end

--隐藏邀请和复制房间号按钮
function EqsBattlePanel.ShowWaitingBtns()
    --分数娱乐场房间，不显示分享和复制房间号按钮
    if not BattleModule.IsFkFlowRoom() then
        this.HideWaitingBtns()
        UIUtil.SetActive(this.talkingBtn, false)
        UIUtil.SetActive(this.gpsBtn, false)
        UIUtil.SetActive(this.tuoGuanTipsImg, true)
        return
    end
    UIUtil.SetActive(this.returnToLobbyBtn, false)
    UIUtil.SetActive(this.inviteBtn.gameObject, true)
    UIUtil.SetActive(this.copyRoomInfoBtn.gameObject, true)
    -- UIUtil.SetActive(this.tuoGuanTipsImg, false)
    UIUtil.SetActive(this.changeRoomBtn.gameObject, BattleModule.IsClubRoom())
end

function EqsBattlePanel.SetChangeBtnVisible(visible)
    if BattleModule.isPlayback then
        visible = false
    end
    UIUtil.SetActive(this.changeBtn.gameObject, visible)
end

function EqsBattlePanel.SetChangeBtnAnim(play)
    if BattleModule.isPlayback then
        play = false
    end
    UIUtil.SetActive(this.transform:Find('Content/Btns/HuanSanZhuangBtn/Image'), play)
    UIUtil.SetActive(this.transform:Find('Content/Btns/HuanSanZhuangBtn/light'), play)
end

--隐藏所有操作按钮：换三张、胡、开、对、吃、过
function EqsBattlePanel.HideAllOperationBtns()
    --Log("隐藏所有按钮")
    UIUtil.SetActive(this.huBtn.gameObject, false)
    UIUtil.SetActive(this.kaiBtn.gameObject, false)
    UIUtil.SetActive(this.duiBtn.gameObject, false)
    UIUtil.SetActive(this.chiBtn.gameObject, false)
    UIUtil.SetActive(this.guoBtn.gameObject, false)
end

function EqsBattlePanel.SetGuoBtnVisible(visible)
    UIUtil.SetActive(this.guoBtn.gameObject, visible)
end

function EqsBattlePanel.SetOperationBtn(operation)
    if BattleModule.isPlayback then
        return
    end
    local operation = tonumber(operation)
    if operation == EqsOperation.Hu then
        UIUtil.SetActive(this.huBtn.gameObject, true)
        this.SetGuoBtnVisible(true)
    elseif operation == EqsOperation.Kai then
        --有开必开，不能有过按钮
        UIUtil.SetActive(this.kaiBtn.gameObject, true)
        this.SetGuoBtnVisible(false)
    elseif operation == EqsOperation.Dui then
        UIUtil.SetActive(this.duiBtn.gameObject, true)
        this.SetGuoBtnVisible(true)
    elseif operation == EqsOperation.Chi then
        UIUtil.SetActive(this.chiBtn.gameObject, true)
        this.SetGuoBtnVisible(true)
    elseif operation == EqsOperation.Guo then
        this.SetGuoBtnVisible(true)
    elseif operation == EqsOperation.BaiPai then
        this.SetGuoBtnVisible(false)
    end
end

--设置剩余牌信息
local originLeftCardText = nil
function EqsBattlePanel.SetLeftCard(num)
    -- Log("声音牌张数：", num)
    UIUtil.SetActive(this.leftCardNumText.transform, true)
    if this.leftCardNumText ~= nil then
        this.leftCardNumText.text = string.format("剩余:%s张", num)
    end
end

--设置托管提示显示或关闭
function EqsBattlePanel.SetTuoGuanIsVisable(bool)
    UIUtil.SetActive(this.tuoGuanTips, bool)
end

return EqsBattlePanel