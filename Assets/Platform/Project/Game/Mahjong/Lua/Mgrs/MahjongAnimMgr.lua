MahjongAnimMgr = {
}
local this = MahjongAnimMgr

--重置，用于房间重置
function MahjongAnimMgr.Reset()
    this.StopZhuangAnim()
    this.StopHuanAnim()
    this.StopHuPaiAnim()
end

--清除，用于退出房间
function MahjongAnimMgr.Clear()
    this.ClearZhuangAnim()
    this.ClearHuanAnim()
    this.StopHuPaiAnim()
end

--销毁，用于完全卸载
function MahjongAnimMgr.Destroy()
    this.ClearZhuangAnim()
    this.ClearHuanAnim()
end

--================================================================
--
--是否在播放庄动画
this.isPlayingZhuangAnim = false
--移动的对象
this.moveGO = nil
--移动的动画对象
this.moveTweener = nil
--动画的目标对象
this.targetGO = nil
--移动的图标的原坐标
this.moveMasterPosition = nil
--移动的目标世界坐标
this.targetPosition = nil
--DOTWEEN
this.zhuangMoveTweener = nil
--
--播放飞庄动画
function MahjongAnimMgr.PlayZhuangAnim(moveGO, moveMasterPosition, targetGO)
    if this.isPlayingZhuangAnim == true then
        return
    end

    this.isPlayingZhuangAnim = true
    this.moveGO = moveGO
    this.targetGO = targetGO
    this.moveMasterPosition = moveMasterPosition
    this.targetPosition = targetGO.transform.position
    this.moveTweener = this.moveGO:GetComponent("TweenPosition")
    this.moveTweener.enabled = false

    UIUtil.SetActive(this.moveGO, true)
    UIUtil.SetLocalPosition(this.moveGO, this.moveMasterPosition)

    this.StopZhuangAnimTweener()
    this.StopPlayZhuangAnimTimer()
    this.playZhuangAnimTimer = Timing.New(this.OnPlayZhuangAnimWaitCompleted, 0.4)
    this.playZhuangAnimTimer:Start()
end

--停止庄动画
function MahjongAnimMgr.StopZhuangAnim()
    this.isPlayingZhuangAnim = false
    this.StopPlayZhuangAnimTimer()
    this.StopZhuangAnimTweener()

    if this.moveGO ~= nil then
        UIUtil.SetActive(this.moveGO, false)
        this.moveTweener.enabled = false
    end
    this.moveGO = nil
    this.moveTweener = nil
    this.targetGO = nil
end

--清除庄动画相关数据
function MahjongAnimMgr.ClearZhuangAnim()
    this.StopZhuangAnim()
end

------------------------------------------------------------------
--
--等待播放动画完成
function MahjongAnimMgr.OnPlayZhuangAnimWaitCompleted()
    this.playZhuangAnimTimer:Stop()
    this.playZhuangAnimTimer = nil

    this.moveTweener:ResetToBeginning()
    this.moveTweener:PlayForward()
    this.moveTweener:AddLuaFinished(this.OnPlayZhuangPingPongCompleted)
end

--PingPong动画播放完成
function MahjongAnimMgr.OnPlayZhuangPingPongCompleted()

    this.moveTweener.enabled = false
    UIUtil.SetLocalPosition(this.moveGO, this.moveMasterPosition)

    --处理DOTWEEN
    this.StopZhuangAnimTweener()
    this.zhuangMoveTweener = this.moveGO.transform:DOMove(this.targetPosition, 0.5, false):OnComplete(this.OnPlayZhuangAnimMoveCompleted)

end

--飞庄DOTWEEN动画完成
function MahjongAnimMgr.OnPlayZhuangAnimMoveCompleted()
    this.zhuangMoveTweener = nil
    this.isPlayZhuangAnim = false
    if this.moveGO ~= nil then
        UIUtil.SetActive(this.moveGO, false)
        this.moveTweener.enabled = false
        UIUtil.SetActive(this.targetGO, true)
    end
    --
    this.isPlayingZhuangAnim = false
