LobbyPanel = ClassPanel("LobbyPanel")

local this = LobbyPanel
this.bindTips = "重装游戏或重启手机，游客登录会生成新账号。为了保证账号财产安全，请务必绑定手机和修改昵称，然后使用手机号登录。"

--红点存储
LobbyPanel.redPointTrans = nil
function LobbyPanel:OnInitUI()
    btnClickCallback = Audio.PlayClickAudio
    this = self

    this.redPointTrans = {}
    this.background = self:Find("Background").gameObject
    this.backgroundImage = this.background:GetComponent(TypeImage)
    Functions.SetBackgroundAdaptation(this.backgroundImage)

    --顶部
    local top = self:Find("Top/Top")

    local headBg = top:Find("HeadBg")
    this.headBtn = headBg:Find("Head/Frame").gameObject
    this.headImage = headBg:Find("Head/Mask/Icon"):GetComponent(TypeImage)
    this.nameTxt = headBg:Find("NameText"):GetComponent(TypeText)
    -- this.male = top:Find("Name/Male").gameObject
    -- this.female = top:Find("Name/Female").gameObject
    this.idTxt = headBg:Find("IdText"):GetComponent(TypeText)

    this.diamondBtn = top:Find("Diamond/Button").gameObject
    this.diamondTxt = top:Find("Diamond/Text"):GetComponent(TypeText)

    this.goldBtn = top:Find("Gold/Button").gameObject
    this.goldTxt = top:Find("Gold/Text"):GetComponent(TypeText)

    this.quitBtn = top:Find("QuitBtn")

    --中间
    local center = self:Find("Center")
    local right = center:Find("Right")

    this.clubBtn = right:Find("ClubBtn").gameObject
    this.Pin3Btn = right:Find("Pin3Btn").gameObject
    this.Pin5Btn = right:Find("Pin5Btn").gameObject

    local centerRight = center:Find("CenterRight")

    --加入
    this.joinBtn = centerRight:Find("JoinBtn").gameObject
    -- this.joinBtnAnim = centerRight:Find("JoinBtn/Effect"):GetComponent(TypeSkeletonGraphic)
    --创建
    this.createBtn = centerRight:Find("CreateBtn").gameObject
    -- this.createBtnAnim = centerRight:Find("CreateBtn/Effect"):GetComponent(TypeSkeletonGraphic)
    --茶馆
    this.unionBtn = centerRight:Find("UnionBtn").gameObject
    -- this.unionBtnAnim = centerRight:Find("UnionBtn/Effect"):GetComponent(TypeSkeletonGraphic)
    --血战麻将
    this.xueZhanBtn = centerRight:Find("XueZhanBtn").gameObject
    this.xueZhanBtnAnim = centerRight:Find("XueZhanBtn/Effect"):GetComponent(TypeSkeletonGraphic)
    --幺鸡麻将
    this.yaoJiBtn = centerRight:Find("YaoJiBtn").gameObject
    this.yaoJiBtnAnim = centerRight:Find("YaoJiBtn/Effect"):GetComponent(TypeSkeletonGraphic)
    --跑得快
    this.pDKBtn = centerRight:Find("PDKBtn").gameObject
    this.pDKBtnAnim = centerRight:Find("PDKBtn/Effect"):GetComponent(TypeSkeletonGraphic)

    this.UnionList = center:Find("CenterLeft/UnionList")
    this.UnionListContent = this.UnionList:Find("ScrollView/Viewport/Content")
    this.UnionItemPrefab = this.UnionListContent:Find("UnionItem")
    this.NoneUnion = this.UnionList:Find("NoneUnion")
    this.UnionCreateBtn = this.UnionList:Find("CreateButton")
    this.UnionJoinBtn = this.UnionList:Find("JoinButton")
    this.UnionItemTable = {}

    -- local girl = center:Find("GirlAnim")
    -- this.girlTween = girl:GetComponent(TypeTweenAlpha)
    -- this.girlAnim = girl:GetComponent(TypeSkeletonGraphic)

    --下面
    local bottom = self:Find("Bottom/Bottom")
    local bottomBtns = bottom:Find("Btns")
    this.shareBtn = bottomBtns:Find("ShareButton").gameObject
    this.recordBtn = bottomBtns:Find("RecordButton").gameObject
    this.noticeBtn = bottomBtns:Find("NoticeButton").gameObject
    this.settingBtn = bottomBtns:Find("SettingBtn").gameObject
    this.customBtn = bottomBtns:Find("CustomBtn").gameObject

    this.AddUIListenerEvent()
    this.CheckAndOpenUpdateNoticePanel()
    --偏移
    self:OffsetLeftOnIPhoneX()
