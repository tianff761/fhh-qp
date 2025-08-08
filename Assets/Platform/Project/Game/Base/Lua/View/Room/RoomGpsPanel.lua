RoomGpsPanel = ClassPanel("RoomGpsPanel")
RoomGpsPanel.Instance = nil
--
local this = nil
--
--座位配置，注意线对应的位置
local GpsSeatConfig = {
    [2] = {
        [1] = {}, --1
        [2] = { 1 }, --2
        [3] = { 1, 2 }, --补位
        [4] = { 1, 2, 3 }, --补位
    },
    [3] = {
        [1] = {}, --3
        [2] = { 3 }, --2
        [3] = { 3, 2 }, --1
        [4] = { 1, 2, 3 }, --补位
    },
    [4] = {
        [1] = {}, --4
        [2] = { 4 }, --2
        [3] = { 4, 2 }, --1
        [4] = { 4, 2, 1 }, --3
    },
}
--
--初始属性数据
function RoomGpsPanel:InitProperty()
    --参数数据
    this.data = nil
    --玩家的总人数
    this.playerMaxTotal = 2
    --当前界面的玩家数据
    this.playerDatas = nil
    --座位上Item，根据人数调整的
    this.seatItems = nil
    --座位配置
    this.seatConfig = nil
    --倒计时Timer
    this.countDownTimer = nil
    --倒计时时间
    this.countDownTime = 0
    --用于存储比较显示
    this.lastCountDownTime = -1
    --更新倒计时时间
    this.updateCountDownTime = 0
    --延迟关闭Timer
    this.delayCloseTimer = nil
end

--UI初始化
function RoomGpsPanel:OnInitUI()
    this = self
    this:InitProperty()

    this.closeBtn = self:Find("Content/Background/CloseBtn").gameObject

    local nodeTrans = self:Find("Content/Node")

    local layout = self:Find("Content/Node/Layout")

    this.viewBtn = layout:Find("ViewButton").gameObject
    this.readyBtn = layout:Find("ReadyButton").gameObject
    this.quitBtn = layout:Find("QuitButton").gameObject
    this.quitBtnText = this.quitBtn.transform:Find("Text")

    this.dismissBtn = nodeTrans:Find("DismissButton").gameObject
    this.openGpsSettingBtn = nodeTrans:Find("OpenGpsSettingBtn").gameObject
    this.emptyHeadSprite = nodeTrans:Find("EmptyHead"):GetComponent(TypeImage).sprite

    local textNodeTrans = nodeTrans:Find("TextNode")
    this.textNode = textNodeTrans.gameObject
    this.countDownTxt = textNodeTrans:Find("CountDownTxt"):GetComponent(TypeText)

    --玩家信息
    local playersTrans = nodeTrans:Find("Players")
    this.playersGO = playersTrans.gameObject

    this.items = {}
    for i = 1, 4 do
        local item = {}
        item.playerId = -1--用于处理头像重复问题
        this.items[i] = item
        item.transform = playersTrans:Find("Player" .. i)
        item.gameObject = item.transform.gameObject
        item.headImage = item.transform:Find("Head/Mask/Icon"):GetComponent(TypeImage)
        item.nameTxt = item.transform:Find("NameText"):GetComponent(TypeText)
        item.readyGO = item.transform:Find("Ready").gameObject

        --处理线条
        item.lines = {}
        local length = i - 1
        for j = 1, length do
            local lineItem = {}
            item.lines[j] = lineItem
            lineItem.transform = item.transform:Find("Line-" .. j)
            lineItem.gameObject = lineItem.transform.gameObject
            lineItem.grayGO = lineItem.transform:Find("Gray").gameObject
            lineItem.redGO = lineItem.transform:Find("Red").gameObject
            lineItem.greenGO = lineItem.transform:Find("Green").gameObject
            lineItem.txt = lineItem.transform:Find("Text"):GetComponent(TypeText)
        end
    end

    this.AddUIListenerEvent()
end

