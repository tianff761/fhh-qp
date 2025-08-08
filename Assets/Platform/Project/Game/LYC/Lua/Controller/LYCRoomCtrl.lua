LYCRoomCtrl = Class("LYCRoomCtrl")
local this = LYCRoomCtrl

--是否可以点击语音按钮
this.isCanClick = true
--语音Y轴偏移量
this.speechTouchY = 0

--所有网络信号图片
local allNetSprites = {}

local gameObject
local transform
local isActive = true

function LYCRoomCtrl:Init(trans)
    transform = trans
    gameObject = transform.gameObject
    --注册监听语音事件
    LYCRoomPanel.voiceSpeech:Init(this.OnSpeechTouchDown, this.OnSpeechTouchUp, this.OnSpeechTouchMove)
end

-- 启动事件--
function LYCRoomCtrl:OnCreate()
    this.Open()
end

function LYCRoomCtrl.Open()
    LYCRoomPanel.HideReadyBtn()

    -- 初始化wifi等信息的获取
    this.InitRightTopData()

    isActive = true
    this.InitAutoFlip()
    LogError("<color=aqua>AddMsg LYCObserverSitDown</color>")
    AddMsg(LYCAction.LYCObserverSitDown, this.ResetAllPlayerUI)
end

function LYCRoomCtrl.InitAutoFlip()
    --LYCRoomData.isAutoFlipCard = PlayerPrefs.GetInt("AutoFlip") == 1 and true or false
    LYCRoomData.isAutoFlipCard = false
end

--------------------------点击事件
--点击关闭回顾
function LYCRoomCtrl.OnClickHuiguMask()
    UIUtil.SetActive(LYCRoomPanel.Retrospect.gameObject, false)
end

--点击聊天
function LYCRoomCtrl.OnClickChat()
    if LYCRoomData.isPlayback then
        return
    end
    PanelManager.Open(PanelConfig.RoomChat, { isShield = true })
end

--点击菜单按钮
function LYCRoomCtrl.OnClickUpMenu()
    if LYCRoomData.isPlayback then
        return
    end
    LYCRoomPanel.SetMenuItemsActive(false)
    UIUtil.SetActive(LYCRoomPanel.menuDwon.gameObject, true)
    UIUtil.SetActive(LYCRoomPanel.menuUp.gameObject, false)
end

--点击展开菜单栏
function LYCRoomCtrl.OnClickDownMenu()
    if LYCRoomData.isPlayback then
        return
    end
    LYCRoomPanel.SetMenuItemsActive(true)
    UIUtil.SetActive(LYCRoomPanel.menuDwon.gameObject, false)
    UIUtil.SetActive(LYCRoomPanel.menuUp.gameObject, true)
end

--复制房间号
function LYCRoomCtrl.OnClickFuzhi(go)
    if LYCRoomData.isPlayback then
        return
    end
    local text = this.ShareDataStr()
    AppPlatformHelper.CopyText(text)
end

--点击规则按钮
function LYCRoomCtrl.OnClickRule(go)
    PanelManager.Open(LYCPanelConfig.RoomInfo)
end

--点击观战列表弹窗按钮
function LYCRoomCtrl.OnClickWatcherListBtn(go)
    PanelManager.Open(LYCPanelConfig.LYCWatcherList)
end

--点击回顾
function LYCRoomCtrl.OnClickRetrospectBtn()
    if LYCRoomData.isPlayback then
        return
    end
    if LYCRoomData.IsGoldGame() then
        PanelManager.Open(LYCPanelConfig.GoldReview)
    else
        PanelManager.Open(LYCPanelConfig.Review)
    end
end

--点击设置
function LYCRoomCtrl.OnClickSetBtn()
    if LYCRoomData.isPlayback then
        return
    end
    PanelManager.Open(LYCPanelConfig.RoomSetup)
end

--点击离开
function LYCRoomCtrl.OnClickLeaveBtn()
    if LYCRoomData.isPlayback then
        return
    end
    --发送离开协议
    LYCApiExtend.SendLeave()
end

--点击解散
function LYCRoomCtrl.OnClickDismissBtn()
    if LYCRoomData.isPlayback then
        return
    end

    -- if LYCRoomData.IsGoldGame() then
    --     Toast.Show("匹配场无法解散房间")
    --     return
    -- end

    local text = "是否退出房间？"
    if LYCRoomData.MainIsOwner() then
        text = "您是否确认解散房间？"
    end

    if LYCRoomData.IsGameStarted() then
        text = "牌局已经开始，是否申请解散？"
    end

    Alert.Prompt(text, function()
        if LYCRoomData.MainIsOwner() then
            if LYCRoomData.IsGameStarted() then
                LYCApiExtend.SendDissolve(-1)
            else
                LYCApiExtend.SendOwnerDissolve()
            end
        else
            LYCApiExtend.SendDissolve(-1)
        end
    end)
