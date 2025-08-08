LobbySharePanel = ClassPanel("LobbySharePanel")
local this = LobbySharePanel

this.code = nil

function LobbySharePanel:OnInitUI()
    this = self

    local content = this.transform:Find("Content")
    this.closeBtn = content:Find("Background/CloseBtn").gameObject

    this.AddUIListenerEvent()
end

function LobbySharePanel:OnOpened(code)
    this = self
    this.code = code
    this.InitPanel()
    this.AddListenerEvent()
end

function LobbySharePanel.InitPanel()
end

function LobbySharePanel:OnClosed()
    this.code = nil
end

------------------------------------------------------------------
--
function LobbySharePanel.AddListenerEvent()

end

--
function LobbySharePanel.RemoveListenerEvent()

end

--
function LobbySharePanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
end

function LobbySharePanel.Close()
    PanelManager.Destroy(PanelConfig.LobbyShare, true)
end

------------------------------------------------------------------
--
function LobbySharePanel.OnCloseBtnClick()
    this.Close()
end
