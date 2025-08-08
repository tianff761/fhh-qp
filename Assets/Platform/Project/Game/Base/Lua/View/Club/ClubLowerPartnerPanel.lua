ClubLowerPartnerPanel = ClassPanel("ClubLowerPartnerPanel")
ClubLowerPartnerPanel.backBtn = nil
ClubLowerPartnerPanel.searchBtn = nil
ClubLowerPartnerPanel.searchIdInput = nil
ClubLowerPartnerPanel.lastBtn = nil
ClubLowerPartnerPanel.nextBtn = nil
ClubLowerPartnerPanel.pageNumText = nil
ClubLowerPartnerPanel.pageList = nil
ClubLowerPartnerPanel.itemGroups = nil
--当前页码信息
ClubLowerPartnerPanel.curPageIdx = 0
ClubLowerPartnerPanel.totalPage = 0
--获取uid下属的合伙人
ClubLowerPartnerPanel.uid = 0
ClubLowerPartnerPanel.isSearched = false

local this = ClubLowerPartnerPanel
function ClubLowerPartnerPanel:Awake()
    this = self
    this.backBtn = self:Find("Bgs/BackBtn")
    this.loadingText = self:Find("Content/LoadingText")
    this.noDataText = self:Find("Content/NoDataText")

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
            lowerMemberBtn = itemTran:Find("LowerMemberBtn"),
        }
    end
end

function ClubLowerPartnerPanel:OnOpened(uid)
    this.isSearched = false
    this.uid = uid
    this:AddOnClick(this.lastBtn, this.OnClickLastPageBtn)
    this:AddOnClick(this.nextBtn, this.OnClickNextPageBtn)
    this:AddOnClick(this.backBtn, this.OnClickBackBtn)
    this:AddOnClick(this.searchBtn, this.OnClickSearchBtn)
    UnionManager.SendGetPartnerList(1, this.uid, 4, 1, 0)

    local inputField = this.searchIdInput:GetComponent(TypeInputField)
    inputField.onValueChanged:RemoveAllListeners()
    inputField.onValueChanged:AddListener(this.OnInputFieldValueChanged)
end

function ClubLowerPartnerPanel.UpdateDataList(data)
    this.curPageIdx = data.pageIndex
    this.totalPage = Functions.CheckPageTotal(data.allPage)
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
                    UIUtil.SetText(itemGroup.idText, UnionData.GetUidString(itemData.pId))
                    UIUtil.SetText(itemGroup.nameText, tostring(itemData.pName))
                    UIUtil.SetText(itemGroup.numText1, tostring(itemData.tNum).."\n"..tostring(itemData.yNum))
                    UIUtil.SetText(itemGroup.numText2, tostring(itemData.per).."\n"..tostring(itemData.totalN))
                    UIUtil.SetText(itemGroup.numText3, tostring(itemData.tScore).."\n"..tostring(itemData.yScore))
                    this:AddOnClick(itemGroup.headBtn, function()
                        PanelManager.Open(PanelConfig.UnionPartnerPercentChange, itemData.pId)
                        Log("点击头像")
                    end)
                    this:AddOnClick(itemGroup.lowerMemberBtn, function()
                        PanelManager.Open(PanelConfig.UnionLowerMember, itemData.pId)
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

function ClubLowerPartnerPanel.OnClickSearchBtn()
    local text = UIUtil.GetInputText(this.searchIdInput)
    if not string.IsNullOrEmpty(text) and string.len(text) == 6 then
        local num = tonumber(text)
        if num ~= nil then
        this.isSearched = true
        LockScreen(0.5)
            UnionManager.SendGetPartnerList(1, this.uid, 4, 1, num)            
        else
            Toast.Show("请输入正确的玩家ID")
        end
    else
        Toast.Show("请输入正确的玩家ID")
    end
end

function ClubLowerPartnerPanel.UpdateCurPanel()
    UnionManager.SendGetPartnerList(1, this.uid,  4,this.curPageIdx, 0)
end

function ClubLowerPartnerPanel.OnClickBackBtn()
    PanelManager.Close(PanelConfig.UnionLowerPartner, true)
end

function ClubLowerPartnerPanel.OnClickLastPageBtn()
    if this.curPageIdx <= 1 then
        Toast.Show("当前已是首页")
    else
        UnionManager.SendGetPartnerList(1, this.uid,  4,this.curPageIdx - 1, 0)            
    end
end

function ClubLowerPartnerPanel.OnClickNextPageBtn()
    if this.curPageIdx >= this.totalPage then
        Toast.Show("当前已是尾页")
    else
        UnionManager.SendGetPartnerList(1, this.uid,  4,this.curPageIdx + 1, 0)            
    end
end

function ClubLowerPartnerPanel.OnInputFieldValueChanged(text)
    if this.isSearched then
        if string.IsNullOrEmpty(text) then
            UnionManager.SendGetPartnerList(1, this.uid,  4,1, 0)
            this.isSearched = false
        end
    end
end