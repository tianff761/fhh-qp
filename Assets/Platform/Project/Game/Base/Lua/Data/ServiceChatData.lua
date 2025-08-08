ServiceChatData = {}
local this = ServiceChatData

--所有玩家缓存
this.playerDatas = {}
--所有发送成功的消息缓存
this.allMassegeDatas = {}
--发送消息队列
this.tempMassegeDatas = {}
--聊天目标玩家ID
this.playerId = 0
--当前联盟ID
this.curUnionId = 0
--类型 联盟：1 俱乐部：2
this.type = 0

--聊天消息类型
ChatMessageType = {
    --文本
    Text = 1,
    --图片
    Image = 2
}

FileMode = {
    CreateNew = 1,
    Create = 2,
    Open = 3,
    OpenOrCreate = 4,
    Truncate = 5,
    Append = 6
}


--根据玩家ID获取玩家数据
function ServiceChatData.GetPlayerDataByPlayerId(playerId, isFirst)
    local playerData = nil
    for i = 1, #this.playerDatas do
        if this.playerDatas[i].playerId == playerId then
            playerData = this.playerDatas[i]
            if isFirst then
                table.remove(this.playerDatas, i)
                table.insert(this.playerDatas, 1, playerData)
            end
            break
        end
    end
    if playerData == nil then
        playerData = this.NewPlayerData()
        if isFirst then
            table.insert(this.playerDatas, 1, playerData)
        else
            table.insert(this.playerDatas, playerData)
        end
    end
    return playerData
end
--------------------------------------------------------
--玩家对象
function ServiceChatData.NewPlayerData()
    local data = {
        playerId = 0,
        playerName = "",
        playerHeadUrl = "",
        isOnline = false,
        isUnread = false,
        lastSendTime = 0,
        isReadFile = false
    }
    return data
end

--聊天消息格式 --type消息类型 sendTime发送时间 sendPlayerName发送人 sendPlayerID发送人ID sendPlayerHeadUrl发送人头像 content内容
--receivePlayerID:接收人ID
function ServiceChatData.NewChatMassegeData(type, sendTime, sendPlayerID, sendPlayerName, sendPlayerHeadUrl, receivePlayerID, content)
    local data = {
        type = type,
        sendTime = sendTime,
        sendPlayerName = sendPlayerName,
        sendPlayerID = sendPlayerID,
        sendPlayerHeadUrl = sendPlayerHeadUrl,
        receivePlayerID = receivePlayerID,
        content = content,
    }
    return data
end

---------------------------------------------------
--获取聊天信息
function ServiceChatData.GetMassegeDatasByPlayerId(playerId)
    local massegeDatas = this.allMassegeDatas[playerId]
    if IsNil(massegeDatas) then
        massegeDatas = {}
        this.allMassegeDatas[playerId] = massegeDatas
    end
    return massegeDatas
end

--添加一条聊天信息
function ServiceChatData.AddMassegeDataByPlayerId(playerId, massegeData)
    local data = this.allMassegeDatas[playerId]
    if IsNil(data) then
        data = {}
        this.allMassegeDatas[playerId] = data
    end
    if #data >= 50 then
        table.remove(data, 1)
    end
    table.insert(data, massegeData)
end

--添加一条临时消息
function ServiceChatData.AddTempMassegeData(massegeData)
    table.insert(this.tempMassegeDatas, massegeData)
end

--移除一条临时消息
function ServiceChatData.RemoveTempMassegeDataBySendTime(sendTime)
    local massegeData = nil
    for i = 1, #this.tempMassegeDatas do
        if this.tempMassegeDatas[i].sendTime == sendTime then
            massegeData = this.tempMassegeDatas[i]
            table.remove(this.tempMassegeDatas, i)
            break
        end
    end
    return massegeData
end

--清除
function ServiceChatData.Clear()
    this.playerDatas = {}
    this.allMassegeDatas = {}
    this.tempMassegeDatas = {}
    this.playerId = 0
    this.curUnionId = 0
    this.type = 0
end