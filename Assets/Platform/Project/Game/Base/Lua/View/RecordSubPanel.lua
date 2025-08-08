RecordSubPanel = ClassPanel("RecordSubPanel")
local this = RecordSubPanel
--当前选中的游戏类型
this.gameId = GameType.Mahjong
--当前战绩类型
this.roomType = nil
this.recordType = 1 --1:个人战绩 2:所有战绩
this.groupId = 0
this.recordInfoItems = {}
--一页数量
this.count = 4
--是否开启隐私
this.isOpenYinSi = false
--是否开启
this.isOpen = false
this.roomId = 0
--回放信息
this.playbackInfo = {}

--初始化面板--
function RecordSubPanel:OnInitUI()
    this = self
    --初始化背景

    local content = self:Find("Content")

    this.closeBtn = content:Find("Background/CloseBtn")

    --记录
    local scrollView = content:Find("ScrollView")
    this.noDataGO = content:Find("NoDataText").gameObject
    this.recordScrollRect = scrollView:GetComponent("ScrollRectExtension")
    this.recordContent = scrollView:Find("Viewport/Content")
    this.playerItemGO = scrollView:Find("PlayerItem")
    this.pin5PlayerItemGo = scrollView:Find("Pin5PlayerItem")
    this.ItemAtlas = content:Find("ItemAtlas"):GetComponent("UISpriteAtlas")
    this.PokerAtlas = content:Find("PokerAtlas"):GetComponent("UISpriteAtlas")
    this.Pin5PokerTypeAtlas = content:Find("Pin5PokerTypeAtlas"):GetComponent("UISpriteAtlas")
    this.LYCPokerTypeAtlas = content:Find("LYCPokerTypeAtlas"):GetComponent("UISpriteAtlas")

    this:AddUIListenerEvent()
    this.InitScrollRect()
end
-----------------------------------------------UI点击事件-----------------------------------
function RecordSubPanel:AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
end

function RecordSubPanel:OnOpened(subArgs)
    this = self

    this.InitScrollRect()
    this.subArgs = subArgs
    --LogError(">> RecordSubPanel:OnOpened > ", subArgs)

    --LogError("<color=aqua>OnOpened roomId</color>", this.subArgs.data.roomId, "<color=aqua>roomNum</color>", this.subArgs.data.roomNum)

    this.roomType = subArgs.roomType
    if IsNil(this.roomType) then
        this.roomType = RoomType.Lobby
    end
    this.groupId = subArgs.groupId
    if IsNil(this.groupId) then
        this.groupId = 0
    end
    this.isOpenYinSi = subArgs.isOpenYinSi
    if IsNil(this.isOpenYinSi) then
        this.isOpenYinSi = false
    end

    this.AddListerEvent()
    this.roomId = subArgs.data.roomId
    BaseTcpApi.SendRequestSubRecord(subArgs.data.roomId, UnionData.curUnionId, subArgs.data.gameId, subArgs.subPage, subArgs.count)
    this.InitRecordData(subArgs)
    
    this.isOpen = true
end

function RecordSubPanel:OnClosed()
    this.RemoveListnerEvent()
    this.isOpen = false
end

--分页列表初始化
function RecordSubPanel.InitScrollRect()
    this.recordScrollRect.onGetLastPageDataAction = function(page)
        if page >= 0 then
            this.SetRecordData(page + 1)
        end
    end
    this.recordScrollRect.onGetNextPageDataAction = function(page)
        if page < this.recordDatas[this.gameId][this.roomId].totalPage then
            this.SetRecordData(page + 1)
        end
    end
    this.recordScrollRect:SetMaxDataCount(0)
    this.recordScrollRect:InitItems()
    this.recordScrollRect.onUpdateItemAction = this.UpdateRecordItemInfo
end

--初始化数据
function RecordSubPanel.InitRecordData(subArgs)
    if this.recordDatas == nil then
        this.recordDatas = {}
    end
    if this.recordDatas[this.gameId] == nil then
        this.recordDatas[this.gameId] = {}
    end
    if this.recordDatas[this.gameId][this.roomId] == nil then
        this.recordDatas[this.gameId][this.roomId] = {
            subPage = 1,
            totalPage = 1,
            totalCount = 0,
            recordList = {}
        }
    end
