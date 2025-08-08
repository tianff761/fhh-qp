-------------名字------------
SDBRoomInfoPanel = ClassPanel("SDBRoomInfoPanel");
local this = SDBRoomInfoPanel
-----------------------------
--@RefType [luaIde#UnityEngine.Transform]
local transform
local gameObject

function SDBRoomInfoPanel:OnInitUI()
    self:InitPanel()
    self:AddClickEvent()
end

function SDBRoomInfoPanel:InitPanel()
    transform = self.transform
    local content = transform:Find('Content')
    local panelContent = content:Find("Node")
    self.closeBtn = content:Find('Background/CloseButton').gameObject
    self.playWayT = panelContent:Find('PlayWay/T'):GetComponent('Text')
    self.diFen = panelContent:Find('DiFen')
    self.diFenT = self.diFen:Find('T'):GetComponent('Text')
    self.diFen2 = panelContent:Find('DiFen2')
    self.diFen2T = self.diFen2:Find('T'):GetComponent('Text')
    self.model = panelContent:Find('Model/T'):GetComponent('Text')
    self.ruleT = panelContent:Find('Rule/T'):GetComponent('Text')
    self.cardRuleT = panelContent:Find('CardRule/T'):GetComponent('Text')
    self.payType = panelContent:Find('PayType')
    self.payTypeT = self.payType:Find("T"):GetComponent("Text")
    self.payType2 = panelContent:Find('PayType2')
    self.payType2T = self.payType2:Find("T"):GetComponent("Text")
end

--注册点击事件
function SDBRoomInfoPanel:AddClickEvent()
    self:AddOnClick(self.closeBtn, this.Close)
end

function SDBRoomInfoPanel:OnOpened()
    self:SetData()
end

--设置数据
function SDBRoomInfoPanel:SetData()
    local ruleStr = ""
    local isGoldGame = SDBRoomData.IsGoldGame()
    if isGoldGame then
        ruleStr = SDBRoomData.gaoJiConfig
    else
        ruleStr = '推注:' .. SDBRoomData.tuiZhu .. ' ' .. SDBRoomData.showStartType .. " " .. SDBRoomData.gaoJiConfig
    end
    self.playWayT.text = SDBRoomData.gameName
    self.model.text = SDBRoomData.model
    self.ruleT.text = ruleStr
    self.payTypeT.text = SDBRoomData.payType
    self.cardRuleT.text = "五小(2倍)  十点半(3倍)  天王(4倍)  人五小(5倍)"
   
    if isGoldGame then
        self.payType2T.text = SDBRoomData.difenBeiShu
        self.diFen2T.text = SDBRoomData.Bet
    else
        self.payTypeT.text = SDBRoomData.payType
        self.diFenT.text = SDBRoomData.Bet
    end

    UIUtil.SetActive(self.diFen, not isGoldGame)
    UIUtil.SetActive(self.diFen2, isGoldGame)

    UIUtil.SetActive(self.payType, not isGoldGame)
    UIUtil.SetActive(self.payType2, isGoldGame)
end


--关闭面板
function SDBRoomInfoPanel.Close()

    PanelManager.Close(SDBPanelConfig.RoomInfo, false)
end