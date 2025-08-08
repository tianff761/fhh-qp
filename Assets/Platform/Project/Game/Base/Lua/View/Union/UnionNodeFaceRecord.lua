UnionNodeFaceRecord = {}
local this = UnionNodeFaceRecord

local pageItemCount = 4

function UnionNodeFaceRecord.Init(transform)
    this.transform = transform
    this.gameObject = transform.gameObject
    this.isInitUI = false
    this.pageIndex = 1
    this.pageTotal = 1
    this.curPageIdx = 1
end

function UnionNodeFaceRecord.CheckUI()
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

function UnionNodeFaceRecord.Open()
    this.CheckUI()
    this.AddEventListener()
    UnionManager.SendRecordFaceListRequest(1, pageItemCount)
end

function UnionNodeFaceRecord.Close()
    this.RemoveEventListener()
end

------------------------------------------------------------------
--
--注册事件
function UnionNodeFaceRecord.AddEventListener()
    AddMsg(CMD.Tcp.S2C_RecordFaceList, this.ReceiveFaceRecord)
end

--移除事件
function UnionNodeFaceRecord.RemoveEventListener()
    RemoveMsg(CMD.Tcp.S2C_RecordFaceList, this.ReceiveFaceRecord)
end

--UI相关事件
function UnionNodeFaceRecord.AddUIEventListener()
    EventUtil.AddOnClick(this.LastBtn, function()
        local pageIndex = this.curPageIdx - 1
        if this.PageIndexCtrl(pageIndex) then
            UnionManager.SendRecordFaceListRequest(pageIndex, pageItemCount)
        end
    end)
    EventUtil.AddOnClick(this.NextBtn, function()
        local pageIndex = this.curPageIdx + 1
        if this.PageIndexCtrl(pageIndex) then
            UnionManager.SendRecordFaceListRequest(pageIndex, pageItemCount)
        end
    end)
end

--================================================================
--
--

function UnionNodeFaceRecord.OnInvitePartnerBtnClick()
    PanelManager.Open(PanelConfig.UnionInputNumber, UnionInputNumberPanelType.AddPartner, function(num)
        UnionManager.SendAddPartnerMember(num)
        PanelManager.Close(PanelConfig.UnionInputNumber, true)
    end)
end
--
--
function UnionNodeFaceRecord.OnInviteMemberBtnClick()
    PanelManager.Open(PanelConfig.UnionInputNumber, UnionInputNumberPanelType.AddMember, function(num)
        UnionManager.SendAddCommonMember(num)
        PanelManager.Close(PanelConfig.UnionInputNumber, true)
    end)
end

--================================================================
--
-- {"cmd":4204,"code":0,"data":{"yScore":0,"tScore":0,"yNum":0,"tNum":0,"pcount":16,"per":100,"totalScore":869704}}->
function UnionNodeFaceRecord.ReceiveFaceRecord(data)
    --LogError("<color=aqua>ReceiveFaceRecord</color>", data)
    if data.code == 0 then
        local data = data.data
        local list = data.list
        this.pageTotal = data.totalPage
        --LogError("tostring(data.page) .. \"/\" .. tostring(Functions.CheckPageTotal(data.totalPage))", tostring(data.page) .. "/" .. tostring(Functions.CheckPageTotal(data.totalPage)))
        UIUtil.SetText(this.pageNumText, tostring(data.page) .. "/" .. tostring(Functions.CheckPageTotal(data.totalPage)))
        if GetTableSize(list) > 0 then
            local totalCount = data.num
            --local page = this.pages[this.curPageType]
            --UIUtil.SetActive(page, true)
            --UIUtil.SetActive(this.loadingText, false)
            UIUtil.SetActive(this.noDataText, false)
            local listTran = this.ItemList
            local itemData = nil
            local itemTran = nil
            for i = 1, totalCount do
                itemData = list[i]
                itemTran = listTran:Find("Item" .. tostring(i))
                if itemData ~= nil then
                    UIUtil.SetActive(itemTran, true)
                    LogError("itemData", itemData)
                    Functions.SetHeadImage(itemTran:Find("Mask/HeadImg"):GetComponent(TypeImage), itemData.iCon)
                    UIUtil.SetText(itemTran:Find("Num0"), tostring(itemData.name) .. "\nID:" .. itemData.contrib)
                    UIUtil.SetText(itemTran:Find("Num1"), tostring(itemData.roomId))
                    UIUtil.SetText(itemTran:Find("Num2"), tostring(itemData.faceorgin))
                    UIUtil.SetText(itemTran:Find("Num3"), tostring(itemData.face))
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

function UnionNodeFaceRecord.PageIndexCtrl(pageIndex)
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