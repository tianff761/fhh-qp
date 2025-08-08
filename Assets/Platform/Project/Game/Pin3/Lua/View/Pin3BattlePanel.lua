Pin3BattlePanel = ClassPanel("Pin3BattlePanel")
Pin3BattlePanel.usersParent = nil          --当前房间所有玩家的父节点
Pin3BattlePanel.fPPosTran = nil          --发牌位置
Pin3BattlePanel.middlePosTran = nil          --中间位置

Pin3BattlePanel.roomNumText = nil             --房间号
Pin3BattlePanel.juShuText = nil           --局数信息
Pin3BattlePanel.baseScoreText = nil           --底分信息
Pin3BattlePanel.lunShuText = nil    --轮数
Pin3BattlePanel.danZhuGoldText = nil    --单注

Pin3BattlePanel.pingText = nil          --ping值
Pin3BattlePanel.energyValueImage = nil          --电量值显示
Pin3BattlePanel.versionInfo = nil          --版本信息
Pin3BattlePanel.dataText = nil          --日期文本

--所有游戏中按钮
Pin3BattlePanel.settingBtn = nil
Pin3BattlePanel.ruleBtn = nil
Pin3BattlePanel.chatBtn = nil
Pin3BattlePanel.qiPaiBtn = nil
Pin3BattlePanel.kanPaiBtn = nil
Pin3BattlePanel.biPaiBtn = nil
---比牌按钮的文字（当前注）
Pin3BattlePanel.BiPaiText = nil
Pin3BattlePanel.genZhuBtn = nil
---跟牌按钮文字
Pin3BattlePanel.GenPaiText = nil
Pin3BattlePanel.jiaZhuBtn = nil
Pin3BattlePanel.liangPaiBtn = nil
Pin3BattlePanel.prepareBtn = nil
---坐下按钮
Pin3BattlePanel.SitdownBtn = nil
Pin3BattlePanel.startGameBtn = nil
--加入房卡游戏按钮
Pin3BattlePanel.joinFkGameBtn = nil

--自动跟注toggle
Pin3BattlePanel.autoYzToggle = nil

--玩家信息节点
Pin3BattlePanel.userPos = nil

--桌面押注筹码区域
Pin3BattlePanel.tableYzGoldRect = nil
--筹码押注区域
Pin3BattlePanel.tableYzRectSizeDelta = nil
--所有加注按钮父节点
Pin3BattlePanel.jiaZhuBtns = nil
--加注筹码等级按钮
Pin3BattlePanel.rankBtns = nil
--桌面押注
Pin3BattlePanel.tableYzText = nil

--提示文本
Pin3BattlePanel.tipText = nil

Pin3BattlePanel.backgrouds = nil

Pin3BattlePanel.uiUpdateToggle = false

Pin3BattlePanel.CountDown = 0

Pin3BattlePanel.ObserverTip = 0

local this = Pin3BattlePanel
Pin3BattlePanel.adaptFullScreen = false
function Pin3BattlePanel:Awake()
    this = self
    self:InitArgs()
end

function Pin3BattlePanel:OnOpened(args)
    Waiting.ForceHide()
    GameSceneManager.SwitchGameSceneEnd(GameSceneType.Room)
    this.AdaptFullScreen()
    this.InitPanel()
    AddLuaComponent(self.gameObject, "Pin3Manager")

    --开始获取电量数据
    AppPlatformHelper.StartGetBatteryStateOnRoom()

    self.SetVersionInfo()
    this.SetPing(30)
    PanelManager.Close(PanelConfig.GoldMatch)
    PanelManager.Close(Pin3Panels.Pin3DanJuJieSuan)
end

function Pin3BattlePanel:OnDestroy()
    AppPlatformHelper.StopGetBatteryStateOnRoom()
end

