CMD.Tcp.Pin3 = {}
CMD.Tcp.Pin3.C2S_JoinedRoom          = 10002     --告诉服务器前端已经加入了房间

CMD.Tcp.Pin3.S2C_GetRoomData         = 101700    --获取房间数据

CMD.Tcp.Pin3.S2C_UpdateUserInfo      = 101701    --更新玩家信息

CMD.Tcp.Pin3.S2C_UpdateTableOperStatus = 101702    --更新桌子状态

CMD.Tcp.Pin3.C2S_UserPrepare         = 101703    --准备
CMD.Tcp.Pin3.S2C_UserPrepared        = 101704    --准备

CMD.Tcp.Pin3.C2S_UserPerformOper     = 101705    --玩家执行操作
CMD.Tcp.Pin3.S2C_UserPerformOper     = 101706    --玩家执行操作

CMD.Tcp.Pin3.S2C_DanJuJieSuan        = 101707    --单局结算

CMD.Tcp.Pin3.C2S_QuitRoom            = 10003     --公用退出房间协议
CMD.Tcp.Pin3.S2C_QuitRoom            = 101708    --

CMD.Tcp.Pin3.C2S_AutoYaZhu           = 101709    --自动跟注
CMD.Tcp.Pin3.S2C_AutoYaZhu           = 101710    --自动跟注

CMD.Game.UpdataCardBackgroud         = 100000000 --更新牌面背景

CMD.Tcp.Pin3.S2C_UpdateGold          = 19995    --玩家执行操作

CMD.Tcp.Pin3.C2S_FangZhuStartGame    = 101720   --房主开始游戏，成功直接返回702
CMD.Tcp.Pin3.S2C_FangZhuStartGame    = 101720   --房主开始游戏，成功直接返回702

CMD.Tcp.Pin3.C2S_JoinFkGame = 101722    --加入房卡游戏
CMD.Tcp.Pin3.S2C_JoinFkGame = 101723    --加入房卡游戏

CMD.Tcp.Pin3.C2S_DissolveFkRoomRequest = 101750    --发起解散房间请求
CMD.Tcp.Pin3.S2C_DissolveFkRoomRequest = 101751    

CMD.Tcp.Pin3.C2S_DealDissolveFkRoomRequest = 101752    --处理解散房间请求
CMD.Tcp.Pin3.S2C_DealDissolveFkRoomRequest = 101751    --处理解散房间请求

CMD.Tcp.Pin3.S2C_ZongJieSuan = 101721    --总结算

CMD.Tcp.Pin3.REQUEST_SIT_DOWN = 101724    --玩家请求坐下
CMD.Tcp.Pin3.RESPOND_SIT_DOWN = 101725    --请求坐下返回(返回 result 1，2 ，3 失败 1玩家不存在2已经坐下了3没有空位)

CMD.Tcp.Pin3.PUSH_GAME_START = 101726    --返回游戏开始倒计时
