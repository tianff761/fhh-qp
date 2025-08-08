ClubBlackRoomMemberPanel = ClassPanel("ClubBlackRoomMemberPanel")
local this = ClubBlackRoomMemberPanel

this.memberItems = {}
this.playerId = 0
this.index = 0

function ClubBlackRoomMemberPanel:OnInitUI()
    this = self
    local content = self:Find("Content")
    this.closeBtn = content:Find("Background/CloseBtn")
    this.searchBtn = content:Find("SearchBtn")
    this.searchIdInput = content:Find("SearchInputField"):GetComponent("InputField")
    this.loadingText = content:Find("MemberScrollRect/LoadingText")
    this.noDataText = content:Find("MemberScrollRect/NoDataText")
    this.memberListRect = content:Find("MemberScrollRect"):GetComponent("ScrollRectExtension")
    this.AddUIListenerEvent()
end

function ClubBlackRoomMemberPanel:OnOpened(index)
    this.index = index
    this.RequestData()
    UIUtil.SetActive(this.loadingText, true)
    ClubManager.SendGetClubMemberList(1, this.playerId)
end

function ClubBlackRoomMemberPanel:OnClosed()
    this.playerId = 0
end

function ClubBlackRoomMemberPanel.AddUIListenerEvent()
    this.searchIdInput.onEndEdit:AddListener(this.OnSearchEndEditByMember)
    this:AddOnClick(this.closeBtn, this.OnClickCloseBtn)
    this:AddOnClick(this.searchBtn, this.OnClickSearchBtn)
end

function ClubBlackRoomMemberPanel.RequestData()
    --绑定列表初始化
    this.memberListRect.onGetLastPageDataAction = function(page)
        if page > 0 then
            ClubManager.SendGetClubMemberList(page + 1, this.playerId)
        end
    end
    this.memberListRect.onGetNextPageDataAction = function(page)
        if page < ClubData.totalMemberPage then
            ClubManager.SendGetClubMemberList(page + 1, this.playerId)
        end
    end
    this.memberListRect:SetMaxDataCount(0)
    this.memberListRect:InitItems()
    this.memberListRect.onUpdateItemAction = this.UpdateMemberItemInfo
end

function ClubBlackRoomMemberPanel.UpdateMemberList()
    UIUtil.SetActive(this.loadingText, false)
    UIUtil.SetActive(this.noDataText, ClubData.totalMemberCount <= 0)
    this.memberListRect:SetMaxDataCount(ClubData.totalMemberCount)
    this.memberListRect:UpdateAllItems()
end

function ClubBlackRoomMemberPanel.UpdateMemberItemInfo(transform, idx)
    local item = this.GetMemberInfoItem(transform)
    local data = ClubData.GetMemberItem(idx + 1)
    if IsNil(data) then
        if idx > ClubData.totalMemberCount - 1 then
            UIUtil.SetActive(item.gameObject, false)
        else
            --此处处理服务器还未返回数据
            --需要提前显示列表item的UI
            --使用占位的方式 数据使用默认
            UIUtil.SetActive(item.groupNode, false)
            UIUtil.SetActive(item.dataLoadingNode, true)
        end
    else
        this.UpdateMemberingItem(data, item, idx)
    end
end

function ClubBlackRoomMemberPanel.UpdateMemberingItem(data, item, idx)
    UIUtil.SetActive(item.gameObject, true)
    UIUtil.SetActive(item.groupNode.gameObject, true)
    UIUtil.SetActive(item.dataLoadingNode.gameObject, false)

    Functions.SetHeadImage(item.headImage, data.headIcon)
    item.nameText.text = data.name
    item.idText.text = data.uid
    item.timeText.text = os.date("%m/%d %H:%M", data.lastOnline / 1000)

    this:AddOnClick(item.addBtn, function()
        PanelManager.Close(PanelConfig.ClubBlackRoomMember)
        ClubBlackRoomCreatePanel.UpdatePlayerInfo(this.index, data)
    end)
end

--获取战绩Item
function ClubBlackRoomMemberPanel.GetMemberInfoItem(transform)
    local id = transform.gameObject:GetInstanceID()
    local item = this.memberItems[id]
    if IsNil(item) then
        item = {}
        item.transform = transform
        item.gameObject = transform.gameObject
        item.groupNode = transform:Find("Group")
        item.dataLoadingNode = transform:Find("DataLoading")
        item.headImage = item.groupNode:Find("Head/Mask/HeadIcon"):GetComponent("Image")
        item.nameText = item.groupNode:Find("NameText"):GetComponent("Text")
        item.idText = item.groupNode:Find("IdText"):GetComponent("Text")
        item.timeText = item.groupNode:Find("TimeText"):GetComponent("Text")
        item.addBtn = item.groupNode:Find("AddBtn"):GetComponent("Button")
    end
    this.memberItems[id] = item
    return item
end

--绑定搜索完毕后调用  重新刷新绑定列表
function ClubBlackRoomMemberPanel.OnSearchEndEditByMember()
    if this.searchIdInput.text == "" then
        this.playerId = 0
        ClubManager.SendGetClubMemberList(1, this.playerId)
    end
end

function ClubBlackRoomMemberPanel.OnClickCloseBtn()
    PanelManager.Close(PanelConfig.ClubBlackRoomMember)
end

function ClubBlackRoomMemberPanel.OnClickSearchBtn()
    local text = this.searchIdInput.text
    if not string.IsNullOrEmpty(text) and string.len(text) == 6 then
        local num = tonumber(text)
        if num ~= nil then
            LockScreen(0.5)
            this.playerId = num
            ClubManager.SendGetClubMemberList(1, this.playerId)
        else
            Toast.Show("请输入正确的玩家ID")
        end
    else
        Toast.Show("请输入正确的玩家ID")
    end
end

