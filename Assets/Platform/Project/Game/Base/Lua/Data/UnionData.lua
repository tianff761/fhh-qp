UnionData = {}
--大联盟列表
UnionData.unionList = nil
--当前进入的大联盟成员列表
UnionData.unionMemberList = nil
UnionData.totalMemberCount = 0

--当前进入的大联盟加入申请列表列表
UnionData.unionApplyList = nil
UnionData.totalApplyCount = 0

--当前进入联盟Id
UnionData.curUnionId = nil
--当前自己在联盟的身份
UnionData.selfRole = UnionRole.Common

--玩家名片数据
UnionData.myName = ""
UnionData.myUid = 0
UnionData.myHeadIcon = 0
UnionData.myWebchat = ""
UnionData.myQQ = ""
UnionData.myKeyCode = ""

--上级玩家名片数据
UnionData.superiorName = ""
UnionData.superiorUid = 0
UnionData.superiorHeadIcon = 0
UnionData.superiorWebchat = ""
UnionData.superiorQQ = ""
UnionData.superiorKeyCode = ""

--名片类型
UnionData.memberCardType = 0

--联盟设置数据
UnionData.isOpenShenHe = false
UnionData.isOpenYinSi = false
UnionData.isOpenDaYang = false
UnionData.unionTitle = ""
UnionData.unionNotice = ""
UnionData.showTableNum = nil

--联盟桌子数据
UnionData.unionTableList = nil
UnionData.totalTableCount = 0

--战绩搜索
UnionData.searchType = 1
UnionData.searchId = ""

UnionData.UnionNotice = ""
--背景样式
UnionData.bgStyle = nil

--是否有保底
UnionData.isBaodi = false

local UnionStyleConfig = {
    {name = "幽静庭院", src = "bg-union-1"},
    {name = "塞外客栈", src = "bg-union-2"},
    {name = "繁华都市", src = "bg-union-3"},
    {name = "英雄擂台", src = "bg-union-3"}
}

local this = UnionData
function UnionData.SetCurUnionId(unionId)
    this.curUnionId = unionId
    --LogError("this.unionList", this.unionList)
    LogError(">> UnionData.SetCurUnionId > ", unionId)
    for _, unionInfo in pairs(this.unionList) do
        if unionInfo.id == unionId then
            this.selfRole = unionInfo.role
            return true
        end
    end
    return false
end

---是否是联盟盟主
function UnionData.IsUnionLeader()
    return this.selfRole == UnionRole.Leader
end

---是否联盟盟主或管理员
function UnionData.IsUnionLeaderOrAdministrator()
    return this.selfRole == UnionRole.Leader or this.selfRole == UnionRole.Admin
end

function UnionData.IsUnionLeaderOrAdministratorOrObserver()
    return this.selfRole == UnionRole.Leader or this.selfRole == UnionRole.Admin or this.selfRole == UnionRole.Observer
end

function UnionData.IsUnionAdministrator()
    return this.selfRole == UnionRole.Admin
end

function UnionData.IsUnionAdministratorOrObserver()
    return this.selfRole == UnionRole.Admin or this.selfRole == UnionRole.Observer
end

function UnionData.IsUnionCommonPlayer()
    return this.selfRole == UnionRole.Common
end

function UnionData.IsUnionPartner()
    return this.selfRole == UnionRole.Partner
end

---是否 “非”普通玩家
function UnionData.IsNotCommonPlayer()
    return this.selfRole == UnionRole.Leader or this.selfRole == UnionRole.Admin or this.selfRole == UnionRole.Partner or this.selfRole == UnionRole.Observer
end

function UnionData.ParseUnionList(data)
    this.unionList = {}
    if data.list ~= nil then
        local union = nil
        for _, unionItem in pairs(data.list) do
            union = {
                --Id
                id = unionItem.unionId,
                --名称
                name = unionItem.unionName,
                --联盟专属码
                key = unionItem.exclusiveKey,
                --桌子数量
                tableNum = unionItem.unionTableNum,
                --玩家身份 UnionRole定义
                role = unionItem.adminType,
                --盟主Id
                leaderId = unionItem.monsterId,
                --盟主名称
                leaderName = unionItem.monsterName,
                --盟主头像Icon
                leaderHeadIcon = unionItem.monsterIcon,
                --是否开启隐私
                isOpenYinSi = false,
                --当前人数
                playerNum = unionItem.playerNum,
                --总人数
                allNum = unionItem.allNum,
            }
            table.insert(this.unionList, union)
        end
    end
end

function UnionData.ParseUnionData(data)
    for _, unionItem in pairs(this.unionList) do
        if unionItem.id == data.unionId then
            unionItem.isOpenPrivacy = data.openPrivacy == 1
            this.isOpenYinSi = data.openPrivacy == 1
            UserData.SetGold(data.gold);
            UnionRoomPanel.UpdatePersonalInfo();
            break
        end
    end
end

function UnionData.GetUidString(uid)
    if this.isOpenYinSi then
        return Functions.GetPrivacyUid(uid)
    else
        return tostring(uid)
    end
end

function UnionData.GetUnionInfo()
    if this.unionList ~= nil then
        for _, union in pairs(this.unionList) do
            if union.id ~= nil and union.id == this.curUnionId then
                return union
            end
        end
    end
    return nil
end

