ClubRoomPanel = ClassPanel("ClubRoomPanel")
local this = ClubRoomPanel

--top
ClubRoomPanel.headImg = nil
ClubRoomPanel.sex1Tran = nil
ClubRoomPanel.sex0Tran = nil
ClubRoomPanel.nameText = nil
ClubRoomPanel.idText = nil
ClubRoomPanel.fkText = nil
ClubRoomPanel.goldText = nil
ClubRoomPanel.partnerBtn = nil
ClubRoomPanel.luckyValueBtn = nil
ClubRoomPanel.noticeBtn = nil
ClubRoomPanel.backBtn = nil
ClubRoomPanel.clubKey = nil
ClubRoomPanel.clubName = nil

--left
--key:游戏类型(0表示所有游戏)，value:游戏按钮
ClubRoomPanel.gameToggles = nil

--bottom
ClubRoomPanel.settingBtn = nil
ClubRoomPanel.memberBtn = nil
ClubRoomPanel.luckyValueManageBtn = nil
ClubRoomPanel.recordBtn = nil
ClubRoomPanel.myCardBtn = nil
ClubRoomPanel.giveLuckyValueBtn = nil
ClubRoomPanel.goldGameBtn = nil
ClubRoomPanel.fkGameBtn = nil

--center
--key:索引， value：桌子组件table
ClubRoomPanel.tableGroups = nil
ClubRoomPanel.tableScrollExt = nil

--当前修改桌子Id
ClubRoomPanel.curModifyTableId = 0
--当前桌子对应的游戏
ClubRoomPanel.curGameType = GameType.None
--当前桌子对应的页码
ClubRoomPanel.curGetPage = 0
--上一次获取桌子数据时间
ClubRoomPanel.lastGetTableListTime = 0
--定时获取房间列表句柄
ClubRoomPanel.getRoomListHandle = nil

--红点存储
ClubRoomPanel.redPointTrans = nil
function ClubRoomPanel:Awake()
    this = self
    this.redPointTrans = {}
    --top
    local top = this:Find("Content/Top")
    this.headImg = top:Find("UserInfo/Head/Mask/HeadIcon"):GetComponent(TypeImage)
    this.sex0Tran = top:Find("UserInfo/Sex0")
    this.sex1Tran = top:Find("UserInfo/Sex1")
    this.nameText = top:Find("UserInfo/NameText")
    this.idText = top:Find("UserInfo/IdText")
    this.fkText = top:Find("UserInfo/FkInfo/Num")
    this.goldText = top:Find("UserInfo/GoldInfo/Num")
    this.partnerBtn = top:Find("PartnerBtn")
    this.luckyValueBtn = top:Find("LuckyValueBtn")
    this.noticeBtn = top:Find("NoticeBtn")
    this.backBtn = top:Find("BackBtn")

    this.clubKey = top:Find("ClubKey")
    this.clubName = top:Find("ClubName")

    --bottom
    local bottomTran = this:Find("Content/Bottom")
    this.settingBtn = bottomTran:Find("ListBtns/SettingBtn")
    this.memberBtn = bottomTran:Find("ListBtns/MemberBtn")
    this.luckyValueManageBtn = bottomTran:Find("ListBtns/LuckyValueManageBtn")
    this.recordBtn = bottomTran:Find("ListBtns/RecordBtn")
    this.blackRoomBtn = bottomTran:Find("ListBtns/BlackRoomBtn")
    this.myCardBtn = bottomTran:Find("ListBtns/MyCardBtn")
    this.giveLuckyValueBtn = bottomTran:Find("GiveLuckyValueBtn")
    this.goldGameBtn = bottomTran:Find("ListBtns/ChangCiBtns/GoldGameBtn")
    this.fkGameBtn = bottomTran:Find("ListBtns/ChangCiBtns/FkGameBtn")
    this.serviceBtn = bottomTran:Find("ListBtns/ServiceBtn")

    this.redPointTrans[RedPointType.ClubApplyJoin] = this.memberBtn:Find("RedPoint")
    this.redPointTrans[RedPointType.ClubServiceChatMessage] = this.serviceBtn:Find("RedPoint")

    --left
    local toggles = this:Find("Content/Left/GameList/Viewport/Content")
    this.gameToggles = {}
    this.gameToggles[0] = toggles:Find("0")
    for _, gameType in pairs(GameType) do
        this.gameToggles[gameType] = toggles:Find(tostring(gameType))
    end

    --center
    this.tableScrollExt = this:Find("Content/Center/TableList"):GetComponent("ScrollRectExtension")
    local content = this:Find("Content/Center/TableList/Viewport/Content")
    local child = content.childCount
    this.tableGroups = {}
    local group = nil
    for i = 0, child - 1 do
        group = this.GetTableGroupFromTableTran(content:GetChild(i), i + 1)
        this.tableGroups[group.transform] = group
    end
