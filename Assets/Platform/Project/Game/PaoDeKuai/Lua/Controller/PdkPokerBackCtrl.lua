PdkPokerBackCtrl = ClassLuaComponent("PdkPokerBackCtrl")
local this = PdkPokerBackCtrl

function PdkPokerBackCtrl:Awake()
    self.max = 10     --最大张数
    self.leftP = 8    
    self.leftR = 4
    self.RightP = 4
    self.RightR = -4
    self.time = 0.5
    self.isDOTween = false
end

--初始化
function PdkPokerBackCtrl:Init()
    self.backPokers = {}
    local count = self.transform.childCount
    if count > 0 then
        for i = 0, count - 1 do
            local poker = self.transform:GetChild(i)
            poker:DOAnchorPosY(0, 0.01):SetEase(DG.Tweening.Ease.Linear)
            poker:DOLocalRotate(Vector3(0, 0, 0), 0.01):SetEase(DG.Tweening.Ease.Linear)
            table.insert(self.backPokers, poker)
            UIUtil.SetActive(poker.gameObject, true)
        end
    end
end

--更新牌数
function PdkPokerBackCtrl:UpdateCardNum(num)
    local length = GetTableSize(self.backPokers) - num
    if length > 0 then
        for i = 1, length do
            local poker = self.backPokers[1]
            table.remove(self.backPokers, 1)
            UIUtil.SetActive(poker, false)
        end
    end
    if GetTableSize(self.backPokers) > 0 and num > 0 then
        self:UpdateLayout(0.1) 
    end
end

function PdkPokerBackCtrl:UpdateLayout(time)
    local length = GetTableSize(self.backPokers)
    if self.isDOTween or length <= 0 then
        return
    end
    self.isDOTween = true
    local beishu = self.max / length

    local left = Functions.TernaryOperator(length / 3 < 1, 1, math.floor(length / 3))
    local zhong = Functions.TernaryOperator(length >= left + 1, left + 1, 0)
    local right = length - zhong - left

    local y = 0
    local poker = nil

    for i = 0, left - 1 do
        poker = self.backPokers[i + 1]
        local tween = poker:DOAnchorPosY(i * self.leftP * beishu, time):SetEase(DG.Tweening.Ease.Linear)
        poker:DOLocalRotate(Vector3(0, 0, (left - 1 - i) * self.leftR * beishu + 6), time):SetEase(DG.Tweening.Ease.Linear)
        if (i == left - 1) then
            y = i * self.leftP * beishu
        end
        tween:OnComplete(function ()
            self.isDOTween = false
        end)
    end
    if (zhong > 0) then
        local tween = self.backPokers[math.floor(left) + 1]:DOAnchorPosY(y, time):SetEase(DG.Tweening.Ease.Linear)
        self.backPokers[math.floor(left) + 1]:DOLocalRotate(Vector3(0, 0, 0), time):SetEase(DG.Tweening.Ease.Linear)
        tween:OnComplete(function ()
            self.isDOTween = false
        end)
    end
    for i = math.floor(left) + 1, length - 1 do
        poker = self.backPokers[i + 1]
        local tween = poker:DOAnchorPosY(y - (i - left) * self.RightP * beishu, time):SetEase(DG.Tweening.Ease.Linear)
        poker:DOLocalRotate(Vector3(0, 0, ((i - 1) - left) * self.RightR * beishu - 6), time):SetEase(DG.Tweening.Ease.Linear)
        tween:OnComplete(function ()
            self.isDOTween = false
        end)
    end
end