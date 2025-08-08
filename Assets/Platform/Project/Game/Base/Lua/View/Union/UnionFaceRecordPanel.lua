UnionFaceRecordPanel = ClassPanel("UnionFaceRecordPanel")
local this = UnionFaceRecordPanel

function UnionFaceRecordPanel:Init()
    dofile(ScriptPath.ViewUnion .. "UnionNodeFaceRecord")
    dofile(ScriptPath.ViewUnion .. "UnionNodeKeepBaseRecord")
    dofile(ScriptPath.ViewUnion .. "UnionNodeLuckyValueRecord")

    this.nodeIndex = 0
    this.nodePanels = { UnionNodeFaceRecord,UnionNodeKeepBaseRecord, UnionNodeLuckyValueRecord }
end

function UnionFaceRecordPanel:OnInitUI()
    this = self
    this:Init()

    this.closeBtn = this:Find("Background/CloseBtn").gameObject

    local menuContent = this:Find("Menu/Viewport/Content")
    this.menuToggles = {}
    for i = 1, menuContent.childCount do
        local item = {}
        item.index = i
        item.gameObject = menuContent:Find(tostring(i)).gameObject
        item.toggle = item.gameObject:GetComponent(TypeToggle)
        table.insert(this.menuToggles, item)
        this:AddOnToggle(item.gameObject, function(isOn)
            this.OnMenuValueChanged(item, isOn)
        end)
    end

    for i = 1, #this.nodePanels do
        this.nodePanels[i].Init(this:Find("Node" .. i))
    end

    this.AddUIEventListener()
end

function UnionFaceRecordPanel:OnOpened()
    local temp = this.menuToggles[1]
    temp.toggle.isOn = false
    temp.toggle.isOn = true
    UIUtil.SetActive(this.menuToggles[2].gameObject, UnionData.isBaodi)
end

function UnionFaceRecordPanel:OnClosed()
    this.CloseNode(this.nodeIndex)
    this.nodeIndex = 0
end

------------------------------------------------------------------
--
--注册事件
function UnionFaceRecordPanel.AddEventListener()

end

--移除事件
function UnionFaceRecordPanel.RemoveEventListener()

end

--UI相关事件
function UnionFaceRecordPanel.AddUIEventListener()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
end

--================================================================
--
--菜单按钮点击
function UnionFaceRecordPanel.OnMenuValueChanged(item, isOn)
    if isOn then
        if this.nodeIndex ~= item.index then
            this.CloseNode(this.nodeIndex)
            this.nodeIndex = item.index
            this.OpenNode(this.nodeIndex)
        end
    end
end

--
function UnionFaceRecordPanel.OnCloseBtnClick()
    this:Close()
end
--
--================================================================
--
--关闭节点
function UnionFaceRecordPanel.CloseNode(index)
    local temp = this.nodePanels[index]
    if temp ~= nil then
        UIUtil.SetActive(temp.gameObject, false)
        temp.Close()
    end
end

--打开节点
function UnionFaceRecordPanel.OpenNode(index)
    local temp = this.nodePanels[index]
    if temp ~= nil then
        UIUtil.SetActive(temp.gameObject, true)
        temp.Open()
    end
end