end

function ClubRoomPanel:OnOpened()
    this.InitPanel()
    this.OnClickGameToggle(GameType.None)
    BaseTcpApi.SendEnterModule(ModuleType.Club)

    Scheduler.unscheduleGlobal(this.getRoomListHandle)
    this.getRoomListHandle = Scheduler.scheduleGlobal(function()
        this.SendGetTableList(this.curGetPage, true)
    end, 5)

    AddMsg(CMD.Game.UpdateRedPointTips, this.OnGameUpdateRedPoint)
    AddMsg(CMD.Game.UpdateMoney, this.OnGameUpdateUserInfo)

    this.OnGameUpdateRedPoint()
    ClubManager.SendGetClubInfo(ClubData.curClubId)
end

function ClubRoomPanel:OnClosed()
    Scheduler.unscheduleGlobal(this.getRoomListHandle)
    RemoveMsg(CMD.Game.UpdateRedPointTips, this.OnGameUpdateRedPoint)
    RemoveMsg(CMD.Game.UpdateMoney, this.OnGameUpdateUserInfo)
    ClubManager.SendGetClubList()
    Log("====>ClubRoomPanel:OnClosed")
end

function ClubRoomPanel.InitPanel()
    this:AddOnClick(this.partnerBtn, this.OnClickPartnerBtn)
    this:AddOnClick(this.luckyValueBtn, this.OnClickLuckyValueBtn)
    this:AddOnClick(this.noticeBtn, this.OnClickNoticeBtn)
    this:AddOnClick(this.backBtn, this.OnClickCloseBtn)

    this:AddOnClick(this.settingBtn, this.OnClickSettingBtn)
    this:AddOnClick(this.memberBtn, this.OnClickMemberBtn)
    this:AddOnClick(this.luckyValueManageBtn, this.OnClickLuckyValueManageBtn)
    this:AddOnClick(this.recordBtn, this.OnClickRecordBtn)
    this:AddOnClick(this.blackRoomBtn, this.OnClickBlackRoomBtn)
    this:AddOnClick(this.serviceBtn, this.OnClickServiceBtn)
    this:AddOnClick(this.myCardBtn, this.OnClickMyCardBtn)
    this:AddOnClick(this.giveLuckyValueBtn, this.OnClickGiveLuckyValueBtn)
    this:AddOnClick(this.goldGameBtn, this.OnClickChangeTableTypeBtn)
    this:AddOnClick(this.fkGameBtn, this.OnClickChangeTableTypeBtn)

    for gameType, toggle in pairs(this.gameToggles) do
        local gt = gameType
        this:AddOnToggle(toggle, function(isOn)
            if isOn then
                this.OnClickGameToggle(gt)
            end
        end)
    end

    --设置个人信息
    this.UpdatePersonalInfo()

    this.UpdateTitle()

    --权限相关
    UIUtil.SetActive(this.settingBtn, ClubData.selfRole == ClubRole.Admin or ClubData.selfRole == ClubRole.Boss)
    UIUtil.SetActive(this.partnerBtn, ClubData.selfRole == ClubRole.Partner or ClubData.selfRole == ClubRole.Boss)
    --UIUtil.SetActive(this.fkGameBtn, ClubData.curTableMoneyType == MoneyType.Gold)
    --UIUtil.SetActive(this.goldGameBtn, ClubData.curTableMoneyType == MoneyType.Fangka)
    UIUtil.SetActive(this.blackRoomBtn, ClubData.selfRole == ClubRole.Admin or ClubData.selfRole == ClubRole.Boss)
end

function ClubRoomPanel.UpdateTitle()
    --设置联盟信息
    local clubInfo = ClubData.GetClubInfo()
    if ClubData.curTableMoneyType == MoneyType.Gold then
        UIUtil.SetText(this.clubKey, tostring(clubInfo.key))--.."(比赛场)")
    elseif ClubData.curTableMoneyType == MoneyType.Fangka then
        UIUtil.SetText(this.clubKey, tostring(clubInfo.key))--.."(普通场)")
    else
        UIUtil.SetText(this.clubKey, tostring(clubInfo.key))
    end
    UIUtil.SetText(this.clubName, tostring(clubInfo.clubName))
end

