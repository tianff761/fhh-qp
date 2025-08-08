--游戏初始化
local Init = {}
Init.inited = false
--游戏打开类型
Init.gameOpenType = nil

function Init.DoFile(path)
    dofile("AB/PaoDeKuai/Lua/" .. path)
end

function Init.AddLuaFiles()
    Init.DoFile("Define/PdkDefine")
    Init.DoFile("Define/PdkCommand")
    Init.DoFile("Module/PdkRoomModule")
    Init.DoFile("Controller/PdkRoomCtrl")
    Init.DoFile("Controller/PdkSelfHandCardCtrl")
    Init.DoFile("Controller/PdkAudioCtrl")
    Init.DoFile("Controller/PdkEffectCtrl")
    Init.DoFile("Controller/PdkResourcesCtrl")
    Init.DoFile("Controller/PdkPokerBackCtrl")
    Init.DoFile("Controller/PdkPlayBackCtrl")
    Init.DoFile("Logic/PdkHandCard")
    Init.DoFile("Logic/PdkPlayer")
    Init.DoFile("Logic/PdkClockTimer")
    Init.DoFile("Logic/PdkPokerLogic")
end

function Init.Init(args)
    if Init.inited == false then
        Init.inited = true
        Init.AddLuaFiles()
    end
    --如果是新房间游戏，需要关闭结算界面
    if PdkRoomModule.roomId ~= nil and args.roomId ~= PdkRoomModule.roomId then
        PanelManager.Close(PdkPanelConfig.SingleRecord)
        PanelManager.Close(PdkPanelConfig.TotalRecord)
    end
    --房间初始化
    PdkRoomModule.Init(args)
    if args.isPlayback == true then
        PdkPlayBackCtrl.Init(args.playbackData)
    end
    PanelManager.Open(PdkPanelConfig.Room, args)
end

function Init.Close()
    PdkRoomModule.Clear()
end

function Init.CloseUI()
    PanelManager.Close(PdkPanelConfig.Room)
    PanelManager.Close(PdkPanelConfig.Rule)
    PanelManager.Close(PdkPanelConfig.Dissovle)
    PanelManager.Close(PdkPanelConfig.Playback)
    PanelManager.Close(PdkPanelConfig.Setup)
    PanelManager.Close(PdkPanelConfig.SingleRecord)
    PanelManager.Close(PdkPanelConfig.TotalRecord)
end

function Init.Unload()
    Init.inited = false
    PanelManager.Destroy(PdkPanelConfig.Room, true)
    PanelManager.Destroy(PdkPanelConfig.Rule, true)
    PanelManager.Destroy(PdkPanelConfig.Dissovle, true)
    PanelManager.Destroy(PdkPanelConfig.Playback, true)
    PanelManager.Destroy(PdkPanelConfig.Setup, true)
    PanelManager.Destroy(PdkPanelConfig.SingleRecord, true)
    PanelManager.Destroy(PdkPanelConfig.TotalRecord, true)
    -- PanelManager.Destroy(PanelConfig.Alert)
end

return Init
