TpEffectMgr = {
    --特效对象，玩家有座位的需要座位号_特效名称来组合字串
    effectItems = {},
}

local this = TpEffectMgr

------------------------------------------------------------------
--

--清除，用于退出房间
function TpEffectMgr.Clear()
    this.StopAllEffect()
end

--销毁，用于完全卸载
function TpEffectMgr.Destroy()
    this.effectItems = {}
end

--停止所有特效播放，用于退出房间
function TpEffectMgr.StopAllEffect()
    for k, v in pairs(this.effectItems) do
        if v ~= nil and v.gameObject ~= nil then
            UIUtil.SetActive(v.gameObject, false)
        end
    end

    --this.StopDice()
end

------------------------------------------------------------------
--操作相关
--操作映射
TpEffectMgr.OperateEffectMap = {
}

TpEffectMgr.EffectAnimNameMap = {
}

--检测是否有操作特效
function TpEffectMgr.CheckIsOperateEffect(operateCode)
    return TpEffectMgr.OperateEffectMap[operateCode] ~= nil
end

--播放操作特效
function TpEffectMgr.PlayOperateEffect(operateCode, seatIndex, isHu)
    local effectName = TpEffectMgr.OperateEffectMap[operateCode]
    if effectName ~= nil then
        local tempSeatIndex = seatIndex
        if operateCode == TpOperateCode.HU_GANG_SHANG_HUA or operateCode == TpOperateCode.HU_GANG_SHANG_PAO then
            tempSeatIndex = 0
        end
        TpEffectMgr.PlayEffect(effectName, tempSeatIndex, isHu)
    end
end

------------------------------------------------------------------
--
--播放特效
function TpEffectMgr.PlayEffect(effectName, seatIndex, isHu)
    --Log(">> TpEffectMgr.PlayEffect > ", effectName)
    local key = effectName
    if seatIndex ~= 0 then
        key = tostring(seatIndex) .. "_" .. effectName
    end

    local item = this.effectItems[key]
    if item ~= nil then
        this.InternalPlayEffect(item, isHu)
    else
        local arg = { key = key, effectName = effectName, seatIndex = seatIndex, isHu = isHu }
        TpResourcesMgr.GetEffectPrefab(effectName, this.OnLoadEffectCompleted, arg)
    end
end

--特效加载完成
function TpEffectMgr.OnLoadEffectCompleted(prefab, arg)

    --Log(">> TpEffectMgr.OnLoadEffectCompleted > ================ > TpEffectMgr.OnLoadEffectCompleted", arg)

    if arg == nil or TpRoomPanel == nil or TpRoomPanel.Instance == nil then
        return
    end

    local parent = TpRoomPanel.Instance.GetEffectNode(arg.seatIndex)

    if parent == nil then
        return
    end

    local item = this.effectItems[arg.key]
    if item == nil then
        item = {}
        item.gameObject = CreateGO(prefab, parent, arg.key)
        this.effectItems[arg.key] = item
        UIUtil.SetAnchoredPosition(item.gameObject, 0, 0)
        UIUtil.SetRotation(item.gameObject, 0, 0, 0)
    end
    item.key = arg.key
    item.effectName = arg.effectName
    this.InternalPlayEffect(item, arg.isHu)
end

--播放单个特效
function TpEffectMgr.InternalPlayEffect(item, isHu)
    UIUtil.SetActive(item.gameObject, true)
    --流局特效特殊处理
    if item.effectName == TpEffectName.LiuJu then
        if item.spineAnim == nil then
            item.spineAnim = item.gameObject:GetComponentInChildren(TypeSkeletonGraphic)
            if item.spineAnim ~= nil then
                local temp = item
                item.spineAnim.AnimationState.Complete = item.spineAnim.AnimationState.Complete + function() this.OnLiuJuEffectPlayCompleted(temp) end
            end
        end
        if item.spineAnim ~= nil then
            this.PlayTpeAnim(item.spineAnim, "animation", false)
        end
    else
        local animName = TpEffectMgr.EffectAnimNameMap[item.effectName]
        if animName ~= nil then
            if item.spineAnim == nil then
                item.spineAnim = item.gameObject:GetComponentInChildren(TypeSkeletonGraphic)
                if item.spineAnim ~= nil then
                    local temp = item
                    if isHu then
                        item.spineAnim.AnimationState.Complete = item.spineAnim.AnimationState.Complete + function() this.OnHuEffectPlayCompleted(temp) end
                    else
                        item.spineAnim.AnimationState.Complete = item.spineAnim.AnimationState.Complete + function() this.OnEffectPlayCompleted(temp) end
                    end
                end
            end
            if item.spineAnim ~= nil then
                this.PlayTpeAnim(item.spineAnim, animName, false)
            end
        else
            if item.spriteAnimation == nil then
                item.spriteAnimation = item.gameObject:GetComponent("UISpriteAnimation")
            end
            if item.spriteAnimation then
                if isHu then
                    item.spriteAnimation.onCompleted = this.OnHuEffectPlayCompleted
                else
                    item.spriteAnimation.onCompleted = nil
                end
                item.spriteAnimation:Replay()
            else
                --Scheduler.unscheduleGlobal(this.closeSchedule)
                this.closeSchedule = coroutine.start(function()
                    coroutine.wait(1.333)
                    UIUtil.SetActive(item.gameObject, false)
                end)
            end
        end
    end
end

--播放Tpe动画
function TpEffectMgr.PlayTpeAnim(anim, animName, loop)
    local temp = anim.SkeletonData:FindAnimation(animName)
    if temp ~= nil then
        anim.AnimationState:SetAnimation(0, animName, loop)
    end
end

function TpEffectMgr.OnPlayFinish(gameObject)
    UIUtil.SetActive(gameObject, false)
end


function TpEffectMgr.OnEffectPlayCompleted(item)
    UIUtil.SetActive(item.gameObject, false)
end

--胡牌动画播放完成回调，现在使用的是有新Hu时使用Timer处理
function TpEffectMgr.OnHuEffectPlayCompleted(item)
    UIUtil.SetActive(item.gameObject, false)
end

--流局特效播放完成
function TpEffectMgr.OnLiuJuEffectPlayCompleted(item)
    UIUtil.SetActive(item.gameObject, false)
    SendEvent(CMD.Game.Tp.LiuJuEffectFinished)
end

return TpEffectMgr