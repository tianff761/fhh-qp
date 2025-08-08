UnionPersonalDataPanel = ClassPanel("UnionPersonalDataPanel")
local this = UnionPersonalDataPanel

--每页总数
local PageCount = 4

--初始化
function UnionPersonalDataPanel.Init()
    this.pageIndex = 1
    this.pageTotal = 1
    this.nodeIndex = 0
end

function UnionPersonalDataPanel:Awake()
    this = self
    this.Init()

    local content = this:Find("Content")

    this.closeBtn = content:Find("Background/CloseBtn")

    local menuContent = content:Find("Menu/Viewport/Content")
    this.menuToggles = {}
    for i = 1, 10 do
        local item = {}
        item.index = i
        item.gameObject = menuContent:Find(tostring(i)).gameObject
        item.toggle = item.gameObject:GetComponent(TypeToggle)
        table.insert(this.menuToggles, item)
        this:AddOnToggle(item.gameObject, function(isOn)
            this.OnMenuValueChanged(item, isOn)
        end)
    end

    this.pageNodes = {}
    for i = 1, 10 do
        local item = {}
        table.insert(this.pageNodes, item)
        item.transform = content:Find("Content/" .. i)
        item.gameObject = item.transform.gameObject
        item.itemContent = item.transform:Find("Content")
        item.itemPrefab = i ~= 10 and item.itemContent:Find("Item") or 1
        item.items = {}
    end

    local page = content:Find("Content/Bottom/Page")
    this.lastBtn = page:Find("LastBtn").gameObject
    this.nextBtn = page:Find("NextBtn").gameObject
    this.pageTextNode = page:Find("PageText").gameObject
    this.pageLabel = page:Find("PageText/Text"):GetComponent(TypeText)

    this.loading = content:Find("Content/LoadingText").gameObject
    this.noData = content:Find("Content/NoDataText").gameObject

    this.Title1 = content:Find("Content/2/Titles").gameObject
    this.Title2 = content:Find("Content/2/Titles2").gameObject

    this.Node5Title3 = content:Find("Content/5/Titles/Label3")

    this.searchIdInput = content:Find("Content/Bottom/SearchInput")
    local inputField = this.searchIdInput:GetComponent(TypeInputField)
    inputField.onValueChanged:RemoveAllListeners()
    inputField.onValueChanged:AddListener(this.OnInputFieldValueChanged)

    this.searchId = 0
    this.AddUIEventListener()

    this.scrollView = content:Find("Content/10/RecordScrollView")
    this.tipsText = this.scrollView:Find("Tips")
    this.recordScrollRect = this.scrollView:GetComponent("ScrollRectExtension")
    this.playerItemGO = this.scrollView:Find("PlayerItem")
    this.InitScrollRect()
end

function UnionPersonalDataPanel:OnOpened(userId, isHeadBtnOpen)
    this.userId = userId
    this.AddEventListener()
    this.isHeadBtnOpen = isHeadBtnOpen and true or false
    --UIUtil.SetActive(this.TitleImgObj, this.isHeadBtnOpen)
    --UIUtil.SetActive(this.TitleTxtObj, not this.isHeadBtnOpen)
    if this.isHeadBtnOpen then
        UIUtil.SetActive(this.menuToggles[1].gameObject, false)
        UIUtil.SetActive(this.menuToggles[2].gameObject, true)
        UIUtil.SetActive(this.menuToggles[3].gameObject, true)
        UIUtil.SetActive(this.menuToggles[4].gameObject, false)
        UIUtil.SetActive(this.menuToggles[5].gameObject, UnionData.IsUnionLeaderOrAdministratorOrObserver())
        UIUtil.SetActive(this.menuToggles[6].gameObject, UnionData.selfRole ~= UnionRole.Common)
        UIUtil.SetActive(this.menuToggles[7].gameObject, UnionData.selfRole ~= UnionRole.Common)
        UIUtil.SetActive(this.menuToggles[8].gameObject, false)
        UIUtil.SetActive(this.menuToggles[9].gameObject, UnionData.IsNotCommonPlayer())
        UIUtil.SetActive(this.menuToggles[10].gameObject, UnionData.IsNotCommonPlayer())
    else
        UIUtil.SetActive(this.menuToggles[1].gameObject, true)
        UIUtil.SetActive(this.menuToggles[2].gameObject, true)
        UIUtil.SetActive(this.menuToggles[3].gameObject, true)
        UIUtil.SetActive(this.menuToggles[4].gameObject, true)
        UIUtil.SetActive(this.menuToggles[5].gameObject, UnionData.IsUnionLeaderOrAdministratorOrObserver())
        UIUtil.SetActive(this.menuToggles[6].gameObject, false)
        UIUtil.SetActive(this.menuToggles[7].gameObject, true)
        UIUtil.SetActive(this.menuToggles[8].gameObject, true)
    end
    UIUtil.SetActive(this.Title1, not this.isHeadBtnOpen)
    UIUtil.SetActive(this.Title2, this.isHeadBtnOpen)

    ---默认选中
    local temp = this.isHeadBtnOpen and this.menuToggles[2] or this.menuToggles[1]
    temp.toggle.isOn = false
    temp.toggle.isOn = true

    this.searchFlag = false

    this.InitRecordData()
end

function UnionPersonalDataPanel:OnClosed()
    this.RemoveEventListener()
    this.pageIndex = 1
    this.pageTotal = 1
    this.CloseNode(this.nodeIndex)
    this.nodeIndex = 0
