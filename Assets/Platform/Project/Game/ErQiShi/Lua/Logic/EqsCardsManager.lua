EqsCardsManager = {}
EqsCardsManager.cards = {} --贰柒拾牌      EqsCard对象
EqsCardsManager.cardTrans = {} --贰柒拾牌      大牌Transform对象，便于其他地方复制引用
EqsCardsManager.sCards = {} --贰柒拾小牌    Transform对象

EqsCardsManager.cacheCardTrans = {}   --贰柒拾大牌缓存：{id={tran,tran,tran,tran}, ...}
EqsCardsManager.cachesCardTrans = {}   --贰柒拾小牌缓存：{id={tran,tran,tran,tran}, ...}

EqsCardsManager.cardsParent = nil       --所有牌的父节点
EqsCardsManager.sCardsParent = nil      --所有小牌的父节点

local this = EqsCardsManager
--所有贰柒拾card的父节点
function EqsCardsManager.Init(panel)
    this.reset()
    this.panel = panel
    this.cardsParent = panel.transform:Find("Cards/NormalCards")
    for k, id in pairs(EqsCardDefine.CardID) do
        local cardTran = this.cardsParent:Find(tostring(id))
        if cardTran ~= nil then
            this.cardTrans[id] = cardTran
            local effect = cardTran:Find("ChuPaiEffect")
            effect.gameObject:SetActive(false)

            this.cacheCardTrans[id] = {}
            --缓存4张大牌
            for i = 1, 4 do
                local go = CreateGO(cardTran.gameObject, this.cardsParent, tostring(id))
                go.transform.anchoredPosition = Vector2(10000, 10000)
                table.insert( this.cacheCardTrans[id], go.transform)
            end
        else
            Log("ERROR=====================>没有查找到牌GameObject:", id)
        end
    end

    this.sCardsParent = panel.transform:Find("Cards/SmallCards")
    for k, id in pairs(EqsCardDefine.CardID) do
        this.sCards[id] = this.sCardsParent:Find(id)
        this.SetSmallCardEffect(this.sCards[id], EqsCardDefine.SmallCardEffectType.Null)
        this.cachesCardTrans[id] = {}
        --缓存5张小牌
        for i = 1, 5 do
            local go = CreateGO(this.sCards[id], this.sCardsParent, tostring(id))
            go.transform.anchoredPosition = Vector2(10000, 10000)
            table.insert( this.cachesCardTrans[id], go.transform)
        end
    end

    this.cardsParent.gameObject:SetActive(false)
    this.sCardsParent.gameObject:SetActive(false)
end

function EqsCardsManager.reset()
    EqsCardsManager.cards = {} --贰柒拾牌      EqsCard对象
    EqsCardsManager.cardTrans = {} --贰柒拾牌      大牌Transform对象，便于其他地方复制引用
    EqsCardsManager.sCards = {} --贰柒拾小牌    Transform对象

    EqsCardsManager.cacheCardTrans = {}   --贰柒拾大牌缓存：{id={tran,tran,tran,tran}, ...}
    EqsCardsManager.cachesCardTrans = {}   --贰柒拾小牌缓存：{id={tran,tran,tran,tran}, ...}
    ResourcesManager.CheckGC(true)
end

-- Card的ID：非唯一ID  返回EqsCard对象
function EqsCardsManager.GetCardByUid(uid)
    local id = EqsTools.GetEqsCardId(uid)
    local cardTran = this.GetCardTranById(id)
    if IsNull(cardTran) then
        LogError("没有查找到牌ID：", uid, id)
        return nil
    end
    this.DestroyCardComponent(cardTran)
    AddLuaComponent(cardTran.gameObject, "EqsCard")
    local card = GetLuaComponent(cardTran.gameObject, "EqsCard")
    cardTran.localPosition = Vector2(10000, 10000)
    cardTran.localScale = Vector3(1,1,1)
    cardTran.gameObject.name = tostring(uid)
    card:InitCard(uid)
    return card
end

