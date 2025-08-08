LYCDismissPanel = ClassPanel("LYCDismissPanel")
local this = LYCDismissPanel

local isInit = false
local dismissPlayers = {}
local countDown = 0
--初始化面板--
function LYCDismissPanel:OnInitUI()
    self:InitPanel()
    self:AddMsg()
end

function LYCDismissPanel:InitPanel()
    local transform = self.transform
    local content = transform:Find("Content")
    local panelContent = content:Find("Node")

    self.ButtonJuJue = panelContent:Find('ButtonJuJue').gameObject -- 拒绝按钮
    self.ButtonTongYi = panelContent:Find('ButtonTongYi').gameObject -- 同意按钮
    self.TextPlayerName = panelContent:Find('TextPlayerName').gameObject:GetComponent('Text')
    self.TextTime = panelContent:Find('TextTime').gameObject:GetComponent('Text')
    self.ItemList = panelContent:Find('List').gameObject.transform
    self.playerItem = self.ItemList:Find('Item').gameObject
end

function LYCDismissPanel:AddMsg()
    self:AddOnClick(self.ButtonJuJue, this.OnClickJuJue)
    self:AddOnClick(self.ButtonTongYi, this.OnClickTongYi)
end

function LYCDismissPanel:OnOpened(arg)
    self:OnCreate(arg)
    countDown = arg.countDown
    self:UpdateTimeText(countDown)
    if IsNil(self.downCountTimer) then
        self.downCountTimer = Scheduler.scheduleGlobal(function()
            countDown = countDown - 1
            self:UpdateTimeText(countDown)
            
            if countDown <= 0 then
                Scheduler.unscheduleGlobal(self.downCountTimer)
                self.downCountTimer = nil
            end
        end, 1)
    end
end

function LYCDismissPanel:SetPlayerUInfo(arg)
    local InfoUITable = {}
    InfoUITable.tran = arg
    InfoUITable.gameObject = arg.gameObject
    InfoUITable.HeadIcon = arg:Find('HeadIcon').gameObject:GetComponent('Image')
    InfoUITable.NameText = arg:Find('NameText').gameObject:GetComponent('Text')
    InfoUITable.Wait = arg:Find('State/Wait').gameObject
    InfoUITable.Sure = arg:Find('State/Sure').gameObject
    return InfoUITable
end

--更新时间Text
function LYCDismissPanel:UpdateTimeText(text)
    if self == nil or text == nil then
        Log("<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>         解散房间更新时间 self 为空")
        return
    end
    self.TextTime.text = text .. "s"
end

--启动事件--
function LYCDismissPanel:OnCreate(arg)
    if not isInit then
        self:InitShowInfo(arg)
        isInit = true
    end
    self:UpdataShowInfo(arg)
end

--初始化显示
function LYCDismissPanel:InitShowInfo(data)
    if dismissPlayers ~= nil then
        for k, v in pairs(dismissPlayers) do
            destroy(v.gameObject)
        end
        dismissPlayers = {}
    end

    UIUtil.SetActive(self.ButtonJuJue, false)
    UIUtil.SetActive(self.ButtonTongYi, false)

    for i = 1, #data.playerList do
        self:CreateGoPlayerItem(data.playerList[i].userId, i)
    end
end

--克隆一个玩家预设体
function LYCDismissPanel:CreateGoPlayerItem(playerId, i)
    local id = tonumber(playerId)
    local playerData = LYCRoomData.GetPlayerDataById(id)
    local name = playerData.name
    local info = dismissPlayers[i]
    if info == nil then
        local Item = CreateGO(self.playerItem, self.ItemList, playerId)
        info = self:SetPlayerUInfo(Item.transform)
        table.insert(dismissPlayers, info)
    end

    info.NameText.text = name
    --设置头像
    Functions.SetHeadImage(info.HeadIcon, Functions.CheckJoinPlayerHeadUrl(playerData.playerHead))

    info.Sure:SetActive(false)
    info.Wait:SetActive(true)
    info.uId = id

    if id == LYCRoomData.mainId then
        UIUtil.SetActive(self.ButtonJuJue, true)
        UIUtil.SetActive(self.ButtonTongYi, true)
    end
    return dismissPlayers[i]
end

--更新显示内容
function LYCDismissPanel:UpdataShowInfo(data)
    local playerInfo = nil
    for i = 1, #data.playerList do
        playerInfo = data.playerList[i]
        for k, v in pairs(dismissPlayers) do
            if v.uId == playerInfo.userId then
                UIUtil.SetActive(v.Sure, playerInfo.status == 1)
                UIUtil.SetActive(v.Wait, playerInfo.status == -1)

                if v.uId == LYCRoomData.mainId and playerInfo.status == 1 then
                    UIUtil.SetActive(self.ButtonJuJue, false)
                    UIUtil.SetActive(self.ButtonTongYi, false)
                end
            end
        end
    end
end

--重连
function LYCDismissPanel:Reconnection(arg)
    if dismissPlayers ~= nil then
        for k, v in pairs(dismissPlayers) do
            destroy(v.gameObject)
        end
        dismissPlayers = {}
    end

    UIUtil.SetActive(self.ButtonJuJue, false)
    UIUtil.SetActive(self.ButtonTongYi, false)
    for i = 1, #arg.list do
        if arg.list[i].uId == LYCRoomData.mainId then
            UIUtil.SetActive(self.ButtonJuJue, true)
            UIUtil.SetActive(self.ButtonTongYi, true)
        end
    end

    for i = 1, #arg.list do
        local playerId = arg.list[i].userId
        local state = arg.list[i].status
        local item = self:CreateGoPlayerItem(playerId, i)
        UIUtil.SetActive(item.Sure, state == 1)
        UIUtil.SetActive(item.Wait, state == 0)

        if playerId == LYCRoomData.mainId and state == 1 then
            UIUtil.SetActive(self.ButtonJuJue, false)
            UIUtil.SetActive(self.ButtonTongYi, false)
        end
    end
end

function LYCDismissPanel.OnClickJuJue()
    if LYCRoomData.roomCode == nil then
        PanelManager.Close(LYCPanelConfig.Dismiss, true)
        return
    end
    LYCApiExtend.SendDissolve(0)
end

function LYCDismissPanel.OnClickTongYi()
    if LYCRoomData.roomCode == nil then
        PanelManager.Close(LYCPanelConfig.Dismiss, true)
        return
    end
    LYCApiExtend.SendDissolve(1)
end

function LYCDismissPanel:OnClosed()
    isInit = false
    countDown = 0
    Scheduler.unscheduleGlobal(self.downCountTimer)
    self.downCountTimer = nil
end

function LYCDismissPanel:OnDestroy()
    dismissPlayers = {}
    isInit = false
end