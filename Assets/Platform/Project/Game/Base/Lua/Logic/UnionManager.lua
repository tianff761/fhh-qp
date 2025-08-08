-----------------------------------------协议定义---------------------------------------
CMD.Tcp.Union = {}
--获取联盟列表
CMD.Tcp.Union.C2S_GetUnionList = 4003
CMD.Tcp.Union.S2C_GetUnionList = 4004

--申请加入
CMD.Tcp.Union.C2S_ApplyJoinUnionList = 4005
CMD.Tcp.Union.S2C_ApplyJoinUnionList = 4006

--获取联盟信息
CMD.Tcp.Union.C2S_GetUnionInfo = 4007
CMD.Tcp.Union.S2C_GetUnionInfo = 4008

--申请加入联盟列表
CMD.Tcp.Union.C2S_GetUnionApplyList = 4051
CMD.Tcp.Union.S2C_GetUnionApplyList = 4052

--处理申请审核
CMD.Tcp.Union.C2S_DealApply = 4053
CMD.Tcp.Union.S2C_DealApply = 4054

--联盟成员列表
CMD.Tcp.Union.C2S_GetUnionMemberList = 4045
CMD.Tcp.Union.S2C_GetUnionMemberList = 4046

--冻结解冻
CMD.Tcp.Union.C2S_FreezeMember = 4049
CMD.Tcp.Union.S2C_FreezeMember = 4050

--清除玩家联盟积分
CMD.Tcp.Union.C2S_ClearUnionScore = 4225
CMD.Tcp.Union.S2C_ClearUnionScore = 4226


--设为管理员或者普通成员
CMD.Tcp.Union.C2S_SetMemberRole = 4047
CMD.Tcp.Union.S2C_SetMemberRole = 4048

--设为客服或者普通成员
CMD.Tcp.Union.C2S_SetServiceRole = 4069
CMD.Tcp.Union.S2C_SetServiceRole = 4070

--幸运池管理
--成员数据
CMD.Tcp.Union.C2S_LuckyMemberDataList = 4095
CMD.Tcp.Union.S2C_LuckyMemberDataList = 4096
--今日排行
CMD.Tcp.Union.C2S_TodayRankingList = 4081
CMD.Tcp.Union.S2C_TodayRankingList = 4082
--昨日排行
CMD.Tcp.Union.C2S_YestodayRankingList = 4083
CMD.Tcp.Union.S2C_YestodayRankingList = 4084

--个人数据游戏分数变动记录
CMD.Tcp.Union.C2S_GameScoreChangeList = 4059
CMD.Tcp.Union.S2C_GameScoreChangeList = 4060
--个人积分变动记录--todo:应该4061，后端还没改
CMD.Tcp.Union.C2S_LuckyValueChangeList = 4061
CMD.Tcp.Union.S2C_LuckyValueChangeList = 4062
--- 同桌统计数据
CMD.Tcp.Union.C2S_SameTableInfo = 3013
CMD.Tcp.Union.S2C_SameTableInfo = 3014

--名片
--获取名片
CMD.Tcp.Union.C2S_GetMemberCard = 4055
CMD.Tcp.Union.S2C_GetMemberCard = 4056

--设置名片
CMD.Tcp.Union.C2S_SettingMemberCard = 4057
CMD.Tcp.Union.S2C_SettingMemberCard = 4058

--合伙人
--获取合伙人列表
CMD.Tcp.Union.C2S_GetPartnerList = 4085
CMD.Tcp.Union.S2C_GetPartnerList = 4086

--添加合伙人
CMD.Tcp.Union.C2S_AddPartner = 4087
CMD.Tcp.Union.S2C_AddPartner = 4088

--邀请成员玩家
CMD.Tcp.Union.C2S_InviteMember = 4067
CMD.Tcp.Union.S2C_InviteMember = 4068

--清除合作积分
CMD.Tcp.Union.C2S_ClearCooperationScore = 4093
CMD.Tcp.Union.S2C_ClearCooperationScore = 4094

--调整比例
CMD.Tcp.Union.C2S_AdjustPartnerPercent = 4089
CMD.Tcp.Union.S2C_AdjustPartnerPercent = 4090

--联盟设置
--获取联盟设置
CMD.Tcp.Union.C2S_GetUnionSetting = 4065
CMD.Tcp.Union.S2C_GetUnionSetting = 4066
--设置联盟设置
CMD.Tcp.Union.C2S_SetUnionSetting = 4041
CMD.Tcp.Union.S2C_SetUnionSetting = 4042

---联盟设置节点2（俱乐部设置） s:修改普通配置
CMD.Tcp.Union.C2S_UNION_COMM_CONFIG = 4231;
CMD.Tcp.Union.S2C_UNION_COMM_CONFIG = 4232;

---联盟设置节点3（高级设置） s:修改高级配置
CMD.Tcp.Union.C2S_UNION_ADVANCE_CONFIG = 4233;
CMD.Tcp.Union.S2C_UNION_ADVANCE_CONFIG = 4234;

---联盟设置节点3（高级设置） s:修改其他配置
CMD.Tcp.Union.C2S_UNION_OTHER_CONFIG = 4235;
CMD.Tcp.Union.S2C_UNION_OTHER_CONFIG = 4236;

---请求获取玩家游戏保底
CMD.Tcp.Union.C2S_RequestKeepBasePercent = 4245
CMD.Tcp.Union.S2C_RequestKeepBasePercent = 4246

---请求修改玩家游戏保底比例
CMD.Tcp.Union.C2S_AdjustKeepBasePercent = 4247
CMD.Tcp.Union.S2C_AdjustKeepBasePercent = 4248

--桌子相关接口
--获取桌子列表
CMD.Tcp.Union.C2S_GetTableList = 4021
CMD.Tcp.Union.S2C_GetTableList = 4022
--刷新桌子信息
CMD.Tcp.Union.C2S_RefreshTables = 4031
CMD.Tcp.Union.S2C_RefreshTables = 4032
--创建桌子
CMD.Tcp.Union.C2S_CreateTable = 4023
CMD.Tcp.Union.S2C_CreateTable = 4024
--删除桌子
CMD.Tcp.Union.C2S_DeleteTable = 4025
CMD.Tcp.Union.S2C_DeleteTable = 4026
--修改桌子
CMD.Tcp.Union.C2S_ModifyTable = 4027
CMD.Tcp.Union.S2C_ModifyTable = 4028
--加入桌子
CMD.Tcp.Union.C2S_JoinTable = 4029
CMD.Tcp.Union.S2C_JoinTable = 4030
--获取游戏开启类型
CMD.Tcp.Union.C2S_HasRoomGameIds = 4254
CMD.Tcp.Union.S2C_HasRoomGameIds = 4255

--联盟公告
CMD.Tcp.Union.C2S_UnionNotice = 4009
CMD.Tcp.Union.S2C_UnionNotice = 4010

--赠送积分
CMD.Tcp.Union.C2S_DonateLuckyValue = 4009
CMD.Tcp.Union.S2C_DonateLuckyValue = 4010

