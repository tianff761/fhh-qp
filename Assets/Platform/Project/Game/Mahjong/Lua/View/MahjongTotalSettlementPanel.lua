MahjongTotalSettlementPanel = ClassPanel("MahjongTotalSettlementPanel")
MahjongTotalSettlementPanel.Instance = nil
--
local this = MahjongTotalSettlementPanel
this.againBtnClickTime = 0
--
--初始属性数据
function MahjongTotalSettlementPanel:InitProperty()
    self.items = {}
    this.sprites = {}
end

--UI初始化
function MahjongTotalSettlementPanel:OnInitUI()
    this = self
    this:InitProperty()

    local nodeTrans = self:Find("Content/Node")

    this.shareBtn = nodeTrans:Find("BtnLayout/ShareButton").gameObject
    this.backBtn = nodeTrans:Find("BtnLayout/BackButton").gameObject
    this.PlayAgainBtn = nodeTrans:Find("BtnLayout/PlayAgainBtn").gameObject

    this.iconTea = nodeTrans:Find("IconTea").gameObject
    this.iconClub = nodeTrans:Find("IconClub").gameObject
    this.infoTxt = nodeTrans:Find("InfoTxt"):GetComponent(TypeText)
    this.playWayTxt = nodeTrans:Find("PlayWayTxt"):GetComponent(TypeText)

    local itemsTrans = nodeTrans:Find("Items")
    for i = 1, 4 do
        local item = {}
        item.transform = itemsTrans:Find(tostring(i))
        item.gameObject = item.transform.gameObject
        this.items[i] = item
    end

    --图标
    local atlas = nodeTrans:Find("Atlas"):GetComponent("UISpriteAtlas")
    local tempSprites = atlas.sprites:ToTable()
    local sprite = nil
    for i = 1, #tempSprites do
        sprite = tempSprites[i]
        if sprite ~= nil then
            this.sprites[sprite.name] = sprite
        else
            LogWarn(">> MahjongTotalSettlementPanel > sprite == nil > index = " .. i)
        end
    end

    this.AddUIListenerEvent()
end

--当面板开启开启时
function MahjongTotalSettlementPanel:OnOpened()
    MahjongTotalSettlementPanel.Instance = self
    self:AddListenerEvent()

    this.data = MahjongDataMgr.settlementData
    if this.data == nil then
        this.SetDefaultUI()
        Alert.Show("请到战绩界面查看结算数据")
    else
        this.UpdateData()
    end

    UIUtil.SetActive(this.PlayAgainBtn, MahjongDataMgr.groupId ~= 0)
end

--当面板关闭时调用
function MahjongTotalSettlementPanel:OnClosed()
    MahjongTotalSettlementPanel.Instance = nil

    self:RemoveListenerEvent()
end

------------------------------------------------------------------
--
--关闭
function MahjongTotalSettlementPanel.Close()
    PanelManager.Close(MahjongPanelConfig.TotalSettlement)
end
--
function MahjongTotalSettlementPanel.AddListenerEvent()
    AddEventListener(CMD.Tcp.Union.S2C_AGAIN, this.OnGetPlayAgainCallBack)
end
--
function MahjongTotalSettlementPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Tcp.Union.S2C_AGAIN, this.OnGetPlayAgainCallBack)
end

--UI相关事件
function MahjongTotalSettlementPanel.AddUIListenerEvent()
    this:AddOnClick(this.shareBtn, this.OnShareBtnClick)
    this:AddOnClick(this.backBtn, this.OnBackBtnClick)
    this:AddOnClick(this.PlayAgainBtn, this.OnPlayAgainBtnClick)
end

------------------------------------------------------------------
--
--分享按钮点击
function MahjongTotalSettlementPanel.OnShareBtnClick()
    --分享截图
    local data = {
        roomCode = MahjongDataMgr.roomId,
        type = 2,
        ScreenshotScale = { w = 1172 - 16, h = 700 - 16 },
    }
    PanelManager.Open(PanelConfig.RoomInvite, data)
end

--返回大厅按钮点击
function MahjongTotalSettlementPanel.OnBackBtnClick()
    MahjongRoomMgr.ExitRoom()
end

function MahjongTotalSettlementPanel.OnPlayAgainBtnClick()
    if Time.realtimeSinceStartup - this.againBtnClickTime > 2 then
        this.againBtnClickTime = Time.realtimeSinceStartup
        if MahjongDataMgr.groupId ~= 0 then
            UnionManager.SendPlayAgain(MahjongDataMgr.groupId, GameType.Mahjong, MahjongDataMgr.settlementData.note, MahjongDataMgr.baseScore)
        else
            Toast.Show("联盟不存在，加入游戏失败")
        end
    else
        Toast.Show("请稍后...")
    end
end

function MahjongTotalSettlementPanel.OnGetPlayAgainCallBack(data)
    if data.code == 0 then
        MahjongRoomMgr.ExitRoom()
        this:Close()
    else
        UnionManager.ShowError(data.code)
    end
end
------------------------------------------------------------------
--
--设置默认UI
function MahjongTotalSettlementPanel.SetDefaultUI()
    UIUtil.SetActive(this.iconTea, false)
    this.infoTxt.text = ""
    for i = 1, 4 do
        UIUtil.SetActive(this.items[i].gameObject, false)
    end
end

