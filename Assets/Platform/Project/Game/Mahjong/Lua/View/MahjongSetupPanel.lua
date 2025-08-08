MahjongSetupPanel = ClassPanel("MahjongSetupPanel")
MahjongSetupPanel.Instance = nil
--
local this = nil
--
--初始属性数据
function MahjongSetupPanel:InitProperty()

end

--UI初始化
function MahjongSetupPanel:OnInitUI()
    this = self
    this:InitProperty()

    local content = self:Find("Content")

    this.closeBtn = content:Find("Background/CloseBtn").gameObject
    local nodeTrans = content:Find("Node")

    this.musicSliderGO = nodeTrans:Find("Music/Slider").gameObject
    this.musicSlider = this.musicSliderGO:GetComponent("Slider")
    this.soundSliderGO = nodeTrans:Find("Sound/Slider").gameObject
    this.soundSlider = this.soundSliderGO:GetComponent("Slider")

    this.musicOpenBtn = nodeTrans:Find("Music/OpenBtn").gameObject
    this.musicCloseBtn = nodeTrans:Find("Music/CloseBtn").gameObject

    this.soundOpenBtn = nodeTrans:Find("Sound/OpenBtn").gameObject
    this.soundCloseBtn = nodeTrans:Find("Sound/CloseBtn").gameObject

    this.tablecloth = {}
    local tableclothTrans = nodeTrans:Find("Tablecloth")
    for i = 1, 3 do
        this.tablecloth[i] = tableclothTrans:Find(tostring(i)):GetComponent(TypeToggle)
    end

    local tingPaiTrans = nodeTrans:Find("TingPai/TingPaiTips")
    local activeTrans = tingPaiTrans:Find("Active")
    this.tingPaiActive = activeTrans.gameObject
    this.tingPaiTween = activeTrans:Find("Handle"):GetComponent(TypeTweenPosition)
    this.tingPaiCloseNode = activeTrans:Find("CloseNode").gameObject
    this.tingPaiNone = tingPaiTrans:Find("None").gameObject

    this.dismissBtnGameObject = nodeTrans:Find("DismissButton").gameObject
    this.dismissBtn = nodeTrans:Find("DismissButton"):GetComponent(TypeButton)
    this.quitBtn = nodeTrans:Find("QuitButton").gameObject

    this.AddUIListenerEvent()
end


--当面板开启开启时
function MahjongSetupPanel:OnOpened()
    MahjongSetupPanel.Instance = self
    this.AddListenerEvent()

    --设置背景音乐大小
    this.musicSlider.value = AudioManager.GetBackgroundVolume()
    --设置音效声音大小
    this.soundSlider.value = AudioManager.GetSoundVolume()

    this.SetMusicBtn(this.musicSlider.value)
    this.SetSoundBtn(this.soundSlider.value)

    this.UpdateButtonDisplay()
    this.UpdateTableclothDisplay()
    this.CheckTingPaiTiShi()
end

--当面板关闭时调用
function MahjongSetupPanel:OnClosed()
    MahjongSetupPanel.Instance = nil

    this.RemoveListenerEvent()
end

------------------------------------------------------------------
--
--关闭
function MahjongSetupPanel.Close()
    PanelManager.Close(MahjongPanelConfig.Setup)
end
--
function MahjongSetupPanel.AddListenerEvent()
    AddEventListener(CMD.Game.Mahjong.GameBegin, this.OnGameBegin)
end
--
function MahjongSetupPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Game.Mahjong.GameBegin, this.OnGameBegin)
end

--UI相关事件
function MahjongSetupPanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.dismissBtnGameObject, this.OnQuitOrDismissBtnClick)
    this:AddOnClick(this.quitBtn, this.OnQuitOrDismissBtnClick)

    this.musicSlider.onValueChanged:AddListener(this.OnMusicValueChanged)
    this.soundSlider.onValueChanged:AddListener(this.OnSoundValueChanged)

    this:AddOnClick(this.tingPaiActive, this.OnTingPaiActiveClick)
    this.tingPaiTween.onFinished = this.OnTingPaiTweenCompleted

    for i = 1, #this.tablecloth do
        UIToggleListener.AddListener(this.tablecloth[i].gameObject, this.OnTableclothValueChanged)
    end

    this:AddOnClick(this.musicOpenBtn, function () this.OnMusicClick(0) end)
    this:AddOnClick(this.musicCloseBtn, function () this.OnMusicClick(1) end)
    this:AddOnClick(this.soundOpenBtn, function () this.OnSoundClick(0) end)
    this:AddOnClick(this.soundCloseBtn, function () this.OnSoundClick(1) end)