function Pin3BattlePanel:InitArgs()
    --content组件在1280*760分辨率下，content四周对齐时，上下边距180，为了适配分辨率，其他分辨率时，需要同步修改上下边距
    self.fPPosTran = self:Find("Content/FpPos")
    self.middlePosTran = self:Find("Content/MiddlePos")
    local display = self:Find('Content/DisplayTexts')
    self.roomNumText = display:Find('RoomNumInfo/RoomNum')
    self.juShuText = display:Find('JuShuInfo/JuShuText')
    self.baseScoreText = display:Find('BaseScoreInfo/BaseScore')
    self.lunShuText = display:Find("TableInfo/LunShuInfo")
    self.danZhuGoldText = display:Find("TableInfo/DanZhuInfo")
    self.tableYzText = display:Find("TableInfo/TableYzInfo/Text")

    self.pingText = self:Find("Content/LeftUp/NetworkTime"):GetComponent("Text")
    self.versionInfo = self:Find("Content/LeftUp/VersionInfo")
    self.energyValueImage = self:Find("Content/LeftUp/energy/Image"):GetComponent("Image")
    self.signalImage = self:Find("Content/LeftUp/Signal"):GetComponent("Image")
    self.signalValue = self.signalImage.transform:Find("SignalValue"):GetComponent("Image")

    local btns = self:Find("Content/Btns")
    self.settingBtn = btns:Find('SettingBtn')
    self.ruleBtn = btns:Find('RuleBtn')
    self.chatBtn = btns:Find('ChatBtn')
    self.qiPaiBtn = btns:Find('QiPaiBtn')
    self.kanPaiBtn = btns:Find('KanPaiBtn')
    self.biPaiBtn = btns:Find('BiPaiBtn')
    self.BiPaiText = self.biPaiBtn:Find("Text")
    self.genZhuBtn = btns:Find('GenZhuBtn')
    self.GenPaiText = self.genZhuBtn:Find("Text")
    this.CancelAutoGen = btns:Find('CancelAutoGen')
    this.xuli = self.genZhuBtn:Find("Mask/xuli")
    self.jiaZhuBtn = btns:Find('JiaZhuBtn')
    self.liangPaiBtn = btns:Find('LiangPaiBtn')
    self.prepareBtn = btns:Find("PrepareBtn")
    self.SitdownBtn = btns:Find("SitdownBtn")
    self.startGameBtn = btns:Find("StartGameBtn")
    self.joinFkGameBtn = btns:Find("JoinFkGameBtn")
    self.autoYzToggle = btns:Find("AutoYzToggle")
    self.jiaZhuBtns = btns:Find("JiaZhuBtns")

    self.tableYzGoldRect = self:Find("Content/TableYzGold"):GetComponent(TypeRectTransform)
    self.tableYzRectSizeDelta = self.tableYzGoldRect.sizeDelta

    self.Clock = self:Find("Clock")
    self.ClockCountdown = self.Clock:Find("Countdown")
    self.ClockLabel = self.Clock:Find("Label")

    self.userPos = {}
    local playerPositions = self:Find("Content/Players")
    for i = 1, Pin3Data.totalUserNum do
        self.userPos[i] = playerPositions:Find("Pos" .. tostring(i))
    end

    self.tipText = self:Find("Tips/Text")

    self.ObserverTip = self:Find("ObserverTip")

    self.backgrouds = {}
    self.backgrouds[1] = self:Find("Bgs/TableBg1")
    self.backgrouds[2] = self:Find("Bgs/TableBg2")
    self.backgrouds[3] = self:Find("Bgs/TableBg3")
    self.backgrouds[4] = self:Find("Bgs/TableBg4")
    for _, backgroud in pairs(self.backgrouds) do
        UIUtil.SetBackgroundAdaptation(backgroud.gameObject)
    end

    --------------------------------
    --回放指示手指
    this.handTrans = self:Find("Hand")
    this.handGO = this.handTrans.gameObject
    this.handTweener = this.handGO:GetComponent("TweenScale")
    this.handTweener:AddLuaFinished(this.OnHandTweenerCompleted)
end

function Pin3BattlePanel.AdaptFullScreen()
    if UnityEngine.Screen.width / UnityEngine.Screen.height > 1.95 and this.adaptFullScreen then
        --根节点
        --local rect = this.transform:GetComponent("RectTransform")
        --rect.offsetMin = Vector2(100, 0)
        --rect.offsetMax = Vector2(100, 0) * -1
    end
end

function Pin3BattlePanel.UpdateTableBackgroud()
    for i, back in pairs(this.backgrouds) do
        UIUtil.SetActive(back, i == Pin3Data.tableBackType)
    end