end

--停止庄的DOTWEEN动画
function MahjongAnimMgr.StopZhuangAnimTweener()
    if this.zhuangMoveTweener ~= nil then
        this.zhuangMoveTweener:Kill(false)
        this.zhuangMoveTweener = nil
    end
end

--停止飞庄Timer
function MahjongAnimMgr.StopPlayZhuangAnimTimer()
    if this.playZhuangAnimTimer ~= nil then
        this.playZhuangAnimTimer:Stop()
        this.playZhuangAnimTimer = nil
    end
end

--================================================================
--
--换牌动画相关
--是否在播放换牌动画
this.isPlayingHuanAnim = false
--骰子点数
this.dicePoint = 0
--玩家人数
this.playerTotal = 2
--换张数量
this.changeCardTotal = 3
--换牌的骰子动画
this.huanDice = nil
this.huanDiceImage = nil
this.huanDiceTweener = nil
this.huanDiceSpriteAnim = nil
--换牌使用的Timer
this.huanTimer = nil
--换牌旋转箭头使用的Timer
this.huanArrowTimer = nil
--换牌的旋转类型，0对家换，1顺时针，2逆时针
this.huanRotateType = 0
--换牌的特效
this.huanEffect = nil
--换牌的座位号
this.huanSeatIndexs = nil
--换牌的Sprite
this.huanSprites = nil
--换牌特效节点
this.huanEffectNode = nil
--换牌的麻将
this.huanMahjongItems = nil
--换牌的旋转显示对象存储
this.huanRotateItem = nil
--换牌总时间长
this.huanTotalTime = 0
--混换动画[name] = {gameobject = nil, armature = nil}
this.mixHuanAnims = {}


--播放换牌动画
function MahjongAnimMgr.PlayHuanAnim(dicePoint, changeCardType, playerTotal, changeCardTotal)
    if this.isPlayingHuanAnim == true then
        return
    end

    this.huanTotalTime = 0
    this.isPlayingHuanAnim = true
    this.dicePoint = dicePoint
    --处理骰子点数
    if this.dicePoint < 1 then
        this.dicePoint = 1
    elseif this.dicePoint > 6 then
        this.dicePoint = 6
    end
    --处理玩家人数
    if playerTotal == nil then
        this.playerTotal = MahjongDataMgr.playerTotal
    else
        this.playerTotal = playerTotal
    end

    --处理换张数量
    if changeCardTotal == nil then
        this.changeCardTotal = MahjongDataMgr.changeCardTotal
    else
        this.changeCardTotal = changeCardTotal
    end

    if changeCardType == MahjongChangeCardType.ArbitraryMix then
        this.PlayMixHuanAnim()
    else
        if IsNull(this.huanDice) then
            MahjongResourcesMgr.GetEffectPrefab("EffectOneDice", this.OnLoadDiceEffectCompleted)
        else
            this.PlayHuanDice()
        end
    end
end

--停止换牌动画，不会清除引用
function MahjongAnimMgr.StopHuanAnim()
    Log(">> Mahjong > MahjongAnimMgr.StopHuanAnim.")
    if this.huanAnimTimer ~= nil then
        this.huanAnimTimer:Stop()
    end
    this.isPlayingHuanAnim = false
    this.StopHuanTimer()
    this.StopHuanArrowTimer()
    --停止两端动画
    this.StopHuanDice()
    this.StopHuanStep2Anim()
    --
    this.CloseMixHuanAnim()
end

--清除换牌动画，需要停止动画，会直接清除引用
function MahjongAnimMgr.ClearHuanAnim()
    this.StopHuanAnim()

    --处理麻将牌和箭头动画
    this.huanEffect = nil
    this.huanSprites = nil
    this.huanEffectNode = nil
    this.huanMahjongItems = nil
    this.huanRotateItem = nil

    --处理骰子动画
    this.huanDice = nil
    this.huanDiceImage = nil
    this.huanDiceTweener = nil
    this.huanDiceSpriteAnim = nil

    --处理混换动画
    this.CloseMixHuanAnim()
