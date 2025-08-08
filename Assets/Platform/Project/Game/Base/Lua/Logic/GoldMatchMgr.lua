GoldMacthMgr = {}
GoldMacthMgr.macthId = 0 --匹配场ID
GoldMacthMgr.matchEtc = 0 --匹配场次
GoldMacthMgr.gameType = 0
GoldMacthMgr.matchBaseCores = {} --匹配场关闭的底分


--处理匹配返回
function GoldMacthMgr.HandleMatchRoom(code)
    if code == 0 then
        Waiting.Hide()
        PanelManager.Open(PanelConfig.GoldMatch)
    elseif code == 40012 then --元宝不足
        Alert.Prompt("您的元宝不足,是否前往充值?", function()
            PanelManager.Open(PanelConfig.Mall, GoodsType.Gold)
        end)
        Waiting.Hide()
    elseif code == 40053 then
        if GameSceneManager.IsLobbyScene() then
            BaseTcpApi.SendCheckIsInRoom(0, GoldMacthMgr.OnCheckIsInRoomCallback)
        end
    elseif code == 40069 then
        Toast.Show("未匹配到合适的房间，请重新再试")
        PanelManager.Close(PanelConfig.GoldMatch)
        --加入时房间人数已满或者房间被解散单独处理
    elseif code == 10003 or code == 10004 or code == 10005 or code == 10006 then
        GoldMacthMgr.ContinueMatch()
    elseif code == 40064 then
    elseif code == 40070 then  --已经在匹配中 若在大厅中执行打开面板，若在房间中，不处理
        if GameSceneManager.IsLobbyScene() then
            PanelManager.Open(PanelConfig.GoldMatch)
        end
    elseif code == 40071 then
        Alert.Show("该场次已经被会长屏蔽，暂时无法进入", function()
            if GameSceneManager.IsLobbyScene() then
                BaseTcpApi.SendGetCloseMatchBaseCores() --重新刷新底分
            end
            SendEvent(CMD.Game.HandleQuickMatch)
        end)
    elseif code == 40076 then
        Alert.Prompt("您尚未开启定位，请开启后进入匹配。(提示:若已经开启定位仍然无法进入匹配，请联系官方客服微信" .. AppConfig.WeChatID1 .. ")", function()
            AppPlatformHelper.OpenDeviceSetting()
        end)
    elseif code == 40083 then
        Toast.Show("该游戏场次的游戏已被禁用，详情请咨询圈主")
        SendEvent(CMD.Game.UpdateMatchGames)--游戏场次发生变化
    else
        ErrorUtil.HandleTeaError(code)
        Waiting.Hide()
        SendEvent(CMD.Game.HandleQuickMatch)
    end
end

--检测房间号
function GoldMacthMgr.OnCheckIsInRoomCallback(data)
    if GameSceneManager.IsLobbyScene() then
        --不在房间中，不处理
        if data.code == 0 then
            if data.data.roomId > 0 then
                UserData.SetRoomId(data.data.roomId)
                BaseTcpApi.CheckAndJoinRoom(data.data.roomId, true, true)
            end
        end
    end
end
--获取匹配场次
function GoldMacthMgr.GetMatchEtc()
    return GoldMacthMgr.matchEtc
end

--设置匹配场次
function GoldMacthMgr.SetMatchEtc(matchEtc)
    GoldMacthMgr.matchEtc = matchEtc
end

--设置匹配场ID
function GoldMacthMgr.SetMatchId(matchId)
    GoldMacthMgr.macthId = matchId
end

--获取匹配场ID
function GoldMacthMgr.GetMatchId()
    return GoldMacthMgr.macthId
end

--根据场次获取此匹配场所有ID
function GoldMacthMgr.GetMatchInfos()
    return MatchConfigData
end

--根据匹配ID获取单个匹配信息
function GoldMacthMgr.GetMatchInfoByMatchId()
    local matchId = GoldMacthMgr.GetMatchId()
    for _, game in pairs(MatchConfigData) do
        for i = 1, #game do
            if game[i].matchId == matchId then
                return game[i]
            end
        end
    end
end

-- 发送加入匹配协议 需要传入游戏类型 底分
function GoldMacthMgr.SendMatchGame(matchId)
    GoldMacthMgr.SendMatchCommand(matchId)
end

--继续匹配
function GoldMacthMgr.ContinueMatch()
    GoldMacthMgr.SendMatchCommand(GoldMacthMgr.GetMatchId())
end


-- 根据场次获取游戏ID
function GoldMacthMgr.GetGameTypeByMatchEtc()
    local matchEtc = GoldMacthMgr.GetMatchEtc()
    if matchEtc == MatchEtc.NeiJiang3Ren then
        return GameType.Mahjong
    else
        return GameType.None
    end
end

--发送匹配协议
function GoldMacthMgr.SendMatchCommand(matchId)
    GoldMacthMgr.SetMatchId(matchId)
    local gps = GPSModule.GetGpsDataByPlayerId(UserData.GetUserId())
    local lat = gps.lat
    local lng = gps.lng

    local matchInfo = GoldMacthMgr.GetMatchInfoByMatchId()
    if not IsNil(matchInfo) then
        -- if IsEditorOrPcPlatform() then
        --     lat = GetRandom(10000, 890000) / 10000
        --     lng = GetRandom(100000, 8900000) / 100000
        -- else
        lat = GetRandom(1000000, 89000000) / 1000000
        lng = GetRandom(10000000, 890000000) / 10000000
        --     end
        -- end
    end
    BaseTcpApi.SendGameMatch(matchId, lat, lng)
end

--根据匹配ID获取匹配场次
function GoldMacthMgr.GetMatchEtcByMatchId(matchId)
    for _, game in pairs(MatchConfigData) do
        for i = 1, #game do
            if game[i].matchId == matchId then
                return game[i].matchEtc
            end
        end
    end
end

--设置比配场关闭底分
function GoldMacthMgr.SetMatchBaseCores(baseCores)
    GoldMacthMgr.matchBaseCores = baseCores
end
--获取匹配场关闭底分
function GoldMacthMgr.GetMatchBaseCores()
    return GoldMacthMgr.matchBaseCores
end

--检测当前底分是否关闭
function GoldMacthMgr.CheckMatchBaseCoreIsCloase(baseCore)
    for i, v in ipairs(GoldMacthMgr.GetMatchBaseCores()) do
        if baseCore == v then
            return true
        end
    end
    return false
end