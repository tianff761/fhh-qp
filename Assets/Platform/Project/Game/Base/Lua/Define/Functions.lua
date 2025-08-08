Functions = {}


--获取游戏名称
function Functions.GetGameName(gameType)
    local config = GameConfig[gameType]
    if config ~= nil then
        return config.Name
    end
    return nil
end

--获取游戏名称文本
function Functions.GetGameNameText(gameType)
    local config = GameConfig[gameType]
    if config ~= nil then
        return config.Text
    end
    return ""
end

--获取游戏资源版本号数值
function Functions.GetResVersion(gameType)
    local temp = VersionManager.Instance:GetGameLocalVersionNum(Functions.GetGameName(gameType))
    if temp < 1 then
        return 10001
    else
        return temp
    end
end

--获取游戏资源版本号字符串
function Functions.GetResVersionStr(gameType)
    return Functions.GetResVersionStrByName(Functions.GetGameName(gameType))
end

--获取游戏资源版本号字符串
function Functions.GetResVersionStrByName(gameName)
    local temp = VersionManager.Instance:GetGameLocalVersionStr(gameName)
    if string.IsNullOrEmpty(temp) then
        return "1.0.1"
    else
        return temp
    end
end

--检测游戏是否需要更新
function Functions.CheckGameNeedUpgrade(gameType)
    return VersionManager.Instance:CheckGameNeedUpgrade(Functions.GetGameName(gameType))
end

--检测游戏是否需要更新
function Functions.CheckGameNeedUpgradeByName(name)
    return VersionManager.Instance:CheckGameNeedUpgrade(name)
end

--是否是老版本
function Functions.IsOldVerApp()
    local appVerNum = AppConst.AppVerNum

    if IsEditorOrPcPlatform() then
        return false
    end

    if appVerNum < 80000 then
        --外网版本
        if appVerNum <= 10001 then
            return true
        end
    elseif appVerNum < 90000 then
        --内网开发版本
        if appVerNum <= 80001 then
            return true
        end
    else
        --内网Trunk版本
        if appVerNum <= 90016 then
            return true
        end
    end
    return false
end

--获取游戏资源版本号字符串
function Functions.RequirePanelsScript(panelConfigs)
    local panelConfig = nil
    for i = 1, #panelConfigs do
        panelConfig = panelConfigs[i]
        require(panelConfig.path .. panelConfig.assetName)
    end
end

--检测玩家的名称
function Functions.CheckPlayerName(name)
    if name == nil or name == "" then
        return "玩家"
    end
    return name
end

--检测玩家的头像
function Functions.CheckPlayerHeadUrlById(headUrl)
    headUrl = tonumber(headUrl)
    if not IsNumber(headUrl) then
        headUrl = 0
    end
    if headUrl < 0 or headUrl > 1000 then
        headUrl = 0
    end
    return headUrl
end

--是否是http的链接
function Functions.IsHttpUrl(url)
    if string.IsNullOrEmpty(url) then
        return false
    end
    local x = string.find(url, "http")
    if x ~= nil then
        return true
    end
    return false
end

--检测玩家的头像
function Functions.CheckPlayerHeadUrl(headUrl)
    if string.IsNullOrEmpty(headUrl) then
        return "0"
    end
    -- local x = string.find(headUrl, "http")
    -- if x ~= nil then
    --     return headUrl
    -- end
    return headUrl--AppConfig.headDownUrl .. headUrl .. ".jpg"
end

--是否是有效的头像
function Functions.IsValidHeadUrl(headUrl)
    if headUrl == nil or headUrl == "" or headUrl == "0" then
        Log(">> ====================================== > ", headUrl)
        return false
    end
    return true
end

--检测玩家的头像框
function Functions.CheckPlayerHeadFrame(headFrame)
    if headFrame == nil or headFrame == "" then
        return 0
    end
    return tonumber(headFrame)
end

--拼接服务器发送来的头像
function Functions.CheckJoinPlayerHeadUrl(head)
    return head
end

