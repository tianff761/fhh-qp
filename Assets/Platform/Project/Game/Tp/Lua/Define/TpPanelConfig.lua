--脚本路径
TpScriptPath = {
    View = "AB/Tp/Lua/View/",
}

--Bundle名称
TpBundleName = {
    Panel = "tp/panels",
    Audio = "tp/audio",
    Music = "tp/music",
    Effect = "tp/effects",
    Quick = "tp/quick",
    Share = "tp/share",
}

--面板，大厅的普通面板都使用层数4
TpPanelConfig = {
    --
    Room = { path = TpScriptPath.View, bundleName = TpBundleName.Panel, assetName = "TpRoomPanel", 
        layer = 1, isSpecial = true, isPortrait = true
    },
    --
    Operation = { path = TpScriptPath.View, bundleName = TpBundleName.Panel, assetName = "TpOperationPanel", 
        layer = 2, isSpecial = true, isPortrait = true 
    },
    TotalSettlement = { path = TpScriptPath.View, bundleName = TpBundleName.Panel, assetName = "TpTotalSettlementPanel", layer = 5, isSpecial = true, isPortrait = true },
    Playback = { path = TpScriptPath.View, bundleName = TpBundleName.Panel, assetName = "TpPlaybackPanel", layer = 2, isSpecial = true, isPortrait = true },
    Setup = {path = TpScriptPath.View, bundleName = TpBundleName.Panel, assetName = "TpSettingPanel", layer = 4, isSpecial = true, isPortrait = true },
    Rule = {path = TpScriptPath.View, bundleName = TpBundleName.Panel, assetName = "TpRulePanel", layer = 4, isSpecial = true, isPortrait = true},
    Dismiss = { path = TpScriptPath.View, bundleName = TpBundleName.Panel, assetName = "TpDismissPanel", layer = 6, isSpecial = true },
}