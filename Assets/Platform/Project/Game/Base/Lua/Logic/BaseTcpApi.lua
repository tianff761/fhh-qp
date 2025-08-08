BaseTcpApi = {}
--检测的房间ID
BaseTcpApi.checkRoomId = nil
--检测是否强制更新
BaseTcpApi.isForceUpgrade = false
--当前进入模块附带参数
BaseTcpApi.curModuleArg = nil
--检测房间返回的数据
BaseTcpApi.checkRoomData = nil

local this = BaseTcpApi

function BaseTcpApi.Init()
    AddEventListener(CMD.Tcp.Push_Money, this.OnPushMoney)
    AddEventListener(CMD.Tcp.S2C_PlayerName, this.OnPlayerName)
    AddEventListener(CMD.Tcp.S2C_PlayerHead, this.OnPlayerHead)
    AddEventListener(CMD.Tcp.S2C_BindPhone, this.OnBindPhone)
    AddEventListener(CMD.Tcp.S2C_CreateRoom, this.OnCreateRoom)
    AddEventListener(CMD.Tcp.S2C_JoinRoom, this.OnJoinRoom)
    AddEventListener(CMD.Tcp.S2C_CheckRoom, this.OnCheckRoom)
    AddEventListener(CMD.Tcp.S2C_CheckIsInRoom, this.OnCheckIsInRoom)
    AddEventListener(CMD.Game.Reauthentication, this.OnReauthentication)
    --匹配相关
    AddEventListener(CMD.Tcp.LobbyMatchRes, this.OnQuickMatchRoom)
    --邀请加入俱乐部返回
    AddEventListener(CMD.Tcp.JoinGuildRes, this.OnJoinGuild)
    --主推退出俱乐部
    AddEventListener(CMD.Tcp.PushQuitGuild, this.OnQuitGuild)
    --主推后台创建俱乐部
    AddEventListener(CMD.Tcp.PushCreateGuild, this.OnCreateGuild)
    --主推后台解散俱乐部
    AddEventListener(CMD.Tcp.PushDissovleGuild, this.OnDissolveGuild)
    --红点相关
    AddEventListener(CMD.Tcp.S2C_HD, this.OnRedPointTips)
    AddEventListener(CMD.Tcp.Push_HD, this.OnPushRedPointTips)
    --监听主推广播的gps信息
    AddEventListener(CMD.Tcp.S2C_PushGps, this.OnPushGps)

    --监听修改头像申请结果通知
    AddEventListener(CMD.Tcp.S2C_playerHeadResult, this.OnPlayerHeadResult)

    --客服微信号监听
    AddEventListener(CMD.Tcp.S2C_GetServiceWeChat, this.OnTcpGetServiceWebchat)

    AddEventListener(CMD.Tcp.S2C_PushGamePrivacy, this.OnTcpPushGamePrivacy)
end

--================================================================
--
--断线重连重新认证成功
function BaseTcpApi.OnReauthentication()
    this.SendEnterModule(UserData.GetModuleType(), this.curModuleArg)
end

--货币推送
function BaseTcpApi.OnPushMoney(data)
    local tempData = data.data
    local value
    if tempData ~= nil then
        value = tempData[MoneyStrType.Fangka]
        if value ~= nil then
            UserData.SetRoomCard(value)
        end
        value = tempData[MoneyStrType.Gold]
        if value ~= nil then
            UserData.SetGold(tonumber(value))
        end
        value = tempData[MoneyStrType.Gift]
        if value ~= nil then
            UserData.SetGift(value)
        end
        SendEvent(CMD.Game.UpdateMoney)
    end
end

--玩家姓名
function BaseTcpApi.OnPlayerName(data)
    if data.code == 0 then
        Toast.Show("修改成功")
        UserData.SetName(data.data.newName)
        SendEvent(CMD.Game.UpdateUserInfo)
    end
end

--玩家头像
function BaseTcpApi.OnPlayerHead(data)
    if data.code == 0 then
        UserData.SetHeadUrl(data.data.newTx)
        SendEvent(CMD.Game.UpdateUserInfo)
    end
end

--手机号
function BaseTcpApi.OnBindPhone(data)
    if data.code == 0 then
        UserData.SetBindPhone(data.data.phoneNum)
    end
end
--================================================================
--
--检测和加入房间
--isAutoJoin 是否是自动加入
function BaseTcpApi.CheckAndJoinRoom(roomId, isForceUpgrade, isAutoJoin)
    if isForceUpgrade == nil then
        isForceUpgrade = true
    end
    this.isForceUpgrade = isForceUpgrade
    this.SendCheckRoom(roomId)
    if not GameSceneManager.IsRoomScene() then
        if isAutoJoin == true then
            Waiting.Show("进入房间中...")
        else
            Waiting.Show("加入房间中...")
        end
    end
