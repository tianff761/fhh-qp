--================================================================
--游戏场景基类
GameScene = Class("GameScene")
GameScene.type = nil

function GameScene:ctor(type)
    self.type = type
end

--打开
function GameScene:Open(gameType)

end

--关闭功能部分，包括事件移除
function GameScene:Close()

end

--关闭UI部分
function GameScene:CloseUI()

end

--================================================================
--游戏场景登录
GameSceneLogin = GameScene.New(GameSceneType.Login)

function GameSceneLogin:Open(gameType, args)
    Audio.PlayLobbyMusic()
    PanelManager.Open(PanelConfig.Login)
end

function GameSceneLogin:Close()

end

function GameSceneLogin:CloseUI()
    PanelManager.Destroy(PanelConfig.Login, true)
    PanelManager.Destroy(PanelConfig.PhoneRegister, true)
    PanelManager.Destroy(PanelConfig.PhoneLogin, true)
    ResourcesManager.Unload(BundleName.Login, true)
    ResourcesManager.CheckGC(true)
    ResourcesManager.CheckGC()
end

--================================================================
--大厅场景登录
GameSceneLobby = GameScene.New(GameSceneType.Lobby)

function GameSceneLobby:Open(gameType, args)
    Audio.PlayLobbyMusic()
    PanelManager.Open(PanelConfig.Lobby, args)
end

function GameSceneLobby:Close()

end

function GameSceneLobby:CloseUI()
    Log(">> GameScene > GameSceneLobby > CloseUI.")
    PanelManager.Close(PanelConfig.Lobby)
    PanelManager.Close(PanelConfig.LobbyMacth)
    PanelManager.Destroy(PanelConfig.UserInfo)
    --
    PanelManager.Destroy(PanelConfig.Activity, true)
    PanelManager.Destroy(PanelConfig.ShengMing, true)
    --
    --处理俱乐部、联盟战绩界面
    if AppGlobal.recordType ~= nil then
        if RecordPanel ~= nil then
            RecordPanel.Hide()
        end
        if RecordDetailPanel ~= nil then
            RecordDetailPanel.Hide()
        end
        if RecordSubPanel then
            RecordSubPanel.Hide()
        end
    else
        PanelManager.Close(PanelConfig.Record)
        PanelManager.Close(PanelConfig.RecordSub)
    end
    --
    TeaData.CloseAllTeaPanel()
    PanelManager.CloseAll()
    ResourcesManager.CheckGC(true)
    ResourcesManager.CheckGC()
end

--================================================================
--房间场景登录
GameSceneRoom = GameScene.New(GameSceneType.Room)

function GameSceneRoom:Open(gameType, args)
    GameManager.EnterRoom(gameType, args)
end

function GameSceneRoom:Close()
    GameManager.Close()
end

function GameSceneRoom:CloseUI()
    GameManager.CloseUI()
    --关闭统一的房间面板
    PanelManager.Close(PanelConfig.GoldMatch)
    PanelManager.Close(PanelConfig.RoomGps)
    UserData.SetRoomId(0)
    UserData.SetIsReconnectTag(false)
    ResourcesManager.CheckGC(true)
    ResourcesManager.CheckGC()
end

--================================================================
--游戏场景管理
GameSceneManager = {}
GameSceneManager.gameScenes = {}
GameSceneManager.lastGameScene = nil
GameSceneManager.currGameScene = nil
GameSceneManager.timeCount = 0

function GameSceneManager.Init()
    GameSceneManager.gameScenes[GameSceneType.Login] = GameSceneLogin
    GameSceneManager.gameScenes[GameSceneType.Lobby] = GameSceneLobby
    GameSceneManager.gameScenes[GameSceneType.Room] = GameSceneRoom
end

--切换游戏场景，并非Unity的场景，游戏类型、参数
function GameSceneManager.SwitchGameScene(gameSceneType, gameType, args)
    Log(">> GameSceneManager.SwitchGameScene > Opend > gameSceneType = " .. tostring(gameSceneType), gameType, args)
    if GameSceneManager.currGameScene ~= nil then
        if GameSceneManager.currGameScene.type == gameSceneType then
            GameSceneManager.currGameScene:Open(gameType, args)
            LogWarn(">> GameSceneManager.SwitchGameScene > Opend > gameSceneType = " .. tostring(gameSceneType))
            return
        end
    end

    --战绩回放类型处理
    if IsTable(args) then
        AppGlobal.recordType = args.recordType
    else
        AppGlobal.recordType = nil
    end

    GameSceneManager.timeCount = os.timems()

    GameSceneManager.lastGameScene = GameSceneManager.currGameScene
    if GameSceneManager.lastGameScene ~= nil then
        GameSceneManager.lastGameScene:Close()
    end
    GameSceneManager.currGameScene = GameSceneManager.gameScenes[gameSceneType]
    GameSceneManager.currGameScene:Open(gameType, args)
end

--切换场景结束，包括了切换的UI完成
function GameSceneManager.SwitchGameSceneEnd(gameSceneType)
    Log(">> GameSceneManager > SwitchGameSceneEnd > ", gameSceneType, os.timems() - GameSceneManager.timeCount)
    if GameSceneManager.lastGameScene ~= nil and GameSceneManager.lastGameScene.type ~= gameSceneType then
        GameSceneManager.lastGameScene:CloseUI()
    end
    --LogError("切换场景完成后currGameScene Type", GameSceneManager.currGameScene.type)
    --GameSceneManager.lastGameScene = GameSceneManager.currGameScene
    --LogError("切换场景完成后lastGameScene Type", GameSceneManager.lastGameScene.type)
end

--检测是否是指定场景
function GameSceneManager.CheckGameScene(gameSceneType)
    if GameSceneManager.currGameScene ~= nil then
        if GameSceneManager.currGameScene.type == gameSceneType then
            return true
        end
    end
    return false
end

--是否登录场景，封装便于使用
function GameSceneManager.IsLoginScene()
    return GameSceneManager.CheckGameScene(GameSceneType.Login)
end

--是否房间场景，封装便于使用
function GameSceneManager.IsRoomScene()
    return GameSceneManager.CheckGameScene(GameSceneType.Room)
end

--是否大厅场景，封装便于使用
function GameSceneManager.IsLobbyScene()
    return GameSceneManager.CheckGameScene(GameSceneType.Lobby)
end