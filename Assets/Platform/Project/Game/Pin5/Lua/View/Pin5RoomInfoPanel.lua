-------------名字------------
Pin5RoomInfoPanel = ClassPanel("Pin5RoomInfoPanel");
local this = Pin5RoomInfoPanel
-----------------------------
--@RefType [luaIde#UnityEngine.Transform]
local transform
local gameObject

function Pin5RoomInfoPanel:OnInitUI()
    self:InitPanel()
    self:AddClickEvent()
end

function Pin5RoomInfoPanel:InitPanel()
    transform = self.transform
    local content = transform:Find('Content')
    local node = content:Find('Node')

    self.closeBtn = content:Find('Background/CloseBtn').gameObject
    self.playWayT = node:Find('PlayWay/T'):GetComponent('Text')
    self.diFen = node:Find('DiFen')
    self.diFenT = self.diFen:Find('T'):GetComponent('Text')
    self.ruleT = node:Find('Rule/T'):GetComponent('Text')
    self.cardRuleT = node:Find('CardRule/T'):GetComponent('Text')
    self.fanBeiRule = node:Find('FanBeiRule')
    self.fanBeiRuleT = self.fanBeiRule:Find("T"):GetComponent("Text")
end

--注册点击事件
function Pin5RoomInfoPanel:AddClickEvent()
    self:AddOnClick(self.closeBtn, this.Close)
end

function Pin5RoomInfoPanel:OnOpened()
    self:SetData()
end

--设置数据
function Pin5RoomInfoPanel:SetData()
    local ruleStr = ""
    local isGoldGame = Pin5RoomData.IsGoldGame()
    if isGoldGame then
        ruleStr = "最大抢庄:" .. Pin5RoomData.multiple .. " " .. Pin5RoomData.tuiZhu .. "推注 " .. Pin5RoomData.model .. " " .. Pin5RoomData.gaoJiConfig.."  抢庄最低积分 "..Pin5RoomData.RobLimit
    else
        ruleStr = Pin5RoomData.payType .. ' ' .. Pin5RoomData.showStartType .. " 最大抢庄:" .. Pin5RoomData.multiple .. " " .. Pin5RoomData.tuiZhu .. "推注 " .. Pin5RoomData.model .. " " .. Pin5RoomData.gaoJiConfig
    end

    self.fanBeiRuleT.text = Pin5RoomData.fanBeiRule

    self.playWayT.text = Pin5RoomData.gameName
    self.ruleT.text = ruleStr
    self.cardRuleT.text = Pin5RoomData.SpecialConfig

    self.diFenT.text = Pin5RoomData.diFen

    UIUtil.SetActive(self.diFen, not isGoldGame)

    UIUtil.SetActive(self.payType, not isGoldGame)
end


--关闭面板
function Pin5RoomInfoPanel.Close()

    PanelManager.Close(Pin5PanelConfig.RoomInfo, false)
end