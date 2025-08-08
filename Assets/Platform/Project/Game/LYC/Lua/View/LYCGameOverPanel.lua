LYCGameOverPanel = ClassPanel("LYCGameOverPanel")
local this = LYCGameOverPanel

--存入一个对象
local mSelf = nil

local isInitDeck = false
-----------------------------
function LYCGameOverPanel:OnInitUI()
    mSelf = self
    self:InitPanel()
    --监听事件
    self:AddMsg()
end

function LYCGameOverPanel:InitPanel()
    local transform = self.transform
    local btns = transform:Find("Btns")
    self.recordBtn = btns:Find("RecordBtn").gameObject
    self.backLobbyBtn = btns:Find("BackLobbyBtn").gameObject
    self.PlayAgainBtn = btns:Find("PlayAgainBtn").gameObject
    self:AddListenerEvent()
end

-- 快于start
function LYCGameOverPanel:OnOpened()
    UIUtil.SetActive(self.recordBtn, true)
end

--监听事件
function LYCGameOverPanel:AddMsg()
    --查看战绩按钮
    self:AddOnClick(self.recordBtn, this.OnClickCheckRecord)
    --点击返回大厅
    self:AddOnClick(self.backLobbyBtn, this.OnClickBackLobby)
    --再来一局
    self:AddOnClick(self.PlayAgainBtn, this.OnPlayAgainBtnClick)
end

--移除监听
function LYCGameOverPanel:RemoveMsg()

end

--查看战绩
function LYCGameOverPanel.OnClickCheckRecord()
    PanelManager.Open(LYCPanelConfig.JieSuan)
end

--返回大厅
function LYCGameOverPanel.OnClickBackLobby()
    Waiting.Show('正在返回大厅...')
    local function LastFanHui()
        coroutine.wait(0.5)
        Waiting.Hide()
        LYCRoom.ExitRoom()
        mSelf.Close()
    end
    coroutine.start(LastFanHui)
end

function LYCGameOverPanel.OnPlayAgainBtnClick()
    --UnionManager.SendPlayAgain(GameType.LYC, LYCRoomData.Note, LYCRoomData.diFen)
end

function LYCGameOverPanel:AddListenerEvent()
    AddEventListener(CMD.Tcp.Union.S2C_AGAIN, this.OnGetPlayAgainCallBack)
end

function LYCGameOverPanel.OnGetPlayAgainCallBack(data)
    if data.code == 0 then
        LYCRoom.ExitRoom()
        mSelf.Close()
    else
        UnionManager.ShowError(data.code)
    end
end

function LYCGameOverPanel:OnDestroy()
    mSelf:RemoveMsg()
    mSelf = nil
    isInitDeck = nil
end 