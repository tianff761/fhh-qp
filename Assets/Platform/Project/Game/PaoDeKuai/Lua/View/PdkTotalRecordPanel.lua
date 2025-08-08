PdkTotalRecordPanel = ClassPanel("PdkTotalRecordPanel")
local this = PdkTotalRecordPanel
this.againBtnClickTime = 0

function PdkTotalRecordPanel:OnInitUI()
    -- this.bg = self.transform:Find("Bg")
    -- UIUtil.SetBackgroundAdaptation(this.bg.gameObject)
    -- self:AdaptContent()
    local content = self.transform:Find("Content/Content")
    this.roomIDText = content:Find("Node/RoomIDText"):GetComponent("Text")
    this.roundText = content:Find("Node/RoundText"):GetComponent("Text")
    this.timeText = content:Find("Node/TimeText"):GetComponent("Text")

    this.layout = content:Find("Node/Players"):GetComponent("HorizontalLayoutGroup")

    local buttonLayout = content:Find("Node/ButtonLayout")
    this.shareBtn = buttonLayout:Find("ShareBtn").gameObject
    this.backBtn = buttonLayout:Find("BackBtn").gameObject
    this.playAgainBtn = buttonLayout:Find("PlayAgainBtn").gameObject

    this.players = {}
    local tran = nil
    for i = 1, 4 do
        local player = {}
        tran = content:Find("Node/Players/Player" .. i)
        player.obj = tran.gameObject
        player.BG = tran:Find("BG")
        player.bg1 = player.BG:Find("Bg1").gameObject
        player.bg2 = player.BG:Find("Bg2").gameObject
        player.nameText = player.BG:Find("NameText"):GetComponent("Text")
        player.idText = player.BG:Find("IdText"):GetComponent("Text")
        player.headImage = player.BG:Find("Head/HeadMask/Image"):GetComponent("Image")
        player.headBox = player.BG:Find("Head/Frame"):GetComponent("Image")
        player.addTxt = player.BG:Find("Score/AddTxt"):GetComponent("Text")
        player.subTxt = player.BG:Find("Score/SubTxt"):GetComponent("Text")
        player.zdText = player.BG:Find("ZD/Text"):GetComponent("Text")
        player.winText = player.BG:Find("Win/Text"):GetComponent("Text")
        player.mingTangText = player.BG:Find("MT/Text"):GetComponent("Text")
        player.winIcon = player.BG:Find("WinIcon").gameObject
        player.bombIcon = player.BG:Find("BombIcon").gameObject
        player.ownerIcon = player.BG:Find("OwnerIcon").gameObject
        table.insert(this.players, player)
    end
end

function PdkTotalRecordPanel:OnOpened(data)
    this.Reset()
    this.AddListener()
    this.ShowUI()
    this.Init(data)
end

--当面板关闭时调用
function PdkTotalRecordPanel:OnClosed()
    this.Reset()
end

function PdkTotalRecordPanel.ShowUI()
    local mtIsShow = false
    if PdkRoomModule.IsSCGame() then
        mtIsShow = true
    elseif PdkRoomModule.IsLSGame() then
        mtIsShow = false
    end
    for i = 1,#this.players do
        UIUtil.SetActive(this.players[i].mingTangText.transform.parent, mtIsShow)
    end
end

