PdkHandCard = ClassLuaComponent("PdkHandCard")
local this = PdkHandCard
PdkHandCard.value = nil    --扑克
PdkHandCard.index = nil    --扑克位置
PdkHandCard.color = nil    --扑克的花色
PdkHandCard.point = nil   --扑克的点数
PdkHandCard.weight = nil   --扑克的权值
PdkHandCard.isUp = false   --是否弹起
PdkHandCard.isClick = false --是否可以点击

function PdkHandCard:Awake()
    self.rectTransform = self:GetComponent("RectTransform")
    self.listener = self.transform:Find("Listener")
    self.width = UIUtil.GetWidth(self.rectTransform)
    self.height = UIUtil.GetHeight(self.rectTransform)
    self.pokerImage = self.listener:Find("Image"):GetComponent("Image")
    UIEventTriggerListener.Get(self.listener.gameObject).onEnter = HandlerByStaticArg2(self, self.OnClickEnter)
    UIEventTriggerListener.Get(self.listener.gameObject).onDown = HandlerByStaticArg2(self, self.OnClickDown)
    UIEventTriggerListener.Get(self.listener.gameObject).onUp = HandlerByStaticArg2(self, self.OnClickUp)
end

--初始化卡牌的信息  扑克ID 扑克花色 扑克点数
function PdkHandCard:Init(value, index)
    self.transform:DOKill()
    UIUtil.SetLocalScale(self.transform, 1, 1, 1)
    UIUtil.SetRotation(self.transform, 0, 0, 0)
    UIUtil.SetLocalPosition(self.pokerImage.rectTransform, 0, 0, 0)
    self.pokerImage.color = Color(1, 1, 1, 1)
    -- self.transform.gameObject.name = tostring(value)
    self.value = value
    self.index = index
    self.isClick = false
    self.isUp = false
    self.isSelect = false
    self.color = PdkPokerLogic.GetIdColorType(value)
    self.point = PdkPokerLogic.GetIdPoint(value)
    self.weight = PdkPokerLogic.GetIdWeight(value)
    self:SetSprite(-1)
end

function PdkHandCard.OnClickEnter(mself, trigger, event)
    if not mself.isClick then
        return
    end
    PdkSelfHandCardCtrl.OnClickEnter(mself.index)
end

function PdkHandCard.OnClickDown(mself, trigger, event)
    if not mself.isClick then
        return
    end
    PdkSelfHandCardCtrl.OnClickDown(mself.index)
end

function PdkHandCard.OnClickUp(mself, trigger, event)
    if not mself.isClick then
        return
    end
    PdkSelfHandCardCtrl.OnClickUp()
end

function PdkHandCard:SetIsClick(isClick)
    self.isClick = isClick
end

--设置花色
function PdkHandCard:SetSprite(value)
    self.pokerImage.sprite = PdkResourcesCtrl.pokerAtlas[value]
end

function PdkHandCard:SetIndex(index)
    self.index = index
end

function PdkHandCard:SetIsSelect(isSelect)
    self.isSelect = isSelect
end

--改变扑克的状态
function PdkHandCard:ChangePokerStatus(isSelect)
    self.isSelect = isSelect
    if isSelect then
        self.pokerImage.color = Color(0.38, 0.38, 0.38, 1)
    else
        self.pokerImage.color = Color(1, 1, 1, 1)
    end
end

function PdkHandCard:ChangePokerColor()
    if self.isSelect then
        self.pokerImage.color = Color(0.38, 0.38, 0.38, 1)
    else
        self.pokerImage.color = Color(1, 1, 1, 1)
    end
end

--卡牌弹起还是落下
function PdkHandCard:SetPokerPosY()
    --如果需要动画则不直接设置坐标值
    if self.isUp then
        self:DownPoker(true)
    else
        self:UpPoker(true)
    end
    self:ChangePokerStatus(false)
end

function PdkHandCard:UpPoker(isAnim)
    if isAnim then
        local tween = self.pokerImage.transform:DOLocalMove(Vector3(self.pokerImage.rectTransform.localPosition.x, 50, 0), 0.1, false)
    else
        UIUtil.SetLocalPosition(self.pokerImage.rectTransform, self.pokerImage.rectTransform.localPosition.x, 50, 0)
    end
    -- tween:SetId(self.pokerImage.transform)
    self.isUp = true
end

function PdkHandCard:DownPoker(isAnim)
    if isAnim then
        local tween = self.pokerImage.transform:DOLocalMove(Vector3(self.pokerImage.rectTransform.localPosition.x, 0, 0), 0.1, false)
    else
        UIUtil.SetLocalPosition(self.pokerImage.rectTransform, self.pokerImage.rectTransform.localPosition.x, 0, 0)
    end
    -- tween:SetId(self.pokerImage.transform)
    self.isUp = false
end