end

-- 点击玩家头像
function LYCRoomCtrl.OnClickPlayerHead(go, playerUI)
    if LYCRoomData.isPlayback then
        return
    end
    if playerUI.playerId ~= nil and playerUI.playerId ~= "" then
        local playerData = LYCRoomData.GetPlayerDataById(playerUI.playerId)
        local moneyType = MoneyType.Fangka
        if LYCRoomData.IsGoldGame() then
            moneyType = MoneyType.Gold
        end
        LogError("玩家数据", playerData)
        local arg = {
            name = playerData.name, --姓名
            sex = playerData.sex, --性别 1男 2 女
            id = playerData.id, --玩家id
            --score = playerData.playerScore, --元宝数量
            gold = playerData.gold, --元宝数量
            moneyType = moneyType, --货币类型
            limitScore = LYCRoomData.zhunru, --元宝场准入分数
            headUrl = playerData.playerHead, --头像链接
            isShowAdress = false,
        }
        
        LogError(" 捞腌菜--游戏内显示点击玩家头像界面 ")
        PanelManager.Open(PanelConfig.RoomUserInfo, arg)
    else
        LogError(">>>>>>>>>>>>>>>>>>   OnClickPlayerHead  playerUI.playerId  空")
    end
end

-- 点击准备按钮
function LYCRoomCtrl.OnClickReady(go)
    if LYCRoomData.isPlayback then
        return
    end
    LYCApiExtend.SendReady()
    LYCResourcesMgr.PlayGameOperSound(LYCGameSoundType.READY, LYCRoomData.mainId)
end

-- 房主开始游戏
function LYCRoomCtrl.OnClickStartBtn(go)
    if LYCRoomData.isPlayback then
        return
    end
    LYCApiExtend.SendStartGame()
end

function LYCRoomCtrl.OnClickSitDownBtn()
    if LYCRoomData.isPlayback then
        return
    end
    LYCApiExtend.SendSeatDownMsg()
end

--------------------------------------------------------------------
--设置是否自动翻牌
function LYCRoomCtrl.OnAutoFlipToggle(isOn)
    LYCRoomData.isAutoFlipCard = isOn
    PlayerPrefs.SetInt("AutoFlip", isOn and 1 or 0)
end
--------------------------------------
--分享复制的文本内容
function LYCRoomCtrl.ShareDataStr()
    if LYCRoomData.isPlayback then
        return
    end
    local text = "【欢乐游戏】"
    local roomNameCode = LYCRoomData.roomCode
    local roomName = LYCRoomData.gameName
    local diFen = LYCRoomData.diFen
    local jushu = LYCRoomData.gameTotal
    local showStartType = LYCRoomData.showStartType
    local wanfa = LYCRoomData.gaoJiConfig
    local t = "房间号：" .. roomNameCode .. "，游戏：" .. roomName .. "，底分：" .. diFen .. "，局数" .. jushu .. "局，开始类型：" .. showStartType

    local ownerData = LYCRoomData.GetPlayerDataById(LYCRoomData.owner)
    if not IsNil(ownerData) then
        local houseOwner = ownerData.name
        t = t .. "，房主 :" .. houseOwner
    end

    if wanfa ~= " " and wanfa ~= "" and wanfa ~= nil then
        t = t .. "，玩法：" .. wanfa
    end
    text = text .. t
    return text
end

--根据状态显示按钮
function LYCRoomCtrl.ShowUIByState()
    if LYCRoomData.GetSelfData() == nil then
        LogError(">>>>>>>>>>>>>> 自己的信息为nil")
        return
    end
    local pState = LYCRoomData.GetSelfData().state
    --判断自己是否准备  --没有准备的情况
    if pState == LYCPlayerState.WAITING or pState == LYCPlayerState.NO_READY then
        --未坐下（未准备）
        if LYCRoomData.isCardGameStarted then
            this.LookOn()
        else
            this.NoReady()
        end
        if pState == LYCPlayerState.WAITING then
            LYCRoomPanel.ShowCopyInvite()
        end
    elseif pState == LYCPlayerState.READY or pState == LYCPlayerState.WAITING_START then
        --坐下（准备）
        this.SitDowned()
    elseif pState == LYCPlayerState.WAIT or pState == LYCPlayerState.OPTION then
        --游戏中
        this.Gaming()
    end
end

