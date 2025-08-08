CMD.Game.Mahjong = {}

--麻将桌子面板开启
CMD.Game.Mahjong.DeskPanelOpened = "MahjongDPO"
--麻将游戏开始
CMD.Game.Mahjong.GameBegin = "MahjongGB"
--流局特效播放完成
CMD.Game.Mahjong.LiuJuEffectFinished = "MahjongLJEF"
--更新换牌按钮
CMD.Game.Mahjong.UpdateChangeCardButton = "MahjongUCCB"
--换牌动画完成
CMD.Game.Mahjong.ChangeCardAnimCompleted = "MahjongCCAC"
--回放操作
CMD.Game.Mahjong.PlaybackOperate = "MahjongPO"

--================================================================
--麻将协议相关
--
CMD.Tcp.Mahjong = {}
--
--加入房间，固定的协议
CMD.Tcp.Mahjong.C2S_JoinRoom = 10002
CMD.Tcp.Mahjong.S2C_JoinRoom = 11002
--退出房间，固定的协议
CMD.Tcp.Mahjong.C2S_QuitRoom = 10003
CMD.Tcp.Mahjong.S2C_QuitRoom = 11003

--服务器推送退出房间
CMD.Tcp.Mahjong.Push_ExitRoom = 10101
--踢出房间，只会自己收到
CMD.Tcp.Mahjong.Push_KickRoom = 10105
--
--玩家数据，全部玩家、玩家增加、玩家减少
CMD.Tcp.Mahjong.Push_PlayerData = 10110
--玩家在线状态，在线、离线；
CMD.Tcp.Mahjong.Push_PlayerOnline = 10120
--
--
--准备
CMD.Tcp.Mahjong.C2S_Ready = 10131
--准备返回
CMD.Tcp.Mahjong.S2C_Ready = 10132
--准备推送
CMD.Tcp.Mahjong.Push_Ready = 10133
--服务器推送准备倒计时
CMD.Tcp.Mahjong.Push_ReadyCountDown = 10140
--
--
--玩家数据更新
CMD.Tcp.Mahjong.C2S_PlayerDataUpdate = 10151
--玩家数据更新返回
CMD.Tcp.Mahjong.S2C_PlayerDataUpdate = 10152
--玩家数据更新推送
CMD.Tcp.Mahjong.Push_PlayerDataUpdate = 10153
--
--解散
CMD.Tcp.Mahjong.C2S_Dismiss = 10161
--解散返回
CMD.Tcp.Mahjong.S2C_Dismiss = 10162
--解散推送
CMD.Tcp.Mahjong.Push_Dismiss = 10163
--解散操作
CMD.Tcp.Mahjong.C2S_DismissOperate = 10165
--解散操作返回
CMD.Tcp.Mahjong.S2C_DismissOperate = 10166
--
--
--取消托管
CMD.Tcp.Mahjong.C2S_CancelTrust = 10181
--取消托管返回
CMD.Tcp.Mahjong.S2C_CancelTrust = 10182
--
--比赛场积分请求
CMD.Tcp.Mahjong.C2S_MatchScore = 10183
--比赛场积分返回
CMD.Tcp.Mahjong.S2C_MatchScore = 10184
--
--
--游戏开始推送
CMD.Tcp.Mahjong.Push_GameBegin = 10200
--游戏结束推送
CMD.Tcp.Mahjong.Push_GameEnd = 10300
--游戏胡牌的结算
CMD.Tcp.Mahjong.Push_HuSettlement = 10301
--
--
-- 分数场匹配游戏返回大厅
CMD.Tcp.Mahjong.C2S_BackLobby = 10401
-- 分数场匹配游戏返回大厅返回
CMD.Tcp.Mahjong.S2C_BackLobby = 10402
--
--
--操作
CMD.Tcp.Mahjong.C2S_Operate = 10771
--
CMD.Tcp.Mahjong.S2C_Operate = 10772
--服务器推送
CMD.Tcp.Mahjong.Push_Operate = 10773
--换张服务器推送
CMD.Tcp.Mahjong.Push_ChangeCard = 10775
---通知杠牌可选
CMD.Tcp.Mahjong.Push_GangCanChoose = 10194


