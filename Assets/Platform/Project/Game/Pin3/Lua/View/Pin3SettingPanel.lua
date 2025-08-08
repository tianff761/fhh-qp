Pin3SettingPanel = ClassPanel("Pin3SettingPanel")
Pin3SettingPanel.shenQingJieShanRoomBtn = nil
Pin3SettingPanel.exitRoomBtn = nil
Pin3SettingPanel.closeBtn = nil
Pin3SettingPanel.cardBackgrouds = nil
Pin3SettingPanel.tableBackgrouds = nil
local this = Pin3SettingPanel
this.gameObject = nil
this.transform = nil
this.isInGame = false

function Pin3SettingPanel:Awake(obj)
    this = self
end

function Pin3SettingPanel:OnOpened(openType)
    self:InitPanel()
end

function Pin3SettingPanel:InitPanel()
    this.shenQingJieShanRoomBtn = self:Find('Content/ShenQingJieShanRoomBtn')
    this.exitRoomBtn = self:Find('Content/ExitRoomBtn')
    this.closeBtn = self:Find('Content/CloseBtn')
    Log("==>Pin3SettingPanel:InitPanel", Pin3Data.IsFkFlowRoom(), Pin3Data.isStartGame, Pin3Data.GetIsPrepare(Pin3Data.uid))
    Log("==>Pin3SettingPanel:InitPanel", GetTableString(Pin3Data))
    if Pin3Data.IsFkFlowRoom() then
        if Pin3Data.isStartGame then
            if Pin3Data.GetIsPrepare(Pin3Data.uid) then
                UIUtil.SetActive(this.exitRoomBtn, false)
                --UIUtil.SetActive(this.shenQingJieShanRoomBtn, true)
            else
                UIUtil.SetActive(this.exitRoomBtn, true)
                UIUtil.SetActive(this.shenQingJieShanRoomBtn, false)
            end

        else
            UIUtil.SetActive(this.exitRoomBtn, true)
            UIUtil.SetActive(this.shenQingJieShanRoomBtn, false)
        end
    else
        UIUtil.SetActive(this.shenQingJieShanRoomBtn, false)
        if Pin3Data.gameStatus == Pin3GameStatus.WaitingPrepare then
            UIUtil.SetActive(this.exitRoomBtn, true)
        else
            if not Pin3Data.GetIsPrepare(Pin3Data.uid) then
                UIUtil.SetActive(this.exitRoomBtn, true)
            else
                if Pin3Data.isFaPai then
                    UIUtil.SetActive(this.exitRoomBtn, false)
                else
                    UIUtil.SetActive(this.exitRoomBtn, true)
                end
            end
        end
    end


    --添加点击背景关闭事件
    this:AddOnClick(this.closeBtn,                this.OnClickCloseBtn)
    this:AddOnClick(this.shenQingJieShanRoomBtn, this.OnClickJieShanRoomBtn)
    this:AddOnClick(this.exitRoomBtn,            this.OnClickQuitRoomBtn)

    local slider = this.transform:Find("Content/MusicSlider"):GetComponent(typeof(Slider))
    slider.value = tonumber(AudioManager.GetBackgroundVolume())

    slider.onValueChanged:AddListener(function(val)
        AudioManager.SetBackgroudVolume(val)
    end)

    slider = this.transform:Find("Content/SoundSlider"):GetComponent(typeof(Slider))

    slider.value = AudioManager.GetSoundVolume()

    slider.onValueChanged:AddListener(function(val)
        AudioManager.SetSoundVolume(val)
    end)

    this.tableBackgrouds = {}
    this.tableBackgrouds[1] = this.transform:Find("Content/TableBackgroud/TableBg1")
    this.tableBackgrouds[2] = this.transform:Find("Content/TableBackgroud/TableBg2")
    this.tableBackgrouds[3] = this.transform:Find("Content/TableBackgroud/TableBg3")
    this.tableBackgrouds[4] = this.transform:Find("Content/TableBackgroud/TableBg4")
    for i, toggle in pairs(this.tableBackgrouds) do
        UIUtil.SetToggle(toggle, i == Pin3Data.tableBackType)
        this:AddOnToggle(toggle, function(isOn)
            Log("UpdateTable", isOn)
            this.OnToggleTableBackgroud(isOn, i)
        end)
    end

    this.cardBackgrouds = {}
    this.cardBackgrouds[1] = this.transform:Find("Content/CardBackgroud/CardBg1")
    this.cardBackgrouds[2] = this.transform:Find("Content/CardBackgroud/CardBg2")
    this.cardBackgrouds[3] = this.transform:Find("Content/CardBackgroud/CardBg3")
    this.cardBackgrouds[4] = this.transform:Find("Content/CardBackgroud/CardBg4")
    for i, toggle in pairs(this.cardBackgrouds) do
        UIUtil.SetToggle(toggle, i == Pin3Data.cardBackType)
        this:AddOnToggle(toggle, function(isOn)
            this.OnToggleCardBackgroud(isOn, i)
        end)
    end
    Log("=========》", this.tableBackgrouds, this.cardBackgrouds)
end

function Pin3SettingPanel.OnClickCloseBtn()
    this:Close()
end

function Pin3SettingPanel.OnClickQuitRoomBtn()
    Alert.Prompt("请确定退出房间？", function()
        this:Close()
        Pin3NetworkManager.SendQuitRoom()
    end)
end

function Pin3SettingPanel.OnClickJieShanRoomBtn()
    Alert.Prompt("请确定申请解散房间？", function()
        this:Close()
        Pin3NetworkManager.SendDissovleFkRoom()
    end)
end

function Pin3SettingPanel.OnToggleCardBackgroud(isOn, type)
    if isOn then
        Pin3Data.cardBackType = type
        SendMsg(CMD.Game.UpdataCardBackgroud, type)
    end
end

function Pin3SettingPanel.OnToggleTableBackgroud(isOn, type)
    if isOn then
        Pin3Data.tableBackType = type
        Pin3BattlePanel.UpdateTableBackgroud()
    end
end
