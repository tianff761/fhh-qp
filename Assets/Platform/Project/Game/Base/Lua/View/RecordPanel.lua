RecordPanel = ClassPanel("RecordPanel")
local this = RecordPanel
--当前选中的游戏类型
this.gameId = GameType.None
--当前选中的日期类型
this.day = 0
--当前战绩类型
this.roomType = nil
--联盟才有的，1:个人战绩 2:所有战绩
this.recordType = 1
this.groupId = 0
this.recordInfoItems = {}
this.playerItemGO = nil
--一页数量
this.count = 4
--是否开启隐私
this.isOpenYinSi = false
--是否开启
this.isOpen = false
this.sprites = {}

--初始化面板--
function RecordPanel:OnInitUI()
    this = self

    this.closeBtn = self:Find("Content/Background/CloseBtn").gameObject

    local content = self:Find("Content")
    --左边
    local Menus = content:Find("Menus")
    local gameContent = Menus:Find("Viewport/Content")
    this.gameToggles = {}
    local length = gameContent.childCount
    for i = 1, length do
        local toggle = gameContent:GetChild(i - 1):GetComponent("Toggle")
        table.insert(this.gameToggles, toggle)
    end

    local dayType = content:Find("DayType")
    this.dayTypeToggles = {}
    local len = dayType.childCount
    for i = 1, len do
        local toggle = dayType:GetChild(i - 1):GetComponent("Toggle")
        table.insert(this.dayTypeToggles, toggle)
    end

    this.dayDropdown = content:Find("DayDropdown"):GetComponent(TypeDropdown)

    this.toggleGroup = content:Find("ToggleGroup")
    this.myToggle = this.toggleGroup:Find("MyToggle"):GetComponent(TypeToggle)
    this.allToggle = this.toggleGroup:Find("AllToggle"):GetComponent(TypeToggle)

    this.searchBtn = content:Find("SearchBtn").gameObject

    --记录
    this.tipsNoData = content:Find("NoDataText")
    local scrollView = content:Find("ScrollView")
    this.recordScrollRect = scrollView:GetComponent("ScrollRectExtension")
    this.recordContent = scrollView:Find("Viewport/Content")
    this.playerItemGO = scrollView:Find("PlayerItem")

    --胡图标
    this.sprites = {}
    local atlas = content:Find("Atlas"):GetComponent("UISpriteAtlas")
    local tempSprites = atlas.sprites:ToTable()
    local sprite = nil
    for i = 1, #tempSprites do
        sprite = tempSprites[i]
        if sprite ~= nil then
            this.sprites[i] = sprite
        else
            LogWarn(">> RecordPanel > sprite == nil > index = " .. i)
        end
    end

    this:AddUIListenerEvent()
    this.InitScrollRect()
end

function RecordPanel:OnOpened(roomType, groupId, isOpenYinSi, recordType)
    this = self

    this.roomType = roomType
    if IsNil(this.roomType) then
        this.roomType = RoomType.Lobby
    end
    this.groupId = groupId
    if IsNil(this.groupId) then
        this.groupId = 0
    end
    this.isOpenYinSi = isOpenYinSi
    if IsNil(this.isOpenYinSi) then
        this.isOpenYinSi = false
    end

    UIUtil.SetActive(this.toggleGroup, not (this.roomType == RoomType.Lobby))

    --处理联盟查看某个人的战绩处理
    if this.roomType ~= RoomType.Lobby then
        UIUtil.SetActive(this.toggleGroup, true)
        this.recordType = 1--recordType or 1
        if this.recordType == 1 then
            this.myToggle.isOn = false
            this.myToggle.isOn = true
        else
            this.allToggle.isOn = false
            this.allToggle.isOn = true
        end
    else
        UIUtil.SetActive(this.toggleGroup, false)
    end

    this.InitRecordData()
    this.DisplaySearch()
    --下拉列表初始化
    --this.dayDropdown.value = this.day
    this.AddListerEvent()
    this.isOpen = true
    this.InitMenuToggle()
    this.dayTypeToggles[1].isOn = false
    this.dayTypeToggles[1].isOn = true
end

function RecordPanel:OnClosed()
    this.RemoveListnerEvent()
    this.isOpen = false
    UnionData.searchId = ""
    UIUtil.SetActive(this.searchBtn, false)
end

