Pin5GameOverPanel = ClassPanel("Pin5GameOverPanel")
local this = Pin5GameOverPanel
this.againBtnClickTime = 0
--存入一个对象
local mSelf = nil

local isInitDeck = false
-----------------------------
function Pin5GameOverPanel:OnInitUI()
    mSelf = self
    self:InitPanel()
    --监听事件
    self:AddMsg()
end

function Pin5GameOverPanel:InitPanel()
    local transform = self.transform
    local btns = transform:Find("Btns")
    self.recordBtn = btns:Find("RecordBtn").gameObject
    self.backLobbyBtn = btns:Find("BackLobbyBtn").gameObject
    self.PlayAgainBtn = btns:Find("PlayAgainBtn").gameObject
    self:AddListenerEvent()
end

-- 快于start
function Pin5GameOverPanel:OnOpened()
    UIUtil.SetActive(self.recordBtn, true)
end

--监听事件
function Pin5GameOverPanel:AddMsg()
    --查看战绩按钮
    self:AddOnClick(self.recordBtn, this.OnClickCheckRecord)
    --点击返回大厅
    self:AddOnClick(self.backLobbyBtn, this.OnClickBackLobby)
    --再来一局
    self:AddOnClick(self.PlayAgainBtn, this.OnPlayAgainBtnClick)
end

--移除监听
function Pin5GameOverPanel:RemoveMsg()

end

--查看战绩
function Pin5GameOverPanel.OnClickCheckRecord()
    PanelManager.Open(Pin5PanelConfig.JieSuan)
end

--返回大厅
function Pin5GameOverPanel.OnClickBackLobby()
    Waiting.Show('正在返回大厅...')
    local function LastFanHui()
        coroutine.wait(0.5)
        Waiting.Hide()
        Pin5Room.ExitRoom()
        mSelf.Close()
    end
    coroutine.start(LastFanHui)
end

function Pin5GameOverPanel.OnPlayAgainBtnClick()
    if Time.realtimeSinceStartup - this.againBtnClickTime > 2 then
        this.againBtnClickTime = Time.realtimeSinceStartup
        if Pin5RoomData.groupId ~= 0 then
            UnionManager.SendPlayAgain(Pin5RoomData.groupId, GameType.Pin5, Pin5RoomData.Note, Pin5RoomData.diFen)
        else
            Toast.Show("联盟不存在，加入游戏失败")
        end
    else
        Toast.Show("请稍后...")
    end
end

function Pin5GameOverPanel:AddListenerEvent()
    AddEventListener(CMD.Tcp.Union.S2C_AGAIN, this.OnGetPlayAgainCallBack)
end

function Pin5GameOverPanel.OnGetPlayAgainCallBack(data)
    if data.code == 0 then
        Pin5Room.ExitRoom()
        mSelf.Close()
    else
        UnionManager.ShowError(data.code)
    end
end

function Pin5GameOverPanel:OnDestroy()
    mSelf:RemoveMsg()
    mSelf = nil
    isInitDeck = nil
end 