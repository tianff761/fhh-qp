PdkEffectCtrl = {}
local this = PdkEffectCtrl
local effectsAnimationAsset = {}

PdkEffectCtrl.airplaneGO = nil

--跑得快特效配置
PdkEffectCtrl.EffectConfig = {
    -- [PdkPokerType.Three] = "3dai0",
    --[PdkPokerType.Three] = {name = "PdkEff", animation = "3zhang", count = 1},
    --[PdkPokerType.ThreeAndOne] = {name = "PdkEff", animation = "3-1", count = 1},
    --[PdkPokerType.ThreeAndTwo] = {name = "PdkEff", animation = "3-2", count = 1},
    [PdkPokerType.Straight] = {name = "ShunZi", animation = "animation", count = 1},
    [PdkPokerType.DoubleStraight] = {name = "LianDui", animation = "animation", count = 1},
    [PdkPokerType.Airplane] = {name = "PdkEff", animation = "feiji", count = 1},
    -- [PdkPokerType.AirplaneAndOne] = {name = "Airplane", animation = "newAnimation", count = 1},
    -- [PdkPokerType.AirplaneAndTwo] = {name = "Airplane", animation = "newAnimation", count = 1},
    [PdkPokerType.Bomb] = {name = "Bomb", animation = "play", count = 1},
    --[PdkPokerType.BombAndDouble] = {name = "PdkEff", animation = "4-2", count = 1},
    --[PdkPokerType.BombAndThree] = {name = "PdkEff", animation = "4-3", count = 1},
    [PdkPokerType.Four] = {name = "PdkEff", animation = "sizhang", count = 1},
    ["BaoDan"] = {name = "BaoDan", animation = "animation", count = -1}
}

--注册用的事件
local DragonBonesEventObject = {
    -- 动画开始播放。
    START = "start",
    -- 动画循环播放完成一次
    LOOP_COMPLETE = "loopComplete",
    -- 动画播放完成
    COMPLETE = "complete",
    -- 动画淡入开始
    FADE_IN = "fadeIn",
    -- 动画淡入完成
    FADE_IN_COMPLETE = "fadeInComplete",
    -- 动画淡出开始
    FADE_OUT = "fadeOut",
    -- 动画淡出完成
    FADE_OUT_COMPLETE = "fadeOutComplete",
    -- 动画帧事件
    FRAME_EVENT = "frameEvent",
    -- 动画帧声音事件
    SOUND_EVENT = "soundEvent"
}

--加载道具资源
function PdkEffectCtrl.LoadAssetByEffectName(name)
    if effectsAnimationAsset[name] == nil then
        local asset = ResourcesManager.LoadPrefabBySynch(PdkBundleName.Effect, name)
        if not IsNil(asset) then
            effectsAnimationAsset[name] = asset
        else
            Log(">>>>>>>>>>>>>> PdkEffectCtrl > LoadAssetByEffectName > 加载资源不存在")
        end
    end
    return effectsAnimationAsset[name]
end

--播放特效
function PdkEffectCtrl.PlayEffect(cardType, parent, index)
    if PdkEffectCtrl.EffectConfig[cardType] == nil then
        return
    end
    local isOld = Functions.IsOldVerApp()
    if cardType == PdkPokerType.Airplane and not isOld then
        this.PlayAirplane()
        return
    end
    if PdkEffectCtrl.EffectConfig[cardType] then
        this.CreatEffect(parent, PdkEffectCtrl.EffectConfig[cardType], index)
    end
end

--播放报单特效
function PdkEffectCtrl.PlayBaoDan(parent)
    this.CreatEffect(parent, PdkEffectCtrl.EffectConfig["BaoDan"])
end

--播放飞机特效
function PdkEffectCtrl.PlayAirplane()
    if this.airplaneGO == nil then
        local asset = this.LoadAssetByEffectName("PdkAirplane")
        this.airplaneGO = CreateGO(asset)
        UIUtil.SetLocalPosition(this.airplaneGO, 0, 0, 0)
    end
    UIUtil.SetActive(this.airplaneGO, false)
    UIUtil.SetActive(this.airplaneGO, true)
    local animator = this.airplaneGO.transform:Find("Airplane"):GetComponent("Animator")
    local animatorState = Util.GetAnimatorStateMachine(animator)
    animatorState.onExitStateCallBack = function ()
        UIUtil.SetActive(this.airplaneGO, false)
    end
end

--创建特效
function PdkEffectCtrl.CreatEffect(parent, data, index)
    local asset = this.LoadAssetByEffectName(data.name)
    local go = CreateGO(asset, parent, data.name)
    UIUtil.SetLocalPosition(go, 0, 0, 0)

    -- local unityArmature = go.transform:Find("Armature"):GetComponent("UnityArmatureComponent")
    -- DragonBonesUtil.AddEventListener(
    --     unityArmature,
    --     DragonBonesEventObject.COMPLETE,
    --     HandlerByStaticArg2({item = go}, this.OnCompleteWealthGod)
    -- )
    -- DragonBonesUtil.Play(unityArmature, data.animation, data.count)

    local spineAnim = go.transform:Find("effect"):GetComponent(TypeSkeletonGraphic)
    spineAnim.AnimationState.Complete = spineAnim.AnimationState.Complete + HandlerByStaticArg2({item = go}, this.OnCompleteWealthGod)

    local animName = data.animation
    if data.name == "Bomb" then
        local yinshe = {[1] = 3, [2] = 2, [3] = 1, [4] = 1}
        index = yinshe[index]
        animName = animName .. index
    end
    spineAnim.AnimationState:SetAnimation(0, animName, false)
end

--1 3  2 2 3 1 4 1

--结束回调
function PdkEffectCtrl.OnCompleteWealthGod(arg, str, eventObject)
    destroy(arg.item)
end

--清除特效
function PdkEffectCtrl.ClearEff()
    if this.airplaneGO ~= nil then
        UIUtil.SetActive(this.airplaneGO, false)
    end
end
