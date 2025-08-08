MahjongSingleSettlementPanel = ClassPanel("MahjongSingleSettlementPanel")
MahjongSingleSettlementPanel.Instance = nil
--
local this = MahjongSingleSettlementPanel

--立牌的宽度
local CardWidth = 50
--操作牌一坎的宽度
local OperationWidth = 152 + 4
--摸牌或者胡牌的间隔
local NewCardGap = 12

local jieSuanAnimName = {
    Win = "js_shengli",
    Lose = "js_shibai",
    Tie = "js_pingju",
    Flow = "js_liuju",
}

local InitItemPosX = {31, 4, -23, -50}

--
--初始属性数据
function MahjongSingleSettlementPanel:InitProperty()
    this.items = {}
    this.data = nil
    this.sprites = {}
    --点炮顺序数据
    this.dianHuData = {}
    --继续游戏按钮点击时间
    this.nextBtnClickTime = 0
    --是否分数房间结束，用于中途查看结算
    this.isGoldRoomEnd = true
    --临时玩家数据，关闭清除
    this.tempPlayerDatas = {}
    --临时玩家牌数据，关闭清除
    this.tempPlayerCardDatas = {}
    --本次结算是否播放结算动画
    this.isPlayjieSuanAnim = false
end

--UI初始化
function MahjongSingleSettlementPanel:OnInitUI()
    this = self
    this:InitProperty()

    
    this.maskBtn = self:Find("Mask")
    local content = self:Find("Content")

    this.jieSuanAnim = content:Find("Background/EffectJieSuan"):GetComponent(TypeSkeletonGraphic)
    --标题
    local titleTrans = content:Find("Background/Title")
    this.titleWinGO = titleTrans:Find("TitleWin").gameObject
    this.titleLoseGO = titleTrans:Find("TitleLose").gameObject
    this.titleTieGO = titleTrans:Find("TitleTie").gameObject
    this.titleFlowGO = titleTrans:Find("TitleFlow").gameObject
    --分数场底分显示相关
    local goldTrans = content:Find("Gold")
    this.goldNode = goldTrans.gameObject
    this.goldTxt = goldTrans:Find("Text"):GetComponent(TypeText)

    local nodeTrans = content:Find("Node")
    this.shareBtn = nodeTrans:Find("ShareButton").gameObject
    this.backBtn = nodeTrans:Find("BackButton").gameObject
    this.nextBtn = nodeTrans:Find("NextButton").gameObject
    this.closeBtn = nodeTrans:Find("CloseButton").gameObject
    this.totalBtn = nodeTrans:Find("TotalButton").gameObject

    local settleNextBtn2 = nodeTrans:Find("NextButton2")
    this.settleNextBtn2 = settleNextBtn2.gameObject
    this.readyCountdownLabel = settleNextBtn2:Find("Label"):GetComponent(TypeText)

    this.closeAnim = this.closeBtn.transform:GetComponent(TypeAnimator)
    this.totalAnim = this.totalBtn.transform:GetComponent(TypeAnimator)
    this.settleNextAnim = this.settleNextBtn2.transform:GetComponent(TypeAnimator)

    this.iconTea = nodeTrans:Find("IconTea").gameObject
    this.iconClub = nodeTrans:Find("IconClub").gameObject

    local Infos = self:Find("Infos")
    this.infoTxt = Infos:Find("InfoTxt"):GetComponent(TypeText)
    this.playWayTxt = Infos:Find("PlayWayTxt"):GetComponent(TypeText)

    local itemsTrans = nodeTrans:Find("Items")
    for i = 1, 4 do
        local item = {}
        item.transform = itemsTrans:Find(tostring(i))
        item.gameObject = item.transform.gameObject
        this.items[i] = item
    end

    --胡图标
    local atlas = content:Find("Atlas"):GetComponent("UISpriteAtlas")
    local tempSprites = atlas.sprites:ToTable()
    local sprite = nil
    for i = 1, #tempSprites do
        sprite = tempSprites[i]
        if sprite ~= nil then
            this.sprites[sprite.name] = sprite
        else
            LogWarn(">> MahjongSingleSettlementPanel > sprite == nil > index = " .. i)
        end
    end

    this.cardItemPrefab = nodeTrans:Find("CardItem").gameObject
    this.operationItemPrefab = nodeTrans:Find("OperationItem").gameObject
    this.AddUIListenerEvent()
end

