UnionScoreManagerPanel = ClassPanel("UnionScoreManagerPanel")
local this = UnionScoreManagerPanel

--每页总数
local PageCount = 3

--初始化
function UnionScoreManagerPanel.Init()
    this.pageIndex = 1
    this.pageTotal = 1
    this.nodeIndex = 0
end

function UnionScoreManagerPanel:Awake()
    this = self
    this.Init()

    local content = this:Find("Content")

    this.closeBtn = content:Find("Background/CloseBtn")

    local menuContent = content:Find("Menu/Viewport/Content")
    this.menuToggles = {}
    for i = 1, 8 do
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
    for i = 1, 8 do
        local item = {}
        table.insert(this.pageNodes, item)
        item.transform = content:Find("Content/" .. i)
        item.gameObject = item.transform.gameObject
        if i == 1 then
            item.itemContent = item.transform:Find("ScrollView/Viewport/Content")
        else
            item.itemContent = item.transform:Find("Content")
        end
        item.itemPrefab = item.itemContent:Find("Item")
        item.items = {}
    end

    local page = content:Find("Content/Bottom/Page")
    this.lastBtn = page:Find("LastBtn").gameObject
    this.nextBtn = page:Find("NextBtn").gameObject
    this.pageLabel = page:Find("PageText/Text"):GetComponent(TypeText)

    this.loading = content:Find("Content/LoadingText").gameObject
    this.noData = content:Find("Content/NoDataText").gameObject

    --this.TitleImgObj = content:Find("Background/TitleBg/Title").gameObject
    --this.TitleTxtObj = content:Find("Background/TitleBg/Text").gameObject
    this.Title1 = content:Find("Content/2/Titles").gameObject
    this.Title2 = content:Find("Content/2/Titles2").gameObject

    this.searchIdInput = content:Find("Content/SearchInput")
    local inputField = this.searchIdInput:GetComponent(TypeInputField)
    inputField.onValueChanged:RemoveAllListeners()
    inputField.onValueChanged:AddListener(this.OnInputFieldValueChanged)

    this.searchId = 0
    this.AddUIEventListener()
end

function UnionScoreManagerPanel:OnOpened(userId, isHeadBtnOpen)
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
        UIUtil.SetActive(this.menuToggles[5].gameObject, true)
        UIUtil.SetActive(this.menuToggles[6].gameObject, UnionData.selfRole ~= UnionRole.Common)
        UIUtil.SetActive(this.menuToggles[7].gameObject, false)
        UIUtil.SetActive(this.menuToggles[8].gameObject, false)
    else
        UIUtil.SetActive(this.menuToggles[1].gameObject, true)
        UIUtil.SetActive(this.menuToggles[2].gameObject, true)
        UIUtil.SetActive(this.menuToggles[3].gameObject, true)
        UIUtil.SetActive(this.menuToggles[4].gameObject, false)
        UIUtil.SetActive(this.menuToggles[5].gameObject, true)
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

end

function UnionScoreManagerPanel:OnClosed()
    this.RemoveEventListener()
    this.pageIndex = 1
    this.pageTotal = 1
    this.CloseNode(this.nodeIndex)
    this.nodeIndex = 0
    this.SearchText = ""
end

--注册事件
function UnionScoreManagerPanel.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_GetUnionMemberList, this.OnTcpGetUnionMemberList)
    AddEventListener(CMD.Tcp.Union.S2C_GameScoreCount, this.OnGameScoreCount)
    AddEventListener(CMD.Tcp.Union.S2C_Union_ScoreChange, this.OnScoreChange)
    AddEventListener(CMD.Tcp.Union.S2C_SameTableInfo, this.UpdateSameTableInfo)
    AddEventListener(CMD.Tcp.Union.S2C_MyGameScoreInfo, this.OnGameScoreCount)
    AddEventListener(CMD.Tcp.Union.S2C_UpDownPlayers, this.UpdateUpDownPlayers)
    AddEventListener(CMD.Tcp.Union.S2C_TeamStatistics, this.UpdateTeamStatistics)
    AddEventListener(CMD.Tcp.Union.S2C_Record, this.UpdateMemberChangeRecord)
    AddEventListener(CMD.Game.UnionUpdateMatchScore, this.EventUpdateMatchScore)
    AddEventListener(CMD.Tcp.Union.S2C_Union_SetScore, this.RequestUpdateMatchScore)
    AddEventListener(CMD.Tcp.Union.S2C_PartnerChange, this.RequestUpdateMatchScore)
    AddEventListener(CMD.Tcp.Union.S2C_MemberChange, this.RequestUpdateMatchScore)
    AddEventListener(CMD.Tcp.Union.S2C_ClearUnionScore, this.RequestUpdateMatchScore)
    AddEventListener(CMD.Tcp.Union.S2C_UNION_ADD_BLACK_HOUSE_ALL, this.RequestUpdateMatchScore)
    AddEventListener(CMD.Tcp.Union.S2C_Kick, this.RequestUpdateMatchScore)
    AddEventListener(CMD.Tcp.Union.S2C_SetAsObserver, this.RequestUpdateMatchScore)