end

function Pin3BattlePanel.GetTransform()
    return this.transform
end

function Pin3BattlePanel.GetPosByUIIdx(idx)
    return this.userPos[idx]
end

function Pin3BattlePanel.IsUiUpdateToggle()
    return this.uiUpdateToggle
end

function Pin3BattlePanel.InitPanel()
    this:AddOnClick(this.ruleBtn, Pin3Manager.OnClickRuleBtn)
    if Pin3Data.isPlayback then
        UIUtil.SetActive(this.settingBtn, false)
        UIUtil.SetActive(this.chatBtn, false)
        this.SetObserverTipActive(false)
        UIUtil.SetActive(this.SitdownBtn, false)
    else
        this:AddOnClick(this.settingBtn, Pin3Manager.OnClickSettingBtn)
        this:AddOnClick(this.ruleBtn, Pin3Manager.OnClickRuleBtn)
        this:AddOnClick(this.kanPaiBtn, Pin3Manager.OnClickKanPaiBtn)
        this:AddOnClick(this.qiPaiBtn, Pin3Manager.OnClickQiPaiBtn)
        this:AddOnClick(this.biPaiBtn, Pin3Manager.OnClickBiPaiBtn)
        --UIDownUpListener.Get(this.genZhuBtn.gameObject).onDown = this.OnGenZhuDown
        --UIDownUpListener.Get(this.genZhuBtn.gameObject).onUp = this.OnGenZhuUp
        this:AddOnClick(this.genZhuBtn, Pin3Manager.OnClickGenZhuBtn)
        this:AddOnClick(this.CancelAutoGen, this.OnClickCancelAutoGen)
        this:AddOnClick(this.jiaZhuBtn, this.SetJiaZhuBtnsDisplay)
        this:AddOnClick(this.liangPaiBtn, Pin3Manager.OnClickLiangPaiBtn)
        this:AddOnClick(this.prepareBtn, Pin3Manager.OnClickPrepare)
        this:AddOnClick(this.startGameBtn, Pin3NetworkManager.SendStartGame)
        this:AddOnClick(this.SitdownBtn, Pin3NetworkManager.SendSitdownMessage)
        this:AddOnClick(this.joinFkGameBtn, Pin3NetworkManager.SendJoinFkGame)
        this:AddOnToggle(this.autoYzToggle, function(isOn)
            Pin3Manager.OnClickAutoYzToggle(isOn)
        end)

        --注册聊天按钮
        ChatModule.RegisterChatTextEvent(this.chatBtn.gameObject)
    end

    this.SetTime()
    this.UpdateTableInfo()
    this.HideOperBtns()
    this.ShowTips()
    this.HidePlaybackHand()

    this.UpdateTableBackgroud()
end

-- 跟注按钮按下
function Pin3BattlePanel.OnGenZhuDown(listener, eventData)
    this.isDown = true
    this.downTime = Time.realtimeSinceStartup
    this.isShowXuli = false
    this.StartDownTimer()
    if this.isAutoMenu then
        this.HideAutoMenu()
    end
end

-- 跟注按钮弹起
function Pin3BattlePanel.OnGenZhuUp(listener, eventData)
    this.isDown = false
    this.isShowXuli = false
    this.StopDownTimer()
    UIUtil.SetActive(this.xuli, false)
    if eventData.pointerCurrentRaycast.gameObject ~= eventData.pointerPressRaycast.gameObject then
        return
    end
    if this.isAutoMenu then
        return
    end
    -- 点击一次
    if Time.realtimeSinceStartup > 0.2 then
        Pin3Manager.OnClickGenZhuBtn()
    end
end

function Pin3BattlePanel.OnClickCancelAutoGen()
    Pin3NetworkManager.SendAutoYaZhu(0)
end

-- 隐藏自动菜单
function Pin3BattlePanel.HideAutoMenu()
    this.isAutoMenu = false
    UIUtil.SetActive(this.autoMenu, false);
end

-- 启动按下的Timer
function Pin3BattlePanel.StartDownTimer()
    if this.downTimer == nil then
        this.downTimer = Timing.New(this.OnDownTimer, 0.1)
    end
    this.downTimer:Start()
end

