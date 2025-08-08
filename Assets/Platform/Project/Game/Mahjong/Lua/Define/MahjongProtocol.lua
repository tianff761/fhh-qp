
--发送加入房间
local C2SJoinRoom = {
	roomId = "",--房间ID
	userId = "",--用户ID
	username = "",--用户名称
	img = "",--用户头像
	sex = "",--用户性别
	frameId = "",--头像框
	gold = 0,--分数
}

--加入房间返回
local S2CJoinRoom = {
	code = 0,--错误码
	id = 10001,--房间ID，房间号
	time = 0,--服务器的当前时间，秒
	rules = {},--规则数据对象、有玩法类型，局数总数，人数总数等
	clubOrTeaId = 10001,--亲友圈或者分数娱乐场id
	index = 0,--当前局数
	owner = 10001,--房主
	roomState = 0,--状态，1初始化、2等待中、3游戏中、4结算状态、5房间结束
	dismiss = 0,--解散申请状态，0没有，1表示有
	mLv = 1,--比赛等级
	mId = 1,--比赛ID
	zr = 0,--准入
	players = {
		{
			id = 10001,--ID
			name = "",--名称
			gender = 0,--性别
			head = "",--头像
			frame = "",--头像框
			seat = 1,--座位序号
			score = 0,--分数，分数余额
			ip = "",--ip地址，服务器发送
			gps = {--GPS，客户端上传
				lng = 0,--经度
				lat = 0,--纬度
			},
			online = 0,--在线标识
			entrance = 0,--入口类型，0大厅普通加入1亲友圈进入2分数娱乐场/联盟进入3快速匹配进入，没有使用（但没删除）
			ready = 0,--准备状态，0未准备、1已准备
			join = 0,--0表示未进入，1表示进入
		}
	}
}

--小局未开始前的玩家变动数据推送
local PushPlayerData = {
	delete = 10001,--删除的玩家ID，没有直接不发送
	--新增的玩家，没有直接不发送
	add = {
		id = 10001,--ID
		name = "",--名称
		gender = 0,--性别
		head = "",--头像
		frame = "",--头像框
		seat = 1,--座位序号
		score = 0,--分数
		ip = "",--ip地址，客户端上传
		gps = "",--GPS，客户端上传
		online = 0,--在线标识
		entrance = 0,--入口类型
		join = 0,--0表示未进入，1表示进入
	}
}

--玩家在线状态
local PushPlayerOnline = {
	players = {--数组
		{
			id = 10001,--ID
			online = 0,--在线标识，0离线、1在线
		}
	}
}

--------------------------------
--发送退出房间
local C2SQuitRoom = {
	roomId = 1,--房间ID
}

--退出返回，返回状态
local S2CQuitRoom = {
	code = 0,--错误码
	roomId = 1,--房间ID
}

--退出房间推送，用于未开始的房间房主解散，其他玩家退出房间
local PushExitRoom = {
	type = 0,--0未开局房间内房主解散，1未开局房间外直接解散， 2开局房间内申请解散，3开局房间外直接解散
	roomId = 1,--房间ID
}

--踢出房间推送
local PushKickRoom = {
	type = 0,--0系统强制踢人、1未准备被踢、2被玩家踢（带上玩家ID，名称）
	roomId = 1,--房间ID
	playerId = 1,--玩家ID
}

--------------------------------
--发送返回大厅
local C2SBackLobby = {
	roomId = 1,--房间ID
	isMatch = 0,--0返回大厅, 1继续游戏
}

--返回大厅返回，返回状态
local S2CBackLobby = {
	code = 0,--错误码
	isMatch = 0,-- 0返回大厅 1 继续游戏
}

--------------------------------
--准备倒计时推送
local PushReadyCountDown = {
	countDown = 30--倒计时，秒数
}

--------------------------------
--玩家数据更新
local C2SPlayerDataUpdate = {
	gps = {--GPS、可选
		lng = 0,--经度
		lat = 0,--纬度
	}
}

--玩家数据更新返回
local S2CPlayerDataUpdate = {
	code = 0,--错误码
}

--玩家数据更新推送
local PushPlayerDataUpdate = {
	players = {--数组
		{
			id = 10001,--ID
			gps = {--GPS、可选
				lng = 0,--经度
				lat = 0,--纬度
			}
		}
	}
}

