Pin3PlaybackPanel = ClassPanel("Pin3PlaybackPanel")
Pin3PlaybackPanel.Instance = nil
--
local this = nil
--
--初始属性数据
function Pin3PlaybackPanel:InitProperty()
    --是否自动播放
    this.isAutoPlayback = false
    --自动播放的Timer
    this.autoPlayTimer = nil
    --自动播放的计时
    this.autoPlayTime = 0
end

--UI初始化
function Pin3PlaybackPanel:OnInitUI()
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
function Pin3PlaybackPanel:OnOpened()
    Pin3PlaybackPanel.Instance = self
    this.AddListenerEvent()
    this.UpdateDisplay()
end

--当面板关闭时调用
function Pin3PlaybackPanel:OnClosed()
    Pin3PlaybackPanel.Instance = nil
    this.RemoveListenerEvent()
    this.StopAutoPlayTimer()
    this.isAutoPlayback = false
    UIUtil.SetActive(this.settlementBtn, false)
end

------------------------------------------------------------------
--
--关闭
function Pin3PlaybackPanel.Close()
    PanelManager.Close(Pin3Panels.Pin3Playback)
end
--
function Pin3PlaybackPanel.AddListenerEvent()


end
--
function Pin3PlaybackPanel.RemoveListenerEvent()

end

--UI相关事件
function Pin3PlaybackPanel.AddUIListenerEvent()
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

--重放
function Pin3PlaybackPanel.OnReplayBtnClick()
    Pin3PlaybackManager.Replay()
    
    if this.isAutoPlayback then
        --重播，处理自动播放，需要重置时间
        this.StartAutoPlayTimer()
    end
end

--上一手
function Pin3PlaybackPanel.OnPrevBtnClick()
    this.Pause()
    Pin3PlaybackManager.PlayPrev()
end

--暂停
function Pin3PlaybackPanel.OnPauseBtnClick()
    this.Pause()
end

--回放暂停
function Pin3PlaybackPanel.OnResumeBtnClick()
    if not this.isAutoPlayback then
        UIUtil.SetActive(this.pauseBtn, true)
        UIUtil.SetActive(this.resumeBtn, false)
    end
    this.SetAutoPlay(true)
end

--下一手
function Pin3PlaybackPanel.OnNextBtnClick()
    this.Pause()
    Pin3PlaybackManager.PlayNext()
end

--退出
function Pin3PlaybackPanel.OnQuitBtnClick()
    Alert.Prompt("是否退出回放？", this.OnQuitAlert)
end

--退出提示处理
function Pin3PlaybackPanel.OnQuitAlert()
    Pin3Manager.QuitRoom()
end

--结算
function Pin3PlaybackPanel.SettlementBtnClick()
    -- if Pin3PlaybackManager.settlementData ~= nil then
    --     PanelManager.Open(MahjongPanelConfig.SingleSettlement)
    -- else
    --     Toast.Show("暂无结算信息")
    -- end
end
------------------------------------------------------------------
--
function Pin3PlaybackPanel.UpdateDisplay()
    if Pin3PlaybackManager.time ~= nil then
        this.timeTxt.text = Pin3Utils.GetDateByTimeStamp(Pin3PlaybackManager.time)
    else
        this.timeTxt.text = ""
    end
    UIUtil.SetActive(this.pauseBtn, this.isAutoPlayback)
    UIUtil.SetActive(this.resumeBtn, not this.isAutoPlayback)
    this.SetAutoPlay(this.isAutoPlayback)
end

--设置结算按钮的显示
function Pin3PlaybackPanel.SetSettlementBtnActive(isActive)
    UIUtil.SetActive(this.settlementBtn, isActive)
end

--暂停
function Pin3PlaybackPanel.Pause()
    if this.isAutoPlayback then
        UIUtil.SetActive(this.pauseBtn, false)
        UIUtil.SetActive(this.resumeBtn, true)
    end
    this.SetAutoPlay(false)
end

--设置是否自动播放
function Pin3PlaybackPanel.SetAutoPlay(isAutoPlay)
    this.isAutoPlayback = isAutoPlay
    this.CheckAutoPlay()
end

--检测是否自动播放
function Pin3PlaybackPanel.CheckAutoPlay()
    if this.isAutoPlayback then
        this.StartAutoPlayTimer()
    else
        this.StopAutoPlayTimer()
    end
end

--检测开始自动Timer
function Pin3PlaybackPanel.StartAutoPlayTimer()
    if this.autoPlayTimer == nil then
        this.autoPlayTime = Time.realtimeSinceStartup
        this.autoPlayTimer = Timing.New(this.OnAutoPlayTimer, 0.2)
    end
    this.autoPlayTimer:Restart()
end

--停止Timer
function Pin3PlaybackPanel.StopAutoPlayTimer()
    if this.autoPlayTimer ~= nil then
        this.autoPlayTimer:Stop()
        this.autoPlayTimer = nil
    end
end

--处理Timer
function Pin3PlaybackPanel.OnAutoPlayTimer()
    if Time.realtimeSinceStartup - this.autoPlayTime > 0.79 then
        this.autoPlayTime = Time.realtimeSinceStartup
        --播放失败，即后续没有数据
        if Pin3PlaybackManager.PlayNext() == false then
            this.StopAutoPlayTimer()
        end
    end
end