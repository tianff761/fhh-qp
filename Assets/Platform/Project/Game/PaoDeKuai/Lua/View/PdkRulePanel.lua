PdkRulePanel = ClassPanel("PdkRulePanel")
local this = PdkRulePanel

--UI初始化
function PdkRulePanel:OnInitUI()
    this = self

    this.closeBtn = self:Find("Content/Background/CloseBtn").gameObject
    local nodeTrans = self:Find("Content/Node")

    this.playWayNameTxt = nodeTrans:Find("PlayWay/Text"):GetComponent(TypeText)
    this.juShuTxt = nodeTrans:Find("JuShu/Text"):GetComponent(TypeText)
    this.ruleTxt = nodeTrans:Find("Rule/Text"):GetComponent(TypeText)
    local scoreTrans = nodeTrans:Find("Score")
    this.scoreGO = scoreTrans.gameObject
    this.scoreTxt = scoreTrans:Find("Text"):GetComponent(TypeText)

    this.AddUIListenerEvent()
end

--当面板开启开启时
function PdkRulePanel:OnOpened()
    this.UpdateDisplay()
end

--当面板关闭时调用
function PdkRulePanel:OnClosed()

end

function PdkRulePanel.Clear()
    this.playWayNameTxt.text = ""
    this.juShuTxt.text = ""
    this.scoreTxt.text = ""
    this.ruleTxt.text = ""
    UIUtil.SetActive(this.scoreGO, false)
end

--关闭
function PdkRulePanel.Close()
    PanelManager.Close(PdkPanelConfig.Rule)
end

--UI相关事件
function PdkRulePanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
end

function PdkRulePanel.OnCloseBtnClick()
    this.Close()
end

function PdkRulePanel.UpdateDisplay()
    if PdkRoomModule.rules ~= nil then
        local ruleInfoData = PdkConfig.ParsePdkRule(PdkRoomModule.rules)
        this.playWayNameTxt.text = ruleInfoData.playWayName
        this.juShuTxt.text = ruleInfoData.juShuTxt
        this.ruleTxt.text = ruleInfoData.rule

        if PdkRoomModule.IsGoldRoom() then
            UIUtil.SetActive(this.scoreGO, true)
            this.scoreTxt.text = PdkRoomModule.GetRule(PdkRuleType.DiFen)
        else
            UIUtil.SetActive(this.scoreGO, false)
        end
    else
        this.Clear()
    end
end