--参数数据格式
local data = {
    gameType = 1,
    roomType = 1,
    moneyType = 1,
    isRoomBegin = false, --房间是否开始，即第一局开始后，后面的处理退出都需要解散
    isRoomOwner = false, --房间拥有者，玩家自己是否是房主
    playerMaxTotal = 4, --玩家最大总人数
    readyCallback = nil, --准备点击回调
    quitCallback = nil, --退出解散回调
    countDown = nil, --准备倒计时，如果是非准备阶段，该值为nil，是否是GPS查看也通过该方法
    players = {
        --本地的座位索引，2人1-2，3人1-3，4人1-4
        [1] = {
            id = 1,
            name = nil,
            headUrl = nil,
            headFrame = nil,
            ready = 0, --准备标识，0未准备、1准备
            gps = {
                lat = 0,
                lng = 0,
            }
        }
    }
}

--当面板开启开启时
function RoomGpsPanel:OnOpened(argData)
    RoomGpsPanel.Instance = self
    this.AddListenerEvent()
    this.data = argData
    if this.data == nil then
        Alert.Show("参数错误，请联系客服")
        this.Close()
        return
    end
    Log(this.data)
    this.UpdateData()
end

--当面板关闭时调用
function RoomGpsPanel:OnClosed()
    RoomGpsPanel.Instance = nil
    this.data = nil
    this.playerMaxTotal = 2
    this.playerDatas = nil
    this.StopCountDownTimer()
    this.StopDelayCloseTimer()
    this.countDownTime = 0
    this.lastCountDownTime = -1
    this.updateCountDownTime = 0
    this.RemoveListenerEvent()
    --清除item上存储的玩家ID
    for i = 1, 4 do
        local item = this.items[i]
        item.playerId = -1
    end
end

------------------------------------------------------------------
--
--关闭
function RoomGpsPanel.Close()
    PanelManager.Close(PanelConfig.RoomGps)
end

--
function RoomGpsPanel.AddListenerEvent()
    AddEventListener(CMD.Game.RoomGpsPlayerUpdate, this.OnRoomGpsPlayerUpdate)
    AddEventListener(CMD.Game.RoomGpsReadyFinished, this.OnRoomGpsReadyFinished)
end

--
function RoomGpsPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Game.RoomGpsPlayerUpdate, this.OnRoomGpsPlayerUpdate)
    RemoveEventListener(CMD.Game.RoomGpsReadyFinished, this.OnRoomGpsReadyFinished)
end

--UI相关事件
function RoomGpsPanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.readyBtn, this.OnReadyBtnClick)
    this:AddOnClick(this.quitBtn, this.OnQuitBtnClick)
    this:AddOnClick(this.dismissBtn, this.OnDismissBtnClick)
    this:AddOnClick(this.openGpsSettingBtn, this.OnOpenGpsSettingBtnClick)
    this:AddOnClick(this.viewBtn, this.OnViewBtnClick)
end

------------------------------------------------------------------
--
function RoomGpsPanel.OnCloseBtnClick()
    this.Close()
end

function RoomGpsPanel.OnReadyBtnClick()
    if this.data ~= nil and this.data.readyCallback ~= nil then
        this.data.readyCallback()
    end
end

function RoomGpsPanel.OnQuitBtnClick()
    this.QuitOrDismissRoom("是否退出房间？")
end

function RoomGpsPanel.OnDismissBtnClick()
    this.QuitOrDismissRoom("是否解散房间？")
end

function RoomGpsPanel.OnOpenGpsSettingBtnClick()
    AppPlatformHelper.OpenDeviceSetting()
end


--查看战绩按钮点击
function RoomGpsPanel.OnViewBtnClick()
    if this.data ~= nil and this.data.viewCallback ~= nil then
        this.data.viewCallback()
    end
end

------------------------------------------------------------------
--
function RoomGpsPanel.CountPlayerNum(players)
    local playerNum = 0
    local temp = nil
    for i = 1, this.playerMaxTotal do
        if players[i] ~= nil then
            playerNum = playerNum + 1
        end
    end
    return playerNum
end

--玩家数据更新
function RoomGpsPanel.OnRoomGpsPlayerUpdate(players)
    if this.data == nil then
        return
    end
    if this.data.countDown ~= nil then
        --人数减少就关闭
        if this.CountPlayerNum(players) < this.playerMaxTotal then
            this.Close()
            return
        end
    end
    this.data.players = players
    this.UpdatePlayerDisplay()
