UnionWarnScorePanel = ClassPanel("UnionWarnScorePanel")

local this = UnionWarnScorePanel

function UnionWarnScorePanel:Awake()
    this = self
    this.closeBtn = this:Find("Content/Background/CloseBtn").gameObject
    this.okBtn = this:Find("Content/Content/OkBtn")
    this.inputField = this:Find("Content/Content/InputField"):GetComponent(TypeInputField)
    this.maxLabel = this:Find("Content/Content/MaxText"):GetComponent(TypeText)
    this:AddOnClick(this.closeBtn, this.OnClickCloseBtn)
    this:AddOnClick(this.okBtn, this.OnClickOkBtn)
end

function UnionWarnScorePanel:OnOpened(args)
    this.AddEventListener()
    this.pId = args.pId
    this.totalScore = math.ToRound(tonumber(args.totalScore), 2)
    this.warnScore = math.ToRound(args.warnScore, 2)

    this.inputField.text = args.warnScore
    this.maxLabel.text = args.totalScore
end

function UnionWarnScorePanel:OnClosed()
    this.RemoveEventListener()
end

--注册事件
function UnionWarnScorePanel.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_UNION_SET_WARRING_SCORE, this.OnSetWarringScore)
end

--移除事件
function UnionWarnScorePanel.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.Union.S2C_UNION_SET_WARRING_SCORE, this.OnSetWarringScore)
end

--================================================================
--
--关闭
function UnionWarnScorePanel.Close()
    PanelManager.Close(PanelConfig.UnionSetScore)
end
--================================================================
--
function UnionWarnScorePanel.OnClickCloseBtn()
    this.Close()
end

function UnionWarnScorePanel.Close()
    PanelManager.Close(PanelConfig.UnionWarnScore)
end

function UnionWarnScorePanel.OnClickOkBtn()
    if this.pId == UserData.GetUserId() then
        this.Close()
        return
    end

    local value = tonumber(this.inputField.text)
    if value ~= nil then
        --if value > this.totalScore then
        --    Toast.Show("输入分数不能大于总分")
        --else
            UnionManager.SendSetWarringScore(this.pId, value)
        --end
    else
        Toast.Show("请输入正确的分数")
    end
end

--设置警戒线返回
function UnionWarnScorePanel.OnSetWarringScore(data)
    if data.code == 0 then
        Toast.Show("设置警戒线成功")
        SendEvent(CMD.Game.UnionSetWarnScoreRefresh)
        this.Close()
    else
        UnionManager.ShowError(data.code)
    end
end