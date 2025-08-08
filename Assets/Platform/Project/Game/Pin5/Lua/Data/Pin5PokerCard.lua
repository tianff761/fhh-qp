--扑克牌
Pin5PokerCard = {
    --扑克牌颜色，默认橙色
    color = nil,
    --当前扑克牌的gameObject
    gameObject = nil,
    --当前扑克牌的transform
    transform = nil,
    --当前扑克牌的Image
    image = nil,
    --默认点数
    point = nil,
    --是否正在翻牌
    isFloping = nil,
    --是否翻过牌了
    isFloped = false,
}

--翻牌时间
local flopTime = 0.3
Pin5PokerCard.meta = { __index = Pin5PokerCard }

function Pin5PokerCard:New()
    local o = {}
    setmetatable(o, self.meta)
    return o
end

--初始化扑克牌
function Pin5PokerCard:Init(gameObject)
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.rectTransform = gameObject:GetComponent(TypeRectTransform)
    self.image = gameObject:GetComponent(TypeImage)
    self.tweener = self.gameObject:GetComponent(TypeTweenPosition)
    self.tagGo = self.transform:Find("Tag").gameObject
    self.parentRectTransform = self.transform.parent:GetComponent(TypeRectTransform)
    self:GetPokerColor()
    self:ChangePokerColor()
    self:HideCard()
    Event.AddListener(Pin5Action.PokerStyleType, HandlerArgs(Pin5PokerCard.ChangePokerColor, self))
end

--改变牌颜色
function Pin5PokerCard.ChangePokerColor(poker)
    if poker.gameObject ~= nil then
        poker:ChangePokerColor(Pin5RoomData.cardColor)
    else
        Event.RemoveListener(Pin5Action.PokerStyleType)
    end
end

function Pin5PokerCard:Reset()
    self.point = nil
    self.isFloped = false
    self:RestoreUpPositionY()
    self:SetActiveFiveCardTip(false)
    self:StopTween()
end


--改变扑克牌背面颜色  --传入颜色枚举  PokerCardColor
function Pin5PokerCard:GetPokerColor()
    self.color = Pin5RoomData.cardColor
    return self.color
end

--改变扑克牌背面的颜色
function Pin5PokerCard:ChangePokerColor(color)
    self.color = color
    if self.point == "-1" and self.gameObject.activeSelf == true then
        self:SetPoints("-1")
    end
end

--设置点数 --传入扑克牌点数  --不传，即设置为背面 --isActive(是否显示牌,可以设置点数，不展示牌)
function Pin5PokerCard:SetPoints(cardPoint, isActive)
    if self.isFloping then
        self.transform:DOKill()
        UIUtil.SetRotation(self.gameObject, 0, 0, 0)
        self.isFloping = false
    end

    --Log(">>>>>>>>>>>      设置点数》》》》 ", cardPoint)
    local point = tonumber(cardPoint)
    --没有传入点数，表示没有点数，显示背面
    if IsNil(point) or point == -1 then
        if self.color == nil then
            self:GetPokerColor()
        end
        self.point = "-1"
        local sprite = Pin5ResourcesMgr.GetCardBack()
        if not IsNil(sprite) then
            self.image.sprite = sprite
        end
    else
        self.point = cardPoint
        local sprite = Pin5ResourcesMgr.GetHandleCardSprite(cardPoint)
        if sprite ~= nil then
            self.image.sprite = sprite
        end
    end

    if IsNil(isActive) then
        isActive = true
    end

    if isActive then
        self:ShowCard()
    else
        self:HideCard()
    end
end

--翻牌动画 由背面翻到正面  --传入点数
function Pin5PokerCard:PlayFlopAnim(cardPoint, callback)
    if self.isFloping or self.isFloped then
        return
    end

    self.isFloping = true
    if cardPoint ~= "-1" then
        self.isFloped = true
    end

    self.transform:DOLocalRotate(Vector3.New(0, 90, 0), flopTime / 2, DG.Tweening.RotateMode.Fast):OnComplete(function()
        if self.point == nil or self.point == "-1" then
            self:SetPoints(cardPoint)
            UIUtil.SetRotation(self.gameObject, 0, -90, 0)

            self.transform:DOLocalRotate(Vector3.New(0, 0, 0), flopTime / 2, DG.Tweening.RotateMode.Fast):OnComplete(function()
                self.isFloping = false
                if not IsNil(callback) then
                    callback()
                end
            end)
        else
            UIUtil.SetRotation(self.gameObject, 0, 0, 0)
        end
    end)
end

--隐藏牌
function Pin5PokerCard:HideCard()
    self:SetDisplay(false)
    self:StopTween()
end

--显示牌
function Pin5PokerCard:ShowCard()
    self:SetDisplay(true)
end

function Pin5PokerCard:SetDisplay(display)
    if self.lastDisplay ~= display then
        self.lastDisplay = display
        UIUtil.SetActive(self.gameObject, display)
    end
end

--设置坐标
function Pin5PokerCard:SetParentLocalPosition(pos)
    self.parentRectTransform.anchoredPosition = pos
end

--设置隐藏显示第五张牌标记
function Pin5PokerCard:SetActiveFiveCardTip(display)
    if self.lastTagDisplay ~= display then
        self.lastTagDisplay = display
        UIUtil.SetActive(self.tagGo, display)
    end
end

--提起牌
function Pin5PokerCard:DOLocalMoveUpPositionY(y, isPlayAni)
    --if isPlayAni then
        --self.transform:DOLocalMove(Vector3(0, y, 0), 0.2)
    --else
        self.rectTransform.anchoredPosition = Vector2(0, y)
    --end
end

--是否提起牌
function Pin5PokerCard:IsUpPositionY()
    return self.rectTransform.anchoredPosition.y ~= 0
end

--还原牌
function Pin5PokerCard:RestoreUpPositionY()
    self.rectTransform.anchoredPosition = Vector2(0, 0)
end

--播放Tween动画
function Pin5PokerCard:PlayTween()
    self.tweener:ResetToBeginning()
    self.tweener:PlayForward()
end

--停止Tween动画
function Pin5PokerCard:StopTween()
    self.tweener.enabled = false
end

return Pin5PokerCard