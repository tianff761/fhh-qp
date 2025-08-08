UnionNodeMyPartner = {}
local this = UnionNodeMyPartner

--每页总数
local PageCount = 3

--初始化
function UnionNodeMyPartner.Init(transform)
    this.transform = transform
    this.gameObject = transform.gameObject
    this.isInitUI = false

    this.isSearched = false
    this.pageIndex = 1
    this.pageTotal = 1
    this.nowDeviceClickItem = nil
end

--检测UI
function UnionNodeMyPartner.CheckUI()
    if this.isInitUI then
        return
    end
    this.isInitUI = true

    this.itemContent = this.transform:Find("ScrollView/Viewport/Content")
    this.itemPrefab = this.itemContent:Find("Item").gameObject

    this.items = {}
    for i = 1, PageCount do
        local item = {}
        table.insert(this.items, item)
        --
        item.gameObject = CreateGO(this.itemPrefab, this.itemContent, tostring(i))
        item.transform = item.gameObject.transform
        item.headIconGo = item.transform:Find("Index0/Head/Icon").gameObject
        item.isOnline = item.transform:Find("Index0/Head/IsOnline").gameObject
        item.headIcon = item.headIconGo:GetComponent(TypeImage)
        item.nameLabel = item.transform:Find("Index0/NameText"):GetComponent(TypeText)
        item.idLabel = item.transform:Find("Index0/IdText"):GetComponent(TypeText)
        item.deviceBtn = item.transform:Find("Index0/DeviceBtn").gameObject

        item.deviceBG = item.transform:Find("Index0/DeviceBG").gameObject
        item.deviceText = item.transform:Find("Index0/DeviceBG/DeviceText"):GetComponent(TypeText)

        item.label1 = item.transform:Find("Text1"):GetComponent(TypeText)
        item.label2 = item.transform:Find("Text2"):GetComponent(TypeText)
        item.label3 = item.transform:Find("Text3"):GetComponent(TypeText)

        item.totalScoreLabel = item.transform:Find("Text4/Text1"):GetComponent(TypeText)
        item.totalPlayerLabel = item.transform:Find("Text4/Text2"):GetComponent(TypeText)
        item.warnLabel = item.transform:Find("Text5/Text1"):GetComponent(TypeText)

        local layout = item.transform:Find("Layout")
        item.button1 = layout:Find("Button1").gameObject
        item.button2 = layout:Find("Button2").gameObject
        item.button3 = layout:Find("Button3").gameObject
        item.button4 = layout:Find("Button4").gameObject
        item.button5 = layout:Find("Button5").gameObject
        item.button6 = layout:Find("Button6").gameObject
        item.button7 = layout:Find("Button7").gameObject

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
        EventUtil.AddOnClick(item.button4, function()
            this.HideDevice()
            this.OnButton4Click(item)
        end)
        EventUtil.AddOnClick(item.button5, function()
            this.HideDevice()
            this.OnButton5Click(item)
        end)
        EventUtil.AddOnClick(item.button6, function()
            this.HideDevice()
            this.OnButton6Click(item)
        end)
        EventUtil.AddOnClick(item.button7, function()
            this.HideDevice()
            this.OnButton7Click(item)
        end)
    end

    local page = this.transform:Find("Bottom/Page")
    this.lastBtn = page:Find("LastBtn").gameObject
    this.nextBtn = page:Find("NextBtn").gameObject
    this.pageLabel = page:Find("PageText/Text"):GetComponent(TypeText)
    this.searchBtn = this.transform:Find("Bottom/SearchBtn").gameObject
    this.input = this.transform:Find("Bottom/SearchInput"):GetComponent(TypeInputField)

    this.loading = this.transform:Find("LoadingText").gameObject
    this.noData = this.transform:Find("NoDataText").gameObject

    this.AddUIEventListener()
end

function UnionNodeMyPartner.Open()
    this.CheckUI()
    this.AddEventListener()
    this.SendGetPartnerList(this.pageIndex)
end

function UnionNodeMyPartner.Close()
    this.RemoveEventListener()
    this.isSearched = false
    this.searchId = ""
    this.input.text = ""
    this.pageIndex = 1
    this.pageTotal = 1
    this.HideDevice()
end

