--游戏场景类型
GameSceneType = {
    --登录
    Login = 1,
    --大厅
    Lobby = 2,
    --游戏房间
    Room = 3,
}

--登录类型
LoginType = {
    --测试登录，手动输入Http地址和账号登录
    Test = 1,
    --发布登录，微信等平台或者设备号(没有微信就用设备号，在审核时，只处理微信和游客)
    Release = 2,
}

--注册界面类型
RegisterType = {
    --注册
    Register = 1,
    --重置
    Reset = 2,
}

--操作类型 1 注册验证码 2修改密码验证码
RegisterOpType = {
    Register = 1,
    Reset = 2,
}

--红点类型
RedPointType = {
    UnionApplyJoin = "2",
    LobbyMessage = "3",
    ServiceChatMessage = "4",
    ClubApplyJoin = "5",
    ClubServiceChatMessage = "6",
}

--脚本路径
ScriptPath = {
    View = "AB/Base/Lua/View/",
    ViewCommon = "AB/Base/Lua/View/Common/",
    ViewRoom = "AB/Base/Lua/View/Room/",
    ViewClub = "AB/Base/Lua/View/Club/",
    ViewTea = "AB/Base/Lua/View/Tea/",
    ViewCreateRoom = "AB/Base/Lua/View/CreateRoom/",
    ViewUnion = "AB/Base/Lua/View/Union/",
    ViewLuckyValue = "AB/Base/Lua/View/LuckyValue/",
}

--Bundle名称
BundleName = {
    Common = "base/common",
    Login = "base/login",
    Panel = "base/panels",
    Club = "base/club",
    Tea = "base/tea",
    Room = "base/room",
    Chat = "base/chat",
    Chargingprops = "base/chargingprops",
    Help = "base/help",
    CreateRoom = "base/createroom",
    RoomDesk = "base/roomdesk",
    Union = "base/union",
}

--游戏回到大厅，退到相应的panel
DefaultOpenType = {
    Lobby = 0,
    Club = 1,
    Tea = 2,
    Match = 3,
    Record = 4   --战绩
}

--游戏类型，与服务器对应
GameType = {
    --代表所有类型
    None = 0,
    --麻将
    Mahjong = 1001,
    --贰柒拾
    ErQiShi = 1007,
    --跑得快
    PaoDeKuai = 1003,
    --拼三张
    Pin3 = 1017,
    --拼十
    Pin5 = 1014,
    --十点半
    SDB = 1005,
    ---捞腌菜
    LYC = 1040,
    -- 德州
    TP = 1051,
}

--游戏配置，Name:游戏名称；Text:游戏名称文本；isOn:是否开启
GameConfig = {
    [GameType.Mahjong] = {
        Name = "Mahjong",
        Text = "麻将",
        isOn = true,
    },
    [GameType.ErQiShi] = {
        Name = "ErQiShi",
        Text = "贰柒拾",
        isOn = true,
    },
    [GameType.PaoDeKuai] = {
        Name = "PaoDeKuai",
        Text = "跑得快",
        isOn = true,
    },
    [GameType.Pin5] = {
        Name = "Pin5",
        Text = "拼十",
        isOn = true,
    },
    [GameType.Pin3] = {
        Name = "Pin3",
        Text = "拼三张",
        isOn = true,
    },
    [GameType.SDB] = {
        Name = "SDB",
        Text = "十点半",
        isOn = false,
    },
    [GameType.LYC] = {
        Name = "LYC",
        Text = "捞腌菜",
        isOn = true,
    },
    [GameType.TP] = {
        Name = "Tp",
        Text = "德州扑克",
        isOn = true,
    }
}

--房间类型，与服务器对应
RoomType = {
    --大厅
    Lobby = 0,
    --俱乐部
    Club = 1,
    --联盟
    Tea = 2,
}

--货币类型
MoneyType = {
    --钻石
    Fangka = 1,
    --积分
    Gold = 2,
    --礼券
    Gift = 3
}

--货币类型
MoneyStrType = {
    --钻石
    Fangka = "1",
    --元宝
    Gold = "2",
    --礼券
    Gift = "3"
}

--房间支付类型
PayType = {
    --房主
    Owner = 1,
    --AA制
    AA = 2,
    --大赢家
    Winner = 4
}

--房间支付类型
PayTypeName = {
    --房主
    [PayType.Owner] = "房主付",
    --AA制
    [PayType.AA] = "AA支付",
    --大赢家
    [PayType.Winner] = "大赢家付",
}

--入口类型，0大厅普通加入1俱乐部进入2茶馆/联盟进入3快速匹配进入
EntranceType = {
    Lobby = 0,
    --俱乐部
    Club = 1,
    --茶馆
    Tea = 2,
    --匹配场
    Match = 3,
}

