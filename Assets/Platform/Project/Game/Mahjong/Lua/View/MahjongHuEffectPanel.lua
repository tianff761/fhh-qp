MahjongHuEffectPanel = ClassPanel("MahjongHuEffectPanel")
MahjongHuEffectPanel.Instance = nil
--
local this = MahjongHuEffectPanel
--
--初始属性数据
function MahjongHuEffectPanel:InitProperty()

end

--UI初始化
function MahjongHuEffectPanel:OnInitUI()
    this = self
    this:InitProperty()

    this.maskBtn = self:Find("Mask")
    this.effectNode = self:Find("EffectNode")
    this.AddUIListenerEvent()
end

--当面板开启开启时
function MahjongHuEffectPanel:OnOpened()
    MahjongHuEffectPanel.Instance = self
end

--当面板关闭时调用
function MahjongHuEffectPanel:OnClosed()
    MahjongHuEffectPanel.Instance = nil
end

------------------------------------------------------------------
--
function MahjongHuEffectPanel.AddListenerEvent()

end

--
function MahjongHuEffectPanel.RemoveListenerEvent()

end

--UI相关事件
function MahjongHuEffectPanel.AddUIListenerEvent()
    this:AddOnClick(this.maskBtn, this.OnCloseBtnClick)
end

------------------------------------------------------------------
--
function MahjongHuEffectPanel.GetEffectNode()
    return this.effectNode
end

function MahjongHuEffectPanel.SetEffectItem(item)
    this.effectItem = item
end

function MahjongHuEffectPanel.OnCloseBtnClick()
    if this.effectItem ~= nil and this.effectItem.spineAnim ~= nil then
        this.effectItem.spineAnim.AnimationState:ClearTracks();
        UIUtil.SetActive(this.effectItem.gameObject, false)
    end
    this.effectItem = nil
    PanelManager.Close(MahjongPanelConfig.HuEffect)
end
