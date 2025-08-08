ServiceChatPanel = ClassPanel("ServiceChatPanel")
local this = ServiceChatPanel

this.PageCount = 10
this.pageIndex = 1

--消息预制体
this.messageItemGO1 = nil
this.messageItemGO2 = nil
this.messageItems = {}
this.messageIndex = 0
this.totalHeight = 0
--最后发送时间
this.lastSendTime = 0

local maxWidth = 330
local maxHeight = 300
local viewportHeight = 367
local top = 5
local bottom = 0
local spacing = 20

function ServiceChatPanel:OnInitUI()
    this = self
    local content = this.transform:Find("Content")
    this.closeBtn = content:Find("Background/CloseButton")
    -- local left = content:Find("Left")
    this.playerScroll = content:Find("LeftScrollView")
    this.playerContent = this.playerScroll:Find("Viewport/Content")
    this.playerGroup = this.playerContent:GetComponent("ToggleGroup")
    this.scrollView = UIPageVerticalScrollView.New()
    this.scrollView.onSetItemCallback = this.OnSetItemCallback
    this.scrollView.onUpdateItemCallback = this.OnUpdateItemCallback
    this.scrollView.onNeedPageCallback = this.OnNeedPageCallback
    this.scrollView:Init(this.playerScroll, this.PageCount, 5, 0, 89, 10)

    local right = content:Find("Right")
    this.scrollRect = right:GetComponent("ScrollRect")
    this.messageContent = right:Find("Viewport/Content")
    this.messageItemGO1 = this.messageContent:Find("MessageItem1")
    this.messageItemGO2 = this.messageContent:Find("MessageItem2")

    local bottomTrans = content:Find("Bottom")
    this.inputField = bottomTrans:Find("InputField"):GetComponent("InputField")
    this.sendImageBtn = bottomTrans:Find("SendImageBtn")
    this.sendTextBtn = bottomTrans:Find("SendTextBtn")

    this.largerImageTrans = this.transform:Find("LargerImage")
    this.closeLargerBtn = this.largerImageTrans:Find("Mask")
    this.largerImage = this.largerImageTrans:Find("Image"):GetComponent("Image")
    this.AddUIListenerEvent()
end

function ServiceChatPanel:OnOpened(type, unionId)
    this.totalHeight = top
    this.AddListenerEvent()
    ServiceChatData.type = type
    ServiceChatData.curUnionId = unionId
    BaseTcpApi.SendGetServiceList(ServiceChatData.type, ServiceChatData.curUnionId)
end

function ServiceChatPanel:OnClosed()
    this.RemoveListenerEvent()
    this.pageIndex = 1
    this.scrollView:Reset()
    this.ResetViewport()
    ServiceChatMgr.Clear()
end

--------------------------------------
function ServiceChatPanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.sendImageBtn, this.OnSendImageBtnClick)
    this:AddOnClick(this.sendTextBtn, this.OnSendTextBtnClick)
    this:AddOnClick(this.closeLargerBtn, this.OnCloseLargerBtnClick)
end

function ServiceChatPanel.AddListenerEvent()

end

function ServiceChatPanel.RemoveListenerEvent()

end
-------------------按钮绑定事件-----------------------
function ServiceChatPanel.OnCloseBtnClick()
    PanelManager.Close(PanelConfig.ServiceChat)
end
--发送图片
function ServiceChatPanel.OnSendImageBtnClick()
    if os.time() - this.lastSendTime < 2 then
        Toast.Show("消息发送间隔为2秒")
        return
    end
    this.lastSendTime = os.time()
    local sendTime = os.timems()
    AppPlatformHelper.GetImagePathByPhoto(function(imagePath)
        ServiceChatMgr.UploadImage(imagePath, function(fileName)
            BaseTcpApi.SendChatInfo(ServiceChatData.type, ServiceChatData.curUnionId, ServiceChatData.playerId, ChatMessageType.Image, fileName, sendTime)
            local massegeData = ServiceChatData.NewChatMassegeData(ChatMessageType.Image, sendTime, UserData.GetUserId(), UserData.GetName(), UserData.GetHeadUrl(), ServiceChatData.playerId, fileName)
            ServiceChatData.AddTempMassegeData(massegeData)
            this.UpdateMassege(massegeData)
        end)
    end)