--创建房间打开的功能类型
CreateRoomFuncType = {
    --创建房间
    Normal = 1,
    --配置房间
    Config = 2,
    --一键开房
    OneKey = 3,
}

--Gps的类型
GpsType = {
    --不处理
    None = 0,
    --强制开启
    Force = 1,

}

--本地数据名称
LocalDatas = {
    --测试服务器URL索引
    TestServerIndex = "TestServerIndex",
    --测试登录ID
    TestLoginID = "TestLoginID",
    --用户数据
    UserInfoData = "UserInfoData",
    --检测本地资源时间
    CheckLocalResTime = "CheckLocalResTime",
    --更新功能版本
    UpdateNotiveVersion = "UpdateNotiveVersion",

    ----------------测试用---------------
    -- 语言类型
    LanguageType = "LanguageType",
    --音乐的音量大小，用于背景音乐
    MusicVolume = "MusicVolume",
    --音效的音量大小，用于按钮等
    SoundVolume = "SoundVolume",
    --实名认证
    RealName = "RealName",
    --头像信息
    HeadInfoUrl = "HeadInfoUrl",
    --缓存战绩回放时的战绩数据，用于从房间回到战绩界面
    RecordDetailData = "RecordDetailData",
    --麻将
    MahjongPlayWayData = "MahjongPlayWayData",
    --贰柒拾
    EqsPlayWayData = "EqsPlayWayData",
    --跑得快
    PdkPlayWayData = "PdkPlayWayData",
}

--分享场景类型
ShareSceneType = {
    --会话
    Session = 0,
    --朋友圈
    Timeline = 1,
    --收藏
    Favorite = 2,
}

--授权类型
AuthCode = {
    Success = 0, --成功
    Failed = 1, --失败
    Cancel = 2, --取消
    NoApp = 3, --没有安装APP
}

--获取登录信息返回的Code
ResponseCode = {
    Success = 0, --成功
    Failed = 1, --失败
    Timeout = 2, --超时
}

--分享返回Code
ShareCode = {
    Success = 0, --成功
    Failed = 1, --失败
    Cancel = 2, --取消
    NoApp = 3 --没有安装APP
}


--平台类型
PlatformType = {
    NONE = 0, --无
    PHONE = 1, --手机号码
    WECHAT = 2, --微信
    XIANLIAO = 3, --闲聊
    QQ = 4, --QQ
    ZHIFUBAO = 5, --支付宝
}

--道具类型  Icon和Base/Res/Atlas/Props文件夹下icon一一对应
PropType = {
    FangKa = 1,
    Gold = 2,
    Gift = 3
}

--参与玩法,供俱乐部活动使用
ActivityTypes = {
    All = 1,
    XueZhan = 2,
    SanEr = 3,
    SanSan = 4,
    LiangRen = 5,
    SiEr = 6,
    YaoSi = 7,
    YaoSan = 8,
    YaoEr = 9,
}

--布尔类型的值
BOOLTYPE = {
    TRUE = 1,
    FALSE = 0,
}

--聊天类型
ChatDataType = {
    --语音聊天
    voiceChat = 1,
    -- 短语
    phraseChat = 2,
    --输入文本
    inuptChat = 3,
    --表情
    emotionChat = 4,
    --道具
    propChat = 5,
}

PropConfig = {
    [1001] = { Anim = "AnimItem1", Move = "MoveItem1" },
    [1002] = { Anim = "AnimItem2", Move = "MoveItem2" },
    [1003] = { Anim = "AnimItem3", Move = "MoveItem3" },
    [1004] = { Anim = "AnimItem4", Move = "MoveItem4" },
    [1005] = { Anim = "AnimItem5", Move = "MoveItem5" },
    [1006] = { Anim = "AnimItem6", Move = "MoveItem6" },
    [1007] = { Anim = "AnimItem7", Move = "MoveItem7" },
    [1008] = { Anim = "AnimItem8", Move = "MoveItem8" },
}

--分享的图片名
ShareImageNames = {
}

--幸运转盘奖励类型
LuckyWheelType = {
    --钻石
    roomCard = 1,
    --元宝
    coin = 2,
    --礼券
    grid = 3,
    --手机
    phone = 4,
    --谢谢惠顾
    thanks = 5
}

--语言类型
LanguageType = {
    putonghua = 1, --普通话
    sichuan = 2, --四川方言
}

--房间玩家准备状态类型
ReadyType = {
    --没有准备
    No = 0,
    --准备
    Ready = 1
}

--网络等级
NetLevel = {
    --极差
    Low = 0,
    --差
    Bad = 1,
    --一般
    General = 2,
    --良好
    Good = 3,
}

--电量等级
EnergyLevel = {
    --无
    None = 1,
    --低
    Low = 2,
    --正常
    Normal = 3,
}