--更新数据
function MahjongTotalSettlementPanel.UpdateData()

    if MahjongDataMgr.roomType == RoomType.Club then
        UIUtil.SetActive(this.iconTea, false)
        UIUtil.SetActive(this.iconClub, true)
    elseif MahjongDataMgr.roomType == RoomType.Tea then
        UIUtil.SetActive(this.iconTea, true)
        UIUtil.SetActive(this.iconClub, false)
    else
        UIUtil.SetActive(this.iconTea, false)
        UIUtil.SetActive(this.iconClub, false)
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

    local infoStr = "房间号:" .. this.data.id
    infoStr = infoStr .. " 局数:" .. index .. "/" .. MahjongDataMgr.gameTotal
    infoStr = infoStr .. " " .. time
    this.infoTxt.text = infoStr

    --显示玩法
    local playWayInfo = Functions.ParseGameRule(GameType.Mahjong, MahjongDataMgr.rules, MahjongDataMgr.gpsType)
    this.playWayTxt.text = playWayInfo.rule

    --大赢家的最大分数
    this.winMaxScore = 1
    --点炮的最大次数
    this.dpMax = 1
    local index = 1
    if this.data.zj ~= nil then
        local tempData = nil
        local length = #this.data.zj
        for i = 1, length do
            tempData = this.data.zj[i]
            tempData.total = tonumber(tempData.total)
            if tempData.total > this.winMaxScore then
                this.winMaxScore = tempData.total
            end
            if tempData.dp > this.dpMax then
                this.dpMax = tempData.dp
            end
        end

        for i = 1, length do
            tempData = this.data.zj[i]
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
function MahjongTotalSettlementPanel.CheckItem(item)
    --处理UI查找赋值
    if item.inited ~= true then
        item.inited = true

        item.bg = item.transform:Find("Bg")
        item.bgImage = item.bg:GetComponent(TypeImage)
        item.headIcon = item.bg:Find("Head/HeadMask/Image"):GetComponent(TypeImage)
        item.headFrame = item.bg:Find("Head/Frame"):GetComponent(TypeImage)
        item.nameTxt = item.bg:Find("NameText"):GetComponent(TypeText)
        item.idTxt = item.bg:Find("IdText"):GetComponent(TypeText)

        item.selfGo = item.bg:Find("Self").gameObject
        item.ownerGO = item.bg:Find("Owner").gameObject
        item.iconZjpsGO = item.bg:Find("IconZjps").gameObject
        item.iconWinGO = item.bg:Find("IconWin").gameObject

        --麻将结算
        item.mJNode = item.bg:Find("MJNode")
        item.descList = {}
        for i = 1, 6, 1 do
            local list = {}
            list.tips = item.mJNode:Find("Desc"..i.."/Tips"):GetComponent(TypeText)
            list.txt = item.mJNode:Find("Desc"..i.."/Text"):GetComponent(TypeText)
            list.line = item.mJNode:Find("Desc"..i.."/Line"):GetComponent(TypeImage)
            table.insert(item.descList, list)
        end

        item.addTxtGO = item.bg:Find("Score/AddTxt").gameObject
        item.addTxt = item.addTxtGO:GetComponent(TypeText)
        item.subTxtGO = item.bg:Find("Score/SubTxt").gameObject
        item.subTxt = item.subTxtGO:GetComponent(TypeText)
    end
end
--更新显示
function MahjongTotalSettlementPanel.UpdateItem(item, itemData)
    UIUtil.SetActive(item.gameObject, true)
    this.CheckItem(item)

    local playerData = MahjongDataMgr.GetPlayerDataById(itemData.id)
    item.nameTxt.text = playerData.name
    item.idTxt.text = "ID:" .. playerData.id

    --设置头像
    Functions.SetHeadImage(item.headIcon, playerData.headUrl)
    --设置头像框
    --Functions.SetHeadFrame(item.headFrame, playerData.headFrame)

    --处理自己标识
    local isMain = itemData.id == MahjongDataMgr.userId
    UIUtil.SetActive(item.selfGo, false)

    local bgName = isMain and "ui_js_lb_2" or "ui_js_lb_1"
    item.bgImage.sprite = this.sprites[bgName]
    item.bgImage:SetNativeSize()

    --分数
    local score = tonumber(itemData.total)
    if score < 0 then
        UIUtil.SetActive(item.addTxtGO, false)
        UIUtil.SetActive(item.subTxtGO, true)
        item.subTxt.text = MahjongUtil.CheckResultScore(score)
    else
        UIUtil.SetActive(item.addTxtGO, true)
        UIUtil.SetActive(item.subTxtGO, false)
        item.addTxt.text = MahjongUtil.CheckResultScore(score)
    end

    --处理大赢家和最佳炮手图标
    local isShowWin = itemData.total == this.winMaxScore
    UIUtil.SetActive(item.iconWinGO, isShowWin)
    UIUtil.SetActive(item.iconZjpsGO, itemData.dp == this.dpMax)
    --处理房主图标
    UIUtil.SetActive(item.ownerGO, this.data.owner == itemData.id)
    --处理次数
    item.descList[1].txt.text = tostring(itemData.zm)
    item.descList[2].txt.text = tostring(itemData.jp)
    item.descList[3].txt.text = tostring(itemData.dp)
    item.descList[4].txt.text = tostring(itemData.ag)
    item.descList[5].txt.text = tostring(itemData.mg)
    item.descList[6].txt.text = tostring(itemData.cj)

    local color = isMain and Color(144 / 255, 88 / 255, 32 / 255, 1) or Color(81 / 255, 114 / 255, 174 / 255, 1)
    local lineName = isMain and "ui_js_lb_2_fgx" or "ui_js_lb_1_fgx"
    for i = 1, 6, 1 do
        local list = item.descList[i]
        list.tips.color = color
        list.txt.color = color
        list.line.sprite = this.sprites[lineName]
    end
end