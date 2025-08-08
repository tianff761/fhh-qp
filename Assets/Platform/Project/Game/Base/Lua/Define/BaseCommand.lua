
--HTTP协议命令扩展

--货币推送
CMD.Tcp.Push_Money = 1101

CMD.Tcp.C2S_CreateRoom          = 5001     --创建房间
CMD.Tcp.S2C_CreateRoom          = 5002     --创建房间
CMD.Tcp.C2S_JoinRoom            = 5003     --加入房间
CMD.Tcp.S2C_JoinRoom            = 5004     --加入房间
CMD.Tcp.C2S_CheckRoom           = 5007     --检测房间   返回游戏版本号
CMD.Tcp.S2C_CheckRoom           = 5008     --检测房间   返回游戏版本号
CMD.Tcp.C2S_CheckIsInRoom       = 5009     --检测玩家是否在房间中
CMD.Tcp.S2C_CheckIsInRoom       = 5010     --检测玩家是否在房间中
CMD.Tcp.C2S_Receipt             = 1051     --验证订单号
CMD.Tcp.S2C_Receipt             = 1052     --验证回调
CMD.Tcp.C2S_Activity            = 1053     --请求最新系统活动、公告（图片）
CMD.Tcp.S2C_Activity            = 1054     --返回系统活动、公告数据
CMD.Tcp.C2S_ScrollNotice        = 1055     --请求最新滚动公告
CMD.Tcp.S2C_ScrollNotice        = 1056     --获取最新滚动公告
CMD.Tcp.C2S_Trumpet             = 1057     --小喇叭
CMD.Tcp.S2C_Trumpet             = 1058     --小喇叭

CMD.Tcp.C2S_EnterModule         = 9001      --前端进入模块发送
CMD.Tcp.S2C_EnterModule         = 9002      --前端进入模块返回
--================================================================
--

--//*********************俱乐部**********************//
--/**加入的俱乐部列表*/
CMD.Tcp_C2S_CLUB_SELF_LIST = 2001;
--/**返回加入的俱乐部列表*/
CMD.Tcp_S2C_CLUB_SELF_LIST = 2002;

--/**俱乐部申请记录*/
CMD.Tcp_C2S_CLUB_APPLY_RECORD = 2003;
--/**回复俱乐部申请记录*/
CMD.Tcp_S2C_CLUB_APPLY_RECORD = 2004;

--/**申请加入俱乐部*/
CMD.Tcp_C2S_CLUB_APPLY_JOIN = 2005;
--/**返回申请加入俱乐部*/
CMD.Tcp_S2C_CLUB_APPLY_JOIN = 2006;

--/**进入俱乐部*/
CMD.Tcp_C2S_CLUB_ENTER = 2007;
--/**回复进入俱乐部*/
CMD.Tcp_S2C_CLUB_ENTER = 2008;

--/**俱乐部成员*/
CMD.Tcp_CLUB_MEMBER = 2009;

--/**俱乐部入会申请*/
CMD.Tcp_C2S_CLUB_JOINORLEAVE_APPLY = 2011;
--/**俱乐部入会申请*/
CMD.Tcp_S2C_CLUB_JOINORLEAVE_APPLY = 2012;

--/**俱乐部一键开房*/
CMD.Tcp_C2S_CLUB_SETOPTIN = 2013;
--/**回复俱乐部一键开房*/
CMD.Tcp_S2C_CLUB_SETOPTIN = 2014;

--/**同意加入或者拒绝加入俱乐部*/
CMD.Tcp_C2S_CLUB_AGREEORREFUSE = 2015;
--/**回复同意加入或者拒绝加入俱乐部*/
CMD.Tcp_S2C_CLUB_AGREEORREFUSE = 2016;


--/**创建俱乐部房间*/
CMD.Tcp_C2S_CLUB_CREATE_ROOM = 2017;
--/**回复创建俱乐部房间*/
CMD.Tcp_S2C_CLUB_CREATE_ROOM = 2018;

--/**俱乐部一键开房*/
CMD.Tcp_CLUB_ONE_GAME = 2019;
--/**(主推)被踢玩家推送消息*/
CMD.Tcp_S2C_CLUB_SEND_KICI = 2020;