end

--注册事件
function UnionPersonalDataPanel.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_GetUnionMemberList, this.OnTcpGetUnionMemberList)
    AddEventListener(CMD.Tcp.Union.S2C_GameScoreCount, this.OnGameScoreCount)
    AddEventListener(CMD.Tcp.Union.S2C_Union_ScoreChange, this.OnScoreChange)
    AddEventListener(CMD.Tcp.Union.S2C_SameTableInfo, this.UpdateSameTableInfo)
    AddEventListener(CMD.Tcp.Union.S2C_MyGameScoreInfo, this.OnGameScoreCount)
    AddEventListener(CMD.Tcp.Union.S2C_UpDownPlayers, this.UpdateUpDownPlayers)
    AddEventListener(CMD.Tcp.Union.S2C_TeamStatistics, this.UpdateTeamStatistics)
    AddEventListener(CMD.Tcp.Union.S2C_Record, this.UpdateMemberChangeRecord)
    AddEventListener(CMD.Game.UnionUpdateMatchScore, this.RequestUpdateMatchScore)
    AddEventListener(CMD.Tcp.Union.S2C_UNION_SCORE_DETAIL, this.ResponseScoreDetail)
    AddEventListener(CMD.Tcp.Union.S2C_UNION_FIND_RECORD, this.OnUnionRecord)
end

--移除事件
function UnionPersonalDataPanel.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.Union.S2C_GetUnionMemberList, this.OnTcpGetUnionMemberList)
    RemoveEventListener(CMD.Tcp.Union.S2C_GameScoreCount, this.OnGameScoreCount)
    RemoveEventListener(CMD.Tcp.Union.S2C_Union_ScoreChange, this.OnScoreChange)
    RemoveEventListener(CMD.Tcp.Union.S2C_SameTableInfo, this.UpdateSameTableInfo)
    RemoveEventListener(CMD.Tcp.Union.S2C_MyGameScoreInfo, this.OnGameScoreCount)
    RemoveEventListener(CMD.Tcp.Union.S2C_UpDownPlayers, this.UpdateUpDownPlayers)
    RemoveEventListener(CMD.Tcp.Union.S2C_TeamStatistics, this.UpdateTeamStatistics)
    RemoveEventListener(CMD.Tcp.Union.S2C_Record, this.UpdateMemberChangeRecord)
    RemoveEventListener(CMD.Tcp.Union.C2S_UNION_SCORE_DETAIL, this.ResponseScoreDetail)
    RemoveEventListener(CMD.Tcp.Union.S2C_UNION_FIND_RECORD, this.OnUnionRecord)
end

--UI相关事件
function UnionPersonalDataPanel.AddUIEventListener()
    EventUtil.AddOnClick(this.lastBtn, this.OnLastBtnClick)
    EventUtil.AddOnClick(this.nextBtn, this.OnNextBtnClick)
    EventUtil.AddOnClick(this.closeBtn, this.OnCloseBtnClick)
end

--================================================================
--
--
function UnionPersonalDataPanel.OnCloseBtnClick()
    this:Close()
end
--
function UnionPersonalDataPanel.OnLastBtnClick()
    if this.pageIndex <= 1 then
        Toast.Show("当前已是首页")
    else
        this.SendRequestList(this.pageIndex - 1)
    end
end

--
function UnionPersonalDataPanel.OnNextBtnClick()
    if this.pageIndex >= this.pageTotal then
        Toast.Show("当前已是尾页")
    else
        this.SendRequestList(this.pageIndex + 1)
    end
end

--菜单按钮点击
function UnionPersonalDataPanel.OnMenuValueChanged(item, isOn)
    if isOn then
        if this.nodeIndex ~= item.index then
            this.CloseNode(this.nodeIndex)
            this.nodeIndex = item.index
            this.OpenNode(this.nodeIndex)
        end
    end
end

function UnionPersonalDataPanel.OnInputFieldValueChanged(text)
    LogError("<color=aqua>string.IsNullOrEmpty(text)</color>", string.IsNullOrEmpty(text))
    this.SearchText = string.IsNullOrEmpty(text) and "" or text
    if this.nodeIndex == 4 then
        this.RequestSameTableInfoRequest(1, text)
    elseif this.nodeIndex == 3 then
        this.RequestScoreChangeList(1, text)
    elseif this.nodeIndex == 1 then
        this.RequestGetUnionMemberList(1, text)
    end
end

function UnionPersonalDataPanel.RequestScoreChangeList(pageIndex, searchString)
    if string.IsNullOrEmpty(searchString) then
        UnionManager.SendGetScoreChangeList(this.userId, pageIndex, PageCount)
    else
        UnionManager.SendGetScoreChangeList(this.userId, pageIndex, PageCount, nil, searchString)
    end
end

function UnionPersonalDataPanel.RequestSameTableInfoRequest(pageIndex, text)
    if string.IsNullOrEmpty(text) then
        UnionManager.SendSameTableInfoRequest(pageIndex, PageCount, this.userId)
    else
        UnionManager.SendSameTableInfoRequest(1, PageCount, tonumber(text))
    end
end

function UnionPersonalDataPanel.RequestGetUnionMemberList(pageIndex, text)
    if string.IsNullOrEmpty(text) then
        UnionManager.SendGetUnionMemberList(pageIndex, PageCount, "")
    else
        UnionManager.SendGetUnionMemberList(1, PageCount, tonumber(text))
    end
end