--扣除元宝类型
--type(1支付桌费2游戏盈亏3付费表情)
DeductGoldType = {
    --桌费
    Table = 1,
    --游戏
    Game = 2,
    --表情
    Expression = 3,
}


--登录敏感词过滤
SensitiveWord = { "客服", "管理员", "官方", "GM", "上下分", "上分", "下分", "系统" }

--道具名称
PropsAnimationName = {
    --财神
    wealthGod = { name = "WealthGod", id = 10001, audio = "AudioWealthGod", isFull = true, isSingle = false },

    --加特林
    jiaTeLin = { name = "JiaTeLin", id = 10002, audio = "AudioJiaTeLin", isFull = false, isSingle = true },
    --弹孔
    dankong = { name = "Dankong" },

    --炮台
    dapao = { name = "DaPaoOne", twoName = "DaPaoTwo", threeName = "DaPaoThree", id = 10003, audio = "AudioDaPao", isFull = false, isSingle = true },
    --被炮轰弹孔
    beBlown = { name = "DaPaoBeiHong", audio = "AudioBeBlown" },

    --轰炸机
    feiJi = { name = "FeiJi", id = 10004, audio = "AudioFeiJi", isFull = false, isSingle = true },
    --对讲机
    duiJiangJi = { name = "DuiJiangJi" },
    --飞机被炸
    feiJiBeiHong = { name = "FeiJiBeiHong", audio = "AudioBeBlown" },

    --弓箭
    gongJian = { name = "GongJian", id = 10005, audio = "AudioGongJian", isFull = false, isSingle = true },
    --弓箭被射
    gongJianBeiShe = { name = "GongJianBeiShe" }
}


--龙骨动画注册用的事件
DragonBonesEventObject = {
    -- 动画开始播放。
    START = "start",
    -- 动画循环播放完成一次
    LOOP_COMPLETE = "loopComplete",
    -- 动画播放完成
    COMPLETE = "complete",
    -- 动画淡入开始
    FADE_IN = "fadeIn",
    -- 动画淡入完成
    FADE_IN_COMPLETE = "fadeInComplete",
    -- 动画淡出开始
    FADE_OUT = "fadeOut",
    -- 动画淡出完成
    FADE_OUT_COMPLETE = "fadeOutComplete",
    -- 动画帧事件
    FRAME_EVENT = "frameEvent",
    -- 动画帧声音事件
    SOUND_EVENT = "soundEvent"
}

--道具类型
PropsAnimationType = {
    [10001] = PropsAnimationName.wealthGod,
    -- [10002] = PropsAnimationName.jiaTeLin,
    [10003] = PropsAnimationName.dapao,
    -- [10004] = PropsAnimationName.feiJi,
    -- [10005] = PropsAnimationName.gongJian,
}

--道具错误码
ChatModuleCode = {
    Normal = 0, --正常返回
    Gold_Not_Enough = 1001, --元宝不足
    Gift_Not_Enough = 1002 --礼券不足
}


--网络类型
ProtocolType = {
    Tcp = 6,
}

--太极盾错误码
GuanDuJNICodeType = {
    ERRNO_SUCC = 1; --成功
    ERRNO_HOSTURL_NOT_CONFIG = 4; --Host URL不在太极盾保护URL列表中. GuanduJNI.ServerIP返回输入参数HostURL， GuanduJNI.ServerPort返回输入参数HostPort。
    ERRNO_NO_INIT = 5; --没有调用太极盾初始化函数。 GuanduJNI.ServerIP返回输入参数HostURL， GuanduJNI.ServerPort返回输入参数HostPort。
    ERRNO_PARAMETER_ERROR = 6; --输入参数为空
    ERRNO_SYSTEM_ERROR = 7; --发生系统错误，一般为内存不足或者系统套接字资源不足。
    ERRNO_PROTOCOL_NOT_SUPPORTED = 8; --不支持的协议类型
    ERRNO_SRC_PORT_OUT_OF_RANGE = 9; --源端口异常
}

--模块定义
ModuleType = {
    Lobby = 9001, --大厅
    Club = 9002, --俱乐部
    Union = 9003, --大联盟
    Game = 9101, --游戏
}

--商城物品定义
GoodsType = {
    FangKa = 1, -- 钻石
    Gold = 2, -- 元宝
    GuildSign = 3, -- 俱乐部会长标识
}
--
CreateRoomToggleColorType = {
    --普通颜色
    NormalColor = Color(194 / 255, 100 / 255, 63 / 255, 1),
    --选中颜色
    SelectedColor = Color(179 / 255, 91 / 255, 6 / 255, 1),
    --禁用颜色
    ForbiddenColor = Color(100 / 255, 100 / 255, 100 / 255, 1)
}