--/**俱乐部战绩*/
CMD.Tcp_C2S_CLUB_PLAYBACK = 2021;
--/**回复俱乐部战绩*/
CMD.Tcp_S2C_CLUB_PLAYBACK = 2022;

--///**(主推)俱乐部玩家列表*/  改为客户端请求
--俱乐部玩家列表
CMD.Tcp_C2S_CLUB_MEMBER_INFO = 2023
--回复俱乐部玩家列表
CMD.Tcp_S2C_CLUB_MEMBER_INFO = 2024
--///**(主推)俱乐部房间列表   改为客户端自己请求*/
--/**客户端请求俱乐部房间列表*/
CMD.Tcp_C2S_CLUB_ROOM_INFO = 2025
--/**回复客户端请求俱乐部房间列表*/
CMD.Tcp_S2C_CLUB_ROOM_INFO = 2026

--/**(主推) 俱乐部玩家信息更改*/
CMD.Tcp_CLUB_MEMBER_CHANGE = 2027;
--/**(主推) 俱乐部房间信息更改*/
CMD.Tcp_CLUB_ROOM_CHANGE = 2028;

--/**群主解散等待中的房间*/
CMD.Tcp_C2S_CLUB_WAIT_ROOM_DIS = 2029;
--/**群主解散等待中的房间*/
CMD.Tcp_S2C_CLUB_WAIT_ROOM_DIS = 2030;

--/**俱乐部群主创建组或者删除组*/
CMD.Tcp_CLUB_ASSIGN_TEAM = 2031;
--/**俱乐部群主添加组员或者删除组员*/
CMD.Tcp_CLUB_TEAM_ADD_MEMBER = 2033;

--/**俱乐部打烊开启或者关闭*/
CMD.Tcp_C2S_CLUB_IS_DA_YANG = 2035;
--/**俱乐部打烊开启或者关闭*/
CMD.Tcp_S2C_CLUB_IS_DA_YANG = 2036;

--/**俱乐部增加或撤销管理员*/
CMD.Tcp_C2S_CLUB_ADD_ADMIN = 2037;
--/**俱乐部增加或撤销管理员*/
CMD.Tcp_S2C_CLUB_ADD_ADMIN = 2038;

--/**圈主修改管理员权限以及跑马灯*/
CMD.Tcp_C2S_CLUB_ADMIN_RULE = 2039;
--/**圈主修改管理员权限以及跑马灯*/
CMD.Tcp_S2C_CLUB_ADMIN_RULE = 2040;

--/**俱乐部禁赛功能*/
CMD.Tcp_C2S_CLUB_BANNED_FROM_THE_GAME = 2041;
--/**俱乐部禁赛功能*/
CMD.Tcp_S2C_CLUB_BANNED_FROM_THE_GAME = 2042;


--/**分组时获取不是组成员的成员列表*/
CMD.Tcp_TEAM_LIST_MEMBER = 2043;

--/**增加或解绑小黑屋玩家*/
CMD.Tcp_C2S_ADD_BLACK_HOUSE = 2045;
--/**增加或解绑小黑屋玩家*/
CMD.Tcp_S2C_ADD_BLACK_HOUSE = 2046;

--/**获得小黑屋所有绑定数据*/
CMD.Tcp_C2S_GET_ALL_BLACK_HOUSE = 2047;
--/**获得小黑屋所有绑定数据*/
CMD.Tcp_S2C_GET_ALL_BLACK_HOUSE = 2048;

--/**邀请玩家加入俱乐部*/
CMD.Tcp_C2S_INVITE_PLAYER_TO_CLUB = 2049;
--/**回复邀请玩家加入俱乐部*/
CMD.Tcp_S2C_INVITE_PLAYER_TO_CLUB = 2050;

--/**玩家获得所有邀请自己加入的俱乐部信息*/
CMD.Tcp_C2S_GET_PLAYER_ALL_INVITE = 2051;
--/**回复玩家获得所有邀请自己加入的俱乐部信息*/
CMD.Tcp_S2C_GET_PLAYER_ALL_INVITE = 2052;

--/**玩家同意或者拒绝俱乐部的邀请*/
CMD.Tcp_C2S_PLAYER_AGREE_OR_REFUSE = 2053;
--/**玩家同意或者拒绝俱乐部的邀请*/
CMD.Tcp_S2C_PLAYER_AGREE_OR_REFUSE = 2054;