end

--================================================================
--
--gameId 就是游戏类型GameType   roomtype:1钻石场   2元宝场
--游戏类型、规则对象、总人数、总局数、房间类型（大厅、俱乐部、茶馆）、货币类型（钻石、元宝）、消费配置ID、组织ID、支付类型（AA、房主付）
function BaseTcpApi.SendCreateRoom(gameType, rulesObj, playerTotal, gameTotal, roomType, moneyType, consumeId, groupId, payType, gps)
    if gps == nil then
        gps = 0
    end
    local data = {
        userId = UserData.GetUserId(), --玩家ID
        gameId = gameType, --游戏类型
        rules = ObjToJson(rulesObj), --规则对象字符串
        maxcount = playerTotal, --总人数
        maxjs = gameTotal, --总局数
        roomType = roomType, --房间类型（0大厅、1俱乐部、2茶馆）
        moneyType = moneyType, --货币类型（1钻石、2元宝）
        consumeId = consumeId, --消费配置ID
        groupId = groupId, --组织ID
        payType = payType, --支付类型（1房主付, 2AA）
        gps = gps,
    }
    SendTcpMsg(CMD.Tcp.C2S_CreateRoom, data)
end

--处理创建房间
--需要返回游戏类型，房间号，最低要求版本
function BaseTcpApi.OnCreateRoom(data)
    if data.code == 0 then
        local roomId = data.data.roomId
        if IsNumber(data.data.groupId) and data.data.groupId > 0 then
            if data.data.roomType == RoomType.Club then
                --俱乐部房间，不加入
                SendEvent(CMD.Game.CreateClubOrTeaRoomSucess, data)
            elseif data.data.roomType == RoomType.Tea then
                UserData.SetRoomId(roomId)
                this.CheckAndJoinRoom(roomId, true, true)
            end
        else
            UserData.SetRoomId(roomId)
            this.CheckAndJoinRoom(roomId, true, true)
        end
    elseif data.code == SystemErrorCode.HasRoom10019 then
        UserData.SetRoomId(data.data.roomId)
        this.CheckAndJoinRoom(data.data.roomId, true, true)
    elseif data.code == SystemErrorCode.HasRoomByMultiple then
        Toast.Show("请不要频繁创建")
    else
        Waiting.ForceHide()
        Toast.Show(SystemError.GetText(data.code))
    end
end

--
--发送加入房间协议
function BaseTcpApi.SendJoinRoom(roomId)
    local data = {
        userId = UserData.GetUserId(),
        roomId = roomId,
    }
    this.checkRoomId = roomId
    SendTcpMsg(CMD.Tcp.C2S_JoinRoom, data)
end

--处理加入房间协议
function BaseTcpApi.OnJoinRoom(data)
    if data.code == 0 then
        this.checkRoomId = nil
        local gameType = data.data.gameId
        local roomId = data.data.roomId
        local version = data.data.version

        Log(">> BaseTcpApi.OnJoinRoom > ", data)

        UserData.SetRoomId(roomId)

        --版本号再次对比
        local isUpgrade = false
        if version ~= nil then
            local localVersion = Functions.GetResVersion(gameType)
            isUpgrade = version > localVersion
        end

        this.CheckRoomDataGPS()

        local argsData = {
            gameType = gameType,
            roomId = roomId,
            groupId = data.data.groupId, --组织ID
            roomType = data.data.roomType, --房间类型
            moneyType = data.data.moneyType, --货币类型
            userId = UserData.GetUserId(),
            line = data.data.line, --逻辑服线路
            gps = gps, --Gps类型
        }

        --如果匹配面板存在就直接关闭，如果是茶馆房间提示修改
        if PanelManager.IsOpened(PanelConfig.GoldMatch) then
            PanelManager.Close(PanelConfig.GoldMatch)
            if argsData.roomType == RoomType.Tea then
                --该处使用房间类型来判断是否是匹配场
                Toast.Show("匹配成功")
            end
        end
        if not GameSceneManager.IsRoomScene() then
            Waiting.Show("进入房间中...")
        end

        if GameSceneManager.currGameScene.type ~= GameSceneType.Lobby then
            coroutine.start(function()
                coroutine.wait(2)
                if GameManager.IsCheckGameByForce(gameType, HandlerArgs(this.OnJoinRoomCheckGameCallback, argsData), isUpgrade) then
                    this.OnJoinRoomCheckGameCallback(argsData)
                end
            end)
        else
            if GameManager.IsCheckGameByForce(gameType, HandlerArgs(this.OnJoinRoomCheckGameCallback, argsData), isUpgrade) then
                this.OnJoinRoomCheckGameCallback(argsData)
            end
        end
    elseif data.code == SystemErrorCode.RoomIsNotExist10003 then
        if GameSceneManager.IsLoginScene() then
            --如果在登录界面提示房间不存在，直接清除房间号，进入大厅
            Toast.Show(SystemError.GetText(data.code))
            --清除房间号
            UserData.SetRoomId(0)
            --
            GameSceneManager.SwitchGameScene(GameSceneType.Lobby)
        else
            Alert.Show(SystemError.GetText(data.code))
            Waiting.ForceHide()
        end
    else
        Alert.Show(SystemError.GetText(data.code))
        Waiting.ForceHide()
    end