--检测玩家的性别
function Functions.CheckPlayerGender(genderType)
    if genderType == Global.GenderType.Male then
        return genderType
    else
        return Global.GenderType.Female
    end
end

--检测房间类型
function Functions.CheckRoomType(roomType)
    if roomType == nil or not IsNumber(roomType) then
        return RoomType.Lobby
    else
        return roomType
    end
end

--检测货币类型
function Functions.CheckMoneyType(moneyType)
    if moneyType == nil or not IsNumber(moneyType) then
        return MoneyType.Fangka
    else
        return moneyType
    end
end

--检测获取网络等级，1表示网络良好，2表示网络一般，3表示网络差
function Functions.CheckNetLevel(value)
    local level = NetLevel.Good
    if value < 100 then
        level = NetLevel.Good
    elseif value < 300 then
        level = NetLevel.General
    else
        level = NetLevel.Bad
    end
    return level
end

--检测获取网络等级，1表示网络良好，2表示网络一般，3表示网络差，极差
function Functions.CheckNetLevel4(value)
    local level = NetLevel.Good
    if value < 80 then
        level = NetLevel.Good
    elseif value < 160 then
        level = NetLevel.General
    elseif value < 240 then
        level = NetLevel.Bad
    else
        level = NetLevel.Low
    end
    return level
end

--检测获取电量等级，1表示没有获取到电量，2表示低电量，3表示正常
function Functions.CheckEnergyLevel(value)
    local level = EnergyLevel.None
    if value < 1 then
        level = EnergyLevel.None
    elseif value < 20 then
        level = EnergyLevel.Low
    else
        level = EnergyLevel.Normal
    end
    return level
end

----------------------------测试新添-----
--复制指定文字到剪贴板
function Functions.CopyToClipBoard(str)
    PlatformHelper.CopyText(str)
end

-------------------------------------------------------------------
--
--设置头像，不传后2个参数，会直接对图片进行处理，固定设置可以不传递后2个参数
--动态设置头像需要完整的传递参数，比如滑动中的玩家列表中的头像设置
--如果头像图片不在内存中，则加载后会调用callback，然后自行处理
--注意：如果两个地方同时调用此方法，并且调用的headUrl相同，这里的callback一定要自己传入，否则只会设置上先调用此方法的image
function Functions.SetHeadImage(image, headUrl, callback, arg)
    if IsNull(image) then
        Log(">> Functions.SetHeadImage > image == nil.")
        return
    end
    --Log(">> 设置头像 > ", headUrl)

    local isUrl = Functions.IsHttpUrl(headUrl)
    if isUrl then
        if string.find(headUrl, ".jpg") ~= nil then
            Functions.SetNetImage(image, headUrl, callback, arg)
        else
            headUrl = string.sub(headUrl, 1, string.len(headUrl) - 3)
            headUrl = headUrl .. "64"
            Functions.SetNetImage(image, headUrl, callback, arg)
        end
        return
    end

    local tempHeadUrl = tonumber(headUrl)
    if not IsNumber(tempHeadUrl) then
        Functions.SetHeadImageById(image, headUrl)
    else
        if tempHeadUrl <= 100000 then
            Functions.SetHeadImageById(image, headUrl)
        else
            headUrl = Functions.CheckPlayerHeadUrl(headUrl)
            Functions.SetNetImage(image, headUrl, callback, arg)
        end
    end
end

--设置网络图片
function Functions.SetNetImage(image, headUrl, callback, arg)
    if headUrl ~= "0" then
        local isSuccess = netImageMgr:SetImage(image, headUrl)
        if not isSuccess then
            local tempCallback = callback
            if tempCallback == nil then
                tempCallback = Functions.OnPlayerImageLoadCompleted
            end
            local tempArg = arg
            if tempArg == nil then
                tempArg = { image = image, headUrl = headUrl }
            else
                tempArg.image = image
                tempArg.headUrl = headUrl
            end
            netImageMgr:Load(headUrl, tempCallback, tempArg)
        end
    else
        image.sprite = BaseResourcesMgr.headNoneSprite
    end
end

