--此文件由[BabeLua]插件自动生成
--local EqsCard = Class("EqsCard")
EqsCard = ClassLuaComponent("EqsCard")
local cardMovingTime = 0.1
EqsCard.followCards = {}   --key:value = EqsCard:Vector3  表示当前follow牌相对于跟随牌的相对位置(全局坐标)
EqsCard.isChuPai = false
EqsCard.lastClickUpTime = 0
EqsCard.cUid = 0

--uid = EqsCardDefine.CardID + 1|2|3|4   uid：牌的唯一标识符   如：大二 121,122,123,124
function EqsCard:InitCard(uid)
    self.cUid = uid
    self.isChuPai = false
    self.cId = EqsTools.GetEqsCardId(self.cUid) -- 牌id       120
    self.cType = EqsTools.GetEqsCardType(self.cUid) -- 牌类型 EqsCardDefine.CardType  2
    self.cPoint = EqsTools.GetEqsCardPoint(self.cUid) -- 牌点数 EqsCardDefine.CardPoint
    self:SetLocation(0, 0) -- 牌所在行列
    self.chuPaiEffectTran = self:Find("ChuPaiEffect")
    UIEventTriggerListener.Get(self.gameObject).onDown = HandlerByStatic(self, self.OnClickDown, self)
    UIEventTriggerListener.Get(self.gameObject).onUp = HandlerByStatic(self, self.OnClickUp, self)
    -- 牌是否被激活(相同三张或者4张牌必须组成一坎牌，此时牌未被激活，不能被操作)
    self.isActive = true
    self.isFanPai = false  --是否是翻牌
    local cardTran = self:Find("Card")
    if cardTran ~= nil then
        self.image = cardTran:GetComponent("UnityEngine.UI.Image")
    end
    --是否是移动
    self.isMoved = false
    self.transform = self.gameObject.transform:GetComponent("RectTransform")
    self:CancelAllEffect()

    --设置圈标记
    UIUtil.SetActive(self:Find("QuanTag"), false)

    AddEventListener(CMD.Game.ApplicationPause, HandlerByStaticArg1(self, self.UnscheduleGlobal))
end

function EqsCard:UnscheduleGlobal(pauseStatus)
    SelfHandEqsCardsCtrl.isClickedCard = false
    Scheduler.unscheduleGlobal(self.updateHandle)
    if IsNull(self.transform) then
        return 
    end
    EqsBattleCtrl.SetAllSmallCardsEffect(self:GetUid(), EqsCardDefine.SmallCardEffectType.Normal)
    self:CancelDragEffect()
    self.updateHandle = nil
    --返回游戏前端
    if pauseStatus == false then
        EqsBattleCtrl.SetTingPaiVisible(false)
        SelfHandEqsCardsCtrl.DealAllLineCards()
    end
end

function EqsCard:GetPoint()
    --Log("GetPoint:", self.cPoint, "   Uid:", self.cUid)
    return self.cPoint
end

function EqsCard:GetUid()
    return self.cUid
end

function EqsCard:GetId()
    return self.cId
end

function EqsCard:GetType()
    return self.cType
end

function EqsCard:SetQuanTag()
    if self.cType == EqsCardDefine.CardType.Da and self.cPoint == BattleModule.curCircle then
        UIUtil.SetActive(self:Find("QuanTag"), true)
    else
        UIUtil.SetActive(self:Find("QuanTag"), false)
    end
end

local colorNotActive = Color(0.8, 0.8, 0.8, 1)
local colorActive = Color(1, 1, 1, 1)

function EqsCard:SetActive(active)
    self.isActive = active
end

function EqsCard:GetActive()
    return self.isActive
end

-- 设置牌的逻辑位置:line 行    row：列
function EqsCard:SetLocation(line, row)
    self.location = Vector2(line, row)
end

function EqsCard:GetLocation()
    return self.location
end

function EqsCard:HasFollowCards()
    if SelfHandEqsCardsCtrl.isXiaoJia or self.movingCardNum == nil then
        return false
    end
    return self.movingCardNum > 1
end

function EqsCard:SetLocalPosition(vec2)
    self.transform.localPosition = Vector2(300, 100)
end

function EqsCard:SetParent(tran)
    self.transform:SetParent(tran)
end

function EqsCard:IsChuPai()
    return self.isChuPai
end
function EqsCard:ShowChuPaiEffect(visible)
    if self.chuPaiEffectTran ~= nil then
        self.chuPaiEffectTran.gameObject:SetActive(visible)
    end
