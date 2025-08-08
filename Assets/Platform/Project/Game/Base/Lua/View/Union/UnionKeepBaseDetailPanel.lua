UnionKeepBaseDetailPanel = ClassPanel("UnionKeepBaseDetailPanel")
local this = UnionKeepBaseDetailPanel

function UnionKeepBaseDetailPanel:Awake()
    this = self
    local content = this:Find("Content")

    this.CloseBtn = content:Find("Background/CloseBtn")

    local Page = content:Find("Page")
    this.NextBtn = Page:Find("NextBtn")
    this.LastBtn = Page:Find("LastBtn")
    this.PageLabel = Page:Find("PageText/Text")

    this.ItemContent = content:Find("ItemContent")
    this.NilData = content:Find("NoDataText")
    this.Item = content:Find("ItemContent/Item")

    this:AddOnClick(this.CloseBtn, this.OnClickCloseBtn)
    this:AddOnClick(this.NextBtn, this.OnClickNextBtn)
    this:AddOnClick(this.LastBtn, this.OnClickLastBtn)
    this.pageIndex = 1
    this.ItemTable = {}
end

function UnionKeepBaseDetailPanel:OnOpened(mid)
    --LogError("mid", mid)
    this.mid = mid
    UnionManager.SendRequestKeepBaseDetail(mid, 4, 1)
    this.AddEventListener()
end

function UnionKeepBaseDetailPanel:OnClosed()
    this.RemoveEventListener()
end

function UnionKeepBaseDetailPanel.PageIndexCtrl(num)
    local result = this.pageIndex + num
    if result > 0 and result <= this.pageTotal then
        this.pageIndex = result
        UnionManager.SendRequestKeepBaseDetail(this.mid, 4, result)
    elseif result <= 0 then
        Toast.Show("已在首页")
    elseif result > this.pageTotal then
        Toast.Show("已在尾页")
    end
end

--注册事件
function UnionKeepBaseDetailPanel.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_Request_KeepBaseDetail, this.UpdateKeepBaseDetail)
end

--移除事件
function UnionKeepBaseDetailPanel.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.Union.S2C_Request_KeepBaseDetail, this.UpdateKeepBaseDetail)
end

---9504 返回查询详情结果
---@field allPage number 总页数
---@field num number 每页数量
---@field pageIndex number 当前页数
---@field list table 数据列表
---@field userId number 玩家id(list内)
---@field var number 玩家过期数量(list内)
---@field nick number 昵称(list内)
---@field time number 时间(list内)
function UnionKeepBaseDetailPanel.UpdateKeepBaseDetail(data)
    if data.code == 0 then
        this.ClearItems()
        local info = data.data
        this.pageIndex = info.pageIndex
        this.pageTotal = Functions.CheckPageTotal(info.allPage)
        UIUtil.SetText(this.PageLabel, this.pageIndex .. "/" .. this.pageTotal)
        UIUtil.SetActive(this.NilData, #info.list == 0)
        for i = 1, #info.list do
            local itemData = info.list[i]
            local item = this.GetItem(i)
            item.data = itemData
            UIUtil.SetText(item.name, itemData.nick .. "\nID:" .. itemData.userId)
            UIUtil.SetText(item.score, tostring(itemData.var))
            UIUtil.SetText(item.time, Functions.GetDateByTimeStamp(itemData.time))
        end
        UIUtil.SetActive(this.Item, false)
    end
end

function UnionKeepBaseDetailPanel.GetItem(i)
    if this.ItemTable[i] then
        UIUtil.SetActive(this.ItemTable[i].gameObject, true)
        return this.ItemTable[i]
    else
        local item = {}
        item.gameObject = NewObject(this.Item, this.ItemContent)
        item.transform = item.gameObject.transform
        item.name = item.transform:Find("Text1")
        item.score = item.transform:Find("Text2")
        item.time = item.transform:Find("Text3")
        this.ItemTable[i] = item
        return item
    end
end

function UnionKeepBaseDetailPanel.ClearItems()
    for i = 1, #this.ItemTable do
        UIUtil.SetActive(this.ItemTable[i].gameObject, false)
    end
end

function UnionKeepBaseDetailPanel.OnClickNextBtn()
    this.PageIndexCtrl(1)
end

function UnionKeepBaseDetailPanel.OnClickLastBtn()
    this.PageIndexCtrl(-1)
end

function UnionKeepBaseDetailPanel.OnClickCloseBtn()
    this:Close()
end