--设置头像
function Functions.SetHeadImageById(image, headId)
    if IsNull(image) then
        Log(">> Functions.SetHeadImage > image == nil.")
        return
    end
    headId = Functions.CheckPlayerHeadUrlById(headId)
    if headId ~= nil then
        local sp = ResourcesManager.LoadSpriteBySynch("base/common", tostring(headId))
        if sp ~= nil then
            image.sprite = sp
        else
            image.sprite = BaseResourcesMgr.headNoneSprite
        end
    else
        image.sprite = BaseResourcesMgr.headNoneSprite
    end
    -- image:SetNativeSize()
end

--加载头像图片回调
function Functions.OnPlayerImageLoadCompleted(arg)
    if arg ~= nil and not IsNull(arg.image) and arg.headUrl ~= nil then
        Log(">> Functions.OnPlayerImageLoadCompleted > arg.headUrl = ", tostring(arg.headUrl))
        local isSuccess = netImageMgr:SetImage(arg.image, arg.headUrl)
        --arg.image.sprite.texture.filterMode = UnityEngine.FilterMode.Bilinear
        --arg.image.sprite.texture.Compress(true)
        if not isSuccess then
            arg.image.sprite = BaseResourcesMgr.headNoneSprite
        end
    end
end

--滚动式加载
function Functions.OnCompleteDownHeadUrlOnScroll(arg)
    if arg == nil or arg.item == nil then
        return
    end
    local name = arg.item.name
    if name == tostring(arg.index) then
        if arg ~= nil and not IsNull(arg.image) and arg.headUrl ~= nil then
            local isSuccess = netImageMgr:SetImage(arg.image, arg.headUrl)
            if not isSuccess then
                arg.image.sprite = BaseResourcesMgr.headNoneSprite
            end
        end
    end
end

--设置图片
function Functions.SetImage(image, headUrl, callback, arg)
    if IsNull(image) then
        Log(">> Functions.SetHeadImage > image == nil.")
        return
    end

    if headUrl ~= nil and headUrl ~= "" then
        local isSuccess = netImageMgr:SetImage(image, headUrl)
        if isSuccess and callback ~= nil then
            callback()
        else
            local tempCallback = callback
            if tempCallback == nil then
                tempCallback = Functions.OnPlayerImageLoadCompleted
            end
            local tempArg = arg
            if tempArg == nil then
                tempArg = { image = image, headUrl = headUrl }
            else
                tempArg.image = image
                tempArg.headUrl = headUrl
            end
            netImageMgr:Load(headUrl, tempCallback, tempArg)
        end
    end
end

--设置头像框，id为数字型
function Functions.SetHeadFrame(image, frameId)
    -- if IsNull(image) then
    --     return
    -- end
    -- local id = tonumber(frameId)
    -- if id == nil then
    --     id = 0
    -- end
    -- local sprite = ResourcesManager.LoadSpriteBySynch("base/head", "HeadFrame" .. id)
    -- if not IsNil(sprite) then
    --     image.sprite = sprite
    -- end
end
-------------------------------------------------------------------
--
--获取年
function Functions.GetYear()
    return os.date("%Y", os.time())
end

--获取未来24小时
function Functions.GetNext24Hour()
    local hours = {}
    local curHour = os.date("%H", os.time())
    for i = curHour, 24 do
        table.insert(hours, i)
    end

    for i = 1, curHour - 1 do
        table.insert(hours, i)
    end
    return hours
end

--获取未来count天日期
function Functions.GetNextDate(count)
    local days = {}
    local ONE_DAY = 60 * 60 * 24
    for i = 1, count do
        table.insert(days, { os.date("%m", os.time() + ONE_DAY * i), os.date("%d", os.time() + ONE_DAY * i) })
    end
    return days
end

