UnionSettingPanel = ClassPanel("UnionSettingPanel")
UnionSettingPanel.closeBtn = nil
UnionSettingPanel.saveBtn = nil
UnionSettingPanel.shenHeToggle = nil
UnionSettingPanel.yinSiToggle = nil
UnionSettingPanel.daYangToggle = nil
UnionSettingPanel.titleInput = nil
UnionSettingPanel.noticeInput = nil
local this = UnionSettingPanel
function UnionSettingPanel:Awake()
    this = self
    this.content = this:Find("Content/Content")
    this.closeBtn = this:Find("Content/Background/CloseBtn")

    dofile(ScriptPath.ViewUnion .. "UnionSettingNode4DarkRoom")

    this.InitMenu()
    this.InitPageNode()
    this.InitNode1Panel()
    this.InitNode2Panel()
    this.InitNode3Panel()
    this.InitNode4Panel()
    this.InitNode5Panel()
    this.InitNode6Panel()

    UnionSettingNode4DarkRoom:Awake(this.content:Find("4"))
end

function UnionSettingPanel.InitMenu()
    local menuContent = this:Find("Content/Menu/Viewport/Content")
    this.menuToggles = {}
    for i = 1, 6 do
        local item = {}
        item.index = i
        item.gameObject = menuContent:Find(tostring(i)).gameObject
        item.toggle = item.gameObject:GetComponent(TypeToggle)
        table.insert(this.menuToggles, item)
        this:AddOnToggle(item.gameObject, function(isOn)
            this.OnMenuValueChanged(item, isOn)
        end)
    end
end

function UnionSettingPanel.InitPageNode()
    this.pageNodes = {}
    for i = 1, 6 do
        local item = {}
        table.insert(this.pageNodes, item)
        item.transform = this:Find("Content/Content/" .. i)
        item.gameObject = item.transform.gameObject
        --item.itemContent = item.transform:Find("Content")
        --item.itemPrefab = item.itemContent:Find("Item")
        --item.items = {}
    end
end

function UnionSettingPanel.InitNode1Panel()
    this.captainItemList = {}
    this.captainId = 0
    local node1 = this.content:Find("1")
    this.shenHeToggle = node1:Find("ShenHe/ShenHeToggle")
    this.yinSiToggle = node1:Find("YinSi/YinSiToggle")
    this.daYangToggle = node1:Find("DaYang/DaYangToggle")
    this.captain = node1:Find("Captain")
    this.titleInput = node1:Find("Title/TitleInputField")
    this.captainInput = node1:Find("Captain/CaptainInputField")
    this.searchBtn = node1:Find("Captain/SearchBtn")
    this.noticeInput = node1:Find("Notice/NoticeInputField")
    this.numInput = node1:Find("Num/InputField"):GetComponent(TypeInputField)
    this.saveBtn = node1:Find("SaveBtn")
    this.QuarantineBtn = node1:Find("QuarantineBtn")

end

function UnionSettingPanel.InitNode2Panel()
    local node2 = this.content:Find("2")
    this.LeaveInput = node2:Find("Leave/TitleInputField")
    this.BaseInput = node2:Find("Base/TitleInputField")
    this.RubInput = node2:Find("Rub/TitleInputField")
    this.OptionToggles = node2:Find("OptionToggles")
    this.ScoreToggles = node2:Find("ScoreToggles")
    this.RightToggles = node2:Find("RightToggles")
    this.OptionToggle1 = this.OptionToggles:Find("Toggle")
    this.OptionToggle2 = this.OptionToggles:Find("Toggle (1)")
    this.ScoreToggles1 = this.ScoreToggles:Find("Toggle")
    this.ScoreToggles2 = this.ScoreToggles:Find("Toggle (1)")
    this.RightToggles1 = this.RightToggles:Find("Toggle")
    this.RightToggles2 = this.RightToggles:Find("Toggle (1)")
    this.RightToggles3 = this.RightToggles:Find("Toggle (2)")
    this.Node2SaveBtn = node2:Find("SaveBtn")
end

