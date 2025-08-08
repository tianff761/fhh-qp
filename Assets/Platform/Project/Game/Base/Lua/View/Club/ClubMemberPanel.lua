ClubMemberPanel = ClassPanel("ClubMemberPanel")
ClubMemberPanel.closeBtn = nil
ClubMemberPanel.searchBtn = nil
ClubMemberPanel.searchIdInput = nil
ClubMemberPanel.toggles = nil
ClubMemberPanel.pages = nil
--当前显示页面类型 1成员列表   2审核管理
ClubMemberPanel.curPageType = 0
--成员管理界面Item
ClubMemberPanel.memberItemGroups = nil
--申请审核管理界面Item
ClubMemberPanel.applyItemGroups = nil

ClubMemberPanel.memberScrollExt = nil
ClubMemberPanel.applyScrollExt = nil

ClubMemberPanel.loadingText = nil
ClubMemberPanel.noDataText = nil

ClubMemberPanel.curMemberGetPage = 0
ClubMemberPanel.curApplyGetPage = 0
--是否进行过搜索
ClubMemberPanel.isSearched = false

ClubMemberPanel.redPointTrans = nil
local this = ClubMemberPanel
function ClubMemberPanel:Awake()
    this = self
    this.redPointTrans = {}
    this.closeBtn = self:Find("Bgs/BackBtn")
    this.searchBtn = self:Find("Content/SearchBtn")
    this.searchIdInput = self:Find("Content/SearchInputField")

    this.loadingText = self:Find("Content/LoadingText")
    this.noDataText = self:Find("Content/NoDataText")

    this.memberScrollExt = self:Find("Content/MemberListScrollRect"):GetComponent("ScrollRectExtension")
    this.applyScrollExt = self:Find("Content/ApplyListScrollRect"):GetComponent("ScrollRectExtension")

    this.toggles = {}
    this.toggles[1] = self:Find("Content/Left/MemberListToggle")
    this.toggles[2] = self:Find("Content/Left/ApplyListToggle")
    this.redPointTrans[RedPointType.ClubApplyJoin] = this.toggles[2]:Find("RedPoint")

    this.pages = {}
    this.pages[1] = this.memberScrollExt.transform
    this.pages[2] = this.applyScrollExt.transform

    --所有成员列表控件查找
    local cnt = this.memberScrollExt.grid.transform
    local childCount = cnt.childCount
    this.memberItemGroups = {}
    local itemTran = nil
    for i = 0, childCount - 1 do
        itemTran = cnt:GetChild(i)
        this.memberItemGroups[itemTran] = {
            headImg = itemTran:Find("Head/Mask/HeadIcon"):GetComponent(TypeImage),
            nameText = itemTran:Find("NameText"),
            idText = itemTran:Find("IdText"),
            timeText = itemTran:Find("TimeInfo"),
            leaderTag = itemTran:Find("LeaderTag"),
            adminTag = itemTran:Find("AdminTag"),
            partnerTag = itemTran:Find("PartnerTag"),
            freezeBtn = itemTran:Find("Btns/FreezeBtn"),
            unFreezeBtn = itemTran:Find("Btns/UnfreezeBtn"),
            setAdminBtn = itemTran:Find("Btns/SetAdminBtn"),
            setCommonBtn = itemTran:Find("Btns/SetCommonBtn"),
        }
    end

    --所有申请列表控件查找
    local cnt = this.applyScrollExt.grid.transform
    local childCount = cnt.childCount
    this.applyItemGroups = {}
    local itemTran = nil
    local itemGroup = nil
    for i = 0, childCount - 1 do
        itemTran = cnt:GetChild(i)
        this.applyItemGroups[itemTran] = {
            headImg = itemTran:Find("Head/Mask/HeadIcon"):GetComponent(TypeImage),
            nameText = itemTran:Find("NameText"),
            idText = itemTran:Find("IdText"),
            inviteCodeText = itemTran:Find("InviteCode"),
            timeText = itemTran:Find("TimeInfo"),
            refuseBtn = itemTran:Find("RefuseBtn"),
            agreeBtn = itemTran:Find("AgreeBtn"),
        }
    end
    this:AddOnClick(this.closeBtn, this.OnClickCloseBtn)
    this:AddOnClick(this.searchBtn, this.OnClickSearchBtn)
    
    this:AddOnToggle(this.toggles[1], function (isOn)
        if isOn then
            this.OnClickToggle(1)
        end
    end)

    this:AddOnToggle(this.toggles[2], function (isOn)
        if isOn then
            this.OnClickToggle(2)
        end
    end)
end

