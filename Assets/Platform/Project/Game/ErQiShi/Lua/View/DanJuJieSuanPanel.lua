DanJuJieSuanPanel = ClassPanel("DanJuJieSuanPanel")
DanJuJieSuanPanel.userParent = nil
DanJuJieSuanPanel.userTran = {}
DanJuJieSuanPanel.huUid = nil       --胡牌玩家id
DanJuJieSuanPanel.huCardid = 0    --胡牌牌id
DanJuJieSuanPanel.zhunBeiBtn = nil
DanJuJieSuanPanel.shareBtn = nil
DanJuJieSuanPanel.returnToLobbyBtn = nil
--true表示房间已结束，返回大厅
DanJuJieSuanPanel.endType = nil
local countDownTime = 0
local this = DanJuJieSuanPanel

function DanJuJieSuanPanel:Awake()
    this = self
    this.zhunBeiBtn = self:Find("Content/Btn/ZhunBeiBtn")
    this.shareBtn = self:Find("Content/Btn/ShareBtn")
    this.returnToLobbyBtn = self:Find("Content/Btn/ReturnLobbyBtn")

    local nextButton = self:Find("Content/Btn/NextButton")
    this.nextButton = nextButton.gameObject
    this.readyCountdownLabel = nextButton:Find("Text"):GetComponent(TypeText)

    self:AddOnClick(this.zhunBeiBtn, this.OnClickPrepareBtn)
    self:AddOnClick(this.nextButton, this.OnClickPrepareBtn)
    self:AddOnClick(this.shareBtn, this.OnClickShareBtn)
    self:AddOnClick(this.returnToLobbyBtn, this.OnClickReturnToLobby)
end

--{"code":0,"err":"成功","data":{"users":[{"uid":100020,"huShu":16,"huRules":[1003],"yuType":[400],"huType":1,"huScore":24,"totalScore":26,"yuScore":2},{"uid":100021,"huShu":0,"huRules":[],"yuType":[300,300],"huType":0,"huScore":0,"totalScore":5,"yuScore":5},{"uid":100211,"huShu":0,"huRules":[],"yuType":[],"huType":3,"huScore":-24,"totalScore":-31,"yuScore":-7}]},"cmd":70810}
function DanJuJieSuanPanel:OnOpened(data)
    this.huCardid = 0
    this.huUid = ""
    countDownTime = 0
    ResourcesManager.CheckGC(true)
  
    if BattleModule.IsFkFlowRoom() then
        UIUtil.SetActive(this.shareBtn, false)
        UIUtil.SetActive(this.returnToLobbyBtn, false)
    else
        UIUtil.SetActive(this.shareBtn, false)
        UIUtil.SetActive(this.returnToLobbyBtn, true)
    end

    if BattleModule.isPlayback then
        UIUtil.SetActive(this.zhunBeiBtn, true)
        UIUtil.SetActive(this.nextButton, false)
        this.StopReadyCountdownTimer()
    else
        UIUtil.SetActive(this.zhunBeiBtn, false)
        UIUtil.SetActive(this.nextButton, true)
        this.SetReadyCountdown(10)
    end

    local user2Parent = this:Find('Content/Player2')
    local user3Parent = this:Find('Content/Player3')
    local user4Parent = this:Find('Content/Player4')
    if BattleModule.userNum == 2 then
        user2Parent.gameObject:SetActive(true)
        user3Parent.gameObject:SetActive(false)
        user4Parent.gameObject:SetActive(false)
        self.userParent = user2Parent
    elseif BattleModule.userNum == 3 then
        user2Parent.gameObject:SetActive(false)
        user3Parent.gameObject:SetActive(true)
        user4Parent.gameObject:SetActive(false)
        self.userParent = user3Parent
    elseif BattleModule.userNum == 4 then
        user2Parent.gameObject:SetActive(false)
        user3Parent.gameObject:SetActive(false)
        user4Parent.gameObject:SetActive(true)
        self.userParent = user4Parent
    else
        LogError("人数错误：", BattleModule.userNum)
    end
    TryCatchCall(function ()
        self.Init(data.users)
    end)
    --0游戏正常，可以继续游戏  1游戏已经打完，正常结束  2有玩家分数不足，提前解散
    this.endType = data.isEnd
    BattleModule.isEnd = this.endType == 1 or this.endType == 2
