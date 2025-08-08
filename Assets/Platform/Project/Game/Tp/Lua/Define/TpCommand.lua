CMD.Game.Tp = {}

--桌子面板开启
CMD.Game.Tp.DeskPanelOpened = "TpDPO"
--游戏开始
CMD.Game.Tp.GameBegin = "TpGB"
--回顾操作
CMD.Game.Tp.PlaybackOperate = "TpPO"
--操作检测
CMD.Game.Tp.OperateCheck = "TpOC"
--小结算
CMD.Game.Tp.Settlement = "TpSettle"
--小局重置
CMD.Game.Tp.Reset = "TpReset"


--================================================================
--协议相关
--
-- 消息列表
-- --进入游戏推送游戏信息
-- PUSH_GAME_MSG=105100
-- --玩家信息更新
-- PUSH_PLAYER_MSG=105101
-- --推送游戏状态
-- PUSH_GAME_STATUS=105102
-- --玩家发送准备
-- REQUEST_READY_MSG=105103
-- --广播准备消息
-- PUSH_READY_MSG=105104
-- --玩家操作
-- REQUEST_PLAYER_OPER=105105
-- --玩家操作广播
-- RESPOND_PLAYER_OPER=105106
-- --推动结算信息
-- PUSH_EACH_RESULT=105107
-- --离开房间个人推送
-- PUSH_EXIT_ROOM=105108
-- --通知玩家啊操作
-- PUSH_NOTOICE_OPER = 101509 
-- --通知玩家发牌
-- PUSH_NOTOICE_FAPAI = 101510

-- --房主开始请求 (可忽略)
-- FANGZHU_START_GAME=105120

-- --推送总结算信息
-- PUSH_LAST_RESULT=105121
-- --玩家请求加入游戏
-- REQUEST_JOIN_GAME=105122
-- --玩家请求加入游戏回复
-- RESPOND_JOIN_GAME=105123
-- --玩家请求坐下
-- REQUEST_SIT_DOWN =105124
-- --请求坐下返回
-- RESPOND_SIT_DOWN =105125

-- --返回游戏开始倒计时
-- PUSH_GAME_START =105126

-- --请求解散房间
-- REQUEST_DIS_ROOM=105150
-- --推送解散面板信息
-- PUSH_DIS_ROOM_MSG=105151
-- --玩家同意或拒绝解散
-- REQUEST_IS_AGREE_DIS=105152

CMD.Tcp.Tp = {}
--
--加入房间，固定的协议
CMD.Tcp.Tp.C2S_JoinRoom = 10002
CMD.Tcp.Tp.S2C_JoinRoom = 11002
--退出房间，固定的协议
CMD.Tcp.Tp.C2S_QuitRoom = 10003
CMD.Tcp.Tp.S2C_QuitRoom = 11003

--踢出房间，只会自己收到
CMD.Tcp.Tp.Push_KickRoom = 10105
--

--进入游戏推送游戏信息
CMD.Tcp.Tp.Push_Game = 105100
--玩家数据，全部玩家、玩家增加、玩家减少
CMD.Tcp.Tp.Push_PlayerData = 105101
--推送游戏状态
CMD.Tcp.Tp.Push_GameStatus = 105102
--
--准备
CMD.Tcp.Tp.C2S_Ready = 105103
--准备推送
CMD.Tcp.Tp.Push_Ready = 105104

--操作
CMD.Tcp.Tp.C2S_Operate = 105105
--服务器推送操作，某玩家操作过后的状态，或者进行了什么操作
CMD.Tcp.Tp.Push_Operate = 105106
--
--推送结算信息
CMD.Tcp.Tp.Push_SingleSettlement = 105107
--离开房间，个人推送
CMD.Tcp.Tp.Push_ExitRoom = 105108
--
--
--通知玩家操作，轮到某玩家操作
CMD.Tcp.Tp.Push_PlayerOperate = 105109
--通知玩家发牌，系统发的3轮牌
CMD.Tcp.Tp.Push_PlayerDeal = 105110

--
--房主开始请求
CMD.Tcp.Tp.C2S_StartGame = 105120
--推送总结算信息
CMD.Tcp.Tp.Push_TotalSettlement = 105121
--玩家请求加入游戏
CMD.Tcp.Tp.C2S_JoinGame = 105122
--玩家请求加入游戏回复
CMD.Tcp.Tp.S2C_JoinGame = 105123
--
--玩家请求坐下
CMD.Tcp.Tp.C2S_SitDown = 105124
--请求坐下返回
CMD.Tcp.Tp.S2C_SitDown = 105125
--
--推送游戏开始倒计时
CMD.Tcp.Tp.Push_GameStartCountdown = 105126