end

function RecordSubPanel.AddListerEvent()
    AddEventListener(CMD.Tcp_S2C_SubRecord, this.OnRecord)
end

function RecordSubPanel.RemoveListnerEvent()
    RemoveEventListener(CMD.Tcp_S2C_SubRecord, this.OnRecord)
end

function RecordSubPanel.OnCloseBtnClick()
    this:Close()
end

--战绩回复
function RecordSubPanel.OnRecord(data)
    if data.code == 0 then
        this.UpdateRecord(data)
    end
end

--更新战绩
function RecordSubPanel.UpdateRecord(data)
    -- this.roomType = data.data.roomType
    this.moneyType = data.data.currency
    this.gameId = data.data.gameId
    this.recordDatas[this.gameId] = this.recordDatas[this.gameId] or {}
    this.recordDatas[this.gameId][this.roomId] = this.recordDatas[this.gameId][this.roomId] or {}
    local recordData = this.recordDatas[this.gameId][this.roomId]
    recordData.subPage = data.data.page
    recordData.totalPage = data.data.totalPage
    recordData.totalCount = data.data.totalNum

    --移除多余的数据
    --LogError("战绩列表", recordData.recordList)
    --local start = (recordData.totalPage - 1) * this.count + 1
    --LogError("<color=aqua>start</color>", start)
    --for i = start, #recordData.recordList do
    --    table.remove(recordData.recordList, i)
    --end

    recordData.recordList = recordData.recordList or {}
    for i = 1, this.count do
        local idx = (recordData.subPage - 1) * this.count + i
        if data.data.list[i] ~= nil then
            recordData.recordList[idx] = data.data.list[i]
        else
            recordData.recordList[idx] = nil
        end
    end
    if recordData.totalCount > 0 then
        UIUtil.SetActive(this.noDataGO, false)
        this.recordScrollRect:SetMaxDataCount(recordData.totalCount)
        this.recordScrollRect:UpdateAllItems()
    else
        UIUtil.SetActive(this.noDataGO, true)
        HideChildren(this.recordContent)
    end
end

--设置数据
function RecordSubPanel.SetRecordData(page)
    --if this.roomType == RoomType.Lobby then
    local recordList = this.recordDatas[this.gameId][this.roomId].recordList
    local totalCount = this.recordDatas[this.gameId][this.roomId].totalCount
    --当前数据条数
    local curTotalCount = GetTableSize(recordList)
    if curTotalCount <= totalCount and curTotalCount < page * this.count then
        --LogError("<color=aqua>roomId</color>", this.subArgs.data.roomId, "<color=aqua>roomNum</color>", this.subArgs.data.roomNum)
        BaseTcpApi.SendRequestSubRecord(this.subArgs.data.roomId, UnionData.curUnionId, this.subArgs.data.gameId, page, this.subArgs.count)
    else
        UIUtil.SetActive(this.noDataGO, false)
        this.recordScrollRect:SetMaxDataCount(totalCount)
        this.recordScrollRect:UpdateAllItems()
    end
    --else
    --    if this.recordType == 1 then
    --        BaseTcpApi.SendGroupMyRecord(this.gameId, this.groupId, this.roomType, page, this.count)
    --    else
    --        if string.IsNullOrEmpty(UnionData.searchId) then
    --            BaseTcpApi.SendGroupAllRecord(this.gameId, this.groupId, this.roomType, page, this.count)
    --        else
    --            UnionManager.SendSearchRecord(this.gameId, UnionData.searchType, UnionData.searchId, page, this.count)
    --        end
    --    end
    --end
end



--更新战绩列表
function RecordSubPanel.UpdateRecordItemInfo(transform, idx)
    local dataObj = this.recordDatas[this.gameId][this.roomId]
    local data = dataObj.recordList[idx + 1]
    if IsNil(data) then
        if idx > dataObj.totalCount - 1 then
            transform.gameObject:SetActive(false)
        else
            --此处处理服务器还未返回数据
            --需要提前显示列表item的UI
            --使用占位的方式 数据使用默认
            transform.transform:Find("Group").gameObject:SetActive(false)
            transform.transform:Find("DataLoading").gameObject:SetActive(true)
        end
    else
        this.UpdateRecordItem(data, transform, idx)
    end
