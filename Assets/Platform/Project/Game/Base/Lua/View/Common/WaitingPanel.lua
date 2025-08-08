WaitingPanel = ClassPanel("WaitingPanel")
WaitingPanel.Instance = nil
WaitingPanel.lastData = nil

local this = WaitingPanel

function WaitingPanel:OnInitUI()
    this = self
    this.content = self:Find("Content")
    this.msgTxtTrans = this.content:Find("MsgTxt")
    this.msgTxt = this.msgTxtTrans:GetComponent(TypeText)
end

function WaitingPanel:OnOpened(data)
    WaitingPanel.Instance = self
    this.UpdateData(data)
end


function WaitingPanel:OnClosed()
    WaitingPanel.Instance = nil
    this.lastData = nil
end

------------------------------------------------------------------
--
function WaitingPanel.AddListenerEvent()
end

function WaitingPanel.RemoveListenerEvent()

end

--================================================================
--更新数据
function WaitingPanel.UpdateData(data)
    if data == nil then
        this.Close()
        return
    end

    this.lastData = data
    this.msgTxt.text = this.lastData.message

    -- local msgTxtWidth = this.msgTxt.preferredWidth
    -- if msgTxtWidth < 60 then
    --     msgTxtWidth = 60
    -- elseif msgTxtWidth > 900 then
    --     msgTxtWidth = 900
    -- end
    -- UIUtil.SetWidth(this.msgTxtTrans, msgTxtWidth + 20)
    -- UIUtil.SetWidth(this.background, msgTxtWidth + 230)
end

------------------------------------------------------------------
--
