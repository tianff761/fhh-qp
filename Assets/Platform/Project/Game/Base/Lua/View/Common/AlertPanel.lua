AlertPanel = ClassPanel("AlertPanel")
AlertPanel.Instance = nil
AlertPanel.lastData = nil

local this = nil

function AlertPanel:OnInitUI()
    this = self
    local content = self:Find("Content")
    this.msgTxt = content:Find("MsgTxt"):GetComponent(TypeText)
    this.okCenterBtn = content:Find("OkCenterButton").gameObject
    this.okBtn = content:Find("OkButton").gameObject
    this.cancelBtn = content:Find("CancelButton").gameObject
    this.TitleText = content:Find("Background/Title/TitleText")
    this.AddListenerEvent()
end

function AlertPanel:OnOpened(data)
    AlertPanel.Instance = self
    this = self
    this.UpdateData(data)
end

function AlertPanel:OnClosed()
    AlertPanel.Instance = nil
    this.lastData = nil
end

------------------------------------------------------------------
--
function AlertPanel.AddListenerEvent()
    this:AddOnClick(this.okCenterBtn, this.OnOkBtnClick)
    this:AddOnClick(this.okBtn, this.OnOkBtnClick)
    this:AddOnClick(this.cancelBtn, this.OnCancelBtnClick)
end

function AlertPanel.RemoveListenerEvent()

end
------------------------------------------------------------------
--
--关闭
function AlertPanel.ClosePanel()
    if Alert.openPanelConfig == this.panelConfig then
        Alert.openPanelConfig = nil
    end
    Alert.isOpen = false
    this:Close()
end

--================================================================
--更新数据
function AlertPanel.UpdateData(data)
    if data == nil then
        this.ClosePanel()
        return
    end
    if data.level == nil then
        data.level = AlertLevel.Normal
    end

    if this.lastData ~= nil and this.lastData.level > data.level then
        return
    end

    this.lastData = data

    this.msgTxt.text = this.lastData.message
    --LogError("data.title", data.title)
    --UIUtil.SetText(this.TitleText, data.title)

    if this.lastData.type == AlertType.Prompt then
        this.ShowPromptDisplay()
    else
        this.ShowAlertDisplay()
    end
end

------------------------------------------------------------------
--
function AlertPanel.ShowAlertDisplay()
    UIUtil.SetActive(this.okCenterBtn, true)
    UIUtil.SetActive(this.okBtn, false)
    UIUtil.SetActive(this.cancelBtn, false)
end

function AlertPanel.ShowPromptDisplay()
    UIUtil.SetActive(this.okCenterBtn, false)
    UIUtil.SetActive(this.okBtn, true)
    UIUtil.SetActive(this.cancelBtn, true)
end

function AlertPanel.OnOkBtnClick()
    local temp = this.lastData
    this.ClosePanel()
    if temp ~= nil and temp.okCallback ~= nil then
        temp.okCallback()
    end
end

function AlertPanel.OnCancelBtnClick()
    local temp = this.lastData
    this.ClosePanel()
    if temp ~= nil and temp.cancelCallback ~= nil then
        temp.cancelCallback()
    end
end