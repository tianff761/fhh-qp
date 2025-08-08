--茶馆
TeaApi = {}
--4002进入俱乐部
function TeaApi.SendEnterGuild()
    local data = {
        userId = UserData.GetUserId(),
        guildId = UserData.GetGuildId(),
    }
    SendTcpMsg(CMD.Tcp.EnterGuild, data)
end

--4004申请加入俱乐部
function TeaApi.SendApplyJoinGuild(guildId)
    local data = {
        userId = UserData.GetUserId(),
        guildId = guildId,
    }
    SendTcpMsg(CMD.Tcp.JoinGuild, data)
end

--4006退出俱乐部 1 确认退出，0取消退会
function TeaApi.SendQuitGuild(operType)
    local data = {
        userId = UserData.GetUserId(),
        guildId = UserData.GetGuildId(),
        operType = operType,

    }
    SendTcpMsg(CMD.Tcp.QuitGuild, data)
end

--4008 保存俱乐部公告
function TeaApi.SendSaveGuildNotice(notice)
    local data = {
        userId = UserData.GetUserId(),
        notice = notice,
        guildId = UserData.GetGuildId(),
    }
    SendTcpMsg(CMD.Tcp.SaveGuildNotice, data)
end

--圈主对申请成员进行操作  1同意 2 拒绝
function TeaApi.SendApplyOperate(guildId,playerId,operType)
    local data = {
        userId = UserData.GetUserId(),
        guildId = guildId,
        playerId = playerId,
        operType = operType, 
    }
    SendTcpMsg(CMD.Tcp.GuildApplyOperate, data)
end

--4010 圈主获取俱乐部积分场申请列表
function TeaApi.SendGuildApplyList(pageIndex,count)
        local data = {
        userId = UserData.GetUserId(),
        guildId = UserData.GetGuildId(),
        pageIndex = pageIndex,
        count = count,
    }
    SendTcpMsg(CMD.Tcp.GetGuildApplyRecord, data)
end

--4014 俱乐部玩家列表
function TeaApi.SendGuildMemberList(pageIndex, targetId)
    local data = {
        userId = UserData.GetUserId(),
        pageIndex = pageIndex,
        playerId = targetId,
        count = 4,
        guildId = UserData.GetGuildId()
    }
    SendTcpMsg(CMD.Tcp.GuildMemberList, data)
end

--4016 成员禁赛（解禁） --0解禁1禁赛
function TeaApi.SendMemberBanGame(option, targetId)
    local data = {
        userId = UserData.GetUserId(),
        playerId = targetId,
        guildId = UserData.GetGuildId(),
        jinsai = option,
    }
    SendTcpMsg(CMD.Tcp.GuildBanGame, data)
end

--4018 禁赛列表
function TeaApi.SendBanGameList(pageIndex, targetId)
    local data = {
        userId = UserData.GetUserId(),
        playerId = targetId,
        guildId = UserData.GetGuildId(),
        pageIndex = pageIndex,
    }
    SendTcpMsg(CMD.Tcp.GuildBanGameList, data)
end

--4020 拉黑成员操作
function TeaApi.SendMemberBlackOperate(option, targetId)
    local data = {
        userId = UserData.GetUserId(),
        playerId = targetId,
        guildId = UserData.GetGuildId(),
        black = option,
    }
    SendTcpMsg(CMD.Tcp.MemberBlackOperate, data)
end

--4022 黑名单列表
function TeaApi.SendBlackList(pageIndex, targetId)
    local data = {
        userId = UserData.GetUserId(),
        playerId = targetId,
        guildId = UserData.GetGuildId(),
        pageIndex = pageIndex,
    }
    SendTcpMsg(CMD.Tcp.MemberBlackList, data)
end

--4024 管理员列表
function TeaApi.SendManagerList(pageIndex, targetId)
    local data = {
        userId = UserData.GetUserId(),
        playerId = targetId,
        guildId = UserData.GetGuildId(),
        pageIndex = pageIndex,
    }
    SendTcpMsg(CMD.Tcp.ManangerList, data)
end

--4026 配置管理员权限
function TeaApi.SendConfigManagerLimit(optionArr, targetId)
    local data = {
        userId = UserData.GetUserId(),
        adminId = targetId,
        guildId = UserData.GetGuildId(),
        powerArr = optionArr,
    }
    SendTcpMsg(CMD.Tcp.ConfigManagerLimit, data)
end

--4028 升级为管理员，降级为普通成员
function TeaApi.SendManagerOperate(isAdmin, targetId)
    local data = {
        userId = UserData.GetUserId(),
        playerId = targetId,
        guildId = UserData.GetGuildId(),
        isAdmin = isAdmin,
    }
    SendTcpMsg(CMD.Tcp.ManagerOperate, data)
end

-- 4030 茶馆打烊或开启
function TeaApi.SendTeaOpenOrClose(isopen)
    local data = {
        userId = UserData.GetUserId(),
        guildId = UserData.GetGuildId(),
        isopen = isopen,
    }
    SendTcpMsg(CMD.Tcp.TeaOpenOrClose, data)
end

--4032 俱乐部获得推荐列表 0 代表无俱乐部获取推荐 其他代表搜索
function TeaApi.SendGuildList(guildId)
    local data = {
        userId = UserData.GetUserId(),
        guildId = guildId,
    }
    SendTcpMsg(CMD.Tcp.GuildList, data)
end

--4034 查看俱乐部信息
function TeaApi.CheckGuildInfo(guildId)
    local data = {
        guildId = guildId,
        userId = UserData.GetUserId(),
    }
    SendTcpMsg(CMD.Tcp.GetGuildInfo, data)
end