end

--二比一分辨率进行偏移
function LobbyPanel:OffsetLeftOnIPhoneX()

end

--每次打开都调用一次   defaultOpenType:DefaultOpenType定义   arg：如果是俱乐部或者俱乐部，则是其ID
function LobbyPanel:OnOpened(args)
    this.JudgeOpenMessagePanel()
    this.AddListenerEvent()
    Waiting.ForceHide()
    this.InitPanel()
    --this.UpdateLobbyBackground()
    --this.BindPhoneTips()
    AppPlatformHelper.CheckIsGetCopyTextOnLobby()
    this.EnterRelatePanel(args)
    BaseTcpApi.SendEnterModule(ModuleType.Lobby)

    BaseTcpApi.SendGetServiceWebchat()
    this.SendUnionInfoRequest()
    Functions.SetRoomPrivate(false)

    BaseTcpApi.SendGetRedPointInfo()
    this.getRedPointHandle = Scheduler.scheduleGlobal(function()
        BaseTcpApi.SendGetRedPointInfo()
    end, 15)
    GameSceneManager.SwitchGameSceneEnd(GameSceneType.Lobby)

    AddMsg(CMD.Game.UpdateRedPointTips, this.OnGameUpdateRedPoint)
    
    this.scheulde1 = Scheduler.scheduleOnceGlobal(function()
        UIUtil.SetActive(this.createBtn, true)
    end, 0.1)

    this.scheulde2 = Scheduler.scheduleOnceGlobal(function()
        UIUtil.SetActive(this.joinBtn, true)
    end, 0.2)
end

function LobbyPanel:OnEnable()
    --LogError("<color=aqua>OnEnable</color>")
    this.SendUnionInfoRequest()
end

--获取联盟列表
function LobbyPanel.SendUnionInfoRequest()
    this.UpdateLastUnionID()
    UnionManager.SendGetUnionsList()
end

function LobbyPanel.UpdateLastUnionID()
    this.LastUnionID = tonumber(GetLocal("LastUnionID"))
end

---判断是否需要打开消息界面展示招募图片
function LobbyPanel.JudgeOpenMessagePanel()
    if GameSceneManager.lastGameScene.type == GameSceneType.Login then
        --PanelManager.Open(PanelConfig.Message, MessageType.Recruit)
    end
end

function LobbyPanel:OnClosed()
    Scheduler.unscheduleGlobal(this.getRedPointHandle)
    Scheduler.unscheduleGlobal(this.scheulde1)
    Scheduler.unscheduleGlobal(this.scheulde2)
    this.RemoveListenerEvent()
    --PanelManager.Close(PanelConfig.Notice)
end

------------------------------------------------------------------
--
function LobbyPanel.AddListenerEvent()
    AddEventListener(CMD.Tcp.S2C_Receipt, this.UpdateCard)
    AddEventListener(CMD.Game.UpdateUserInfo, this.OnUpdateUserInfo)
    AddEventListener(CMD.Game.Reauthentication, this.OnReauthentication)
    AddEventListener(CMD.Game.UpdateHeadFrame, this.OnUpdateHeadFrame)
    AddEventListener(CMD.Game.UpdateMoney, this.OnUpdateMoney)
    AddEventListener(CMD.Game.LobbyBackgroundUpdate, this.OnLobbyBackgroundUpdate)
    --AddEventListener(CMD.Game.UpdateRedPointTips, this.OnUpdateRedPointTips)
    AddEventListener(CMD.Tcp_S2C_MEMBER_STATUS, this.CMDUpdateMemberStatus)
    AddMsg(CMD.Tcp.Union.S2C_GetUnionList, this.OnTcpGetUnionsList)
    AddMsg(CMD.Tcp.Union.PushInfoUpdate, this.OnTcpPushInfoUpdate)