-- Card的ID：非唯一ID  返回牌Transform对象
function EqsCardsManager.GetCardTranById(id)
    --先从缓存获取
    local id = tonumber(id)
    local cache = this.cacheCardTrans[id]
    if cache and GetTableSize(cache) > 0 then
        for key, cardTran in pairs(cache) do
            if IsNull(cardTran) then
                LogError("bug：", key, cardTran, cache, this.cardTrans)
                break
            end
            cache[key] = nil
            cardTran.localRotation = Quaternion.Euler(0, 0, 0)
            cardTran.gameObject.name = tostring(id)
            return cardTran
        end
    end

    --实例化
    local card = this.cardTrans[id]
    if IsNull(card) then
        card = this.cardsParent:Find(tostring(id))
    end
    if not IsNull(card) then
        card = CreateGO(card.gameObject, this.cardsParent, tostring(id))
        card.transform.anchoredPosition = Vector3(10000, 0, 0)
        card.name = tostring(id)
        local effect = card.transform:Find("ChuPaiEffect")
        effect.gameObject:SetActive(false)
        return card.transform
    end
    LogError("没有查找到牌：", id)
    return nil
end

-- Card的ID：唯一ID, 返回Transform
function EqsCardsManager.GetSmallCardByUid(uid)
     --先从缓存获取
     local id = tonumber(EqsTools.GetEqsCardId(uid))
     local cache = this.cachesCardTrans[id]
     if cache and GetTableSize(cache) > 0 then
         for key,cardTran in pairs(cache) do
            cache[key] = nil
            if IsNull(cardTran) then
                LogError("bug：", key, cardTran, cache, this.sCards)
                break
            end
            cardTran.gameObject.name = tostring(uid)
            return cardTran
         end
     end

      --实例化
    local card = this.sCards[id]
    if card then
        local card = CreateGO(card.gameObject, this.sCardsParent, tostring(id))
        card.transform.anchoredPosition = Vector3(10000, 0, 0)
        local effect = card.transform:Find("ChuPaiEffect")
        card.name = tostring(uid)
        return card.transform
    end
    return nil
end

--EqsCardDefine.SmallCardEffectType
function EqsCardsManager.SetSmallCardEffect(cardTran, effect)
    local effectTag = cardTran.transform:Find("SmallEffect")
    local yuTag = cardTran.transform:Find("YuTag")
    local gunTag = cardTran.transform:Find("GunTag")
    local directionTag = cardTran.transform:Find("DirectionTag")
    local selectedHsz = cardTran.transform:Find("SelectedTag")
    local changedHsz = cardTran.transform:Find("HuanTag")

    effectTag.gameObject:SetActive(false)
    yuTag.gameObject:SetActive(false)
    gunTag.gameObject:SetActive(false)
    directionTag.gameObject:SetActive(false)
    selectedHsz.gameObject:SetActive(false)
    changedHsz.gameObject:SetActive(false)

   -- Log("设置小牌特效：", cardTran.gameObject.name, effect)
    local img = cardTran:GetComponent("UnityEngine.UI.Image")
    img.color = Color(1, 1, 1, 1)

    if effect == EqsCardDefine.SmallCardEffectType.YuTag then
        yuTag.gameObject:SetActive(true)
    elseif effect == EqsCardDefine.SmallCardEffectType.GunTag then
        gunTag.gameObject:SetActive(true)
    elseif effect == EqsCardDefine.SmallCardEffectType.BoundEffect then
        effectTag.gameObject:SetActive(true)
    elseif effect == EqsCardDefine.SmallCardEffectType.Up then
        directionTag.gameObject:SetActive(true)
        directionTag.transform.localRotation = UnityEngine.Quaternion.Euler(0, 0, 90)
    elseif effect == EqsCardDefine.SmallCardEffectType.Down then
        directionTag.gameObject:SetActive(true)
        directionTag.transform.localRotation = UnityEngine.Quaternion.Euler(0, 0, 270)
    elseif effect == EqsCardDefine.SmallCardEffectType.Left then
        directionTag.gameObject:SetActive(true)
        directionTag.transform.localRotation = UnityEngine.Quaternion.Euler(0, 0, 180)
    elseif effect == EqsCardDefine.SmallCardEffectType.Right then
        directionTag.gameObject:SetActive(true)
        directionTag.transform.localRotation = UnityEngine.Quaternion.Euler(0, 0, 0)
    elseif effect == EqsCardDefine.SmallCardEffectType.Hei then
        local img = cardTran:GetComponent("UnityEngine.UI.Image")
        img.color = Color(0.7, 0.7, 0.7, 1)
    elseif effect == EqsCardDefine.SmallCardEffectType.Hong then
        local img = cardTran:GetComponent("UnityEngine.UI.Image")
        img.color = Color(1, 0.5, 0.5, 1)
    elseif effect == EqsCardDefine.SmallCardEffectType.Normal then
        local img = cardTran:GetComponent("UnityEngine.UI.Image")
        img.color = Color(1, 1, 1, 1)
    elseif effect == EqsCardDefine.SmallCardEffectType.SelectedHsz then
        selectedHsz.gameObject:SetActive(true)
    elseif effect == EqsCardDefine.SmallCardEffectType.ChangedHsz then
        changedHsz.gameObject:SetActive(true)
    end
