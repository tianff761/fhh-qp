UnionRoomPanel = ClassPanel("UnionRoomPanel")
local this = UnionRoomPanel

-- 当前桌子对应的游戏，即游戏ID
UnionRoomPanel.gameType = 0
-- 当前桌子对应的标签
UnionRoomPanel.note = nil
---被跟踪玩家ID
UnionRoomPanel.followPlayerId = 0
-- 当前请求的页数
UnionRoomPanel.pageIndex = 1
-- 当前数据的总页数
UnionRoomPanel.pageTotal = 1
-- 当前请求数据中的总数据
UnionRoomPanel.tableDataTotal = 0
--桌子数据列表
UnionRoomPanel.tableDataList = {}
-- 定时属性房间列表的Timer
UnionRoomPanel.refreshTimer = nil
--请求时间字典
UnionRoomPanel.requestTimeDict = {}
-- 红点存储
UnionRoomPanel.redPointTrans = nil
--是否开启，主要用于Toggle的初始化判断
UnionRoomPanel.isOpend = false
--备注显示项
UnionRoomPanel.noteItems = {}
--缓存的桌子总数据，用于处理UIScrollView
UnionRoomPanel.lastTableDataTotal = 0
--换成更新处理的游戏类型
UnionRoomPanel.lastUpdateGameType = nil
--当前的玩法对应的游戏类型，用于记录选中的玩法
UnionRoomPanel.lastNoteGameType = nil
--当前的玩法序号类型
UnionRoomPanel.lastNoteIndexType = nil
--当前换成的标签名称
UnionRoomPanel.lastNoteName = nil

--是否请求了Note数据
UnionRoomPanel.isRequestNoteData = false
--用于请求数据的游戏类型
UnionRoomPanel.requestNoteGameType = nil

--是否展开
UnionRoomPanel.isUnfold = false
UnionRoomPanel.fastClickTime = 0
UnionRoomPanel.deskClickTime = 0

--标记是否显示btn列表
UnionRoomPanel.isShowListBtns = true

UnionRoomPanel.isShowNoteList = true

local Color_Txt_Gray = Color(1, 1, 1)
local Color_Txt_Normal = Color(255 / 255, 255 / 255, 1)


function UnionRoomPanel:Awake()
    this = self
    this.redPointTrans = {}
    -- top
    local top = this:Find("Content/Top")

    this.backBtn = top:Find("BackBtn")

    this.unionKey = top:Find("UnionId")
    this.unionName = top:Find("UnionName")
    this.waiting = top:Find("waiting")
    this.gaming = top:Find("gaming")

    local headBg = this:Find("Content/UserInfo/HeadBg")
    local HeadTrans = headBg:Find("Head/Mask/HeadIcon")
    this.headImg = HeadTrans:GetComponent(TypeImage)
    this.HeadIconBtn = HeadTrans:GetComponent(TypeButton)

    this.nameText = headBg:Find("NameText")
    this.idText = headBg:Find("IdText")

    -- bottom
    local bottomTran = this:Find("Content/Bottom")

    this.fkText = top:Find("Money/FkInfo/Num")
    this.goldText = top:Find("Money/GoldInfo/Num")

    this.menuBtn = bottomTran:Find("MenuButton").gameObject

    this.selectBtn = bottomTran:Find("BtnsContent/SelectBtn").gameObject
    this.noticeBtnGo = bottomTran:Find("BtnsContent/ListBtns/NoticeBtn").gameObject
    this.manageBtnGo = bottomTran:Find("BtnsContent/ListBtns/ManageBtn").gameObject
    this.partnerBtnGo = bottomTran:Find("BtnsContent/ListBtns/PartnerBtn").gameObject
    this.recordBtnGo = bottomTran:Find("BtnsContent/ListBtns/RecordBtn").gameObject
    this.settingBtnGo = bottomTran:Find("BtnsContent/ListBtns/SettingBtn").gameObject
    this.styleBtnGo = bottomTran:Find("BtnsContent/ListBtns/StyleBtn").gameObject
    this.createBtnGo = bottomTran:Find("BtnsContent/ListBtns/CreateBtn").gameObject

    this.noticeBtn = bottomTran:Find("BtnsContent/ListBtns/NoticeBtn/Button").gameObject
    this.manageBtn = bottomTran:Find("BtnsContent/ListBtns/ManageBtn/Button").gameObject
    this.partnerBtn = bottomTran:Find("BtnsContent/ListBtns/PartnerBtn/Button").gameObject
    this.recordBtn = bottomTran:Find("BtnsContent/ListBtns/RecordBtn/Button").gameObject
    this.settingBtn = bottomTran:Find("BtnsContent/ListBtns/SettingBtn/Button").gameObject
    this.styleBtn = bottomTran:Find("BtnsContent/ListBtns/StyleBtn/Button").gameObject
    this.createBtn = bottomTran:Find("BtnsContent/ListBtns/CreateBtn/Button").gameObject

    

    this.switchBtn = bottomTran:Find("BtnsContent/ListBtns/SwitchBtn").gameObject
    this.switchBtnTweener = bottomTran:Find("BtnsContent/ListBtns/SwitchBtn"):GetComponent(TypeTweenRotation)
    this.listBtnsTweener = bottomTran:Find("BtnsContent/ListBtns"):GetComponent(TypeTweenPosition)
    this.listBtnRect = bottomTran:Find("BtnsContent/ListBtns"):GetComponent(TypeRectTransform)
    

    this.FastEnterTableBtn = bottomTran:Find("FastEnterTableBtn").gameObject
    this.StopFollowPlayerBtn = bottomTran:Find("StopFollowPlayerBtn").gameObject

    -- GameNode
    local gameNode = this:Find("Content/GameNode")
    this.gameNode = gameNode.gameObject
    this.gameNodeCloseBtn = gameNode:Find("CloseBtn").gameObject
    --this.gameNodeTweener = gameNode:GetComponent(TypeWindowTweener)
    local gameListContent = gameNode:Find("GameList/Viewport/Content")
    this.gameMenus = {}
    local tempMenuConfigs = { 0, GameType.Mahjong, GameType.PaoDeKuai, GameType.Pin5, GameType.Pin3, GameType.ErQiShi, GameType.TP, GameType.LYC }
    for i = 1, #tempMenuConfigs do
        local gameType = tempMenuConfigs[i]
        table.insert(this.gameMenus,
            { gameType = gameType, toggle = gameListContent:Find(tostring(gameType)):GetComponent(TypeToggle) })
    end

    -- center
    local center = this:Find("Content/Center")
    local tableList = center:Find("TableList")
    this.tableListRect = tableList:GetComponent(TypeRectTransform)
    this.uiScrollView = UIHScrollView.New()
    this.uiScrollView.onSetItemCallback = this.OnSetItemCallback
    this.uiScrollView.onUpdateItemCallback = this.OnUpdateItemCallback
    this.uiScrollView.onNeedPageCallback = this.OnNeedPageCallback
    this.uiScrollView:Init(tableList, 2, UnionTableCountPerPage / 2, 16, 16, 300, 210, 10)
    this.playerItemPrefab = center:Find("PlayerItem").gameObject

    this.noteListSwitchBtn = center:Find("Mask/NoteList/SwitchBtn").gameObject
    local noteList = center:Find("Mask/NoteList")
    this.noteContent = noteList:Find("ScrollView/Viewport/Content")

    this.allNoteItem = {}
    local temp = this.noteContent:Find("0")
    this.allNoteItem.index = 0
    this.allNoteItem.transform = temp
    this.allNoteItem.gameObject = temp.gameObject
    this.allNoteItem.data = { gameType = 0, game = 0, gameName = "全部玩法" }
    this.allNoteItem.noteName = "0"
    this.allNoteItem.toggle = temp.gameObject:GetComponent(TypeToggle)
    this.noteItemPrefab = this.noteContent:Find("Item").gameObject

    this.Background = this:Find("Background"):GetComponent(TypeImage)

    this.AddUIListenerEvent()
