MessagePanel = ClassPanel("MessagePanel")
MessagePanel.backBtn = nil
MessagePanel.toggles = nil
MessagePanel.pages = nil
MessagePanel.curMessageType = MessageType.None

MessagePanel.lastBtn = nil
MessagePanel.nextBtn = nil
MessagePanel.pageNumText = nil

--当前页码信息
MessagePanel.curPageIdx = 1
MessagePanel.totalPage = 1
MessagePanel.backBtn = nil
MessagePanel.btnClickTime = 0

local this = MessagePanel
function MessagePanel:Awake()
    this = self
    this.backBtn = self:Find("Bgs/BackBtn")
    this.loadingText = self:Find("Content/LoadingText")
    this.noDataText = self:Find("Content/NoDataText")

    this.toggles = {}
    this.toggles[MessageType.Message] = this:Find("Content/Left/MessageToggle")
    this.toggles[MessageType.Recruit] = this:Find("Content/Left/RecruitToggle")
    this.toggles[MessageType.Notice] = this:Find("Content/Left/NoticeToggle")

    this.pages = {}
    this.pages[MessageType.Message] = this:Find("Content/MessagePage")
    this.pages[MessageType.Recruit] = this:Find("Content/RecruitPage")
    this.pages[MessageType.Notice] = this:Find("Content/NoticePage")

    this.msgListGo = this:Find("Content/MessagePage/List").gameObject

    this.lastBtn = this:Find("Content/LastBtn")
    this.nextBtn = this:Find("Content/NextBtn")
    this.pageNumText = this:Find("Content/PageText/Text")

    this.RecruitPageImg = this:Find("Content/RecruitPage"):GetComponent(TypeImage)
    this.NoticePageImg = this:Find("Content/NoticePage"):GetComponent(TypeImage)
end

function MessagePanel.DownloadRecruitImg()
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    local url = "http://xycdown.aisign.top/web/notice.png?t=" .. 132131231--tostring(os.time()):reverse() .. math.random(1, 99999)
    LogError("url", url)
    Functions.SetNetImage(this.RecruitPageImg, url)
end

function MessagePanel:OnOpened(messageType)
    --this.DownloadRecruitImg()
    this.curMessageType = MessageType.None
    if messageType == nil then
        messageType = MessageType.Message
    end
    for i, toggle in pairs(this.toggles) do
        UIUtil.SetToggle(toggle, i == messageType)
    end
    for i, toggle in pairs(this.toggles) do
        this:AddOnToggle(toggle, function(isOn)
            if isOn then
                this.OnClickToggle(i)
            end
        end)
    end

    --this.OnClickToggle(messageType)
    this.OnClickToggle(MessageType.Recruit)
    this:AddOnClick(this.lastBtn, this.OnClickLastPageBtn)
    this:AddOnClick(this.nextBtn, this.OnClickNextPageBtn)
    this:AddOnClick(this.backBtn, this.OnClickBackBtn)

    AddEventListener(CMD.Tcp.S2C_GetMessageList, this.OnTcpGetMessageList)
    AddEventListener(CMD.Tcp.S2C_DealMessage, this.OnTcpDealMessage)
end

function MessagePanel:OnClosed()
    RemoveEventListener(CMD.Tcp.S2C_GetMessageList, this.OnTcpGetMessageList)
    RemoveEventListener(CMD.Tcp.S2C_DealMessage, this.OnTcpDealMessage)
end

function MessagePanel.OnClickToggle(pageType)
    LockScreen(0.5)
    --if this.curMessageType == pageType then
    --    return
    --end
    this.curMessageType = pageType
    -- for page, pageTran in pairs(this.pages) do
    --     UIUtil.SetActive(pageTran, false)
    -- end
    UIUtil.SetActive(this.RecruitPageImg.gameObject, pageType == MessageType.Recruit)
    UIUtil.SetActive(this.NoticePageImg.gameObject, pageType == MessageType.Notice)
    if pageType == MessageType.Message then
        this.SendGetMessageList(0)
        UIUtil.SetActive(this.loadingText, true)
        UIUtil.SetActive(this.noDataText, false)
    end
end

function MessagePanel.OnClickBackBtn()
    PanelManager.Close(PanelConfig.Message)
end