--================================================================
--通过规则对象解析游戏规则数据
function Functions.ParseGameRule(gameType, ruleObj, gps, separator, bdPer, faceType)
    if string.IsNullOrEmpty(separator) then
        separator = " "
    end
    if gameType == GameType.Mahjong then
        return Mahjong.ParseMahjongRule(ruleObj, gps, separator, bdPer)
    elseif gameType == GameType.PaoDeKuai then
        return PdkConfig.ParsePdkRule(ruleObj, separator, bdPer)
    elseif gameType == GameType.ErQiShi then
        return EqsConfig.ParseEqsRule(ruleObj, gps, separator, bdPer)
    elseif gameType == GameType.Pin5 then
        return Pin5Config.ParsePin5Rule(ruleObj, gps, separator, bdPer)
    elseif gameType == GameType.Pin3 then
        return Pin3Config.ParsePin3Rule(ruleObj, gps, separator, bdPer)
    elseif gameType == GameType.SDB then
        return SDB.ParseSDBRule(ruleObj, gps, separator, bdPer)
    elseif gameType == GameType.LYC then
        return LYCConfig.ParseLYCRule(ruleObj, gps, separator, bdPer, faceType)
    elseif gameType == GameType.TP then
        return TpConfig.ParseTpRule(ruleObj, gps, separator, bdPer)
    else
        return { playWayName = "", juShu = 0, juShuTxt = "", rule = "", baseScore = 0 }
    end
end

--计算游戏准入 gameId:游戏ID baseScore:底分
function Functions.CalculateInGold(gameId, baseScore)
    if not IsNumber(baseScore) then
        baseScore = 0
    end
    local inGold = 0
    inGold = baseScore * 1000
    return inGold
end

--组装联盟、俱乐部创建房间规则参数 gameId:游戏ID   rules:各个游戏规则   playType:玩法   maxRoundCount:最大局数 
--                              maxPlayerCount:最大人数   configId:钻石配置   payType:支付方式    baseScore:底分   inGold:准入
--                              feetype 1表示 区间收费 2 表示百分比类型, bigwin  1 表示大赢家 0 表示所有赢家, per 表情比例 0-100
function Functions.PackGameRule(gameId, rules, playType, maxRoundCount, maxPlayerCount, configId, payType, baseScore, inGold, jieSanFenShu, note, wins, consts, baoDi, feetype, bigwin, per, bdPer, faceType)
    local data = {
        gameId = gameId,
        rules = rules,
        playType = playType,
        maxRoundCount = maxRoundCount,
        maxPlayerCount = maxPlayerCount,
        configId = configId,
        payType = payType,
        baseScore = baseScore,
        inGold = inGold,
        jieSanFenShu = jieSanFenShu,
        note = note,
        wins = wins,
        consts = consts,
        baoDi = baoDi,
        feetype = feetype,
        bigwin = bigwin,
        per = per,
        bdPer = bdPer,
        faceType = faceType,
    }
    return data
end


--================================================================
--使用经纬度计算距离 返回单位米 lat1纬度1   lng1经度1     lat2纬度2    lng2经度2 
function Functions.GetDisance(lat1, lng1, lat2, lng2)
    if IsNumber(lat1) and IsNumber(lng1) and IsNumber(lat2) and IsNumber(lng2) then
        if (lat1 == 0 and lng1 == 0) or (lat2 == 0 and lng2 == 0) then
            return -1
        end
        -- 经典计算方式
        if math.abs(lat1) > 90 or math.abs(lat2) > 90 then
            return -1
        end
        if ((math.abs(lng1) > 180) or (math.abs(lng2) > 180)) then
            return -1
        end

        local radLat1 = Functions.rad(lat1);
        local radLat2 = Functions.rad(lat2);
        local a = radLat1 - radLat2;
        local b = Functions.rad(lng1) - Functions.rad(lng2);
        local s = 2 * math.asin(math.sqrt(math.pow(math.sin(a / 2), 2) + math.cos(radLat1) * math.cos(radLat2) * math.pow(math.sin(b / 2), 2)));
        s = s * 6378.137;
        -- EARTH_RADIUS; 单位Km
        s = math.floor(s * 10000 + 0.5) / 10000
        -- 整理显示方式
        local result = s * 1000
        return result
    end
    return -1
end