function ClubMemberPanel:OnOpened()
    this.curPageType = 0
    this.isSearched = false
    UIUtil.SetActive(this.toggles[2], ClubData.selfRole == ClubRole.Admin or ClubData.selfRole == ClubRole.Boss)
    UIUtil.SetToggle(this.toggles[1], true)
    this.OnClickToggle(1)

    AddMsg(CMD.Game.UpdateRedPointTips, this.OnGameUpdateRedPoint)
    this.OnGameUpdateRedPoint()
end

function ClubMemberPanel:OnClosed()
    RemoveMsg(CMD.Game.UpdateRedPointTips, this.OnGameUpdateRedPoint)
end

function ClubMemberPanel.OnClickToggle(pageType)
    LockScreen(0.5)
    Log("OnClickToggle", this.curPageType, pageType, this.isSearched)
    if this.curPageType == pageType and this.isSearched == false then
        return 
    end
    this.isSearched = false
    this.curPageType = pageType
    for page, pageTran in pairs(this.pages) do
        UIUtil.SetActive(pageTran, false)
    end
    if pageType == 1 then
        this.memberScrollExt:SetMaxDataCount(0)
        this.memberScrollExt:InitItems()
        this.memberScrollExt.onUpdateItemAction = this.OnUpdateMemberItem
        this.memberScrollExt.onGetNextPageDataAction = this.SendGetMemberList
        this.memberScrollExt.onGetLastPageDataAction = function(page)
            this.curGetPage = page
        end
        this.SendGetMemberList(0)
    elseif pageType == 2 then
        this.applyScrollExt:SetMaxDataCount(0)
        this.applyScrollExt:InitItems()
        this.applyScrollExt.onUpdateItemAction = this.onUpdateApplyItem
        this.applyScrollExt.onGetNextPageDataAction = this.SendGetApplyList
        this.applyScrollExt.onGetLastPageDataAction = function(page)
            this.curGetPage = page
        end
        this.SendGetApplyList(0)
    end
    UIUtil.SetActive(this.loadingText, true)
    UIUtil.SetActive(this.noDataText, false)
end

function ClubMemberPanel.OnClickCloseBtn()
    PanelManager.Close(PanelConfig.ClubMember)
end

function ClubMemberPanel.OnClickSearchBtn()
    local text = UIUtil.GetInputText(this.searchIdInput)
    if not string.IsNullOrEmpty(text) and string.len(text) == 6 then
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

function ClubMemberPanel.UpdateMemberList()
    if ClubData.totalMemberCount <= 0 then
        UIUtil.SetActive(this.loadingText, false)
        UIUtil.SetActive(this.noDataText, true)
        UIUtil.SetActive(this.pages[this.curPageType], false)
    else
        UIUtil.SetActive(this.loadingText, false)
        UIUtil.SetActive(this.noDataText, false)
        UIUtil.SetActive(this.pages[this.curPageType], true)
        this.memberScrollExt:SetMaxDataCount(ClubData.totalMemberCount)
        this.memberScrollExt:UpdateAllItems()
    end
    Log("UpdateMemberList", ClubData.totalMemberCount)
end

function ClubMemberPanel.UpdateApplyList()
    if ClubData.totalApplyCount <= 0 then
        UIUtil.SetActive(this.loadingText, false)
        UIUtil.SetActive(this.noDataText, true)
        UIUtil.SetActive(this.pages[this.curPageType], false)
    else
        UIUtil.SetActive(this.loadingText, false)
        UIUtil.SetActive(this.noDataText, false)
        UIUtil.SetActive(this.pages[this.curPageType], true)
        this.applyScrollExt:SetMaxDataCount(ClubData.totalApplyCount)
        this.applyScrollExt:UpdateAllItems()
    end
    Log("UpdateApplyList", ClubData.totalApplyCount)
end

--pageIdx: 0开始, 服务器从1开始
function ClubMemberPanel.SendGetMemberList(pageIdx)
    this.curMemberGetPage = pageIdx
    if pageIdx < 0 then
        pageIdx = 1
    else
        pageIdx = pageIdx + 1
    end
    ClubManager.SendGetClubMemberList(pageIdx)
end

--pageIdx: 0开始, 服务器从1开始
function ClubMemberPanel.SendGetApplyList(pageIdx)
    this.curApplyGetPage = pageIdx
    if pageIdx < 0 then
        pageIdx = 1
    else
        pageIdx = pageIdx + 1
    end
    ClubManager.SendGetClubApplyList(pageIdx)
end