function UnionPersonalDataPanel.RequestUpdateMatchScore()
    UnionPersonalDataPanel.SendRequestList(this.pageIndex)
end
--================================================================
--

function UnionPersonalDataPanel.OnTcpGetUnionMemberList(data)
    if this.nodeIndex ~= 1 then
        return
    end
    if data.code == 0 then
        this.UpdateNode(data.data)
    else
        UnionManager.ShowError(data.code)
    end
end

--游戏统计数据返回
function UnionPersonalDataPanel.OnGameScoreCount(data)
    if this.nodeIndex ~= 2 then
        return
    end
    if data.code == 0 then
        this.UpdateNode(data.data)
    else
        UnionManager.ShowError(data.code)
    end
end

--积分变动数据返回
function UnionPersonalDataPanel.OnScoreChange(data)
    if this.nodeIndex ~= 3 then
        return
    end
    if data.code == 0 then
        LogError("OnScoreChange data", data)
        this.UpdateNode(data.data)
    else
        UnionManager.ShowError(data.code)
    end
end

--积分详情数据返回
function UnionPersonalDataPanel.OnScoreDetails(data)
    if this.nodeIndex ~= 4 then
        return
    end
    if data.code == 0 then
        this.UpdateNode(data.data)
    else
        UnionManager.ShowError(data.code)
    end
end

function UnionPersonalDataPanel.UpdateSameTableInfo(data)
    LogError("UpdateSameTableInfo", data)
    if this.nodeIndex ~= 5 then
        return
    end
    if data.code == 0 then
        if #data.data.list > 0 then
            local isUser1 = data.data.list[1].userid1 == this.userId
            local recentPlayCount = isUser1 and data.data.list[1].user1ju or data.data.list[1].user2ju
            UIUtil.SetText(this.Node5Title3, "最近总场次：" .. recentPlayCount)
        end
        this.UpdateNode(data.data)
    else
        UnionManager.ShowError(data.code)
    end
end

function UnionPersonalDataPanel.UpdateUpDownPlayers(data)
    LogError("上下级玩家返回", data)
    if this.nodeIndex == 6 then
        if data.code == 0 then
            this.UpdateNode(data.data)
        else
            UnionManager.ShowError(data.code)
        end
    end
end

function UnionPersonalDataPanel.UpdateTeamStatistics(data)
    LogError("战队统计", data)
    if this.nodeIndex == 7 then
        if data.code == 0 then
            this.UpdateNode(data.data)
        else
            UnionManager.ShowError(data.code)
        end
    end
end

---更新成员变更记录
function UnionPersonalDataPanel.UpdateMemberChangeRecord(data)
    if this.nodeIndex == 8 then
        if data.code == 0 then
            this.UpdateNode(data.data)
        else
            UnionManager.ShowError(data.code)
        end
    end
end

function UnionPersonalDataPanel.ResponseScoreDetail(data)
    if this.nodeIndex == 9 then
        if data.code == 0 then
            this.UpdateNode(data.data)
        else
            UnionManager.ShowError(data.code)
        end
    end
end

function UnionPersonalDataPanel.OnUnionRecord(data)
    if this.nodeIndex == 10 then
        if data.code == 0 then
            this.SetNode10Panel(data)
        else
            UnionManager.ShowError(data.code)
        end
    end
end
--================================================================
--
--请求数据
function UnionPersonalDataPanel.SendRequestList(pageIndex)
    if this.nodeIndex == 1 then
        this.RequestGetUnionMemberList(pageIndex, this.SearchText)
    elseif this.nodeIndex == 2 then
        if not this.isHeadBtnOpen then
            UnionManager.SendGameScoreCount(this.userId, pageIndex, PageCount)
        else
            UnionManager.SendMyGameScoreInfoReq(UnionData.curUnionId, pageIndex, PageCount, this.userId)
        end
    elseif this.nodeIndex == 3 then
        this.RequestScoreChangeList(pageIndex, this.SearchText)
    elseif this.nodeIndex == 4 then
    elseif this.nodeIndex == 5 then
        this.RequestSameTableInfoRequest(pageIndex, this.SearchText)
    elseif this.nodeIndex == 6 then
        UnionManager.SendUpDownPlayersInfoRequest(pageIndex, PageCount, this.userId)
    elseif this.nodeIndex == 7 then
        UnionManager.SendTeamStatisticInfoRequest(pageIndex, PageCount, this.userId)
    elseif this.nodeIndex == 8 then
        UnionManager.SendRecord(pageIndex, PageCount)
    elseif this.nodeIndex == 9 then
        UnionManager.SentScoreDetailRequest(pageIndex, PageCount, this.userId)
    elseif this.nodeIndex == 10 then
        UnionManager.SendSearchRecord(0, 2, this.userId, pageIndex, this.count)
    end
end

--关闭节点
function UnionPersonalDataPanel.CloseNode(index)
    local temp = this.pageNodes[index]
    if temp ~= nil then
        UIUtil.SetActive(temp.gameObject, false)
    end
end

--打开节点
function UnionPersonalDataPanel.OpenNode(index)
    local temp = this.pageNodes[index]
    if temp ~= nil then
        UIUtil.SetActive(temp.gameObject, true)
        --
        this.pageIndex = 1
        this.pageTotal = 1
        this.pageLabel.text = tostring(this.pageIndex) .. "/" .. tostring(this.pageTotal)
        this.SendRequestList(this.pageIndex)
        --
        this.OpenNodeSetActive(temp)
        this.JudgeShowSearchInput()
        this.HideKeepBaseTitleBySelfUnionRole(temp, index)
        this.JudgeShowPageCtrlBtn()
        if index == 10 then
            this.InitScrollRect()
        end
    end