end

--移除事件
function UnionScoreManagerPanel.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.Union.S2C_GetUnionMemberList, this.OnTcpGetUnionMemberList)
    RemoveEventListener(CMD.Tcp.Union.S2C_GameScoreCount, this.OnGameScoreCount)
    RemoveEventListener(CMD.Tcp.Union.S2C_Union_ScoreChange, this.OnScoreChange)
    RemoveEventListener(CMD.Tcp.Union.S2C_SameTableInfo, this.UpdateSameTableInfo)
    RemoveEventListener(CMD.Tcp.Union.S2C_MyGameScoreInfo, this.OnGameScoreCount)
    RemoveEventListener(CMD.Tcp.Union.S2C_UpDownPlayers, this.UpdateUpDownPlayers)
    RemoveEventListener(CMD.Tcp.Union.S2C_TeamStatistics, this.UpdateTeamStatistics)
    RemoveEventListener(CMD.Tcp.Union.S2C_Record, this.UpdateMemberChangeRecord)
    RemoveEventListener(CMD.Game.UnionUpdateMatchScore, this.RequestUpdateMatchScore)
    RemoveEventListener(CMD.Tcp.Union.S2C_Union_SetScore, this.RequestUpdateMatchScore)
    RemoveEventListener(CMD.Tcp.Union.S2C_PartnerChange, this.RequestUpdateMatchScore)
    RemoveEventListener(CMD.Tcp.Union.S2C_MemberChange, this.RequestUpdateMatchScore)
    RemoveEventListener(CMD.Tcp.Union.S2C_ClearUnionScore, this.RequestUpdateMatchScore)
    RemoveEventListener(CMD.Tcp.Union.S2C_UNION_ADD_BLACK_HOUSE_ALL, this.RequestUpdateMatchScore)
    RemoveEventListener(CMD.Tcp.Union.S2C_Kick, this.RequestUpdateMatchScore)
    RemoveEventListener(CMD.Tcp.Union.S2C_SetAsObserver, this.RequestUpdateMatchScore)
end

--UI相关事件
function UnionScoreManagerPanel.AddUIEventListener()
    EventUtil.AddOnClick(this.lastBtn, this.OnLastBtnClick)
    EventUtil.AddOnClick(this.nextBtn, this.OnNextBtnClick)
    EventUtil.AddOnClick(this.closeBtn, this.OnCloseBtnClick)
end

--================================================================
--
--关闭
function UnionScoreManagerPanel.Close()
    PanelManager.Close(PanelConfig.UnionScoreManager)
end

--================================================================
--
--
function UnionScoreManagerPanel.OnCloseBtnClick()
    this.Close()
end
--
function UnionScoreManagerPanel.OnLastBtnClick()
    if this.pageIndex <= 1 then
        Toast.Show("当前已是首页")
    else
        this.SendRequestList(this.pageIndex - 1)
    end
end

--
function UnionScoreManagerPanel.OnNextBtnClick()
    if this.pageIndex >= this.pageTotal then
        Toast.Show("当前已是尾页")
    else
        this.SendRequestList(this.pageIndex + 1)
    end
end

--菜单按钮点击
function UnionScoreManagerPanel.OnMenuValueChanged(item, isOn)
    if isOn then
        if this.nodeIndex ~= item.index then
            this.CloseNode(this.nodeIndex)
            this.nodeIndex = item.index
            this.OpenNode(this.nodeIndex)
        end
    end
end

function UnionScoreManagerPanel.OnInputFieldValueChanged(text)
    this.SearchText = string.IsNullOrEmpty(text) and "" or text
    if this.nodeIndex == 8 then
        this.RequestUnionRecord(1, text)
    elseif this.nodeIndex == 4 then
        this.RequestSameTableInfoRequest(1, text)
    elseif this.nodeIndex == 3 then
        this.RequestScoreChangeList(1, text)
    elseif this.nodeIndex == 1 then
        this.RequestGetUnionMemberList(1, text)
    end