function UnionSettingPanel.InitNode3Panel()
    local node3 = this.content:Find("3")
    local toggles = node3:Find("Toggles")
    this.Node3_noToggle = toggles:Find("OptionToggles/Toggle")
    this.Node3_yesToggle = toggles:Find("OptionToggles/Toggle (1)")
    this.Node3_noToggle1 = toggles:Find("OptionToggles (1)/Toggle")
    this.Node3_yesToggle1 = toggles:Find("OptionToggles (1)/Toggle (1)")
    this.Node3_noToggle2 = toggles:Find("OptionToggles (2)/Toggle")
    this.Node3_yesToggle2 = toggles:Find("OptionToggles (2)/Toggle (1)")
    this.Node3_line3Toggle1 = toggles:Find("OptionToggles (3)/Toggle")
    this.Node3_line3Toggle2 = toggles:Find("OptionToggles (3)/Toggle (1)")
    this.Node3_line3Toggle3 = toggles:Find("OptionToggles (3)/Toggle (2)")
    this.Node3_line4Toggle1 = toggles:Find("OptionToggles (4)/Toggle")
    this.Node3_line4Toggle2 = toggles:Find("OptionToggles (4)/Toggle (1)")
    this.Node3_line4Toggle3 = toggles:Find("OptionToggles (4)/Toggle (2)")
    this.Node3_noToggle5 = toggles:Find("OptionToggles (5)/Toggle")
    this.Node3_yesToggle5 = toggles:Find("OptionToggles (5)/Toggle (1)")
    this.Node3_noToggle6 = toggles:Find("OptionToggles (6)/Toggle")
    this.Node3_yesToggle6 = toggles:Find("OptionToggles (6)/Toggle (1)")
    this.Node3_line7Toggle1 = toggles:Find("OptionToggles (7)/Toggle")
    this.Node3_line7Toggle2 = toggles:Find("OptionToggles (7)/Toggle (1)")
    this.Node3_line7Toggle3 = toggles:Find("OptionToggles (7)/Toggle (2)")
    this.Node3SaveBtn = node3:Find("SaveBtn")
end

function UnionSettingPanel.InitNode4Panel()

end

function UnionSettingPanel.InitNode5Panel()
    local node5 = this.content:Find("5")
    local toggles = node5:Find("Toggles")
    this.Node5_line0Toggle1 = toggles:Find("OptionToggles/Toggle")
    this.Node5_line0Toggle2 = toggles:Find("OptionToggles/Toggle (1)")
    this.Node5_line0Toggle3 = toggles:Find("OptionToggles/Toggle (2)")
    this.Node5_noToggle1 = toggles:Find("OptionToggles (1)/Toggle")
    this.Node5_yesToggle1 = toggles:Find("OptionToggles (1)/Toggle (1)")
    this.Node5_noToggle2 = toggles:Find("OptionToggles (1)/Toggle")
    this.Node5_yesToggle2 = toggles:Find("OptionToggles (1)/Toggle (1)")
    this.Node5_line3Toggle1 = toggles:Find("OptionToggles (3)/Toggle")
    this.Node5_line3Toggle2 = toggles:Find("OptionToggles (3)/Toggle (1)")
    this.Node5_line3Toggle3 = toggles:Find("OptionToggles (3)/Toggle (2)")
    this.Node5_line3Toggle4 = toggles:Find("OptionToggles (3)/Toggle (3)")
    this.Node5_line3Toggle5 = toggles:Find("OptionToggles (3)/Toggle (4)")
    this.Node5_line3Toggle6 = toggles:Find("OptionToggles (3)/Toggle (5)")
    this.Node5_line4Toggle1 = toggles:Find("OptionToggles (4)/Toggle")
    this.Node5_line4Toggle2 = toggles:Find("OptionToggles (4)/Toggle (1)")
    this.Node5_line4Toggle3 = toggles:Find("OptionToggles (4)/Toggle (2)")
    this.Node5_noToggle5 = toggles:Find("OptionToggles (1)/Toggle")
    this.Node5_yesToggle5 = toggles:Find("OptionToggles (1)/Toggle (1)")
end