end

--开启节点1
function UnionPersonalDataPanel.OpenNodeSetActive(node)
    local item = nil
    for i = 1, #node.items do
        item = node.items[i]
        if item.data ~= nil then
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

function UnionPersonalDataPanel.HideKeepBaseTitleBySelfUnionRole(temp, index)
    LogError("HideKeepBaseTitleBySelfUnionRole")
    if index == 7 then
        local Label4 = temp.gameObject.transform:Find("Titles/Label4").gameObject
        UIUtil.SetActive(Label4, UnionData.IsUnionLeaderOrAdministrator())
    end
end

--创建显示对象
function UnionPersonalDataPanel.CreateItem(itemContent, itemPrefab, index)
    local item = {}
    item.gameObject = CreateGO(itemPrefab, itemContent, tostring(index))
    UIUtil.SetActive(item.gameObject, false)
    item.transform = item.gameObject.transform
    item.data = nil
    item.isInit = false
    return item
end

--================================================================
--
--更新游戏统计
function UnionPersonalDataPanel.UpdateNode(data)
    this.pageIndex = data.pageIndex or data.index or data.page
    this.pageTotal = Functions.CheckPageTotal(data.allPage or data.totalPage or data.allIndex)

    this.pageLabel.text = tostring(this.pageIndex) .. "/" .. tostring(this.pageTotal)

    local node = this.pageNodes[this.nodeIndex]
    local list = data.list
    --LogError("GetTableSize(list)", GetTableSize(list))
    if GetTableSize(list) > 0 then
        UIUtil.SetActive(this.loading, false)
        UIUtil.SetActive(this.noData, false)

        local item = nil
        local itemData = nil
        for i = 1, PageCount do
            item = node.items[i]
            itemData = data.list[i]
            if itemData ~= nil then
                if item == nil then
                    item = this.CreateItem(node.itemContent, node.itemPrefab, i)
                    table.insert(node.items, item)
                end
                if this.nodeIndex == 1 then
                    this.SetNode1Item(item, itemData)
                elseif this.nodeIndex == 2 then
                    if not this.isHeadBtnOpen then
                        this.SetNode2Item(item, itemData)
                    else
                        this.SetNodeNew2Item(item, itemData)
                    end
                elseif this.nodeIndex == 3 then
                    this.SetNode3Item(item, itemData)
                elseif this.nodeIndex == 4 then
                    this.SetNode4Item(item, itemData)
                elseif this.nodeIndex == 5 then
                    this.SetNode5Item(item, itemData)
                elseif this.nodeIndex == 6 then
                    this.SetNode6Item(item, itemData)
                elseif this.nodeIndex == 7 then
                    this.SetNode7Item(item, itemData)
                elseif this.nodeIndex == 8 then
                    this.SetNode8Item(item, itemData)
                elseif this.nodeIndex == 9 then
                    this.SetNode9Item(item, itemData)
                end
            else
                if item ~= nil and itemData == nil then
                    UIUtil.SetActive(item.gameObject, false)
                end
            end
        end
    else
        UIUtil.SetActive(this.loading, false)
        UIUtil.SetActive(this.noData, true)
        local item = nil
        for i = 1, PageCount do
            item = node.items[i]
            if item ~= nil and item.data ~= nil then
                item.data = nil
                UIUtil.SetActive(item.gameObject, false)
            end
        end
    end
end

function UnionPersonalDataPanel.JudgeShowSearchInput()
    UIUtil.SetActive(this.searchIdInput.gameObject, this.nodeIndex == 4 or this.nodeIndex == 1 or this.nodeIndex == 3)
end

function UnionPersonalDataPanel.JudgeShowPageCtrlBtn()
    UIUtil.SetActive(this.lastBtn, this.nodeIndex ~= 10)
    UIUtil.SetActive(this.nextBtn, this.nodeIndex ~= 10)
    UIUtil.SetActive(this.pageTextNode, this.nodeIndex ~= 10)
end

function UnionPersonalDataPanel.SetNode1Item(item, data)
    if item.isInit ~= true then
        item.isInit = true
        item.label1 = item.transform:Find("Text1"):GetComponent(TypeText)
        item.HeadImg = item.transform:Find("Text1/Mask/HeadImg"):GetComponent(TypeImage)
        item.Name = item.transform:Find("Text1/Name"):GetComponent(TypeText)
        item.ID = item.transform:Find("Text1/ID")
        item.label2 = item.transform:Find("Text2"):GetComponent(TypeText)
        item.label3 = item.transform:Find("Text3"):GetComponent(TypeText)
        item.label4 = item.transform:Find("Text4"):GetComponent(TypeText)
        item.label5 = item.transform:Find("Text5"):GetComponent(TypeText)
        item.label6 = item.transform:Find("Text6"):GetComponent(TypeText)
        item.MoreBtn = item.transform:Find("Text7/MoreBtn"):GetComponent(TypeButton)
        item.AdjustBtn = item.transform:Find("Text7/Adjust"):GetComponent(TypeButton)
        item.leaderTag = item.transform:Find("Text1/LeaderTag")
        item.adminTag = item.transform:Find("Text1/AdminTag")
        item.partnerTag = item.transform:Find("Text1/PartnerTag")
    end
    UIUtil.SetActive(item.gameObject, true)
    item.data = data
    item.Name.text = data.pName
    UIUtil.SetText(item.ID, tostring(data.pId))
    item.label2.text = data.score .. "\n" .. data.per .. "%"
    Functions.SetHeadImage(item.HeadImg, data.pIcon)
    item.label3.text = data.isOnline
    item.label4.text = data.dFace .. "\n" .. data.yFace
    item.label5.text = data.dAct .. "\n" .. data.yAct
    item.label6.text = data.fen .. "\n" .. data.team

    UIUtil.SetActive(item.leaderTag, data.aType == UnionRole.Leader)
    UIUtil.SetActive(item.adminTag, data.aType == UnionRole.Admin)
    UIUtil.SetActive(item.partnerTag, data.aType == UnionRole.Partner)

    this:AddOnClick(item.AdjustBtn, function()
        PanelManager.Open(PanelConfig.UnionScoreChange, data.pId)
    end)
    this:AddOnClick(item.MoreBtn, function()
        PanelManager.Open(PanelConfig.UnionPartnerMoreAction, 2, data.isIce, data.pId, data.pIcon, data.pName, data.aType)
    end)
