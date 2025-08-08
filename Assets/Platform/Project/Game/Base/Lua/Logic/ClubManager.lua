-----------------------------------------协议定义---------------------------------------
CMD.Tcp.Club = {}
-----------------------------------------------原俱乐部接口-----------------------------
--创建俱乐部
CMD.Tcp.Club.C2S_CreateClub = 2001
CMD.Tcp.Club.S2C_CreateClub = 2002
--加入俱乐部
CMD.Tcp.Club.C2S_JoinClub = 2003
CMD.Tcp.Club.S2C_JoinClub = 2004
--获取申请列表
CMD.Tcp.Club.C2S_GetApplyClub = 2007
CMD.Tcp.Club.S2C_GetApplyClub = 2008

--获取俱乐部列表
CMD.Tcp.Club.C2S_GetClubList = 2015
CMD.Tcp.Club.S2C_GetClubList = 2016

--
CMD.Game.Club = {}
CMD.Game.Club.OnJoinClubClear = 'OnJoinClubClear'
------------------------------------------------------------------------------------------


--申请加入
CMD.Tcp.Club.C2S_ApplyJoinClub = 2003
CMD.Tcp.Club.S2C_ApplyJoinClub = 2004

--获取俱乐部信息
CMD.Tcp.Club.C2S_GetClubInfo = 2023
CMD.Tcp.Club.S2C_GetClubInfo = 2024

--申请加入俱乐部列表
CMD.Tcp.Club.C2S_GetClubApplyList = 2007
CMD.Tcp.Club.S2C_GetClubApplyList = 2008

--处理申请审核
CMD.Tcp.Club.C2S_DealApply = 2005
CMD.Tcp.Club.S2C_DealApply = 2006

--俱乐部成员列表
CMD.Tcp.Club.C2S_GetClubMemberList = 2009
CMD.Tcp.Club.S2C_GetClubMemberList = 2010

--冻结解冻
CMD.Tcp.Club.C2S_FreezeMember = 2029
CMD.Tcp.Club.S2C_FreezeMember = 2030

--设为管理员或者普通成员
CMD.Tcp.Club.C2S_SetMemberRole = 2013
CMD.Tcp.Club.S2C_SetMemberRole = 2014

--幸运池管理
--成员数据
CMD.Tcp.Club.C2S_LuckyMemberDataList = 2051
CMD.Tcp.Club.S2C_LuckyMemberDataList = 2052
--今日排行
CMD.Tcp.Club.C2S_TodayRankingList = 2035
CMD.Tcp.Club.S2C_TodayRankingList = 2036
--昨日排行
CMD.Tcp.Club.C2S_YestodayRankingList = 2037
CMD.Tcp.Club.S2C_YestodayRankingList = 2038

--个人数据游戏分数变动记录
CMD.Tcp.Club.C2S_GameScoreChangeList = 2041
CMD.Tcp.Club.S2C_GameScoreChangeList = 2042
--个人积分变动记录--todo:应该4061，后端还没改
CMD.Tcp.Club.C2S_LuckyValueChangeList = 4061
CMD.Tcp.Club.S2C_LuckyValueChangeList = 4062

--合伙人
--获取合伙人列表
CMD.Tcp.Club.C2S_GetPartnerList = 2021
CMD.Tcp.Club.S2C_GetPartnerList = 2022


--邀请成员玩家
CMD.Tcp.Club.C2S_InviteMember = 2055
CMD.Tcp.Club.S2C_InviteMember = 2056

--清除合作积分
CMD.Tcp.Club.C2S_ClearCooperationScore = 2053
CMD.Tcp.Club.S2C_ClearCooperationScore = 2054

--调整比例
CMD.Tcp.Club.C2S_AdjustPartnerPercent = 4089
CMD.Tcp.Club.S2C_AdjustPartnerPercent = 4090

--俱乐部设置
--获取俱乐部设置
CMD.Tcp.Club.C2S_GetClubSetting = 4065
CMD.Tcp.Club.S2C_GetClubSetting = 4066
--设置俱乐部设置
CMD.Tcp.Club.C2S_SetClubSetting = 2027
CMD.Tcp.Club.S2C_SetClubSetting = 2028