end

--
function LobbyPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Tcp.S2C_Receipt, this.UpdateCard)
    RemoveEventListener(CMD.Game.UpdateUserInfo, this.OnUpdateUserInfo)
    RemoveEventListener(CMD.Game.Reauthentication, this.OnReauthentication)
    RemoveEventListener(CMD.Game.UpdateHeadFrame, this.OnUpdateHeadFrame)
    RemoveEventListener(CMD.Game.UpdateMoney, this.OnUpdateMoney)
    RemoveEventListener(CMD.Game.LobbyBackgroundUpdate, this.OnLobbyBackgroundUpdate)
    --RemoveEventListener(CMD.Game.UpdateRedPointTips, this.OnUpdateRedPointTips)
    RemoveEventListener(CMD.Tcp_S2C_MEMBER_STATUS, this.CMDUpdateMemberStatus)
    RemoveMsg(CMD.Tcp.Union.S2C_GetUnionList, this.OnTcpGetUnionsList)
    RemoveMsg(CMD.Tcp.Union.PushInfoUpdate, this.OnTcpPushInfoUpdate)
end

function LobbyPanel.AddUIListenerEvent()
    this:AddOnClick(this.headBtn, this.OnHeadBtnClick)
    this:AddOnClick(this.diamondBtn, this.OnDiamondBtnClick)
    this:AddOnClick(this.goldBtn, this.OnGoldBtnClick)

    this:AddOnClick(this.createBtn, this.OnCreateBtnClick)
    this:AddOnClick(this.joinBtn, this.OnJoinBtnClick)
    this:AddOnClick(this.unionBtn, this.OnUnionBtnClick)

    this:AddOnClick(this.xueZhanBtn, this.OnXueZhanBtnClick)
    this:AddOnClick(this.yaoJiBtn, this.OnYaoJiBtnClick)
    this:AddOnClick(this.pDKBtn, this.OnPDKBtnClick)

    this:AddOnClick(this.Pin3Btn, this.OnPin3CreateBtnCLick)
    this:AddOnClick(this.Pin5Btn, this.OnPin5CreateBtnCLick)
    this:AddOnClick(this.clubBtn, this.OnClubBtnClick)

    this:AddOnClick(this.shareBtn, this.OnShareBtnClick)
    this:AddOnClick(this.recordBtn, this.OnRecordBtnClick)
    this:AddOnClick(this.noticeBtn, this.OnNoticeBtnClick)
    this:AddOnClick(this.settingBtn, this.OnSettingBtnClick)
    this:AddOnClick(this.customBtn, this.OnCustomBtnClick)
    

    this:AddOnClick(this.quitBtn, this.OnQuitBtnClick)

    this:AddOnClick(this.UnionCreateBtn, this.OnUnionCreateBtnClick)
    this:AddOnClick(this.UnionJoinBtn, this.OnUnionJoinBtnClick)
    -- this.girlTween.onFinished = this.OnGirlTweenFinished
end

------------------------------------------------------------------------
--
--重连，如果有房间，则进入游戏
function LobbyPanel.OnReauthentication()
    if UserData.GetRoomId() > 0 then
        BaseTcpApi.CheckAndJoinRoom(UserData.GetRoomId(), true, true)
    else
        if PanelManager.IsOpened(PanelConfig.GoldMatch) then
            SendEvent(CMD.Game.ContinueMatch)
        end
    end
    this.UpdateUserInfo()
end

--更新头像框
function LobbyPanel.OnUpdateHeadFrame()
    Functions.SetHeadFrame(this.headFrame, UserData.GetFrameId())
end

--更新玩家货币，比如钻石和元宝
function LobbyPanel.OnUpdateMoney()
    this.UpdateUserInfo()
end

function LobbyPanel.OnLobbyBackgroundUpdate()
    this.UpdateLobbyBackground()
end

--------------------------------------UI事件----------------------------------
--
--头像按钮
function LobbyPanel.OnHeadBtnClick()
    PanelManager.Open(PanelConfig.UserInfo)
