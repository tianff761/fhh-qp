LYCJieSuanPanel = ClassPanel("LYCJieSuanPanel")
local this = LYCJieSuanPanel
local mSelf = nil
this.againBtnClickTime = 0

function LYCJieSuanPanel:OnInitUI()
    mSelf = self
    this.playItems = {}
    self:InitPanel()
    self:AddClickMsg()
end

--初始化面板--
function LYCJieSuanPanel:InitPanel()
    local content = self.transform:Find("Content")
    -----------------------------------------------------------------Top
    local node = content:Find("Node")
    self.roomCodeText = node:Find("RoomCode"):GetComponent("Text")
    self.difenText = node:Find("DiFen"):GetComponent("Text")
    self.modelText = node:Find("Model"):GetComponent("Text")
    self.juShuText = node:Find("JuShu"):GetComponent("Text")
    self.timeText = node:Find("Time"):GetComponent("Text")
    self.backBtn = node:Find('BackButton').gameObject
    self.saveBtn = node:Find('SaveButton').gameObject
    self.PlayAgainBtn = node:Find('PlayAgainBtn').gameObject
    this.PlayAgainBtn = self.PlayAgainBtn
    -----------------------------------------------------------------Content
    this.itemContent = node:Find("ScrollView/Viewport/Content")
    this.itemContentRectTransform = this.itemContent:GetComponent(TypeRectTransform)
    this.itemPrefab = this.itemContent:Find("Item").gameObject
    self:AddListenerEvent()
end

function LYCJieSuanPanel:OnOpened()
    UIUtil.SetActive(this.itemContent.gameObject, false)
    UIUtil.SetActive(self.backBtn.gameObject, false)
    UIUtil.SetActive(self.PlayAgainBtn.gameObject, false)
    
    mSelf = self
    if IsTable(LYCRoomData.netJieSuanData) and #LYCRoomData.netJieSuanData ~= 0 then
        self:ParseInfo()
        self:SetTopInfo()
        self:UpdateItemInfo()

    end
    --coroutine.start(this.DelaySetPlayAgainBtn)
end

function LYCJieSuanPanel.DelaySetPlayAgainBtn()
    local btn = this.PlayAgainBtn:GetComponent(TypeButton)
    btn.interactable = false
    coroutine.wait(2)
    btn.interactable = true
end

function LYCJieSuanPanel:ParseInfo()
    --查找大赢家 土豪
    local maxScore = 0
    local minScore = 0
    for i = 1, #LYCRoomData.netJieSuanData do
        LYCRoomData.netJieSuanData[i].score = tonumber(LYCRoomData.netJieSuanData[i].score)
        if LYCRoomData.netJieSuanData[i].score > maxScore then
            maxScore = LYCRoomData.netJieSuanData[i].score
            self.winer = LYCRoomData.netJieSuanData[i].playerId
        end
        if LYCRoomData.netJieSuanData[i].score < minScore then
            minScore = LYCRoomData.netJieSuanData[i].score
            self.loser = LYCRoomData.netJieSuanData[i].playerId
        end
    end
end

--挂载点击事件
function LYCJieSuanPanel:AddClickMsg()
    self:AddOnClick(self.backBtn, this.OnClickBackLobbyBtn)
    self:AddOnClick(self.saveBtn, this.OnClickSaveBtn)
    --再来一局
    self:AddOnClick(self.PlayAgainBtn, this.OnPlayAgainBtnClick)
end

--点击返回大厅
function LYCJieSuanPanel.OnClickBackLobbyBtn()
    if GameSceneManager.IsRoomScene() then
        LYCRoom.ExitRoom()
        mSelf:Close()
    else
        mSelf:Close()
    end
end

--点击保存
function LYCJieSuanPanel.OnClickSaveBtn()
    --截图
    local temp = Functions.GetScreenshotSize(1114, 680)
    PlatformHelper.GetScreenshotPngBytes(function(bytes)
        AppPlatformHelper.SaveImageToPhone(bytes, "")
    end, temp.x, temp.y, temp.width, temp.height)
end

--设置顶部数据信息
function LYCJieSuanPanel:SetTopInfo()
    self.roomCodeText.text = LYCRoomData.netJieSuanData.roomCode
    self.difenText.text = LYCRoomData.netJieSuanData.difen
    self.modelText.text = LYCRoomData.netJieSuanData.model
    self.juShuText.text = LYCRoomData.netJieSuanData.jushu
    self.timeText.text = os.date("%Y-%m-%d %H:%M", LYCRoomData.netJieSuanData.endTime)
end


