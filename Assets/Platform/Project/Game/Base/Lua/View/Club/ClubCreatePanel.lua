ClubCreatePanel = ClassPanel("ClubCreatePanel")
local this = ClubCreatePanel

function ClubCreatePanel:OnInitUI()
    this = self
    local content = this.transform:Find("Content")
    this.closeBtn = content:Find("Background/CloseButton"):GetComponent("Button")
    this.nameInputField = content:Find("NameInputField"):GetComponent("InputField")
    this.idInputField = content:Find("PlayerIDInputField"):GetComponent("InputField")
    this.createBtn = content:Find("CreateBtn"):GetComponent("Button")
    this.AddUIListenerEvent()
end

function ClubCreatePanel:OnOpened()
    this.AddListenerEvent()
end

--关闭面板
function ClubCreatePanel:OnClosed()
    this.RemoveListenerEvent()
    this.ClearInputText()
end

function ClubCreatePanel.AddListenerEvent()
    
end

function ClubCreatePanel.RemoveListenerEvent()
    
end

function ClubCreatePanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.createBtn, this.OnCreateBtnClick)
end

--返回
function ClubCreatePanel.OnCloseBtnClick()
    this:Close()
end

--创建俱乐部
function ClubCreatePanel.OnCreateBtnClick()
    local clubName = this.nameInputField.text
    local playerId = tonumber(this.idInputField.text)
    ClubManager.SendCreateClub(clubName, playerId)
end

--清除输入的
function ClubCreatePanel.ClearInputText()
    this.nameInputField.text = ""
    this.idInputField.text = ""
end