end

--设置数据
function UnionPersonalDataPanel.SetNode2Item(item, data)
    if item.isInit ~= true then
        item.isInit = true
        item.label1 = item.transform:Find("Text1"):GetComponent(TypeText)
        item.label2 = item.transform:Find("Text2"):GetComponent(TypeText)
        item.label3 = item.transform:Find("Text3"):GetComponent(TypeText)
        item.label4 = item.transform:Find("Text4"):GetComponent(TypeText)
        item.label5 = item.transform:Find("Text5"):GetComponent(TypeText)
    end
    UIUtil.SetActive(item.gameObject, true)
    item.data = data
    item.label1.text = data.timestr
    item.label2.text = data.name
    item.label3.text = data.gamecount
    item.label4.text = math.ToRound(data.face, 2)
    item.label5.text = math.ToRound(data.gamesore, 2)
end

function UnionPersonalDataPanel.SetNodeNew2Item(item, data)
    if item.isInit ~= true then
        item.isInit = true
        item.label1 = item.transform:Find("Text1"):GetComponent(TypeText)
        item.label2 = item.transform:Find("Text2"):GetComponent(TypeText)
        item.label3 = item.transform:Find("Text3"):GetComponent(TypeText)
        item.label4 = item.transform:Find("Text4"):GetComponent(TypeText)
        UIUtil.SetActive(item.transform:Find("Text5").gameObject, false)
    end
    UIUtil.SetActive(item.gameObject, true)
    item.data = data
    item.label1.text = os.date("%Y-%m-%d", data.time / 1000)
    item.label2.text = GameConfig[data.game].Text
    item.label3.text = data.ju
    item.label4.text = data.score
end

--设置数据
function UnionPersonalDataPanel.SetNode3Item(item, data)
    if item.isInit ~= true then
        item.isInit = true
        item.headIconGo = item.transform:Find("Head/Icon").gameObject
        item.headIcon = item.headIconGo:GetComponent(TypeImage)
        item.nameLabel = item.transform:Find("NameText"):GetComponent(TypeText)
        item.idLabel = item.transform:Find("IdText"):GetComponent(TypeText)
        item.label1 = item.transform:Find("Text1"):GetComponent(TypeText)
        item.label2 = item.transform:Find("Text2"):GetComponent(TypeText)
        item.label3 = item.transform:Find("Text3"):GetComponent(TypeText)
        item.label4 = item.transform:Find("Text4"):GetComponent(TypeText)
    end
    UIUtil.SetActive(item.gameObject, true)
    item.data = data
    if item.icon ~= data.icon then
        item.icon = data.icon
        Functions.SetHeadImage(item.headIcon, data.icon)
    end
    item.nameLabel.text = data.userName2
    item.idLabel.text = data.uId2

    local temp = 0
    local temp2 = ""
    if data.num > 0 then
        temp = "+" .. data.num
        temp2 = "赠送"
    else
        temp = tostring(data.num)
        temp2 = "扣除"
    end
    item.label1.text = temp
    item.label2.text = data.userName .. "\n" .. Functions.GetUserIdString(data.uId)
    item.label3.text = UnionRoleName[data.bType]
    item.label4.text = os.date("%Y-%m-%d\n%H:%M:%S", tonumber(data.time) / 1000)
end

--设置数据
function UnionPersonalDataPanel.SetNode4Item(item, data)
    if item.isInit ~= true then
        item.label1 = item.transform:Find("TextParent1/Text1"):GetComponent(TypeText)
        item.label2 = item.transform:Find("TextParent2/Text2"):GetComponent(TypeText)
        item.label3 = item.transform:Find("TextParent3/Text3"):GetComponent(TypeText)
        item.label4 = item.transform:Find("TextParent4/Text4"):GetComponent(TypeText)
    end
    UIUtil.SetActive(item.gameObject, true)
    item.data = data
end

function UnionPersonalDataPanel.SetNode5Item(item, data)
    --LogError("<color=aqua>data</color>", data)
    if item.isInit ~= true then
        local headTrans = item.transform:Find("Head")
        item.headImg = headTrans:Find("Mask/HeadImg"):GetComponent(TypeImage)
        item.Name = headTrans:Find("Name")
        item.ID = headTrans:Find("ID")
        item.Text2 = item.transform:Find("Text2")
    end
    UIUtil.SetActive(item.gameObject, true)
    local isSelf = data.userid1 == this.userId
    Functions.SetHeadImage(item.headImg, isSelf and data.iCon2 or data.iCon1)
    UIUtil.SetText(item.Name, isSelf and data.name2 or data.name1)
    UIUtil.SetText(item.ID, tostring(isSelf and data.userid2 or data.userid1))
    UIUtil.SetText(item.Text2, tostring(data.ju))
