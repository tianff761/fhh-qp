--扑克牌
LYCPokerCard = {
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
LYCPokerCard.meta = { __index = LYCPokerCard }

function LYCPokerCard:New()
    local o = {}
    setmetatable(o, self.meta)
    return o
end

--初始化扑克牌
function LYCPokerCard:Init(obj)
    self.gameObject = obj
    self.transform = obj.transform
    self.image = obj:GetComponent(TypeImage)
    self:GetPokerColor()
    self:ChangePokerColor()
    self:InitPanel()
    Event.AddListener(LYCAction.PokerStyleType, HandlerArgs(LYCPokerCard.ChangePokerColor, self))
end

--改变牌颜色
function LYCPokerCard.ChangePokerColor(poker)
    if poker.gameObject ~= nil then
        poker:ChangePokerColor(LYCRoomData.cardColor)
    else
        Event.RemoveListener(LYCAction.PokerStyleType)
    end
end

function LYCPokerCard:Reset()
    self.point = nil
    self.isFloped = false
    self:RestoreUpPositionY()
    self:SetAvtiveFiveCardTip(false)
end

function LYCPokerCard:InitPanel()
    self.tipImage = self.transform:Find("Image")
end

--改变扑克牌背面颜色  --传入颜色枚举  PokerCardColor
function LYCPokerCard:GetPokerColor()
    self.color = LYCRoomData.cardColor
    return self.color
end

--改变扑克牌背面的颜色
function LYCPokerCard:ChangePokerColor(color)
    self.color = color
    if self.point == "-1" and self.gameObject.activeSelf == true then
        self:SetPoints("-1")
    end
end

--设置点数 --传入扑克牌点数  --不传，即设置为背面 --isActive(是否显示牌,可以设置点数，不展示牌)
function LYCPokerCard:SetPoints(cardPoint, isActive)
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
        local sprite = LYCResourcesMgr.GetCardBack()
        if not IsNil(sprite) then
            self.image.sprite = sprite
        end
    else
        self.point = cardPoint
        local sprite = LYCResourcesMgr.GetHandleCardSprite(cardPoint)
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
function LYCPokerCard:PlayFlopAni(cardPoint, callback)
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
function LYCPokerCard:HideCard()
    UIUtil.SetActive(self.gameObject, false)
end

--显示牌
function LYCPokerCard:ShowCard()
    UIUtil.SetActive(self.gameObject, true)
end

--设置坐标
function LYCPokerCard:SetParentLocalPosition(pos)
    UIUtil.SetLocalPosition(self.transform.parent.gameObject, pos)
end

--设置隐藏显示第五张牌标记
function LYCPokerCard:SetAvtiveFiveCardTip(isTrue)
    -- UIUtil.SetActive(self.tipImage.gameObject, isTrue)
    UIUtil.SetActive(self.tipImage.gameObject, false)
end

--提起牌
function LYCPokerCard:DOLocalMoveUpPositionY(y, isPlayAni)
    if isPlayAni then
        self.transform:DOLocalMove(Vector3(0, y, 0), 0.2)
    else
        UIUtil.SetLocalPosition(self.transform.gameObject, Vector3(0, y, 0))
    end
end

--是否提起牌
function LYCPokerCard:IsUpPositionY()
    return self.transform.localPosition.y ~= 0
end

--还原牌
function LYCPokerCard:RestoreUpPositionY()
    UIUtil.SetLocalPosition(self.transform.gameObject, Vector3(0, -2, 0))
end

return LYCPokerCard