--桌子相关接口
--获取桌子列表
CMD.Tcp.Club.C2S_GetTableList = 2017
CMD.Tcp.Club.S2C_GetTableList = 2018
--刷新桌子信息
CMD.Tcp.Club.C2S_RefreshTables = 4031
CMD.Tcp.Club.S2C_RefreshTables = 4032
--创建桌子
CMD.Tcp.Club.C2S_CreateTable = 2011
CMD.Tcp.Club.S2C_CreateTable = 2012
--删除桌子
CMD.Tcp.Club.C2S_DeleteTable = 2019
CMD.Tcp.Club.S2C_DeleteTable = 2020
--修改桌子
CMD.Tcp.Club.C2S_ModifyTable = 4027
CMD.Tcp.Club.S2C_ModifyTable = 4028
--加入桌子
CMD.Tcp.Club.C2S_JoinTable = 2031
CMD.Tcp.Club.S2C_JoinTable = 2032

--俱乐部公告
CMD.Tcp.Club.C2S_ClubNotice = 4009
CMD.Tcp.Club.S2C_ClubNotice = 4010

--赠送积分
CMD.Tcp.Club.C2S_DonateLuckyValue = 4009
CMD.Tcp.Club.S2C_DonateLuckyValue = 4010

-------------小黑屋-----------------
--小黑屋列表
CMD.Tcp.Club.C2S_BlackRoomList = 2047
CMD.Tcp.Club.S2C_BlackRoomList = 2048
--绑定
CMD.Tcp.Club.C2S_BlackRoomBind = 2045
CMD.Tcp.Club.S2C_BlackRoomBind = 2046
----------------------------------------------------------------------------------------
ClubManager = {}
local this = ClubManager

function ClubManager.Open(groupId, gameType)
    this.Init()
    PanelManager.Open(PanelConfig.ClubEnter, groupId, gameType)
end

function ClubManager.Close()
    this.Uninit()
    PanelManager.Close(PanelConfig.ClubEnter)
    BaseTcpApi.SendEnterModule(ModuleType.Club)
end

function ClubManager.Init()
    AddMsg(CMD.Tcp.Club.S2C_CreateClub, this.OnTcpCreateClub)
    AddMsg(CMD.Tcp.Club.S2C_GetClubList, this.OnTcpGetClubsList)
    AddMsg(CMD.Tcp.Club.S2C_ApplyJoinClub, this.OnTcpApplyJoinClub)
    AddMsg(CMD.Tcp.Club.S2C_GetClubInfo, this.OnTcpGetClubInfo)
    AddMsg(CMD.Tcp.Club.S2C_DealApply, this.OnTcpDealApply)
    AddMsg(CMD.Tcp.Club.S2C_GetClubApplyList, this.OnTcpGetClubApplyList)
    AddMsg(CMD.Tcp.Club.S2C_GetClubMemberList, this.OnTcpGetClubMemberList)
    AddMsg(CMD.Tcp.Club.S2C_FreezeMember, this.OnTcpFreezeMember)
    AddMsg(CMD.Tcp.Club.S2C_SetMemberRole, this.OnTcpSetMemberRole)
    AddMsg(CMD.Tcp.Club.S2C_LuckyMemberDataList, this.OnTcpGetLuckyMemberList)
    AddMsg(CMD.Tcp.Club.S2C_TodayRankingList, this.OnTcpGetTodayRankingList)
    AddMsg(CMD.Tcp.Club.S2C_YestodayRankingList, this.OnTcpGetYestodayRankingList)
    AddMsg(CMD.Tcp.Club.S2C_GameScoreChangeList, this.OnTcpGameScoreChangeList)
    AddMsg(CMD.Tcp.Club.S2C_LuckyValueChangeList, this.OnTcpLuckyValueChangeList)
    AddMsg(CMD.Tcp.Club.S2C_GetPartnerList, this.OnTcpGetPartnerList)
    AddMsg(CMD.Tcp.Club.S2C_InviteMember, this.OnTcpAddCommonMember)
    AddMsg(CMD.Tcp.Club.S2C_ClearCooperationScore, this.OnTcpClearCooperationScore)
    AddMsg(CMD.Tcp.Club.S2C_AdjustPartnerPercent, this.OnTcpAdjustPartnerPercent)
    AddMsg(CMD.Tcp.Club.S2C_GetClubSetting, this.OnTcpGetClubSetting)
    AddMsg(CMD.Tcp.Club.S2C_SetClubSetting, this.OnTcpSetClubSetting)
    --桌子相关接口
    AddMsg(CMD.Tcp.Club.S2C_GetTableList, this.OnTcpGetTableList)
    AddMsg(CMD.Tcp.Club.S2C_RefreshTables, this.OnTcpRefreshTables)
    AddMsg(CMD.Tcp.Club.S2C_CreateTable, this.OnTcpCreateTable)
    AddMsg(CMD.Tcp.Club.S2C_DeleteTable, this.OnTcpDeleteTable)
    AddMsg(CMD.Tcp.Club.S2C_ModifyTable, this.OnTcpModifyTable)
    AddMsg(CMD.Tcp.Club.S2C_JoinTable, this.OnTcpJoinTable)
    --------------------------------------------------------------

    AddMsg(CMD.Tcp.Club.S2C_ClubNotice, this.OnTcpGetClubNotice)

    AddMsg(CMD.Tcp.S2C_DonateLuckyValue, this.OnTcpDonateLuckValue)

    AddMsg(CMD.Tcp.Club.S2C_BlackRoomList, this.OnTcpBlackRoomList)
    AddMsg(CMD.Tcp.Club.S2C_BlackRoomBind, this.OnTcpBlackRoomBind)
