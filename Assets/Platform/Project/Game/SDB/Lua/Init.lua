local Init = {}
function Init.AddLuaFiles()
    local logicPath = "AB/SDB/Lua/Logic/"
    -- local definePath = "AB/SDB/Lua/Define/"
    local commonPath = "AB/SDB/Lua/Common/"
    local dataPath = "AB/SDB/Lua/Data/"

    ---------------------------------------------
    require(logicPath .. "SDBDefine")
    require(logicPath .. "SDBResourcesMgr")
    require(logicPath .. "SDBRoom")
    require(logicPath .. "SDBRoomAnimator")
    require(logicPath .. "SDBContentTip")
    require(logicPath .. "SDBPlaybackMgr")
    ---------------------------------------------
    require(dataPath .. "SDBData")
    require(dataPath .. "SDBPlayer")
    require(dataPath .. "SDBPlayerItem")
    require(dataPath .. "SDBPokerCard")
    require(dataPath .. "SDBConst")
    ---------------------------------------------
    require(commonPath .. "SDBFuntions")
    require(commonPath .. "SDBAction")
    require(commonPath .. "SDBApiExtend")
end

function Init.PreloadPrefabs()
    SDBResourcesMgr.Initialize(false)
end

function Init.Init(args)
    Log("执行十点半逻辑", args)
    SDBRoomData.roomData = args
    Init.PresLoadRes()
    SDBRoomData.isPlayback = args.isPlayback == true
    if not IsNil(SDBRoomData.roomData) then
        Init.EnterRoom()
    else
        LogError(">>>>>>>>>> 数据错误")
    end
end

--预加载资源
function Init.PresLoadRes()
    --初始化数据 获取本地的扑克牌颜色，桌面颜色等
    Init.InitDatas()
    --预加载桌面
    SDBResourcesMgr.LoadDesk(SDBRoomData.sdbDeskColor)
end

function Init.EnterRoom()
    SDBRoomData.isInitRoomEnd = false
    Log(">>>>>>>>>>>>>>>>>>>       开始加载资源")

    --是否可以发送数据
    SDBRoomData.isCandSend = not SDBRoomData.isPlayback
    ChatModule.SetIsCanSend(not SDBRoomData.isPlayback)

    --初始化协议
    if not SDBRoomData.isPlayback then
        SDBRoom.Initialize()
    end

    AddMsg(SDBAction.SDBLoadEnd, Init.OnSdbLoadEnd)
    --初始化玩家
    SDBRoomData.mainId = SDBRoomData.roomData.userId

    --增加资源加载回调
    SDBResourcesMgr.onInitCompleted = Init.ResInitCompleted
    --初始化资源
    SDBResourcesMgr.Initialize(true)

    --是否拥有亲友圈id
    if SDBRoomData.roomData.roomType == RoomType.Club then
        SDBRoomData.clubId = SDBRoomData.roomData.groupId
    end
end

--资源加载结束回调
function Init.ResInitCompleted()
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>  加载结束")
    SDBResourcesMgr.onInitCompleted = nil
    PanelManager.Open(SDBPanelConfig.SdbDesk)
    PanelManager.Open(SDBPanelConfig.Room)
    PanelManager.Open(SDBPanelConfig.Operation)
    PanelManager.Open(SDBPanelConfig.LoadRes)
end

local isDeskPanel = false
local isRoomPanel = false
local isOperationPanel = false
--十点半三个界面开启完成回调
function Init.OnSdbLoadEnd(panelName)
    if panelName == 1 then
        isDeskPanel = true
    elseif panelName == 2 then
        isRoomPanel = true
    elseif panelName == 3 then
        isOperationPanel = true
    end

    if isDeskPanel and isRoomPanel and isOperationPanel then
        RemoveMsg(SDBAction.SDBLoadEnd, Init.OnSdbLoadEnd)
        --登录场景打开完成
        GameSceneManager.SwitchGameSceneEnd(GameSceneType.Room)
        SDBRoomData.isInitRoomEnd = true

        Init.OnCompleteOpenPanel()
    end
end

function Init.OnCompleteOpenPanel()
    if SDBRoomData.isPlayback then
        SDBPlaybackMgr.Init(SDBRoomData.roomData.playbackData)
        PanelManager.Open(SDBPanelConfig.Playback)
    else
        SDBRoom.SendNetWorkData()
    end

    --关闭载入的遮罩
    Waiting.ForceHide()
end

--初始化房间信息
function Init.InitDatas()
    --初始化牌颜色
    local pokerColor = GetLocal(SDBAction.PokerStyleType, 1)
    SDBRoomData.cardColor = tonumber(pokerColor)

    local deskColor = GetLocal(SDBAction.DeskStypleType, 1)
    SDBRoomData.sdbDeskColor = tonumber(deskColor)
end

function Init.CloseUI()
    for _, v in pairs(SDBPanelConfig) do
        PanelManager.Close(v, true)
    end
end

function Init.Close()
    --清理房间协议信息（移除监听）
    SDBRoom.Clear()
    --清理资源
    SDBResourcesMgr.Clear()
    --清理RoomData
    SDBRoomData.Clear()
    SDBRoomData.isInitRoomEnd = false
    isDeskPanel = false
    isRoomPanel = false
    isOperationPanel = false
    ChatModule.UnInit()
    RemoveMsg(SDBAction.SDBLoadEnd, Init.OnSdbLoadEnd)
end

function Init.Unload()
    Log(">> 十点半 卸载资源")
    ResourcesManager.Unload(SDBBundleName.sdbPanels, false)
    ResourcesManager.Unload(SDBBundleName.sdbsound, false)
    ResourcesManager.Unload(SDBBundleName.sdbMusic, false)
    ResourcesManager.Unload(SDBBundleName.chat, false)
    ResourcesManager.Unload(BundleName.RoomDesk .. "1", false)
    ResourcesManager.Unload(BundleName.RoomDesk .. "2", false)
    ResourcesManager.Unload(BundleName.RoomDesk .. "3", false)
    ResourcesManager.Unload(BundleName.RoomDesk .. "4", false)
end

Init.AddLuaFiles()
return Init