end

--货币按钮
function LobbyPanel.OnDiamondBtnClick()
    Toast.Show("敬请期待...")
end

--货币按钮
function LobbyPanel.OnGoldBtnClick()
    Toast.Show("敬请期待...")
end

--活动按钮
function LobbyPanel.OnActivityBtnClick()
    Toast.Show("敬请期待...")
end

--俱乐部
function LobbyPanel.OnClubBtnClick()
    Toast.Show("敬请期待...")
end

--大联盟
function LobbyPanel.OnUnionBtnClick()
    --LogError("this.unionItem.unionId", type(this.unionItem.unionId))
    Functions.ShowHeadIconTips(UnionManager.Open)
    --this.DirectlyOpenUnion()
end

--血战到底
function LobbyPanel.OnXueZhanBtnClick()
    Toast.Show("请进入茶馆")
end

--幺鸡麻将
function LobbyPanel.OnYaoJiBtnClick()
    Toast.Show("请进入茶馆")
end

--跑得快
function LobbyPanel.OnPDKBtnClick()
    Toast.Show("请进入茶馆")
end


---直接打开联盟
function LobbyPanel.DirectlyOpenUnion()
    UnionManager.Open(nil, nil, true)
    if this.unionItem ~= nil and UnionData.SetCurUnionId(this.unionItem.unionId) then
        PanelManager.Open(PanelConfig.UnionRoom)
    else
        Toast.Show("当前联盟不存在")
    end
end

function LobbyPanel.OpenUnionByUnionId(unionId)
    UnionManager.Open(nil, nil, true)
    if UnionData.SetCurUnionId(unionId) then
        PanelManager.Open(PanelConfig.UnionRoom)
    else
        Toast.Show("当前联盟不存在")
    end
end

function LobbyPanel.OnMoreUnionBtnClick()
    Functions.ShowHeadIconTips(UnionManager.Open)
end

--创建房间(majiang)
function LobbyPanel.OnCreateBtnClick()
    PanelManager.Open(PanelConfig.CreateRoom, GameType.Mahjong, RoomType.Lobby)
end

--创建房间(跑得快)
function LobbyPanel.OnCreateBtnClick1()
    PanelManager.Open(PanelConfig.CreateRoom, GameType.PaoDeKuai, RoomType.Lobby)
end

--创建房间(247)
function LobbyPanel.OnCreateBtnClick2()
    PanelManager.Open(PanelConfig.CreateRoom, GameType.ErQiShi, RoomType.Lobby)
end

---创建拼三张房间
function LobbyPanel.OnPin3CreateBtnCLick()
    PanelManager.Open(PanelConfig.CreateRoom, GameType.Pin3, RoomType.Lobby)
end

---创建拼十房间
function LobbyPanel.OnPin5CreateBtnCLick()
    PanelManager.Open(PanelConfig.CreateRoom, GameType.Pin5, RoomType.Lobby)
end

--加入房间
function LobbyPanel.OnJoinBtnClick()
    PanelManager.Open(PanelConfig.JoinRoom)
end

--商城
function LobbyPanel.OnMallBtnClick()
    Toast.Show("敬请期待...")
    -- local phoneNum = UserData.GetBindPhone()
    -- if phoneNum == "" and IsIPhonePlatform() then
    --     Alert.Prompt(this.bindTips, function()
    --         PanelManager.Open(PanelConfig.UserInfo, 0)
    --     end, function()
    --         PanelManager.Open(PanelConfig.Mall)
    --     end)
    -- else
    --     PanelManager.Open(PanelConfig.Mall)
    -- end
end

--分享
function LobbyPanel.OnShareBtnClick()
    PanelManager.Open(PanelConfig.LobbyShare)
end

--战绩
function LobbyPanel.OnRecordBtnClick()
    Toast.Show("请在茶馆里查看战绩")
    --PanelManager.Open(PanelConfig.Record)
end

--大厅公告
function LobbyPanel.OnNoticeBtnClick()
    PanelManager.Open(PanelConfig.LobbyNotice)
end

--信息
function LobbyPanel.OnNewsBtnClick()
    Toast.Show("敬请期待...")
    --PanelManager.Open(PanelConfig.Message, MessageType.Message)
