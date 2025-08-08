UnionNodeLuckyValueRecord = {}
local this = UnionNodeLuckyValueRecord

local pageItemCount = 4

function UnionNodeLuckyValueRecord.Init(transform)
    this.transform = transform
    this.gameObject = transform.gameObject
    this.isInitUI = false
    this.pageIndex = 1
    this.pageTotal = 1
    this.curPageIdx = 1
end

function UnionNodeLuckyValueRecord.CheckUI()
    if this.isInitUI then
        return
    end
    this.isInitUI = true

    this.Content = this.transform:Find("Content")
    local page = this.Content:Find("Page")
    this.LastBtn = page:Find("LastBtn")
    this.NextBtn = page:Find("NextBtn")
    this.pageNumText = page:Find("PageText/Text")
    this.loadingText = this.Content:Find("LoadingText")
    this.noDataText = this.Content:Find("NoDataText")
    this.ItemList = this.Content:Find("List")

    this.AddUIEventListener()
end

function UnionNodeLuckyValueRecord.Open()
    this.CheckUI()
    this.AddEventListener()
    UnionManager.SendLuckyValueRecordRequest(pageItemCount, 1)
end

function UnionNodeLuckyValueRecord.Close()
    this.RemoveEventListener()
end

------------------------------------------------------------------
--
--注册事件
function UnionNodeLuckyValueRecord.AddEventListener()
    AddMsg(CMD.Tcp.S2C_GetLuckyValueRecord, this.UpdatePutAndGetRecordList)
end

--移除事件
function UnionNodeLuckyValueRecord.RemoveEventListener()
    RemoveMsg(CMD.Tcp.S2C_GetLuckyValueRecord, this.UpdatePutAndGetRecordList)
end

--UI相关事件
function UnionNodeLuckyValueRecord.AddUIEventListener()
    EventUtil.AddOnClick(this.LastBtn, function()
        local pageIndex = this.curPageIdx - 1
        if this.PageIndexCtrl(pageIndex) then
            UnionManager.SendLuckyValueRecordRequest(pageItemCount, pageIndex)
        end
    end)
    EventUtil.AddOnClick(this.NextBtn, function()
        local pageIndex = this.curPageIdx + 1
        if this.PageIndexCtrl(pageIndex) then
            UnionManager.SendLuckyValueRecordRequest(pageItemCount, pageIndex)
        end
    end)
end

--
-- {"cmd":4204,"code":0,"data":{"yScore":0,"tScore":0,"yNum":0,"tNum":0,"pcount":16,"per":100,"totalScore":869704}}->
function UnionNodeLuckyValueRecord.UpdatePutAndGetRecordList(data)
    if data.code == 0 then
        local data = data.data
        local list = data.list
        this.pageTotal = data.totalPage
        UIUtil.SetText(this.pageNumText, tostring(data.pageIndex) .. "/" .. tostring(Functions.CheckPageTotal(data.allPage)))
        --Log("..........UpdatePutAndGetRecordList", this.pageNumText)
        if GetTableSize(list) > 0 then
            local totalCount = 8
            UIUtil.SetActive(this.noDataText, false)
            local listTran = this.ItemList
            local itemData = nil
            local itemTran = nil
            for i = 1, totalCount do
                itemData = list[i]
                itemTran = listTran:Find("Item" .. tostring(i))
                if itemData ~= nil then
                    UIUtil.SetActive(itemTran, true)
                    UIUtil.SetText(itemTran:Find("Num1"), tostring(itemData.luckyPool))
                    UIUtil.SetText(itemTran:Find("Num2"), tostring(itemData.accessNum))
                    UIUtil.SetText(itemTran:Find("Num3"), Functions.TernaryOperator(itemData.accessType == 1, "存入", "取出"))
                    UIUtil.SetText(itemTran:Find("Num4"), os.date("%Y-%m-%d %H:%M", itemData.time / 1000))
                else
                    UIUtil.SetActive(itemTran, false)
                end
            end
        else
            UIUtil.SetActive(this.loadingText, false)
            UIUtil.SetActive(this.noDataText, true)
        end
    else
        LuckyValueError.ShowError(data.code)
    end
end

function UnionNodeLuckyValueRecord.PageIndexCtrl(pageIndex)
    if pageIndex < 1 then
        Toast.Show("当前已是首页")
        return
    elseif this.pageTotal and pageIndex > this.pageTotal then
        Toast.Show("当前已是尾页")
        return
    end
    this.curPageIdx = pageIndex
    return pageIndex
end