end

function ClubManager.Uninit()
    RemoveMsg(CMD.Tcp.Club.S2C_CreateClub, this.OnTcpCreateClub)
    RemoveMsg(CMD.Tcp.Club.S2C_GetClubList, this.OnTcpGetClubsList)
    RemoveMsg(CMD.Tcp.Club.S2C_ApplyJoinClub, this.OnTcpApplyJoinClub)
    RemoveMsg(CMD.Tcp.Club.S2C_GetClubMemberList, this.OnTcpGetClubMemberList)
    RemoveMsg(CMD.Tcp.Club.S2C_DealApply, this.OnTcpDealApply)
    RemoveMsg(CMD.Tcp.Club.S2C_GetClubApplyList, this.OnTcpGetClubApplyList)
    RemoveMsg(CMD.Tcp.Club.S2C_FreezeMember, this.OnTcpFreezeMember)
    RemoveMsg(CMD.Tcp.Club.S2C_SetMemberRole, this.OnTcpSetMemberRole)
    RemoveMsg(CMD.Tcp.Club.S2C_LuckyMemberDataList, this.OnTcpGetLuckyMemberList)
    RemoveMsg(CMD.Tcp.Club.S2C_TodayRankingList, this.OnTcpGetTodayRankingList)
    RemoveMsg(CMD.Tcp.Club.S2C_YestodayRankingList, this.OnTcpGetYestodayRankingList)
    RemoveMsg(CMD.Tcp.Club.S2C_GameScoreChangeList, this.OnTcpGameScoreChangeList)
    RemoveMsg(CMD.Tcp.Club.S2C_LuckyValueChangeList, this.OnTcpLuckyValueChangeList)
    RemoveMsg(CMD.Tcp.Club.S2C_GetPartnerList, this.OnTcpGetPartnerList)
    RemoveMsg(CMD.Tcp.Club.S2C_InviteMember, this.OnTcpAddCommonMember)
    RemoveMsg(CMD.Tcp.Club.S2C_ClearCooperationScore, this.OnTcpClearCooperationScore)
    RemoveMsg(CMD.Tcp.Club.S2C_AdjustPartnerPercent, this.OnTcpAdjustPartnerPercent)
    RemoveMsg(CMD.Tcp.Club.S2C_GetClubSetting, this.OnTcpGetClubSetting)
    RemoveMsg(CMD.Tcp.Club.S2C_SetClubSetting, this.OnTcpSetClubSetting)
    --桌子相关接口
    RemoveMsg(CMD.Tcp.Club.S2C_GetTableList, this.OnTcpGetTableList)
    RemoveMsg(CMD.Tcp.Club.S2C_RefreshTables, this.OnTcpRefreshTables)
    RemoveMsg(CMD.Tcp.Club.S2C_CreateTable, this.OnTcpCreateTable)
    RemoveMsg(CMD.Tcp.Club.S2C_DeleteTable, this.OnTcpDeleteTable)
    RemoveMsg(CMD.Tcp.Club.S2C_ModifyTable, this.OnTcpModifyTable)
    RemoveMsg(CMD.Tcp.Club.S2C_JoinTable, this.OnTcpJoinTable)
    --------------------------------------------------------------

    RemoveMsg(CMD.Tcp.Club.S2C_ClubNotice, this.OnTcpGetClubNotice)

    RemoveMsg(CMD.Tcp.S2C_DonateLuckyValue, this.OnTcpDonateLuckValue)

    RemoveMsg(CMD.Tcp.Club.S2C_BlackRoomList, this.OnTcpBlackRoomList)
    RemoveMsg(CMD.Tcp.Club.S2C_BlackRoomBind, this.OnTcpBlackRoomBind)