end


function UnionRoomPanel:OnOpened()
    this.AddListenerEvent()
    this.InitPanel()
    this.HideLuckyValueBtnByUserUnionRole()
    BaseTcpApi.SendEnterModule(ModuleType.Union)
    this.OnGameUpdateRedPoint()
    --LogError("OnOpened", UnionData.curUnionId)
    UnionManager.SendGetUnionInfo(UnionData.curUnionId)
    --
    PanelManager.Close(PanelConfig.UnionEnter)

    this.ResetRequest()
    this.StartRefreshTimer()
    this.SetLastSelectUnion()
    --
    this.isOpend = true
    this.JudgeOpenNoticePanel()
    --跑马灯
    this.OpenTopNoticePanel()
    --
    UIUtil.SetActive(this.gameNode, true)
    this.OnSetTableListPos()
    this.isOpenGameNode = true
    this.CheckSelectGameMenu()
    this.isOpenGameNode = false
    --
    this.CheckUpdateBackground()

    UnionManager.SendHasRoomGameIds()
end

function UnionRoomPanel.SetLastSelectUnion()
    local unionInfo = UnionData.GetUnionInfo()
    SetLocal("LastUnionID", unionInfo.id)
end

--检测选中的游戏菜单
function UnionRoomPanel.CheckSelectGameMenu()
    --处理菜单显示
    local item = nil
    local selected = nil
    for i = 1, #this.gameMenus do
        item = this.gameMenus[i]
        if item.gameType == this.gameType then
            selected = item
        end
    end
    if selected == nil then
        selected = this.gameMenus[1]
    end
    selected.toggle.isOn = false
    selected.toggle.isOn = true
end

function UnionRoomPanel.JudgeOpenNoticePanel()
    LogError("GameSceneManager.lastGameScene.type", GameSceneManager.lastGameScene.type)
    if GameSceneManager.lastGameScene and GameSceneManager.lastGameScene.type ~= GameSceneType.Room then
        this.OnNoticeBtnClick()
    end
end

function UnionRoomPanel.OpenTopNoticePanel()
    PanelManager.Open(PanelConfig.Notice)
end

function UnionRoomPanel.CloseTopNoticePanel()
    PanelManager.Close(PanelConfig.Notice)
end

function UnionRoomPanel.HideLuckyValueBtnByUserUnionRole()
    --UIUtil.SetActive(this.luckyValueBtn, UnionData.selfRole ~= UnionRole.Common)
end

function UnionRoomPanel:OnClosed()
    this.isOpend = false
    this.gameType = 0
    this.RemoveListenerEvent()
    UnionManager.SendGetUnionsList()
    this.note = nil
    this.HideAllNoteItem()
    this.pageIndex = 1
    this.pageTotal = 1
    this.requestTimeDict = {}
    this.tableDataList = {}
    this.StopRefreshTimer()
    this.lastTableDataTotal = 0
    this.CloseTopNoticePanel()

    this.lastUpdateGameType = nil
    this.lastNoteGameType = nil
    this.lastNoteIndexType = nil
    this.lastNoteName = nil
    this.isRequestNoteData = false
    this.requestNoteGameType = nil
    this.isOpenGameNode = false

    if this.isShowListBtns == false then
        this.OnSwitchBtnClick()
    end

    if this.isShowNoteList == false then
        this.OnNoteListSwitchBtnnClick()
    end
end

------------------------------------------------------------------
--
--注册事件
function UnionRoomPanel.AddListenerEvent()
    AddMsg(CMD.Game.UpdateRedPointTips, this.OnGameUpdateRedPoint)
    AddMsg(CMD.Game.UpdateMoney, this.OnGameUpdateUserInfo)
    AddMsg(CMD.Game.UnionDeleteTableRefresh, this.OnUnionDeleteTableRefresh)
    AddMsg(CMD.Game.UnionUpdateName, this.OnUnionUpdateName)
    AddMsg(CMD.Tcp.Union.S2C_QuickGame, this.GetFastEnterTableResponse)
    AddMsg(CMD.Game.UnionFollowPlayer, this.OnUnionFollowPlayer)
    AddMsg(CMD.Game.UnionUpdateBackground, this.OnUnionUpdateBackground)
end

--移除事件
function UnionRoomPanel.RemoveListenerEvent()
    RemoveMsg(CMD.Game.UpdateRedPointTips, this.OnGameUpdateRedPoint)
    RemoveMsg(CMD.Game.UpdateMoney, this.OnGameUpdateUserInfo)
    RemoveMsg(CMD.Game.UnionDeleteTableRefresh, this.OnUnionDeleteTableRefresh)
    RemoveMsg(CMD.Game.UnionUpdateName, this.OnUnionUpdateName)
    RemoveMsg(CMD.Tcp.Union.S2C_QuickGame, this.GetFastEnterTableResponse)
    RemoveMsg(CMD.Game.UnionFollowPlayer, this.OnUnionFollowPlayer)
    RemoveMsg(CMD.Game.UnionUpdateBackground, this.OnUnionUpdateBackground)
