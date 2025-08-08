--单张牌显示对象
TpCardItem = {
    enabled = nil,
    -----------------------------------------------
    gameObject = nil,
    transform = nil,
    rectTransform = nil,
    --
    --牌ID
    cardId = nil,
    --
    maskColorType = nil,
    --是否已经发牌
    isDealed = false,
    --是否发牌中
    isDealing = false,
    --是否已经翻牌
    isFliped = false,
    --是否翻牌中
    isFliping = false,
}

local meta = { __index = TpCardItem }

function TpCardItem.New()
    local o = {}
    setmetatable(o, meta)
    return o
end

function TpCardItem:Init(index, transform)
    self.index = index
    self.transform = transform
    self.gameObject = transform.gameObject
    self.rectTransform = self.gameObject:GetComponent(TypeRectTransform)
    self.position = self.rectTransform.anchoredPosition

    self.image = transform:Find("Image"):GetComponent(TypeImage)
    self.imageRectTransform = self.image:GetComponent(TypeRectTransform)

    self.positionTweener = self.gameObject:GetComponent(TypeTweenPosition)
    if self.positionTweener ~= nil then
        self.positionTweener.onFinished = function() self:OnPositionTweenFinished() end
    end
    self.scaleTweener = self.gameObject:GetComponent(TypeTweenScale)

    self.rotationTweener = self.image:GetComponent(TypeTweenRotation)
    if self.rotationTweener ~= nil then
        self.rotationTweener.onFinished = function() self:OnRotationTweenFinished() end
    end
end

function TpCardItem:Clear()
    if self.cardId ~= nil then
        self.cardId = nil
        self:SetDisplay(false)
        self.positionTweener.enabled = false
        self.scaleTweener.enabled = false
        self.rotationTweener.enabled = false
        self.isDealed = false
        self.isDealing = false
        self.isFliped = false
        self.isFliping = false
    end
end

--重置牌，给直接显示牌使用
function TpCardItem:Reset()
    self.positionTweener.enabled = false
    self.scaleTweener.enabled = false
    self.rotationTweener.enabled = false

    self.imageRectTransform.localEulerAngles = Vector3.zero
    self.rectTransform.anchoredPosition = self.position
    self.rectTransform.localScale = Vector3.one
end

function TpCardItem:Destroy()

end

--================================================================
--
--设置牌的ID，并发牌
function TpCardItem:DealCard(cardId)
    if self.cardId ~= cardId then
        self.cardId = cardId
        --
        if self.isDealed ~= true or self.isFliped ~= true then
            if self.isDealing ~= true then
                self:PlayDealCardAnim()
            end
            return
        end
        self:CheckUpdateCardDisplay(self.cardId)
        self:SetDisplay(true)
    end
end

--设置牌的ID，直接显示
function TpCardItem:SetCard(cardId)
    if self.cardId ~= cardId then
        self.cardId = cardId
        self:Reset()
        --
        self:CheckUpdateCardDisplay(self.cardId)
        self:SetDisplay(true)
    end
end

--================================================================
--设置显示
function TpCardItem:SetDisplay(display)
    if self.enabled ~= display then
        self.enabled = display
        UIUtil.SetActive(self.gameObject, self.enabled)
    end
end

--更新牌显示
function TpCardItem:CheckUpdateCardDisplay(id)
    if self.lastId ~= id then
        self.lastId = id
        local resKey = -1
        if id ~= 0 and id ~= -1 then
            resKey = TpDataMgr.GetCardData(id).resKey
        end
        local sprite = TpResourcesMgr.GetCardSprite(resKey)
        if sprite == nil then
            sprite = TpResourcesMgr.GetCardSprite(-1)
        end
        self.image.sprite = sprite
    end
end

--================================================================
--播放发牌动画
function TpCardItem:PlayDealCardAnim()
    self.isDealing = true
    self:CheckUpdateCardDisplay(-1)
    self:SetDisplay(true)

    self.rotationTweener.enabled = false
    self.imageRectTransform.localEulerAngles = Vector3.zero

    self.positionTweener:ResetToBeginning()
    self.positionTweener:PlayForward()

    self.scaleTweener:ResetToBeginning()
    self.scaleTweener:PlayForward()
end

--播放翻牌动画
function TpCardItem:PlayFlipCardAnim()
    self.isFliping = true

    self.rotationTweener.from = Vector3(0, 0, 0)
    self.rotationTweener.to = Vector3(0, -90, 0)
    self.rotationTweener:ResetToBeginning()
    self.rotationTweener:PlayForward()
end

--================================================================
--
--发牌动画完成
function TpCardItem:OnPositionTweenFinished()
    self.isDealed = true
    self.isDealing = false
    self.rectTransform.anchoredPosition = self.position
    self.rectTransform.localScale = Vector3.one
    --
    self:PlayFlipCardAnim()
end

--翻牌动画完成
function TpCardItem:OnRotationTweenFinished()
    if self.rotationTweener.from.y >= 0 then
        --第一步是背面翻转完成后显示牌，并进行第二步
        self:CheckUpdateCardDisplay(self.cardId)
        self.rotationTweener.from = Vector3(0, -90, 0)
        self.rotationTweener.to = Vector3(0, 0, 0)
        self.rotationTweener:ResetToBeginning()
        self.rotationTweener:PlayForward()
    else
        --第二步才是正在的完成动画
        self.imageRectTransform.localEulerAngles = Vector3(0, 0, 0)
        self.isFliped = true
        self.isFliping = false
        self:CheckUpdateCardDisplay(self.cardId)
    end
end

--================================================================
--

--设置遮罩颜色
function TpCardItem:SetMaskColor(colorType)
    if self.maskColorType ~= colorType then
        self.maskColorType = colorType
        if self.maskColorType == TpMaskColorType.None then
            UIUtil.SetImageColor(self.image, 1, 1, 1)
        elseif self.maskColorType == TpMaskColorType.Gray then
            UIUtil.SetImageColor(self.image, 0.392, 0.392, 0.392)
        else
            UIUtil.SetImageColor(self.image, 1, 1, 1)
        end
    end
end

--================================================================
--