end

function UnionScoreManagerPanel.RequestUpdateMatchScore(data)
    if data.code == 0 then
        UnionScoreManagerPanel.SendRequestList(this.pageIndex)
    else
        UnionManager.ShowError(data.code)
    end
end

function UnionScoreManagerPanel.EventUpdateMatchScore()
    UnionScoreManagerPanel.SendRequestList(this.pageIndex)
end

function UnionScoreManagerPanel.RequestScoreChangeList(pageIndex, searchString)
    UnionManager.SendGetScoreChangeList(this.userId, pageIndex, PageCount, nil, searchString)
end

function UnionScoreManagerPanel.RequestSameTableInfoRequest(pageIndex, searchString)
    UnionManager.SendSameTableInfoRequest(pageIndex, PageCount, searchString)
end

function UnionScoreManagerPanel.RequestGetUnionMemberList(pageIndex, searchString)
    UnionManager.SendGetUnionMemberList(pageIndex, PageCount, searchString)
end

function UnionScoreManagerPanel.RequestUnionRecord(pageIndex, searchString)
    UnionManager.SendRecord(pageIndex, PageCount, searchString)
end

--================================================================
--

function UnionScoreManagerPanel.OnTcpGetUnionMemberList(data)
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
function UnionScoreManagerPanel.OnGameScoreCount(data)
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
function UnionScoreManagerPanel.OnScoreChange(data)
    if this.nodeIndex ~= 3 then
        return
    end
    if data.code == 0 then
        this.UpdateNode(data.data)
    else
        UnionManager.ShowError(data.code)
    end
end

--积分详情数据返回
function UnionScoreManagerPanel.OnScoreDetails(data)
    if this.nodeIndex ~= 4 then
        return
    end
    if data.code == 0 then
        this.UpdateNode(data.data)
    else
        UnionManager.ShowError(data.code)
    end
end

function UnionScoreManagerPanel.UpdateSameTableInfo(data)
    LogError("UpdateSameTableInfo", this.nodeIndex)
    if this.nodeIndex ~= 5 then
        return
    end
    if data.code == 0 then
        this.UpdateNode(data.data)
    else
        UnionManager.ShowError(data.code)
    end
end

function UnionScoreManagerPanel.UpdateUpDownPlayers(data)
    LogError("上下级玩家返回", data)
    if this.nodeIndex == 6 then
        if data.code == 0 then
            this.UpdateNode(data.data)
        else
            UnionManager.ShowError(data.code)
        end
    end
end

function UnionScoreManagerPanel.UpdateTeamStatistics(data)
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
function UnionScoreManagerPanel.UpdateMemberChangeRecord(data)
    if this.nodeIndex == 8 then
        if data.code == 0 then
            this.UpdateNode(data.data)
        else
            UnionManager.ShowError(data.code)
        end
    end
end

--================================================================
--
--请求数据
function UnionScoreManagerPanel.SendRequestList(pageIndex)
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
        this.RequestUnionRecord(pageIndex, this.SearchText)
    end
end

--关闭节点
function UnionScoreManagerPanel.CloseNode(index)
    local temp = this.pageNodes[index]
    if temp ~= nil then
        UIUtil.SetActive(temp.gameObject, false)
    end
end

--打开节点
function UnionScoreManagerPanel.OpenNode(index)
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
    end
end

--开启节点1
function UnionScoreManagerPanel.OpenNodeSetActive(node)
    local item = nil
    for i = 1, #node.items do
        item = node.items[i]
        if item.data ~= nil then
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

function UnionScoreManagerPanel.HideKeepBaseTitleBySelfUnionRole(temp, index)
    LogError("HideKeepBaseTitleBySelfUnionRole")
    if index == 7 then
        local Label4 = temp.gameObject.transform:Find("Titles/Label4").gameObject
        UIUtil.SetActive(Label4, UnionData.IsUnionLeaderOrAdministrator())
    end
end

--创建显示对象
function UnionScoreManagerPanel.CreateItem(itemContent, itemPrefab, index)
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
function UnionScoreManagerPanel.UpdateNode(data)
    this.pageIndex = data.pageIndex or data.page
    this.pageTotal = Functions.CheckPageTotal(data.allPage or data.totalPage)

    this.pageLabel.text = tostring(this.pageIndex) .. "/" .. tostring(this.pageTotal)

    local node = this.pageNodes[this.nodeIndex]
    local list = data.list
    LogError("GetTableSize(list)", GetTableSize(list))
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