-- 联盟设置积分
CMD.Tcp.Union.C2S_Union_SetScore = 4071
CMD.Tcp.Union.S2C_Union_SetScore = 4072

-- 积分变动
CMD.Tcp.Union.C2S_Union_ScoreChange = 4073
CMD.Tcp.Union.S2C_Union_ScoreChange = 4074


--获取小黑屋关系组 
CMD.Tcp.Union.C2S_UNION_GET_BLACK_HOUSE_ALL = 4075
CMD.Tcp.Union.S2C_UNION_GET_BLACK_HOUSE_ALL = 4076

--创建删除小黑屋关系组 
CMD.Tcp.Union.C2S_UNION_CREATE_BLACK_HOUSE = 4077
CMD.Tcp.Union.S2C_UNION_CREATE_BLACK_HOUSE = 4078

--修改小黑屋关系组 
CMD.Tcp.Union.C2S_UNION_MODIFY_BLACK_HOUSE = 4079
CMD.Tcp.Union.S2C_UNION_MODIFY_BLACK_HOUSE = 4080

--添加删除小黑屋关系组成员 
CMD.Tcp.Union.C2S_UNION_ADD_BLACK_HOUSE = 4099
CMD.Tcp.Union.S2C_UNION_ADD_BLACK_HOUSE = 4100

--添加删除小黑屋关系组成员 包含所有下级玩家
CMD.Tcp.Union.C2S_UNION_ADD_BLACK_HOUSE_ALL = 4101
CMD.Tcp.Union.S2C_UNION_ADD_BLACK_HOUSE_ALL = 4102

--获取小黑屋单个关系组数据 
CMD.Tcp.Union.C2S_UNION_GET_BLACK_HOUSE = 4103
CMD.Tcp.Union.S2C_UNION_GET_BLACK_HOUSE = 4104

--设置警戒线
CMD.Tcp.Union.C2S_UNION_SET_WARRING_SCORE = 4105
CMD.Tcp.Union.S2C_UNION_SET_WARRING_SCORE = 4106

--取消合伙人
CMD.Tcp.Union.C2S_CancelPartner = 4107
CMD.Tcp.Union.S2C_CancelPartner = 4108

--合伙人换绑
CMD.Tcp.Union.C2S_PartnerChange = 4205
CMD.Tcp.Union.S2C_PartnerChange = 4206

--转移成员
CMD.Tcp.Union.C2S_MemberChange = 4207
CMD.Tcp.Union.S2C_MemberChange = 4208

--合伙人统计
CMD.Tcp.Union.C2S_PartnerCount = 4203
CMD.Tcp.Union.S2C_PartnerCount = 4204

--记录变更
CMD.Tcp.Union.C2S_Record = 4200
CMD.Tcp.Union.S2C_Record = 4201

--战绩查询
CMD.Tcp.Union.C2S_UNION_FIND_RECORD = 3009
CMD.Tcp.Union.S2C_UNION_FIND_RECORD = 3010

--踢人
CMD.Tcp.Union.C2S_Kick = 4213
CMD.Tcp.Union.S2C_Kick = 4214

--战队成员
CMD.Tcp.Union.C2S_Team = 4111
CMD.Tcp.Union.S2C_Team = 4112

---联盟合伙人信息扩展
CMD.Tcp.Union.C2S_TeamExtra = 4115
CMD.Tcp.Union.S2C_TeamExtra = 4116


--联盟 游戏统计
CMD.Tcp.Union.C2S_GameScoreCount = 4209
CMD.Tcp.Union.S2C_GameScoreCount = 4210

---只与自己有关的游戏统计
CMD.Tcp.Union.C2S_MyGameScoreInfo = 3015
CMD.Tcp.Union.S2C_MyGameScoreInfo = 3016

--游戏记录
CMD.Tcp.Union.C2S_GameRecord = 4215
CMD.Tcp.Union.S2C_GameRecord = 4216

--房间详情
CMD.Tcp.Union.C2S_RoomDetails = 4217
CMD.Tcp.Union.S2C_RoomDetails = 4218

--解散房间
CMD.Tcp.Union.C2S_DeskDismiss = 4221
CMD.Tcp.Union.S2C_DeskDismiss = 4222

--大厅桌子踢人
CMD.Tcp.Union.C2S_DeskKick = 4219
CMD.Tcp.Union.S2C_DeskKick = 4220

--大厅桌子再来一局
CMD.Tcp.Union.C2S_AGAIN = 4113
CMD.Tcp.Union.S2C_AGAIN = 4114

--层级关系
CMD.Tcp.Union.C2S_UpDownPlayers = 4223
CMD.Tcp.Union.S2C_UpDownPlayers = 4224

---俱乐部统计
CMD.Tcp.Union.C2S_TeamStatistics = 4227
CMD.Tcp.Union.S2C_TeamStatistics = 4228

---快速加入
CMD.Tcp.Union.C2S_QuickGame = 4229
CMD.Tcp.Union.S2C_QuickGame = 4230

---新战队成员
CMD.Tcp.Union.C2S_UNION_DOWN_DETAILS = 4237
CMD.Tcp.Union.S2C_UNION_DOWN_DETAILS = 4238

CMD.Tcp.Union.C2S_UNION_SCORE_DETAIL = 9501
CMD.Tcp.Union.S2C_UNION_SCORE_DETAIL = 9502
---请求玩家信息
CMD.Tcp.Union.C2S_REQUEST_PLAYER_INFO = 4239
CMD.Tcp.Union.S2C_REQUEST_PLAYER_INFO = 4240
---设置未观察员
CMD.Tcp.Union.C2S_SetAsObserver = 4241
CMD.Tcp.Union.S2C_SetAsObserver = 4242
---排行榜
CMD.Tcp.Union.C2S_Request_Ranking = 4243
CMD.Tcp.Union.S2C_Request_Ranking = 4244
---查看过期表情保底详情
CMD.Tcp.Union.C2S_Request_KeepBaseDetail = 9503
CMD.Tcp.Union.S2C_Request_KeepBaseDetail = 9504
--推送联盟变化，身份变化、联盟增减
CMD.Tcp.Union.PushInfoUpdate = 4249

--修改联盟玩家游戏可玩状态
CMD.Tcp.Union.C2S_ModifyPlayableGame = 4250
CMD.Tcp.Union.S2C_ModifyPlayableGame = 4251

--请求联盟玩家游戏可玩状态
CMD.Tcp.Union.C2S_GetPlayableGame = 4252
CMD.Tcp.Union.S2C_GetPlayableGame = 4253

--请求盟主代替队长领取收益
CMD.Tcp.Union.C2S_GetPlayEarnings = 6279
CMD.Tcp.Union.S2C_GetPlayEarnings = 6280

--获取指定队长公告
CMD.Tcp.Union.C2S_GetCaptainNotice = 4260
CMD.Tcp.Union.S2C_GetCaptainNotice = 4261
----------------------------------------------------------------------------------------
UnionManager = {}
local this = UnionManager

