MahjongPlaybackPanel = ClassPanel("MahjongPlaybackPanel")
MahjongPlaybackPanel.Instance = nil
--
local this = nil
--
--初始属性数据
function MahjongPlaybackPanel:InitProperty()
    --是否自动播放
    this.isAutoPlayback = false
    --自动播放的Timer
    this.autoPlayTimer = nil
    --自动播放的计时
    this.autoPlayTime = 0
end

--UI初始化
function MahjongPlaybackPanel:OnInitUI()
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
function MahjongPlaybackPanel:OnOpened()
    MahjongPlaybackPanel.Instance = self
    this.AddListenerEvent()
    this.UpdateDisplay()
end

--当面板关闭时调用
function MahjongPlaybackPanel:OnClosed()
    MahjongPlaybackPanel.Instance = nil
    this.RemoveListenerEvent()
    this.StopAutoPlayTimer()
    this.isAutoPlayback = false
    UIUtil.SetActive(this.settlementBtn, false)
end

------------------------------------------------------------------
--
--关闭
function MahjongPlaybackPanel.Close()
    PanelManager.Close(MahjongPanelConfig.Playback)
end
--
function MahjongPlaybackPanel.AddListenerEvent()
    AddEventListener(CMD.Game.Mahjong.LiuJuEffectFinished, this.OnLiuJuEffectFinished)

end
--
function MahjongPlaybackPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Game.Mahjong.LiuJuEffectFinished, this.OnLiuJuEffectFinished)
end

--UI相关事件
function MahjongPlaybackPanel.AddUIListenerEvent()
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
function MahjongPlaybackPanel.OnLiuJuEffectFinished()
    this.SetSettlementBtnActive(true)
end

--重放
function MahjongPlaybackPanel.OnReplayBtnClick()
    MahjongPlaybackCardMgr.Replay()
    
    if this.isAutoPlayback then
        --重播，处理自动播放，需要重置时间
        this.StartAutoPlayTimer()
    end
end

--上一手
function MahjongPlaybackPanel.OnPrevBtnClick()
    this.Pause()
    MahjongPlaybackCardMgr.PlayPrev()
end

--暂停
function MahjongPlaybackPanel.OnPauseBtnClick()
    this.Pause()
end

--回放暂停
function MahjongPlaybackPanel.OnResumeBtnClick()
    if not this.isAutoPlayback then
        UIUtil.SetActive(this.pauseBtn, true)
        UIUtil.SetActive(this.resumeBtn, false)
    end
    this.SetAutoPlay(true)
end

--下一手
function MahjongPlaybackPanel.OnNextBtnClick()
    this.Pause()
    MahjongPlaybackCardMgr.PlayNext()
end

--退出
function MahjongPlaybackPanel.OnQuitBtnClick()
    Alert.Prompt("是否退出回放？", this.OnQuitAlert)
end

--退出提示处理
function MahjongPlaybackPanel.OnQuitAlert()
    MahjongRoomMgr.ExitRoom()
end

--结算
function MahjongPlaybackPanel.SettlementBtnClick()
    if MahjongPlaybackCardMgr.settlementData ~= nil then
        PanelManager.Open(MahjongPanelConfig.SingleSettlement)
    else
        Toast.Show("暂无结算信息")
    end
end
------------------------------------------------------------------
--
function MahjongPlaybackPanel.UpdateDisplay()
    if MahjongPlaybackCardMgr.time ~= nil then
        this.timeTxt.text = MahjongUtil.GetDateByTimeStamp(MahjongPlaybackCardMgr.time)
    else
        this.timeTxt.text = ""
    end
    UIUtil.SetActive(this.pauseBtn, this.isAutoPlayback)
    UIUtil.SetActive(this.resumeBtn, not this.isAutoPlayback)
    this.SetAutoPlay(this.isAutoPlayback)
end

--设置结算按钮的显示
function MahjongPlaybackPanel.SetSettlementBtnActive(isActive)
    UIUtil.SetActive(this.settlementBtn, isActive)
end

--暂停
function MahjongPlaybackPanel.Pause()
    if this.isAutoPlayback then
        UIUtil.SetActive(this.pauseBtn, false)
        UIUtil.SetActive(this.resumeBtn, true)
    end
    this.SetAutoPlay(false)
end

--设置是否自动播放
function MahjongPlaybackPanel.SetAutoPlay(isAutoPlay)
    this.isAutoPlayback = isAutoPlay
    this.CheckAutoPlay()
end

--检测是否自动播放
function MahjongPlaybackPanel.CheckAutoPlay()
    if this.isAutoPlayback then
        this.StartAutoPlayTimer()
    else
        this.StopAutoPlayTimer()
    end
end

--检测开始自动Timer
function MahjongPlaybackPanel.StartAutoPlayTimer()
    if this.autoPlayTimer == nil then
        this.autoPlayTime = Time.realtimeSinceStartup
        this.autoPlayTimer = Timing.New(this.OnAutoPlayTimer, 0.2)
    end
    this.autoPlayTimer:Restart()
end

--停止Timer
function MahjongPlaybackPanel.StopAutoPlayTimer()
    if this.autoPlayTimer ~= nil then
        this.autoPlayTimer:Stop()
        this.autoPlayTimer = nil
    end
end

--处理Timer
function MahjongPlaybackPanel.OnAutoPlayTimer()
    if MahjongAnimMgr.isPlayingHuanAnim then
        return
    end

    if Time.realtimeSinceStartup - this.autoPlayTime > 0.79 then
        this.autoPlayTime = Time.realtimeSinceStartup
        --播放失败，即后续没有数据
        if MahjongPlaybackCardMgr.PlayNext() == false then
            this.StopAutoPlayTimer()
        end
    end
end