end

--完成换牌动画，清除数据
function MahjongAnimMgr.CompleteHuanAnim()
    Log(">> Mahjong > MahjongAnimMgr.CompleteHuanAnim. > this.huanTotalTime = ", this.huanTotalTime)
    this.isPlayingHuanAnim = false
    this.StopHuanTimer()
    this.StopHuanArrowTimer()

    --处理麻将牌和箭头动画
    if this.huanEffect ~= nil then
        UIUtil.SetActive(this.huanEffect, false)
    end
    --处理骰子动画
    if this.huanDice ~= nil then
        UIUtil.SetActive(this.huanDice, false)
    end

    --关闭混换动画
    this.CloseMixHuanAnim()

    SendEvent(CMD.Game.Mahjong.ChangeCardAnimCompleted)
end

--加载骰子动画完成
function MahjongAnimMgr.OnLoadDiceEffectCompleted(prefab)
    if prefab == nil or MahjongRoomPanel == nil or MahjongRoomPanel.Instance == nil then
        this.CompleteHuanAnim()
        return
    end

    local parent = MahjongRoomPanel.Instance.GetEffectNode(0)
    if parent == nil then
        this.CompleteHuanAnim()
        return
    end
    if this.isPlayingHuanAnim == true then
        this.huanDice = CreateGO(prefab, parent, "Dice")
        UIUtil.SetRotation(this.huanDice, 0, 0, 0)
        this.PlayHuanDice()
    end
end

------------------------------------------------------------------
--播放骰子动画
function MahjongAnimMgr.PlayHuanDice()
    Log(">> Mahjong > ======== > MahjongAnimMgr.PlayHuanDice.")
    this.StopHuanDice()
    this.StopHuanTimer()

    UIUtil.SetActive(this.huanDice, true)
    this.OnHuanDiceSpriteAnimCompleted()

    --不再播放骰子动画 2021.12.28
    --等待0.2秒后才进行播放动画
    --this.huanTimer = Timing.New(this.OnWaitPlayHuanDiceCompleted, 0.2)
    --this.huanTimer:Start()
    --this.huanTotalTime = this.huanTotalTime + 0.2
end

--等待完成
function MahjongAnimMgr.OnWaitPlayHuanDiceCompleted()
    Log(">> Mahjong > ======== > MahjongAnimMgr.OnWaitPlayHuanDiceCompleted.")
    this.StopHuanTimer()
    if this.isPlayingHuanAnim == true then
        --播放声音
        MahjongAudioMgr.PlayDice()

        if this.huanDiceTweener == nil then
            this.huanDiceImage = this.huanDice:GetComponent(TypeImage)
            this.huanDiceTweener = this.huanDice:GetComponent("TweenPosition")
            this.huanDiceSpriteAnim = this.huanDice:GetComponent("UISpriteAnimation")
        end

        UIUtil.SetActive(this.huanDice, true)

        this.huanDiceTweener:ResetToBeginning()
        this.huanDiceTweener:PlayForward()
        this.huanDiceTweener:AddLuaFinished(this.OnHuanDiceTweenCompleted)
        this.huanTotalTime = this.huanTotalTime + 0.4
        this.huanDiceSpriteAnim.enabled = false
    end
end

--停止播放骰子动画
function MahjongAnimMgr.StopHuanDice()
    if this.huanDice ~= nil then
        UIUtil.SetActive(this.huanDice, false)
    end
end

--移动骰子完成，原地旋转骰子
function MahjongAnimMgr.OnHuanDiceTweenCompleted()
    Log(">> Mahjong > ======== > MahjongAnimMgr.OnHuanDiceTweenCompleted.")
    this.huanDiceSpriteAnim.enabled = true
    this.StopHuanTimer()
    if this.isPlayingHuanAnim == true then
        this.huanTimer = Timing.New(this.OnHuanDiceSpriteAnimCompleted, 1)
        this.huanTimer:Start()
        this.huanTotalTime = this.huanTotalTime + 1
    end