--检测Gps距离
function Functions.CheckGpsDisance(distance)
    if distance < 300 then
        return distance / 5
    elseif distance < 600 then
        return distance / 4
    else
        return distance
    end
end

function Functions.rad(d)
    return d * math.pi / 180;
end

--propType:PropType定义  
function Functions.SetPropIcon(tran, propType, isSetNativeSize)
    if propType ~= nil and tran ~= nil then
        local img = tran:GetComponent("Image")
        if img ~= nil then
            img.sprite = ResourcesManager.LoadSpriteBySynch("base/props", tostring(propType))
            if isSetNativeSize then
                img:SetNativeSize()
            end
        end
    end
end

--下载回放数据
function Functions.DownloadPlaybackData(url, callBack)
    coroutine.start(function()
        local www = WWW(url)
        coroutine.www(www)
        if www.error == nil and www.text and www.text ~= "" then
            if callBack ~= nil then
                callBack(0, www.text)
            end
        else
            if callBack ~= nil then
                callBack(2)
            end
        end
    end)
end


--聊天框文本最小宽度
local ChatTextMinWidth = 80
--聊天框文本最小高度
local ChatTextMinHeight = 28
--设置聊天文本气泡显示
function Functions.SetChatText(chatFrameGO, text, str)
    text.text = str

    -- 文字泡大小适配
    local rectTransform = chatFrameGO:GetComponent("RectTransform")
    local textRectTransform = text.gameObject:GetComponent("RectTransform")

    local txtWidth = text.preferredWidth

    if txtWidth > textRectTransform.sizeDelta.x then
        txtWidth = textRectTransform.sizeDelta.x
    end

    if txtWidth < ChatTextMinWidth then
        txtWidth = ChatTextMinWidth
    end

    local txtFrameWidth = txtWidth + 40
    local txtFrameHeight = text.preferredHeight + 40

    if txtFrameHeight < ChatTextMinHeight then
        txtFrameHeight = ChatTextMinHeight
    end

    rectTransform.sizeDelta = Vector2.New(txtFrameWidth, txtFrameHeight)

    UIUtil.SetActive(chatFrameGO, true)
end

--================================================================
--设置背景适配，用于Lua临时处理
function Functions.SetBackgroundAdaptation(image)
    if image == nil or image.mainTexture == nil then
        return
    end

    local rectTransform = image:GetComponent("RectTransform")
    rectTransform.sizeDelta = Functions.CalculateAdaptation(image.mainTexture.width, image.mainTexture.height)
end

--计算背景适配
function Functions.CalculateAdaptation(width, height)
    local screenWidth = ScenemMgr.width
    local screenHeight = ScenemMgr.height
    if screenWidth < screenHeight then
        screenWidth = ScenemMgr.height
        screenHeight = ScenemMgr.width
    end

    local referenceResolution = AppConst.ReferenceResolution

    local widthScale = screenWidth / referenceResolution.x
    local heightScale = screenHeight / referenceResolution.y

    local tWidth = referenceResolution.x
    local tHeight = referenceResolution.y

    --UI整体缩放比例
    local scale = 1
    if widthScale < heightScale then
        scale = widthScale
    else
        scale = heightScale
    end

    --计算出Canvas的大小
    tWidth = screenWidth / scale
    tHeight = screenHeight / scale

    --计算图片缩放比例
    local tempWidthScale = width / tWidth
    local tempHeightScale = height / tHeight
    if tempWidthScale < tempHeightScale then
        scale = tempWidthScale
    else
        scale = tempHeightScale
    end
    tWidth = math.ceil(width / scale)
    tHeight = math.ceil(height / scale)

    return Vector2.New(tWidth, tHeight)
end