--当面板开启开启时
function MahjongSingleSettlementPanel:OnOpened()
    MahjongSingleSettlementPanel.Instance = self
    this.AddListenerEvent()

    this.isGoldRoomEnd = true
    if MahjongDataMgr.isPlayback then
        this.data = MahjongPlaybackCardMgr.settlementData
    else
        this.data = MahjongDataMgr.settlementData
    end

    if MahjongDataMgr.isPlayback then
        UIUtil.SetActive(this.backBtn, false)
        UIUtil.SetActive(this.nextBtn, false)
        UIUtil.SetActive(this.shareBtn, false)
        UIUtil.SetActive(this.closeBtn, true)
        UIUtil.SetActive(this.settleNextBtn2, false)
    else
        if MahjongDataMgr.IsGoldRoom() then
            local isRoomEnd = false
            if this.data ~= nil then
                if this.data.roomState ~= MahjongRoomStateType.Settlement and this.data.roomState ~= MahjongRoomStateType.End then
                    this.isGoldRoomEnd = false
                end
                isRoomEnd = this.data.roomState == MahjongRoomStateType.End
            end

            UIUtil.SetActive(this.backBtn, false)
            UIUtil.SetActive(this.nextBtn, false)
            UIUtil.SetActive(this.shareBtn, false)
            UIUtil.SetActive(this.closeBtn, false)--not isRoomEnd
            UIUtil.SetActive(this.totalBtn, isRoomEnd or this.data.isIsDiss == 1)
            UIUtil.SetActive(this.settleNextBtn2, not (isRoomEnd or this.data.isIsDiss == 1))
            this.SetReadyCountdown(10)
        else
            UIUtil.SetAnchoredPositionX(this.nextBtn, 0)
            UIUtil.SetAnchoredPositionX(this.settleNextBtn2, 0)
            --UIUtil.SetAnchoredPositionX(this.shareBtn, -265)
            --
            UIUtil.SetActive(this.backBtn, false)
            UIUtil.SetActive(this.nextBtn, false)
            UIUtil.SetActive(this.shareBtn, false)
            UIUtil.SetActive(this.closeBtn, false)
            UIUtil.SetActive(this.totalBtn, false)
            UIUtil.SetActive(this.settleNextBtn2, true)
            this.SetReadyCountdown(10)
        end
    end
    if this.isMaskCanClick == nil then
        this.isMaskCanClick = true
    end
    this.closeAnim.enabled = this.isMaskCanClick
    this.totalAnim.enabled = this.isMaskCanClick
    this.settleNextAnim.enabled = this.isMaskCanClick

    if this.data ~= nil then
        this.UpdateData()
    else
        this.SetDefaultUI()
    end
end

--当面板关闭时调用
function MahjongSingleSettlementPanel:OnClosed()
    MahjongSingleSettlementPanel.Instance = nil
    this.tempPlayerDatas = {}
    this.tempPlayerCardDatas = {}
    this.RemoveListenerEvent()
    this.StopReadyCountdownTimer()
    this.isMaskCanClick = true
    
    --结算动画相关代码
    this.isPlayjieSuanAnim = false
    this.jieSuanAnim.AnimationState:ClearTracks();
    UIUtil.SetActive(this.jieSuanAnim.gameObject, false)
end

------------------------------------------------------------------
--
--关闭
function MahjongSingleSettlementPanel.Close()
    PanelManager.Close(MahjongPanelConfig.SingleSettlement)
end
--
function MahjongSingleSettlementPanel.AddListenerEvent()
end
--
function MahjongSingleSettlementPanel.RemoveListenerEvent()
end

--UI相关事件
function MahjongSingleSettlementPanel.AddUIListenerEvent()
    this:AddOnClick(this.shareBtn, this.OnShareBtnClick)
    this:AddOnClick(this.backBtn, this.OnBackBtnClick)
    this:AddOnClick(this.nextBtn, this.OnNextBtnClick)
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.totalBtn, this.OnNextBtnClick)
    this:AddOnClick(this.settleNextBtn2, this.OnNextBtnClick)
    this:AddOnClick(this.maskBtn, this.OnMaskBtnClick)
end

