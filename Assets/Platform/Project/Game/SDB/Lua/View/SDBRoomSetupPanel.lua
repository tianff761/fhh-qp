SDBRoomSetupPanel = ClassPanel("SDBRoomSetupPanel");
local isInitied = false
local this = SDBRoomSetupPanel

--启动事件--
function SDBRoomSetupPanel:OnInitUI(obj)
    self:InitPanel()
end

--初始化面板--
function SDBRoomSetupPanel:InitPanel()
    local content = self.transform:Find("Content")
    local panelContent = content:Find("Node")

    self.closeBtn = content:Find("Background/CloseButton").gameObject
    self.soundSlider = panelContent:Find("SoundEffect/SoundSlider"):GetComponent("Slider")
    self.musicSlider = panelContent:Find("Music/SoundSlider"):GetComponent("Slider")
    self.musicChangeDropdown = panelContent:Find("MusicChange/Dropdown"):GetComponent("Dropdown")

    self.pokerToggles = {}
    self.deskToggles = {}

    local pokerGroupTrans = panelContent:Find("CardBack/ToggleGroup")
    for i = 1, 4 do
        self.pokerToggles[i] = pokerGroupTrans:Find(tostring(i)):GetComponent("Toggle")
    end

    local deskGroupTrans = panelContent:Find("SdbDeskGroup/ToggleGroup")
    for i = 1, 4 do
        self.deskToggles[i] = deskGroupTrans:Find(tostring(i)):GetComponent("Toggle")
    end
end

function SDBRoomSetupPanel:OnOpened(arg)
    self:Init()
end

function SDBRoomSetupPanel:OnDestroy()
    isInitied = false
end

--启动事件--
function SDBRoomSetupPanel:Init()
    if not isInitied then
        isInitied = true
        self:AddOnClickMsg()
    end
    --设置默认音乐大小
    self.musicSlider.value = this.GetBackgroudVolume()
    --设置按键声音大小
    self.soundSlider.value = this.GetSoundVolume()
    for i = 1, 4 do
        self.pokerToggles[i].isOn = i == SDBRoomData.cardColor
    end
    for i = 1, 4 do
        self.deskToggles[i].isOn = i == SDBRoomData.sdbDeskColor
    end
    --设置背景音
    self.musicChangeDropdown.value = tonumber(GetLocal(SDBAction.SDBBackMusic, 1)) - 1
end

function SDBRoomSetupPanel:AddOnClickMsg()
    self:AddOnClick(self.closeBtn, this.OnCloseBtnClick)

    self.musicSlider.onValueChanged:AddListener(this.OnMusicValueChanged)
    self.soundSlider.onValueChanged:AddListener(this.OnSoundValueChanged)

    for i = 1, 4 do
        local go = self.pokerToggles[i].gameObject
        self:AddOnToggle(go, HandlerByStaticArg1({ name = go.name }, this.OnPokerValueChanged))
    end

    for i = 1, 4 do
        local go = self.deskToggles[i].gameObject
        self:AddOnToggle(go, HandlerByStaticArg1({ name = go.name }, this.OnSdbDeskValueChanged))
    end

    self.musicChangeDropdown.onValueChanged:AddListener(this.ChangeMusic)
end

function SDBRoomSetupPanel.GetBackgroudVolume()
    local bgVolume = AudioManager.GetBackgroundVolume()
    if IsNumber(bgVolume) then
        return bgVolume / SDBVolumeScale.Music
    end
    LogError("<<<<<<<<<<<<        背景音量获取为空  ")
end

function SDBRoomSetupPanel.GetSoundVolume()
    local soundVolume = AudioManager.GetSoundVolume()
    if IsNumber(soundVolume) then
        return soundVolume / SDBVolumeScale.Sound
    end
    LogError("<<<<<<<<<<<<        背景音量获取为空  ")
end

function SDBRoomSetupPanel.ChangeMusic(arg)
    SetLocal(SDBAction.SDBBackMusic, arg + 1)
    AudioManager.PlayBackgroud(SDBBundleName.sdbMusic, SDBMusics[arg + 1])
end

--关闭按钮单击事件--
function SDBRoomSetupPanel.OnCloseBtnClick(go)
    PanelManager.Close(SDBPanelConfig.RoomSetup, false)
end

--背景音量改变
function SDBRoomSetupPanel.OnMusicValueChanged(value)
    --通过值缩放音量
    local mMusicVolume = SDBVolumeScale.Music * value
    --设置背景音量
    AudioManager.SetBackgroudVolume(mMusicVolume)
end

--音效音量改变
function SDBRoomSetupPanel.OnSoundValueChanged(value)
    --保存音量到本地
    SetLocal(SDBAction.SoundVolume, tostring(value))
    --通过值缩放音量
    local mSoundVolume = SDBVolumeScale.Sound * value
    --设置音效音量
    AudioManager.SetSoundVolume(mSoundVolume)
end

--牌背改变
function SDBRoomSetupPanel.OnPokerValueChanged(arg, isOn)
    if isOn then
        --设置到本地牌类型
        SetLocal(SDBAction.PokerStyleType, arg.name)
        SDBRoomData.cardColor = tonumber(arg.name)
        --改变牌类型
        Event.Brocast(SDBAction.PokerStyleType)
    end
end

--桌面类型改变
function SDBRoomSetupPanel.OnSdbDeskValueChanged(arg, isOn)
    if isOn then
        --设置到本地桌子类型
        SetLocal(SDBAction.DeskStypleType, tonumber(arg.name))
        SDBRoomData.sdbDeskColor = tonumber(arg.name)
        --改变桌子类型
        Event.Brocast(SDBAction.DeskStypleType)
    end
end