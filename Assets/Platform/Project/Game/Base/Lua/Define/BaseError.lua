
ErrorType =
{
	Toast = 1,
	Alert = 2,
}

--茶馆错误配置
TeaErrorConfig =
{
	[10001] = {content = "系统错误", type = ErrorType.Alert},
	[10014] = {content = "游戏未被激活，敬请期待", type = ErrorType.Toast},
	[10017] = {content = "服务器进行维护，不能开房", type = ErrorType.Toast},
	[40000] = {content = "请先加入茶馆", type = ErrorType.Toast},
	[40001] = {content = "茶馆不存在", type = ErrorType.Toast},
	[40002] = {content = "您已加入过其他茶馆，不能再次申请", type = ErrorType.Toast},
	[40003] = {content = "已经申请过该茶馆，无需重复申请", type = ErrorType.Toast},
	[40004] = {content = "会长不能退出茶馆", type = ErrorType.Toast},
	[40005] = {content = "操作权限不足，只能会长操作", type = ErrorType.Toast},
	[40006] = {content = "茶馆公告字数长度超出限制", type = ErrorType.Toast},
	[40007] = {content = "暂无申请记录", type = ErrorType.Toast},
	[40008] = {content = "茶馆没有开启该游戏", type = ErrorType.Toast},
	[40009] = {content = "不能在该茶馆游戏", type = ErrorType.Toast},
	[40010] = {content = "茶馆该游戏未开启", type = ErrorType.Toast},
	[40011] = {content = "规则已经重新设定，请确认", type = ErrorType.Toast},
	[40012] = {content = "元宝不足", type = ErrorType.Toast},
	[40013] = {content = "茶馆不存在", type = ErrorType.Toast},
	[40014] = {content = "没有匹配到房间", type = ErrorType.Toast},
	[40015] = {content = "没有开启开房功能", type = ErrorType.Toast},
	[40016] = {content = "没有该开房规则", type = ErrorType.Toast},
	[40017] = {content = "底分错误", type = ErrorType.Toast},
	[40018] = {content = "该游戏没有配置开房规则", type = ErrorType.Toast},
	[40019] = {content = "配置的规则有误", type = ErrorType.Toast},
	[40020] = {content = "联盟不存在", type = ErrorType.Toast},
	[40021] = {content = "已经有联盟", type = ErrorType.Toast},
	[40022] = {content = "联盟邀请已发出，无需重复邀请", type = ErrorType.Toast},
	[40023] = {content = "联盟成员已满", type = ErrorType.Toast},
	[40024] = {content = "联盟信息不存在", type = ErrorType.Toast},
	[40025] = {content = "喇叭数量不足", type = ErrorType.Toast},
	[40026] = {content = "喇叭信息错误", type = ErrorType.Toast},
	[40027] = {content = "喇叭快捷信息错误", type = ErrorType.Toast},
	[40028] = {content = "没有购买这个头像框", type = ErrorType.Toast},
	[40029] = {content = "头像框已过期", type = ErrorType.Toast},
	[40030] = {content = "该茶馆没有这个房间", type = ErrorType.Toast},
	[40031] = {content = "匹配时规则已被修改", type = ErrorType.Toast},
	[40032] = {content = "茶馆成员满员", type = ErrorType.Toast},
	
	[40033] = {content = "已被该茶馆拉黑", type = ErrorType.Toast},
	[40034] = {content = "操作权限不足", type = ErrorType.Toast},
	[40035] = {content = "该玩家不在此茶馆", type = ErrorType.Toast},
	[40036] = {content = "该玩家已不是茶馆管理员", type = ErrorType.Toast},
	[40037] = {content = "参数错误", type = ErrorType.Toast},
	[40038] = {content = "茶馆已打烊", type = ErrorType.Toast},
	[40039] = {content = "此茶馆ID已被注册", type = ErrorType.Toast},
	[40040] = {content = "此茶馆名称已被注册", type = ErrorType.Toast},
	[40041] = {content = "此底分房间已关闭", type = ErrorType.Toast},
	[40042] = {content = "您已被禁赛，不能加入该茶馆下的游戏房间", type = ErrorType.Toast},
	[40043] = {content = "没有配置游戏规则", type = ErrorType.Toast},
	[40044] = {content = "联盟没有邀请信息", type = ErrorType.Toast},
	[40048] = {content = "准入信息错误", type = ErrorType.Toast},
	[40049] = {content = "查找茶馆玩家ID不存在", type = ErrorType.Toast},
	[40050] = {content = "茶馆尚未创建茶馆，请联系管理员创建", type = ErrorType.Toast},
	[40051] = {content = "您当前操作的成员权限不足", type = ErrorType.Toast},
	[40052] = {content = "匹配失败，请稍后重试", type = ErrorType.Toast},
	[40053] = {content = "您已匹配成功，请稍等片刻", type = ErrorType.Toast},
	[40054] = {content = "茶馆已联盟", type = ErrorType.Toast},
	[40055] = {content = "茶馆已经是打烊状态", type = ErrorType.Toast},
	[40056] = {content = "茶馆已经是开启状态", type = ErrorType.Toast},
	[40057] = {content = "权限不足", type = ErrorType.Toast},
	[40058] = {content = "匹配失败", type = ErrorType.Toast},
	[40059] = {content = "操作失败，该玩家已经被其他管理员或会长禁赛", type = ErrorType.Toast},
	[40060] = {content = "操作失败，该玩家已经被其他管理员或会长取消了禁赛", type = ErrorType.Toast},
	[40061] = {content = "操作失败，该玩家已经被其他管理员或会长从黑名单中移除", type = ErrorType.Toast},
	[40062] = {content = "房间不存在", type = ErrorType.Toast},
	[40063] = {content = "没有获取到推荐茶馆", type = ErrorType.Toast},
	[40064] = {content = "请不要频繁操作", type = ErrorType.Toast},
	[40065] = {content = "您已经发出离会申请，无需重复申请", type = ErrorType.Toast},
	[40066] = {content = "没有离会申请记录", type = ErrorType.Toast},
	[40067] = {content = "离会状态不正确", type = ErrorType.Toast},
	[40068] = {content = "已经匹配成功，无法取消匹配", type = ErrorType.Toast},
	[40069] = {content = "匹配失败", type = ErrorType.Toast},
	[40070] = {content = "已经在匹配中", type = ErrorType.Toast},
	[40083] = {content = "该匹配场次已被禁用，请联系圈主", type = ErrorType.Toast},
}

--错误辅助工具
ErrorUtil = {}

--处理茶馆的错误提示
function ErrorUtil.HandleTeaError(code)
	if code == nil then
		LogError(">> ErrorUtil.HandleTeaError > code == nil")
		return
	end
	local config = TeaErrorConfig[code]
	if config == nil then
		Alert.Show("未知错误" .. code)
		return
	end
	if config.type == ErrorType.Toast then
		Toast.Show(config.content)
	else
		Alert.Show(config.content)
	end
end 