--获取适配缩放
function Functions.GetAdaptationScale(width, height, referenceX, referenceY)
    if referenceX == nil then
        local referenceResolution = AppConst.ReferenceResolution
        referenceX = referenceResolution.x
        referenceY = referenceResolution.y
    end

    local screenWidth = ScenemMgr.width
    local screenHeight = ScenemMgr.height
    if screenWidth < screenHeight then
        screenWidth = ScenemMgr.height
        screenHeight = ScenemMgr.width
    end

    local widthScale = screenWidth / referenceX
    local heightScale = screenHeight / referenceY

    local tWidth = referenceX
    local tHeight = referenceY

    --UI整体缩放比例
    local scale = 1
    if widthScale < heightScale then
        scale = widthScale
    else
        scale = heightScale
    end

    --计算出Canvas的大小
    tWidth = screenWidth / scale
    tHeight = screenHeight / scale

    --计算图片缩放比例
    local tempWidthScale = width / tWidth
    local tempHeightScale = height / tHeight
    if tempWidthScale < tempHeightScale then
        scale = tempWidthScale
    else
        scale = tempHeightScale
    end
    return 1 / scale
end

--================================================================
--检测本地资源
function Functions.CheckLocalResources()
    --检测本地资源
    local now = os.time()
    local time = GetLocal(LocalDatas.CheckLocalResTime, 0)
    if time == 0 then
        SetLocal(LocalDatas.CheckLocalResTime, now)
    else
        --7天处理一次
        local interval = 7 * 24 * 3600
        if (now - time) > interval then
            SetLocal(LocalDatas.CheckLocalResTime, now)
            netImageMgr:CheckLocal(interval * 1000)
        end
    end
end

--===============================================================
--下载超时时间
local downTimeOut = 20
--回调
local playbackCallback = nil
--重试次数
local retryCount = 0
--最大重试次数
local maxRetryDownCount = 3
--检查本地是否缓存有回放
function Functions.CheckLocalPlaybackData(name, url, callback)
    retryCount = 0
    playbackCallback = callback
    PlaybackDataMgr:CheckLocal(name, function(code, str)
        if code == 0 then
            callback(code, str)
        else
            Functions.DownPlaybackByUrl(name, url)
        end
    end)
end

function Functions.DownPlaybackByUrl(name, url)
    local httpDown = HttpRequest.New(url)
    httpDown:SetTimeout(downTimeOut)
    httpDown:AddListener(function(data) Functions.CheckLocalPlayDataCallback(name, data) end)
    httpDown:Connect()
end

function Functions.CheckLocalPlayDataCallback(name, data)
    if data.code == 0 then
        if playbackCallback ~= nil then
            playbackCallback(data.code, data.text)
        end
        --写入本地文件
        PlaybackDataMgr:WritePlaybackData(name, data.text)
    else
        --重试
        retryCount = retryCount + 1
        if retryCount < maxRetryDownCount then
            Functions.DownPlaybackByUrl(name, data.url)
        else
            if playbackCallback ~= nil then
                playbackCallback(data.code, data.text)
            end
        end
    end
end

--三目运算函数
function Functions.TernaryOperator(bool, trueReturn, falseReturn)
    if IsBool(bool) then
        if bool == true then
            return trueReturn
        else
            return falseReturn
        end
    end
    return nil
end

--判断传入是否是ip地址
function Functions.CheckStringIsIp(str)
    local tab = string.split(str, ".")
    if #tab == 4 then
        return true
    end
    return false
end

--跳转到gps设置界面
function Functions.GoToGPSInfo()
    if Functions.IsOldVerApp() then
        AppPlatformHelper.OpenDeviceSetting()
    else
        if IsAndroidPlatform() then
            AppPlatformHelper.CheckAndroidIsOpenDeviceGPS(function(phoneIsEnable)
                if phoneIsEnable then
                    AppPlatformHelper.CheckAndroidIsOpenAppGPS(function(appIsEnable)
                        if appIsEnable then
                            AppPlatformHelper.OpenDeviceSetting()
                        else
                            AppPlatformHelper.OpenAppDetail()
                        end
                    end)
                else
                    AppPlatformHelper.OpenDeviceSetting()
                end
            end)
        else
            AppPlatformHelper.OpenDeviceSetting()
        end
    end
end

