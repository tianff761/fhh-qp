SDBJieSuanPanel = ClassPanel("SDBJieSuanPanel")
local this = SDBJieSuanPanel
local mSelf = nil

function SDBJieSuanPanel:OnInitUI()
    mSelf = self
    self:InitPanel()
    self:AddClickMsg()
end

--初始化面板--
function SDBJieSuanPanel:InitPanel()
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
    -----------------------------------------------------------------Content
    local playerItemContent = node:Find("PlayerItems")
    self.itemList = {}
    for i = 1, 8 do
        local item = {}
        item.transform = playerItemContent:Find(i)
        item.gameObject = item.transform.gameObject
        item.headImage = item.transform:Find("Head"):GetComponent("Image")
        item.headFrame = item.transform:Find("HeadFrame"):GetComponent("Image")
        item.nameText = item.transform:Find("Name"):GetComponent("Text")
        item.idText = item.transform:Find("ID"):GetComponent("Text")
        item.selfImageGo = item.transform:Find("Self").gameObject
        item.robBankerCountText = item.transform:Find("RobBankerCount"):GetComponent("Text")
        item.bankerCountText = item.transform:Find("BankerCount"):GetComponent("Text")
        item.boomCardCountText = item.transform:Find("BoomCardCount"):GetComponent("Text")
        item.addScoreText = item.transform:Find("AddScore"):GetComponent("Text")
        item.subScoreText = item.transform:Find("SubScore"):GetComponent("Text")
        item.bigWiner = item.transform:Find("BigWiner").gameObject
        item.owner = item.transform:Find("Owner").gameObject
        item.tyrant = item.transform:Find("Tyrant").gameObject
        table.insert(self.itemList, item)
    end
    self.AddListenerEvent()
end

function SDBJieSuanPanel:OnOpened()
    mSelf = self
    if IsTable(SDBRoomData.netJieSuanData) and #SDBRoomData.netJieSuanData ~= 0 then
        self:ParseInfo()
        self:SetTopInfo()
        --设置详细信息
        for i = 1, #SDBRoomData.netJieSuanData do
            self:SetItemInfo(self.itemList[i], SDBRoomData.netJieSuanData[i])
        end
    end
end

function SDBJieSuanPanel:ParseInfo()
    --查找大赢家 土豪
    local maxScore = 0
    local minScore = 0
    for i = 1, #SDBRoomData.netJieSuanData do
        if SDBRoomData.netJieSuanData[i].score > maxScore then
            maxScore = SDBRoomData.netJieSuanData[i].score
            self.winer = SDBRoomData.netJieSuanData[i].playerId
        end
        if SDBRoomData.netJieSuanData[i].score < minScore then
            minScore = SDBRoomData.netJieSuanData[i].score
            self.loser = SDBRoomData.netJieSuanData[i].playerId
        end
    end
end

--挂载点击事件
function SDBJieSuanPanel:AddClickMsg()
    self:AddOnClick(self.backBtn, this.OnClickBackLobbyBtn)
    self:AddOnClick(self.saveBtn, this.OnClickSaveBtn)
    self:AddOnClick(self.PlayAgainBtn, this.OnPlayAgainBtnClick)
end

--点击返回大厅
function SDBJieSuanPanel.OnClickBackLobbyBtn()
    if GameSceneManager.IsRoomScene() then
        SDBRoom.ExitRoom()
        mSelf:Close()
    else
        mSelf:Close()
    end
end

--点击分享
function SDBJieSuanPanel.OnClickSaveBtn()
    --分享截图
    local temp = Functions.GetScreenshotSize(1114, 680)
    PlatformHelper.GetScreenshotPngBytes(function(bytes)
        AppPlatformHelper.SaveImageToPhone(bytes, "")
    end, temp.x, temp.y, temp.width, temp.height)
end

--设置顶部数据信息
function SDBJieSuanPanel:SetTopInfo()
    self.roomCodeText.text = SDBRoomData.netJieSuanData.roomCode
    self.difenText.text = SDBRoomData.netJieSuanData.difen
    self.modelText.text = SDBRoomData.netJieSuanData.model
    self.juShuText.text = SDBRoomData.netJieSuanData.jushu
    self.timeText.text = os.date("%Y-%m-%d %H:%M", SDBRoomData.netJieSuanData.endTime)
end

--设置某个item的信息
function SDBJieSuanPanel:SetItemInfo(item, data)
    if item == nil or data == nil then
        return
    end

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

    item.robBankerCountText.text = data.robBankerCount

    item.bankerCountText.text = data.bankerCount

    item.boomCardCountText.text = data.boomCardCount

    --设置头像
    Functions.SetHeadImage(item.headImage, Functions.CheckJoinPlayerHeadUrl(data.headUrl))

    UIUtil.SetActive(item.owner, SDBRoomData.netJieSuanData.owner == data.playerId)

    UIUtil.SetActive(item.bigWiner, self.winer == data.playerId)

    UIUtil.SetActive(item.tyrant, self.loser == data.playerId)
    UIUtil.SetActive(item.selfImageGo, data.playerId == SDBRoomData.mainId)

    UIUtil.SetActive(item.gameObject, true)
end

function SDBJieSuanPanel.OnPlayAgainBtnClick()
    --UnionManager.SendPlayAgain(GameType.SDB, SDBRoomData.Note, SDBRoomData.diFen)
end

function SDBJieSuanPanel:AddListenerEvent()
    AddEventListener(CMD.Tcp.Union.S2C_AGAIN, this.OnGetPlayAgainCallBack)
end

function SDBJieSuanPanel.OnGetPlayAgainCallBack(data)
    if data.code == 0 then
        SDBRoom.ExitRoom()
        mSelf.Close()
    else
        UnionManager.ShowError(data.code)
    end
end

function SDBJieSuanPanel:OnClosed()
    SDBRoomData.netJieSuanData = nil
    if not IsNil(this.itemList) then
        for _, v in ipairs(this.itemList) do
            UIUtil.SetActive(v.gameObject, false)
        end
    end
end

function SDBJieSuanPanel:OnDestroy()
    SDBRoomData.netJieSuanData = nil
end