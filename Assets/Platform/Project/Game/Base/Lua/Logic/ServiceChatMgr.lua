ServiceChatMgr = {}
local this = ServiceChatMgr
this.inited = false
--空间名
this.bucket = "cnwb-1300923411"
--空间前缀
this.bucketPath = "/hlcnqp/servicechat/"
--图片存储位置
this.imageLocalPath = Application.persistentDataPath .. "/NetImage/"
--文本存储位置
this.textLocalPath = Application.persistentDataPath .. "/ChatTexts/"
--玩家数据存储位置
this.playerLocalPath = Application.persistentDataPath .. "/Players/"
--小红点数据存储位置
this.redPointLocalPath = Application.persistentDataPath .. "/RedPoint/"
--默认图片
this.imageNoneSprite = nil

--初始化客服聊天
function ServiceChatMgr.Init()
    if not this.inited then
        this.inited = true
        this.AddCmdListener()
        this.imageNoneSprite = ResourcesManager.LoadSpriteBySynch(BundleName.Common, "ImageNoneIcon")
    end
end

function ServiceChatMgr.AddCmdListener()
    AddEventListener(CMD.Tcp.S2C_ServiceList, this.OnServiceList)
    AddEventListener(CMD.Tcp.S2C_SendChat, this.OnSendChat)
    AddEventListener(CMD.Tcp.S2C_PushChat, this.OnPushChat)
    AddEventListener(CMD.Tcp.S2C_PlayerStatus, this.OnPlayerStatus)
end

function ServiceChatMgr.RemoveCmdListener()
    RemoveEventListener(CMD.Tcp.S2C_ServiceList, this.OnServiceList)
    RemoveEventListener(CMD.Tcp.S2C_SendChat, this.OnSendChat)
    RemoveEventListener(CMD.Tcp.S2C_PushChat, this.OnPushChat)
    RemoveEventListener(CMD.Tcp.S2C_PlayerStatus, this.OnPlayerStatus)
end

--客服列表
function ServiceChatMgr.OnServiceList(data)
    if data.code == 0 then
        if data.data.code == 0 then
            ServiceChatData.playerDatas = {}
            if GetTableSize(data.data.list) > 0 then
                local playerDatas = this.ReadTotalPlayerData(ServiceChatData.type, ServiceChatData.curUnionId)
                for i = 1, #data.data.list do
                    local serData = data.data.list[i]
                    local playerData = ServiceChatData.GetPlayerDataByPlayerId(serData.playerId, false)
                    playerData.playerId = serData.userId
                    playerData.playerName = serData.username
                    playerData.playerHeadUrl = serData.imgurl
                    playerData.isOnline = serData.isOnline
                    playerData.isReadFile = false
                    --找到本地缓存数据
                    for j = 1, #playerDatas do
                        if playerData.playerId == playerDatas[j].playerId then
                            playerData.isUnread = playerDatas[j].isUnread
                            break
                        end
                    end
                end
            end
        else
            ServiceChatData.playerDatas = this.ReadTotalPlayerData(ServiceChatData.type, ServiceChatData.curUnionId)
            if IsTable(ServiceChatData.playerDatas) then
                for i = 1, #ServiceChatData.playerDatas do
                    local playerData = ServiceChatData.playerDatas[i]
                    playerData.isOnline = false
                    playerData.isReadFile = false
                end
            end
        end
        if PanelManager.IsOpened(PanelConfig.ServiceChat) then
            ServiceChatPanel.UpdatePlayerList(true)
        end
    end
end

--发送消息回复
function ServiceChatMgr.OnSendChat(data)
    if data.code == 0 then
        if data.data.code == 0 then
            Toast.Show("发送成功")
            local massegeData = ServiceChatData.RemoveTempMassegeDataBySendTime(data.data.time)
            if massegeData ~= nil then
                ServiceChatData.AddMassegeDataByPlayerId(massegeData.receivePlayerID, massegeData)
                this.WriteMassegeDataByPlayerId(ServiceChatData.type, ServiceChatData.curUnionId, massegeData.receivePlayerID, massegeData)
            end
            -- ServiceChatPanel.UpdateMassege(massegeData)
        elseif data.data.code == 50005 then
            Toast.Show("不能给离线玩家发送消息")
            ServiceChatData.RemoveTempMassegeDataBySendTime(data.data.time)
            ServiceChatPanel.RemoveMassegeItemBySendTime(data.data.time)
        end
    else
        
    end