end

--原地旋转骰子动画完成，
function MahjongAnimMgr.OnHuanDiceSpriteAnimCompleted()
    Log(">> Mahjong > ======== > MahjongAnimMgr.OnHuanDiceSpriteAnimCompleted.")
    this.StopHuanTimer()
    this.huanDiceSpriteAnim = this.huanDiceSpriteAnim or this.huanDice:GetComponent("UISpriteAnimation")
    this.huanDiceSpriteAnim.enabled = false

    if this.isPlayingHuanAnim == true then
        this.huanDiceImage = this.huanDiceImage or this.huanDice:GetComponent(TypeImage)
        this.huanDiceImage.sprite = this.huanDiceSpriteAnim.sprites[-4 + this.dicePoint * 4]
        this.PlayHuanStep2Anim()
    end
end

------------------------------------------------------------------
--停止播放麻将的Timer
function MahjongAnimMgr.StopHuanTimer()
    if this.huanTimer ~= nil then
        this.huanTimer:Stop()
        this.huanTimer = nil
    end
end

--停止播放箭头的Timer
function MahjongAnimMgr.StopHuanArrowTimer()
    if this.huanArrowTimer ~= nil then
        this.huanArrowTimer:Stop()
        this.huanArrowTimer = nil
    end
end

------------------------------------------------------------------
--播放换牌的第二步骤动画
function MahjongAnimMgr.PlayHuanStep2Anim()
    --处理旋转类型
    if this.playerTotal == 2 then
        --两人换
        this.huanRotateType = MahjongHuanRotateType.Dui
        this.huanSeatIndexs = { 1, 3 }
    elseif this.playerTotal == 3 then
        --三人换
        if this.dicePoint == 1 or this.dicePoint == 2 or this.dicePoint == 3 then
            --顺时针
            this.huanRotateType = MahjongHuanRotateType.Shun
        else
            --逆时针
            this.huanRotateType = MahjongHuanRotateType.Ni
        end
        this.huanSeatIndexs = { 1, 2, 4 }
    elseif this.playerTotal == 4 then
        --四人换
        if this.dicePoint == 1 or this.dicePoint == 4 then
            --逆时针
            this.huanRotateType = MahjongHuanRotateType.Ni
        elseif this.dicePoint == 2 or this.dicePoint == 5 then
            --顺时针
            this.huanRotateType = MahjongHuanRotateType.Shun
        else
            --对家换
            this.huanRotateType = MahjongHuanRotateType.Dui
        end
        this.huanSeatIndexs = { 1, 2, 3, 4 }
    end

    if this.huanEffect == nil then
        MahjongResourcesMgr.GetEffectPrefab("EffectChangeCard", this.OnLoadHuanEffectCompleted)
    else
        this.PlayHuanEffect()
    end
end

--停止第二步动画
function MahjongAnimMgr.StopHuanStep2Anim()
    Log(">> Mahjong > ======== > MahjongAnimMgr.StopHuanStep2Anim.")
    this.StopHuanTimer()
    this.StopHuanArrowTimer()
    if this.huanEffect ~= nil then
        UIUtil.SetActive(this.huanEffect, false)
    end
end

--加载换牌特效完成
function MahjongAnimMgr.OnLoadHuanEffectCompleted(prefab)
    if prefab == nil or MahjongRoomPanel == nil or MahjongRoomPanel.Instance == nil then
        this.CompleteHuanAnim()
        return
    end

    local parent = MahjongRoomPanel.Instance.GetEffectNode(0)
    if parent == nil then
        this.CompleteHuanAnim()
        return
    end

    if this.isPlayingHuanAnim == true then
        this.huanEffect = CreateGO(prefab, parent, "HuanEffect")
        UIUtil.SetAnchoredPosition(this.huanEffect, 0, 0)
        this.PlayHuanEffect()
    end
end