end

--玩家自己准备完成
function RoomGpsPanel.OnRoomGpsReadyFinished()
    if this.data ~= nil and this.data.countDown ~= nil then
        this.Close()
    end
end

------------------------------------------------------------------
--
--更新数据
function RoomGpsPanel.UpdateData()
    this.playerMaxTotal = 2
    if this.data.playerMaxTotal ~= nil then
        this.playerMaxTotal = this.data.playerMaxTotal
    end
    --调整座位
    this.seatItems = {}
    this.seatConfig = GpsSeatConfig[this.playerMaxTotal]
    if this.seatConfig == nil then
        this.seatConfig = GpsSeatConfig[2]
    end
    if this.playerMaxTotal == 2 then
        this.SetSeatItem(1, 1)
        this.SetSeatItem(2, 2)
        this.SetSeatItem(3, 3)
        this.SetSeatItem(4, 4)
    elseif this.playerMaxTotal == 3 then
        this.SetSeatItem(1, 3)
        this.SetSeatItem(2, 2)
        this.SetSeatItem(3, 1)
        this.SetSeatItem(4, 4)
    else
        this.SetSeatItem(1, 3)
        this.SetSeatItem(2, 2)
        this.SetSeatItem(3, 4)
        this.SetSeatItem(4, 1)
    end
    this.UpdateUIDisplay()
    this.UpdatePlayerDisplay()
end

function RoomGpsPanel.SetSeatItem(seatIndex, itemIndex)
    this.seatItems[seatIndex] = this.items[itemIndex]
    this.seatItems[seatIndex].index = itemIndex
end

--更新UI显示
function RoomGpsPanel.UpdateUIDisplay()
    --查看GPS
    if this.data.isRoomBegin == true or this.data.countDown == nil then
        UIUtil.SetActive(this.closeBtn, true)
        UIUtil.SetActive(this.readyBtn, false)
        UIUtil.SetActive(this.dismissBtn, false)
        UIUtil.SetActive(this.quitBtn, false)
        UIUtil.SetActive(this.textNode, false)
        --
        if this.playerMaxTotal == 3 then
            UIUtil.SetAnchoredPositionY(this.playersGO, 110)
        else
            UIUtil.SetAnchoredPositionY(this.playersGO, 70)
        end
        --
        this.StopCountDownTimer()
    else
        UIUtil.SetActive(this.closeBtn, false)
        UIUtil.SetActive(this.readyBtn, true)
        UIUtil.SetActive(this.textNode, true)

        if this.data.moneyType == MoneyType.Gold then
            UIUtil.SetActive(this.quitBtn, true)
            UIUtil.SetActive(this.dismissBtn, false)

            --处理战绩查看
            if this.data.viewCallback ~= nil then
                UIUtil.SetActive(this.viewBtn, true)
            else
                UIUtil.SetActive(this.viewBtn, false)
            end
        else
            if this.data.roomType == RoomType.Lobby and this.data.isRoomOwner then
                UIUtil.SetActive(this.dismissBtn, true)
                UIUtil.SetActive(this.quitBtn, false)
            else
                UIUtil.SetActive(this.dismissBtn, false)
                UIUtil.SetActive(this.quitBtn, true)
            end
        end
        -- --
        -- if this.playerMaxTotal == 2 then
        --     UIUtil.SetAnchoredPositionY(this.playersGO, 30)
        -- elseif this.playerMaxTotal == 3 then
        --     UIUtil.SetAnchoredPositionY(this.playersGO, 90)
        -- else
        --     UIUtil.SetAnchoredPositionY(this.playersGO, 65)
        -- end

        if this.playerMaxTotal == 3 then
            UIUtil.SetAnchoredPositionY(this.playersGO, 110)
        else
            UIUtil.SetAnchoredPositionY(this.playersGO, 70) 
        end
        --
        this.UpdateReadyCountDown()
    end
end

--退出或者解散房间
function RoomGpsPanel.QuitOrDismissRoom(tips)
    Alert.Prompt(tips, this.OnAlertQuitOrDismissRoom)
end