end

function ClubManager.ShowError(errorCode)
    local errString = ClubErrorDefine[errorCode]
    if string.IsNullOrEmpty(errString) then
        Toast.Show("俱乐部异常")
    else
        Toast.Show(errString)
    end
end

-----------------------------------------创建俱乐部----------------------------------------
-----发送创建俱乐部
function ClubManager.SendCreateClub(clubName, playerId)
    local data = {
        userId = UserData.GetUserId(),
        clubName = clubName,
        tgPlayerId = playerId
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_CreateClub, data)
end

--创建俱乐部回复
function ClubManager.OnTcpCreateClub(data)
    if data.code == 0 then
        Toast.Show("创建俱乐部成功")
        PanelManager.Close(PanelConfig.ClubCreate)
        this.SendGetClubList()
    else
        this.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------

-----------------------------------------获取俱乐部列表---------------------------------------
function ClubManager.SendGetClubList()
    SendTcpMsg(CMD.Tcp.Club.C2S_GetClubList, {})
end

function ClubManager.OnTcpGetClubsList(data)
    Log("获取俱乐部列表", PanelManager.IsOpened(PanelConfig.ClubEnter))
    if data.code == 0 then
        ClubData.ParseClubList(data.data)
        if PanelManager.IsOpened(PanelConfig.ClubEnter) then
            ClubEnterPanel.UpdateClubList()
        end
    else
        this.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------
-----------------------------------------获取俱乐部列表------------------------------------------
function ClubManager.SendApplyJoinClub(key)
    SendTcpMsg(CMD.Tcp.Club.C2S_ApplyJoinClub, { inviteNum = key, type = 2 })
end

function ClubManager.OnTcpApplyJoinClub(data)
    if data.code == 0 then
        Toast.Show("申请加入成功")
        this.SendGetClubList()
        PanelManager.Close(PanelConfig.ClubInputNumber)
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------

-----------------------------------------获取俱乐部信息------------------------------------------
function ClubManager.SendGetClubInfo(clubId)
    SendTcpMsg(CMD.Tcp.Club.C2S_GetClubInfo, { clubId = clubId })
end
function ClubManager.OnTcpGetClubInfo(data)
    if data.code == 0 then
        ClubData.ParseClubData(data.data)
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------


-----------------------------------------获取俱乐部成员列表--------------------------------------
---pageIdx:页面，从1开始
function ClubManager.SendGetClubMemberList(pageIdx, searchUid)
    if searchUid == nil then
        searchUid = 0
    end
    local clubId = ClubData.curClubId
    local args = {
        clubId = clubId,
        playerId = searchUid,
        num = ClubApplyCountPerPage,
        page = pageIdx
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_GetClubMemberList, args)
end