end

--加入房间资源检测
function BaseTcpApi.CheckRoomDataGPS()
    local gps = nil
    if this.checkRoomData ~= nil then
        gps = this.checkRoomData.gps
    end
    return gps
end
function BaseTcpApi.OnJoinRoomCheckGameCallback(argsData)
    if argsData ~= nil then
        GameSceneManager.SwitchGameScene(GameSceneType.Room, argsData.gameType, argsData)
    end
end

--进入房间错误处理
function BaseTcpApi.OnJoinRoomErrorAlert()
    if this.checkRoomId ~= nil then
        this.SendJoinRoom(this.checkRoomId)
    end
end

------------------------------------------------------------------
--主推退出俱乐部
function BaseTcpApi.OnQuitGuild()
    UserData.SetGuildId(0)
    Toast.Show("您已被踢出俱乐部")
    TeaData.HideAllTeaPanel()
end

function BaseTcpApi.OnDissolveGuild()
    UserData.SetGuildId(0)
    Toast.Show("俱乐部已被解散")
    TeaData.HideAllTeaPanel()
end

function BaseTcpApi.OnCreateGuild(data)
    -- body
    Log("主推创建俱乐部成功", data)
    Toast.Show("创建俱乐部成功")
    UserData.SetGuildId(data.data.guildId)

end

------------------------------------------------------------------
--红点返回
function BaseTcpApi.OnRedPointTips(data)
    if data.code == 0 then
        RedPointMgr.ParseRedPointsByData(data.data)
        ServiceChatMgr.SetRedPointData()
    end
end

--红点推送
function BaseTcpApi.OnPushRedPointTips(data)
    if data.code == 0 then
        RedPointMgr.AddRedPointData(data.data)
    end
end

--主推的gps信息
function BaseTcpApi.OnPushGps(data)
    if data.code == 0 then
        GPSModule.UpdateAllPlayersData(data.data.players)
        SendEvent(CMD.Game.UpdatePlayersGpsData)
    end
end

--主推的修改头像结果通知
function BaseTcpApi.OnPlayerHeadResult(data)
    Log("..........................3")
    if data.code == 0 then
        --设置状态
        UserData.SetHeadAuditing(false)
        --result:1成功，2失败
        if data.data.reuslt == 1 then
            UserData.SetHeadUrl(data.data.img)
            SendMsg(CMD.Game.UpdateUserInfo)
        end
    end
end
------------------------------------------------------------------
--
--发送根据房间号检测房间版本和游戏类型
function BaseTcpApi.SendCheckRoom(roomId)
    local data = {
        roomId = roomId,
        userId = UserData.GetUserId()
    }
    this.checkRoomId = roomId
    SendTcpMsg(CMD.Tcp.C2S_CheckRoom, data)
end

--处理房间检测返回
--游戏类型、最低要求版本
function BaseTcpApi.OnCheckRoom(data)
    if data.code == 0 then
        this.checkRoomData = data.data

        local gps = this.checkRoomData.gps
        if gps ~= nil and gps == GpsType.Force then
            GPSModule.CheckGpsEnabled(this.OnCheckGpsCompleted)
        else
            this.HandleCheckRoom()
        end
    elseif data.code == SystemErrorCode.RoomIsNotExist10003 then
        --加入房间不存在，在大厅就不处理，登录的时候特殊处理一次进入房间
        --
        if GameSceneManager.IsLoginScene() then
            --容错处理
            if this.checkRoomId == nil then
                this.SendJoinRoom(0)
            else
                this.SendJoinRoom(this.checkRoomId)
            end
        else
            Waiting.Hide()
            Alert.Show(SystemError.GetText(data.code))
        end
    else
        Waiting.Hide()
        Alert.Show(SystemError.GetText(data.code))
    end
