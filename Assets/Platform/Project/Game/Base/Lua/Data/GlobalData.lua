--全局数据
GlobalData = {}

--第三方平台（简称平台）数据
GlobalData.platform = {
    --应用唯一ID，等录时使用
    openId = nil,
    --平台的唯一ID，unionId
    unionId = "0",
    --昵称
    nickName = nil,
    --头像Url
    headUrl = "0",
    --性别男1，女2，未填写为0
    gender = 2,
    --设备类型
    deviceType = "",
    --设备ID
    deviceId = "",
    --是否更新头像，0不更新，1更新
    isUpdateHead = 0,
	--账号类型 0游客，1手机号码
	accountType = PlatformType.NONE,
	--手机号
	phoneNum = "",
	--密码
	password = "",
}

--战绩回放下载地址链接 登录时设置
GlobalData.playbackDownUrl = ""

--创建房间的缓存数据，根据游戏来存储，客户端缓存使用，各个游戏内部可以自定义
--{
--	[gameType] = {}
--}
GlobalData.createRoomCacheData = {}

--链接服务器数据
GlobalData.ServerConfigData = nil

--全局房间数据，进入房间才有的数据
GlobalData.room = {
    --房间ID
    id = nil,
    --游戏类型
    gameType = GameType.Mahjong,
    --房间类型
    roomType = RoomType.Lobby,
    --货币类型
    moneyType = MoneyType.Fangka,
}

--上次分享的时间（秒）
GlobalData.lastShareTime = 0

--微信客服号(6301协议获取)，微信号字符串数组
GlobalData.serviceWebchat = nil

--当前游戏房间隐私权限是否开启
GlobalData.isOpenCurRoomPrivate = false