end

--更新item
function RecordSubPanel.UpdateRecordItem(data, transform, idx)
    local item = this.GetRecordInfoItem(transform)
    UIUtil.SetActive(item.gameObject, true)
    UIUtil.SetActive(item.groupNodeGo, true)
    UIUtil.SetActive(item.dataLoadingNodeGo, false)

    item.roomIDText.text = data.roomNum
    local gameId = data.gameId
    --五子棋隐藏 玩法、局数、底分
    local rule = JsonToObj(data.roomRule)

    item.data = data
    item.rule = rule

    local ruleText = Functions.ParseGameRule(gameId, rule)
    --Log("规则解析", ruleText)
    item.playWayText.text = ruleText.playWayName
    -- item.roundNumText.text = ruleText.juShuTxt
    item.diFenNumText.text = ruleText.baseScore
    if ruleText.baseScore > 0 then
        UIUtil.SetActive(item.diFenNumGo, true)
    else
        UIUtil.SetActive(item.diFenNumGo, false)
    end

    item.tiemText.text = os.date("%Y-%m-%d %H:%M:%S", data.endTime / 1000)

    if IsNil(data.users) then
        data.users = {}
    end
    item.scrollRect.enabled = #data.users > 4
    if #data.users <= 4 then
        UIUtil.SetAnchoredPosition(item.itemContent.gameObject, 0, 0)
    end
    if gameId == GameType.Pin5 or gameId == GameType.LYC then
        UIUtil.SetActive(item.detailsBtn, false)
        this.HidePlayerItems(item.playerItems)
        this.UpdatePin5PlayerItems(item.pin5PlayerItems, data.users, item.itemContent)
    else
        UIUtil.SetActive(item.detailsBtn, true)
        this.HidePlayerItems(item.pin5PlayerItems)
        this.UpdatePlayerItems(item.playerItems, data.users, item.itemContent)
    end
end

--
function RecordSubPanel.HidePlayerItems(items)
    local item = nil
    for i = 1, #items do
        item = items[i]
        if item.data ~= nil then
            item.data = nil
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

function RecordSubPanel.UpdatePlayerItems(items, list, itemContent)
    local dataLength = #list
    local data = nil
    local item = nil
    for i = 1, dataLength do
        data = list[i]
        item = items[i]
        if item == nil then
            item = this.CreatePlayerItem(itemContent, i)
            table.insert(items, item)
        end
        this.SetPlayerItem(item, data)
    end
    for i = dataLength + 1, #items do
        item = items[i]
        if item.data ~= nil then
            item.data = nil
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

function RecordSubPanel.UpdatePin5PlayerItems(items, list, itemContent)
    local dataLength = #list
    local data = nil
    local item = nil
    for i = 1, dataLength do
        data = list[i]
        item = items[i]
        if item == nil then
            item = this.CreatePin5PlayerItem(itemContent, i)
            table.insert(items, item)
        end
        this.SetPin5PlayerItem(item, data)
    end
    for i = dataLength + 1, #items do
        item = items[i]
        if item.data ~= nil then
            item.data = nil
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

function RecordSubPanel.SetPlayerItem(item, data)
    data.score = tonumber(data.score)
    item.data = data
    UIUtil.SetActive(item.gameObject, true)
    local isSelf = data.userId == UserData.GetUserId()
    local bgName = isSelf and "ui_com_fenlei_diban_01" or "ui_com_fenlei_diban_02"
    item.SelfImg.sprite = this.ItemAtlas:GetSpriteByName(bgName)
    UIUtil.SetActive(item.SelfBg, isSelf)
    Functions.SetHeadImage(item.headImage, Functions.CheckJoinPlayerHeadUrl(data.iCon))
    item.nameText.text = data.name
    item.idText.text = Functions.GetUserIdString(data.userId)

    if data.score < 0 then
        UIUtil.SetActive(item.minusScoreTextGo, true)
        UIUtil.SetActive(item.addScoreTextGo, false)
        item.minusScoreText.text = data.score
    else
        UIUtil.SetActive(item.minusScoreTextGo, false)
        UIUtil.SetActive(item.addScoreTextGo, true)
        item.addScoreText.text = "+" .. data.score
    end
