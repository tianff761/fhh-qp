MahjongEffectMgr = {
    --特效对象，玩家有座位的需要座位号_特效名称来组合字串
    effectItems = {},
}

local this = MahjongEffectMgr

------------------------------------------------------------------
--
--麻将特效名称
MahjongEffectMgr.EffectName = {
    GangShangHua = "EffectGangShangHua",
    GangShangPao = "EffectGangShangPao",
    Tornado = "EffectTornado",
    LiuJu = "EffectLiuJu",

    --新换特效资源
    Hu = "EffectHu",
    ZiMo = "EffectZiMo",
    Gang = "EffectGang",
    Peng = "EffectPeng",
    TianHu = "EffectHu_TianHu",
    DiHu = "EffectHu_DiHu",
    HaiDiLao = "Effect_HaiDiLao", --暂时没特效资源
    HaiDiPao = "Effect_HaiDiPao", --暂时没特效资源
    QingYiSe = "EffectHu_QingYiSe",
    LongQiDui = "EffectHu_LongQiDui",
    AnQiDui = "EffectHu_AnQiDui",
    JinGouGou = "EffectHu_JinGouGou",
}

--清除，用于退出房间
function MahjongEffectMgr.Clear()
    this.StopAllEffect()
end

--销毁，用于完全卸载
function MahjongEffectMgr.Destroy()
    this.effectItems = {}
end

--停止所有特效播放，用于退出房间
function MahjongEffectMgr.StopAllEffect()
    for k, v in pairs(this.effectItems) do
        if v ~= nil and v.gameObject ~= nil then
            UIUtil.SetActive(v.gameObject, false)
        end
    end

    --this.StopDice()
end

------------------------------------------------------------------
--操作相关
--麻将操作映射
MahjongEffectMgr.OperateEffectMap = {
    [MahjongOperateCode.PENG] = MahjongEffectMgr.EffectName.Peng,
    [MahjongOperateCode.SPC_PENG] = MahjongEffectMgr.EffectName.Peng,
    [MahjongOperateCode.GANG] = MahjongEffectMgr.EffectName.Gang,
    [MahjongOperateCode.GANG_IN] = MahjongEffectMgr.EffectName.Gang,
    --暗杠
    [MahjongOperateCode.GANG_ALL_IN] = MahjongEffectMgr.EffectName.Tornado,
    [MahjongOperateCode.SPC_GANG] = MahjongEffectMgr.EffectName.Gang,
    [MahjongOperateCode.SPC_GANG_IN] = MahjongEffectMgr.EffectName.Gang,
    --幺鸡暗杠
    [MahjongOperateCode.SPC_GANG_ALL_IN] = MahjongEffectMgr.EffectName.Tornado,
    --胡牌
    [MahjongOperateCode.HU] = MahjongEffectMgr.EffectName.Hu,
    [MahjongOperateCode.HU_ZI_MO] = MahjongEffectMgr.EffectName.ZiMo,
    [MahjongOperateCode.HU_GANG_SHANG_HUA] = MahjongEffectMgr.EffectName.GangShangHua,
    [MahjongOperateCode.HU_GANG_SHANG_PAO] = MahjongEffectMgr.EffectName.GangShangPao,
    [MahjongOperateCode.HU_QIANG_GANG] = MahjongEffectMgr.EffectName.Hu,

    [MahjongOperateCode.HU_TIAN_HU] = MahjongEffectMgr.EffectName.TianHu,
    [MahjongOperateCode.HU_DI_HU] = MahjongEffectMgr.EffectName.DiHu,
    [MahjongOperateCode.HU_HAI_DI_LAO] = MahjongEffectMgr.EffectName.HaiDiLao,
    [MahjongOperateCode.HU_HAI_DI_PAO] = MahjongEffectMgr.EffectName.HaiDiPao,
    [MahjongOperateCode.HU_QING_YI_SE] = MahjongEffectMgr.EffectName.QingYiSe,
    [MahjongOperateCode.HU_LONG_QI_DUI] = MahjongEffectMgr.EffectName.LongQiDui,
    [MahjongOperateCode.HU_AN_QI_DUI] = MahjongEffectMgr.EffectName.AnQiDui,
    [MahjongOperateCode.HU_JIN_GOU_GOU] = MahjongEffectMgr.EffectName.JinGouGou,
}


MahjongEffectMgr.EffectAnimNameMap = {
    [MahjongEffectMgr.EffectName.Peng] = "YH_peng",
    [MahjongEffectMgr.EffectName.Gang] = "YH_gang",
    [MahjongEffectMgr.EffectName.Tornado] = "YH_gang",
    [MahjongEffectMgr.EffectName.GangShangHua] = "YH_gangshanghua",
    [MahjongEffectMgr.EffectName.GangShangPao] = "YH_gangshangpao",
    [MahjongEffectMgr.EffectName.Hu] = "YH_hu",
    [MahjongEffectMgr.EffectName.ZiMo] = "YH_zimo",
}

