UnionPartnerPanel = ClassPanel("UnionPartnerPanel")
UnionPartnerPanel.backBtn = nil
UnionPartnerPanel.searchBtn = nil
UnionPartnerPanel.searchIdInput = nil
UnionPartnerPanel.lastBtn = nil
UnionPartnerPanel.nextBtn = nil
UnionPartnerPanel.pageNumText = nil
UnionPartnerPanel.addPartnerBtn = nil
UnionPartnerPanel.clearScoreBtn = nil
UnionPartnerPanel.pageList = nil
UnionPartnerPanel.itemGroups = nil
-- 当前页码信息
UnionPartnerPanel.curPageIdx = 0
UnionPartnerPanel.totalPage = 0

UnionPartnerPanel.isSearched = false
local this = UnionPartnerPanel
function UnionPartnerPanel:Awake()
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
            lowerPatnerBtn = itemTran:Find("Btns/LowerPartnerBtn"),
            lowerMemberBtn = itemTran:Find("Btns/LowerMemberBtn"),
            setupBtn = itemTran:Find("Btns/SetupBtn")
        }
    end

    this:AddOnClick(this.lastBtn, this.OnClickLastPageBtn)
    this:AddOnClick(this.nextBtn, this.OnClickNextPageBtn)
    this:AddOnClick(this.backBtn, this.OnClickBackBtn)
    this:AddOnClick(this.addPartnerBtn, this.OnClickAddPartnerBtn)
    this:AddOnClick(this.searchBtn, this.OnClickSearchBtn)
    this:AddOnClick(this.clearScoreBtn, this.OnClickClearScoreBtn)

    local inputField = this.searchIdInput:GetComponent(TypeInputField)
    inputField.onValueChanged:RemoveAllListeners()
    inputField.onValueChanged:AddListener(this.OnInputFieldValueChanged)
end

function UnionPartnerPanel:OnOpened()
    this.isSearched = false
    UnionManager.SendGetPartnerList(1, UserData.GetUserId(), 4, 1, 0)
end

function UnionPartnerPanel.UpdateCurPanel()
    UnionManager.SendGetPartnerList(1, UserData.GetUserId(), 4, this.curPageIdx, 0)
end

function UnionPartnerPanel.UpdateDataList(data)
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
                    -- UIUtil.SetText(itemGroup.idText, tostring(itemData.pId))
                    UIUtil.SetText(itemGroup.idText, UnionData.GetUidString(itemData.pId))
                    UIUtil.SetText(itemGroup.nameText, tostring(itemData.pName))
                    UIUtil.SetText(itemGroup.numText1, math.PreciseDecimal(itemData.tNum, 2) .. "\n" ..
                            math.PreciseDecimal(itemData.yNum, 2))
                    UIUtil.SetText(itemGroup.numText2,
                            tostring(itemData.per) .. "%\n" .. math.PreciseDecimal(itemData.totalN, 2))
                    UIUtil.SetText(itemGroup.numText3, math.PreciseDecimal(itemData.tScore, 2) .. "\n" ..
                            math.PreciseDecimal(itemData.yScore, 2))
                    this:AddOnClick(itemGroup.headBtn, function()
                        if itemData.pId == UserData.GetUserId() then
                            Toast.Show("不能调整自己的比例")
                        else
                            PanelManager.Open(PanelConfig.UnionPartnerPercentAndScoreChangePanel, itemData.pId)
                        end
                    end)
                    -- 1号是自身  只需要显示下属玩家  其他的根据  盟主和管理  来显示下属合伙人和下属玩家
                    if UnionData.IsUnionLeaderOrAdministratorOrObserver() then
                        UIUtil.SetActive(itemGroup.lowerPatnerBtn, UserData.GetUserId() ~= itemData.pId)
                        this:AddOnClick(itemGroup.lowerPatnerBtn, function()
                            PanelManager.Open(PanelConfig.UnionLowerPartner, itemData.pId)
                        end)
                        UIUtil.SetActive(itemGroup.lowerMemberBtn, UnionData.IsUnionLeaderOrAdministratorOrObserver())
                        this:AddOnClick(itemGroup.lowerMemberBtn, function()
                            PanelManager.Open(PanelConfig.UnionLowerMember, itemData.pId)
                        end)
                    end
                    if UnionData.IsUnionPartner() then
                        UIUtil.SetActive(itemGroup.lowerMemberBtn, UserData.GetUserId() == itemData.pId)
                        this:AddOnClick(itemGroup.lowerMemberBtn, function()
                            PanelManager.Open(PanelConfig.UnionLowerMember, itemData.pId)
                        end)
                    end
                    -- UIUtil.SetActive(itemGroup.setupBtn, itemData.pId ~= UserData.GetUserId())
                    this:AddOnClick(itemGroup.setupBtn, function()
                        PanelManager.Open(PanelConfig.UnionWarnScore, {
                            pId = itemData.pId,
                            totalScore = itemData.totalScore,
                            warnScore = itemData.warnScore
                        })
                    end)
                else
                    UIUtil.SetActive(itemGroup.transform, false)
                end
            end
        end
    else
        UIUtil.SetActive(this.loadingText, false)
        UIUtil.SetActive(this.noDataText, true)
        UIUtil.SetActive(this.pageList, false)
    end
end

function UnionPartnerPanel.OnClickSearchBtn()
    local text = UIUtil.GetInputText(this.searchIdInput)
    if not string.IsNullOrEmpty(text) and string.len(text) == 6 then
        local num = tonumber(text)
        if num ~= nil then
            LockScreen(0.5)
            this.isSearched = true
            UnionManager.SendGetPartnerList(1, UserData.GetUserId(), 4, 1, num)
        else
            Toast.Show("请输入正确的玩家ID")
        end
    else
        Toast.Show("请输入正确的玩家ID")
    end
end

function UnionPartnerPanel.OnInputFieldValueChanged(text)
    if this.isSearched then
        if string.IsNullOrEmpty(text) then
            UnionManager.SendGetPartnerList(1, UserData.GetUserId(), 4, 1, 0)
            this.isSearched = false
        end
    end
end

function UnionPartnerPanel.OnClickBackBtn()
    PanelManager.Close(PanelConfig.UnionPartner, true)
end

function UnionPartnerPanel.OnClickLastPageBtn()
    if this.curPageIdx <= 1 then
        Toast.Show("当前已是首页")
    else
        UnionManager.SendGetPartnerList(1, UserData.GetUserId(), 4, this.curPageIdx - 1, 0)
    end
end

function UnionPartnerPanel.OnClickNextPageBtn()
    if this.curPageIdx >= this.totalPage then
        Toast.Show("当前已是尾页")
    else
        UnionManager.SendGetPartnerList(1, UserData.GetUserId(), 4, this.curPageIdx + 1, 0)
    end
end

function UnionPartnerPanel.OnClickAddPartnerBtn()
    PanelManager.Open(PanelConfig.UnionInputNumber, UnionInputNumberPanelType.AddPartner, function(num)
        UnionManager.SendAddPartnerMember(num)
        PanelManager.Close(PanelConfig.UnionInputNumber, true)
    end)
end

function UnionPartnerPanel.OnClickClearScoreBtn()
    Alert.Prompt("确定清除伙伴合作积分？", function()
        UnionManager.SendClearCooperationScore()
    end)
end
