LoginPanel = ClassPanel("LoginPanel")
--登录类型，1测试登录，2平台设备登录
LoginPanel.loginType = LoginType.Release
--测试服务器类型
LoginPanel.testServerType = 1
--测试服务器选择的索引
LoginPanel.testServerIndex = 1
--测试服务器数据s
LoginPanel.testServerData = nil
--服务器的选择项
LoginPanel.serverItems = {}
--是否游戏登录标识
LoginPanel.isGameLogin = false
--提示时间
LoginPanel.tipsTime = 0
--登录使用的Timer
LoginPanel.loginTimer = nil
--登录时间
LoginPanel.lastLoginTime = 0
--是否处理了测试节点
LoginPanel.isHandleTestNode = false
--临时登录数据
LoginPanel.tempLoginData = nil
--
local this = LoginPanel


--UI初始化
function LoginPanel:OnInitUI()
    this = self
    this.background = this:Find("Background/BgImage").gameObject
    -- this.backgroundRectTransform = this.background:GetComponent(TypeRectTransform)
    Functions.SetBackgroundAdaptation(this.background:GetComponent(TypeImage))
    -- this.bgAnim = this:Find("Background/BgImage/Armature")

    -- --处理背景动画的缩放
    -- local sizeDelta = this.backgroundRectTransform.sizeDelta
    -- local scale = sizeDelta.y / AppConst.ReferenceResolution.y * 100
    -- this.bgAnim.localScale = Vector3(scale, scale, 1)
    --this.bgAnim = this:Find("Background/BgArmature")
    --UIUtil.SetBackgroundAnimAdaptation(this.bgAnim, 1280, 720)

    this.versionTxt = this:Find("Bottom/VersionTxt"):GetComponent(TypeText)

    --按钮
    local btnsNodeTrans = this:Find("BtnsNode")
    this.wechatBtn = btnsNodeTrans:Find("WeChatBtn").gameObject
    this.visitorBtn = btnsNodeTrans:Find("VisitorBtn").gameObject
    this.phoneBtn = btnsNodeTrans:Find("PhoneBtn").gameObject

    this.AddUIListenerEvent()

    --初始化语音
    --ChatVoice.Init()
    PlatformHelper.InitWeChat(AppConfig.WeChatAppId, AppConfig.WeChatAppSecret)
end

--当面板开启开启时
function LoginPanel:OnOpened()
    if AppGlobal.isMiniGame then
        UIManager.Instance:DestroyInternalPanel("WelcomePanel")
    end
    --登录场景打开完成
    GameSceneManager.SwitchGameSceneEnd(GameSceneType.Login)
    --设置Loading相关
    Loading.SetSpeed(Loading.SPEED_FAST)
    Loading.SetProgress(1)

    this.AddListenerEvent()

    --版本号处理
    local verStr = "" .. AppConst.AppVerStr
    -- if AppGlobal.littleVersion > 0 then
    --     verStr = verStr .. "." .. AppGlobal.littleVersion
    -- else
    --     verStr = verStr .. ".1"
    -- end
    verStr = "AppVer："..verStr .. "\nResVer：" .. Functions.GetResVersionStrByName("Base")
    this.versionTxt.text = verStr

    --重置登录事件
    this.lastLoginTime = 0
    --检查是否可以自动登录
    this.CheckAutoLogin()
    --检测测试
    this.CheckContainer()
    --请求IP地址
    --self.RequestIp()
    --不是编辑器平台才进行初始化
    if IsEditorPlatform() then
        this.OnPreloadCompleted()
    else
        --预加载大厅面板
        ResourcesManager.PreloadPrefabs(BundleName.Panel, { "LobbyPanel" }, this.OnPreloadCompleted)
    end

    local mainGame = GetLocal("MainGame", "")
    if mainGame ~= "MainGame" then
        Log(">> LoginPanel:OnOpened > Set > MainGame.")
        SetLocal("MainGame", "MainGame")
    end

    GlobalData.platform.deviceId = SystemInfo.deviceUniqueIdentifier
