--单张手牌显示对象
TpHandCardItem = {
    -----------------------------------------------
    gameObject = nil,
    transform = nil,
    rectTransform = nil,
    --
    --牌ID
    cardId = nil,
    --
    maskColorType = nil,
}

local meta = { __index = TpHandCardItem }

local ColorWhite = Color(1, 1, 1)
local ColorGray = Color(0.392, 0.392, 0.392)
local ColorYellow = Color(1, 208/255, 64/255)

function TpHandCardItem.New()
    local o = {}
    setmetatable(o, meta)
    return o
end

function TpHandCardItem:Init(index, transform, parentRectTransform)
    self.index = index --玩家索引
    self.transform = transform
    self.parentRectTransform = parentRectTransform
    self.gameObject = transform.gameObject
    self.rectTransform = self.gameObject:GetComponent("RectTransform")
    self.position = self.rectTransform.anchoredPosition

    self.positionTweener = transform:GetComponent(TypeTweenPosition)
    self.positionTweener.onFinished = function() self:OnPositionTweenFinished() end

    self.rotationTweener = transform:GetComponent(TypeTweenRotation) 

    self.image1 = transform:Find("1"):GetComponent(TypeImage)
    self.image1RectTransform = self.image1:GetComponent("RectTransform")
    self.image1Tweener = self.image1:GetComponent(TypeTweenRotation)

    self.image2 = transform:Find("2"):GetComponent(TypeImage)
    self.image2RectTransform = self.image2:GetComponent("RectTransform")
    self.image2Tweener = self.image2:GetComponent(TypeTweenRotation)

    self.isDealed = false
    self.isDealing = false

    self.resultGo = transform:Find("Result").gameObject
    self.resultLabel = transform:Find("Result/Text"):GetComponent(TypeText)
end

function TpHandCardItem:Clear()
    if self.cardId1 ~= nil or self.cardId2 ~= nil then
        self.cardId1 = nil
        self.cardId2 = nil
        self.resultType = nil
        self:SetDisplay(false)
        self:SetResultDisplay(false)
        self.positionTweener.enabled = false
        self.rotationTweener.enabled = false
        self.image1Tweener.enabled = false
        self.image2Tweener.enabled = false
        self.isDealed = false
        self.isDealing = false
        self:SetMaskColor(TpMaskColorType.None)
    end
end

function TpHandCardItem:Reset()
    self.positionTweener.enabled = false
    self.rotationTweener.enabled = false
    self.image1Tweener.enabled = false
    self.image2Tweener.enabled = false

    self.rectTransform.anchoredPosition = self.position
    self.rectTransform.localEulerAngles = Vector3.zero
    self.image1RectTransform.localEulerAngles = self.image1Tweener.to
    self.image2RectTransform.localEulerAngles = self.image2Tweener.to
end

function TpHandCardItem:Destroy()

end

--================================================================
--
--设置是否为主玩家，用于回放时，播放上一步时，被结算赋值为正常显示
function TpHandCardItem:SetIsMainPlayer(isMainPlayer)
    self.isMainPlayer = isMainPlayer
end

--
--设置牌，播放发牌动画
function TpHandCardItem:DealCard(handCards, px)
    self.resultType = px
    if self.isMainPlayer then
        self.cardId1 = handCards[1]
        self.cardId2 = handCards[2]
    else
        self.cardId1 = -1
        self.cardId2 = -1
    end
    if self.isDealed ~= true then
        if self.isDealing ~= true then
            self:PlayDealCardAnim()
        end
        return
    end
    self:CheckUpdateCardDisplay(self.cardId1, self.cardId2)
    self:UpdateResultDisplay()
    self:SetMaskColor(TpMaskColorType.None)
    self:SetDisplay(true)
end

--设置牌，不播放动画
function TpHandCardItem:SetCard(handCards, px)
    self:Reset()
    self.resultType = px
    if self.isMainPlayer then
        self.cardId1 = handCards[1]
        self.cardId2 = handCards[2]
    else
        self.cardId1 = -1
        self.cardId2 = -1
    end
    self:CheckUpdateCardDisplay(self.cardId1, self.cardId2)
    self:UpdateResultDisplay()
    self:SetMaskColor(TpMaskColorType.None)
    self:SetDisplay(true)
end

--设置弃牌显示，如果有牌才显示
function TpHandCardItem:SetCardDisplayByGiveUp()
    if self.cardId1 ~= nil and self.cardId2 ~= nil then
        self:Reset()
        self:CheckUpdateCardDisplay(self.cardId1, self.cardId2)
        if self.isMainPlayer and self.resultType ~= nil then
            self:UpdateResultDisplay()
            self:SetResultDisplay(true)
        else
            self:SetResultDisplay(false)
        end
        self:SetMaskColor(TpMaskColorType.Gray)
        self:SetDisplay(true)
    else
        self:Clear()
    end