--处理退出或者解散房间
function RoomGpsPanel.OnAlertQuitOrDismissRoom()
    if this.data ~= nil and this.data.quitCallback ~= nil then
        this.data.quitCallback()
    end
end

--更新准备倒计时
function RoomGpsPanel.UpdateReadyCountDown()
    if this.data == nil then
        return
    end
    if not IsNumber(this.data.countDown) then
        this.countDownTime = 0
    else
        this.countDownTime = this.data.countDown
        if this.countDownTime < 0 then
            this.countDownTime = 0
        end
        this.StartCountDownTimer()
    end
    this.UpdateCountDownTxt()
end

--更新倒计时文本显示
function RoomGpsPanel.UpdateCountDownTxt()
    local time = math.ceil(this.countDownTime)
    if this.lastCountDownTime ~= time then
        this.lastCountDownTime = time
        this.countDownTxt.text = tostring(time)
        UIUtil.SetText(this.quitBtnText, "退出房间"..tostring(time))
    end
end

------------------------------------------------------------------
--
--启动倒计时Timer
function RoomGpsPanel.StartCountDownTimer()
    if this.countDownTimer == nil then
        this.countDownTimer = Timing.New(this.OnCountDownTimer, 0.2)
    end
    this.updateCountDownTime = Time.realtimeSinceStartup
    this.countDownTimer:Restart()
end

--停止倒计时Timer
function RoomGpsPanel.StopCountDownTimer()
    if this.countDownTimer ~= nil then
        this.countDownTimer:Stop()
        this.countDownTimer = nil
    end
end

local tempCountDownTime = 0
local tempCountDownDiffTime = 0
--处理倒计时Timer，该方法不能直接调用
function RoomGpsPanel.OnCountDownTimer()
    tempCountDownTime = Time.realtimeSinceStartup
    tempCountDownDiffTime = tempCountDownTime - this.updateCountDownTime

    if tempCountDownDiffTime < 0 then
        tempCountDownDiffTime = 0
    end
    this.updateCountDownTime = tempCountDownTime
    this.countDownTime = this.countDownTime - tempCountDownDiffTime

    if this.countDownTime < 0 then
        this.countDownTime = 0
        this.StopCountDownTimer()
    end
    this.UpdateCountDownTxt()
end

------------------------------------------------------------------
--更新玩家数据
function RoomGpsPanel.UpdatePlayerDisplay()
    this.playerDatas = nil
    if this.data.players ~= nil then
        this.playerDatas = this.data.players
    else
        this.playerDatas = {}
    end

    local playerData = nil
    local item = nil
    for i = 1, this.playerMaxTotal do
        playerData = this.playerDatas[i]
        item = this.seatItems[i]
        UIUtil.SetActive(item.gameObject, true)
        this.UpdatePlayerInfoByPlayerData(i, item, playerData)
        this.UpdatePlayerGpsByPlayerData(i, item, playerData)
        this.UpdatePlayerReadyByPlayerData(i, item, playerData)
    end
    --隐藏多余的
    for i = this.playerMaxTotal + 1, 4 do
        item = this.seatItems[i]
        item.playerId = nil
        UIUtil.SetActive(item.gameObject, false)
    end
end

--更新所有玩家的GPS
function RoomGpsPanel.UpdatePlayerGps()
    if this.playerDatas == nil then
        return
    end
    for i = 1, this.playerMaxTotal do
        this.UpdatePlayerGpsByPlayerData(i, this.seatItems[i], this.playerDatas[i])
    end
end

--更新所有玩家的准备
function RoomGpsPanel.UpdatePlayerReady()
    if this.playerDatas == nil then
        return
    end
    for i = 1, this.playerMaxTotal do
        this.UpdatePlayerReadyByPlayerData(i, this.seatItems[i], this.playerDatas[i])
    end
end

--更新玩家的信息，头像、名称
function RoomGpsPanel.UpdatePlayerInfoByPlayerData(index, item, playerData)
    local playerId = 0
    if playerData ~= nil then
        playerId = playerData.id
    end

    if item.playerId == playerId then
        return
    end
    item.playerId = playerId

    if playerData ~= nil then
        item.nameTxt.text = playerData.name
        Functions.SetHeadImage(item.headImage, Functions.CheckJoinPlayerHeadUrl(playerData.headUrl))
        --  Functions.SetHeadFrame(item.headFrame, playerData.headFrame)
    else
        item.nameTxt.text = ""
        item.headImage.sprite = this.emptyHeadSprite
        --  Functions.SetHeadFrame(item.headFrame, 0)
    end
