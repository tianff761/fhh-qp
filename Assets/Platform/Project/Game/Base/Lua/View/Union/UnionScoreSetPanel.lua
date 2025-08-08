UnionScoreSetPanel = ClassPanel("UnionScoreSetPanel")

local this = UnionScoreSetPanel
--UI初始化
function UnionScoreSetPanel:OnInitUI()
    this = self
    this.closeBtn = self:Find("Content/Background/CloseBtn")

    local Content = self:Find("Content/Node")
    --按钮
    this.SecondPanel = Content:Find("Btns")
    this.SecondPanelContent = this.SecondPanel:Find("Viewport/Content")
    this.SecondFreezeButton = this.SecondPanelContent:Find("FreezeButton")
    this.SecondUnFreezeButton = this.SecondPanelContent:Find("UnFreezeButton")
    this.SetAdministrator = this.SecondPanelContent:Find("SetAdministrator")
    this.SetAsObserver = this.SecondPanelContent:Find("SetAsObserver")
    this.CancelSetAsObserver = this.SecondPanelContent:Find("CancelSetAsObserver")
    this.SetCommon = this.SecondPanelContent:Find("SetCommon")
    this.ClearButton2 = this.SecondPanelContent:Find("ClearButton")

    this.KickButton2 = this.SecondPanelContent:Find("KickButton")
    this.MoveTeam = this.SecondPanelContent:Find("MoveTeam")
    this.MoveMember = this.SecondPanelContent:Find("MoveMember")
    this.BlackHouse = this.SecondPanelContent:Find("BlackHouse")
    this.GetPlayButton = this.SecondPanelContent:Find("GetPlayButton")

    local UserInfo = Content:Find("UserInfo")
    this.HeadImg = UserInfo:Find("Mask/HeadImg"):GetComponent(TypeImage)
    this.Name = UserInfo:Find("Name")
    this.ID = UserInfo:Find("ID")

    this.input = Content:Find("InputField"):GetComponent(TypeInputField)

    this.AddUIListenerEvent()
    this.ConfirmCallback = function()
        UnionManager.SendSetScore(this.adjustUid, this.AdjustScore)
    end
end

function UnionScoreSetPanel:OnOpened(panelIndex, isIce, uid, icon, name, unionRole, black)
    --输入
    this.adjustUid = uid
    this.isIce = isIce == 1 and true or false
    this.UnionRole = unionRole
    this.black = black
    LogError("<color=aqua>this.isIce</color>", this.isIce)
    Functions.SetHeadImage(this.HeadImg, icon)
    UIUtil.SetText(this.Name, name)
    UIUtil.SetText(this.ID, tostring(uid))
    if panelIndex == 1 then
    elseif panelIndex == 2 then
        UIUtil.SetActive(this.SecondPanel, true)
        UIUtil.SetActive(this.SecondFreezeButton, not this.isIce and UnionData.IsUnionLeaderOrAdministrator())
        UIUtil.SetActive(this.SecondUnFreezeButton, this.isIce and UnionData.IsUnionLeaderOrAdministrator())
        UIUtil.SetActive(this.SetAdministrator, unionRole == UnionRole.Common)
        UIUtil.SetActive(this.SetCommon, unionRole == UnionRole.Admin)
        UIUtil.SetActive(this.MoveTeam, unionRole == UnionRole.Partner and UnionData.IsUnionLeader())
        UIUtil.SetActive(this.MoveMember, unionRole == UnionRole.Common)
        UIUtil.SetActive(this.BlackHouse, unionRole == UnionRole.Partner)
        UIUtil.SetActive(this.SetAsObserver, unionRole == UnionRole.Common)
        LogError("unionRole", unionRole)
        UIUtil.SetActive(this.CancelSetAsObserver, unionRole == UnionRole.Observer)
        UIUtil.SetActive(this.GetPlayButton, false)
        -- UIUtil.SetActive(this.GetPlayButton, unionRole == UnionRole.Partner)
    end
    this.AddListenerEvent()
end

function UnionScoreSetPanel.OnClosed()
    this.RemoveListenerEvent()
end


--UI相关事件
function UnionScoreSetPanel.AddUIListenerEvent()
    LogError("<color=aqua>this.SecondFreezeButton</color>", this.SecondFreezeButton)
    this:AddOnClick(this.SecondFreezeButton, this.OnFreezeButtonClick)
    this:AddOnClick(this.SecondUnFreezeButton, this.OnUnFreezeButtonClick)
    this:AddOnClick(this.SetAdministrator, this.OnSetAdminstratorClick)
    this:AddOnClick(this.ClearButton2, this.OnClearButton2Click)
    this:AddOnClick(this.KickButton2, this.OnKickButton2Click)
    this:AddOnClick(this.MoveTeam, this.OnMoveTeamClick)
    this:AddOnClick(this.MoveMember, this.OnMoveMemberClick)
    this:AddOnClick(this.BlackHouse, this.OnBlackHouseClick)
    this:AddOnClick(this.SetCommon, this.OnSetCommonClick)
    this:AddOnClick(this.SetAsObserver, this.OnSetAsObserverClick)
    this:AddOnClick(this.CancelSetAsObserver, this.OnCancelSetAsObserverClick)
    this:AddOnClick(this.ClearButton, this.OnClearButtonClick)
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.GetPlayButton, this.OnGetPlayClick)
    this.input.onEndEdit:AddListener(this.OnEndEdit)
end

function UnionScoreSetPanel.AddListenerEvent()
    AddEventListener(CMD.Tcp.Union.S2C_Union_SetScore, this.OnTcpSetScore)
    AddEventListener(CMD.Tcp.Union.S2C_REQUEST_PLAYER_INFO, this.ResponsePlayerInfo)
    AddEventListener(CMD.Tcp.Union.S2C_UNION_CREATE_BLACK_HOUSE, this.AddBlackHousePlayerAll)
