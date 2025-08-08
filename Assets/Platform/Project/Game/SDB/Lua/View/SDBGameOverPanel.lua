
SDBGameOverPanel = ClassPanel("SDBGameOverPanel")
local this = SDBGameOverPanel

--存入一个对象
local mSelf = nil

local isInitDeck = false
-----------------------------
function SDBGameOverPanel:OnInitUI()
	mSelf = self
	self:InitPanel()
	--监听事件
	self:AddMsg()
    self:AddListenerEvent()
end

function SDBGameOverPanel:InitPanel()
    local BtnParentTransform =self.transform:Find("btns")

    self.recordBtn = BtnParentTransform:Find("RecordBtn").gameObject
    self.backLobbyBtn = BtnParentTransform:Find("BackLobbyBtn").gameObject
    self.PlayAgainBtn = BtnParentTransform:Find("PlayAgainBtn").gameObject
end

-- 快于start
function SDBGameOverPanel:OnOpened()
    
end

--监听事件
function SDBGameOverPanel:AddMsg()
	 --查看战绩按钮
     self:AddOnClick(self.recordBtn, this.OnClickCheckRecord)
     --点击返回大厅
     self:AddOnClick(self.backLobbyBtn, this.OnClickBackLobby)
end

--移除监听
function SDBGameOverPanel:RemoveMsg()

end

--查看战绩
function SDBGameOverPanel.OnClickCheckRecord()
    PanelManager.Open(SDBPanelConfig.JieSuan)
end

--返回大厅
function SDBGameOverPanel.OnClickBackLobby()
    Waiting.Show('正在返回大厅...')
    local function LastFanHui()
        coroutine.wait(0.5)
        Waiting.Hide()
        SDBRoom.ExitRoom()
    end
    coroutine.start(LastFanHui)
end

function SDBGameOverPanel.OnPlayAgainBtnClick()
    --UnionManager.SendPlayAgain(GameType.Pin5, Pin5RoomData.Note, Pin5RoomData.diFen)
end

function SDBGameOverPanel:AddListenerEvent()
    AddEventListener(CMD.Tcp.Union.S2C_AGAIN, this.OnGetPlayAgainCallBack)
end

function SDBGameOverPanel.OnGetPlayAgainCallBack(data)
    if data.code == 0 then
        SDBRoom.ExitRoom()
        mSelf.Close()
    else
        UnionManager.ShowError(data.code)
    end
end

function SDBGameOverPanel:OnDestroy()
	mSelf:RemoveMsg()
	mSelf = nil
	isInitDeck = nil
end 