Pin5RoomSetupPanel = ClassPanel("Pin5RoomSetupPanel");
local isInitied = false
local this = Pin5RoomSetupPanel

--启动事件--
function Pin5RoomSetupPanel:OnInitUI(obj)
    self:InitPanel()
end

--初始化面板--
function Pin5RoomSetupPanel:InitPanel()
    local content = self.transform:Find("Content")
    local node = content:Find("Node")

    self.closeBtn = content:Find("Background/CloseBtn").gameObject

    this.musicSliderGO = node:Find("Music/Slider").gameObject
    this.musicSlider = this.musicSliderGO:GetComponent("Slider")
    this.soundSliderGO = node:Find("Sound/Slider").gameObject
    this.soundSlider = this.soundSliderGO:GetComponent("Slider")

    this.musicOpenBtn = node:Find("Music/OpenBtn").gameObject
    this.musicCloseBtn = node:Find("Music/CloseBtn").gameObject

    this.soundOpenBtn = node:Find("Sound/OpenBtn").gameObject
    this.soundCloseBtn = node:Find("Sound/CloseBtn").gameObject


    self.musicChangeDropdown = node:Find("MusicChange/Dropdown"):GetComponent("Dropdown")

    self.pokerToggles = {}
    self.deskToggles = {}

    local pokerGroupTrans = node:Find("CardBack/ToggleGroup")
    for i = 1, 4 do
        self.pokerToggles[i] = pokerGroupTrans:Find(tostring(i)):GetComponent("Toggle")
    end

    local deskGroupTrans = node:Find("Pin5DeskGroup/ToggleGroup")
    for i = 1, 4 do
        self.deskToggles[i] = deskGroupTrans:Find(tostring(i)):GetComponent("Toggle")
    end
end

function Pin5RoomSetupPanel:OnOpened(arg)
    self:Init()
end

function Pin5RoomSetupPanel:OnDestroy()
    isInitied = false
end

--启动事件--
function Pin5RoomSetupPanel:Init()
    if not isInitied then
        isInitied = true
        self:AddOnClickMsg()
    end
    --设置默认音乐大小
    self.musicSlider.value = this.GetBackgroudVolume()
    --设置按键声音大小
    self.soundSlider.value = this.GetSoundVolume()

    this.SetMusicBtn(this.musicSlider.value)
    this.SetSoundBtn(this.soundSlider.value)

    for i = 1, 4 do
        self.pokerToggles[i].isOn = i == Pin5RoomData.cardColor
    end
    for i = 1, 4 do
        self.deskToggles[i].isOn = i == Pin5RoomData.pin5DeskColor
    end
    --设置背景音
    self.musicChangeDropdown.value = tonumber(GetLocal(Pin5Action.Pin5BackMusic, 3)) - 1
end

function Pin5RoomSetupPanel:AddOnClickMsg()
    self:AddOnClick(self.closeBtn, this.OnCloseBtnClick)

    self.musicSlider.onValueChanged:AddListener(this.OnMusicValueChanged)
    self.soundSlider.onValueChanged:AddListener(this.OnSoundValueChanged)

    for i = 1, 4 do
        local go = self.pokerToggles[i].gameObject
        self:AddOnToggle(go, HandlerByStaticArg1({ name = go.name }, this.OnPokerValueChanged))
    end

    for i = 1, 4 do
        local go = self.deskToggles[i].gameObject
        self:AddOnToggle(go, HandlerByStaticArg1({ name = go.name }, this.OnPin5DeskValueChanged))
    end

    self.musicChangeDropdown.onValueChanged:AddListener(this.ChangeMusic)

    this:AddOnClick(this.musicOpenBtn, function () this.OnMusicClick(0) end)
    this:AddOnClick(this.musicCloseBtn, function () this.OnMusicClick(1) end)
    this:AddOnClick(this.soundOpenBtn, function () this.OnSoundClick(0) end)
    this:AddOnClick(this.soundCloseBtn, function () this.OnSoundClick(1) end)
end

function Pin5RoomSetupPanel.GetBackgroudVolume()
    local bgVolume = AudioManager.GetBackgroundVolume()
    if IsNumber(bgVolume) then
        return bgVolume / Pin5VolumeScale.Music
    end
    LogError("<<<<<<<<<<<<        背景音量获取为空  ")
end

function Pin5RoomSetupPanel.GetSoundVolume()
    local soundVolume = AudioManager.GetSoundVolume()
    if IsNumber(soundVolume) then
        return soundVolume / Pin5VolumeScale.Sound
    end
    LogError("<<<<<<<<<<<<        背景音量获取为空  ")
end

function Pin5RoomSetupPanel.ChangeMusic(arg)
    SetLocal(Pin5Action.Pin5BackMusic, arg + 1)
    AudioManager.PlayBackgroud(Pin5BundleName.pin5Music, Pin5Musics[arg + 1])
end

--关闭按钮单击事件--
function Pin5RoomSetupPanel.OnCloseBtnClick(go)
    PanelManager.Close(Pin5PanelConfig.RoomSetup, false)
end

--背景音量改变
function Pin5RoomSetupPanel.OnMusicValueChanged(value)
    --通过值缩放音量
    local mMusicVolume = Pin5VolumeScale.Music * value
    --设置背景音量
    AudioManager.SetBackgroudVolume(mMusicVolume)
end

--音效音量改变
function Pin5RoomSetupPanel.OnSoundValueChanged(value)
    --保存音量到本地
    SetLocal(Pin5Action.SoundVolume, tostring(value))
    --通过值缩放音量
    local mSoundVolume = Pin5VolumeScale.Sound * value
    --设置音效音量
    AudioManager.SetSoundVolume(mSoundVolume)
end

--牌背改变
function Pin5RoomSetupPanel.OnPokerValueChanged(arg, isOn)
    if isOn then
        --设置到本地牌类型
        SetLocal(Pin5Action.PokerStyleType, arg.name)
        Pin5RoomData.cardColor = tonumber(arg.name)
        --改变牌类型
        Event.Brocast(Pin5Action.PokerStyleType)
    end
end

--桌面类型改变
function Pin5RoomSetupPanel.OnPin5DeskValueChanged(arg, isOn)
    if isOn then
        --设置到本地桌子类型
        SetLocal(Pin5Action.DeskStypleType, tonumber(arg.name))
        Pin5RoomData.pin5DeskColor = tonumber(arg.name)
        --改变桌子类型
        Event.Brocast(Pin5Action.DeskStypleType)
    end
end

------------------------------------------------------------------
--音乐按钮设置
function Pin5RoomSetupPanel.SetMusicBtn(value)
    UIUtil.SetActive(this.musicOpenBtn, value > 0)
    UIUtil.SetActive(this.musicCloseBtn, value == 0)
end

--音效按钮设置
function Pin5RoomSetupPanel.SetSoundBtn(value)
    UIUtil.SetActive(this.soundOpenBtn, value > 0)
    UIUtil.SetActive(this.soundCloseBtn, value == 0)
end

--游戏音乐点击
function Pin5RoomSetupPanel.OnMusicClick(value)
    AudioManager.SetBackgroudVolume(value)
    this.SetMusicBtn(value)
end

--游戏音效点击
function Pin5RoomSetupPanel.OnSoundClick(value)
    AudioManager.SetSoundVolume(value)
    this.SetSoundBtn(value)
end