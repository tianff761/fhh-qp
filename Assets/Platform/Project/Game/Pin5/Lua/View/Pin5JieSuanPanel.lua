Pin5JieSuanPanel = ClassPanel("Pin5JieSuanPanel")
local this = Pin5JieSuanPanel
local mSelf = nil
this.againBtnClickTime = 0

local ColorWin = Color(134 / 255, 8 / 255, 8 / 255)
local ColorLose = Color(21 / 255, 41 / 255, 68 / 255)
local InfoFormat = "房间号:%s 玩法:%s分/%s/%s"

function Pin5JieSuanPanel:OnInitUI()
    mSelf = self
    self:InitPanel()
    self:AddClickMsg()
end

--初始化面板--
function Pin5JieSuanPanel:InitPanel()
    local node = self.transform:Find("Node")
    local background = node:Find("Background").gameObject
    this.backgroundImage = background:GetComponent(TypeImage)
    Functions.SetBackgroundAdaptation(this.backgroundImage)

    self.label1 = node:Find("Label1"):GetComponent("Text")
    self.label2 = node:Find("Label2"):GetComponent("Text")

    self.btnLayout = node:Find("BtnLayout")
    self.backBtn = self.btnLayout:Find("BackButton").gameObject
    -- self.saveBtn = self.btnLayout:Find("SaveButton").gameObject
    self.PlayAgainBtn = self.btnLayout:Find("PlayAgainBtn").gameObject

    self.itemContent = node:Find("ScrollView/Viewport/Content")
    self.itemContentRectTransform = self.itemContent:GetComponent(TypeRectTransform)
    self.itemContentSizeDelta = self.itemContentRectTransform.sizeDelta
    self.itemPrefab = self.itemContent:Find("Item").gameObject

    local itemRectTransform = self.itemPrefab:GetComponent(TypeRectTransform)
    self.itemWidth = itemRectTransform.sizeDelta.x

    
    --图标
    local atlas = node:Find("Atlas"):GetComponent("UISpriteAtlas")
    local tempSprites = atlas.sprites:ToTable()
    local sprite = nil
    self.sprites = {}
    for i = 1, #tempSprites do
        sprite = tempSprites[i]
        if sprite ~= nil then
            self.sprites[sprite.name] = sprite
        else
            LogWarn(">> MahjongTotalSettlementPanel > sprite == nil > index = " .. i)
        end
    end

    self.items = {}
end

function Pin5JieSuanPanel:OnOpened()
    mSelf = self
    self.AddListenerEvent()

    local dataLength = 0
    local data = nil
    local item = nil
    if IsTable(Pin5RoomData.netJieSuanData) and #Pin5RoomData.netJieSuanData ~= 0 then
        local list = {}
        for i = 1, #Pin5RoomData.netJieSuanData do
            data = Pin5RoomData.netJieSuanData[i]
            if data.playerId == Pin5RoomData.mainId then
                table.insert(list, 1, data)
            else
                table.insert(list, data)
            end
        end

        self:ParseInfo()
        self:SetTopInfo()

        dataLength = #list

        local width = 20 + dataLength * self.itemWidth + (dataLength - 1) * 6
        if width < UIConst.uiCanvasWidth then
            width = UIConst.uiCanvasWidth
        end
        self.itemContentSizeDelta.x = width
        self.itemContentRectTransform.sizeDelta = self.itemContentSizeDelta

        for i = 1, dataLength do
            data = list[i]
            item = mSelf.items[i]
            if item == nil then
                item = mSelf.CreateItem(i)
            end
            mSelf.SetItem(item, data)
            UIUtil.SetActive(item.bg.gameObject, false)
        end
    end

    for i = dataLength + 1, #mSelf.items do
        item = mSelf.items[i]
        if item.data ~= nil then
            item.data = nil
            UIUtil.SetActive(item.gameObject, false)
        end
    end
    self.SetMoveAnim(dataLength)
end