end

function RecordSubPanel.SetPin5PlayerItem(item, data)
    -- LogError("执行", data)
    data.score = tonumber(data.score)
    item.data = data
    UIUtil.SetActive(item.gameObject, true)
    local isSelf = data.userId == UserData.GetUserId()
    local bgName = isSelf and "ui_com_fenlei_diban_01" or "ui_com_fenlei_diban_02"
    item.SelfImg.sprite = this.ItemAtlas:GetSpriteByName(bgName)
    UIUtil.SetActive(item.SelfBg, isSelf)
    Functions.SetHeadImage(item.headImage, Functions.CheckJoinPlayerHeadUrl(data.iCon))
    item.nameText.text = data.name
    item.idText.text = Functions.GetUserIdString(data.userId)

    UIUtil.SetActive(item.Rob, data.userData.zhuang == 1)
    UIUtil.SetActive(item.Zhu, data.userData.zhuang ~= 1 and this.gameId ~= GameType.LYC)

    item.ScoreLabel.text = tostring(data.score)
    item.ZhuLabel.text = tostring(data.userData.bet)

    local pokerItem = nil
    local pokers = data.userData.pokers
    local pokerValue = 0
    local pokerLength = #pokers
    for i = 1, pokerLength do
        pokerValue =  pokers[i]
        pokerItem = item.pokerItems[i]
        UIUtil.SetActive(pokerItem.gameObject, true)

        local UpDistance = 0
        if this.gameId == GameType.Pin5 then
            UpDistance = pokerValue == data.userData.nowCard[1] and 6 or 0
            UIUtil.SetActive(pokerItem.FiveCardTag, pokerValue == data.userData.nowCard[1])
        else
            UIUtil.SetActive(pokerItem.FiveCardTag, false)
        end
        local lastPosition = pokerItem.transform.localPosition
        pokerItem.transform.localPosition = Vector3.New(lastPosition.x, pokerItem.LocalPosY + UpDistance, lastPosition.z)
        pokerItem.image.sprite = this.PokerAtlas:GetSpriteByName(tostring(pokerValue))
    end

    for i = pokerLength + 1, #item.pokerItems do
        pokerItem = item.pokerItems[i]
        UIUtil.SetActive(pokerItem.gameObject, false)
    end

    UIUtil.SetActive(item.pokerType.gameObject, this.gameId ~= GameType.LYC)
    UIUtil.SetActive(item.lycPointsBg.gameObject, this.gameId == GameType.LYC)
    if this.gameId == GameType.Pin5 then
        local typeName = this.GetPokerTypeSpriteNamePin5(data.userData.pokerType, data.userData.PokerBl)
        item.pokerType.sprite = this.Pin5PokerTypeAtlas:GetSpriteByName(typeName)
        item.pokerType.gameObject.transform.localScale = Vector3.New(0.5, 0.5, 0.5)
    -- elseif this.gameId == GameType.SG then
    --     local typeName = this.GetPokerTypeSpriteNameSG(data.userData.pokerType, pokers)
    --     item.pokerType.sprite = this.SGPokerTypeAtlas:GetSpriteByName(typeName)
    --     item.pokerType.gameObject.transform.localScale = Vector3.New(0.3, 0.3, 0.3)
    elseif this.gameId == GameType.LYC then
        local imgType = data.userData.special == 3 and "10" or data.userData.point
        item.lycPointsImg.sprite = this.LYCPokerTypeAtlas:GetSpriteByName(imgType)
        UIUtil.SetActive(item.lycPointsMultiply.gameObject, false)
        --双腌，三腌，五腌(炸弹)
        if data.userData.special == 1 or data.userData.special == 2 then
            UIUtil.SetActive(item.lycPointsMultiply.gameObject, true)
            item.lycPointsYanImg.sprite = this.LYCPokerTypeAtlas:GetSpriteByName("yan"..data.userData.special)
        end
        -- UIUtil.SetActive(item.lycPointsMultiply.gameObject, data.userData.multi > 1) --倍数
        -- item.lycPointsMultiplyNum.text = "x"..data.userData.multi
    end
    item.pokerType:SetNativeSize()