UnionManager.UnionOperateType = {
    [1] = "游戏",
    [2] = "后台操作",
    [3] = "充值操作",
    [4] = "邮件领取",
    [5] = "付费表情",
    [6] = "领取收益",
    [7] = "调整积分",
    [8] = "游戏表情",
    [9] = "联盟扣除盟主房卡",
    [10] = "联盟奖池",
    [11] = "联盟踢人",
    [12] = "联盟清分",
    [13] = "游戏结算",
    [14] = "过期表情",
    [15] = "联盟保底过期",
    [16] = "玩家的表情过期",
    [17] = "玩家保底过期",
}

function UnionManager.Open(groupId, gameType, notOpenEnterPanel)
    this.Init()
    if not notOpenEnterPanel then
        PanelManager.Open(PanelConfig.UnionEnter, groupId, gameType)
    end
    --this.GetGpsModule()
end

function UnionManager.GetGpsModule()
    GPSModule.Check()
end

function UnionManager.Close()
    this.Uninit()
    PanelManager.Close(PanelConfig.UnionEnter, true)
    BaseTcpApi.SendEnterModule(ModuleType.Union)
end

function UnionManager.Init()
    AddMsg(CMD.Tcp.Union.S2C_GetUnionList, this.OnTcpGetUnionsList)
    AddMsg(CMD.Tcp.Union.S2C_ApplyJoinUnionList, this.OnTcpApplyJoinUnionList)
    AddMsg(CMD.Tcp.Union.S2C_GetUnionInfo, this.OnTcpGetUnionInfo)
    AddMsg(CMD.Tcp.Union.S2C_DealApply, this.OnTcpDealApply)

    AddMsg(CMD.Tcp.Union.S2C_FreezeMember, this.OnTcpFreezeMember)
    AddMsg(CMD.Tcp.Union.S2C_SetMemberRole, this.OnTcpSetMemberRole)
    AddMsg(CMD.Tcp.Union.S2C_SetServiceRole, this.OnTcpSetServiceRole)
    AddMsg(CMD.Tcp.Union.S2C_LuckyMemberDataList, this.OnTcpGetLuckyMemberList)
    AddMsg(CMD.Tcp.Union.S2C_TodayRankingList, this.OnTcpGetTodayRankingList)
    AddMsg(CMD.Tcp.Union.S2C_YestodayRankingList, this.OnTcpGetYestodayRankingList)
    AddMsg(CMD.Tcp.Union.S2C_GameScoreChangeList, this.OnTcpGameScoreChangeList)
    AddMsg(CMD.Tcp.Union.S2C_LuckyValueChangeList, this.OnTcpLuckyValueChangeList)
    AddMsg(CMD.Tcp.Union.S2C_GetMemberCard, this.OnTcpGetMemberCard)
    AddMsg(CMD.Tcp.Union.S2C_SettingMemberCard, this.OnTcpSetMemberCard)

    AddMsg(CMD.Tcp.Union.S2C_ClearCooperationScore, this.OnTcpClearCooperationScore)
    AddMsg(CMD.Tcp.Union.S2C_GetUnionSetting, this.OnTcpGetUnionSetting)
    AddMsg(CMD.Tcp.Union.S2C_SetUnionSetting, this.OnTcpSetUnionSetting)
    --桌子相关接口
    AddMsg(CMD.Tcp.Union.S2C_GetTableList, this.OnTcpGetTableList)
    AddMsg(CMD.Tcp.Union.S2C_RefreshTables, this.OnTcpRefreshTables)
    AddMsg(CMD.Tcp.Union.S2C_CreateTable, this.OnTcpCreateTable)
    AddMsg(CMD.Tcp.Union.S2C_ModifyTable, this.OnTcpModifyTable)
    AddMsg(CMD.Tcp.Union.S2C_JoinTable, this.OnTcpJoinTable)
    AddMsg(CMD.Tcp.Union.S2C_HasRoomGameIds, this.OnTcpHasRoomGameIds)
    --------------------------------------------------------------
    AddMsg(CMD.Tcp.Union.S2C_UnionNotice, this.OnTcpGetUnionNotice)

    AddMsg(CMD.Tcp.S2C_DonateLuckyValue, this.OnTcpDonateLuckValue)
    AddMsg(CMD.Tcp.Union.S2C_GetPlayEarnings, this.OnTcpGetPlayEarnings)
    AddMsg(CMD.Tcp.Union.S2C_GetCaptainNotice, this.OnTcpGetCaptainNotice)
end

function UnionManager.Uninit()
    RemoveMsg(CMD.Tcp.Union.S2C_GetUnionList, this.OnTcpGetUnionsList)
    RemoveMsg(CMD.Tcp.Union.S2C_ApplyJoinUnionList, this.OnTcpApplyJoinUnionList)

    RemoveMsg(CMD.Tcp.Union.S2C_DealApply, this.OnTcpDealApply)

    RemoveMsg(CMD.Tcp.Union.S2C_FreezeMember, this.OnTcpFreezeMember)
    RemoveMsg(CMD.Tcp.Union.S2C_SetMemberRole, this.OnTcpSetMemberRole)
    RemoveMsg(CMD.Tcp.Union.S2C_SetServiceRole, this.OnTcpSetServiceRole)
    RemoveMsg(CMD.Tcp.Union.S2C_LuckyMemberDataList, this.OnTcpGetLuckyMemberList)
    RemoveMsg(CMD.Tcp.Union.S2C_TodayRankingList, this.OnTcpGetTodayRankingList)
    RemoveMsg(CMD.Tcp.Union.S2C_YestodayRankingList, this.OnTcpGetYestodayRankingList)
    RemoveMsg(CMD.Tcp.Union.S2C_GameScoreChangeList, this.OnTcpGameScoreChangeList)
    RemoveMsg(CMD.Tcp.Union.S2C_LuckyValueChangeList, this.OnTcpLuckyValueChangeList)
    RemoveMsg(CMD.Tcp.Union.S2C_GetMemberCard, this.OnTcpGetMemberCard)
    RemoveMsg(CMD.Tcp.Union.S2C_SettingMemberCard, this.OnTcpSetMemberCard)

    RemoveMsg(CMD.Tcp.Union.S2C_ClearCooperationScore, this.OnTcpClearCooperationScore)
    RemoveMsg(CMD.Tcp.Union.S2C_GetUnionSetting, this.OnTcpGetUnionSetting)
    RemoveMsg(CMD.Tcp.Union.S2C_SetUnionSetting, this.OnTcpSetUnionSetting)
    --桌子相关接口
    RemoveMsg(CMD.Tcp.Union.S2C_GetTableList, this.OnTcpGetTableList)
    RemoveMsg(CMD.Tcp.Union.S2C_RefreshTables, this.OnTcpRefreshTables)
    RemoveMsg(CMD.Tcp.Union.S2C_CreateTable, this.OnTcpCreateTable)
    RemoveMsg(CMD.Tcp.Union.S2C_ModifyTable, this.OnTcpModifyTable)
    RemoveMsg(CMD.Tcp.Union.S2C_JoinTable, this.OnTcpJoinTable)
    RemoveMsg(CMD.Tcp.Union.S2C_HasRoomGameIds, this.OnTcpHasRoomGameIds)
    --------------------------------------------------------------
    RemoveMsg(CMD.Tcp.Union.S2C_UnionNotice, this.OnTcpGetUnionNotice)

    RemoveMsg(CMD.Tcp.S2C_DonateLuckyValue, this.OnTcpDonateLuckValue)
    RemoveMsg(CMD.Tcp.Union.S2C_GetPlayEarnings, this.OnTcpGetPlayEarnings)
    RemoveMsg(CMD.Tcp.Union.S2C_GetCaptainNotice, this.OnTcpGetCaptainNotice)