end

------------------------------------------------------------------
--音乐按钮设置
function MahjongSetupPanel.SetMusicBtn(value)
    UIUtil.SetActive(this.musicOpenBtn, value > 0)
    UIUtil.SetActive(this.musicCloseBtn, value == 0)
end

--音效按钮设置
function MahjongSetupPanel.SetSoundBtn(value)
    UIUtil.SetActive(this.soundOpenBtn, value > 0)
    UIUtil.SetActive(this.soundCloseBtn, value == 0)
end

--游戏音乐点击
function MahjongSetupPanel.OnMusicClick(value)
    AudioManager.SetBackgroudVolume(value)
    this.SetMusicBtn(value)
end

--游戏音效点击
function MahjongSetupPanel.OnSoundClick(value)
    AudioManager.SetSoundVolume(value)
    this.SetSoundBtn(value)
end

--
--更新按钮显示状态
function MahjongSetupPanel.UpdateButtonDisplay()
    --是否有按钮显示
    local isButtonDisplay = false

    --房卡流程不变，分数有限局需要申请解散，跟房卡流程一样；分数场无限局房卡打牌过程中不解散，游戏未开始可以退出
    --分数场处理不一样
    if MahjongDataMgr.roomType == RoomType.Match then
        UIUtil.SetActive(this.dismissBtnGameObject, false)
        UIUtil.SetActive(this.quitBtn, false)
    elseif MahjongDataMgr.IsGoldRoomInfinite() then
        if MahjongDataMgr.IsGameBegin() then
            UIUtil.SetActive(this.dismissBtnGameObject, false)
            UIUtil.SetActive(this.quitBtn, false)
        else
            isButtonDisplay = true
            UIUtil.SetActive(this.dismissBtnGameObject, false)
            UIUtil.SetActive(this.quitBtn, true)
        end
    else
        --游戏开始，都需要解散
        if MahjongDataMgr.IsRoomBegin() then
            -- UIUtil.SetActive(this.dismissBtnGameObject, true)
            UIUtil.SetActive(this.quitBtn, false)
            isButtonDisplay = true
        else
            --大厅的房间需要判断房主
            if MahjongDataMgr.roomType == RoomType.Lobby then
                if MahjongDataMgr.IsRoomOwner() then
                    -- UIUtil.SetActive(this.dismissBtnGameObject, true)
                    this.dismissBtn.interactable = true
                    UIUtil.SetActive(this.quitBtn, true)
                else
                    UIUtil.SetActive(this.dismissBtnGameObject, false)
                    UIUtil.SetActive(this.quitBtn, true)
                end
                isButtonDisplay = true
            elseif MahjongDataMgr.roomType == RoomType.Club then
                UIUtil.SetActive(this.dismissBtnGameObject, false)
                UIUtil.SetActive(this.quitBtn, true)
                isButtonDisplay = true
            else
                UIUtil.SetActive(this.dismissBtnGameObject, false)
                UIUtil.SetActive(this.quitBtn, true)
                isButtonDisplay = true
            end
        end
    end
end

--更新桌布显示
function MahjongSetupPanel.UpdateTableclothDisplay()
    for i = 1, #this.tablecloth do
        this.tablecloth[i].isOn = false
    end
    local id = MahjongUtil.GetTableclothId()
    local index = tonumber(id)
    local toggle = this.tablecloth[index]
    if toggle == nil then
        toggle = this.tablecloth[1]
    end
    toggle.isOn = true
end

------------------------------------------------------------------
--
function MahjongSetupPanel.OnCloseBtnClick()
    this.Close()