--播放换特效
function MahjongAnimMgr.PlayHuanEffect()
    Log(">> Mahjong > ======== > MahjongAnimMgr.PlayHuanEffect.")
    if this.huanEffect ~= nil then

        UIUtil.SetActive(this.huanEffect, true)

        local trans = this.huanEffect.transform

        if this.huanSprites == nil then
            local atlas = trans:Find("Sprites"):GetComponent("UISpriteAtlas")
            this.SetHuanSprites(atlas.sprites)
        end

        local tipsTrans = trans:Find("Tips")
        local tipsImage = tipsTrans:GetComponent(TypeImage)
        tipsImage.sprite = this.huanSprites["HuanR" .. this.huanRotateType]
        tipsImage:SetNativeSize()
        local tweener = tipsTrans:GetComponent("TweenAlpha")
        tweener:ResetToBeginning()
        tweener:PlayForward()

        this.huanEffectNode = trans:Find("Player" .. this.playerTotal)
        UIUtil.SetActive(this.huanEffectNode.gameObject, true)
        --
        this.PlayHuanMahjongAnim()
        this.PlayHuanArrowAnim()
    end
end

function MahjongAnimMgr.SetHuanSprites(sprites)
    local tempSprites = sprites:ToTable()
    this.huanSprites = {}
    local sprite = nil
    for i = 1, #tempSprites do
        sprite = tempSprites[i]
        if sprite ~= nil then
            this.huanSprites[sprite.name] = sprite
        else
            LogWarn(">> MahjongAnimMgr.SetHuanSprites > sprite == nil > index = " .. i)
        end
    end
end

--停止播放换特效
function MahjongAnimMgr.StopHuanEffect()

    this.StopHuanTimer()
    this.StopHuanArrowTimer()

    if this.huanEffectNode ~= nil then
        UIUtil.SetActive(this.huanEffectNode.gameObject, false)
        this.huanEffectNode = nil
    end

    if this.huanEffect ~= nil then
        UIUtil.SetActive(this.huanEffect, false)
    end
end

------------------------------------------------------------------
--播放换牌麻将相关动画
function MahjongAnimMgr.PlayHuanMahjongAnim()
    Log(">> Mahjong > ======== > MahjongAnimMgr.PlayHuanMahjongAnim.")
    this.huanMahjongItems = {}

    local item = nil
    local key = nil
    local index = nil
    local spriteName = nil
    local image = nil
    local tweener = nil
    for i = 1, #this.huanSeatIndexs do
        key = this.huanSeatIndexs[i]

        item = {}
        this.huanMahjongItems[key] = item
        item.transform = this.huanEffectNode:Find(tostring(key))
        item.gameObject = item.transform.gameObject

        -- index = 1
        -- if key == 2 or key == 4 then
        --     index = 2
        -- end
        --设置麻将的图片
        spriteName = tostring(this.changeCardTotal) .. "_" .. key
        image = item.gameObject:GetComponent(TypeImage)
        image.sprite = this.huanSprites[spriteName]
        image:SetNativeSize()

        tweener = item.gameObject:GetComponent("TweenAlpha")
        tweener:PlayForward()
        tweener:ResetToBeginning()
        item.tweenAlpha = tweener

        tweener = item.gameObject:GetComponent("TweenPosition")
        tweener:PlayForward()
        tweener:ResetToBeginning()
        item.tweenPosition = tweener

        UIUtil.SetActive(item.gameObject, true)
    end

    this.StopHuanTimer()
    this.huanTimer = Timing.New(this.OnPlayHuanMahjongAnimStep2, 2.1)
    this.huanTimer:Start()
    this.huanTotalTime = this.huanTotalTime + 2.1
end