function UnionScoreManagerPanel.JudgeShowSearchInput()
    UIUtil.SetActive(this.searchIdInput.gameObject, this.nodeIndex == 1 or this.nodeIndex == 3 or this.nodeIndex == 4 or this.nodeIndex == 8)
end

function UnionScoreManagerPanel.SetNode1Item(item, data)
    if item.isInit ~= true then
        item.isInit = true
        --item.label1 = item.transform:Find("Text1"):GetComponent(TypeText)
        local temp = item.transform:Find("Text1/Mask/HeadImg")
        item.HeadImg = temp:GetComponent(TypeImage)
        item.HeadBtn = temp.gameObject
        item.Name = item.transform:Find("Text1/Name"):GetComponent(TypeText)
        item.ID = item.transform:Find("Text1/ID"):GetComponent(TypeText)
        item.label2 = item.transform:Find("Text2"):GetComponent(TypeText)
        item.label3 = item.transform:Find("Text3"):GetComponent(TypeText)
        item.label4 = item.transform:Find("Text4"):GetComponent(TypeText)
        item.label5 = item.transform:Find("Text5"):GetComponent(TypeText)
        item.label6 = item.transform:Find("Text6"):GetComponent(TypeText)
        item.MoreBtn = item.transform:Find("Text7/MoreBtn"):GetComponent(TypeButton)
        item.AdjustBtn = item.transform:Find("Text7/Adjust"):GetComponent(TypeButton)
        item.leaderTag = item.transform:Find("LeaderTag")
        item.adminTag = item.transform:Find("AdminTag")
        -- item.observerTag = item.transform:Find("ObserverTag")
        item.partnerTag = item.transform:Find("PartnerTag")

        local tempItem = item
        EventUtil.AddOnClick(item.HeadBtn, function()
            PanelManager.Open(PanelConfig.UnionPersonalData, tempItem.data.pId, true)
        end)
    
        this:AddOnClick(item.AdjustBtn, function()
            PanelManager.Open(PanelConfig.UnionScoreChange, tempItem.data.pId)
        end)
        this:AddOnClick(item.MoreBtn, function()
            --PanelManager.Open(PanelConfig.UnionPartnerMoreAction, 2, tempItem.data.isIce, tempItem.data.pId, tempItem.data.pIcon, tempItem.data.pName, tempItem.data.aType, tempItem.data.black)
            PanelManager.Open(PanelConfig.UnionScoreSet, 2, tempItem.data.isIce, tempItem.data.pId, tempItem.data.pIcon, tempItem.data.pName, tempItem.data.aType, tempItem.data.black)
        
        end)
    end
    UIUtil.SetActive(item.gameObject, true)
    item.data = data
    item.Name.text = data.pName
    item.ID.text = tostring(data.pId)
    item.label2.text = data.score .. "\n" .. data.per .. "%"
    Functions.SetHeadImage(item.HeadImg, data.pIcon)
    item.label3.text = data.isOnline
    item.label4.text = data.dFace .. "\n" .. data.yFace
    item.label5.text = data.dAct .. "\n" .. data.yAct
    item.label6.text = data.fen .. "\n" .. data.team

    UIUtil.SetActive(item.leaderTag, data.aType == UnionRole.Leader)
    UIUtil.SetActive(item.adminTag, data.aType == UnionRole.Admin)
    UIUtil.SetActive(item.observerTag, data.aType == UnionRole.Observer)
    UIUtil.SetActive(item.partnerTag, data.aType == UnionRole.Partner)
end

--设置数据
function UnionScoreManagerPanel.SetNode2Item(item, data)
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

function UnionScoreManagerPanel.SetNodeNew2Item(item, data)
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
    item.label1.text = os.date("%Y-%m-%d", data.time / 1000)
    item.label2.text = GameConfig[data.game].Text
    item.label3.text = data.ju
    item.label4.text = data.score
    item.label5.text = ""
end