function UnionSettingPanel.InitNode6Panel()
    local node = this.content:Find("6")
    local DayToggles = node:Find("DayToggles")
    this.TodayToggle = DayToggles:Find("TodayToggle")
    this.YesterdayToggle = DayToggles:Find("YesterdayToggle")

    local page = node:Find("Bottom/Page")
    this.page = page.gameObject
    this.NextBtn = page:Find("NextBtn")
    this.LastBtn = page:Find("LastBtn")
    this.PageText = page:Find("PageText/Text")
    this.NilData = node:Find("NoDataText")
    this.RankingPageIndex = 1
    this.AllPageCount = 0
    this.DayIndex = 0
    this:AddOnToggle(this.TodayToggle, this.OnTodayToggleClick)
    this:AddOnToggle(this.YesterdayToggle, this.OnYesterdayToggleClick)
    this:AddOnClick(this.NextBtn,this.OnNextBtnClick)
    this:AddOnClick(this.LastBtn,this.OnLastBtnClick)
    this.PageCount = 4
    this.RankingItemList = {}
    this.RankingItemParent = node:Find("Content")
    this.RankingItem = this.RankingItemParent:Find("Item")
    AddEventListener(CMD.Tcp.Union.S2C_Request_Ranking, this.UpdateRankingInfo)
end

function UnionSettingPanel.OnTodayToggleClick(isOn)
    if isOn then
        this.RankingPageIndex = 1
        this.DayIndex = 0
        UnionManager.SendRankingInfoRequest(this.PageCount,1,0)
    end
end

function UnionSettingPanel.OnYesterdayToggleClick(isOn)
    if isOn then
        this.RankingPageIndex = 1
        this.DayIndex = 1
        UnionManager.SendRankingInfoRequest(this.PageCount,1,1)
    end
end

function UnionSettingPanel.OnNextBtnClick()
    if this.RankingPageIndex >= this.AllPageCount then
        Toast.Show("已在尾页")
        return
    end
    this.RankingPageIndex = this.RankingPageIndex + 1
    UnionManager.SendRankingInfoRequest(this.PageCount,this.RankingPageIndex,this.DayIndex)
end

function UnionSettingPanel.OnLastBtnClick()
    if this.RankingPageIndex <= 1 then
        Toast.Show("已在首页")
        return
    end
    this.RankingPageIndex = this.RankingPageIndex - 1
    UnionManager.SendRankingInfoRequest(this.PageCount,this.RankingPageIndex,this.DayIndex)
end


--菜单按钮点击
function UnionSettingPanel.OnMenuValueChanged(item, isOn)
    if isOn then
        if this.nodeIndex ~= item.index then
            this.CloseNode(this.nodeIndex)
            this.nodeIndex = item.index
            this.OpenNode(this.nodeIndex)
        end
    end
end

--关闭节点
function UnionSettingPanel.CloseNode(index)
    local temp = this.pageNodes[index]
    if temp ~= nil then
        UIUtil.SetActive(temp.gameObject, false)
    end
end

--打开节点
function UnionSettingPanel.OpenNode(index)
    local temp = this.pageNodes[index]
    if temp ~= nil then
        UIUtil.SetActive(temp.gameObject, true)
        --
        this.pageIndex = 1
        this.pageTotal = 1
        this.SendRequestList()
        if this.nodeIndex == 4 then
            UnionSettingNode4DarkRoom:OnOpened()
        end
    end
end

function UnionSettingPanel:OnOpened()
    this:AddOnClick(this.closeBtn, this.OnClickBackBtn)
    this:AddOnClick(this.QuarantineBtn, this.OnQuarantineBtnClick)
    this:AddOnClick(this.saveBtn, this.OnClickSaveBtn)
    this:AddOnClick(this.searchBtn, this.OnClickSearchBtn)
    this:AddOnClick(this.Node2SaveBtn, this.OnClickNode2SaveBtn)
    this:AddOnClick(this.Node3SaveBtn, this.OnClickNode3SaveBtn)
    this.SendRequestList(this.pageIndex)

    ---默认选中
    local temp = this.menuToggles[1]
    temp.toggle.isOn = false
    temp.toggle.isOn = true
end

function UnionSettingPanel:OnClosed()
    UnionSettingNode4DarkRoom:OnClosed()
    RemoveEventListener(CMD.Tcp.Union.S2C_Request_Ranking, this.UpdateRankingInfo)
end

