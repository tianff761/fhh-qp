UnionNodeMyMember = {}
local this = UnionNodeMyMember

--每页总数
local PageCount = 3

--初始化
function UnionNodeMyMember.Init(transform)
    this.transform = transform
    this.gameObject = transform.gameObject
    this.isInitUI = false

    this.isSearched = false
    this.pageIndex = 1
    this.pageTotal = 1
    this.nowDeviceClickItem = nil
end

--检测UI
function UnionNodeMyMember.CheckUI()
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
        item.headIconGo = item.transform:Find("Head/Icon").gameObject
        item.isOnline = item.transform:Find("Head/IsOnline").gameObject
        item.headIcon = item.headIconGo:GetComponent(TypeImage)
        item.nameLabel = item.transform:Find("NameText"):GetComponent(TypeText)
        item.idLabel = item.transform:Find("IdText"):GetComponent(TypeText)
        item.label1 = item.transform:Find("NumText1"):GetComponent(TypeText)
        item.label2 = item.transform:Find("NumText2"):GetComponent(TypeText)
        item.label3 = item.transform:Find("NumText3"):GetComponent(TypeText)

        --设备号
        item.deviceBtn = item.transform:Find("DeviceBtn").gameObject
        item.deviceBG = item.transform:Find("DeviceBG").gameObject
        item.deviceText = item.transform:Find("DeviceBG/DeviceText"):GetComponent(TypeText)

        item.ID = 0
        local layout = item.transform:Find("Layout")
        item.button1 = layout:Find("Button1").gameObject
        item.button2 = layout:Find("Button2").gameObject
        item.button3 = layout:Find("Button3").gameObject
        item.button4 = layout:Find("Button4").gameObject
        item.button5 = layout:Find("Button5").gameObject
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

function UnionNodeMyMember.Open()
    this.CheckUI()
    this.AddEventListener()
    this.SendGetPartnerList(this.pageIndex)
end

function UnionNodeMyMember.Close()
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
function UnionNodeMyMember.AddEventListener()
    AddEventListener(CMD.Game.UnionSetScoreRefresh, this.OnUnionSetScoreRefresh)
    --
    AddEventListener(CMD.Tcp.Union.S2C_AddPartner, this.OnTcpAddPartnerMember)
    AddEventListener(CMD.Tcp.Union.S2C_Kick, this.OnKick)
    AddEventListener(CMD.Tcp.Union.S2C_GetPartnerList, this.OnGetPartnerList)
    AddEventListener(CMD.Tcp.Union.S2C_Union_SetScore, this.ResponseSetScore)
end

--移除事件
function UnionNodeMyMember.RemoveEventListener()
    RemoveEventListener(CMD.Game.UnionSetScoreRefresh, this.OnUnionSetScoreRefresh)
    --
    RemoveEventListener(CMD.Tcp.Union.S2C_AddPartner, this.OnTcpAddPartnerMember)
    RemoveEventListener(CMD.Tcp.Union.S2C_Kick, this.OnKick)
    RemoveEventListener(CMD.Tcp.Union.S2C_GetPartnerList, this.OnGetPartnerList)
    RemoveEventListener(CMD.Tcp.Union.S2C_Union_SetScore, this.ResponseSetScore)
end

--UI相关事件
function UnionNodeMyMember.AddUIEventListener()
    EventUtil.AddOnClick(this.lastBtn, this.OnLastBtnClick)
    EventUtil.AddOnClick(this.nextBtn, this.OnNextBtnClick)
    EventUtil.AddOnClick(this.searchBtn, this.OnSearchBtnClick)
    this.input.onValueChanged:RemoveAllListeners()
    this.input.onValueChanged:AddListener(this.OnInputFieldValueChanged)
end


--================================================================
--
--刷新当前页
function UnionNodeMyMember.OnUnionSetScoreRefresh()
    if PanelManager.IsOpened(PanelConfig.UnionLowerMember) then
        return
    end
    this.SendGetPartnerList(this.pageIndex)
end

--设置合伙人
function UnionNodeMyMember.OnTcpAddPartnerMember(data)
    if data.code == 0 then
        Toast.Show("设置队长成功")
        this.SendGetPartnerList(this.pageIndex)
    else
        UnionManager.ShowError(data.code)
    end
end

--踢出
function UnionNodeMyMember.OnKick(data)
    if data.code == 0 then
        this.SendGetPartnerList(this.pageIndex)
    else
        UnionManager.ShowError(data.code)
    end
end

--获取列表
function UnionNodeMyMember.OnGetPartnerList(data)
    if PanelManager.IsOpened(PanelConfig.UnionLowerMember) then
        return
    end
    if data.code == 0 then
        this.UpdateDataList(data.data)
    else
        UnionManager.ShowError(data.code)
    end
end

--================================================================

--隐藏设备号bg
function UnionNodeMyMember.HideDevice()
    if this.nowDeviceClickItem ~= nil then
        UIUtil.SetActive(this.nowDeviceClickItem.deviceBG, false)
        this.nowDeviceClickItem = nil
    end