--------------------------------
--发送准备
local C2SReady = {
	ready = 1,--准备状态
}

--准备返回，返回状态
local S2CReady = {
	code = 0,--错误码
	time = 0--服务器时间戳，单位秒
}

--推送所有玩家准备状态
local PushReady = {
	players = {--玩家数组
		{
			id = 10001,--ID
			seat = 1,--座位序号
			ready = 0
		}
	}
}
--------------------------------
--发送解散
local C2SDismiss = {
	id = 1,--房间ID
}

--解散返回，返回状态
local S2CDismiss = {
	code = 0,--错误码
	id = 1,--房间ID
}

--推送所有玩家解散状态
local PushDismiss = {
	applyId = 1,--申请人ID
	countDown = 60,--倒计时
	players = {--玩家数组
		{
			id = 10001,--ID
			state = 0,--状态，0未处理，1同意，2拒绝
		}
	}
}

--发送解散操作
local C2SDismissOperate = {
	id = 1,--房间ID
	state = 1,--1同意，2拒绝
}

--解散操作返回，返回状态
local S2CDismissOperate = {
	code = 0,--错误码
	id = 1,--房间ID
}
--------------------------------
--发送取消托管
local C2SCancelTrust = {
	--房间ID
	id = 0
}

--取消托管返回
local S2CCancelTrust = {
	code = 0,--错误码
}

--------------------------------
--当前小局游戏开始推送
local PushGameBegin = {
	time = 0,--服务器当前时间，单位秒
	index = 0,--当前局数
	touzi = 0,--骰子的点数
	zhuang = 10001,--庄玩家ID
	cards = 1,--剩余牌数
	type = 8,--操作类型
	id = 1,--打牌或者操作玩家ID
	card = 1,--打出牌的ID，操作时不需要
	opTime = 10,--操作时间，即中间显示的倒计时
	players = {
		{
			id = 10001,--玩家ID
			seat = 1,--座位序号
			score = 0,--分数，分数等
			state = 0,--0是等待，1是有操作项，2是胡了，3是出牌
			tState = 0,--0是没有(所有人操作完成)、1是换牌的选牌中、2是换牌的完成选牌、3是定缺中、4是完成定缺
			huType = 1,
			--[可选]，胡牌类型
			huIndex = 1,
			--[可选]，胡牌序号
			huTips = {},
			--[可选]，胡牌提示[{"hu":"25,4;28,4","key":21}]
			dq = 0,--定缺，0，未定缺，1、2、3分半表示定缺的牌，牌局是否需要定缺从玩法规则上获取
			trust = 0,--托管状态，0未托管，1托管
			left = {--左手牌、操作牌
				{
					type = 0,--操作类型
					from = 0,--来源
					k1 = 0,
					k2 = 0,
					k3 = 0,
					k4 = 0,
				--[可选]
				}
			},
			mid = {1, 2, 3},
			--[数组|数值]中间牌、手牌，如果是其他玩家则发送一个手牌长度数字
			right = 0,--右手牌,摸得牌,0表示没有牌，大于1表示有牌(1表示其他人的牌)
			push = {1, 2, 3},--打出去的牌
			
			operation = {--操作
				{
					type = 0,
					from = 0,
					k1 = 0,
					k2 = 0,
					k3 = 0,
					k4 = 0,
				}
			}
		}
	}
}


local C2SOperate = {
	--操作类型，换三张，定缺，出牌，碰牌，杠牌，过牌，胡牌，换牌
	type = 0,
	--来源
	from = 0,	
	k1 = 0,	
	k2 = 0,	
	k3 = 0,	
	k4 = 0,
}

local S2COperate = {
	code = 0,--错误码
	type = 0--成功，返回操作类型
}

