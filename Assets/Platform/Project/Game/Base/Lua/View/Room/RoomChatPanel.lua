RoomChatPanel = ClassPanel("RoomChatPanel")
local this = RoomChatPanel

local chatTextArr = nil
--发送时间间隔
local sendTime = 3
--是否可以发送
local isSend = true
--所有历史记录
local allHistoryDatas = {}
--屏蔽打字后的高度
local shieldWordsHight = 500
--原本额的高度
local originalHight = 580
-----------------------------
function RoomChatPanel:OnInitUI()
    this = self
    local content = self.transform:Find("Content")

    self.closeBtn = content:Find("Background/CloseBtn")

    --右边
    self.rightContent = content:Find("Right")
    --
    self.textToggle = self.rightContent:Find("TopBtns/TextToggle")
    self.emotionToggle = self.rightContent:Find("TopBtns/EmotionToggle")
    --
    self.textItemContent = self.rightContent:Find("TextScrollView/Viewport/Content")
    self.textItem = self.textItemContent:Find("Item")
    --
    self.emotionItemContent = self.rightContent:Find("EmotionScrollView/Viewport/Content")
    --下方
    self.downContent = content:Find("Down")
    --
    self.textInputField = self.downContent:Find("InputField"):GetComponent("InputField")
    self.sendBtn = self.downContent:Find("SendBtn")
    --左方
    self.leftContent = content:Find("Left")
    --
    self.historyChatScrollView = self.leftContent:Find("HistoryChatScrollView"):GetComponent("ScrollRect")
    self.historyChatItemCotent = self.leftContent:Find("HistoryChatScrollView/Viewport/Content")
    self.historyChatItem = self.historyChatItemCotent:Find("Item")

    chatTextArr = ChatModule.GetPhraseConfig()
    self:InitTextItems()
    self:InitEmotion()
    self:AddClickEvent()
end

function RoomChatPanel:OnOpened(arg)
    self:InitHistoryDatas()
    this.ShieldWords(arg.isShield)
    AddMsg(CMD.Game.UpdateHistoryData, this.UpdateHistoryDatas)
end

function RoomChatPanel:OnClosed()
    for i = 1, #allHistoryDatas do
        destroy(allHistoryDatas[i].gameObject)
    end
    allHistoryDatas = {}
    RemoveMsg(CMD.Game.UpdateHistoryData, this.UpdateHistoryDatas)
end

--设置表情
function RoomChatPanel:InitEmotion()
    for i = 0, self.emotionItemContent.childCount - 1 do
        local item = self.emotionItemContent:GetChild(i)
        self:AddOnClick(item, HandlerArgs(this.OnClickEmotionItem, i))
    end
end

--设置右边快捷文本内容
function RoomChatPanel:InitTextItems()
    if chatTextArr == nil then
        LogError(">>>>>>>>>> RoomChatPanel > InitTextItems > chatTextArr is nil")
        return
    end
    for i = 1, #chatTextArr do
        local item = CreateGO(self.textItem, self.textItemContent, i)
        UIUtil.SetActive(item, true)
        local itemText = item.transform:Find("Text"):GetComponent("Text")
        itemText.text = chatTextArr[i].text
        self:AddOnClick(item, HandlerArgs(this.OnClickTextItem, i))
    end
end

function RoomChatPanel:AddClickEvent()
    self:AddOnClick(self.sendBtn, this.OnClickSendBtn)
    self:AddOnClick(self.closeBtn, this.ClosePanel)
end

--点击表情聊天文本
function RoomChatPanel.OnClickEmotionItem(index)
    if not this:GetIsOnClick() then
        Toast.Show("请不要频繁操作")
        return
    end
    ChatModule.SendEmotionChatData(index + 1)
    this.ClosePanel()
end

--点击快捷聊天文本
function RoomChatPanel.OnClickTextItem(index)
    if not this:GetIsOnClick() then
        Toast.Show("请不要频繁操作")
        return
    end
    if chatTextArr[index] ~= nil then
        ChatModule.SendTextChatData(index)
        this.ClosePanel()
    end
end