--已坐下
function LYCRoomCtrl.SitDowned()
    this.CheckStartBtnActive()
    --隐藏准备按钮
    LYCRoomPanel.HideReadyBtn()

    LYCRoomPanel.HideCopyInvite()
    LYCRoomPanel.ShowChatVoice()

    --local readPlayers = LYCRoomData.GetReadyPlayer()
    --if readPlayers ~= nil and #readPlayers == 1 then
    --    LYCRoomPanel.SetStartBtnInteractable(false)
    --end
end

--旁观，未坐下
function LYCRoomCtrl.LookOn()
    this.CheckStartBtnActive()
    --提示语
    -- LYCContentTip.HandleLookOn()
end

--状态为未准备
function LYCRoomCtrl.NoReady()
    --显示准备
    LYCContentTip.HandleSelfNoReady()
    --检测是否能够显示开始按钮
    this.CheckStartBtnActive()
end

--游戏中
function LYCRoomCtrl.Gaming()
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>     状态为游戏中.............................")
    LYCRoomPanel.HideReadyBtn()
    UIUtil.SetActive(LYCRoomPanel.startBtn.gameObject, false)
    LYCRoomPanel.HideCopyInvite()
    LYCRoomPanel.ShowChatVoice()
    --关闭所有玩家准备图片
    LYCRoomPanel.HideAllReadyImge()
end

--检测是否可以激活开始按钮
function LYCRoomCtrl.CheckStartBtnActive()
    if LYCRoomData.IsFangKaFlow() and LYCRoomData.MainIsOwner() and LYCRoomData.isFrist and not LYCRoomData.IsGameStarted() then
        if LYCRoomData.GetSelfData().state ~= LYCPlayerState.WAITING then
            LYCRoomPanel.ShowStartBtn(true)
        else
            LYCRoomPanel.ShowStartBtn(false)
        end
    else
        LYCRoomPanel.HideStartBtn()
    end
end
-- ---------------------------------------------------------------------------------------------
--检查显示庄
function LYCRoomCtrl.CheckZhuang()
    LYCRoomPanel.ShowZhuangImage()
    this.CheckZhuangJia()
end

-- 设置庄家信息
function LYCRoomCtrl.CheckZhuangJia()
    --是否开始游戏
    if LYCRoomData.isCardGameStarted and LYCRoomData.gameState == LYCGameState.ROB_ZHUANG then
        for i = 1, #LYCRoomData.playerDatas do
            LYCRoomData.playerDatas[i]:ShowRobZhuangNum()
        end
    end
end
------------------------------------网络消息处理函数END------------------------------------------
-------------------------------------------------------------------------------------------------
--玩家离开后根据playerID移除玩家显示
function LYCRoomCtrl.RemovePlayerUI(leavePlayerID)
    local playerItem = LYCRoomData.GetPlayerUIById(leavePlayerID)
    if playerItem ~= nil then
        playerItem:Clear()
    end
end

function LYCRoomCtrl.ResetAllPlayerUI()
    LogError("<color=aqua>ResetAllPlayerUI</color>")
    local playerItems = LYCRoomPanel.GetAllPlayerItems()
    for i = 1, #playerItems do
        playerItems[i]:Clear()
    end
    LogError("<color=aqua>playerItems</color>", playerItems)
    this.UpdatePlayersDisplay()
end

--更新玩家座位
function LYCRoomCtrl.UpdatePlayersDisplay()
    --获取其他准备的玩家数据
    local playerDatas = LYCRoomData.playerDatas
    if IsTable(playerDatas) then
        local playerItems = LYCRoomPanel.GetAllPlayerItems()
        for i = 1, #playerItems do
            if IsTable(playerItems[i]) and playerItems[i].playerId ~= nil then
                playerItems[i]:SetActive(false)
            end
        end
        this.RefreshChangeList();
        LogError("playerDatas", playerDatas)
        for i = 1, #playerDatas do
            if not LYCFuntions.IsNilOrZero(playerDatas[i].seatNumber) then
                this.UpdatePlayerUI(playerDatas[i])
            end
        end
    end
end


--加入房间时根据座位号转换一下对应的item序号
--6人桌
local JoinIndex_6 = {
    [1] = 1;
    [2] = 2;
    [3] = 3;
    [4] = 4;
    [5] = 9;
    [6] = 10;
}
--8人桌
local JoinIndex_8 = {
    [1] = 1;
    [2] = 2;
    [3] = 3;
    [4] = 4;
    [5] = 5;
    [6] = 8;
    [7] = 9;
    [8] = 10;
}

