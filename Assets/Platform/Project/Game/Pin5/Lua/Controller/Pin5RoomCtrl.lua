Pin5RoomCtrl = Class("Pin5RoomCtrl")
local this = Pin5RoomCtrl

--是否可以点击语音按钮
this.isCanClick = true
--语音Y轴偏移量
this.speechTouchY = 0

--所有网络信号图片
local allNetSprites = {}

local gameObject
local transform
local isActive = true

function Pin5RoomCtrl:Init(trans)
    transform = trans
    gameObject = transform.gameObject
    --注册监听语音事件
    Pin5RoomPanel.voiceSpeech:Init(this.OnSpeechTouchDown, this.OnSpeechTouchUp, this.OnSpeechTouchMove)
end

-- 启动事件--
function Pin5RoomCtrl:OnCreate()
    this.Open()
end

function Pin5RoomCtrl.Open()
    Pin5RoomPanel.HideReadyBtn()

    -- 初始化wifi等信息的获取
    this.InitRightTopData()

    isActive = true
    this.InitAutoFlip()
    LogError("<color=aqua>AddMsg Pin5ObserverSitDown</color>")
    AddMsg(Pin5Action.Pin5ObserverSitDown, this.ResetAllPlayerUI)
end

function Pin5RoomCtrl.InitAutoFlip()
    --Pin5RoomData.isAutoFlipCard = PlayerPrefs.GetInt("AutoFlip") == 1 and true or false
    Pin5RoomData.isAutoFlipCard = false
end

--------------------------点击事件
--点击关闭回顾
function Pin5RoomCtrl.OnClickHuiguMask()
    UIUtil.SetActive(Pin5RoomPanel.Retrospect.gameObject, false)
end

--点击聊天
function Pin5RoomCtrl.OnClickChat()
    if Pin5RoomData.isPlayback then
        return
    end
    --Pin5OperationPanel.ShowRubCard(302, {502, 502, 502, 502}, nil)--测试搓牌使用
    PanelManager.Open(PanelConfig.RoomChat, { isShield = true })
end

--点击菜单按钮
function Pin5RoomCtrl.OnClickUpMenu()
    if Pin5RoomData.isPlayback then
        return
    end
    Pin5RoomPanel.SetMenuItemsActive(false)
    UIUtil.SetActive(Pin5RoomPanel.menuDwon, true)
    UIUtil.SetActive(Pin5RoomPanel.menuUp, false)
end

--点击展开菜单栏
function Pin5RoomCtrl.OnClickDownMenu()
    if Pin5RoomData.isPlayback then
        return
    end
    Pin5RoomPanel.SetMenuItemsActive(true)
    UIUtil.SetActive(Pin5RoomPanel.menuDwon, false)
    UIUtil.SetActive(Pin5RoomPanel.menuUp, true)
end

--复制房间号
function Pin5RoomCtrl.OnClickFuzhi(go)
    if Pin5RoomData.isPlayback then
        return
    end
    local text = this.ShareDataStr()
    AppPlatformHelper.CopyText(text)
end

--点击规则按钮
function Pin5RoomCtrl.OnClickRule(go)
    PanelManager.Open(Pin5PanelConfig.RoomInfo)
end

--点击观战列表弹窗按钮
function Pin5RoomCtrl.OnClickWatcherListBtn(go)
    PanelManager.Open(Pin5PanelConfig.Pin5WatcherList)
end

--点击回顾
function Pin5RoomCtrl.OnClickRetrospectBtn()
    if Pin5RoomData.isPlayback then
        return
    end
    if Pin5RoomData.IsGoldGame() then
        PanelManager.Open(Pin5PanelConfig.GoldReview)
    else
        PanelManager.Open(Pin5PanelConfig.Review)
    end
end

--点击设置
function Pin5RoomCtrl.OnClickSetBtn()
    if Pin5RoomData.isPlayback then
        return
    end
    PanelManager.Open(Pin5PanelConfig.RoomSetup)
end

--点击离开
function Pin5RoomCtrl.OnClickLeaveBtn()
    if Pin5RoomData.isPlayback then
        return
    end
    --发送离开协议
    Pin5ApiExtend.SendLeave()
end

--点击离开置灰按钮
function Pin5RoomCtrl.OnClickGreyLeaveBtn()
    Toast.Show("游戏已开始,无法中途退出")
end


