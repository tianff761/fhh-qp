UnionKeepBasePopPanel = ClassPanel("UnionKeepBasePopPanel")
local this = UnionKeepBasePopPanel

--显示配置
local DisplayConfigs = {
    [GameType.Mahjong] = { isOn = true },
    [GameType.ErQiShi] = { isOn = false },
    [GameType.PaoDeKuai] = { isOn = true },
    [GameType.Pin5] = { isOn = true },
    [GameType.Pin3] = { isOn = true },
    [GameType.SDB] = { isOn = false },
    [GameType.LYC] = { isOn = true },
}

function UnionKeepBasePopPanel:Awake()
    this = self
    local content = this:Find("Content")

    this.CloseBtn = content:Find("Background/CloseBtn")

    this.GameItem = content:Find("Games/GameItem")
    this.ItemTable = {}
    this:AddOnClick(this.CloseBtn, this.OnClickCloseBtn)
end

function UnionKeepBasePopPanel:OnOpened()
    UnionManager.SendRequestKeepBasePercent(UserData.userId)
    this.AddEventListener()
end

function UnionKeepBasePopPanel:OnClosed()
    this.RemoveEventListener()
end

--注册事件
function UnionKeepBasePopPanel.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_RequestKeepBasePercent, this.OnTcpRequestKeepBase)
end

--移除事件
function UnionKeepBasePopPanel.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.Union.S2C_RequestKeepBasePercent, this.OnTcpRequestKeepBase)
end

function UnionKeepBasePopPanel.OnTcpRequestKeepBase(data)
    this.ClearItems()
    if data.code == 0 then
        local playerInfos = data.data.list
        local data = nil
        local config = nil
        local index = 0
        for i = 1, #playerInfos do
            data = playerInfos[i]
            config = DisplayConfigs[data.gameId]
            if config ~= nil and config.isOn then
                index = index + 1
                local item = this.GetItem(index)
                UIUtil.SetText(item.name, GameConfig[data.gameId].Text .. ":")
                UIUtil.SetText(item.ratio, data.per .. "%")
            end
        end
        UIUtil.SetActive(this.GameItem, false)
    else
        UnionManager.ShowError(data.code)
    end
end

function UnionKeepBasePopPanel.GetItem(i)
    if this.ItemTable[i] then
        UIUtil.SetActive(this.ItemTable[i].gameObject, true)
        return this.ItemTable[i]
    else
        local item = {}
        item.gameObject = NewObject(this.GameItem, this.GameItem.parent)
        item.transform = item.gameObject.transform
        item.name = item.transform:Find("Name")
        item.ratio = item.name:Find("Ratio")
        this.ItemTable[i] = item
        UIUtil.SetActive(item.gameObject, true)
        return item
    end
end

function UnionKeepBasePopPanel.ClearItems()
    for i = 1, #this.ItemTable do
        UIUtil.SetActive(this.ItemTable[i].gameObject, false)
    end
end

function UnionKeepBasePopPanel.OnClickCloseBtn()
    this:Close()
end
