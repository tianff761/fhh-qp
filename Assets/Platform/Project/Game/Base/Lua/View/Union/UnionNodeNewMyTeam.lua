UnionNodeNewMyTeam = {}
local this = UnionNodeNewMyTeam

--每页总数
local PageCount = 3

--初始化
function UnionNodeNewMyTeam.Init(transform)
    this.transform = transform
    this.gameObject = transform.gameObject
    this.isInitUI = false

    this.pageIndex = 1
    this.pageTotal = 1
    LogError("set this.pageTotal = 1")
    this.openCount = 0

    this.upIcon = nil
    this.upName = nil
    this.upId = nil
    this.upIconChanged = false


    this.title = this.transform:Find("Title")
    this.ScoreSortImg = this.title:Find("2/Image")
    this.RoundCountSortImg = this.title:Find("3/Image")
    this.MarkSortImg = this.title:Find("4/Image")
    this.TeamScoreSortImg = this.title:Find("5/Image")
    this.SortImgArr = {}
    table.insert(this.SortImgArr, this.ScoreSortImg)
    table.insert(this.SortImgArr, this.RoundCountSortImg)
    table.insert(this.SortImgArr, this.MarkSortImg)
    table.insert(this.SortImgArr, this.TeamScoreSortImg)
end

--检测UI
function UnionNodeNewMyTeam.CheckUI()
    if this.isInitUI then
        return
    end
    this.isInitUI = true

    this.itemContent = this.transform:Find("ScrollView/Viewport/Content")
    this.itemPrefab = this.itemContent:Find("Item").gameObject

    local page = this.transform:Find("Bottom/Page")
    this.lastBtn = page:Find("LastBtn").gameObject
    this.nextBtn = page:Find("NextBtn").gameObject
    this.pageLabel = page:Find("PageText/Text"):GetComponent(TypeText)

    this.searchBtn = this.transform:Find("Bottom/SearchBtn").gameObject
    this.input = this.transform:Find("Bottom/SearchInput")

    this.loading = this.transform:Find("LoadingText").gameObject
    this.noData = this.transform:Find("NoDataText").gameObject

    this.ScoreSortBtn = this.title:Find("2/Button")
    this.RoundCountSortBtn = this.title:Find("3/Button")
    this.MarkSortBtn = this.title:Find("4/Button")
    this.TeamScoreSortBtn = this.title:Find("5/Button")

    this.AddUIEventListener()
end

function UnionNodeNewMyTeam.Open()
    this.SortStateData = {
        0,
        0,
        1,
        0,
    }
    this.CheckUI()
    this.AddEventListener()
    this.SortDescHandler(2)
    this.SendRequestList(this.pageIndex)
    LogError("<color=aqua>this.ScoreSortBtn</color>", this.ScoreSortBtn)
end

function UnionNodeNewMyTeam.Close()
    this.RemoveEventListener()
    this.SearchField = ""
    UIUtil.SetInputText(this.input, "")
    this.pageIndex = 1
    --this.pageTotal = 1
end

------------------------------------------------------------------
--
--注册事件
function UnionNodeNewMyTeam.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_UNION_DOWN_DETAILS, this.OnTeam)
end

--移除事件
function UnionNodeNewMyTeam.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.Union.S2C_UNION_DOWN_DETAILS, this.OnTeam)
end

--UI相关事件
function UnionNodeNewMyTeam.AddUIEventListener()
    EventUtil.AddOnClick(this.lastBtn, this.OnLastBtnClick)
    EventUtil.AddOnClick(this.nextBtn, this.OnNextBtnClick)
    EventUtil.AddOnClick(this.searchBtn, this.OnSearchBtnClick)
    EventUtil.AddOnClick(this.ScoreSortBtn, this.OnScoreSortBtnClick)
    EventUtil.AddOnClick(this.RoundCountSortBtn, this.OnRoundCountSortBtnClick)
    EventUtil.AddOnClick(this.MarkSortBtn, this.OnMarkSortBtnClick)
    EventUtil.AddOnClick(this.TeamScoreSortBtn, this.OnTeamScoreSortBtnClick)
    --this.input.onValueChanged:RemoveAllListeners()
    --this.input.onValueChanged:AddListener(this.OnInputFieldValueChanged)
