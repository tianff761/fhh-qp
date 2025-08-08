UnionPartnerPercentChangePanel = ClassPanel("UnionPartnerPercentChangePanel")
UnionPartnerPercentChangePanel.closeBtn = nil
UnionPartnerPercentChangePanel.percentChangeBtn = nil
UnionPartnerPercentChangePanel.scrollRect = nil
UnionPartnerPercentChangePanel.itemGo = nil
UnionPartnerPercentChangePanel.curPercent = 0
--调整的玩家Id
UnionPartnerPercentChangePanel.adjustUid = 0 
local this = UnionPartnerPercentChangePanel
function UnionPartnerPercentChangePanel:Awake()
    this = self
    this.closeBtn = this:Find("Bgs/CloseBtn")
    this.scrollRect = this:Find("PercentScrollView"):GetComponent(TypeScrollRect)
    this.itemGo = this:Find("PercentScrollView/ViewRect/Viewport/Item").gameObject
    this.percentChangeBtn = this:Find("PercentChangeBtn")
    this.inputField = this:Find("InputField"):GetComponent("InputField")
    this:AddOnClick(this.closeBtn, this.OnClickCloseBtn)
    this:AddOnClick(this.percentChangeBtn, this.OnClickOkBtn)
end

function UnionPartnerPercentChangePanel:OnOpened(uid)
    this.adjustUid = uid
    local cnt = this.scrollRect.content
    ClearChildren(cnt)
    local newGo = nil
    for i = 0, 100 do
        newGo = NewObject(this.itemGo, cnt)
        UIUtil.SetText(newGo, tostring(i))
    end
    
    local y = 0
    this.scrollRect.onValueChanged:AddListener(function (v2)
        y = v2.y
    end)
    
    local height = 100 * 50
    local yuShu = 0
    UIEventTriggerListener.Get(this.scrollRect.gameObject).onUp = function ()
        this.scrollRect:StopMovement();
        if y <= 0 then
            y = height
        elseif y >= 1 then
            y = 0
        else
            y = (1 - y) * height
            yuShu = y % 50
            if yuShu < 25 then
                y = y - yuShu
            else
                y = y + (50 - yuShu)
            end
            this.curPercent = y / 50
            Log("Y",y, " YuShu", y / 50)
            UIUtil.SetAnchoredPosition(cnt, 0, y)
        end
        cnt:GetComponent(TypeRectTransform):DOAnchorPosY(y, 0.1):SetEase(DG.Tweening.Ease.Linear)
    end
end

function UnionPartnerPercentChangePanel.OnClickCloseBtn()
    PanelManager.Close(PanelConfig.UnionPartnerPercentChange)
    this.scrollRect.onValueChanged = nil
end

function UnionPartnerPercentChangePanel.OnClickOkBtn()
    local value = tonumber(this.inputField.text)
    if IsNumber(value) and value >= 0 and value <= 100 then
        UnionManager.SendAdjustPartnerPercent(this.adjustUid, value)
    else
        Toast.Show("请输入0-100的比例值")
    end
end
