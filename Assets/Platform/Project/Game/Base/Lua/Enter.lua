--管理器--
Enter = {
    --Loading界面进度完成标识
    isLoading = false,
    --预加载资源标识
    isPreloadCommon = false,
}
local this = Enter

function Enter.Require(path)
    require("AB/Base/Lua/" .. path)
end

function Enter.DoFile(path)
    dofile("AB/Base/Lua/" .. path)
end

function Enter.InitLuaFiles()
    this.Require("Define/BaseDefine")
    this.Require("Define/Functions")
    this.Require("Define/BaseCommand")
    this.Require("Define/ConfigData")
    this.Require("Define/BaseError")
    this.Require("Common/AppConfig")
    this.Require("Common/AppGlobal")
    this.Require("Common/Audio")
    --
    this.Require("Config/PanelConfig")
    --
    this.Require("CreateRoomConfig/TpConfig")
    this.Require("CreateRoomConfig/CreateRoomConfig")
    this.Require("CreateRoomConfig/MahjongConfig")
    this.Require("CreateRoomConfig/PdkConfig")
    this.Require("CreateRoomConfig/EqsConfig")
    this.Require("CreateRoomConfig/Pin5Config")
    this.Require("CreateRoomConfig/LYCConfig")
    this.Require("CreateRoomConfig/Pin3Config")
    this.Require("CreateRoomConfig/SDBConfig")
    --
    this.Require("Config/LobbyMatchConfig")
    this.Require("Config/TaskConfig")
    this.Require("Config/NoticeConfig")
    --
    this.Require("AppPlatformHelper")
    this.Require("Data/GlobalData")
    this.Require("Logic/GameSceneManager")
    this.Require("Logic/GameManager")
    this.Require("Logic/BaseTcpApi")
    this.Require("Logic/TeaApi")
    this.Require("Logic/BaseResourcesMgr")
    this.Require("Logic/ChatVoice")
    this.Require("Logic/GoldMatchMgr")
    this.Require("Logic/GPSModule")
    this.Require("Logic/QiNiuApiMgr")
    this.Require("Logic/TencentApiMgr")
    this.Require("Logic/SettingMgr")
    --客服聊天
    this.Require("Data/ServiceChatData")
    this.Require("Logic/ServiceChatMgr")

    --俱乐部
    this.Require("Define/ClubDefine")
    this.Require("Logic/ClubManager")
    this.Require("Data/ClubData")
    --
    this.Require("Data/TeaData")
    this.Require("Logic/BaseGlobalEventMgr")
    this.Require("Logic/PropsAnimationMgr")
    --复制功能
    this.Require("Util/RoomUtil")
    this.Require("Util/ScrollRectHelper")
    --聊天记录相关
    this.Require("Data/ChatDataManager")
    this.Require("Logic/ChatModule")
    this.Require("Logic/RedPointMgr")
    this.Require("Logic/SensitiveWordsManager")

    this.Require("Item/InputBtnIem")

    this.Require("View/CreateRoom/CreateMahjongRoomPanel")
    this.Require("View/CreateRoom/CreateEqsRoomPanel")
    this.Require("View/CreateRoom/CreateLSPdkRoomPanel")
    this.Require("View/CreateRoom/CreatePin5RoomPanel")
    this.Require("View/CreateRoom/CreateLYCRoomPanel")
    this.Require("View/CreateRoom/CreatePin3RoomPanel")
    this.Require("View/CreateRoom/CreateSDBRoomPanel")
    this.Require("View/CreateRoom/CreateRoomCommonPanel")
    this.Require("View/CreateRoom/ModifyMahjongRoomPanel")
    this.Require("View/CreateRoom/ModifyEqsRoomPanel")
    this.Require("View/CreateRoom/ModifyLSPdkRoomPanel")
    this.Require("View/CreateRoom/ModifyPin5RoomPanel")
    this.Require("View/CreateRoom/ModifyLYCRoomPanel")
    this.Require("View/CreateRoom/ModifyPin3RoomPanel")
    this.Require("View/CreateRoom/ModifySDBRoomPanel")
    this.Require("Define/LuckyValueDefine")
    --联盟
    this.Require("Define/UnionDefine")
    this.Require("Logic/UnionManager")
    this.Require("Data/UnionData")
    --
    --作用是过一次所有的面板脚本
    if AppConfig.IsScriptDebugEnabled then
        Functions.RequirePanelsScript(PanelConfig)
    end