------------------------------------------------------------------
--
function MahjongSingleSettlementPanel.OnShareBtnClick()
    local item = nil
    for i = 1, #this.data.xj do
        if this.data.xj[i].id == UserData.GetUserId() then
            item = this.data.xj[i]
            break
        end
    end
    --分享截图
    local data = {
        roomCode = MahjongDataMgr.roomId,
        type = 2,
        ScreenshotScale = { w = 1172 - 24, h = 700 - 24 }
    }
    if this.CheckScreenshot(item) then
        local ScreenshotCallback = function(sharePlatformType, shareType)
            local data = {
                itemData = item,
                sharePlatformType = sharePlatformType,
                shareType = shareType,
                cardItemPrefab = this.cardItemPrefab,
                operationItemPrefab = this.operationItemPrefab
            }
            PanelManager.Open(MahjongPanelConfig.MahjongScreenshot, data)
        end
        data.callback = ScreenshotCallback
        data.type = 3
    end
    PanelManager.Open(PanelConfig.RoomInvite, data)
end
--
-- function MahjongSingleSettlementPanel.OnShareBtnClick()
--     --分享截图
--     local data = {
--         roomCode = MahjongDataMgr.roomId,
--         type = 2,
--         ScreenshotScale = { w = 1172 - 16, h = 700 - 16 },
--     }
--     PanelManager.Open(PanelConfig.RoomInvite, data)
-- end
--
--返回大厅
function MahjongSingleSettlementPanel.OnBackBtnClick()
    MahjongRoomMgr.ExitRoom()
end

--继续游戏
function MahjongSingleSettlementPanel.OnNextBtnClick()
    -- if MahjongDataMgr.IsGoldRoom() then
    --     if os.time() - this.nextBtnClickTime < 3 then
    --         Toast.Show("请不要频繁操作")
    --         return
    --     end
    --     this.nextBtnClickTime = os.time()

    --     local tempRoomId = nil
    --     if this.data ~= nil then
    --         tempRoomId = this.data.id
    --     end
    -- else
    if MahjongDataMgr.settlementData ~= nil then
        MahjongDataMgr.settlementIndex = MahjongDataMgr.settlementData.index
    end
    this.Close()
    --数据为空或者房间结束
    if (this.data == nil or this.data.roomState == MahjongRoomStateType.End or this.data.isIsDiss == 1) and not MahjongDataMgr.isPlayback then
        PanelManager.Open(MahjongPanelConfig.TotalSettlement)
    else
        --点了下一局，游戏状态设置为等待状态
        MahjongDataMgr.gameState = MahjongGameStateType.Waiting
        MahjongDataMgr.settlementData = nil
        MahjongCommand.SendReady()
    end
    --end
end

--回放状态下的关闭按钮
function MahjongSingleSettlementPanel.OnCloseBtnClick()
    this.Close()
end

--遮罩按钮，点击直接跳过动画显示结算信息
function MahjongSingleSettlementPanel.OnMaskBtnClick()
    if not this.isMaskCanClick then
        return
    end 
    this.isMaskCanClick = false
    local item = nil
    for i = 1, 4 do
        item = this.items[i]
        if item.bgAnim ~= nil then
            item.bgAnim.enabled = false
            item.bg.gameObject.transform.localScale = Vector3.one
            UIUtil.SetAnchoredPosition(item.bg.gameObject.transform, 0, 0)
            UIUtil.SetImageColor(item.huIcon, 1, 1, 1)
            item.scoreGo.transform.localScale = Vector3.one
        end
    end
    this.closeAnim.enabled = false
    this.totalAnim.enabled = false
    this.settleNextAnim.enabled = false
    this.closeBtn.transform.localScale = Vector3.one
    this.totalBtn.transform.localScale = Vector3.one
    this.settleNextBtn2.transform.localScale = Vector3.one
end


------------------------------------------------------------------结算动画

function MahjongSingleSettlementPanel.SetPlayEffect(animName)
    if this.isPlayjieSuanAnim then
        return
    end
    this.isPlayjieSuanAnim = true
    UIUtil.SetActive(this.jieSuanAnim.gameObject, true)
    local temp = this.jieSuanAnim.SkeletonData:FindAnimation(animName)
    if temp ~= nil then
        this.jieSuanAnim.AnimationState:SetAnimation(0, animName, false)
    end
end

------------------------------------------------------------------
--
--设置默认UI
function MahjongSingleSettlementPanel.SetDefaultUI()
    -- UIUtil.SetActive(this.titleFlowGO, false)
    -- UIUtil.SetActive(this.titleWinGO, false)
    -- UIUtil.SetActive(this.titleLoseGO, false)
    -- UIUtil.SetActive(this.titleTieGO, true)

    this.SetPlayEffect(jieSuanAnimName.Tie)
    
    UIUtil.SetActive(this.iconTea, false)
    UIUtil.SetActive(this.iconClub, false)

    UIUtil.SetActive(this.goldNode, false)

    this.infoTxt.text = ""
    this.playWayTxt.text = ""

    for i = 1, 4 do
        UIUtil.SetActive(this.items[i].gameObject, false)
    end