--启动倒计时Timer,设置移动动画
function Pin5JieSuanPanel.SetMoveAnim(maxIndex)
    UIUtil.SetLocalScale(mSelf.btnLayout.gameObject, 0, 0, 1)
    local startIndex = 0
    if mSelf.bgMoveTimer == nil then
        mSelf.bgMoveTimer = Timing.New(
        function ()
            if startIndex >= maxIndex then
                mSelf.StopBGMoveTimer()
                return
            end
            startIndex = startIndex + 1
            local item = mSelf.items[startIndex]
            if item == nil then
                return
            end
            UIUtil.SetActive(item.bg.gameObject, true)
            UIUtil.SetAnchoredPosition(item.bg.gameObject, -50, 0)
            item.bg.transform:DOLocalMoveX(0, 0.25, true):OnComplete(function ()
                if startIndex >= maxIndex then
                    mSelf.btnLayout:DOScale(Vector3(1, 1, 1), 0.25)
                end
            end)
        end,
        0.15)
    end
    mSelf.bgMoveTimer:Restart()
end

--停止倒计时Timer
function Pin5JieSuanPanel.StopBGMoveTimer()
    if mSelf.bgMoveTimer ~= nil then
        mSelf.bgMoveTimer:Stop()
        mSelf.bgMoveTimer = nil
    end
end


function Pin5JieSuanPanel.AddListenerEvent()
    AddEventListener(CMD.Tcp.Union.S2C_AGAIN, mSelf.OnGetPlayAgainCallBack)
end

function Pin5JieSuanPanel:RemoveListenerEvent()
    RemoveEventListener(CMD.Tcp.Union.S2C_AGAIN, mSelf.OnGetPlayAgainCallBack)
end

function Pin5JieSuanPanel:OnClosed()
    Pin5RoomData.netJieSuanData = nil
    self.RemoveListenerEvent()
    self.StopBGMoveTimer()
end

function Pin5JieSuanPanel:OnDestroy()
    Pin5RoomData.netJieSuanData = nil
end

function Pin5JieSuanPanel.DelaySetPlayAgainBtn()
    local btn = mSelf.PlayAgainBtn:GetComponent(TypeButton)
    btn.interactable = false
    coroutine.wait(2)
    btn.interactable = true
end

function Pin5JieSuanPanel:ParseInfo()
    --查找大赢家 土豪
    local maxScore = 0
    local minScore = 0
    for i = 1, #Pin5RoomData.netJieSuanData do
        Pin5RoomData.netJieSuanData[i].score = tonumber(Pin5RoomData.netJieSuanData[i].score)
        if Pin5RoomData.netJieSuanData[i].score > maxScore then
            maxScore = Pin5RoomData.netJieSuanData[i].score
            self.winer = Pin5RoomData.netJieSuanData[i].playerId
        end
        if Pin5RoomData.netJieSuanData[i].score < minScore then
            minScore = Pin5RoomData.netJieSuanData[i].score
            self.loser = Pin5RoomData.netJieSuanData[i].playerId
        end
    end
end

--设置顶部数据信息
function Pin5JieSuanPanel:SetTopInfo()
    local temp = Pin5RoomData.netJieSuanData
    self.label1.text = string.format(InfoFormat, temp.roomCode, temp.difen, temp.jushu, temp.model)
    -- self.roomCodeText.text = Pin5RoomData.netJieSuanData.roomCode
    -- self.difenText.text = Pin5RoomData.netJieSuanData.difen
    -- self.modelText.text = Pin5RoomData.netJieSuanData.model
    -- self.juShuText.text = Pin5RoomData.netJieSuanData.jushu

    self.label2.text = temp.manCount .. "人房 " .. os.date("%Y-%m-%d %H:%M", temp.endTime)
end

--挂载点击事件
function Pin5JieSuanPanel:AddClickMsg()
    self:AddOnClick(self.backBtn, mSelf.OnClickBackLobbyBtn)
    -- self:AddOnClick(self.saveBtn, mSelf.OnClickSaveBtn)
    --再来一局
    self:AddOnClick(self.PlayAgainBtn, mSelf.OnPlayAgainBtnClick)
end

--点击返回大厅
function Pin5JieSuanPanel.OnClickBackLobbyBtn()
    if GameSceneManager.IsRoomScene() then
        Pin5Room.ExitRoom()
        mSelf:Close()
    else
        mSelf:Close()
    end
end

--点击保存
function Pin5JieSuanPanel.OnClickSaveBtn()
    --截图
    local temp = Functions.GetScreenshotSize(1114, 680)
    PlatformHelper.GetScreenshotPngBytes(function(bytes)
        AppPlatformHelper.SaveImageToPhone(bytes, "")
    end, temp.x, temp.y, temp.width, temp.height)
end