end
local isChuPaiStatus = false
local userCtrl = nil
-- 拖动牌
function EqsCard:OnDrag(target)
    if BattleModule.isPlayback then
        --Log("回放")
        return 
    end
    local self = target
    if SelfHandEqsCardsCtrl.GetDraggable() == false then
        return
    end
    if self:IsChuPai() then
        return
    end

    if self:GetActive() == false and not self:HasFollowCards() then
        return
    end
    
    local pos = UIUtil.ScreenToPosition(self.transform, Input.mousePosition, UIConst.uiCamera)
    self.transform.position = Vector3(pos.x, pos.y, 0) + self.pianYiPos
    if self:HasFollowCards() then
        for card, pos in pairs(self.followCards) do
            card.transform.position = self.transform.position - pos
        end
    end

    local tranPos = self.transform.position
    if math.abs(tranPos.x - self.originPos.x) > 5 or math.abs(tranPos.y - self.originPos.y) > 5 then
        self.isMoved = true
    end

    -- 如果拖动到出牌区域，显示特效
    local isInRect = EqsTools.ScreenPosInRect(EqsBattlePanel.GetChuPaiRect())
    if isInRect and isChuPaiStatus then
        self:ShowChuPaiEffect(true)
        return
    else
        self:ShowChuPaiEffect(false)
    end

    if SelfHandEqsCardsCtrl.isXiaoJia then
        return
    end
    -- 判断在牌格子里时，将格子里面的牌上移
    for i = 1, 10 do
        for j = 1, 4 do
            local cell = SelfHandEqsCardsCtrl.GetCell(i, j)
            local card = SelfHandEqsCardsCtrl.GetEqsCard(i, j)
            local loc = self:GetLocation()

            local inCell = EqsTools.ScreenPosInRect(cell)
            -- 在格子里面
            if inCell then
                -- 如果格子没激活
                if card ~= nil and card:GetActive() == false and not self:HasFollowCards() then
                    return
                end

                --在本行内移动时，交换位置
                if loc.x == i then
                    if not self:HasFollowCards() then
                        if card ~= self then -- 非自己
                            SelfHandEqsCardsCtrl.AddCardToCell(self, i, j, true, true)
                            if card ~= nil then
                                SelfHandEqsCardsCtrl.AddCardToCell(card, loc.x, loc.y, true)
                                return
                            end
                        end
                    end
                else -- 不在本行内移动时
                    local lineCardNum = SelfHandEqsCardsCtrl.GetLineCardNum(i)
                    if not self:HasFollowCards() then
                        if lineCardNum < 4 then
                            -- 其余牌上移
                            for k = 3, j, -1 do
                                local card = SelfHandEqsCardsCtrl.GetEqsCard(i, k)
                                if card ~= nil then
                                    SelfHandEqsCardsCtrl.AddCardToCell(card, i, k + 1, true)
                                end
                            end
                            -- 自己牌放格子里
                            SelfHandEqsCardsCtrl.AddCardToCell(self, i, j, false, true)
                            --将自己牌所在列上面的牌下移
                            SelfHandEqsCardsCtrl.DealLineCards(loc.x)
                        end
                    else
                        --自己行除了移动牌后剩余牌张数      跟随牌为3张或者4张
                        local selfLeftLineCardNum = SelfHandEqsCardsCtrl.GetLineCardNum(self.location.x) - self.movingCardNum
                        --交换行(只能相邻行交换, 且相邻行必须有牌)
                        if math.abs(self.location.x - i) == 1 and lineCardNum > 0 then
                            if selfLeftLineCardNum + lineCardNum <= 4 then
                                local addIdx = 0
                                local card = SelfHandEqsCardsCtrl.GetEqsCard(self.location.x, 1)
                                if card ~= nil and card:GetId() ~= self:GetId() then
                                    addIdx = 1
                                end

                                --将目标行牌移动到本行
                                for k = 1, 4 do
                                    local card = SelfHandEqsCardsCtrl.GetEqsCard(i, k)
                                    if card ~= nil then
                                        SelfHandEqsCardsCtrl.AddCardToCell(card, self.location.x, k + addIdx, true)
                                    end
                                end

                                --将本行移动牌移动到目标行
                                SelfHandEqsCardsCtrl.AddCardToCell(self, i, self.location.y, false, true)
                                for card, _ in pairs(self.followCards) do
                                    SelfHandEqsCardsCtrl.AddCardToCell(card, i, card.location.y, false, true)
                                end
                                SelfHandEqsCardsCtrl.DealLineCards(self.clickDownLoc.x)
                            end
                        end
                    end
                end
                return
            end
        end
    end