end

function UnionPersonalDataPanel.SetNode6Item(item, data)
    LogError("层级数据", data)
    if item.isInit ~= true then
        item.label1 = item.transform:Find("Text1"):GetComponent(TypeText)
        item.label2 = item.transform:Find("Text2"):GetComponent(TypeText)
        item.HeadImg = item.transform:Find("Mask/HeadImg"):GetComponent(TypeImage)
    end
    UIUtil.SetActive(item.gameObject, true)
    item.data = data
    item.label1.text = data.userName .. "\n" .. data.userId
    item.label2.text = data.coin
    Functions.SetHeadImage(item.HeadImg, data.icon)
end

function UnionPersonalDataPanel.SetNode7Item(item, data)
    LogError("战队统计", data)
    if item.isInit ~= true then
        item.label1 = item.transform:Find("Text1"):GetComponent(TypeText)
        item.label2 = item.transform:Find("Text2"):GetComponent(TypeText)
        item.label3 = item.transform:Find("Text3"):GetComponent(TypeText)
        item.label4 = item.transform:Find("Text4"):GetComponent(TypeText)
        item.label5 = item.transform:Find("Text5"):GetComponent(TypeText)
        item.label6 = item.transform:Find("Text6"):GetComponent(TypeText)
        item.label7 = item.transform:Find("Text7"):GetComponent(TypeText)
    end
    UIUtil.SetActive(item.gameObject, true)
    item.data = data
    item.label1.text = data.timestr
    item.label2.text = data.ju .. "/" .. data.roomcard
    item.label3.text = data.faceall
    item.label4.text = data.face
    item.label5.text = data.bd
    UIUtil.SetActive(item.label5.gameObject, UnionData.IsUnionLeaderOrAdministrator())
    item.label6.text = data.score
    item.label7.text = data.contrib
end

function UnionPersonalDataPanel.SetNode8Item(item, data)
    if item.isInit ~= true then
        item.timeLabel = item.transform:Find("Time"):GetComponent(TypeText)
        item.txtLabel = item.transform:Find("Text3"):GetComponent(TypeText)

        item.idText = item.transform:Find("Head1/ID"):GetComponent(TypeText)
        item.nameText = item.transform:Find("Head1/Name"):GetComponent(TypeText)
        item.headIcon = item.transform:Find("Head1/Mask/HeadImg"):GetComponent(TypeImage)

        item.idText2 = item.transform:Find("Head2/ID"):GetComponent(TypeText)
        item.nameText2 = item.transform:Find("Head2/Name"):GetComponent(TypeText)
        item.headIcon2 = item.transform:Find("Head2/Mask/HeadImg"):GetComponent(TypeImage)
    end
    UIUtil.SetActive(item.gameObject, true)
    item.data = data
    if item.icon ~= data.icon then
        item.icon = data.icon
        Functions.SetHeadImage(item.headIcon, data.icon)
    end
    item.nameText.text = data.changeName
    item.idText.text = UnionData.GetUidString(data.changeId)

    if item.icon2 ~= data.icon2 then
        item.icon2 = data.icon2
        Functions.SetHeadImage(item.headIcon2, data.icon2)
    end
    item.nameText2.text = data.operaName
    item.idText2.text = UnionData.GetUidString(data.operaId)

    item.timeLabel.text = os.date("%m/%d %H:%M", data.time / 1000)
    local desc = ""
    if data.operaType == 1 then
        desc = "被任命队长"
    elseif data.operaType == 2 then
        desc = "被邀请加入茶馆"
    elseif data.operaType == 3 then
        desc = "被踢出茶馆"
    elseif data.operaType == 4 then
        desc = "被取消队长"
    elseif data.operaType == 5 then
        desc = "整条线被踢"
    elseif data.operaType == 6 then
        desc = "被清分"
    elseif data.operaType == 7 then
        desc = "被整条线清分"
    elseif data.operaType == 8 then
        desc = "被修改上级"
    end
    item.txtLabel.text = desc
end

function UnionPersonalDataPanel.SetNode9Item(item, data)
    LogError("<color=aqua>data</color>", data)
    if item.isInit ~= true then
        item.label1 = item.transform:Find("Text1"):GetComponent(TypeText)
        item.label2 = item.transform:Find("Text2"):GetComponent(TypeText)
        item.detailBtn = item.transform:Find("Text2/DetailBtn")
        item.label3 = item.transform:Find("Text3"):GetComponent(TypeText)
        item.label4 = item.transform:Find("Text4"):GetComponent(TypeText)
        item.label5 = item.transform:Find("Text5"):GetComponent(TypeText)
    end
    UIUtil.SetActive(item.gameObject, true)
    item.data = data
    item.label1.text = UnionManager.UnionOperateType[data.currencyOpType]
    local operNum = not data.operNum and "" or (data.operNum == 0 and "" or data.operNum)
    LogError("operNum", operNum)
    item.label2.text = operNum == "" and "" or (data.currencyOpType == 1 and "房间号:" or "") .. operNum
    if data.currencyOpType == 14 or data.currencyOpType == 15 then
        UIUtil.SetActive(item.detailBtn, true)
        this:AddOnClick(item.detailBtn, function()
            PanelManager.Open(PanelConfig.UnionKeepBaseDetail, data.mId)
        end)
    else
        UIUtil.SetActive(item.detailBtn, false)
    end
    item.label3.text = data.chanage
    item.label4.text = data.after
    item.label5.text = os.date("%Y-%m-%d\n%H:%M:%S", data.datatime / 1000)