-- 停止按下的Timer
function Pin3BattlePanel.StopDownTimer()
    if this.downTimer ~= nil then
        this.downTimer:Stop()
        this.downTimer = nil
    end
end

-- 处理按下的Timer
function Pin3BattlePanel.OnDownTimer()
    if this.isDown then
        if not this.isShowXuli then
            if Time.realtimeSinceStartup - this.downTime > 0.2 then
                this.isShowXuli = true
                UIUtil.SetActive(this.xuli, true)
            end
        end
        if Time.realtimeSinceStartup - this.downTime > 1 then
            this.StopDownTimer()
            Pin3Manager.OnClickGenZhuBtn()
            Pin3NetworkManager.SendAutoYaZhu(1)
        end
    end
end

function Pin3BattlePanel.UpdateBtnsText()
    local yz = 0
    if Pin3Data.GetSelfIsKanPai() then
        yz = Pin3Data.curDanZhuGold * 2
    else
        yz = Pin3Data.curDanZhuGold
    end
    UIUtil.SetText(this.BiPaiText, tostring(yz * 2) .. "\n比牌")
    UIUtil.SetText(this.GenPaiText, tostring(yz) .. "\n跟注")
end

function Pin3BattlePanel.UpdateTableInfo()
    UIUtil.SetText(this.roomNumText, tostring(Pin3Data.roomId))
    UIUtil.SetText(this.baseScoreText, tostring(Pin3Data.GetRule(Pin3RuleType.baseScore)))
    UIUtil.SetText(this.lunShuText, "轮数: " .. tostring(Pin3Data.curLunShu) .. "/" .. tostring(Pin3Data.GetRule(Pin3RuleType.maxLunShu)))
    --UIUtil.SetText(this.danZhuGoldText, "单注: " .. tostring(Pin3Data.curDanZhuGold))
    UIUtil.SetText(this.danZhuGoldText, "总注: " .. tostring(Pin3Data.curTotalYzGold))
    --UIUtil.SetText(this.tableYzText, tostring(Pin3Data.curTotalYzGold))
    --LogError("<color=aqua>Pin3Data.curYz</color>", Pin3Data.curYz, Pin3Data.BaseScore)
    this.UpdateBtnsText()
    local juShu = Pin3Data.GetRule(Pin3RuleType.juShu)
    if juShu >= 0 then
        UIUtil.SetText(this.juShuText, tostring(Pin3Data.curJuShu) .. "/" .. tostring(juShu))
    else
        UIUtil.SetText(this.juShuText, "无限局")
    end
    --Log("==>UpdateTableInfo", Pin3Data.GetIsJoinGame(Pin3Data.uid))
    this.uiUpdateToggle = true
    local isOn = Pin3Data.GetIsAutoYaZhu(Pin3Data.GetSelfUidInGame())
    --LogError("<color=aqua>Pin3Data.gameStatus</color>", Pin3Data.gameStatus)
    if isOn ~= nil and Pin3Data.gameStatus ~= Pin3GameStatus.WaitingPrepare then
        if UIUtil.GetToggle(this.autoYzToggle) ~= isOn then
            UIUtil.SetToggle(this.autoYzToggle, isOn == true)
        end
        --UIUtil.SetActive(this.CancelAutoGen, isOn)
    elseif Pin3Data.gameStatus == Pin3GameStatus.WaitingPrepare then
        UIUtil.SetActive(this.CancelAutoGen, false)
    end
    this.uiUpdateToggle = false

    Log("-------------Pin3Data.IsFkFlowRoom()", Pin3Data.isStartGame, Pin3Data.ownerId, Pin3Data.curJuShu, Pin3Data.IsFkFlowRoom(), Pin3Data.gameStatus, Pin3Data.GetIsPrepare(Pin3Data.uid))
    if Pin3Data.IsFkFlowRoom() then
        if Pin3Data.isStartGame then
            UIUtil.SetActive(this.joinFkGameBtn, false)--Pin3Data.GetIsJoinGame(Pin3Data.uid) == false
            UIUtil.SetActive(this.startGameBtn, false)
        else
            UIUtil.SetActive(this.joinFkGameBtn, false)
            UIUtil.SetActive(this.startGameBtn, false)
            if Pin3Data.uid == Pin3Data.ownerId then
                UIUtil.SetActive(this.startGameBtn, Pin3Data.curJuShu <= 1 and Pin3Data.gameStatus == Pin3GameStatus.WaitingPrepare and Pin3Data.GetIsPrepare(Pin3Data.uid))
            else
                UIUtil.SetActive(this.startGameBtn, false)
            end
        end
    else
        UIUtil.SetActive(this.startGameBtn, false)
        UIUtil.SetActive(this.joinFkGameBtn, false)
    end
