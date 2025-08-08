UnionEnterPanel = ClassPanel("UnionEnterPanel")
local this = UnionEnterPanel

function UnionEnterPanel:Awake()
    this = self

    this.background = this:Find("Content/Background").gameObject
    this.backgroundImage = this.background:GetComponent(TypeImage)
    Functions.SetBackgroundAdaptation(this.backgroundImage)

    this.closeBtn = this:Find("Content/Top/CloseBtn").gameObject
    this.createBtn = this:Find("Content/CreateUnionBtn").gameObject
    this.joinBtn = this:Find("Content/JoinUnionBtn").gameObject

    this.unionItems = {}
    this.itemContent = this:Find("Content/ScrollView/Viewport/Content")
    this.itemPrefab = this.itemContent:Find("Item").gameObject

    this.dropdown = this:Find("Content/Dropdown"):GetComponent(TypeDropdown)
    this.noneGo = this:Find("Content/None").gameObject

    this.AddUIListenerEvent()
end

function UnionEnterPanel:OnOpened(unionId, gameType)
    LockScreen(0.5)
    this.dataType = 0
    this.dropdown.value = 0
    UnionManager.SendGetUnionsList()
end

function UnionEnterPanel:OnClosed()

end

------------------------------------------------------------------
--
function UnionEnterPanel.AddListenerEvent()

end

--
function UnionEnterPanel.RemoveListenerEvent()

end

--
function UnionEnterPanel.AddUIListenerEvent()
    EventUtil.AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    EventUtil.AddOnClick(this.createBtn, this.OnCreateBtnClick)
    EventUtil.AddOnClick(this.joinBtn, this.OnJoinBtnClick)

    this.dropdown.onValueChanged:AddListener(this.OnDropdownValueChanged)
end

function UnionEnterPanel.Close()
    PanelManager.Destroy(PanelConfig.UnionEnter)
end

------------------------------------------------------------------
--

function UnionEnterPanel.OnCloseBtnClick()
    UnionManager.Close()
end

function UnionEnterPanel.OnCreateBtnClick()
    Toast.Show("权限不足")
end

function UnionEnterPanel.OnJoinBtnClick()
    -- Toast.Show("敬请期待...")
    PanelManager.Open(PanelConfig.UnionInputNumber, UnionInputNumberPanelType.JoinUnion, function(num)
        UnionManager.SendApplyJoinUnionsList(num)
        PanelManager.Close(PanelConfig.UnionInputNumber, true)
    end)
end

function UnionEnterPanel.OnDropdownValueChanged(index)
    this.dataType = index
    this.UpdateUnionList()
end

------------------------------------------------------------------
--
function UnionEnterPanel.UpdateUnionList()
    local unionList = UnionData.unionList
    local tempList = {}
    local item = nil
    local data = nil
    if unionList ~= nil then
        local type = 0
        for i = 1, #unionList do
            data = unionList[i]
            if this.dataType == 0 then
                table.insert(tempList, data)
            else
                type = data.role + 1
                if type == this.dataType then
                    table.insert(tempList, data)
                end
            end
        end
    end

    local dataLength = #tempList
    for i = 1, dataLength do
        data = tempList[i]
        item = this.GetItem(i)
        this.SetItem(item, data)
    end
    for i = dataLength + 1, #this.unionItems do
        item = this.unionItems[i]
        if item.data ~= nil then
            item.data = nil
            UIUtil.SetActive(item.gameObject, false)
        end
    end

    if unionList == nil or #unionList == 0 then
        UIUtil.SetActive(this.noneGo, true)
    else
        UIUtil.SetActive(this.noneGo, false)
    end
    --开启GPS检测
    GPSModule.Check()
end

--获取显示对象
function UnionEnterPanel.GetItem(index)
    local item = this.unionItems[index]
    if item == nil then
        item = {}
        item.gameObject = CreateGO(this.itemPrefab, this.itemContent, tostring(index))
        item.transform = item.gameObject.transform
        item.titleLabel = item.transform:Find("Title"):GetComponent(TypeText)
        item.IdLabel = item.transform:Find("Id"):GetComponent(TypeText)
        item.leaderNameLabel = item.transform:Find("Player/Name"):GetComponent(TypeText)
        item.leaderIdLabel = item.transform:Find("Player/Id"):GetComponent(TypeText)
        item.leaderIcon = item.transform:Find("Player/Head/Mask/Icon"):GetComponent(TypeImage)

        item.positionLabel = item.transform:Find("MyPosition/Text"):GetComponent(TypeText)
        item.tableNumLabel = item.transform:Find("TableNum/Text"):GetComponent(TypeText)

        item.data = nil

        EventUtil.AddOnClick(item.transform, function()
            this.OnItemClick(item)
        end)

        table.insert(this.unionItems, item)
    end
    return item
end

function UnionEnterPanel.SetItem(item, data)
    UIUtil.SetActive(item.gameObject, true)
    item.data = data

    item.titleLabel.text = tostring(data.name)
    item.IdLabel.text = "茶馆专属码：" .. tostring(data.key)
    item.leaderNameLabel.text = tostring(data.leaderName)
    local LeaderID = UnionData.IsUnionLeaderOrAdministratorOrObserver() and tostring(data.leaderId) or "******"
    item.leaderIdLabel.text = "ID：" .. LeaderID
    item.positionLabel.text = tostring(UnionRoleName[data.role])

    if data.role == UnionRole.Leader or data.role == UnionRole.Admin or data.role == UnionRole.Observer then
        item.tableNumLabel.text = tostring(data.tableNum)
    else
        item.tableNumLabel.text = "**"
    end
    Functions.SetHeadImage(item.leaderIcon, data.leaderHeadIcon)
end

function UnionEnterPanel.OnItemClick(item)
    if UnionData.SetCurUnionId(item.data.id) then
        PanelManager.Open(PanelConfig.UnionRoom)
    else
        Toast.Show("当前茶馆不存在")
    end
end
