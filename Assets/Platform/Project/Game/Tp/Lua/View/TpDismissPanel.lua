TpDismissPanel = ClassPanel("TpDismissPanel")
TpDismissPanel.leftTime = 0
local this = TpDismissPanel

--初始化面板--
function TpDismissPanel:OnInitUI()
    this = self
    self:InitPanel()
end

function TpDismissPanel:InitPanel()
    local transform = self.transform
    local content = transform:Find("Content")
    local panelContent = content:Find("Node")

    self.refuseBtn = self:Find('Content/Node/RefuseBtn') -- 拒绝按钮
    self.agreeBtn = self:Find('Content/Node/AgreeBtn') -- 同意按钮
    self.applyDissolveInfoText = self:Find('Content/Node/ApplyDissolveInfoText')
    self.textTime = self:Find('Content/Node/LeftTimeText')
    self.list = self:Find('Content/Node/List')

    self:AddOnClick(self.refuseBtn, this.OnClickRefuseBtn)
    self:AddOnClick(self.agreeBtn, this.OnClickAgreeBtn)
end

function TpDismissPanel:OnOpened(data)
    this.dismissInfo = data
    this.UpdatePanel()
end

function TpDismissPanel.UpdatePanel()
    this.leftTime = this.dismissInfo.countDown
    local applyId = this.dismissInfo.dId
    local playerData = TpDataMgr.GetPlayerDataById(applyId)
    local text = '玩家<color=red>' .. playerData.name .. '[' .. tostring(applyId) .. ']' .. '</color>申请解散房间'
    UIUtil.SetText(this.applyDissolveInfoText, text)
    UIUtil.SetText(this.textTime, tostring(this.leftTime) .. "秒")

    local itemTran = nil
    local players = this.dismissInfo.msgs
    local length = #players
    for i = 1, length do
        playerData = players[i]
        itemTran = this.list:Find("Item" .. tostring(i))
        if playerData then
            UIUtil.SetActive(itemTran, true)
            UIUtil.SetText(itemTran:Find("NameText"), TpDataMgr.GetPlayerDataById(playerData.playerId).name)
            UIUtil.SetActive(itemTran:Find("State/Wait"), playerData.isAgree == 0)
            UIUtil.SetActive(itemTran:Find("State/Sure"), playerData.isAgree == 1)
            Functions.SetHeadImage(itemTran:Find("HeadMask/HeadIcon"):GetComponent(typeof(Image)), TpDataMgr.GetPlayerDataById(playerData.playerId).headUrl)
            if TpDataMgr.userId == playerData.playerId then
                UIUtil.SetActive(this.refuseBtn, playerData.isAgree == 0)
                UIUtil.SetActive(this.agreeBtn, playerData.isAgree == 0)
            end
        end
    end

    for i = length + 1, 9 do
        itemTran = this.list:Find("Item" .. tostring(i))
        if itemTran ~= nil then
            UIUtil.SetActive(itemTran, false)
        end
    end

    Scheduler.unscheduleGlobal(this.closeHandle)
    if this.dismissInfo.result == 2 then
    elseif this.dismissInfo.result == 0 then
        Toast.Show("房间解散失败")
        this.closeHandle = Scheduler.scheduleOnceGlobal(function()
            PanelManager.Close(TpPanelConfig.Dismiss)
        end, 1)
    end

    Scheduler.unscheduleGlobal(this.leftTimeHandle)
    this.leftTimeHandle = Scheduler.scheduleGlobal(function()
        this.leftTime = this.leftTime - 1
        UIUtil.SetText(this.textTime, tostring(this.leftTime) .. "秒")
    end, 1)
end

function TpDismissPanel.OnClickRefuseBtn()
    TpCommand.SendDismissOperate(2)
end

function TpDismissPanel.OnClickAgreeBtn()
    TpCommand.SendDismissOperate(1)
end

function TpDismissPanel:OnClosed()
    Scheduler.unscheduleGlobal(this.closeHandle)
    Scheduler.unscheduleGlobal(this.leftTimeHandle)
end