--设置数据
function UnionScoreManagerPanel.SetNode3Item(item, data)
    if item.isInit ~= true then
        item.isInit = true
        item.headIconGo = item.transform:Find("Index0/Mask/HeadIcon").gameObject
        item.headIcon = item.headIconGo:GetComponent(TypeImage)
        item.nameLabel = item.transform:Find("Index0/NameText"):GetComponent(TypeText)
        item.idLabel = item.transform:Find("Index0/IdText"):GetComponent(TypeText)
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
function UnionScoreManagerPanel.SetNode4Item(item, data)
    if item.isInit ~= true then
        item.label1 = item.transform:Find("Text1"):GetComponent(TypeText)
        item.label2 = item.transform:Find("Text2"):GetComponent(TypeText)
        item.label3 = item.transform:Find("Text3"):GetComponent(TypeText)
        item.label4 = item.transform:Find("Text4"):GetComponent(TypeText)
    end
    UIUtil.SetActive(item.gameObject, true)
    item.data = data
end

function UnionScoreManagerPanel.SetNode5Item(item, data)
    LogError("<color=aqua>data</color>", data)
    if item.isInit ~= true then
        local headTrans1 = item.transform:Find("Head")
        local headTrans2 = item.transform:Find("Head2")
        item.headImg1 = headTrans1:Find("Mask/HeadImg"):GetComponent(TypeImage)
        item.headImg2 = headTrans2:Find("Mask/HeadImg"):GetComponent(TypeImage)
        item.name1 = headTrans1:Find("Name")
        item.id1 = headTrans1:Find("ID")
        item.name2 = headTrans2:Find("Name")
        item.id2 = headTrans2:Find("ID")
        item.text2 = item.transform:Find("Text2")
        item.text3 = item.transform:Find("Text3")
        item.text4 = item.transform:Find("Text4")
    end
    UIUtil.SetActive(item.gameObject, true)
    --local isSelf = data.userid1 == this.userId
    Functions.SetHeadImage(item.headImg1, data.iCon1)--isSelf and data.iCon2 or data.iCon1)
    Functions.SetHeadImage(item.headImg2, data.iCon2)--isSelf and data.iCon2 or data.iCon1)
    UIUtil.SetText(item.name1, data.name1)
    UIUtil.SetText(item.name2, data.name2)
    UIUtil.SetText(item.id1, tostring(data.userid1))
    UIUtil.SetText(item.id2, tostring(data.userid2))
    UIUtil.SetText(item.text2, data.user1ju .. "/" .. data.user1lastju)
    UIUtil.SetText(item.text3, data.ju .. "/" .. data.lastju)
    UIUtil.SetText(item.text4, data.user2ju .. "/" .. data.user2ju)
end

function UnionScoreManagerPanel.OldSetNode5Item(item, data)
    LogError("<color=aqua>data</color>", data)
    if item.isInit ~= true then
        item.label1 = item.transform:Find("Text1"):GetComponent(TypeText)
        item.label2 = item.transform:Find("Text2"):GetComponent(TypeText)
        item.label3 = item.transform:Find("Text3"):GetComponent(TypeText)
        item.label4 = item.transform:Find("Text4"):GetComponent(TypeText)
        item.label5 = item.transform:Find("Text5"):GetComponent(TypeText)
    end
    UIUtil.SetActive(item.gameObject, true)
    item.data = data
    item.label1.text = data.name1 .. "\n" .. data.userid1
    item.label2.text = data.user1ju .. "/" .. data.user1lastju
    item.label3.text = data.name2 .. "\n" .. data.userid2
    item.label4.text = data.user2ju .. "/" .. data.user2lastju
    item.label5.text = data.ju .. "/" .. data.lastju
end

function UnionScoreManagerPanel.SetNode6Item(item, data)
    LogError("层级数据", data)
    if item.isInit ~= true then
        item.nameLabel = item.transform:Find("Index0/Name"):GetComponent(TypeText)
        item.idLabel = item.transform:Find("Index0/ID"):GetComponent(TypeText)
        item.HeadImg = item.transform:Find("Index0/Mask/HeadImg"):GetComponent(TypeImage)
        item.label2 = item.transform:Find("Text2"):GetComponent(TypeText)
    end
    UIUtil.SetActive(item.gameObject, true)
    item.data = data
    item.nameLabel.text = data.userName
    item.idLabel.text = "ID:" .. data.userId
    item.label2.text = data.coin
    Functions.SetHeadImage(item.HeadImg, data.icon)
end

function UnionScoreManagerPanel.SetNode7Item(item, data)
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

function UnionScoreManagerPanel.SetNode8Item(item, data)
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
        desc = data.operaDesc
    elseif data.operaType == 7 then
        -- desc = "被整条线清分"
        desc = data.operaDesc
    elseif data.operaType == 8 then
        desc = "被修改上级"
    end
    item.txtLabel.text = desc
end