function ClubManager.OnTcpGetClubMemberList(data)
    if data.code == 0 then
        ClubData.ParseMemberList(data.data)
        if PanelManager.IsOpened(PanelConfig.ClubMember) then
            ClubMemberPanel.UpdateMemberList()
        end
        if PanelManager.IsOpened(PanelConfig.ClubBlackRoomMember) then
            ClubBlackRoomMemberPanel.UpdateMemberList()
        end
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------
-----------------------------------------获取俱乐部申请列表--------------------------------------
---pageIdx:页面，从1开始   searchUid:查询的玩家Id
function ClubManager.SendGetClubApplyList(pageIdx, searchUid)
    if searchUid == nil then
        searchUid = 0
    end
    local clubId = ClubData.curClubId
    local args = {
        clubId = clubId,
        playerId = searchUid,
        num = ClubApplyCountPerPage,
        page = pageIdx
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_GetClubApplyList, args)
end

function ClubManager.OnTcpGetClubApplyList(data)
    if data.code == 0 then
        ClubData.ParseApplyList(data.data)
        if PanelManager.IsOpened(PanelConfig.ClubMember) then
            ClubMemberPanel.UpdateApplyList()
        end
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------
---
-------------------------------------------------冻结解冻--------------------------------------
---0冻结1解冻
function ClubManager.SendFreezeMember(uid, opType)
    local ClubData = ClubData.curClubId
    local args = {
        clubId = ClubData,
        keyId = uid,
        option = opType
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_FreezeMember, args)
end

function ClubManager.OnTcpFreezeMember(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.ClubMember) then
            ClubMemberPanel.SendGetMemberList(0)
        end
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------
-------------------------------------------------设置身份--------------------------------------
---设置玩家身份
function ClubManager.SendSetMemberRole(uid, role)
    local ClubData = ClubData.curClubId
    local args = {
        clubId = ClubData,
        keyId = uid,
        option = role
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_SetMemberRole, args)
end

function ClubManager.OnTcpSetMemberRole(data)
    if data.code == 0 then
        if data.data.option == 1 then
            Toast.Show("设置成功")
            if PanelManager.IsOpened(PanelConfig.ClubPartner) then
                ClubPartnerPanel.UpdateCurPanel()
            end
            if PanelManager.IsOpened(PanelConfig.ClubLowerMember) then
                ClubLowerMemberPanel.UpdateCurPanel()
            end
        else
            if PanelManager.IsOpened(PanelConfig.ClubMember) then
                ClubMemberPanel.SendGetMemberList(0)
            end
        end
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------

-------------------------------------------------处理加入申请----------------------------------
---opType:0同意 1拒绝 2踢人
function ClubManager.SendDealApply(uid, opType)
    local ClubData = ClubData.curClubId
    local args = {
        clubId = ClubData,
        keyId = uid,
        type = opType
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_DealApply, args)
end

function ClubManager.OnTcpDealApply(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.ClubMember) then
            ClubMemberPanel.SendGetApplyList(ClubMemberPanel.curApplyGetPage)
        end
        BaseTcpApi.SendGetRedPointInfo()
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------

-------------------------------------------------幸运池成员数据----------------------------------
function ClubManager.SendGetLuckyMemberList(page, searchUid)
    if searchUid == nil then
        searchUid = 0
    end
    local args = {
        clubId = ClubData.curClubId,
        playerId = searchUid,
        num = 5,
        page = page
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_LuckyMemberDataList, args)
end

function ClubManager.OnTcpGetLuckyMemberList(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.ClubLuckyValueManage) then
        ClubLuckyValueManagePanel.UpdateMemberDataList(data.data)
        end
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------

----------------------------------------------------幸运池今日排行-----------------------------
function ClubManager.SendGetTodayRankingList(page)
    local args = {
        clubId = ClubData.curClubId,
        playerId = 0,
        rankKey = 0,
        num = 5,
        page = page
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_TodayRankingList, args)
end