end

function UnionPersonalDataPanel.SetNode10Panel(data)
    UIUtil.SetActive(this.loading, false)
    UIUtil.SetActive(this.noData, false)
    --
    LogError("<color=aqua>UpdateRecord</color>", data)
    -- this.roomType = data.data.roomType
    this.moneyType = data.data.currency
    LogError("<color=aqua>gameId</color>", data.data.gameId)
    this.gameId = GameType.None
    local recordData = this.recordDatas[this.gameId][this.roomType]
    recordData.curPage = isSub and recordData.curPage or data.data.page
    recordData.totalPage = data.data.totalPage
    recordData.totalCount = data.data.totalNum

    LogError("战绩条数：", recordData.totalCount)
    --移除多余的数据
    local start = (recordData.totalPage - 1) * this.count + 1
    for i = start, #recordData.recordList do
        table.remove(recordData.recordList, i)
    end

    for i = 1, this.count do
        local idx = (recordData.curPage - 1) * this.count + i
        if data.data.list[i] ~= nil then
            recordData.recordList[idx] = data.data.list[i]
        else
            recordData.recordList[idx] = nil
        end
    end
    if recordData.totalCount > 0 then
        LogError("recordData.totalCount > 0")
        this.tipsText.gameObject:SetActive(false)
        this.recordContent = this.scrollView:Find("Viewport/Content")
        this.recordScrollRect:SetMaxDataCount(recordData.totalCount)
        this.recordScrollRect:UpdateAllItems()
    else
        if not IsNull(this.tipsText) then
            this.tipsText.gameObject:SetActive(true)
            HideChildren(this.recordContent)
        end
    end
end

function UnionPersonalDataPanel.InitScrollRect()
    LogError("InitScrollRect")
    this.recordScrollRect.onGetLastPageDataAction = function(page)
        if page >= 0 then
            this.SetRecordData(page + 1)
        end
    end
    this.recordScrollRect.onGetNextPageDataAction = function(page)
        if page < this.recordDatas[this.gameId][this.roomType].totalPage then
            this.SetRecordData(page + 1)
        end
    end
    this.recordScrollRect:SetMaxDataCount(0)
    this.recordScrollRect:InitItems()
    this.recordScrollRect.onUpdateItemAction = this.UpdateRecordItemInfo
end

function UnionPersonalDataPanel.SetRecordData(page)
    if this.roomType == RoomType.Lobby then
        --Log(">>>>>>>RecordPanel.SetRecordData>>>>>>游戏", this.gameId)
        local recordList = this.recordDatas[this.gameId][this.roomType].recordList
        local totalCount = this.recordDatas[this.gameId][this.roomType].totalCount
        --当前数据条数
        local curTotalCount = GetTableSize(recordList)
        if curTotalCount <= totalCount and curTotalCount < page * this.count then
            UnionManager.SendSearchRecord(0, 2, this.userId, page, this.count)
        else
            this.tipsText.gameObject:SetActive(false)
            this.recordScrollRect:SetMaxDataCount(totalCount)
            this.recordScrollRect:UpdateAllItems()
        end
    else
        if this.recordType == 1 then
            BaseTcpApi.SendGroupMyRecord(0, this.groupId, this.roomType, page, this.count)
        else
            if string.IsNullOrEmpty(UnionData.searchId) then
                BaseTcpApi.SendGroupAllRecord(0, this.groupId, this.roomType, page, this.count)
            else
                UnionManager.SendSearchRecord(0, UnionData.searchType, UnionData.searchId, page, this.count)
            end
        end
    end
end

--更新战绩列表
function UnionPersonalDataPanel.UpdateRecordItemInfo(transform, idx)
    --LogError("UpdateRecordItemInfo")
    local recordList = this.recordDatas[this.gameId][this.roomType].recordList[idx + 1]
    if IsNil(recordList) then
        if idx > this.recordDatas[this.gameId][this.roomType].totalCount - 1 then
            transform.gameObject:SetActive(false)
        else
            --此处处理服务器还未返回数据
            --需要提前显示列表item的UI
            --使用占位的方式 数据使用默认
            transform.transform:Find("Group").gameObject:SetActive(false)
            transform.transform:Find("DataLoading").gameObject:SetActive(true)
        end
    else
        this.UpdateRecordItem(recordList, transform, idx, this.recordDatas[this.gameId][this.roomType].subPage)
    end
end

