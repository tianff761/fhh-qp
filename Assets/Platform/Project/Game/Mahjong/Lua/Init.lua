--游戏初始化
local Init = {}
--是否初始化标识
Init.inited = false

function Init.DoFile(path)
    dofile("AB/Mahjong/Lua/" .. path)
end

function Init.AddLuaFiles()
    Init.DoFile("Define/MahjongDefine")
    Init.DoFile("Define/MahjongCommand")
    --
    Init.DoFile("Data/MahjongPlayerData")
    Init.DoFile("Data/MahjongHuCheckCardData")
    Init.DoFile("Data/MahjongPlayerCardData")
    Init.DoFile("Data/MahjongCardData")
    Init.DoFile("Data/MahjongTingData")
    --
    Init.DoFile("Item/MahjongCardItem")
    Init.DoFile("Item/MahjongOperateCardItem")
    Init.DoFile("Item/MahjongOutCardItem")
    Init.DoFile("Item/MahjongPlayCardArrowItem")
    Init.DoFile("Item/MahjongPlayerItem")
    --
    Init.DoFile("Logic/MahjongOutCard")
    Init.DoFile("Logic/MahjongPlayer")
    --
    Init.DoFile("Util/MahjongTingHelper")
    Init.DoFile("Util/MahjongUtil")
    --
    Init.DoFile("Mgrs/MahjongEffectMgr")
    Init.DoFile("Mgrs/MahjongAnimMgr")
    Init.DoFile("Mgrs/MahjongAudioMgr")
    Init.DoFile("Mgrs/MahjongResourcesMgr")
    Init.DoFile("Mgrs/MahjongDataMgr")
    --
    Init.DoFile("Mgrs/MahjongPlayCardHelper")
    Init.DoFile("Mgrs/MahjongPlayCardMgr")
    Init.DoFile("Mgrs/MahjongPlaybackCardMgr")
    --
    Init.DoFile("Mgrs/MahjongRoomMgr")
end

function Init.Init(args)
    Log(">> Mahjong > ================ > Init.Init > ", args)

    if Init.inited == false then
        Init.inited = true
        Init.AddLuaFiles()
    end

    --检测关闭界面
    PanelManager.Close(MahjongPanelConfig.SingleSettlement)
    PanelManager.Close(MahjongPanelConfig.TotalSettlement)
    PanelManager.Close(MahjongPanelConfig.Operation)
    PanelManager.Close(MahjongPanelConfig.HuTips)

    --设置房间号
    MahjongDataMgr.SetRoomId(args.roomId)
    --设置主玩家
    MahjongDataMgr.SetUserId(args.userId)

    MahjongDataMgr.moneyType = Functions.CheckMoneyType(args.moneyType)
    MahjongDataMgr.roomType = Functions.CheckRoomType(args.roomType)
    MahjongDataMgr.groupId = args.groupId
    if MahjongDataMgr.roomType == RoomType.Tea then
        -- GoldMacthMgr.SetMatchId(args.groupId)
    end
    MahjongDataMgr.gpsType = args.gps
    MahjongDataMgr.recordType = args.recordType
    if MahjongDataMgr.recordType == nil then
        MahjongDataMgr.recordType = 1
    end

    if args.isPlayback == true then
        MahjongDataMgr.isPlayback = true
        --保存回放数据
        MahjongPlaybackCardMgr.Initialize(args.playbackData)
    else
        MahjongDataMgr.isPlayback = false
        --站点(加上网关后，用站点替代上面的port)
        MahjongDataMgr.serverLine = args.line
    end
    --进入房间时，房间结束标记设置为false
    MahjongDataMgr.ClearByInit()
    --Log(">> Mahjong > Init > args.userId = ", args.userId)
    --如果牌局存在则重置牌局
    if MahjongRoomPanel ~= nil then
        MahjongRoomMgr.Reset()
    end
    --房间初始化
    MahjongRoomMgr.Initialize()
end

function Init.Close()
    Log(">> Mahjong > ================ > Init.Close.")
    MahjongRoomMgr.Clear()
    PanelManager.Close(MahjongPanelConfig.SingleSettlement)
    PanelManager.Close(MahjongPanelConfig.TotalSettlement)
    PanelManager.Close(MahjongPanelConfig.Setup)
    PanelManager.Close(MahjongPanelConfig.Rule)
    PanelManager.Close(MahjongPanelConfig.Operation)
    PanelManager.Close(MahjongPanelConfig.Dismiss)
    PanelManager.Close(MahjongPanelConfig.HuTips)
    PanelManager.Close(MahjongPanelConfig.Playback)
    PanelManager.Close(MahjongPanelConfig.MahjongScreenshot)
    PanelManager.Close(MahjongPanelConfig.GoldSettlement)
    PanelManager.Close(MahjongPanelConfig.JushuTips)
    PanelManager.Close(MahjongPanelConfig.MatchSettlement)
end

function Init.CloseUI()
    Log(">> Mahjong > ================ > Init.CloseUI.")
    RoomUtil.StopCheckPlayerHeadImage()
    PanelManager.Close(MahjongPanelConfig.Room)
end

function Init.Unload()
    Log(">> Mahjong > ================ > Init.Unload.")
    Init.inited = false
    MahjongRoomMgr.Destroy()
    --销毁面板
    PanelManager.Destroy(MahjongPanelConfig.SingleSettlement)
    PanelManager.Destroy(MahjongPanelConfig.TotalSettlement)
    PanelManager.Destroy(MahjongPanelConfig.Setup)
    PanelManager.Destroy(MahjongPanelConfig.Rule)
    PanelManager.Destroy(MahjongPanelConfig.Operation)
    PanelManager.Destroy(MahjongPanelConfig.Dismiss)
    PanelManager.Destroy(MahjongPanelConfig.HuTips)
    PanelManager.Destroy(MahjongPanelConfig.Playback)
    PanelManager.Destroy(MahjongPanelConfig.Room)
    PanelManager.Destroy(MahjongPanelConfig.MahjongScreenshot)
    PanelManager.Destroy(MahjongPanelConfig.GoldSettlement)
    PanelManager.Destroy(MahjongPanelConfig.JushuTips)
    PanelManager.Destroy(MahjongPanelConfig.MatchSettlement)
    --卸载AB包
    ResourcesManager.Unload(MahjongBundleName.Audio, true)
    ResourcesManager.Unload(MahjongBundleName.Music, true)
    ResourcesManager.Unload(MahjongBundleName.Effect, true)
    ResourcesManager.Unload(MahjongBundleName.Quick, true)
    --由于麻将的面板有预加载，故这里不卸载
    --ResourcesManager.Unload(MahjongBundleName.Panel, false)
end

return Init