end

--检测Gps
function BaseTcpApi.OnCheckGpsCompleted()
    if GPSModule.gpsEnabled then
        this.HandleCheckRoom()
    else
        Waiting.Hide()
        Alert.Prompt("该房间为强制定位房间，请开启GPS定位功能", this.OnGpsAlertCallback)
    end
end

--检测定位提示处理
function BaseTcpApi.OnGpsAlertCallback()
    AppPlatformHelper.OpenDeviceSetting()
end

--处理检测房间
function BaseTcpApi.HandleCheckRoom()
    if this.checkRoomData ~= nil then
        local gameType = this.checkRoomData.gameId
        local version = this.checkRoomData.version
        --资源检测处理
        local isUpgrade = false
        if version ~= nil then
            local localVersion = Functions.GetResVersion(gameType)
            isUpgrade = version > localVersion
        end

        --如果是强制更新资源，则提示明确
        if this.isForceUpgrade then
            if GameManager.IsCheckGameByForce(gameType, this.OnCheckRoomCheckGameCallback, isUpgrade) then
                this.OnCheckRoomCheckGameCallback()
            end
        else
            Waiting.ForceHide()
            if GameManager.IsCheckGame(gameType, this.OnCheckRoomCheckGameCallback, isUpgrade) then
                this.OnCheckRoomCheckGameCallback()
            end
        end
    end
end

--检测房间错误处理
function BaseTcpApi.OnCheckRoomErrorAlert()
    --是强制更新，表明来源需要强制性
    if this.checkRoomId ~= nil and this.isForceUpgrade then
        this.SendCheckRoom(this.checkRoomId)
    else
        Waiting.Hide()
    end
end

--检测游戏完成，就该进入房间
function BaseTcpApi.OnCheckRoomCheckGameCallback()
    if this.checkRoomId ~= nil then
        this.SendJoinRoom(this.checkRoomId)
    end
end

--================================================================
--快速匹配返回
function BaseTcpApi.OnQuickMatchRoom(data)
    GoldMacthMgr.HandleMatchRoom(data.code)
end

--获取匹配场人数
function BaseTcpApi.SendGetMatchNumber(teahouseIds)
    local data = {
        userId = UserData.GetUserId(),
        teahouseIds = teahouseIds,
    }
    SendTcpMsg(CMD.Tcp.GetMathcNumber, data)
    -- body
end
--获取匹配场关闭的底分
function BaseTcpApi.SendGetCloseMatchBaseCores()
    local data = {
        userId = UserData.GetUserId(),
        guildId = UserData.GetGuildId(),
    }
    SendTcpMsg(CMD.Tcp.GetGuildBaseCore, data)
end

-- 重置匹配场关闭的底分
function BaseTcpApi.SendResetCloseMatchBaseCores(scores)
    local data = {
        userId = UserData.GetUserId(),
        guildId = UserData.GetGuildId(),
        scoreClose = scores,
    }
    SendTcpMsg(CMD.Tcp.ResetGuildBaseCore, data)
end


--发送苹果订单号
function BaseTcpApi.SendReceipt(playerID, currBuyID, code)
    local data = {
        userId = playerID,
        productId = currBuyID,
        receipt = code,
    }
    SendTcpMsg(CMD.Tcp.C2S_Receipt, data)
end


----------------------------------
--检测玩家是否还有房间号
--回调(处理正常流程逻辑)
local checkRoomCallback = nil
--游戏类型
local checkRoomGameType = nil
--单局结算面板配置
local checkRoomSingleSettlementConfig = nil
--退出房间回调
local checkRoomExitCallback = nil
--检测玩家是否还有房间号，游戏中断线重连时，先检测玩家是否在房间中，如果在，则继续发生tcp的1002
function BaseTcpApi.SendCheckIsInRoom(roomId, callback, gameType, singleSettlementConfig, exitRoomCallback)
    checkRoomCallback = callback
    checkRoomGameType = gameType
    checkRoomSingleSettlementConfig = singleSettlementConfig
    checkRoomExitCallback = exitRoomCallback
    local data = {
        roomId = roomId,
        userId = UserData.GetUserId(),
    }
    SendTcpMsg(CMD.Tcp.C2S_CheckIsInRoom, data)
end

