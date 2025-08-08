PdkPlaybackPanel = ClassPanel("PdkPlaybackPanel")
local this = PdkPlaybackPanel
--
--初始属性数据
function PdkPlaybackPanel:InitProperty()
    --是否自动播放
    this.isAutoPlayback = false
    --自动播放的Timer
    this.autoPlayTimer = nil
    --自动播放的计时
    this.autoPlayTime = 0
end

--UI初始化
function PdkPlaybackPanel:OnInitUI()
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
function PdkPlaybackPanel:OnOpened()
    this.AddListenerEvent()
    this.UpdateDisplay()
end

--当面板关闭时调用
function PdkPlaybackPanel:OnClosed()
    this.RemoveListenerEvent()
    this.StopAutoPlayTimer()
    this.isAutoPlayback = false
    UIUtil.SetActive(this.settlementBtn, false)
end

------------------------------------------------------------------
--
--关闭
function PdkPlaybackPanel.Close()
    PanelManager.Close(PdkPanelConfig.Playback)
end
--
function PdkPlaybackPanel.AddListenerEvent()

end
--
function PdkPlaybackPanel.RemoveListenerEvent()

end

--UI相关事件
function PdkPlaybackPanel.AddUIListenerEvent()
    this:AddOnClick(this.replayBtn, this.OnReplayBtnClick)
    this:AddOnClick(this.prevBtn, this.OnPrevBtnClick)
    this:AddOnClick(this.pauseBtn, this.OnPauseBtnClick)
    this:AddOnClick(this.resumeBtn, this.OnResumeBtnClick)
    this:AddOnClick(this.nextBtn, this.OnNextBtnClick)
    this:AddOnClick(this.quitBtn, this.OnQuitBtnClick)
    this:AddOnClick(this.settlementBtn, this.SettlementBtnClick)
end

--重放
function PdkPlaybackPanel.OnReplayBtnClick()
    PdkPlayBackCtrl.Replay()
    
    if this.isAutoPlayback then
        --重播，处理自动播放，需要重置时间
        this.StartAutoPlayTimer()
    end
end

--上一手
function PdkPlaybackPanel.OnPrevBtnClick()
    this.Pause()
    PdkPlayBackCtrl.PlayPrev()
end

--暂停
function PdkPlaybackPanel.OnPauseBtnClick()
    this.Pause()
end

--回放暂停
function PdkPlaybackPanel.OnResumeBtnClick()
    if not this.isAutoPlayback then
        UIUtil.SetActive(this.pauseBtn, true)
        UIUtil.SetActive(this.resumeBtn, false)
    end
    this.SetAutoPlay(true)
end

--下一手
function PdkPlaybackPanel.OnNextBtnClick()
    this.Pause()
    PdkPlayBackCtrl.PlayNext()
end

--退出
function PdkPlaybackPanel.OnQuitBtnClick()
    Alert.Prompt("是否退出回放？", this.OnQuitAlert)
end

--退出提示处理
function PdkPlaybackPanel.OnQuitAlert()
    PdkRoomCtrl.ExitRoom()
end

--结算
function PdkPlaybackPanel.SettlementBtnClick()
    if PdkPlayBackCtrl.SingleRecordData ~= nil then
        PanelManager.Open(PdkPanelConfig.SingleRecord, PdkPlayBackCtrl.SingleRecordData)
    else
        Toast.Show("暂无结算信息")
    end
end
------------------------------------------------------------------
--
function PdkPlaybackPanel.UpdateDisplay()
    if PdkPlayBackCtrl.time ~= nil then
        this.timeTxt.text = os.date("%Y-%m-%d %H:%M:%S", PdkPlayBackCtrl.time / 1000)
    else
        this.timeTxt.text = ""
    end
    UIUtil.SetActive(this.pauseBtn, this.isAutoPlayback)
    UIUtil.SetActive(this.resumeBtn, not this.isAutoPlayback)
    this.SetAutoPlay(this.isAutoPlayback)
end

--设置结算按钮的显示
function PdkPlaybackPanel.SetSettlementBtnActive(isActive)
    UIUtil.SetActive(this.settlementBtn, isActive)
end

--暂停
function PdkPlaybackPanel.Pause()
    if this.isAutoPlayback then
        UIUtil.SetActive(this.pauseBtn, false)
        UIUtil.SetActive(this.resumeBtn, true)
    end
    this.SetAutoPlay(false)
end

--设置是否自动播放
function PdkPlaybackPanel.SetAutoPlay(isAutoPlay)
    this.isAutoPlayback = isAutoPlay
    this.CheckAutoPlay()
end

--检测是否自动播放
function PdkPlaybackPanel.CheckAutoPlay()
    if this.isAutoPlayback then
        this.StartAutoPlayTimer()
    else
        this.StopAutoPlayTimer()
    end
end

--检测开始自动Timer
function PdkPlaybackPanel.StartAutoPlayTimer()
    if this.autoPlayTimer == nil then
        this.autoPlayTime = Time.realtimeSinceStartup
        this.autoPlayTimer = Timing.New(this.OnAutoPlayTimer, 0.2)
    end
    this.autoPlayTimer:Restart()
end

--停止Timer
function PdkPlaybackPanel.StopAutoPlayTimer()
    if this.autoPlayTimer ~= nil then
        this.autoPlayTimer:Stop()
        this.autoPlayTimer = nil
    end
end

--处理Timer
function PdkPlaybackPanel.OnAutoPlayTimer()
    if Time.realtimeSinceStartup - this.autoPlayTime > 0.79 then
        this.autoPlayTime = Time.realtimeSinceStartup
        --播放失败，即后续没有数据
        if PdkPlayBackCtrl.PlayNext() == false then
            this.StopAutoPlayTimer()
        end
    end
end