end

--UI相关事件
function UnionRoomPanel.AddUIListenerEvent()
    LogError(">> UnionRoomPanel.AddUIListenerEvent")

    EventUtil.AddOnClick(this.menuBtn, this.OnMenuBtnClick)
    EventUtil.AddOnClick(this.gameNodeCloseBtn, this.OnGameNodeCloseBtnClick)

    EventUtil.AddOnClick(this.noticeBtn, this.OnNoticeBtnClick)
    EventUtil.AddOnClick(this.partnerBtn, this.OnPartnerBtnClick)

    EventUtil.AddOnClick(this.backBtn, this.OnCloseBtnClick)

    EventUtil.AddOnClick(this.settingBtn, this.OnSettingBtnClick)
    EventUtil.AddOnClick(this.styleBtn, this.OnStyleBtnClick)

    EventUtil.AddOnClick(this.manageBtn, this.OnManageBtnClick)
    EventUtil.AddOnClick(this.recordBtn, this.OnRecordBtnClick)
    EventUtil.AddOnClick(this.createBtn, this.OnCreateRoomBtnClick)
    EventUtil.AddOnClick(this.selectBtn, this.OnSelectBtnClick)
    
    EventUtil.AddOnClick(this.switchBtn, this.OnSwitchBtnClick)
    EventUtil.AddOnClick(this.noteListSwitchBtn, this.OnNoteListSwitchBtnnClick)

    this:AddOnClick(this.FastEnterTableBtn, this.OnFastEnterTableBtnClick)
    this:AddOnClick(this.StopFollowPlayerBtn, this.OnStopFollowPlayerBtnClick)


    this:AddOnClick(this.HeadIconBtn, this.OnHeadIconBtnClick)
    --全部备注显示项
    this:AddOnToggle(this.allNoteItem.toggle, function(isOn)
        this.OnNoteItemValueChanged(this.allNoteItem, isOn)
    end)

    for i = 1, #this.gameMenus do
        local item = this.gameMenus[i]
        this:AddOnToggle(item.toggle, function(isOn)
            this.OnGameMenuValueChanged(item, isOn)
        end)
    end
end

--================================================================
--
--列表显隐
function UnionRoomPanel.OnNoteListSwitchBtnnClick()
    this.isShowNoteList = not this.isShowNoteList
    local img1 = this.noteListSwitchBtn.transform:Find("Image1").gameObject
    local img2 = this.noteListSwitchBtn.transform:Find("Image2").gameObject
    if(this.isShowNoteList) then
        this.tableListRect.offsetMin = Vector2(336, this.tableListRect.offsetMin.y)
        UIUtil.SetAnchoredPosition(this.noteListSwitchBtn, 215, -45)
        UIUtil.SetActive(img1, true)
        UIUtil.SetActive(img2, false)
    else
        this.tableListRect.offsetMin = Vector2(155, this.tableListRect.offsetMin.y)
        UIUtil.SetAnchoredPosition(this.noteListSwitchBtn, 220, -45)
        UIUtil.SetActive(img1, false)
        UIUtil.SetActive(img2, true)
    end
end

--按钮列表显隐-696
function UnionRoomPanel.OnSwitchBtnClick()
    this.isShowListBtns = not this.isShowListBtns

    local temp = 40 - this.listBtnRect.rect.width

    local rStart = 0
    local rEnd = 0
    local pStart = 0
    local pEnd = 0
    if this.isShowListBtns then
        rStart = 180
        rEnd = 0
        pStart = temp
        pEnd = -50
    else
        rStart = 0
        rEnd = 180
        pStart = -50
        pEnd = temp
    end

    this.switchBtnTweener.from = Vector3(0, 0, rStart)
    this.switchBtnTweener.to = Vector3(0, 0, rEnd)
    this.switchBtnTweener:ResetToBeginning()
    this.switchBtnTweener:PlayForward()

    this.listBtnsTweener.from = Vector3(pStart, -38, 0)
    this.listBtnsTweener.to = Vector3(pEnd, -38, 0)
    this.listBtnsTweener:ResetToBeginning()
    this.listBtnsTweener:PlayForward()
end


--游戏菜单切换
function UnionRoomPanel.OnGameMenuValueChanged(item, isOn)
    if this.isOpend and this.isOpenGameNode == false and isOn then
        if this.gameType ~= item.gameType then
            --设置类型
            this.gameType = item.gameType
            --清除备注
            this.note = nil
            --
            if this.isRequestNoteData then
                --LogError(">> ============================ ", this.gameType)
                this.allNoteItem.toggle.isOn = false
                this.allNoteItem.toggle.isOn = true
            end
        end
    end
end

function UnionRoomPanel.OnPartnerBtnClick()
    PanelManager.Open(PanelConfig.UnionPartnerMgr)
end

function UnionRoomPanel.OnClickLuckyValueBtn()
    PanelManager.Open(PanelConfig.LuckyValuePool, GroupType.Union, UnionData.curUnionId,
        UnionData.selfRole == UnionRole.Leader or UnionData.selfRole == UnionRole.Partner, UnionData.isOpenYinSi)
    --PanelManager.Open(PanelConfig.EnterLuckyValuePool, GroupType.Union, UnionData.curUnionId,
    --        UnionData.selfRole == UnionRole.Leader or UnionData.selfRole == UnionRole.Partner, UnionData.isOpenYinSi)
end

function UnionRoomPanel.OnNoticeBtnClick()
    PanelManager.Open(PanelConfig.UnionNotice)
end

function UnionRoomPanel.OnCloseBtnClick()
    PanelManager.Close(PanelConfig.UnionRoom)
end

function UnionRoomPanel.OnSettingBtnClick()
    if UnionData.IsUnionLeaderOrAdministratorOrObserver() then
        PanelManager.Open(PanelConfig.UnionSetting)
    else
        Toast.Show("无权限查看")
    end
end

function UnionRoomPanel.OnStyleBtnClick()
    PanelManager.Open(PanelConfig.UnionStyle)
end