------------------------------------------------------------------
--
--注册事件
function UnionNodeMyPartner.AddEventListener()
    AddEventListener(CMD.Game.UnionRefreshMyPartner, this.OnUnionRefreshMyPartner)
    AddEventListener(CMD.Game.UnionSetScoreRefresh, this.OnUnionSetScoreRefresh)
    AddEventListener(CMD.Game.UnionSetRatioRefresh, this.OnUnionSetRatioRefresh)
    AddEventListener(CMD.Game.UnionSetWarnScoreRefresh, this.OnUnionSetWarnScoreRefresh)
    --
    AddEventListener(CMD.Tcp.Union.S2C_CancelPartner, this.OnCancelPartner)
    AddEventListener(CMD.Tcp.Union.S2C_GetPartnerList, this.OnGetPartnerList)
    AddEventListener(CMD.Tcp.Union.S2C_Kick, this.SendRefreshData)
    AddEventListener(CMD.Tcp.Union.S2C_FreezeMember, this.SendRefreshData)
    AddEventListener(CMD.Tcp.Union.S2C_ClearUnionScore, this.SendRefreshData)
end

--移除事件
function UnionNodeMyPartner.RemoveEventListener()
    RemoveEventListener(CMD.Game.UnionRefreshMyPartner, this.OnUnionRefreshMyPartner)
    RemoveEventListener(CMD.Game.UnionSetScoreRefresh, this.OnUnionSetScoreRefresh)
    RemoveEventListener(CMD.Game.UnionSetRatioRefresh, this.OnUnionSetRatioRefresh)
    RemoveEventListener(CMD.Game.UnionSetWarnScoreRefresh, this.OnUnionSetWarnScoreRefresh)
    --
    RemoveEventListener(CMD.Tcp.Union.S2C_CancelPartner, this.OnCancelPartner)
    RemoveEventListener(CMD.Tcp.Union.S2C_GetPartnerList, this.OnGetPartnerList)
end

--UI相关事件
function UnionNodeMyPartner.AddUIEventListener()
    EventUtil.AddOnClick(this.lastBtn, this.OnLastBtnClick)
    EventUtil.AddOnClick(this.nextBtn, this.OnNextBtnClick)
    EventUtil.AddOnClick(this.searchBtn, this.OnSearchBtnClick)
    this.input.onValueChanged:RemoveAllListeners()
    this.input.onValueChanged:AddListener(this.OnInputFieldValueChanged)
end


--================================================================
--
--刷新当前页
function UnionNodeMyPartner.OnUnionRefreshMyPartner()
    this.SendGetPartnerList(this.pageIndex)
end

--刷新当前页
function UnionNodeMyPartner.OnUnionSetScoreRefresh()
    if PanelManager.IsOpened(PanelConfig.UnionLowerMember) then
        return
    end
    this.SendGetPartnerList(this.pageIndex)
end

--刷新当前页
function UnionNodeMyPartner.OnUnionSetRatioRefresh()
    this.SendGetPartnerList(this.pageIndex)
end

--刷新当前页
function UnionNodeMyPartner.OnUnionSetWarnScoreRefresh()
    if PanelManager.IsOpened(PanelConfig.UnionLowerMember) then
        return
    end
    this.SendGetPartnerList(this.pageIndex)
end

--取消合伙人
function UnionNodeMyPartner.OnCancelPartner(data)
    if data.code == 0 then
        Toast.Show("取消队长成功")
        this.SendGetPartnerList(this.pageIndex)
    else
        UnionManager.ShowError(data.code)
    end
end

--获取列表
function UnionNodeMyPartner.OnGetPartnerList(data)
    if PanelManager.IsOpened(PanelConfig.UnionLowerMember) then
        return
    end
    if data.code == 0 then
        this.UpdateDataList(data.data)
    else
        UnionManager.ShowError(data.code)
    end
end

function UnionNodeMyPartner.OnKick()
    this.SendRefreshData()
end

function UnionNodeMyPartner.SendRefreshData(data)
    if data.code == 0 then
        this.SendGetPartnerList(this.pageIndex)
    else
        UnionManager.ShowError(data.code)
    end
end

--================================================================

