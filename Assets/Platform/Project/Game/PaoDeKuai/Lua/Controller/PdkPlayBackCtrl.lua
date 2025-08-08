PdkPlayBackCtrl = {
    --回放数据，所有的数据
    data = nil,
    --数据是否有效
    isDataValid = false,
    --播放索引
    index = 0,
    --播放总数
    total = 1,
    --牌局时间
    time = 0,
    --步骤数据
    step = {},
    --操作的包含项
    opTypes = {},
    --是否播放下一步标识
    isPlayNextStep = true,
}
local this = PdkPlayBackCtrl

--回放初始化
function PdkPlayBackCtrl.Init(data)
    this.data = data
    this.isDataValid = false
    if this.data == nil then
        Alert.Show("回放数据错误，返回大厅", this.OnErrorAlert)
    else
        this.isDataValid = true
        this.time = this.data[1].time
        this.total = #this.data
    end
end

--开始回放，界面准备好了后调用
function PdkPlayBackCtrl.BeginPlayback()
    if this.isDataValid then
        this.index = 0
        PanelManager.Open(PdkPanelConfig.Playback)
        this.PlayNext()
    end
end

--重播
function PdkPlayBackCtrl.Replay()
    PdkPlaybackPanel.SetSettlementBtnActive(false)
    this.index = 0
    this.PlayNext()
end

--播放上一手回放
function PdkPlayBackCtrl.PlayPrev()
    -- if MahjongAnimMgr.isPlayingHuanAnim then
    --     MahjongAnimMgr.StopHuanAnim()
    -- end
    this.isPlayNextStep = false
    if this.index > this.total then
        this.index = this.total
    end
    if this.index <= this.total and this.index > 0 then
        this.index = this.index - 1
        if this.index < 1 then--由于第一手数据是加入房间，所有相后点的时候，播放第手局数据就可以了
            Toast.Show("已经是回放开始数据")
            this.index = 1
            return
        end
        --获取数据，并显示
        this.UpdateStepData()
    end
end

--播放下一手回放
function PdkPlayBackCtrl.PlayNext()
    this.isPlayNextStep = true
    if this.index <= this.total then
        this.index = this.index + 1
        if this.index > this.total then
            Toast.Show("回放数据播放完成")
            this.index = this.total
            return false
        end
        --获取数据，并显示
        this.UpdateStepData()
    end
    return true
end

function PdkPlayBackCtrl.UpdateStepData()
    local stepData = this.data[this.index]
    if stepData == nil then
        Alert.Show("回放数据错误，操作序号：" .. this.index)
        return false
    end

    if not this.isPlayNextStep then
        PdkPlaybackPanel.SetSettlementBtnActive(false)
    end

    if stepData.code == 1 then
        PdkRoomPanel.Reset()
        -- PdkSelfHandCardCtrl.Clear()
        PdkRoomModule.InitRoomInfo(stepData)
        PdkRoomPanel.SetRoomID(PdkRoomModule.roomId)
        PdkRoomPanel.SetRoomRound(PdkRoomModule.nowjs, PdkRoomModule.maxjs)
        PdkRoomPanel.SetPlayType(PdkRoomModule.playWayType)
        --初始化玩家信息
        for k, v in pairs(PdkRoomModule.players) do
            PdkRoomPanel.PlayerInit(k, v)
        end
    elseif stepData.code == 2 then
        PdkRoomPanel.Reset()
        -- PdkSelfHandCardCtrl.Clear()
        local index = PdkRoomModule.GetPlayerLocalSeat(stepData.doSeat)
        local player = PdkRoomModule.GetPlayerInfoBySeat(index)
        if player ~= nil then
            if stepData.isPast == 1 then
                PdkRoomPanel.ShowPass(index, true)
                PdkAudioCtrl.PlayPass(player.playerSex)
            else
                --显示打出的牌
                PdkRoomPanel.PlayerOutCard(index, stepData.showPokers)
                --播放特效
                PdkRoomPanel.PlayEffect(index, stepData.showPokerType)
                --播放音效
                local value = nil
                if stepData.showPokerType == PdkPokerType.Single or stepData.showPokerType == PdkPokerType.Double then
                     value = PdkPokerLogic.GetIdPoint(stepData.showPokers[1])
                end
                PdkAudioCtrl.PlayCardSound(player.playerSex, stepData.showPokerType, value)
                -- --播放报单音效
                -- if stepData.pokerNum == 1 then
                --     PdkAudioCtrl.PlayBaoDan(player.sex)
                -- end
            end
        else
            LogError("玩家信息不存在：", index)
        end
        local temp = nil
        for i = 1, #stepData.list do
            temp = stepData.list[i]
            index = PdkRoomModule.GetPlayerLocalSeat(temp.seatNum)
            local playerData = PdkRoomModule.GetPlayerInfoBySeat(index)
            if playerData ~= nil then
                if GetTableSize(temp.pokers) == 1 then
                    --报单特效
                    PdkRoomPanel.UpdateCardNum(index, 1)
                    if  playerData.isPlayBaoDan == nil or not playerData.isPlayBaoDan then
                        --报单音效
                        PdkAudioCtrl.PlayBaoDan(playerData.sex)
                        playerData.isPlayBaoDan = true
                    end
                else
                    playerData.isPlayBaoDan = false
                end
            else
                LogError("玩家信息不存在：", index)
            end
            if index == 1 then
                -- PdkSelfHandCardCtrl.Clear()
                PdkSelfHandCardCtrl.CreateHandPoker(temp.pokers)
            else
                -- PdkRoomPanel.ClearHandPoker(index)
                PdkRoomPanel.CreateCard(index, temp.pokers)
            end
            PdkRoomPanel.SetScoreNum(index, tonumber(temp.score))
            if temp.isTuoGuan ~= nil then
                PdkRoomPanel.PlayerTuoGuan(index, temp.isTuoGuan > 0)
            end
        end
    elseif stepData.code == 3 then
        this.SingleRecordData = stepData
        PdkPlaybackPanel.SetSettlementBtnActive(true)
    end
end

function PdkPlayBackCtrl.OnErrorAlert()
    PdkRoomCtrl.ExitRoom()
end