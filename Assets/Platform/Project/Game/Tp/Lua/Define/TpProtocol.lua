-- PUSH_GAME_MSG  105000
-- 进入房间的消息 
-- roomId 房间号
-- rules  房间规则
-- ownerId 创建者id
-- nowjs 当前局数
-- gameStatus 游戏状态
-- countDown 倒计时
-- totalCD 总共倒计时
-- needGold 最低下注
-- opId 当前操作玩家id
-- isStartGame 游戏是否开始  0/1
-- startAt 游戏开始时间 毫秒
-- zhuangId 庄家id
-- mangPool 芒果池
-- betPool 下注的池
-- mang 芒果大小
-- playerMsg 玩家列表 = [{
-- 	pId 玩家id
-- 	sNum 座位号
-- 	name 名字
-- 	img   头像
-- 	sex   性别
-- 	gold   金币
-- 	isg   下的芒
-- 	itg   下注 
-- 	ir     是否准备
-- 	io   是否在线
-- 	il  是否看牌
-- 	is   是否两排
-- 	ijg  是否加入游戏
-- 	gu   是否弃牌
-- 	ps    玩家状态
-- 	pIds  手牌
-- 	pIdsX  之后扯得牌
-- }]

-- 玩家更新消息
-- PUSH_PLAYER_MSG 105001
-- opType 	1.加入房间，
--         2.退出房间，数据只有玩家id和座位号
-- 		3.上线离线，只有玩家id和座位号和在线状态)
-- 		4.房主切换
-- pId 玩家id
-- sNum 座位号 

-- 如果opType是1，加入房间
-- 	name 名字
-- 	img   头像
-- 	sex   性别
-- 	gold   金币
-- 	isg   下的芒
-- 	itg   下注 
-- 	io   是否在线
-- 如果opType是3，上线离线
-- 	io   是否在线
-- 如果opType是4，
-- 	"isOwner", 1
	
	
-- --推送游戏状态
-- PUSH_GAME_STATUS=105002
-- gameStatus  游戏状态
-- nowjs	当前局数
-- countDown 剩余
-- totalCD 总cd
-- zhuangId 装
-- opId   操作id
-- mangPool 芒果池
-- betPool 下注的池
-- needGold 下注最小
-- playerMsg 玩家列表[{
-- 		id id 
--         itg 下的注
--         isg 下的芒 
--         ir  是否准备 
--         il  是否看牌 
--         gu  是否放弃
--         ps  玩家状态 
--         ijg  是否加入游戏 
--         gold 金币
-- }]

-- --玩家发送准备
-- REQUEST_READY_MSG=105003
-- {
-- }

-- --广播准备消息
-- PUSH_READY_MSG=105004
-- pId 玩家id


-- --客户端  玩家操作

-- REQUEST_PLAYER_OPER=105005
-- opType 操作类型 		-- 看牌
-- 						POKER_LOOK = 1
-- 						-- 弃牌
-- 						POKER_GIVE_UP = 2
-- 						-- 扯牌
-- 						POKER_SEPT = 3
-- 						-- 跟注
-- 						ZHU_GEN = 4
-- 						-- 加注
-- 						ZHU_ADD = 5
-- 						-- 休
-- 						ZHU_PASS = 6
-- 						-- 亮牌
-- 						POKER_SHOW = 7
						
-- 当opType 为扯牌时  POKER_SEPT = 3
-- 	sept 数组 依次传入客户端拍好的四张牌

-- 当opType 为加注时 ZHU_ADD = 5
-- 	ig 为加注后总下注


-- --玩家操作广播
-- RESPOND_PLAYER_OPER=105006

-- opType 操作类型
-- pId 玩家id
-- gold 金币  

-- opType跟注或者加注时
-- 	itg 下注
-- 	isg  下的芒果
-- 	needGold 下注最小
-- 	betPool 下注池
-- 	mangPool 芒池
-- opType 为亮牌时
-- 	pIds 牌 
	
	
-- --推动结算信息
-- PUSH_EACH_RESULT=105007
-- msgs 数组 每个玩家的结算信息[{
-- 	pId 玩家id
-- 	gold 金币
-- 	winGold 输赢
-- 	pIds 手牌 
-- 	pIdsShow 玩家分的牌
-- }]

-- --离开房间个人推送
-- PUSH_EXIT_ROOM=105008
-- type 离开类型 type:1主动退出2被踢出3房间解散4金币不足被踢出5游戏结束


-- --推送总结算信息
-- PUSH_LAST_RESULT=105021
-- list 玩家列表 [{
-- 	pId 玩家id 
-- 	winGold 输赢
-- 	isBigWin 大赢家次数
-- 	isBigLose 大输家次数
-- 	winNum 赢次数
-- 	loseNum 输次数
-- }]
-- note 备注
-- endTime 结束时间


-- --房主开始请求
-- FANGZHU_START_GAME=105020

-- --玩家请求加入游戏  中途加入
-- REQUEST_JOIN_GAME=105022

-- --玩家请求加入游戏回复
-- RESPOND_JOIN_GAME=105023
-- ijg 是否加入 

-- --玩家请求坐下
-- REQUEST_SIT_DOWN =105024


-- --请求坐下返回
-- RESPOND_SIT_DOWN =105025
-- roomId 房间id
-- code 0 成功 其他错误

-- --请求解散房间
-- REQUEST_DIS_ROOM

-- -- 游戏开始倒计时
-- PUSH_GAME_START=105050
-- second 倒计时



-- --玩家请求游戏内回放
-- REQUEST_GAME_RECORD=105009
-- ju 第几局 如果0 则是最后一句


-- --返回游戏内回放
-- RESPOND_GAME_RECORD=105010
-- ju 第几局 
-- all 总局数
-- info 数据 [
-- ]