----------------------------------UI点击事件--------------------------------
function RecordPanel:AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.searchBtn, this.OnSearchBtnClick)

    local length = #this.gameToggles
    for i = 1, length do
        UIToggleListener.AddListener(this.gameToggles[i].gameObject, this.OnGameToggleClick)
    end
    length = #this.dayTypeToggles
    for i = 1, length do
        UIToggleListener.AddListener(this.dayTypeToggles[i].gameObject, this.OnDayTypeToggleClick)
    end
    this:AddOnToggle(this.myToggle, this.OnMyToggleClick)
    this:AddOnToggle(this.allToggle, this.OnAllToggleClick)

    --this.dayDropdown.onValueChanged:AddListener(this.OnDayDropdownValueChanged)
end

function RecordPanel.AddListerEvent()
    AddEventListener(CMD.Tcp_S2C_Record, this.OnRecord)
    AddEventListener(CMD.Tcp_S2C_GroupMyRecord, this.OnRecord)
    --AddEventListener(CMD.Tcp_S2C_SubRecord, this.OnSubRecord)
    AddEventListener(CMD.Tcp_S2C_GroupAllRecord, this.OnRecord)
    AddEventListener(CMD.Tcp.Union.S2C_UNION_FIND_RECORD, this.OnUnionRecord)
    AddEventListener(CMD.Game.UnionUpdateSearchRecord, this.OnUnionUpdateSearchRecord)
end

function RecordPanel.RemoveListnerEvent()
    RemoveEventListener(CMD.Tcp_S2C_Record, this.OnRecord)
    RemoveEventListener(CMD.Tcp_S2C_GroupMyRecord, this.OnRecord)
    RemoveEventListener(CMD.Tcp_S2C_GroupAllRecord, this.OnRecord)
    RemoveEventListener(CMD.Tcp.Union.S2C_UNION_FIND_RECORD, this.OnUnionRecord)
    RemoveEventListener(CMD.Game.UnionUpdateSearchRecord, this.OnUnionUpdateSearchRecord)
end

--================================================================

--初始化游戏菜单toggle选项
function RecordPanel.InitMenuToggle()
    if this.gameId ~= GameType.Mahjong then
        this.gameToggles[1].isOn = false
        this.gameToggles[1].isOn = true
    else
        this.day = 0
        this.SetRecordData(1)
    end
end

--显示搜索
function RecordPanel.DisplaySearch()
    if this.roomType ~= RoomType.Lobby and UnionData.selfRole ~= UnionRole.Common then
        UIUtil.SetActive(this.searchBtn, this.allToggle.isOn)
    end
end

--分页列表初始化
function RecordPanel.InitScrollRect()
    this.recordScrollRect.onGetLastPageDataAction = function(page)
        LogError("onGetLastPageDataAction")
        if page >= 0 then
            this.SetRecordData(page + 1)
        end
    end
    this.recordScrollRect.onGetNextPageDataAction = function(page)
        LogError("onGetNextPageDataAction")
        if page < this.recordDatas[this.gameId][this.roomType].totalPage then
            this.SetRecordData(page + 1)
        end
    end
    this.recordScrollRect:SetMaxDataCount(0)
    this.recordScrollRect:InitItems()
    this.recordScrollRect.onUpdateItemAction = this.UpdateRecordItemInfo
end

--初始化数据
function RecordPanel.InitRecordData()
    this.recordDatas = {
        [GameType.None] = {
            [RoomType.Lobby] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
            [RoomType.Club] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
            [RoomType.Tea] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
        },
        [GameType.Mahjong] = {
            [RoomType.Lobby] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
            [RoomType.Club] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
            [RoomType.Tea] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
        },
        [GameType.ErQiShi] = {
            [RoomType.Lobby] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
            [RoomType.Club] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
            [RoomType.Tea] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
        },
        [GameType.PaoDeKuai] = {
            [RoomType.Lobby] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
            [RoomType.Club] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
            [RoomType.Tea] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
        },
        [GameType.Pin5] = {
            [RoomType.Lobby] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
            [RoomType.Club] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
            [RoomType.Tea] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
        },
        [GameType.SDB] = {
            [RoomType.Lobby] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
            [RoomType.Club] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
            [RoomType.Tea] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
        },
        [GameType.Pin3] = {
            [RoomType.Lobby] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
            [RoomType.Club] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
            [RoomType.Tea] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
        },
        [GameType.TP] = {
            [RoomType.Lobby] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
            [RoomType.Club] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
            [RoomType.Tea] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
        },
        [GameType.LYC] = {
            [RoomType.Lobby] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
            [RoomType.Club] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
            [RoomType.Tea] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
        },
    }
end




function RecordPanel.OnCloseBtnClick()
    this:Close()
end

function RecordPanel.OnSearchBtnClick()
    PanelManager.Open(PanelConfig.RecordSearch)