--获取截屏大小
function Functions.GetScreenshotSize(width, height)
    local screenWidth = UnityEngine.Screen.width
    local screenHeight = UnityEngine.Screen.height

    local uiCanvasSize = UIConst.uiCanvasTrans.sizeDelta
    local scale = screenWidth / uiCanvasSize.x

    local actualWidth = math.ceil(width * scale)
    local actualHeight = math.ceil(height * scale)

    actualWidth = math.min(actualWidth, screenWidth)
    actualHeight = math.min(actualHeight, screenHeight)

    local x = (screenWidth - actualWidth) / 2
    local y = (screenHeight - actualHeight) / 2

    local result = { x = x, y = y, width = actualWidth, height = actualHeight }
    Log(">> Functions.GetScreenshotSize ============= ", result)
    return result
end


--是否设置头像
function Functions.IsSetHeadImage(image)
    if IsNull(image) then
        return true
    else
        if image.sprite == nil or image.sprite == BaseResourcesMgr.headNoneSprite then
            return false
        else
            return true
        end
    end
end

--手机号格式
function Functions.CheckPhoneNum(num)
    return string.match(num, "[1][3-9]%d%d%d%d%d%d%d%d%d") == num
end

--验证码格式
function Functions.CheckVerificationCode(code)
    if #code == 6 then
        return string.match(code, "%d+") == code
    end
    return false
end

--密码格式
function Functions.CheckPassword(password)
    if #password >= 6 and #password <= 9 then
        return string.match(password, "%w+") == password
    end
    return false
end

--通过牌id转换牌id
function Functions.GetCardById(gameType, cardId)
    if gameType == GameType.PaoDeKuai then
        return math.floor(cardId / 10) * 100 + (cardId % 10)
    end
    return -1
end

function Functions.SetRoomPrivate(isPrivate)
    GlobalData.isOpenCurRoomPrivate = isPrivate
end

--获取玩家ID，有隐私判断
function Functions.GetUserIdString(userId)
    if GlobalData.isOpenCurRoomPrivate then
        return Functions.GetPrivacyUid(userId)
    else
        return tostring(userId)
    end
end

function Functions.GetPrivacyUid(userId)
    local str = tostring(userId)
    local len = string.len(str)
    local head = string.sub(str, 1, 1)
    local tail = string.sub(str, len, len)
    return tostring(head) .. "******" .. tostring(tail)
end

function Functions.ShowHeadIconTips(callback)
    --if UserData.GetHeadUrl() == "0" then
    --Alert.Prompt("当前头像为默认头像，建议修改头像后再试？", function()
    --    PanelManager.Open(PanelConfig.ModifyHeadIcon)
    --end, callback)
    --else
    if callback ~= nil then
        callback()
    end
    --end
end

--检测页签总数
function Functions.CheckPageTotal(pageTotal)
    if pageTotal < 1 then
        return 1
    end
    return pageTotal
end

--获取格式化字符串
local format = string.format
function Functions.GetS(key, ...)
    if not key then
        return
    end
    --使用pcall进行调用，方便错误打印
    local flag, msg = pcall(format, key, ...)
    if not flag then
        LogError("语言ID: 语言所需参数与实际参数不符")
        return key
    end
    return msg
end

---还原上次的显示，用于修改房间界面
function Functions.RevertLastDisplay(ruleGroup, rules)
    for i = 1, #ruleGroup do
        for j = 1, #ruleGroup[i].rules do
            ruleGroup[i].rules[j].selected = false
        end
    end
    for i = 1, #ruleGroup do
        for j = 1, #ruleGroup[i].rules do
            for k, v in pairs(rules) do
                if ruleGroup[i].rules[j].data and ruleGroup[i].rules[j].data.type == k and ruleGroup[i].rules[j].data.value == v and ruleGroup[i].rules[j].selected == false then
                    ruleGroup[i].rules[j].selected = true
                end
            end
        end
    end
end

---通过时间戳获取日期
function Functions.GetTimesByTimeStamp(timeStamp)
    return os.date("%Y-%m-%d %H:%M:%S", timeStamp / 1000)
end

function Functions.GetDateByTimeStamp(timeStamp)
    return os.date("%Y-%m-%d", timeStamp / 1000)
end

