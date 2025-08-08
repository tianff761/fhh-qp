--回放管理
TpPlaybackCardMgr = {
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
    --结算数据
    settlementData = nil,
}

local this = TpPlaybackCardMgr

--回放初始化
function TpPlaybackCardMgr.Initialize(data)
    this.data = data
    this.isDataValid = false
    LogError(">> TpPlaybackCardMgr.Initialize", data)
    if this.data == nil or this.data.step == nil or #this.data.step < 1 then
        Alert.Show("回放数据错误，返回大厅", this.OnErrorAlert)
    else
        this.isDataValid = true
        this.time = this.data.time
        this.total = #this.data.step
    end

    if #this.opTypes < 1 then
        this.opTypes[TpOperateType.Bet] = TpOperateType.Bet

        this.opTypes[TpOperateType.Gen] = TpOperateType.Gen
        this.opTypes[TpOperateType.AllIn] = TpOperateType.AllIn
        this.opTypes[TpOperateType.GiveUp] = TpOperateType.GiveUp
        this.opTypes[TpOperateType.Check] = TpOperateType.Check
    end
end

--回放清除
function TpPlaybackCardMgr.Clear()
    this.data = nil
    this.index = 0
    this.total = 1
    this.isDataValid = false
    this.isPlayNextStep = true
    this.step = {}
    this.settlementData = nil
end

--开发回放，界面准备好了后调用
function TpPlaybackCardMgr.BeginPlayback()
    if this.isDataValid then
        this.index = 0
        PanelManager.Open(TpPanelConfig.Playback)
        --
        this.PlayNext()
    end
end

--检测是否为回放操作
function TpPlaybackCardMgr.CheckPlaybackOperate(type)
    if this.opTypes[type] ~= nil then
        return true
    end
    return false
end

--转换回放类型
function TpPlaybackCardMgr.ConvertPlaybackOperate(type)
    return this.opTypes[type]
end

--================================================================
--
function TpPlaybackCardMgr.OnErrorAlert()
    TpRoomMgr.ExitRoom()
end

--================================================================
--重播
function TpPlaybackCardMgr.Replay()
    --关闭解散按钮
    if TpPlaybackPanel.Instance ~= nil then
        TpPlaybackPanel.Instance.SetSettlementBtnActive(false)
    end
    if TpRoomPanel.Instance ~= nil then
        TpRoomPanel.Instance.Reset()
    end
    this.index = 0
    this.PlayNext()
    this.PlayNext()
end

--播放上一手回放
function TpPlaybackCardMgr.PlayPrev()
    this.isPlayNextStep = false
    if this.index > this.total then
        this.index = this.total
    end
    if this.index <= this.total and this.index > 0 then
        this.index = this.index - 1
        if this.index < 2 then --由于第一手数据是加入房间，所有相后点的时候，播放第手局数据就可以了
            Toast.Show("已经是回放开始数据")
            this.index = 2
            return
        end
        --获取数据，并显示
        this.UpdateStepData()
    end
end

--播放下一手回放
function TpPlaybackCardMgr.PlayNext()
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

--================================================================
--
--更新步骤数据
function TpPlaybackCardMgr.UpdateStepData()
    --Log(">> TpPlaybackCardMgr.UpdateStepData > this.index = ", this.index)
    local stepData = this.step[this.index]
    if stepData == nil then
        local str = this.data.step[this.index]
        if str == nil then
            Alert.Show("回放数据错误，操作序号：" .. this.index)
            return false
        end
        stepData = str --JsonToObj(str)
        this.step[this.index] = stepData
    end

    --上一步需要关闭将结算按钮
    if not this.isPlayNextStep then
        if TpPlaybackPanel.Instance ~= nil then
            TpPlaybackPanel.Instance.SetSettlementBtnActive(false)
        end
    end

    if stepData ~= nil then
        --Log("====================================================")
        LogError(stepData)
        if stepData.cmdId == CMD.Tcp.Tp.Push_Operate then
            --跳过特殊处理
            if this.isPlayNextStep then
                --操作
                TryCatchCall(TpRoomMgr.HandleOnPushOperate, stepData)
                --
                if stepData.pId ~= TpDataMgr.userId then
                    this.PlayNext()
                end
            else
                if stepData.pId ~= TpDataMgr.userId then
                    this.PlayPrev()
                else
                    TryCatchCall(TpRoomMgr.HandleOnPushOperate, stepData)
                end
            end
        elseif stepData.cmdId == CMD.Tcp.Tp.Push_PlayerOperate then
            --跳过特殊处理
            if this.isPlayNextStep then
                --通知操作
                TryCatchCall(TpRoomMgr.HandlePushPlayerOperate, stepData)
                --
                this.PlayNext()
            else
                this.PlayPrev()
            end
        elseif stepData.cmdId == CMD.Tcp.Tp.Push_Game then
            TpRoomMgr.Reset()
            --游戏开始
            TryCatchCall(TpRoomMgr.HandleOnPushGame, stepData)
            --
        elseif stepData.cmdId == CMD.Tcp.Tp.Push_GameStatus then
            --
            TryCatchCall(TpRoomMgr.HandleOnPushGameStatus, stepData)
            --
        elseif stepData.cmdId == CMD.Tcp.Tp.Push_PlayerDeal then
            --
            TryCatchCall(TpRoomMgr.HandlePushPlayerDeal, stepData)
            --
        elseif stepData.cmdId == CMD.Tcp.Tp.Push_SingleSettlement then
            --
            TryCatchCall(TpRoomMgr.HandleOnPushSingleSettlement, stepData)
            --
        else
            LogError(">> Tp > TpPlaybackCardMgr.UpdateStepData > cmdId = ", stepData.cmdId)
        end
    end
end