--点击解散
function Pin5RoomCtrl.OnClickDismissBtn()
    if Pin5RoomData.isPlayback then
        return
    end

    -- if Pin5RoomData.IsGoldGame() then
    --     Toast.Show("匹配场无法解散房间")
    --     return
    -- end

    local text = "是否退出房间？"
    if Pin5RoomData.MainIsOwner() then
        text = "您是否确认解散房间？"
    end

    if Pin5RoomData.IsGameStarted() then
        text = "牌局已经开始，是否申请解散？"
    end

    Alert.Prompt(text, function()
        if Pin5RoomData.MainIsOwner() then
            if Pin5RoomData.IsGameStarted() then
                Pin5ApiExtend.SendDissolve(-1)
            else
                Pin5ApiExtend.SendOwnerDissolve()
            end
        else
            Pin5ApiExtend.SendDissolve(-1)
        end
    end)
end

-- 点击玩家头像
function Pin5RoomCtrl.OnClickPlayerHead(go, playerUI)
    if Pin5RoomData.isPlayback then
        return
    end
    if playerUI.playerId ~= nil and playerUI.playerId ~= "" then
        local playerData = Pin5RoomData.GetPlayerDataById(playerUI.playerId)
        local moneyType = MoneyType.Fangka
        if Pin5RoomData.IsGoldGame() then
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
            limitScore = Pin5RoomData.zhunru, --元宝场准入分数
            headUrl = playerData.playerHead, --头像链接
            isShowAdress = false,
        }
        LogError(" 拼5--游戏内不显示点击玩家头像界面 ")
        -- PanelManager.Open(PanelConfig.RoomUserInfo, arg)
    else
        LogError(">>>>>>>>>>>>>>>>>>   OnClickPlayerHead  playerUI.playerId  空")
    end
end

-- 点击准备按钮
function Pin5RoomCtrl.OnClickReady(go)
    if Pin5RoomData.isPlayback then
        return
    end
    Pin5ApiExtend.SendReady()
    Pin5ResourcesMgr.PlayGameOperSound(Pin5GameSoundType.READY, Pin5RoomData.mainId)
end

-- 房主开始游戏
function Pin5RoomCtrl.OnClickStartBtn(go)
    if Pin5RoomData.isPlayback then
        return
    end
    Pin5ApiExtend.SendStartGame()
end

function Pin5RoomCtrl.OnClickSitDownBtn()
    if Pin5RoomData.isPlayback then
        return
    end
    Pin5ApiExtend.SendSeatDownMsg()
end

--------------------------------------------------------------------
--设置是否自动翻牌
function Pin5RoomCtrl.OnAutoFlipToggle(isOn)
    Pin5RoomData.isAutoFlipCard = isOn
    PlayerPrefs.SetInt("AutoFlip", isOn and 1 or 0)
end
--------------------------------------
--分享复制的文本内容
function Pin5RoomCtrl.ShareDataStr()
    if Pin5RoomData.isPlayback then
        return
    end
    local text = "【欢乐游戏】"
    local roomNameCode = Pin5RoomData.roomCode
    local roomName = Pin5RoomData.gameName
    local diFen = Pin5RoomData.diFen
    local jushu = Pin5RoomData.gameTotal
    local showStartType = Pin5RoomData.showStartType
    local wanfa = Pin5RoomData.gaoJiConfig
    local t = "房间号：" .. roomNameCode .. "，游戏：" .. roomName .. "，底分：" .. diFen .. "，局数" .. jushu .. "局，开始类型：" .. showStartType

    local ownerData = Pin5RoomData.GetPlayerDataById(Pin5RoomData.owner)
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
function Pin5RoomCtrl.ShowUIByState()
    if Pin5RoomData.GetSelfData() == nil then
        LogError(">>>>>>>>>>>>>> 自己的信息为nil")
        return
    end
    local pState = Pin5RoomData.GetSelfData().state
    --判断自己是否准备  --没有准备的情况
    if pState == Pin5PlayerState.WAITING or pState == Pin5PlayerState.NO_READY then
        --未坐下（未准备）
        if Pin5RoomData.isCardGameStarted then
            this.LookOn()
        else
            this.NoReady()
        end
        if pState == Pin5PlayerState.WAITING then
            Pin5RoomPanel.ShowCopyInvite()
        end
    elseif pState == Pin5PlayerState.READY or pState == Pin5PlayerState.WAITING_START then
        --坐下（准备）
        this.SitDowned()
    elseif pState == Pin5PlayerState.WAIT or pState == Pin5PlayerState.OPTION then
        --游戏中
        this.Gaming()
    end
end