function UnionRoomPanel.OnMenuBtnClick()
    if this.gameNode.activeSelf then
        this.gameNodeTweener:PlayCloseAnim(this.OnGameNodeTweenerCompleted)
    else
        UIUtil.SetActive(this.gameNode, true)
        this.gameNodeTweener:PlayOpenAnim()
        this.isOpenGameNode = true
        this.CheckSelectGameMenu()
        this.isOpenGameNode = false
    end
end

--设置菜单栏显隐时桌子列表布局显示
function UnionRoomPanel.OnSetTableListPos()
    if this.gameNode.activeSelf then
        this.tableListRect.offsetMin = Vector2(313, this.tableListRect.offsetMin.y)
    else
        this.tableListRect.offsetMin = Vector2(125, this.tableListRect.offsetMin.y)
    end
end

function UnionRoomPanel.OnSelectBtnClick()
    UIUtil.SetActive(this.gameNode, not this.gameNode.activeSelf)
    this.OnSetTableListPos()
end

function UnionRoomPanel.OnGameNodeCloseBtnClick()
    UIUtil.SetActive(this.gameNode, false)
    this.OnSetTableListPos()
    -- this.gameNodeTweener:PlayCloseAnim(this.OnGameNodeTweenerCompleted)
end

--关闭动画完成
function UnionRoomPanel.OnGameNodeTweenerCompleted()
    UIUtil.SetActive(this.gameNode, false)
end


function UnionRoomPanel.OnManageBtnClick()
    --Toast.Show("敬请期待...")
    --if UnionData.selfRole == UnionRole.Common then
    --    PanelManager.Open(PanelConfig.UnionScoreManager, UserData.GetUserId())
    --else
    --    PanelManager.Open(PanelConfig.UnionLuckyValueManage)
    --end
    if UnionData.IsUnionLeaderOrAdministratorOrObserver() then
        PanelManager.Open(PanelConfig.UnionScoreManager, UserData.GetUserId())
    else
        Toast.Show("无权限查看")
    end
end

function UnionRoomPanel.OnBlackHouseBtnClick()
    PanelManager.Open(PanelConfig.UnionDarkRoom)
end

function UnionRoomPanel.OnRecordBtnClick()
    PanelManager.Open(PanelConfig.Record, RoomType.Tea, UnionData.curUnionId, UnionData.isOpenYinSi)
end

function UnionRoomPanel.OnClickMyCardBtn()
    PanelManager.Open(PanelConfig.UnionMyCard, UserData.GetUserId())
end

function UnionRoomPanel.OnClickServiceBtn()
    PanelManager.Open(PanelConfig.ServiceChat, 1, UnionData.curUnionId)
end

function UnionRoomPanel.OnFastEnterTableBtnClick()
    --Toast.Show("功能暂未开放")
    if this.note == "0" then
        Toast.Show("没选择玩法")
    else
        if Time.realtimeSinceStartup - this.fastClickTime > 2 then
            this.fastClickTime = Time.realtimeSinceStartup
            UnionManager.SendQuickGameRequest(this.note)
        else
            Toast.Show("请稍后...")
        end
    end
end

function UnionRoomPanel.OnStopFollowPlayerBtnClick()
    --Toast.Show("功能暂未开放")
    this.followPlayerId = 0
    this.DirectSendGetTableList(this.pageIndex)
    UIUtil.SetActive(this.StopFollowPlayerBtn, false)
end

function UnionRoomPanel.GetFastEnterTableResponse(data)
    if data.code ~= 0 then
        Toast.Show(UnionManager.ShowError(data.code))
    end
end

function UnionRoomPanel.OnHeadIconBtnClick()
    PanelManager.Open(PanelConfig.UnionPersonalData, UserData.GetUserId(), true)
end

function UnionRoomPanel.OnCreateRoomBtnClick()
    LogError(">> UnionRoomPanel.OnCreateRoomBtnClick")
    local args = {
        type = 1, -- 1创建桌子，2修改桌子
        unionCallback = this.OnDealCreateOrModifyRoom
    }
    PanelManager.Open(PanelConfig.CreateRoom, this.gameType, RoomType.Tea, MoneyType.Gold, args)
end

-- 创建、修改桌子回调
function UnionRoomPanel.OnDealCreateOrModifyRoom(type, args)
    if type == nil or args == nil then
        Toast.Show("参数异常")
        return
    end
    Log(">> OnDealCreateOrModifyRoom", this.curModifyTableId, type, args)
    if type == 1 then
        UnionManager.SendCreateTable(args.gameId, args.playType, args.rules, args.maxRoundCount, args.maxPlayerCount,
            args.baseScore, args.inGold, args.jieSanFenShu, args.note, args.wins, args.consts, args.baoDi, args.feetype,
            args.bigwin, args.per, args.bdPer, args.faceType)
        -- elseif type == 2 then
        --     UnionManager.SendModifyTable(args.gameId, this.curModifyTableId, args.playType, args.rules, args.maxRoundCount,
        --         args.maxPlayerCount, args.baseScore, args.inGold, args.zhuoFei, args.zhuoFeiMin, args.jieSanFenShu)
    end
end