end

function Pin3BattlePanel.SetTime()
    local time = this:Find("Content/LeftUp/Time")
    if Pin3Data.isPlayback then
        if IsNumber(Pin3PlaybackManager.time) then
            UIUtil.SetText(time, os.date("%Y-%m-%d %H:%M", Pin3PlaybackManager.time))
        else
            UIUtil.SetText(time, "")
        end
    else
        UIUtil.SetText(time, os.date("%Y-%m-%d %H:%M"))
        Scheduler.unscheduleGlobal(this.setTimeSchedule)
        this.setTimeSchedule = Scheduler.scheduleGlobal(function()
            if IsNull(time) then
                Scheduler.unscheduleGlobal(this.setTimeSchedule)
            else
                UIUtil.SetText(time, os.date("%Y-%m-%d %H:%M"))
            end
        end, 59)
    end
end

function Pin3BattlePanel.SetPing(pingValue)
    LogError("<color=aqua>SetPing</color>")
    --更新网络环境
    this.UpdateNetType()
    --更新网络信号强度
    this.UpdateNetPing(pingValue)
end

function Pin3BattlePanel.ShowTips(tipStr)
    if string.IsNullOrEmpty(tipStr) then
        UIUtil.SetActive(this.tipText.parent, false)
    else
        UIUtil.SetActive(this.tipText.parent, true)
        UIUtil.SetText(this.tipText, tipStr)
    end
end

function Pin3BattlePanel.UpdateClock(str, time)
    if not string.IsNullOrEmpty(str) then
        UIUtil.SetActive(this.Clock, true)
        UIUtil.SetText(this.ClockLabel, str)
        Scheduler.unscheduleGlobal(this.timeSchedule)
        this.CountDown = time
        UIUtil.SetText(this.ClockCountdown, tostring(this.CountDown))
        this.timeSchedule = Scheduler.scheduleGlobal(function()
            this.CountDown = this.CountDown - 1
            if this.CountDown <= 0 then
                Scheduler.unscheduleGlobal(this.timeSchedule)
                UIUtil.SetActive(this.Clock, false)
            else
                --LogError("this.ClockCountdown", this.ClockCountdown)
                UIUtil.SetText(this.ClockCountdown, tostring(this.CountDown))
            end
        end, 1)
    end
end

--更新网络类型
function Pin3BattlePanel.UpdateNetType()
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

function Pin3BattlePanel.UpdateNetPing(value)
    if string.IsNullOrEmpty(value) then
        return
    end
    UIUtil.SetText(this.pingText.transform, tostring(value))

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

    this.signalValue.sprite = ResourcesManager.LoadSpriteBySynch(BundleName.Room, spriteName)
end

function Pin3BattlePanel.SetVersionInfo()
    if Pin3Data.isPlayback then
        UIUtil.SetActive(this.versionInfo.gameObject, false)
    else
        UIUtil.SetActive(this.versionInfo.gameObject, true)
        local info = "Res:" .. Functions.GetResVersionStr(GameType.Pin3) .. " Line:"
        if Pin3Data.port == nil or Pin3Data.port <= 0 then
            info = info .. "0"
        else
            local line = tostring(Pin3Data.port % 100)
            if #line == 1 then
                line = "0" .. line
            end
            info = info .. line
        end
        UIUtil.SetText(this.versionInfo, info)
    end
end

--设置电量
function Pin3BattlePanel.SetEnergyValue(value)
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

function Pin3BattlePanel.GetFaPaiTran()
    return this.fPPosTran
end

function Pin3BattlePanel.GetMiddleTran()
    return this.middlePosTran
end