function ClubManager.OnTcpGetTodayRankingList(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.ClubLuckyValueManage) then
            ClubLuckyValueManagePanel.UpdateTodayRankingList(data.data)
        end
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------
---
-------------------------------------------------------幸运池昨日排行-----------------------------
function ClubManager.SendGetYestodayRankingList(page)
    local args = {
        clubId = ClubData.curClubId,
        playerId = 0,
        rankKey = 0,
        num = 5,
        page = page
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_YestodayRankingList, args)
end

function ClubManager.OnTcpGetYestodayRankingList(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.ClubLuckyValueManage) then
        ClubLuckyValueManagePanel.UpdateYestodayRankingList(data.data)
        end
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------

-------------------------------------------------------游戏积分变动-----------------------------
function ClubManager.SendGameScoreChangeList(page, uid)
    local args = {
        clubId = ClubData.curClubId,
        playerId = uid,
        rankKey = 0,
        num = 7,
        page = page
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_GameScoreChangeList, args)
end

function ClubManager.OnTcpGameScoreChangeList(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.ClubPersonalData) then
            ClubPersonalDataPanel.UpdateGameChangeDataList(data.data)
        end
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------


-------------------------------------------------------积分变动-----------------------------
function ClubManager.SendLuckyValueChangeList(page, uid)
    local args = {
        clubId = ClubData.curClubId,
        playerId = uid,
        rankKey = 0,
        num = 7,
        page = page
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_LuckyValueChangeList, args)
end

function ClubManager.OnTcpLuckyValueChangeList(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.ClubPersonalData) then
            ClubPersonalDataPanel.UpdateLuckyValueChangeDataList(data.data)
        end
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------

-------------------------------------------------------获取合伙人列表--------------------------------
--opType:1下属合伙人2下属玩家
--getUid:获取玩家下属相关
local curGetPartnerUid = 0
function ClubManager.SendGetPartnerList(opType, getUid, pageIdx, searchId)
    if searchId == nil then
        searchId = 0
    end
    local args = {
        clubId = ClubData.curClubId,
        getId = getUid,
        opType = opType,
        num = 4,
        page = pageIdx,
        playerId = searchId,
    }
    curGetPartnerUid = getUid
    SendTcpMsg(CMD.Tcp.Club.C2S_GetPartnerList, args)
end

function ClubManager.OnTcpGetPartnerList(data)
    if data.code == 0 then
        data = data.data
        Log("===============>OnTcpGetPartnerList", curGetPartnerUid, PanelManager.IsOpened(PanelConfig.ClubLowerMember))
        --获取下属合伙人
        if data.opType == 1 then
            if curGetPartnerUid == UserData.GetUserId() then
                if PanelManager.IsOpened(PanelConfig.ClubPartner) then
                    ClubPartnerPanel.UpdateDataList(data)
                end
                if PanelManager.IsOpened(PanelConfig.ClubLowerPartner) then
                    ClubLowerPartnerPanel.UpdateDataList(data)
                end
            end
        else
            if PanelManager.IsOpened(PanelConfig.ClubLowerMember) then
                ClubLowerMemberPanel.UpdateDataList(data)
            end
        end
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------


-------------------------------------------------------添加合伙人--------------------------------
function ClubManager.SendAddPartnerMember(addUid)
    local args = {
        clubId = ClubData.curClubId,
        addPlayerId = addUid,
    }
    this.SendSetMemberRole(addUid, ClubRole.Partner)
end
----------------------------------------------------------------------------------------------------

-------------------------------------------------------添加普通玩家--------------------------------
function ClubManager.SendAddCommonMember(addUid)
    local args = {
        clubId = ClubData.curClubId,
        playerId = addUid,
        exclusiveKey = ClubData.GetClubInfo().key
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_InviteMember, args)
end

function ClubManager.OnTcpAddCommonMember(data)
    if data.code == 0 then
        Toast.Show("邀请成功")
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------


-------------------------------------------------------清除合作积分--------------------------------
function ClubManager.SendClearCooperationScore()
    local args = {
        clubId = ClubData.curClubId,
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_ClearCooperationScore, args)
end

