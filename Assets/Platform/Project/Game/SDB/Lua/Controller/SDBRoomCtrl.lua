SDBRoomCtrl = Class("SDBRoomCtrl")
local this = SDBRoomCtrl

--是否可以点击语音按钮
this.isCanClick = true
--语音Y轴偏移量
this.speechTouchY = 0

--所有网络信号图片
local allNetSprites = {}

local gameObject
local transform
local isActive = true

function SDBRoomCtrl:Init(trans)
    transform = trans
    gameObject = transform.gameObject
    --注册监听语音事件
    SDBRoomPanel.voiceSpeech:Init(this.OnSpeechTouchDown, this.OnSpeechTouchUp, this.OnSpeechTouchMove)
end

-- 启动事件--
function SDBRoomCtrl:OnCreate()
    this.Open()
end

function SDBRoomCtrl.Open()
    SDBRoomPanel.HideSitDown()

    -- 初始化wifi等信息的获取
    this.InitRightTopData()

    isActive = true
end

--------------------------点击事件
--点击关闭回顾
function SDBRoomCtrl.OnClickHuiguMask()
    UIUtil.SetActive(SDBRoomPanel.Retrospect.gameObject, false)
end

--点击聊天
function SDBRoomCtrl.OnClickChat()
    if SDBRoomData.isPlayback then
        return
    end
    PanelManager.Open(PanelConfig.RoomChat, { isShield = true })
end

--点击菜单按钮
function SDBRoomCtrl.OnClickUpMenu()
    if SDBRoomData.isPlayback then
        return
    end
    SDBRoomPanel.SetMenuItemsActive(false)
    UIUtil.SetActive(SDBRoomPanel.menuDwon.gameObject, true)
    UIUtil.SetActive(SDBRoomPanel.menuUp.gameObject, false)
end

--点击展开菜单栏
function SDBRoomCtrl.OnClickDownMenu()
    if SDBRoomData.isPlayback then
        return
    end
    SDBRoomPanel.SetMenuItemsActive(true)
    UIUtil.SetActive(SDBRoomPanel.menuDwon.gameObject, false)
    UIUtil.SetActive(SDBRoomPanel.menuUp.gameObject, true)
end

--复制房间号
function SDBRoomCtrl.OnClickFuzhi(go)
    if SDBRoomData.isPlayback then
        return
    end
    local text = this.ShareDataStr()
    AppPlatformHelper.CopyText(text)
end

--点击规则按钮
function SDBRoomCtrl.OnClickRule(go)
    PanelManager.Open(SDBPanelConfig.RoomInfo)
end

--点击回顾
function SDBRoomCtrl.OnClickRetrospectBtn()
    if SDBRoomData.isPlayback then
        return
    end
    if SDBRoomData.IsGoldGame() then
        PanelManager.Open(SDBPanelConfig.GoldReview)
    else
        PanelManager.Open(SDBPanelConfig.Review)
    end
end

--点击设置
function SDBRoomCtrl.OnClickSetBtn()
    if SDBRoomData.isPlayback then
        return
    end
    PanelManager.Open(SDBPanelConfig.RoomSetup)
end

--点击离开
function SDBRoomCtrl.OnClickLeaveBtn()
    if SDBRoomData.isPlayback then
        return
    end
    --发送离开协议
    SDBApiExtend.SendLeave()
end

--点击解散
function SDBRoomCtrl.OnClickDismissBtn()
    if SDBRoomData.isPlayback then
        return
    end
    if SDBRoomData.GetSelfIsLook() and not SDBRoomData.MainIsOwner() then
        LogError("玩家未准备不能解散房间...............按键错误显示")
        return
    end

    --if SDBRoomData.IsGoldGame() then
    --    Toast.Show("匹配场无法解散房间")
    --    return
    --end

    local text = "是否退出房间？"
    if SDBRoomData.MainIsOwner() then
        text = "您是否确认解散房间？"
    end

    if SDBRoomData.GetSelfData().state ~= PlayerState.LookOn then
        if SDBRoomData.isCardGameStarted or SDBRoomData.gameIndex > 0 then
            text = "牌局已经开始，是否申请解散？"
        end
    end

    Alert.Prompt(text, function()
        SDBApiExtend.SendDissolve()
    end)