--isKanPai：是否看牌
function Pin3BattlePanel.ShowOperBtns()
    Log("==>Pin3BattlePanel.ShowOperBtns", GetTableString(Pin3Data))
    if Pin3Data.gameStatus == Pin3GameStatus.WaitingUserPerform then
        if Pin3Data.GetIsPrepare(Pin3Data.uid) and Pin3Data.GetShuStatus(Pin3Data.uid) == 0 then
            UIUtil.SetActive(this.qiPaiBtn, true)
            UIUtil.SetActive(this.kanPaiBtn, true)
            UIUtil.SetActive(this.biPaiBtn, true)
            UIUtil.SetActive(this.genZhuBtn, true)
            UIUtil.SetActive(this.jiaZhuBtn, true)
            UIUtil.SetActive(this.autoYzToggle, true)
            this.biPaiBtnImage = this.biPaiBtnImage or this.biPaiBtn:GetComponent(TypeImage)
            this.genZhuBtnImage = this.genZhuBtnImage or this.genZhuBtn:GetComponent(TypeImage)
            this.jiaZhuBtnImage = this.jiaZhuBtnImage or this.jiaZhuBtn:GetComponent(TypeImage)
            --该自己操作
            if Pin3Data.GetOperStatus(Pin3Data.uid) == 1 then
                this.SetUIGrayBtn(this.kanPaiBtn, Pin3Data.GetIsCanKanPai(Pin3Data.uid) and not Pin3Data.GetIsKanPai(Pin3Data.uid) and Pin3Data.curLunShu > Pin3Data.GetRule(Pin3RuleType.menLunShu))
                local biPaiBtnInteractable = Pin3Data.curLunShu > Pin3Data.GetRule(Pin3RuleType.menLunShu)
                local jiaZhuBtnInteractable = tonumber(Pin3Data.curDanZhuGold) < Pin3Data.GetRule(Pin3RuleType.fengZhu)
                this.SetUIGrayBtn(this.biPaiBtnImage, biPaiBtnInteractable)
                this.SetUIGrayBtn(this.genZhuBtnImage, true)
                this.SetUIGrayBtn(this.jiaZhuBtnImage, jiaZhuBtnInteractable)
            elseif Pin3Data.GetOperStatus(Pin3Data.uid) == 0 then
                --该其他人操作
                this.SetUIGrayBtn(this.kanPaiBtn, Pin3Data.GetIsCanKanPai(Pin3Data.uid) and not Pin3Data.GetIsKanPai(Pin3Data.uid) and Pin3Data.curLunShu > Pin3Data.GetRule(Pin3RuleType.menLunShu))
                this.SetUIGrayBtn(this.biPaiBtnImage, false)
                this.SetUIGrayBtn(this.genZhuBtnImage, false)
                this.SetUIGrayBtn(this.jiaZhuBtnImage, false)
            end
        else
            this.HideOperBtns()
        end
    else
        this.HideOperBtns()
    end
end

function Pin3BattlePanel.SetSitdownBtnActive(bool)
    UIUtil.SetActive(this.SitdownBtn, bool)
end

function Pin3BattlePanel.JudgeShowSitdownBtn()
    local active = GetTableSize(Pin3Data.userDatas) <= Pin3Data.parsedRules.playerTotal and Pin3Data.IsObserver
    UIUtil.SetActive(this.SitdownBtn, active)
end

function Pin3BattlePanel.SetObserverTipActive(bool)
    UIUtil.SetActive(this.ObserverTip, bool)
end

function Pin3BattlePanel.SetUIGrayBtn(image, bool)
    local GrayBtn = image.transform:GetChild(0)
    UIUtil.SetActive(GrayBtn, not bool)
    image:GetComponent(TypeButton).interactable = bool
end

function Pin3BattlePanel.SetNullMaterialByInteractable(interactable, image)
    if interactable then
        image.material = nil
    else
        this.SetUIGrayMaterial(image)
    end
end

function Pin3BattlePanel.SetRayCastTarget(image, bool)
    image.raycastTarget = bool
end

function Pin3BattlePanel.HideOperBtns()
    Log("==>Pin3BattlePanel.HideOperBtns")
    UIUtil.SetActive(this.qiPaiBtn, false)
    UIUtil.SetActive(this.kanPaiBtn, false)
    UIUtil.SetActive(this.biPaiBtn, false)
    UIUtil.SetActive(this.genZhuBtn, false)
    UIUtil.SetActive(this.jiaZhuBtn, false)
    UIUtil.SetActive(this.autoYzToggle, false)
    Pin3BattlePanel.SetJiaZhuBtnsDisplay(false)