--隐藏设备号bg
function UnionNodeMyPartner.HideDevice()
    if this.nowDeviceClickItem ~= nil then
        UIUtil.SetActive(this.nowDeviceClickItem.deviceBG, false)
        this.nowDeviceClickItem = nil
    end
end

--点击查看设备号按钮
function UnionNodeMyPartner.OnDeviceClick(item)
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
function UnionNodeMyPartner.OnHeadClick(item)
    if item.data ~= nil then
        PanelManager.Open(PanelConfig.UnionPersonalData, item.data.pId, true)
    end
end

--警戒线
function UnionNodeMyPartner.OnButton1Click(item)
    if item.data ~= nil then
        local temp = {
            pId = item.data.pId,
            totalScore = item.data.totalScore,
            warnScore = item.data.warnScore
        }
        --PanelManager.Open(PanelConfig.UnionWarnScore, temp)
        PanelManager.Open(PanelConfig.UnionSetRatio, item.data.pId, item.data.per, temp)
    end
end


--取消合伙人
function UnionNodeMyPartner.OnButton2Click(item)
    if item.data ~= nil then
        Alert.Prompt("是否取消【" .. item.data.pName .. "】的队长资格？\n他的下级玩家会成为你的下级玩家，请谨慎使用！", function()
            this.OnAlertCallback(item.data.pId)
        end)
    end
end

--取消提示回调
function UnionNodeMyPartner.OnAlertCallback(id)
    UnionManager.SendCancelPartner(id)
end

--转移小队
function UnionNodeMyPartner.OnButton3Click(item)
    if item.data ~= nil then
        PanelManager.Open(PanelConfig.UnionPartnerChange, item.data.pId)
    end
end

--调整比例
function UnionNodeMyPartner.OnButton4Click(item)
    if item.data ~= nil then
        local temp = {
            pId = item.data.pId,
            totalScore = item.data.totalScore,
            warnScore = item.data.warnScore
        }
        PanelManager.Open(PanelConfig.UnionSetRatio, item.data.pId, item.data.per, temp)
    end
end

--调整分数
function UnionNodeMyPartner.OnButton5Click(item)
    if item.data ~= nil then
        --PanelManager.Open(PanelConfig.UnionSetScore, item.data.pId)
        PanelManager.Open(PanelConfig.UnionScoreChange, item.data.pId)
    end
end

--调整分数
function UnionNodeMyPartner.OnButton6Click(item)
    if item.data ~= nil then
        PanelManager.Open(PanelConfig.UnionPartnerMoreAction, 1, item.data.isIce, item.data.pId)
    end
end

--查看下级
function UnionNodeMyPartner.OnButton7Click(item)
    if item.data ~= nil then
        PanelManager.Open(PanelConfig.UnionLowerMember, {id = item.data.pId, name = item.data.pName, headUrl = item.data.pIcon})
    end
end


--
function UnionNodeMyPartner.OnLastBtnClick()
    if this.pageIndex <= 1 then
        Toast.Show("当前已是首页")
    else
        this.SendGetPartnerList(this.pageIndex - 1)
    end
end

--
function UnionNodeMyPartner.OnNextBtnClick()
    if this.pageIndex >= this.pageTotal then
        Toast.Show("当前已是尾页")
    else
        this.SendGetPartnerList(this.pageIndex + 1)
    end
end

--
function UnionNodeMyPartner.OnSearchBtnClick()
    local text = this.input.text
    if not string.IsNullOrEmpty(text) then
        LockScreen(0.5)
        this.isSearched = true
        this.searchId = text
        this.SendGetPartnerList(1)
    else
        Toast.Show("请输入玩家ID或名称")
    end
end

--监听文本框输入
function UnionNodeMyPartner.OnInputFieldValueChanged(text)
    if this.isSearched then
        if string.IsNullOrEmpty(text) then
            this.isSearched = false
            this.searchId = ""
            this.SendGetPartnerList(1)
        end
    end
end

--================================================================
--
--请求数据
function UnionNodeMyPartner.SendGetPartnerList(pageIndex)
    UnionManager.SendGetPartnerList(1, UserData.GetUserId(), PageCount, pageIndex, this.searchId)
end

