UnionRulePanel = ClassPanel("UnionRulePanel")
UnionRulePanel.gameNameText = nil
UnionRulePanel.juShuText = nil
UnionRulePanel.baseScoreText = nil
UnionRulePanel.ruleText = nil
UnionRulePanel.removeTableBtn = nil
UnionRulePanel.modifyTableBtn = nil
UnionRulePanel.closeBtn = nil
UnionRulePanel.tableId = nil
UnionRulePanel.gameType = nil
local this = UnionRulePanel
function UnionRulePanel:Awake()
    this = self
    local content = this:Find("Content")
    this.gameNameText = content:Find("Rules/PlayWay/Text")
    this.juShuText = content:Find("Rules/JuShu/Text")
    this.baseScoreText = content:Find("Rules/Score/Text")
    this.ruleText = content:Find("Rules/Rule/Text")
    this.removeTableBtn = content:Find("Rules/Btns/RemoveBtn")
    this.modifyTableBtn = content:Find("Rules/Btns/ModifyBtn")
    this.closeBtn = content:Find("Background/CloseBtn")

    this:AddOnClick(this.removeTableBtn, this.OnClickRemoveTableBtn)
    this:AddOnClick(this.modifyTableBtn, this.OnClickModifyTableBtn)
    this:AddOnClick(this.closeBtn, this.OnClickBackBtn)
end

function UnionRulePanel:OnOpened(tableId, gameType, rules)
    this.AddEventListener()

    this.tableId = tableId
    this.gameType = gameType

    local parsedRule = Functions.ParseGameRule(gameType, rules)
    UIUtil.SetText(this.gameNameText, tostring(parsedRule.playWayName))
    UIUtil.SetText(this.juShuText, tostring(parsedRule.juShuTxt))
    UIUtil.SetText(this.baseScoreText, tostring(parsedRule.baseScore))
    UIUtil.SetText(this.ruleText, tostring(parsedRule.rule))

    --按钮权限设置
    UIUtil.SetActive(this.removeTableBtn, UnionData.IsUnionLeaderOrAdministratorOrObserver())
    UIUtil.SetActive(this.modifyTableBtn, false)
end

function UnionRulePanel:OnClosed()
    this.RemoveEventListener()
end

--注册事件
function UnionRulePanel.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_DeleteTable, this.OnTcpDeleteTable)
end

--移除事件
function UnionRulePanel.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.Union.S2C_DeleteTable, this.OnTcpDeleteTable)
end

--================================================================
--
--关闭
function UnionRulePanel.Close()
    PanelManager.Close(PanelConfig.UnionRule)
end
--================================================================
--
function UnionRulePanel.OnClickRemoveTableBtn()
    UnionManager.SendDeleteTable(this.gameType, this.tableId)
end

function UnionRulePanel.OnClickModifyTableBtn()
    -- local args = {
    --     type = 2, --1创建桌子，2修改桌子
    --     unionCallback = UnionRoomPanel.OnDealCreateOrModifyRoom
    -- }
    -- PanelManager.Open(PanelConfig.CreateRoom, this.gameType, RoomType.Tea, MoneyType.Gold, args)
end

function UnionRulePanel.OnClickBackBtn()
    this.Close()
end

--================================================================
--
function UnionRulePanel.OnTcpDeleteTable(data)
    if data.code == 0 then
        Toast.Show("删除桌子成功")
        SendEvent(CMD.Game.UnionDeleteTableRefresh)
        this.Close()
    else
        UnionManager.ShowError(data.code)
    end
end