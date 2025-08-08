SDBApiExtend = {}

---------------------------------------房间Tcp-----------------------
--进入游戏  请求userId(long，玩家ID),roomId(long 房间ID),img(string 头像)，username(string 名字)，sex(short,性别)
function SDBApiExtend.EnterGame(roomId, userId, line)
    if not SDBRoomData.isCandSend or SDBRoomData.isGameOver then
        return
    end
    local data = {
        roomId = roomId,
        userId = userId,
        line = line,
    }
    SendTcpMsg(SDBAction.SDB_CTS_JOIN_ROOM, data)
end

--坐下
function SDBApiExtend.SendSitDown()
    if not SDBRoomData.isCandSend or SDBRoomData.isGameOver then
        return
    end
    local data = {}
    SendTcpMsg(SDBAction.SDB_CTS_READY, data)
end

--开始游戏
function SDBApiExtend.SendStartGame()
    if not SDBRoomData.isCandSend or SDBRoomData.isGameOver then
        return
    end
    local data = {}
    SendTcpMsg(SDBAction.SDB_CTS_OPERATE_START_GAME, data)
end

--下注
function SDBApiExtend.SendBetState(score)
    if not SDBRoomData.isCandSend or SDBRoomData.isGameOver then
        return
    end
    local data = {
        score = score,
    }
    SendTcpMsg(SDBAction.SDB_CTS_OPERATE_BET_SCORE, data)
end

--要牌
function SDBApiExtend.SendGetCard(state)
    if not SDBRoomData.isCandSend or SDBRoomData.isGameOver then
        return
    end
    local data = {
        state = state
    }
    SendTcpMsg(SDBAction.SDB_CTS_OPERATE_GET_CARDS, data)
end

--抢庄
function SDBApiExtend.SendRobBanker(robnum)
    if not SDBRoomData.isCandSend or SDBRoomData.isGameOver then
        return
    end
    local data = {

        robnum = robnum
    }
    SendTcpMsg(SDBAction.SDB_CTS_OPERATE_ROB_BANKER, data)
end

--发起解散
function SDBApiExtend.SendDissolve()
    if not SDBRoomData.isCandSend or SDBRoomData.isGameOver then
        return
    end
    local data = {}
    SendTcpMsg(SDBAction.SDB_CTS_LAUNCH_DISSOLVE, data)
end

--操作解散
function SDBApiExtend.SendOperateDissolve(isOk)
    if not SDBRoomData.isCandSend or SDBRoomData.isGameOver then
        return
    end
    local data = {
        state = isOk
    }
    SendTcpMsg(SDBAction.SDB_CTS_OPERATE_DISSOLVE, data)
end

--请求玩家信息
function SDBApiExtend.SendPortionPlayerInfo()
    if not SDBRoomData.isCandSend or SDBRoomData.isGameOver then
        return
    end
    local data = {}
    SendTcpMsg(SDBAction.SDB_CTS_PORTION_PLYAER_INFO, data)
end

--发送离开
function SDBApiExtend.SendLeave(roomCode)
    if not SDBRoomData.isCandSend or SDBRoomData.isGameOver then
        return
    end
    local data = {
        roomId = roomCode
    }
    SendTcpMsg(SDBAction.SDB_CTS_LEAVE_ROOM, data)
end

--请求上局回顾
function SDBApiExtend.SendReview(roomCode, index)
    if not SDBRoomData.isCandSend or SDBRoomData.isGameOver then
        return
    end
    local data = {
        roomId = roomCode,
        index = index
    }
    SendTcpMsg(SDBAction.SDB_CTS_REVIEW, data)
end

--聊天消息
function SDBApiExtend.SendChat(msgType, shareFileID, time)
    if not SDBRoomData.isCandSend or SDBRoomData.isGameOver then
        return
    end
    local data = {
        msgType = msgType,
        shareFileID = shareFileID,
        time = time
    }
    SendTcpMsg(SDBAction.SDB_CHAT_MESSAGES, data)
end

return SDBApiExtend