--播放换牌麻将动画第二步骤，移动
function MahjongAnimMgr.OnPlayHuanMahjongAnimStep2()
    Log(">> Mahjong > ======== > MahjongAnimMgr.OnPlayHuanMahjongAnimStep2.")
    this.StopHuanTimer()

    if this.isPlayingHuanAnim and this.huanMahjongItems ~= nil then

        local config = MahjongHuanEffectConfig[this.playerTotal][this.huanRotateType]

        if config == nil then
            this.CompleteHuanAnim()
            return
        end

        local item = nil
        local key = nil
        local v3 = nil
        for i = 1, #this.huanSeatIndexs do
            key = this.huanSeatIndexs[i]
            item = this.huanMahjongItems[key]
            v3 = config[key]
            if v3 ~= nil then
                item.transform:DOLocalMove(v3, 0.5, false)
            end
            item.tweenAlpha:PlayReverse()
        end

        this.huanTimer = Timing.New(this.OnPlayHuanMahjongAnimCompleted, 0.7)
        this.huanTimer:Start()
        this.huanTotalTime = this.huanTotalTime + 0.7
    end
end

--完成
function MahjongAnimMgr.OnPlayHuanMahjongAnimCompleted()
    Log(">> Mahjong > ======== > MahjongAnimMgr.OnPlayHuanMahjongAnimCompleted.")
    this.StopHuanTimer()
    this.CompleteHuanAnim()
end

------------------------------------------------------------------
--播放箭头动画
function MahjongAnimMgr.PlayHuanArrowAnim()
    this.huanRotateItem = {}
    local arrowTrans = this.huanEffect.transform:Find("Arrow")
    if arrowTrans ~= nil then
        this.huanRotateItem.arrowNode = arrowTrans.gameObject
        UIUtil.SetActive(this.huanRotateItem.arrowNode, true)
        this.huanRotateItem.arrow1 = arrowTrans:Find("Arrow1").gameObject
        this.huanRotateItem.arrow2 = arrowTrans:Find("Arrow2").gameObject
        UIUtil.SetActive(this.huanRotateItem.arrow1, false)
        UIUtil.SetActive(this.huanRotateItem.arrow2, false)
        this.huanRotateItem.arrow3 = arrowTrans:Find("Arrow3").gameObject
        UIUtil.SetActive(this.huanRotateItem.arrow3, false)
        this.huanRotateItem.arrow4 = arrowTrans:Find("Arrow4").gameObject
        UIUtil.SetActive(this.huanRotateItem.arrow4, false)
    end
    --
    this.StopHuanArrowTimer()
    this.huanArrowTimer = Timing.New(this.OnPlayHuanArrowAnimWait, 0.5)
    this.huanArrowTimer:Start()
end

--等待播放
function MahjongAnimMgr.OnPlayHuanArrowAnimWait()
    this.StopHuanArrowTimer()
    if this.isPlayingHuanAnim and this.huanRotateItem ~= nil and this.huanRotateItem.arrow1 ~= nil then

        local tweener = nil
        local v3 = nil
        if this.huanRotateType == MahjongHuanRotateType.Dui then
            --对家换包括2,4人都有
            UIUtil.SetActive(this.huanRotateItem.arrow1, true)
            UIUtil.SetActive(this.huanRotateItem.arrow2, true)

            tweener = this.huanRotateItem.arrow1:GetComponent("TweenPosition")
            tweener:ResetToBeginning()
            tweener:PlayForward()
            tweener = this.huanRotateItem.arrow2:GetComponent("TweenPosition")
            tweener:ResetToBeginning()
            tweener:PlayForward()
        elseif this.huanRotateType == MahjongHuanRotateType.Shun then
            --顺时针包括3,4人都有
            if this.playerTotal == 3 then
                UIUtil.SetActive(this.huanRotateItem.arrow3, true)
                tweener = this.huanRotateItem.arrow3:GetComponent("TweenRotation")
                UIUtil.SetLocalScale(this.huanRotateItem.arrow3, -1, 1, 1)
                v3 = { x = 0, y = 0, z = -125 }--加5个度数进行动画优化
            else
                UIUtil.SetActive(this.huanRotateItem.arrow4, true)
                tweener = this.huanRotateItem.arrow4:GetComponent("TweenRotation")
                UIUtil.SetLocalScale(this.huanRotateItem.arrow4, -1, 1, 1)
                v3 = { x = 0, y = 0, z = -95 }
            end
            tweener.to = v3
            tweener:ResetToBeginning()
            tweener:PlayForward()
        else
            --逆时针包括3,4人都有
            if this.playerTotal == 3 then
                UIUtil.SetActive(this.huanRotateItem.arrow3, true)
                tweener = this.huanRotateItem.arrow3:GetComponent("TweenRotation")
                UIUtil.SetLocalScale(this.huanRotateItem.arrow3, 1, 1, 1)
                v3 = { x = 0, y = 0, z = 125 }
            else
                UIUtil.SetActive(this.huanRotateItem.arrow4, true)
                tweener = this.huanRotateItem.arrow4:GetComponent("TweenRotation")
                UIUtil.SetLocalScale(this.huanRotateItem.arrow4, 1, 1, 1)
                v3 = { x = 0, y = 0, z = 95 }
            end
            tweener.to = v3
            tweener:ResetToBeginning()
            tweener:PlayForward()
        end

        if tweener ~= nil then
            tweener:AddLuaFinished(this.OnPlayHuanArrowAnimCompleted)
        end
    end