end


--出牌
local lastChuPaiTime = 0
function EqsCard:ChuPai(uid)
    local now = os.timems()
    ----Log("出牌时间：",self.cUid, now, lastChuPaiTime, now - lastChuPaiTime)
    if now - lastChuPaiTime >= 1000 then
        --可以走出牌逻辑
        lastChuPaiTime = now
    else
        ----Log("禁止出牌：",self.cUid, now, lastChuPaiTime, now - lastChuPaiTime)
        return 
    end
    if EqsBattleCtrl.curChuPaiUid ~= BattleModule.uid then
        EqsBattleCtrl.SetChuPaiInfo(self, uid, true, true)
        SelfHandEqsCardsCtrl.AddChuPaiToChuPaiRect(self, true)
        ----Log('自己出牌：', self.cUid)

        Scheduler.scheduleOnceGlobal(SelfHandEqsCardsCtrl.DealAllLineCards, 0.4)
    else
        ----Log('自己出牌失败，已经出牌：', self.cUid)
    end

end

EqsCard.updateHandle = nil
function EqsCard:OnClickDown(targetCard)
    local tweenAlpha = self.transform:Find("Card"):GetComponent(typeof(TweenAlpha))
    if not IsNull(tweenAlpha) then
        tweenAlpha.enabled = false
    end
    Scheduler.unscheduleGlobal(self.updateHandle)
    --Log("点击按下", self.cUid)
    if BattleModule.isPlayback then
        --Log("回放")
        return 
    end
    local self = targetCard
    if SelfHandEqsCardsCtrl.GetDraggable() == false then
        --Log("SelfHandEqsCardsCtrl.GetDraggable():", SelfHandEqsCardsCtrl.GetDraggable(), self.cUid)
        return
    end
    if self:IsChuPai() then
        --Log("IsChuPai:", self:IsChuPai(), self.cUid)
        return
    end
    self.followCards = SelfHandEqsCardsCtrl.GetFollowCards(self)
    self.movingCardNum = GetTableSize(self.followCards) + 1   -- 移动牌加上自己的牌
    if self:GetActive() == false and not self:HasFollowCards() then
        --Log("GetActive:", self:GetActive(), self:HasFollowCards())
        return
    end
    SelfHandEqsCardsCtrl.isClickedCard = true
    local pos = UIUtil.ScreenToPosition(self.transform, Input.mousePosition, UIConst.uiCamera)
    self.pianYiPos = self.transform.position - Vector3(pos.x, pos.y, 0)
    self.originPos = self.transform.position
    self.clickDownLoc = self:GetLocation()

    self.updateHandle = Scheduler.scheduleUpdateGlobal(HandlerByStatic(self, self.OnDrag, self))

    EqsBattleCtrl.SetAllSmallCardsEffect(self:GetUid(), EqsCardDefine.SmallCardEffectType.Hong)

    self:SetDragEffect()
    if self:HasFollowCards() then
        for card, _ in pairs(self.followCards) do
            card:SetDragEffect()
        end
    end

    isChuPaiStatus = false
    userCtrl = BattleModule.GetUserInfoByUid(BattleModule.uid)
    if userCtrl ~= nil then
        isChuPaiStatus = userCtrl:GetStatus() == EqsUserStatus.ChuPai and not self:HasFollowCards() and not BattleModule.hasChuPai
    end

    EqsBattleCtrl.SetTingPaiContent(self.cId)
end