end

--天数类型点击
function RecordPanel.OnDayTypeToggleClick(isOn, listener)
    if isOn then
        local value = tonumber(listener.name)
        LogError(">> RecordPanel.OnDayDropdownValueChanged", value)
        this.day = value
        this.SetRecordData(1, this.day)
    end
end

--游戏点击
function RecordPanel.OnGameToggleClick(isOn, listener)
    Audio.PlayClickAudio()
    if isOn then
        this.recordScrollRect:SetMaxDataCount(0)
        this.recordScrollRect:InitItems()
        this.gameId = tonumber(listener.name)
        this.SetRecordData(1)
    end
end

--与我相关的战绩
function RecordPanel.OnMyToggleClick(isOn)
    if not this.isOpen then
        return
    end
    if isOn then
        this.recordScrollRect:SetMaxDataCount(0)
        this.recordScrollRect:InitItems()
        this.recordType = 1
        this.SetRecordData(1)
        UIUtil.SetActive(this.searchBtn, false)
    end
end

--所有战绩
function RecordPanel.OnAllToggleClick(isOn)
    if not this.isOpen then
        return
    end
    if isOn then
        this.recordScrollRect:SetMaxDataCount(0)
        this.recordScrollRect:InitItems()
        this.recordType = 2
        this.SetRecordData(1)
        this.DisplaySearch()
    end
end

--
function RecordPanel.OnDayDropdownValueChanged(index)
    LogError(">> RecordPanel.OnDayDropdownValueChanged", index)
    this.day = index
    this.SetRecordData(1, this.day)
end

--战绩回复
function RecordPanel.OnRecord(data)
    if data.code == 0 then
        this.UpdateRecord(data)
    end
end

function RecordPanel.OnSubRecord(data)
    if data.code == 0 then
        this.recordDatas[this.gameId][this.roomType].subPage = data.data.page
        this.UpdateRecord(data, true)
    end
end

--更新战绩
function RecordPanel.UpdateRecord(data, isSub)
    --LogError("<color=aqua>UpdateRecord</color>", data, isSub)
    -- this.roomType = data.data.roomType
    this.moneyType = data.data.currency
    --LogError("<color=aqua>gameId</color>", data.data.gameId)
    this.gameId = data.data.gameId or this.gameId
    local recordData = this.recordDatas[this.gameId][this.roomType]
    recordData.curPage = isSub and recordData.curPage or data.data.page
    recordData.totalPage = data.data.totalPage
    recordData.totalCount = data.data.totalNum

    --LogError("战绩条数：", recordData.totalCount)
    --移除多余的数据
    local start = (recordData.totalPage - 1) * this.count + 1
    for i = start, #recordData.recordList do
        table.remove(recordData.recordList, i)
    end

    for i = 1, this.count do
        local idx = (recordData.curPage - 1) * this.count + i
        if data.data.list[i] ~= nil then
            recordData.recordList[idx] = data.data.list[i]
        else
            recordData.recordList[idx] = nil
        end
    end
    if recordData.totalCount > 0 then
        this.tipsNoData.gameObject:SetActive(false)
        this.recordScrollRect:SetMaxDataCount(recordData.totalCount)
        this.recordScrollRect:UpdateAllItems()
    else
        if not IsNull(this.tipsNoData) then
            this.tipsNoData.gameObject:SetActive(true)
            HideChildren(this.recordContent)
        end
    end
end

--联盟战绩
function RecordPanel.OnUnionRecord(data)
    if data.code == 0 then
        this.UpdateRecord(data)
    else
        local errString = UnionErrorDefine[data.code]
        if not string.IsNullOrEmpty(errString) then
            Toast.Show(errString)
        end
        UnionData.searchId = ""
        this.OnUnionUpdateSearchRecord()
    end
end

--更新战绩搜索
function RecordPanel.OnUnionUpdateSearchRecord()
    this.SetRecordData(1)
end

--更新战绩列表
function RecordPanel.UpdateRecordItemInfo(transform, idx)

    local recordList = this.recordDatas[this.gameId][this.roomType].recordList[idx + 1]
    if IsNil(recordList) then
        if idx > this.recordDatas[this.gameId][this.roomType].totalCount - 1 then
            transform.gameObject:SetActive(false)
        else
            --此处处理服务器还未返回数据
            --需要提前显示列表item的UI
            --使用占位的方式 数据使用默认
            transform.transform:Find("Group").gameObject:SetActive(false)
            transform.transform:Find("DataLoading").gameObject:SetActive(true)
        end
    else
        this.UpdateRecordItem(recordList, transform, idx, this.recordDatas[this.gameId][this.roomType].subPage)
    end