--检测玩家是否还有房间号返回处理，各个游戏都需要先在这里处理
function BaseTcpApi.OnCheckIsInRoom(data)
    if checkRoomGameType == nil then
        this.HandleCheckRoomCallback(data)
    else
        if GameSceneManager.IsRoomScene() then
            --有房间则回调到房间中
            if data.code == 0 and data.data.roomId > 0 then
                this.HandleCheckRoomCallback(data)
            else
                if PanelManager.IsOpened(PanelConfig.RoomGps) or PanelManager.IsOpened(PanelConfig.RoomGps) then
                    --Gps界面是开启的，且房间不存在，说明被踢出房间
                    Alert.Show("由于您未准备游戏，不在房间中，请返回大厅", checkRoomExitCallback)
                else
                    if checkRoomSingleSettlementConfig ~= nil and PanelManager.IsOpened(checkRoomSingleSettlementConfig) then
                        --结算面板开启，不提示
                        if PanelManager.IsOpened(PanelConfig.GoldMatch) then
                            --匹配面板开启，则继续匹配
                            SendEvent(CMD.Game.ContinueMatch)
                        end
                    else
                        PanelManager.Close(PanelConfig.GoldMatch)
                        Alert.Show("牌局已结束，返回大厅", checkRoomExitCallback)
                    end
                end
            end
        end
    end
    checkRoomCallback = nil
    checkRoomGameType = nil
    checkRoomSingleSettlementConfig = nil
    checkRoomExitCallback = nil
end

----检测玩家是否还有房间号处理回调
function BaseTcpApi.HandleCheckRoomCallback(data)
    if checkRoomCallback ~= nil then
        checkRoomCallback(data)
    end
end

----------------------------------
--
--1053 活动图片、奖励图片、系统公告
function BaseTcpApi.SendActivity(noticeType)
    local data = {
        userId = UserData.GetUserId(),
        noticeType = noticeType, -- 1代表主动请求系统公告 其他表示全部
    }
    SendTcpMsg(CMD.Tcp.C2S_Activity, data)
end
--1057发送小喇叭
function BaseTcpApi.SendTrumpet(msg)
    local data = {
        userId = UserData.GetUserId(),
        msg = msg
    }
    SendTcpMsg(CMD.Tcp.C2S_Trumpet, data)
end
--1055特殊牌型、小喇叭
function BaseTcpApi.SendNotice()
    local data = {
        userId = UserData.GetUserId(),
    }
    SendTcpMsg(CMD.Tcp.C2S_Notice, data)
end


--3001 请求大厅指定游戏战绩
function BaseTcpApi.SendRecordByGameId(gameId, curPage, count, day)
    day = day or 0
    local data = {
        userId = UserData.GetUserId(),
        gameId = gameId,
        page = curPage,
        num = count,
        day = day,
    }
    SendTcpMsg(CMD.Tcp_C2S_Record, data)
end

--联盟和俱乐部所有战绩
function BaseTcpApi.SendGroupAllRecord(gameId, groupId, roomType, curPage, count, day)
    day = day or 0
    local data = {
        userId = UserData.GetUserId(),
        gameId = gameId,
        page = curPage,
        num = count,
        option = roomType,
        keyId = groupId,
        day = day,
    }
    SendTcpMsg(CMD.Tcp_C2S_GroupAllRecord, data)
end

--联盟和俱乐部个人战绩
function BaseTcpApi.SendGroupMyRecord(gameId, groupId, roomType, curPage, count, day)
    day = day or 0
    local data = {
        userId = UserData.GetUserId(),
        gameId = gameId,
        page = curPage,
        num = count,
        option = roomType,
        keyId = groupId,
        day = day,
    }
    SendTcpMsg(CMD.Tcp_C2S_GroupMyRecord, data)
end

---请求子战绩
function BaseTcpApi.SendRequestSubRecord(roomId, unionId, gameId, page, num)
    local data = {
        roomId = roomId,
        unionId = unionId,
        gameId = gameId,
        page = page,
        num = num
    }
    SendTcpMsg(CMD.Tcp_C2S_SubRecord, data)
end


--3005 请求大厅指定游戏战绩详情
--gameId 游戏类型id
function BaseTcpApi.SendRecordDetailByroomId(gameId, onlyRoomId, inning, keyId, option)
    local data = {
        userId = UserData.GetUserId(),
        gameId = gameId,
        roomId = onlyRoomId,
        inning = inning,
        keyId = keyId,
        option = option,
    }
    SendTcpMsg(CMD.Tcp_C2S_RecordDetail, data)
end

--4100 获得付费头像框列表
function BaseTcpApi.SendHeadBoxList()
    local data = {
        userId = UserData.GetUserId(),

    }
    SendTcpMsg(CMD.Tcp.GetHeadBoxList, data)
end


