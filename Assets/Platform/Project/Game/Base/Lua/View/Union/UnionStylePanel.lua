UnionStylePanel = ClassPanel("UnionStylePanel")
UnionStylePanel.closeBtn = nil

local this = UnionStylePanel
function UnionStylePanel:Awake()
    this = self
    local node = this:Find("Node")

    this.closeBtn = node:Find("Background/CloseBtn")
    local content = node:Find("Content")
    this.okBtn = content:Find("OkBtn")
    this.cancelBtn = content:Find("CancelBtn")
    local layout = content:Find("Layout")
    this.toggles = {}
    for i = 1, 3 do
        local item = {}
        item.index = i
        item.transform = layout:Find(tostring(i))
        item.toggle = item.transform:GetComponent(TypeToggle)
        this:AddOnToggle(item.transform, function(isOn) this.OnToggleValueChanged(item, isOn) end)
        table.insert(this.toggles, item)
    end

    this.AddUIListenerEvent()
end


function UnionStylePanel:OnOpened()
    local styleIndex = UnionData.GetBgStyle()
    local item = this.toggles[styleIndex]
    item.toggle.isOn = false
    item.toggle.isOn = true
end

function UnionStylePanel:OnClosed()

end


------------------------------------------------------------------
--
function UnionStylePanel.AddListenerEvent()

end

--
function UnionStylePanel.RemoveListenerEvent()

end

--UI相关事件
function UnionStylePanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.cancelBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.okBtn, this.OnOkBtnClick)
end

------------------------------------------------------------------
--
function UnionStylePanel.Close()
    PanelManager.Close(PanelConfig.UnionStyle, true)
end
------------------------------------------------------------------
--
function UnionStylePanel.OnCloseBtnClick()
    this.Close()
end

--
function UnionStylePanel.OnToggleValueChanged(item, isOn)

end

--
function UnionStylePanel.OnOkBtnClick()
    local index = 1
    local item = nil
    for i = 1, #this.toggles do
        item = this.toggles[i]
        if item.toggle.isOn then
            index = i
            break
        end
    end
    if index ~= UnionData.GetBgStyle() then
        UnionData.SetBgStyle(index)
        SendEvent(CMD.Game.UnionUpdateBackground)
    end
    this.Close()
end