end

--发送文字
function ServiceChatPanel.OnSendTextBtnClick()
    if os.time() - this.lastSendTime < 2 then
        Toast.Show("消息发送间隔为2秒")
        return
    end
    this.lastSendTime = os.time()

    local text = this.inputField.text
    if string.IsNullOrEmpty(text) then
        Toast.Show("发送的内容不能为空")
        return
    end

    if SubStringGetTotalIndex(text) > 50 then
        Toast.Show("单次发送字数不能超过50字")
        return
    end
    local sendTime = os.timems()
    BaseTcpApi.SendChatInfo(ServiceChatData.type, ServiceChatData.curUnionId, ServiceChatData.playerId, ChatMessageType.Text, text, sendTime)
    local massegeData = ServiceChatData.NewChatMassegeData(ChatMessageType.Text, sendTime, UserData.GetUserId(), UserData.GetName(), UserData.GetHeadUrl(), ServiceChatData.playerId, text)
    ServiceChatData.AddTempMassegeData(massegeData)
    this.UpdateMassege(massegeData)
    this.inputField.text = ""
end
-------------------按钮绑定事件end---------------------------------
-----------------------------------------------------
--更新聊天列表
function ServiceChatPanel.UpdatePlayerList(isSelected)
    local allCount = #ServiceChatData.playerDatas
    local allPage = math.ceil(allCount / this.PageCount)
    this.scrollView:Set(allPage, allCount)
    if isSelected then
        local selectedItem = this.scrollView:GetFirstItem()
        if selectedItem ~= nil then
            selectedItem.toggle.isOn = false
            selectedItem.toggle.isOn = true
        end
    end

    local ids = this.GetCurPagePlayerID()
    BaseTcpApi.SendPlayerStatus(ids)
end

--更新玩家Item
function ServiceChatPanel.UpdatePlayerItem(index)
    local item = this.scrollView:GetItemByIndex(index)
    if not IsNil(item) then
        this.OnUpdateItemCallback(item)
    end
end

--更新消息
function ServiceChatPanel.UpdateMassege(MassegeData)
    local isRight = UserData.GetUserId() == MassegeData.sendPlayerID
    local item = this.GetMassegeItem(isRight)
    item.sendTime = MassegeData.sendTime
    UIUtil.SetActive(item.gameObject, true)
    Functions.SetHeadImage(item.headImage, MassegeData.playerHeadUrl)
    UIUtil.SetActive(item.chatBg, MassegeData.type == ChatMessageType.Text)
    UIUtil.SetActive(item.chatImage.gameObject, MassegeData.type == ChatMessageType.Image)
    if MassegeData.type == ChatMessageType.Text then
        item.chatText.text = MassegeData.content
        local textWidth = item.chatText.preferredWidth
        if textWidth > maxWidth then
            textWidth = maxWidth
        end
        UIUtil.SetWidth(item.textRectTransform, textWidth)
        UIUtil.SetWidth(item.chatBg, textWidth + 30)
        local textHeight = item.chatText.preferredHeight
        UIUtil.SetHeight(item.textRectTransform, textHeight)
        UIUtil.SetHeight(item.chatBg, textHeight + 20)
        local itemHeight = textHeight + 45
        UIUtil.SetHeight(item.transform, itemHeight)
        this.SetContentHeight(itemHeight, true)
        item.itemHeight = itemHeight
    else
        --设置图片回调
        local callback = function(arg)
            ServiceChatMgr.OnImageLoadCompleted(arg)
            --设置图片原始大小
            item.chatImage:SetNativeSize()
            --计算图片缩放
            local imageWidth = UIUtil.GetWidth(item.imageRectTransform)
            local scaleX = 1
            local scaleY = 1
            if imageWidth > maxWidth then
                scaleX = maxWidth / imageWidth
            end
            local imageHeight = UIUtil.GetHeight(item.imageRectTransform)
            if imageHeight > maxHeight then
                scaleY = maxHeight / imageHeight
            end
            local scale = 1
            if scaleX > scaleY then
                scale = scaleY
            else
                scale = scaleX
            end
            UIUtil.SetLocalScale(item.imageRectTransform, scale, scale, 1)
            -- UIUtil.SetWidth(item.imageRectTransform, imageWidth)
            --设置消息Item高度
            local imageHeight = UIUtil.GetHeight(item.imageRectTransform)
            local itemHeight = (imageHeight + 20) * scale
            UIUtil.SetHeight(item.transform, itemHeight)
            this.SetContentHeight(itemHeight, true)
            item.itemHeight = itemHeight
        end
        -- local url = ServiceChatMgr.CheckPlayerHeadUrl(MassegeData.content)
        ServiceChatMgr.SetImage(item.chatImage, MassegeData.content, callback)
        this:AddOnClick(item.chatImage, function()
            this.OpenLargerImage(MassegeData.content)
        end)
    end