--/**圈主解散俱乐部*/
CMD.Tcp_C2S_DISSOLUTION_CLUB = 2055;
--/**圈主解散俱乐部*/
CMD.Tcp_S2C_DISSOLUTION_CLUB = 2056;

--/**俱乐部搜索玩家功能*/
CMD.Tcp_C2S_CLUB_SEARCH_PLAYER = 2057;
--/**俱乐部搜索玩家功能*/
CMD.Tcp_S2C_CLUB_SEARCH_PLAYER = 2058;

--/**清除俱乐部分组组的所有场次信息*/
CMD.Tcp_CLEAR_TEAM_COUNTS = 2059;

--/**修改俱乐部统计大赢家的底分*/
CMD.Tcp_C2S_MODIFY_BIG_WIN_SCORE = 2061;
--/**修改俱乐部统计大赢家的底分*/
CMD.Tcp_S2C_MODIFY_BIG_WIN_SCORE = 2062;


--/**俱乐部新建活动*/
CMD.Tcp_C2S_ADD_CLUB_ACTIVITY = 2063;
--/**俱乐部新建活动*/
CMD.Tcp_S2C_ADD_CLUB_ACTIVITY = 2064;

--/**俱乐部删除活动*/
CMD.Tcp_C2S_REMOVE_CLUB_ACTIVITY = 2065;
--/**俱乐部删除活动*/
CMD.Tcp_S2C_REMOVE_CLUB_ACTIVITY = 2066;

--/**获得俱乐部活动*/
CMD.Tcp_C2S_GET_CLUB_ACTIVITY = 2067;
--/**获得俱乐部活动*/
CMD.Tcp_S2C_GET_CLUB_ACTIVITY = 2068;

--/**小黑屋搜索功能*/
CMD.Tcp_C2S_SEARCH_BLACK_HOUSE = 2069;
--/**小黑屋搜索功能*/
CMD.Tcp_S2C_SEARCH_BLACK_HOUSE = 2070;

--获取俱乐部游戏房间数量
CMD.Tcp_C2S_GET_ROOM_NUM = 2071
CMD.Tcp_S2C_GET_ROOM_NUM = 2072

--加入俱乐部房间
CMD.Tcp_C2S_JOIN_CLUBROOM = 2073
CMD.Tcp_S2C_JOIN_CLUBROOM = 2074

--更新房间信息
CMD.Tcp_S2C_GET_CLUB_ROOM_INFO = 2075
--俱乐部成员加入、退出成功 权限变化
CMD.Tcp_S2C_MEMBER_STATUS = 2076

--菜单排序
CMD.Tcp_C2S_MENU_SORT = 2077
CMD.Tcp_S2C_MENU_SORT = 2078

--大厅战绩
CMD.Tcp_C2S_Record = 3001
CMD.Tcp_S2C_Record = 3002
--联盟和俱乐部所有战绩
CMD.Tcp_C2S_GroupAllRecord = 3003
CMD.Tcp_S2C_GroupAllRecord = 3004
--联盟和俱乐部个人战绩
CMD.Tcp_C2S_GroupMyRecord = 3007
CMD.Tcp_S2C_GroupMyRecord = 3008

--子战绩请求协议
CMD.Tcp_C2S_SubRecord = 3017
CMD.Tcp_S2C_SubRecord = 3018

--详细战绩
CMD.Tcp_C2S_RecordDetail = 3005
CMD.Tcp_S2C_RecordDetail = 3006
--//*********************俱乐部**********************//
--//********************茶馆**************************
-- 茶馆协议号
CMD.Tcp.EnterGuild                        = 4002    -- 进入俱乐部
CMD.Tcp.EnterGuildRes                     = 4003
CMD.Tcp.JoinGuild                         = 4004    -- 申请加入俱乐部
CMD.Tcp.JoinGuildRes                      = 4005
CMD.Tcp.QuitGuild                         = 4006    -- 退出俱乐部
CMD.Tcp.QuitGuildRes                      = 4007
CMD.Tcp.SaveGuildNotice                   = 4008    -- 保存俱乐部公告
CMD.Tcp.SaveGuildNoticeRes                = 4009