end

--当面板关闭时调用
function LoginPanel:OnClosed()
    this.isGameLogin = false
    this.StopLoginTimer()
    this.RemoveListenerEvent()
end

------------------------------------------------------------------
--注册事件
function LoginPanel.AddListenerEvent()
    AddEventListener(CMD.Game.Login, this.OnGameLogin)
    AddEventListener(CMD.Game.AuthLogin, this.OnAuthLogin)
end

--移除事件
function LoginPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Game.Login, this.OnGameLogin)
    RemoveEventListener(CMD.Game.AuthLogin, this.OnAuthLogin)
end

--UI相关事件
function LoginPanel.AddUIListenerEvent()
    this:AddOnClick(this.wechatBtn, this.OnWeChatBtnClick)
    this:AddOnClick(this.visitorBtn, this.OnVisitorBtnClick)
    this:AddOnClick(this.phoneBtn, this.OnPhoneBtnClick)
end

--================================================================
--准备资源
function LoginPanel.OnPreloadCompleted()
    Log(">> LoginPanel.OnPreloadCompleted > ======== > Preload.")
    BaseResourcesMgr.Initialize()
    this.CheckEnterLobbyOrRoom()
end

--准备麻将资源
function LoginPanel.OnMahjongPreloadCompleted()
    Log(">> LoginPanel.OnMahjongPreloadCompleted > ======== > Mahjong Preload.")
end


--================================================================
--
function LoginPanel.CheckTestNode()
    if not this.isHandleTestNode then
        this.isHandleTestNode = true
        --测试登录
        this.testContainerTrans = this:Find("TestContainer")
        this.testContainerGO = this.testContainerTrans.gameObject
        this.idInput = this.testContainerTrans:Find("IdInput"):GetComponent(TypeInputField)
        this.testLoginBtn = this.testContainerTrans:Find("TestLoginBtn").gameObject

        local customTrans = this.testContainerTrans:Find("Custom")
        this.custom = customTrans.gameObject
        this.switchBtn2 = customTrans:Find("SwitchBtn2").gameObject
        this.ipInput = customTrans:Find("IpInput"):GetComponent(TypeInputField)

        local selectTrans = this.testContainerTrans:Find("Select")
        this.select = selectTrans.gameObject
        this.switchBtn1 = selectTrans:Find("SwitchBtn1").gameObject
        this.serverListBtn = selectTrans:Find("ServerListBtn").gameObject
        this.serverListBtnTxt = selectTrans:Find("ServerListBtn/Text"):GetComponent(TypeText)

        local serverListScrollViewTrans = this.testContainerTrans:Find("ServerListScrollView")
        this.serverListScrollViewGO = serverListScrollViewTrans.gameObject
        this.serverListItemGO = serverListScrollViewTrans:Find("Viewport/Content/Item").gameObject
        this.headUrlInput = this.testContainerTrans:Find("HeadUrlInput"):GetComponent(TypeInputField)

        this.testPhoneBtn = this.testContainerTrans:Find("TestPhoneBtn").gameObject
        this.testVisitorBtn = this.testContainerTrans:Find("TestVisitorBtn").gameObject

        --事件
        this:AddOnClick(this.testLoginBtn, this.OnTestLoginBtnClick)
        this:AddOnClick(this.serverListBtn, this.OnServerListBtnClick)
        this:AddOnClick(this.switchBtn1, this.OnTestSwitchBtn1Click)
        this:AddOnClick(this.switchBtn2, this.OnTestSwitchBtn2Click)

        this:AddOnClick(this.testPhoneBtn, this.OnTestPhoneBtnClick)
        this:AddOnClick(this.testVisitorBtn, this.OnTestVisitorBtnClick)
    end