--检测是否有操作特效
function MahjongEffectMgr.CheckIsOperateEffect(operateCode)
    return MahjongEffectMgr.OperateEffectMap[operateCode] ~= nil
end

--播放操作特效
function MahjongEffectMgr.PlayOperateEffect(operateCode, seatIndex, isHu)
    local effectName = MahjongEffectMgr.OperateEffectMap[operateCode]
    if effectName ~= nil then
        local tempSeatIndex = seatIndex
        if operateCode == MahjongOperateCode.HU_GANG_SHANG_HUA or operateCode == MahjongOperateCode.HU_GANG_SHANG_PAO then
            tempSeatIndex = 0
        end
        MahjongEffectMgr.PlayEffect(effectName, tempSeatIndex, isHu, operateCode)
    end
end

------------------------------------------------------------------
--
--播放特效
function MahjongEffectMgr.PlayEffect(effectName, seatIndex, isHu, operateCode)
    --Log(">> MahjongEffectMgr.PlayEffect > ", effectName)
    local key = effectName
    if seatIndex ~= 0 and operateCode <= 1002 then
        key = tostring(seatIndex) .. "_" .. effectName
    end

    local item = this.effectItems[key]
    if item ~= nil then
        this.InternalPlayEffect(item, isHu)
    else
        local arg = { key = key, effectName = effectName, seatIndex = seatIndex, isHu = isHu, operateCode = operateCode}
        MahjongResourcesMgr.GetEffectPrefab(effectName, this.OnLoadEffectCompleted, arg)
    end
end

--特效加载完成
function MahjongEffectMgr.OnLoadEffectCompleted(prefab, arg)

    --Log(">> MahjongEffectMgr.OnLoadEffectCompleted > ================ > MahjongEffectMgr.OnLoadEffectCompleted", arg)

    if arg == nil or MahjongRoomPanel == nil or MahjongRoomPanel.Instance == nil then
        return
    end
    local parent = nil
    --特殊胡牌特效通过特殊胡牌特效面板播放
    if arg.operateCode ~= nil and arg.operateCode > 1002 then
        if MahjongHuEffectPanel == nil or MahjongHuEffectPanel.Instance == nil then
            LogError("MahjongHuEffectPanel 面板为空")
            return
        end
        parent = MahjongHuEffectPanel.Instance.GetEffectNode()
    else
        parent = MahjongRoomPanel.Instance.GetEffectNode(arg.seatIndex, arg.operateCode)
    end

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
    item.operateCode = arg.operateCode
    this.InternalPlayEffect(item, arg.isHu)
end

--播放单个特效
function MahjongEffectMgr.InternalPlayEffect(item, isHu)
    UIUtil.SetActive(item.gameObject, true)
    --流局特效特殊处理
    if item.effectName == MahjongEffectMgr.EffectName.LiuJu then
        if item.spineAnim == nil then
            item.spineAnim = item.gameObject:GetComponentInChildren(TypeSkeletonGraphic)
            if item.spineAnim ~= nil then
                local temp = item
                item.spineAnim.AnimationState.Complete = item.spineAnim.AnimationState.Complete + function() this.OnLiuJuEffectPlayCompleted(temp) end
            end
        end
        if item.spineAnim ~= nil then
            this.PlaySpineAnim(item.spineAnim, "animation", false)
        end
    else
        local animName = MahjongEffectMgr.EffectAnimNameMap[item.effectName]
        --特殊胡牌特效
        if item.operateCode > 1002 then
            animName = "animation"
            if MahjongHuEffectPanel ~= nil and MahjongHuEffectPanel.Instance ~= nil then
                MahjongHuEffectPanel.Instance.SetEffectItem(item)
            end
        end
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
                this.PlaySpineAnim(item.spineAnim, animName, false)
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

--播放Spine动画
function MahjongEffectMgr.PlaySpineAnim(anim, animName, loop)
    local temp = anim.SkeletonData:FindAnimation(animName)
    if temp ~= nil then
        anim.AnimationState:SetAnimation(0, animName, loop)
    end
end

function MahjongEffectMgr.OnPlayFinish(gameObject)
    UIUtil.SetActive(gameObject, false)
end


function MahjongEffectMgr.OnEffectPlayCompleted(item)
    UIUtil.SetActive(item.gameObject, false)
end

--胡牌动画播放完成回调，现在使用的是有新Hu时使用Timer处理
function MahjongEffectMgr.OnHuEffectPlayCompleted(item)
    item.spineAnim.AnimationState:ClearTracks();
    UIUtil.SetActive(item.gameObject, false)
    if item.operateCode > 1002 or PanelManager.IsOpened(MahjongPanelConfig.HuEffect) then
        PanelManager.Close(MahjongPanelConfig.HuEffect)
    end
end

--流局特效播放完成
function MahjongEffectMgr.OnLiuJuEffectPlayCompleted(item)
    UIUtil.SetActive(item.gameObject, false)
    SendEvent(CMD.Game.Mahjong.LiuJuEffectFinished)
end

return MahjongEffectMgr