--4102 修改当前使用的头像框
function BaseTcpApi.SendEditorHeadBox(txkId)
    local data = {
        userId = UserData.GetUserId(),
        txkId = txkId,
    }
    SendTcpMsg(CMD.Tcp.EditorHeadBox, data)
end

--4300 大厅匹配
function BaseTcpApi.SendGameMatch(matchId, lat, lng)
    local data = {
        userId = UserData.GetUserId(),
        teahouseId = matchId,
        lat = lat,
        lng = lng,
    }
    SendTcpMsg(CMD.Tcp.LobbyMatch, data)
end

--4302 取消匹配
function BaseTcpApi.SendCancelMatch()
    local data = {}
    SendTcpMsg(CMD.Tcp.CancelMatch, data)
end

-- 4306 匹配场列表
function BaseTcpApi.SendGetMatchList()
    local data = {
        guildId = UserData.GetGuildId()
    }
    SendTcpMsg(CMD.Tcp.GetMatchList, data)
end

--4308 匹配场次操作
function BaseTcpApi.SendMatchOpera(matchGameIds)
    local data = {
        guildId = UserData.GetGuildId(),
        pipeiGameIds = matchGameIds,
    }
    SendTcpMsg(CMD.Tcp.MatchListOpera, data)
end

--6100 请求转盘奖品
function BaseTcpApi.SendLuckyWheel()
    local data = {
        userId = UserData.GetUserId(),
    }
    SendTcpMsg(CMD.Tcp_C2S_LuckyWheel, data)
end

--6102 请求签到数据
function BaseTcpApi.SendGetSignIn()
    local data = {
        userId = UserData.GetUserId(),
    }
    SendTcpMsg(CMD.Tcp_C2S_GetSignIn, data)
end

--6104 签到
function BaseTcpApi.SendSignIn()
    local data = {
        userId = UserData.GetUserId(),
    }
    SendTcpMsg(CMD.Tcp_C2S_SignIn, data)
end

-- 7000 发送手机号，获取验证码
function BaseTcpApi.SendGetBindVerfyCode(phoneNum)
    local data = {
        userId = UserData.GetUserId(),
        phone = phoneNum
    }
    SendTcpMsg(CMD.Tcp_C2S_GetBindVerfyCode, data)
end

-- 7002 发送验证码
function BaseTcpApi.SendBindPhone(phone, pwd, code)
    local data = {
        userId = UserData.GetUserId(),
        phone = phone,
        pwd = pwd,
        code = code
    }
    SendTcpMsg(CMD.Tcp_C2S_BindPhone, data)
end

-- 7004 发送实名认证
function BaseTcpApi.SendRealName()
    local data = {
        userId = UserData.GetUserId(),
    }
    SendTcpMsg(CMD.Tcp_C2S_RealName, data)
end

-- 7004 发送实名认证
function BaseTcpApi.SendPwdModify(pwd, newPwd)
    local data = {
        userId = UserData.GetUserId(),
        pwd = pwd,
        newPwd = newPwd
    }
    SendTcpMsg(CMD.Tcp_C2S_PwdModify, data)
end

--7100检测有没有小红点
function BaseTcpApi.SendGetRedPointInfo()
    local data = {
        userId = UserData.GetUserId(),
    }
    SendTcpMsg(CMD.Tcp.C2S_HD, data)
end

---------------------任务系统---------------------
--分享游戏任务
function BaseTcpApi.SendShareGameTask()
    local data = {
        userId = UserData.GetUserId(),
    }
    SendTcpMsg(CMD.Tcp.C2S_ShareGameTask, data)
end
--任务列表
function BaseTcpApi.SendGetTaskList(taskType)
    local data = {
        userId = UserData.GetUserId(),
        taskType = taskType,
    }
    SendTcpMsg(CMD.Tcp.C2S_GetListTask, data)
end
--领取任务奖励
function BaseTcpApi.SendDrawReward(taskId)
    local data = {
        userId = UserData.GetUserId(),
        taskId = taskId,
    }
    SendTcpMsg(CMD.Tcp.C2S_DrawReward, data)
end
--领取活跃度奖励
function BaseTcpApi.SendDrawActivity(activeScore)
    local data = {
        userId = UserData.GetUserId(),
        activeId = activeScore,
    }
    SendTcpMsg(CMD.Tcp.C2S_DrawActivity, data)
end
--选择任务类型
function BaseTcpApi.SendSlectTaskType(taskType)
    local data = {
        userId = UserData.GetUserId(),
        taskType = taskType,
    }
    SendTcpMsg(CMD.Tcp.C2S_SlectTasks, data)