function ClubRoomPanel.UpdatePersonalInfo()
    UIUtil.SetText(this.nameText, tostring(UserData.GetName()))
    UIUtil.SetText(this.idText, tostring(UserData.GetUserId()))
    UIUtil.SetText(this.fkText, tostring(UserData.GetRoomCard()))
    UIUtil.SetText(this.goldText, tostring(UserData.GetGold()))
    Functions.SetHeadImage(this.headImg, UserData.GetHeadUrl())
end

function ClubRoomPanel.OnClickGameToggle(gameType)
    this.curGameType = gameType
    this.curGetPage = 0
    this.InitScrollExt()
    this.SendGetTableList(0)
end

function ClubRoomPanel.InitScrollExt()
    this.tableScrollExt:SetMaxDataCount(0)
    this.tableScrollExt:InitItems()
    this.tableScrollExt.onUpdateItemAction = this.OnUpdateTableItem
    this.tableScrollExt.onGetNextPageDataAction = this.SendGetTableList
    this.tableScrollExt.onGetLastPageDataAction = this.SendGetTableList
end

--获取桌子结构
function ClubRoomPanel.GetTableGroupFromTableTran(tableTran, idx)
    if tableTran ~= nil then
        local group = {}
        tableTran.gameObject.name = tostring(idx)
        group.createRoomBtn = tableTran:Find("TableCreateBtn")
        UIUtil.SetActive(group.createRoomBtn, false)

        group.tableInfoTran = tableTran:Find("TableInfo")
        UIUtil.SetActive(group.tableInfoTran, true)

        group.idxText = group.tableInfoTran:Find("Idx/Text")
        UIUtil.SetText(group.idxText, tostring(idx))
        group.gameNameText = group.tableInfoTran:Find("GameName")
        group.juShuText = group.tableInfoTran:Find("JuShuText")
        group.changCiNameText = group.tableInfoTran:Find("ChangCiName")
        group.baseScoreText = group.tableInfoTran:Find("BaseScore/Text")
        group.ruleBtn = group.tableInfoTran:Find("RuleBtn")
        group.joinGameBtn = group.tableInfoTran:Find("BgBtn")
        group.texts = {}
        group.texts[1] = group.tableInfoTran:Find("Texts/Text1")
        group.texts[2] = group.tableInfoTran:Find("Texts/Text2")
        group.texts[3] = group.tableInfoTran:Find("Texts/Text3")
        group.seats = {}

        local userSeatTran = nil
        for maxUserNum = 2, 10 do
            userSeatTran = group.tableInfoTran:Find("User" .. tostring(maxUserNum))
            if userSeatTran ~= nil then
                group.seats[maxUserNum] = {}
                group.seats[maxUserNum].transform = userSeatTran
                for i = 1, maxUserNum do
                    group.seats[maxUserNum][i] = {}
                    group.seats[maxUserNum][i].transform = userSeatTran:Find("Seat" .. tostring(i))
                    group.seats[maxUserNum][i].headImg = group.seats[maxUserNum][i].transform:Find("Head/Mask/HeadIcon"):GetComponent(TypeImage)
                    group.seats[maxUserNum][i].nameText = group.seats[maxUserNum][i].transform:Find("Name")
                end
            end
        end
        group.transform = tableTran
        return group
    end
    return nil
end

--pageIdx: 0开始, 服务器从1开始
function ClubRoomPanel.SendGetTableList(pageIdx, isTimerGet)
    local isGet = true
    if isTimerGet ~= nil and isTimerGet == true then
        if this.lastGetTableListTime <= 1000 then
            isGet = true
        elseif os.time() - this.lastGetTableListTime >= 5 then
            isGet = true
        else
            isGet = false
        end
    else
        isGet = true
        this.lastGetTableListTime = os.time()
    end
    if isGet then
        this.curGetPage = pageIdx
        if pageIdx < 0 then
            pageIdx = 1
        else
            pageIdx = pageIdx + 1
        end
        ClubManager.SendGetTableList(this.curGameType, pageIdx)
    end
end