end
--检测容器
function LoginPanel.CheckContainer()
    --编辑器下，显示测试登录界面，非编辑器需要判读App版本号为测试版本
    if AppConfig.LoginType == LoginType.Test or IsEditorOrPcPlatform() then
        this.CheckTestNode()
        UIUtil.SetActive(this.testContainerGO, true)

        this.testServerType = 1
        this.testServerIndex = 1
        local serverAddress = ""
        local testLoginID = ""
        local tempStr = nil

        --如果是编辑器或者PC端都读取项目文件
        if IsEditorOrPcPlatform() then
            tempStr = Util.GetFileText(Util.GetProjectPath() .. "TestServerIndex.txt")
            testLoginID = Util.GetFileText(Util.GetProjectPath() .. "TestServerLoginId.txt")
        else
            tempStr = GetLocal(LocalDatas.TestServerIndex, "")
            testLoginID = GetLocal(LocalDatas.TestLoginID, "")
        end

        if string.IsNullOrEmpty(tempStr) then
            tempStr = "1,1,"
        end
        if testLoginID == nil then
            testLoginID = ""
        end

        local tempArr = string.split(tempStr, ",")

        this.testServerType = tonumber(tempArr[1])
        if this.testServerType == nil then
            this.testServerType = 1
        end

        this.testServerIndex = tonumber(tempArr[2])
        if this.testServerIndex == nil then
            this.testServerIndex = 1
        end

        serverAddress = tempArr[3]
        if serverAddress == nil then
            serverAddress = ""
        end
        this.ipInput.text = serverAddress

        if this.testServerType == 1 then
            --选择列表
            UIUtil.SetActive(this.select, true)
            UIUtil.SetActive(this.custom, false)
        else
            UIUtil.SetActive(this.select, false)
            UIUtil.SetActive(this.custom, true)
        end

        local serverData = nil
        local length = #AppConfig.TestServerList
        this.serverItems = ClearObjList(this.serverItems)
        for i = 1, length do
            serverData = AppConfig.TestServerList[i]
            local go = UIUtil.Duplicate(this.serverListItemGO)
            go.name = tostring(i)
            local txt = go.transform:Find("Text"):GetComponent(TypeText)
            txt.text = serverData.name
            this:AddOnClick(go, HandlerArgs(this.OnServerItemClick, i))
        end

        UIUtil.SetActive(this.serverListScrollViewGO, false)
        this.SetTestServerByIndex()

        if string.IsNullOrEmpty(testLoginID) then
            this.idInput.text = ""
        else
            this.idInput.text = testLoginID
        end
    else
        if this.testContainerGO ~= nil then
            UIUtil.SetActive(this.testContainerGO, false)
        end
    end
end

--设置服务器链接
function LoginPanel.SetServerAndLogin()
    if this.loginType == LoginType.Test then
        if this.testServerData == nil then
            Toast.Show("请确认服务器是否正确")
            return
        end
        GlobalData.ServerConfigData = this.testServerData
        --测试状态不使用盾
        Network.SetIsUseDun(false)
    else
        GlobalData.ServerConfigData = AppConfig.ServerList[1]
        --正式登录，需要检查是否为编辑器模式等
        Network.SetIsUseDun(AppConfig.ShieldType ~= nil and AppConfig.ShieldType > 0 and not IsEditorPlatform())
    end
    Network.SetServer(GlobalData.ServerConfigData.address, GlobalData.ServerConfigData.port)
    GlobalTcpApi.SendLogin()
end

--保存测试服务器数据
function LoginPanel.SaveTestServerData(serverType, serverIndex, serverAddress)
    local temp = serverType .. "," .. serverIndex .. "," .. serverAddress
    if IsEditorOrPcPlatform() then
        Util.SaveToFile(Util.GetProjectPath() .. "TestServerIndex.txt", temp)
    else
        SetLocal(LocalDatas.TestServerIndex, temp)
    end
end

function LoginPanel.SaveTestLoginID(id)
    if IsEditorOrPcPlatform() then
        Util.SaveToFile(Util.GetProjectPath() .. "TestServerLoginId.txt", id)
    else
        SetLocal(LocalDatas.TestLoginID, id)
    end
end