end

function UnionManager.ShowError(errorCode)
    local errString = UnionErrorDefine[errorCode]
    if string.IsNullOrEmpty(errString) then
        Toast.Show("参数错误")
    else
        Toast.Show(errString)
    end
end

-----------------------------------------获取联盟列表---------------------------------------
function UnionManager.SendGetUnionsList()
    SendTcpMsg(CMD.Tcp.Union.C2S_GetUnionList, {})
end

--获取联盟列表返回
function UnionManager.OnTcpGetUnionsList(data)
    if data.code == 0 then
        UnionData.ParseUnionList(data.data)
        if PanelManager.IsOpened(PanelConfig.UnionEnter) then
            UnionEnterPanel.UpdateUnionList()
        end
    end
end
----------------------------------------------------------------------------------------------
-----------------------------------------获取联盟列表------------------------------------------
function UnionManager.SendApplyJoinUnionsList(key)
    SendTcpMsg(CMD.Tcp.Union.C2S_ApplyJoinUnionList, { exclusiveKey = key })
end

function UnionManager.OnTcpApplyJoinUnionList(data)
    if data.code == 0 then
        Toast.Show("申请加入成功")
        this.SendGetUnionsList()
        PanelManager.Close(PanelConfig.UnionJoin)
    else
        UnionManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------
-----------------------------------------获取联盟信息------------------------------------------
function UnionManager.SendGetUnionInfo(unionId)
    LogError(type(unionId), unionId)
    SendTcpMsg(CMD.Tcp.Union.C2S_GetUnionInfo, { unionId = unionId })
end
function UnionManager.OnTcpGetUnionInfo(data)
    if data.code == 0 then
        UnionData.ParseUnionData(data.data)
    else
        UnionManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------
-----------------------------------------获取联盟成员列表--------------------------------------
---pageIdx:页面，从1开始
function UnionManager.SendGetUnionMemberList(pageIndex, pageCount, searchUid)
    if searchUid == nil then
        searchUid = ""
    end
    local unionId = UnionData.curUnionId
    local args = {
        unionId = unionId,
        playerId = searchUid,
        count = pageCount,
        pageIndex = pageIndex
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_GetUnionMemberList, args)
end

----------------------------------------------------------------------------------------------
-----------------------------------------获取联盟申请列表--------------------------------------
---pageIdx:页面，从1开始   searchUid:查询的玩家Id
function UnionManager.SendGetUnionApplyList(pageIndex, pageCount, searchUid)
    if searchUid == nil then
        searchUid = 0
    end
    local unionId = UnionData.curUnionId
    local args = {
        unionId = unionId,
        playerId = searchUid,
        count = pageCount,
        pageIndex = pageIndex
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_GetUnionApplyList, args)
end

----------------------------------------------------------------------------------------------
---
-------------------------------------------------冻结解冻--------------------------------------
---1冻结0解冻
function UnionManager.SendFreezeMember(uid, opType)
    local unionData = UnionData.curUnionId
    local args = {
        unionId = unionData,
        playerId = uid,
        opType = opType
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_FreezeMember, args)
end

---已弃用 已在界面上监听
function UnionManager.OnTcpFreezeMember(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.UnionScoreManager) then
            SendEvent(CMD.Game.UnionUpdateMatchScore)
        end
    else
        UnionManager.ShowError(data.code)
    end
end

---清除玩家联盟积分
function UnionManager.SendClearMemberScore(playerId)
    local args = {
        unionId = UnionData.curUnionId,
        opId = playerId,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_ClearUnionScore, args)
end

----------------------------------------------------------------------------------------------
-------------------------------------------------设置身份--------------------------------------
---设置玩家管理员或者普通成员身份
function UnionManager.SendSetMemberRole(uid, role)
    if role == UnionRole.Admin or role == UnionRole.Common then
        local data = {
            playerId = uid,
            opType = role,
            unionId = UnionData.curUnionId,
        }
        SendTcpMsg(CMD.Tcp.Union.C2S_SetMemberRole, data)
    else
        Toast.Show("只能设置管理员和普通成员")
    end
end

---已弃用 已在界面上监听
function UnionManager.OnTcpSetMemberRole(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.UnionScoreManager) then
            SendEvent(CMD.Game.UnionUpdateMatchScore)
        end
    else
        UnionManager.ShowError(data.code)
    end
end

---设置玩家管理员或者普通成员身份
--role：1为客服 0为普通成员
function UnionManager.SendSetServiceRole(uid, role)
    local unionData = UnionData.curUnionId
    local args = {
        unionId = unionData,
        custId = uid,
        type = role
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_SetServiceRole, args)
end

function UnionManager.OnTcpSetServiceRole(data)
    if data.code == 0 then

    else
        UnionManager.ShowError(data.code)
    end
end

function UnionManager.RequestSetAsObserver(playerId, add)
    local unionData = UnionData.curUnionId
    local args = {
        unionId = unionData,
        playerId = playerId,
        add = add
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_SetAsObserver, args)
end

--代替队长领取收益
function UnionManager.RequestGetPlayEarnings(playerId)
    local args = {
        groupId = UnionData.curUnionId,
        beUserId = playerId, --被代领的玩家id
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_GetPlayEarnings, args)
end
----------------------------------------------------------------------------------------------
-------------------------------------------------处理加入申请----------------------------------
---opType:1拒绝  2同意
function UnionManager.SendDealApply(uid, opType)
    local unionData = UnionData.curUnionId
    local args = {
        unionId = unionData,
        playerId = uid,
        opType = opType
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_DealApply, args)
end

function UnionManager.OnTcpDealApply(data)
    if data.code == 0 then

    else
        UnionManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------
-------------------------------------------------幸运池成员数据----------------------------------
function UnionManager.SendGetLuckyMemberList(page, searchUid)
    if searchUid == nil then
        searchUid = 0
    end
    local args = {
        unionId = UnionData.curUnionId,
        playerId = searchUid,
        count = 5,
        pageIndex = page
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_LuckyMemberDataList, args)
end

function UnionManager.OnTcpGetLuckyMemberList(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.UnionLuckyValueManage) then
            UnionLuckyValueManagePanel.UpdateMemberDataList(data.data)
        end
    else
        UnionManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------
