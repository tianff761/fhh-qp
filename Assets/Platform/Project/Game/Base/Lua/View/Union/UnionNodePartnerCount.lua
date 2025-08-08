UnionNodePartnerCount = {}
local this = UnionNodePartnerCount

function UnionNodePartnerCount.Init(transform)
    this.transform = transform
    this.gameObject = transform.gameObject
    this.isInitUI = false
end

function UnionNodePartnerCount.CheckUI()
    if this.isInitUI then
        return
    end
    this.isInitUI = true
    this.label1 = this.transform:Find("Text1"):GetComponent(TypeText)
    this.label2 = this.transform:Find("Text2"):GetComponent(TypeText)
    this.label3 = this.transform:Find("Text3"):GetComponent(TypeText)
    this.label4 = this.transform:Find("Text4"):GetComponent(TypeText)
    this.label5 = this.transform:Find("Text5"):GetComponent(TypeText)
    this.label6 = this.transform:Find("Text6"):GetComponent(TypeText)
    this.label7 = this.transform:Find("Text7"):GetComponent(TypeText)

    this.labelMember1 = this.transform:Find("Bg3/Text"):GetComponent(TypeText)
    this.labelMember2 = this.transform:Find("Bg4/Text"):GetComponent(TypeText)

    this.TodayActuallyQuestionBtn = this.transform:Find("Text3/QuestionBtn")
    this.invitePartnerBtn = this.transform:Find("InvitePartnerBtn").gameObject
    this.inviteMemberBtn = this.transform:Find("InviteMemberBtn").gameObject
    this.FollowPlayerBtn = this.transform:Find("FollowPlayerBtn")

    this.KeepBaseGo = this.transform:Find("Text8").gameObject
    this.KeepBaseQuestionBtn = this.transform:Find("Text8/QuestionBtn")

    UIUtil.SetActive(this.TodayActuallyQuestionBtn, UnionData.IsNotCommonPlayer())

    this.AddUIEventListener()
end

function UnionNodePartnerCount.Open()
    this.CheckUI()
    this.AddEventListener()
    UnionManager.SendPartnerCount()
end

function UnionNodePartnerCount.Close()
    this.RemoveEventListener()
end

------------------------------------------------------------------
--
--注册事件
function UnionNodePartnerCount.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_PartnerCount, this.OnPartnerCount)
    AddEventListener(CMD.Tcp.Union.S2C_AddPartner, this.OnTcpAddPartnerMember)
    AddEventListener(CMD.Tcp.Union.S2C_InviteMember, this.OnTcpAddCommonMember)
    AddEventListener(CMD.Tcp.Union.S2C_REQUEST_PLAYER_INFO, this.ResponsePlayerInfo)
end

--移除事件
function UnionNodePartnerCount.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.Union.S2C_PartnerCount, this.OnPartnerCount)
    RemoveEventListener(CMD.Tcp.Union.S2C_AddPartner, this.OnTcpAddPartnerMember)
    RemoveEventListener(CMD.Tcp.Union.S2C_InviteMember, this.OnTcpAddCommonMember)
    RemoveEventListener(CMD.Tcp.Union.S2C_REQUEST_PLAYER_INFO, this.ResponsePlayerInfo)
end

--UI相关事件
function UnionNodePartnerCount.AddUIEventListener()
    EventUtil.AddOnClick(this.TodayActuallyQuestionBtn, this.OnQuestionBtnClick)
    EventUtil.AddOnClick(this.KeepBaseQuestionBtn, this.OnKeepBaseQuestionBtnClick)
    EventUtil.AddOnClick(this.invitePartnerBtn, this.OnInvitePartnerBtnClick)
    EventUtil.AddOnClick(this.inviteMemberBtn, this.OnInviteMemberBtnClick)
    EventUtil.AddOnClick(this.FollowPlayerBtn, this.OnFollowPlayerBtnClick)
end

--================================================================
--
--
function UnionNodePartnerCount.OnQuestionBtnClick()
    PanelManager.Open(PanelConfig.UnionFaceRecord)
end

function UnionNodePartnerCount.OnKeepBaseQuestionBtnClick()
    PanelManager.Open(PanelConfig.UnionKeepBasePop)
end

function UnionNodePartnerCount.OnInvitePartnerBtnClick()
    PanelManager.Open(PanelConfig.UnionInputNumber, UnionInputNumberPanelType.AddPartner, function(num)
        this.InvitePlayerType = UnionRole.Partner
        UnionManager.RequestPlayerInfo(num)
        PanelManager.Close(PanelConfig.UnionInputNumber, true)
    end)
end
--
function UnionNodePartnerCount.OnInviteMemberBtnClick()
    PanelManager.Open(PanelConfig.UnionInputNumber, UnionInputNumberPanelType.AddMember, function(num)
        this.InvitePlayerType = UnionRole.Common
        UnionManager.RequestPlayerInfo(num)
        PanelManager.Close(PanelConfig.UnionInputNumber, true)
    end)
end
--
function UnionNodePartnerCount.OnFollowPlayerBtnClick()
    PanelManager.Open(PanelConfig.UnionFollowPlayer)
end

--================================================================
--
-- {"cmd":4204,"code":0,"data":{"yScore":0,"tScore":0,"yNum":0,"tNum":0,"pcount":16,"per":100,"totalScore":869704}}->
function UnionNodePartnerCount.OnPartnerCount(data)
    if data.code == 0 then
        local temp = data.data
        --local poolText = temp.pool and "              拼十奖池：" .. math.floor(temp.pool["1014"]) or ""
        this.label1.text = math.ToRound(temp.tScore, 2) .. "(" .. (temp.tBdAll or 0) .. ")"
        this.label2.text = math.ToRound(temp.yScore, 2) .. "(" .. (temp.yBdAll or 0) .. ")"
        this.label3.text = math.ToRound(temp.tNum, 2) .. "(" .. (temp.tBdAct or 0) .. ")"
        this.label4.text = math.ToRound(temp.yNum, 2) .. "(" .. (temp.yBdAct or 0) .. ")"
        this.label5.text = math.ToRound(temp.totalScore, 2)
        this.label6.text = math.ToRound(temp.per, 2) .. "%"
        this.label7.text = temp.pcount or 0

        this.labelMember1.text = (temp.partenN or 0) .. "人"
        this.labelMember2.text = (temp.memberN or 0) .. "人"

        -- UnionData.isBaodi = temp.showBd == 1
        UnionData.isBaodi = UnionData.IsUnionLeader() --保底比例只有馆主才能显示
        UIUtil.SetActive(this.KeepBaseGo, UnionData.isBaodi)
        SendEvent(CMD.Game.UnionBaodiUpdate)
    else
        UnionManager.ShowError(data.code)
    end
end

--设置合伙人
function UnionNodePartnerCount.OnTcpAddPartnerMember(data)
    if data.code == 0 then
        Toast.Show("邀请队长成功")
    else
        UnionManager.ShowError(data.code)
    end
end

--邀请玩家
function UnionNodePartnerCount.OnTcpAddCommonMember(data)
    if data.code == 0 then
        Toast.Show("邀请成功")
    else
        UnionManager.ShowError(data.code)
    end
end

--返回玩家信息
---@param data table playId  "玩家id" --name 名字 --icon 头像
function UnionNodePartnerCount.ResponsePlayerInfo(data)
    if data.code == 0 then
        PanelManager.Open(PanelConfig.UnionInvitePlayerNotice, data.data, this.InvitePlayerType)
    else
        UnionManager.ShowError(data.code)
    end
end