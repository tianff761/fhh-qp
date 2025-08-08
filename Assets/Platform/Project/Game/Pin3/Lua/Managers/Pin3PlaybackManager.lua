--回放管理
Pin3PlaybackManager = {
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

local this = Pin3PlaybackManager

--回放初始化
function Pin3PlaybackManager.Initialize(data)
    this.data = data
    this.isDataValid = false
    if this.data == nil or this.data.step == nil or #this.data.step < 1 then
        Alert.Show("回放数据错误，返回大厅", this.OnErrorAlert)
    else
        this.isDataValid = true
        this.time = this.data.time
        this.total = #this.data.step
    end
end

--回放清除
function Pin3PlaybackManager.Clear()
    this.data = nil
    this.index = 0
    this.total = 1
    this.isDataValid = false
    this.isPlayNextStep = true
    this.step = {}
    this.settlementData = nil
end

--开发回放，界面准备好了后调用
function Pin3PlaybackManager.BeginPlayback()
    if this.isDataValid then
        this.index = 0
        PanelManager.Open(Pin3Panels.Pin3Playback)
        this.PlayNext()
    end
end

--检测是否为回放操作
function Pin3PlaybackManager.CheckPlaybackOperate(type)
    if this.opTypes[type] ~= nil then
        return true
    end
    return false
end

--转换回放类型
function Pin3PlaybackManager.ConvertPlaybackOperate(type)
    return this.opTypes[type]
end

--================================================================
--
function Pin3PlaybackManager.OnErrorAlert()
    Pin3Manager.QuitRoom()
end


--================================================================
--重播
function Pin3PlaybackManager.Replay()
    --关闭解散按钮
    if Pin3PlaybackPanel.Instance ~= nil then
        Pin3PlaybackPanel.Instance.SetSettlementBtnActive(false)
    end
    Pin3BattlePanel.ResetForNext()
    Pin3Manager.ClearByPlayback()
    this.index = 0
    this.PlayNext()
end

--播放上一手回放
function Pin3PlaybackManager.PlayPrev()
    this.isPlayNextStep = false
    if this.index > this.total then
        this.index = this.total
    end
    if this.index <= this.total and this.index > 0 then
        this.index = this.index - 1
        if this.index < 2 then--由于第一手数据是加入房间，所有相后点的时候，播放第手局数据就可以了
            Toast.Show("已经是回放开始数据")
            this.index = 2
            return
        end
        --获取数据，并显示
        this.UpdateStepData()
    end
end

--播放下一手回放
function Pin3PlaybackManager.PlayNext()
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

--检查下一步是不是更新桌子状态，如果是就播放
function Pin3PlaybackManager.CheckNextStepUpdateTableOperStatus()
    local stepData = this.GetStepData(this.index + 1)
    if stepData ~= nil and stepData.cmdId == CMD.Tcp.Pin3.S2C_UpdateTableOperStatus then
        this.PlayNext()
    end
end

--检查上一步是不是更新桌子状态，如果不是就播放
function Pin3PlaybackManager.CheckPrevStepNotUpdateTableOperStatus()
    local stepData = this.GetStepData(this.index - 1)
    if stepData ~= nil and stepData.cmdId ~= CMD.Tcp.Pin3.S2C_UpdateTableOperStatus then
        this.PlayPrev()
    end
end

--================================================================
--
--获取步骤数据
function Pin3PlaybackManager.GetStepData(index)
    local stepData = this.step[index]
    if stepData == nil then
        local str = this.data.step[index]
        if str ~= nil then
            stepData = JsonToObj(str)
            this.step[index] = stepData
        end
    end
    return stepData
end

--更新步骤数据
function Pin3PlaybackManager.UpdateStepData()
    --Log(">> Pin3PlaybackManager.UpdateStepData > this.index = ", this.index)
    local stepData = this.GetStepData(this.index)
    if stepData == nil then
        Alert.Show("回放数据错误，操作序号：" .. this.index)
        return false
    end

    --上一步需要关闭将结算按钮
    if not this.isPlayNextStep then
        if Pin3PlaybackPanel.Instance ~= nil then
            Pin3PlaybackPanel.Instance.SetSettlementBtnActive(false)
        end
    end

    if stepData ~= nil then
        --LogError("====================================================")
        --LogError(stepData)
        if stepData.cmdId == CMD.Tcp.Pin3.S2C_UserPerformOper then
            --操作
            TryCatchCall(Pin3NetworkManager.HandleOnTcpPerformOper, stepData)
            if this.isPlayNextStep then
                this.CheckNextStepUpdateTableOperStatus()
            end
            --
        elseif stepData.cmdId == CMD.Tcp.Pin3.S2C_UpdateTableOperStatus then
            --更新桌子状态
            TryCatchCall(Pin3NetworkManager.HandleOnTcpUpdateTableOperStatus, stepData)
            if not this.isPlayNextStep then
                --向上播放，需要检查上一步不是更新桌子状态就播放
                this.CheckPrevStepNotUpdateTableOperStatus()
            end
            --
        elseif stepData.cmdId == CMD.Tcp.Pin3.S2C_GetRoomData then
            --获取房间数据
            TryCatchCall(Pin3NetworkManager.HandleOnTcpRoomInfo, stepData)
            --
        elseif stepData.cmdId == CMD.Tcp.Pin3.S2C_DanJuJieSuan then
            --单局结算
            TryCatchCall(Pin3NetworkManager.HandleJieSuanByPlayback, stepData)
            --
        else
            Log(">> Pin3 > Pin3PlaybackManager.UpdateStepData > cmdId = ", stepData.cmdId)
        end
    end
end