CMD.Tcp.GetGuildApplyRecord               = 4010    -- 会长获取申请记录(弃用)
CMD.Tcp.GetGuildApplyRecordRes            = 4011
CMD.Tcp.GuildApplyOperate                 = 4012    -- 会长获得申请记录(弃用)
CMD.Tcp.GuildApplyOperateRes              = 4013

CMD.Tcp.GuildMemberList                   = 4014    --俱乐部玩家列表(弃用)
CMD.Tcp.GuildMemberListRes                = 4015
CMD.Tcp.GuildBanGame                      = 4016    --成员禁赛（解禁） --0解禁1禁赛
CMD.Tcp.GuildBanGameRes                   = 4017
CMD.Tcp.GuildBanGameList                  = 4018    --禁赛列表
CMD.Tcp.GuildBanGameListRes               = 4019
CMD.Tcp.MemberBlackOperate                = 4020    -- 拉黑成员操作
CMD.Tcp.MemberBlackOperateRes             = 4021
CMD.Tcp.MemberBlackList                   = 4022    -- 黑名单列表
CMD.Tcp.MemberBlackListRes                = 4023
CMD.Tcp.ManangerList                      = 4024    -- 管理员列表
CMD.Tcp.ManangerListRes                   = 4025
CMD.Tcp.ConfigManagerLimit                = 4026    -- 配置管理员权限
CMD.Tcp.ConfigManagerLimitRes             = 4027
CMD.Tcp.ManagerOperate                    = 4028    -- 升级为管理员，降级为普通成员
CMD.Tcp.ManagerOperateRes                 = 4029
CMD.Tcp.TeaOpenOrClose                    = 4030    -- 茶馆打烊或开启
CMD.Tcp.TeaOpenOrCloseRes                 = 4031

CMD.Tcp.GuildList                         = 4032    --获取俱乐部列表
CMD.Tcp.GuildListRes                      = 4033
CMD.Tcp.GetGuildInfo                      = 4034    --查看俱乐部信息
CMD.Tcp.GetGuildInfoRes                   = 4035   
CMD.Tcp.GuildChangeInfo                   = 4036    --俱乐部成员变动信息
CMD.Tcp.GuildChangeInfoRes                = 4037          
CMD.Tcp.LeaveGuildState                   = 4038    --离会状况
CMD.Tcp.LeaveGuildStateRes                = 4039
CMD.Tcp.PushQuitGuild                     = 4041    --主推退出俱乐部
CMD.Tcp.PushCreateGuild                   = 4043    -- 创建俱乐部成功
CMD.Tcp.PushDissovleGuild                 = 4045    --主推解散俱乐部

CMD.Tcp.GetTeaList                        = 4050    -- 获取茶馆列表
CMD.Tcp.GetTeaListRes                     = 4051
CMD.Tcp.TeaQuickMatch                     = 4052    -- 快速加入房间
CMD.Tcp.TeaQuickMatchRes                  = 4053
CMD.Tcp.GetAkeyRoomConfig                 = 4054    -- 获取一键配置信息
CMD.Tcp.GetAkeyRoomConfigRes              = 4055
CMD.Tcp.EditorAkeyCreateConfig            = 4056    -- 修改一键开房功能
CMD.Tcp.EditorAkeyCreateConfigRes         = 4057
CMD.Tcp.BaseCoreOpenOrClose               = 4058    -- 游戏底分开关
CMD.Tcp.BaseCoreOpenOrCloseRes            = 4059
CMD.Tcp.ChangeTeaName                     = 4060    -- 修改茶馆名称
CMD.Tcp.ChangeTeaNameRes                  = 4061

CMD.Tcp.GameOnOrOff                       = 4066    -- 游戏打烊或开启
CMD.Tcp.GameOnOrOffRes                    = 4067
CMD.Tcp.GameState                         = 4068    -- 游戏状态 是否开启还是打烊 
CMD.Tcp.GameStateRes                      = 4069

CMD.Tcp.TeaInfo                           = 4070
CMD.Tcp.TeaInfoRes                        = 4071
CMD.Tcp.GetGuildBaseCore                  = 4072    --获取匹配场关闭的场次
CMD.Tcp.GetGuildBaseCoreRes               = 4073    
CMD.Tcp.ResetGuildBaseCore                = 4074    --重置俱乐部匹配场关闭底分
CMD.Tcp.ResetGuildBaseCoreRes             = 4075  
CMD.Tcp.KickOutGuildMember                = 4076    --踢出俱乐部成员      
CMD.Tcp.KickOutGuildMemberRes             = 4077          

