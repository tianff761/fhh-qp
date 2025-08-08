--回放管理
MahjongPlaybackCardMgr = {
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

local this = MahjongPlaybackCardMgr

--回放初始化
function MahjongPlaybackCardMgr.Initialize(data)
    this.data = data
    this.isDataValid = false
    if this.data == nil or this.data.step == nil or #this.data.step < 1 then
        Alert.Show("回放数据错误，返回大厅", this.OnErrorAlert)
    else
        this.isDataValid = true
        this.time = this.data.time
        this.total = #this.data.step
    end

    if #this.opTypes < 1 then
        this.opTypes[MahjongOperateCode.HU] = MahjongOperateCode.HU

        this.opTypes[MahjongOperateCode.GANG] = MahjongOperateCode.GANG
        this.opTypes[MahjongOperateCode.GANG_IN] = MahjongOperateCode.GANG
        this.opTypes[MahjongOperateCode.GANG_ALL_IN] = MahjongOperateCode.GANG
        this.opTypes[MahjongOperateCode.PENG] = MahjongOperateCode.PENG
    
        this.opTypes[MahjongOperateCode.HUAN_PAI] = 1
        this.opTypes[MahjongOperateCode.SPC_GANG] = MahjongOperateCode.GANG
        this.opTypes[MahjongOperateCode.SPC_GANG_IN] = MahjongOperateCode.GANG
        this.opTypes[MahjongOperateCode.SPC_GANG_ALL_IN] = MahjongOperateCode.GANG
        this.opTypes[MahjongOperateCode.SPC_PENG] = MahjongOperateCode.PENG

        this.opTypes[MahjongOperateCode.HUAN_ZHANG] = MahjongOperateCode.HUAN_ZHANG
        this.opTypes[MahjongOperateCode.DING_QUE] = MahjongOperateCode.DING_QUE

        this.opTypes[MahjongOperateCode.GUO] = MahjongOperateCode.GUO
    end

end

--回放清除
function MahjongPlaybackCardMgr.Clear()
    this.data = nil
    this.index = 0
    this.total = 1
    this.isDataValid = false
    this.isPlayNextStep = true
    this.step = {}
    this.settlementData = nil
end

--开发回放，界面准备好了后调用
function MahjongPlaybackCardMgr.BeginPlayback()
    if this.isDataValid then
        this.index = 0
        PanelManager.Open(MahjongPanelConfig.Playback)
        --由于第一手数据是加入房间，故需要播放2次
        this.PlayNext()
        this.PlayNext()
    end
end

--检测是否为回放操作
function MahjongPlaybackCardMgr.CheckPlaybackOperate(type)
    if this.opTypes[type] ~= nil then
        return true
    end
    return false
end

--转换回放类型
function MahjongPlaybackCardMgr.ConvertPlaybackOperate(type)
    return this.opTypes[type]
end

--================================================================
--
function MahjongPlaybackCardMgr.OnErrorAlert()
    MahjongRoomMgr.ExitRoom()
end


--================================================================
--重播
function MahjongPlaybackCardMgr.Replay()
    --关闭换牌动画
    MahjongAnimMgr.StopHuanAnim()
    --关闭解散按钮
    if MahjongPlaybackPanel.Instance ~= nil then
        MahjongPlaybackPanel.Instance.SetSettlementBtnActive(false)
    end
    this.index = 0
    this.PlayNext()
    this.PlayNext()
end

--播放上一手回放
function MahjongPlaybackCardMgr.PlayPrev()
    if MahjongAnimMgr.isPlayingHuanAnim then
        MahjongAnimMgr.StopHuanAnim()
    end
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
function MahjongPlaybackCardMgr.PlayNext()
    if MahjongAnimMgr.isPlayingHuanAnim then
        --MahjongDataMgr.ClearChangeCards()
        MahjongAnimMgr.StopHuanAnim()
    end
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
function MahjongPlaybackCardMgr.UpdateStepData()
    --Log(">> MahjongPlaybackCardMgr.UpdateStepData > this.index = ", this.index)
    local stepData = this.step[this.index]
    if stepData == nil then
        local str = this.data.step[this.index]
        if str == nil then
            Alert.Show("回放数据错误，操作序号：" .. this.index)
            return false
        end
        stepData = JsonToObj(str)
        this.step[this.index] = stepData
    end

    --上一步需要关闭将结算按钮
    if not this.isPlayNextStep then
        if MahjongPlaybackPanel.Instance ~= nil then
            MahjongPlaybackPanel.Instance.SetSettlementBtnActive(false)
        end
        --上一步时，如果是换牌的协议，且是换牌的最后一个数据，就需要再上一步
        if stepData.cmdId == CMD.Tcp.Mahjong.Push_ChangeCard and stepData.dice > 0 then
            this.PlayPrev()
            return
        end
    end

    if stepData ~= nil then
        --Log("====================================================")
        --Log(stepData)
        if stepData.cmdId == CMD.Tcp.Mahjong.Push_Operate then
            --操作
            TryCatchCall(MahjongRoomMgr.HandleOnPushOperate, stepData)
            --
        elseif stepData.cmdId == CMD.Tcp.Mahjong.S2C_JoinRoom then
            MahjongRoomMgr.Reset()
            PanelManager.Close(MahjongPanelConfig.Operation)
            --加入房间
            TryCatchCall(MahjongRoomMgr.HandleOnJoinRoom, stepData)
            --
        elseif stepData.cmdId == CMD.Tcp.Mahjong.Push_GameBegin then
            --游戏开始
            TryCatchCall(MahjongRoomMgr.HandleOnPushGameBegin, stepData)
            --
        elseif stepData.cmdId == CMD.Tcp.Mahjong.Push_ChangeCard then
            --换张
            TryCatchCall(MahjongRoomMgr.HandleOnPushChangeCard, stepData)
            --
        elseif stepData.cmdId == CMD.Tcp.Mahjong.Push_GameEnd then
            this.settlementData = stepData
            if stepData.endState == MahjongEndState.LiuJu then
                --播放流局动画
                MahjongEffectMgr.PlayEffect(MahjongEffectMgr.EffectName.LiuJu, 0, false)
            else
                SendEvent(CMD.Game.Mahjong.LiuJuEffectFinished)
            end
        else
            Log(">> Mahjong > MahjongPlaybackCardMgr.UpdateStepData > cmdId = ", stepData.cmdId)
        end
    end
end