function UnionSettingPanel.OnQuarantineBtnClick()
    local temp = this.menuToggles[4]
    temp.toggle.isOn = false
    temp.toggle.isOn = true
end

function UnionSettingPanel.SendRequestList()
    if this.nodeIndex == 1 or this.nodeIndex == 2 or this.nodeIndex == 3 or this.nodeIndex == 5 then
        LogError("<color=aqua>sendRequset</color>")
        UnionManager.SendGetUnionSetting()
    elseif this.nodeIndex == 6 then
        UnionManager.SendRankingInfoRequest(this.PageCount,1,0)
    end
end

function UnionSettingPanel.OnClickSaveBtn()
    LogError("OnClickSaveBtn")
    local isOpenShenHe = Functions.TernaryOperator(UIUtil.GetToggle(this.shenHeToggle), 1, 0)
    local isOpenYinSi = Functions.TernaryOperator(UIUtil.GetToggle(this.yinSiToggle), 1, 0)
    local isOpenDaYang = Functions.TernaryOperator(UIUtil.GetToggle(this.daYangToggle), 1, 0)
    local title = UIUtil.GetInputText(this.titleInput)
    local notice = UIUtil.GetInputText(this.noticeInput)
    local num = tonumber(this.numInput.text) 
    if string.IsNullOrEmpty(title) then
        Toast.Show("请输入联盟名称")
        return
    end
    if isOpenShenHe == UnionData.isOpenShenHe and
            isOpenYinSi == UnionData.isOpenYinSi and
            isOpenDaYang == UnionData.isOpenDaYang and
            title == UnionData.unionTitle and
            notice == UnionData.unionNotice and
            num == UnionData.showTableNum then
        Toast.Show("没有改变设置")
        return
    end

    Alert.Prompt("确定修改设置数据？", function()
        UnionManager.SendSetUnionSetting(isOpenShenHe, isOpenYinSi, isOpenDaYang, title, notice, num, this.captainId)
    end)
end

--点击搜索队长公告
function UnionSettingPanel.OnClickSearchBtn()
    local str = UIUtil.GetInputText(this.captainInput)
    --空字符串代表联盟公告
    if str == "" then
        this.captainId = 0
        if UnionData.unionNotice ~= nil then
            UIUtil.SetInputText(this.noticeInput, tostring(UnionData.unionNotice))
        else
            UIUtil.SetInputText(this.noticeInput, "")
        end
        return
    else
        if tonumber(str) == nil then
            Toast.Show("请输出正确的玩家ID")
            return
        end
        this.captainId = tonumber(str)
    end
    UnionManager.SendGetCaptainNotice(str)
end

--刷新队长公告显示
function UnionSettingPanel.UpdateCaptainNotice(data)
    if data ~= nil and tonumber(data.partnerId) == this.captainId and data.notice ~= nil then
        UIUtil.SetInputText(this.noticeInput, tostring(data.notice))
    else
        UIUtil.SetInputText(this.noticeInput, "")
    end
end

function UnionSettingPanel.OnClickNode2SaveBtn()
    LogError("OnClickNode2SaveBtn")
    local LeaveInputText = UIUtil.GetInputText(this.LeaveInput)
    local BaseInputText = UIUtil.GetInputText(this.BaseInput)
    local RubInputText = UIUtil.GetInputText(this.RubInput)

    local isOptionToggle1 = UIUtil.GetToggle(this.OptionToggle1)
    local isOptionToggle2 = UIUtil.GetToggle(this.OptionToggle2)
    local isScoreToggles1 = UIUtil.GetToggle(this.ScoreToggles1)
    local isScoreToggles2 = UIUtil.GetToggle(this.ScoreToggles2)
    local isRightToggles1 = Functions.TernaryOperator(UIUtil.GetToggle(this.RightToggles1), 1, nil)
    local isRightToggles2 = Functions.TernaryOperator(UIUtil.GetToggle(this.RightToggles2), 2, nil)
    local isRightToggles3 = Functions.TernaryOperator(UIUtil.GetToggle(this.RightToggles3), 3, nil)

    local isOptionToggles = isOptionToggle1
    local isScoreToggles = isScoreToggles1
    local isRightToggles = isRightToggles1 or isRightToggles2 or isRightToggles3

    Alert.Prompt("确定修改茶馆设置数据？", function()
        UnionManager.SendSetUnionNode2Option(tonumber(BaseInputText), tonumber(RubInputText), tonumber(LeaveInputText), isOptionToggles, isScoreToggles, isRightToggles)
    end)
