ClubLuckyValueManagePanel = ClassPanel("ClubLuckyValueManagePanel")
ClubLuckyValueManagePanel.backBtn = nil
ClubLuckyValueManagePanel.toggles = nil
ClubLuckyValueManagePanel.pages = nil
ClubLuckyValueManagePanel.curPageType = 0

ClubLuckyValueManagePanel.searchBtn = nil
ClubLuckyValueManagePanel.searchIdInput = nil
ClubLuckyValueManagePanel.lastBtn = nil
ClubLuckyValueManagePanel.nextBtn = nil
ClubLuckyValueManagePanel.pageNumText = nil

--当前页码信息
ClubLuckyValueManagePanel.curPageIdx = 0
ClubLuckyValueManagePanel.totalPage = 0
--是否进行过搜索
ClubLuckyValueManagePanel.isSearched = false
local this = ClubLuckyValueManagePanel
function ClubLuckyValueManagePanel:Awake()
    this = self
    this.backBtn = self:Find("Bgs/BackBtn")
    this.loadingText = self:Find("Content/LoadingText")
    this.noDataText = self:Find("Content/NoDataText")

    this.toggles = {}
    this.toggles[1] = this:Find("Content/Left/MemberDataListToggle")
    this.toggles[2] = this:Find("Content/Left/TodayRankToggle")
    this.toggles[3] = this:Find("Content/Left/YestodayRankToggle")

    this.pages = {}
    this.pages[1] = this:Find("Content/PersonalDataList")
    this.pages[2] = this:Find("Content/TodayRankingList")
    this.pages[3] = this:Find("Content/YestodayRankingList")

    local bottom = this:Find("Content/Bottom")
    this.searchBtn = bottom:Find("SearchBtn")
    this.searchIdInput = bottom:Find("SearchInputField")
    this.lastBtn = bottom:Find("LastBtn")
    this.nextBtn = bottom:Find("NextBtn")
    this.pageNumText = bottom:Find("PageText/Text")
end

function ClubLuckyValueManagePanel:OnOpened()
    this.isSearched = false
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
    this:AddOnClick(this.lastBtn, this.OnClickLastPageBtn)
    this:AddOnClick(this.nextBtn, this.OnClickNextPageBtn)
    this:AddOnClick(this.backBtn, this.OnClickBackBtn)
end

function ClubLuckyValueManagePanel.OnClickToggle(pageType)
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
        UIUtil.SetActive(this.searchIdInput, true)
        ClubManager.SendGetLuckyMemberList(1, 0)
    elseif pageType == 2 then
        UIUtil.SetActive(this.searchBtn, false)
        UIUtil.SetActive(this.searchIdInput, false)
        ClubManager.SendGetTodayRankingList(1)
    elseif pageType == 3 then
        UIUtil.SetActive(this.searchBtn, false)
        UIUtil.SetActive(this.searchIdInput, false)
        ClubManager.SendGetYestodayRankingList(1)
    end
    UIUtil.SetActive(this.loadingText, true)
    UIUtil.SetActive(this.noDataText, false)
end

function ClubLuckyValueManagePanel.UpdateMemberDataList(data)
    this.curPageIdx = data.page
    this.totalPage = data.totalPage
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
                    UIUtil.SetText(itemTran:Find("EmotionValue"), tostring(itemData.bNum))
                    this:AddOnClick(itemTran:Find("PersonalDataBtn"), function()
                        PanelManager.Open(PanelConfig.ClubPersonalData, itemData.pId)
                    end)
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

function ClubLuckyValueManagePanel.UpdateTodayRankingList(data)
    this.curPageIdx = data.page
    this.totalPage = data.totalPage
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

function ClubLuckyValueManagePanel.UpdateYestodayRankingList(data)
    this.UpdateTodayRankingList(data)
end

function ClubLuckyValueManagePanel.OnClickSearchBtn()
    local text = UIUtil.GetInputText(this.searchIdInput)
    if not string.IsNullOrEmpty(text) and string.len(text) == 8 then
        local num = tonumber(text)
        if num ~= nil then
            LockScreen(0.5)
            this.isSearched = true
            if this.curPageType == 1 then
                ClubManager.SendGetClubMemberList(1, num)
            elseif this.curPageType == 2 then
                ClubManager.SendGetClubApplyList(1, num)
            end
        else
            Toast.Show("请输入正确的玩家ID")
        end
    else
        Toast.Show("请输入正确的玩家ID")
    end
end

function ClubLuckyValueManagePanel.OnClickBackBtn()
    PanelManager.Close(PanelConfig.ClubLuckyValueManage)
end

function ClubLuckyValueManagePanel.OnClickLastPageBtn()
    if this.curPageIdx <= 1 then
        Toast.Show("当前已是首页")
    else
        if this.curPageType == 1 then
            ClubManager.SendGetLuckyMemberList(this.curPageIdx - 1)
        elseif this.curPageType == 2 then
            ClubManager.SendGetTodayRankingList(this.curPageIdx - 1)
        elseif this.curPageType == 3 then
            ClubManager.SendGetYestodayRankingList(this.curPageIdx - 1)
        end
    end
end

function ClubLuckyValueManagePanel.OnClickNextPageBtn()
    if this.curPageIdx >= this.totalPage then
        Toast.Show("当前已是尾页")
    else
        if this.curPageType == 1 then
            ClubManager.SendGetLuckyMemberList(this.curPageIdx + 1)
        elseif this.curPageType == 2 then
            ClubManager.SendGetTodayRankingList(this.curPageIdx + 1)
        elseif this.curPageType == 3 then
            ClubManager.SendGetYestodayRankingList(this.curPageIdx + 1)
        end
    end
end