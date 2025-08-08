LYCWatcherListPanel = ClassPanel("LYCWatcherListPanel");
local this = LYCWatcherListPanel

--启动事件--
function LYCWatcherListPanel:OnInitUI(obj)
    local content = self.transform:Find("Content")
    this.closeBtn = content:Find("Background/CloseBtn").gameObject
    this.itemContent = content:Find("ScrollView/Viewport/Content")
    this.PlayerItem = this.itemContent:Find("Item")
    this.AddOnClickMsg()
    this.PlayerItemList = {}
end

function LYCWatcherListPanel:OnOpened(arg)
    SendTcpMsg(LYCAction.LYC_CTS_GetWatchPlayerList, {})
    AddEventListener(LYCAction.LYC_STC_GetWatchPlayerList, this.UpdateWatcherList)
end

function LYCWatcherListPanel.UpdateWatcherList(watcherData)
    LogError("watcherData", watcherData)
    local users = watcherData.data.users
    for i = 1, #users do
        local userInfo = users[i]
        local playerItem = this.GetPlayerItem(i)
        local playerName = playerItem:Find("Text")
        UIUtil.SetText(playerName, userInfo.userName)
        local playerHeadImg = playerItem:Find("Head/Mask/Icon"):GetComponent(TypeImage)
        Functions.SetHeadImage(playerHeadImg, userInfo.iCon)
        UIUtil.SetActive(playerItem, true)
        table.insert(this.PlayerItemList, playerItem)
    end
    UIUtil.SetActive(this.PlayerItem, false)
end

function LYCWatcherListPanel.GetPlayerItem(index)
    if this.PlayerItemList[index] then
        return this.PlayerItemList[index]
    else
        return NewObject(this.PlayerItem, this.itemContent)
    end
end

function LYCWatcherListPanel.AddOnClickMsg()
    this:AddOnClick(this.closeBtn, this.OnClose)
end

function LYCWatcherListPanel.OnClose()
    for i = 1, #this.PlayerItemList do
        UIUtil.SetActive(this.PlayerItemList[i], false)
    end
    PanelManager.Close(LYCPanelConfig.LYCWatcherList, false)
end