function MessagePanel.UpdateMessageList(data)
    this.curPageIdx = data.page

    this.totalPage = data.totalPage
    if this.totalPage < 1 then
        this.totalPage = 1
    end

    UIUtil.SetText(this.pageNumText, tostring(this.curPageIdx) .. "/" .. tostring(this.totalPage))
    local list = data.list
    local page = this.pages[this.curMessageType]
    if GetTableSize(list) > 0 then
        local itemTran = nil
        local okBtn = nil
        local agreeBtn = nil
        local refuseBtn = nil
        UIUtil.SetActive(this.msgListGo, true)
        UIUtil.SetActive(this.loadingText, false)
        UIUtil.SetActive(this.noDataText, false)
        for i = 1, 6 do
            itemTran = page:Find("List/Item" .. tostring(i))
            local itemData = list[i]
            if itemData == nil then
                UIUtil.SetActive(itemTran, false)
            else
                UIUtil.SetActive(itemTran, true)
                UIUtil.SetText(itemTran:Find("Content"), tostring(itemData.content))
                UIUtil.SetText(itemTran:Find("Time"), os.date("%Y-%m-%d\n%H:%M:%S", itemData.time / 1000))
                okBtn = itemTran:Find("OKBtn")
                agreeBtn = itemTran:Find("AgreeBtn")
                refuseBtn = itemTran:Find("RefuseBtn")
                --1--通知消息  2--俱乐部邀请 3--联盟邀请
                if itemData.type == 1 then
                    UIUtil.SetActive(okBtn, true)
                    UIUtil.SetActive(agreeBtn, false)
                    UIUtil.SetActive(refuseBtn, false)
                    this:AddOnClick(okBtn, function()
                        this.SendDealMessage(itemData.msgId, -1)
                    end)
                elseif itemData.type == 2 or itemData.type == 3 then
                    UIUtil.SetActive(okBtn, false)
                    UIUtil.SetActive(agreeBtn, true)
                    UIUtil.SetActive(refuseBtn, true)
                    this:AddOnClick(agreeBtn, function()
                        this.SendDealMessage(itemData.msgId, 0)
                    end)
                    this:AddOnClick(refuseBtn, function()
                        this.SendDealMessage(itemData.msgId, 1)
                    end)
                end
            end
        end
    else
        UIUtil.SetActive(this.msgListGo, false)
        UIUtil.SetActive(this.loadingText, false)
        UIUtil.SetActive(this.noDataText, true)
    end
end

function MessagePanel.OnClickLastPageBtn()
    if this.curPageIdx <= 1 then
        Toast.Show("当前已是首页")
    else
        if Time.realtimeSinceStartup - this.btnClickTime < 1 then
            Toast.Show("请稍后...")
            return
        end
        this.btnClickTime = Time.realtimeSinceStartup
        --
        if this.curMessageType == MessageType.Message then
            this.SendGetMessageList(this.curPageIdx - 1)
        end
    end
end

function MessagePanel.OnClickNextPageBtn()
    if this.curPageIdx >= this.totalPage then
        Toast.Show("当前已是尾页")
    else
        if Time.realtimeSinceStartup - this.btnClickTime < 1 then
            Toast.Show("请稍后...")
            return
        end
        this.btnClickTime = Time.realtimeSinceStartup
        --
        if this.curMessageType == MessageType.Message then
            this.SendGetMessageList(this.curPageIdx + 1)
        end
    end
end

function MessagePanel.SendGetMessageList(page)
    if page <= 0 then
        page = 1
    elseif page > this.totalPage then
        page = this.totalPage
    end
    SendTcpMsg(CMD.Tcp.C2S_GetMessageList, { page = page, num = 6 })
end

function MessagePanel.OnTcpGetMessageList(data)
    this.btnClickTime = 0
    if data.code == 0 then
        --this.UpdateMessageList(data.data)
    else
        this.ShowError(data.code)
    end
end

--option: 1 拒绝 0 同意  -1 删除消息
function MessagePanel.SendDealMessage(msgId, option)
    SendTcpMsg(CMD.Tcp.C2S_DealMessage, { msgId = msgId, option = option })
end

function MessagePanel.OnTcpDealMessage(data)
    --Log(".............", data)
    if data.code == 0 then
        this.SendGetMessageList(0)
        Toast.Show("操作成功")
        BaseTcpApi.SendGetRedPointInfo()
    else
        this.ShowError(data.code)
    end
end

function MessagePanel.ShowError(code)
    if code == 20004 then
        Toast.Show("加入的茶馆不存在")
    elseif code == 20012 then
        Toast.Show("玩家加入茶馆达上限")
    elseif code == 20012 then
        Toast.Show("玩家已经加入该茶馆了")
    else
        Toast.Show("数据错误")
    end
end