end

--获取牛牛手牌类型
function RecordSubPanel.GetPokerTypeSpriteNamePin5(pokerType, PokerBl)
    return (PokerBl and tonumber(PokerBl) > 1) and "pin5_result_" .. pokerType .. "_" .. PokerBl or "pin5_result_" .. pokerType
end

--获取战绩Item
function RecordSubPanel.GetRecordInfoItem(transform)
    local id = transform.gameObject:GetInstanceID()
    local item = this.recordInfoItems[id]
    if IsNil(item) then
        item = {}
        item.transform = transform
        item.gameObject = transform.gameObject
        item.groupNode = transform:Find("Group")
        item.groupNodeGo = item.groupNode.gameObject
        item.dataLoadingNodeGo = transform:Find("DataLoading").gameObject
        item.roomIDText = item.groupNode:Find("RoomIDText"):GetComponent("Text")
        item.playWayText = item.groupNode:Find("PlayWayText"):GetComponent("Text")
        item.diFenNumGo = item.groupNode:Find("DiFenNumText").gameObject
        item.diFenNumText = item.diFenNumGo:GetComponent("Text")
        item.tiemText = item.groupNode:Find("TimeText"):GetComponent("Text")
        item.detailsBtn = item.groupNode:Find("DetailsBtn").gameObject

        local playerItemTrans = item.groupNode:Find("PlayerItems")
        item.playerItems = {}
        item.pin5PlayerItems = {}
        item.itemContent = playerItemTrans:Find("Viewport/Content")
        item.scrollRect = playerItemTrans:GetComponent("ScrollRect")

        this:AddOnClick(item.detailsBtn, function()
            this.OnDetailsBtnClick(item)
        end)
    end
    this.recordInfoItems[id] = item
    return item
end

--获取玩家Item
function RecordSubPanel.CreatePlayerItem(parent, index)
    local item = {}
    item.gameObject = CreateGO(this.playerItemGO, parent, tostring(index))
    item.transform = item.gameObject.transform
    item.SelfImg = item.transform:GetComponent(TypeImage)
    item.SelfBg = item.transform:Find("SelfBg")
    item.headImage = item.transform:Find("Head/Mask/HeadIcon"):GetComponent("Image")
    item.nameText = item.transform:Find("NameText"):GetComponent("Text")
    item.idText = item.transform:Find("IDText"):GetComponent("Text")
    item.winner = item.transform:Find("Winner")
    item.rich = item.transform:Find("Rich")
    item.addScoreTextGo = item.transform:Find("AddScoreText").gameObject
    item.addScoreText = item.addScoreTextGo:GetComponent("Text")
    item.minusScoreTextGo = item.transform:Find("MinusScoreText").gameObject
    item.minusScoreText = item.minusScoreTextGo:GetComponent("Text")
    return item
end

