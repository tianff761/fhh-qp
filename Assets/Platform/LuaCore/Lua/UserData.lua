UserData = {}
local this = UserData

--注：所有变量通过Get和Set方法访问
UserData.openId = 0
--用户ID long   只读
UserData.userId = 0
--钻石 long
UserData.roomCard = 0
--礼券 long
UserData.gift = 0
--元宝 long
UserData.gold = 0
--房间号 long
UserData.roomId = 0
--令牌 long   只读
UserData.token = ""
--姓名 string
UserData.name = ""
--性别 int 1男 2女
UserData.gender = 0
--头像Url string
UserData.headUrl = ""
--是否已经登录
UserData.isLogined = false
--绑定手机号 string 绑定的手机号码，没有为""
UserData.bindPhone = ""
--头像框
UserData.frameId = 0
--设备号
UserData.deviceId = nil
--设备类型
UserData.deviceType = 0
--亲友圈ID
UserData.guildId = 0
--登录时间
UserData.loginTime = 0
UserData.ip = ""
--gps信息
UserData.location = {
    lat = 0,
    lng = 0,
    address = ""
}

UserData.isSetTaskType = false


--是否是断线重连
UserData.isReconnect = false
UserData.isFirstLogin = true

UserData.moduleType = 0

--头像是否审核中
UserData.headAuditing = false

function UserData.SetOpenId(openId)
    this.openId = openId
end

function UserData.GetOpenId()
    return this.openId
end

--只读
function UserData.GetUserId()
    return this.userId
end

--只读
function UserData.GetToken()
    return this.token
end

function UserData.IsLogin()
    return this.isLogined
end

function UserData.SetIsLogin(isLogin)
    this.isLogined = isLogin
end

function UserData.GetBindPhone()
    return this.bindPhone
end

function UserData.SetBindPhone(BindPhone)
    this.bindPhone = BindPhone
end
--可读写
function UserData.SetRoomCard(roomCard)
    this.roomCard = roomCard
end

function UserData.GetRoomCard()
    return this.roomCard
end

function UserData.SetGift(gift)
    this.gift = gift
end

function UserData.GetGift()
    return this.gift
end

function UserData.SetGold(gold)
    this.gold = gold
end

function UserData.GetGold()
    return this.gold
end

function UserData.SetRoomId(roomId)
    this.roomId = roomId
end

function UserData.GetRoomId()
    return this.roomId
end

function UserData.SetName(name)
    this.name = name
end

function UserData.GetName()
    return this.name
end

function UserData.SetGender(gender)
    this.gender = gender
end

function UserData.GetGender()
    return this.gender
end

function UserData.SetHeadUrl(url)
    if string.IsNullOrEmpty(url) then
        this.headUrl = "0"
    else
        this.headUrl = url
    end
end

function UserData.GetHeadUrl()
    return this.headUrl
end

function UserData.SetDeviceType(deviceType)
    this.deviceType = deviceType
end

function UserData.GetDeviceType(deviceType)
    return this.deviceType
end

function UserData.GetDeviceId()
    if this.deviceId == nil then
        this.deviceId = SystemInfo.deviceUniqueIdentifier
    end
    return this.deviceId
end

function UserData.SetIsReconnectTag(bool)
    this.isReconnect = bool
end

function UserData.IsReconnect()
    return this.isReconnect
end

function UserData.GetFrameId()
    return this.frameId
end

function UserData.SetFrameId(txk)
    this.frameId = txk
end

function UserData.SetGuildId(guild)
    this.guildId = guild
end

function UserData.GetGuildId()
    return this.guildId
end

function UserData.SetLoginTime(time)
    this.loginTime = time
end

function UserData.GetLoginTime()
    return this.loginTime
end

function UserData.SetIP(ipTxt)
    this.ip = ipTxt
end

function UserData.GetIP()
    return this.ip
end

function UserData.IsFirstLogin()
    return this.isFirstLogin
end

function UserData.SetIsFirstLogin(isLogin)
    this.isFirstLogin = isLogin
end

function UserData.SetModuleType(moduleType)
    this.moduleType = moduleType
end

function UserData.GetModuleType()
    return this.moduleType
end

--清除玩家数据
function UserData.Clear()
    this.isLogined = false
    this.isFirstLogin = true
    this.roomId = 0
    this.guildId = 0
end

function UserData.SetLocation(lat, lng)
    Log(string.format(">> UserData > SetLocation > lat = %s, lng = %s", lat, lng))
    this.location.lat = lat
    this.location.lng = lng
end
function UserData.SetLocationAddress(address)
    Log(string.format(">> UserData > SetLocationAddress > address = %s", address))
    this.location.address = address
end

function UserData.GetLocation()
    return this.location
end

function UserData.SetTaskType(isSet)
    this.isSetTaskType = isSet
end
function UserData.GetIsSetTaskType()
    return this.isSetTaskType
end

function UserData.GetHeadAuditing()
    return this.headAuditing
end

function UserData.SetHeadAuditing(isSet)
    this.headAuditing = isSet
end