end

function Pin3BattlePanel.SetPrepareBtnVisible(visible)
    --LogError("<color=aqua>SetPrepareBtnVisible</color>", visible)
    UIUtil.SetActive(this.prepareBtn, visible)
end

function Pin3BattlePanel.SetStartGameBtnVisible(visible)
    UIUtil.SetActive(this.startGameBtn, visible)
end

function Pin3BattlePanel.SetLiangPaiBtnVisible(visible)
    -- UIUtil.SetActive(this.liangPaiBtn, visible)
    --屏蔽亮牌功能
    UIUtil.SetActive(this.liangPaiBtn, false)
end

--当前添加筹码次数
Pin3BattlePanel.addGoldTimes = 0
--添加押注金币
function Pin3BattlePanel.AddYzGoldTran(goldTran)
    Log("==>添加桌面筹码", goldTran)
    if goldTran ~= nil then
        goldTran:SetParent(this.tableYzGoldRect)
        this.addGoldTimes = this.addGoldTimes + 1
        local x = this.tableYzRectSizeDelta.x / 2 * this.addGoldTimes / 10
        local y = this.tableYzRectSizeDelta.y / 2 * this.addGoldTimes / 10
        if x > 200 then
            x = 200
        end
        if y > 50 then
            y = 50
        end
        goldTran:DOAnchorPos(Vector2(Util.Random(-x, x), Util.Random(-y, y)), 0.3):SetEase(DG.Tweening.Ease.Linear)
        Pin3AudioManager.PlayAudio(Pin3AudioType.AddGold)
    end
end

--清理所有的周末押注筹码
function Pin3BattlePanel.ClearAllYzGoldTran()
    this.addGoldTimes = 0
    ClearChildren(this.tableYzGoldRect)
end

--重置数据准备下一局
function Pin3BattlePanel.ResetForNext()
    this.ClearAllYzGoldTran()
end

--获取押注筹码图标
function Pin3BattlePanel.GetGoldTran(gold, uid)
    local baseScore = Pin3Data.GetRule(Pin3RuleType.baseScore)
    local maxFengDingBeiShu = Pin3Data.GetRule(Pin3RuleType.fengZhu) / baseScore
    local beiShu = gold / baseScore
    local configs = Pin3JiaZhuConfig[maxFengDingBeiShu]
    local config = nil
    if Pin3Data.GetIsKanPai(uid) then
        beiShu = beiShu / 2
    end
    for rank = 1, 10 do
        config = configs[rank]
        if config ~= nil then
            if config.beiShu >= beiShu then
                if this.rankBtns[rank] ~= nil then
                    local go = NewObject(this.rankBtns[rank].gameObject, this.GetTransform())
                    local btn = go:GetComponent(TypeButton)
                    if btn ~= nil then
                        DestroyObj(btn)
                    end
                    UIUtil.SetLocalScale(go, 0.33, 0.33, 0.33)
                    UIUtil.SetActive(go, true)
                    UIUtil.SetText(go.transform:Find("Text"), tostring(gold))

                    local rectTran = go:GetComponent(TypeRectTransform)
                    rectTran.anchorMax = Vector2.one / 2
                    rectTran.anchorMin = Vector2.one / 2
                    return rectTran
                end
            end
        end
    end
    Log("GetGoldTran", Pin3Data.GetRule(Pin3RuleType.fengZhu), baseScore, maxFengDingBeiShu, gold, beiShu, GetTableString(configs))
    return nil
end