--检测和更新测试服务器地址
function LoginPanel.CheckAndUpdateTestServer()
    local configData = nil
    local ipInputTxt = this.ipInput.text
    if this.testServerType == 1 then
        configData = AppConfig.TestServerList[this.testServerIndex]
        if configData == nil then
            Toast.Show("请选择正确的服务器")
            return false
        end
    else
        if string.IsNullOrEmpty(ipInputTxt) then
            Toast.Show("请输入服务器地址")
            return false
        end
        local ipArr = string.split(ipInputTxt, ":")
        if #ipArr < 2 then
            Toast.Show("请输入正确的服务器地址")
            return false
        end
        local ip = ipArr[1]
        local port = tonumber(ipArr[2])
        if port == nil then
            Toast.Show("请输入正确的服务器端口")
            return false
        end
        configData = { name = "自定义服务器", address = ip, port = port }
    end

    this.testServerData = configData
    this.SaveTestServerData(this.testServerType, this.testServerIndex, ipInputTxt)
    return true
end

--测试登录按钮点击处理
function LoginPanel.OnTestLoginBtnClick()
    if not this.CheckAndUpdateTestServer() then
        return
    end
    local id = this.idInput.text
    if string.IsNullOrEmpty(id) then
        Toast.Show("请输入正确的ID")
        return
    end
    this.SaveTestLoginID(id)

    local head = this.headUrlInput.text

    local data = {
        deviceId = id,
        platformType = PlatformType.NONE
    }
    local random = Util.Random(0, 100)
    if random > 50 then
        data.sex = Global.GenderType.Female
    else
        data.sex = Global.GenderType.Male
    end

    this.LoginToServer(data)
end

--测试手机登录
function LoginPanel.OnTestPhoneBtnClick()
    AppGlobal.isTest = true
    if not this.CheckAndUpdateTestServer() then
        return
    end
    PanelManager.Open(PanelConfig.PhoneLogin)
end

--测试游客登录
function LoginPanel.OnTestVisitorBtnClick()
    if not this.CheckAndUpdateTestServer() then
        return
    end
    AppGlobal.isTest = true
    local data = {
        openId = UserData.GetDeviceId(),
        platformType = PlatformType.NONE
    }
    this.VisitorLoginToServer(data)
end


--服务器列表按钮按钮点击处理
function LoginPanel.OnServerListBtnClick()
    if this.serverListScrollViewGO.activeSelf then
        UIUtil.SetActive(this.serverListScrollViewGO, false)
    else
        UIUtil.SetActive(this.serverListScrollViewGO, true)
    end
end

--测试切换按钮1
function LoginPanel.OnTestSwitchBtn1Click()
    UIUtil.SetActive(this.select, false)
    UIUtil.SetActive(this.serverListScrollViewGO, false)
    UIUtil.SetActive(this.custom, true)
    this.testServerType = 2
end

--测试切换按钮2
function LoginPanel.OnTestSwitchBtn2Click()
    UIUtil.SetActive(this.select, true)
    UIUtil.SetActive(this.custom, false)
    this.testServerType = 1
end

--服务器列表选项按钮按钮点击处理
function LoginPanel.OnServerItemClick(index)
    this.testServerIndex = index
    this.SetTestServerByIndex()
    UIUtil.SetActive(this.serverListScrollViewGO, false)
end

--微信按钮
function LoginPanel.OnWeChatBtnClick()
    AppGlobal.isTest = false
    PlatformHelper.AuthLogin(PlatformType.WECHAT)
end

--游客按钮
function LoginPanel.OnVisitorBtnClick()
    AppGlobal.isTest = false
    local data = {
        openId = UserData.GetDeviceId(),
        platformType = PlatformType.NONE
    }
    this.VisitorLoginToServer(data)
end

--手机登录
function LoginPanel.OnPhoneBtnClick()
    AppGlobal.isTest = false
    PanelManager.Open(PanelConfig.PhoneLogin)
    -- local data = {
    --     platformType = PlatformType.WECHAT,
    --     openId = "HGQ123456",
    --     nickName = "hgq",
    --     headImgUrl = "0",
    --     sex = 1,
    -- }
    -- this.AutoLogin(data)