MahjongCommand = {}

--用于重连时检测是否还在房间中
function MahjongCommand.SendCheckAndJoinedRoom(callback, exitRoomCallback)
    BaseTcpApi.SendCheckIsInRoom(MahjongDataMgr.roomId, callback, GameType.Mahjong, MahjongPanelConfig.SingleSettlement, exitRoomCallback)
end

--进入房间
function MahjongCommand.SendJoinRoom()
    local data = {
        roomId = MahjongDataMgr.roomId,
        userId = UserData.GetUserId(),
        line = MahjongDataMgr.serverLine,
    }
    SendTcpMsg(CMD.Tcp.Mahjong.C2S_JoinRoom, data)
end
--
--准备
function MahjongCommand.SendReady()
    if MahjongDataMgr.isCandSend then
        local data = {
            ready = 1,
        }
        SendTcpMsg(CMD.Tcp.Mahjong.C2S_Ready, data)
    end
end
--
--发送数据
function MahjongCommand.SendPlayerDataUpdate(lng, lat)
    if MahjongDataMgr.isCandSend then
        local data = {
            gps = {
                lng = lng,
                lat = lat,
            }
        }
        SendTcpMsg(CMD.Tcp.Mahjong.C2S_PlayerDataUpdate, data)
    end
end
--
--退出房间
function MahjongCommand.SendQuitRoom()
    local data = {
        roomId = MahjongDataMgr.roomId,
    }
    SendTcpMsg(CMD.Tcp.Mahjong.C2S_QuitRoom, data)
end

--发送返回大厅，isMatch：0返回大厅, 1继续游戏
function MahjongCommand.SendBackLobby(isMatch)
    local data = {
        roomId = MahjongDataMgr.roomId,
        isMatch = isMatch,
    }
    SendTcpMsg(CMD.Tcp.Mahjong.C2S_BackLobby, data)
end

--发送打牌
function MahjongCommand.SendPlayCard(cardId)
    if MahjongDataMgr.isCandSend then
        local data = {
            type = MahjongOperateCode.CHU_PAI,
            from = 0,
            k1 = cardId,
            k2 = 0,
            k3 = 0,
            k4 = 0
        }
        SendTcpMsg(CMD.Tcp.Mahjong.C2S_Operate, data)
    end
end

--发送操作
function MahjongCommand.SendOperate(type, from, k1, k2, k3, k4)
    if MahjongDataMgr.isCandSend then
        local data = {
            type = type,
            from = from,
            k1 = k1,
            k2 = k2,
            k3 = k3,
            k4 = k4
        }
        SendTcpMsg(CMD.Tcp.Mahjong.C2S_Operate, data)
    end
end

--发送解散
function MahjongCommand.SendDismiss()
    local data = {
        id = MahjongDataMgr.roomId
    }
    SendTcpMsg(CMD.Tcp.Mahjong.C2S_Dismiss, data)
end

--发送解散操作，1同意、2拒绝
function MahjongCommand.SendDismissOperate(state)
    if MahjongDataMgr.isCandSend then
        local data = {
            id = MahjongDataMgr.roomId,
            state = state,
        }
        SendTcpMsg(CMD.Tcp.Mahjong.C2S_DismissOperate, data)
    end
end

--发送取消托管
function MahjongCommand.SendCancelTrust()
    if MahjongDataMgr.isCandSend then
        local data = {
            id = MahjongDataMgr.roomId,
        }
        SendTcpMsg(CMD.Tcp.Mahjong.C2S_CancelTrust, data)
    end
end

--发送取消托管
function MahjongCommand.SendGps(lng, lat, address)
    if MahjongDataMgr.isCandSend then
        local data = {
            lng = lng,
            lat = lat,
            adr = address,
        }
        SendTcpMsg(CMD.Tcp.C2S_Gps, data)
    end
end

--发送比赛场获取分数
function MahjongCommand.SendMatchScore()
    if MahjongDataMgr.isCandSend then
        local data = {}
        SendTcpMsg(CMD.Tcp.Mahjong.C2S_MatchScore, data)
    end
end 