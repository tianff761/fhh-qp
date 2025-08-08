Pin5DismissPanel = ClassPanel("Pin5DismissPanel")
local this = Pin5DismissPanel

local isInit = false
local dismissPlayers = {}
local countDown = 0
--初始化面板--
function Pin5DismissPanel:OnInitUI()
    self:InitPanel()
    self:AddMsg()
end

function Pin5DismissPanel:InitPanel()
    local transform = self.transform
    local content = transform:Find("Content")
    local panelContent = content:Find("Node")

    self.ButtonJuJue = panelContent:Find('ButtonJuJue').gameObject -- 拒绝按钮
    self.ButtonTongYi = panelContent:Find('ButtonTongYi').gameObject -- 同意按钮
    self.TextPlayerName = panelContent:Find('TextPlayerName').gameObject:GetComponent('Text')
    self.TextTime = panelContent:Find('TextTime').gameObject:GetComponent('Text')
    self.ItemList = panelContent:Find('ScrollView/Viewport/Content').gameObject.transform
    self.playerItem = self.ItemList:Find('Item').gameObject

    local spriteAtlasImages = panelContent:Find("StateAtlas"):GetComponent("UISpriteAtlas").sprites:ToTable()
    this.stateImages = {}
    for i = 1, #spriteAtlasImages do
        this.stateImages[spriteAtlasImages[i].name] = spriteAtlasImages[i]
    end
end

function Pin5DismissPanel:AddMsg()
    self:AddOnClick(self.ButtonJuJue, this.OnClickJuJue)
    self:AddOnClick(self.ButtonTongYi, this.OnClickTongYi)
end

function Pin5DismissPanel:OnOpened(arg)
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

function Pin5DismissPanel:SetPlayerUInfo(arg)
    local InfoUITable = {}
    InfoUITable.tran = arg
    InfoUITable.gameObject = arg.gameObject
    
    InfoUITable.StateFrame = arg:Find('StateFrame').gameObject:GetComponent('Image')
    InfoUITable.HeadIcon = arg:Find('HeadMask/HeadIcon').gameObject:GetComponent('Image')
    InfoUITable.NameText = arg:Find('NameText').gameObject:GetComponent('Text')

    -- InfoUITable.Wait = arg:Find('State/Wait').gameObject
    -- InfoUITable.Sure = arg:Find('State/Sure').gameObject
    return InfoUITable
end

--更新时间Text
function Pin5DismissPanel:UpdateTimeText(text)
    if self == nil or text == nil then
        Log("<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>         解散房间更新时间 self 为空")
        return
    end
    self.TextTime.text = text .. "s"
end

--启动事件--
function Pin5DismissPanel:OnCreate(arg)
    if not isInit then
        self:InitShowInfo(arg)
        isInit = true
    end
    self:UpdataShowInfo(arg)
end

--初始化显示
function Pin5DismissPanel:InitShowInfo(data)
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
function Pin5DismissPanel:CreateGoPlayerItem(playerId, i)
    local id = tonumber(playerId)
    local playerData = Pin5RoomData.GetPlayerDataById(id)
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

    -- info.Sure:SetActive(false)
    -- info.Wait:SetActive(true)
    info.uId = id

    if id == Pin5RoomData.mainId then
        UIUtil.SetActive(self.ButtonJuJue, true)
        UIUtil.SetActive(self.ButtonTongYi, true)
    end
    return dismissPlayers[i]
end

--更新显示内容
function Pin5DismissPanel:UpdataShowInfo(data)
    local playerInfo = nil
    local stateFrameIndex = 0
    for i = 1, #data.playerList do
        playerInfo = data.playerList[i]
        for k, v in pairs(dismissPlayers) do
            if v.uId == playerInfo.userId then
                -- UIUtil.SetActive(v.Sure, playerInfo.status == 1)
                -- UIUtil.SetActive(v.Wait, playerInfo.status == -1)

                if playerInfo.status == 1 then --同意解散
                    stateFrameIndex = 2
                elseif playerInfo.status == 2 then --拒绝解散
                    stateFrameIndex = 3
                else --选择中
                    stateFrameIndex = 4
                end
                v.StateFrame.sprite = this.stateImages["ui_jsfj_diban_"..stateFrameIndex]

                if v.uId == Pin5RoomData.mainId and playerInfo.status == 1 then
                    UIUtil.SetActive(self.ButtonJuJue, false)
                    UIUtil.SetActive(self.ButtonTongYi, false)
                end
            end
        end
    end
end

--重连
function Pin5DismissPanel:Reconnection(arg)
    if dismissPlayers ~= nil then
        for k, v in pairs(dismissPlayers) do
            destroy(v.gameObject)
        end
        dismissPlayers = {}
    end

    UIUtil.SetActive(self.ButtonJuJue, false)
    UIUtil.SetActive(self.ButtonTongYi, false)
    for i = 1, #arg.list do
        if arg.list[i].uId == Pin5RoomData.mainId then
            UIUtil.SetActive(self.ButtonJuJue, true)
            UIUtil.SetActive(self.ButtonTongYi, true)
        end
    end

    local stateFrameIndex = 0
    for i = 1, #arg.list do
        local playerId = arg.list[i].userId
        local state = arg.list[i].status
        local item = self:CreateGoPlayerItem(playerId, i)

        if state == 1 then --同意解散
            stateFrameIndex = 2
        elseif state == 2 then --拒绝解散
            stateFrameIndex = 3
        else --选择中
            stateFrameIndex = 4
        end
        item.StateFrame.sprite = this.stateImages["ui_jsfj_diban_"..stateFrameIndex]

        -- UIUtil.SetActive(item.Sure, state == 1)
        -- UIUtil.SetActive(item.Wait, state == 0)

        if playerId == Pin5RoomData.mainId and state == 1 then
            UIUtil.SetActive(self.ButtonJuJue, false)
            UIUtil.SetActive(self.ButtonTongYi, false)
        end
    end
end

function Pin5DismissPanel.OnClickJuJue()
    if Pin5RoomData.roomCode == nil then
        PanelManager.Close(Pin5PanelConfig.Dismiss, true)
        return
    end
    Pin5ApiExtend.SendDissolve(0)
end

function Pin5DismissPanel.OnClickTongYi()
    if Pin5RoomData.roomCode == nil then
        PanelManager.Close(Pin5PanelConfig.Dismiss, true)
        return
    end
    Pin5ApiExtend.SendDissolve(1)
end

function Pin5DismissPanel:OnClosed()
    isInit = false
    countDown = 0
    Scheduler.unscheduleGlobal(self.downCountTimer)
    self.downCountTimer = nil
end

function Pin5DismissPanel:OnDestroy()
    dismissPlayers = {}
    isInit = false
end