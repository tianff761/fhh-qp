GPSModule = {
    playerGpsData = {},
    --Gps是否开启
    gpsEnabled = nil,
    --Gps检测回调
    gpsCheckCallback = nil,
}
local this = GPSModule

--==============================================
GPSClass = {
    lat = 0,
    lng = 0,
    address = ""
}

local gpsMeta = { __index = GPSClass }
function GPSClass:New()
    local o = {}
    setmetatable(o, gpsMeta)
    return o
end

function GPSClass:SetData(lat, lng, address)
    self.lat = lat
    self.lng = lng
    self.address = address
end
--==============================================
--gpsModule启动timer
local gpsModuleStartTimer = nil
--上次检测gps信息
local lastCheckGpsTime = 0
--检测gps间隔
local checkGpsInterval = 0
--是否启动
local isStart = false
--请求间隔时间
local lastSendTime = 0
--最大间隔时间
local maxInterval = 60
--是否获取到gps信息
local gpsInfoIsOk = false

--检测
function GPSModule.Check()
    if not gpsInfoIsOk then
        checkGpsInterval = 0.9
        lastCheckGpsTime = 0
    end
    if not isStart then
        this.Start()
    end
end

--启动gpsModule
function GPSModule.Start()
    Log(" >> GPSModule > Start")
    checkGpsInterval = 0.9
    lastCheckGpsTime = 0
    lastSendTime = 0
    --先关闭，再重启
    this.Stop()

    gpsModuleStartTimer = Scheduler.scheduleGlobal(this.CheckGpsData, 1)
    isStart = true
    this.RequestGps()
end

function GPSModule.HandCheckGpsData()
    checkGpsInterval = 0.9
    lastCheckGpsTime = 0
    this.CheckGpsData()
end

--检测gps信息
function GPSModule.CheckGpsData()
    local curCheckTime = os.time()
    if curCheckTime - lastCheckGpsTime >= checkGpsInterval then
        lastCheckGpsTime = curCheckTime
        if curCheckTime - lastSendTime > 61 then
            lastSendTime = os.time()
            this.RequestGps()
        end
    end
end

function GPSModule.RequestGps()
    if IsAndroidPlatform() then
        PlatformHelper.GetOriginGpsInfo()
    else
        GpsHelper.Check(this.CheckGpsCallback)
    end
end

function GPSModule.CheckGpsCallback(lat, lng)
    lastSendTime = 0
    --LogError("<color=aqua> >> GPSModule > CheckGpsCallback > lat = </color>", lat, " lng = ", lng)
    if lat == 0 and lng == 0 then
        gpsInfoIsOk = false
        --获取失败
        checkGpsInterval = checkGpsInterval + 0.5
        if checkGpsInterval > maxInterval then
            checkGpsInterval = maxInterval
        end
        UserData.SetLocation(0, 0)
    else
        gpsInfoIsOk = true
        --获取成功判断是否需要获取地址
        --this.IsCheckAddress(lat, lng)
        --获取到gps值，设置上gps值
        UserData.SetLocation(lat, lng)
        --更新自己的gps数据
        this.UpdatePlayerGpsData(UserData.GetUserId(), lat, lng)
        SendEvent(CMD.Game.UpdateUserGpsData)
        checkGpsInterval = 1 * 60
    end

    this.OnCheckAndGetGpsCompleted(lat, lng)
end

--{"error":0,"lat":30.576002,"lng":104.102702,"address":"四川省成都市锦江区康达路","nation":"中国","province":"四川省","city":"成都市","district":"锦江区","town":"柳江街道","village":"Unknown","street":"康达路"}
function GPSModule.SetGpsData(info)
    local data = JsonToObj(info)
    if data.error == 0 then
        this.CheckGpsCallback(data.lat, data.lng)
        if data.address ~= nil then
            this.UpdatePlayerAddressData(UserData.GetUserId(), data.address)
            PlatformHelper.StopRequestLocation()
        end
    else
        this.CheckGpsCallback(0, 0)
        PlatformHelper.StopRequestLocation()
    end
end

--检查是否需要获取地址信息
-- function GPSModule.IsCheckAddress(lat, lng)
--     local location = UserData.GetLocation()
--     local localData = this.CheckLocalAddress()
--     -- Log(" >> GPSModule > IsCheckAddress > lat = ", lat, " lng = ", lng, " location = ", location)
--     -- Log(" >> GPSModule > IsCheckAddress > localData = ", localData)
--     if IsNil(localData) then
--         if string.IsNullOrEmpty(location.address) then
--             TencentCloudMap.CheckGPSInfo(lat, lng, this.CheckGPSAddress)
--         else
--             this.CheckGetDisance(lat, lng)
--         end
--     else
--         if localData.lat ~= 0 and localData.lng ~= 0 and not string.IsNullOrEmpty(localData.address) then
--             local dis = Functions.GetDisance(localData.lat, localData.lng, lat, lng)
--             if dis > 1000 then
--                 TencentCloudMap.CheckGPSInfo(lat, lng, this.CheckGPSAddress)
--             else
--                 UserData.SetLocationAddress(localData.address)
--                 this.UpdatePlayerAddressData(UserData.GetUserId(), localData.address)
--                 SendEvent(CMD.Game.UpdateUserAddress)
--             end
--         else
--             this.CheckGetDisance(lat, lng)
--         end
--     end
-- end
-- function GPSModule.CheckGetDisance(lat, lng)
--     local location = UserData.GetLocation()
--     local dis = Functions.GetDisance(location.lat, location.lng, lat, lng)
--     -- Log(" >> GPSModule > CheckGetDisance > dis = ", dis)
--     if dis > 1000 then
--         --TencentCloudMap.CheckGPSInfo(lat, lng, this.CheckGPSAddress)
--     end
-- end
--检测本地地址信息
function GPSModule.CheckLocalAddress()
    local str = GetLocal(LocalDatas.gpsInfo)
    -- Log(" >> GPSModule > CheckLocalAddress > str = ", str)
    if not string.IsNullOrEmpty(str) then
        local gpsData = JsonToObj(str)
        if IsTable(gpsData) then
            if gpsData.lat ~= nil and gpsData.lat ~= 0 and gpsData.lng ~= nil and gpsData.lng ~= 0 then
                return gpsData
            end
        end
    end
    return nil