function RecordSubPanel.CreatePin5PlayerItem(parent, index)
    local item = {}
    item.gameObject = CreateGO(this.pin5PlayerItemGo, parent, tostring(index))
    item.transform = item.gameObject.transform
    item.SelfImg = item.transform:GetComponent(TypeImage)
    item.SelfBg = item.transform:Find("SelfBg")
    item.headImage = item.transform:Find("Head/Mask/HeadIcon"):GetComponent("Image")
    item.nameText = item.transform:Find("NameText"):GetComponent("Text")
    item.idText = item.transform:Find("IDText"):GetComponent("Text")
    item.Rob = item.transform:Find("Rob").gameObject
    item.ScoreLabel = item.transform:Find("Score"):GetComponent("Text")
    item.Zhu = item.transform:Find("Zhu").gameObject
    item.ZhuLabel = item.Zhu:GetComponent("Text")
    item.pokerItems = {}
    for i = 1, 5 do
        local pokerItem = {}
        pokerItem.transform = item.transform:Find("Pokers/Poker" .. i)
        pokerItem.gameObject = pokerItem.transform.gameObject
        pokerItem.image =  pokerItem.transform:GetComponent(TypeImage)
        pokerItem.FiveCardTag = pokerItem.transform:Find("5th")
        pokerItem.LocalPosY = pokerItem.transform.localPosition.y
        table.insert(item.pokerItems, pokerItem)
    end
    item.pokerType = item.transform:Find("PokerTypeBg/pokerTypeImg"):GetComponent(TypeImage)

    --捞腌菜点数显示
    item.lycPointsBg = item.transform:Find("PokerTypeBg/LYCPointsBg")
    item.lycPointsImg = item.lycPointsBg:Find("LYCPointsImg"):GetComponent(TypeImage)
    item.lycPointsMultiply = item.lycPointsBg:Find("LYCPointsMultiply")
    -- item.lycPointsMultiplyNum = item.lycPointsBg:Find("LYCPointsMultiply/LYCPointsMultiplyNum"):GetComponent(TypeText)
    item.lycPointsYanImg = item.lycPointsBg:Find("LYCPointsMultiply/LYCPointsYanImg"):GetComponent(TypeImage)
    return item
end

--显示界面，不做任何处理
function RecordSubPanel.Show()
    UIUtil.SetActive(this.gameObject, true)
end

--隐藏界面，不做任何清除
function RecordSubPanel.Hide()
    UIUtil.SetActive(this.gameObject, false)
end


--战绩
function RecordSubPanel.OnDetailsBtnClick(item)
    local data = item.data

    local list = data.users
    local tempPlayerId = 0
    local viewPlayerId = 0
    for i = 1, #list do
        local infoData = list[i]
        if tempPlayerId == 0 then
            tempPlayerId = infoData.userId
        end
        if infoData.userId == UserData.GetUserId() then
            viewPlayerId = infoData.userId
        end
    end
    --如果查看别人的战绩，战绩中没有自己的数据，就取第一个玩家ID来查看
    if viewPlayerId == 0 then
        viewPlayerId = tempPlayerId
    end

    this.playbackInfo = {
        gameId = data.gameId,
        inning = data.inning,
        roomType = data.roomType,
        moneyType = data.currency,
        onlyRoomId = data.roomId,
        time = data.endTime,
        roomId = data.roomNum,
        groupId = this.groupId,
        rule = item.rule,
        viewPlayerId = viewPlayerId,
    }

    Waiting.Show("加载回放数据中...")
    local name = data.gameId .. "/" .. Util.GetTimeData(data.endTime, "yyyy-MM-dd") .. "/" .. data.roomId .. "/" .. data.inning .. ".txt"
    AppConfig.CheckGetPlaybackUrl(GlobalData.playbackDownUrl, function(url) this.OnCheckGetPlaybackUrl(name, url) end)
end

--检查获取链接地址
function RecordSubPanel.OnCheckGetPlaybackUrl(name, url)
    --Log(">> RecordSubPanel.OnCheckGetPlaybackUrl > url = ", url, name)
    Functions.CheckLocalPlaybackData(name, url .. name, this.OnDownLoadPlayerBackDataCallBack)
end

--下载回放数据回调  --开始回放
function RecordSubPanel.OnDownLoadPlayerBackDataCallBack(code, str)
    --请求进入回放房间
    if code == 0 then
        local info = this.playbackInfo
        if GameManager.IsCheckGame(info.gameId) then
            local data = {
                roomId = info.roomId,
                userId = info.viewPlayerId,
                isPlayback = true,
                playbackData = JsonToObj(str),
                groupId = info.groupId, --组织ID
                roomType = info.roomType, --房间类型
                moneyType = info.moneyType, --货币类型
                time = info.time,
                recordType = info.roomType, --大厅回放
            }
            GameSceneManager.SwitchGameScene(GameSceneType.Room, this.gameId, data)
        end
    else
        Waiting.ForceHide()
        Toast.Show("获取回放数据失败")
    end
end