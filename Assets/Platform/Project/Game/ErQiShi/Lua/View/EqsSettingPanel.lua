EqsSettingPanel = ClassPanel("EqsSettingPanel")
EqsSettingPanel.jieShanRoomBtn = nil
EqsSettingPanel.exitRoomBtn = nil
EqsSettingPanel.closeBtn = nil
EqsSettingPanel.isGoldFlowRoom = false
local this = EqsSettingPanel
this.gameObject = nil
this.transform = nil
this.isInGame = false

function EqsSettingPanel:Awake(obj)
    this = self
end

function EqsSettingPanel:OnOpened(openType)
    this.isGoldFlowRoom = not BattleModule.IsFkFlowRoom()
    self:InitPanel()
    local selfCtrl = BattleModule.GetUserInfoByUid(BattleModule.uid)
    if selfCtrl ~= nil then
        Log("EqsSettingPanel：", this.isGoldFlowRoom, BattleModule.teaId, BattleModule.clubId, selfCtrl:GetStatus())
        if this.isGoldFlowRoom then
            UIUtil.SetActive(this.jieShanRoomBtn, false)
            UIUtil.SetActive(this.exitRoomBtn, false)
            local status = selfCtrl:GetStatus()
            if status == EqsUserStatus.WaitJoin or status == EqsUserStatus.Preparing or status == EqsUserStatus.Prepared then
                UIUtil.SetActive(this.exitRoomBtn, true)
            end
        else
            UIUtil.SetActive(this.jieShanRoomBtn, false)
            UIUtil.SetActive(this.exitRoomBtn, false)
            if BattleModule.isStarted then
                -- UIUtil.SetActive(this.jieShanRoomBtn, true)
            else
                if BattleModule.IsClubRoom() or BattleModule.IsTeaRoom() then
                    UIUtil.SetActive(this.exitRoomBtn, true)
                else
                    if selfCtrl:IsCreator() then
                        -- UIUtil.SetActive(this.jieShanRoomBtn, true)
                    else
                        UIUtil.SetActive(this.exitRoomBtn, true)
                    end
                end
            end
        end
    end
end

function EqsSettingPanel:InitPanel() 
    local content = self:Find('Content')
    this.closeBtn = content:Find('Background/CloseBtn')

    local node = content:Find("Node")
    this.jieShanRoomBtn = node:Find('ShenQingJieShanRoomBtn')
    this.exitRoomBtn = node:Find('ExitRoomBtn')

    --添加点击背景关闭事件
    this:AddOnClick(this.closeBtn, this.OnClickCloseBtn)
    this:AddOnClick(this.jieShanRoomBtn, this.OnClickJieShanRoomBtn)
    this:AddOnClick(this.exitRoomBtn, this.OnClickQuitRoomBtn)

    --音乐、音效
    this.musicSliderGO = node:Find("Music/Slider").gameObject
    this.musicSlider = this.musicSliderGO:GetComponent("Slider")
    this.soundSliderGO = node:Find("Sound/Slider").gameObject
    this.soundSlider = this.soundSliderGO:GetComponent("Slider")

    this.musicOpenBtn = node:Find("Music/OpenBtn").gameObject
    this.musicCloseBtn = node:Find("Music/CloseBtn").gameObject

    this.soundOpenBtn = node:Find("Sound/OpenBtn").gameObject
    this.soundCloseBtn = node:Find("Sound/CloseBtn").gameObject

    --设置背景音乐大小
    this.musicSlider.value = AudioManager.GetBackgroundVolume()
    --设置音效声音大小
    this.soundSlider.value = AudioManager.GetSoundVolume()
    this.SetMusicBtn(this.musicSlider.value)
    this.SetSoundBtn(this.soundSlider.value)

    this:AddOnClick(this.musicOpenBtn, function () this.OnMusicClick(0) end)
    this:AddOnClick(this.musicCloseBtn, function () this.OnMusicClick(1) end)
    this:AddOnClick(this.soundOpenBtn, function () this.OnSoundClick(0) end)
    this:AddOnClick(this.soundCloseBtn, function () this.OnSoundClick(1) end)


    --桌布
    -- local toggle1 = node:Find('ZhuoBuContainer/ShenSeToggle'):GetComponent(typeof(Toggle))
    -- local toggle2 = node:Find('ZhuoBuContainer/QianSeToggle'):GetComponent(typeof(Toggle))
    -- local toggle3 = node:Find('ZhuoBuContainer/LanSeToggle'):GetComponent(typeof(Toggle))

    -- toggle1.onValueChanged:RemoveAllListeners()
    -- toggle2.onValueChanged:RemoveAllListeners()
    -- toggle3.onValueChanged:RemoveAllListeners()

    -- toggle1.onValueChanged:AddListener(function(isOn)
    --     if isOn then
    --         this.SetBg(1)
    --     end
    -- end)

    -- toggle2.onValueChanged:AddListener(function(isOn)
    --     if isOn then
    --         this.SetBg(2)
    --     end
    -- end)

    -- toggle3.onValueChanged:AddListener(function(isOn)
    --     if isOn then
    --         this.SetBg(3)
    --     end
    -- end)
    -- --初始化背景
    -- local bgid = GetLocal(EqsLocalKey.EqsTableColor, "2")

    -- toggle1.isOn = tonumber(bgid) == 1
    -- toggle2.isOn = tonumber(bgid) == 2
    -- toggle3.isOn = tonumber(bgid) == 3

    --音乐、音效 老版暂时不用的
    -- local slider = this.transform:Find("MusicSlider/Slider"):GetComponent(typeof(Slider))
    -- slider.value = tonumber(AudioManager.GetBackgroundVolume())

    -- slider.onValueChanged:AddListener(function(val)
    --     AudioManager.SetBackgroudVolume(val)
    -- end)

    -- slider = this.transform:Find("SoundSlider/Slider"):GetComponent(typeof(Slider))

    -- slider.value = AudioManager.GetSoundVolume()

    -- slider.onValueChanged:AddListener(function(val)
    --     AudioManager.SetSoundVolume(val)
    -- end)


    -- fyType:""   以前第一套             1_ 种类：命名开始为1_
    -- local fyType = GetLocal(EqsLocalKey.MusicType)
    -- if fyType == nil then
    --     fyType = ""
    -- end
    -- local fy1Toggle = this.transform:Find('MusicTypeContainer/FangYan1Toggle'):GetComponent(typeof(Toggle))
    -- local fy2Toggle = this.transform:Find('MusicTypeContainer/FangYan2Toggle'):GetComponent(typeof(Toggle))
    -- fy1Toggle.isOn = fyType == ""
    -- fy2Toggle.isOn = fyType == "1_"
    -- fy1Toggle.onValueChanged:RemoveAllListeners()
    -- fy2Toggle.onValueChanged:RemoveAllListeners()

    -- fy1Toggle.onValueChanged:AddListener(function(isOn)
    --     if isOn then
    --         SetLocal(EqsLocalKey.MusicType, EqsAudioType.FangYan1)
    --         EqsSoundManager.SetAudioType(EqsAudioType.FangYan1)

    --     end
    -- end)
    -- fy2Toggle.onValueChanged:AddListener(function(isOn)
    --     if isOn then
    --         SetLocal(EqsLocalKey.MusicType, EqsAudioType.FangYan2)
    --         EqsSoundManager.SetAudioType(EqsAudioType.FangYan2)
    --     end
    -- end)
