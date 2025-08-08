local Init = {}
function Init.AddLuaFiles()
    local logicPath = "AB/Pin5/Lua/Logic/"
    local commonPath = "AB/Pin5/Lua/Common/"
    local dataPath = "AB/Pin5/Lua/Data/"

    ---------------------------------------------
    require(logicPath .. "Pin5Define")
    require(logicPath .. "Pin5ResourcesMgr")
    require(logicPath .. "Pin5Room")
    require(logicPath .. "Pin5RoomAnimator")
    require(logicPath .. "Pin5ContentTip")
    ---------------------------------------------
    require(dataPath .. "Pin5RoomData")
    require(dataPath .. "Pin5Player")
    require(dataPath .. "Pin5PlayerItem")
    require(dataPath .. "Pin5PokerCard")
    require(dataPath .. "Pin5Const")
    ---------------------------------------------
    require(commonPath .. "Pin5Funtions")
    require(commonPath .. "Pin5Action")
    require(commonPath .. "Pin5ApiExtend")
end

function Init.PreloadPrefabs()
    Pin5ResourcesMgr.Initialize(false)
end

function Init.Init(args)
    Log(">> Pin5 > Init.Init > ", args)
    Pin5RoomData.Clear()
    Pin5RoomData.roomData = args
    Pin5RoomData.isPlayback = args.isPlayback == true
    Init.PresLoadRes()
    if not IsNil(Pin5RoomData.roomData) then
        Init.EnterRoom()
    else
        LogError(">> Pin5 > Init.Init > 数据错误")
    end
end

--预加载资源
function Init.PresLoadRes()
    --初始化数据 获取本地的扑克牌颜色，桌面颜色等
    Init.InitDatas()
    --预加载桌面
    Pin5ResourcesMgr.LoadDesk(Pin5RoomData.pin5DeskColor)
end

function Init.EnterRoom()
    Pin5RoomData.isInitRoomEnd = false
    Log(">> Pin5 > Init.EnterRoom")

    --是否可以发送数据
    Pin5RoomData.isCandSend = not Pin5RoomData.isPlayback
    ChatModule.SetIsCanSend(not Pin5RoomData.isPlayback)

    --初始化协议
    if not Pin5RoomData.isPlayback then
        Pin5Room.Initialize()
    end

    AddMsg(Pin5Action.Pin5LoadEnd, Init.OnPin5LoadEnd)
    --初始化玩家
    Pin5RoomData.mainId = Pin5RoomData.roomData.userId

    --增加资源加载回调
    Pin5ResourcesMgr.onInitCompleted = Init.ResInitCompleted
    --初始化资源
    Pin5ResourcesMgr.Initialize(true)

    Pin5RoomData.groupId = Pin5RoomData.roomData.groupId

    --是否拥有亲友圈id
    if Pin5RoomData.roomData.roomType == RoomType.Club then
        Pin5RoomData.clubId = Pin5RoomData.roomData.groupId
    end
    --检测加载完成，主要是用于再来一局检测
    Init.OnPin5LoadEnd()
end

--资源加载结束回调
function Init.ResInitCompleted()
    Log(">> Pin5 > Init.ResInitCompleted > 加载结束")
    Pin5ResourcesMgr.onInitCompleted = nil
    PanelManager.Open(Pin5PanelConfig.Pin5Desk)
    PanelManager.Open(Pin5PanelConfig.Room)
    PanelManager.Open(Pin5PanelConfig.Operation)
    PanelManager.Open(Pin5PanelConfig.LoadRes)
end

local isDeskPanel = false
local isRoomPanel = false
local isOperationPanel = false
--三个界面开启完成回调
function Init.OnPin5LoadEnd(panelName)
    LogError(">> Pin5 > Init.OnPin5LoadEnd > panelName > ", panelName)
    if panelName == 1 then
        isDeskPanel = true
    elseif panelName == 2 then
        isRoomPanel = true
    elseif panelName == 3 then
        isOperationPanel = true
    end

    if isDeskPanel and isRoomPanel and isOperationPanel then
        RemoveMsg(Pin5Action.Pin5LoadEnd, Init.OnPin5LoadEnd)
        --登录场景打开完成
        GameSceneManager.SwitchGameSceneEnd(GameSceneType.Room)
        Pin5RoomData.isInitRoomEnd = true

        Init.OnCompleteOpenPanel()
    end
end

function Init.OnCompleteOpenPanel()
    Log(">> Pin5 > Init.OnCompleteOpenPanel > Pin5RoomData.isPlayback = ", Pin5RoomData.isPlayback)
    --清除界面相关
    Pin5RoomPanel.Clear()
    if Pin5RoomData.isPlayback then
        Pin5PlaybackMgr.Init(Pin5RoomData.roomData.playbackData)
        PanelManager.Open(Pin5PanelConfig.Playback)
    else
        Pin5Room.SendNetWorkData()
    end
    --关闭载入的遮罩
    Waiting.ForceHide()
end

--初始化房间信息
function Init.InitDatas()
    --初始化牌颜色
    local pokerColor = GetLocal(Pin5Action.PokerStyleType, 1)
    Pin5RoomData.cardColor = tonumber(pokerColor)

    local deskColor = GetLocal(Pin5Action.DeskStypleType, 1)
    Pin5RoomData.pin5DeskColor = tonumber(deskColor)
end

function Init.CloseUI()
    for _, v in pairs(Pin5PanelConfig) do
        PanelManager.Close(v, true)
    end
end

function Init.Close()
    --清理房间协议信息（移除监听）
    Pin5Room.Clear()
    --清理资源
    Pin5ResourcesMgr.Clear()
    --清理RoomData
    Pin5RoomData.Clear()
    Pin5RoomData.isInitRoomEnd = false
    isDeskPanel = false
    isRoomPanel = false
    isOperationPanel = false
    ChatModule.UnInit()
    RemoveMsg(Pin5Action.Pin5LoadEnd, Init.OnPin5LoadEnd)
end

function Init.Unload()
    Log(">> Pin5 > Init.Unload > 卸载资源")
    ResourcesManager.Unload(Pin5BundleName.pin5Panels, false)
    ResourcesManager.Unload(Pin5BundleName.pin5sound, false)
    ResourcesManager.Unload(Pin5BundleName.pin5Music, false)
    ResourcesManager.Unload(Pin5BundleName.chat, false)
    ResourcesManager.Unload(BundleName.RoomDesk .. "1", false)
    ResourcesManager.Unload(BundleName.RoomDesk .. "2", false)
    ResourcesManager.Unload(BundleName.RoomDesk .. "3", false)
    ResourcesManager.Unload(BundleName.RoomDesk .. "4", false)
end

Init.AddLuaFiles()
return Init
