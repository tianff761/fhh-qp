-------------名字------------
LYCRoomInfoPanel = ClassPanel("LYCRoomInfoPanel");
local this = LYCRoomInfoPanel
-----------------------------
--@RefType [luaIde#UnityEngine.Transform]
local transform
local gameObject

function LYCRoomInfoPanel:OnInitUI()
    self:InitPanel()
    self:AddClickEvent()
end

function LYCRoomInfoPanel:InitPanel()
    transform = self.transform
    local content = transform:Find('Content')
    local panelContent = content:Find("Node")
    self.closeBtn = content:Find('Background/CloseBtn').gameObject
    self.playWayT = panelContent:Find('PlayWay/T'):GetComponent('Text')
    self.diFen = panelContent:Find('DiFen')
    self.diFenT = self.diFen:Find('T'):GetComponent('Text')
    self.ruleT = panelContent:Find('Rule/T'):GetComponent('Text')
    self.cardRuleT = panelContent:Find('CardRule/T'):GetComponent('Text')
    self.fanBeiRule = panelContent:Find('FanBeiRule')
    self.fanBeiRuleT = self.fanBeiRule:Find("T"):GetComponent("Text")
end

--注册点击事件
function LYCRoomInfoPanel:AddClickEvent()
    self:AddOnClick(self.closeBtn, this.Close)
end

function LYCRoomInfoPanel:OnOpened()
    self:SetData()
end

--设置数据
function LYCRoomInfoPanel:SetData()
    local ruleStr = LYCRoomData.gaoJiConfig
    local isGoldGame = LYCRoomData.IsGoldGame()
    self.playWayT.text = LYCRoomData.gameName


    self.fanBeiRuleT.text = LYCRoomData.baseRuleText
    self.cardRuleT.text = LYCRoomData.specialRuleText--LYCRoomData.SpecialConfig
    self.ruleT.text = LYCRoomData.RuleText


    self.diFenT.text = LYCRoomData.diFen

    UIUtil.SetActive(self.diFen, not isGoldGame)

    UIUtil.SetActive(self.payType, not isGoldGame)
end


--关闭面板
function LYCRoomInfoPanel.Close()

    PanelManager.Close(LYCPanelConfig.RoomInfo, false)
end