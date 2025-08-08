LuckyValueDefine = {}
GroupType = {
    None = -1,
    --大厅
    Lobby = 0,
    --俱乐部
    Club = 1,
    --联盟
    Union = 2
}


LuckyValueError = {
    [18001] = "发送邮件没有该玩家",
    [18002] = "请输入密码",
    [18003] = "密码错误",
    [18004] = "存入时，积分不足",
    [18005] = "取出时，积分池积分不足",
    [18006] = "输入的旧密码为空",
    [18007] = "输入的新密码为空",
    [18008] = "没有该组织",
    [18009] = "没有在该组织",
    [18010] = "赠送给玩家不在该组织",
    [18011] = "赠送金额错误",
    [18012] = "赠送积分不足",
    [18013] = "没有绑定手机",
    [18014] = "验证码或密码为空",
    [18018] = "每日0:15-6:00期间可领取积分！",
    [60003] = "有效期内不能重复发送，请稍后再试",
    [60004] = "有效期内不能重复发送，请稍后再试",
    [60005] = "没有输入验证码",
    [60006] = "验证码不正确",
    [60007] = "验证码已经过期",
}
function LuckyValueError.ShowError(code)
    local strError = LuckyValueError[code]
    if string.IsNullOrEmpty(strError) then
        Toast.Show("数据异常")
    else
        Toast.Show(strError)
    end
end