-- 点击松开
function EqsCard:OnClickUp(targetCard)
    EqsBattleCtrl.SetTingPaiVisible(false)
    ----LogError("点击抬起", self.cUid)
    SelfHandEqsCardsCtrl.isClickedCard = false
    if BattleModule.isPlayback then
        ----Log("回放")
        return 
    end

    local self = targetCard
    EqsBattleCtrl.SetAllSmallCardsEffect(self:GetUid(), EqsCardDefine.SmallCardEffectType.Normal)
    self:CancelDragEffect()

    Scheduler.unscheduleGlobal(self.updateHandle)
   
    if SelfHandEqsCardsCtrl.GetDraggable() == false then
        --Log("SelfHandEqsCardsCtrl.GetDraggable():", SelfHandEqsCardsCtrl.GetDraggable(), self.cUid)
        --归位
        if self.transform.localPosition:Equals(Vector3.zero) ~= true then
            self.transform:DOLocalMove(Vector3.zero, cardMovingTime, false)
            for card, _ in pairs(self.followCards) do
                card.transform:DOLocalMove(Vector3.zero, cardMovingTime, false)
            end
        end
        self.transform.localRotation = Quaternion.Euler(0, 0, 0)
        SelfHandEqsCardsCtrl.DealAllLineCards()
        SelfHandEqsCardsCtrl.DealLinesMove()
        return
    end
    --Log("IsChuPai:",self:GetActive(),self:HasFollowCards(), self:IsChuPai(), self.cUid, BattleModule.isSelectingHsz, self.isMoved, IsNull(self.transform))
    if self:IsChuPai() then
        return
    end
    --换三张过程中
    if BattleModule.isSelectingHsz then
        if not self.isMoved then
            if self:IsSelectedHuan() then
                EqsBattleCtrl.RemoveHszCards(self)
            else
                EqsBattleCtrl.AddHszCards(self)
            end
        end
    end
    self.isMoved = false

    if self:HasFollowCards() then
        for card, _ in pairs(self.followCards) do
            card:CancelDragEffect()
        end
    end

    if self:GetActive() == false and not self:HasFollowCards() then
        return
    end
    self:ShowChuPaiEffect(false)

    if self.clickDownLoc == nil then
        return 
    end

    --双击出牌判断
    local chuPai = false
    if os.timems() - self.lastClickUpTime < 400 then
        --Log("点击间隔：", os.timems(), self.lastClickUpTime, os.timems() - self.lastClickUpTime)
        self.lastClickUpTime = os.timems()
        chuPai = true
    else
        self.lastClickUpTime = os.timems()
    end

    if BattleModule.isSelectingHsz == true then
        chuPai = false
    end
    local isInRect = EqsTools.ScreenPosInRect(EqsBattlePanel.GetChuPaiRect())
    -- 在出牌区域出牌
    if (chuPai and isChuPaiStatus) or (isInRect and isChuPaiStatus) then
        --缓存位置信息
        local loc = self.clickDownLoc
        self:ChuPai(BattleModule.uid)
        if SelfHandEqsCardsCtrl.isXiaoJia then
            return
        end
        --将已出牌列上面的牌下移
        SelfHandEqsCardsCtrl.DealLineCards(loc.x)
        SelfHandEqsCardsCtrl.DealLineCards(self:GetLocation().x)

        --处理移动列情况
        SelfHandEqsCardsCtrl.DealLinesMove()
    else --非出牌区域
        Scheduler.unscheduleGlobal(self.dealLineSchedule)
        self.dealLineSchedule = Scheduler.scheduleOnceGlobal(function ()
            SelfHandEqsCardsCtrl.AddCardToCell(self,self.location.x,self.location.y,false,false)
        end,0.5)
        if SelfHandEqsCardsCtrl.isXiaoJia then --小家时，牌直接归位
            if self.transform.localPosition:Equals(Vector3.zero) ~= true then
                self.transform:DOLocalMove(Vector3.zero, cardMovingTime, false)
            end
            return
        end
        -- 判断当前鼠标是否在格子里
        local mouseInCell = false
        for i = 1, 10 do
            for j = 1, 4 do
                local cell = SelfHandEqsCardsCtrl.GetCell(i, j)
                if cell ~= nil then
                    if EqsTools.ScreenPosInRect(cell) then
                        mouseInCell = true
                        break
                    end
                end
            end

            if mouseInCell then
                break
            end
        end

        --在格子里面
        if mouseInCell then
            -- 预防自己牌不在中心时，归位
            if self.transform.localPosition:Equals(Vector3.zero) ~= true then
                self.transform:DOLocalMove(Vector3.zero, cardMovingTime, false)
                for card, _ in pairs(self.followCards) do
                    card.transform:DOLocalMove(Vector3.zero, cardMovingTime, false)
                end
            end
            if not self:HasFollowCards() then
                -- 左移超过2行时，移动到左边相邻的空行
                if self:GetLocation().x + 1 < self.clickDownLoc.x then
                    for x = self.clickDownLoc.x - 1, self:GetLocation().x, -1 do
                        local num = SelfHandEqsCardsCtrl.GetLineCardNum(x)
                        if num == 0 then
                            SelfHandEqsCardsCtrl.AddCardToCell(self, x, 1, true)
                            break
                        end
                    end
                end

                --右移超过两行时，移动到右边相邻空行
                if self:GetLocation().x > self.clickDownLoc.x + 1 then
                    for x = self.clickDownLoc.x + 1, self:GetLocation().x do
                        local num = SelfHandEqsCardsCtrl.GetLineCardNum(x)
                        if num == 0 then
                            SelfHandEqsCardsCtrl.AddCardToCell(self, x, 1, true)
                            break
                        end
                    end
                end

                --当该行有牌时，移动到最下面的格子，处理3次(当牌在当前列最上面时)
                local loc = self:GetLocation()
                SelfHandEqsCardsCtrl.DealLineCards(loc.x)

                --处理移动列情况
                SelfHandEqsCardsCtrl.DealLinesMove()
            else
                SelfHandEqsCardsCtrl.DealLineCards(self:GetLocation().x)
            end
        else -- 不在格子里面时
            if not self:HasFollowCards() then
                -- 移回原位置(如果原位置有牌时，全体上移一格)
                for i = 3, self.clickDownLoc.y, -1 do
                    local card = SelfHandEqsCardsCtrl.GetEqsCard(self.clickDownLoc.x, i)
                    if card ~= nil then
                        SelfHandEqsCardsCtrl.AddCardToCell(card, self.clickDownLoc.x, i + 1, true)
                    end
                end
                -- Log('最近的格子：', self:GetLocation().x, '   ', self:GetLocation().y)
                local loc = self:GetLocation()
                SelfHandEqsCardsCtrl.AddCardToCell(self, self.clickDownLoc.x, self.clickDownLoc.y, true)
                SelfHandEqsCardsCtrl.DealLineCards(loc.x) -- 处理经过的最近的格子
            else
                --归位
                if self.transform.localPosition:Equals(Vector3.zero) ~= true then
                    self.transform:DOLocalMove(Vector3.zero, cardMovingTime, false)
                    for card, _ in pairs(self.followCards) do
                        card.transform:DOLocalMove(Vector3.zero, cardMovingTime, false)
                    end
                end
                self.transform.localRotation = Quaternion.Euler(0, 0, 0)
            end
        end
    end
    SelfHandEqsCardsCtrl.SaveAllLocalPos()
    self.followCards = {}
    SelfHandEqsCardsCtrl.DealAllLineCards()
    if not BattleModule.isPerform772 then
        SelfHandEqsCardsCtrl.CheckCardsByTempIds()
    end