end

--更新数据
function MahjongSingleSettlementPanel.UpdateData()
    --优先处理流局
    local isLiuJu = false
    if this.data.endState == MahjongEndState.LiuJu then
        -- UIUtil.SetActive(this.titleFlowGO, true)
        -- UIUtil.SetActive(this.titleWinGO, false)
        -- UIUtil.SetActive(this.titleLoseGO, false)
        -- UIUtil.SetActive(this.titleTieGO, false)

        this.SetPlayEffect(jieSuanAnimName.Flow)
        isLiuJu = true
    else
        -- UIUtil.SetActive(this.titleFlowGO, false)
    end

    if MahjongDataMgr.roomType == RoomType.Club then
        UIUtil.SetActive(this.iconTea, false)
        UIUtil.SetActive(this.iconClub, true)
        UIUtil.SetActive(this.goldNode, false)
    elseif MahjongDataMgr.roomType == RoomType.Tea then
        UIUtil.SetActive(this.iconTea, true)
        UIUtil.SetActive(this.iconClub, false)
        UIUtil.SetActive(this.goldNode, true)
        this.goldTxt.text = tostring(MahjongDataMgr.baseScore)
    else
        UIUtil.SetActive(this.iconTea, false)
        UIUtil.SetActive(this.iconClub, false)
        UIUtil.SetActive(this.goldNode, false)
    end

    --处理房间信息
    local index = 1
    if IsNumber(this.data.index) then
        index = this.data.index
    end

    local time = ""
    if IsNumber(this.data.endTime) then
        time = MahjongUtil.GetDateByTimeStamp(this.data.endTime)
    end

    --房间信息
    local infoStr = "房间号:" .. this.data.id
    if MahjongDataMgr.IsGoldRoom() then
        infoStr = infoStr .. " 局数:" .. index
    else
        infoStr = infoStr .. " 局数:" .. index .. "/" .. MahjongDataMgr.gameTotal
    end
    infoStr = infoStr .. " " .. time .. " 底分:" .. MahjongDataMgr.baseScore
    this.infoTxt.text = infoStr

    --显示玩法
    local playWayInfo = Functions.ParseGameRule(GameType.Mahjong, MahjongDataMgr.rules, MahjongDataMgr.gpsType)
    this.playWayTxt.text = playWayInfo.rule

    --点炮顺序
    this.dianHuData = {}
    local index = 1
    if this.data.xj ~= nil then
        local tempData = nil
        local length = #this.data.xj
        local tempDianHuData = nil
        --处理点炮顺序
        for i = 1, length do
            tempData = this.data.xj[i]
            if tempData.huState == MahjongHuState.Hu and tempData.huFrom ~= nil then
                tempDianHuData = this.dianHuData[tempData.huFrom]
                --考虑到一个人可能点几人的情况
                if tempDianHuData == nil then
                    tempDianHuData = {}
                    this.dianHuData[tempData.huFrom] = tempDianHuData
                end
                table.insert(tempDianHuData, tempData.huIndex)
            end
        end

        for i = 1, length do
            tempData = this.data.xj[i]
            tempData.score = tonumber(tempData.score)
            --流局了就不处理分数
            if not isLiuJu and tempData.id == MahjongDataMgr.userId then
                -- UIUtil.SetActive(this.titleWinGO, tempData.score > 0)
                -- UIUtil.SetActive(this.titleLoseGO, tempData.score < 0)
                -- UIUtil.SetActive(this.titleTieGO, tempData.score == 0)

                if tempData.score > 0 then
                    this.SetPlayEffect(jieSuanAnimName.Win)
                elseif tempData.score < 0 then
                    this.SetPlayEffect(jieSuanAnimName.Lose)
                elseif tempData.score == 0 then
                    this.SetPlayEffect(jieSuanAnimName.Tie)
                end
            end
            --更新Item显示
            this.UpdateItem(this.items[i], tempData)
            index = index + 1
        end
    end
    for i = index, 4 do
        UIUtil.SetActive(this.items[i].gameObject, false)
    end
end