--获取桌子数据返回
---@field trackUser number 被追踪的玩家
function UnionRoomPanel.OnGetTableList(data)
    this.tableDataTotal = data.allCount
    this.pageTotal = math.ceil(this.tableDataTotal / UnionTableCountPerPage)

    if (this.followPlayerId ~= nil and this.followPlayerId ~= 0) and (data.trackUser == nil or data.trackUser == 0) then
        Toast.Show("暂无追踪信息")
    end
    this.followPlayerId = data.trackUser
    if this.followPlayerId ~= nil and this.followPlayerId ~= 0 then
        PanelManager.Close(PanelConfig.UnionFollowPlayer)
        PanelManager.Close(PanelConfig.UnionPartnerMgr)
        UIUtil.SetActive(this.StopFollowPlayerBtn, true)
        if this.tipsFollowPlayerId ~= this.followPlayerId then
            this.tipsFollowPlayerId = this.followPlayerId
            Toast.Show("追踪成功")
        end
    end

    --LogError("<color=aqua>桌子信息 data</color>", data)
    local waitingText = UnionData.IsUnionLeaderOrAdministratorOrObserver() and data.waitting .. "桌" or "***桌"
    local gamingText = UnionData.IsUnionLeaderOrAdministratorOrObserver() and data.gaming .. "桌" or "***桌"
    UIUtil.SetText(this.waiting, --[["等待中：" ..]] waitingText)
    UIUtil.SetText(this.gaming, --[["游戏中：" ..]] gamingText)

    local tempPageIndex = data.pageIndex
    --如果数据是当前第一页，再请求下第二页
    if tempPageIndex == 1 and tempPageIndex < this.pageTotal then
        --由于里面有时间检测，所有可以这里不用考虑时间
        this.SendGetTableList(tempPageIndex + 1)
    end

    local beginIndex = 0

    --创建房间按钮，创建房间按钮放第一个
    -- if UnionData.IsUnionLeaderOrAdministratorOrObserver() then
    --     beginIndex = 1
    --     this.tableDataTotal = this.tableDataTotal + 1
    --     this.tableDataList[1] = { id = 0 }
    -- end

    --缓存数据
    local list = data.list
    if GetTableSize(list) > 0 then
        local startIndex = beginIndex + (tempPageIndex - 1) * UnionTableCountPerPage
        local tempIndex = 0
        local tableData = nil
        local temp = nil
        local playerData = nil
        for i = 1, #data.list do
            temp = data.list[i]
            tempIndex = startIndex + i
            tableData = this.tableDataList[tempIndex]
            if tableData == nil then
                tableData = {}
                this.tableDataList[tempIndex] = tableData
            end
            tableData.id = temp.tId
            tableData.rules = JsonToObj(temp.rules)
            tableData.gameType = temp.gameId
            tableData.baseScore = tonumber(temp.score)
            tableData.inGold = tonumber(temp.inGold)
            tableData.maxJs = temp.maxjs
            tableData.js = temp.js or 0
            tableData.maxUserNum = temp.maxNum
            tableData.rules.expressionNum = temp.per
            tableData.rules.keepBaseNum = temp.bd
            tableData.advanceData = tableData.advanceData or {}
            tableData.advanceData.diFen = temp.score
            tableData.advanceData.enterNum = temp.inGold
            tableData.advanceData.kickNum = tableData.rules.JSFS
            tableData.advanceData.remarkStr = temp.note
            tableData.advanceData.robNum = tableData.rules.qzfs
            tableData.advanceData.allToggle = temp.bigwin == 0 and true or false --1为大赢家 0为所有赢家
            tableData.advanceData.expressionNum = temp.per
            tableData.advanceData.keepBaseNum = temp.bd

            tableData.advanceData.zhunRu = tableData.rules.zr or tableData.rules.ZR
            tableData.advanceData.jieSanFenShu = tableData.rules.JSFS
            tableData.advanceData.baoDi = temp.bd
            tableData.advanceData.note = temp.note
            tableData.advanceData.wins = temp.qj
            tableData.advanceData.costs = temp.zf
            tableData.advanceData.bdPer = temp.bdPer
            tableData.advanceData.faceType = temp.faceType

            tableData.userDatas = {}
            --LogError("服务器玩家数据", temp.players)
            for j = 1, #temp.players do
                playerData = temp.players[j]
                table.insert(tableData.userDatas,
                    { uid = playerData.uId, name = playerData.uN, headIcon = playerData.uH, isOnline = playerData
                    .isOnlie })
            end
        end
    end

    --创建房间按钮，创建房间按钮放最后一个
    --if UnionData.selfRole == UnionRole.Leader or UnionData.selfRole == UnionRole.Admin then
    --    beginIndex = 1
    --    this.tableDataTotal = this.tableDataTotal + 1
    --    this.tableDataList[this.tableDataTotal] = { id = 0 }
    --end

    -- --更新ScrollView的总数据，多余1的是创建房间的数量
    -- if this.lastTableDataTotal ~= this.tableDataTotal then
    --     this.lastTableDataTotal = this.tableDataTotal
    --     this.uiScrollView:Set(this.lastTableDataTotal)
    -- else
    --     --手动更新
    --     this.UpdateItemDisplay()
    -- end
    this.lastTableDataTotal = this.tableDataTotal
    this.uiScrollView:Set(this.lastTableDataTotal)

    --更新Note列表
    this.UpdateNoteItemDisplay(data.newNote)
end

--更新游戏类型菜单
function UnionRoomPanel.OnRefreshGameType(data)
    if data == nil then
        return
    end
    local item = nil
    local isHave = false
    for i = 1, #this.gameMenus do
        item = this.gameMenus[i]
        isHave = item.gameType == 0
        for j = 1, #data do
            if data[j] == item.gameType then
                isHave = true
                break
            end
        end
        UIUtil.SetActive(item.toggle.gameObject, isHave)
    end
end

--================================================================
--
-- pageIdx: 0开始, 服务器从1开始
function UnionRoomPanel.SendGetTableList(pageIndex)
    local time = this.requestTimeDict[pageIndex]
    if time == nil or Time.realtimeSinceStartup > time then
        this.DirectSendGetTableList(pageIndex)
    end
end

--直接请求桌子列表
function UnionRoomPanel.DirectSendGetTableList(pageIndex)
    --可以请求新数据
    this.requestTimeDict[pageIndex] = Time.realtimeSinceStartup + 5
    if pageIndex < 0 then
        pageIndex = 1
    end
    if string.IsNullOrEmpty(this.note) then
        this.note = "0"
    end
    --LogError(this.requestNoteGameType, this.note, pageIndex, this.lastNoteIndexType, this.followPlayerId)
    UnionManager.SendGetTableList(this.requestNoteGameType, this.note, pageIndex, this.lastNoteIndexType,
        this.followPlayerId)
end

--刷新当前的桌子列表，直接刷新
function UnionRoomPanel.RefreshTableList()
    this.DirectSendGetTableList(this.pageIndex)
    --如果还有下一页
    if this.pageIndex < this.pageTotal then
        this.DirectSendGetTableList(this.pageIndex + 1)
    end
end

--初始面板
function UnionRoomPanel.InitPanel()
    -- 设置个人信息
    this.UpdatePersonalInfo()

    -- 设置联盟信息
    local unionInfo = UnionData.GetUnionInfo()
    UIUtil.SetText(this.unionKey, tostring(unionInfo.key))
    UIUtil.SetText(this.unionName, tostring(unionInfo.name))
    -- 权限相关
    UIUtil.SetActive(this.settingBtnGo, UnionData.IsUnionLeader())
    UIUtil.SetActive(this.manageBtnGo, UnionData.IsUnionLeaderOrAdministratorOrObserver())
    UIUtil.SetActive(this.partnerBtnGo, UnionData.IsNotCommonPlayer())
    UIUtil.SetActive(this.StopFollowPlayerBtn, false)
    UIUtil.SetActive(this.createBtnGo, UnionData.IsUnionLeaderOrAdministratorOrObserver())
