MaskPanel = ClassPanel("MaskPanel")
MaskPanel.Instance = nil

local this = nil

function MaskPanel:OnInitUI()
    this = self
end

function MaskPanel:OnOpened(data)
    MaskPanel.Instance = self
end


function MaskPanel:OnClosed()
    MaskPanel.Instance = nil
end

------------------------------------------------------------------
--
function MaskPanel.AddListenerEvent()
end

function MaskPanel.RemoveListenerEvent()

end

--================================================================