--十点半牌映射
SDBCardMap = {
    [1] = 101,
    [2] = 201,
    [3] = 301,
    [4] = 401,
    [5] = 501,
    [6] = 601,
    [7] = 701,
    [8] = 801,
    [9] = 901,
    [10] = 1001,
    [11] = 1101,
    [12] = 1201,
    [13] = 1301,
    [17] = 102,
    [18] = 202,
    [19] = 302,
    [20] = 402,
    [21] = 502,
    [22] = 602,
    [23] = 702,
    [24] = 802,
    [25] = 902,
    [26] = 1002,
    [27] = 1102,
    [28] = 1202,
    [29] = 1302,
    [33] = 103,
    [34] = 203,
    [35] = 303,
    [36] = 403,
    [37] = 503,
    [38] = 603,
    [39] = 703,
    [40] = 803,
    [41] = 903,
    [42] = 1003,
    [43] = 1103,
    [44] = 1203,
    [45] = 1303,
    [49] = 104,
    [50] = 204,
    [51] = 304,
    [52] = 404,
    [53] = 504,
    [54] = 604,
    [55] = 704,
    [56] = 804,
    [57] = 904,
    [58] = 1004,
    [59] = 1104,
    [60] = 1204,
    [61] = 1304,
    [65] = 2001,
    [66] = 2002,
    ---------------------------------
    [101] = 1,
    [201] = 2,
    [301] = 3,
    [401] = 4,
    [501] = 5,
    [601] = 6,
    [701] = 7,
    [801] = 8,
    [901] = 9,
    [1001] = 10,
    [1101] = 11,
    [1201] = 12,
    [1301] = 13,
    [102] = 17,
    [202] = 18,
    [302] = 19,
    [402] = 20,
    [502] = 21,
    [602] = 22,
    [702] = 23,
    [802] = 24,
    [902] = 25,
    [1002] = 26,
    [1102] = 27,
    [1202] = 28,
    [1302] = 29,
    [103] = 33,
    [203] = 34,
    [303] = 35,
    [403] = 36,
    [503] = 37,
    [603] = 38,
    [703] = 39,
    [803] = 40,
    [903] = 41,
    [1003] = 42,
    [1103] = 43,
    [1203] = 44,
    [1303] = 45,
    [104] = 49,
    [204] = 50,
    [304] = 51,
    [404] = 52,
    [504] = 53,
    [604] = 54,
    [704] = 55,
    [804] = 56,
    [904] = 57,
    [1004] = 58,
    [1104] = 59,
    [1204] = 60,
    [1304] = 61,
    [105] = 65,
    [205] = 66,
}

--消息界面消息类型
MessageType = {
    None = -1,
    Recruit = 0,
    Message = 1,
    Notice = 2
}

--房间规则类型
RoomRuleType = {
    --准入
    ZhunRu = "ZR",
    --解散番数
    JieSanFenShu = "JSFS",
    --区间
    QuJian = "QJ",
}

--================================================================

---公用快捷聊天
CommonQuickMessage = {
    [LanguageType.putonghua] = {
        [Global.GenderType.Male] = {
            { text = "你真是一个天生的演员。", audio = "chat1" },
            { text = "底牌亮出来绝对吓死你。", audio = "chat2" },
            { text = "时间就是金钱我的朋友。", audio = "chat3" },
            { text = "大家一起浪起来。", audio = "chat4" },
            { text = "我是庄家，谁敢单挑！", audio = "chat5" },
            { text = "搏一搏单车变摩托！", audio = "chat6" },
            { text = "风水轮流转，底裤都输光了！", audio = "chat7" },
            { text = "别和我抢庄小心玩死你。", audio = "chat8" },
            { text = "不要怜惜我，使劲码宝吧！", audio = "chat9" }, --捞腌菜使用，目前只有捞腌菜显示聊天按钮
        },
        [Global.GenderType.Female] = {
            { text = "你真是一个天生的演员。", audio = "chat1" },
            { text = "底牌亮出来绝对吓死你。", audio = "chat2" },
            { text = "时间就是金钱我的朋友。", audio = "chat3" },
            { text = "大家一起浪起来。", audio = "chat4" },
            { text = "我是庄家，谁敢单挑！", audio = "chat5" },
            { text = "搏一搏单车变摩托！", audio = "chat6" },
            { text = "风水轮流转，底裤都输光了！", audio = "chat7" },
            { text = "别和我抢庄小心玩死你。", audio = "chat8" },
            { text = "不要怜惜我，使劲码宝吧！", audio = "chat9" }, --捞腌菜使用，目前只有捞腌菜显示聊天按钮
        }
    }
}

---公用快捷聊天语音bundle
CommonQuickMessageAudioBundle = {
    Quick = "base/chat",
}