Pin3Card = ClassLuaComponent("Pin3Card")
local cardBundleName = "pin3/cardimgs"
--牌ID
Pin3Card.id = 0
--牌正面
Pin3Card.forwardImg = nil
--牌背面
Pin3Card.backTran = nil
--所有牌背面
Pin3Card.allBackTrans = {}
function Pin3Card:Init()
    self.gameObject.name = tostring(self.id)
    self.forwardImg = self:Find("Forward"):GetComponent("Image")
    self.transform = self.transform:GetComponent("RectTransform")
    self.allBackTrans = {}
    self.allBackTrans[1] = self:Find("Back1"):GetComponent("RectTransform")
    self.allBackTrans[2] = self:Find("Back2"):GetComponent("RectTransform")
    self.allBackTrans[3] = self:Find("Back3"):GetComponent("RectTransform")
    self.allBackTrans[4] = self:Find("Back4"):GetComponent("RectTransform")
    self:SetBgImgTran(true)

    self.updateCardBgHandle = function()
        self:OnGameUpdateBackgroud()
    end
    AddMsg(CMD.Game.UpdataCardBackgroud, self.updateCardBgHandle)
end

function Pin3Card:OnDestroy()
    RemoveMsg(CMD.Game.UpdataCardBackgroud, self.updateCardBgHandle)
end

function Pin3Card:SetBgImgTran(isSetBackShow)
    for i, backTran in pairs(self.allBackTrans) do
        if i == Pin3Data.cardBackType then
            self.backTran = backTran
        end
    end
    if self.backTran == nil then
        self.backTran = self.allBackTrans[2]
        Pin3Data.cardBackType = 2
    end
    if isSetBackShow == true then
        for _, back in pairs(self.allBackTrans) do
            UIUtil.SetActive(back, back == self.backTran)
        end
    end

    Log("======>SetBgImgTran", self.backTran, Pin3Data.cardBackType, self.allBackTrans)
end

function Pin3Card:SetCardId(id)
    self.id = id
    if id ~= nil and id > 0 then
        Pin3Utils.SetCardIdSprite(self)
    end
end

function Pin3Card:SetAnchoredPosition(x, y, anim, animTime)
    if IsNumber(x) and IsNumber(y) and not IsNull(self.transform) then
        if IsBool(anim) and anim == true then
            if IsNumber(animTime) and animTime > 0.001 then
                return self.transform:DOAnchorPos(Vector2(x, y), animTime):SetEase(DG.Tweening.Ease.Linear)
            else
                return self.transform:DOAnchorPos(Vector2(x, y), 0.2):SetEase(DG.Tweening.Ease.Linear)
            end
        else
            UIUtil.SetAnchoredPosition(self.transform, x, y)
        end
    end
end

function Pin3Card:SetParent(parent)
    if not IsNull(parent) then
        self.transform:SetParent(parent)
        self.transform:SetAsFirstSibling()
    end
end

--翻牌动画：背面翻转到正面
local rotationY90 = Vector3(0, 90, 0)
local rotationY270 = Vector3(0, 270, 0)
local rotationY360 = Vector3(0, 360, 0)
function Pin3Card:ShowForwardByAnim()
    if self.backTran.gameObject.activeSelf then
        UIUtil.SetActive(self.forwardImg.transform, false)
        UIUtil.SetActive(self.backTran, true)
        self.backTran:DOLocalRotate(rotationY90, 0.05):OnComplete(function()
            UIUtil.SetActive(self.forwardImg.transform, true)
            UIUtil.SetActive(self.backTran, false)
            self.forwardImg.transform.localRotation = Quaternion.Euler(-rotationY90.x, -rotationY90.y, -rotationY90.z)
            self.forwardImg.transform:DOLocalRotate(Vector3.zero, 0.05)
        end)
    end
end


--设置黑色效果
function Pin3Card:SetBlackEffect()
    UIUtil.SetImageColor(self.forwardImg, 0.5, 0.5, 0.5)
    UIUtil.SetImageColor(self.backTran:GetComponent("Image"), 0.5, 0.5, 0.5)
end

function Pin3Card:OnGameUpdateBackgroud()
    local isShowBack = self.backTran.gameObject.activeSelf
    self:SetBgImgTran(false)
    if isShowBack then
        for _, back in pairs(self.allBackTrans) do
            UIUtil.SetActive(back, back == self.backTran)
        end
    end
end