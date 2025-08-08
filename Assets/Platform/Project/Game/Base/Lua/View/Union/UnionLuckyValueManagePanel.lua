UnionLuckyValueManagePanel = ClassPanel("UnionLuckyValueManagePanel")
UnionLuckyValueManagePanel.backBtn = nil
UnionLuckyValueManagePanel.toggles = nil
UnionLuckyValueManagePanel.pages = nil
UnionLuckyValueManagePanel.curPageType = 0

UnionLuckyValueManagePanel.searchBtn = nil
UnionLuckyValueManagePanel.searchIdInput = nil
UnionLuckyValueManagePanel.lastBtn = nil
UnionLuckyValueManagePanel.nextBtn = nil
UnionLuckyValueManagePanel.pageNumText = nil

--当前页码信息
UnionLuckyValueManagePanel.curPageIdx = 0
UnionLuckyValueManagePanel.totalPage = 0
--是否进行过搜索
UnionLuckyValueManagePanel.isSearched = false
local this = UnionLuckyValueManagePanel
function UnionLuckyValueManagePanel:Awake()
    this = self
    this.backBtn = self:Find("Bgs/BackBtn")
    this.loadingText = self:Find("Content/LoadingText")
    this.noDataText = self:Find("Content/NoDataText")

    this.toggles = {}
    this.toggles[1] = this:Find("Content/Left/MemberDataListToggle")
    this.toggles[2] = this:Find("Content/Left/TodayRankToggle")
    this.toggles[3] = this:Find("Content/Left/YestodayRankToggle")
    this.toggles[4] = this:Find("Content/Left/SocreChangeToggle")

    this.pages = {}
    this.pages[1] = this:Find("Content/PersonalDataList")
    this.pages[2] = this:Find("Content/TodayRankingList")
    this.pages[3] = this:Find("Content/YestodayRankingList")
    this.pages[4] = this:Find("Content/ScoreChangeList")

    local bottom = this:Find("Content/Bottom")
    this.searchBtn = bottom:Find("SearchBtn")
    this.searchIdInputGo = bottom:Find("SearchInputField")
    this.searchIdInput = this.searchIdInputGo:GetComponent(TypeInputField)
    this.lastBtn = bottom:Find("LastBtn")
    this.nextBtn = bottom:Find("NextBtn")
    this.pageNumText = bottom:Find("PageText/Text")

    this:AddOnClick(this.lastBtn, this.OnClickLastPageBtn)
    this:AddOnClick(this.nextBtn, this.OnClickNextPageBtn)
    this:AddOnClick(this.backBtn, this.OnClickBackBtn)
    this:AddOnClick(this.searchBtn, this.OnClickSearchBtn)
    this.searchIdInput.onValueChanged:AddListener(this.OnInputFieldValueChanged)
end

function UnionLuckyValueManagePanel:OnOpened()
    AddMsg(CMD.Tcp.Union.S2C_Union_ScoreChange, this.OnTcpGetScoreChangeList)

    this.isSearched = false
    this.searchIdInput.text = ""
    for i, toggle in pairs(this.toggles) do
        UIUtil.SetToggle(toggle, i == 1)
    end
    for i, toggle in pairs(this.toggles) do
        this:AddOnToggle(toggle, function (isOn)
            if isOn then
                this.OnClickToggle(i)
            end
        end)
    end
    this.OnClickToggle(1)
end

function UnionLuckyValueManagePanel:OnClosed()
    LogError(">> UnionLuckyValueManagePanel:OnClosed")
    RemoveMsg(CMD.Tcp.Union.S2C_Union_ScoreChange, this.OnTcpGetScoreChangeList)
end

function UnionLuckyValueManagePanel.OnClickToggle(pageType)
    LockScreen(0.5)
    Log("OnClickToggle", this.curPageType, pageType, this.isSearched, this.toggles, this.pages)
    if this.curPageType == pageType and this.isSearched == false then
        return
    end
    this.isSearched = false
    this.curPageType = pageType
    for page, pageTran in pairs(this.pages) do
        UIUtil.SetActive(pageTran, false)
    end
    if pageType == 1 then
        UIUtil.SetActive(this.searchBtn, true)
        UIUtil.SetActive(this.searchIdInputGo, true)
        this.searchIdInput.text = ""
        UnionManager.SendGetLuckyMemberList(1, 0)
    elseif pageType == 2 then
        UIUtil.SetActive(this.searchBtn, false)
        UIUtil.SetActive(this.searchIdInputGo, false)
        UnionManager.SendGetTodayRankingList(1)
    elseif pageType == 3 then
        UIUtil.SetActive(this.searchBtn, false)
        UIUtil.SetActive(this.searchIdInputGo, false)
        UnionManager.SendGetYestodayRankingList(1)
    elseif pageType == 4 then
        UIUtil.SetActive(this.searchBtn, false)
        UIUtil.SetActive(this.searchIdInputGo, false)
        UnionManager.SendGetScoreChangeList(nil, 1, 7)
    end
    UIUtil.SetActive(this.loadingText, true)
    UIUtil.SetActive(this.noDataText, false)
