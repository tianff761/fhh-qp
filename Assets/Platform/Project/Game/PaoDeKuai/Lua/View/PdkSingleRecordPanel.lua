PdkSingleRecordPanel = ClassPanel("PdkSingleRecordPanel")
local this = PdkSingleRecordPanel
this.nowjs = 0

function PdkSingleRecordPanel:OnInitUI()
    -- self:AdaptContent()
    local content = self.transform:Find("Content/Content")
    this.winImage = content:Find("Background/Title/Win")
    this.loseImage = content:Find("Background/Title/Lose")

    this.winArmature = this.winImage:GetComponent(TypeSkeletonGraphic)
    this.loseArmature = this.loseImage:GetComponent(TypeSkeletonGraphic)
    -- this.clubIcon = content:Find("ClubIcon")
    -- this.teaIcon = content:Find("TeaIcon")

    -- this.roomIDText = content:Find("RoomIDText"):GetComponent("Text")
    -- this.roundText = content:Find("RoundText"):GetComponent("Text")
    -- this.timeText = content:Find("TimeText"):GetComponent("Text")

    -- this.shareBtn = content:Find("ShareBtn")
    this.CloseBtn = content:Find("CloseBtn").gameObject
    this.backBtn = content:Find("Btns/BackBtn")
    this.nextBtn = content:Find("Btns/NextBtn")
    this.nextBtn2 = content:Find("Btns/NextBtn2")
    this.readyCountdownLabel = this.nextBtn2:Find("Text"):GetComponent(TypeText)

    this.pokerNumText = content:Find("SlefPlayer/PokerNumText"):GetComponent("Text")
    this.mingTangText = content:Find("SlefPlayer/MingTangText"):GetComponent("Text")
    this.bombText = content:Find("SlefPlayer/BombText"):GetComponent("Text")
    this.addText = content:Find("SlefPlayer/AddText"):GetComponent("Text")
    this.minusText = content:Find("SlefPlayer/MinusText"):GetComponent("Text")
    this.bankerIcon = content:Find("SlefPlayer/BankerIcon").gameObject
    this.closeDoor = content:Find("SlefPlayer/CloseDoor").gameObject
    this.zhaNiaoIcon = content:Find("SlefPlayer/ZhaNiaoIcon").gameObject
    this.chunTianIcon = content:Find("SlefPlayer/ChunTianIcon").gameObject

    this.titleTran = content:Find("Players/Title")
    this.mtTitle = content:Find("Players/Title/MT").gameObject

    this.players = {}
    this.playersTran = content:Find("Players")
    local tran = nil
    for i = 1, 3 do
        local player = {}
        tran = this.playersTran:Find("Player" .. i)
        player.line = tran:Find("Line")
        player.obj = tran.gameObject
        -- player.bg1 = tran:Find("Bg1").gameObject
        -- player.bg2 = tran:Find("Bg2").gameObject
        player.nameText = tran:Find("NameText"):GetComponent("Text")
        player.remainText = tran:Find("RemainText"):GetComponent("Text")
        player.bombText = tran:Find("BombText"):GetComponent("Text")
        player.cardTypeText = tran:Find("CardTypeText"):GetComponent("Text")
        player.scoreText = tran:Find("ScoreText"):GetComponent("Text")
        player.bankerIcon = tran:Find("BankerIcon").gameObject
        player.zhaNiaoIcon = tran:Find("ZhaNiaoIcon").gameObject
        player.closeDoor = tran:Find("CloseDoor").gameObject
        player.chunTianIcon = tran:Find("ChunTianIcon").gameObject
        table.insert(this.players, player)
    end
end

function PdkSingleRecordPanel:OnOpened(data)
    -- if PdkRoomModule.IsFangKaRoom() or PdkRoomModule.isPlayback then
    --     UIUtil.SetActive(this.backBtn, false)
    -- else
    --     UIUtil.SetActive(this.backBtn, true)
    -- end
    this.Reset()
    this.ShowUI()
    this.AddListener()
    this.Init(data)

    UIUtil.SetActive(this.CloseBtn, PdkRoomModule.isPlayback)
    if PdkRoomModule.isPlayback then
        UIUtil.SetActive(this.nextBtn, true)
        UIUtil.SetActive(this.nextBtn2, false)
        this.StopReadyCountdownTimer()
    else
        UIUtil.SetActive(this.nextBtn, false)
        UIUtil.SetActive(this.nextBtn2, true)
        this.SetReadyCountdown(10)
    end
end

--当面板关闭时调用
function PdkSingleRecordPanel:OnClosed()
    LogError(">> PdkSingleRecordPanel:OnClosed")
    this.Reset()
    this.StopReadyCountdownTimer()
end

function PdkSingleRecordPanel:OnEnable()
    --DragonBonesUtil.Play(this.winArmature, "newAnimation", 0)
    --DragonBonesUtil.Play(this.loseArmature, "newAnimation", 0)
end