end

function EqsCard:SetDragEffect()
    local img = self.transform:Find("Card"):GetComponent("UnityEngine.UI.Image")
    img.color = Color(0.7, 0.7, 0.7, 0.8)
end

function EqsCard:CancelDragEffect()
    local img = self.transform:Find("Card"):GetComponent("UnityEngine.UI.Image")
    img.color = Color(1, 1, 1, 1)
end

function EqsCard:SetGunVisible(visible)
    -- Log(">>>>>>>>>>>>设磙特效：", visible, self:GetId())
    local tran = self.transform:Find("BigGunTag")
    if tran ~= nil then
        tran.gameObject:SetActive(visible == true)
    end
end

function EqsCard:SetHuanVisible(visible)
    local tran = self.transform:Find("Selected")
    if tran ~= nil then
        tran.gameObject:SetActive(visible == true)
    end
end

function EqsCard:IsSelectedHuan()
    local tran = self.transform:Find("Selected")
    if tran ~= nil then
        return tran.gameObject.activeSelf
    end
end

function EqsCard:SetChangedHuanVisible(visible)
    local tran = self.transform:Find("Changed")
    if tran ~= nil then
        tran.gameObject:SetActive(visible == true)
    end
end

function EqsCard:CancelAllEffect(includeGun)
    if includeGun == nil then
        self:SetGunVisible(false)
    else
        if includeGun then
            self:SetGunVisible(false)
        end
    end
    -- Log("取消所有特效：", self.cUid, includeGun)
    self:CancelDragEffect()
    self:SetHuanVisible(false)
    self:SetChangedHuanVisible(false)
    self:ShowChuPaiEffect(false)
    UIUtil.SetActive(self:Find("QuanTag"), false)
end

function EqsCard:OnDestroy()
    self:UnscheduleGlobal(true)
end
return EqsCard