end

--移除已发送的消息
function ServiceChatPanel.RemoveMassegeItemBySendTime(time)
    local item = nil
    for i = 1, #this.messageItems do
        item = this.messageItems[i]
        if item.sendTime == time then
            item.isActive = false
            UIUtil.SetActive(item.gameObject, false)
            this.SetContentHeight(item.itemHeight, false)
            return
        end
    end
end
-------------------------------------------------------------------
-------------------------------------------------------------------
function ServiceChatPanel.OnSetItemCallback(item)
    item.nameText = item.transform:Find("NameText"):GetComponent("Text")
    item.idText = item.transform:Find("IDText"):GetComponent("Text")
    item.headImage = item.transform:Find("Head/Mask/Image"):GetComponent("Image")
    item.onLineIcon = item.transform:Find("OnLineIcon")
    item.offLineIcon = item.transform:Find("OffLineIcon")
    item.redIcon = item.transform:Find("RedIcon")
    item.toggle = item.transform:GetComponent("Toggle")
    item.toggle.group = this.playerGroup
end

function ServiceChatPanel.OnUpdateItemCallback(item)
    local playerData = ServiceChatData.playerDatas[item.dataIndex]
    if IsNil(playerData) then
    else
        item.nameText.text = playerData.playerName
        item.idText.text = playerData.playerId
        Functions.SetHeadImage(item.headImage, playerData.playerHeadUrl)
        UIUtil.SetActive(item.onLineIcon, playerData.isOnline)
        UIUtil.SetActive(item.offLineIcon, not playerData.isOnline)
        UIUtil.SetActive(item.redIcon, playerData.isUnread)
        this:AddOnToggle(item.toggle, function(isOn)
            if isOn then
                ServiceChatData.playerId = playerData.playerId
                this.ResetViewport()
                local data = ServiceChatMgr.GetMassegeDatasByPlayerId()
                for i = 1, #data do
                    this.UpdateMassege(data[i])
                end
                -----------------选中某个玩家聊天以后还需处理小红点数据
                playerData.isUnread = false
                ServiceChatMgr.WriteTotalPlayerData(ServiceChatData.type, ServiceChatData.curUnionId, ServiceChatData.playerDatas)
                ServiceChatMgr.RemoveUnreadInfo(ServiceChatData.type, ServiceChatData.curUnionId, playerData.playerId)
                UIUtil.SetActive(item.redIcon, playerData.isUnread)
            end
        end)
    end
end

function ServiceChatPanel.OnNeedPageCallback(pageIndex, needPage)
    LogError(">> ServiceChatPanel.OnNeedPageCallback > " .. pageIndex, needPage)
    this.pageIndex = pageIndex
    this.UpdatePlayerList(false)
    -- local ids = this.GetCurPagePlayerID()
    -- BaseTcpApi.SendPlayerStatus(ids)
end