end

function UnionLuckyValueManagePanel.UpdateMemberDataList(data)
    this.curPageIdx = data.pageIndex
    this.totalPage = Functions.CheckPageTotal(data.allPage)
    UIUtil.SetText(this.pageNumText, tostring(this.curPageIdx) .. "/" .. tostring(this.totalPage))
    local list = data.list
    if GetTableSize(list) > 0 then
        UIUtil.SetActive(this.loadingText, false)
        UIUtil.SetActive(this.noDataText, false)
        local pageTran = this.pages[this.curPageType]
        UIUtil.SetActive(pageTran, true)
        local pageCount = 5
        local listTran = pageTran:Find("List")
        local childCount = listTran.childCount
        local itemTran = nil
        for i = 1, pageCount do
            local itemData = nil
            itemTran = listTran:GetChild(i - 1)
            itemData = list[i]
            if itemTran ~= nil then
                if itemData ~= nil then
                    UIUtil.SetActive(itemTran, true)
                    Functions.SetHeadImage(itemTran:Find("Head/Mask/HeadIcon"):GetComponent(TypeImage), itemData.pIcon)
                    UIUtil.SetText(itemTran:Find("IdText"), tostring(itemData.pId))
                    UIUtil.SetText(itemTran:Find("NameText"), tostring(itemData.pName))
                    UIUtil.SetText(itemTran:Find("LuckyValue"), tostring(itemData.luckyNum))
                    UIUtil.SetText(itemTran:Find("EmotionValue"), math.PreciseDecimal(itemData.bNum, 2))
                    this:AddOnClick(itemTran:Find("PersonalDataBtn"), function()
                        PanelManager.Open(PanelConfig.UnionScoreManager, itemData.pId)
                    end)
                    this:AddOnClick(itemTran:Find("IntegralManageBtn"), function()
                        PanelManager.Open(PanelConfig.UnionSetScore, itemData.pId)
                    end)
                else
                    UIUtil.SetActive(itemTran, false)
                end
            end
        end
    else
        local pageTran = this.pages[this.curPageType]
        UIUtil.SetActive(pageTran, false)
        UIUtil.SetActive(this.loadingText, false)
        UIUtil.SetActive(this.noDataText, true)
    end
end

function UnionLuckyValueManagePanel.UpdateTodayRankingList(data)
    this.curPageIdx = data.pageIndex
    this.totalPage = Functions.CheckPageTotal(data.allPage)
    UIUtil.SetText(this.pageNumText, tostring(this.curPageIdx) .. "/" .. tostring(this.totalPage))
    local list = data.list
    if GetTableSize(list) > 0 then
        UIUtil.SetActive(this.loadingText, false)
        UIUtil.SetActive(this.noDataText, false)
        local pageTran = this.pages[this.curPageType]
        UIUtil.SetActive(pageTran, true)
        local pageCount = 5
        local listTran = pageTran:Find("List")
        local childCount = listTran.childCount
        local itemTran = nil
        local itemData = nil
        for i = 1, pageCount do
            itemTran = listTran:GetChild(i - 1)
            itemData = list[i]
            if itemTran ~= nil then
                if itemData ~= nil then
                    UIUtil.SetActive(itemTran, true)
                    Functions.SetHeadImage(itemTran:Find("Head/Mask/HeadIcon"):GetComponent(TypeImage), itemData.pIcon)
                    UIUtil.SetText(itemTran:Find("IdText"), tostring(itemData.pId))
                    UIUtil.SetText(itemTran:Find("NameText"), tostring(itemData.pName))
                    UIUtil.SetText(itemTran:Find("WinTimes"), tostring(itemData.winNum))
                    UIUtil.SetText(itemTran:Find("LostTimes"), tostring(itemData.loseNum))
                    UIUtil.SetText(itemTran:Find("TotalTimes"), tostring(itemData.totalNum))
                    UIUtil.SetText(itemTran:Find("WinScore"), tostring(itemData.winScore))
                    UIUtil.SetText(itemTran:Find("LostScore"), tostring(itemData.loseScore))
                    UIUtil.SetText(itemTran:Find("TotalScore"), tostring(itemData.totalScore))
                else
                    UIUtil.SetActive(itemTran, false)
                end
            end
        end
    else
        UIUtil.SetActive(this.loadingText, false)
        UIUtil.SetActive(this.noDataText, true)
    end
end

function UnionLuckyValueManagePanel.UpdateYestodayRankingList(data)
    this.UpdateTodayRankingList(data)
end