--创建Item
function Pin5JieSuanPanel.CreateItem(index)
    local item = {}
    item.gameObject = CreateGO(mSelf.itemPrefab, mSelf.itemContent, tostring(index))
    item.transform = item.gameObject.transform

    item.bg = item.transform:Find("Bg")
    item.bgImage = item.bg:GetComponent(TypeImage)
    item.headImage = item.bg:Find("Head/HeadMask/Icon"):GetComponent("Image")

    item.nameText = item.bg:Find("Name"):GetComponent("Text")
    item.idText = item.bg:Find("ID"):GetComponent("Text")
    item.selfImageGo = item.bg:Find("Self").gameObject

    item.addTxt = item.bg:Find("Score/AddTxt"):GetComponent(TypeText)
    item.subTxt = item.bg:Find("Score/SubTxt"):GetComponent(TypeText)

    item.bigWiner = item.bg:Find("BigWiner").gameObject
    item.owner = item.bg:Find("Owner").gameObject
    item.tyrant = item.bg:Find("Tyrant").gameObject


    item.descNode = item.bg:Find("DescNode")
    item.descList = {}
    for i = 1, 3, 1 do
        local list = {}
        list.tips = item.descNode:Find("Desc"..i.."/Tips"):GetComponent(TypeText)
        list.txt = item.descNode:Find("Desc"..i.."/Text"):GetComponent(TypeText)
        list.line = item.descNode:Find("Desc"..i.."/Line"):GetComponent(TypeImage)
        table.insert(item.descList, list)
    end

    table.insert(mSelf.items, item)
    return item
end

--设置某个item的信息
function Pin5JieSuanPanel.SetItem(item, data)
    if item == nil or data == nil then
        return
    end
    item.data = data
    data.score = tonumber(data.score)

    local isWin = data.score >= 0
    local bgName = isWin and "ui_js_lb_2" or "ui_js_lb_1"
    item.bgImage.sprite = mSelf.sprites[bgName]
    item.bgImage:SetNativeSize()

    item.nameText.text = data.name
    item.idText.text = data.uId

    local color = isWin and Color(144 / 255, 96 / 255, 61 / 255, 1) or Color(81 / 255, 114 / 255, 174 / 255, 1)
    item.nameText.color = color
    item.idText.color = color

    UIUtil.SetActive(item.addTxt.gameObject, data.score >= 0)
    UIUtil.SetActive(item.subTxt.gameObject, data.score < 0)

    if data.score < 0 then
        item.subTxt.text = tostring(data.score)
    else
        item.addTxt.text = "+" .. tostring(data.score)
    end

    --设置头像
    Functions.SetHeadImage(item.headImage, Functions.CheckJoinPlayerHeadUrl(data.headUrl))
    UIUtil.SetActive(item.owner, Pin5RoomData.netJieSuanData.owner == data.playerId)
    UIUtil.SetActive(item.bigWiner, mSelf.winer == data.playerId)
    -- UIUtil.SetActive(item.tyrant, self.loser == data.playerId)
    UIUtil.SetActive(item.selfImageGo, data.playerId == Pin5RoomData.mainId)


    item.descList[1].txt.text = tostring(data.winNum)
    item.descList[2].txt.text = tostring(data.loseNum)
    item.descList[3].txt.text = tostring(data.tieNum)


    local lineName = isWin and "ui_js_lb_2_fgx" or "ui_js_lb_1_fgx"
    for i = 1, 3, 1 do
        local list = item.descList[i]
        list.tips.color = color
        list.txt.color = color
        list.line.sprite = mSelf.sprites[lineName]
    end

    UIUtil.SetActive(item.gameObject, true)
end

function Pin5JieSuanPanel.OnPlayAgainBtnClick()
    if Time.realtimeSinceStartup - this.againBtnClickTime > 2 then
        this.againBtnClickTime = Time.realtimeSinceStartup
        if Pin5RoomData.groupId ~= 0 then
            Waiting.Show("加入新房间中", WaitingLevel.Normal, 6)
            UnionManager.SendPlayAgain(Pin5RoomData.groupId, GameType.Pin5, Pin5RoomData.Note, Pin5RoomData.diFen)
        else
            Toast.Show("联盟不存在，加入游戏失败")
        end
    else
        Toast.Show("请稍后...")
    end
end

function Pin5JieSuanPanel.OnGetPlayAgainCallBack(data)
    if data.code == 0 then
        --Pin5Room.ExitRoom()
        --mSelf:Close()
    else
        Waiting.CheckHide()
        UnionManager.ShowError(data.code)
    end
end