end

--点击查看设备号按钮
function UnionNodeMyMember.OnDeviceClick(item)
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
function UnionNodeMyMember.OnHeadClick(item)
    if item.data ~= nil then
        PanelManager.Open(PanelConfig.UnionPersonalData, item.data.pId, true)
    end
end

--设置合伙人
function UnionNodeMyMember.OnButton1Click(item)
    if item.data ~= nil then
        PanelManager.Open(PanelConfig.UnionSetPartner, item.data.pName, function(per)
            UnionManager.SendAddPartnerMember(item.data.pId, per)
        end)
    end
end

--设置合伙人提示回调
function UnionNodeMyMember.OnSetPartnerAlertCallback(id)
    UnionManager.SendAddPartnerMember(id)
end

--转移成员
function UnionNodeMyMember.OnButton2Click(item)
    if item.data ~= nil then
        PanelManager.Open(PanelConfig.UnionMemberChange, item.data.pId)
    end
end

--踢出
function UnionNodeMyMember.OnButton3Click(item)
    if item.data ~= nil then
        Alert.Prompt("是否把【" .. item.data.pName .. "】踢出战队？", function()
            this.OnKickAlertCallback(item.data.pId)
        end)
    end
end

--踢出提示回调
function UnionNodeMyMember.OnKickAlertCallback(id)
    UnionManager.SendKick(id)
end

--调整分数
function UnionNodeMyMember.OnButton4Click(item)
    if item.data ~= nil then
        --PanelManager.Open(PanelConfig.UnionSetScore, item.data.pId)
        PanelManager.Open(PanelConfig.UnionScoreChange, item.data.pId)
    end
end

--调整分数
function UnionNodeMyMember.OnButton5Click(item)
    if item.data ~= nil then
        Alert.Prompt("是否清除此玩家所有积分？", function()
            UnionManager.SendSetScore(item.ID, -item.Score)
        end)
    end
end

--
function UnionNodeMyMember.OnLastBtnClick()
    if this.pageIndex <= 1 then
        Toast.Show("当前已是首页")
    else
        this.SendGetPartnerList(this.pageIndex - 1)
    end
end

--
function UnionNodeMyMember.OnNextBtnClick()
    if this.pageIndex >= this.pageTotal then
        Toast.Show("当前已是尾页")
    else
        this.SendGetPartnerList(this.pageIndex + 1)
    end
end

--
function UnionNodeMyMember.OnSearchBtnClick()
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
function UnionNodeMyMember.OnInputFieldValueChanged(text)
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
function UnionNodeMyMember.SendGetPartnerList(pageIndex)
    UnionManager.SendGetPartnerList(2, UserData.GetUserId(), PageCount, pageIndex, this.searchId)
end

--
--更新数据
function UnionNodeMyMember.UpdateDataList(data)
    --玩家是2
    if data.opType ~= 2 then
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
function UnionNodeMyMember.SetItem(item, data)
    item.data = data
    --
    if item.pIcon ~= data.pIcon then
        item.pIcon = data.pIcon
        Functions.SetHeadImage(item.headIcon, data.pIcon)
    end
    UIUtil.SetActive(item.isOnline, data.isOnline == false)
    item.nameLabel.text = tostring(data.pName)
    -- local ID = UnionData.GetUidString(data.pId)
    local ID = tostring(data.pId) --玩家下级id正常显示，隐私只隐藏下下级玩家id
    item.idLabel.text = "ID:" .. ID
    item.ID = data.pId
    item.Score = data.gold
    item.deviceText.text = "设备ID:"..data.devId
    item.label1.text = math.ToRound(data.gold, 2) .. "\n" .. data.js
    -- item.label2.text = math.ToRound(data.tNum, 2) .. "\n" .. math.ToRound(data.yNum, 2)
    item.label2.text = math.ToRound(data.tScore, 2) .. "\n" .. math.ToRound(data.yScore, 2)
    item.label3.text = math.ToRound(data.tScore, 2) .. "\n" .. math.ToRound(data.yScore, 2)
    this.HideKickBtnByRole(item)
    this.HideDivertTeamBtn(item)
    this.CheckIsSelfHideButton5(item, ID)
    this.HideDevice()
end

function UnionNodeMyMember.HideKickBtnByRole(item)
    UIUtil.SetActive(item.button3, UnionData.IsUnionLeader())
end

function UnionNodeMyMember.HideDivertTeamBtn(item)
    UIUtil.SetActive(item.button2, false)--UnionData.IsUnionLeaderOrAdministrator())
end

function UnionNodeMyMember.CheckIsSelfHideButton5(item, ID)
    UIUtil.SetActive(item.button4, tonumber(ID) ~= UserData.GetUserId())
end

function UnionNodeMyMember.ResponseSetScore(data)
    if data.code == 0 then
        SendEvent(CMD.Game.UnionSetScoreRefresh)
    else
        UnionManager.ShowError(data.code)
    end
end