end

function EqsCardsManager.DestroyCardComponent(tran)
    local group = tran:GetComponent("CanvasGroup")
    if group ~= nil then
        GameObject.DestroyImmediate(group)
    end
    local luaCmp = tran:GetComponent("LuaComponent")
    if luaCmp~= nil then
        GameObject.DestroyImmediate(luaCmp)
    end
    local uievent = tran:GetComponent("UIEventTriggerListener")
    if uievent ~= nil then
        GameObject.DestroyImmediate(uievent)
    end
end

function EqsCardsManager.recycleCardTran( tran )
    tran.localPosition = Vector3(10000,10000,0)
    local effect = tran:Find("ChuPaiEffect")
    effect.gameObject:SetActive(false)
    local id = EqsTools.GetEqsCardId(tran.gameObject.name)
    tran.gameObject.name = tostring(id)
    local cache = this.cacheCardTrans[id]
    if cache == nil then
        this.cacheCardTrans[id] = {}
        cache = this.cacheCardTrans[id]
    end
    
    this.DestroyCardComponent(tran)
   
    tran:SetParent(this.cardsParent)
    table.insert( cache, tran)
end

function EqsCardsManager.recycleSmallCardTran( tran )
    tran.localPosition = Vector3(10000,10000,0)
    this.SetSmallCardEffect(tran, EqsCardDefine.SmallCardEffectType.Null)
    local id = EqsTools.GetEqsCardId(tran.gameObject.name)
    tran.gameObject.name = tostring(id)
    local cache = this.cachesCardTrans[id]
    if cache == nil then
        this.cachesCardTrans[id] = {}
        cache = this.cachesCardTrans[id]
    end
    table.insert( cache, tran)
    tran:SetParent(this.sCardsParent)   
end
-- EqsCard对象
function EqsCardsManager.RecycleCard(eqsCard, anim)
    if eqsCard == nil or IsNull(eqsCard.transform) or eqsCard.transform.gameObject == nil or this.cardsParent == nil then
        LogWarn("回收牌错误：", eqsCard, eqsCard == nil, IsNull(eqsCard.transform), this.cardsParent == nil)
        return
    end
    eqsCard:CancelAllEffect()
    eqsCard.isChuPai = true
   if anim ~= nil and anim == true then
        eqsCard:SetLocation(0, 0)
        UIUtil.DOFade(eqsCard.transform, 0, 0.3):OnComplete(
            function()
                this.recycleCardTran(eqsCard.transform)
                eqsCard.transform = nil
            end
        )
   else
        eqsCard:SetLocation(0, 0)
        this.recycleCardTran(eqsCard.transform)
        eqsCard.transform = nil
   end
   eqsCard:UnscheduleGlobal(true)
end

function EqsCardsManager.RecycleSmallCard(cardTran, anim)
    local cardTran = cardTran
    if anim == true then
        UIUtil.DOFade(cardTran.transform, 0, 0.15):OnComplete(
            function()
                this.recycleSmallCardTran(cardTran)
            end
        )
    else
        this.recycleSmallCardTran(cardTran)
    end
end

function EqsCardsManager.RecycleCardTran(cardTran, anim)
    local cardTran = cardTran
    if anim == true then
        UIUtil.DOFade(cardTran.transform, 0, 0.15):OnComplete(
            function()
                this.recycleCardTran(cardTran)
            end
        )
    else
        this.recycleCardTran(cardTran)
    end
end
