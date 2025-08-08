ClubData = {}
--大俱乐部列表
ClubData.clubList = nil
--当前进入的大俱乐部成员列表
ClubData.clubMemberList = nil
ClubData.totalMemberCount = 0
ClubData.totalMemberPage = 0

--当前进入的大俱乐部加入申请列表列表
ClubData.clubApplyList = nil
ClubData.totalApplyCount = 0

--当前进入俱乐部Id
ClubData.curClubId = nil
--当前自己在俱乐部的身份
ClubData.selfRole = ClubRole.Member

--玩家名片数据
ClubData.myName = ""
ClubData.myUid = 0
ClubData.myHeadIcon = 0
ClubData.myWebchat = ""
ClubData.myQQ = ""
ClubData.myKeyCode = ""

--上级玩家名片数据
ClubData.superiorName = ""
ClubData.superiorUid = 0
ClubData.superiorHeadIcon = 0
ClubData.superiorWebchat = ""
ClubData.superiorQQ = ""
ClubData.superiorKeyCode = ""

--名片类型
ClubData.memberCardType = 0

--俱乐部设置数据
ClubData.isOpenShenHe = false
ClubData.isOpenYinSi = false
ClubData.isOpenDaYang = false
ClubData.clubTitle = ""
ClubData.clubNotice = ""

--俱乐部桌子数据
ClubData.clubTableList = nil
ClubData.totalTableCount = 0

--当前桌子货币类型
ClubData.curTableMoneyType = MoneyType.Fangka

local this = ClubData
function ClubData.SetCurClubId(clubId)
    Log("SetCurClubId",clubId, this.clubList)
    this.curClubId = clubId
    for _, clubInfo in pairs(this.clubList) do
        if clubInfo.clubId == clubId then
            this.selfRole = clubInfo.role
            return true
        end
    end
    return false
end

function ClubData.ParseClubList(data)
    this.clubList = {}
    if data.clubList ~= nil then
        local club = nil
        for _, clubItem in pairs(data.clubList) do
            club = {
                --Id
                clubId = clubItem.clubId,
                --名称
                clubName = clubItem.clubName,
                --俱乐部专属码
                key = clubItem.inviteNum,
                --桌子数量
                tableNum = clubItem.tableNum,
                --玩家身份 ClubRole定义
                role = clubItem.memberLevel,

                boss = {
                    --盟主Id
                    bossId = clubItem.boss.bossId,
                    --盟主名称
                    bossName = clubItem.boss.bossName,
                    --盟主头像Icon
                    bossIcon = clubItem.boss.bossIcon,
                },

                --是否开启隐私
                isOpenYinSi = false,
                --是否打烊
                isDaYang = false
            }
            table.insert(this.clubList, club)
        end
    end
end

function ClubData.ParseClubData(data)
    for _, clubItem in pairs(this.clubList) do
        if clubItem.clubId == data.clubId then
            clubItem.clubName = data.clubName
            clubItem.isOpenPrivacy = data.isPrivacy
            clubItem.isDaYang = data.isOff
            clubItem.clubNotice = data.notice
            clubItem.isApply =  data.isApply
            -- this.isOpenYinSi = data.privacy
            this.ParseClubSetting(data)
            break
        end
    end
end

function ClubData.GetUidString(uid)
    if this.isOpenYinSi then
        return Functions.GetPrivacyUid(uid)
    else
        return tostring(uid)
    end
end

function ClubData.GetClubInfo()
    Log(">>>>>>>>>>>>>>>>>>>>", this.curClubId, this.clubList)
    if this.clubList ~= nil then
        for _, club in pairs(this.clubList) do
            if club.clubId ~= nil and club.clubId == this.curClubId then
                return club
            end
        end
    end
    return nil
end

--解析当前俱乐部成员数据
function ClubData.ParseMemberList(data)
    if this.clubMemberList == nil then
        this.clubMemberList = {}
    end
    this.totalMemberCount = data.totalNum
    this.totalMemberPage = data.totalPage
    local curPage = data.page
    local list = data.members
    if GetTableSize(list) > 0 then
        for k, item in pairs(list) do
            this.clubMemberList[(curPage - 1) * ClubMemberCountPerPage + k] = {
                uid = item.userId,
                name = item.userName,
                headIcon = item.iCon,
                lastOnline = item.lastLoginTime,
                isFreezed = item.isOff,
                role = item.admin,
            }
        end

        local tempSize = GetTableSize(this.clubMemberList)
        for i = this.totalMemberCount + 1, tempSize do
            this.clubMemberList[i] = nil
        end
    end
end

--索引从1开始，结构见ParseMemberList中
function ClubData.GetMemberItem(idx)
    return this.clubMemberList[idx]
end

--解析当前俱乐部申请数据
function ClubData.ParseApplyList(data)
    if this.clubApplyList == nil then
        this.clubApplyList = {}
    end
    this.totalApplyCount = data.totalNum
    local curPage = data.page
    local list = data.applyList
    if GetTableSize(list) > 0 then
        for k, item in pairs(list) do
            this.clubApplyList[(curPage - 1) * ClubApplyCountPerPage + k] = {
                uid = item.userId,
                name = item.userName,
                headIcon = item.iCon,
                inviteCode = item.inviteNum,
            }
        end

        local tempSize = GetTableSize(this.clubApplyList)
        for i = this.totalApplyCount + 1, tempSize do
            this.clubApplyList[i] = nil
        end
    end
end

--获取当前申请数据，索引从1开始，结构见ParseApplyList中
function ClubData.GetApplyItem(idx)
    return this.clubApplyList[idx]
end


--获取当前桌子数据，索引从1开始，结构见ParseTableList中
function ClubData.GetTableItem(idx)
    return this.clubTableList[idx]
end

--解析俱乐部桌子数据
function ClubData.ParseTableList(data)
    if this.clubTableList == nil then
        this.clubTableList = {}
    end
    this.totalTableCount = data.totalNum
    local curPage = data.page
    local list = data.list
    local itemTable = nil
    if GetTableSize(list) > 0 then
        for k, item in pairs(list) do
            Log("Item:", item, item.rules)
            itemTable = {
                id = item.tId,
                rules = JsonToObj(item.rules),
                gameType = item.gameId,
                moneyType = item.moneyType,
                baseScore = item.score,
                inGold = item.inGold,
                maxJs = item.maxjs,
                maxUserNum = item.maxNum,
                userInfos = {},
            }
            this.clubTableList[(curPage - 1) * ClubTableCountPerPage + k] = itemTable
            if item.players ~= nil then
                for _, userItem in pairs(item.players) do
                    table.insert(itemTable.userInfos, { uid = userItem.uId, name = userItem.uN, headIcon = userItem.uH })
                end
            end
        end

        local tempSize = GetTableSize(this.clubTableList)
        for i = this.totalTableCount + 1, tempSize do
            this.clubTableList[i] = nil
        end
    else
        this.clubTableList = {}
    end
end


--解析玩家名片数据
function ClubData.ParseMemberCardData(data)
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
function ClubData.ParseClubSetting(data)
    this.clubName = data.clubName
    this.isOpenYinSi = data.isPrivacy
    this.isOpenDaYang = data.isOff
    this.clubNotice = data.notice
    this.isOpenShenHe =  data.isApply
end