--已坐下
function Pin5RoomCtrl.SitDowned()
    this.CheckStartBtnActive()
    --隐藏准备按钮
    Pin5RoomPanel.HideReadyBtn()

    Pin5RoomPanel.HideCopyInvite()
    Pin5RoomPanel.ShowChatVoice()

    --local readPlayers = Pin5RoomData.GetReadyPlayer()
    --if readPlayers ~= nil and #readPlayers == 1 then
    --    Pin5RoomPanel.SetStartBtnInteractable(false)
    --end
end

--旁观，未坐下
function Pin5RoomCtrl.LookOn()
    this.CheckStartBtnActive()
    --提示语
    -- Pin5ContentTip.HandleLookOn()
end

--状态为未准备
function Pin5RoomCtrl.NoReady()
    --显示准备
    Pin5ContentTip.HandleSelfNoReady()
    --检测是否能够显示开始按钮
    this.CheckStartBtnActive()
end

--游戏中
function Pin5RoomCtrl.Gaming()
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>     状态为游戏中.............................")
    Pin5RoomPanel.HideReadyBtn()
    UIUtil.SetActive(Pin5RoomPanel.startBtn.gameObject, false)
    Pin5RoomPanel.HideCopyInvite()
    Pin5RoomPanel.ShowChatVoice()
    --关闭所有玩家准备图片
    Pin5RoomPanel.HideAllReadyImge()
end

--检测是否可以激活开始按钮
function Pin5RoomCtrl.CheckStartBtnActive()
    if Pin5RoomData.IsFangKaFlow() and Pin5RoomData.MainIsOwner() and Pin5RoomData.isFrist and not Pin5RoomData.IsGameStarted() then
        if Pin5RoomData.GetSelfData().state ~= Pin5PlayerState.WAITING then
            Pin5RoomPanel.ShowStartBtn(true)
        else
            Pin5RoomPanel.ShowStartBtn(false)
        end
    else
        Pin5RoomPanel.HideStartBtn()
    end
end
-- ---------------------------------------------------------------------------------------------
--检查显示庄
function Pin5RoomCtrl.CheckZhuang()
    --Pin5RoomPanel.CheckBankerTag()
    this.CheckZhuangJia()
end


-- 设置庄家信息
function Pin5RoomCtrl.CheckZhuangJia()
    --是否开始游戏
    if Pin5RoomData.isCardGameStarted and Pin5RoomData.gameState == Pin5GameState.ROB_ZHUANG then
        for i = 1, #Pin5RoomData.playerDatas do
            Pin5RoomData.playerDatas[i]:ShowRobBankerMultiple()
        end
    end
end
------------------------------------网络消息处理函数END------------------------------------------
-------------------------------------------------------------------------------------------------
--玩家离开后根据playerID移除玩家显示
function Pin5RoomCtrl.RemovePlayerUI(leavePlayerID)
    local playerItem = Pin5RoomData.GetPlayerItemById(leavePlayerID)
    if playerItem ~= nil then
        playerItem:Clear()
    end
end

function Pin5RoomCtrl.ResetAllPlayerUI()
    LogError("<color=aqua>ResetAllPlayerUI</color>")
    local playerItems = Pin5RoomPanel.GetAllPlayerItems()
    for i = 1, #playerItems do
        playerItems[i]:Clear()
    end
    LogError("<color=aqua>playerItems</color>", playerItems)
    this.UpdatePlayersDisplay()
end

--更新玩家座位
function Pin5RoomCtrl.UpdatePlayersDisplay()
    --获取其他准备的玩家数据
    local playerDatas = Pin5RoomData.playerDatas
    if IsTable(playerDatas) then
        local playerItems = Pin5RoomPanel.GetAllPlayerItems()
        for i = 1, #playerItems do
            if IsTable(playerItems[i]) and playerItems[i].playerId ~= nil then
                playerItems[i]:SetEmpty()
            end
        end

        LogError("playerDatas", playerDatas)
        for i = 1, #playerDatas do
            if not Pin5Funtions.IsNilOrZero(playerDatas[i].seatNumber) then
                this.UpdatePlayerUI(playerDatas[i])
            end
        end
    end
end