function UnionLuckyValueManagePanel.OnClickSearchBtn()
    local text = this.searchIdInput.text

    if string.IsNullOrEmpty(text) then
        if this.isSearched then
            LockScreen(0.5)
            this.isSearched = false
            UnionManager.SendGetLuckyMemberList(1, 0)
        end
    elseif string.len(text) == 6 then
        local num = tonumber(text)
        if num ~= nil then
            LockScreen(0.5)
            this.isSearched = true
            UnionManager.SendGetLuckyMemberList(1, num)
        else
            Toast.Show("请输入正确的玩家ID")
        end
    else
        Toast.Show("请输入正确的玩家ID")
    end
end

--获取搜索玩家ID
function UnionLuckyValueManagePanel.GetSearchId()
    local text = this.searchIdInput.text
    if not string.IsNullOrEmpty(text) and string.len(text) == 6 then
        local num = tonumber(text)
        if num ~= nil then
           return num
        end
    end
    return 0
end

function UnionLuckyValueManagePanel.OnClickBackBtn()
    PanelManager.Close(PanelConfig.UnionLuckyValueManage)
end

function UnionLuckyValueManagePanel.OnClickLastPageBtn()
    if this.curPageIdx <= 1 then
        Toast.Show("当前已是首页")
    else
        if this.curPageType == 1 then
            if this.isSearched then
                UnionManager.SendGetLuckyMemberList(this.curPageIdx - 1, this.GetSearchId())
            else
                UnionManager.SendGetLuckyMemberList(this.curPageIdx - 1, 0)
            end
        elseif this.curPageType == 2 then
            UnionManager.SendGetTodayRankingList(this.curPageIdx - 1)
        elseif this.curPageType == 3 then
            UnionManager.SendGetYestodayRankingList(this.curPageIdx - 1)
        elseif this.curPageType == 4 then
            UnionManager.SendGetScoreChangeList(nil, this.curPageIdx - 1, 7)
        end
    end
end

function UnionLuckyValueManagePanel.OnClickNextPageBtn()
    if this.curPageIdx >= this.totalPage then
        Toast.Show("当前已是尾页")
    else
        if this.curPageType == 1 then
            if this.isSearched then
                UnionManager.SendGetLuckyMemberList(this.curPageIdx + 1, this.GetSearchId())
            else
                UnionManager.SendGetLuckyMemberList(this.curPageIdx + 1, 0)
            end
        elseif this.curPageType == 2 then
            UnionManager.SendGetTodayRankingList(this.curPageIdx + 1)
        elseif this.curPageType == 3 then
            UnionManager.SendGetYestodayRankingList(this.curPageIdx + 1)
        elseif this.curPageType == 4 then
            UnionManager.SendGetScoreChangeList(nil, this.curPageIdx + 1, 7)
        end
    end
end


function UnionLuckyValueManagePanel.OnTcpGetScoreChangeList(data)
    if data.code == 0 then
        this.UpdateSocreChangeDataList(data.data)
    else
        UnionManager.ShowError(data.code)
    end
end


function UnionLuckyValueManagePanel.UpdateSocreChangeDataList(data)
    if this.curPageType ~= 4 then
        return
    end
    this.curPageIdx = data.page
    this.totalPage = data.totalPage
    if this.totalPage < 1 then
        this.totalPage = 1
    end
    UIUtil.SetText(this.pageNumText, tostring(this.curPageIdx) .. "/" .. tostring(this.totalPage))
    local list = data.list
    if GetTableSize(list) > 0 then
        UIUtil.SetActive(this.loadingText, false)
        UIUtil.SetActive(this.noDataText, false)
        local pageTran = this.pages[this.curPageType]
        UIUtil.SetActive(pageTran, true)
        local pageCount = 7
        local listTran = pageTran:Find("List")
        local childCount = listTran.childCount
        local itemTran = nil
        for i = 1, pageCount do
            local itemData = nil
            itemTran = listTran:GetChild(i - 1)
            itemData = list[i]
            if itemTran ~= nil then
                if itemData ~= nil then
                    UIUtil.SetActive(itemTran, true)
                    UIUtil.SetText(itemTran:Find("NameText"), itemData.userName)
                    UIUtil.SetText(itemTran:Find("NameText2"), itemData.userName2)
                    UIUtil.SetText(itemTran:Find("ScoreText"), tostring(itemData.num))
                    UIUtil.SetText(itemTran:Find("TimeInfo"), os.date("%m/%d %H:%M", itemData.time / 1000))
                else
                    UIUtil.SetActive(itemTran, false)
                end
            end
        end
    else
        UIUtil.SetActive(this.loadingText, false)
        UIUtil.SetActive(this.noDataText, true)
    end
end

function UnionLuckyValueManagePanel.OnInputFieldValueChanged(text)
    if this.isSearched then
        if string.IsNullOrEmpty(text) then
            UnionManager.SendGetLuckyMemberList(1, 0)
            this.isSearched = false
        end
    end
end