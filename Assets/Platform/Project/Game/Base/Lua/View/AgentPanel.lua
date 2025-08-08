AgentPanel = ClassPanel("AgentPanel")
local this = AgentPanel
function AgentPanel:Awake()
    this = self
    local content = this:Find("Content")
    this.closeBtn = content:Find("Bgs/CloseBtn")
    this.SendButton = content:Find("SendButton")
    this:AddOnClick(this.closeBtn, this.OnClickCloseBtn)
    this:AddOnClick(this.SendButton, this.OnClickSendButton)
    this.GameInput = content:Find("GameInput")
    this.PlaceInput = content:Find("PlaceInput")
    this.Phone = content:Find("Phone")
    this.WeChat = content:Find("WeChat")
end

function AgentPanel:OnOpened()
    LogError("<color=aqua>1111111111111</color>")
    AddEventListener(CMD.Tcp.S2C_Agent, this.AgentRecall)
end

function AgentPanel.OnClickSendButton()
    LogError("<color=aqua>2222222222222</color>")
    local game = UIUtil.GetInputText(this.GameInput)
    local area = UIUtil.GetInputText(this.PlaceInput)
    local phone = UIUtil.GetInputText(this.Phone)
    local wechat = UIUtil.GetInputText(this.WeChat)
    if game == "" then
        Toast.Show("请输入游戏名")
        return
    elseif area == "" then
        Toast.Show("请输入代理区域")
        return
    elseif phone == "" then
        Toast.Show("请输入手机号")
        return
    elseif wechat == "" then
        Toast.Show("请输入微信")
        return
    end
    BaseTcpApi.SendAgent(game,area,phone,wechat)
end

function AgentPanel.AgentRecall(data)
    LogError("333333333")
    if data.code == 0 then
        Toast.Show("提交成功")
        this.OnClickCloseBtn()
    elseif data.code == 10106 then
        Toast.Show("提交合作信息失败")
    end
end

function AgentPanel.OnClickCloseBtn()
    PanelManager.Close(PanelConfig.Agent, true)
end

function AgentPanel:OnClosed()
    RemoveEventListener(CMD.Tcp.S2C_Agent, this.AgentRecall)
end