--请求解散房间
CMD.Tcp.Tp.C2S_Dismiss = 105150
--推送解散面板信息
CMD.Tcp.Tp.Push_Dismiss = 105151
--解散操作
CMD.Tcp.Tp.C2S_DismissOperate = 105152


TpCommand = {}

--用于重连时检测是否还在房间中
function TpCommand.SendCheckAndJoinedRoom(callback, exitRoomCallback)
    BaseTcpApi.SendCheckIsInRoom(TpDataMgr.roomId, callback, GameType.Tp, TpPanelConfig.SingleSettlement, exitRoomCallback)
end

--进入房间
function TpCommand.SendJoinRoom()
    local data = {
        roomId = TpDataMgr.roomId,
        userId = UserData.GetUserId(),
        line = TpDataMgr.serverLine,
    }
    SendTcpMsg(CMD.Tcp.Tp.C2S_JoinRoom, data)
end
--
--准备
function TpCommand.SendReady()
    if TpDataMgr.isCanSend then
        local data = {
            ready = 1,
        }
        SendTcpMsg(CMD.Tcp.Tp.C2S_Ready, data)
    end
end

--发送操作
function TpCommand.SendOperate(type, ig)
    LogError(">> TpCommand.SendOperate", type, ig)
    if TpDataMgr.isCanSend then
        local data = {
            opType = type,
            ig = ig or 0,
        }
        SendTcpMsg(CMD.Tcp.Tp.C2S_Operate, data)
    end
end

--房主开始请求
function TpCommand.SendStartGame()
    if TpDataMgr.isCanSend then
        local data = {}
        SendTcpMsg(CMD.Tcp.Tp.C2S_StartGame, data)
    end
end

--玩家请求加入游戏  中途加入
function TpCommand.SendJoinGame()
    if TpDataMgr.isCanSend then
        local data = {}
        SendTcpMsg(CMD.Tcp.Tp.C2S_JoinGame, data)
    end
end

--玩家请求坐下
function TpCommand.SendSitDown(take)
    if TpDataMgr.isCanSend then
        local data = {take = take}
        SendTcpMsg(CMD.Tcp.Tp.C2S_SitDown, data)
    end
end

--发送解散
function TpCommand.SendDismiss()
    local data = {
        id = TpDataMgr.roomId
    }
    SendTcpMsg(CMD.Tcp.Tp.C2S_Dismiss, data)
end

--发送解散操作，1同意、2拒绝
function TpCommand.SendDismissOperate(state)
    if TpDataMgr.isCanSend then
        local data = {
            id = TpDataMgr.roomId,
            isAgree = state,
        }
        SendTcpMsg(CMD.Tcp.Tp.C2S_DismissOperate, data)
    end
end

--玩家请求游戏内回顾
--txt 1 表示请求的是那种文字型的 0 表示默认的
function TpCommand.SendGameReview(ju, txt)
    if TpDataMgr.isCanSend then
        local data = {
            ju = ju,
            txt = txt or 0,
        }
        SendTcpMsg(CMD.Tcp.Tp.C2S_GameReview, data)
    end
end

--
--退出房间
function TpCommand.SendQuitRoom()
    local data = {
        roomId = TpDataMgr.roomId,
    }
    SendTcpMsg(CMD.Tcp.Tp.C2S_QuitRoom, data)
end

--请求奖池列表
function TpCommand.SendRewardPool()
    local data = {}
    SendTcpMsg(CMD.Tcp.Tp.C2S_RewardPool, data)
end

--请求获奖列表
function TpCommand.SendRewardList()
    local data = {}
    SendTcpMsg(CMD.Tcp.Tp.C2S_RewardList, data)
end

--请求实时数据
function TpCommand.SendRealRecord()
    local data = {}
    SendTcpMsg(CMD.Tcp.Tp.C2S_RealRecord, data)
end

--请求带入相关信息
function TpCommand.SendTakeMsg()
    local data = {}
    SendTcpMsg(CMD.Tcp.Tp.C2S_TakeMsg, data)
end

--请求补充筹码
function TpCommand.SendTakeAct(take)
    local data = {take = take}
    SendTcpMsg(CMD.Tcp.Tp.C2S_TakeAct, data)
end


--请求申请留座
function TpCommand.SendStayTable()
    local data = {}
    SendTcpMsg(CMD.Tcp.Tp.C2S_StayTable, data)
end

--请求申请回到座位
function TpCommand.SendBackTable()
    local data = {}
    SendTcpMsg(CMD.Tcp.Tp.C2S_BackTable, data)
end

--请求申请站起
function TpCommand.SendStandUp()
    local data = {}
    SendTcpMsg(CMD.Tcp.Tp.C2S_StandUp, data)
end