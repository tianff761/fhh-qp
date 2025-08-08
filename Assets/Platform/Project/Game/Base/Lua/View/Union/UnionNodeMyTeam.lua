UnionNodeMyTeam = {}
local this = UnionNodeMyTeam

--每页总数
local PageCount = 3

--初始化
function UnionNodeMyTeam.Init(transform)
    this.transform = transform
    this.gameObject = transform.gameObject
    this.isInitUI = false

    this.isSearched = false
    this.pageIndex = 1
    this.pageTotal = 1
    this.openCount = 0
end

--检测UI
function UnionNodeMyTeam.CheckUI()
    if this.isInitUI then
        return
    end
    this.isInitUI = true

    this.itemContent = this.transform:Find("Content")
    this.itemPrefab = this.itemContent:Find("Item").gameObject

    this.lastBtn = this.transform:Find("LastBtn").gameObject
    this.nextBtn = this.transform:Find("NextBtn").gameObject
    this.searchBtn = this.transform:Find("SearchBtn").gameObject
    this.pageLabel = this.transform:Find("Page/Text"):GetComponent(TypeText)
    this.input = this.transform:Find("SearchInputField")
    this.inputField = this.input:GetComponent(TypeInputField)

    this.loading = this.transform:Find("LoadingText").gameObject
    this.noData = this.transform:Find("NoDataText").gameObject

    this.AddUIEventListener()
end

function UnionNodeMyTeam.Open()
    this.CheckUI()
    this.AddEventListener()
    if this.openCount == 0 then
        this.SendRequestList(this.pageIndex)
    end
    this.openCount = this.openCount + 1
end

function UnionNodeMyTeam:OnClosed()
    this.RemoveEventListener()
    this.isSearched = false
    this.searchId = 0
    this.inputField.text = ""
    this.pageIndex = 1
    this.pageTotal = 1
end

function UnionNodeMyTeam.Close()
    this:OnClosed()
end

------------------------------------------------------------------
--
--注册事件
function UnionNodeMyTeam.AddEventListener()
    --AddEventListener(CMD.Tcp.Union.S2C_Team, this.OnTeam)
    AddEventListener(CMD.Tcp.Union.S2C_TeamExtra, this.OnTeam)
end

--移除事件
function UnionNodeMyTeam.RemoveEventListener()
    --RemoveEventListener(CMD.Tcp.Union.S2C_Team, this.OnTeam)
    RemoveEventListener(CMD.Tcp.Union.S2C_TeamExtra, this.OnTeam)
end

--UI相关事件
function UnionNodeMyTeam.AddUIEventListener()
    EventUtil.AddOnClick(this.lastBtn, this.OnLastBtnClick)
    EventUtil.AddOnClick(this.nextBtn, this.OnNextBtnClick)
    EventUtil.AddOnClick(this.searchBtn, this.OnSearchBtnClick)
    this.inputField.onValueChanged:RemoveAllListeners()
    this.inputField.onValueChanged:AddListener(this.OnInputFieldValueChanged)
end


--================================================================
--

--队伍信息
function UnionNodeMyTeam.OnTeam(data)
    if data.code == 0 then
        --this.UpdateDataList(data.data)
        this.UpdateNewDataList(data.data)
    else
        UnionManager.ShowError(data.code)
    end
end

--================================================================
--
--查看个人数据
function UnionNodeMyTeam.OnHeadClick(item)
    if item.data ~= nil then
        PanelManager.Open(PanelConfig.UnionPersonalData, item.data.pId, true)
    end
end

--详情按钮
function UnionNodeMyTeam.OnDetailsClick(item)
    PanelManager.Open(PanelConfig.UnionTeamDetails, item.data)
end

--
function UnionNodeMyTeam.OnLastBtnClick()
    if this.pageIndex <= 1 then
        Toast.Show("当前已是首页")
    else
        this.SendRequestList(this.pageIndex - 1)
    end
end

--
function UnionNodeMyTeam.OnNextBtnClick()
    if this.pageIndex >= this.pageTotal then
        Toast.Show("当前已是尾页")
    else
        this.SendRequestList(this.pageIndex + 1)
    end
end

--
function UnionNodeMyTeam.OnSearchBtnClick()
    local text = UIUtil.GetInputText(this.input)
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
function UnionNodeMyTeam.OnInputFieldValueChanged(text)
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
function UnionNodeMyTeam.SendRequestList(pageIndex)
    LogError("this.searchId, pageIndex, PageCount", this.searchId, pageIndex, PageCount)
    UnionManager.SendGetTeamExtra(this.searchId, pageIndex, PageCount)
end

function UnionNodeMyTeam.InitItemObjList(count)
    if this.items then
        for i = 1, #this.items do
            GameObject.Destroy(this.items[i].gameObject)
        end
    end
    this.items = {}
    for i = 1, count do
        local item = {}
        table.insert(this.items, item)
        --
        item.gameObject = CreateGO(this.itemPrefab, this.itemContent, tostring(i))
        item.transform = item.gameObject.transform
        item.headIconGo = item.transform:Find("Head/Icon").gameObject
        item.headIcon = item.headIconGo:GetComponent(TypeImage)
        item.nameLabel = item.transform:Find("NameText"):GetComponent(TypeText)
        item.idLabel = item.transform:Find("IdText"):GetComponent(TypeText)
        item.label1 = item.transform:Find("Text1"):GetComponent(TypeText)
        item.label2 = item.transform:Find("Text2"):GetComponent(TypeText)
        item.label3 = item.transform:Find("Text3"):GetComponent(TypeText)
        item.label4 = item.transform:Find("Text4"):GetComponent(TypeText)
        item.label5Btn = item.transform:Find("Text5/Button").gameObject
        UIUtil.SetActive(item.gameObject, false)

        EventUtil.AddOnClick(item.label5Btn, function() this.OnDetailsClick(item) end)
    end
end

--
--更新数据
function UnionNodeMyTeam.UpdateDataList(data)
    this.pageIndex = data.pageIndex
    this.pageTotal = Functions.CheckPageTotal(data.allPage)

    this.InitItemObjList(1)
    this.SetItem(this.items[1], data)
end

function UnionNodeMyTeam.UpdateNewDataList(data)
    LogError("战队成员", data)
    this.pageIndex = data.pageIndex
    this.pageTotal = Functions.CheckPageTotal(data.allPage)
    this.pageLabel.text = this.pageIndex .. "/" .. this.pageTotal
    this.InitItemObjList(#data.list)
    for i = 1, #data.list do
        this.SetItem(this.items[i], data.list[i])
    end
end

--设置Item数据
function UnionNodeMyTeam.SetItem(item, data)
    item.data = data
    --
    UIUtil.SetActive(item.gameObject, true)
    if item.picon ~= data.picon then
        item.picon = data.picon
        Functions.SetHeadImage(item.headIcon, data.picon)
    end
    item.nameLabel.text = tostring(data.pname)
    item.idLabel.text = "ID:" .. UnionData.GetUidString(data.puserId)

    item.label1.text = data.playerCount
    item.label2.text = data.allplayCount
    item.label3.text = data.allbigWin
    item.label4.text = math.ToRound(data.allsore, 2)
end