end

--更新个人信息
function UnionRoomPanel.UpdatePersonalInfo()
    UIUtil.SetText(this.nameText, tostring(UserData.GetName()))
    UIUtil.SetText(this.idText,  "ID:" .. tostring(UserData.GetUserId()))
    UIUtil.SetText(this.fkText, UnionData.IsUnionLeader() and tostring(UserData.GetRoomCard()) or "充足")
    UIUtil.SetText(this.goldText, tostring(UserData.GetGold()))
    Functions.SetHeadImage(this.headImg, UserData.GetHeadUrl())
end

--重置滑动区域
function UnionRoomPanel.ResetScrollView()
    this.uiScrollView:Reset()
end

--重置请求数据，需要把缓存数据清除
function UnionRoomPanel.ResetRequest()
    --
    this.requestTimeDict = {}
    this.tableDataList = {}
    this.pageIndex = 1
    this.pageTotal = 1
    --this.ResetScrollView()
    this.SendGetTableList(this.pageIndex)
end

--更新桌子显示
function UnionRoomPanel.UpdateTableItem(item)
    --LogError("UpdateTableItem")
    local data = this.tableDataList[item.dataIndex]
    if data == nil then
        return
    end
    if data.id == 0 then
        UIUtil.SetActive(item.createRoomBtn, false) --UnionData.IsUnionLeaderOrAdministratorOrObserver())
        UIUtil.SetActive(item.tableInfoTran, false)
    else
        UIUtil.SetActive(item.createRoomBtn, false)
        UIUtil.SetActive(item.tableInfoTran, true)

        item.data = data

        if data.gameType == GameType.PaoDeKuai then
            local playWayConfig = PdkConfig.GetPlayWayConfig(data.rules[PdkRuleType.PlayType])
            if playWayConfig ~= nil then
                item.playWayText.text = playWayConfig.name
            else
                item.playWayText.text = ""
            end
        elseif data.gameType == GameType.Mahjong then
            local playTypeName = Mahjong.GetPlayWayName(data.rules)
            item.playWayText.text = playTypeName
        elseif data.gameType == GameType.ErQiShi then
            EqsConfig.CheckRules(data.rules)
            local playWayConfig = EqsConfig.GetPlayWayConfig(data.rules[EqsRuleType.RType])
            if playWayConfig ~= nil then
                item.playWayText.text = playWayConfig.name
            else
                item.playWayText.text = ""
            end
        elseif data.gameType == GameType.Pin5 then
            local playWayName = Pin5RulePlayTypeName[data.rules[Pin5RuleType.PlayType]]
            local laiZi = data.rules[Pin5RuleType.LaiZi] or 0
            playWayName = laiZi > 1 and "王癞拼十" or "拼十"
            if playWayName ~= nil then
                item.playWayText.text = playWayName
            else
                item.playWayText.text = ""
            end
        elseif data.gameType == GameType.SDB then
            local playWayName = SDB.PlayWayNames[data.rules[SDB.RuleType.PlayWayType]]
            if playWayName ~= nil then
                item.playWayText.text = playWayName
            else
                item.playWayText.text = ""
            end
        elseif data.gameType == GameType.Pin3 then
            local playWayName = Pin3Config.PlayWayNames[1]
            if playWayName ~= nil then
                item.playWayText.text = "拼三张" --playWayName
            else
                item.playWayText.text = ""
            end
        elseif data.gameType == GameType.LYC then
            local playWayName = LYCRulePlayTypeName[data.rules[LYCRuleType.PlayType]]
            item.playWayText.text = playWayName or ""
        elseif data.gameType == GameType.TP then
            local playWayName = TpConfig.GetPlayWayNameByRule(data.rules)
            item.playWayText.text = playWayName or ""
        end

        local gameName = ""
        if data.gameType ~= GameType.Pin5 then
            --[[item.gameNameText.text]]
            gameName = tostring(Functions.GetGameNameText(data.gameType))
        else
            --[[item.gameNameText.text]]
            gameName = data.rules[Pin5RuleType.FanBeiRule] == 4 and "牛几几倍" or "普通牛"
        end

        if gameName ~= "" then
            gameName = "(" .. gameName .. ")"
        end

        if data.maxJs ~= nil then
            if data.maxJs > 0 then
                item.juShuText.text = "局数:" .. string.format("%d/%d", data.js, data.maxJs) .. gameName
            else
                item.juShuText.text = "局数:无限局" .. gameName
            end
        else
            item.juShuText.text = "--"
        end

        local name = "底分:"
        local score = tostring(data.baseScore)
        if data.gameType == GameType.TP then
            name = "前注:"
            score = tostring(data.rules.qz)
        end
        item.baseScoreText.text = name .. score

        --LogError(item.index, item.dataIndex, data.gameType, data.maxUserNum)

        --根据游戏类型(data.gameType)处理桌子样式
        local maxUserNum = data.maxUserNum
        local deskSeats = item.seatDict[data.gameType]
        local deskSeatItem = nil
        if deskSeats ~= nil then
            deskSeatItem = deskSeats[maxUserNum]
            if item.lastDeskSeats ~= deskSeats then
                if item.lastDeskSeats ~= nil then
                    UIUtil.SetActive(item.lastDeskSeats.transform, false)
                end
                item.lastDeskSeats = deskSeats
                UIUtil.SetActive(item.lastDeskSeats.transform, true)
            end
        else
            LogError(">> 没有找到对应座位节点", data.gameType)
        end
        if deskSeatItem ~= nil then
            if item.lastDeskSeatItem ~= deskSeatItem then
                if item.lastDeskSeatItem ~= nil then
                    UIUtil.SetActive(item.lastDeskSeatItem.transform, false)
                end
                item.lastDeskSeatItem = deskSeatItem
                UIUtil.SetActive(item.lastDeskSeatItem.transform, true)
            end
            --显示
            local userData = nil
            local seatItem = nil
            --LogError("用户数据", data.userDatas)
            for i = 1, maxUserNum do
                userData = data.userDatas[i]
                seatItem = deskSeatItem[i]
                if userData ~= nil then
                    if seatItem.headImg == nil then
                        this.CreateSeatPlayerItem(seatItem)
                    end
                    UIUtil.SetActive(seatItem.gameObject, true)
                    Functions.SetHeadImage(seatItem.headImg, userData.headIcon)
                    seatItem.nameText.text = tostring(userData.name)

                    --处理头像是否在线
                    if userData.isOnline ~= true then
                        if seatItem.isGray ~= true then
                            seatItem.isGray = true
                            UIUtil.SetImageColor(seatItem.headImg, 0.392, 0.392, 0.392)
                            seatItem.nameText.color = Color_Txt_Gray
                            UIUtil.SetActive(seatItem.offlineGo, true)
                        end
                    else
                        if seatItem.isGray == true then
                            seatItem.isGray = false
                            UIUtil.SetImageColor(seatItem.headImg, 1, 1, 1)
                            seatItem.nameText.color = Color_Txt_Normal
                            UIUtil.SetActive(seatItem.offlineGo, false)
                        end
                    end
                else
                    UIUtil.SetActive(seatItem.gameObject, false)
                end
            end
        else
            LogError(">> 没有找到对应数量座位节点", data.gameType, maxUserNum)
        end
    end
