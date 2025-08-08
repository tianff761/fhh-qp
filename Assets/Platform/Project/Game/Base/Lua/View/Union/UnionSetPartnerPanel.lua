UnionSetPartnerPanel = ClassPanel("UnionSetPartnerPanel")
UnionSetPartnerPanel.Instance = nil

local this = UnionSetPartnerPanel

function UnionSetPartnerPanel:OnInitUI()
    this = self
    local content = self:Find("Content")
    this.msgTxt = content:Find("MsgTxt")
    this.okBtn = content:Find("OkButton").gameObject
    this.cancelBtn = content:Find("CancelButton").gameObject
    this.InputField = content:Find("InputField")
    this.CloseBtn = content:Find("Background/CloseBtn").gameObject
    this.AddListenerEvent()
end

function UnionSetPartnerPanel:OnOpened(name, callBack)
    UnionSetPartnerPanel.Instance = self
    this = self
    this.id = id
    this.CallBack = callBack

    UIUtil.SetText(this.msgTxt, "是否把【" .. name .. "】设置为的队长？")
end

function UnionSetPartnerPanel:OnClosed()
    UnionSetPartnerPanel.Instance = nil
end

------------------------------------------------------------------
--
function UnionSetPartnerPanel.AddListenerEvent()
    this:AddOnClick(this.okBtn, this.OnOkBtnClick)
    this:AddOnClick(this.cancelBtn, this.OnCancelBtnClick)
    this:AddOnClick(this.CloseBtn, this.OnCancelBtnClick)
end

function UnionSetPartnerPanel.RemoveListenerEvent()

end
------------------------------------------------------------------
--
--关闭
function UnionSetPartnerPanel.ClosePanel()
    this:Close()
end

------------------------------------------------------------------
function UnionSetPartnerPanel.OnOkBtnClick()
    local text = UIUtil.GetInputText(this.InputField)
    if type(tonumber(text)) ~= "number" and text ~= "" then
        Toast.Show("请输入正确的数字")
        return
    end
    if this.CallBack then
        this.CallBack(tonumber(text))
    end
    this.ClosePanel()
end

function UnionSetPartnerPanel.OnCancelBtnClick()
    this.ClosePanel()
end