UpgradePanel = ClassPanel("UpgradePanel")

local this = nil

--初始化面板--
function UpgradePanel:OnInitUI()
    this = self

    self.closeBtn = self.transform:Find("Content/CloseButton").gameObject
    self.upgradeBtn = self.transform:Find("Content/UpgradeButton").gameObject

    this.AddUIListenerEvent()
end

function UpgradePanel:OnOpened()

end

function UpgradePanel:OnClosed()

end

------------------------------------------------------------------
--
--关闭
function UpgradePanel.Close()
    PanelManager.Close(PanelConfig.Upgrade)
end

--UI相关事件
function UpgradePanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.upgradeBtn, this.OnUpgradeBtnClick)
end

------------------------------------------------------------------
--
--关闭按钮单击事件--
function UpgradePanel.OnCloseBtnClick()
    this.Close()
end

function UpgradePanel.OnUpgradeBtnClick()
    this.Close()
    Application.OpenURL(AppConfig.LobbyDownloadUrl)
end