end

--更新item
function RecordPanel.UpdateRecordItem(data, transform, idx, subPage)
    local item = this.GetRecordInfoItem(transform)
    UIUtil.SetActive(item.gameObject, true)
    UIUtil.SetActive(item.groupNode.gameObject, true)
    UIUtil.SetActive(item.dataLoadingNode.gameObject, false)
    item.transform.localScale = Vector3.one
    item.roomIDText.text = data.roomNum
    local gameId = data.gameId
    --五子棋隐藏 玩法、局数、底分
    local rule = nil

    rule = JsonToObj(data.roomRule)
    local ruleText = Functions.ParseGameRule(gameId, rule)
    --LogError("<color=aqua>规则解析</color>", ruleText)
    item.GameName.text = GameConfig[gameId].Text
    item.playWayText.text = ruleText.playWayName
    -- item.roundNumText.text = ruleText.juShuTxt
    item.diFenNumText.text = ruleText.baseScore
    if ruleText.baseScore > 0 then
        UIUtil.SetActive(item.diFenNumGo, true)
    else
        UIUtil.SetActive(item.diFenNumGo, false)
    end

    item.tiemText.text = os.date("%Y-%m-%d %H:%M:%S", data.endTime / 1000)
    local args = {
        gameId = gameId,
        inning = data.inning,
        roomType = data.roomType,
        moneyType = data.currency,
        groupId = this.groupId,
        onlyRoomId = data.roomId,
        time = data.endTime,
        roomId = data.roomNum,
        rule = rule,
    }
    this:AddOnClick(item.detailsBtn, function()
        local subArgs = {
            roomType = this.roomType, groupId = this.groupId, isOpenYinSi = this.isOpenYinSi, recordType = this.recordType, data = data, subPage = subPage, count = this.count, recordDatas = this.recordDatas
        }
        --LogError("data", data)
        PanelManager.Open(PanelConfig.RecordSub, subArgs)
    end)
    UIUtil.SetActive(item.detailsBtn.gameObject, true)

    HideChildren(item.itemContent)
    if IsNil(data.users) then
        data.users = {}
    end
    local playerData = nil
    local length = #data.users
    item.scrollRect.enabled = #data.users > 4
    if #data.users <= 4 then
        UIUtil.SetAnchoredPosition(item.itemContent.gameObject, 0, 0)
    end
    for i = 1, length do
        playerData = data.users[i]
        playerData.score = tonumber(playerData.score)
        --LogError("<color=aqua>playerData</color>", playerData)
        local playerItem = item.playerItems[i]
        if playerItem == nil then
            playerItem = this.GetPlayerItem()
            item.playerItems[i] = playerItem
            playerItem.transform:SetParent(item.itemContent)
            playerItem.transform.localScale = Vector3.one
        end

        UIUtil.SetActive(playerItem.gameObject, true)
        playerItem.playerData = playerData
        local isSelf = playerData.userId == UserData.GetUserId()
        local bgName = isSelf and 1 or 2
        playerItem.selfImg.sprite = this.sprites[bgName]
        UIUtil.SetActive(playerItem.selfBg, isSelf)
        UIUtil.SetActive(playerItem.frameRed, playerData.line == 1 and playerData.userId ~= UserData.GetUserId())
        --UIUtil.SetActive(playerItem.OtherBg, playerData.userId ~= UserData.GetUserId())
        Functions.SetHeadImage(playerItem.headImage, Functions.CheckJoinPlayerHeadUrl(playerData.iCon))
        playerItem.nameText.text = playerData.name
        playerItem.idText.text = Functions.GetUserIdString(playerData.userId)

        UIUtil.SetActive(playerItem.minusScoreText.gameObject, playerData.score < 0)
        UIUtil.SetActive(playerItem.addScoreText.gameObject, playerData.score >= 0)
        if playerData.score < 0 then
            playerItem.minusScoreText.text = math.PreciseDecimal(playerData.score, 2)
        else
            playerItem.addScoreText.text = "+" .. math.PreciseDecimal(playerData.score, 2)
        end
    end
end

function RecordPanel.OnOtherPlayerBgClick(playerItem)
    LogError("playerItem.playerData.userId", playerItem.playerData.userId)
    PanelManager.Open(PanelConfig.UnionPlayerLayer, playerItem.playerData.userId)
end

