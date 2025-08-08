SDBPlaybackPanel = ClassPanel("SDBPlaybackPanel")
SDBPlaybackPanel.Instance = nil
--
local this = SDBPlaybackPanel
local mSelf = nil

--UI初始化
function SDBPlaybackPanel:OnInitUI()
    mSelf = self
    local playbackTrans = self:Find("Playback")
    self.replayBtn = playbackTrans:Find("ReplayButton").gameObject
    self.prevBtn = playbackTrans:Find("PrevButton").gameObject
    self.pauseBtn = playbackTrans:Find("PauseButton").gameObject
    self.resumeBtn = playbackTrans:Find("ResumeButton").gameObject
    self.nextBtn = playbackTrans:Find("NextButton").gameObject
    self.quitBtn = playbackTrans:Find("QuitButton").gameObject

    self:AddUIListenerEvent()
end


--当面板开启开启时
function SDBPlaybackPanel:OnOpened()
    self:UpdateDisplay()
end

--当面板关闭时调用
function SDBPlaybackPanel:OnClosed()
   
end
------------------------------------------------------------------
--
--关闭
function SDBPlaybackPanel.Close()
    mSelf:Close()
end

--UI相关事件
function SDBPlaybackPanel:AddUIListenerEvent()
    self:AddOnClick(self.replayBtn, this.OnReplayBtnClick)
    self:AddOnClick(self.prevBtn, this.OnPrevBtnClick)
    self:AddOnClick(self.pauseBtn, this.OnPauseBtnClick)
    self:AddOnClick(self.resumeBtn, this.OnResumeBtnClick)
    self:AddOnClick(self.nextBtn, this.OnNextBtnClick)
    self:AddOnClick(self.quitBtn, this.OnQuitBtnClick)
end

------------------------------------------------------------------
--
--重放
function SDBPlaybackPanel.OnReplayBtnClick()
    SDBPlaybackMgr.Replay()
end

--上一手
function SDBPlaybackPanel.OnPrevBtnClick()
    this.Pause()
    SDBPlaybackMgr.LastPlayback()
end

--暂停
function SDBPlaybackPanel.OnPauseBtnClick()
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 暂停")
    this.Pause()
end

--回放继续
function SDBPlaybackPanel.OnResumeBtnClick()
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 回放继续")
    SDBPlaybackMgr.AutoPlayback()
    mSelf:UpdateDisplay()
end

--下一手
function SDBPlaybackPanel.OnNextBtnClick()
    this.Pause()
    SDBPlaybackMgr.NextPlayback()
end

--退出
function SDBPlaybackPanel.OnQuitBtnClick()
    Alert.Prompt("是否退出回放？", this.OnQuitAlert)
end

--退出提示处理
function SDBPlaybackPanel.OnQuitAlert()
    SDBRoom.ExitRoom()
end

------------------------------------------------------------------
--
function SDBPlaybackPanel:UpdateDisplay()
    UIUtil.SetActive(self.pauseBtn, SDBPlaybackMgr.isAuto)
    UIUtil.SetActive(self.resumeBtn, not SDBPlaybackMgr.isAuto)
end


--暂停
function SDBPlaybackPanel.Pause()
    SDBPlaybackMgr.StopAutoPlayback()
    mSelf:UpdateDisplay()
end