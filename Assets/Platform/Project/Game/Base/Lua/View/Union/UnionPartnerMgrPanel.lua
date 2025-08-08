UnionPartnerMgrPanel = ClassPanel("UnionPartnerMgrPanel")
local this = UnionPartnerMgrPanel

function UnionPartnerMgrPanel:Init()
    dofile(ScriptPath.ViewUnion .. "UnionNodePartnerCount")
    dofile(ScriptPath.ViewUnion .. "UnionNodeMyPartner")
    dofile(ScriptPath.ViewUnion .. "UnionNodeMyMember")
    dofile(ScriptPath.ViewUnion .. "UnionNodeScoreGet")
    dofile(ScriptPath.ViewUnion .. "UnionNodeKeepBaseGet")
    dofile(ScriptPath.ViewUnion .. "UnionNodeScoreRecord")
    dofile(ScriptPath.ViewUnion .. "UnionNodeMyTeam")
    dofile(ScriptPath.ViewUnion .. "UnionNodeNewMyTeam")

    this.nodeIndex = 0
    this.nodePanels = { UnionNodePartnerCount, UnionNodeMyPartner, UnionNodeMyMember, UnionNodeScoreGet, UnionNodeKeepBaseGet, UnionNodeScoreRecord, UnionNodeMyTeam, UnionNodeNewMyTeam }
    LogError("new nodePanels", this.nodePanels)
end

function UnionPartnerMgrPanel:OnInitUI()
    this = self
    this:Init()

    local content = this:Find("Content")

    this.closeBtn = content:Find("Background/CloseBtn").gameObject

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

    LogError("get nodePanels", this.nodePanels)
    for i = 1, total do
        this.nodePanels[i].Init(content:Find("Node" .. i))
    end

    UIUtil.SetActive(this.menuToggles[3].gameObject, not UnionData.IsUnionAdministratorOrObserver())--UnionData.IsUnionLeader())
    UIUtil.SetActive(this.menuToggles[7].gameObject, false)--UnionData.IsUnionLeader())

    this.AddUIEventListener()
end

function UnionPartnerMgrPanel:OnOpened()
    this.AddEventListener()
    local temp = this.menuToggles[1]
    temp.toggle.isOn = false
    temp.toggle.isOn = true
end

function UnionPartnerMgrPanel:OnClosed()
    this.RemoveEventListener()
    this.CloseNode(this.nodeIndex)
    this.nodeIndex = 0
end

------------------------------------------------------------------
--
--注册事件
function UnionPartnerMgrPanel.AddEventListener()
    AddEventListener(CMD.Game.UnionBaodiUpdate, this.OnUnionBaodiUpdate)
end

--移除事件
function UnionPartnerMgrPanel.RemoveEventListener()
    RemoveEventListener(CMD.Game.UnionBaodiUpdate, this.OnUnionBaodiUpdate)
end

--UI相关事件
function UnionPartnerMgrPanel.AddUIEventListener()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
end

--================================================================
--
--关闭
function UnionPartnerMgrPanel.Close()
    PanelManager.Destroy(PanelConfig.UnionPartnerMgr)
end

--================================================================
--
--菜单按钮点击
function UnionPartnerMgrPanel.OnMenuValueChanged(item, isOn)
    if isOn then
        if this.nodeIndex ~= item.index then
            this.CloseNode(this.nodeIndex)
            this.nodeIndex = item.index
            this.OpenNode(this.nodeIndex)
        end
    end
end

--
function UnionPartnerMgrPanel.OnCloseBtnClick()
    this.Close()
end

--================================================================
--
function UnionPartnerMgrPanel.OnUnionBaodiUpdate()
    UIUtil.SetActive(this.menuToggles[5].gameObject, UnionData.isBaodi)
end

--================================================================
--
--关闭节点
function UnionPartnerMgrPanel.CloseNode(index)
    local temp = this.nodePanels[index]
    if temp ~= nil then
        UIUtil.SetActive(temp.gameObject, false)
        temp.Close()
    end
end

--打开节点
function UnionPartnerMgrPanel.OpenNode(index)
    local temp = this.nodePanels[index]
    if temp ~= nil then
        UIUtil.SetActive(temp.gameObject, true)
        temp.Open()
    end
end