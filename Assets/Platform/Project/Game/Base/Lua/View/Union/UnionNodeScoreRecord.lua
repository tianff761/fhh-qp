UnionNodeScoreRecord = {}
local this = UnionNodeScoreRecord

--每页总数
local PageCount = 3

local TypeNameSelf = "自己"
local TypeNamePartner = "队长"
local TypeNameMemeber = "成员"
local TypeNameLeader = "盟主"

function UnionNodeScoreRecord.Init(transform)
    this.transform = transform
    this.gameObject = transform.gameObject
    this.isInitUI = false

    this.pageIndex = 1
    this.pageTotal = 1
end

function UnionNodeScoreRecord.CheckUI()
    if this.isInitUI then
        return
    end
    this.isInitUI = true

    this.itemContent = this.transform:Find("ScrollView/Viewport/Content")
    this.itemPrefab = this.itemContent:Find("Item").gameObject

    this.items = {}
    for i = 1, PageCount do
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
        UIUtil.SetActive(item.gameObject, false)
    end
    UIUtil.SetActive(this.itemPrefab, false)

    local page = this.transform:Find("Bottom/Page")
    this.lastBtn = page:Find("LastBtn").gameObject
    this.nextBtn = page:Find("NextBtn").gameObject
    this.pageLabel = page:Find("PageText/Text"):GetComponent(TypeText)

    this.searchBtn = this.transform:Find("Bottom/SearchBtn").gameObject
    this.SearchInputField = this.transform:Find("Bottom/SearchInput")

    this.loading = this.transform:Find("LoadingText").gameObject
    this.noData = this.transform:Find("NoDataText").gameObject

    this.AddUIEventListener()
end

function UnionNodeScoreRecord.Open()
    this.userId = UserData.GetUserId()
    this.CheckUI()
    this.AddEventListener()
    this.isSearched = false
    this.SendRequestList(this.pageIndex)
end

function UnionNodeScoreRecord.Close()
    this.RemoveEventListener()
    this.pageIndex = 1
    this.pageTotal = 1
end

------------------------------------------------------------------
--
--注册事件
function UnionNodeScoreRecord.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_Union_ScoreChange, this.OnScoreChangeRecord)
end

--移除事件
function UnionNodeScoreRecord.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.Union.S2C_Union_ScoreChange, this.OnScoreChangeRecord)
end

--UI相关事件
function UnionNodeScoreRecord.AddUIEventListener()
    EventUtil.AddOnClick(this.lastBtn, this.OnLastBtnClick)
    EventUtil.AddOnClick(this.nextBtn, this.OnNextBtnClick)
    EventUtil.AddOnClick(this.searchBtn, this.OnSearchBtnClick)
end


--================================================================
--
function UnionNodeScoreRecord.OnLastBtnClick()
    if this.pageIndex <= 1 then
        Toast.Show("当前已是首页")
    else
        this.GetSearchString()
        this.RequestScoreChangeList(this.pageIndex - 1, this.SearchString)
    end
end

--
function UnionNodeScoreRecord.OnNextBtnClick()
    if this.pageIndex >= this.pageTotal then
        Toast.Show("当前已是尾页")
    else
        this.GetSearchString()
        this.RequestScoreChangeList(this.pageIndex + 1, this.SearchString)
    end
end

function UnionNodeScoreRecord.GetSearchString()
    this.SearchString = UIUtil.GetInputText(this.SearchInputField) or ""
end

function UnionNodeScoreRecord.OnSearchBtnClick()
    this.GetSearchString()
    LockScreen(0.5)
    this.RequestScoreChangeList(1, this.SearchString)
end

function UnionNodeScoreRecord.RequestScoreChangeList(pageIndex, searchString)
    if string.IsNullOrEmpty(searchString) then
        UnionManager.SendGetScoreChangeList(0, pageIndex, PageCount)
    else
        UnionManager.SendGetScoreChangeList(0, pageIndex, PageCount, nil, searchString)
    end
end

--================================================================
--
--
function UnionNodeScoreRecord.OnScoreChangeRecord(data)
    if data.code == 0 then
        this.UpdateDataList(data.data)
    else
        UnionManager.ShowError(data.code)
    end
end


--================================================================
--
--请求数据
function UnionNodeScoreRecord.SendRequestList(pageIndex)
    UnionManager.SendGetScoreChangeList(0, pageIndex, PageCount)
end

--
--更新数据
function UnionNodeScoreRecord.UpdateDataList(data)
    this.pageIndex = data.pageIndex
    this.pageTotal = Functions.CheckPageTotal(data.allPage)
    this.pageLabel.text = tostring(this.pageIndex) .. "/" .. tostring(this.pageTotal)
    --
    local list = data.list
    LogError("<color=aqua>list</color>", list)
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
                UIUtil.SetActive(item.gameObject, false)

                --if item.data ~= nil then
                --    item.data = nil
                --end
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
--userName 修改人的名字，uId修改人的ID，userName2被修改人的名字，uId2被修改人的ID，time时间，num数目，icon 被修改人头像，aType被修改人的权限
function UnionNodeScoreRecord.SetItem(item, data)
    item.data = data
    --
    if item.icon ~= data.icon then
        item.icon = data.icon
        Functions.SetHeadImage(item.headIcon, data.icon)
    end
    item.nameLabel.text = data.userName2
    item.idLabel.text = "ID:" .. data.uId2

    local temp = 0
    if data.num > 0 then
        temp = "+" .. data.num
    else
        temp = tostring(data.num)
    end
    item.label1.text = temp

    local typeStr = nil
    if data.uId2 == this.userId then
        typeStr = TypeNameSelf
    else
        if data.aType == UnionRole.Leader then
            typeStr = TypeNameLeader
        elseif data.aType == UnionRole.Partner then
            typeStr = TypeNamePartner
        else
            typeStr = TypeNameMemeber
        end
    end
    item.label2.text = data.userName .. "\n" .. Functions.GetUserIdString(data.uId)
    item.label3.text = UnionRoleName[data.bType]
    item.label4.text = os.date("%Y-%m-%d %H:%M:%S", tonumber(data.time) / 1000)
end