--刷新座位数据  1 2 3 5 6 假如3号位是主玩家，刷新后改为 3 5 6 1 2
function LYCRoomCtrl.RefreshChangeList()
    local playerDatas = LYCRoomData.playerDatas
    LYCRoomData.playerPosDataList = {}
    LYCRoomData.playerPosIndexList = {}
    local itemIndex = 0;
    local selfData = LYCRoomData.GetSelfData();--主玩家数据
    local selfSeatNumber = selfData.seatNumber --主玩家座位号,如果在旁观也不会坐下去，不显示
    if LYCRoomData.isNewGame or selfData.state ~= LYCPlayerState.WAITING then
        itemIndex = itemIndex + 1
        table.insert(LYCRoomData.playerPosDataList, {playData = selfData, itemIndex = itemIndex})
        table.insert(LYCRoomData.playerPosIndexList, selfData.seatNumber)
    end

    local list_1 = {}
    local list_2 = {}
    for i = 1, #playerDatas do
        if (LYCRoomData.isNewGame or playerDatas[i].state ~= LYCPlayerState.WAITING) and not LYCFuntions.IsNilOrZero(playerDatas[i].seatNumber) then
            if selfData.id ~= playerDatas[i].id then
                table.insert(LYCRoomData.playerPosIndexList, playerDatas[i].seatNumber)
                if selfSeatNumber > playerDatas[i].seatNumber then
                    table.insert(list_1, playerDatas[i])
                elseif(selfSeatNumber < playerDatas[i].seatNumber) then
                    table.insert(list_2, playerDatas[i])
                end
            end
        end
    end
    table.sort(list_1, function(data1, data2)
        return data1.seatNumber < data2.seatNumber
    end)
    table.sort(list_2, function(data1, data2)
        return data1.seatNumber < data2.seatNumber
    end)

    table.sort(LYCRoomData.playerPosIndexList, function(data1, data2)
        return data1 < data2
    end)

    for i = 1, #list_2 do
        itemIndex = itemIndex + 1
        table.insert(LYCRoomData.playerPosDataList, {playData = list_2[i], itemIndex = itemIndex})
    end

    for i = 1, #list_1 do
        itemIndex = itemIndex + 1
        table.insert(LYCRoomData.playerPosDataList, {playData = list_1[i], itemIndex = itemIndex})
    end

    -- for i = 1, #LYCRoomData.playerPosDataList do
    --     LogError("刷新座位数据  ", LYCRoomData.playerPosDataList[i].playData.id, LYCRoomData.playerPosDataList[i].itemIndex)
    -- end
    -- LogError("刷新座位数据 座位索引表", LYCRoomData.playerPosIndexList)
end

--获取玩家顺位排序对应的座位号
function LYCRoomCtrl.GetItemIndex(playerData)
    for i = 1, #LYCRoomData.playerPosDataList do
        if LYCRoomData.playerPosDataList[i].playData.id == playerData.id then
            local itemIndex = LYCRoomData.playerPosIndexList[LYCRoomData.playerPosDataList[i].itemIndex]
            if itemIndex ~= nil then
                --6人桌和8人桌需要把服务器座位号转换成客户端对应的item序号
                if LYCRoomData.manCount == 6 then
                    return JoinIndex_6[itemIndex]
                elseif(LYCRoomData.manCount == 8) then
                    return JoinIndex_8[itemIndex]
                end
                return itemIndex
            else
                LogError(" 玩家座位号错误 ", playerData.id)
            end 
        end
    end
    return 3--出错了，但总不能填其他数报错吧
end

--玩家坐下后被调用
function LYCRoomCtrl.UpdatePlayerUI(playerData)
    if playerData ~= nil then
        -- LogError(" 玩家当前的状态  ",playerData.state,LYCRoomData.isGameStarted,LYCRoomData.isNewGame)
        --显示观战中
        --游戏还在进行中时，所有玩家坐下不显示,自己坐下去旁观不显示玩家信息，只隐藏旁观信息按钮
        if playerData.state == LYCPlayerState.WAITING and not LYCRoomData.isNewGame then
            if LYCRoomData.CheckIsSelf(playerData.id) then
                -- LYCRoomPanel.ShowWait()
                LYCRoomPanel.HideSitDownBtn()
            end
            LYCRoomData.isNewPlayer = true;
            return
        end

        local selfSeatNumber = LYCRoomData.GetSelfData().seatNumber
        LogError("设置玩家UI 玩家ID", playerData.id, " 玩家当前的状态 ",playerData.state, "自己的座位号", selfSeatNumber, "玩家座位号", playerData.seatNumber)
        -- local itemIndex = LYCFuntions.CalcLocalSeatByServerSeat(selfSeatNumber, playerData.seatNumber)
        local itemIndex = 1
        if selfSeatNumber ~= playerData.seatNumber then
            itemIndex = this.GetItemIndex(playerData)
        end

        local playerItem = LYCRoomPanel.GetPlayerItem(itemIndex)
        playerItem:ResetPlayerUI()
        --设置玩家信息
        playerItem:SetUIByPlayerData(playerData.id)
        --显示观战中
        if LYCRoomData.isGameStarted and playerData.state == LYCPlayerState.WAITING then
            playerItem:SetLookOnImageActive(true)
        end
        --更新聊天模块
        LYCRoom.UpdateChatPlayers(LYCRoomPanel.GetAllPlayerItems())
    end