----------------------------------------------------幸运池今日排行-----------------------------
function UnionManager.SendGetTodayRankingList(page)
    local args = {
        unionId = UnionData.curUnionId,
        playerId = 0,
        rankKey = 0,
        count = 5,
        pageIndex = page
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_TodayRankingList, args)
end

function UnionManager.OnTcpGetTodayRankingList(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.UnionLuckyValueManage) then
            UnionLuckyValueManagePanel.UpdateTodayRankingList(data.data)
        end
    else
        UnionManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------
---
-------------------------------------------------------幸运池昨日排行-----------------------------
function UnionManager.SendGetYestodayRankingList(page)
    local args = {
        unionId = UnionData.curUnionId,
        playerId = 0,
        rankKey = 0,
        count = 5,
        pageIndex = page
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_YestodayRankingList, args)
end

function UnionManager.OnTcpGetYestodayRankingList(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.UnionLuckyValueManage) then
            UnionLuckyValueManagePanel.UpdateYestodayRankingList(data.data)
        end
    else
        UnionManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------
-------------------------------------------------------游戏积分变动-----------------------------
function UnionManager.SendGameScoreChangeList(page, uid)
    local args = {
        unionId = UnionData.curUnionId,
        playerId = uid,
        rankKey = 0,
        count = 7,
        pageIndex = page
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_GameScoreChangeList, args)
end

---已弃用 已在界面上监听
function UnionManager.OnTcpGameScoreChangeList(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.UnionScoreManager) then
            UnionPersonalDataPanel.UpdateGameChangeDataList(data.data)
        end
    else
        UnionManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------
---
--获取积分变动
function UnionManager.SendGetScoreChangeList(getId, pageIndex, pageCount, self, searchId)
    local args = {
        unionId = UnionData.curUnionId,
        getId = getId,
        num = pageCount,
        index = pageIndex,
        self = self or 0,
        searchId = searchId
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_Union_ScoreChange, args)
end

-------------------------------------------------------积分变动-----------------------------
function UnionManager.SendLuckyValueChangeList(page, uid)
    local args = {
        unionId = UnionData.curUnionId,
        playerId = uid,
        rankKey = 0,
        count = 7,
        pageIndex = page,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_LuckyValueChangeList, args)
end

---同桌统计数据请求
---@param page number 页数
---@param num number 每页数量
function UnionManager.SendSameTableInfoRequest(page, num, userId)
    local args = {
        keyId = UnionData.curUnionId,
        page = page,
        num = num,
        playerId = userId,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_SameTableInfo, args)
end

---已弃用 已在界面上监听
function UnionManager.OnTcpLuckyValueChangeList(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.UnionScoreManager) then
            UnionPersonalDataPanel.UpdateLuckyValueChangeDataList(data.data)
        elseif PanelManager.IsOpened(PanelConfig.UnionScoreManager) then
            UnionScoreManagerPanel.UpdateLuckyValueChangeDataList(data.data)
        end
    else
        UnionManager.ShowError(data.code)
    end
end

---层级关系数据请求
---@param index number 页数
---@param num number 每页条数
---@param opId number 被查询人ID
function UnionManager.SendUpDownPlayersInfoRequest(index, num, opId)
    local args = {
        index = index,
        num = num,
        unionId = UnionData.curUnionId,
        opId = opId,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_UpDownPlayers, args)
end

---查看过期表情保底详情
---@param mId number 记录id
---@param page number 每页显示条数
---@param index number 当前页数
function UnionManager.SendRequestKeepBaseDetail(mId, page, index)
    local args = {
        mId = mId,
        page = page,
        index = index,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_Request_KeepBaseDetail, args)
end

---战队统计数据请求
---@param opId number 战队拥有者id
---@param pageIndex number 当前页数
---@param count number 每页显示条数
function UnionManager.SendTeamStatisticInfoRequest(pageIndex, count, opId)
    local args = {
        unionId = UnionData.curUnionId,
        opId = opId,
        pageIndex = pageIndex,
        count = count,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_TeamStatistics, args)
end

---快速加入游戏
---@param note string 游戏备注
function UnionManager.SendQuickGameRequest(note)
    local args = {
        unionId = UnionData.curUnionId,
        note = note,
        gps = UserData.GetLocation()
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_QuickGame, args)
end


----------------------------------------------------------------------------------------------------
-------------------------------------------------------获取名片------------------------------------
--opType:1我的名片  2上级名片
function UnionManager.SendGetMemberCard(opType)
    local args = {
        unionId = UnionData.curUnionId,
        opType = opType
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_GetMemberCard, args)
end

function UnionManager.OnTcpGetMemberCard(data)
    if data.code == 0 then
        UnionData.ParseMemberCardData(data.data)
        Log("刷新数据", UnionData.memberCardType, data)
        --我的名片
        if UnionData.memberCardType == 1 then
            if PanelManager.IsOpened(PanelConfig.UnionMyCard) then
                UnionMyCardPanel.UpdatePanel()
            end
        elseif UnionData.memberCardType == 2 then
            if PanelManager.IsOpened(PanelConfig.UnionSuperiorCard) then
                UnionSuperiorCardPanel.UpdatePanel()
            end
        end
    else
        UnionManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------
-------------------------------------------------------设置名片------------------------------------
--opType:1我的名片  2上级名片
function UnionManager.SendSetMemberCard(wechat, qq)
    local args = {
        unionId = UnionData.curUnionId,
        chatMsg = wechat,
        qqMsg = qq
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_SettingMemberCard, args)
end

function UnionManager.OnTcpSetMemberCard(data)
    if data.code == 0 then
        Toast.Show("名片设置成功")
        UnionManager.SendGetMemberCard(1)
    else
        UnionManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------
-------------------------------------------------------获取合伙人列表--------------------------------
--opType:1下属合伙人2下属玩家
--getUid:获取玩家下属相关
local curGetPartnerUid = 0
function UnionManager.SendGetPartnerList(opType, getUid, pageCount, pageIdx, searchId)

    --LogError("UnionManager.SendGetPartnerList", opType, getUid, pageCount, pageIdx, searchId)

    if searchId == nil then
        searchId = ""
    end
    local args = {
        unionId = UnionData.curUnionId,
        getId = getUid,
        opType = opType,
        count = pageCount,
        pageIndex = pageIdx,
        playerId = searchId,
    }
    curGetPartnerUid = getUid
    SendTcpMsg(CMD.Tcp.Union.C2S_GetPartnerList, args)
end

----------------------------------------------------------------------------------------------------
-------------------------------------------------------添加合伙人--------------------------------
function UnionManager.SendAddPartnerMember(addUid, per)
    local args = {
        unionId = UnionData.curUnionId,
        addPlayerId = addUid,
        per = per
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_AddPartner, args)
end

----------------------------------------------------------------------------------------------------
-------------------------------------------------------添加普通玩家--------------------------------
function UnionManager.SendAddCommonMember(addUid)
    local args = {
        unionId = UnionData.curUnionId,
        playerId = addUid,
        exclusiveKey = UnionData.GetUnionInfo().key
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_InviteMember, args)
end