end

function UnionScoreSetPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Tcp.Union.S2C_Union_SetScore, this.OnTcpSetScore)
    RemoveEventListener(CMD.Tcp.Union.S2C_REQUEST_PLAYER_INFO, this.ResponsePlayerInfo)
    RemoveEventListener(CMD.Tcp.Union.S2C_UNION_CREATE_BLACK_HOUSE, this.AddBlackHousePlayerAll)
end

function UnionScoreSetPanel.OnEndEdit()
    local value = tonumber(this.input.text)
    if IsNumber(value) then
        UnionManager.RequestPlayerInfo(this.adjustUid)
        this.AdjustScore = value
    else
        Toast.Show("请输入正确的分数")
    end
end

function UnionScoreSetPanel.OnTcpSetScore(data)
    if data.code == 0 then
        Toast.Show("分数调整成功")
        SendEvent(CMD.Game.UnionSetScoreRefresh)
    else
        UnionManager.ShowError(data.code)
    end
end


--返回玩家信息
---@param data table playId  "玩家id" --name 名字 --icon 头像
function UnionScoreSetPanel.ResponsePlayerInfo(data)
    if data.code == 0 then
        PanelManager.Open(PanelConfig.UnionSetScoreNotice, data.data, this.AdjustScore, this.ConfirmCallback)
    else
        UnionManager.ShowError(data.code)
    end
end

function UnionScoreSetPanel.AddBlackHousePlayerAll(data)
    LogError("<color=aqua>data</color>", data)
    if data.code == 0 then
        UnionManager.SendAddBlackHousePlayerAll(data.data.houseId, 0, this.adjustUid)
    else
        UnionManager.ShowError(data.code)
    end
end

function UnionScoreSetPanel.OnCloseBtnClick()
    this:Close()
end

function UnionScoreSetPanel.OnFreezeButtonClick()
    Audio.PlayClickAudio()
    local message = this.GetMessage()
    Alert.Prompt("是否确定冻结？\n此" .. message .. "将无法进行游戏。", function()
        UnionManager.SendFreezeMember(this.adjustUid, 1)
        this:Close()
    end)
end

function UnionScoreSetPanel.OnUnFreezeButtonClick()
    Audio.PlayClickAudio()
    UnionManager.SendFreezeMember(this.adjustUid, 0)
    this:Close()
end

function UnionScoreSetPanel.OnSetAdminstratorClick()
    Audio.PlayClickAudio()
    Alert.Prompt("是否确定将此玩家设为管理员。", function()
        UnionManager.SendSetMemberRole(this.adjustUid, UnionRole.Admin)
        this:Close()
    end)
end

function UnionScoreSetPanel.OnClearButton2Click()
    this.OnClearButtonClick()
end

function UnionScoreSetPanel.OnClearButtonClick()
    Audio.PlayClickAudio()
    local message = this.GetMessage()
    Alert.Prompt("是否确定清分？\n此" .. message .. "将被积分清零。", function()
        UnionManager.SendClearMemberScore(this.adjustUid)
        this:Close()
    end)
end

function UnionScoreSetPanel.OnKickButton2Click()
    this.OnKickButtonClick()
end

function UnionScoreSetPanel.OnKickButtonClick()
    Audio.PlayClickAudio()
    local message = this.GetMessage()
    Alert.Prompt("是否确定踢出？\n此" .. message .. "将被踢出。", function()
        UnionManager.SendKick(this.adjustUid)
        this:Close()
    end)
end

function UnionScoreSetPanel.OnMoveTeamClick()
    PanelManager.Open(PanelConfig.UnionPartnerChange, this.adjustUid)
end

function UnionScoreSetPanel.OnMoveMemberClick()
    PanelManager.Open(PanelConfig.UnionMemberChange, this.adjustUid)
end

function UnionScoreSetPanel.OnBlackHouseClick()
    if this.black then
        Alert.Prompt("此人已在隔离池，是否再次隔离整个小队？", this.BlackAction)
    else
        Alert.Prompt("是否隔离整个小队？", this.BlackAction)
    end
end

function UnionScoreSetPanel.OnSetCommonClick()
    Audio.PlayClickAudio()
    Alert.Prompt("是否确定将此玩家设为普通成员。", function()
        UnionManager.SendSetMemberRole(this.adjustUid, UnionRole.Common)
        this:Close()
    end)
end

function UnionScoreSetPanel.OnSetAsObserverClick()
    Audio.PlayClickAudio()
    Alert.Prompt("是否确定将此玩家设为观察员。", function()
        UnionManager.RequestSetAsObserver(this.adjustUid, 1)
        this:Close()
    end)
end

function UnionScoreSetPanel.OnCancelSetAsObserverClick()
    Audio.PlayClickAudio()
    Alert.Prompt("是否确定将此玩家观察员身份取消。", function()
        UnionManager.RequestSetAsObserver(this.adjustUid, 0)
        this:Close()
    end)
end

--代替队长领取本次收益
function UnionScoreSetPanel.OnGetPlayClick()
    Audio.PlayClickAudio()
    Alert.Prompt("是否确定代替此玩家领取收益。", function()
        UnionManager.RequestGetPlayEarnings(this.adjustUid)
        this:Close()
    end)
end

function UnionScoreSetPanel.GetMessage()
    local message = "玩家"
    if this.UnionRole then
        if this.UnionRole == UnionRole.Partner then
            message = "队长的整条线玩家都"
        elseif this.UnionRole == UnionRole.Common then
            message = "玩家"
        end
    end
    return message
end