end

--收到聊天消息
function ServiceChatMgr.OnPushChat(data)
    if data.code == 0 then
        local type = data.data.type
        local unionId = data.data.unionId
        local sendPlayerId = data.data.seId
        local massegeData = ServiceChatData.NewChatMassegeData(data.data.msgType, os.timems(), sendPlayerId, data.data.seName, data.data.seImg, UserData.GetUserId(), data.data.msg)
        this.WriteMassegeDataByPlayerId(type, unionId, sendPlayerId, massegeData)
        local playerData = nil
        if ServiceChatData.curUnionId == unionId then
            playerData = ServiceChatData.GetPlayerDataByPlayerId(sendPlayerId, true)
            playerData.playerId = sendPlayerId
            playerData.playerName = data.data.seName
            playerData.playerHeadUrl = data.data.seImg
            playerData.isOnline = true
            playerData.isUnread = true
            playerData.lastSendTime = os.timems()
            --已经读取了消息的玩家才添加缓存消息
            if playerData.isReadFile then
                ServiceChatData.AddMassegeDataByPlayerId(sendPlayerId, massegeData)
            end
            if PanelManager.IsOpened(PanelConfig.ServiceChat) then
                if ServiceChatData.playerId == sendPlayerId then
                    playerData.isUnread = false
                    ServiceChatPanel.UpdateMassege(massegeData)
                else
                    local isSelected = IsNil(ServiceChatData.playerId) or ServiceChatData.playerId == 0
                    ServiceChatPanel.UpdatePlayerList(isSelected)
                end
            end
            this.WriteTotalPlayerData(type, unionId, ServiceChatData.playerDatas)
        else
            local playerDatas = this.ReadTotalPlayerData(type, unionId)
            for i = 1, #playerDatas do
                if playerDatas[i].playerId == sendPlayerId then
                    playerData = playerDatas[i]
                    break
                end
            end
            if IsNil(playerData) then
                playerData = ServiceChatData.NewPlayerData()
                table.insert(playerDatas, 1, playerData)
            end
            playerData.playerId = sendPlayerId
            playerData.playerName = data.data.seName
            playerData.playerHeadUrl = data.data.seImg
            playerData.isOnline = true
            playerData.isUnread = true
            playerData.lastSendTime = os.timems()
            this.WriteTotalPlayerData(type, unionId, playerDatas)
        end
        --未读消息 存储小红点信息
        if playerData ~= nil and playerData.isUnread then
            this.AddUnreadInfo(type, unionId, sendPlayerId)
        end
    end
end

--玩家状态
function ServiceChatMgr.OnPlayerStatus(data)
    if data.code == 0 then
        local tempData = nil
        local playerData = nil
        for i = 1, #data.data.list do
            tempData = data.data.list[i]
            for i = 1, #ServiceChatData.playerDatas do
                playerData = ServiceChatData.playerDatas[i]
                if tempData.userId == playerData.playerId then
                    playerData.isOnline = tempData.isOnline
                    ServiceChatPanel.UpdatePlayerItem(i)
                end
            end
        end
    end
end

-----------------------------------------------------------------------------
------------------------------逻辑处理---------------------------------------
-----------------------------------------------------------------------------
--获取某个玩家聊天数据
function ServiceChatMgr.GetMassegeDatasByPlayerId()
    local id = ServiceChatData.playerId
    local unionId = ServiceChatData.curUnionId
    local type = ServiceChatData.type
    local playerData = ServiceChatData.GetPlayerDataByPlayerId(id, false)
    if not playerData.isReadFile then
        this.ReadMassegeDataByPlayerId(type, unionId, id)
        playerData.isReadFile = true
    end
    local massegeDatas = ServiceChatData.GetMassegeDatasByPlayerId(id)
    return massegeDatas
end

