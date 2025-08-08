UnionNodeLowMember = {}
local this = UnionNodeLowMember
local PageCount = 3

--初始化
function UnionNodeLowMember.Init(transform)
    this.transform = transform
    this.gameObject = transform.gameObject
    this.isInitUI = false
    this.isOpen = false
    this.nowDeviceClickItem = nil
    this.items = {}
end

--检测UI
function UnionNodeLowMember.CheckUI()
    if this.isInitUI then
        return
    end
    this.isInitUI = true

    this.itemContent = this.transform:Find("ScrollView/Viewport/Content")
    this.itemPrefab = this.itemContent:Find("Item").gameObject

    for i = 1, PageCount do
        local item = {}
        table.insert(this.items, item)
        --
        item.gameObject = CreateGO(this.itemPrefab, this.itemContent, tostring(i))
        item.transform = item.gameObject.transform

        local head = item.transform:Find("Head")
        item.headBtn = head:Find("Mask/HeadImg")
        item.headImg = item.headBtn:GetComponent(TypeImage)
        item.nameLabel = head:Find("Name"):GetComponent(TypeText)
        item.idLabel = head:Find("ID"):GetComponent(TypeText)

        --设备号
        item.deviceBtn = head:Find("DeviceBtn").gameObject
        item.deviceBG = head:Find("DeviceBG").gameObject
        item.deviceText = head:Find("DeviceBG/DeviceText"):GetComponent(TypeText)

        EventUtil.AddOnClick(item.headBtn, function()
            this.HideDevice()
            this.OnHeadClick(item)
        end)

        EventUtil.AddOnClick(item.deviceBtn, function()
            this.OnDeviceClick(item)
        end)

        item.label2 = item.transform:Find("Text2"):GetComponent(TypeText)
        item.label3 = item.transform:Find("Text3"):GetComponent(TypeText)
        item.label4 = item.transform:Find("Text4"):GetComponent(TypeText)

        item.btn = item.transform:Find("7/Button")
        EventUtil.AddOnClick(item.btn, function()
            this.HideDevice()
            this.OnButtonClick(item)
        end)
        UIUtil.SetActive(item.gameObject, false)
    end

    this.AddUIEventListener()
end

function UnionNodeLowMember.Open()
    this.CheckUI()
    if not this.isOpen then
        this.AddEventListener()
    end
    this.isOpen = true
end


function UnionNodeLowMember.Close()
    this.isOpen = false
    this.HideDevice()
    this.RemoveEventListener()
end

------------------------------------------------------------------
--
--注册事件
function UnionNodeLowMember.AddEventListener()

end

--移除事件
function UnionNodeLowMember.RemoveEventListener()

end

--UI相关事件
function UnionNodeLowMember.AddUIEventListener()

end

--================================================================

--隐藏设备号bg
function UnionNodeLowMember.HideDevice()
    if this.nowDeviceClickItem ~= nil then
        UIUtil.SetActive(this.nowDeviceClickItem.deviceBG, false)
        this.nowDeviceClickItem = nil
    end
end

--点击查看设备号按钮
function UnionNodeLowMember.OnDeviceClick(item)
    if item.data == nil then
        return
    end
    if this.nowDeviceClickItem ~= nil then
        UIUtil.SetActive(this.nowDeviceClickItem.deviceBG, false)
        if this.nowDeviceClickItem.data.pId == item.data.pId then
            this.nowDeviceClickItem = nil
            return
        end
    end
    this.nowDeviceClickItem = item
    UIUtil.SetActive(this.nowDeviceClickItem.deviceBG, true)
end


--
--查看个人数据
function UnionNodeLowMember.OnHeadClick(item)
    if item.data ~= nil then
        PanelManager.Open(PanelConfig.UnionPersonalData, item.data.pId, true)
    end
end

--调整分数
function UnionNodeLowMember.OnButtonClick(item)
    if item.data ~= nil then
        PanelManager.Open(PanelConfig.UnionScoreChange, item.data.pId)
    end
end

--================================================================
--
--更新数据
function UnionNodeLowMember.UpdateDataList(list)
    local length = #list
    if length > PageCount then
        length = PageCount 
    end
    local data = nil
    local item = nil
    for i = 1, length do
        data = list[i]
        item = this.items[i]
        this.SetItem(item, data)
    end
    for i = length + 1, #this.items do
        item = this.items[i]
        if item.data ~= nil then
            item.data = nil
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end


--设置Item数据
--tNum今日表情，yNum昨日表情，totalN表情总数，tScore今日业绩，yScore昨日业绩，yPoint昨日分数
function UnionNodeLowMember.SetItem(item, data)
    --LogError(data)
    item.data = data
    UIUtil.SetActive(item.gameObject, true)
    --
    if item.pIcon ~= data.pIcon then
        item.pIcon = data.pIcon
        Functions.SetHeadImage(item.headImg, data.pIcon)
    end
    item.nameLabel.text = tostring(data.pName)
    item.idLabel.text = "ID:" .. UnionData.GetUidString(data.pId)
    item.deviceText.text = "设备ID:"..data.devId
    
    item.label2.text = math.ToRound(data.gold, 2)
    item.label3.text = math.ToRound(data.tNum, 2) .. "\n" .. math.ToRound(data.yNum, 2)
    item.label4.text = math.ToRound(data.tScore, 2) .. "\n" .. math.ToRound(data.yScore, 2)
    this.HideDevice()
end