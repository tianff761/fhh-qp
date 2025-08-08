--游戏初始化
local Init = {}
Init.inited = false
function Init.DoFile(path)
    dofile("AB/Pin3/Lua/" .. path)
end

function Init.AddLuaFiles()
    Init.DoFile("Define/Pin3Define")
    Init.DoFile("Define/Pin3Command")
    
    Init.DoFile("Data/Pin3Data")
    
    Init.DoFile("Logic/Pin3Utils")
    Init.DoFile("Logic/Pin3Card")
    Init.DoFile("Logic/Pin3UserInfoCtrl")
    Init.DoFile("Managers/Pin3AudioManager")
    Init.DoFile("Managers/Pin3AnimManager")
    Init.DoFile("Managers/Pin3Manager")
    Init.DoFile("Managers/Pin3NetworkManager")
    Init.DoFile("Managers/Pin3PlaybackManager")


   -- Init.DoFile("Module/Pin3BattleModule")
end

--打开面板使用
function Init.AddOpenLuaFiles()
    Init.AddLuaFiles()
end

--进入游戏
function Init.AddEnterLuaFiles()
    Init.AddLuaFiles()

end

function Init.Init(args)
    if Init.inited == false then
        Init.inited = true
        Init.AddEnterLuaFiles()
    end
    Pin3Manager.Init(args)
end

function Init.Close()
end

function Init.CloseUI()
    PanelManager.Close(Pin3Panels.Pin3Setting,    true, false)
    PanelManager.Close(Pin3Panels.Pin3Battle,     true, false)
    PanelManager.Close(Pin3Panels.Pin3DanJuJieSuan,  true, false)
    PanelManager.Close(Pin3Panels.Pin3ZongJieSuan,   true, false)
    PanelManager.Close(Pin3Panels.Pin3DismissRoom,   true, false)
    PanelManager.Close(Pin3Panels.Pin3Rule,          true, false)
    PanelManager.Close(Pin3Panels.Pin3Playback, true, false)
    PanelManager.Close(PanelConfig.RoomGps,     true, false)
    PanelManager.Close(PanelConfig.GoldMatch)
    PanelManager.Close(PanelConfig.Alert)
    Pin3Manager.Uninit()
end

function Init.Unload()
    Init.inited = false
    ResourcesManager.Unload(Pin3BundleNames.otherBundle, false)
end
return Init