SDBDismissPanel = ClassPanel("SDBDismissPanel")
local this = SDBDismissPanel

local isInit = false
local dismissPlayers = {}

--初始化面板--
function SDBDismissPanel:OnInitUI()
    self:InitPanel()
    self:AddMsg()
end

function SDBDismissPanel:InitPanel()
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

function SDBDismissPanel:AddMsg()
    self:AddOnClick(self.ButtonJuJue, this.OnClickJuJue)
    self:AddOnClick(self.ButtonTongYi, this.OnClickTongYi)
end

function SDBDismissPanel:OnOpened(arg)
    self:OnCreate(arg)

    local curTime  = self.TextTime.text
    if curTime == "" or curTime == nil then
        self:UpdateTimeText(arg.maxTime)
    end
end

function SDBDismissPanel:SetPlayerUInfo(arg)
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
function SDBDismissPanel:UpdateTimeText(text)
    if self == nil or text == nil then
        Log("<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>         解散房间更新时间 self 为空")
        return
    end
    self.TextTime.text = text .. "s"
end

--启动事件--
function SDBDismissPanel:OnCreate(arg)
    if not isInit then
        --1 正常初始化
        if arg.type == 2 then
            self:InitShowInfo(arg)
        else --2 重连
            self:Reconnection(arg) 
        end
        isInit = true
    end
    --1 正常更新
    if arg.type == 2 then
        self:UpdataShowInfo(arg)
    end
end

--初始化显示
function SDBDismissPanel:InitShowInfo(data)
    if dismissPlayers ~= nil then
        for k,v in pairs(dismissPlayers) do
            destroy(v.gameObject)
        end
        dismissPlayers = {}
    end

    UIUtil.SetActive(self.ButtonJuJue, false)
    UIUtil.SetActive(self.ButtonTongYi, false)

    local operationPlayerIds = string.split(data.oprIds, ",")
    for i = 1, #operationPlayerIds do
        self:CreateGoPlayerItem(operationPlayerIds[i],i)
    end
end

--克隆一个玩家预设体
function SDBDismissPanel:CreateGoPlayerItem(playerId,i)
    local id = tonumber(playerId)
    local playerData = SDBRoomData.GetPlayerDataById(id)
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

    if id == SDBRoomData.mainId then
        UIUtil.SetActive(self.ButtonJuJue, true)
        UIUtil.SetActive(self.ButtonTongYi, true)
    end
    return dismissPlayers[i]
end

--更新显示内容
function SDBDismissPanel:UpdataShowInfo(data)
    for k, v in pairs(dismissPlayers) do
        if v.uId == data.uId then
            UIUtil.SetActive(v.Sure, data.state == 1)
            UIUtil.SetActive(v.Wait, data.state == 0)

            if v.uId == SDBRoomData.mainId and data.state == 1 then
                UIUtil.SetActive(self.ButtonJuJue, false)
                UIUtil.SetActive(self.ButtonTongYi, false)
            end
        end
    end
end

--重连
function SDBDismissPanel:Reconnection(arg)
    if dismissPlayers ~= nil then
        for k,v in pairs(dismissPlayers) do
            destroy(v.gameObject)
        end
        dismissPlayers = {}
    end

    UIUtil.SetActive(self.ButtonJuJue, false)
    UIUtil.SetActive(self.ButtonTongYi, false)
    for i=1,#arg.list do
        if arg.list[i].uId == SDBRoomData.mainId then
            UIUtil.SetActive(self.ButtonJuJue, true)
            UIUtil.SetActive(self.ButtonTongYi, true)
        end
    end
    
    for i = 1, #arg.list do
        local playerId = arg.list[i].uId
        local state = arg.list[i].state
        local item = self:CreateGoPlayerItem(playerId, i)
        UIUtil.SetActive(item.Sure, state == 1)
        UIUtil.SetActive(item.Wait, state == 0)

        if playerId == SDBRoomData.mainId and state == 1 then
            UIUtil.SetActive(self.ButtonJuJue, false)
            UIUtil.SetActive(self.ButtonTongYi, false)
        end
    end
end

function SDBDismissPanel.OnClickJuJue()

    if SDBRoomData.roomCode == nil then
        PanelManager.Close(SDBPanelConfig.Dismiss,true)
        return
    end
    SDBApiExtend.SendOperateDissolve(2)
end

function SDBDismissPanel.OnClickTongYi()

    if SDBRoomData.roomCode == nil then
        PanelManager.Close(SDBPanelConfig.Dismiss,true)
        return
    end
    SDBApiExtend.SendOperateDissolve(1)
end

function SDBDismissPanel:OnClosed()
    isInit = false
end

function SDBDismissPanel:OnDestroy()
    dismissPlayers = {}
    isInit = false
end
