--游戏初始化
local Init = {}
--是否初始化标识
Init.inited = false

function Init.DoFile(path)
    dofile("AB/Tp/Lua/" .. path)
end

function Init.AddLuaFiles()
    Init.DoFile("Define/TpConst")
    Init.DoFile("Define/TpDefine")
    Init.DoFile("Define/TpPanelConfig")
    Init.DoFile("Define/TpCommand")
    --
    Init.DoFile("Data/TpPlayerData")
    Init.DoFile("Data/TpCardData")
    --
    Init.DoFile("Item/TpCardItem")
    Init.DoFile("Item/TpHandCardItem")
    Init.DoFile("Item/TpJackpotItem")
    Init.DoFile("Item/TpPlayerItem")
    --
    Init.DoFile("Util/TpUtil")
    --
    Init.DoFile("Mgrs/TpEffectMgr")
    Init.DoFile("Mgrs/TpAnimMgr")
    Init.DoFile("Mgrs/TpAudioMgr")
    Init.DoFile("Mgrs/TpResourcesMgr")
    Init.DoFile("Mgrs/TpDataMgr")
    --
    Init.DoFile("Mgrs/TpPlaybackCardMgr")
    --
    Init.DoFile("Mgrs/TpRoomMgr")
    Init.DoFile("Mgrs/TpPlayCardMgr")
end

function Init.Init(args)
    Log(">> Tp > ================ > Init.Init > ", args)

    if Init.inited == false then
        Init.inited = true
        Init.AddLuaFiles()
    end

    --检测关闭界面
    PanelManager.Close(TpPanelConfig.TotalSettlement)
    PanelManager.Close(TpPanelConfig.Operation)
    PanelManager.Close(TpPanelConfig.Playback)

    --设置房间号
    TpDataMgr.SetRoomId(args.roomId)
    --设置主玩家
    TpDataMgr.SetUserId(args.userId)

    TpDataMgr.moneyType = Functions.CheckMoneyType(args.moneyType)
    TpDataMgr.roomType = Functions.CheckRoomType(args.roomType)
    TpDataMgr.groupId = args.groupId
    if TpDataMgr.roomType == RoomType.Tea then
        -- GoldMacthMgr.SetMatchId(args.groupId)
    end
    TpDataMgr.gpsType = args.gps
    TpDataMgr.recordType = args.recordType
    if TpDataMgr.recordType == nil then
        TpDataMgr.recordType = 1
    end

    if args.isPlayback == true then
        TpDataMgr.isPlayback = true
        --保存回放数据
        TpPlaybackCardMgr.Initialize(args.playbackData)
    else
        TpDataMgr.isPlayback = false
        --站点(加上网关后，用站点替代上面的port)
        TpDataMgr.serverLine = args.line
    end
    --进入房间时，房间结束标记设置为false
    TpDataMgr.ClearByInit()
    --Log(">> Tp > Init > args.userId = ", args.userId)
    --如果牌局存在则重置牌局
    if TpRoomPanel ~= nil then
        TpRoomMgr.Reset()
    end
    --房间初始化
    TpRoomMgr.Initialize()
end

function Init.Close()
    Log(">> Tp > ================ > Init.Close.")
    TpRoomMgr.Clear()
    PanelManager.Close(TpPanelConfig.Setup)
    PanelManager.Close(TpPanelConfig.Rule)
    PanelManager.Close(TpPanelConfig.Operation)
    PanelManager.Close(TpPanelConfig.Playback)
    PanelManager.Close(TpPanelConfig.Dismiss)
end

function Init.CloseUI()
    Log(">> Tp > ================ > Init.CloseUI.")
    RoomUtil.StopCheckPlayerHeadImage()
    PanelManager.Close(TpPanelConfig.Room)
    PanelManager.Close(TpPanelConfig.TotalSettlement)
end

function Init.Unload()
    Log(">> Tp > ================ > Init.Unload.")
    Init.inited = false
    TpRoomMgr.Destroy()
    --销毁面板
    PanelManager.Destroy(TpPanelConfig.Setup)
    PanelManager.Destroy(TpPanelConfig.Rule)
    PanelManager.Destroy(TpPanelConfig.Operation)
    PanelManager.Destroy(TpPanelConfig.Playback)
    PanelManager.Destroy(TpPanelConfig.Dismiss)
    --
    PanelManager.Destroy(TpPanelConfig.Room)
    PanelManager.Destroy(TpPanelConfig.TotalSettlement)
    --卸载AB包
    ResourcesManager.Unload(TpBundleName.Audio, true)
    ResourcesManager.Unload(TpBundleName.Music, true)
    ResourcesManager.Unload(TpBundleName.Effect, true)
    ResourcesManager.Unload(TpBundleName.Quick, true)
    ResourcesManager.Unload(TpBundleName.Panel, false)
end

return Init