function PdkSingleRecordPanel:OnDisable()
    --DragonBonesUtil.Stop(this.winArmature)
    --DragonBonesUtil.Stop(this.loseArmature)
end

--添加按钮点击事件
function PdkSingleRecordPanel.AddListener()
    this:AddOnClick(this.backBtn, PdkRoomCtrl.ExitRoom)
    this:AddOnClick(this.nextBtn, this.OnNextBtnClick)
    this:AddOnClick(this.nextBtn2, this.OnNextBtnClick)
    this:AddOnClick(this.CloseBtn, this.CloseBtnOnClick)
end

--根据玩法设置UI
function PdkSingleRecordPanel.ShowUI()
    local width = 0
    local mtIsShow = false
    if PdkRoomModule.IsSCGame() then
        mtIsShow = true
        width = 941
    elseif PdkRoomModule.IsLSGame() then
        mtIsShow = false
        width = 655
    end
    UIUtil.SetActive(this.mingTangText.gameObject, mtIsShow)
    UIUtil.SetWidth(this.playersTran, width)
    UIUtil.SetWidth(this.titleTran, width)
    UIUtil.SetActive(this.mtTitle, mtIsShow)
    local player = nil
    for i = 1, #this.players do
        player = this.players[i]
        UIUtil.SetWidth(player.obj, width)
        UIUtil.SetWidth(player.line, width)
        UIUtil.SetActive(player.cardTypeText.gameObject, mtIsShow)
    end
end

--初始化结算信息
function PdkSingleRecordPanel.Init(data)
    -- this.roomIDText.text = PdkRoomModule.roomId
    -- this.roundText.text = PdkRoomModule.nowjs .. "/" .. PdkRoomModule.maxjs
    this.nowjs = data.nowjs
    -- local player = nil
    -- local temp = nil
    -- local playerInfo = nil
    local win = false
    local pokerNum = 0
    local selfScore = nil

    local index = 0
    for i = 1, #data.list do
        local temp = data.list[i]
        temp.score = tonumber(temp.score)
        if PdkRoomModule.IsSelfByID(temp.playerId) then
            local color = nil
            if temp.isWin == 1 then
                win = true
                color = "ff966c"
            else
                color = "9aadff"
                this.pokerNumText.text = SetRichText("输牌" .. temp.pokerNum .. "张", color)
            end
            if temp.isClose == 1 then
                if PdkRoomModule.IsLSGame() then
                    UIUtil.SetActive(this.chunTianIcon, true)
                else
                    UIUtil.SetActive(this.closeDoor, true)
                end
            end
            if temp.isZhuang == 1 then
                UIUtil.SetActive(this.bankerIcon, true)
            end
            if temp.isZhaNiao == 1 then
                UIUtil.SetActive(this.zhaNiaoIcon, true)
            end
            this.bombText.text = SetRichText("炸弹" .. temp.boomNum .. "次", color)
            local text = ""
            if GetTableSize(temp.tsPokerTypes) > 0 then
                for i = 1, #temp.tsPokerTypes do
                    if i == #temp.tsPokerTypes then
                        text = text .. PdkConfig.GetCardTypeText(temp.tsPokerTypes[i])
                    else
                        text = text .. PdkConfig.GetCardTypeText(temp.tsPokerTypes[i], "/")
                    end
                end
            else
                text = "无"
            end
            this.mingTangText.text = SetRichText(text, color)
            selfScore = temp.score
            -- table.remove(data.list, i)
            -- break
        else
            index = index + 1
            local player = this.players[index]
            UIUtil.SetActive(player.obj, true)
            if temp.isClose == 1 then
                if PdkRoomModule.IsLSGame() then
                    UIUtil.SetActive(player.chunTianIcon, true)
                else
                    UIUtil.SetActive(player.closeDoor, true)
                end
            end
            if temp.isZhuang == 1 then
                UIUtil.SetActive(player.bankerIcon, true)
            end
            if temp.isZhaNiao == 1 then
                UIUtil.SetActive(player.zhaNiaoIcon, true)
            end
            local playerData = PdkRoomModule.GetPlayerInfoById(temp.playerId)
            if playerData ~= nil then
                player.nameText.text = playerData.playerName
            else
                LogError("玩家信息不存在：", temp.playerId)
            end
            player.remainText.text = temp.pokerNum
            player.bombText.text = temp.boomNum
            local text = ""
            if GetTableSize(temp.tsPokerTypes) > 0 then
                for i = 1, #temp.tsPokerTypes do
                    if i == #temp.tsPokerTypes then
                        text = text .. PdkConfig.GetCardTypeText(temp.tsPokerTypes[i])
                    else
                        text = text .. PdkConfig.GetCardTypeText(temp.tsPokerTypes[i], "/")
                    end
                end
            else
                text = "无"
            end
            player.cardTypeText.text = text
            if temp.score < 0 then
                player.scoreText.text = SetRichText(CutNumber(temp.score), "9aadff")
            else
                player.scoreText.text = SetRichText("+" .. CutNumber(temp.score), "ff6521")
            end
            pokerNum = pokerNum + temp.pokerNum
            -- if win then
            --     UIUtil.SetActive(this.players[i].bg1, true)
            -- else
            --     UIUtil.SetActive(this.players[i].bg2, true)
            -- end
        end
    end
    if win then
        UIUtil.SetActive(this.winImage, true)
        this.winArmature.AnimationState:SetAnimation(0, "animation", false)
        if data.isGameingDis == 0 then
            this.pokerNumText.text = SetRichText("赢牌" .. pokerNum .. "张", "F5EEBD")
        else
            this.pokerNumText.text = SetRichText("赢牌0张", "F5EEBD")
        end
        UIUtil.SetActive(this.addText.gameObject, true)
        UIUtil.SetActive(this.minusText.gameObject, false)
        if selfScore >= 0 then
            this.addText.text = "+" .. CutNumber(selfScore, true)
        else
            this.addText.text = CutNumber(selfScore, true)
        end
        PdkAudioCtrl.PlayWin()
    else
        UIUtil.SetActive(this.loseImage, true)
        this.loseArmature.AnimationState:SetAnimation(0, "animation", false)
        UIUtil.SetActive(this.addText.gameObject, false)
        UIUtil.SetActive(this.minusText.gameObject, true)
        if selfScore >= 0 then
            this.minusText.text = "+" .. CutNumber(selfScore, true)
        else
            this.minusText.text = CutNumber(selfScore, true)
        end
        PdkAudioCtrl.PlayLoss()
    end