end

-- 点击玩家头像
function SDBRoomCtrl.OnClickPlayerHead(go, playerUI)
    if SDBRoomData.isPlayback then
        return
    end
    if playerUI.playerId ~= nil and playerUI.playerId ~= "" then
        local playerData = SDBRoomData.GetPlayerDataById(playerUI.playerId)
        local moneyType = MoneyType.Fangk
        if SDBRoomData.IsGoldGame() then
            moneyType = MoneyType.Gold
        end
        local arg = {
            name = playerData.name, --姓名
            sex = playerData.sex, --性别 1男 2 女
            id = playerData.id, --玩家id
            gold = playerData.playerScore, --元宝数量
            moneyType = moneyType, --货币类型
            limitScore = SDBRoomData.zhunru, --元宝场准入分数
            headUrl = playerData.playerHead, --头像链接
            isShowAdress = false,
        }
        LogError(" --游戏内不显示点击玩家头像界面 ")
        -- PanelManager.Open(PanelConfig.RoomUserInfo, arg)
    else
        LogError(">>>>>>>>>>>>>>>>>>   OnClickPlayerHead  playerUI.playerId  空")
    end
end

-- 点击准备按钮
function SDBRoomCtrl.OnClickReady(go)
    if SDBRoomData.isPlayback then
        return
    end
    SDBApiExtend.SendSitDown()
    SDBResourcesMgr.PlayGameOperSound(SDBGameSoundType.READY, SDBRoomData.mainId)
end

-- 房主开始游戏
function SDBRoomCtrl.OnClickStartBtn(go)
    if SDBRoomData.isPlayback then
        return
    end
    SDBApiExtend.SendStartGame()
end

--------------------------------------
--分享复制的文本内容
function SDBRoomCtrl.ShareDataStr()
    if SDBRoomData.isPlayback then
        return
    end
    local text = "【欢乐游戏】"
    local roomNameCode = SDBRoomData.roomCode
    local roomName = SDBRoomData.gameName
    local diFen = SDBRoomData.Bet
    local jushu = SDBRoomData.gameTotal
    local showStartType = SDBRoomData.showStartType
    local wanfa = SDBRoomData.gaoJiConfig
    local t = "房间号：" .. roomNameCode .. "，游戏：" .. roomName .. "，底分：" .. diFen .. "，局数" .. jushu .. "局，开始类型：" .. showStartType

    local ownerData = SDBRoomData.GetPlayerDataById(SDBRoomData.owner)
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
function SDBRoomCtrl.ShowUIByState()
    if SDBRoomData.GetSelfData() == nil then
        LogError(">>>>>>>>>>>>>> 自己的信息为nil")
        return
    end
    local pState = SDBRoomData.GetSelfData().state
    --判断自己是否准备  --没有准备的情况
    if pState == PlayerState.Ready then
        --已坐下
        this.SitDowned()
    elseif pState == PlayerState.LookOn then
        --旁观（未坐下）
        this.LookOn()
    elseif pState == PlayerState.Stand then
        --站立（未准备）
        this.NoReady()
    elseif pState == PlayerState.Gaming then
        --游戏中
        this.Gaming()
    end
end

--已坐下
function SDBRoomCtrl.SitDowned()
    this.CheckStartBtnActive()

    --处理提示语
    SDBContentTip.HandleSitDown()
    --隐藏坐下与准备按钮
    SDBRoomPanel.HideSitDown()

    SDBRoomPanel.HideCopyInvite()
    SDBRoomPanel.ShowChatVoice()

    local readPlayers = SDBRoomData.GetReadyPlayer()
    if readPlayers ~= nil and #readPlayers == 1 then
        SDBRoomPanel.SetStartBtnInteractable(false)
    end