--
CMD.Tcp.UnionInviteTea                    = 4204    --联盟邀请茶馆加入
CMD.Tcp.UnionInviteTeaRes                 = 4205
CMD.Tcp.InviteRecord                      = 4206    --获取邀请或被邀请记录
CMD.Tcp.InviteRecordRes                   = 4207
CMD.Tcp.DealInvite                        = 4208    --茶馆处理邀请
CMD.Tcp.DealInviteRes                     = 4209
CMD.Tcp.RemoveUnion                       = 4210    --解除联盟
CMD.Tcp.RemoveUnionRes                    = 4211
CMD.Tcp.UnionMember                       = 4212    --联盟成员
CMD.Tcp.UnionMemberRes                    = 4213

CMD.Tcp.GetHeadBoxList                    = 4100    --获取头像列表
CMD.Tcp.GetHeadBoxListRes                 = 4101
CMD.Tcp.EditorHeadBox                     = 4102    --修改当前头像框
CMD.Tcp.EditorHeadBoxRes                  = 4103

CMD.Tcp.CreateGuild                       = 4000    --创建俱乐部
CMD.Tcp.CreateGuildRes                    = 4001 
CMD.Tcp.CreateUnion                       = 4202    --创建联盟
CMD.Tcp.CreateUnionRes                    = 4203
CMD.Tcp.LobbyMatch                        = 4300    --大厅匹配
CMD.Tcp.LobbyMatchRes                     = 4301
CMD.Tcp.CancelMatch                       = 4302    --取消匹配
CMD.Tcp.CancelMatchRes                    = 4303 
CMD.Tcp.GetMathcNumber                    = 4304    --匹配场游戏人数
CMD.Tcp.GetMathcNumberRes                 = 4305       

CMD.Tcp.GetMatchList                      = 4306    --获取匹配场次列表
CMD.Tcp.GetMatchListRes                   = 4307
CMD.Tcp.MatchListOpera                    = 4308    --匹配场次操作
CMD.Tcp.MatchListOperaRes                 = 4309 

CMD.Tcp_C2S_LuckyWheel                    = 6100    --开始请求转盘奖品
CMD.Tcp_S2C_LuckyWheel                    = 6101

CMD.Tcp_C2S_GetSignIn                     = 6102    --获取签到数据
CMD.Tcp_S2C_GetSignIn                     = 6103

CMD.Tcp_C2S_SignIn                        = 6104    --签到
CMD.Tcp_S2C_SignIn                        = 6105

---------------任务协议-----------------
CMD.Tcp.C2S_ShareGameTask				= 6201    --分享游戏任务
CMD.Tcp.S2C_ShareGameTask				= 6202

CMD.Tcp.C2S_GetListTask					= 6301    --任务列表
CMD.Tcp.S2C_GetListTask					= 6302

CMD.Tcp.C2S_DrawReward					= 6303    --领取任务奖励
CMD.Tcp.S2C_DrawReward					= 6304

CMD.Tcp.C2S_DrawActivity				= 6305    --领取活跃度奖励
CMD.Tcp.S2C_DrawActivity				= 6306

CMD.Tcp.C2S_SlectTasks                  = 6309    --选择任务  
CMD.Tcp.S2C_SlectTasks                  = 6310

CMD.Tcp.C2S_ActiveList                 = 6311    --活跃度列表 
CMD.Tcp.S2C_ActiveList                 = 6312


--------------手机绑定协议-------------
CMD.Tcp_C2S_GetBindVerfyCode               = 7000    --获取绑定手机号验证码
CMD.Tcp_S2C_GetBindVerfyCode               = 7001
CMD.Tcp_C2S_BindPhone                    = 7002    --绑定手机
CMD.Tcp_S2C_BindPhone                    = 7003
CMD.Tcp_C2S_PwdModify                      = 7004    --修改密码
CMD.Tcp_S2C_PwdModify                     = 7005    --修改密码
--------------实名认证-----------------
CMD.Tcp_C2S_RealName                      = 7004    --通知服务器实名
CMD.Tcp_S2C_RealName                      = 7005    --通知服务器实名
-----------大厅小红点提示--------------
CMD.Tcp.C2S_HD                            = 7100    --小红点提示
CMD.Tcp.S2C_HD                            = 7101
CMD.Tcp.Push_HD                           = 7102    --红点提示推送
--------------邮件协议-----------------
CMD.Tcp.C2S_GetEmailList                  = 6002    --获取邮件
CMD.Tcp.S2C_GetEmailList                  = 6003