end

-- function GPSModule.CheckGPSAddress(code, str)
--     Log(" >> GPSModule > CheckGPSAddress > code > str = ", code, str)
--     if code == 0 then
--         UserData.SetLocationAddress(str)
--         SetLocal(LocalDatas.gpsInfo, ObjToJson(UserData.GetLocation()))
--     end
--     this.UpdatePlayerAddressData(UserData.GetUserId(), str)
--     SendEvent(CMD.Game.UpdateUserAddress)
-- end
--关闭gpsModule
function GPSModule.Stop()
    isStart = false
    if gpsModuleStartTimer ~= nil then
        Scheduler.unscheduleGlobal(gpsModuleStartTimer)
    end
    gpsModuleStartTimer = nil
end

--======================================================================
--更新所有玩家数据
function GPSModule.UpdateAllPlayersData(players)
    if not IsTable(players) then
        return
    end

    for i, v in ipairs(players) do
        this.UpdatePlayerData(v.id, v.lat, v.lng, v.adr)
    end
end

--更新玩家数据
function GPSModule.UpdatePlayerData(playerId, lat, lng, address)
    if IsNil(playerId) or IsNil(lat) or IsNil(lng) or IsNil(address) then
        return
    end
    this.UpdatePlayerGpsData(playerId, lat, lng)
    -- this.UpdatePlayerAddressData(playerId, address)
end

--更新玩家GPS数据
function GPSModule.UpdatePlayerGpsData(playerId, lat, lng)
    if IsNil(playerId) or IsNil(lat) or IsNil(lng) or lat == 0 or lng == 0 then
        return
    end
    local gpsData = this.playerGpsData[playerId]
    if gpsData == nil then
        gpsData = GPSClass.New()
        this.playerGpsData[playerId] = gpsData
    end
    gpsData.lat = lat
    gpsData.lng = lng
end

--更新玩家地址数据
function GPSModule.UpdatePlayerAddressData(playerId, address)
    if IsNil(playerId) or string.IsNullOrEmpty(address) then
        return
    end
    local gpsData = this.playerGpsData[playerId]
    if gpsData == nil then
        gpsData = GPSClass.New()
        this.playerGpsData[playerId] = gpsData
    end
    gpsData.address = address
end

--获取一个玩家的gps信息
function GPSModule.GetGpsDataByPlayerId(playerId)
    local gpsData = this.playerGpsData[playerId]
    if gpsData == nil then
        gpsData = GPSClass.New()
        this.playerGpsData[playerId] = gpsData
    end
    return gpsData
end

--清理所有玩家gps数据
function GPSModule.ClearPlayersGpsData()
    this.playerGpsData = {}
end

--根据玩家id清理玩家数据
function GPSModule.ClearPlayerGpsDataByPlayerId(playerId)
    this.playerGpsData[playerId] = {}
end

--==================================================================
--检测Gps开启功能，每次都要检测
function GPSModule.CheckGpsEnabled(callback)
    --判断Gps数据缓存是否正确
    local location = UserData.GetLocation()
    -- if this.gpsEnabled and location.lat ~= 0 and location.lng ~= 0 then
    --     --直接回调
    --     if callback ~= nil then
    --         callback()
    --     end
    -- else
    --
    this.gpsCheckCallback = callback
    if Functions.IsOldVerApp() then
        this.HandCheckGpsData()
    else
        if IsAndroidPlatform() then
            AppPlatformHelper.CheckAndroidIsOpenDeviceGPS(this.OnCheckAndroidIsOpenDeviceGPS)
        else
            this.HandCheckGpsData()
        end
    end
    --end
end

--安卓端检测设备Gps回调
function GPSModule.OnCheckAndroidIsOpenDeviceGPS(isOpen)
    LogError("this.gpsEnabled", isOpen)
    this.gpsEnabled = isOpen
    if this.gpsEnabled then
        AppPlatformHelper.CheckAndroidIsOpenAppGPS(this.OnCheckAndroidIsOpenAppGPS)
    else
        this.CheckAndGetGpsCompleted()
    end
end

--安卓端检测应用的GPS回到
function GPSModule.OnCheckAndroidIsOpenAppGPS(isOpen)
    this.gpsEnabled = isOpen
    local location = UserData.GetLocation()
    if this.gpsEnabled then
        if location.lat ~= 0 and location.lng ~= 0 then
            this.CheckAndGetGpsCompleted()
        else
            this.HandCheckGpsData()
        end
    else
        this.CheckAndGetGpsCompleted()
    end
end

--检测定位完成回调
function GPSModule.CheckAndGetGpsCompleted()
    if this.gpsCheckCallback ~= nil then
        this.gpsCheckCallback()
        this.gpsCheckCallback = nil
    end
end

--检测定位
function GPSModule.OnCheckAndGetGpsCompleted(lat, lng)
    -- Log(">> GPSModule > OnCheckAndGetGpsCompleted > LocationEnabled = ", GpsHelper.LocationEnabled, " ,lat = ", lat, " ,lng = ", lng)
    if lat ~= 0 and lng ~= 0 then
        this.gpsEnabled = true
    else
        this.gpsEnabled = false
    end

    this.CheckAndGetGpsCompleted()
end

return GPSModule