function ClubManager.OnTcpClearCooperationScore(data)
    if data.code == 0 then
        Toast.Show("清除合作积分成功")
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------

-------------------------------------------------------调整合伙人比例--------------------------------
function ClubManager.SendAdjustPartnerPercent(uid, percent)
    local args = {
        clubId = ClubData.curClubId,
        playerId = uid,
        per = percent
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_AdjustPartnerPercent, args)
end

function ClubManager.OnTcpAdjustPartnerPercent(data)
    if data.code == 0 then
        Toast.Show("比例调整成功")
        PanelManager.Close(PanelConfig.ClubPartnerPercentChange, true)
        if PanelManager.IsOpened(PanelConfig.ClubPartner) then
            ClubPartnerPanel.UpdateCurPanel()
        end
        if PanelManager.IsOpened(PanelConfig.ClubLowerPartner) then
            ClubLowerPartner.UpdateCurPanel()
        end
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------


-------------------------------------------------------获取俱乐部设置--------------------------------
function ClubManager.SendGetClubSetting()
    local args = {
        clubId = ClubData.curClubId,
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_GetClubSetting, args)
end

function ClubManager.OnTcpGetClubSetting(data)
    if data.code == 0 then
        ClubData.ParseClubSetting(data.data)
        if PanelManager.IsOpened(PanelConfig.ClubSetting) then
            ClubSettingPanel.UpdatePanel()
        end
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------


-------------------------------------------------------设置俱乐部设置--------------------------------
local settingData = nil
function ClubManager.SendSetClubSetting(isOpenShenHe, isOpenYinSi, isOpenDaYang, title, notice)
    settingData = {
        clubId = ClubData.curClubId,
        isApply = isOpenShenHe,
        isPrivacy = isOpenYinSi,
        isOff = isOpenDaYang,
        clubName = title,
        notice = notice
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_SetClubSetting, settingData)
end

function ClubManager.OnTcpSetClubSetting(data)
    if data.code == 0 then
        ClubData.ParseClubSetting(settingData)
        Toast.Show("设置成功")
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------


-------------------------------------------------------获取俱乐部桌子列表--------------------------------
function ClubManager.SendGetTableList(gameId, page)
    local args = {
        clubId = ClubData.curClubId,
        num = ClubTableCountPerPage,
        page = page,
        gameId = gameId,
        moneyType = ClubData.curTableMoneyType
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_GetTableList, args)
    --Log("SendGetTableList：暂时屏蔽发送")
end

function ClubManager.OnTcpGetTableList(data)
    if data.code == 0 then
        ClubData.ParseTableList(data.data)
        if PanelManager.IsOpened(PanelConfig.ClubRoom) then
            ClubRoomPanel.UpdateTableList()
        end
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------

-------------------------------------------------------刷新俱乐部桌子------------------------------------
function ClubManager.SendRefreshTables(gameId, tableIds)
    local args = {
        clubId = ClubData.curClubId,
        num = 12,
        tableIds = tableIds
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_RefreshTables, args)
end

function ClubManager.OnTcpRefreshTables(data)
    if data.code == 0 then
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------

-------------------------------------------------------创建俱乐部桌子------------------------------------
function ClubManager.SendCreateTable(gameId, playType, rules, maxjs, maxUserNum, baseScore, inGold, fkConfigId)
    local args = {
        clubId = ClubData.curClubId,
        gameId = gameId,
        gameType = playType,
        rules = rules,
        maxjs = maxjs,
        maxNum = maxUserNum,
        score = baseScore,
        inGold = inGold,
        moneyType = ClubData.curTableMoneyType,
        fkId = fkConfigId
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_CreateTable, args)
end

function ClubManager.OnTcpCreateTable(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.ClubRoom) then
            ClubRoomPanel.InitScrollExt()
            ClubRoomPanel.SendGetTableList(0)
        end
        PanelManager.Close(PanelConfig.CreateRoom)
        Toast.Show("创建桌子成功")
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------