end

--创建座位玩家
function UnionRoomPanel.CreateSeatPlayerItem(seatItem)
    seatItem.playerGo = CreateGO(this.playerItemPrefab, seatItem.transform)
    local temp = seatItem.playerGo.transform
    temp.localScale = Vector3.one
    temp.localPosition = Vector2.zero
    seatItem.headImg = temp:Find("Head/Mask/HeadIcon"):GetComponent(TypeImage)
    seatItem.nameText = temp:Find("Name"):GetComponent(TypeText)
    seatItem.offlineGo = temp:Find("Offline").gameObject
end

function UnionRoomPanel.OnGameUpdateRedPoint()
    local val = RedPointMgr.GetRedPointByValue(RedPointType.UnionApplyJoin, UnionData.curUnionId)
    UIUtil.SetActive(this.redPointTrans[RedPointType.UnionApplyJoin], val ~= nil)
    val = RedPointMgr.GetRedPointByValue(RedPointType.ServiceChatMessage, UnionData.curUnionId)
    UIUtil.SetActive(this.redPointTrans[RedPointType.ServiceChatMessage], val ~= nil)
end

function UnionRoomPanel.OnGameUpdateUserInfo()
    this.UpdatePersonalInfo()
end

--删除桌子后刷新桌子
function UnionRoomPanel.OnUnionDeleteTableRefresh()
    this.RefreshTableList()
end

--更新联盟名称
function UnionRoomPanel.OnUnionUpdateName()
    local unionInfo = UnionData.GetUnionInfo()
    UIUtil.SetText(this.unionName, tostring(unionInfo.name))
end

---追钟玩家
function UnionRoomPanel.OnUnionFollowPlayer(playerId)
    this.followPlayerId = playerId
    this.tipsFollowPlayerId = nil
    UnionManager.SendGetTableList(this.requestNoteGameType, this.note, 1, this.lastNoteIndexType, playerId)
end

function UnionRoomPanel.OnUnionUpdateBackground()
    this.CheckUpdateBackground()
end

--================================================================
--
function UnionRoomPanel.UpdateItemDisplay()
    if this.uiScrollView.items == nil then
        return
    end
    local item = nil
    for i = 1, #this.uiScrollView.items do
        item = this.uiScrollView.items[i]
        if item.dataIndex > 0 then
            this.UpdateTableItem(item)
        end
    end
end

--桌子配置
local DeskConfigs = {
    [GameType.Mahjong] = { 2, 3, 4 },
    [GameType.PaoDeKuai] = { 2, 3, 4 },
    [GameType.Pin5] = { 6, 8, 10 },
    [GameType.Pin3] = { 4, 6, 8, 10 },
    [GameType.ErQiShi] = { 2, 3, 4 },
    [GameType.TP] = { 6, 7, 8, 9 },
    [GameType.LYC] = { 6, 8, 10 },
}

--
function UnionRoomPanel.OnSetItemCallback(item)
    local transform = item.transform
    item.createRoomBtn = transform:Find("TableCreateBtn")
    item.tableInfoTran = transform:Find("TableInfo")

    item.nameGo = item.tableInfoTran:Find("Name").gameObject
    item.playWayText = item.tableInfoTran:Find("Name/Text"):GetComponent(TypeText)
    item.gameNameText = item.tableInfoTran:Find("GameName"):GetComponent(TypeText)
    item.juShuText = item.tableInfoTran:Find("JuShuText"):GetComponent(TypeText)
    item.baseScoreText = item.tableInfoTran:Find("ScoreText"):GetComponent(TypeText)
    item.joinGameBtn = item.tableInfoTran:Find("BgBtn").gameObject

    this:AddOnClick(item.nameGo, function()
        this.OnItemNameClick(item)
    end)

    this:AddOnClick(item.joinGameBtn, function()
        this.OnItemJoinClick(item)
    end)

    this:AddOnClick(item.createRoomBtn, this.OnCreateRoomBtnClick)

    item.seatDict = {}

    local userSeatTran = nil
    local deskSeatItem = nil
    local desk = nil
    local maxUserNum = 0
    --游戏类型
    for k, v in pairs(DeskConfigs) do
        desk = item.tableInfoTran:Find(tostring(k))
        if desk ~= nil then
            local deskSeats = { transform = desk }
            item.seatDict[k] = deskSeats

            for i = 1, #v do
                maxUserNum = v[i]
                userSeatTran = desk:Find("User" .. tostring(maxUserNum))
                if userSeatTran ~= nil then
                    deskSeatItem = {}
                    deskSeats[maxUserNum] = deskSeatItem
                    --
                    deskSeatItem.transform = userSeatTran
                    for j = 1, maxUserNum do
                        local seatObj = {}
                        deskSeatItem[j] = seatObj
                        --
                        seatObj.transform = userSeatTran:Find("Seat" .. tostring(j))
                        seatObj.gameObject = seatObj.transform.gameObject
                    end
                end
            end
        end
    end
end

function UnionRoomPanel.OnItemNameClick(item)
    local data = item.data
    this.curModifyTableId = data.id
    --LogError("桌子数据", data)
    PanelManager.Open(PanelConfig.UnionDeskDetails, data)
end