--点击发送按钮
function RoomChatPanel.OnClickSendBtn()
    if not this:GetIsOnClick() then
        Toast.Show("请不要频繁操作")
        return
    end
    local str = this.textInputField.text
    if string.IsNullOrEmpty(str) then
        Toast.Show("输入文本不能为空")
        return
    end
    ChatModule.SendInputTextChatData(str)
    --发送后，清空文本
    this.textInputField.text = ""
    this.ClosePanel()
end

--判断是否可以点击发送
function RoomChatPanel:GetIsOnClick()
    if isSend then
        isSend = false
        Scheduler.scheduleOnceGlobal(
                function()
                    isSend = true
                end,
                sendTime
        )
        return true
    end
    return false
end

--更新历史记录
function RoomChatPanel.UpdateHistoryDatas(arg)
    if arg.type == 1 then
        this.AddOneHistory(arg.chatData)
    else
        this.DestroyHistory(arg.chatData)
    end
end

--初始化历史记录
function RoomChatPanel:InitHistoryDatas()
    for i = 1, ChatDataManager.GetHistoryCount() do
        local chatData = ChatDataManager.GetHistoryData(i)
        this.AddOneHistory(chatData)
    end
end

--添加一条历史记录
function RoomChatPanel.AddOneHistory(chatData)
    Log(">>>>>>>>>>>>>>>>>>> 增加一条历史记录", chatData)
    local item = CreateGO(this.historyChatItem, this.historyChatItemCotent, chatData.uid).transform
    local nameText = item:Find("Name"):GetComponent("Text")
    nameText.text = SubStringName(chatData.name, 8)
    local timeText = item:Find("Time"):GetComponent("Text")
    timeText.text = chatData.time
    local content = item:Find("Content")

    local strtextTra = content:Find("Text")
    local chatTra = content:Find("ChatBtn")
    local emotionTra = content:Find("Emotion")

    if chatData.type == ChatDataType.inuptChat or chatData.type == ChatDataType.phraseChat then
        UIUtil.SetActive(strtextTra, true)
        UIUtil.SetActive(chatTra, false)
        UIUtil.SetActive(emotionTra, false)
        strtextTra:GetComponent("Text").text = chatData.content
    elseif chatData.type == ChatDataType.voiceChat then
        UIUtil.SetActive(strtextTra, false)
        UIUtil.SetActive(chatTra, true)
        UIUtil.SetActive(emotionTra, false)

        this:AddOnClick(chatTra, HandlerArgs(this.OnClickPlayChatVoice, chatData.uid, item))
    elseif chatData.type == ChatDataType.emotionChat then
        UIUtil.SetActive(strtextTra, false)
        UIUtil.SetActive(chatTra, false)
        UIUtil.SetActive(emotionTra, true)
        local sprite = this.emotionItemContent:Find(tonumber(chatData.content) .. "/Item"):GetComponent("Image").sprite
        emotionTra:GetComponent("Image").sprite = sprite
    else
        UIUtil.SetActive(strtextTra, false)
        UIUtil.SetActive(chatTra, false)
        UIUtil.SetActive(emotionTra, false)
    end

    table.insert(allHistoryDatas, item)

    Scheduler.scheduleOnceGlobal(
            function()
                this.historyChatScrollView.verticalNormalizedPosition = 0
            end,
            0.05
    )
end

--点击播放语音
function RoomChatPanel.OnClickPlayChatVoice(index, item)
    -- local chatData = ChatDataManager.GetHistoryDataByUid(index)
    -- if chatData == nil then
    --     return

    -- end
    -- local icon = item:Find("Content/ChatBtn/Icon")
    -- local animation = icon:GetComponent("UISpriteAnimation")
    -- animation:Play()

    -- Scheduler.scheduleOnceGlobal(function()
    --     animation:Stop()
    --     icon:GetComponent("Image").sprite = animation.sprites[2]
    -- end, chatData.duration / 1000)

    ChatDataManager.PlayVoiceByIndex(index)
end

function RoomChatPanel.DestroyHistory(chatData)
    for i = 1, #allHistoryDatas do
        if allHistoryDatas[i].name == tostring(chatData.uid) then
            destroy(allHistoryDatas[i].gameObject)
            table.remove(allHistoryDatas, i)
            return
        end
    end
end

--屏蔽打字功能
function RoomChatPanel.ShieldWords(isShield)
    UIUtil.SetActive(this.downContent, not isShield)
end


function RoomChatPanel.ClosePanel()
    this:Close()
end