CMD.Tcp.C2S_RemoveEmail                   = 6004    --删除邮件
CMD.Tcp.S2C_RemoveEmail                   = 6005

CMD.Tcp.C2S_GetEmailReward                = 6006    --领取邮件附件
CMD.Tcp.S2C_GetEmailReward                = 6007
------------------------------------------------------------------
--
--游戏内部命令扩展，值为字符串
--更新头像框
CMD.Game.UpdateHeadFrame                   = "UpdateHeadFrame"
--清除加入房间的房间号
CMD.Game.CleanJoinRoomPanel                = "CleanJoinRoomPanel"
--Gps准备界面玩家数据更新，如果是倒计时界面，玩家人数减少就关闭
CMD.Game.RoomGpsPlayerUpdate               = "RoomGpsPlayerUpdate"
--Gps准备界面，玩家自己准备完成，如果是倒计时界面就关闭
CMD.Game.RoomGpsReadyFinished              = "RoomGpsReadyFinished"
--大厅背景更新
CMD.Game.LobbyBackgroundUpdate              = "LobbyBackgroundUpdate"

CMD.Game.VoiceUpload                       = "CMD_VoiceUpload"  --语音上传成功
CMD.Game.VoiceDown                         = "CMD_VoiceDown"    --语音下载成功
CMD.Game.VoicePlay                         = "CMD_VoicePlay"    --语音开始播放
CMD.Game.MicrophoneFailure                 = "CMD_MicrophoneFailure" --麦克风开启失败
CMD.Game.VoicePlayEnd                      = "CMD_VoicePlayEnd" --语音播放结束
CMD.Game.BatteryState                      = "CMD_BatteryState" --电量获取
CMD.Game.ShieldProp                        = "CMD_ShieldProp" --更新屏蔽道具

CMD.Game.BindPhoneUpdate                   = "CMD_BindPhoneUpdate" --手机绑定
CMD.Game.UpdateHistoryData                 = "CMD_UpdateHistoryData" --更新历史记录

CMD.Game.ShareComplete                   = "CMD_Game_ShareComplete"  --分享回调


CMD.Game.CreateClubOrTeaRoomSucess         = "CreateClubOrTeaRoomSucess"

CMD.Game.UpdateGuildNotice                 = "CMD_UpdateGuildNotice" --更新俱乐部公告
CMD.Game.UpdateTeaGameState                = "CMD_UpdateTeaGameState" --更新茶馆具体底分游戏开启或关闭
CMD.Game.UpdateTeaRulesInCreateRoom        = "UpdateTeaRulesInCreateRoom"  --更新茶馆在创建房间界面的规则
CMD.Game.HandleQuickMatch                  = "CMD_HandleQuickMatch"  -- 处理快速匹配
CMD.Game.HandleContinueGame                = "CMD_HandleContinueGame"     --处理游戏房间继续游戏
CMD.Game.UpdateGuildMemberInfo             = "CMD_UpdateGuildMemberInfo"  --俱乐部成员信息更新
CMD.Game.UpdateRedPointTips                = "CMD_UpdateRedPointTips"   --更新红点提示
CMD.Game.ContinueMatch                     = "ContinueMatch"   --继续匹配积分场
CMD.Game.UpdateMatchGames                  = "CMD.Game.UpdateMatchGames"  --更新匹配场场次


CMD.Game.UpdatePlayersGpsData			   = "CMD_UpdatePlayersGpsData" --玩家的地址信息变更
CMD.Game.UpdateUserAddress				   = "CMD_UpdateUserAddress" --自己的地址信息变更
CMD.Game.UpdateUserGpsData				   = "CMD_UpdateUserGpsData" -- 自己的gps信息变更

