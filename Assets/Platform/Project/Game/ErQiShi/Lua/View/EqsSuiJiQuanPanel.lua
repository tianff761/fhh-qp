EqsSuiJiQuanPanel = ClassPanel("EqsSuiJiQuanPanel")
local this = EqsSuiJiQuanPanel
local v3yOrigin = Vector3(0, -90, 0)
local v3y90 = Vector3(0, 90, 0)
local v3y180 = Vector3(0, 180, 0)
local v3y270 = Vector3(0, 270, 0)
local v3y360 = Vector3(0, 359, 0)
local time = 0.05
EqsSuiJiQuanPanel.back = nil
EqsSuiJiQuanPanel.cards = nil
EqsSuiJiQuanPanel.quanCard = nil
EqsSuiJiQuanPanel.curAnimIdx = 0
EqsSuiJiQuanPanel.targetQuanCardTran = nil
function EqsSuiJiQuanPanel:Awake()
    this = self
    this.back = self:Find("Content/Back"):GetComponent("Image")
    this.back.rectTransform.localRotation = Quaternion.Euler(v3y90.x, v3y90.y, v3y90.z)
    this.quanCard = self:Find("Content/TargetCard"):GetComponent("Image")
    this.cards = {}
    for i = 1, 10 do
        this.cards[i] = self:Find("Content/Card"..tostring(i)):GetComponent("Image")
    end
    this.curAnimIdx = 1
end

local closeSchedule = nil
function EqsSuiJiQuanPanel:OnOpened()
    local quanNum = BattleModule.curCircle 
    local targetQuanCardTran = EqsBattlePanel.GetSuiJiQuanCard()

    if IsNumber(quanNum) and quanNum >= 1 and quanNum <= 10 then
        this.quanCard.transform.localPosition = Vector3.zero
        this.quanCard.sprite = this.cards[quanNum].sprite
    end
    this:AnimIdx(1)
    this.targetQuanCardTran = targetQuanCardTran
    UIUtil.SetActive(this.targetQuanCardTran, false)
    
    EqsBattlePanel.SetQuanCard(quanNum)
    Scheduler.unscheduleGlobal(closeSchedule)
    closeSchedule = Scheduler.scheduleOnceGlobal(function()
        PanelManager.Close(EqsPanels.EqsSuiJiQuan, true)        
    end,3)
end

function EqsSuiJiQuanPanel:HideAllCards()
    UIUtil.SetActive(this.back.transform, false)
    UIUtil.SetActive(this.quanCard.transform, false)
    for i = 1, 10 do
        UIUtil.SetActive(this.cards[i].transform, false)
    end
end

function EqsSuiJiQuanPanel:AnimIdx(idx)
    this:HideAllCards()
    if idx <= 10 and idx >=1 then
        local card = this.cards[idx]
        UIUtil.SetActive(card.transform, true)
        card.rectTransform.localRotation = Quaternion.Euler(v3yOrigin.x, v3yOrigin.y, v3yOrigin.z)
        card.rectTransform:DORotate(v3y90, time):OnComplete(
            function ()
                UIUtil.SetActive(card.transform, false)
                UIUtil.SetActive(this.back.transform, true)
                this.back.rectTransform.localRotation = Quaternion.Euler(v3y90.x, v3y90.y, v3y90.z)
                this.back.rectTransform:DORotate(v3y270, time):OnComplete(
                    function ()
                        this:AnimIdx(idx + 1)   
                    end
                )
            end
        )
    elseif idx == 11 then
        local time = 0.3
        UIUtil.SetActive(this.quanCard.transform, true)
        Scheduler.scheduleOnceGlobal(function()
            this.quanCard.transform:DOMove(this.targetQuanCardTran.position, time):OnComplete(function ()
                UIUtil.SetActive(this.targetQuanCardTran, true)
                UIUtil.SetActive(this.quanCard.transform, false)
                PanelManager.Close(EqsPanels.EqsSuiJiQuan, true)
                SelfHandEqsCardsCtrl.SetQuanTag()
            end)
            this.quanCard:DOFade(0.5, time)
            this.quanCard.rectTransform:DOScale(Vector3(0.3, 0.15, 0.3), time)
        end,0.4)
    end
end