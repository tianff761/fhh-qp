--扑克牌
SDBPokerCard = {
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
SDBPokerCard.meta = { __index = SDBPokerCard }

function SDBPokerCard:New()
    local o = {}
    setmetatable(o, self.meta)
    return o
end

--初始化扑克牌
function SDBPokerCard:Init(obj)
    self.gameObject = obj
    self.transform = obj.transform
    self.image = obj:GetComponent(TypeImage)
    self:GetPokerColor()
    self:ChangePokerColor()
    Event.AddListener(SDBAction.PokerStyleType, HandlerArgs(SDBPokerCard.ChangePokerColor, self))
end

--改变牌颜色
function SDBPokerCard.ChangePokerColor(poker)
    if poker.gameObject ~= nil then
        poker:ChangePokerColor(SDBRoomData.cardColor)
    else
        Event.RemoveListener(SDBAction.PokerStyleType)
    end
end

function SDBPokerCard:Reset()
    self.point = nil
    self.isFloped = false
end

--改变扑克牌背面颜色  --传入颜色枚举  PokerCardColor
function SDBPokerCard:GetPokerColor()
    self.color = SDBRoomData.cardColor
    return self.color
end

--改变扑克牌背面的颜色
function SDBPokerCard:ChangePokerColor(color)
    self.color = color
    if self.point == "-1" and self.gameObject.activeSelf == true then
        self:SetPoints("-1")
    end
end

--设置点数 --传入扑克牌点数  --不传，即设置为背面 --isActive(是否显示牌,可以设置点数，不展示牌)
function SDBPokerCard:SetPoints(cardPoint, isActive)
    Log(">>>>>>>>>>>      设置点数》》》》 ", cardPoint)
    local point = tonumber(cardPoint)
    --没有传入点数，表示没有点数，显示背面
    if IsNil(point) or point == -1 then
        if self.color == nil then
            self:GetPokerColor()
        end
        self.point = "-1"
        local sprite = SDBResourcesMgr.GetCardBack()
        if not IsNil(sprite) then
            self.image.sprite = sprite
        end
    else
        self.point = cardPoint
        local sprite = SDBResourcesMgr.GetHandleCardSprite(cardPoint)
        if sprite ~= nil then
            self.image.sprite = sprite
        end
    end

    if IsNil(isActive) then
        isActive = true
    end

    if isActive then
        self:ShowCard()
    end
end

--翻牌动画 由背面翻到正面  --传入点数
function SDBPokerCard:PlayFlopAni(cardPoint)
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
            end)
        else
            UIUtil.SetRotation(self.gameObject, 0, 0, 0)
        end
    end)
end

--隐藏牌
function SDBPokerCard:HideCard()
    UIUtil.SetActive(self.gameObject, false)
end

--显示牌
function SDBPokerCard:ShowCard()
    UIUtil.SetActive(self.gameObject, true)
end

return SDBPokerCard