---联盟邀请提示(请求玩家信息)
function UnionManager.RequestPlayerInfo(playerId)
    local args = {
        playId = playerId
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_REQUEST_PLAYER_INFO, args)
end

----------------------------------------------------------------------------------------------------
-------------------------------------------------------清除合作积分--------------------------------
function UnionManager.SendClearCooperationScore()
    local args = {
        unionId = UnionData.curUnionId,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_ClearCooperationScore, args)
end

function UnionManager.OnTcpClearCooperationScore(data)
    if data.code == 0 then
        Toast.Show("清除合作积分成功")
    else
        UnionManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------
-------------------------------------------------------调整合伙人比例--------------------------------
--发送设置比例
function UnionManager.SendSetRatio(uid, ratio)
    local args = {
        unionId = UnionData.curUnionId,
        playerId = uid,
        per = ratio
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_AdjustPartnerPercent, args)
end

--发送设置分数
function UnionManager.SendSetScore(uid, score)
    local args = {
        unionId = UnionData.curUnionId,
        operId = uid,
        score = score
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_Union_SetScore, args)
end

---发送设置保底
---@field unionId number 联盟id
---@field playerId number 玩家id
function UnionManager.SendRequestKeepBasePercent(uid)
    local args = {
        unionId = UnionData.curUnionId,
        playerId = uid,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_RequestKeepBasePercent, args)
end

---发送设置保底
---@field unionId number 联盟id
---@field playerId number 玩家id
---@field gameId number 游戏id
---@field per number 比例
function UnionManager.SendSetKeepBase(uid, gameId, per)
    local args = {
        unionId = UnionData.curUnionId,
        playerId = uid,
        gameId = gameId,
        per = per,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_AdjustKeepBasePercent, args)
end

function UnionManager.SendRankingInfoRequest(count, pageIndex, day)
    local args = {
        unionId = UnionData.curUnionId, -- 联盟id
        count = count, -- 每页数量
        pageIndex = pageIndex, -- 当前页码
        day = day, -- 0 表示今天 1表示昨天
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_Request_Ranking, args)
end
----------------------------------------------------------------------------------------------------
-------------------------------------------------------获取联盟设置--------------------------------
function UnionManager.SendGetUnionSetting()
    local args = {
        unionId = UnionData.curUnionId,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_GetUnionSetting, args)
end

function UnionManager.OnTcpGetUnionSetting(data)
    if data.code == 0 then
        UnionData.ParseUnionSetting(data.data)
        if PanelManager.IsOpened(PanelConfig.UnionSetting) then
            UnionSettingPanel.UpdatePanel(data.data)
        end
    else
        UnionManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------
-------------------------------------------------------设置联盟设置--------------------------------
local settingData = nil
function UnionManager.SendSetUnionSetting(isOpenShenHe, isOpenYinSi, isOpenDaYang, title, notice, num, partner_id)
    settingData = {
        unionId = UnionData.curUnionId,
        op_check = isOpenShenHe,
        op_privacy = isOpenYinSi,
        op_close = isOpenDaYang,
        op_name = title,
        op_notice = notice,
        num = num,
        partner_id = partner_id
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_SetUnionSetting, settingData)
end

function UnionManager.OnTcpSetUnionSetting(data)
    if data.code == 0 then
        if settingData ~= nil and settingData.partner_id ~= 0 then
            settingData.op_notice = UnionData.unionNotice
        end
        UnionData.ParseUnionSetting(settingData)
        Toast.Show("设置成功")
        SendEvent(CMD.Game.UnionUpdateName)
    else
        UnionManager.ShowError(data.code)
    end
end

---@param niuJoin number 牛牛加入倍数
---@param niuRob number 牛牛抢庄倍数
---@param niuLeave number 离座分数
---@param gameNegative  boolean 游戏中能否负分
---@param changeScoreInGame boolean 游戏中能否修改游戏
---@param jiFenAuth number 积分权限
function UnionManager.SendSetUnionNode2Option(niuJoin, niuRob, niuLeave, gameNegative, changeScoreInGame, jiFenAuth)
    local args = {
        unionId = UnionData.curUnionId,
        comm = {
            niuJoin = niuJoin,
            niuRob = niuRob,
            niuLeave = niuLeave,
            gameNegative = gameNegative,
            changeScoreInGame = changeScoreInGame,
            jiFenAuth = jiFenAuth,
        }
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_UNION_COMM_CONFIG, args)
end

---@param dissolveInGame boolean 游戏中解散
---@param hideFenInGame boolean 游戏中隐藏分
---@param canSendTxtGame  boolean 游戏中发送消息
---@param tuoguan number 托管
---@param notReady number 不准备剔除
---@param sameUpDivided boolean 通队长隔离
---@param showPer number 显示比例
---@param limitDistance number 距离限制
function UnionManager.SendSetNode3AdvanceOption(dissolveInGame, hideFenInGame, canSendTxtGame, tuoguan, notReady, sameUpDivided, showPer, limitDistance)
    local args = {
        unionId = UnionData.curUnionId,
        advanced = {
            dissolveInGame = dissolveInGame,
            hideFenInGame = hideFenInGame,
            canSendTxtGame = canSendTxtGame,
            tuoguan = tuoguan,
            notReady = notReady,
            sameUpDivided = sameUpDivided,
            showPer = showPer,
            limitDistance = limitDistance,
        }
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_UNION_ADVANCE_CONFIG, args)
end

---@param luckyMode number 分成
---@param hideAllFace boolean 显示隐藏所有表情
---@param autoNotFull boolean 自动模式坐满前
---@param maxSameJu number 同坐最大次数
---@param hideFull number 隐藏满人
---@param autoMode boolean 自动匹配模式
function UnionManager.SendSetNode4OtherOption(luckyMode, hideAllFace, autoNotFull, maxSameJu, hideFull, autoMode)
    local args = {
        unionId = UnionData.curUnionId,
        other = {
            luckyMode = luckyMode,
            hideAllFace = hideAllFace,
            autoNotFull = autoNotFull,
            maxSameJu = maxSameJu,
            hideFull = hideFull,
            autoMode = autoMode,
        }
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_UNION_OTHER_CONFIG, args)
end

--获取指定队长公告
function UnionManager.SendGetCaptainNotice(partnerId)
    local args = {
        unionId = UnionData.curUnionId,
        partnerId = partnerId,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_GetCaptainNotice, args)
end

--获取指定队长公告返回
function UnionManager.OnTcpGetCaptainNotice(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.UnionSetting) then
            UnionSettingPanel.UpdateCaptainNotice(data.data)
        end
    else
        UnionManager.ShowError(data.code)
    end
end

----------------------------------------------------------------------------------------------------
-------------------------------------------------------获取联盟桌子列表--------------------------------
---@param trackUser number 被追踪玩家的id
function UnionManager.SendGetTableList(gameId, note, pageIndex, gameType, trackUser)
    local args = {
        unionId = UnionData.curUnionId,
        gameId = gameId,
        count = UnionTableCountPerPage,
        note = note,
        pageIndex = pageIndex,
        gameType = gameType,
        trackUser = trackUser,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_GetTableList, args)
