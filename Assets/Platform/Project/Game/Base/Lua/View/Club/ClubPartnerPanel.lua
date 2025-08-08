ClubPartnerPanel = ClassPanel("ClubPartnerPanel")
ClubPartnerPanel.backBtn = nil
ClubPartnerPanel.searchBtn = nil
ClubPartnerPanel.searchIdInput = nil
ClubPartnerPanel.lastBtn = nil
ClubPartnerPanel.nextBtn = nil
ClubPartnerPanel.pageNumText = nil
ClubPartnerPanel.addPartnerBtn = nil
ClubPartnerPanel.clearScoreBtn = nil
ClubPartnerPanel.pageList = nil
ClubPartnerPanel.itemGroups = nil
--当前页码信息
ClubPartnerPanel.curPageIdx = 0
ClubPartnerPanel.totalPage = 0

ClubPartnerPanel.isSearched = false
local this = ClubPartnerPanel
function ClubPartnerPanel:Awake()
    this = self
    this.backBtn = self:Find("Bgs/BackBtn")
    this.loadingText = self:Find("Content/LoadingText")
    this.noDataText = self:Find("Content/NoDataText")
    this.addPartnerBtn = self:Find("Content/AddPartnerBtn")
    this.clearScoreBtn = self:Find("Content/ClearScoreBtn")

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
            headBtn = itemTran:Find("Head/BorderBtn"),
            nameText = itemTran:Find("NameText"),
            idText = itemTran:Find("IdText"),
            numText1 = itemTran:Find("NumText1"),
            numText2 = itemTran:Find("NumText2"),
            numText3 = itemTran:Find("NumText3"),
            -- lowerPatnerBtn = itemTran:Find("Btns/LowerPartnerBtn"),
            lowerMemberBtn = itemTran:Find("Btns/LowerMemberBtn"),
        }
    end
end

function ClubPartnerPanel:OnOpened()
    this.isSearched = false
    this:AddOnClick(this.lastBtn, this.OnClickLastPageBtn)
    this:AddOnClick(this.nextBtn, this.OnClickNextPageBtn)
    this:AddOnClick(this.backBtn, this.OnClickBackBtn)
    this:AddOnClick(this.addPartnerBtn, this.OnClickAddPartnerBtn)
    this:AddOnClick(this.searchBtn, this.OnClickSearchBtn)
    this:AddOnClick(this.clearScoreBtn, this.OnClickClearScoreBtn)
    
    local inputField = this.searchIdInput:GetComponent(TypeInputField)
    inputField.onValueChanged:RemoveAllListeners()
    inputField.onValueChanged:AddListener(this.OnInputFieldValueChanged)

    ClubManager.SendGetPartnerList(1, UserData.GetUserId(), 1, 0)
end

function ClubPartnerPanel.UpdateCurPanel()
    ClubManager.SendGetPartnerList(1, UserData.GetUserId(), this.curPageIdx, 0)
end

function ClubPartnerPanel.UpdateDataList(data)
    this.curPageIdx = data.page
    this.totalPage = data.totalPage
    UIUtil.SetText(this.pageNumText, tostring(this.curPageIdx) .. "/" .. tostring(this.totalPage))
    local list = data.list
    if GetTableSize(list) > 0 then
        UIUtil.SetActive(this.loadingText, false)
        UIUtil.SetActive(this.noDataText, false)
        UIUtil.SetActive(this.pageList, true)
        local pageCount = 4
        local itemGroup = nil
        for i = 1, pageCount do
            local itemData = nil
            itemGroup = this.itemGroups[i]
            itemData = list[i]
            if itemGroup ~= nil then
                if itemData ~= nil then
                    UIUtil.SetActive(itemGroup.transform, true)
                    Functions.SetHeadImage(itemGroup.headImg, itemData.pIcon)
                    --UIUtil.SetText(itemGroup.idText, tostring(itemData.pId))
                    UIUtil.SetText(itemGroup.idText, ClubData.GetUidString(itemData.pId))
                    UIUtil.SetText(itemGroup.nameText, tostring(itemData.pName))
                    UIUtil.SetText(itemGroup.numText1, tostring(itemData.tNum).."\n"..tostring(itemData.yNum))
                    UIUtil.SetText(itemGroup.numText2, tostring(itemData.per).."%\n"..tostring(itemData.totalN))
                    UIUtil.SetText(itemGroup.numText3, tostring(itemData.tScore).."\n"..tostring(itemData.yScore))
                    -- this:AddOnClick(itemGroup.headBtn, function()
                    --     if itemData.pId == UserData.GetUserId() then
                    --         Toast.Show("不能调整自己的比例")
                    --     else
                    --         PanelManager.Open(PanelConfig.ClubPartnerPercentChange, itemData.pId)
                    --     end
                    -- end)
                    -- UIUtil.SetActive(itemGroup.lowerPatnerBtn, itemData.pId ~= UserData.GetUserId())
                    -- this:AddOnClick(itemGroup.lowerPatnerBtn, function()
                    --     PanelManager.Open(PanelConfig.ClubLowerPartner, itemData.pId)
                    -- end)
                    this:AddOnClick(itemGroup.lowerMemberBtn, function()
                        PanelManager.Open(PanelConfig.ClubLowerMember, itemData.pId)
                    end)
                else
                    UIUtil.SetActive(itemGroup.transform, false)
                end
            end
        end
    else
        UIUtil.SetActive(this.loadingText, false)
        UIUtil.SetActive(this.noDataText, true)
    end
end

function ClubPartnerPanel.OnClickSearchBtn()
    local text = UIUtil.GetInputText(this.searchIdInput)
    if not string.IsNullOrEmpty(text) and string.len(text) == 6 then
        local num = tonumber(text)
        if num ~= nil then
            LockScreen(0.5)
            this.isSearched = true
            ClubManager.SendGetPartnerList(1, UserData.GetUserId(), 1, num)
        else
            Toast.Show("请输入正确的玩家ID")
        end
    else
        Toast.Show("请输入正确的玩家ID")
    end
end

function ClubPartnerPanel.OnInputFieldValueChanged(text)
    if this.isSearched then
        if string.IsNullOrEmpty(text) then
            ClubManager.SendGetPartnerList(1, UserData.GetUserId(), 1, 0)
            this.isSearched = false
        end
    end
end

function ClubPartnerPanel.OnClickBackBtn()
    PanelManager.Close(PanelConfig.ClubPartner, true)
end

function ClubPartnerPanel.OnClickLastPageBtn()
    if this.curPageIdx <= 1 then
        Toast.Show("当前已是首页")
    else
        ClubManager.SendGetPartnerList(1, UserData.GetUserId(), this.curPageIdx - 1, 0)
    end
end

function ClubPartnerPanel.OnClickNextPageBtn()
    if this.curPageIdx >= this.totalPage then
        Toast.Show("当前已是尾页")
    else
        ClubManager.SendGetPartnerList(1, UserData.GetUserId(), this.curPageIdx + 1, 0)
    end
end

function ClubPartnerPanel.OnClickAddPartnerBtn()
    PanelManager.Open(PanelConfig.ClubInputNumber, ClubInputNumberPanelType.AddPartner, function (num)
        -- ClubManager.SendAddPartnerMember(num)
        ClubManager.SendSetMemberRole(num, ClubRole.Partner)
        PanelManager.Close(PanelConfig.ClubInputNumber, true)
    end)
end

function ClubPartnerPanel.OnClickClearScoreBtn()
    Alert.Prompt("确定清除伙伴合作积分？", function ()
        ClubManager.SendClearCooperationScore()
    end)
end