local Init = {}
function Init.AddLuaFiles()
    require("AB/ErQiShi/Lua/Define/EqsDefine")
    require("AB/ErQiShi/Lua/Define/EqsTools")
    require("AB/ErQiShi/Lua/Define/EqsCommand")

    require("AB/ErQiShi/Lua/Module/BattleModule")

    require("AB/ErQiShi/Lua/View/EqsBattlePanel")
    require("AB/ErQiShi/Lua/View/EqsSettingPanel")
    require("AB/ErQiShi/Lua/View/DanJuJieSuanPanel")
    require("AB/ErQiShi/Lua/View/EqsSuiJiQuanPanel")

    require("AB/ErQiShi/Lua/Controller/EqsBattleCtrl")

    require("AB/ErQiShi/Lua/Logic/EqsCard")
    require("AB/ErQiShi/Lua/Logic/EqsCardsManager")
    require("AB/ErQiShi/Lua/Logic/EqsUserInfoCtrl")
    require("AB/ErQiShi/Lua/Logic/PlaybackOthersHandCards")
    require("AB/ErQiShi/Lua/Logic/SelfHandEqsCardsCtrl")
    require("AB/ErQiShi/Lua/Logic/LeftCardLineCtrl")
    require("AB/ErQiShi/Lua/Logic/Queue")
    require("AB/ErQiShi/Lua/Logic/EffectMgr")
    require("AB/ErQiShi/Lua/Logic/EqsSoundManager")
    
    require("AB/ErQiShi/Lua/TestApi")
    require("AB/ErQiShi/Lua/TestUILogic")
end

function Init.Init(args)
    Log("打开二七十：", args)
    Init.AddLuaFiles()
    PanelManager.Open(EqsPanels.EqsBattle, args)
end

--房间返回大厅
function Init.Close()
    PanelManager.Close(EqsPanels.BaiPanel,      true, false)
    PanelManager.Close(EqsPanels.ChiPanel,      true, false)
    PanelManager.Close(EqsPanels.EqsSetting,    true, false)
    PanelManager.Close(EqsPanels.EqsBattle,     true, false)
    PanelManager.Close(EqsPanels.DanJuJieSuan,  true, false)
    PanelManager.Close(EqsPanels.ZongJieSuan,   true, false)
    PanelManager.Close(EqsPanels.JieShanRoom,   true, false)
    PanelManager.Close(EqsPanels.Rule,          true, false)
    PanelManager.Close(PanelConfig.RoomGps,     true, false)
    PanelManager.Close(PanelConfig.RoomChange,     true, false)
    PanelManager.Close(EqsPanels.EqsSuiJiQuan,  true, false)
    PanelManager.Close(PanelConfig.GoldMatch)
    PanelManager.Close(PanelConfig.Alert)
    BattleModule.Uninit()
end
--释放资源
function Init.Unload()
    ResourcesManager.Unload(EqsPanels.bundleName, false)
end
return Init