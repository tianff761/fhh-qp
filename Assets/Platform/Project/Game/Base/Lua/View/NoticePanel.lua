NoticePanel = ClassPanel("NoticePanel")

local this = NoticePanel
local noticeList = {}
local tempNoitceList = {}
local isPlayFinished = true
local notice = nil
local tempNotice = nil
local isPull = false

function NoticePanel:OnInitUI()
    this = self
    self.RollContent = self:Find("RollContent")
    self.content = self:Find("RollContent/Mask/Content")
    self.noticeTweener = self.content:GetComponent("TweenPosition")

    self.mask = self:Find("Mask")
    self.noticeScroll = self:Find("Mask/AllNoticeScrollView"):GetComponent("ScrollRectExtension")
    UIUtil.SetActive(self.mask.gameObject, false)
    self.pullBtn = self:Find("PullBtn"):GetComponent("Button")
    this:AddOnClick(self.pullBtn, this.OnPullClick)
    this:AddOnClick(self.mask, this.OnPullClick)
end

function NoticePanel:OnOpened()
    this = self
    self.isOpenPanel = true
    UnionManager.SendGetUnionNotice()

    --不是大厅就直接关闭，主要是针对异步加载的不同步问题
    if not GameSceneManager.IsLobbyScene() then
        this.Close()
        return
    end
    self.noticeTweener:AddLuaFinished(this.OnNoticeTweenerFinished)
    noticeList = {}
    tempNoitceList = {}
    this.AddListenerEvent()
    BaseTcpApi.SendActivity()

    -- this.noticeScroll.onGetLastPageDataAction = function(page)
    --     this.noticeScroll:SetMaxDataCount(#tempNoitceList)
    --     this.noticeScroll:UpdateAllItems()
    -- end
    -- this.noticeScroll.onGetNextPageDataAction = function(page)
    --     this.noticeScroll:SetMaxDataCount(#tempNoitceList)
    --     this.noticeScroll:UpdateAllItems()
    -- end

    this.noticeScroll:SetMaxDataCount(0)
    this.noticeScroll:InitItems()
    this.noticeScroll.onUpdateItemAction = this.UpdateNoticeItem
end

function NoticePanel.Close()
    PanelManager.Close(PanelConfig.Notice)
end

function NoticePanel.AddListenerEvent()
    AddMsg(CMD.Tcp.S2C_ScrollNotice, this.UpdateNotice)
    AddMsg(CMD.Tcp.S2C_Activity, this.CMD_Get_Activity)
    AddMsg(CMD.Tcp.Union.S2C_UnionNotice, this.OnTcpGetUnionNotice)
end

function NoticePanel.RemoveListenerEvent()
    RemoveMsg(CMD.Tcp.S2C_ScrollNotice, this.UpdateNotice)
    RemoveMsg(CMD.Tcp.S2C_Activity, this.CMD_Get_Activity)
    RemoveMsg(CMD.Tcp.Union.S2C_UnionNotice, this.OnTcpGetUnionNotice)
end

function NoticePanel.OnTcpGetUnionNotice(data)
    if data.code == 0 then
        UnionData.UnionNotice = tostring(data.data.unionNotice)
        notice = { noticeType = 0, gameId = "", title = "", notice = UnionData.UnionNotice --[["本游戏禁止赌博，仅为休闲竞技娱乐！"]] }
        if notice.notice ~= nil and notice.notice ~= "nil" and notice.notice ~= "" then
            this.PlayNotice()
        else
            this.Close()
        end
    else
        UnionManager.ShowError(data.code)
    end
end

--播放公告
function NoticePanel.PlayNotice()
    this.AddNotice(notice)
    this.PlayNextNotice()
end

--公告Tween完成
function NoticePanel.OnNoticeTweenerFinished()
    if tempNotice ~= nil then
        if #tempNoitceList >= 20 then
            table.remove(tempNoitceList, 20)
        end
        if tempNotice.noticeType ~= 0 and tempNotice.noticeType ~= 3 then
            table.insert(tempNoitceList, 1, tempNotice)
            if isPull then
                this.noticeScroll:SetMaxDataCount(#tempNoitceList)
                this.noticeScroll:UpdateAllItems()
            end
        end
    end
    if #noticeList == 0 then
        if notice ~= nil then
            this.AddNotice(notice)
        end
        this.noticeTweener:ResetToBeginning()
        this.PlayNextNotice()
    else
        this.noticeTweener:ResetToBeginning()
        this.PlayNextNotice()
    end
    isPlayFinished = true
end

--
function NoticePanel.PlayNextNotice()
    local data = noticeList[1]
    tempNotice = noticeList[1]
    table.remove(noticeList, 1)
    HideChildren(this.content)
    local notice = this.content:Find(data.noticeType)
    local titleRectTrans = notice:Find("Title"):GetComponent("RectTransform")
    local noticeRectTrans = notice:Find("Notice"):GetComponent("RectTransform")
    local titleText = notice:Find("Title"):GetComponent("Text")
    local noticeText = notice:Find("Notice"):GetComponent("Text")
    local iocnWidth = 0
    --local duration = 10
    local gameIcon = notice:Find("GameIcon")
    if data.noticeType == 1 then
        --1是特殊牌型
        iocnWidth = UIUtil.GetWidth(gameIcon)
        HideChildren(gameIcon)
        local icon = gameIcon:Find(data.gameId)
        UIUtil.SetActive(icon, true)
        --duration = 5
    elseif data.noticeType == 2 then
        --2是小喇叭
        iocnWidth = UIUtil.GetWidth(gameIcon)
        -- duration = 8
    else
        --duration = 10
    end
    titleText.text = data.title
    noticeText.text = data.notice or ""
    UIUtil.SetWidth(titleRectTrans, titleText.preferredWidth)
    UIUtil.SetWidth(noticeRectTrans, noticeText.preferredWidth)
    local width = iocnWidth + titleRectTrans.sizeDelta.x + noticeRectTrans.sizeDelta.x
    UIUtil.SetWidth(notice, width)
    UIUtil.SetWidth(this.content, width)
    local v3 = this.noticeTweener.from + Vector3.New(100, 0, 0)
    this.noticeTweener.to = Vector3.New(-width, v3.y, v3.z)
    local noticeWidth = UIUtil.GetWidth(this.RollContent)
    local moveDistance = noticeWidth + width
    local duration = moveDistance / 100
    --用于计算事件每秒75
    this.noticeTweener.duration = duration
    UIUtil.SetActive(notice, true)
    this.noticeTweener:ResetToBeginning()
    this.noticeTweener:PlayForward()
end

--大厅滚动的默认公告
function NoticePanel.CMD_Get_Activity(data)
    if data.code == 0 then
        if data.data.list ~= nil then
            local activity = {}
            for i = 1, #data.data.list do
                if data.data.list[i].type == 1 then
                    -- notice = {noticeType = 3, gameId = "", title = "【系统】", notice = data.data.list[i].msg}
                    this.AddNotice({ noticeType = 3, gameId = "", title = "【系统】", notice = data.data.list[i].msg })
                elseif data.data.list[i].type == 2 then
                    activity[1] = data.data.list[i]
                elseif data.data.list[i].type == 3 then
                    activity[2] = data.data.list[i]
                elseif data.data.list[i].type == 4 then
                    notice = { noticeType = 3, gameId = "", title = "【系统】", notice = data.data.list[i].msg }
                end
            end
            if UserData.IsFirstLogin() and #activity > 0 then
                PanelManager.Open(PanelConfig.Activity, activity)
            end
        end
    end
    UserData.SetIsFirstLogin(false)
end

function NoticePanel.UpdateNotice(data)
    if data.code == 0 then
        if data.data ~= nil then
            local title = ""
            local notice = ""
            local info = data.data
            if info.gameId == 0 then
                title = SubStringName(info.userName) .. "："
                this.AddNotice({ noticeType = 2, gameId = "", title = title, notice = string.gsub(info.msg, "\n", " "), userId = info.userId })
            else
                if NoticePanel.NoticeCardType[info.gameId][info.type] == nil then
                    return
                end
                title = "【" .. NoticePanel.NoticeCardType[info.gameId][info.type] .. "】："
                notice = this.NoticeContent(SubStringName(info.userName), info.gameId, info.type, info.gameType)
                this.AddNotice({ noticeType = 1, gameId = info.gameId, title = title, notice = notice, userId = info.userId })
            end
        end
    end
end

function NoticePanel.NoticeContent(name, gameId, cardType, playType)

end

function NoticePanel.OnPullClick()
    if isPull then
        UIUtil.SetActive(this.mask.gameObject, false)
        isPull = false
    else
        UIUtil.SetActive(this.mask.gameObject, true)
        isPull = true
        if #tempNoitceList > 0 then
            this.noticeScroll:SetMaxDataCount(#tempNoitceList)
            this.noticeScroll:UpdateAllItems()
        end
    end
end

function NoticePanel.UpdateNoticeItem(item, idx)
    if IsNil(tempNoitceList[idx + 1]) then
        if idx > #tempNoitceList - 1 then
            item.gameObject:SetActive(false)
        end
    else
        this.SetNoticeItem(item, tempNoitceList[idx + 1])
    end
end

function NoticePanel.SetNoticeItem(item, data)
    HideChildren(item)
    if data.noticeType == nil then
        return
    end
    local notice = item:Find(data.noticeType)
    local titleRectTrans = notice:Find("Title"):GetComponent("RectTransform")
    local noticeRectTrans = notice:Find("Notice"):GetComponent("RectTransform")
    local titleText = notice:Find("Title"):GetComponent("Text")
    local noticeText = notice:Find("Notice"):GetComponent("Text")
    local iocnWidth = 0
    local gameIcon = notice:Find("GameIcon")
    if data.noticeType == 1 then
        --1是特殊牌型
        iocnWidth = UIUtil.GetWidth(gameIcon)
        HideChildren(gameIcon)
        local icon = gameIcon:Find(data.gameId)
        UIUtil.SetActive(icon, true)
    elseif data.noticeType == 2 then
        --2是小喇叭
        iocnWidth = UIUtil.GetWidth(gameIcon)
    end
    titleText.text = data.title
    noticeText.text = data.notice or ""
    UIUtil.SetWidth(titleRectTrans, titleText.preferredWidth)
    UIUtil.SetWidth(noticeRectTrans, noticeText.preferredWidth)
    local width = iocnWidth + titleRectTrans.sizeDelta.x + noticeRectTrans.sizeDelta.x
    UIUtil.SetWidth(notice, width)
    -- UIUtil.SetWidth(item, width)
    UIUtil.SetActive(notice, true)
end

function NoticePanel.AddNotice(data)
    local count = #noticeList
    if count < 50 then
        table.insert(noticeList, data)
    else
        local notice = nil
        for i = 2, count do
            notice = noticeList[i]
            if notice.noticeType == 1 then
                table.remove(noticeList, i)
                table.insert(noticeList, data)
                return
            end
        end
        for i = 2, count do
            notice = noticeList[i]
            if notice.noticeType == 2 and notice.userId ~= UserData.GetUserId() then
                table.remove(noticeList, i)
                table.insert(noticeList, data)
                return
            end
        end
    end
end

--面板是否开启
function NoticePanel.IsOpen()
    return this.isOpenPanel
end

--关闭面板
function NoticePanel:OnClosed()
    this.RemoveListenerEvent()
    this.isOpenPanel = false
end