--更新item
function UnionPersonalDataPanel.UpdateRecordItem(data, transform, idx, subPage)

    LogError(idx, data)

    local item = this.GetRecordInfoItem(transform)
    UIUtil.SetActive(item.gameObject, true)
    UIUtil.SetActive(item.groupNode.gameObject, true)
    UIUtil.SetActive(item.dataLoadingNode.gameObject, false)
    item.transform.localScale = Vector3.one
    item.roomIDText.text = data.roomNum
    local gameId = data.gameId
    --五子棋隐藏 玩法、局数、底分
    local rule = nil

    rule = JsonToObj(data.roomRule)
    local ruleText = Functions.ParseGameRule(gameId, rule)
    LogError("<color=aqua>规则解析</color>", ruleText)
    item.GameName.text = GameConfig[gameId].Text
    item.playWayText.text = ruleText.playWayName
    -- item.roundNumText.text = ruleText.juShuTxt
    item.diFenNumText.text = ruleText.baseScore
    if ruleText.baseScore > 0 then
        UIUtil.SetActive(item.diFenNumGo, true)
    else
        UIUtil.SetActive(item.diFenNumGo, false)
    end

    item.tiemText.text = os.date("%Y-%m-%d %H:%M:%S", data.endTime / 1000)
    local args = {
        gameId = gameId,
        inning = data.inning,
        roomType = data.roomType,
        moneyType = data.currency,
        groupId = this.groupId,
        onlyRoomId = data.roomId,
        time = data.endTime,
        roomId = data.roomNum,
        rule = rule,
    }
    this:AddOnClick(item.detailsBtn, function()
        local subArgs = {
            roomType = this.roomType, groupId = this.groupId, isOpenYinSi = this.isOpenYinSi, recordType = this.recordType, data = data, subPage = subPage, count = this.count, recordDatas = this.recordDatas
        }
        LogError("data", data)
        PanelManager.Open(PanelConfig.RecordSub, subArgs)
    end)
    UIUtil.SetActive(item.detailsBtn.gameObject, true)

    HideChildren(item.itemContent)
    if IsNil(data.users) then
        data.users = {}
    end
    local playerData = nil
    local length = #data.users
    item.scrollRect.enabled = length > 4
    if length <= 4 then
        UIUtil.SetAnchoredPosition(item.itemContent.gameObject, 0, 0)
    end
    for i = 1, length do
        playerData = data.users[i]
        playerData.score = tonumber(playerData.score)
        --LogError("<color=aqua>playerData</color>", playerData)
        local playerItem = item.playerItems[i]
        if playerItem == nil then
            playerItem = this.GetPlayerItem()
            item.playerItems[i] = playerItem
            playerItem.transform:SetParent(item.itemContent)
            playerItem.transform.localScale = Vector3.one
        end

        UIUtil.SetActive(playerItem.gameObject, true)
        Functions.SetHeadImage(playerItem.headImage, Functions.CheckJoinPlayerHeadUrl(playerData.iCon))
        playerItem.nameText.text = playerData.name
        playerItem.idText.text = Functions.GetUserIdString(playerData.userId)

        UIUtil.SetActive(playerItem.minusScoreText.gameObject, playerData.score < 0)
        UIUtil.SetActive(playerItem.addScoreText.gameObject, playerData.score >= 0)
        if playerData.score < 0 then
            playerItem.minusScoreText.text = playerData.score
        else
            playerItem.addScoreText.text = "+" .. playerData.score
        end
    end
end

function UnionPersonalDataPanel.GetPlayerItem()
    local itemGO = CreateGO(this.playerItemGO)
    local item = {}
    item.gameObject = itemGO
    item.transform = itemGO.transform
    item.headImage = itemGO.transform:Find("Head/Mask/HeadIcon"):GetComponent("Image")
    item.nameText = itemGO.transform:Find("NameText"):GetComponent("Text")
    item.idText = itemGO.transform:Find("IDText"):GetComponent("Text")
    item.addScoreText = itemGO.transform:Find("AddScoreText"):GetComponent("Text")
    item.minusScoreText = itemGO.transform:Find("MinusScoreText"):GetComponent("Text")
    return item
end

--获取战绩Item
function UnionPersonalDataPanel.GetRecordInfoItem(transform)
    local id = transform.gameObject:GetInstanceID()
    local item = this.recordInfoItems[id]
    if IsNil(item) then
        item = {}
        item.transform = transform
        item.gameObject = transform.gameObject
        item.groupNode = transform:Find("Group")
        item.dataLoadingNode = transform:Find("DataLoading")
        item.GameName = item.groupNode:Find("GameName"):GetComponent("Text")
        item.roomIDText = item.groupNode:Find("RoomIDText"):GetComponent("Text")
        item.playWayText = item.groupNode:Find("PlayWayText"):GetComponent("Text")
        -- item.roundNumText = item.groupNode:Find("RoundNumText"):GetComponent("Text")
        item.diFenNumGo = item.groupNode:Find("DiFenNumText").gameObject
        item.diFenNumText = item.diFenNumGo:GetComponent("Text")
        item.tiemText = item.groupNode:Find("TimeText"):GetComponent("Text")
        item.detailsBtn = item.groupNode:Find("DetailsBtn"):GetComponent("Button")
        local playerItemTrans = item.groupNode:Find("PlayerItems")
        item.playerItems = {}
        item.itemContent = playerItemTrans:Find("Viewport/Content")
        item.scrollRect = playerItemTrans:GetComponent("ScrollRect")
        item.viewportWidth = UIUtil.GetWidth(playerItemTrans)
        item.curScrollX = 0
        item.maxScrollX = 0
    end
    this.recordInfoItems[id] = item
    return item
end

function UnionPersonalDataPanel.InitRecordData()
    this.count = 4
    this.roomType = RoomType.Lobby
    this.playerItemWidth = 215
    this.groupId = UnionData.curUnionId
    this.recordInfoItems = {}
    this.recordDatas = {
        [GameType.None] = {
            [RoomType.Lobby] = { curPage = 1, totalPage = 1, totalCount = 0, recordList = {}, subPage = 1 },
        }
    }
end