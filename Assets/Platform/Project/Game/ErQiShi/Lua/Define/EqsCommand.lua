-- CMD.Http.C2S_CreateRoom         = 5001     --创建房间
-- CMD.Http.S2C_CreateRoom         = 5002     --创建房间
-- CMD.Http.C2S_JoinRoom           = 5003     --加入房间
-- CMD.Http.S2C_JoinRoom           = 5004     --加入房间

CMD.Tcp.C2S_JoinedRoom          = 10002     --告诉服务器前端已经加入了房间
CMD.Tcp.C2S_GetRoomData         = 70514    --获取房间数据
CMD.Tcp.S2C_GetRoomData         = 70515    --获取房间数据

CMD.Tcp.S2C_UpdateRoomData      = 70516    --更新房间信息

CMD.Tcp.C2S_Operation772        = 70772    --发送操作
CMD.Tcp.S2C_Operation772        = 70772    --发送操作

CMD.Tcp.S2C_UserCards           = 70771    --发牌
CMD.Tcp.S2C_UserOperation773    = 70773    --玩家操作结果    如果772操作结果成功，则所有玩家收到773


CMD.Tcp.C2S_UserPrepare         = 70780    --准备
CMD.Tcp.S2C_ChangeStatus        = 70781    --改变玩家状态

CMD.Tcp.C2S_QuitRoom            = 10003     --退出房间
CMD.Tcp.S2C_QuitRoom            = 70791    --退出房间

CMD.Tcp.C2S_JieShanRoom         = 70792    --房主解散房间(未开始)
CMD.Tcp.S2C_JieShanRoom         = 70792    --解散房间

CMD.Tcp.C2S_TouPiaoJieShanRoom  = 70793    --投票解散房间(牌局已开始)
CMD.Tcp.S2C_TouPiaoJieShanRoom  = 70793    --投票解散房间

CMD.Tcp.C2S_Broadcast           = 70800    --广播，原样发送给房间所有玩家
CMD.Tcp.S2C_Broadcast           = 70800    --广播，原样发送给房间所有玩家

CMD.Tcp.C2S_DanJuJieSuan        = 70810    --单局结算
CMD.Tcp.S2C_DanJuJieSuan        = 70810    --单局结算

CMD.Tcp.C2S_ZongJieSuan         = 70811    --总结算
CMD.Tcp.S2C_ZongJieSuan         = 70811    --总结算

CMD.Tcp.S2C_AutoPlay            = 70900    --托管
CMD.Tcp.C2S_AutoPlay            = 70900    --托管

--type：1 离线在线通知    2 同步牌位置
CMD.Tcp.S2C_Notice              = 70851    --服务器通知协议 data:{"type":1, "arg":{"uid":1002, "isOnline":true}}

CMD.Tcp.S2C_ServerJieShanRoom   = 80000    --解散房间，亲友圈代开房和后台强制结束data:{"type":1}  type:1 直接强制返回大厅