function ClubRoomPanel.OnUpdateTableItem(item, idx)
    local itemGroup = this.tableGroups[item]
    local itemData = ClubData.GetTableItem(idx + 1)
    if itemGroup ~= nil and itemData ~= nil then
        UIUtil.SetActive(itemGroup.createRoomBtn, false)
        UIUtil.SetActive(itemGroup.tableInfoTran, true)
        this:AddOnClick(itemGroup.joinGameBtn, function()
            Functions.ShowHeadIconTips(function()
                ClubManager.SendJoinTable(itemData.gameType, itemData.id)
            end)
        end)
        this:AddOnClick(itemGroup.ruleBtn, function()
            this.curModifyTableId = itemData.id
            PanelManager.Open(PanelConfig.ClubRule, itemData.id, itemData.gameType, itemData.rules)
        end)
        --文字显示
        if true then
            UIUtil.SetText(itemGroup.idxText, tostring(idx + 1))
            if itemData.maxJs ~= nil then
                if itemData.maxJs > 0 then
                    UIUtil.SetText(itemGroup.juShuText, tostring(itemData.maxJs).."局")
                else   
                    UIUtil.SetText(itemGroup.juShuText, "无限局")
                end
            else
                UIUtil.SetText(itemGroup.juShuText, "--")
            end
            if itemData.gameType == GameType.PaoDeKuai then
                UIUtil.SetText(itemGroup.gameNameText, tostring(Functions.GetGameNameText(itemData.gameType)))
                UIUtil.SetText(itemGroup.texts[1], "黑桃三先出")
                UIUtil.SetText(itemGroup.texts[2], "底分:" .. tostring(itemData.baseScore))
                UIUtil.SetActive(itemGroup.texts[1], true)
                UIUtil.SetActive(itemGroup.texts[2], true)
                UIUtil.SetActive(itemGroup.texts[3], false)
            elseif itemData.gameType == GameType.Mahjong then
                local playTypeName = Mahjong.PlayWayNames[itemData.rules[Mahjong.RuleType.PlayWayType]]
                local tingNum = itemData.rules[Mahjong.RuleType.TingTotal]
                if tingNum ~= nil then
                    UIUtil.SetText(itemGroup.gameNameText, tostring(playTypeName) .. "(" .. tostring(tingNum) .. "听用)")
                else
                    UIUtil.SetText(itemGroup.gameNameText, tostring(playTypeName))
                end
                UIUtil.SetText(itemGroup.texts[1], Functions.TernaryOperator(itemData.rules[Mahjong.RuleType.HuType] == 0, "点炮胡", "自摸胡"))
                UIUtil.SetText(itemGroup.texts[2], "底分:" .. tostring(itemData.baseScore))
                UIUtil.SetActive(itemGroup.texts[1], true)
                UIUtil.SetActive(itemGroup.texts[2], true)
                UIUtil.SetActive(itemGroup.texts[3], false)

                if ClubData.curTableMoneyType == MoneyType.Fangka then
                    UIUtil.SetText(itemGroup.texts[2], "底分:1")
                end
            elseif  itemData.gameType == GameType.ErQiShi then
            end
        end

        --头像处理
        if true then
            local maxUserNum = itemData.maxUserNum
            local seats = nil
            for maxNum, s in pairs(itemGroup.seats) do
                UIUtil.SetActive(s.transform, maxNum == maxUserNum)
                if maxNum == maxUserNum then
                    seats = s
                end
            end
            if seats ~= nil then
                local userInfo = nil
                for i = 1, maxUserNum do
                    UIUtil.SetActive(seats[i].transform, true)
                    userInfo = itemData.userInfos[i]
                    if userInfo ~= nil then
                        Functions.SetHeadImage(seats[i].headImg, userInfo.headIcon)
                        UIUtil.SetText(seats[i].nameText, tostring(userInfo.name))

                        UIUtil.SetActive(seats[i].headImg.transform, true)
                    else
                        UIUtil.SetActive(seats[i].headImg.transform, false)
                        UIUtil.SetText(seats[i].nameText, "")
                    end
                end
            else
                Log("没有找到最大人数对应座位")
            end
        end
    else
        if itemGroup ~= nil and idx == ClubData.totalTableCount then
            UIUtil.SetActive(itemGroup.createRoomBtn, ClubData.selfRole == ClubRole.Boss)
            UIUtil.SetActive(itemGroup.tableInfoTran, false)
            this:AddOnClick(itemGroup.createRoomBtn, this.OnClickCreateRoomBtn)
        else
            UIUtil.SetActive(itemGroup.createRoomBtn, false)
            UIUtil.SetActive(itemGroup.tableInfoTran, false)
        end
    end
end

function ClubRoomPanel.UpdateTableList()
    if ClubData.selfRole == ClubRole.Boss then
        this.tableScrollExt:SetMaxDataCount(ClubData.totalTableCount + 1)
    else
        this.tableScrollExt:SetMaxDataCount(ClubData.totalTableCount)
    end
    this.tableScrollExt:UpdateAllItems()
end

function ClubRoomPanel.OnClickPartnerBtn()
    PanelManager.Open(PanelConfig.ClubPartner)
end

function ClubRoomPanel.OnClickLuckyValueBtn()
    PanelManager.Open(PanelConfig.EnterLuckyValuePool,
    GroupType.Club, ClubData.curClubId,
    ClubData.selfRole == ClubRole.Boss or ClubData.selfRole == ClubRole.Partner,
    ClubData.isOpenYinSi)
