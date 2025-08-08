TpSettingPanel = ClassPanel("TpSettingPanel")
local this = TpSettingPanel

--UI初始化
function TpSettingPanel:OnInitUI()
    this = self
    local nodeTrans = self:Find("Content")
    this.closeBtn = nodeTrans:Find("CloseBtn").gameObject

    this.musicSlider = nodeTrans:Find("MusicSlider"):GetComponent("Slider")
    this.soundSlider = nodeTrans:Find("SoundSlider"):GetComponent("Slider")

    this.dismissBtn = nodeTrans:Find("ShenQingJieShanRoomBtn").gameObject
    this.quitBtn = nodeTrans:Find("ExitRoomBtn").gameObject

    this.AddUIListenerEvent()
end


--当面板开启开启时
function TpSettingPanel:OnOpened()
    this = self
    this.AddListenerEvent()

    --设置背景音乐大小
    this.musicSlider.value = AudioManager.GetBackgroundVolume()
    --设置音效声音大小
    this.soundSlider.value = AudioManager.GetSoundVolume()

    if TpDataMgr.roomType == RoomType.Match then
        UIUtil.SetActive(this.dismissBtn, false)
        UIUtil.SetActive(this.quitBtn, false)
    elseif TpDataMgr.IsGoldRoomInfinite() then
        if TpDataMgr.IsGameBegin() then
            UIUtil.SetActive(this.dismissBtn, false)
            UIUtil.SetActive(this.quitBtn, false)
        else
            UIUtil.SetActive(this.dismissBtn, false)
            UIUtil.SetActive(this.quitBtn, true)
        end
    else
        --游戏开始，都需要解散
        if TpDataMgr.IsRoomBegin() then
            UIUtil.SetActive(this.dismissBtn, true)
            UIUtil.SetActive(this.quitBtn, false)
        else
            --大厅的房间需要判断房主
            if TpDataMgr.roomType == RoomType.Lobby then
                if TpDataMgr.IsRoomOwner() then
                    UIUtil.SetActive(this.dismissBtn, true)
                    UIUtil.SetActive(this.quitBtn, false)
                else
                    UIUtil.SetActive(this.dismissBtn, false)
                    UIUtil.SetActive(this.quitBtn, true)
                end
            elseif TpDataMgr.roomType == RoomType.Club then
                UIUtil.SetActive(this.dismissBtn, false)
                UIUtil.SetActive(this.quitBtn, true)
            else
                UIUtil.SetActive(this.dismissBtn, false)
                UIUtil.SetActive(this.quitBtn, true)
            end
        end
    end
end

--当面板关闭时调用
function TpSettingPanel:OnClosed()
    this.RemoveListenerEvent()
end

------------------------------------------------------------------
--
--关闭
function TpSettingPanel.Close()
    PanelManager.Close(TpPanelConfig.Setup)
end
--
function TpSettingPanel.AddListenerEvent()

end
--
function TpSettingPanel.RemoveListenerEvent()

end

--UI相关事件
function TpSettingPanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.dismissBtn, this.OnQuitBtnClick)
    this:AddOnClick(this.quitBtn, this.OnQuitBtnClick)

    this.musicSlider.onValueChanged:AddListener(this.OnMusicValueChanged)
    this.soundSlider.onValueChanged:AddListener(this.OnSoundValueChanged)
end

------------------------------------------------------------------
--
function TpSettingPanel.OnCloseBtnClick()
    this.Close()
end
--
function TpSettingPanel.OnDismissBtnClick()

end

function TpSettingPanel.OnQuitBtnClick()
    --如果结算信息还在，则推动检测
    --TpRoomMgr.CheckSettlement()
    if TpDataMgr.isRoomEnd then
        Alert.Prompt("游戏已经结束，是否退出房间？", this.OnExitRoomAlert)
        this.Close()
        return
    end

    if TpDataMgr.IsGoldRoomInfinite() then
        if TpDataMgr.IsGameBegin() then
            Toast.Show("牌局已经开始")
        else
            Alert.Prompt("是否退出房间？", this.OnQuitRoomAlert)
        end
    else
        if TpDataMgr.IsRoomBegin() then
            Alert.Prompt("牌局已经开始，是否申请解散？", this.OnApplyDismissAlert)
        else
            if TpDataMgr.roomType == RoomType.Lobby and TpDataMgr.IsRoomOwner() then
                Alert.Prompt("是否解散房间？", this.OnRoomOwnerDismissAlert)
            else
                Alert.Prompt("是否退出房间？", this.OnQuitRoomAlert)
            end
        end
    end
end

function TpSettingPanel.OnMusicValueChanged(value)
    AudioManager.SetBackgroudVolume(value)
end

function TpSettingPanel.OnSoundValueChanged(value)
    AudioManager.SetSoundVolume(value)
end

--房间结束，退出房间提示处理
function TpSettingPanel.OnExitRoomAlert()
    TpRoomMgr.ExitRoom()
end

--解散房间提示框确认处理
function TpSettingPanel.OnApplyDismissAlert()
    TpCommand.SendDismiss()
end

--房主解散房间处理，游戏开始，直接申请解散
function TpSettingPanel.OnRoomOwnerDismissAlert()
    if TpDataMgr.IsRoomBegin() then
        TpCommand.SendDismiss()
    else
        TpCommand.SendQuitRoom()
    end
end

--退出房间提示框确认处理
function TpSettingPanel.OnQuitRoomAlert()
    local isCanQuit = true

    if TpDataMgr.IsGoldRoomInfinite() then
        if TpDataMgr.IsGameBegin() then
            isCanQuit = false
        end
    else
        if TpDataMgr.IsRoomBegin() then
            isCanQuit = false
        end
    end

    if isCanQuit then
        TpCommand.SendQuitRoom()
    else
        Toast.Show("牌局已经开始")
        this.Close()
    end
end