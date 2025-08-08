LobbyNoticePanel = ClassPanel("LobbyNoticePanel")
local this = LobbyNoticePanel

function LobbyNoticePanel:OnInitUI()
    this = self

    local content = this.transform:Find("Content")
    this.closeBtn = content:Find("Background/CloseBtn").gameObject

    local menuContent = content:Find("Menu/ScrollView/Viewport/Content")
    this.menuItems = {}
    for i = 1, 4 do
        local item = {}
        item.transform = menuContent:Find(tostring(i))
        item.toggle = item.transform:GetComponent(TypeToggle)
        table.insert(this.menuItems, item)
    end

    this.nodes = {}
    for i = 1, 4 do
        local item = {}
        item.transform = content:Find("Node/" .. i)
        item.gameObject = item.transform.gameObject
        table.insert(this.nodes, item)
    end

    this.AddUIListenerEvent()
end

function LobbyNoticePanel:OnOpened()
    this.AddListenerEvent()
    this.menuItems[1].toggle.isOn = true
end

function LobbyNoticePanel:OnClosed()
    this.RemoveListenerEvent()
end

------------------------------------------------------------------
--
function LobbyNoticePanel.AddListenerEvent()

end

--
function LobbyNoticePanel.RemoveListenerEvent()

end

--
function LobbyNoticePanel.AddUIListenerEvent()
    EventUtil.AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    for i = 1, #this.menuItems do
        EventUtil.AddOnToggle(this.menuItems[i].transform, function(isOn) this.OnMenuClick(i, isOn) end)
    end
end

function LobbyNoticePanel.Close()
    PanelManager.Destroy(PanelConfig.LobbyNotice, true)
end

------------------------------------------------------------------
--
function LobbyNoticePanel.OnCloseBtnClick()
    this.Close()
end

--
function LobbyNoticePanel.OnMenuClick(index, isOn)
    -- if isOn then
    --     if this.lastNode ~= nil then
    --         UIUtil.SetActive(this.lastNode.gameObject, false)
    --         this.lastNode = nil
    --     end
    --     this.lastNode = this.nodes[index]
    --     if this.lastNode ~= nil then
    --         UIUtil.SetActive(this.lastNode.gameObject, true)
    --     end
    -- end
end