end
--
function MahjongSetupPanel.OnQuitOrDismissBtnClick()
    --Log(">> MahjongSetupPanel.OnQuitOrDismissBtnClick > ", MahjongDataMgr.gameIndex , MahjongDataMgr.isRoomEnd)
    --如果结算信息还在，则推动检测
    MahjongRoomMgr.CheckSettlement()

    if MahjongDataMgr.isRoomEnd then
        Alert.Prompt("游戏已经结束，是否退出房间？", this.OnExitRoomAlert)
        this.Close()
        return
    end

    if MahjongDataMgr.IsGoldRoomInfinite() then
        if MahjongDataMgr.IsGameBegin() then
            Toast.Show("牌局已经开始")
        else
            Alert.Prompt("是否退出房间？", this.OnQuitRoomAlert)
        end
    else
        if MahjongDataMgr.IsRoomBegin() then
            Alert.Prompt("牌局已经开始，是否申请解散？", this.OnApplyDismissAlert)
        else
            if MahjongDataMgr.roomType == RoomType.Lobby and MahjongDataMgr.IsRoomOwner() then
                Alert.Prompt("是否解散房间？", this.OnRoomOwnerDismissAlert)
            else
                Alert.Prompt("是否退出房间？", this.OnQuitRoomAlert)
            end
        end
    end
end

function MahjongSetupPanel.OnMusicValueChanged(value)
    AudioManager.SetBackgroudVolume(value)
end

function MahjongSetupPanel.OnSoundValueChanged(value)
    AudioManager.SetSoundVolume(value)
end

--桌布切换
function MahjongSetupPanel.OnTableclothValueChanged(isOn, listener)
    if isOn then
        local id = listener.name
        MahjongUtil.SetTableclothId(id)
        if MahjongRoomPanel.Instance ~= nil then
            MahjongRoomPanel.Instance.UpdateTablecloth(id)
        end
    end
end

--解散房间提示框确认处理
function MahjongSetupPanel.OnApplyDismissAlert()
    MahjongCommand.SendDismiss()
end

--房主解散房间处理，游戏开始，直接申请解散
function MahjongSetupPanel.OnRoomOwnerDismissAlert()
    if MahjongDataMgr.IsRoomBegin() then
        MahjongCommand.SendDismiss()
    else
        MahjongCommand.SendQuitRoom()
    end
end

--退出房间提示框确认处理
function MahjongSetupPanel.OnQuitRoomAlert()
    local isCanQuit = true

    if MahjongDataMgr.IsGoldRoomInfinite() then
        if MahjongDataMgr.IsGameBegin() then
            isCanQuit = false
        end
    else
        if MahjongDataMgr.IsRoomBegin() then
            isCanQuit = false
        end
    end

    if isCanQuit then
        MahjongCommand.SendQuitRoom()
    else
        Toast.Show("牌局已经开始")
        this.Close()
    end
end

--房间结束，退出房间提示处理
function MahjongSetupPanel.OnExitRoomAlert()
    MahjongRoomMgr.ExitRoom()
end

--游戏开始，需要更新按钮显示
function MahjongSetupPanel.OnGameBegin()
    this.UpdateButtonDisplay()
end

--听牌提示按钮点击
function MahjongSetupPanel.OnTingPaiActiveClick()
    MahjongDataMgr.isTingTips = not MahjongDataMgr.isTingTips
    MahjongUtil.SetTingPaiTiShi(MahjongDataMgr.isTingTips)
    this.UpdateTingPaiTipsDisplay()
end

------------------------------------------------------------------
--
--检测听牌提示
function MahjongSetupPanel.CheckTingPaiTiShi()
    if MahjongDataMgr.isConfigTingTips then
        UIUtil.SetActive(this.tingPaiActive, true)
        UIUtil.SetActive(this.tingPaiNone, false)
        MahjongDataMgr.isTingTips = MahjongUtil.GetTingPaiTiShi()
        this.UpdateTingPaiTipsDisplay()
    else
        UIUtil.SetActive(this.tingPaiActive, false)
        UIUtil.SetActive(this.tingPaiNone, true)
    end
end

--听牌提示动画完成
function MahjongSetupPanel.OnTingPaiTweenCompleted()
    UIUtil.SetActive(this.tingPaiCloseNode, not MahjongDataMgr.isTingTips)
    --通知牌局界面
    MahjongPlayCardMgr.CheckHuTips()
end

--更新听牌提示显示
function MahjongSetupPanel.UpdateTingPaiTipsDisplay()
    if MahjongDataMgr.isTingTips then
        this.tingPaiTween:PlayForward()
    else
        this.tingPaiTween:PlayReverse()
    end
end