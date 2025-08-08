--系统错误定义
SystemErrorCode = {
    --登录无效，被其他地方登录，即顶号
    LoginInvalidByOtherLogin = 9998,
    --系统错误
    SystemError10001 = 10001,
    --创建房间错误
    CreateRoomError10002 = 10002,
    --加入房间不存在
    RoomIsNotExist10003 = 10003,
    --游戏已经开始，不能加入房间
    GameIsStarted10004 = 10004,
    --人员已满
    RoomMemberIsFull10005 = 10005,
    --加入失败
    JoinRoomFailed10006 = 10006,
    --游戏中，不能解散房间
    CantDissolveRoomWhilePlayingGame10007 = 10007,
    --创建房间时钻石不足
    RoomCardIsNotEnough10008 = 10008,
    --创建房间时元宝不足
    GoldIsNotEnough10009 = 10009,
    --加入房间时钻石不足
    RoomCardIsNotEnoughWhenJoin10010 = 10010,
    --加入房间时元宝不足
    GoldIsNotEnoughWhenJoin10011 = 10011,
    --亲友圈钻石不足
    ClubRoomCardIsNotEnough10012 = 10012,
    --亲友圈不存在
    ClubIsNotExist10013 = 10013,
    --游戏未被激活
    GameIsNotActive10014 = 10014,
    --游戏版本过低
    LowVersion = 10015,
    --开房数量过多           
    MoreThanMaxRoom10016 = 10016,
    --游戏维护中，无法创建房间
    GameMaintenance = 10017,
    --创建房间时，玩家已经有房间
    HasRoom10019 = 10019,
    --服务器维护中
    ServerMaintenance = 10020,
    --已经拥有房间了，即频繁多次创建
    HasRoomByMultiple = 10021,
    --玩家不是亲友圈成员
    PlayerNoClubMan20049 = 20049,
    --亲友圈成员在黑名单中
    Black20029 = 20029,
    --封号
    FengHao10018 = 10018,
    -- 大厅禁止输入茶馆房间号
    JoinRoom40062 = 40062,
    --不能加入其它亲友圈房间
    ClubCantJoinRoom = 20001,
    --禁赛
    ClubForbidGame = 20016,
    --亲友圈被绑定小黑屋
    ClubBlackRoom = 20007,
    --游戏已经结束
    GameIsEnd20008 = 20008,
    --登录方式不对
    LoginError10100 = 10100,
    --手机号不正确
    PhoneError10101 = 10101,
    --手机号未注册
    PhoneUnregistered10102 = 10102,
    --密码错误
    PhonePasswordError10103 = 10103,
    AutoLoginFailed = 10104,
    PhoneError60001 = 60001,
    AlreadyBindPhone60002 = 60002,
    AlreadySendCode60003 = 60003,
    AlreadySendCode60004 = 60004,
    --验证码错误
    CodeError60005 = 60005,
    CodeError60006 = 60006,
    CodeError60007 = 60007,
    --已经注册
    AlreadyRegister60100 = 60100,
    PhonePasswordError60101 = 60101,
    --没有绑定手机
    NotBindPhone61105 = 61105,
    PhonePasswordError61106 = 61106,
    PhonePasswordError61107 = 61107,
    PhoneNotRegister61109 = 61109,
}

SystemError = {}
SystemError.config = {}

SystemError.config[SystemErrorCode.LoginInvalidByOtherLogin] = "已在其他设备登录，请注意账号安全"
SystemError.config[SystemErrorCode.SystemError10001] = "数据错误，退出游戏后重新登录"
SystemError.config[SystemErrorCode.CreateRoomError10002] = "创建房间失败"
SystemError.config[SystemErrorCode.RoomIsNotExist10003] = "加入的房间不存在"
SystemError.config[SystemErrorCode.GameIsStarted10004] = "游戏已经开始，不能加入房间"
SystemError.config[SystemErrorCode.RoomMemberIsFull10005] = "房间人员已满"
SystemError.config[SystemErrorCode.JoinRoomFailed10006] = "加入房间失败"
SystemError.config[SystemErrorCode.CantDissolveRoomWhilePlayingGame10007] = "游戏中，不能解散房间"
SystemError.config[SystemErrorCode.RoomCardIsNotEnough10008] = "钻石不足"
SystemError.config[SystemErrorCode.GoldIsNotEnough10009] = "元宝不足"
SystemError.config[SystemErrorCode.RoomCardIsNotEnoughWhenJoin10010] = "钻石不足"
SystemError.config[SystemErrorCode.GoldIsNotEnoughWhenJoin10011] = "元宝不足"
SystemError.config[SystemErrorCode.ClubRoomCardIsNotEnough10012] = "亲友圈钻石不足"
SystemError.config[SystemErrorCode.ClubIsNotExist10013] = "亲友圈不存在"
SystemError.config[SystemErrorCode.GameIsNotActive10014] = "游戏未被激活，敬请期待"
SystemError.config[SystemErrorCode.LowVersion] = "资源版本过低，请重新打开应用更新"
SystemError.config[SystemErrorCode.MoreThanMaxRoom10016] = "房间数量过多"
SystemError.config[SystemErrorCode.GameMaintenance] = "游戏维护中，无法创建房间"

