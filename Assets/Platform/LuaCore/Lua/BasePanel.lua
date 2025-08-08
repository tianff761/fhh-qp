--所有Panel的基类
BasePanel = Class("BasePanel", BaseLuaComponent)
--PanelManager中PanelType对象
BasePanel.panelConfig = nil
--面板是否打开
BasePanel.isOpened = false
--当前组件是否可用
BasePanel.isValid = false

--请勿重新该方法
function BasePanel:Awake()
    self:OnInitUI()
end

--打开面板时自动调用(包含新建和显示)
function BasePanel:OnOpened(...)
end

--关闭面板时自动调用(包含销毁和隐藏)
function BasePanel:OnClosed()
end

--面板是否打开
function BasePanel:IsOpend()
    return self.isOpened
end

--关闭面板(隐藏)
function BasePanel:Close()
    PanelManager.Close(self.panelConfig)
end

--关闭面板(销毁)
function BasePanel:Destroy()
    PanelManager.Destroy(self.panelConfig)
end

--================================================================

--初始化UI
function BasePanel:OnInitUI()
    
end