--设置数据
function RecordPanel.SetRecordData(page, day)
    day = day or this.day
    LogError(this.gameId, this.groupId, this.roomType, page, this.count, day)
    if this.roomType == RoomType.Lobby then
        --Log(">>>>>>>RecordPanel.SetRecordData>>>>>>游戏", this.gameId)
        local recordList = this.recordDatas[this.gameId][this.roomType].recordList
        local totalCount = this.recordDatas[this.gameId][this.roomType].totalCount
        --当前数据条数
        local curTotalCount = GetTableSize(recordList)
        if curTotalCount <= totalCount and curTotalCount < page * this.count then
            BaseTcpApi.SendRecordByGameId(this.gameId, page, this.count, day)
        else
            this.tipsNoData.gameObject:SetActive(false)
            this.recordScrollRect:SetMaxDataCount(totalCount)
            this.recordScrollRect:UpdateAllItems()
        end
    else
        if this.recordType == 1 then
            BaseTcpApi.SendGroupMyRecord(this.gameId, this.groupId, this.roomType, page, this.count, day)
        else
            if string.IsNullOrEmpty(UnionData.searchId) then
                BaseTcpApi.SendGroupAllRecord(this.gameId, this.groupId, this.roomType, page, this.count, day)
            else
                UnionManager.SendSearchRecord(this.gameId, UnionData.searchType, UnionData.searchId, page, this.count, day)
            end
        end
    end
end

--获取战绩Item
function RecordPanel.GetRecordInfoItem(transform)
    local id = transform.gameObject:GetInstanceID()
    local item = this.recordInfoItems[id]
    if IsNil(item) then
        item = {}
        item.transform = transform
        item.gameObject = transform.gameObject
        item.groupNode = transform:Find("Group")
        item.dataLoadingNode = transform:Find("DataLoading")
        item.GameName = item.groupNode:Find("GameName"):GetComponent("Text")
        item.roomIDText = item.groupNode:Find("RoomIDText"):GetComponent("Text")
        item.playWayText = item.groupNode:Find("PlayWayText"):GetComponent("Text")
        -- item.roundNumText = item.groupNode:Find("RoundNumText"):GetComponent("Text")
        item.diFenNumGo = item.groupNode:Find("DiFenNumText").gameObject
        item.diFenNumText = item.diFenNumGo:GetComponent("Text")
        item.tiemText = item.groupNode:Find("TimeText"):GetComponent("Text")
        item.detailsBtn = item.groupNode:Find("DetailsBtn"):GetComponent("Button")
        --item.leftBtn = item.groupNode:Find("LeftBtn")
        --item.rightBtn = item.groupNode:Find("RightBtn")
        local playerItemTrans = item.groupNode:Find("PlayerItems")
        item.playerItems = {}
        item.itemContent = playerItemTrans:Find("Viewport/Content")
        item.viewportWidth = UIUtil.GetWidth(playerItemTrans)
        item.curScrollX = 0
        item.scrollRect = playerItemTrans:GetComponent("ScrollRect")
    end
    this.recordInfoItems[id] = item
    return item
end

--获取玩家Item
function RecordPanel.GetPlayerItem()
    local item = {}
    item.gameObject = CreateGO(this.playerItemGO)
    item.transform = item.gameObject.transform
    item.playerData = {}
    item.selfImg = item.transform:GetComponent(TypeImage)
    item.selfBg = item.transform:Find("SelfBg")
    item.OtherBg = item.transform:Find("OtherBg")
    item.headImage = item.transform:Find("Head/Mask/HeadIcon"):GetComponent("Image")
    item.frameRed = item.transform:Find("Head/BorderRed").gameObject
    item.nameText = item.transform:Find("NameText"):GetComponent(TypeText)
    item.idText = item.transform:Find("IDText"):GetComponent(TypeText)
    item.winner = item.transform:Find("Winner")
    item.rich = item.transform:Find("Rich")
    item.addScoreText = item.transform:Find("AddScoreText"):GetComponent(TypeText)
    item.minusScoreText = item.transform:Find("MinusScoreText"):GetComponent(TypeText)

    this:AddOnClick(item.gameObject, function()
        if item.playerData.line == 1 then
            PanelManager.Open(PanelConfig.UnionPersonalData, item.playerData.userId, true)
        elseif UnionData.IsUnionLeaderOrAdministratorOrObserver() and item.playerData.userId ~= UserData.GetUserId() then
            PanelManager.Open(PanelConfig.UnionPlayerLayer, item)
        end
    end)

    return item
end

--显示界面，不做任何处理
function RecordPanel.Show()
    UIUtil.SetActive(this.gameObject, true)
end

--隐藏界面，不做任何清除
function RecordPanel.Hide()
    UIUtil.SetActive(this.gameObject, false)
end