SystemError.config[SystemErrorCode.ServerMaintenance] = "服务器维护中，请稍后"

SystemError.config[SystemErrorCode.PlayerNoClubMan20049] = "玩家不是亲友圈成员"
SystemError.config[SystemErrorCode.JoinRoom40062] = "加入的房间不存在"
SystemError.config[SystemErrorCode.Black20029] = "您已被禁止加入该亲友圈房间"
SystemError.config[SystemErrorCode.ClubCantJoinRoom] = "不能加入其它亲友圈房间"
SystemError.config[SystemErrorCode.ClubForbidGame] = "您已被禁赛"
SystemError.config[SystemErrorCode.ClubBlackRoom] = "当前房间不可加入，请尝试加入其他房间"
SystemError.config[SystemErrorCode.FengHao10018] = "此账号涉嫌赌博，已被封禁"
SystemError.config[SystemErrorCode.GameIsEnd20008] = "游戏已经结束"

SystemError.config[SystemErrorCode.LoginError10100] = "登录方式错误"
SystemError.config[SystemErrorCode.PhoneError10101] = "登录的手机号不正确"
SystemError.config[SystemErrorCode.PhoneUnregistered10102] = "登录的手机号未注册"
SystemError.config[SystemErrorCode.PhonePasswordError10103] = "手机号或验证码错误"
SystemError.config[SystemErrorCode.AutoLoginFailed] = "自动登录失败，请重新登录"
SystemError.config[SystemErrorCode.PhoneError60001] = "请输入正确的手机号"
SystemError.config[SystemErrorCode.AlreadyBindPhone60002] = "已经绑定了手机"
SystemError.config[SystemErrorCode.AlreadySendCode60003] = "已经发送验证码，请稍后再试"
SystemError.config[SystemErrorCode.AlreadySendCode60004] = "已经发送验证码，请稍后再试"
SystemError.config[SystemErrorCode.CodeError60005] = "请输入正确的验证码"
SystemError.config[SystemErrorCode.CodeError60006] = "请输入正确的验证码"
SystemError.config[SystemErrorCode.CodeError60007] = "验证码已失效"
SystemError.config[SystemErrorCode.AlreadyRegister60100] = "手机号已注册"
SystemError.config[SystemErrorCode.PhonePasswordError60101] = "绑定手机密码格式不正确"
SystemError.config[SystemErrorCode.NotBindPhone61105] = "您未绑定手机"
SystemError.config[SystemErrorCode.PhonePasswordError61106] = "账号密码不正确"
SystemError.config[SystemErrorCode.PhonePasswordError61107] = "账号密码格式不正确"
SystemError.config[SystemErrorCode.PhoneNotRegister61109] = "该手机号未被注册"
SystemError.config[40041] = "加入桌子失败，分数未达到警戒线"

--获取错误码描述
function SystemError.GetText(code)
    if code ~= nil then
        if SystemError.config[code] ~= nil then
            return SystemError.config[code]
        end
        return "未知错误：" .. code
    end
    return "未知错误"
end

--================================================================
--
--系统提示错误码
SystemTipsErrorCode = {
    --系统错误
    SysError = 301,
    --游戏结束，或者房间未找到
    GameOver = 308,
    --账号已经在其他地方登录
    LoginInvalidByOtherLogin = 309,
    --玩家未找到
    EmptyUser = 310,
}