end

function UnionManager.OnTcpGetTableList(data)
    if data.code == 0 then
        --UnionData.ParseTableList(data.data)
        if PanelManager.IsOpened(PanelConfig.UnionRoom) then
            UnionRoomPanel.OnGetTableList(data.data)
            UnionRoomPanel.OnRefreshGameType(data.data.gameIds)
        end
    else
        UnionManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------
-------------------------------------------------------获取联盟游戏类型列表--------------------------------
function UnionManager.SendHasRoomGameIds()
    SendTcpMsg(CMD.Tcp.Union.C2S_HasRoomGameIds, {})
end

function UnionManager.OnTcpHasRoomGameIds(data)
    if data.code == 0 then
        UnionRoomPanel.OnRefreshGameType(data.data.gameIds)
    else
        UnionManager.ShowError(data.code)
    end
end

----------------------------------------------------------------------------------------------------
-------------------------------------------------------刷新联盟桌子------------------------------------
function UnionManager.SendRefreshTables(gameId, tableIds)
    local args = {
        unionId = UnionData.curUnionId,
        count = 12,
        tableIds = tableIds
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_RefreshTables, args)
end

function UnionManager.OnTcpRefreshTables(data)
    if data.code == 0 then
    else
        UnionManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------
-------------------------------------------------------创建联盟桌子------------------------------------
--
function UnionManager.SendCreateTable(gameId, playType, rules, maxjs, maxUserNum, baseScore, inGold, jieSanFenShu, note, wins, consts, baoDi, feetype, bigwin, per, bdPer, faceType)
    local args = {
        unionId = UnionData.curUnionId,
        gameId = gameId,
        gameType = playType,
        rules = rules,
        maxjs = maxjs,
        maxNum = maxUserNum,
        score = baseScore,
        inGold = inGold,
        JSFS = jieSanFenShu,
        note = note,
        qj = wins,
        zf = consts,
        bd = baoDi,
        feetype = feetype,
        bigwin = bigwin,
        per = per,
        bdPer = bdPer,
        faceType = faceType,
    }
    LogError("创建桌子", args)
    SendTcpMsg(CMD.Tcp.Union.C2S_CreateTable, args)
end

function UnionManager.OnTcpCreateTable(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.UnionRoom) then
            UnionRoomPanel.RefreshTableList()
        end
        PanelManager.Close(PanelConfig.CreateRoom)
        Toast.Show("创建桌子成功")
    else
        UnionManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------
-------------------------------------------------------删除联盟桌子------------------------------------
function UnionManager.SendDeleteTable(gameId, tableId)
    local args = {
        unionId = UnionData.curUnionId,
        gameId = gameId,
        tId = tableId,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_DeleteTable, args)
end
----------------------------------------------------------------------------------------------------
-------------------------------------------------------修改联盟桌子------------------------------------
local curModifyTableGameType = GameType.None
function UnionManager.SendModifyTable(gameId, playType, rules, maxjs, maxUserNum, baseScore, inGold, jieSanFenShu, note, wins, consts, baoDi, feetype, bigwin, per, tableId, bdPer, faceType)
    local args = {
        unionId = UnionData.curUnionId,
        tId = tableId,
        gameId = gameId,
        gameType = playType,
        rules = rules,
        maxjs = maxjs,
        maxNum = maxUserNum,
        score = baseScore,
        inGold = inGold,
        JSFS = jieSanFenShu,
        note = note,
        qj = wins,
        zf = consts,
        bd = baoDi,
        feetype = feetype,
        bigwin = bigwin,
        per = per,
        bdPer = bdPer,
        faceType = faceType,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_ModifyTable, args)
end

function UnionManager.OnTcpModifyTable(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.UnionRoom) then
            UnionRoomPanel.RefreshTableList()
        end
        PanelManager.Close(PanelConfig.UnionDeskDetails)
        PanelManager.Close(PanelConfig.ModifyRoom)
        Toast.Show("修改桌子成功")
    else
        UnionManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------
-------------------------------------------------------创建联盟桌子------------------------------------
function UnionManager.SendJoinTable(gameId, tableId)
    local args = {
        unionId = UnionData.curUnionId,
        tId = tableId,
        gameId = gameId,
        gps = UserData.GetLocation()
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_JoinTable, args)
end

function UnionManager.OnTcpJoinTable(data)
    if data.code == 0 then
    else
        UnionManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------
-------------------------------------------------------联盟公告------------------------------------
function UnionManager.SendGetUnionNotice()
    local args = {
        unionId = UnionData.curUnionId,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_UnionNotice, args)
end

function UnionManager.OnTcpGetUnionNotice(data)
    if data.code == 0 then
        UnionData.UnionNotice = tostring(data.data.unionNotice)
        if PanelManager.IsOpened(PanelConfig.UnionNotice) then
            UnionNoticePanel.SetUnionNotice(data.data.unionNotice)
        end
    else
        UnionManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------
----------------------------------------------------赠送积分成功-------------------------------------
function UnionManager.OnTcpDonateLuckValue(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.UnionRoom) then
            UnionRoomPanel.UpdatePersonalInfo()
        end
    end
end

--盟主代替队长领取收益返回
function UnionManager.OnTcpGetPlayEarnings(data)
    if data.code == 0 then
        Toast.Show("领取成功")
    else
        local errString = UnionErrorDefine[data.code]
        if string.IsNullOrEmpty(errString) then
            Toast.Show("参数错误")
        else
            Toast.Show(errString)
        end
    end
end


----------------------------------------------------------------------------------------------------
----------------------------------------------------小黑屋-------------------------------------
--
--获取小黑屋关系组 
function UnionManager.SendGetBlackHouseGroupList(pageIndex, num)
    local args = {
        unionId = UnionData.curUnionId,
        index = pageIndex,
        num = num,
        index2 = 1, --显示的玩家信息
        num2 = 12,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_UNION_GET_BLACK_HOUSE_ALL, args)
end

--创建删除小黑屋关系组，option 选项 0-增 1-删
function UnionManager.SendCreateBlackHouseGroup()
    local args = {
        unionId = UnionData.curUnionId,
        option = 0,
        houseId = 0,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_UNION_CREATE_BLACK_HOUSE, args)
end

--创建删除小黑屋关系组，option 选项 0-增 1-删
function UnionManager.SendDeleteBlackHouseGroup(houseId)
    local args = {
        unionId = UnionData.curUnionId,
        option = 1,
        houseId = houseId,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_UNION_CREATE_BLACK_HOUSE, args)
end

--修改小黑屋关系组
function UnionManager.SendModifyBlackHouseGroup(houseId, name)
    local args = {
        unionId = UnionData.curUnionId,
        houseId = houseId,
        name = name,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_UNION_MODIFY_BLACK_HOUSE, args)
end

