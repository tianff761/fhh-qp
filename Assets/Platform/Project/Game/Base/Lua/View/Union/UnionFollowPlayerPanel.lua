--调整分数
UnionFollowPlayerPanel = ClassPanel("UnionFollowPlayerPanel")
--调整的玩家Id
UnionFollowPlayerPanel.adjustUid = 0
UnionFollowPlayerPanel.clickTime = 0

local this = UnionFollowPlayerPanel
--
function UnionFollowPlayerPanel:Awake()
    this = self
    local content = this:Find("Content")
    this.closeBtn = content:Find("Background/CloseBtn")
    this.okBtn = content:Find("OkBtn")
    this.input = content:Find("InputField"):GetComponent(TypeInputField)
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.okBtn, this.OnOkBtnClick)
end

function UnionFollowPlayerPanel:OnOpened(uid)
    this.AddEventListener()
    this.adjustUid = uid
    this.input.text = ""
end

function UnionFollowPlayerPanel:OnClosed()
    this.RemoveEventListener()
end

--注册事件
function UnionFollowPlayerPanel.AddEventListener()
    --AddEventListener(CMD.Tcp.Union.S2C_Union_SetScore, this.OnTcpSetScore)
end

--移除事件
function UnionFollowPlayerPanel.RemoveEventListener()
    --RemoveEventListener(CMD.Tcp.Union.S2C_Union_SetScore, this.OnTcpSetScore)
end

--================================================================
--
--关闭
function UnionFollowPlayerPanel.Close()
    PanelManager.Close(PanelConfig.UnionFollowPlayer)
end
--================================================================
--
function UnionFollowPlayerPanel.OnCloseBtnClick()
    this.Close()
end

function UnionFollowPlayerPanel.OnOkBtnClick()
    local value = tonumber(this.input.text)
    if IsNumber(value) then
        if this.clickTime < Time.realtimeSinceStartup then
            this.clickTime = Time.realtimeSinceStartup + 2
            SendEvent(CMD.Game.UnionFollowPlayer, value)
        else
            Toast.Show("请稍后...")
        end
    else
        Toast.Show("请输入正确的玩家ID")
    end
end