--初始化加注按钮
function Pin3BattlePanel.InitJiaZhuBtns()
    local bgBtn = this.jiaZhuBtns:Find("JiaZhuBgBtn")
    this:AddOnClick(bgBtn, this.SetJiaZhuBtnsDisplay)
    local baseScore = Pin3Data.GetRule(Pin3RuleType.baseScore)
    local maxFengDingBeiShu = Pin3Data.GetRule(Pin3RuleType.fengZhu) / baseScore
    Log("InitJiaZhuBtns", maxFengDingBeiShu, Pin3Data.GetRule(Pin3RuleType.fengZhu), baseScore)
    local configs = Pin3JiaZhuConfig[maxFengDingBeiShu]
    this.rankBtns = {}
    local beiShu = nil
    local text = nil
    LogError("this.rankBtns", this.rankBtns)
    for i = 1, 10 do
        this.rankBtns[i] = this.jiaZhuBtns:Find("Btns/Rank" .. tostring(i) .. "Btn")
        if i <= #configs then
            local config = configs[i]
            if config ~= nil then
                local gold = baseScore * config.beiShu
                text = this.rankBtns[i]:Find("Text")
                UIUtil.SetText(text, tostring(gold))
                this:AddOnClick(this.rankBtns[i], function()
                    gold = baseScore * config.beiShu
                    -- Log("101705=========>", Pin3Data.GetIsKanPai(Pin3Data.uid), baseScore, config, gold, baseScore * config.beiShu)
                    if Pin3Data.GetIsKanPai(Pin3Data.uid) then
                        gold = gold * 2
                    end
                    Pin3Manager.OnClickJiaZhuBtn(gold)
                end)
            end
        end
    end
    this.SetJiaZhuBtnsDisplay(false)
end

---加注按钮显示
function Pin3BattlePanel.SetJiaZhuBtnsDisplay(visible)
    if IsBool(visible) then
        UIUtil.SetActive(this.jiaZhuBtns, visible)
    else
        visible = not this.jiaZhuBtns.gameObject.activeSelf
    end
    UIUtil.SetActive(this.jiaZhuBtns, visible)

    if visible and this.rankBtns ~= nil then
        --计算按钮范围显示
        local min = 0
        local max = 0
        local isKanPai = Pin3Data.GetIsKanPai(Pin3Data.uid)
        --如果已经看牌，则为封住大小
        if isKanPai then
            min = Pin3Data.curDanZhuGold * 2
            max = Pin3Data.GetRule(Pin3RuleType.fengZhu) * 2
        else
            min = Pin3Data.curDanZhuGold
            max = Pin3Data.GetRule(Pin3RuleType.fengZhu)
        end
        local baseScore = Pin3Data.GetRule(Pin3RuleType.baseScore)
        local maxFengDingBeiShu = Pin3Data.GetRule(Pin3RuleType.fengZhu) / baseScore
        local configs = Pin3JiaZhuConfig[maxFengDingBeiShu]
        Log("===>min", min, " max", max, maxFengDingBeiShu, " configs", configs)
        local beiShu = nil
        local config = nil
        local gold = nil
        local canGenZhu = false
        for i = 1, 10 do
            if i > #configs then
                LogError("隐藏筹码Index", this.rankBtns[i])
                UIUtil.SetActive(this.rankBtns[i], false)
            else
                config = configs[i]
                if config ~= nil and this.rankBtns[i] ~= nil then
                    if isKanPai then
                        gold = baseScore * config.beiShu * 2
                    else
                        gold = baseScore * config.beiShu
                    end
                    if gold > tonumber(min) and gold <= tonumber(max) then
                        LogError("加注筹码Index", i)
                        UIUtil.SetActive(this.rankBtns[i], true)
                        UIUtil.SetText(this.rankBtns[i]:Find("Text"), tostring(gold))
                        canGenZhu = true
                    else
                        UIUtil.SetActive(this.rankBtns[i], false)
                    end
                end
            end
        end
        this.jiaZhuBtn:GetComponent(TypeButton).interactable = canGenZhu
    end
end

--显示回放手
function Pin3BattlePanel.ShowPlaybackHand(targetGameObject)
    UIUtil.SetActive(this.handGO, true)
    UIUtil.SetPosition(this.handGO, targetGameObject.transform.position)
    this.handTweener:ResetToBeginning()
    this.handTweener:PlayForward()
end

--手引导相关
function Pin3BattlePanel.HidePlaybackHand()
    UIUtil.SetActive(this.handGO, false)
end

--手动画播放完成
function Pin3BattlePanel.OnHandTweenerCompleted()
    --完成后检测
    this.HidePlaybackHand()
end

return Pin3BattlePanel