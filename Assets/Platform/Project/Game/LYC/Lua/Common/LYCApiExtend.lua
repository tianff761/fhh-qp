LYCApiExtend = {}

---------------------------------------房间Tcp-----------------------
--进入游戏  请求userId(long，玩家ID),roomId(long 房间ID),img(string 头像)，username(string 名字)，sex(short,性别)
function LYCApiExtend.EnterGame(roomId, userId, line)
    if not LYCRoomData.isCandSend or LYCRoomData.isGameOver then
        return
    end
    local data = {
        roomId = roomId,
        userId = userId,
        line = line,
    }
    SendTcpMsg(LYCAction.LYC_CTS_JOIN_ROOM, data)
end

--准备 
function LYCApiExtend.SendReady()
    if not LYCRoomData.isCandSend or LYCRoomData.isGameOver then
        return
    end
    local data = {
        type = 2,
    }
    SendTcpMsg(LYCAction.LYC_CTS_READY, data)
end

function LYCApiExtend.SendSeatDownMsg()
    if not LYCRoomData.isCandSend or LYCRoomData.isGameOver then
        return
    end
    local data = {}
    SendTcpMsg(LYCAction.LYC_CTS_SEAT_DOWN, data)
end

--开始游戏
function LYCApiExtend.SendStartGame()
    if not LYCRoomData.isCandSend or LYCRoomData.isGameOver then
        return
    end
    local data = {}
    SendTcpMsg(LYCAction.LYC_CTC_GameStart, data)
end

--下注
function LYCApiExtend.SendBetState(score)
    if not LYCRoomData.isCandSend or LYCRoomData.isGameOver then
        return
    end
    local data = {
        betNum = score,
        operType = 2
    }
    SendTcpMsg(LYCAction.LYC_CTS_Operate, data)
end

--提示
function LYCApiExtend.SendTipCard(state)
    if not LYCRoomData.isCandSend or LYCRoomData.isGameOver then
        return
    end
    local data = {
        operType = 4
    }
    SendTcpMsg(LYCAction.LYC_CTS_Operate, data)
end

--亮牌
function LYCApiExtend.SendShowCard(state)
    if not LYCRoomData.isCandSend or LYCRoomData.isGameOver then
        return
    end
    local data = {
        operType = 3
    }
    SendTcpMsg(LYCAction.LYC_CTS_Operate, data)
end

--抢庄
function LYCApiExtend.SendRobBanker(robnum)
    if not LYCRoomData.isCandSend or LYCRoomData.isGameOver then
        return
    end
    local data = {
        operType = 1,
        robNum = robnum,
    }
    SendTcpMsg(LYCAction.LYC_CTS_Operate, data)
end

---发送玩家炸开
---@param bool boolean true表示炸开 false表示不炸开（庄家必炸）
function LYCApiExtend.SendPlayerBomb(bool)
    local args = {
        zha = bool
    }
    SendTcpMsg(LYCAction.LYC_CTS_PlayerBomb, args)
end

---发送玩家捞牌
---@param bool boolean true表示捞false则不
function LYCApiExtend.SendPlayerLaoPai(bool)
    local args = {
        lao = bool
    }
    SendTcpMsg(LYCAction.LYC_CTS_PlayerLaoPai, args)
end

---发送庄家选择比牌
---@param targetID number 比牌对象玩家ID
function LYCApiExtend.SendPlayerBiPai(targetID)
    local args = {
        target  = targetID
    }
    SendTcpMsg(LYCAction.LYC_CTS_PlayerBiPai, args)
end

--发起解散
function LYCApiExtend.SendDissolve(status)
    if not LYCRoomData.isCandSend or LYCRoomData.isGameOver then
        return
    end
    local data = { status = status }
    SendTcpMsg(LYCAction.LYC_CTS_DISSOLVE, data)
end

--房主发起解散
function LYCApiExtend.SendOwnerDissolve()
    if not LYCRoomData.isCandSend or LYCRoomData.isGameOver then
        return
    end
    local data = {}
    SendTcpMsg(LYCAction.LYC_CTS_Owner_DISSOLVE, data)
end


--操作解散
function LYCApiExtend.SendOperateDissolve(isOk)
    if not LYCRoomData.isCandSend or LYCRoomData.isGameOver then
        return
    end
    local data = {
        state = isOk
    }
    SendTcpMsg(LYCAction.LYC_CTS_OPERATE_DISSOLVE, data)
end

--请求玩家信息
function LYCApiExtend.SendPortionPlayerInfo()
    if not LYCRoomData.isCandSend or LYCRoomData.isGameOver then
        return
    end
    local data = {}
    SendTcpMsg(LYCAction.LYC_CTS_PORTION_PLYAER_INFO, data)
end

--发送离开
function LYCApiExtend.SendLeave(roomCode)
    if not LYCRoomData.isCandSend or LYCRoomData.isGameOver then
        return
    end
    local data = {
        roomId = roomCode
    }
    SendTcpMsg(LYCAction.LYC_CTS_LEAVE_ROOM, data)
end

--请求上局回顾
function LYCApiExtend.SendReview(roomCode, index)
    if not LYCRoomData.isCandSend or LYCRoomData.isGameOver then
        return
    end
    local data = {
        roomId = roomCode,
        index = index
    }
    SendTcpMsg(LYCAction.LYC_CTS_REVIEW, data)
end

--聊天消息
function LYCApiExtend.SendChat(msgType, shareFileID, time)
    if not LYCRoomData.isCandSend or LYCRoomData.isGameOver then
        return
    end
    local data = {
        msgType = msgType,
        shareFileID = shareFileID,
        time = time
    }
    SendTcpMsg(LYCAction.LYC_CHAT_MESSAGES, data)
end

return LYCApiExtend