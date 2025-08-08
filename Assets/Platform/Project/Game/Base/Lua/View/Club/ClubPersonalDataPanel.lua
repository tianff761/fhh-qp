--todo:
ClubPersonalDataPanel = ClassPanel("ClubPersonalDataPanel")
ClubPersonalDataPanel.backBtn = nil
ClubPersonalDataPanel.toggles = nil
ClubPersonalDataPanel.pages = nil
ClubPersonalDataPanel.curPageType = 0

ClubPersonalDataPanel.searchBtn = nil
ClubPersonalDataPanel.searchIdInput = nil
ClubPersonalDataPanel.lastBtn = nil
ClubPersonalDataPanel.nextBtn = nil
ClubPersonalDataPanel.pageNumText = nil

--当前页码信息
ClubPersonalDataPanel.curPageIdx = 0
ClubPersonalDataPanel.totalPage = 0
ClubPersonalDataPanel.backBtn = nil
--当前界面数据所关联的玩家
ClubPersonalDataPanel.curUid = 0
local this = ClubPersonalDataPanel
function ClubPersonalDataPanel:Awake()
    this = self
    this.backBtn = self:Find("Bgs/BackBtn")
    this.loadingText = self:Find("Content/LoadingText")
    this.noDataText = self:Find("Content/NoDataText")

    this.toggles = {}
    this.toggles[1] = this:Find("Content/Left/GameScoreChangeToggle")
    this.toggles[2] = this:Find("Content/Left/DonateScoreToggle")

    this.pages = {}
    this.pages[1] = this:Find("Content/GameScoreChangeList")
    this.pages[2] = this:Find("Content/DonateScoreList")

    this.lastBtn = this:Find("Content/LastBtn")
    this.nextBtn = this:Find("Content/NextBtn")
    this.pageNumText = this:Find("Content/PageText/Text")
end

function ClubPersonalDataPanel:OnOpened(uid)
    this.curUid = uid
    for i, toggle in pairs(this.toggles) do
        UIUtil.SetToggle(toggle, i == 1)
        if i == 2 then
            UIUtil.SetToggle(toggle, false)
        end
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

function ClubPersonalDataPanel.OnClickToggle(pageType)
    LockScreen(0.5)
    Log("OnClickToggle", this.curPageType, pageType, this.toggles, this.pages)
    if this.curPageType == pageType then
        return
    end
    this.curPageType = pageType
    for page, pageTran in pairs(this.pages) do
        UIUtil.SetActive(pageTran, false)
    end
    if pageType == 1 then
        UIUtil.SetActive(this.searchBtn, true)
        UIUtil.SetActive(this.searchIdInput, true)
        ClubManager.SendGameScoreChangeList(1, this.curUid)
    end
    UIUtil.SetActive(this.loadingText, true)
    UIUtil.SetActive(this.noDataText, false)
end

function ClubPersonalDataPanel.OnClickBackBtn()
    PanelManager.Close(PanelConfig.ClubPersonalData)
end


function ClubPersonalDataPanel.OnClickLastPageBtn()
    if this.curPageIdx <= 1 then
        Toast.Show("当前已是首页")
    else
        ClubManager.SendGameScoreChangeList(this.curPageIdx - 1, this.curUid)
    end
end

function ClubPersonalDataPanel.OnClickNextPageBtn()
    if this.curPageIdx >= this.totalPage then
        Toast.Show("当前已是尾页")
    else
        ClubManager.SendGameScoreChangeList(this.curPageIdx + 1, this.curUid)
    end
end

function ClubPersonalDataPanel.UpdateGameChangeDataList(data)
    Log("..................", data)
    this.curPageIdx = data.page
    this.totalPage = data.totalPage
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
                    UIUtil.SetText(itemTran:Find("RoomText"), tostring(itemData.roomId))
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

function ClubPersonalDataPanel.UpdateLuckyValueChangeDataList(data)
    this.curPageIdx = data.pageIndex
    this.totalPage = Functions.CheckPageTotal(data.allPage)
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
                    UIUtil.SetText(itemTran:Find("TypeText"), "赠送积分")
                    --UIUtil.SetText(itemTran:Find("UidText"), tostring(itemData.cPlayer))
                    UIUtil.SetText(itemTran:Find("UidText"), ClubData.GetUidString(itemData.cPlayer))
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