------------------------------------------------------------------
--
--检测Item的属性查找
function MahjongSingleSettlementPanel.CheckItem(item)
    --处理UI查找赋值
    if item.inited ~= true then
        item.inited = true

        item.bg = item.transform:Find("Bg")
        item.bgAnim = item.bg:GetComponent(TypeAnimator)
        item.bgImage = item.bg:GetComponent(TypeImage)
        item.cardsTrans = item.bg:Find("Cards")

        local contentTrans = item.bg:Find("Content")
        item.nameTxt = contentTrans:Find("NameTxt"):GetComponent(TypeText)
        item.infoTxt = contentTrans:Find("InfoTxt"):GetComponent(TypeText)
        item.huIconGO = contentTrans:Find("HuIcon").gameObject
        item.huIcon = item.huIconGO:GetComponent(TypeImage)
        item.inGame = contentTrans:Find("InGame").gameObject
        item.zhuangGO = contentTrans:Find("Zhuang").gameObject

        item.scoreGo = contentTrans:Find("Score").gameObject
        item.addTxtGO = contentTrans:Find("Score/AddTxt").gameObject
        item.addTxt = item.addTxtGO:GetComponent(TypeText)
        item.subTxtGO = contentTrans:Find("Score/SubTxt").gameObject
        item.subTxt = item.subTxtGO:GetComponent(TypeText)

        local headTrans = contentTrans:Find("Head")
        item.headIcon = headTrans:Find("HeadMask/Image"):GetComponent(TypeImage)
        item.headFrame = headTrans:Find("HeadFrame"):GetComponent(TypeImage)
        item.selfGo = headTrans:Find("Self").gameObject
    end
end

--获取玩家数据
function MahjongSingleSettlementPanel.GetPlayerData(data)
    local playerData = MahjongDataMgr.GetPlayerDataById(data.id)
    if playerData.id == nil then
        playerData = this.tempPlayerDatas[data.id]
        if playerData == nil then
            playerData = MahjongDataMgr.GetNewPlayerDataBySettlement(data)
            this.tempPlayerDatas[data.id] = playerData
        end
    end
    return playerData
end

--获取玩家牌数据
function MahjongSingleSettlementPanel.GetPlayerCardData(seatIndex, data)
    local playerCardData = MahjongPlayCardMgr.GetPlayerCardDataByIndex(seatIndex)
    if playerCardData == nil then
        playerCardData = this.tempPlayerCardDatas[seatIndex]
        if playerCardData == nil then
            playerCardData = MahjongPlayCardMgr.GetNewPlayerCardDataBySettlement(seatIndex, data)
            this.tempPlayerCardDatas[seatIndex] = playerCardData
        end
    end
    return playerCardData
end