end


--================================================================
--

--队伍信息
function UnionNodeNewMyTeam.OnTeam(data)
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
function UnionNodeNewMyTeam.OnHeadClick(item)
    if item.data ~= nil then
        PanelManager.Open(PanelConfig.UnionPersonalData, item.data.pId, true)
    end
end

--详情按钮
function UnionNodeNewMyTeam.OnDetailsClick(item)
    PanelManager.Open(PanelConfig.UnionTeamDetails, item.data)
end

--
function UnionNodeNewMyTeam.OnLastBtnClick()
    if this.pageIndex <= 1 then
        Toast.Show("当前已是首页")
    else
        this.SendRequestList(this.pageIndex - 1)
    end
end

--
function UnionNodeNewMyTeam.OnNextBtnClick()
    LogError("this.pageIndex", this.pageIndex, "this.pageTotal", this.pageTotal)
    if this.pageIndex >= this.pageTotal then
        Toast.Show("当前已是尾页")
    else
        this.SendRequestList(this.pageIndex + 1)
    end
end

--
function UnionNodeNewMyTeam.OnSearchBtnClick()
    LogError("this.input", this.input)
    this.GetSearchInputFieldText()
    local num = this.SearchField--tonumber(text)
    if num ~= nil then
        LockScreen(0.5)
        this.SendRequestList(1)
    else
        Toast.Show("请输入正确的玩家ID")
    end
end

function UnionNodeNewMyTeam.GetSearchInputFieldText()
    this.SearchField = UIUtil.GetInputText(this.input) or ""
end

function UnionNodeNewMyTeam.OnScoreSortBtnClick()
    this.SortDescHandler(0)
    this.SendRequestList(this.pageIndex)
end

function UnionNodeNewMyTeam.OnRoundCountSortBtnClick()
    this.SortDescHandler(1)
    this.SendRequestList(this.pageIndex)
end

function UnionNodeNewMyTeam.OnMarkSortBtnClick()
    this.SortDescHandler(2)
    this.SendRequestList(this.pageIndex)
end

function UnionNodeNewMyTeam.OnTeamScoreSortBtnClick()
    this.SortDescHandler(3)
    this.SendRequestList(this.pageIndex)
end

--积分 --0 积分 --1 几日局数 --2今日成绩 --3战队积分
function UnionNodeNewMyTeam.SortDescHandler(sortKey)
    this.SortKey = sortKey
    local clientSortKey = sortKey + 1
    this.SortDesc = this.SortStateData[clientSortKey]
    this.SortStateData[clientSortKey] = this.SortStateData[clientSortKey] == 0 and 1 or 0
    local y = this.SortDesc == 1 and 1 or -1
    this.SortImgArr[clientSortKey].localScale = Vector3.New(1, y, 1)
end

--================================================================
--
--请求数据
function UnionNodeNewMyTeam.SendRequestList(pageIndex)
    LogError("SendRequestList")
    this.GetSearchInputFieldText()
    LogError("SearchField", this.SearchField)
    UnionManager.SendRequestNewTeamMember(this.SearchField, pageIndex, PageCount, this.SortKey, this.SortDesc)
end

--
--更新数据
function UnionNodeNewMyTeam.UpdateDataList(data)
    this.pageIndex = data.pageIndex
    LogError("174 Functions.CheckPageTotal(data.allPage)", Functions.CheckPageTotal(data.allPage))
    --this.pageTotal = Functions.CheckPageTotal(data.allPage)

    this.InitItemObjList(1)
    this.SetItem(this.items[1], data)
end