--获取消息item
function ServiceChatPanel.GetMassegeItem(isRight)
    local item = nil
    for i = 1, #this.messageItems do
        item = this.messageItems[i]
        if item.isActive == false and item.isRight == isRight then
            item.isActive = true
            return item
        end
    end
    item = this.CreateMassegeItem(isRight)
    item.isActive = true
    return item
end

--消息item
function ServiceChatPanel.CreateMassegeItem(isRight)
    local item = {}
    item.isActive = false
    item.isRight = isRight
    local itemGO = nil
    if isRight then
        itemGO = CreateGO(this.messageItemGO2, this.messageContent)
    else
        itemGO = CreateGO(this.messageItemGO1, this.messageContent)
    end
    item.gameObject = itemGO
    item.transform = itemGO.transform
    item.headImage = itemGO.transform:Find("Head/Mask/Image"):GetComponent("Image")
    item.chatBg = itemGO.transform:Find("Chat")
    item.chatText = item.chatBg:Find("Text"):GetComponent("Text")
    item.textRectTransform = item.chatText.gameObject:GetComponent("RectTransform")
    item.chatImage = itemGO.transform:Find("Image"):GetComponent("Image")
    item.imageRectTransform = item.chatImage:GetComponent("RectTransform")
    item.imageBtn = item.chatImage:GetComponent("Button")
    table.insert(this.messageItems, item)
    return item
end

--重置所有消息item
function ServiceChatPanel.ResetTotalMassegeItem()
    local item = nil
    for i = 1, #this.messageItems do
        item = this.messageItems[i]
        item.isActive = false
        UIUtil.SetActive(item.gameObject, false)
    end
end

--设置高度
function ServiceChatPanel.SetContentHeight(itemHeight, isAdd)
    if isAdd then
        this.totalHeight = this.totalHeight + spacing + itemHeight
    else
        this.totalHeight = this.totalHeight - spacing - itemHeight
    end
    UIUtil.SetHeight(this.messageContent, this.totalHeight)
    this.scrollRect.verticalNormalizedPosition = 0
end

--清除聊天框所有消息
function ServiceChatPanel.ResetViewport()
    this.totalHeight = top
    UIUtil.SetHeight(this.messageContent, this.totalHeight)
    this.scrollRect.verticalNormalizedPosition = 0
    this.ResetTotalMassegeItem()
end

--获取当前页 显示的所有玩家的ID
function ServiceChatPanel.GetCurPagePlayerID()
    local ids = {}
    for i = 1, this.PageCount do
        local index = (this.pageIndex - 1) * this.PageCount + i
        if not IsNil(ServiceChatData.playerDatas[index]) then
            table.insert(ids, ServiceChatData.playerDatas[index].playerId)
        end
    end
    return ids
end

--关闭大图按钮事件
function ServiceChatPanel.OnCloseLargerBtnClick()
    this.CloseLargerImage()
end

--打开大图
function ServiceChatPanel.OpenLargerImage(content)
    local callback = function(arg)
        ServiceChatMgr.OnImageLoadCompleted(arg)
        --设置图片原始大小
        this.largerImage:SetNativeSize()
        --计算图片缩放
        local imageWidth = UIUtil.GetWidth(this.largerImage.transform)
        local scaleX = 1
        local scaleY = 1
        if imageWidth > 1280 then
            scaleX = 1280 / imageWidth
        end
        local imageHeight = UIUtil.GetHeight(this.largerImage.transform)
        if imageHeight > 720 then
            scaleY = 720 / imageHeight
        end
        local scale = 1
        if scaleX > scaleY then
            scale = scaleY
        else
            scale = scaleX
        end
        UIUtil.SetLocalScale(this.largerImage.transform, scale, scale, 1)
    end
    ServiceChatMgr.SetImage(this.largerImage, content, callback)
    UIUtil.SetActive(this.largerImageTrans, true)
end

--关闭大图
function ServiceChatPanel.CloseLargerImage()
    UIUtil.SetActive(this.largerImageTrans, false)
    this.largerImage.sprite = BaseResourcesMgr.imageNoneSprite
end