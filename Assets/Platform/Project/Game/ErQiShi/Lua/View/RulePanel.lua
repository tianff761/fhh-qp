RulePanel = ClassPanel("RulePanel")
local this = RulePanel

function RulePanel:Awake()
    this = self
    this:Find("Content/YouXi/Label"):GetComponent("Text").text = BattleModule.parsedRules.playWayName
    this:Find("Content/JuShu/Label"):GetComponent("Text").text = BattleModule.parsedRules.juShuTxt
    this:Find("Content/GuiZhe/Label"):GetComponent("Text").text = BattleModule.parsedRules.rule
end


function RulePanel:OnOpened()
    self:AddOnClick(self:Find("CloseBtn"), HandlerByStatic(self, self.Close))
end