end

--播放换张箭头
function MahjongAnimMgr.OnPlayHuanArrowAnimCompleted()
    if this.huanRotateItem ~= nil then
        UIUtil.SetActive(this.huanRotateItem.arrowNode, false)
        this.huanRotateItem = nil
    end
end
------------------------------------------------------------------
--播放混换动画
function MahjongAnimMgr.PlayMixHuanAnim()
    if this.changeCardTotal == 4 then
        this.StartPlayMixHuanAnim("MahjongHuanAnim4")
    else
        this.StartPlayMixHuanAnim("MahjongHuanAnim3")
    end
end

--开始播放混换动画
function MahjongAnimMgr.StartPlayMixHuanAnim(name)
    local mixHuanAnim = this.mixHuanAnims[name]
    if mixHuanAnim == nil or IsNull(mixHuanAnim.gameObject) then
        MahjongResourcesMgr.GetEffectPrefab(name, this.OnLoadMixHuanAnimCompleted, name)
    else
        this.PlayMixHuanAnimByEffect(mixHuanAnim)
    end
end

--加载混换动画完成
function MahjongAnimMgr.OnLoadMixHuanAnimCompleted(prefab, name)
    if prefab == nil or MahjongRoomPanel == nil or MahjongRoomPanel.Instance == nil then
        this.CompleteHuanAnim()
        return
    end

    local parent = MahjongRoomPanel.Instance.GetEffectNode(0)
    if parent == nil then
        this.CompleteHuanAnim()
        return
    end

    if this.isPlayingHuanAnim == true then
        local go = CreateGO(prefab, parent, name)
        local mixHuanAnim = {}
        mixHuanAnim.gameObject = go
        this.mixHuanAnims[name] = mixHuanAnim
        UIUtil.SetLocalPosition(go, 0, 0, 0)
        this.PlayMixHuanAnimByEffect(mixHuanAnim)
    end
end

function MahjongAnimMgr.PlayMixHuanAnimByEffect(mixHuanAnim)
    UIUtil.SetActive(mixHuanAnim.gameObject, true)
    -- if mixHuanAnim.armature == nil then
    --     mixHuanAnim.armature = mixHuanAnim.gameObject.transform:Find("Armature"):GetComponent("UnityArmatureComponent")
    --     DragonBonesUtil.AddEventListener(mixHuanAnim.armature, DragonBonesEventObject.COMPLETE, this.OnPlayMixHuanAnim)
    -- end
    -- DragonBonesUtil.Play(mixHuanAnim.armature, "anim" .. this.playerTotal, 1)
    local item = mixHuanAnim.gameObject.transform:GetComponent(TypeSkeletonGraphic)
    local animName = this.changeCardTotal == 4 and "4" or "3"
    local temp = item.SkeletonData:FindAnimation(animName)
    if temp ~= nil then
        item.AnimationState:SetAnimation(0, animName, false)
    end

    if this.huanAnimTimer == nil then
        this.huanAnimTimer = Timing.New(
            function ()
                this.huanAnimTimer:Stop()
                this.OnPlayMixHuanAnim()
            end
        , 1.7)
    end
    this.huanAnimTimer:Start()