--更新联盟小黑屋组列表
CMD.Game.UnionUpdateBlackHouseGroupList  = "CMD_UnionUpdateBlackHouseGroupList"
--更新联盟小黑屋组
CMD.Game.UnionUpdateBlackHouseGroup	 = "CMD_UnionUpdateBlackHouseGroup"
--战绩搜索
CMD.Game.UnionUpdateSearchRecord  = "CMD_UnionUpdateSearchRecord"

--更新创建房间高级设置
CMD.Game.UpdateCreateRoomAdvanced  = "UpdateCreateRoomAdvanced"
--更新创建房间高级设置(新三游戏)
CMD.Game.UpdateNewCreateRoomAdvanced  = "UpdateNewCreateRoomAdvanced"
--联盟删除桌子刷新界面
CMD.Game.UnionDeleteTableRefresh  = "UnionDeleteTableRefresh"
--刷新我的合伙人
CMD.Game.UnionRefreshMyPartner  = "UnionRefreshMyPartner"
--刷新我的玩家
CMD.Game.UnionRefreshMyMember  = "UnionRefreshMyMember"
--联盟设置分数刷新界面
CMD.Game.UnionSetScoreRefresh  = "UnionSetScoreRefresh"
--联盟设置比例刷新界面
CMD.Game.UnionSetRatioRefresh  = "UnionSetRatioRefresh"
--联盟警戒线刷新界面
CMD.Game.UnionSetWarnScoreRefresh  = "UnionSetWarnScoreRefresh"
--联盟更新名称
CMD.Game.UnionUpdateName  = "UnionUpdateName"
--更新积分管理的比赛积分页面
CMD.Game.UnionUpdateMatchScore  = "UnionUpdateMatchScore"
--追踪玩家
CMD.Game.UnionFollowPlayer  = "UnionFollowPlayer"
--联盟更新背景
CMD.Game.UnionUpdateBackground  = "UnionUpdateBackground"
--联盟查看下级
CMD.Game.UnionViewLowMember  = "UnionViewLowMember"
--联盟保底更新
CMD.Game.UnionBaodiUpdate  = "UnionBaodiUpdate"

------------------------------------------------------------------
--
--通用的TCP协议
--房间扣除元宝推送协议
CMD.Tcp.Push_RoomDeductGold                = 19995

--通用的聊天协议
CMD.Tcp.C2S_ChatData                       = 19991
CMD.Tcp.S2C_ChatData                       = 19992
CMD.Tcp.S2C_PushChatData                   = 19993

--玩家上传的gps相关
CMD.Tcp.C2S_Gps = 18885
--玩家上传的gps相关返回
CMD.Tcp.S2C_Gps = 18886
--主推玩家的gps相关信息
CMD.Tcp.S2C_PushGps = 18887

---手机注册登录
CMD.Http_C2S_GetLoginVerfyCode           = 1005
CMD.Http_S2C_GetLoginVerfyCode           = 1006
---手机注册登录
CMD.Http_C2S_PhoneRegister           = 1007
CMD.Http_S2C_PhoneRegister           = 1008 
---
CMD.Tcp.C2S_RegisterAccount             = 1011     --注册手机号
CMD.Tcp.S2C_RegisterAccount             = 1012     --注册手机号
CMD.Tcp.C2S_FindAccount                 = 1013     --找回账号密码
CMD.Tcp.S2C_FindAccount                 = 1014     --找回账号密码

CMD.Tcp.C2S_GetYZCode                   = 7000     --获取验证码
CMD.Tcp.S2C_GetYZCode                   = 7001     --获取验证码
CMD.Tcp.C2S_BindPhone                   = 7002     --绑定手机
CMD.Tcp.S2C_BindPhone                   = 7003     --绑定手机

CMD.Tcp.C2S_AccountPassword             = 7202     --设置账号密码
CMD.Tcp.S2C_AccountPassword             = 7203     --设置账号密码
-- CMD.Tcp.C2S_PlayerGender                = 7204     --设置性别
-- CMD.Tcp.S2C_PlayerGender                = 7205     --设置性别
CMD.Tcp.C2S_PlayerHead                  = 7206     --设置头像
CMD.Tcp.S2C_PlayerHead                  = 7207     --设置头像
CMD.Tcp.C2S_PlayerName                  = 7208     --设置名字
CMD.Tcp.S2C_PlayerName                  = 7209     --设置名字
CMD.Tcp.C2S_FindAccountPwd              = 7212     --找回账号密码
CMD.Tcp.S2C_FindAccountPwd              = 7213     --找回账号密码