end
--获取活跃度
function BaseTcpApi.SendGetActives()
    local data = {
        userId = UserData.GetUserId(),
    }
    SendTcpMsg(CMD.Tcp.C2S_ActiveList, data)
end
------------------
--进入模块
BaseTcpApi.curModuleArg = nil
function BaseTcpApi.SendEnterModule(moduleType, arg)
    local data = {
        userId = UserData.GetUserId(),
        moduleType = moduleType,
        arg = arg
    }
    this.curModuleArg = arg
    UserData.SetModuleType(moduleType)
    SendTcpMsg(CMD.Tcp.C2S_EnterModule, data)
end

function BaseTcpApi.OnJoinGuild(data)
    if not PanelManager.IsOpened(PanelConfig.JoinGuild) then
        if data.code == 0 then
            if data.data.statuts == 1 then
                Toast.Show("申请加入俱乐部成功，请耐心等待")
            else
                Toast.Show("您的俱乐部申请已被通过")
                UserData.SetGuildId(data.data.guildId)
            end
        else
            ErrorUtil.HandleTeaError(data.code)
        end
    end
    -- body
end
--Http请求
function BaseTcpApi.HttpRequest(url)
    Log(">>> 请求http:", url)
    local http = HttpRequest.New(url)
    http:AddListener(this.HttpResponse)
    http:Connect()
end

--Http返回
function BaseTcpApi.HttpResponse(data)
    Log("Http接收", data.code, data.text)
    if data.code == 0 then
        local jsonObj = nil
        local text = data.text
        if text ~= nil and text ~= "" then
            jsonObj = JsonToObj(text)
            Log("收到数据", jsonObj)
            SendEvent(jsonObj.cmd, jsonObj)
        else
            Toast.Show("网络错误，请稍后再试。")
        end
    elseif data.code == 2 then
        Toast.Show("网络超时，请稍后再试")
    else
        Toast.Show("网络错误，请稍后再试")
    end
end


--获取登录验证码
function BaseTcpApi.SendGetLoginVerifyCode(phone, type)
    AppConfig.GetAccountUrl(function(url)
        this.HttpRequest(url .. CMD.Http_C2S_GetLoginVerfyCode .. "&phone=" .. phone .. "&opType=" .. type)
    end)
end

--手机注册
function BaseTcpApi.SendPhoneRegister(phone, pwd, code, devId, type)
    AppConfig.GetAccountUrl(function(url)
        this.HttpRequest(url .. CMD.Http_C2S_PhoneRegister .. "&phone=" .. phone .. "&pwd=" .. pwd .. "&yzCode=" .. code .. "&devId=" .. devId .. "&opType=" .. type)
    end)
end

------------------外包---------------------
--获取验证码
function BaseTcpApi.SendGetCode(phoneNum)
    AppConfig.GetAccountUrl(function(url)
        this.HttpRequest(url .. CMD.Tcp.C2S_RegisterAccount .. "&phoneNum=" .. phoneNum .. "&devId=" .. GlobalData.platform.deviceId)
    end)
end

--注册账号
function BaseTcpApi.SendRegisterAccount(phoneNum, code, password)
    if password ~= nil then
        password = Util.md5(password)
    end
    AppConfig.GetAccountUrl(function(url)
        this.HttpRequest(url .. CMD.Tcp.C2S_RegisterAccount .. "&opType=2&phoneNum=" .. phoneNum .. "&devId=" .. GlobalData.platform.deviceId .. "&YZCode=" .. code .. "&pwd=" .. password)
    end)
end

--找回账号获取验证码
function BaseTcpApi.SendFindGetCode(phoneNum)
    AppConfig.GetAccountUrl(function(url)
        this.HttpRequest(url .. CMD.Tcp.C2S_FindAccount .. "&opType=1&phoneNum=" .. phoneNum)
    end)
end

--找回账号设置密码
function BaseTcpApi.SendFindAccount(phoneNum, code, password)
    if password ~= nil then
        password = Util.md5(password)
    end
    AppConfig.GetAccountUrl(function(url)
        this.HttpRequest(url .. CMD.Tcp.C2S_FindAccount .. "&opType=2&phoneNum=" .. phoneNum .. "&YZCode=" .. code .. "&pwd=" .. password)
    end)
end

--绑定手机获取验证码
function BaseTcpApi.SendBindPhoneGetCode(phoneNum)
    local data = {
        phoneNum = phoneNum
    }
    SendTcpMsg(CMD.Tcp.C2S_GetYZCode, data)
end