--读取消息数据
function ServiceChatMgr.ReadMassegeDataByPlayerId(type, unionId, id)
    FileUtils.CheckCrateDir(this.textLocalPath)
    local fileName = this.textLocalPath .. type .. "-" .. unionId .. "-" .. UserData.GetUserId() .. "-" .. id .. ".txt"
    if FileUtils.ExistsFile(fileName) then
        local text = FileUtils.ReadAllLines(fileName)
        if text ~= nil and text ~= "" then
            local textTable = text:ToTable()
            if IsTable(textTable) then
                for i = 1, #textTable do
                    if textTable[i] ~= nil and textTable[i] ~= "" then
                        local massegeData = JsonToObj(textTable[i])
                        ServiceChatData.AddMassegeDataByPlayerId(id, massegeData)
                    end
                end
            end
        end
    end
end

--写入消息数据
function ServiceChatMgr.WriteMassegeDataByPlayerId(type, unionId, id, massegeData)
    FileUtils.CheckCrateDir(this.textLocalPath)
    local fileName = this.textLocalPath .. type .. "-" .. unionId .. "-" .. UserData.GetUserId() .. "-" .. id .. ".txt"
    local text = ObjToJson(massegeData)
    FileUtils.WriteLine(fileName, text, FileMode.Append)
end

--读取玩家数据
function ServiceChatMgr.ReadTotalPlayerData(type, unionId)
    FileUtils.CheckCrateDir(this.playerLocalPath)
    local fileName = this.playerLocalPath .. type .. "-" .. unionId .. "-" .. UserData.GetUserId() .. "txt"
    local text = FileUtils.GetFileText(fileName)
    local players = {}
    if text ~= nil and text ~= "" then
        players = JsonToObj(text)
    end
    return players
end

--写入玩家数据
function ServiceChatMgr.WriteTotalPlayerData(type, unionId, playerDatas)
    FileUtils.CheckCrateDir(this.playerLocalPath)
    local fileName = this.playerLocalPath .. type .. "-" .. unionId .. "-" .. UserData.GetUserId() .. "txt"
    local playerDatasText = ObjToJson(playerDatas)
    FileUtils.SaveToFile(fileName, playerDatasText)
end


--添加未读信息
function ServiceChatMgr.AddUnreadInfo(type, unionId, playerId)
    local key = "Service" .. type .. UserData.GetUserId()
    local infoStr = GetLocal(key, nil)
    local info = {}
    if infoStr ~= nil and infoStr ~= "" then
        info = JsonToObj(infoStr)
    end
    local unionKey = tostring(unionId)
    local unionList = info[unionKey]
    if IsNil(unionList) then
        unionList = {}
        info[unionKey] = unionList
    end
    local isHave = false
    for i = 1, #unionList do
        if playerId == unionList[i] then
            isHave = true
            break
        end
    end
    if not isHave then
        table.insert(unionList, playerId)
        local tempStr = ObjToJson(info)
        SetLocal(key, tempStr)
    end
    this.SetRedPointData()
end

--移除未读信息
function ServiceChatMgr.RemoveUnreadInfo(type, unionId, playerId)
    local key = "Service" .. type .. UserData.GetUserId()
    local infoStr = GetLocal(key, nil)
    if infoStr ~= nil and infoStr ~= "" then
        local info = JsonToObj(infoStr)
        local unionKey = tostring(unionId)
        local unionList = info[unionKey]
        if IsTable(unionList) then
            for i = 1, #unionList do
                if playerId == unionList[i] then
                    table.remove(unionList, i)
                    if GetTableSize(unionList) <= 0 then
                        info[unionKey] = nil
                    end
                    break
                end
            end
        end
        local tempStr = ObjToJson(info)
        SetLocal(key, tempStr)
        this.SetRedPointData()
    end
end

