--房间辅助功能
RoomUtil = {
    --检测的计时器
    checkTimer = nil,
    --检测间隔
    checkInterval = 20,
    --上一次检测时间
    lastCheckTime = 0,
    --玩家参数
    players = nil,
    ----------------------------------
    --Gps是否开启
    gpsEnabled = false,
    --Gps检测时间，毫秒
    gpsCheckTimems = 0,
    --Gps检测回调
    gpsCheckCallback = nil,
}

local this = RoomUtil
--临时变量
local tempDiffTime = 0

--数组格式
--args = {
--  [1] = {seatIndex = 0, id = 0, image = nil, headUrl = nil}
--}
--启动检测玩家头像图片
function RoomUtil.StartCheckPlayerHeadImage(args)
    this.players = args
    this.StartCheckTimer()
end

--停止检测玩家头像图片
function RoomUtil.StopCheckPlayerHeadImage()
    this.players = nil
    this.StopCheckTimer()
end

--启动检测
function RoomUtil.StartCheckTimer()
    --Log(">> ================ > RoomUtil.StartCheckTimer")
    if this.checkTimer == nil then
        this.checkTimer = Timing.New(this.OnCheckTimer, 5)
    end
    this.checkInterval = 20
    this.lastCheckTime = os.time()
    this.checkTimer:Restart()
end

--停止检测
function RoomUtil.StopCheckTimer()
    --Log(">> ================ > RoomUtil.StopCheckTimer")
    this.checkInterval = 20
    if this.checkTimer ~= nil then
        this.checkTimer:Stop()
        this.checkTimer = nil
    end
end

--处理检测
function RoomUtil.OnCheckTimer()
    tempDiffTime = os.time() - this.lastCheckTime
    if tempDiffTime > this.checkInterval then
        Log(">> ================ > RoomUtil.OnCheckTimer = ", this.checkInterval)
        this.lastCheckTime = os.time()
        this.checkInterval = this.checkInterval + 20
        if this.checkInterval > 120 then
            this.checkInterval = 120
        end
        this.CheckPlayerHeadImage()
    end
end

--检测玩家头像
function RoomUtil.CheckPlayerHeadImage()
    if this.players == nil then
        this.StopCheckTimer()
        return
    end

    --是否存在没有头像
    local isExistNoneImage = false
    local length = #this.players
    local player = nil
    for i = 1, length do
        player = this.players[i]
        if player ~= nil and Functions.IsValidHeadUrl(player.headUrl) then
            if not IsNull(player.image) and (player.image.sprite == nil or player.image.sprite == BaseResourcesMgr.headNoneSprite) then
                isExistNoneImage = true
                Functions.SetHeadImage(player.image,Functions.CheckJoinPlayerHeadUrl(player.headUrl), this.OnPlayerImageLoadCompleted, player)
            end
        end
    end

    if not isExistNoneImage then
        --有头像的都存在，则停止检测
        this.players = nil
        this.StopCheckTimer()
    end
end

--加载头像图片回调
function RoomUtil.OnPlayerImageLoadCompleted(arg)
    if arg == nil or arg.seatIndex == nil or this.players == nil then
        return
    end

    if this.GetPlayerIdBySeatIndex(arg.seatIndex) ~= arg.id then
        return
    end

    if not IsNull(arg.image) then
        Log(">> RoomUtil.OnPlayerImageLoadCompleted > arg.headUrl = ", tostring(arg.headUrl))
        netImageMgr:SetImage(arg.image, arg.headUrl)
    end
end

--通过座位索引号获取玩家ID
function RoomUtil.GetPlayerIdBySeatIndex(seatIndex)
    local player = nil
    local length = #this.players
    for i = 1, length do
        player = this.players[i]
        if player ~= nil and player.seatIndex == seatIndex then
            --座位号相同，id不同表示不是同一个人，就不处理了
            return player.id
        end
    end
    return nil
end

--================================================================
--
--检测Gps开启功能
function RoomUtil.CheckGpsEnabled(callback)
    if Functions.IsOldVerApp() then
        --1秒内不再进行检测
        if this.gpsEnabled and (os.timems() - this.gpsCheckTimems < 1200) then
            if callback ~= nil then
                callback()
            end
        else
            this.gpsCheckCallback = callback
            GpsHelper.Check(this.OnCheckAndGetGpsCompleted)
        end
    else
        if IsAndroidPlatform() then
            this.gpsCheckCallback = callback
            AppPlatformHelper.CheckAndroidIsOpenDeviceGPS(this.OnCheckAndroidIsOpenDeviceGPS)
        else
            this.gpsEnabled = Input.location.isEnabledByUser
            if callback ~= nil then
                callback()
            end
        end
    end
end

--检测设备Gps回调
function RoomUtil.OnCheckAndroidIsOpenDeviceGPS(isOpen)
    this.gpsEnabled = isOpen
    if isOpen then
        AppPlatformHelper.CheckAndroidIsOpenAppGPS(this.OnCheckAndroidIsOpenAppGPS)
    else
        this.CheckAndGetGpsCompleted()
    end
end

--检测应用的GPS回到
function RoomUtil.OnCheckAndroidIsOpenAppGPS(isOpen)
    this.gpsEnabled = isOpen
    this.CheckAndGetGpsCompleted()
end

--检测定位完成回调
function RoomUtil.CheckAndGetGpsCompleted()
    if this.gpsCheckCallback ~= nil then
        this.gpsCheckCallback()
        this.gpsCheckCallback = nil
    end
end

--检测定位
function RoomUtil.OnCheckAndGetGpsCompleted(lat, lng)
    if GpsHelper.LocationEnabled and lat ~= 0 and lng ~= 0 then
        this.gpsEnabled = true
    else
        this.gpsEnabled = false
    end

    this.gpsCheckTimems = os.timems()
    this.CheckAndGetGpsCompleted()
end