-------------------------------------------------------删除俱乐部桌子------------------------------------
local deleteTableGameType = GameType.None
function ClubManager.SendDeleteTable(gameId, tableId)
    local args = {
        clubId = ClubData.curClubId,
        gameId = gameId,
        tId = tableId,
    }
    deleteTableGameType = gameId
    SendTcpMsg(CMD.Tcp.Club.C2S_DeleteTable, args)
end

function ClubManager.OnTcpDeleteTable(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.ClubRoom) then
            ClubRoomPanel.InitScrollExt()
            ClubRoomPanel.SendGetTableList(0)
        end
        PanelManager.Close(PanelConfig.ClubRule)
        Toast.Show("删除桌子成功")
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------

-------------------------------------------------------修改俱乐部桌子------------------------------------
local curModifyTableGameType = GameType.None
function ClubManager.SendModifyTable(gameId, tableId, playType, rules, maxjs, maxUserNum, baseScore, inGold, fkConfigId)
    local args = {
        clubId = ClubData.curClubId,
        tId = tableId,
        gameId = gameId,
        gameType = playType,
        rules = rules,
        maxjs = maxjs,
        maxNum = maxUserNum,
        score = baseScore,
        inGold = inGold,
        fkId = fkConfigId
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_ModifyTable, args)
end

function ClubManager.OnTcpModifyTable(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.ClubRoom) then
            ClubRoomPanel.InitScrollExt()
            ClubRoomPanel.SendGetTableList(0)
        end
        PanelManager.Close(PanelConfig.ClubRule)
        PanelManager.Close(PanelConfig.CreateRoom)
        Toast.Show("修改桌子成功")
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------

-------------------------------------------------------创建俱乐部桌子------------------------------------
function ClubManager.SendJoinTable(gameId, tableId)
    local args = {
        clubId = ClubData.curClubId,
        tId = tableId,
        gameId = gameId,
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_JoinTable, args)
end

function ClubManager.OnTcpJoinTable(data)
    if data.code == 0 then
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------


-------------------------------------------------------俱乐部公告------------------------------------
function ClubManager.SendGetClubNotice()
    local args = {
        clubId = ClubData.curClubId,
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_ClubNotice, args)
end

function ClubManager.OnTcpGetClubNotice(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.ClubNotice) then
            ClubNoticePanel.SetClubNotice(data.data.ClubNotice)
        end
    else
        ClubManager.ShowError(data.code)
    end
end
----------------------------------------------------------------------------------------------------

----------------------------------------------------赠送积分成功-------------------------------------
function ClubManager.OnTcpDonateLuckValue(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.ClubRoom) then
            ClubRoomPanel.UpdatePersonalInfo()
        end
    end
end
----------------------------------------------------小黑屋--------------------------------------------
--小黑屋列表
function ClubManager.SendGetBlackRoomList(page, playerId)
    local args = {
        clubId = ClubData.curClubId,
        page = page,
        playerId = playerId,
        num = ClubBlackRoomCountPerPage,
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_BlackRoomList, args)
end

function ClubManager.OnTcpBlackRoomList(data)
    if data.code == 0 then
        if PanelManager.IsOpened(PanelConfig.ClubBlackRoom) then
            ClubBlackRoomPanel.UpdateBindList(data.data)
        end
    else
        ClubManager.ShowError(data.code)
    end
end

--绑定
function ClubManager.SendBlackRoomBind(option, playerId1, playerId2)
    local args = {
        clubId = ClubData.curClubId,
        option = option,
        firstId = playerId1,
        secondId = playerId2,
    }
    SendTcpMsg(CMD.Tcp.Club.C2S_BlackRoomBind, args)
end

function ClubManager.OnTcpBlackRoomBind(data)
    if data.code == 0 then
        Toast.Show("操作成功")
        if PanelManager.IsOpened(PanelConfig.ClubBlackRoom) then
            ClubBlackRoomPanel.SendGetBlackRoomList(1)
        end
    else
        ClubManager.ShowError(data.code)
    end
end
------------------------------------------------------------------------------------------------------------
return ClubManager