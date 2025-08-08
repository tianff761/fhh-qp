TpRulePanel = ClassPanel("TpRulePanel")
TpRulePanel.Instance = nil
--
local this = nil
--
--初始属性数据
function TpRulePanel:InitProperty()

end

--UI初始化
function TpRulePanel:OnInitUI()
    this = self
    this:InitProperty()

    this.closeBtn = self:Find("Content/Background/CloseBtn").gameObject
    local nodeTrans = self:Find("Content/Node")
    this.node = nodeTrans.gameObject
    this.playWayTxt = nodeTrans:Find("PlayWay/Text"):GetComponent(TypeText)
    this.juShuTxt = nodeTrans:Find("JuShu/Text"):GetComponent(TypeText)
    this.ruleTxt = nodeTrans:Find("Rule/Text"):GetComponent(TypeText)
    local scoreTrans = nodeTrans:Find("JuShu/Score")
    this.scoreGO = scoreTrans.gameObject
    this.scoreTxt = scoreTrans:Find("Text"):GetComponent(TypeText)

    this.AddUIListenerEvent()
end

--当面板开启开启时
function TpRulePanel:OnOpened()
    TpRulePanel.Instance = self
    this.AddListenerEvent()
    this.UpdateDisplay()
end

--当面板关闭时调用
function TpRulePanel:OnClosed()
    TpRulePanel.Instance = nil
    this.RemoveListenerEvent()
    -- this.playWayTxt.text = ""
    -- this.juShuTxt.text = ""
    -- this.scoreTxt.text = ""
    -- this.ruleTxt.text = ""
    UIUtil.SetActive(this.scoreGO, false)
end

------------------------------------------------------------------
--
--关闭
function TpRulePanel.Close()
    PanelManager.Close(TpPanelConfig.Rule)
end

--
function TpRulePanel.AddListenerEvent()

end

--
function TpRulePanel.RemoveListenerEvent()

end

--UI相关事件
function TpRulePanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
end

------------------------------------------------------------------
--
function TpRulePanel.OnCloseBtnClick()
    this.Close()
end

------------------------------------------------------------------
--
function TpRulePanel.UpdateDisplay()
    if TpDataMgr.rules ~= nil then
        local ruleInfoData = TpConfig.ParseTpRule(TpDataMgr.rules, TpDataMgr.gpsType)
        this.playWayTxt.text = ruleInfoData.playWayName
        this.ruleTxt.text = ruleInfoData.rule

        if TpDataMgr.moneyType == MoneyType.Gold then
            this.juShuTxt.text = ruleInfoData.juShuTxt
            UIUtil.SetActive(this.scoreGO, true)
            this.scoreTxt.text = tostring(TpDataMgr.rules.qz)
        else
            this.juShuTxt.text = ruleInfoData.juShuTips
            UIUtil.SetActive(this.scoreGO, false)
        end
        local height = this.ruleTxt.preferredHeight
        height = 154 + 22 + height + 28 --距离顶部，文本距离顶部，下边的Padding
        UIUtil.SetHeight(this.node, height)
    else
        this.playWayTxt.text = ""
        this.juShuTxt.text = ""
        this.scoreTxt.text = ""
        this.ruleTxt.text = ""
    end
end
