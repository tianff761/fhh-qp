--游戏管理，不是游戏应用管理，管理房间中的游戏，比如麻将、贰柒拾等
GameManager = {}
--游戏类型
GameManager.lastGameType = nil
--游戏名称
GameManager.lastGameName = nil
--参数对象
GameManager.tempArgs = nil
--游戏入口实例
GameManager.lastGame = nil
--
--临时使用的检测游戏的游戏类型
GameManager.tempCheckGameType = nil
--临时使用的检测游戏的回调
GameManager.tempCheckGameCallback = nil
--临时使用的检测游戏的显示名称
GameManager.tempCheckGameName = ""
--当前更新是否完成
GameManager.isUpgradeCompleted = true

local this = GameManager


--进入游戏
function GameManager.EnterRoom(gameType, args)
    this.HandleGame(gameType, args)
end

------------------------------------------------------------------
--
function GameManager.GetCurGameType()
    return GameManager.lastGameType
end

--处理游戏
function GameManager.HandleGame(gameType, args)
    if gameType == nil then
        LogWarn(">> GameManager.HandleGame > gameType = nil.")
        return
    end

    if this.lastGameType ~= gameType then
        this.UnloadGame()

        this.lastGameType = gameType
        this.lastGameName = Functions.GetGameName(gameType)
        if this.lastGameName == nil then
            LogWarn(">> GameManager.HandleGame > gameType = " .. tostring(gameType))
            return
        end
    end

    this.tempArgs = args

    this.InternalHandleGame()
end

--内部处理
function GameManager.InternalHandleGame()
    if this.lastGame == nil then
        this.InternalInitGame(this.lastGameName)
    end
    if this.tempArgs == nil then
        return
    end

    --保存全局的房间数据
    GlobalData.room.id = this.tempArgs.roomId
    GlobalData.room.gameType = this.tempArgs.gameType
    GlobalData.room.roomType = this.tempArgs.roomType
    GlobalData.room.moneyType = this.tempArgs.moneyType

    if this.lastGame ~= nil then
        this.lastGame.Init(this.tempArgs)
    end
end

------------------------------------------------------------------
--
--内部初始化游戏
function GameManager.InternalInitGame(gameName)
    Log('===gameName====',gameName)
    local lowerGameName = string.lower(gameName)
    Util.AddSearchBundle(lowerGameName, lowerGameName)
    resMgr:AddDependencies(lowerGameName)

    this.lastGame = dofile("AB/" .. gameName .. "/Lua/Init")
end

--卸载当前打开的游戏
function GameManager.UnloadGame()
    if this.lastGame ~= nil then
        this.lastGame.Unload()
        this.lastGame = nil
    end
    if this.lastGameType ~= nil then
        local lowerGameName = string.lower(this.lastGameName)
        Util.RemoveSearchBundle(lowerGameName)
        resMgr:RemoveDependencies(lowerGameName)
        this.lastGameType = nil
    end
end

--关闭游戏，但不卸载
function GameManager.Close()
    if this.lastGame ~= nil then
        this.lastGame.Close()
    end
end

--关闭UI
function GameManager.CloseUI()
    if this.lastGame ~= nil and IsFunction(this.lastGame.CloseUI) then
        this.lastGame.CloseUI()
    end
end

--================================================================
--
--检测基础是否需要更新，需要更新返回true，否则返回false
function GameManager.CheckBaseNeedUpgrade()
    if Functions.CheckGameNeedUpgradeByName("Base") then
        Alert.Show("版本需要更新，请重新启动更新版本", this.OnQuitAppAlert, "", AlertLevel.System)
        return true
    end
    return false
end

--检测游戏版本，用于创建房间等非进入游戏的地方
--如果资源检测成功返回true，失败false
--如果选择更新，则完成后通过callback返回
--isUpgrade更新
function GameManager.IsCheckGame(gameType, callback, isUpgrade)
    if GameManager.CheckBaseNeedUpgrade() then
        return false
    end

    if Functions.CheckGameNeedUpgrade(gameType) or isUpgrade == true then
        this.tempCheckGameType = gameType
        this.tempCheckGameCallback = callback
        --this.tempCheckGameName = Functions.GetGameNameText(this.tempCheckGameType)
        --Alert.Prompt("需要更新\"" .. Functions.GetGameNameText(gameType) .. "\"，是否更新？", this.OnCheckGameOkAlert, this.OnCheckGameCancelAlert)
        this.OnCheckGameOkAlert()
        return false
    else
        return true
    end
end

--强制检测，用于有房间号，进入房间时时候
function GameManager.IsCheckGameByForce(gameType, callback, isUpgrade)
    if GameManager.CheckBaseNeedUpgrade() then
        return false
    end

    if Functions.CheckGameNeedUpgrade(gameType) or isUpgrade == true then
        this.tempCheckGameType = gameType
        this.tempCheckGameCallback = callback
        --this.tempCheckGameName = Functions.GetGameNameText(this.tempCheckGameType)
        --Alert.Show("需要更新\"" .. Functions.GetGameNameText(gameType) .. "\"，是否更新？", this.OnCheckGameOkAlert, "", AlertLevel.System)
        this.OnCheckGameOkAlert()
        return false
    else
        return true
    end
end

--更新确定处理，首先更新版本文件
function GameManager.OnCheckGameOkAlert()
    --卸载该类型的游戏
    if this.lastGameType == this.tempCheckGameType then
        this.UnloadGame()
    end
    --卸载预加载的游戏面板等
    ResourcesManager.UnloadPreload(this.tempCheckGameType)
    --
    this.isUpgradeCompleted = false
    --Waiting设置最大时间
    Waiting.Show(this.tempCheckGameName .. "更新中...", nil, 600)
    UpgradeManager.Instance:CheckRemoteConfig(this.OnCheckRemoteConfigCallback)
end

--检测版本文件返回，如果基础资源不更新，则更新游戏资源
function GameManager.OnCheckRemoteConfigCallback()
    if GameManager.CheckBaseNeedUpgrade() then
        Waiting.Hide()
    else
        local gameName = Functions.GetGameName(this.tempCheckGameType)
        if gameName == nil then
            Alert.Show("更新错误，请联系客服")
        else
            UpgradeManager.Instance:CheckWithoutVersion(gameName, this.OnCheckFinshCallback, this.OnCheckProgressCallback)
        end
    end
end

--更新取消处理
function GameManager.OnCheckGameCancelAlert()
    Toast.Show("更新取消，无法创建或进入游戏房间")
end

--资源检测完成
function GameManager.OnCheckFinshCallback()
    Waiting.Hide()
    Toast.Show(this.tempCheckGameName .. "更新完成")
    if this.tempCheckGameCallback ~= nil then
        this.tempCheckGameCallback()
    end
end

function GameManager.OnCheckProgressCallback(status, progress)
    --当前更新完成或者在房间中，就提示更新进度
    if this.isUpgradeCompleted or GameSceneManager.IsRoomScene() then
        return
    end
    local temp = progress / 0.7 * 100--由于最多为70%
    --防止超过100%
    if temp >= 100 then
        temp = 100
        this.isUpgradeCompleted = true
    end
    temp = math.Round(temp, 2)
    --Waiting设置最大时间，防止更新过慢，自动隐藏
    Waiting.Show(this.tempCheckGameName .. "更新中..." .. temp .. "%", nil, 600)
end

--退出应用提示
function GameManager.OnQuitAppAlert()
    AppPlatformHelper.QuitGame()
end