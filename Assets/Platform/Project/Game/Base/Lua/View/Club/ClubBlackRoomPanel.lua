ClubBlackRoomPanel = ClassPanel("ClubBlackRoomPanel")
local this = ClubBlackRoomPanel

this.bindItems = {}
this.bindDatas = {}
this.playerId = 0

this.bindMaxCount = 0 --绑定列表总共条数
this.bindPage = 1 --小黑屋绑定列表当前页数
this.bindTotalPage = 0 --小黑屋绑定列表总共页数

function ClubBlackRoomPanel:OnInitUI()
    this = self
    this.closeBtn = self:Find("Bgs/BackBtn")
    local content = self:Find("Content")
    this.searchBtn = content:Find("SearchBtn")
    this.searchIdInput = content:Find("SearchInputField"):GetComponent("InputField")
    this.loadingText = content:Find("BindListScrollRect/LoadingText")
    this.noDataText = content:Find("BindListScrollRect/NoDataText")
    this.blackListRect = content:Find("BindListScrollRect"):GetComponent("ScrollRectExtension")
    this.createBtn = content:Find("CreateBtn")
    this.AddUIListenerEvent()
end

function ClubBlackRoomPanel:OnOpened()
    this.RequestData()
    UIUtil.SetActive(this.loadingText, true)
    this.SendGetBlackRoomList(1)
end

function ClubBlackRoomPanel:OnClosed()
    this.bindDatas = {}
    this.playerId = 0
end

function ClubBlackRoomPanel.AddUIListenerEvent()
    this.searchIdInput.onEndEdit:AddListener(this.OnSearchEndEditByBind)
    this:AddOnClick(this.closeBtn, this.OnClickCloseBtn)
    this:AddOnClick(this.searchBtn, this.OnClickSearchBtn)
    this:AddOnClick(this.createBtn, this.OnClickCreateBtn)
end

function ClubBlackRoomPanel.RequestData()
    --绑定列表初始化
    this.blackListRect.onGetLastPageDataAction = function(page)
        if page > 0 then
            this.SendGetBlackRoomList(page + 1)
        end
    end
    this.blackListRect.onGetNextPageDataAction = function(page)
        if page < this.bindTotalPage then
            this.SendGetBlackRoomList(page + 1)
        end
    end
    this.blackListRect:SetMaxDataCount(0)
    this.blackListRect:InitItems()
    this.blackListRect.onUpdateItemAction = this.UpdateBindItemInfo
end

--俱乐部小黑屋列表更新
function ClubBlackRoomPanel.UpdateBindList(data)
    Log(">>>>>>>>更新小黑屋列表")
    this.bindPage = data.page
    this.bindTotalPage = data.totalPage
    this.bindMaxCount = data.totalNum

    --移除多余的数据
    local start = (this.bindTotalPage - 1) * ClubBlackRoomCountPerPage + 1
    for i = start, #this.bindDatas do
        table.remove(this.bindDatas, i)
    end

    for i = 1, ClubBlackRoomCountPerPage do
        local idx = (this.bindPage - 1) * ClubBlackRoomCountPerPage + i
        if data.list[i] ~= nil then
            this.bindDatas[idx] = data.list[i]
        else
            this.bindDatas[idx] = nil
        end
    end

    UIUtil.SetActive(this.loadingText, false)
    UIUtil.SetActive(this.noDataText, this.bindMaxCount <= 0)
    this.blackListRect:SetMaxDataCount(this.bindMaxCount)
    this.blackListRect:UpdateAllItems()
end

function ClubBlackRoomPanel.UpdateBindItemInfo(transform, idx)
    local item = this.GetBindInfoItem(transform)
    if IsNil(this.bindDatas[idx + 1]) then
        if idx > this.totalCount - 1 then
            UIUtil.SetActive(item.gameObject, false)
        else
            --此处处理服务器还未返回数据
            --需要提前显示列表item的UI
            --使用占位的方式 数据使用默认
            UIUtil.SetActive(item.groupNode, false)
            UIUtil.SetActive(item.dataLoadingNode, true)
        end
    else
        this.UpdateBindingItem(this.bindDatas[idx + 1], item, idx)
    end
end

function ClubBlackRoomPanel.UpdateBindingItem(data, item, idx)
    UIUtil.SetActive(item.gameObject, true)
    UIUtil.SetActive(item.groupNode.gameObject, true)
    UIUtil.SetActive(item.dataLoadingNode.gameObject, false)

    Functions.SetHeadImage(item.player1.headImage, data.player1Img)
    item.player1.nameText.text = data.player1Name
    item.player1.idText.text = data.player1Id

    Functions.SetHeadImage(item.player2.headImage, data.player2Img)
    item.player2.nameText.text = data.player2Name
    item.player2.idText.text = data.player2Id

    this:AddOnClick(item.relieveBtn, function()
        Alert.Prompt("确定解除绑定？",function()
            ClubManager.SendBlackRoomBind(1, data.player1Id, data.player2Id)
        end)
    end)
end

--获取战绩Item
function ClubBlackRoomPanel.GetBindInfoItem(transform)
    local id = transform.gameObject:GetInstanceID()
    local item = this.bindItems[id]
    if IsNil(item) then
        item = {}
        item.transform = transform
        item.gameObject = transform.gameObject
        item.groupNode = transform:Find("Group")
        item.dataLoadingNode = transform:Find("DataLoading")

        item.player1 = {}
        local playerTrans1 = item.groupNode:Find("Player1")
        item.player1.headImage = playerTrans1:Find("Head/Mask/HeadIcon"):GetComponent("Image")
        item.player1.nameText = playerTrans1:Find("NameText"):GetComponent("Text")
        item.player1.idText = playerTrans1:Find("IDText"):GetComponent("Text")

        item.player2 = {}
        local playerTrans2 = item.groupNode:Find("Player2")
        item.player2.headImage = playerTrans2:Find("Head/Mask/HeadIcon"):GetComponent("Image")
        item.player2.nameText = playerTrans2:Find("NameText"):GetComponent("Text")
        item.player2.idText = playerTrans2:Find("IDText"):GetComponent("Text")

        item.relieveBtn = item.groupNode:Find("RelieveBtn")
    end
    this.bindItems[id] = item
    return item
end

--绑定搜索完毕后调用  重新刷新绑定列表
function ClubBlackRoomPanel.OnSearchEndEditByBind()
    if this.searchIdInput.text == "" then
        this.playerId = 0
        this.SendGetBlackRoomList(1)
    end
end

function ClubBlackRoomPanel.OnClickCloseBtn()
    PanelManager.Close(PanelConfig.ClubBlackRoom)
end

function ClubBlackRoomPanel.OnClickSearchBtn()
    local text = this.searchIdInput.text
    if not string.IsNullOrEmpty(text) and string.len(text) == 6 then
        local num = tonumber(text)
        if num ~= nil then
            LockScreen(0.5)
            this.playerId = num
            this.SendGetBlackRoomList(1)
        else
            Toast.Show("请输入正确的玩家ID")
        end
    else
        Toast.Show("请输入正确的玩家ID")
    end
end

function ClubBlackRoomPanel.OnClickCreateBtn()
    PanelManager.Open(PanelConfig.ClubBlackRoomCreate)
end

function ClubBlackRoomPanel.SendGetBlackRoomList(page)
    ClubManager.SendGetBlackRoomList(page, this.playerId)
end