end

function DanJuJieSuanPanel:OnClosed()
    LogError(">> DanJuJieSuanPanel:OnClosed")
    this.StopReadyCountdownTimer()
end

function DanJuJieSuanPanel.OnClickPrepareBtn()
    this.StopReadyCountdownTimer()
    --Log("总结算数据：", BattleModule.zongJieSuanData)
    if BattleModule.zongJieSuanData ~= nil then
        PanelManager.Open(EqsPanels.ZongJieSuan)
    else
        if this.endType == 1 then
            Alert.Show("房间已经结束，请返回大厅", function ()
                EqsTools.ReturnToLobby()
            end)
        elseif this.endType == 2 then
            Alert.Show("有玩家分数不足，房间已经结束，请返回大厅", function ()
                EqsTools.ReturnToLobby()
            end)
        elseif this.endType == 3 then
            Alert.Show("因存在玩家托管数局，房间解散！", function ()
                EqsTools.ReturnToLobby()
            end)
        else
            if BattleModule.userNum == BattleModule.curUserNum then
                BattleModule.SendPrepare()
            else
                Toast.Show("游戏人数不够，请退出房间后重新进入")
            end
        end
    end
end
--匹配场继续游戏
function DanJuJieSuanPanel.OnClickContinueGameBtn()
    if os.time() - countDownTime < 3 then
       Toast.Show("请不要频繁操作")
       return 
    end
    countDownTime = os.time()
    GoldMacthMgr.SendMatchGame(BattleModule.teaId)
    TryCatchCall(function ()
        EqsBattleCtrl.OnInitNextInCoinRoom()
    end)
end

function DanJuJieSuanPanel.OnClickShareBtn()
    --分享截图
    local data = {
        roomCode = BattleModule.roomId,
        type = 2,      
        ScreenshotScale = {w = 1280, h = 720},
    }
    PanelManager.Open(PanelConfig.RoomInvite, data)
end

function DanJuJieSuanPanel.OnClickReturnToLobby()
    BattleModule.SendQuitRoom()
end

function DanJuJieSuanPanel.Init(users)
    if GetTableSize(users) > 0 then
        for _, userData in pairs(users) do
            userData.totalScore = tonumber(userData.totalScore)
            userData.yuScore = tonumber(userData.yuScore)
            userData.huScore = tonumber(userData.huScore)

            local userInfo = BattleModule.GetUserInfoByUid(userData.uid)
            if userInfo ~= nil then
                userInfo:UnscheduleFingerTips()
                local unit = this.userParent:Find("User" .. tostring(userInfo.uiIdx))
                if unit ~= nil then
                    --当前局分数为huScore + yuScore       玩家总分数为：totalScore
                    if not IsNumber(userData.yuScore) then
                        userData.yuScore = 0
                    end
                    if not IsNumber(userData.huScore) then
                        userData.huScore = 0
                    end
                    if not IsNumber(userData.totalScore) then
                        userData.totalScore = 0
                    end
                    if not IsNumber(userData.rightCard) then
                        userData.rightCard = 0
                    end

                    Log("更新玩家结算数据：", userData)
                    this.SetTotalScore(unit, userData.huScore + userData.yuScore)
                    userInfo:SetScore(userData.totalScore)
                    --userData.huRules 胡牌规则：如天胡、地胡、昆胡等
                    this.SetText(unit, userData.huRules, userData.yuType, userData.yuScore, userData.huShu, userData.huType)
                    if not userInfo:IsSelf() then
                        this.userTran[userData.uid] = unit
                        this.SetShouPai(unit, userData.handCards, userData.rightCard, userData.uid)
                    else
                        SelfHandEqsCardsCtrl.CheckAndSyncCards(userData.handCards)
                    end
                else
                    Log("unit查找失败：", userInfo.uid, userInfo.uiIdx)
                end
            else
                Log("结算时，不存在玩家：", userData.uid)
            end
        end
    else
        Log("################结算数据错误")
    end