end

function ClubRoomPanel.OnClickNoticeBtn()
    PanelManager.Open(PanelConfig.ClubNotice)
end

function ClubRoomPanel.OnClickCloseBtn()
    PanelManager.Close(PanelConfig.ClubRoom)
end

function ClubRoomPanel.OnClickSettingBtn()
    PanelManager.Open(PanelConfig.ClubSetting)
end

function ClubRoomPanel.OnClickMemberBtn()
    PanelManager.Open(PanelConfig.ClubMember)
end

function ClubRoomPanel.OnClickLuckyValueManageBtn()
    if ClubData.selfRole == ClubRole.Member then
        PanelManager.Open(PanelConfig.ClubPersonalData, UserData.GetUserId())
    else
        PanelManager.Open(PanelConfig.ClubLuckyValueManage)
    end
end

function ClubRoomPanel.OnClickRecordBtn()
    PanelManager.Open(PanelConfig.Record, RoomType.Club, ClubData.curClubId, ClubData.isOpenYinSi)
end

function ClubRoomPanel.OnClickBlackRoomBtn()
    PanelManager.Open(PanelConfig.ClubBlackRoom)
end

function ClubRoomPanel.OnClickMyCardBtn()
    PanelManager.Open(PanelConfig.ClubMyCard, UserData.GetUserId())
end

function ClubRoomPanel.OnClickServiceBtn()
    PanelManager.Open(PanelConfig.ServiceChat, 2, ClubData.curClubId)
end

function ClubRoomPanel.OnClickGiveLuckyValueBtn()
    Functions.ShowHeadIconTips(function()
        PanelManager.Open(PanelConfig.DonateLuckyValue, GroupType.Club, ClubData.curClubId)
    end)
end

function ClubRoomPanel.OnClickCreateRoomBtn()
    local args = {
        type = 1, --1创建桌子，2修改桌子
        clubCallback = this.OnDealCreateOrModifyRoom
    }
    PanelManager.Open(PanelConfig.CreateRoom, this.curGameType, RoomType.Club, ClubData.curTableMoneyType, args)
end

--点击切换房间类型按钮
local lastClickChangeTableTypeBtnTime = 0
function ClubRoomPanel.OnClickChangeTableTypeBtn()
    local waitTime = 5
    local now = os.time()
    if now - lastClickChangeTableTypeBtnTime <= waitTime then
        Toast.Show("切换太频繁，"..tostring(waitTime - (now - lastClickChangeTableTypeBtnTime) + 1).."秒后再试", 0.1)
        return 
    end
    lastClickChangeTableTypeBtnTime = now
    ClubData.curTableMoneyType = Functions.TernaryOperator(ClubData.curTableMoneyType == MoneyType.Fangka, MoneyType.Gold, MoneyType.Fangka)
    UIUtil.SetActive(this.fkGameBtn, ClubData.curTableMoneyType == MoneyType.Gold)
    UIUtil.SetActive(this.goldGameBtn, ClubData.curTableMoneyType == MoneyType.Fangka)
    this.SendGetTableList(0)
    this.UpdateTitle()
end

--创建、修改桌子回调
function ClubRoomPanel.OnDealCreateOrModifyRoom(type, args)
    if type == nil or args == nil then
        Toast.Show("参数异常")
        return
    end
    Log("OnDealCreateOrModifyRoom", this.curModifyTableId, type, args)
    if type == 1 then
        ClubManager.SendCreateTable(
        args.gameId,
        args.playType,
        args.rules,
        args.maxRoundCount,
        args.maxPlayerCount,
        args.baseScore,
        args.inGold,
        args.configId
        )
    elseif type == 2 then
        ClubManager.SendModifyTable(
        args.gameId,
        this.curModifyTableId,
        args.playType,
        args.rules,
        args.maxRoundCount,
        args.maxPlayerCount,
        args.baseScore,
        args.inGold,
        args.configId
        )
    end
end

function ClubRoomPanel.OnGameUpdateRedPoint()
    local val = RedPointMgr.GetRedPointByValue(RedPointType.ClubApplyJoin, ClubData.curClubId)
    UIUtil.SetActive(this.redPointTrans[RedPointType.ClubApplyJoin], val ~= nil)
    val = RedPointMgr.GetRedPointByValue(RedPointType.ClubServiceChatMessage, ClubData.curClubId)
    UIUtil.SetActive(this.redPointTrans[RedPointType.ClubServiceChatMessage], val ~= nil)
end

function ClubRoomPanel.OnGameUpdateUserInfo()
    this.UpdatePersonalInfo()
end