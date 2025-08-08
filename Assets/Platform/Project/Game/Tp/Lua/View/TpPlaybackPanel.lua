TpPlaybackPanel = ClassPanel("TpPlaybackPanel")
TpPlaybackPanel.Instance = nil
--
local this = nil
--
--初始属性数据
function TpPlaybackPanel:InitProperty()
    --是否自动播放
    this.isAutoPlayback = false
    --自动播放的Timer
    this.autoPlayTimer = nil
    --自动播放的计时
    this.autoPlayTime = 0
end

--UI初始化
function TpPlaybackPanel:OnInitUI()
    this = self
    this:InitProperty()

    local playbackTrans = self:Find("Playback")

    this.replayBtn = playbackTrans:Find("ReplayButton").gameObject
    this.prevBtn = playbackTrans:Find("PrevButton").gameObject
    this.pauseBtn = playbackTrans:Find("PauseButton").gameObject
    this.resumeBtn = playbackTrans:Find("ResumeButton").gameObject
    this.nextBtn = playbackTrans:Find("NextButton").gameObject
    this.quitBtn = playbackTrans:Find("QuitButton").gameObject

    this.settlementBtn = self:Find("SettlementButton").gameObject
    this.timeTxt = self:Find("TimeText"):GetComponent("Text")

    this.AddUIListenerEvent()
end


--当面板开启开启时
function TpPlaybackPanel:OnOpened()
    TpPlaybackPanel.Instance = self
    this.AddListenerEvent()
    this.UpdateDisplay()
end

--当面板关闭时调用
function TpPlaybackPanel:OnClosed()
    TpPlaybackPanel.Instance = nil
    this.RemoveListenerEvent()
    this.StopAutoPlayTimer()
    this.isAutoPlayback = false
    UIUtil.SetActive(this.settlementBtn, false)
end

------------------------------------------------------------------
--
--关闭
function TpPlaybackPanel.Close()
    PanelManager.Close(TpPanelConfig.Playback)
end
--
function TpPlaybackPanel.AddListenerEvent()
    AddEventListener(CMD.Game.Tp.LiuJuEffectFinished, this.OnLiuJuEffectFinished)

end
--
function TpPlaybackPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Game.Tp.LiuJuEffectFinished, this.OnLiuJuEffectFinished)
end

--UI相关事件
function TpPlaybackPanel.AddUIListenerEvent()
    this:AddOnClick(this.replayBtn, this.OnReplayBtnClick)
    this:AddOnClick(this.prevBtn, this.OnPrevBtnClick)
    this:AddOnClick(this.pauseBtn, this.OnPauseBtnClick)
    this:AddOnClick(this.resumeBtn, this.OnResumeBtnClick)
    this:AddOnClick(this.nextBtn, this.OnNextBtnClick)
    this:AddOnClick(this.quitBtn, this.OnQuitBtnClick)
    this:AddOnClick(this.settlementBtn, this.SettlementBtnClick)
end

------------------------------------------------------------------
--
--流局特效播放完成
function TpPlaybackPanel.OnLiuJuEffectFinished()
    this.SetSettlementBtnActive(true)
end

--重放
function TpPlaybackPanel.OnReplayBtnClick()
    TpPlaybackCardMgr.Replay()
    
    if this.isAutoPlayback then
        --重播，处理自动播放，需要重置时间
        this.StartAutoPlayTimer()
    end
end

--上一手
function TpPlaybackPanel.OnPrevBtnClick()
    this.Pause()
    TpPlaybackCardMgr.PlayPrev()
end

--暂停
function TpPlaybackPanel.OnPauseBtnClick()
    this.Pause()
end

--回放暂停
function TpPlaybackPanel.OnResumeBtnClick()
    if not this.isAutoPlayback then
        UIUtil.SetActive(this.pauseBtn, true)
        UIUtil.SetActive(this.resumeBtn, false)
    end
    this.SetAutoPlay(true)
end

--下一手
function TpPlaybackPanel.OnNextBtnClick()
    this.Pause()
    TpPlaybackCardMgr.PlayNext()
end

--退出
function TpPlaybackPanel.OnQuitBtnClick()
    Alert.Prompt("是否退出回放？", this.OnQuitAlert)
end

--退出提示处理
function TpPlaybackPanel.OnQuitAlert()
    TpRoomMgr.ExitRoom()
end

--结算
function TpPlaybackPanel.SettlementBtnClick()
    if TpPlaybackCardMgr.settlementData ~= nil then
        PanelManager.Open(TpPanelConfig.SingleSettlement)
    else
        Toast.Show("暂无结算信息")
    end
end
------------------------------------------------------------------
--
function TpPlaybackPanel.UpdateDisplay()
    if TpPlaybackCardMgr.time ~= nil then
        this.timeTxt.text = TpUtil.GetDateByTimeStamp(TpPlaybackCardMgr.time)
    else
        this.timeTxt.text = ""
    end
    UIUtil.SetActive(this.pauseBtn, this.isAutoPlayback)
    UIUtil.SetActive(this.resumeBtn, not this.isAutoPlayback)
    this.SetAutoPlay(this.isAutoPlayback)
end

--设置结算按钮的显示
function TpPlaybackPanel.SetSettlementBtnActive(isActive)
    UIUtil.SetActive(this.settlementBtn, isActive)
end

--暂停
function TpPlaybackPanel.Pause()
    if this.isAutoPlayback then
        UIUtil.SetActive(this.pauseBtn, false)
        UIUtil.SetActive(this.resumeBtn, true)
    end
    this.SetAutoPlay(false)
end

--设置是否自动播放
function TpPlaybackPanel.SetAutoPlay(isAutoPlay)
    this.isAutoPlayback = isAutoPlay
    this.CheckAutoPlay()
end

--检测是否自动播放
function TpPlaybackPanel.CheckAutoPlay()
    if this.isAutoPlayback then
        this.StartAutoPlayTimer()
    else
        this.StopAutoPlayTimer()
    end
end

--检测开始自动Timer
function TpPlaybackPanel.StartAutoPlayTimer()
    if this.autoPlayTimer == nil then
        this.autoPlayTime = Time.realtimeSinceStartup
        this.autoPlayTimer = Timing.New(this.OnAutoPlayTimer, 0.2)
    end
    this.autoPlayTimer:Restart()
end

--停止Timer
function TpPlaybackPanel.StopAutoPlayTimer()
    if this.autoPlayTimer ~= nil then
        this.autoPlayTimer:Stop()
        this.autoPlayTimer = nil
    end
end

--处理Timer
function TpPlaybackPanel.OnAutoPlayTimer()
    if Time.realtimeSinceStartup - this.autoPlayTime > 0.79 then
        this.autoPlayTime = Time.realtimeSinceStartup
        --播放失败，即后续没有数据
        if TpPlaybackCardMgr.PlayNext() == false then
            this.StopAutoPlayTimer()
        end
    end
end