--添加删除小黑屋关系组成员,操作类型 0-增加 1-删除
function UnionManager.SendAddBlackHousePlayer(houseId, option, userId)
    local args = {
        unionId = UnionData.curUnionId,
        houseId = houseId,
        option = option,
        uId = userId,
    }
    LogError(args)
    SendTcpMsg(CMD.Tcp.Union.C2S_UNION_ADD_BLACK_HOUSE, args)
end

--添加删除小黑屋关系组成员 包含所有下级玩家，操作类型 0-增加 1-删除
function UnionManager.SendAddBlackHousePlayerAll(houseId, option, userId)
    local args = {
        unionId = UnionData.curUnionId,
        houseId = houseId,
        option = option,
        uId = userId,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_UNION_ADD_BLACK_HOUSE_ALL, args)
end

--获取小黑屋单个关系组数据 
function UnionManager.SendGetBlackHouseGroup(houseId, pageIndex, num)
    local args = {
        unionId = UnionData.curUnionId,
        houseId = houseId,
        index = pageIndex,
        num = num,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_UNION_GET_BLACK_HOUSE, args)
end

--发送设置警戒线
function UnionManager.SendSetWarringScore(pid, score)
    local args = {
        unionId = UnionData.curUnionId,
        keyId = pid,
        score = score,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_UNION_SET_WARRING_SCORE, args)
end

--发送战绩搜索，//1 房间号  2 玩家id
function UnionManager.SendSearchRecord(gameId, type, value, page, num, day)
    --LogError("<color=aqua>发送战绩查询</color>", gameId, type, value, page, num)
    day = day or 0
    local args = {
        keyId = UnionData.curUnionId,
        gameId = gameId,
        page = page,
        num = num,
        type = type,
        value = value,
        day = day,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_UNION_FIND_RECORD, args)
end

--发送合伙人换绑
function UnionManager.SendPartnerChange(userId, newUpId)
    local args = {
        unionId = UnionData.curUnionId,
        changeId = userId,
        newUpId = newUpId,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_PartnerChange, args)
end

--发送转移成员
function UnionManager.SendMemberChange(userId, newUpId)
    local args = {
        unionId = UnionData.curUnionId,
        changeId = userId,
        newUpId = newUpId,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_MemberChange, args)
end

--发送合伙人统计
function UnionManager.SendPartnerCount()
    local args = {
        unionId = UnionData.curUnionId,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_PartnerCount, args)
end

--发送踢人
function UnionManager.SendKick(userId)
    local args = {
        unionId = UnionData.curUnionId,
        mId = userId,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_Kick, args)
end

--发送取消合伙人
function UnionManager.SendCancelPartner(userId)
    local args = {
        unionId = UnionData.curUnionId,
        uId = userId,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_CancelPartner, args)
end

--发送请求战队成员
function UnionManager.SendGetTeam(userId, pageIndex, pageCount, mid)
    local args = {
        unionId = UnionData.curUnionId,
        mid = mid,
        uId = userId,
        pageIndex = pageIndex,
        count = pageCount,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_Team, args)
end

--请求联盟合伙人信息扩展
function UnionManager.SendGetTeamExtra(playerId, pageIndex, count)
    local args = {
        unionId = UnionData.curUnionId,
        playerId = playerId or 0,
        count = count,
        pageIndex = pageIndex,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_TeamExtra, args)
end

--请求联盟新战队成员（下级列表）
---@param key number 排序关键字 --0 积分 --1 几日局数 --2今日成绩 --3战队积分
---@param desc number  0/1 是否降序
function UnionManager.SendRequestNewTeamMember(playerId, pageIndex, count, key, desc)
    local args = {
        unionId = UnionData.curUnionId,
        playerId = playerId or 0,
        count = count,
        pageIndex = pageIndex,
        key = key,
        desc = desc,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_UNION_DOWN_DETAILS, args)
end

--发送请求游戏统计
function UnionManager.SendGameScoreCount(userId, pageIndex, pageCount)
    local args = {
        unionId = UnionData.curUnionId,
        uId = userId,
        pageIndex = pageIndex,
        count = pageCount,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_GameScoreCount, args)
end

---请求只与自己有关的游戏统计
---@param keyId number 联盟id
---@param page number 页数
---@param num number 每页数量
function UnionManager.SendMyGameScoreInfoReq(keyId, page, num, playerId)
    local args = {
        keyId = keyId,
        page = page,
        num = num,
        playerId = playerId,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_MyGameScoreInfo, args)
end

--发送请求记录变更
function UnionManager.SendRecord(pageIndex, pageCount, uId)
    local args = {
        unionId = UnionData.curUnionId,
        pageIndex = pageIndex,
        count = pageCount,
        uId = uId
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_Record, args)
end

--9501
---@field groupId number 联盟id
---@param playId number 玩家id
---@param pageCount number 每页数量
---@param index number 当前页码
function UnionManager.SentScoreDetailRequest(index, pageCount, playId)
    local args = {
        groupId = UnionData.curUnionId,
        playId = playId,
        page = pageCount,
        index = index,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_UNION_SCORE_DETAIL, args)
end

--发送请求游戏记录
function UnionManager. SendGetGameRecord(userId, pageIndex, pageCount)
    local args = {
        unionId = UnionData.curUnionId,
        uId = userId,
        pageIndex = pageIndex,
        count = pageCount,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_GameRecord, args)
end

--发送请求房间详情
function UnionManager.SendGetRoomDetails(userId, roomId)
    local args = {
        unionId = UnionData.curUnionId,
        uId = userId,
        roomId = roomId,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_RoomDetails, args)
end

--发送桌子解散
function UnionManager.SendDeskDismiss(tId)
    local args = {
        unionId = UnionData.curUnionId,
        tId = tId,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_DeskDismiss, args)
end

--发送桌子踢人
function UnionManager.SendDeskKick(tId, uId)
    local args = {
        unionId = UnionData.curUnionId,
        tId = tId,
        uId = uId,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_DeskKick, args)
end

---发送再来一局
---@param gameID number 游戏id
---@param note string 备注
---@param score number 底分
function UnionManager.SendPlayAgain(guildId, gameId, note, score)
    local args = {
        unionId = guildId,
        gameId = gameId,
        note = note,
        score = score,
        gps = UserData.GetLocation()
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_AGAIN, args)
end

---请求新表情记录
function UnionManager.SendRecordFaceListRequest(pageIndex, pageItemCount, isBD)
    local args = {
        unionId = UnionData.curUnionId,
        count = pageItemCount,
        pageIndex = pageIndex,
        isBD = isBD,
    }
    SendTcpMsg(CMD.Tcp.C2S_RecordFaceList, args)
end

---请求新表情记录
function UnionManager.SendLuckyValueRecordRequest(count, pageIndex)
    local args = {
        count = count,
        pageIndex = pageIndex,
        groupId = UnionData.curUnionId,
    }
    SendTcpMsg(CMD.Tcp.C2S_GetLuckyValueRecord, args)
end

----------------------------------------------------------------------------------------------------
return UnionManager