function UnionNodeNewMyTeam.UpdateNewDataList(data)
    --LogError("战队成员", data)
    this.pageIndex = data.pageIndex
    this.pageTotal = Functions.CheckPageTotal(data.allPage)
    --LogError("this.pageTotal", this.pageTotal)
    this.UpdateNoDataNoticeActive(data)
    this.pageLabel.text = this.pageIndex .. "/" .. this.pageTotal
    this.InitItemObjList(#data.list)
    if this.upId ~= data.upId then
        this.upIconChanged = true
        this.upIcon = data.upIcon
        this.upName = data.upName
        this.upId = data.upId
    end
    for i = 1, #data.list do
        this.SetItem(this.items[i], data.list[i])
    end
end

function UnionNodeNewMyTeam.UpdateNoDataNoticeActive(data)
    --LogError("<color=aqua>#data.list == 0</color>", #data.list == 0)
    UIUtil.SetActive(this.noData, #data.list == 0)
end

function UnionNodeNewMyTeam.InitItemObjList(count)
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
        item.headIconGo1 = item.transform:Find("Head1")
        item.headBtn1 = item.headIconGo1:Find("Mask/HeadImg").gameObject
        item.headImg1 = item.headBtn1:GetComponent(TypeImage)
        item.Name1 = item.headIconGo1:Find("Name"):GetComponent(TypeText)
        item.ID1 = item.headIconGo1:Find("ID"):GetComponent(TypeText)
        item.headIconGo2 = item.transform:Find("Head2")
        item.headBtn2 = item.headIconGo2:Find("Mask/HeadImg").gameObject
        item.headImg2 = item.headBtn2:GetComponent(TypeImage)
        item.Name2 = item.headIconGo2:Find("Name"):GetComponent(TypeText)
        item.ID2 = item.headIconGo2:Find("ID"):GetComponent(TypeText)
        item.Score = item.transform:Find("Score"):GetComponent(TypeText)
        item.RoundCount = item.transform:Find("RoundCount"):GetComponent(TypeText)
        item.Grade = item.transform:Find("Grade"):GetComponent(TypeText)
        item.TeamScore = item.transform:Find("TeamScore"):GetComponent(TypeText)
        item.btn = item.transform:Find("7/Button")
        EventUtil.AddOnClick(item.btn, function()
            this.OnButtonClick(item)
        end)
        EventUtil.AddOnClick(item.headBtn1, function()
            this.OnHead1Click(item)
        end)
        EventUtil.AddOnClick(item.headBtn2, function()
            this.OnHead2Click(item)
        end)
        UIUtil.SetActive(item.gameObject, false)
    end
end

--设置Item数据
function UnionNodeNewMyTeam.SetItem(item, data)
    item.data = data
    --
    UIUtil.SetActive(item.gameObject, true)
    if item.icon ~= data.icon then
        item.icon = data.icon
        Functions.SetHeadImage(item.headImg1, data.icon)
    end

    item.Name1.text = tostring(data.name)
    item.ID1.text = "ID:" .. UnionData.GetUidString(data.userId)

    item.Name2.text = data.upName
    item.ID2.text = "ID:" .. data.upId
    Functions.SetHeadImage(item.headImg2, data.upIcon)

    item.Score.text = data.fen
    item.RoundCount.text = data.dayGame .. "\n" .. data.lastGame
    item.Grade.text = data.dayScore .. "\n" .. data.lastScore
    item.TeamScore.text = data.score
end

--调整分数
function UnionNodeNewMyTeam.OnButtonClick(item)
    if item.data ~= nil then
        PanelManager.Open(PanelConfig.UnionScoreChange, item.data.userId)
    end
end

--头像1点击
function UnionNodeNewMyTeam.OnHead1Click(item)
    if item.data ~= nil then
        PanelManager.Open(PanelConfig.UnionPlayableGame, item.data.userId)
    end
end

--头像2点击
function UnionNodeNewMyTeam.OnHead2Click(item)
    PanelManager.Open(PanelConfig.UnionPersonalData, this.upId, true)
end