local PushOperate = {
	time = 0,--服务器当前时间，单位秒
	cards = 1,--剩余牌数
	type = 8,--操作类型
	id = 1,--打牌或者操作玩家ID
	card = 1,--打出牌的ID，定缺的时候为哪一门颜色，即操作的时候记录的未操作k1
	opTime = 10,--操作时间，即中间显示的倒计时
	players = {
		id = 10001,--玩家ID
		seat = 1,--座位序号
		state = 0,--0是等待，1是有操作项，2是胡了，3是出牌
		tState = 0,--0是没有(所有人操作完成)、1是换牌的选牌中、2是换牌的完成选牌、3是定缺中、4是完成定缺
		huType = 1,
		--[可选]，胡牌类型,1胡牌，2自摸，3杠上花，4杠上炮，5抢杠胡
		huIndex = 1,
		huTips = {},
		--[可选]，胡牌提示[{"hu":"25,4;28,4","key":21}]
		dq = 0,
		trust = 0,--托管状态，0未托管，1托管
		left = {--左手牌、操作牌
			{
				type = 0,--操作类型
				from = 0,--来源
				k1 = 0,
				k2 = 0,
				k3 = 0,
				k4 = 0,
			--[可选]
			}
		},
		mid = {1, 2, 3},
		--[数组|数值]中间牌、手牌，如果是其他玩家则发送一个手牌长度数字
		right = 0,--右手牌、摸得牌
		push = {1, 2, 3},--打出去的牌
		
		operation = {--操作
			{
				type = 0,
				from = 0,
				--[可选]来源
				k1 = 0,
				--[可选]
				k2 = 0,
				--[可选]
				k3 = 0,
				--[可选]
				k4 = 0,
			--[可选]
			}
		}
	}
}

--推送房间扣除分数
local PushRoomDeductGold = {
	time = 0,--服务器当前时间，单位秒
	players = {
		id = 0,--玩家ID
		cut = 0,--减少了多少
		gold = 0,--分数余额
	}
}

--换张
local PushChangeCard = {
	time = 0,--服务器当前时间，单位秒
	dice = 0,--骰子的点数
	players = {
		id = 0,--玩家ID，回放记录
		out = {1, 2, 3, 4},--换出去的牌
		back = {1, 2, 3, 4},--换回来的牌
		mid = {1, 2, 3},--当前中间牌
		right = 0,--当前右手牌、摸得牌
	}
}

--推送游戏结束
local PushGameEnd = {
	id = 10001,--房间ID
	roomState = 0,--状态，1初始化中；2等待中；3游戏中；4处理结果、小结；5房间结束；否则未结束
	endState = 0,--0正常结算，1流局，2解散房间
	index = 0,--当前的局数
	owner = 10001,--房主
	zhuang = 10001,--庄家
	endTime = 0,--牌局结束时间，单位秒
	rcTime = 0,--准备倒计时，单位秒
	xj = {--小结数据
		{
			id = 0,--玩家ID
			seat = 0,--服务器座位号
			n = "",--玩家名称
			h = "",--头像
			hf = "",--头像框
			dq = 0,--定缺
			score = 0,--当前小局的输赢分数
			total = 0,--总分数
			fan = 0,--番
			huState = 0,--0.无、1.自摸、2.胡、3有叫、4查叫
			huIndex = 1,--胡牌顺序
			huFrom = 10001,--胡牌的来源，即类型为胡牌是，谁点的炮
			huRules = {},--胡牌规则数组
			gangs = {--gang的数据
				{
					type = 1,--类型，2明杠、3巴杠、4暗杠、5根、6点杠、7被巴杠、8被暗杠
					num = 1,--次数、数量
				}
			},
			left = {--左手牌、操作牌
				{
					type = 0,--操作类型
					from = 0,--来源
					k1 = 0,
					k2 = 0,
					k3 = 0,
					k4 = 0,	
				--[可选]
				}
			},
			mid = {1, 2, 3},
			--[数组|数值]中间牌、手牌
			right = 0,--右手牌、摸得牌
		}
	},
	zj = {--总结数据，没有可以为空对象或者空数组
		{
			id = 1,
			total = 0,--总分数
			zm = 0,--自摸次数
			jp = 0,--接炮次数
			dp = 0,--点炮次数
			ag = 0,--暗杠次数
			mg = 0,--明杠次数
			cj = 0,--查叫次数
		}
	},
	firstIds = {},--第一的玩家ID
	reward = 0,--比赛奖励
}

--回放数据
local Playback = {
	time = 0,--时间秒
	id = 10001,--房间ID
	index = 0,--当前的局数
	owner = 10001,--房主
	zhuang = 10001,--庄家
	rules = {},--规则数据对象、有玩法类型，局数总数，人数总数等
	groupId = 0,--组织ID，亲友圈或者分数娱乐场ID
	step = {},--播放步骤，数组形式
} 