end

--Base入口初始化完成
function Enter.OnInitOK()
    --日志处理
    LogUtil.IsPrintLog = AppConfig.IsLogEnabled
    this.SetPlatformFrameRate()
    Util.SetLogEnabled(AppConfig.IsLogEnabled)
    this.JudgePlatformSetLogReporter()
    --多点触碰处理
    Input.multiTouchEnabled = AppConfig.MultiTouchEnabled
    --UI全局初始化
    UIConst.Initialize()
    --初始全局事件管理
    BaseGlobalEventMgr.Initialize()
    --初始化基础UI
    Alert.SetPanelConfig(PanelConfig.Alert)
    Toast.SetPanelConfig(PanelConfig.Toast)
    Waiting.SetPanelConfig(PanelConfig.Waiting)
    Mask.SetPanelConfig(PanelConfig.Mask)
    --设置头像加载超时
    NetImageManager.LoadTimeout = 5
    NetImageManager.LoadMaxTotal = 5
    NetImageManager.ReloadMaxTotal = 0
    --设置进度
    Loading.SetSpeed(Loading.SPEED_NORMAL)
    Loading.SetProgress(0.8)
    Loading.SetFinishedCallback(this.OnLoadingFinishedCallback)
    --检测本地资源
    Functions.CheckLocalResources()

    --标记Lua启动完成
    AppConst.IsLuaStarted = true
    BaseTcpApi.Init()
    resMgr:AddDependencies("base")
    --预加载Waitting资源
    ResourcesManager.PreloadPrefabs(BundleName.Common, { "WaitingPanel" }, this.OnPreloadCommonCompleted)
    GameSceneManager.Init()

    --初始化屏蔽字库
    SensitiveWordsManager.Init()
    --设置初始化
    SettingMgr.Init()
    --网络初始化
    Network.Init()

    -- TryCatchCall(function()
    --     AppGlobal.littleVersion = AppConst.AppLittleVersion
    -- end)

    --快速初始化防护盾
    AppPlatformHelper.InitShield()

    GameSceneManager.SwitchGameScene(GameSceneType.Login)

    --设置截图路径
    AppGlobal.GetScreenshotPngPath = Application.persistentDataPath .. "/JieSuanScreenshot/";
    --聊天系统
    ServiceChatMgr.Init()
end

function Enter.SetPlatformFrameRate()
    Application.targetFrameRate = 60
end

function Enter.JudgePlatformSetLogReporter()
    if not IsOnlyPcPlatform() then
        this.SetLogReporterActive(AppConfig.IsLogEnabled and AppConfig.IsReporterEnabled)
    end
end

function Enter.SetLogReporterActive(bool)
    this.reporter = (not this.reporter) and GameObject.Find("Reporter")
    UIUtil.SetActive(this.reporter, bool)
end

--Loading进度完成回调
function Enter.OnLoadingFinishedCallback()
    this.isLoading = true
    this.CheckInitCompleted()
end

--预加载Common资源完成回调
function Enter.OnPreloadCommonCompleted()
    this.isPreloadCommon = true
    this.CheckInitCompleted()
end

--检测初始化是否完成，完成了才关闭Loading、销毁欢迎界面
function Enter.CheckInitCompleted()
    if this.isLoading and this.isPreloadCommon then
        Loading.Hidden()
        UIManager.Instance:DestroyInternalPanel("WelcomePanel")
    end
end
Enter.InitLuaFiles()
Enter.OnInitOK()