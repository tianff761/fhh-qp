--用于下级相关
UnionLowerMemberPanel = ClassPanel("UnionLowerMemberPanel")
--
local this = UnionLowerMemberPanel
--每页总数
local PageCount = 3
--
UnionLowerMemberPanel.nodeIndex = 0
--是否强制更新节点
UnionLowerMemberPanel.isForceUpdateNode = false
--当前查看下级的玩家ID
UnionLowerMemberPanel.curUid = 0
UnionLowerMemberPanel.isSearched = false
UnionLowerMemberPanel.pageIndex = 1
UnionLowerMemberPanel.pageTotal = 1
--查看ID列表，用于1级的返回
UnionLowerMemberPanel.viewIdList = {}

function UnionLowerMemberPanel:Init()
    dofile(ScriptPath.ViewUnion .. "UnionNodeLowPartner")
    dofile(ScriptPath.ViewUnion .. "UnionNodeLowMember")

    this.nodeIndex = 0
    this.nodePanels = { UnionNodeLowPartner, UnionNodeLowMember}
end

function UnionLowerMemberPanel:Awake()
    this = self
    this:Init()

    local content = this:Find("Content")

    this.closeBtn = content:Find("Background/CloseBtn")
    local head = content:Find("Head")
    this.headImage = head:Find("Mask/Icon"):GetComponent(TypeImage)
    this.nameLabel = head:Find("NameText"):GetComponent(TypeText)
    this.idLabel = head:Find("IdText"):GetComponent(TypeText)

    local node = content:Find("Node")
    this.loadingText = node:Find("LoadingText")
    this.noDataText = node:Find("NoDataText")

    local menuContent = content:Find("Menu/Viewport/Content")
    this.menuToggles = {}
    local total = menuContent.childCount
    for i = 1, total do
        local item = {}
        item.index = i
        item.gameObject = menuContent:Find(tostring(i)).gameObject
        item.toggle = item.gameObject:GetComponent(TypeToggle)
        table.insert(this.menuToggles, item)
        this:AddOnToggle(item.gameObject, function(isOn)
            this.OnMenuValueChanged(item, isOn)
        end)
    end

    for i = 1, total do
        this.nodePanels[i].Init(node:Find("Node" .. i))
    end

    local bottom = node:Find("Bottom")
    this.searchBtn = bottom:Find("SearchBtn")
    this.searchIdInput = bottom:Find("SearchInput"):GetComponent(TypeInputField)
    local page = bottom:Find("Page")
    this.lastBtn = page:Find("LastBtn")
    this.nextBtn = page:Find("NextBtn")
    this.pageNumLabel = page:Find("PageText/Text"):GetComponent(TypeText)
    this.AddUIEventListener()
end

function UnionLowerMemberPanel:OnOpened(playerArg)
    this.AddEventListener()
    this.ViewMember(playerArg, false)
end

function UnionLowerMemberPanel:OnClosed()
    this.RemoveEventListener()
    this.curUid = 0
    this.lastPlayerArg = nil
    this.isSearched = false
    this.pageIndex = 1
    this.pageTotal = 1
    this.viewIdList = {}
    --
    this.CloseNode(this.nodeIndex)
    this.nodeIndex = 0
    this.isForceUpdateNode = false
end

------------------------------------------------------------------
--
--注册事件
function UnionLowerMemberPanel.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_GetPartnerList, this.OnGetPartnerList)
    AddEventListener(CMD.Game.UnionViewLowMember, this.OnUnionViewLowMember)
    AddEventListener(CMD.Game.UnionSetWarnScoreRefresh, this.OnUnionSetWarnScoreRefresh)
    AddEventListener(CMD.Game.UnionSetScoreRefresh, this.OnUnionSetScoreRefresh)
end

--移除事件
function UnionLowerMemberPanel.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.Union.S2C_GetPartnerList, this.OnGetPartnerList)
    RemoveEventListener(CMD.Game.UnionViewLowMember, this.OnUnionViewLowMember)
    RemoveEventListener(CMD.Game.UnionSetWarnScoreRefresh, this.OnUnionSetWarnScoreRefresh)
    RemoveEventListener(CMD.Game.UnionSetScoreRefresh, this.OnUnionSetScoreRefresh)
end

--UI相关事件
function UnionLowerMemberPanel.AddUIEventListener()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.lastBtn, this.OnLastPageBtnClick)
    this:AddOnClick(this.nextBtn, this.OnNextPageBtnClick)
    this:AddOnClick(this.searchBtn, this.OnSearchBtnClick)

    this.searchIdInput.onValueChanged:RemoveAllListeners()
    this.searchIdInput.onValueChanged:AddListener(this.OnInputFieldValueChanged)
end

--================================================================
--
--关闭节点
function UnionLowerMemberPanel.CloseNode(index)
    local temp = this.nodePanels[index]
    if temp ~= nil then
        UIUtil.SetActive(temp.gameObject, false)
        temp.Close()
    end
end

