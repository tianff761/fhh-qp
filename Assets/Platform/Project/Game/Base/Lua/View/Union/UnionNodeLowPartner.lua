UnionNodeLowPartner = {}
local this = UnionNodeLowPartner
local PageCount = 3

--初始化
function UnionNodeLowPartner.Init(transform)
    this.transform = transform
    this.gameObject = transform.gameObject
    this.isInitUI = false
    this.isOpen = false
    this.nowDeviceClickItem = nil
    this.items = {}
end

--检测UI
function UnionNodeLowPartner.CheckUI()
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
        item.headIconGo = item.transform:Find("1/Head/Icon").gameObject
        item.headIcon = item.headIconGo:GetComponent(TypeImage)
        item.nameLabel = item.transform:Find("1/NameText"):GetComponent(TypeText)
        item.idLabel = item.transform:Find("1/IdText"):GetComponent(TypeText)

        --设备号
        item.deviceBtn = item.transform:Find("1/DeviceBtn").gameObject
        item.deviceBG = item.transform:Find("1/DeviceBG").gameObject
        item.deviceText = item.transform:Find("1/DeviceBG/DeviceText"):GetComponent(TypeText)

        item.label2 = item.transform:Find("Text2"):GetComponent(TypeText)
        item.label3 = item.transform:Find("Text3"):GetComponent(TypeText)
        item.label4 = item.transform:Find("Text4"):GetComponent(TypeText)

        item.totalScoreLabel = item.transform:Find("5/Text1"):GetComponent(TypeText)
        item.totalPlayerLabel = item.transform:Find("5/Text2"):GetComponent(TypeText)
        item.warnLabel = item.transform:Find("6/Text1"):GetComponent(TypeText)

        local layout = item.transform:Find("7")
        item.button1 = layout:Find("Button1").gameObject
        item.button2 = layout:Find("Button2").gameObject
        item.button3 = layout:Find("Button3").gameObject

        UIUtil.SetActive(item.gameObject, false)

        EventUtil.AddOnClick(item.deviceBtn, function()
            this.OnDeviceClick(item)
        end)

        EventUtil.AddOnClick(item.headIconGo, function()
            this.HideDevice()
            this.OnHeadClick(item)
        end)
        EventUtil.AddOnClick(item.button1, function()
            this.HideDevice()
            this.OnButton1Click(item)
        end)
        EventUtil.AddOnClick(item.button2, function()
            this.HideDevice()
            this.OnButton2Click(item)
        end)
        EventUtil.AddOnClick(item.button3, function()
            this.HideDevice()
            this.OnButton3Click(item)
        end)
    end

    this.AddUIEventListener()
end

function UnionNodeLowPartner.Open()
    this.CheckUI()
    if not this.isOpen then
        this.AddEventListener()
    end
    this.isOpen = true
end

function UnionNodeLowPartner.Close()
    this.isOpen = false
    this.HideDevice()
    this.RemoveEventListener()
end

------------------------------------------------------------------
--
--注册事件
function UnionNodeLowPartner.AddEventListener()

end

--移除事件
function UnionNodeLowPartner.RemoveEventListener()

end

--UI相关事件
function UnionNodeLowPartner.AddUIEventListener()

end

--================================================================


--隐藏设备号bg
function UnionNodeLowPartner.HideDevice()
    if this.nowDeviceClickItem ~= nil then
        UIUtil.SetActive(this.nowDeviceClickItem.deviceBG, false)
        this.nowDeviceClickItem = nil
    end
end

--点击查看设备号按钮
function UnionNodeLowPartner.OnDeviceClick(item)
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
function UnionNodeLowPartner.OnHeadClick(item)
    if item.data ~= nil then
        PanelManager.Open(PanelConfig.UnionPersonalData, item.data.pId, true)
    end
end

--警戒线
function UnionNodeLowPartner.OnButton1Click(item)
    if item.data ~= nil then
        local temp = {
            pId = item.data.pId,
            totalScore = item.data.totalScore,
            warnScore = item.data.warnScore
        }
        PanelManager.Open(PanelConfig.UnionWarnScore, temp)
    end
end

--调整分数
function UnionNodeLowPartner.OnButton2Click(item)
    if item.data ~= nil then
        PanelManager.Open(PanelConfig.UnionScoreChange, item.data.pId)
    end
end

--查看下级
function UnionNodeLowPartner.OnButton3Click(item)
    if item.data ~= nil then
        SendEvent(CMD.Game.UnionViewLowMember, {id = item.data.pId, name = item.data.pName, headUrl = item.data.pIcon})
    end
end

--================================================================
--
--更新数据
function UnionNodeLowPartner.UpdateDataList(pid, list)
    this.pid = pid
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
function UnionNodeLowPartner.SetItem(item, data)
    --LogError(data)
    item.data = data
    UIUtil.SetActive(item.gameObject, true)
    --
    if item.pIcon ~= data.pIcon then
        item.pIcon = data.pIcon
        Functions.SetHeadImage(item.headIcon, data.pIcon)
    end
    item.nameLabel.text = tostring(data.pName)
    local ShowID = UnionData.GetUidString(data.pId)
    item.idLabel.text = "ID:" .. ShowID
    item.deviceText.text = "设备ID:"..data.devId

    item.label2.text = math.ToRound(data.gold, 2) .. "\n" .. math.ToRound(data.per, 2) .. "%"
    local tKeepBase = data.tBdAll and "(" .. data.tBdAll .. ")" or ""
    local yKeepBase = data.yBdAll and "(" .. data.yBdAll .. ")" or ""
    local tKeepBaseAc = data.tBdAll and "(" .. data.tBd .. ")" or ""
    local yKeepBaseAc = data.tBdAll and "(" .. data.yBd .. ")" or ""
    item.label3.text = math.ToRound(data.tNum, 2) .. tKeepBase .. "\n" .. math.ToRound(data.yNum, 2) .. yKeepBase
    item.label4.text = math.ToRound(data.tScore, 2) .. tKeepBaseAc .. "\n" .. math.ToRound(data.yScore, 2) .. yKeepBaseAc

    item.totalScoreLabel.text = math.ToRound(data.totalScore, 2)
    item.totalPlayerLabel.text = data.playerNum .. "人"
    item.warnLabel.text = math.ToRound(data.warnScore, 2)

    local isNotSelf = tonumber(data.pId) ~= this.pid
    UIUtil.SetActive(item.button1, isNotSelf)
    UIUtil.SetActive(item.button2, isNotSelf)
    UIUtil.SetActive(item.button3, isNotSelf)
    this.HideDevice()
end