end

--设置结算分数
function DanJuJieSuanPanel.SetTotalScore(tran, score)
	if tran ~= nil and score ~= nil then
		local addText = tran:Find("Score/AddText"):GetComponent(typeof(Text))
        local subText = tran:Find("Score/SubText"):GetComponent(typeof(Text))
        UIUtil.SetActive(addText.gameObject, score >= 0)
        UIUtil.SetActive(subText.gameObject, score < 0)
        if score >= 0 then
            score = "+"..score
        end
		addText.text = score
        subText.text = score
	end
end

--设置结算显示文字
--huType  1000天胡   1001地胡   1002圈胡  1003坤胡   1004漂胡    1005清一色   1006双圈  1007磙翻   1008大胡  1009上台 1010小家自摸加翻
--结构：1000,1001,1002....
--yuType:  100巴雨     200点雨        300翻雨      400磙
--取余100 如果等于0 表示玩家相应巴雨 如果不等于0 表示玩家相应雨次数
--结构：100,203...huRules
function DanJuJieSuanPanel.SetText(tran, huRules, yuType, yuFen, hushu, huType)
    local text = ""
    if not IsTable(huRules) then
        Log("huRules error")
        return 
    end
	for _, item in ipairs(huRules) do
		if item == 1000 then
			text = text .. "天胡 "
		elseif item == 1001 then
			text = text .. "地胡 "
		elseif item == 1001 then
			text = text .. "地胡 "
		elseif item == 1002 then
			text = text .. "圈胡 "
		elseif item == 1003 then
			text = text .. "坤胡 "
		elseif item == 1004 then
			text = text .. "漂胡 "
		elseif item == 1005 then
			text = text .. "清一色 "
		elseif item == 1006 then
            text = text .. "双圈 "
        elseif item == 1007 then
            text = text .. "磙翻 "
        elseif item == 1008 then
            text = text .. "大胡 "
        elseif item == 1009 then
            text = text .. "上台 "
        elseif item == 1010 then
			text = text .. "小家自摸加翻 "
		end
    end
    --处理雨，因为后端会发送相同的雨，如[200,200]，此处去重
    if not IsTable(yuType) then
        Log("yuType error")
        return 
    end
    local yu = {}
    for _, item in ipairs(yuType) do
        yu[item] = item
    end
	text = text..' '
	for _, item in ipairs(yu) do
        if item == 100 then
            text = text .. "巴雨 "
        elseif item == 200 then
            text = text .. "点雨 "
        elseif item == 300 then
            text = text .. "翻雨 "
        elseif item == 400 then
            text = text .. "磙 "
        end
    end
    local roomType = tonumber(BattleModule.GetRule(EqsRuleType.RType))
    if roomType  == EqsPlayType.LeShan or roomType == EqsPlayType.MeiShan or 
    roomType == EqsPlayType.SanRen14Zhang or roomType == EqsPlayType.ErRen then
        if BattleModule.GetRule(EqsRuleType.XiaYu) == 1 then
            text = text..'  雨分:'..tostring(yuFen)
        end
    end
    if not IsNumber(hushu) then
        hushu = 0
    end
    if tonumber(hushu) > 0 then
        text = text..'  胡数:'..tostring(hushu)
    end
    
    if huType == 3 then
        text = text .. " 点炮"
    end

    if huType == 31 then
        text = text .. " 打圈半自付"
    end

    if huType == 10 then
        text = text .. " 翻胡"
    end

    if huType == 1 then
        text = text.." 胡牌"
    end

	local disc = tran:Find("Disc"):GetComponent(typeof(Text))
	if disc then
		disc.text = text
	end
end