--打开节点
function UnionLowerMemberPanel.OpenNode(index)
    local temp = this.nodePanels[index]
    if temp ~= nil then
        --打开界面的时候
        this.isSearched = false
        this.pageIndex = 1
        this.pageTotal = 1
        this.searchIdInput.text = ""
        --请求数据
        this.RequestDataList(this.pageIndex)
        --
        UIUtil.SetActive(temp.gameObject, true)
        temp.Open()
    end
end

--================================================================
--
--菜单按钮点击
function UnionLowerMemberPanel.OnMenuValueChanged(item, isOn)
    if isOn then
        if this.nodeIndex ~= item.index or this.isForceUpdateNode then
            if this.nodeIndex ~= item.index then
                this.CloseNode(this.nodeIndex)
                this.nodeIndex = item.index
            end
            this.OpenNode(this.nodeIndex)
        end
        this.isForceUpdateNode = false
    end
end


function UnionLowerMemberPanel.OnCloseBtnClick()
    this.HandleBack()
end


function UnionLowerMemberPanel.OnSearchBtnClick()
    local text = this.searchIdInput.text
    if not string.IsNullOrEmpty(text) and string.len(text) == 6 then
        local num = tonumber(text)
        if num ~= nil then
            LockScreen(0.5)
            this.isSearched = true
            this.RequestDataList(1, num)
        else
            Toast.Show("请输入正确的玩家ID")
        end
    else
        Toast.Show("请输入正确的玩家ID")
    end
end

function UnionLowerMemberPanel.OnLastPageBtnClick()
    if this.pageIndex <= 1 then
        Toast.Show("当前已是首页")
    else
        this.RequestDataList(this.pageIndex - 1)
    end
end

function UnionLowerMemberPanel.OnNextPageBtnClick()
    if this.pageIndex >= this.pageTotal then
        Toast.Show("当前已是尾页")
    else
        this.RequestDataList(this.pageIndex + 1)
    end
end

function UnionLowerMemberPanel.OnInputFieldValueChanged(text)
    if this.isSearched then
        if string.IsNullOrEmpty(text) then
            --
            this.isSearched = false
        end
    end
end

--获取列表
function UnionLowerMemberPanel.OnGetPartnerList(data)
    if data.code == 0 then
        this.UpdateDataList(data.data)
    else
        UnionManager.ShowError(data.code)
    end
end

--继续查看下级
function UnionLowerMemberPanel.OnUnionViewLowMember(data)
    this.ViewMember(data, false)
end

--刷新界面
function UnionLowerMemberPanel.OnUnionSetWarnScoreRefresh()
    this.RequestDataList(this.pageIndex)
end

--刷新界面
function UnionLowerMemberPanel.OnUnionSetScoreRefresh()
    this.RequestDataList(this.pageIndex)
end

--================================================================
--查看下级，如果是返回就不需要缓存ID
function UnionLowerMemberPanel.ViewMember(playerArg, isBack)
    if not isBack and this.lastPlayerArg ~= nil and this.lastPlayerArg.id ~= playerArg.id then
        table.insert(this.viewIdList, this.lastPlayerArg)
    end
    this.lastPlayerArg = playerArg
    this.curUid = playerArg.id

    if this.lastHeadUrl ~= playerArg.headUrl then
        this.lastHeadUrl = playerArg.headUrl
        Functions.SetHeadImage(this.headImage, playerArg.headUrl)
    end
    this.nameLabel.text = tostring(playerArg.name)
    this.idLabel.text = "ID:" .. playerArg.id
    --
    this.isForceUpdateNode = true
    local temp = this.menuToggles[1]
    temp.toggle.isOn = false
    temp.toggle.isOn = true
    LockScreen(0.5)
end

--处理返回
function UnionLowerMemberPanel.HandleBack()
    local length = #this.viewIdList
    if length > 0 then
        local playerArg = this.viewIdList[length]
        table.remove(this.viewIdList, length)
        this.ViewMember(playerArg, true)
    else
        PanelManager.Close(PanelConfig.UnionLowerMember)
    end
end

--请求列表
function UnionLowerMemberPanel.RequestDataList(pageIndex, searchId)
    if this.nodeIndex == 2 then
        UnionManager.SendGetPartnerList(2, this.curUid, PageCount, pageIndex, searchId)
    else
        UnionManager.SendGetPartnerList(1, this.curUid, PageCount, pageIndex, searchId)
    end
end

--================================================================
--更新数据
function UnionLowerMemberPanel.UpdateDataList(data)
    this.pageIndex = data.pageIndex
    this.pageTotal = Functions.CheckPageTotal(data.allPage)
    this.pageNumLabel.text = tostring(this.pageIndex) .. "/" .. tostring(this.pageTotal)
    local list = data.list
    if GetTableSize(list) > 0 then
        UIUtil.SetActive(this.loadingText, false)
        UIUtil.SetActive(this.noDataText, false)
    else
        UIUtil.SetActive(this.loadingText, false)
        UIUtil.SetActive(this.noDataText, true)
    end
    if data.opType == this.nodeIndex then
        if this.nodeIndex == 2 then
            UnionNodeLowMember.UpdateDataList(list)
        else
            UnionNodeLowPartner.UpdateDataList(this.curUid, list)
        end
    end
end