--更新显示
function MahjongSingleSettlementPanel.UpdateItem(item, itemData)
    UIUtil.SetActive(item.gameObject, true)
    --检测Item
    this.CheckItem(item)

    --是否显示牌张
    local isShowCards = false
    --是否显示Info信息
    local isShowInfo = true
    --是否明牌显示
    local isDisplay = false
    --是否是主玩家
    local isMain = itemData.id == MahjongDataMgr.userId

    if not this.isGoldRoomEnd then
        --自己肯定要显示Info信息
        isShowInfo = isMain or false
        --没有胡牌则不显示详细信息，显示游戏中，胡牌的除直接的牌显示盖住的
        if itemData.huState == MahjongHuState.ZiMo or itemData.huState == MahjongHuState.Hu then
            isShowCards = true
            isDisplay = isMain
        end
    else
        isShowCards = true
        isDisplay = true
    end

    local playerData = this.GetPlayerData(itemData)

    -- UIUtil.SetActive(item.selfGo, isMain)
    item.bgAnim.enabled = this.isMaskCanClick
    local bgName = isMain and "ui_js_lb2" or "ui_js_lb1"
    item.bgImage.sprite = this.sprites[bgName]
    item.bgImage:SetNativeSize()

    item.nameTxt.text = playerData.name
    local fanTxt = ""
    local chaJiaoTxt = ""
    --头像
    Functions.SetHeadImage(item.headIcon, playerData.headUrl)
    --Functions.SetHeadFrame(item.headFrame, playerData.headFrame)

    --查叫
    local huState = itemData.huState
    if huState == MahjongHuState.YouJiao then
        chaJiaoTxt = " <color=#0f5902>有叫</color>"
        --有叫才显示番番数
        fanTxt = " <color=#FF0900>+" .. itemData.fan .. "番</color>"
    elseif huState == MahjongHuState.ChaJiao then
        --查叫的人不显示番数
        chaJiaoTxt = " <color=#0f5902>查叫</color>"
    else
        fanTxt = " <color=#FF0900>" .. itemData.fan .. "番</color>"
    end

    local huStr = ""
    --胡图标
    local huIconName = nil
    if huState == MahjongHuState.ZiMo then
        huIconName = "SsZiMo" .. itemData.huIndex
        huStr = "自摸"
    elseif huState == MahjongHuState.Hu then
        huIconName = "SsHu" .. itemData.huIndex
        huStr = "接炮"
    end

    if huIconName == nil then
        UIUtil.SetActive(item.huIconGO, false)
    else
        UIUtil.SetActive(item.huIconGO, true)
        item.huIcon.sprite = this.sprites[huIconName]
        item.huIcon:SetNativeSize()
    end

    --分数
    local score = tonumber(itemData.score)
    if score < 0 then
        UIUtil.SetActive(item.addTxtGO, false)
        UIUtil.SetActive(item.subTxtGO, true)
        item.subTxt.text = MahjongUtil.CheckResultScore(score)
    else
        UIUtil.SetActive(item.addTxtGO, true)
        UIUtil.SetActive(item.subTxtGO, false)
        item.addTxt.text = MahjongUtil.CheckResultScore(score)
    end

    --庄
    local isZhuang = this.data.zhuang == itemData.id
    UIUtil.SetActive(item.zhuangGO, isZhuang)

    --信息处理
    local infoStr = nil
    local length = 0

    if isShowInfo then
        local huRuleName = nil
        if itemData.huRules ~= nil then
            length = #itemData.huRules
            for i = 1, length do
                huRuleName = MahjongHuRuleName[itemData.huRules[i]]
                if huRuleName ~= nil then
                    if infoStr == nil then
                        infoStr = " (" .. huRuleName
                    else
                        infoStr = infoStr .. " " .. huRuleName
                    end
                else
                    LogWarn(">> MahjongSingleSettlementPanel.UpdateItem > ", itemData.huRules[i])
                end
            end
            if infoStr ~= nil then
                infoStr = infoStr .. ") "
            end
        end
    end
    if infoStr == nil then
        infoStr = ""
    end

    --杠信息
    local gangStr = ""
    if isShowInfo then
        if itemData.gangs ~= nil then
            local temp = nil
            local typeStr = nil
            length = #itemData.gangs
            for i = 1, length do
                temp = itemData.gangs[i]
                typeStr = MahjongGangName[temp.type]
                if typeStr ~= nil then
                    gangStr = gangStr .. typeStr .. tonumber(temp.num) .. " "
                end
            end
        end
    end

    local dianHuStr = ""
    local tempDianHuData = this.dianHuData[itemData.id]
    if tempDianHuData ~= nil then
        for i = 1, #tempDianHuData do
            dianHuStr = dianHuStr .. "点" .. tempDianHuData[i] .. "胡 "
        end
    end

    if string.IsNullOrEmpty(infoStr) then
        huStr = huStr .. " "
    end

    if isShowCards then
        --胡牌类型、牌型字段、根（杠）、点炮顺序
        item.infoTxt.text = huStr .. infoStr .. gangStr .. dianHuStr .. fanTxt .. chaJiaoTxt
    else
        item.infoTxt.text = ""
    end

    this.UpdateCards(item, itemData, isShowCards, isDisplay)
end

--更新牌数据
function MahjongSingleSettlementPanel.UpdateCards(item, itemData, isShowCards, isDisplay)
    if item.cardItems ~= nil then
        item.cardItems = ClearObjList(item.cardItems)
    else
        item.cardItems = {}
    end

    if not isShowCards then
        UIUtil.SetActive(item.inGame, true)
        --只显示游戏中
        return
    else
        UIUtil.SetActive(item.inGame, false)
    end

    local x = 0
    local data = nil
    local gameObject = nil
    --左手牌
    if itemData.left ~= nil then
        for i = 1, #itemData.left do
            data = itemData.left[i]
            gameObject = this.CreateOperationCards(i, data, item.cardsTrans)
            table.insert(item.cardItems, gameObject)
            UIUtil.SetAnchoredPosition(gameObject, x, 0)
            x = x + OperationWidth
        end
    end

    local playerData = this.GetPlayerData(itemData)
    local playerCardData = this.GetPlayerCardData(playerData.seatIndex, itemData)

    --手牌
    if itemData.mid ~= nil and playerCardData ~= nil then
        --用于数据可能被清除，需要重新设置定缺
        playerCardData:SetDingQue(playerData.dingQue)
        local result = playerCardData:CheckMidCards(itemData.mid)
        for i = 1, #result do
            data = result[i]
            gameObject = this.CreateCards(data, item.cardsTrans, isDisplay)
            table.insert(item.cardItems, gameObject)
            UIUtil.SetAnchoredPosition(gameObject, x, 0)
            x = x + CardWidth
        end
    end

    --摸牌或者胡牌
    x = x + NewCardGap
    if IsNumber(itemData.right) and itemData.right > 0 then
        local cardData = MahjongDataMgr.GetCardData(itemData.right)
        --处理摸牌的定缺
        if MahjongUtil.IsTingYongCard(cardData.key) then
            cardData.isTingYong = true
            cardData.isDingQue = false
        else
            cardData.isTingYong = false
            cardData.isDingQue = cardData.type == playerData.dingQue
        end
        gameObject = this.CreateCards(cardData, item.cardsTrans, true)
        table.insert(item.cardItems, gameObject)
        UIUtil.SetAnchoredPosition(gameObject, x, 0)
    end
