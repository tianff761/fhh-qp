ClubRulePanel = ClassPanel("ClubRulePanel")
ClubRulePanel.gameNameText = nil
ClubRulePanel.juShuText = nil
ClubRulePanel.baseScoreText = nil
ClubRulePanel.ruleText = nil
ClubRulePanel.removeTableBtn = nil
ClubRulePanel.modifyTableBtn = nil
ClubRulePanel.closeBtn = nil
ClubRulePanel.tableId = nil
ClubRulePanel.gameType = nil
local this = ClubRulePanel
function ClubRulePanel:Awake()
    this = self
    local content = this:Find("Content")
    this.gameNameText = content:Find("Rules/PlayWay/Text")
    this.juShuText = content:Find("Rules/JuShu/Text")
    this.baseScoreText = content:Find("Rules/Score/Text")
    this.ruleText = content:Find("Rules/Rule/Text")
    this.removeTableBtn = content:Find("Rules/Btns/RemoveBtn")
    this.closeBtn = content:Find("Bgs/CloseBtn")
end

function ClubRulePanel:OnOpened(tableId, gameType, rules)
    Log("OnOpened", tableId, gameType, rules)
    this.tableId = tableId
    this.gameType = gameType
    this:AddOnClick(this.removeTableBtn, this.OnClickRemoveTableBtn)
    this:AddOnClick(this.closeBtn, this.OnClickBackBtn)
    local parsedRule = Functions.ParseGameRule(gameType, rules)
    UIUtil.SetText(this.gameNameText, tostring(parsedRule.playWayName))
    UIUtil.SetText(this.juShuText, tostring(parsedRule.juShuTxt))
    UIUtil.SetText(this.baseScoreText, tostring(parsedRule.baseScore))
    UIUtil.SetText(this.ruleText, tostring(parsedRule.rule))

    --按钮权限设置
    UIUtil.SetActive(this.removeTableBtn, ClubData.selfRole == ClubRole.Boss)
end

function ClubRulePanel.OnClickRemoveTableBtn()
    ClubManager.SendDeleteTable(this.gameType, this.tableId)
end

function ClubRulePanel.OnClickBackBtn()
    PanelManager.Close(PanelConfig.ClubRule, true)
end