--刷新玩家信息
function LYCJieSuanPanel:UpdateItemInfo()
    local dataLength = #LYCRoomData.netJieSuanData
    local item = nil
    local data = nil
    for i = 1, dataLength do
        data = LYCRoomData.netJieSuanData[i]
        item = this.GetItem(i)
        self:SetItemInfo(item, data)
        UIUtil.SetActive(item.gameObject, true)
    end

    for i = dataLength + 1, #this.playItems do
        item = this.playItems[i]
        UIUtil.SetActive(item.gameObject, false)
    end

    --延时1.5秒显示
    if self.Timer == nil then
        self.Timer = Timing.New(
            function ()
                self.Timer:Stop()
                self.Timer = nil
                UIUtil.SetActive(this.itemContent.gameObject, true)
                UIUtil.SetActive(self.backBtn.gameObject, true)
                UIUtil.SetActive(self.PlayAgainBtn.gameObject, true)
            end
        , 0.9)
    end
    self.Timer:Start()
end

--获得显示项
function LYCJieSuanPanel.GetItem(index)
    local item = this.playItems[index]
    if item == nil then
        item = {}
        item.gameObject = CreateGO(this.itemPrefab, this.itemContent, tostring(index))
        item.transform = item.gameObject.transform
        item.bgWinGo = item.transform:Find("BgWin").gameObject
        item.bgLoseGo = item.transform:Find("BgLose").gameObject
        item.headImage = item.transform:Find("HeadMask/Head"):GetComponent(TypeImage)
        item.nameText = item.transform:Find("NameText"):GetComponent(TypeText)
        item.idText = item.transform:Find("IdText"):GetComponent(TypeText)

        item.addScoreText = item.transform:Find("AddScore"):GetComponent(TypeText)
        item.subScoreText = item.transform:Find("SubScore"):GetComponent(TypeText)

        item.bigWiner = item.transform:Find("BigWiner").gameObject
        item.owner = item.transform:Find("Owner").gameObject
        item.tyrant = item.transform:Find("Tyrant").gameObject

        table.insert(this.playItems, item)
    end
    return item
end


--设置某个item的信息
function LYCJieSuanPanel:SetItemInfo(item, data)
    if item == nil or data == nil then
        return
    end
    data.score = tonumber(data.score)

    item.nameText.text = data.name
    item.idText.text = data.uId

    local scoreText = nil

    UIUtil.SetActive(item.subScoreText.gameObject, data.score < 0)
    UIUtil.SetActive(item.addScoreText.gameObject, data.score >= 0)

    if data.score < 0 then
        scoreText = item.subScoreText
    else
        scoreText = item.addScoreText
        data.score = "+" .. data.score
    end

    scoreText.text = data.score

    --设置头像
    Functions.SetHeadImage(item.headImage, Functions.CheckJoinPlayerHeadUrl(data.headUrl))

    UIUtil.SetActive(item.owner, LYCRoomData.netJieSuanData.owner == data.playerId)

    UIUtil.SetActive(item.bigWiner, self.winer == data.playerId)

    UIUtil.SetActive(item.tyrant, self.loser == data.playerId)
    UIUtil.SetActive(item.selfImageGo, data.playerId == LYCRoomData.mainId)

    UIUtil.SetActive(item.gameObject, true)
end

function LYCJieSuanPanel.OnPlayAgainBtnClick()
    if Time.realtimeSinceStartup - this.againBtnClickTime > 2 then
        this.againBtnClickTime = Time.realtimeSinceStartup
        if LYCRoomData.groupId ~= 0 then
            Waiting.Show("加入新房间中", WaitingLevel.Normal, 6)
            UnionManager.SendPlayAgain(LYCRoomData.groupId, GameType.LYC, LYCRoomData.Note, LYCRoomData.diFen)
        else
            Toast.Show("联盟不存在，加入游戏失败")
        end
    else
        Toast.Show("请稍后...")
    end
end

function LYCJieSuanPanel:AddListenerEvent()
    AddEventListener(CMD.Tcp.Union.S2C_AGAIN, this.OnGetPlayAgainCallBack)
end

function LYCJieSuanPanel:RemoveListenerEvent()
    RemoveEventListener(CMD.Tcp.Union.S2C_AGAIN, this.OnGetPlayAgainCallBack)
end

function LYCJieSuanPanel.OnGetPlayAgainCallBack(data)
    if data.code == 0 then
        -- LYCRoom.ExitRoom()
        -- mSelf:Close()
    else
        Waiting.CheckHide()
        UnionManager.ShowError(data.code)
    end
end

function LYCJieSuanPanel:OnClosed()
    LYCRoomData.netJieSuanData = nil
    self:RemoveListenerEvent()
    if self.Timer ~= nil then
        self.Timer:Stop()
        self.Timer = nil
    end
end

function LYCJieSuanPanel:OnDestroy()
    LYCRoomData.netJieSuanData = nil
end