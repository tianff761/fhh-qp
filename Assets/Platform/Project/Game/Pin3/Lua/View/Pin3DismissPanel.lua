Pin3DismissPanel = ClassPanel("Pin3DismissPanel")
Pin3DismissPanel.leftTime = 0
local this = Pin3DismissPanel

--初始化面板--
function Pin3DismissPanel:OnInitUI()
    this = self
    self:InitPanel()
end

function Pin3DismissPanel:InitPanel()
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

function Pin3DismissPanel:OnOpened()
    this.UpdatePanel()
end

function Pin3DismissPanel.UpdatePanel()
    this.leftTime = Pin3Data.dissolveLeftTime
    local applyId = Pin3Data.requestDissolveUid
    local text = '玩家<color=red>' .. tostring(Pin3Data.GetUserName(applyId)) .. '[' .. tostring(Pin3Data.requestDissolveUid) .. ']' .. '</color>申请解散房间'
    UIUtil.SetText(this.applyDissolveInfoText, text)
    UIUtil.SetText(this.textTime, tostring(this.leftTime) .. "秒")

    local uids = Pin3Data.GetAllUserIds()
    local itemTran = nil
    local idx = 0
    local isAgree = false
    for i, uid in pairs(uids) do
        idx = i
        itemTran = this.list:Find("Item" .. tostring(i))
        if itemTran ~= nil then
            if Pin3Data.GetIsPrepare(uid) == false then
                UIUtil.SetActive(itemTran, false)
            else
                isAgree = Pin3Data.GetIsAgreeDissolveRoom(uid) == true
                UIUtil.SetActive(itemTran, true)
                UIUtil.SetText(itemTran:Find("NameText"), Pin3Data.GetUserName(uid))
                UIUtil.SetActive(itemTran:Find("State/Wait"), not isAgree)
                UIUtil.SetActive(itemTran:Find("State/Sure"), isAgree)
                Functions.SetHeadImage(itemTran:Find("HeadMask/HeadIcon"):GetComponent(typeof(Image)), Pin3Data.GetHeadIcon(uid))
                if Pin3Data.uid == uid then
                    UIUtil.SetActive(this.refuseBtn, not isAgree)
                    UIUtil.SetActive(this.agreeBtn, not isAgree)
                end
            end
        end
    end

    for i = idx + 1, 8 do
        itemTran = this.list:Find("Item" .. tostring(i))
        if itemTran ~= nil then
            UIUtil.SetActive(itemTran, false)
        end
    end

    Scheduler.unscheduleGlobal(this.closeHandle)
    if Pin3Data.dissolveStatus == 2 then
        --房间解散成功，走退出房间流程101708协议
    elseif Pin3Data.dissolveStatus == 0 then
        Toast.Show("房间解散失败")
        this.closeHandle = Scheduler.scheduleOnceGlobal(function()
            PanelManager.Close(Pin3Panels.Pin3DismissRoom)
        end, 1)
    end

    Scheduler.unscheduleGlobal(this.leftTimeHandle)
    this.leftTimeHandle = Scheduler.scheduleGlobal(function()
        this.leftTime = this.leftTime - 1
        UIUtil.SetText(this.textTime, tostring(this.leftTime) .. "秒")
    end, 1)
end

function Pin3DismissPanel.OnClickRefuseBtn()
    Pin3NetworkManager.SendDealDessovleFkRoomRequset(2)
end

function Pin3DismissPanel.OnClickAgreeBtn()
    Pin3NetworkManager.SendDealDessovleFkRoomRequset(1)
end

function Pin3DismissPanel:OnClosed()
    Scheduler.unscheduleGlobal(this.closeHandle)
    Scheduler.unscheduleGlobal(this.leftTimeHandle)
end