end

--创建操作牌
function MahjongSingleSettlementPanel.CreateCards(cardData, parent, isDisplay)
    if not isDisplay then
        --处理不显示的牌
        cardData = MahjongDataMgr.UnknownCardData
    end

    local go = CreateGO(this.cardItemPrefab, parent, tostring(cardData.id))
    this.SetImage(go, cardData.key, false, cardData.isDingQue, cardData.isTingYong)
    return go
end

--设置图片
function MahjongSingleSettlementPanel.SetImage(gameObject, key, isCover, isDingQue, isTingYong)
    local cardFrame = gameObject.transform:Find("CardFrame"):GetComponent(TypeImage)
    local image = gameObject.transform:Find("CardIcon"):GetComponent(TypeImage)
    UIUtil.SetActive(image.gameObject, not isCover)
    local name = isCover and  "op_1_0" or "face_1_bottom_stand"
    cardFrame.sprite = MahjongResourcesMgr.GetSingleCardFrameSprite(name)
    --盖牌不显示麻将字元素
    if not isCover then
        image.sprite = MahjongResourcesMgr.GetCardSprite(key)
    end
    --处理定缺牌的颜色
    if isDingQue then
        MahjongUtil.SetMaskColor(image, MahjongMaskColorType.Gray)
    elseif isTingYong then
        MahjongUtil.SetMaskColor(image, MahjongMaskColorType.None)
        local markGo = gameObject.transform:Find("Mark").gameObject
        UIUtil.SetActive(markGo, true)
    else
        MahjongUtil.SetMaskColor(image, MahjongMaskColorType.None)
    end
end

--设置牌，通过ID
function MahjongSingleSettlementPanel.SetCardItemById(gameObject, id)
    local cardData = MahjongDataMgr.GetCardData(id)
    local isTingYong = MahjongUtil.IsTingYongCard(cardData.key)
    this.SetImage(gameObject, cardData.key, false, false, isTingYong)
end

--创建操作牌
function MahjongSingleSettlementPanel.CreateOperationCards(index, data, parent)
    local go = CreateGO(this.operationItemPrefab, parent, tostring(index))
    local trans = go.transform

    local itemGO = nil
    local cardItems = {}
    for i = 1, 4 do
        local name = tostring(i)
        itemGO = trans:Find(name).gameObject
        table.insert(cardItems, itemGO)
    end

    local cardData = nil
    local sprite = nil
    if data.type == MahjongOperateCode.PENG then
        cardData = MahjongDataMgr.GetCardData(data.k1)
        for i = 1, 3 do
            this.SetImage(cardItems[i], cardData.key, false)
        end
    elseif data.type == MahjongOperateCode.FlyChickenChi then
        local cardData1 = MahjongDataMgr.GetCardData(data.k1)
        local cardData2 = MahjongDataMgr.GetCardData(data.k1)
        local cardData3 = MahjongDataMgr.GetCardData(data.k1)
        this.SetImage(cardItems[1], cardData1.key, false)
        this.SetImage(cardItems[2], cardData2.key, false)
        this.SetImage(cardItems[3], cardData3.key, false)
    elseif data.type == MahjongOperateCode.GANG or data.type == MahjongOperateCode.GANG_IN then
        cardData = MahjongDataMgr.GetCardData(data.k1)
        for i = 1, 4 do
            this.SetImage(cardItems[i], cardData.key, false)
        end
        UIUtil.SetActive(cardItems[4], true)
    elseif data.type == MahjongOperateCode.GANG_ALL_IN then
        --暗杠，背面3张，明第4张
        for i = 1, 3 do
            this.SetImage(cardItems[i], nil, true)
        end
        this.SetCardItemById(cardItems[4], data.k1)
        UIUtil.SetActive(cardItems[4], true)
    elseif data.type == MahjongOperateCode.SPC_PENG then
        --幺鸡碰
        this.SetCardItemById(cardItems[1], data.k1)
        this.SetCardItemById(cardItems[2], data.k2)
        this.SetCardItemById(cardItems[3], data.k3)
    elseif data.type == MahjongOperateCode.SPC_GANG_ALL_IN then
        --幺鸡杠，包括暗杠，所有的牌都是明牌
        --幺鸡玩法，第一个幺鸡放第一个位置，第二个幺鸡放第3个位置，第三个幺鸡放第2位置，主牌放第4个位置
        this.HandleYaoJiGang(cardItems, data, true)
    else
        --其他幺鸡杠全是明牌
        this.HandleYaoJiGang(cardItems, data, false)
    end

    return go