end

--信息
function LobbyPanel.OnInviteCodeClick()
    PanelManager.Open(PanelConfig.InviteCode, MessageType.Message)
end

--菜单
function LobbyPanel.OnMenuBtnClick()
    UIUtil.SetActive(this.menuBtnsTran, not this.menuBtnsTran.gameObject.activeSelf)
end

--菜单背景按钮
function LobbyPanel.OnMenuBtnsTranClick()
    UIUtil.SetActive(this.menuBtnsTran, not this.menuBtnsTran.gameObject.activeSelf)
end

--设置
function LobbyPanel.OnSettingBtnClick()
    PanelManager.Open(PanelConfig.Setup)
    --LobbyPanel.OnMenuBtnsTranClick()
end

--客服
function LobbyPanel.OnCustomBtnClick()
    PanelManager.Open(PanelConfig.Service)
end

--退出
function LobbyPanel.OnQuitBtnClick()
    Alert.Prompt("确定退出游戏，返回到登录界面？", function()
        SendEvent(CMD.Game.LogoutAndOpenLogin)
    end)
end

--------------------------------------UI事件----------------------------------end
-- 初始化面板--
function LobbyPanel.InitPanel()
    this.SetUserInfo()
    this.CheckRedPointTips()
    --PanelManager.Open(PanelConfig.Notice)
    BaseTcpApi.SendActivity(1) --获取系统公告
    UIUtil.SetActive(this.menuBtnsTran, false)
end

--绑定手机提示
function LobbyPanel.BindPhoneTips()
    if UserData.IsFirstLogin() then
        local phoneNum = UserData.GetBindPhone()
        if phoneNum == "" and IsIPhonePlatform() then
            Alert.Prompt(this.bindTips, function()
                PanelManager.Open(PanelConfig.UserInfo, 0)
            end, nil)
        end
        -- UserData.SetIsFirstLogin(false)
    end
end

-- 设置大厅玩家信息
function LobbyPanel.SetUserInfo()
    this.nameTxt.text = SubStringName(UserData.GetName())
    this.idTxt.text = "ID:" .. UserData.GetUserId()
    -- if UserData.gender == Global.GenderType.Male then
    --     UIUtil.SetActive(this.male, true)
    --     UIUtil.SetActive(this.female, false)
    -- else
    --     UIUtil.SetActive(this.male, false)
    --     UIUtil.SetActive(this.female, true)
    -- end
    this.UpdateUserInfo()
    Functions.SetHeadImage(this.headImage, UserData.GetHeadUrl())
end

--更新钻石数量显示
function LobbyPanel.UpdateUserInfo()
    this.diamondTxt.text = UserData.GetRoomCard()
    this.goldTxt.text = UserData.GetGold()
end

--更新大厅背景
function LobbyPanel.UpdateLobbyBackground()
    local index = SettingMgr.GetBackgroundIndex()
    if this.backgroundIndex ~= index then
        this.backgroundIndex = index
        --
        local sprite = ResourcesManager.LoadSpriteBySynch("base/lobby", "bg-lobby-" .. index)
        if sprite ~= nil then
            this.backgroundImage.sprite = sprite
        end
    end
end

---------------------------------------------------------------------
--
function LobbyPanel.UpdateCard(data)
    local playerID = UserData.GetUserId()
    local key = "PAY_VERIFY" .. playerID
    if data.code == 0 then
        Toast.Show("充值成功")
        UserData.SetRoomCard(data.data.fk)
        SetText(this.roomCardTxt, UserData.GetRoomCard())
        DataPool.SetLocal(key, nil)
    else
        Log("UpdateCard", SystemError.GetText(data.code))
    end
end

--更新玩家信息
function LobbyPanel.OnUpdateUserInfo()
    this.SetUserInfo()
end

---------------------------------------------------------------------
--
--处理红点
function LobbyPanel.CheckRedPointTips()
    --this.UpdateAllRedPointTips()
    --BaseTcpApi.SendGetRedPointInfo()
end

--更新所有的红点
function LobbyPanel.UpdateAllRedPointTips()

end