--玩家坐下后被调用
function Pin5RoomCtrl.UpdatePlayerUI(playerData)
    if playerData ~= nil then
        local selfSeatNumber = Pin5RoomData.GetSelfData().seatNumber
        --LogError("设置玩家UI 玩家ID", playerData.id, "自己的座位号", selfSeatNumber, "玩家座位号", playerData.seatNumber)
        local itemIndex = Pin5Funtions.CalcLocalSeatByServerSeat(selfSeatNumber, playerData.seatNumber)
        --LogError("设置玩家UI序列号", itemIndex)
        local playerItem = Pin5RoomPanel.GetPlayerItem(itemIndex)
        --设置玩家信息
        playerItem:SetPlayerData(playerData)
        --显示观战中
        if Pin5RoomData.isGameStarted and playerData.state == Pin5PlayerState.WAITING then
            playerItem:SetImgLookOnDisplay(true)
        else
            playerItem:SetImgLookOnDisplay(false)
        end
        --更新聊天模块
        Pin5Room.UpdateChatPlayers(Pin5RoomPanel.GetAllPlayerItems())
    end
end

--比牌结束
function Pin5RoomCtrl.ThanCardEnd()

end

--处理初始化界面UI
function Pin5RoomCtrl.InitRoomUI(data)
    --显示房间信息
    this.UpdataMathInfo(data)
    --游戏未开始时，隐藏按钮
    if not Pin5RoomData.IsGameStarted() then
        --隐藏自动翻牌开关
        Pin5RoomPanel.HideAutoFlip()
        --隐藏操作按钮
        Pin5OperationPanel.SetOperationBtnActive(false)
    else
        --判断是否显示自动翻牌按钮
        if Pin5RoomData.CheckHaveSelfData() then
            if not Pin5RoomData.GetSelfIsNoReady() then
                --显示自动翻牌开关
                Pin5RoomPanel.ShowAutoFlip()
            end
        end
    end
end

--显示比赛信息
function Pin5RoomCtrl.UpdataMathInfo(data)
    --设置房间类型
    Pin5RoomPanel.SetGameTypeText(Pin5RoomData.gameName)
    --设置底分
    Pin5RoomPanel.SetDiFenText(Pin5RoomData.diFen)
    --设置房间号
    Pin5RoomPanel.SetRoomCodeText(Pin5RoomData.roomCode)
    --设置局数
    Pin5RoomPanel.SetJuShuText(Pin5RoomData.gameIndex, Pin5RoomData.gameTotal)
    ---更新奖池显示
    Pin5RoomData.UpdateAwardPoolCoinNum(data.reward.awardPoolNum)
    ---更新获奖记录
    Pin5RoomData.UpdateRewardRecord(data.reward.lastReward)
end

function Pin5RoomCtrl.OnAwardPoolBtnClick()
    LogError('???????????????????')
    PanelManager.Open(Pin5PanelConfig.AwardPool)
end

----------------------------------------------------------------
--! 初始化右上角的wifi，电量，以及时间信息
function Pin5RoomCtrl.InitRightTopData()
    --时间
    Pin5RoomPanel.SetTime()
    if IsNil(this.updateTimeTimer) then
        this.updateTimeTimer = Scheduler.scheduleGlobal(Pin5RoomPanel.SetTime, 10)
    end
end

-- 退出房间
function Pin5RoomCtrl.ExitRoom()
    Waiting.Show("正在离开房间...")
    local args = { gameType = GameType.Pin5 }
    if Pin5RoomData.isPlayback then
        if Pin5RoomData.roomData.recordType == 2 then
            args.groupId = Pin5RoomData.roomData.groupId
            args.playWayType = Pin5RoomData.roomData.playWayType
            args.openType = DefaultOpenType.Tea
        else
            args.openType = DefaultOpenType.Record
        end
    elseif Pin5RoomData.roomData then
        args.openType = Pin5RoomData.roomData.roomType
        args.groupId = Pin5RoomData.roomData.groupId
        args.playWayType = Pin5RoomData.roomData.playWayType
    end

    GameSceneManager.SwitchGameScene(GameSceneType.Lobby, GameType.Pin5, args)
end

function Pin5RoomCtrl:OnDestroy()
    if not IsNil(this.updateTimeTimer) then
        Scheduler.unscheduleGlobal(this.updateTimeTimer)
        this.updateTimeTimer = nil
    end
    --是否可以点击语音按钮
    Pin5RoomCtrl.isCanClick = true
    --语音Y轴偏移量
    Pin5RoomCtrl.speechTouchY = 0

    LogError("<color=aqua>RemoveMsg Pin5ObserverSitDown</color>")
    RemoveMsg(Pin5Action.Pin5ObserverSitDown, this.ResetAllPlayerUI)

    gameObject = nil
    transform = nil

    isActive = true

    allNetSprites = {}
end

return Pin5RoomCtrl