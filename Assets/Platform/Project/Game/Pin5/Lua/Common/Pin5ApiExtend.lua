Pin5ApiExtend = {}

---------------------------------------房间Tcp-----------------------
--进入游戏  请求userId(long，玩家ID),roomId(long 房间ID),img(string 头像)，username(string 名字)，sex(short,性别)
function Pin5ApiExtend.EnterGame(roomId, userId, line)
    if not Pin5RoomData.isCandSend or Pin5RoomData.isGameOver then
        return
    end
    local data = {
        roomId = roomId,
        userId = userId,
        line = line,
    }
    SendTcpMsg(Pin5Action.Pin5_CTS_JOIN_ROOM, data)
end

--准备 
function Pin5ApiExtend.SendReady()
    if not Pin5RoomData.isCandSend or Pin5RoomData.isGameOver then
        return
    end
    local data = {
        type = 2,
    }
    SendTcpMsg(Pin5Action.Pin5_CTS_READY, data)
end

function Pin5ApiExtend.SendSeatDownMsg()
    if not Pin5RoomData.isCandSend or Pin5RoomData.isGameOver then
        return
    end
    local data = {}
    SendTcpMsg(Pin5Action.Pin5_CTS_SEAT_DOWN, data)
end

--开始游戏
function Pin5ApiExtend.SendStartGame()
    if not Pin5RoomData.isCandSend or Pin5RoomData.isGameOver then
        return
    end
    local data = {}
    SendTcpMsg(Pin5Action.Pin5_CTC_GameStart, data)
end

--下注
function Pin5ApiExtend.SendBetState(score)
    if not Pin5RoomData.isCandSend or Pin5RoomData.isGameOver then
        return
    end
    local data = {
        betNum = score,
        operType = 2
    }
    SendTcpMsg(Pin5Action.Pin5_CTS_Operate, data)
end

--提示
function Pin5ApiExtend.SendTipCard(state)
    if not Pin5RoomData.isCandSend or Pin5RoomData.isGameOver then
        return
    end
    local data = {
        operType = 4
    }
    SendTcpMsg(Pin5Action.Pin5_CTS_Operate, data)
end

--亮牌
function Pin5ApiExtend.SendShowCard(state)
    if not Pin5RoomData.isCandSend or Pin5RoomData.isGameOver then
        return
    end
    local data = {
        operType = 3
    }
    SendTcpMsg(Pin5Action.Pin5_CTS_Operate, data)
end

--抢庄
function Pin5ApiExtend.SendRobBanker(robnum)
    if not Pin5RoomData.isCandSend or Pin5RoomData.isGameOver then
        return
    end
    local data = {
        operType = 1,
        robNum = robnum,
    }
    SendTcpMsg(Pin5Action.Pin5_CTS_Operate, data)
end

--发起解散
function Pin5ApiExtend.SendDissolve(status)
    if not Pin5RoomData.isCandSend or Pin5RoomData.isGameOver then
        return
    end
    local data = { status = status }
    SendTcpMsg(Pin5Action.Pin5_CTS_DISSOLVE, data)
end

--房主发起解散
function Pin5ApiExtend.SendOwnerDissolve()
    if not Pin5RoomData.isCandSend or Pin5RoomData.isGameOver then
        return
    end
    local data = {}
    SendTcpMsg(Pin5Action.Pin5_CTS_Owner_DISSOLVE, data)
end


--操作解散
function Pin5ApiExtend.SendOperateDissolve(isOk)
    if not Pin5RoomData.isCandSend or Pin5RoomData.isGameOver then
        return
    end
    local data = {
        state = isOk
    }
    SendTcpMsg(Pin5Action.Pin5_CTS_OPERATE_DISSOLVE, data)
end

--请求玩家信息
function Pin5ApiExtend.SendPortionPlayerInfo()
    if not Pin5RoomData.isCandSend or Pin5RoomData.isGameOver then
        return
    end
    local data = {}
    SendTcpMsg(Pin5Action.Pin5_CTS_PORTION_PLYAER_INFO, data)
end

--发送离开
function Pin5ApiExtend.SendLeave(roomCode)
    if not Pin5RoomData.isCandSend or Pin5RoomData.isGameOver then
        return
    end
    local data = {
        roomId = roomCode
    }
    SendTcpMsg(Pin5Action.Pin5_CTS_LEAVE_ROOM, data)
end

--请求上局回顾
function Pin5ApiExtend.SendReview(roomCode, index)
    if not Pin5RoomData.isCandSend or Pin5RoomData.isGameOver then
        return
    end
    local data = {
        roomId = roomCode,
        index = index
    }
    SendTcpMsg(Pin5Action.Pin5_CTS_REVIEW, data)
end

--聊天消息
function Pin5ApiExtend.SendChat(msgType, shareFileID, time)
    if not Pin5RoomData.isCandSend or Pin5RoomData.isGameOver then
        return
    end
    local data = {
        msgType = msgType,
        shareFileID = shareFileID,
        time = time
    }
    SendTcpMsg(Pin5Action.Pin5_CHAT_MESSAGES, data)
end

return Pin5ApiExtend