function UnionRoomPanel.OnItemJoinClick(item)
    if Time.realtimeSinceStartup - this.deskClickTime > 2 then
        this.deskClickTime = Time.realtimeSinceStartup
        local data = item.data
        Functions.ShowHeadIconTips(function()
            UnionManager.SendJoinTable(data.gameType, data.id)
        end)
    else
        Toast.Show("请稍后...")
    end
end

--
function UnionRoomPanel.OnUpdateItemCallback(item)
    this.UpdateTableItem(item)
end

--
function UnionRoomPanel.OnNeedPageCallback(pageIndex)
    this.pageIndex = pageIndex
    this.SendGetTableList(this.pageIndex)
    --如果还有下一页
    if this.pageIndex < this.pageTotal then
        this.SendGetTableList(this.pageIndex + 1)
    end
    --LogError(">> UnionRoomPanel.OnNeedPageCallback > ", pageIndex)
end

--================================================================
--
--启动请求刷新的Timer
function UnionRoomPanel.StartRefreshTimer()
    if this.refreshTimer == nil then
        this.refreshTimer = Timing.New(this.OnRefreshTimer, 1)
    end
    this.refreshTimer:Start()
end

--
--停止请求刷新的Timer
function UnionRoomPanel.StopRefreshTimer()
    if this.refreshTimer ~= nil then
        this.refreshTimer:Stop()
    end
end

--
--处理请求刷新的Timer
function UnionRoomPanel.OnRefreshTimer()
    this.SendGetTableList(this.pageIndex)
    --如果还有下一页
    if this.pageIndex < this.pageTotal then
        this.SendGetTableList(this.pageIndex + 1)
    end
end

--================================================================
--
--更新备注显示项显示
function UnionRoomPanel.UpdateNoteItemDisplay(list)
    --LogError("=============================================")
    --LogError(list)
    this.isRequestNoteData = true
    if list == nil then
        list = {}
    end

    local selectItem = nil
    local length = #list
    local item = nil
    local noteData = nil
    local index = 0
    local gameConfig = nil
    for i = 1, length do
        noteData = list[i]
        --筛选游戏
        gameConfig = GameConfig[noteData.game]
        if gameConfig ~= nil and gameConfig.isOn then
            if this.gameType == 0 or noteData.game == this.gameType then
                local noteList = noteData.note
                for j = 1, #noteList do
                    index = index + 1
                    item = this.noteItems[index]
                    if item == nil then
                        item = this.CreateNoteItem(index)
                    end
                    this.SetNoteItem(item, noteData, j)
                    if this.lastNoteGameType == noteData.game and this.lastNoteIndexType == noteData.gameType and this.lastNoteName == item.noteName then
                        selectItem = item
                    end
                end
            end
        end
    end

    for i = index + 1, #this.noteItems do
        item = this.noteItems[i]
        if item.data ~= nil then
            item.data = nil
            UIUtil.SetActive(item.gameObject, false)
        end
    end

    --处理选中
    if selectItem == nil then
        selectItem = this.allNoteItem
    end

    if selectItem ~= nil then
        selectItem.toggle.isOn = false
        selectItem.toggle.isOn = true
    end
end

function UnionRoomPanel.SetNoteItem(item, data, noteIndex)
    item.data = data
    -- if data.gameType ~= nil and data.gameType ~= 0 then
    --     if data.gameType == Mahjong.NoteType.ChengDu then
    --         data.gameName = "血战到底"
    --     elseif data.gameType == Mahjong.NoteType.YaoJi then
    --         data.gameName = "幺鸡麻将"
    --     end
    -- end
    -- if data.gameName == "拼十" then
    --     data.gameName = "明牌抢庄"
    -- elseif data.gameName == "拼三张" then
    --     data.gameName = "炸金花"
    -- end
    UIUtil.SetActive(item.gameObject, true)
    item.noteName = data.note[noteIndex]
    item.label.text = item.noteName
    item.label2.text = item.noteName
end

function UnionRoomPanel.OnNoteItemValueChanged(item, isOn)
    if isOn then
        --LogError("OnNoteItemValueChanged", isOn, item.gameObject.name)
        local data = item.data
        local isRequest = false
        if this.gameType ~= this.lastUpdateGameType or this.lastNoteGameType ~= data.game or this.lastNoteIndexType ~= data.gameType or this.lastNoteName ~= item.noteName then
            isRequest = true
        end

        if this.gameType == 0 then
            this.requestNoteGameType = data.game or GameType.None
        else
            this.requestNoteGameType = this.gameType
        end
        --用于记录当前的玩法对应的游戏类型ID
        this.lastNoteGameType = data.game
        this.lastNoteIndexType = data.gameType
        this.lastNoteName = item.noteName
        this.note = this.lastNoteName
        this.lastUpdateGameType = this.gameType

        if isRequest then
            --LogError(">> OnNoteItemValueChanged > SendGetTableList", this.requestNoteGameType, this.note, this.pageIndex, this.lastNoteIndexType)
            UnionManager.SendGetTableList(this.requestNoteGameType, this.note, this.pageIndex, this.lastNoteIndexType)
        end
    end
end

--创建备注显示项
function UnionRoomPanel.CreateNoteItem(index)
    local item = {}
    table.insert(this.noteItems, item)
    item.gameObject = CreateGO(this.noteItemPrefab, this.noteContent, tostring(index))
    item.transform = item.gameObject.transform
    item.data = nil
    item.noteName = nil
    item.toggle = item.gameObject:GetComponent(TypeToggle)
    item.label = item.transform:Find("Text"):GetComponent(TypeText)
    item.label2 = item.transform:Find("Text2"):GetComponent(TypeText)
    item.toggle.onValueChanged:AddListener(function(isOn) this.OnNoteItemValueChanged(item, isOn) end)
    return item
end

--隐藏所有的备注节点
function UnionRoomPanel.HideAllNoteItem()
    local item = nil
    for i = 1, #this.noteItems do
        item = this.noteItems[i]
        if item.data == nil then
            item.data = nil
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

--更新背景
function UnionRoomPanel.CheckUpdateBackground()
    -- local sprite = ResourcesManager.LoadSpriteBySynch("base/bg-union", UnionData.GetBgAssetName())
    local sprite = ResourcesManager.LoadSpriteBySynch("base/bg-union-1")
    if sprite ~= nil then
        this.Background.sprite = sprite
        Functions.SetBackgroundAdaptation(this.Background)
    end
end