end

function UnionSettingPanel.OnClickNode3SaveBtn()
    LogError("OnClickNode3SaveBtn")
    local isNode3_yesToggle = UIUtil.GetToggle(this.Node3_yesToggle)
    local isNode3_yesToggle1 = UIUtil.GetToggle(this.Node3_yesToggle1)
    local isNode3_yesToggle2 = UIUtil.GetToggle(this.Node3_yesToggle2)
    local isNode3_line3Toggle1 = Functions.TernaryOperator(UIUtil.GetToggle(this.Node3_line3Toggle1), 1, nil)
    local isNode3_line3Toggle2 = Functions.TernaryOperator(UIUtil.GetToggle(this.Node3_line3Toggle2), 1, nil)
    local isNode3_line3Toggle3 = Functions.TernaryOperator(UIUtil.GetToggle(this.Node3_line3Toggle3), 1, nil)
    local isNode3_line4Toggle1 = Functions.TernaryOperator(UIUtil.GetToggle(this.Node3_line4Toggle1), 1, nil)
    local isNode3_line4Toggle2 = Functions.TernaryOperator(UIUtil.GetToggle(this.Node3_line4Toggle2), 1, nil)
    local isNode3_line4Toggle3 = Functions.TernaryOperator(UIUtil.GetToggle(this.Node3_line4Toggle3), 1, nil)
    local isNode3_yesToggle5 = UIUtil.GetToggle(this.Node3_yesToggle5)
    local isNode3_yesToggle6 = UIUtil.GetToggle(this.Node3_yesToggle6)
    local isNode3_line7Toggle1 = Functions.TernaryOperator(UIUtil.GetToggle(this.Node3_line7Toggle1), 1, nil)
    local isNode3_line7Toggle2 = Functions.TernaryOperator(UIUtil.GetToggle(this.Node3_line7Toggle2), 1, nil)
    local isNode3_line7Toggle3 = Functions.TernaryOperator(UIUtil.GetToggle(this.Node3_line7Toggle3), 1, nil)

    local isNode3_line3Toggles = isNode3_line3Toggle1 or isNode3_line3Toggle2 or isNode3_line3Toggle3
    local isNode3_line4Toggles = isNode3_line4Toggle1 or isNode3_line4Toggle2 or isNode3_line4Toggle3
    local isNode3_line7Toggles = isNode3_line7Toggle1 or isNode3_line7Toggle2 or isNode3_line7Toggle3

    Alert.Prompt("确定修改高级设置数据？", function()
        UnionManager.SendSetNode3AdvanceOption(isNode3_yesToggle, isNode3_yesToggle1, isNode3_yesToggle2, isNode3_line3Toggles, isNode3_line4Toggles, isNode3_yesToggle5, isNode3_yesToggle6, isNode3_line7Toggles)
    end)
end

function UnionSettingPanel.OnClickNode5SaveBtn()
    LogError("OnClickNode5SaveBtn")
    Alert.Prompt("确定修改茶馆设置数据？", function()
        UnionManager.SendSetNode4OtherOption(luckyMode, hideAllFace, autoNotFull, maxSameJu, hideFull, autoMode)
    end)
end

function UnionSettingPanel.OnClickBackBtn()
    PanelManager.Close(PanelConfig.UnionSetting, true)
end

function UnionSettingPanel.UpdatePanel(data)
    if this.nodeIndex == 1 then
        this.UpdataNode1Panel(data)
    elseif this.nodeIndex == 2 then
        this.UpdataNode2Panel(data)
    elseif this.nodeIndex == 3 then
        this.UpdataNode3Panel(data)
    elseif this.nodeIndex == 5 then
        this.UpdataNode5Panel(data)
    end
end