end

--处理玩家GPS数据
function RoomGpsPanel.UpdatePlayerGpsByPlayerData(index, item, playerData)
    local length = #item.lines
    local lineItem = nil
    --
    if playerData == nil then
        for i = 1, length do
            lineItem = item.lines[i]
            UIUtil.SetActive(lineItem.grayGO, true)
            UIUtil.SetActive(lineItem.redGO, false)
            UIUtil.SetActive(lineItem.greenGO, false)
            lineItem.txt.text = ""
        end
    else
        local otherIndex = 0
        local otherPlayerData = nil
        local gps = this.CheckGps(playerData.gps)
        local seatIndexs = this.seatConfig[item.index]
        local distance = -1
        length = #seatIndexs
        for i = 1, length do
            lineItem = item.lines[i]
            otherIndex = seatIndexs[i]
            distance = -1
            --
            otherPlayerData = this.playerDatas[otherIndex]
            if otherPlayerData ~= nil then
                local otherGPS = this.CheckGps(otherPlayerData.gps)
                distance = Functions.GetDisance(gps.lat, gps.lng, otherGPS.lat, otherGPS.lng)
                distance = Functions.CheckGpsDisance(distance)
            end

            --200米认为过近，小于0表示没有开启
            if distance < 0 then
                UIUtil.SetActive(lineItem.grayGO, true)
                UIUtil.SetActive(lineItem.redGO, false)
                UIUtil.SetActive(lineItem.greenGO, false)
                lineItem.txt.text = ""
            elseif distance < 200 then
                UIUtil.SetActive(lineItem.grayGO, false)
                UIUtil.SetActive(lineItem.redGO, true)
                UIUtil.SetActive(lineItem.greenGO, false)
                lineItem.txt.text = this.CheckGpsDistance(distance)
            else
                UIUtil.SetActive(lineItem.grayGO, false)
                UIUtil.SetActive(lineItem.redGO, false)
                UIUtil.SetActive(lineItem.greenGO, true)
                lineItem.txt.text = this.CheckGpsDistance(distance)
            end

        end
    end
end

--处理玩家准备图标
function RoomGpsPanel.UpdatePlayerReadyByPlayerData(index, item, playerData)
    if playerData ~= nil and playerData.ready == ReadyType.Ready then
        UIUtil.SetActive(item.readyGO, true)
    else
        UIUtil.SetActive(item.readyGO, false)
    end
end

--检测处理GPS
function RoomGpsPanel.CheckGps(gps)
    local reuslt = {}
    reuslt.lat = 0
    reuslt.lng = 0

    if IsTable(gps) then
        if IsNumber(gps.lat) then
            reuslt.lat = gps.lat
        end
        if IsNumber(gps.lng) then
            reuslt.lng = gps.lng
        end
    end
    return reuslt
end

--检测处理GPS距离
function RoomGpsPanel.CheckGpsDistance(distance)
    if distance > 9999 then
        distance = distance / 1000
        return string.format("%.1f", distance) .. "千米"
    else
        return string.format("%.1f", distance) .. "米"
    end
end

------------------------------------------------------------------
--停止或者关闭延迟计时器
function RoomGpsPanel.StartDelayCloseTimer()
    if this.delayCloseTimer == nil then
        this.delayCloseTimer = Timing.New(this.OnDelayCloseTimer, 0.8)
    end
    this.delayCloseTimer:Restart()
end

--停止或者关闭延迟计时器
function RoomGpsPanel.StopDelayCloseTimer()
    if this.delayCloseTimer ~= nil then
        this.delayCloseTimer:Stop()
        this.delayCloseTimer = nil
    end
end

--延迟关闭
function RoomGpsPanel.OnDelayCloseTimer()
    this.StopDelayCloseTimer()
    --延迟关闭，时间要小于小结界面的弹出时间
    this.Close()
end