ClubLowerMemberPanel = ClassPanel("ClubLowerMemberPanel")
local this = ClubLowerMemberPanel
ClubLowerMemberPanel.backBtn = nil
ClubLowerMemberPanel.searchBtn = nil
ClubLowerMemberPanel.searchIdInput = nil
ClubLowerMemberPanel.lastBtn = nil
ClubLowerMemberPanel.nextBtn = nil
ClubLowerMemberPanel.pageNumText = nil
ClubLowerMemberPanel.addPartnerBtn = nil
ClubLowerMemberPanel.pageList = nil
ClubLowerMemberPanel.itemGroups = nil
--当前页码信息
ClubLowerMemberPanel.curPageIdx = 0
ClubLowerMemberPanel.totalPage = 0

ClubPartnerPanel.isSearched = false
--当前谁的下属玩家
ClubPartnerPanel.curUid = 0
function ClubLowerMemberPanel:Awake()
    this = self
    this.backBtn = self:Find("Bgs/BackBtn")
    this.loadingText = self:Find("Content/LoadingText")
    this.noDataText = self:Find("Content/NoDataText")
    this.addPartnerBtn = self:Find("Content/InviteMemberBtn")

    this.searchBtn = self:Find("Content/SearchBtn")
    this.searchIdInput = self:Find("Content/SearchInputField")
    this.lastBtn = self:Find("Content/LastBtn")
    this.nextBtn = self:Find("Content/NextBtn")
    this.pageNumText = self:Find("Content/PageText/Text")

    local list = this:Find("Content/PartnerList")
    this.pageList = list
    this.itemGroups = {}
    local childCount = list.childCount
    local itemTran = nil
    for i = 1, childCount do
        itemTran = list:GetChild(i - 1)
        this.itemGroups[i] = {
            transform = itemTran,
            headImg = itemTran:Find("Head/Mask/HeadIcon"):GetComponent(TypeImage),
            nameText = itemTran:Find("NameText"),
            idText = itemTran:Find("IdText"),
            percentText = itemTran:Find("CooperationPercentText"),
            emotionText = itemTran:Find("EmationText"),
            todayText = itemTran:Find("TodayText"),
            yestodayText = itemTran:Find("YestodayText"),
            setToParterBtn = itemTran:Find("SetToParterBtn"),
        }
    end
end

function ClubLowerMemberPanel:OnOpened(uid)
    this.curUid = uid
    this.isSearched = false
    this:AddOnClick(this.lastBtn, this.OnClickLastPageBtn)
    this:AddOnClick(this.nextBtn, this.OnClickNextPageBtn)
    this:AddOnClick(this.backBtn, this.OnClickBackBtn)
    this:AddOnClick(this.addPartnerBtn, this.OnClickAddPartnerBtn)
    this:AddOnClick(this.searchBtn, this.OnClickSearchBtn)
    ClubManager.SendGetPartnerList(2, this.curUid, 1, 0)

    local inputField = this.searchIdInput:GetComponent(TypeInputField)
    inputField.onValueChanged:RemoveAllListeners()
    inputField.onValueChanged:AddListener(this.OnInputFieldValueChanged)
end

function ClubLowerMemberPanel.UpdateDataList(data)
    this.curPageIdx = data.page
    this.totalPage = data.totalPage
    UIUtil.SetText(this.pageNumText, tostring(this.curPageIdx) .. "/" .. tostring(this.totalPage))
    local pageCount = 4
    local list = data.list
    if GetTableSize(list) > 0 then
        UIUtil.SetActive(this.loadingText, false)
        UIUtil.SetActive(this.noDataText, false)
        UIUtil.SetActive(this.pageList, true)
        local itemGroup = nil
        for i = 1, pageCount do
            local itemData = nil
            itemGroup = this.itemGroups[i]
            itemData = list[i]
            if itemGroup ~= nil then
                if itemData ~= nil then
                    UIUtil.SetActive(itemGroup.transform, true)
                    Functions.SetHeadImage(itemGroup.headImg, itemData.pIcon)
                    UIUtil.SetText(itemGroup.idText, ClubData.GetUidString(itemData.pId))
                    UIUtil.SetText(itemGroup.nameText, tostring(itemData.pName))
                    UIUtil.SetText(itemGroup.percentText, tostring(itemData.per) .. "%")
                    UIUtil.SetText(itemGroup.emotionText, tostring(itemData.totalN))
                    UIUtil.SetText(itemGroup.todayText, tostring(itemData.tScore))
                    UIUtil.SetText(itemGroup.yestodayText, tostring(itemData.yScore))
                    UIUtil.SetText(itemGroup.yestodayScoreText, tostring(itemData.yPoint))
                    UIUtil.SetActive(itemGroup.setToParterBtn, this.curUid == UserData.GetUserId() and itemData.pId ~= this.curUid)
                    this:AddOnClick(itemGroup.setToParterBtn, function ()
                        Alert.Prompt("确定将当前玩家设为队长？", function ()
                            ClubManager.SendAddPartnerMember(itemData.pId)
                        end)
                    end)
                else
                    UIUtil.SetActive(itemGroup.transform, false)
                end
            end
        end
    else
        UIUtil.SetActive(this.loadingText, false)
        UIUtil.SetActive(this.noDataText, true)
        local itemGroup = nil
        for i = 1, pageCount do
            itemGroup = this.itemGroups[i]
            if itemGroup ~= nil then
                UIUtil.SetActive(itemGroup.transform, false)
            end
        end
    end
end

function ClubLowerMemberPanel.OnClickSearchBtn()
    local text = UIUtil.GetInputText(this.searchIdInput)
    if not string.IsNullOrEmpty(text) and string.len(text) == 6 then
        local num = tonumber(text)
        if num ~= nil then
            LockScreen(0.5)
            this.isSearched = true
            ClubManager.SendGetPartnerList(2, this.curUid, 1, num)
        else
            Toast.Show("请输入正确的玩家ID")
        end
    else
        Toast.Show("请输入正确的玩家ID")
    end
end

function ClubLowerMemberPanel.OnClickBackBtn()
    PanelManager.Close(PanelConfig.ClubLowerMember, true)
end

function ClubLowerMemberPanel.OnClickLastPageBtn()
    if this.curPageIdx <= 1 then
        Toast.Show("当前已是首页")
    else
        ClubManager.SendGetPartnerList(2, this.curUid, this.curPageIdx - 1, 0)
    end
end

function ClubLowerMemberPanel.OnClickNextPageBtn()
    if this.curPageIdx >= this.totalPage then
        Toast.Show("当前已是尾页")
    else
        ClubManager.SendGetPartnerList(2, this.curUid, this.curPageIdx + 1, 0)
    end
end

function ClubLowerMemberPanel.UpdateCurPanel()
    ClubManager.SendGetPartnerList(2, this.curUid, this.curPageIdx, 0)
end

function ClubLowerMemberPanel.OnClickAddPartnerBtn()
    PanelManager.Open(PanelConfig.ClubInputNumber, ClubInputNumberPanelType.AddMember, function (num)
        ClubManager.SendAddCommonMember(num)
        PanelManager.Close(PanelConfig.ClubInputNumber, true)
    end)
end

function ClubLowerMemberPanel.OnInputFieldValueChanged(text)
    if this.isSearched then
        if string.IsNullOrEmpty(text) then
            ClubManager.SendGetPartnerList(2, UserData.GetUserId(), 1, 0)
            this.isSearched = false
        end
    end
end