end

--bgID: 1 深色      2 浅色      3蓝色
function EqsSettingPanel.SetBg(id)
    SetLocal(EqsLocalKey.EqsTableColor, id)
    EqsBattlePanel.SetBg(id)
end

function EqsSettingPanel.OnClickCloseBtn()
    this:Close()
end

function EqsSettingPanel.OnClickQuitRoomBtn()
    if this.isGoldFlowRoom then
        Alert.Prompt("请确定退出房间?", function()
            BattleModule.SendQuitRoom()
        end)
    else
        if BattleModule.isStarted then
            Alert.Prompt("请确定申请解散房间？", function()
                BattleModule.SendTouPiaoJieShanRoom(-1)
            end)
        else
            Alert.Prompt("请确定退出房间？", function()
                BattleModule.SendQuitRoom()
            end)
        end
    end
end

function EqsSettingPanel.OnClickJieShanRoomBtn()
    Log("点击解散房间", BattleModule.isStarted)
    if BattleModule.isStarted then
        Alert.Prompt("请确定申请解散房间？", function()
            this:Close()
            BattleModule.SendTouPiaoJieShanRoom(-1)
        end)
    else
        Alert.Prompt("请确定解散房间？", function()
            this:Close()
            BattleModule.SendJieShanRoom()
        end)
    end
end

------------------------------------------------------------------
--音乐按钮设置
function EqsSettingPanel.SetMusicBtn(value)
    UIUtil.SetActive(this.musicOpenBtn, value > 0)
    UIUtil.SetActive(this.musicCloseBtn, value == 0)
end

--音效按钮设置
function EqsSettingPanel.SetSoundBtn(value)
    UIUtil.SetActive(this.soundOpenBtn, value > 0)
    UIUtil.SetActive(this.soundCloseBtn, value == 0)
end

--游戏音乐点击
function EqsSettingPanel.OnMusicClick(value)
    AudioManager.SetBackgroudVolume(value)
    this.SetMusicBtn(value)
end

--游戏音效点击
function EqsSettingPanel.OnSoundClick(value)
    AudioManager.SetSoundVolume(value)
    this.SetSoundBtn(value)
end

return EqsSettingPanel