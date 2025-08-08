UnionPlayerLayerPanel = ClassPanel("UnionPlayerLayerPanel")
local this = UnionPlayerLayerPanel

function UnionPlayerLayerPanel:Awake()
    this = self
    local content = this:Find("Content")

    this.CloseBtn = content:Find("Background/CloseBtn")

    local Page = content:Find("Page")
    this.NextBtn = Page:Find("NextBtn")
    this.LastBtn = Page:Find("LastBtn")
    this.PageLabel = Page:Find("PageText/Text")

    this.ItemContent = content:Find("ItemContent")
    this.Item = content:Find("ItemContent/Item")

    this:AddOnClick(this.CloseBtn, this.OnClickCloseBtn)
    this:AddOnClick(this.NextBtn, this.OnClickNextBtn)
    this:AddOnClick(this.LastBtn, this.OnClickLastBtn)
    this.pageIndex = 1
    this.ItemTable = {}
end

function UnionPlayerLayerPanel:OnOpened(playerItem)
    --LogError("playerItem.playerData.userId", playerItem.playerData.userId)
    this.uid = playerItem.playerData.userId
    UnionManager.SendUpDownPlayersInfoRequest(1, 4, this.uid)
    this.AddEventListener()
end

function UnionPlayerLayerPanel:OnClosed()
    this.RemoveEventListener()
end

function UnionPlayerLayerPanel.PageIndexCtrl(num)
    local result = this.pageIndex + num
    if result > 0 and result <= this.pageTotal then
        this.pageIndex = result
        UnionManager.SendUpDownPlayersInfoRequest(result, 4, this.uid)
    elseif result <= 0 then
        Toast.Show("已在首页")
    elseif result > this.pageTotal then
        Toast.Show("已在尾页")
    end
end

--注册事件
function UnionPlayerLayerPanel.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_UpDownPlayers, this.UpdateUpDownPlayers)
end

--移除事件
function UnionPlayerLayerPanel.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.Union.S2C_UpDownPlayers, this.UpdateUpDownPlayers)
end

function UnionPlayerLayerPanel.UpdateUpDownPlayers(data)
    if data.code == 0 then
        this.ClearItems()
        local info = data.data
        this.pageIndex = info.pageIndex
        this.pageTotal = Functions.CheckPageTotal(info.allPage)
        UIUtil.SetText(this.PageLabel, this.pageIndex .. "/" .. this.pageTotal)
        for i = 1, #info.list do
            local itemData = info.list[i]
            local item = this.GetItem(i)
            item.data = itemData
            UIUtil.SetText(item.name, itemData.userName .. "\n" .. itemData.userId)
            UIUtil.SetText(item.score, tostring(itemData.coin))
            Functions.SetHeadImage(item.HeadImg, itemData.icon)
        end
        UIUtil.SetActive(this.Item, false)
    end
end

function UnionPlayerLayerPanel.GetItem(i)
    if this.ItemTable[i] then
        UIUtil.SetActive(this.ItemTable[i].gameObject, true)
        return this.ItemTable[i]
    else
        local item = {}
        item.gameObject = NewObject(this.Item, this.ItemContent)
        item.transform = item.gameObject.transform
        item.name = item.transform:Find("Index1/Text1")
        item.score = item.transform:Find("Text2")
        item.HeadImg = item.transform:Find("Index1/HeadImg"):GetComponent(TypeImage)
        this.ItemTable[i] = item
        return item
    end
end

function UnionPlayerLayerPanel.ClearItems()
    for i = 1, #this.ItemTable do
        UIUtil.SetActive(this.ItemTable[i].gameObject, false)
    end
end

function UnionPlayerLayerPanel.OnClickNextBtn()
    this.PageIndexCtrl(1)
end

function UnionPlayerLayerPanel.OnClickLastBtn()
    this.PageIndexCtrl(-1)
end

function UnionPlayerLayerPanel.OnClickCloseBtn()
    this:Close()
end
