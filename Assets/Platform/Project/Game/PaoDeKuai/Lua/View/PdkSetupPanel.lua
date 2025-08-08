PdkSetupPanel = ClassPanel("PdkSetupPanel")
local this = PdkSetupPanel

--UI初始化
function PdkSetupPanel:OnInitUI()
    this = self
    local nodeTrans = self:Find("Content/Content/Node")
    this.closeBtn = self:Find("Content/Content/Background/CloseButton").gameObject

    this.musicSlider = nodeTrans:Find("MusicSlider"):GetComponent("Slider")
    this.soundSlider = nodeTrans:Find("SoundSlider"):GetComponent("Slider")

    this.dismissBtn = nodeTrans:Find("DismissButton").gameObject
    this.quitBtn = nodeTrans:Find("QuitButton").gameObject

    this.AddUIListenerEvent()
end


--当面板开启开启时
function PdkSetupPanel:OnOpened()
    this = self
    this.AddListenerEvent()

    --设置背景音乐大小
    this.musicSlider.value = AudioManager.GetBackgroundVolume()
    --设置音效声音大小
    this.soundSlider.value = AudioManager.GetSoundVolume()
    UIUtil.SetActive(this.dismissBtn, false)
    if PdkRoomModule.IsGoldRoom() or PdkRoomModule.IsClubRoom() then
        if PdkRoomModule.IsStart() then
            -- UIUtil.SetActive(this.dismissBtn, true)
            UIUtil.SetActive(this.quitBtn, false)
        else
            UIUtil.SetActive(this.dismissBtn, false)
            UIUtil.SetActive(this.quitBtn, true)
        end
    else
        --房间开始或者房主显示解散按钮
        if PdkRoomModule.IsStart() or PdkRoomModule.IsOwner() then
            -- UIUtil.SetActive(this.dismissBtn, true)
            UIUtil.SetActive(this.quitBtn, false)
        else
            UIUtil.SetActive(this.dismissBtn, false)
            UIUtil.SetActive(this.quitBtn, true)
        end
    end
end

--当面板关闭时调用
function PdkSetupPanel:OnClosed()
    this.RemoveListenerEvent()
end

------------------------------------------------------------------
--
--关闭
function PdkSetupPanel.Close()
    PanelManager.Close(PdkPanelConfig.Setup)
end
--
function PdkSetupPanel.AddListenerEvent()

end
--
function PdkSetupPanel.RemoveListenerEvent()

end

--UI相关事件
function PdkSetupPanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.dismissBtn, PdkRoomCtrl.OnExitRoomClick)
    this:AddOnClick(this.quitBtn, PdkRoomCtrl.OnExitRoomClick)

    this.musicSlider.onValueChanged:AddListener(this.OnMusicValueChanged)
    this.soundSlider.onValueChanged:AddListener(this.OnSoundValueChanged)
end

------------------------------------------------------------------
--
function PdkSetupPanel.OnCloseBtnClick()
    this.Close()
end
--
function PdkSetupPanel.OnDismissBtnClick()

end

function PdkSetupPanel.OnQuitBtnClick()

end

function PdkSetupPanel.OnMusicValueChanged(value)
    AudioManager.SetBackgroudVolume(value)
end

function PdkSetupPanel.OnSoundValueChanged(value)
    AudioManager.SetSoundVolume(value)
end