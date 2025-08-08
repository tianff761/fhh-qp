Pin5WatcherListPanel = ClassPanel("Pin5WatcherListPanel");
local this = Pin5WatcherListPanel

--启动事件--
function Pin5WatcherListPanel:OnInitUI(obj)
    local content = self.transform:Find("Content")
    this.closeBtn = content:Find("Background/CloseBtn").gameObject
    this.itemContent = content:Find("ScrollView/Viewport/Content")
    this.itemPrefab = this.itemContent:Find("Item").gameObject
    this.AddOnClickMsg()
    this.items = {}
end

function Pin5WatcherListPanel:OnOpened(arg)
    SendTcpMsg(Pin5Action.Pin5_CTS_GetWatchPlayerList, {})
    AddEventListener(Pin5Action.Pin5_STC_GetWatchPlayerList, this.OnUpdateWatcherList)
end

function Pin5WatcherListPanel:OnClosed()
    RemoveEventListener(Pin5Action.Pin5_STC_GetWatchPlayerList, this.OnUpdateWatcherList)
end


function Pin5WatcherListPanel.OnUpdateWatcherList(watcherData)

    local users = watcherData.data.users
    local dataLength = #users
    local data = nil
    local item = nil
    for i = 1, dataLength do
        data = users[i]
        item = this.items[i]
        if item == nil then
            item = this.CreateItem(i)
        end
        item.data = data
        item.nameLabel.text = data.userName
        Functions.SetHeadImage(item.headImage, data.iCon)
        UIUtil.SetActive(item.gameObject, true)
    end
    for i = dataLength + 1, #this.items do
        item = this.items[i]
        if item.data ~= nil then
            item.data = nil
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

function Pin5WatcherListPanel.CreateItem(index)
    local item = {}
    item.gameObject = CreateGO(this.itemPrefab, this.itemContent, tostring(index))
    item.transform = item.gameObject.transform
    item.nameLabel = item.transform:Find("Text"):GetComponent(TypeText)
    item.headImage = item.transform:Find("Head/Mask/Icon"):GetComponent(TypeImage)
    table.insert(this.items, item)
    return item
end

function Pin5WatcherListPanel.AddOnClickMsg()
    this:AddOnClick(this.closeBtn, this.OnClose)
end

function Pin5WatcherListPanel.OnClose()
    PanelManager.Close(Pin5PanelConfig.Pin5WatcherList, false)
end