end

--================================================================
--检查是否需要自动登录
function LoginPanel.CheckAutoLogin()
    if AppConfig.IsAutoLogin then
        local data = GetLocal(LocalDatas.UserInfoData)--检查是否存储玩家信息
        if not string.IsNullOrEmpty(data) then
            local userInfo = JsonToObj(data)
            if userInfo ~= nil then
                if userInfo.platformType ~= PlatformType.NONE then
                    this.AutoLogin(userInfo)--有账号直接登录
                end
            end
        end
    end
end

--================================================================
--测试登录处理
function LoginPanel.LoginToServer(data)
    Log(">> LoginPanel.LoginToServer > ", data)
    this.loginType = LoginType.Test
    this.StartLogin(data)
end

--游客登录处理
function LoginPanel.VisitorLoginToServer(data)
    Log(">> LoginPanel.VisitorLoginToServer > ", data)
    if AppGlobal.isTest then
        this.loginType = LoginType.Test
    else
        this.loginType = LoginType.Release
    end
    this.StartLogin(data)
end

--自动登录处理
function LoginPanel.AutoLogin(data)
    Log(">> LoginPanel.AutoLogin > ", data)
    this.loginType = LoginType.Release
    this.StartLogin(data)
end

--授权登录处理
function LoginPanel.OnAuthLogin(data)
    Log(">> LoginPanel.OnAuthLogin > ", data)
    if AppGlobal.isTest then
        this.loginType = LoginType.Test
    else
        this.loginType = LoginType.Release
    end
    this.StartLogin(data)
end

--================================================================
--开始登录，验证数据的正确性，登录唯一入口方法
function LoginPanel.StartLogin(data)
    --提示
    local platformName = ""
    if data.platformType == PlatformType.WECHAT then
        platformName = "微信"
    elseif data.platformType == PlatformType.PHONE then
        platformName = "手机号"
    end

    --启动提示
    Waiting.Show(platformName .. "登录中...")
    this.tempLoginData = data

    this.StartLoginTimer()

    GlobalData.platform.accountType = data.platformType

    GlobalData.platform.phoneNum = data.phone or ""
    GlobalData.platform.password = data.password or ""
    --OpenId
    GlobalData.platform.openId = data.openId or ""
    --UUID，没有UUID使用openId
    if string.IsNullOrEmpty(data.unionId) then
        GlobalData.platform.unionId = GlobalData.platform.openId
    else
        GlobalData.platform.unionId = data.unionId
    end

    if data.platformType == PlatformType.NONE then
        GlobalData.platform.nickName = LoginUtil.CreateNameByDevice()
    else
        GlobalData.platform.nickName = string.Trim(data.nickName) or ""
    end
    --头像
    GlobalData.platform.headUrl = data.headImgUrl or "0"
    --微信登录需要更新头像
    if GlobalData.platform.accountType == PlatformType.WECHAT then
        GlobalData.platform.isUpdateHead = 1
    else
        GlobalData.platform.isUpdateHead = 0
    end
    --性别
    GlobalData.platform.gender = data.sex or 2

    --设备类型
    GlobalData.platform.deviceType = Global.GetDeviceType()
    --设备ID
    if IsNull(data.deviceId) then
        GlobalData.platform.deviceId = SystemInfo.deviceUniqueIdentifier
    else
        GlobalData.platform.deviceId = data.deviceId
    end

    --设置服务器链接并发送登录请求
    this.SetServerAndLogin()
end

--检查头像与本地头像是否相同
function LoginPanel.CheckIsSameHeadUrl(headUrl, openId)
    local isUpdateHeadUrl = 0
    local headUrl = Functions.CheckPlayerHeadUrl(headUrl)
    local key = LocalDatas.HeadInfoUrl .. openId
    local localHeadUrl = GetLocal(key)

    if headUrl == "0" and not string.IsNullOrEmpty(localHeadUrl) then
        SetLocal(key, "")
        return 1
    end

    if headUrl ~= localHeadUrl then
        isUpdateHeadUrl = 1
        --保存头像链接
        SetLocal(key, headUrl)
    end
    return isUpdateHeadUrl