function UnionSettingPanel.UpdataNode1Panel(data)
    LogError("<color=aqua>this.shenHeToggle</color>", this.shenHeToggle, "UnionData.isOpenShenHe", UnionData.isOpenShenHe)
    UIUtil.SetToggle(this.shenHeToggle, false--[[UnionData.isOpenShenHe]])
    UIUtil.SetToggle(this.yinSiToggle, UnionData.isOpenYinSi)
    UIUtil.SetToggle(this.daYangToggle, UnionData.isOpenDaYang)
    if UnionData.unionTitle ~= nil then
        UIUtil.SetInputText(this.titleInput, tostring(UnionData.unionTitle))
    else
        UIUtil.SetInputText(this.titleInput, "")
    end

    if UnionData.unionNotice ~= nil then
        UIUtil.SetInputText(this.noticeInput, tostring(UnionData.unionNotice))
    else
        UIUtil.SetInputText(this.noticeInput, "")
    end

    if UnionData.showTableNum ~= nil then
        this.numInput.text = tostring(UnionData.showTableNum)
    else
        this.numInput.text = ""
    end
end

---@param niuJoin number 牛牛加入倍数
---@param niuRob number 牛牛抢庄倍数
---@param niuLeave number 离座分数
---@param gameNegative  boolean 游戏中能否负分
---@param changeScoreInGame boolean 游戏中能否修改游戏
---@param jiFenAuth number 积分权限
function UnionSettingPanel.UpdataNode2Panel(data)
    LogError("node2 Data", data)
    local data = data.comm
    UIUtil.SetInputText(this.LeaveInput, tostring(data.niuLeave))
    UIUtil.SetInputText(this.BaseInput, tostring(data.niuJoin))
    UIUtil.SetInputText(this.RubInput, tostring(data.niuRob))
    UIUtil.SetToggle(this.OptionToggle1, data.gameNegative)
    UIUtil.SetToggle(this.OptionToggle2, not data.gameNegative)
    UIUtil.SetToggle(this.ScoreToggles1, data.changeScoreInGame)
    UIUtil.SetToggle(this.ScoreToggles2, not data.changeScoreInGame)
    UIUtil.SetToggle(this.RightToggles1, data.jiFenAuth == 1)
    UIUtil.SetToggle(this.RightToggles2, data.jiFenAuth == 2)
    UIUtil.SetToggle(this.RightToggles3, data.jiFenAuth == 3)
end

---@param dissolveInGame boolean 游戏中解散
---@param hideFenInGame boolean 游戏中隐藏分
---@param canSendTxtGame  boolean 游戏中发送消息
---@param tuoguan number 托管
---@param notReady number 不准备剔除
---@param sameUpDivided boolean 通队长隔离
---@param showPer number 显示比例
---@param limitDistance number 距离限制
function UnionSettingPanel.UpdataNode3Panel(data)
    LogError("<color=aqua>Node3 data</color>", data)
    local data = data.advanced
    UIUtil.SetToggle(this.Node3_noToggle, not data.dissolveInGame)
    UIUtil.SetToggle(this.Node3_yesToggle, data.dissolveInGame)
    UIUtil.SetToggle(this.Node3_noToggle1, not data.hideFenInGame)
    UIUtil.SetToggle(this.Node3_yesToggle1, data.hideFenInGame)
    UIUtil.SetToggle(this.Node3_noToggle2, not data.canSendTxtGame)
    UIUtil.SetToggle(this.Node3_yesToggle2, data.canSendTxtGame)
    UIUtil.SetToggle(this.Node3_line3Toggle1, data.tuoguan == 0)
    UIUtil.SetToggle(this.Node3_line3Toggle2, data.tuoguan == 1)
    UIUtil.SetToggle(this.Node3_line3Toggle3, data.tuoguan == 2)
    UIUtil.SetToggle(this.Node3_line4Toggle1, data.notReady == 0)
    UIUtil.SetToggle(this.Node3_line4Toggle2, data.notReady == 1)
    UIUtil.SetToggle(this.Node3_line4Toggle3, data.notReady == 2)
    UIUtil.SetToggle(this.Node3_noToggle5, not data.sameUpDivided)
    UIUtil.SetToggle(this.Node3_yesToggle5, data.sameUpDivided)
    UIUtil.SetToggle(this.Node3_noToggle6, data.showPer == 0)
    UIUtil.SetToggle(this.Node3_yesToggle6, data.showPer ~= 0)
    UIUtil.SetToggle(this.Node3_line7Toggle1, data.notReady == 0)
    UIUtil.SetToggle(this.Node3_line7Toggle2, data.notReady == 1)
    UIUtil.SetToggle(this.Node3_line7Toggle3, data.notReady == 2)