--设置结算牌信息:自己的不设置  shouPaiIds={}
function DanJuJieSuanPanel.SetShouPai(tran, shouPaiIds, huPaiId, uid)
    Log("设置结算玩家手牌：",tran, shouPaiIds, huPaiId, uid)
	if tran ~= nil and IsTable(shouPaiIds) then
		--手牌解析
        this.ClearAllCellCard(uid)
        local list = this.CalcuLines(shouPaiIds)
        Log(">>>>>>>>>>>>>>>>列数：", #list, GetTableSize(list), list)
	    local listIdx = 0
        local listParent = tran:Find("HandCards")
        for i, item in pairs(list) do
            if listParent.childCount > listIdx then
                local line = listParent:GetChild(listIdx)
                if #item > 0 and line then
                    Log("Line：", item)
                    listIdx = listIdx + 1
                    line.gameObject:SetActive(true)
                    local firstCard = nil
                    for i, id in pairs(item) do
                        local smallCard = EqsTools.AddSmallCardToCell(id,line.transform:Find("Cell" .. tostring(i)))
                        --设置磙特效
                        if i == 1 and #item == 4 then
                            local id1 = EqsTools.GetEqsCardId(item[1])
                            local id2 = EqsTools.GetEqsCardId(item[2])
                            local id3 = EqsTools.GetEqsCardId(item[3])
                            local id4 = EqsTools.GetEqsCardId(item[4])
                            Log(">>>>>>>>>>>>>",id1, id2, id3, id4)
                            if i == 1 and #item == 4 and id1 == id2 and id1 == id3 and id1 == id4 then
                                firstCard = smallCard
                            end
                        end
                        --如果是雨牌，特效
                        if BattleModule.IsYuCardUid(id) then
                            EqsCardsManager.SetSmallCardEffect(smallCard, EqsCardDefine.SmallCardEffectType.BoundEffect)
                        end
                    end
                    if firstCard then
                        Log("设置磙：", uid, firstCard.name)
                        EqsCardsManager.SetSmallCardEffect(firstCard, EqsCardDefine.SmallCardEffectType.GunTag)
                    end
                end
            end
        end
        if IsNumber(huPaiId) and huPaiId > 0 then
            local listLen =  GetTableSize(list) 
            if listParent.childCount > listLen - 1 then
                line = listParent:GetChild(listLen)
                UIUtil.SetActive(line, true)
                local card = EqsTools.AddSmallCardToCell(huPaiId,line.transform:Find("Cell1"))
                if card ~= nil then
                    this.huUid = uid
                    this.huCardid = huPaiId
                    Log("设置胡牌信息：", this.huUid, this.huCardid)
                    card.localPosition = Vector3(30, 0, 0)
                    --如果是雨牌，特效
                    if BattleModule.IsYuCardUid(huPaiId) then
                        EqsCardsManager.SetSmallCardEffect(card, EqsCardDefine.SmallCardEffectType.BoundEffect)
                    end
                end
            end
        end
    end
    if this.IsEquals(shouPaiIds,uid) then
        this.UpdateCardPositions(uid)
    end
end

--手牌ID和同步牌ID一致性判断，如果不一致，不重新更新位置
function DanJuJieSuanPanel.IsEquals(shouPaiIds, uid)
    local pos = BattleModule.GetDanJuJieSuanCardPosition(uid)
    if GetTableSize(pos) > 0 then
        local keyId = {}
        for k, v in pairs(shouPaiIds) do
            keyId[tostring(v)] = v
        end

        for cardid, loc in pairs(pos) do
            if keyId[tostring(cardid)] == nil then
                Log("同步牌和结算牌不一致,\n同步牌：", pos, " 结算牌：", shouPaiIds)
                return false
            end
        end
        return true
    end
    return false
end

function DanJuJieSuanPanel.CalcuLines(tableCards)
    table.sort(
        tableCards,
        function(card1, card2)
            return card1 < card2
        end
    )
    
    --list{列={EqsCard数组}, 列={EqsCard数组}...}
    local list = {} --定义10列

    --初始化20列，tableCards最多21张(三人打，庄家)
    for i = 1, 20 do
        list[i] = {}
    end

    local curListIdx = 1
    for i, card in ipairs(tableCards) do
        local listCardCount = GetTableSize(list[curListIdx])
        if listCardCount == 0 then
            table.insert(list[curListIdx], card)
        else
            if EqsTools.GetEqsCardId(list[curListIdx][listCardCount]) == EqsTools.GetEqsCardId(card) then
                table.insert(list[curListIdx], card) --相同ID插入同一行
            else
                if EqsTools.GetEqsCardPoint(list[curListIdx][listCardCount]) == EqsTools.GetEqsCardPoint(card) then -- 处理点数相同
                    local count = this.GetCountById(tableCards, EqsTools.GetEqsCardId(card))
                    if listCardCount + count < 5 then
                        table.insert(list[curListIdx], card) --相同ID插入同一行
                    else
                        curListIdx = curListIdx + 1
                        table.insert(list[curListIdx], card) --相同ID插入同一行
                    end
                else
                    curListIdx = curListIdx + 1
                    table.insert(list[curListIdx], card) --相同ID插入同一行
                end
            end
        end
    end

    --删除空列
    for idx, cards in pairs(list) do
        if #cards == 0 then
            list[idx] = nil
        end
    end

    -- 处理多余的列:由于牌面只能显示10列，将相邻的只有一张牌的列放在一起(21张牌最多12列)
    --将相邻的只有一张牌的行合并
    local listNum = GetTableSize(list)
    if listNum == 12 then
        for i = 1, 12 do
            if list[i] ~= nil and list[i + 1] ~= nil then
                if #list[i] < 4 and #list[i + 1] == 1 then
                    table.insert(list[i], list[i + 1][1])
                    list[i + 1] = nil
                    break
                end
            end
        end
    end

    --将只有一张牌的行插入到左边不满4张牌的行
    if GetTableSize(list) > 10 then
        for i = 1, 12 do
            if list[i] ~= nil and list[i + 1] ~= nil then
                if #list[i] < 4 and #list[i + 1] == 1 then
                    table.insert(list[i], list[i + 1][1])
                    list[i + 1] = nil
                    break
                end
            end
        end
    end
    return list
end

function DanJuJieSuanPanel.GetCountById(tableCards, id)
	local count = 0
	for _, card in pairs(tableCards) do
		if EqsTools.GetEqsCardId(card) == id then
			count = count + 1
		end
    end
	return count
end

--如果位置信息存在，将所有牌按照位置更新
function DanJuJieSuanPanel.UpdateCardPositions(uid)
    local pos = BattleModule.GetDanJuJieSuanCardPosition(uid)
    if IsTable(pos) and GetTableSize(pos) > 0 then
        --更新所有牌的位置
        this.ClearAllCellCard(uid)
        local maxX = 0
        Log("重新设置所有牌的位置：", uid,pos)
        for cardid, loc in pairs(pos) do
            local cell = this.GetCell(uid,loc.x, loc.y)
            if cell ~= nil then
                local smallCard = EqsTools.AddSmallCardToCell(tonumber(cardid),cell)
                if smallCard ~= nil then
                    --如果是雨牌，特效
                    if BattleModule.IsYuCardUid(tonumber(smallCard.gameObject.name)) then
                        EqsCardsManager.SetSmallCardEffect(smallCard, EqsCardDefine.SmallCardEffectType.BoundEffect)
                    end
                end
                UIUtil.SetActive(cell.parent, true)
                if loc.x >= maxX then
                    maxX = loc.x
                end
            else
                Log("没有找到位置：", uid, loc, cardid)
            end
        end

        --设置磙
        for i = 1, 10 do
            local id1 = EqsTools.GetEqsCardId(EqsTools.GetCellCardUid(this.GetCell(uid,i, 1)))
            local id2 = EqsTools.GetEqsCardId(EqsTools.GetCellCardUid(this.GetCell(uid,i, 2)))
            local id3 = EqsTools.GetEqsCardId(EqsTools.GetCellCardUid(this.GetCell(uid,i, 3)))
            local id4 = EqsTools.GetEqsCardId(EqsTools.GetCellCardUid(this.GetCell(uid,i, 4)))
            if  id1 == id2 and id1 == id3 and id1 == id4 and id1 > 0 then
                local cell = this.GetCell(uid,i, 1)
                if cell ~= nil and cell.childCount > 0 then
                    EqsCardsManager.SetSmallCardEffect(cell:GetChild(0), EqsCardDefine.SmallCardEffectType.GunTag)
                else
                    Log("设置磙错误：", uid, id1, id2, id3, id4)    
                end
            end
        end

        --更新胡牌信息
        Log("更新uid", uid, " 胡牌：", this.huUid, this.huCardid)
        if this.huUid == uid and this.huCardid > 0 then
            local huCell = this.GetCell(uid, maxX + 1, 1)
            if huCell ~= nil then
                local cardTran = EqsTools.AddSmallCardToCell(this.huCardid, huCell)
                cardTran.localPosition = Vector3(30, 0, 0)
                UIUtil.SetActive(huCell.parent, true)
                --如果是雨牌，特效
                if BattleModule.IsYuCardUid(this.huCardid) then
                    EqsCardsManager.SetSmallCardEffect(cardTran, EqsCardDefine.SmallCardEffectType.BoundEffect)
                end
            else
                Log("没有找到胡牌Cell:", uid, maxX, this.huCardid)
            end
        end
    else
        Log("DanJuJieSuanPanel.UpdateCardPositions不存在位置信息", uid)
    end
end

function DanJuJieSuanPanel.ClearAllCellCard(uid)
    local parent = this.userTran[uid]
    if parent ~= nil then
        local listParent = parent:Find("HandCards")
		for i = 0, listParent.childCount - 1 do
            local line = listParent:GetChild(i)
            UIUtil.SetActive(line, false)
			EqsTools.RecycleSmallCardCell(line:Find("Cell1"))
			EqsTools.RecycleSmallCardCell(line:Find("Cell2"))
			EqsTools.RecycleSmallCardCell(line:Find("Cell3"))
			EqsTools.RecycleSmallCardCell(line:Find("Cell4"))
		end
    end
end

--x,y从1开始
function DanJuJieSuanPanel.GetCell(uid, x, y)
    local parent = this.userTran[uid]
    if parent ~= nil then
        local listParent = parent:Find("HandCards")
        local count = listParent.childCount
        if x - 1 < count and x >= 1 then
            local line = listParent:GetChild(x - 1)
            if y >= 1 and y <= 4 then
                return line:Find("Cell"..tostring(y))
            end
        end
    end
    return nil
end


------------------------------------------------------------------
--
--设置倒计时
function DanJuJieSuanPanel.SetReadyCountdown(time)
    if time == nil then
        time = 0
    end
    this.readyTime = time
    this.readyDisplayTime = -1
    this.readySetTime = Time.realtimeSinceStartup
    --显示
    this.StartReadyCountdownTimer()
    --显示下倒计时
    this.OnReadyCountdownTimer()
end

--启动准备倒计时计时器
function DanJuJieSuanPanel.StartReadyCountdownTimer()
    if this.readyCountdownTimer == nil then
        this.readyCountdownTimer = Timing.New(this.OnReadyCountdownTimer, 0.33)
    end
    this.readyCountdownTimer:Start()
end

function DanJuJieSuanPanel.StopReadyCountdownTimer()
    if this.readyCountdownTimer ~= nil then
        this.readyCountdownTimer:Stop()
    end
end

function DanJuJieSuanPanel.OnReadyCountdownTimer()
    this.tempTime = this.readyTime - (Time.realtimeSinceStartup - this.readySetTime)
    this.tempTime = math.ceil(this.tempTime)
    if this.tempTime < 0 then
        this.tempTime = 0
        this.StopReadyCountdownTimer()
        this.OnClickPrepareBtn()
        return
    end
    this.tempTime = math.abs(this.tempTime)
    if this.tempTime ~= this.readyDisplayTime then
        this.readyDisplayTime = this.tempTime
        --显示
        this.readyCountdownLabel.text = this.readyDisplayTime
    end
end