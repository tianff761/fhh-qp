UnionPartnerMoreActionPanel = ClassPanel("UnionPartnerMoreActionPanel")

local this = UnionPartnerMoreActionPanel
--UI初始化
function UnionPartnerMoreActionPanel:OnInitUI()
    this = self
    this.closeBtn = self:Find("CloseBtn")

    --按钮
    local Content = self:Find("Content")
    this.FirstPanel = Content:Find("1")
    this.KickButton = this.FirstPanel:Find("KickButton")
    this.FreezeButton = this.FirstPanel:Find("FreezeButton")
    this.UnFreezeButton = this.FirstPanel:Find("UnFreezeButton")
    this.ClearButton = this.FirstPanel:Find("ClearButton")

    this.SecondPanel = Content:Find("2")
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

    local UserInfo = Content:Find("UserInfo")
    this.HeadImg = UserInfo:Find("HeadImg"):GetComponent(TypeImage)
    this.Name = UserInfo:Find("Name")
    this.ID = UserInfo:Find("ID")

    this.AddUIListenerEvent()
end

function UnionPartnerMoreActionPanel:OnOpened(panelIndex, isIce, uid, icon, name, unionRole, black)
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
        UIUtil.SetActive(this.FirstPanel, true)
        UIUtil.SetActive(this.SecondPanel, false)
        UIUtil.SetActive(this.FreezeButton, not this.isIce and UnionData.IsUnionLeaderOrAdministrator())
        UIUtil.SetActive(this.UnFreezeButton, this.isIce and UnionData.IsUnionLeaderOrAdministrator())
    elseif panelIndex == 2 then
        UIUtil.SetActive(this.FirstPanel, false)
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
    end
    this.AddListenerEvent()
end

function UnionPartnerMoreActionPanel.OnClosed()
    this.RemoveListenerEvent()
end


--UI相关事件
function UnionPartnerMoreActionPanel.AddUIListenerEvent()
    this:AddOnClick(this.KickButton, this.OnKickButtonClick)
    this:AddOnClick(this.FreezeButton, this.OnFreezeButtonClick)
    this:AddOnClick(this.UnFreezeButton, this.OnUnFreezeButtonClick)
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
end

function UnionPartnerMoreActionPanel.AddListenerEvent()
    AddEventListener(CMD.Tcp.Union.S2C_UNION_CREATE_BLACK_HOUSE, this.AddBlackHousePlayerAll)
end

function UnionPartnerMoreActionPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Tcp.Union.S2C_UNION_CREATE_BLACK_HOUSE, this.AddBlackHousePlayerAll)
end

function UnionPartnerMoreActionPanel.OnKickButtonClick()
    Audio.PlayClickAudio()
    local message = this.GetMessage()
    Alert.Prompt("是否确定踢出？\n此" .. message .. "将被踢出。", function()
        UnionManager.SendKick(this.adjustUid)
        this:Close()
    end)
end

function UnionPartnerMoreActionPanel.OnFreezeButtonClick()
    Audio.PlayClickAudio()
    local message = this.GetMessage()
    Alert.Prompt("是否确定冻结？\n此" .. message .. "将无法进行游戏。", function()
        UnionManager.SendFreezeMember(this.adjustUid, 1)
        this:Close()
    end)
end

function UnionPartnerMoreActionPanel.GetMessage()
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

function UnionPartnerMoreActionPanel.OnUnFreezeButtonClick()
    Audio.PlayClickAudio()
    UnionManager.SendFreezeMember(this.adjustUid, 0)
    this:Close()
end

function UnionPartnerMoreActionPanel.OnClearButtonClick()
    Audio.PlayClickAudio()
    local message = this.GetMessage()
    Alert.Prompt("是否确定清分？\n此" .. message .. "将被积分清零。", function()
        UnionManager.SendClearMemberScore(this.adjustUid)
        this:Close()
    end)
end

function UnionPartnerMoreActionPanel.OnSetAdminstratorClick()
    Audio.PlayClickAudio()
    Alert.Prompt("是否确定将此玩家设为管理员。", function()
        UnionManager.SendSetMemberRole(this.adjustUid, UnionRole.Admin)
        this:Close()
    end)
end

function UnionPartnerMoreActionPanel.OnSetCommonClick()
    Audio.PlayClickAudio()
    Alert.Prompt("是否确定将此玩家设为普通成员。", function()
        UnionManager.SendSetMemberRole(this.adjustUid, UnionRole.Common)
        this:Close()
    end)
end

function UnionPartnerMoreActionPanel.OnSetAsObserverClick()
    Audio.PlayClickAudio()
    Alert.Prompt("是否确定将此玩家设为观察员。", function()
        UnionManager.RequestSetAsObserver(this.adjustUid, 1)
        this:Close()
    end)
end

function UnionPartnerMoreActionPanel.OnCancelSetAsObserverClick()
    Audio.PlayClickAudio()
    Alert.Prompt("是否确定将此玩家观察员身份取消。", function()
        UnionManager.RequestSetAsObserver(this.adjustUid, 0)
        this:Close()
    end)
end

function UnionPartnerMoreActionPanel.OnClearButton2Click()
    this.OnClearButtonClick()
end

function UnionPartnerMoreActionPanel.OnKickButton2Click()
    this.OnKickButtonClick()
end

function UnionPartnerMoreActionPanel.OnMoveTeamClick()
    PanelManager.Open(PanelConfig.UnionPartnerChange, this.adjustUid)
end

function UnionPartnerMoreActionPanel.OnMoveMemberClick()
    PanelManager.Open(PanelConfig.UnionMemberChange, this.adjustUid)
end

function UnionPartnerMoreActionPanel.OnBlackHouseClick()
    if this.black then
        Alert.Prompt("此人已在隔离池，是否再次隔离整个小队？", this.BlackAction)
    else
        Alert.Prompt("是否隔离整个小队？", this.BlackAction)
    end
end

function UnionPartnerMoreActionPanel.BlackAction()
    LogError("<color=aqua>BlackAction</color>")
    UnionManager.SendCreateBlackHouseGroup()
end

function UnionPartnerMoreActionPanel.AddBlackHousePlayerAll(data)
    LogError("<color=aqua>data</color>", data)
    if data.code == 0 then
        UnionManager.SendAddBlackHousePlayerAll(data.data.houseId, 0, this.adjustUid)
    else
        UnionManager.ShowError(data.code)
    end
end

function UnionPartnerMoreActionPanel.OnCloseBtnClick()
    this:Close()
end