end

--旁观，未坐下
function SDBRoomCtrl.LookOn()
    UIUtil.SetActive(SDBRoomPanel.readyBtn, false)

    SDBRoomPanel.ShowCopyInvite()

    this.CheckStartBtnActive()

    --提示语
    SDBContentTip.HandleLookOn()

    SDBRoomPanel.SetStartBtnInteractable(false)
end

--状态为未准备
function SDBRoomCtrl.NoReady()
    --显示准备按钮
    SDBContentTip.HandleSelfNoReady()
end

--游戏中
function SDBRoomCtrl.Gaming()
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>     状态为游戏中.............................")
    SDBRoomPanel.HideSitDown()
    UIUtil.SetActive(SDBRoomPanel.startBtn.gameObject, false)
    SDBRoomPanel.HideCopyInvite()
    SDBRoomPanel.ShowChatVoice()
    --关闭所有玩家准备图片
    SDBRoomPanel.HideAllReadyImge()
end

--检测是否可以激活开始按钮
function SDBRoomCtrl.CheckStartBtnActive()
    if not SDBRoomData.IsGoldGame() and SDBRoomData.MainIsOwner() and SDBRoomData.gameIndex == 0 and not SDBRoomData.isCardGameStarted then
        SDBRoomPanel.ShowStartBtn()
    else
        SDBRoomPanel.HideStartBtn()
    end
end
-- ---------------------------------------------------------------------------------------------
--显示可推注
function SDBRoomCtrl.ShowTuiZhu(playerIds)
    if not string.IsNullOrEmpty(playerIds) then
        this.UpdateTuiZhuImage(playerIds)
    end
end

--隐藏庄家可推注
function SDBRoomCtrl.HideTuizhu(playerId)
    local PlayerUI = SDBRoomData.GetPlayerUIById(playerId)
    if PlayerUI ~= nil then
        PlayerUI:SetTuiZhuImageActive(false)
    end
end

--检查显示庄
function SDBRoomCtrl.CheckZhuang()
    SDBRoomPanel.ShowZhuangImage()
    this.CheckZhuangJia()
end

-- 设置庄家信息
function SDBRoomCtrl.CheckZhuangJia()
    --是否开始游戏
    if SDBRoomData.isCardGameStarted and SDBRoomData.gameState == SDBGameState.RobBanker then
        for i = 1, #SDBRoomData.playerDatas do
            SDBRoomData.playerDatas[i]:ShowRobZhuangNum()
        end
    end
end

-- 更新推注状态
function SDBRoomCtrl.UpdateTuiZhuImage(arg)
    local tuizhuStrs = string.split(arg, ",")
    for i = 1, #tuizhuStrs do
        local playerId = tuizhuStrs[i]
        local playerItem = SDBRoomData.GetPlayerUIById(playerId)
        if playerItem ~= nil then
            playerItem:UpdateTuiZhuImage()
        end
    end
end

------------------------------------网络消息处理函数END------------------------------------------
-------------------------------------------------------------------------------------------------
--玩家离开后根据playerID移除玩家显示
function SDBRoomCtrl.RemovePlayerUI(leavePlayerID)
    local playerItem = SDBRoomData.GetPlayerUIById(leavePlayerID)
    if playerItem ~= nil then
        playerItem:Clear()
    end
end

--更新玩家座位
function SDBRoomCtrl.UpdatePlayersDisplay()
    --获取其他准备的玩家数据
    local playerDatas = SDBRoomData.playerDatas
    if IsTable(playerDatas) then
        local playerItems = SDBRoomPanel.GetAllPlayerItems()
        for i = 1, #playerItems do
            if IsTable(playerItems[i]) and playerItems[i].playerId ~= nil then
                playerItems[i]:SetActive(false)
            end
        end

        for i = 1, #playerDatas do
            if not SDBFuntions.IsNilOrZero(playerDatas[i].seatNumber) then
                this.UpdatePlayerUI(playerDatas[i])
            end
        end
    end