--idx从0开始
function ClubMemberPanel.OnUpdateMemberItem(item, idx)
    local itemGroup = this.memberItemGroups[item]
    local itemData = ClubData.GetMemberItem(idx + 1)
    if itemGroup ~= nil and itemData ~= nil then
        UIUtil.SetText(itemGroup.idText, ClubData.GetUidString(itemData.uid))
        UIUtil.SetText(itemGroup.nameText, tostring(itemData.name))
        UIUtil.SetText(itemGroup.timeText, os.date("%m/%d %H:%M", itemData.lastOnline / 1000))
        Functions.SetHeadImage(itemGroup.headImg, itemData.headIcon)
        
        UIUtil.SetActive(itemGroup.leaderTag, itemData.role == ClubRole.Boss)
        UIUtil.SetActive(itemGroup.adminTag, itemData.role == ClubRole.Admin)
        UIUtil.SetActive(itemGroup.partnerTag, itemData.role == ClubRole.Partner)

        
        if itemData.role == ClubRole.Boss then
            UIUtil.SetActive(itemGroup.freezeBtn, false)
            UIUtil.SetActive(itemGroup.unFreezeBtn, false)
        else
            --管理员和盟主都可以任意冻结
            local isRole = ClubData.selfRole == ClubRole.Admin or ClubData.selfRole == ClubRole.Boss
            UIUtil.SetActive(itemGroup.freezeBtn, isRole and not itemData.isFreezed)
            UIUtil.SetActive(itemGroup.unFreezeBtn, isRole and itemData.isFreezed)
        end
       
        
        --如果当前玩家是普通玩家，则可以设置其为管理员或者合伙人
        if ClubData.selfRole == ClubRole.Boss then
            if itemData.role == ClubRole.Member then
                UIUtil.SetActive(itemGroup.setAdminBtn, true)
                UIUtil.SetActive(itemGroup.setCommonBtn, false)
            elseif itemData.role == ClubRole.Admin then
                UIUtil.SetActive(itemGroup.setAdminBtn, false)
                UIUtil.SetActive(itemGroup.setCommonBtn, true)
            elseif itemData.role == ClubRole.Boss then
                UIUtil.SetActive(itemGroup.setAdminBtn, false)
                UIUtil.SetActive(itemGroup.setCommonBtn, false)
            elseif itemData.role == ClubRole.Partner then
                UIUtil.SetActive(itemGroup.setAdminBtn, false)
                UIUtil.SetActive(itemGroup.setCommonBtn, false)
            end
        else
            UIUtil.SetActive(itemGroup.setAdminBtn, false)
            UIUtil.SetActive(itemGroup.setCommonBtn, false)
        end

        this:AddOnClick(itemGroup.setAdminBtn, function ()
            Alert.Prompt("是否将该玩家设为管理员？", function ()
                ClubManager.SendSetMemberRole(itemData.uid, ClubRole.Admin)
            end)
        end)

        this:AddOnClick(itemGroup.setCommonBtn, function ()
            Alert.Prompt("是否将该玩家设为普通成员？", function ()
                ClubManager.SendSetMemberRole(itemData.uid, ClubRole.Member)
            end)
        end)

        this:AddOnClick(itemGroup.freezeBtn, function ()
            Alert.Prompt("是否冻结该玩家？", function ()
                ClubManager.SendFreezeMember(itemData.uid, 0)
            end)
        end)

        this:AddOnClick(itemGroup.unFreezeBtn, function ()
            Alert.Prompt("是否解冻该玩家？", function ()
                ClubManager.SendFreezeMember(itemData.uid, 1)
            end)
        end)
    end
end

function ClubMemberPanel.onUpdateApplyItem(item, idx)
    local itemGroup = this.applyItemGroups[item]
    local itemData = ClubData.GetApplyItem(idx + 1)
    if itemGroup ~= nil and itemData ~= nil then
        UIUtil.SetText(itemGroup.idText, ClubData.GetUidString(itemData.uid))
        UIUtil.SetText(itemGroup.nameText, tostring(itemData.name))
        UIUtil.SetText(itemGroup.inviteCodeText, tostring(itemData.inviteCode))
        Functions.SetHeadImage(itemGroup.headImg, itemData.headIcon)

        this:AddOnClick(itemGroup.refuseBtn, function ()
            Alert.Prompt("是否拒绝该玩家加入？", function ()
                ClubManager.SendDealApply(itemData.uid, 1)
            end)
        end)
        this:AddOnClick(itemGroup.agreeBtn, function ()
            Alert.Prompt("是否同意该玩家加入？", function ()
                ClubManager.SendDealApply(itemData.uid, 0)
            end)
        end)
    end
    Log("更新OnUpdateMemberItem", itemGroup, itemData)
end

function ClubMemberPanel.OnGameUpdateRedPoint()
    local val = RedPointMgr.GetRedPointByValue(RedPointType.ClubApplyJoin, ClubData.curClubId)
    UIUtil.SetActive(this.redPointTrans[RedPointType.ClubApplyJoin], val ~= nil)
end