--
--更新数据
function UnionNodeMyPartner.UpdateDataList(data)
    --合伙人是1
    if data.opType ~= 1 then
        return
    end

    this.pageIndex = data.pageIndex
    this.pageTotal = Functions.CheckPageTotal(data.allPage)

    this.pageLabel.text = tostring(this.pageIndex) .. "/" .. tostring(this.pageTotal)
    --
    local list = data.list
    if GetTableSize(list) > 0 then
        UIUtil.SetActive(this.loading, false)
        UIUtil.SetActive(this.noData, false)

        local item = nil
        local itemData = nil
        for i = 1, PageCount do
            itemData = list[i]
            item = this.items[i]
            if itemData ~= nil then
                UIUtil.SetActive(item.gameObject, true)
                this.SetItem(item, itemData)
            else
                if item.data ~= nil then
                    item.data = nil
                    UIUtil.SetActive(item.gameObject, false)
                end
            end
        end
    else
        UIUtil.SetActive(this.loading, false)
        UIUtil.SetActive(this.noData, true)
        local item = nil
        for i = 1, PageCount do
            item = this.items[i]
            if item.data ~= nil then
                item.data = nil
                UIUtil.SetActive(item.gameObject, false)
            end
        end
    end
end

--设置Item数据
--tNum今日表情，yNum昨日表情，totalN表情总数，tScore今日业绩，yScore昨日业绩，yPoint昨日分数
function UnionNodeMyPartner.SetItem(item, data)
    --LogError(data)
    item.data = data
    --
    if item.pIcon ~= data.pIcon then
        item.pIcon = data.pIcon
        Functions.SetHeadImage(item.headIcon, data.pIcon)
    end
    UIUtil.SetActive(item.isOnline, data.isOnline == false)
    item.nameLabel.text = tostring(data.pName)
    -- local ShowID = UnionData.GetUidString(data.pId)
    local ShowID = tostring(data.pId) --玩家下级id正常显示，隐私只隐藏下下级玩家id
    item.idLabel.text = "ID:" .. ShowID

    item.label1.text = math.ToRound(data.gold, 2) .. "\n" .. math.ToRound(data.per, 2) .. "%"
    local tKeepBase = data.tBdAll and "(" .. data.tBdAll .. ")" or ""
    local yKeepBase = data.yBdAll and "(" .. data.yBdAll .. ")" or ""
    local tKeepBaseAc = data.tBdAll and "(" .. data.tBd .. ")" or ""
    local yKeepBaseAc = data.tBdAll and "(" .. data.yBd .. ")" or ""
    item.label2.text = math.ToRound(data.tNum, 2) .. "\n" .. tKeepBase .. "\n" .. math.ToRound(data.yNum, 2)  .. "\n" ..  yKeepBase
    item.label3.text = math.ToRound(data.tScore, 2)  .. "\n" ..  tKeepBaseAc .. "\n" .. math.ToRound(data.yScore, 2)  .. "\n" ..  yKeepBaseAc

    item.totalScoreLabel.text = math.ToRound(data.totalScore, 2)
    item.totalPlayerLabel.text = data.playerNum .. "人"
    item.warnLabel.text = math.ToRound(data.warnScore, 2)
    item.deviceText.text = "设备ID:"..data.devId

    this.HideDevice()

    local ReallyID = data.pId
    local isNotSelf = tonumber(ReallyID) ~= UserData.GetUserId()
    this.CheckIsSelfHideButton5(item, isNotSelf)
    this.HideDivertTeamBtn(item, isNotSelf)
end

function UnionNodeMyPartner.CheckIsSelfHideButton5(item, isNotSelf)
    UIUtil.SetActive(item.button1, false)--isNotSelf)
    UIUtil.SetActive(item.button2, false)--isNotSelf)
    UIUtil.SetActive(item.button3, false)--isNotSelf)
    UIUtil.SetActive(item.button4, isNotSelf)
    UIUtil.SetActive(item.button5, isNotSelf)
    UIUtil.SetActive(item.button6, false)--isNotSelf)
    --
    UIUtil.SetActive(item.button7, isNotSelf)
end

function UnionNodeMyPartner.HideDivertTeamBtn(item, isNotSelf)
    UIUtil.SetActive(item.button3, false)--UnionData.IsUnionLeaderOrAdministrator() and isNotSelf)
end