end

--龙骨动画播放完成
function MahjongAnimMgr.OnPlayMixHuanAnim()
    --Log(">> Mahjong > MahjongAnimMgr.OnPlayMixHuanAnim.")
    this.CompleteHuanAnim()
end

--关闭所有的混换动画
function MahjongAnimMgr.CloseMixHuanAnim()
    for k, v in pairs(this.mixHuanAnims) do
        -- if v.armature ~= nil then
        --     DragonBonesUtil.Stop(v.armature)
        -- end
        if v.gameObject ~= nil then
            UIUtil.SetActive(v.gameObject, false)
        end
    end
end


--================================================================
--胡牌动画相关
this.huPaiAnimItemDicts = {}
--胡牌动画父节点
this.huPaiAnimParent = nil
--胡牌动画坐在方位
this.huPaiAnimSeatIndex = 0
--当前已胡牌玩家方位
this.huPaiSeatIndexDicts = {}

--播放胡牌动画
function MahjongAnimMgr.StopHuPaiAnim()
    this.huPaiAnimParent = nil
    this.huPaiAnimSeatIndex = 0
    this.huPaiSeatIndexDicts = {}
    for k, v in pairs(this.huPaiAnimItemDicts) do
        if v.gameObject ~= nil then
            UIUtil.SetActive(v.gameObject, false)
        end
    end
end

--播放胡牌动画
function MahjongAnimMgr.PlayHuPaiAnim(parent, seatIndex)
    if this.huPaiSeatIndexDicts[seatIndex] ~= nil then
        return
    end
    this.huPaiSeatIndexDicts[seatIndex] = true
    this.huPaiAnimParent = parent
    this.huPaiAnimSeatIndex = seatIndex
    
    if this.huPaiAnimItemDicts[seatIndex] == nil then
        MahjongResourcesMgr.GetEffectPrefab("EffectHuPai", this.OnLoadHuPaiAnimCompleted, "EffectHuPai")
    else
        this.PlayHuPaiAnimByEffect()
    end
end


--加载混换动画完成
function MahjongAnimMgr.OnLoadHuPaiAnimCompleted(prefab, name)
    if prefab == nil or this.huPaiAnimParent == nil then
        return
    end
    this.huPaiAnimItemDicts[this.huPaiAnimSeatIndex] = CreateGO(prefab, this.huPaiAnimParent, name)
    this.PlayHuPaiAnimByEffect()
end

function MahjongAnimMgr.PlayHuPaiAnimByEffect()
    local config = MahjongHuCardEffectsConfigDicts[this.huPaiAnimSeatIndex]
    if this.huPaiAnimParent == nil or this.huPaiAnimParent == nil or config == nil then
        return
    end

    this.huPaiAnimItemDicts[this.huPaiAnimSeatIndex].transform:SetParent(this.huPaiAnimParent)
    this.huPaiAnimItemDicts[this.huPaiAnimSeatIndex].transform.localScale = Vector3(config.scale, config.scale, 1)
    UIUtil.SetAnchoredPosition(this.huPaiAnimItemDicts[this.huPaiAnimSeatIndex], config.posX, config.posY)

    UIUtil.SetActive(this.huPaiAnimItemDicts[this.huPaiAnimSeatIndex].gameObject, true)
    local item = this.huPaiAnimItemDicts[this.huPaiAnimSeatIndex].gameObject.transform:GetComponent(TypeSkeletonGraphic)
    local temp = item.SkeletonData:FindAnimation("animation")
    if temp ~= nil then
        item.AnimationState:SetAnimation(0, "animation", false)
    end
end