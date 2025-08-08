Pin3RulePanel = ClassPanel("Pin3RulePanel")
local this = Pin3RulePanel

function Pin3RulePanel:Awake()
    this = self
    this:Find("Content/YouXi/Label"):GetComponent("Text").text = Pin3Data.parsedRules.playWayName
    this:Find("Content/JuShu/Label"):GetComponent("Text").text = Pin3Data.parsedRules.juShuTxt
    this:Find("Content/GuiZhe/Label"):GetComponent("Text").text = Pin3Data.parsedRules.rule
end


function Pin3RulePanel:OnOpened()
    self:AddOnClick(self:Find("CloseBtn"), HandlerByStatic(self, self.Close))
end