--绑定手机
-- function BaseTcpApi.SendBindPhone(phoneNum, code, password)
--     if password ~= nil then
--         password = Util.md5(password)
--     end
--     local data = {
--         YZCode = code,
--         phoneNum = phoneNum,
--         pwd = password
--     }
--     SendTcpMsg(CMD.Tcp.C2S_BindPhone, data)
-- end

--账号密码
function BaseTcpApi.SendAccountPassword(newPassword, oldPassword)
    if oldPassword ~= nil then
        oldPassword = Util.md5(oldPassword)
    end
    if newPassword ~= nil then
        newPassword = Util.md5(newPassword)
    end
    local data = {
        oldPWD = oldPassword,
        newPWD = newPassword
    }
    SendTcpMsg(CMD.Tcp.C2S_AccountPassword, data)
end

-- --设置性别
-- function BaseTcpApi.SendPlayerGender(gender)
--     local data = {
--         newSex = gender,
--     }
--     SendTcpMsg(CMD.Tcp.C2S_PlayerGender, data)
-- end
--设置头像
function BaseTcpApi.SendPlayerHead(url)
    local data = {
        newTx = url,
    }
    SendTcpMsg(CMD.Tcp.C2S_PlayerHead, data)
end

--设置名字
function BaseTcpApi.SendPlayerName(name)
    local data = {
        newName = name,
    }
    SendTcpMsg(CMD.Tcp.C2S_PlayerName, data)
end

--找回账号密码
function BaseTcpApi.SendFindAccountPwd(phoneNum, type, code, password)
    if password ~= nil then
        password = Util.md5(password)
    end
    local data = {
        opType = type,
        phoneNum = phoneNum,
        YZCode = code,
        pwd = password
    }
    SendTcpMsg(CMD.Tcp.C2S_FindAccountPwd, data)
end

---------------------------奖励池-------------------------
--
--请求获取奖励池数据
function BaseTcpApi.SendRequestRewardPool()
    local data = {}
    SendTcpMsg(CMD.Tcp.C2S_RewardPool, data)
end

--请求中奖玩家列表
function BaseTcpApi.SendRequestRewardPoolPlayerList()
    local data = {}
    SendTcpMsg(CMD.Tcp.C2S_RewardPoolPlayerList, data)
end

--------------------------头像-------------------------
--申请修改头像
function BaseTcpApi.SendSetPlayerHead(image)
    local data = {
        url = image,
    }
    SendTcpMsg(CMD.Tcp.C2S_SetPlayerHead, data)
end

--取消申请修改头像
function BaseTcpApi.SendCancelPlayerHead()
    local data = {}
    SendTcpMsg(CMD.Tcp.C2S_CancelPlayerHead, data)
end

------------------------获取微信客服号--------------------------------
function BaseTcpApi.SendGetServiceWebchat()
    local data = {}
    SendTcpMsg(CMD.Tcp.C2S_GetServiceWeChat, data)
end

--取消申请修改头像
function BaseTcpApi.OnTcpGetServiceWebchat(data)
    if data.code == 0 then
        GlobalData.serviceWebchat = data.data.list
    end
end
---------------------------------------------------------------------

------------------------是否开启隐私推送------------------------------

function BaseTcpApi.OnTcpPushGamePrivacy(data)
    if data.code == 0 then
        Functions.SetRoomPrivate(data.data.openPrivacy == 1)
    end
end
---------------------------------------------------------------------
-------------------------客服聊天----------------------------
--客服列表
function BaseTcpApi.SendGetServiceList(type, unionId)
    local data = {
        type = type,
        unionId = unionId
    }
    SendTcpMsg(CMD.Tcp.C2S_ServiceList, data)
end

--发送聊天信息 reId:接收者ID msgType:消息类型 msg:消息 time:发送时间
function BaseTcpApi.SendChatInfo(type, unionId, reId, msgType, msg, time)
    local data = {
        type = type,
        unionId = unionId,
        reId = reId,
        msgType = msgType,
        msg = msg,
        time = time
    }
    SendTcpMsg(CMD.Tcp.C2S_SendChat, data)
end

--请求玩家是否在线
function BaseTcpApi.SendPlayerStatus(ids)
    if GetTableSize(ids) > 0 then
        local data = {
            list = ids
        }
        SendTcpMsg(CMD.Tcp.C2S_PlayerStatus, data)
    end
end

---提交代理
---game 游戏 字符串
--area 区域 字符串
--phone 电话 字符串
--wechat 微信 字符串
function BaseTcpApi.SendAgent(game,area,phone,wechat)
    local args = {
        game = game,
        area = area,
        phone = phone,
        wechat = wechat,
    }
    SendTcpMsg(CMD.Tcp.C2S_Agent, args)
end