end

--================================================================
function LoginPanel.SetTestServerByIndex(index)
    local length = #AppConfig.TestServerList
    if this.testServerIndex > length or this.testServerIndex < 1 then
        this.testServerIndex = 1
    end
    local serverData = AppConfig.TestServerList[this.testServerIndex]
    if serverData ~= nil then
        this.serverListBtnTxt.text = serverData.name
    else
        this.serverListBtnTxt.text = ""
    end
end

--================================================================
--检测登录的Timer
function LoginPanel.StartLoginTimer()
    if this.loginTimer == nil then
        this.loginTimer = Timing.New(this.OnLoginTimer, 0.1)
        this.loginTimer:Start()
        this.tipsTime = Time.realtimeSinceStartup
    end
end

function LoginPanel.StopLoginTimer()
    if this.loginTimer ~= nil then
        this.loginTimer:Stop()
        this.loginTimer = nil
    end
end

function LoginPanel.OnLoginTimer()
    this.CheckEnterLobbyOrRoom()
end

--================================================================
--
--登录返回
function LoginPanel.OnGameLogin()
    Log(">> LoginPanel > ======== > OnGameLogin")
    this.isGameLogin = true
    --检查邀请码  --如果玩家没有房间号，邀请加入房间码房间号条件满足，将设置为UserData.roomId
    AppPlatformHelper.CheckInviteCode()
    --更换提示，没有房间号，进入大厅前
    if UserData.GetRoomId() > 0 then
        Waiting.Show("进入房间中...")
    end
    this.SaveLoginData()
    this.CheckEnterLobbyOrRoom()
    --检测回放战绩链接
    this.CheckPlayDataUrl(GlobalData.ServerConfigData)
end

--存储玩家信息，登录成功才保存
function LoginPanel.SaveLoginData()
    if this.tempLoginData ~= nil and GlobalData.platform.accountType ~= PlatformType.NONE then
        local str = ObjToJson(this.tempLoginData)
        --成功，存储数据，进行登录
        SetLocal(LocalDatas.UserInfoData, str)
    end
end

function LoginPanel.CheckPlayDataUrl(serverData)
    Log("LoginPanel > CheckPlayDataUrl > serverData = ", serverData)
    --如果当前服务器连接的回放不是正式的，那么拉取回放数据链接为本地内网服务器
    GlobalData.playbackDownUrl = serverData.PlaybackDataUrl
end

--检测进入大厅或者房间
function LoginPanel.CheckEnterLobbyOrRoom()
    --游戏登录成功、资源加载完成、时间足够，共同达到才能进游戏
    if this.isGameLogin and BaseResourcesMgr.inited then
        local temp = Time.realtimeSinceStartup - this.tipsTime
        --登录时间一定要达到指定值，用于节奏控制
        if temp > 0.4 then
            this.StopLoginTimer()
            local roomId = UserData.GetRoomId()
            this.isGameLogin = false
            if roomId > 0 then
                BaseTcpApi.CheckAndJoinRoom(roomId, true, true)
            else
                GameSceneManager.SwitchGameScene(GameSceneType.Lobby)
            end
        end
    end
end

--================================================================
--获取当前的IP
function LoginPanel.RequestIp()
    local GetCurrIp = function()
        Log(">> LoginPanel.RequestIp > ======== Start.")
        local www = WWW("http://whatismyip.akamai.com")
        coroutine.www(www)
        if www.error == nil and www.text and www.text ~= "" then
            UserData.SetIP(www.text)
            Log(">> LoginCtrl > RequestIp > IP = " .. UserData.GetIP())
        else
            Log(">> LoginCtrl > RequestIp > 获取异常 > " .. tostring(www.error) .. " , " .. tostring(www.text))
        end
    end
    coroutine.start(GetCurrIp)
end