end

function UnionSettingPanel.UpdataNode5Panel(data)
    LogError("<color=aqua>Node5 data</color>", data)
    local data = data.other
    UIUtil.SetToggle(this.Node5_line0Toggle1, data.luckyMode == 0)
    UIUtil.SetToggle(this.Node5_line0Toggle2, data.luckyMode == 1)
    UIUtil.SetToggle(this.Node5_line0Toggle3, data.luckyMode == 2)
    UIUtil.SetToggle(this.Node5_noToggle1, not data.hideAllFace)
    UIUtil.SetToggle(this.Node5_yesToggle1, data.hideAllFace)
    UIUtil.SetToggle(this.Node5_noToggle2, not data.autoNotFull)
    UIUtil.SetToggle(this.Node5_yesToggle2, data.autoNotFull)
    UIUtil.SetToggle(this.Node5_line3Toggle1, data.maxSameJu == 0)
    UIUtil.SetToggle(this.Node5_line3Toggle2, data.maxSameJu == 10)
    UIUtil.SetToggle(this.Node5_line3Toggle3, data.maxSameJu == 20)
    UIUtil.SetToggle(this.Node5_line3Toggle4, data.maxSameJu == 30)
    UIUtil.SetToggle(this.Node5_line3Toggle5, data.maxSameJu == 40)
    UIUtil.SetToggle(this.Node5_line3Toggle6, data.maxSameJu == 50)
    UIUtil.SetToggle(this.Node5_line4Toggle1, data.hideFull == 0)
    UIUtil.SetToggle(this.Node5_line4Toggle2, data.hideFull == 1)
    UIUtil.SetToggle(this.Node5_line4Toggle3, data.hideFull == 2)
    UIUtil.SetToggle(this.Node5_noToggle1, not data.autoMode)
    UIUtil.SetToggle(this.Node5_yesToggle1, data.autoMode)
end

--list列表 {
--    userId 玩家id
--    fen 玩家积分
--    name 名字
--    icon 头像
--    ju 局数
--    win 输赢
--    rank 排行
--}
--pageIndex 页码
--num 每页总数
--allPage 总页数
--totalNum 总数
--page （不一定有当页码不对时纠正用）（可选当前页）
function UnionSettingPanel.UpdateRankingInfo(data)
    LogError("<color=aqua>data</color>",data)
    if data.code == 0 then
        local info = data.data
        local nilData = info.allPage == 0
        UIUtil.SetActive(this.NilData,nilData)
        --UIUtil.SetActive(this.page,not nilData)
        this.HideAllItem()
        if not nilData then
            this.AllPageCount = info.allPage
            UIUtil.SetText(this.PageText,info.pageIndex.."/"..info.allPage)
            for i= 1,#info.list do
                local item = this.GetRankingItem(i)
                local userData = info.list[i]
                local icon = item:Find("Head/Mask/Icon"):GetComponent(TypeImage)
                Functions.SetHeadImage(icon, userData.icon)
                UIUtil.SetText(item:Find("Head/NameText"),userData.name)
                UIUtil.SetText(item:Find("Head/IdText"),tostring(userData.userId))
                UIUtil.SetText(item:Find("RankNum"),tostring(userData.rank))
                UIUtil.SetText(item:Find("Ju"),tostring(userData.ju))
                UIUtil.SetText(item:Find("Result"),tostring(userData.win))
            end
        end
    end
end

function UnionSettingPanel.HideAllItem()
    UIUtil.SetActive(this.RankingItem,false)
    for i = 1,#this.RankingItemList do
        UIUtil.SetActive(this.RankingItemList[i],false)
    end
end

function UnionSettingPanel.GetRankingItem(i)
    this.RankingItemList[i] =  this.RankingItemList[i] or NewObject(this.RankingItem,this.RankingItemParent)
    UIUtil.SetActive(this.RankingItemList[i],true)
    return this.RankingItemList[i]
end