end

--================================================================
--设置显示
function TpHandCardItem:SetDisplay(display)
    if self.lastDisplay ~= display then
        self.lastDisplay = display
        UIUtil.SetActive(self.gameObject, display)
    end
end

--设置显示
function TpHandCardItem:SetResultDisplay(display)
    if self.lastResultDisplay ~= display then
        self.lastResultDisplay = display
        UIUtil.SetActive(self.resultGo, display)
    end
end

--更新牌显示
function TpHandCardItem:CheckUpdateCardDisplay(id1, id2)
    if self.lastId1 ~= id1 then
        self.lastId1 = id1
        self:UpdateCardDisplay(self.image1, id1)
    end
    if self.lastId2 ~= id2 then
        self.lastId2 = id2
        self:UpdateCardDisplay(self.image2, id2)
    end
end

--更新牌显示
function TpHandCardItem:UpdateCardDisplay(image, id)
    local resKey = -1
    if id ~= 0 and id ~= -1 then
        resKey = TpDataMgr.GetCardData(id).resKey
    end
    local sprite = TpResourcesMgr.GetCardSprite(resKey)
    if sprite == nil then
        sprite = TpResourcesMgr.GetCardSprite(-1)
    end
    image.sprite = sprite
end

--更新结果显示
function TpHandCardItem:UpdateResultDisplay()
    if self.isMainPlayer then
        LogError(">> TpHandCardItem:UpdateResultDisplay > ", self.resultType)
        self.resultLabel.text = TpConfig.GetPokerTypeName(self.resultType)
    end
end

--================================================================
--播放发牌动画
function TpHandCardItem:PlayDealCardAnim()
    self:SetMaskColor(TpMaskColorType.None)
    self.isDealing = true
    self:CheckUpdateCardDisplay(-1, -1)
    self:SetDisplay(true)
    self:SetResultDisplay(false)

    self.image1Tweener:ResetToBeginning()
    self.image1Tweener.enabled = false
    self.image2Tweener:ResetToBeginning()
    self.image2Tweener.enabled = false

    self.rotationTweener:ResetToBeginning()
    self.rotationTweener.enabled = false
    local position = UIUtil.ScreenToLocalPosition(self.parentRectTransform, TpAnimMgr.dealCardPosition, UIConst.uiCamera)
    self.positionTweener.from = Vector3(position.x, position.y, 0)
    self.positionTweener.to = Vector3(self.position.x, self.position.y, 0)
    self.positionTweener:ResetToBeginning()
    self.positionTweener:PlayForward()
end

--播放翻牌动画
function TpHandCardItem:PlayFlipCardAnim()
    self.image1Tweener:PlayForward()
    self.image2Tweener:PlayForward()
end

--播放弃牌动画
function TpHandCardItem:PlayGiveUpAnim()
    self:SetResultDisplay(false)

    local position = UIUtil.ScreenToLocalPosition(self.parentRectTransform, TpAnimMgr.dealCardPosition, UIConst.uiCamera)
    self.positionTweener.from = Vector3(self.position.x, self.position.y, 0)
    self.positionTweener.to = Vector3(position.x, position.y, 0)
    self.positionTweener:ResetToBeginning()
    self.positionTweener:PlayForward()

    self.rotationTweener:ResetToBeginning()
    self.rotationTweener:PlayForward()
end

--================================================================
--
--发牌动画完成
function TpHandCardItem:OnPositionTweenFinished()
    local position = self.position
    local target = self.positionTweener.to
    if math.abs(position.x - target.x) < 5 or math.abs(position.y - target.y) < 5 then
        --发牌
        self.isDealed = true
        self.isDealing = false
        self:CheckUpdateCardDisplay(self.cardId1, self.cardId2)
        if self.isMainPlayer and self.resultType ~= nil then
            self:UpdateResultDisplay()
            self:SetResultDisplay(true)
        else
            self:SetResultDisplay(false)
        end
        --
        self:PlayFlipCardAnim()
    else
        --弃牌
        if self.isMainPlayer then
            self:SetCardDisplayByGiveUp()
        else
            self:Clear() 
        end
    end
end

--================================================================
--

--设置遮罩颜色
function TpHandCardItem:SetMaskColor(colorType)
    if self.maskColorType ~= colorType then
        self.maskColorType = colorType
        if self.maskColorType == TpMaskColorType.Gray then
            self.image1.color = ColorGray
            self.image2.color = ColorGray
            self.resultLabel.color = ColorGray
        else
            self.image1.color = ColorWhite
            self.image2.color = ColorWhite
            self.resultLabel.color = ColorYellow
        end
    end
end

--================================================================
--