--更新大厅红点
function LobbyPanel.OnUpdateRedPointTips(redPointType, redPointValue)
    if redPointType == nil then
        this.UpdateAllRedPointTips()
    else
    end
end

--更新红点
function LobbyPanel.UpdateRedPointTips(redPointType, gameObject)
    local isShow = RedPointMgr.GetRedPoint(redPointType) ~= nil
    UIUtil.SetActive(gameObject, isShow)
end

--通过多个控制的红点显示
function LobbyPanel.UpdateRedPointTipsByMultiple(arr, gameObject)
    local isShow = false
    for i = 1, #arr do
        isShow = isShow or RedPointMgr.GetRedPoint(arr[i]) ~= nil
    end
    UIUtil.SetActive(gameObject, isShow)
end

function LobbyPanel.CMDUpdateMemberStatus(data)
    --当俱乐部成员权限发生变化时  请求更新红点
    if data.code == 0 then
        BaseTcpApi.SendGetRedPointInfo()
    end
end

---------------------------------------------------------------------
--
--进入相关界面
function LobbyPanel.EnterRelatePanel(data)
    LogError(">> LobbyPanel.EnterRelatePanel > 打开相关界面")
    if data == nil then
        BaseTcpApi.SendEnterModule(ModuleType.Lobby)
    else
        --LogError("打开相关界面", data.openType, data.recordType)
        if not IsNil(data.openType) then
            LockScreen(1)
            if data.openType == DefaultOpenType.Club then
                --进入俱乐部
                if data.groupId ~= nil and tonumber(data.groupId) > 0 then
                    ClubManager.Open(data.groupId, data.gameType)
                end
            elseif data.openType == DefaultOpenType.Record then
                --进入战绩
                this.CheckEnterRecordPanel()
                --战绩类型为房间类型
                if data.recordType == RoomType.Lobby then
                    --大厅战绩
                    BaseTcpApi.SendEnterModule(ModuleType.Lobby)
                elseif data.recordType == RoomType.Club then
                    --俱乐部战绩
                    if data.groupId ~= nil and tonumber(data.groupId) > 0 then
                        ClubManager.Open(data.groupId, data.gameType)
                    end
                elseif data.recordType == RoomType.Tea then
                    --联盟战绩
                    if data.groupId ~= nil and tonumber(data.groupId) > 0 then
                        -- UnionManager.Open(data.groupId, data.gameType)
                        PanelManager.Open(PanelConfig.UnionRoom)
                        this.isBackToLobby = true
                        this.SendUnionInfoRequest()
                    end
                end
            elseif data.openType == DefaultOpenType.Tea then
                if data.groupId ~= nil and tonumber(data.groupId) > 0 then
                    -- UnionManager.Open(data.groupId, data.gameType, true)
                    this.isBackToLobby = true
                    --this.SendUnionInfoRequest()--在Open方法有请求
                    PanelManager.Open(PanelConfig.UnionRoom)
                end
            else
                BaseTcpApi.SendEnterModule(ModuleType.Lobby)
            end
        else
            BaseTcpApi.SendEnterModule(ModuleType.Lobby)
        end
    end
end

---判断是否需要进入战绩界面
function LobbyPanel.CheckEnterRecordPanel()
    if RecordPanel ~= nil then
        RecordPanel.Show()
    end
    if RecordDetailPanel ~= nil then
        RecordDetailPanel.Show()
    end
    if RecordSubPanel then
        RecordSubPanel.Show()
    end
end

--检测打开更新公告界面
function LobbyPanel.CheckAndOpenUpdateNoticePanel()
    local lastVersion = GetLocal(LocalDatas.UpdateNotiveVersion, 0)
    if lastVersion ~= nil then
        lastVersion = tonumber(lastVersion)
    end

    if lastVersion < NoticeConfig.UpdateVersion then
        SetLocal(LocalDatas.UpdateNotiveVersion, NoticeConfig.UpdateVersion)
        --PanelManager.Open(PanelConfig.UpdateNotice)
    end
end

function LobbyPanel.OnGameUpdateRedPoint()
    local val = RedPointMgr.GetRedPointByType(RedPointType.LobbyMessage)
    --UIUtil.SetActive(this.redPointTrans[RedPointType.LobbyMessage], val ~= nil)
