SetupPanel = ClassPanel("SetupPanel")

local this = nil

--初始化面板--
function SetupPanel:OnInitUI()
    this = self

    this.closeBtn = self.transform:Find("Content/Background/CloseBtn").gameObject

    local content = self.transform:Find("Content")

    this.toggleMusic = content:Find("Toggle-Music"):GetComponent(TypeToggle)
    this.toggleAudio = content:Find("Toggle-Audio"):GetComponent(TypeToggle)

    this.toggleMusicBack = content:Find("Toggle-Music/Background"):GetComponent(TypeImage)
    this.toggleAudioBack = content:Find("Toggle-Audio/Background"):GetComponent(TypeImage)

    local bgLayout = content:Find("BgLayout")
    this.bgItems = {}
    for i = 1, 3 do
        local item = {}
        item.transform = bgLayout:Find(tostring(i))
        item.toggle = item.transform:GetComponent(TypeToggle)
        table.insert(this.bgItems, item)
    end

    local musicLayout = content:Find("MusicLayout")
    this.musicItems = {}
    for i = 1, 3 do
        local item = {}
        item.transform = musicLayout:Find(tostring(i))
        item.toggle = item.transform:GetComponent(TypeToggle)
        table.insert(this.musicItems, item)
    end

    this.quitBtn = content:Find("QuitBtn").gameObject

    this.AddUIListenerEvent()
end

function SetupPanel:OnOpened()
    this = self
    this.UpdateDisplay()
end

function SetupPanel:OnClosed()

end

------------------------------------------------------------------
--
function SetupPanel.AddListenerEvent()

end

--
function SetupPanel.RemoveListenerEvent()

end

--
function SetupPanel.AddUIListenerEvent()
    EventUtil.AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    EventUtil.AddOnClick(this.quitBtn, this.OnQuitBtnClick)

    EventUtil.AddToggleListener(this.toggleMusic, this.OnMusicValueChanged)
    EventUtil.AddToggleListener(this.toggleAudio, this.OnAudioValueChanged)

    for i = 1, #this.bgItems do
        EventUtil.AddOnToggle(this.bgItems[i].transform, function(isOn) this.OnBgItemClick(i, isOn) end)
    end
    for i = 1, #this.musicItems do
        EventUtil.AddOnToggle(this.musicItems[i].transform, function(isOn) this.OnMusicItemClick(i, isOn) end)
    end
end

function SetupPanel.Close()
    PanelManager.Close(PanelConfig.Setup)
end

------------------------------------------------------------------
--
--关闭按钮单击事件--
function SetupPanel.OnCloseBtnClick()
    this.Close()
end

function SetupPanel.OnQuitBtnClick(go)
    Alert.Prompt("确定切换账号，返回到登录界面？", function()
        SendEvent(CMD.Game.LogoutAndOpenLogin)
    end)
end

--
function SetupPanel.OnMusicValueChanged(isOn)
    if not this.isUpdateDisplay then
        if isOn then
            AudioManager.SetBackgroudVolume(1)
        else
            AudioManager.SetBackgroudVolume(0)
        end
        this.toggleMusicBack.enabled = not isOn
    end
end

--
function SetupPanel.OnAudioValueChanged(isOn)
    if not this.isUpdateDisplay then
        if isOn then
            AudioManager.SetSoundVolume(1)
        else
            AudioManager.SetSoundVolume(0)
        end
        this.toggleAudioBack.enabled = not isOn
    end
end

--
function SetupPanel.OnBgItemClick(index, isOn)
    if not this.isUpdateDisplay then
        if isOn then
            SettingMgr.SetBackgroundIndex(index)
            SendEvent(CMD.Game.LobbyBackgroundUpdate)
        end
    end
end

--
function SetupPanel.OnMusicItemClick(index, isOn)
    if not this.isUpdateDisplay then
        if isOn then
            SettingMgr.SetBgMusicIndex(index)
            Audio.PlayLobbyMusic()
        end
    end
end

------------------------------------------------------------------
--
function SetupPanel.UpdateDisplay()
    this.isUpdateDisplay = true

    local temp = AudioManager.GetBackgroundVolume()
    local isOn = false
    if temp > 0 then
        isOn = true
    end
    this.toggleMusic.isOn = isOn
    this.toggleMusicBack.enabled = not isOn

    temp = AudioManager.GetSoundVolume()
    isOn = false
    if temp > 0 then
        isOn = true
    end
    this.toggleAudio.isOn = isOn
    this.toggleAudioBack.enabled = not isOn

    local index = SettingMgr.GetBackgroundIndex()
    local item = this.bgItems[index]
    if item == nil then
        item = this.bgItems[1]
    end
    item.toggle.isOn = false
    item.toggle.isOn = true

    index = SettingMgr.GetBgMusicIndex()
    item = this.musicItems[index]
    if item == nil then
        item = this.musicItems[1]
    end
    item.toggle.isOn = false
    item.toggle.isOn = true

    this.isUpdateDisplay = false
end
