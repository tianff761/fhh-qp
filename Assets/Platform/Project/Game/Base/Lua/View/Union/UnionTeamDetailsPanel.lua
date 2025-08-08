UnionTeamDetailsPanel = ClassPanel("UnionTeamDetailsPanel")
local this = UnionTeamDetailsPanel

--每页总数
local PageCount = 3

function UnionTeamDetailsPanel:Init()
    this.isSearched = false
    this.searchId = 0
    this.pageIndex = 1
    this.pageTotal = 1

end

function UnionTeamDetailsPanel:OnInitUI()
    this = self
    this:Init()

    this.closeBtn = this:Find("Background/CloseBtn").gameObject

    local node = this:Find("Node")
    this.partnerItem = this.CreateItem(node:Find("PartnerItem").gameObject)

    this.itemContent = node:Find("Content")
    this.itemPrefab = this.itemContent:Find("Item").gameObject

    this.items = {}
    for i = 1, PageCount do
        local item = this.CreateItem(CreateGO(this.itemPrefab, this.itemContent, tostring(i)))
        UIUtil.SetActive(item.gameObject, false)
        table.insert(this.items, item)
    end

    this.lastBtn = node:Find("LastBtn").gameObject
    this.nextBtn = node:Find("NextBtn").gameObject
    this.searchBtn = node:Find("SearchBtn").gameObject
    this.pageLabel = node:Find("Page/Text"):GetComponent(TypeText)
    this.input = node:Find("SearchInputField"):GetComponent(TypeInputField)

    this.loading = node:Find("LoadingText").gameObject
    this.noData = node:Find("NoDataText").gameObject

    this.AddUIEventListener()
end

function UnionTeamDetailsPanel:OnOpened(data)
    this.AddEventListener()
    this.itemData = data
    this.SendRequestList(this.pageIndex)
end

function UnionTeamDetailsPanel:OnClosed()
    this.RemoveEventListener()
    this.isSearched = false
    this.searchId = 0
    this.input.text = ""
    this.pageIndex = 1
    this.pageTotal = 1
end

------------------------------------------------------------------
--
--注册事件
function UnionTeamDetailsPanel.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_Team, this.OnTeam)
end

--移除事件
function UnionTeamDetailsPanel.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.Union.S2C_Team, this.OnTeam)
end

--UI相关事件
function UnionTeamDetailsPanel.AddUIEventListener()
    EventUtil.AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    EventUtil.AddOnClick(this.lastBtn, this.OnLastBtnClick)
    EventUtil.AddOnClick(this.nextBtn, this.OnNextBtnClick)
    EventUtil.AddOnClick(this.searchBtn, this.OnSearchBtnClick)
    this.input.onValueChanged:RemoveAllListeners()
    this.input.onValueChanged:AddListener(this.OnInputFieldValueChanged)
end

--================================================================
--
--关闭
function UnionTeamDetailsPanel.Close()
    PanelManager.Close(PanelConfig.UnionTeamDetails)
end

--创建Item
function UnionTeamDetailsPanel.CreateItem(gameObject)
    local item = {}
    --
    item.gameObject = gameObject
    item.transform = item.gameObject.transform
    item.headIconGo = item.transform:Find("Head/Icon").gameObject
    item.headIcon = item.headIconGo:GetComponent(TypeImage)
    item.nameLabel = item.transform:Find("NameText"):GetComponent(TypeText)
    item.idLabel = item.transform:Find("IdText"):GetComponent(TypeText)
    item.label1 = item.transform:Find("Text1"):GetComponent(TypeText)
    item.label2 = item.transform:Find("Text2"):GetComponent(TypeText)
    item.label3 = item.transform:Find("Text3"):GetComponent(TypeText)
    item.label4 = item.transform:Find("Text4").gameObject
    item.label5 = item.transform:Find("Text5").gameObject
    EventUtil.AddOnClick(item.headIconGo, function()
        this.OnHeadClick(item)
    end)
    UIClickListener.Get(item.label5).onClick = function()
        this.OnRecordClick(item)
    end
    UIClickListener.Get(item.label4).onClick = function()
        this.OnPlayerTeamDetailClick(item)
    end
    return item
end

--================================================================
--

--队伍信息
function UnionTeamDetailsPanel.OnTeam(data)
    if data.code == 0 then
        this.UpdateDataList(data.data)
    end
end

--================================================================
--
--查看个人数据
function UnionTeamDetailsPanel.OnHeadClick(item)
    --if item.data ~= nil then
    --    PanelManager.Open(PanelConfig.UnionScoreManager, item.data.uId or item.data.puserId)
    --end