end

--处理幺鸡杠
function MahjongSingleSettlementPanel.HandleYaoJiGang(cardItems, data, isAnGang)
    --临时牌数据
    local tempData = nil
    --主牌数据
    local cardData = nil
    --听用牌数量
    local tingYongNum = 0

    local cards = {}
    table.insert(cards, MahjongDataMgr.GetCardData(data.k1))
    table.insert(cards, MahjongDataMgr.GetCardData(data.k2))
    table.insert(cards, MahjongDataMgr.GetCardData(data.k3))
    table.insert(cards, MahjongDataMgr.GetCardData(data.k4))

    for i = 1, 4 do
        tempData = cards[i]
        if MahjongDataMgr.tingYongCardDict[tempData.key] == true then
            tempData.isTingYong = true
            tingYongNum = tingYongNum + 1
        else
            tempData.isTingYong = false
            cardData = tempData
        end
        tempData:UpdateSort()
    end
    table.sort(cards, MahjongUtil.CardDataSort)

    --Log(">> MahjongSingleSettlementPanel.HandleYaoJiGang ", isAnGang, tingYongNum)
    if isAnGang then
        --如果是暗杠，非幺鸡和非第4张都要盖住显示
        for i = 1, 3 do
            tempData = cards[i]
            if tempData.isTingYong then
                this.SetImage(cardItems[i], tempData.key, false, false, tempData.isTingYong)
            else
                this.SetImage(cardItems[i], nil, true)
            end
        end
        this.SetImage(cardItems[4], cardData.key, false)
    else
        for i = 1, 4 do
            tempData = cards[i]
            this.SetImage(cardItems[i], tempData.key, false, false, tempData.isTingYong)
        end
    end
    UIUtil.SetActive(cardItems[4], true)
end

--=============================================================
function MahjongSingleSettlementPanel.CheckScreenshot(itemData)
    if itemData.huRules ~= nil then
        local length = #itemData.huRules
        local huRuleName = ""
        for i = 1, length do
            huRuleName = MahjongHuRuleShareImageName[itemData.huRules[i]]
            if not string.IsNullOrEmpty(huRuleName) then
                return true
            end
        end
    end
    return false
end

------------------------------------------------------------------
--
--设置倒计时
function MahjongSingleSettlementPanel.SetReadyCountdown(time)
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
function MahjongSingleSettlementPanel.StartReadyCountdownTimer()
    if this.readyCountdownTimer == nil then
        this.readyCountdownTimer = Timing.New(this.OnReadyCountdownTimer, 0.33)
    end
    this.readyCountdownTimer:Start()
end

function MahjongSingleSettlementPanel.StopReadyCountdownTimer()
    if this.readyCountdownTimer ~= nil then
        this.readyCountdownTimer:Stop()
    end
end

function MahjongSingleSettlementPanel.OnReadyCountdownTimer()
    this.tempTime = this.readyTime - (Time.realtimeSinceStartup - this.readySetTime)
    this.tempTime = math.ceil(this.tempTime)
    if this.tempTime < 0 then
        this.tempTime = 0
        this.StopReadyCountdownTimer()
        this.OnNextBtnClick()
        return
    end
    this.tempTime = math.abs(this.tempTime)
    if this.tempTime ~= this.readyDisplayTime then
        this.readyDisplayTime = this.tempTime
        --显示
        this.readyCountdownLabel.text = this.readyDisplayTime
    end
end