--设置小红点数据
function ServiceChatMgr.SetRedPointData()
    local key = "Service1" .. UserData.GetUserId()
    local infoStr = GetLocal(key, nil)
    if infoStr ~= nil and infoStr ~= "" then
        local info = JsonToObj(infoStr)
        if IsTable(info) then
            RedPointMgr.RemoveRedPointByType(RedPointType.ServiceChatMessage)
            local list = {}
            for unionKey, v in pairs(info) do
                table.insert(list, tonumber(unionKey))
            end
            local data = {}
            data[RedPointType.ServiceChatMessage] = list
            RedPointMgr.AddRedPointData(data)
        end
    end

    key = "Service2" .. UserData.GetUserId()
    infoStr = GetLocal(key, nil)
    if infoStr ~= nil and infoStr ~= "" then
        local info = JsonToObj(infoStr)
        if IsTable(info) then
            RedPointMgr.RemoveRedPointByType(RedPointType.ClubServiceChatMessage)
            local list = {}
            for clubKey, v in pairs(info) do
                table.insert(list, tonumber(clubKey))
            end
            local data = {}
            data[RedPointType.ClubServiceChatMessage] = list
            RedPointMgr.AddRedPointData(data)
        end
    end
end
------------------------上传图片相关-----------------------------------------
--上传图片到资源空间
function ServiceChatMgr.UploadImage(imagePath, callback)
    if string.IsNullOrEmpty(imagePath) then
        return
    end
    Log(">>>>>>ServiceChatMgr.UploadImage>>>>上传图片到资源空间")
    local fileName = os.timems()
    local fullFileName = fileName .. ".jpg"
    FileUtils.CheckCrateDir(this.imageLocalPath)
    local md5FileName = Util.md5(fileName) .. ".jpg"
    ImageHepler.Compress(imagePath, this.imageLocalPath .. md5FileName)
    --上传前先进行压缩
    ImageHepler.Compress(imagePath, this.imageLocalPath .. fullFileName)
    Scheduler.scheduleOnceGlobal(function()
        TencentApiMgr.CustomUploadFileRequest(this.bucket, this.bucketPath, this.imageLocalPath .. fullFileName, fullFileName, function(code, key)
            Log(">>>>>>>TencentApiMgr.CustomUploadFileRequest----Callback>>>>>>>> code ：", code, " key :", key)
            if tonumber(code) == 0 then
                --上传成功
                if callback ~= nil then
                    callback(fileName)
                    callback = nil
                end
            else
                --上传失败
                Toast.Show("图片上传失败，请稍后再试")
            end
        end)
    end, 0.2)
end

--检测图片
function ServiceChatMgr.CheckImageUrl(imageUrl)
    if string.IsNullOrEmpty(imageUrl) then
        return "0"
    end
    local x = string.find(imageUrl, "http")
    if x ~= nil then
        return imageUrl
    end
    return AppConfig.chatImageDownUrl .. imageUrl .. ".jpg"
end

--设置图片
function ServiceChatMgr.SetImage(image, imageName, callback, arg)
    this.SetNetImage(image, imageName, callback, arg)
end

--设置网络图片
function ServiceChatMgr.SetNetImage(image, imageUrl, callback, arg)
    if IsNull(image) then
        Log(">> ServiceChatMgr.SetHeadImage > image == nil.")
        return
    end
    local imageUrl = this.CheckImageUrl(imageUrl)
    if imageUrl ~= nil and imageUrl ~= "" then
        local isSuccess = netImageMgr:SetImage(image, imageUrl)
        if isSuccess and callback ~= nil then
            callback()
        else
            local tempCallback = callback
            if tempCallback == nil then
                tempCallback = ServiceChatMgr.OnImageLoadCompleted
            end
            local tempArg = arg
            if tempArg == nil then
                tempArg = { image = image, imageUrl = imageUrl }
            else
                tempArg.image = image
                tempArg.imageUrl = imageUrl
            end
            netImageMgr:Load(imageUrl, tempCallback, tempArg)
        end
    end
end

--加载头像图片回调
function ServiceChatMgr.OnImageLoadCompleted(arg)
    if arg ~= nil and not IsNull(arg.image) and arg.imageUrl ~= nil then
        Log(">> ServiceChatMgr.OnImageLoadCompleted > arg.imageUrl = ", tostring(arg.imageUrl))
        local isSuccess = netImageMgr:SetImage(arg.image, arg.imageUrl)
        if not isSuccess then
            arg.image.sprite = BaseResourcesMgr.imageNoneSprite
        end
    end
end

--清除
function ServiceChatMgr.Clear()
    ServiceChatData.Clear()
end