--解析当前联盟成员数据
function UnionData.ParseMemberList(data)
    if this.unionMemberList == nil then
        this.unionMemberList = {}
    end
    this.totalMemberCount = data.allCount
    local curPage = data.pageIndex
    local list = data.list
    if GetTableSize(list) > 0 then
        for k, item in pairs(list) do
            this.unionMemberList[(curPage - 1) * UnionMemberCountPerPage + k] = {
                uid = item.pId,
                name = item.pName,
                headIcon = item.pIcon,
                lastOnline = item.lastOnline,
                isFreezed = item.isIce == 1,
                isService = item.isCust,
                role = item.aType,
            }
        end

        local tempSize = GetTableSize(this.unionMemberList)
        for i = this.totalMemberCount + 1, tempSize do
            this.unionMemberList[i] = nil
        end
    end
end

--索引从1开始，结构见ParseMemberList中
function UnionData.GetMemberItem(idx)
    return this.unionMemberList[idx]
end

--解析当前联盟申请数据
function UnionData.ParseApplyList(data)
    if this.unionApplyList == nil then
        this.unionApplyList = {}
    end
    this.totalApplyCount = data.allCount
    local curPage = data.pageIndex
    local list = data.list
    if GetTableSize(list) > 0 then
        for k, item in pairs(list) do
            this.unionApplyList[(curPage - 1) * UnionApplyCountPerPage + k] = {
                uid = item.pId,
                name = item.pName,
                headIcon = item.pIcon,
                inviteCode = item.ycode,
            }
        end

        local tempSize = GetTableSize(this.unionApplyList)
        for i = this.totalApplyCount + 1, tempSize do
            this.unionApplyList[i] = nil
        end
    end
end

--获取当前申请数据，索引从1开始，结构见ParseApplyList中
function UnionData.GetApplyItem(idx)
    return this.unionApplyList[idx]
end


--获取当前桌子数据，索引从1开始，结构见ParseTableList中
function UnionData.GetTableItem(idx)
    return this.unionTableList[idx]
end

--解析联盟桌子数据
function UnionData.ParseTableList(data)
    if this.unionTableList == nil then
        this.unionTableList = {}
    end
    this.totalTableCount = data.allCount
    local curPage = data.pageIndex
    local list = data.list
    local itemTable = nil
    if GetTableSize(list) > 0 then
        for k, item in pairs(list) do
            itemTable = {
                id = item.tId,
                rules = JsonToObj(item.rules),
                gameType = item.gameId,
                baseScore = tonumber(item.score),
                inGold = tonumber(item.inGold),
                maxJs = item.maxjs,
                js = item.js,
                maxUserNum = item.maxNum,
                userInfos = {},
            }
            this.unionTableList[(curPage - 1) * UnionTableCountPerPage + k] = itemTable
            if item.players ~= nil then
                for _, userItem in pairs(item.players) do
                    table.insert(itemTable.userInfos, { uid = userItem.uId, name = userItem.uN, headIcon = userItem.uH })
                end
            end
        end

        local tempSize = GetTableSize(this.unionTableList)
        for i = this.totalTableCount + 1, tempSize do
            this.unionTableList[i] = nil
        end
    else
        this.unionTableList = {}
    end
end


--解析玩家名片数据
function UnionData.ParseMemberCardData(data)
    if data ~= nil then
        this.memberCardType = data.opType
        if data.opType ~= nil then
            --我的名片
            if data.opType == 1 then
                this.myUid = data.pId
                this.myName = data.pName
                this.myHeadIcon = data.pIcon
                this.myWebchat = data.chatMsg
                this.myQQ = data.qqMsg
                this.myKeyCode = data.exclusiveKey
                --上级名片
            elseif data.opType == 2 then
                this.superiorUid = data.pId
                this.superiorName = data.pName
                this.superiorHeadIcon = data.pIcon
                this.superiorWebchat = data.chatMsg
                this.superiorQQ = data.qqMsg
                this.superiorKeyCode = data.exclusiveKey
            end
        end
    end
end

--解析玩家设置数据
function UnionData.ParseUnionSetting(data)
    this.isOpenShenHe = data.op_check ~= nil and data.op_check == 1
    this.isOpenYinSi = data.op_privacy ~= nil and data.op_privacy == 1
    this.isOpenDaYang = data.op_close ~= nil and data.op_close == 1
    this.unionTitle = data.op_name
    this.unionNotice = data.op_notice
    this.showTableNum = data.op_num

    local unionInfo = this.GetUnionInfo()
    unionInfo.name = data.op_name
end

--获取背景样式
function UnionData.GetBgStyle()
    if UnionData.bgStyle == nil then
        local temp = GetLocal("UnionBgStyle2", "1")
        UnionData.bgStyle = tonumber(temp) or 1
    end
    if UnionData.bgStyle < 1 then
        UnionData.bgStyle = 1
    elseif UnionData.bgStyle > 4 then
        UnionData.bgStyle = 4
    end
    return UnionData.bgStyle
end

--设置背景样式
function UnionData.SetBgStyle(style)
    UnionData.bgStyle = style
    SetLocal("UnionBgStyle2", style)
end

--获取背景资源名称
function UnionData.GetBgAssetName()
    local index = this.GetBgStyle()
    local config = UnionStyleConfig[index]
    if config ~= nil then
        return config.src
    end
    return nil
end