--4036 俱乐部成员变动信息
function TeaApi.GuildMemberChangeInfo(count, pageIndex)
    local data = {
        guildId = UserData.GetGuildId(),
        count = count,
        pageIndex = pageIndex,
        userId = UserData.GetUserId(),
    }
    SendTcpMsg(CMD.Tcp.GuildChangeInfo, data)
end

--4038 离会状况
function TeaApi.GuildMemberLeaveState()
    --发送信息
    local data = {
        userId = UserData.GetUserId(),
    }
    SendTcpMsg(CMD.Tcp.LeaveGuildState, data)
end


--4050茶馆列表
function TeaApi.SendTeaList(gameId, isbackGround)
    local data = {
        userId = UserData.GetUserId(),
        gameId = gameId
    }
    SendTcpMsg(CMD.Tcp.GetTeaList, data)
end


--4052快速加入获得推荐房间
function TeaApi.SendQuickJoinRoom(teahouseId, gameId, score, version)
    local data = {
        userId = UserData.GetUserId(),
        teahouseId = teahouseId,
        gameId = gameId,
        version = version,
        score = score,
    }
    SendTcpMsg(CMD.Tcp.TeaQuickMatch, data)
end

--4054 获得一键开房配置
function TeaApi.SendGetAkeyCreateConfig(gameId, teahouseId, score)
    local data = {
        userId = UserData.GetUserId(),
        teahouseId = teahouseId,
        gameId = gameId,
        score = score,
    }
    SendTcpMsg(CMD.Tcp.GetAkeyRoomConfig, data)
end

--4056 修改一键开房功能
function TeaApi.SendEditorAkeyConfig(teahouseId, gameId, configId, ruleBean)
    local data = {
        userId = UserData.GetUserId(),
        teahouseId = teahouseId,
        gameId = gameId,
        ruleBean = ruleBean,
        configId = configId
    }
    SendTcpMsg(CMD.Tcp.EditorAkeyCreateConfig, data)
end

--游戏底分开关  isopen:0关闭    1开启
function TeaApi.SendBaseScoreOpenOrClose(teahouseId, gameId, score, isopen)
    local data = {
        userId = UserData.GetUserId(),
        teahouseId = teahouseId,
        gameId = gameId,
        score = score,
        isopen = isopen,
    }
    SendTcpMsg(CMD.Tcp.BaseCoreOpenOrClose, data)
end

-- 4060 
function TeaApi.SendChangeTeaName(name, teahouseId)
    local data = {
        userId = UserData.GetUserId(),
        teahouseId = teahouseId,
        newName = name,
    }
    SendTcpMsg(CMD.Tcp.ChangeTeaName, data)
end

--4066 游戏开启或打烊操作 0打烊 1开启
function TeaApi.SendGameOnOrOffOperate(gameId, teahouseId, isopen)
    local data = {
        userId = UserData.GetUserId(),
        teahouseId = teahouseId,
        gameId = gameId,
        isopen = isopen,
    }
    SendTcpMsg(CMD.Tcp.GameOnOrOff, data)
end

-- 4068 获取所有游戏打烊还是开启
function TeaApi.SendGetGameOnOrOff(teahouseId)
    local data = {
        userId = UserData.GetUserId(),
        teahouseId = teahouseId,
    }
    SendTcpMsg(CMD.Tcp.GameState, data)
end

--4070 茶馆信息
function TeaApi.SendTeaInfo(isbackGround)
    local data = {
        userId = UserData.GetUserId(),
        guildId = UserData.GetGuildId(),
    }
    Log("=========请求茶馆信息", isbackGround)
    SendTcpMsg(CMD.Tcp.TeaInfo, data)
end

--4204 联盟邀请茶馆加入
function TeaApi.SendInviteTeaJoin(teahouseId, unionId)
    local data = {
        userId = UserData.GetUserId(),
        teahouseId = teahouseId,
        unionId = unionId,
    }
    SendTcpMsg(CMD.Tcp.UnionInviteTea, data)
end

--4206 获取联盟或茶馆邀请记录
function TeaApi.SendGetUnionOrTeaInviteRecord(groupId, pageIndex)
    local data = {
        userId = UserData.GetUserId(),
        groupId = groupId,
        pageIndex = pageIndex,
    }
    SendTcpMsg(CMD.Tcp.InviteRecord, data)
end

--4208 茶馆处理邀请
function TeaApi.SendDealUnionOrTeaInvite(teahouseId, unionId, operType)
    local data = {
        userId = UserData.GetUserId(),
        teahouseId = teahouseId,
        unionId = unionId,
        operType = operType,
    }
    SendTcpMsg(CMD.Tcp.DealInvite, data)
end

--4210 解除联盟
function TeaApi.SendRemoveUnion(teahouseId, unionId, isKickOut)
    local data = {
        userId = UserData.GetUserId(),
        teahouseId = teahouseId,
        unionId = unionId,
        isKickOut = isKickOut,
    }
    SendTcpMsg(CMD.Tcp.RemoveUnion, data)
end

--4212 联盟成员列表
function TeaApi.SendUnionMemberList(unionId, pageIndex, teahouseId)
    local data = {
        userId = UserData.GetUserId(),
        pageIndex = pageIndex,
        unionId = unionId,
        teahouseId = teahouseId,
    }
    SendTcpMsg(CMD.Tcp.UnionMember, data)
end

function TeaApi.SendKickOutGuildMember(kickPlayerId)
    local data = {
        userId = UserData.GetUserId(),
        playerId = kickPlayerId,
        guildId = UserData.GetGuildId(),
    }
    SendTcpMsg(CMD.Tcp.KickOutGuildMember, data)
end