end

--比牌结束
function LYCRoomCtrl.ThanCardEnd()

end

--处理初始化界面UI
function LYCRoomCtrl.InitRoomUI(data)
    --显示房间信息
    this.UpdataMathInfo(data)
    --游戏未开始时，隐藏按钮
    if not LYCRoomData.IsGameStarted() then
        --隐藏自动翻牌开关
        LYCRoomPanel.HideAutoFlip()
        --隐藏操作按钮
        LYCOperationPanel.SetOperationBtnActive(false)
    else
        --判断是否显示自动翻牌按钮
        if LYCRoomData.CheckHaveSelfData() then
            if not LYCRoomData.GetSelfIsNoReady() then
                --显示自动翻牌开关
                LYCRoomPanel.ShowAutoFlip()
            end
        end
    end
end

--显示比赛信息
function LYCRoomCtrl.UpdataMathInfo(data)
    --设置房间类型
    LYCRoomPanel.SetGameTypeText(LYCRoomData.gameName)
    --设置底分
    LYCRoomPanel.SetDiFenText(LYCRoomData.diFen)
    --设置房间号
    LYCRoomPanel.SetRoomCodeText(LYCRoomData.roomCode)
    --设置局数
    LYCRoomPanel.SetJuShuText(LYCRoomData.gameIndex, LYCRoomData.gameTotal)
    --设置码宝次数
    LYCRoomPanel.SetMaBaoText(LYCRoomData.maBaoCount)
    --设置抢庄分数
    LYCRoomPanel.SetQZFSText(LYCRoomData.QZFSCount)
    ---更新奖池显示
    --LYCRoomData.UpdateAwardPoolCoinNum(data.reward.awardPoolNum)
    ---更新获奖记录
    --LYCRoomData.UpdateRewardRecord(data.reward.lastReward)
end

function LYCRoomCtrl.OnAwardPoolBtnClick()
    LogError('???????????????????')
    PanelManager.Open(LYCPanelConfig.AwardPool)
end

----------------------------------------------------------------
--! 初始化右上角的wifi，电量，以及时间信息
function LYCRoomCtrl.InitRightTopData()
    --时间
    LYCRoomPanel.SetTime()
    if IsNil(this.updateTimeTimer) then
        this.updateTimeTimer = Scheduler.scheduleGlobal(LYCRoomPanel.SetTime, 10)
    end
end

-- 退出房间
function LYCRoomCtrl.ExitRoom()
    Log("正在离开房间...")
    local args = { gameType = GameType.LYC }
    if LYCRoomData.isPlayback then
        if LYCRoomData.roomData.recordType == 2 then
            args.groupId = LYCRoomData.roomData.groupId
            args.playWayType = LYCRoomData.roomData.playWayType
            args.openType = DefaultOpenType.Tea
        else
            args.openType = DefaultOpenType.Record
        end
    elseif LYCRoomData.roomData then
        args.openType = LYCRoomData.roomData.roomType
        args.groupId = LYCRoomData.roomData.groupId
        args.playWayType = LYCRoomData.roomData.playWayType
    end

    GameSceneManager.SwitchGameScene(GameSceneType.Lobby, GameType.LYC, args)
end

function LYCRoomCtrl:OnDestroy()
    if not IsNil(this.updateTimeTimer) then
        Scheduler.unscheduleGlobal(this.updateTimeTimer)
        this.updateTimeTimer = nil
    end
    --是否可以点击语音按钮
    LYCRoomCtrl.isCanClick = true
    --语音Y轴偏移量
    LYCRoomCtrl.speechTouchY = 0

    LogError("<color=aqua>RemoveMsg LYCObserverSitDown</color>")
    RemoveMsg(LYCAction.LYCObserverSitDown, this.ResetAllPlayerUI)

    gameObject = nil
    transform = nil

    isActive = true

    allNetSprites = {}
end

return LYCRoomCtrl