-- CMD.Tcp.C2S_SetPlayerHead               = 7214     --申请修改头像
-- CMD.Tcp.S2C_SetPlayerHead               = 7214     --申请修改头像回复
-- CMD.Tcp.C2S_CancelPlayerHead            = 7215     --取消申请修改头像
-- CMD.Tcp.S2C_CancelPlayerHead            = 7215     --取消申请修改头像

CMD.Tcp.S2C_playerHeadResult            = 7216     --申请头像结果通知

CMD.Tcp.C2S_ModifyPlayerHeadIcon               = 7206     --修改头像
CMD.Tcp.S2C_ModifyPlayerHeadIcon               = 7207     --修改头像
CMD.Tcp.C2S_ModifyPlayerName            = 7208     --修改昵称
CMD.Tcp.S2C_ModifyPlayerName           = 7209     --修改昵称

---------------------------------------------积分赠送及积分管理(存取记录等)---------------------------------
--赠送积分
CMD.Tcp.C2S_DonateLuckyValue = 6213
CMD.Tcp.S2C_DonateLuckyValue = 6214
--进入幸运池
CMD.Tcp.C2S_EnterLuckyValuePool = 6201
CMD.Tcp.S2C_EnterLuckyValuePool = 6202
--获取幸运池余额
CMD.Tcp.C2S_GetLeftLuckyValue = 6203
CMD.Tcp.S2C_GetLeftLuckyValue = 6204
--存取积分
CMD.Tcp.C2S_SaveAndGetLuckyValue = 6205
CMD.Tcp.S2C_SaveAndGetLuckyValue = 6206
--获取积分记录
CMD.Tcp.C2S_GetLuckyValueRecord = 6207
CMD.Tcp.S2C_GetLuckyValueRecord = 6208
--修改幸运池密码
CMD.Tcp.C2S_ModifyLuckyValuePwd = 6209
CMD.Tcp.S2C_ModifyLuckyValuePwd = 6210
--表情(分红)记录
CMD.Tcp.C2S_EmotionRecord = 6211
CMD.Tcp.S2C_EmotionRecord = 6212
--积分赠送记录
CMD.Tcp.C2S_DonateLuckyValueRecord = 6217
CMD.Tcp.S2C_DonateLuckyValueRecord = 6218
--获取幸运池修改密码验证码
CMD.Tcp.C2S_GetLuckyValueForgetPwdCode = 6219
CMD.Tcp.S2C_GetLuckyValueForgetPwdCode = 6220
--获取幸运池修改密码验证码
CMD.Tcp.C2S_SetLuckyValuePwd = 6221
CMD.Tcp.S2C_SetLuckyValuePwd = 6222
---新表情记录
CMD.Tcp.C2S_RecordFaceList = 3019
CMD.Tcp.S2C_RecordFaceList = 3020





---获取消息列表
CMD.Tcp.C2S_GetMessageList = 9003
CMD.Tcp.S2C_GetMessageList = 9004
---处理消息
CMD.Tcp.C2S_DealMessage = 9005
CMD.Tcp.S2C_DealMessage = 9006

CMD.Tcp.C2S_GetServiceWeChat = 6301
CMD.Tcp.S2C_GetServiceWeChat = 6302
--是否开启游戏隐私推送
CMD.Tcp.S2C_PushGamePrivacy = 66666

--专属码使用
CMD.Tcp.C2S_InviteCode = 9011
CMD.Tcp.S2C_InviteCode = 9012

--客服列表
CMD.Tcp.C2S_ServiceList = 9021
CMD.Tcp.S2C_ServiceList = 9022
--聊天协议
CMD.Tcp.C2S_SendChat = 9023
CMD.Tcp.S2C_SendChat = 9024
--主推
CMD.Tcp.S2C_PushChat = 9025

--玩家状态
CMD.Tcp.C2S_PlayerStatus = 9026
CMD.Tcp.S2C_PlayerStatus = 9027

--提交代理
CMD.Tcp.C2S_Agent = 9028
CMD.Tcp.S2C_Agent = 9029