end

function LobbyPanel.OnTcpGetUnionsList(data)
    --LogError("<color=aqua>OnTcpGetUnionsList</color>", data)
    if data.code == 0 then
        UnionData.ParseUnionList(data.data)
        local unionList = data.data.list
        --this.InitSingleUnion(unionList)
        --this.InitUnionList(unionList)
        this.unionItem = this.GetLastUnionInfo(unionList)
        if this.isBackToLobby then
            this.isBackToLobby = false
            this.DirectlyOpenUnion()
        end
    end
end

--联盟有变化
function LobbyPanel.OnTcpPushInfoUpdate(data)
    LogError(">> LobbyPanel.OnTcpPushInfoUpdate")
    UnionManager.SendGetUnionsList()
end

function LobbyPanel.InitSingleUnion(unionList)
    if #unionList > 0 then
        if #unionList == 1 or not this.LastUnionID then
            --LogError("#unionList == 1 or not this.LastUnionID  ", "#unionList", #unionList, "this.LastUnionID", this.LastUnionID)
            this.unionItem = unionList[1]
        elseif this.LastUnionID then
            --LogError("this.LastUnionID", this.LastUnionID)
            this.unionItem = this.GetLastUnionInfo(unionList)
            if not this.unionItem then
                this.unionItem = unionList[1]
            end
        end
        local name, playerNum, allNum = this.unionItem.unionName, this.unionItem.playerNum, this.unionItem.allNum
        UIUtil.SetText(this.UnionName, name)
        local roleLimit = this.unionItem.adminType == UnionRole.Admin or this.unionItem.adminType == UnionRole.Leader or
        this.unionItem.adminType == UnionRole.Observer
        local onlineText = roleLimit and playerNum .. "/" .. allNum or "***/***"
        UIUtil.SetText(this.OnlinePeopleCount, onlineText)
    else
        UIUtil.SetText(this.UnionName, "暂无亲友圈")
        UIUtil.SetText(this.OnlinePeopleCount, "")
    end
end

function LobbyPanel.InitUnionList(unionList)
    UIUtil.SetActive(this.NoneUnion, #unionList == 0)
    this.ClearUnionItems()
    if #unionList > 0 then
        for i = 1, #unionList do
            local unionData = unionList[i]
            local unionItem = this.GetUnionItem(i)
            unionItem.data = unionData

            UIUtil.SetActive(unionItem.gameObject, true)

            local name, playerNum, allNum = unionData.unionName, unionData.playerNum, unionData.allNum
            UIUtil.SetText(unionItem.name, name)
            local roleLimit = unionData.adminType == UnionRole.Admin or unionData.adminType == UnionRole.Leader or
            unionData.adminType == UnionRole.Observer
            local onlineText = roleLimit and playerNum .. "/" .. allNum or "***/***"
            UIUtil.SetText(unionItem.count, onlineText)
            --显示职位
            UIUtil.SetActive(unionItem.roleTag1, false)
            UIUtil.SetActive(unionItem.roleTag2, false)
            UIUtil.SetActive(unionItem.roleTag3, false)
            UIUtil.SetActive(unionItem.roleTag4, false)
            if unionData.adminType == UnionRole.Leader then
                UIUtil.SetActive(unionItem.roleTag4, true)
            elseif unionData.adminType == UnionRole.Admin then
                UIUtil.SetActive(unionItem.roleTag3, true)
            elseif unionData.adminType == UnionRole.Partner then
                UIUtil.SetActive(unionItem.roleTag2, true)
            else
                UIUtil.SetActive(unionItem.roleTag1, true)
            end
        end
    end
    --UIUtil.SetActive(this.UnionItemPrefab, false)
end

function LobbyPanel.GetUnionItem(i)
    if this.UnionItemTable[i] then
        return this.UnionItemTable[i]
    else
        local unionItem = {}
        unionItem.gameObject = NewObject(this.UnionItemPrefab, this.UnionListContent)
        unionItem.transform = unionItem.gameObject.transform
        unionItem.name = unionItem.transform:Find("Name")
        unionItem.count = unionItem.transform:Find("OnlinePeopleCount")
        unionItem.roleTag1 = unionItem.transform:Find("Tag1").gameObject
        unionItem.roleTag2 = unionItem.transform:Find("Tag2").gameObject
        unionItem.roleTag3 = unionItem.transform:Find("Tag3").gameObject
        unionItem.roleTag4 = unionItem.transform:Find("Tag4").gameObject

        this.UnionItemTable[i] = unionItem

        this:AddOnClick(unionItem.transform, function()
            this.OpenUnionByUnionId(unionItem.data.unionId)
        end)

        return unionItem
    end
end

function LobbyPanel.ClearUnionItems()
    local item = nil
    for i = 1, #this.UnionItemTable do
        item = this.UnionItemTable[i]
        if item.data ~= nil then
            item.data = nil
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

function LobbyPanel.OnUnionCreateBtnClick()
    Toast.Show("权限不足")
end

function LobbyPanel.OnUnionJoinBtnClick()
    Toast.Show("权限不足")
    --PanelManager.Open(PanelConfig.UnionInputNumber, UnionInputNumberPanelType.JoinUnion, function(num)
    --    UnionManager.SendApplyJoinUnionsList(num)
    --    PanelManager.Close(PanelConfig.UnionInputNumber, true)
    --end)
end

function LobbyPanel.GetLastUnionInfo(unionList)
    for i = 1, #unionList do
        if this.LastUnionID == unionList[i].unionId then
            return unionList[i]
        end
    end
end


-- function LobbyPanel.OnGirlTweenFinished()
--     local num = GetRandom(1, 2)
--     this.girlAnim.AnimationState:SetAnimation(0, "idle0" .. num, false)
--     this.girlAnim.AnimationState.Complete = this.girlAnim.AnimationState.Complete + this.OnGirlAnimComplete

--     this.createBtnAnim.AnimationState:SetAnimation(0, "in", false)
--     this.createBtnAnim.AnimationState.Complete = this.createBtnAnim.AnimationState.Complete + this.OnCreateBtnAnimComplete

--     this.joinBtnAnim.AnimationState:SetAnimation(0, "in", false)
--     this.joinBtnAnim.AnimationState.Complete = this.joinBtnAnim.AnimationState.Complete + this.OnJoinBtnAnimComplete

--     this.unionBtnAnim.AnimationState:SetAnimation(0, "in", false)
--     this.unionBtnAnim.AnimationState.Complete = this.unionBtnAnim.AnimationState.Complete + this.OnUnionBtnAnimComplete
-- end

-- function LobbyPanel.OnGirlAnimComplete(track)
--     if this.girlAnim.AnimationState.Complete ~= nil then
--         this.girlAnim.AnimationState.Complete = this.girlAnim.AnimationState.Complete - this.OnGirlAnimComplete
--     end
--     this.girlAnim.AnimationState:SetAnimation(0, "stand", true)
-- end

-- function LobbyPanel.OnCreateBtnAnimComplete(track)
--     if this.createBtnAnim.AnimationState.Complete ~= nil then
--         this.createBtnAnim.AnimationState.Complete = this.createBtnAnim.AnimationState.Complete - this.OnCreateBtnAnimComplete
--     end
--     this.createBtnAnim.AnimationState:SetAnimation(0, "animation", true)
-- end

-- function LobbyPanel.OnJoinBtnAnimComplete(track)
--     if this.joinBtnAnim.AnimationState.Complete ~= nil then
--         this.joinBtnAnim.AnimationState.Complete = this.joinBtnAnim.AnimationState.Complete - this.OnJoinBtnAnimComplete
--     end
--     this.joinBtnAnim.AnimationState:SetAnimation(0, "animation", true)
-- end

-- function LobbyPanel.OnUnionBtnAnimComplete(track)
--     if this.unionBtnAnim.AnimationState.Complete ~= nil then
--         this.unionBtnAnim.AnimationState.Complete = this.unionBtnAnim.AnimationState.Complete - this.OnUnionBtnAnimComplete
--     end
--     this.unionBtnAnim.AnimationState:SetAnimation(0, "animation", true)
-- end