end

--玩家坐下后被调用
function SDBRoomCtrl.UpdatePlayerUI(playerData)
    if playerData ~= nil then
        local selfSeatNumber = SDBRoomData.GetSelfData().seatNumber
        local itemIndex = SDBFuntions.CalcLocalSeatByServerSeat(selfSeatNumber, playerData.seatNumber)
        local playerItem = SDBRoomPanel.GetPlayerItem(itemIndex)
        --设置玩家信息
        playerItem:SetUIByPlayerData(playerData.id)
        --显示观战中
        if SDBRoomData.isCardGameStarted and playerData.state == PlayerState.LookOn then
            playerItem:SetLookOnImageActive(true)
        end
        --更新聊天模块
        SDBRoom.UpdateChatPlayers(SDBRoomPanel.GetAllPlayerItems())
    end
end

--比牌结束
function SDBRoomCtrl.ThanCardEnd()
end

--处理初始化界面UI
function SDBRoomCtrl.InitRoomUI(data)
    --显示房间信息
    this.UpdataMathInfo()
end

--显示比赛信息
function SDBRoomCtrl.UpdataMathInfo()
    --设置房间类型
    SDBRoomPanel.SetGameTypeText(SDBRoomData.gameName)
    --设置模式与人数
    SDBRoomPanel.SetModeText(SDBRoomData.model)
    --设置倍率
    SDBRoomPanel.SetMulripleText(SDBRoomData.multiple)
    --设置房间号
    SDBRoomPanel.SetRoomCodeText(SDBRoomData.roomCode)
    --设置局数
    SDBRoomPanel.SetJuShuText(SDBRoomData.gameIndex .. "/" .. SDBRoomData.gameTotal)

    SDBRoomPanel.SetBaseScore(SDBRoomData.diFen)
    if not SDBRoomData.IsGoldGame() then
        --设置推注分
        SDBRoomPanel.SetBolusText(SDBRoomData.tuiZhu)
    end
end

----------------------------------------------------------------
--! 初始化右上角的wifi，电量，以及时间信息
function SDBRoomCtrl.InitRightTopData()
    --时间
    SDBRoomPanel.SetTime()
    if IsNil(this.updateTimeTimer) then
        this.updateTimeTimer = Scheduler.scheduleGlobal(SDBRoomPanel.SetTime, 10)
    end
end

-- 退出房间
function SDBRoomCtrl.ExitRoom()
    Waiting.Show("正在离开房间...")
    local args = { gameType = GameType.SDB }
    if SDBRoomData.isPlayback then
        if SDBRoomData.roomData.recordType == 2 then
            args.groupId = SDBRoomData.roomData.groupId
            args.playWayType = SDBRoomData.roomData.playWayType
            args.openType = DefaultOpenType.Record
        else
            args.openType = DefaultOpenType.Record
        end
    else
        args.openType = SDBRoomData.roomData.roomType
        args.groupId = SDBRoomData.roomData.groupId
        args.playWayType = SDBRoomData.roomData.playWayType
    end

    GameSceneManager.SwitchGameScene(GameSceneType.Lobby, GameType.SDB, args)
end

function SDBRoomCtrl:OnDestroy()
    if not IsNil(this.updateTimeTimer) then
        Scheduler.unscheduleGlobal(this.updateTimeTimer)
        this.updateTimeTimer = nil
    end
    --是否可以点击语音按钮
    SDBRoomCtrl.isCanClick = true
    --语音Y轴偏移量
    SDBRoomCtrl.speechTouchY = 0

    gameObject = nil
    transform = nil

    isActive = true

    allNetSprites = {}
end

return SDBRoomCtrl