end

--重置UI
function PdkSingleRecordPanel.Reset()
    UIUtil.SetActive(this.winImage, false)
    UIUtil.SetActive(this.loseImage, false)
    UIUtil.SetActive(this.pingJuImage, false)
    UIUtil.SetActive(this.closeDoor, false)
    UIUtil.SetActive(this.bankerIcon, false)
    UIUtil.SetActive(this.zhaNiaoIcon, false)
    UIUtil.SetActive(this.chunTianIcon, false)
    local player = nil
    for i = 1, #this.players do
        player = this.players[i]
        UIUtil.SetActive(player.obj, false)
        -- UIUtil.SetActive(player.bg1, false)
        -- UIUtil.SetActive(player.bg2, false)
        UIUtil.SetActive(player.closeDoor, false)
        UIUtil.SetActive(player.bankerIcon, false)
        UIUtil.SetActive(player.zhaNiaoIcon, false)
        UIUtil.SetActive(player.chunTianIcon, false)
    end
end

--继续按钮
function PdkSingleRecordPanel.OnNextBtnClick()
    -- PdkRoomModule.singleRecordIndex = this.nowjs
    if PdkRoomModule.isPlayback then
        PanelManager.Close(PdkPanelConfig.SingleRecord)
    else
        PdkRoomCtrl.Reset()
        if PdkRoomModule.totalRecordData ~= nil then
            if not PanelManager.IsOpened(PdkPanelConfig.TotalRecord) then
                PanelManager.Open(PdkPanelConfig.TotalRecord, PdkRoomModule.totalRecordData)
            end
        else
            PdkRoomModule.SendPlayerReady()
        end
        PanelManager.Close(PdkPanelConfig.SingleRecord)

        -- if PdkRoomModule.IsFangKaRoom() then

        -- else
        --     if PdkRoomModule.IsTeaRoom() then
        --         GoldMacthMgr.SendMatchGame(PdkRoomModule.groupId)
        --         -- PdkRoomModule.Clear()
        --     end
        -- end
    end
end

--分享
function PdkSingleRecordPanel.OnShareBtnClick()
    --分享截图
    local data = {
        roomCode = PdkRoomModule.roomId,
        type = 2,
        ScreenshotScale = { w = 1166 - 16, h = 656 - 16 }
    }
    PanelManager.Open(PanelConfig.RoomInvite, data)
end

function PdkSingleRecordPanel:AdaptContent()
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

------------------------------------------------------------------
--
--设置倒计时
function PdkSingleRecordPanel.SetReadyCountdown(time)
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
function PdkSingleRecordPanel.StartReadyCountdownTimer()
    if this.readyCountdownTimer == nil then
        this.readyCountdownTimer = Timing.New(this.OnReadyCountdownTimer, 0.33)
    end
    this.readyCountdownTimer:Start()
end

function PdkSingleRecordPanel.StopReadyCountdownTimer()
    if this.readyCountdownTimer ~= nil then
        this.readyCountdownTimer:Stop()
    end
end

function PdkSingleRecordPanel.OnReadyCountdownTimer()
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
        this.readyCountdownLabel.text = "(" .. this.readyDisplayTime .. ")"
    end
end

function PdkSingleRecordPanel.CloseBtnOnClick()
    PanelManager.Close(PdkPanelConfig.SingleRecord)
end