end

--查看个人记录
function UnionTeamDetailsPanel.OnRecordClick(item)
    if item.data ~= nil then
        if item.data.puserId ~= nil then
            --主玩家
            PanelManager.Open(PanelConfig.UnionGameRecord, item.data.puserId)
        else
            PanelManager.Open(PanelConfig.UnionGameRecord, item.data.uId)
        end
    end
end

---其他玩家的队员详情被点击
function UnionTeamDetailsPanel.OnPlayerTeamDetailClick(item)
    if item.data ~= nil then
        this:OnOpened(item.data)
    end
end

--
function UnionTeamDetailsPanel.OnCloseBtnClick()
    this.Close()
end


--
function UnionTeamDetailsPanel.OnLastBtnClick()
    if this.pageIndex <= 1 then
        Toast.Show("当前已是首页")
    else
        this.SendRequestList(this.pageIndex - 1)
    end
end

--
function UnionTeamDetailsPanel.OnNextBtnClick()
    if this.pageIndex >= this.pageTotal then
        Toast.Show("当前已是尾页")
    else
        this.SendRequestList(this.pageIndex + 1)
    end
end

--
function UnionTeamDetailsPanel.OnSearchBtnClick()
    local text = this.input.text
    if not string.IsNullOrEmpty(text) and string.len(text) == 6 then
        local num = tonumber(text)
        if num ~= nil then
            LockScreen(0.5)
            this.isSearched = true
            this.searchId = num
            this.SendRequestList(1)
        else
            Toast.Show("请输入正确的玩家ID")
        end
    else
        Toast.Show("请输入正确的玩家ID")
    end
end

--监听文本框输入
function UnionTeamDetailsPanel.OnInputFieldValueChanged(text)
    if this.isSearched then
        if string.IsNullOrEmpty(text) then
            this.isSearched = false
            this.searchId = 0
            this.SendRequestList(1)
        end
    end
end



--================================================================
--
--请求数据
function UnionTeamDetailsPanel.SendRequestList(pageIndex)
    UnionManager.SendGetTeam(this.searchId, pageIndex, PageCount, this.itemData.puserId or this.itemData.uId)
end

--
--更新数据
function UnionTeamDetailsPanel.UpdateDataList(data)
    this.pageIndex = data.pageIndex
    this.pageTotal = Functions.CheckPageTotal(data.allPage)
    this.SetPartnerItem(this.partnerItem, data)

    this.pageLabel.text = tostring(this.pageIndex) .. "/" .. tostring(this.pageTotal)
    --
    local list = data.list
    if GetTableSize(list) > 0 then
        UIUtil.SetActive(this.loading, false)
        UIUtil.SetActive(this.noData, false)

        local item = nil
        local itemData = nil
        for i = 1, PageCount do
            itemData = list[i]
            item = this.items[i]
            if itemData ~= nil then
                UIUtil.SetActive(item.gameObject, true)
                this.SetItem(item, itemData)
            else
                if item.data ~= nil then
                    item.data = nil
                    UIUtil.SetActive(item.gameObject, false)
                end
            end
        end
    else
        UIUtil.SetActive(this.loading, false)
        UIUtil.SetActive(this.noData, true)
        local item = nil
        for i = 1, PageCount do
            item = this.items[i]
            if item.data ~= nil then
                item.data = nil
                UIUtil.SetActive(item.gameObject, false)
            end
        end
    end
end

--设置Item数据
function UnionTeamDetailsPanel.SetPartnerItem(item, data)
    item.data = data
    --
    UIUtil.SetActive(item.gameObject, true)
    if item.picon ~= data.picon then
        item.picon = data.picon
        Functions.SetHeadImage(item.headIcon, data.picon)
    end
    item.nameLabel.text = tostring(data.pname)
    item.idLabel.text = "ID:" .. UnionData.GetUidString(data.puserId)

    item.label1.text = data.allbigWin
    item.label2.text = data.allplayCount
    item.label3.text = math.ToRound(data.allsore, 2)
end

--设置Item数据
function UnionTeamDetailsPanel.SetItem(item, data)
    item.data = data
    --
    if item.icon ~= data.icon then
        item.icon = data.icon
        Functions.SetHeadImage(item.headIcon, data.icon)
    end
    item.nameLabel.text = tostring(data.name)
    item.idLabel.text = "ID:" .. UnionData.GetUidString(data.uId)

    item.label1.text = data.bigWinNum
    item.label2.text = data.playNum
    item.label3.text = math.ToRound(data.gain, 2)
end