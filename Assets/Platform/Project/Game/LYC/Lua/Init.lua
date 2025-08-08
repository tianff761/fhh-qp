local Init = {}
function Init.AddLuaFiles()
    local logicPath = "AB/LYC/Lua/Logic/"
    local commonPath = "AB/LYC/Lua/Common/"
    local dataPath = "AB/LYC/Lua/Data/"

    ---------------------------------------------
    require(logicPath .. "LYCDefine")
    require(logicPath .. "LYCResourcesMgr")
    require(logicPath .. "LYCRoom")
    require(logicPath .. "LYCRoomAnimator")
    require(logicPath .. "LYCContentTip")
    ---------------------------------------------
    require(dataPath .. "LYCRoomData")
    require(dataPath .. "LYCPlayer")
    require(dataPath .. "LYCPlayerItem")
    require(dataPath .. "LYCPokerCard")
    require(dataPath .. "LYCConst")
    ---------------------------------------------
    require(commonPath .. "LYCFuntions")
    require(commonPath .. "LYCAction")
    require(commonPath .. "LYCApiExtend")
end

function Init.PreloadPrefabs()
    LYCResourcesMgr.Initialize(false)
end

function Init.Init(args)
    Log("执行捞腌菜逻辑", args)
    LYCRoomData.Clear()
    LYCRoomData.roomData = args
    LYCRoomData.isPlayback = args.isPlayback == true
    Init.PresLoadRes()
    if not IsNil(LYCRoomData.roomData) then
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
    LYCResourcesMgr.LoadDesk(LYCRoomData.lycDeskColor)
end

function Init.EnterRoom()
    LYCRoomData.isInitRoomEnd = false
    Log(">>>>>>>>>>>>>>>>>>>       开始加载资源")

    --是否可以发送数据
    LYCRoomData.isCandSend = not LYCRoomData.isPlayback
    ChatModule.SetIsCanSend(not LYCRoomData.isPlayback)

    --初始化协议
    if not LYCRoomData.isPlayback then
        LYCRoom.Initialize()
    end

    AddMsg(LYCAction.LYCLoadEnd, Init.OnLYCLoadEnd)
    --初始化玩家
    LYCRoomData.mainId = LYCRoomData.roomData.userId

    --增加资源加载回调
    LYCResourcesMgr.onInitCompleted = Init.ResInitCompleted
    --初始化资源
    LYCResourcesMgr.Initialize(true)

    LYCRoomData.groupId = LYCRoomData.roomData.groupId

    --是否拥有亲友圈id
    if LYCRoomData.roomData.roomType == RoomType.Club then
        LYCRoomData.clubId = LYCRoomData.roomData.groupId
    end
    --检测加载完成，主要是用于再来一局检测
    Init.OnLYCLoadEnd()
end

--资源加载结束回调
function Init.ResInitCompleted()
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>  加载结束")
    LYCResourcesMgr.onInitCompleted = nil
    PanelManager.Open(LYCPanelConfig.LYCDesk)
    PanelManager.Open(LYCPanelConfig.Room)
    PanelManager.Open(LYCPanelConfig.Operation)
    PanelManager.Open(LYCPanelConfig.LoadRes)
end

local isDeskPanel = false
local isRoomPanel = false
local isOperationPanel = false
--三个界面开启完成回调
function Init.OnLYCLoadEnd(panelName)
    if panelName == 1 then
        isDeskPanel = true
    elseif panelName == 2 then
        isRoomPanel = true
    elseif panelName == 3 then
        isOperationPanel = true
    end

    if isDeskPanel and isRoomPanel and isOperationPanel then
        RemoveMsg(LYCAction.LYCLoadEnd, Init.OnLYCLoadEnd)
        --登录场景打开完成
        GameSceneManager.SwitchGameSceneEnd(GameSceneType.Room)
        LYCRoomData.isInitRoomEnd = true

        Init.OnCompleteOpenPanel()
    end
end

function Init.OnCompleteOpenPanel()
    Log(">>>>>>>>>>>>>  LYCRoomData.isPlayback = ", LYCRoomData.isPlayback)
    --清除界面相关
    LYCRoomPanel.Clear()
    if LYCRoomData.isPlayback then
        LYCPlaybackMgr.Init(LYCRoomData.roomData.playbackData)
        PanelManager.Open(LYCPanelConfig.Playback)
    else
        LYCRoom.SendNetWorkData()
    end

    --关闭载入的遮罩
    Waiting.ForceHide()
end

--初始化房间信息
function Init.InitDatas()
    --初始化牌颜色
    local pokerColor = GetLocal(LYCAction.PokerStyleType, 2)
    LYCRoomData.cardColor = tonumber(pokerColor)

    local deskColor = GetLocal(LYCAction.DeskStypleType, 1)
    LYCRoomData.lycDeskColor = tonumber(deskColor)
end

function Init.CloseUI()
    for _, v in pairs(LYCPanelConfig) do
        PanelManager.Close(v, true)
    end
end

function Init.Close()
    --清理房间协议信息（移除监听）
    LYCRoom.Clear()
    --清理资源
    LYCResourcesMgr.Clear()
    --清理RoomData
    LYCRoomData.Clear()
    LYCRoomData.isInitRoomEnd = false
    isDeskPanel = false
    isRoomPanel = false
    isOperationPanel = false
    ChatModule.UnInit()
    RemoveMsg(LYCAction.LYCLoadEnd, Init.OnLYCLoadEnd)
end

function Init.Unload()
    Log(">> 捞腌菜 卸载资源")
    ResourcesManager.Unload(LYCBundleName.lycPanels, false)
    ResourcesManager.Unload(LYCBundleName.lycsound, false)
    ResourcesManager.Unload(LYCBundleName.lycMusic, false)
    ResourcesManager.Unload(LYCBundleName.chat, false)
    ResourcesManager.Unload(BundleName.RoomDesk .. "1", false)
    ResourcesManager.Unload(BundleName.RoomDesk .. "2", false)
    ResourcesManager.Unload(BundleName.RoomDesk .. "3", false)
    ResourcesManager.Unload(BundleName.RoomDesk .. "4", false)
end

Init.AddLuaFiles()
return Init