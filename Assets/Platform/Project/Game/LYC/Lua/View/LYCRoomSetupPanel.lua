LYCRoomSetupPanel = ClassPanel("LYCRoomSetupPanel");
local isInitied = false
local this = LYCRoomSetupPanel

--启动事件--
function LYCRoomSetupPanel:OnInitUI(obj)
    self:InitPanel()
end

--初始化面板--
function LYCRoomSetupPanel:InitPanel()
    local content = self.transform:Find("Content")
    local panelContent = content:Find("Node")

    self.closeBtn = content:Find("Background/CloseBtn").gameObject
    this.musicSlider = panelContent:Find("MusicSlider"):GetComponent("Slider")
    this.soundSlider = panelContent:Find("SoundSlider"):GetComponent("Slider")

    self.musicChangeDropdown = panelContent:Find("MusicChange/Dropdown"):GetComponent("Dropdown")

    self.pokerToggles = {}
    self.deskToggles = {}

    local pokerGroupTrans = panelContent:Find("CardBack/ToggleGroup")
    for i = 1, 4 do
        self.pokerToggles[i] = pokerGroupTrans:Find(tostring(i)):GetComponent("Toggle")
    end

    local deskGroupTrans = panelContent:Find("LYCDeskGroup/ToggleGroup")
    for i = 1, 4 do
        self.deskToggles[i] = deskGroupTrans:Find(tostring(i)):GetComponent("Toggle")
    end
end

function LYCRoomSetupPanel:OnOpened(arg)
    self:Init()
end

function LYCRoomSetupPanel:OnDestroy()
    isInitied = false
end

--启动事件--
function LYCRoomSetupPanel:Init()
    if not isInitied then
        isInitied = true
        self:AddOnClickMsg()
    end
    --设置默认音乐大小
    self.musicSlider.value = this.GetBackgroudVolume()
    --设置按键声音大小
    self.soundSlider.value = this.GetSoundVolume()
    for i = 1, 4 do
        self.pokerToggles[i].isOn = i == LYCRoomData.cardColor
    end
    for i = 1, 4 do
        self.deskToggles[i].isOn = i == LYCRoomData.lycDeskColor
    end
    --设置背景音
    self.musicChangeDropdown.value = tonumber(GetLocal(LYCAction.LYCBackMusic, 3)) - 1
end

function LYCRoomSetupPanel:AddOnClickMsg()
    self:AddOnClick(self.closeBtn, this.OnCloseBtnClick)

    self.musicSlider.onValueChanged:AddListener(this.OnMusicValueChanged)
    self.soundSlider.onValueChanged:AddListener(this.OnSoundValueChanged)

    for i = 1, 4 do
        local go = self.pokerToggles[i].gameObject
        self:AddOnToggle(go, HandlerByStaticArg1({ name = go.name }, this.OnPokerValueChanged))
    end

    for i = 1, 4 do
        local go = self.deskToggles[i].gameObject
        self:AddOnToggle(go, HandlerByStaticArg1({ name = go.name }, this.OnLYCDeskValueChanged))
    end

    self.musicChangeDropdown.onValueChanged:AddListener(this.ChangeMusic)
end

function LYCRoomSetupPanel.GetBackgroudVolume()
    local bgVolume = AudioManager.GetBackgroundVolume()
    if IsNumber(bgVolume) then
        return bgVolume / LYCVolumeScale.Music
    end
    LogError("<<<<<<<<<<<<        背景音量获取为空  ")
end

function LYCRoomSetupPanel.GetSoundVolume()
    local soundVolume = AudioManager.GetSoundVolume()
    if IsNumber(soundVolume) then
        return soundVolume / LYCVolumeScale.Sound
    end
    LogError("<<<<<<<<<<<<        背景音量获取为空  ")
end

function LYCRoomSetupPanel.ChangeMusic(arg)
    SetLocal(LYCAction.LYCBackMusic, arg + 1)
    AudioManager.PlayBackgroud(LYCBundleName.lycMusic, LYCMusics[arg + 1])
end

--关闭按钮单击事件--
function LYCRoomSetupPanel.OnCloseBtnClick(go)
    PanelManager.Close(LYCPanelConfig.RoomSetup, false)
end

--背景音量改变
function LYCRoomSetupPanel.OnMusicValueChanged(value)
    --通过值缩放音量
    local mMusicVolume = LYCVolumeScale.Music * value
    --设置背景音量
    AudioManager.SetBackgroudVolume(mMusicVolume)
end

--音效音量改变
function LYCRoomSetupPanel.OnSoundValueChanged(value)
    --保存音量到本地
    SetLocal(LYCAction.SoundVolume, tostring(value))
    --通过值缩放音量
    local mSoundVolume = LYCVolumeScale.Sound * value
    --设置音效音量
    AudioManager.SetSoundVolume(mSoundVolume)
end

--牌背改变
function LYCRoomSetupPanel.OnPokerValueChanged(arg, isOn)
    if isOn then
        --设置到本地牌类型
        SetLocal(LYCAction.PokerStyleType, arg.name)
        LYCRoomData.cardColor = tonumber(arg.name)
        --改变牌类型
        Event.Brocast(LYCAction.PokerStyleType)
    end
end

--桌面类型改变
function LYCRoomSetupPanel.OnLYCDeskValueChanged(arg, isOn)
    if isOn then
        --设置到本地桌子类型
        SetLocal(LYCAction.DeskStypleType, tonumber(arg.name))
        LYCRoomData.lycDeskColor = tonumber(arg.name)
        --改变桌子类型
        Event.Brocast(LYCAction.DeskStypleType)
    end
end