--初始化结算信息
function PdkTotalRecordPanel.Init(data)
    PdkRoomModule.note = data.note
    this.roomIDText.text = PdkRoomModule.roomId
    this.roundText.text = data.nowjs .. "/" .. PdkRoomModule.maxjs
    this.timeText.text = os.date("%Y-%m-%d %H:%M:%S", data.endTime / 1000)
    -- local player = nil
    -- local temp = nil
    -- local playerInfo = nil
    local lenght = #data.list
    if lenght == 2 then
        this.layout.spacing = 200
    elseif lenght == 3 then
        this.layout.spacing = 100
    elseif lenght == 4 then
        this.layout.spacing = 25
    end
    for i = 1, lenght do
        local player = this.players[i]
        local temp = data.list[i]
        temp.totalScore = tonumber(temp.totalScore)
        UIUtil.SetActive(player.obj, true)
        local playerData = PdkRoomModule.GetPlayerInfoById(temp.playerId)
        if playerData ~= nil then
            player.nameText.text = playerData.playerName
            player.idText.text = temp.playerId
            Functions.SetHeadImage(player.headImage, playerData.playerHead)
            -- Functions.SetHeadFrame(player.headBox, playerData.playerTxk)
        else
            LogError("玩家信息不存在：", temp.playerId)
        end
        if temp.totalScore >= 0 then
            UIUtil.SetActive(player.addTxt.gameObject, true)
            player.addTxt.text = "+" .. CutNumber(temp.totalScore, true)
        else
            UIUtil.SetActive(player.subTxt.gameObject, true)
            player.subTxt.text = CutNumber(temp.totalScore, true)
        end
        for i = 1,#data.bigWinId do
            if data.bigWinId[i] == temp.playerId then
                UIUtil.SetActive(player.winIcon, true)
                break
            end
        end
        if data.boomKing == temp.playerId then
            UIUtil.SetActive(player.bombIcon, true)
        end
        if PdkRoomModule.ownerId == temp.playerId then
            UIUtil.SetActive(player.ownerIcon, true)
        end
        player.zdText.text = temp.boomTimes
        player.winText.text = temp.winNum
        player.mingTangText.text = temp.tsPokerNum
        if PdkRoomModule.IsSelfByID(temp.playerId) then
            UIUtil.SetActive(player.bg1, false)
            UIUtil.SetActive(player.bg2, true)
        end
    end
end

--重置UI
function PdkTotalRecordPanel.Reset()
    local player = nil
    for i = 1, #this.players do
        player = this.players[i]
        UIUtil.SetActive(player.obj, false)
        UIUtil.SetActive(player.bg1, true)
        UIUtil.SetActive(player.bg2, false)
        UIUtil.SetActive(player.addTxt.gameObject, false)
        UIUtil.SetActive(player.subTxt.gameObject, false)
        UIUtil.SetActive(player.winIcon, false)
        UIUtil.SetActive(player.bombIcon, false)
        UIUtil.SetActive(player.ownerIcon, false)
    end
end

--添加按钮点击事件
function PdkTotalRecordPanel.AddListener()
    this:AddOnClick(this.shareBtn, this.OnShareBtnClick)
    this:AddOnClick(this.backBtn, PdkRoomCtrl.ExitRoom)
    this:AddOnClick(this.playAgainBtn, this.OnPlayAgainBtnClick)
end

--分享
function PdkTotalRecordPanel.OnShareBtnClick()
    --分享截图
    local data = {
        roomCode = PdkRoomModule.roomId,
        type = 2,
        ScreenshotScale = {w = 1280 - 16, h = 720 - 16}
    }
    PanelManager.Open(PanelConfig.RoomInvite, data)
end

function PdkTotalRecordPanel.OnPlayAgainBtnClick()
    if Time.realtimeSinceStartup - this.againBtnClickTime > 3 then
        this.againBtnClickTime = Time.realtimeSinceStartup
        if PdkRoomModule.groupId ~= 0 then
            UnionManager.SendPlayAgain(PdkRoomModule.groupId, GameType.PaoDeKuai, PdkRoomModule.note, PdkRoomModule.diFen)
            Waiting.Show("加入新房间...")
        else
            Toast.Show("联盟不存在，加入游戏失败")
        end
    else
        Toast.Show("请稍后...")
    end
end


function PdkTotalRecordPanel:AdaptContent()
    local content = self:Find("Content/Content"):GetComponent("RectTransform")

    local offMax = content.offsetMax;
    local offMin = content.offsetMin;
    local designWH = 16 / 9 --设计宽高比
    local curWH = ScenemMgr.width / ScenemMgr.height  --当前宽高比
    if curWH < designWH then
        local y = 180 * designWH * ScenemMgr.height / ScenemMgr.width
        offMax.y = y * content.offsetMax.y / math.abs(content.offsetMax.y);
        content.offsetMax = offMax;

        offMin = content.offsetMin;
        offMin.y = y * content.offsetMin.y / math.abs(content.offsetMin.y);
        content.offsetMin = offMin;
    else
        local x = 320 * curWH / designWH
        offMax.x = x * content.offsetMax.x / math.abs(content.offsetMax.x);
        content.offsetMax = offMax;

        offMin = content.offsetMin;
        offMin.x = x * content.offsetMin.x / math.abs(content.offsetMin.x);
        content.offsetMin = offMin;
    end
end