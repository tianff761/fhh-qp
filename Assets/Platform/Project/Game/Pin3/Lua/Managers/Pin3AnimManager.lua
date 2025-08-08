Pin3AnimManager = {}
local this = Pin3AnimManager
Pin3AnimType = {
    StartGame = {assetName = "StartGame", animName = "animation"},
    ShowVs = {assetName = "PKAnim", animName = "start"},
    HideVs = {assetName = "VsAnim", animName = "vs01"},
    Lei = {assetName = "PKAnim", animName = "shandian"},
    Win = {assetName = "WinAnim", animName = "win"},
    Gzyz = {assetName = "GzyzAnim", animName = "gzyz"}
}

function Pin3AnimManager.Play(pin3AnimType, parent, callback, isDestroyAfterPerform)
    if parent == nil then
        parent = Pin3BattlePanel.GetTransform()
    end
    local scale = Vector3.one
    local position = Vector3.zero
    local go = nil
    if pin3AnimType == Pin3AnimType.StartGame then
        go = NewObject(Pin3Utils.GetGoByName(pin3AnimType.assetName), parent)
        UIUtil.SetLocalPosition(go, 0, 0, 0)
        this.PlaySpinAnim(go, pin3AnimType, callback, isDestroyAfterPerform)
    elseif pin3AnimType == Pin3AnimType.ShowVs then
        go = NewObject(Pin3Utils.GetGoByName(pin3AnimType.assetName), parent)
        UIUtil.SetLocalPosition(go, 0, 0, 0)
        this.PlaySpinAnim(go, pin3AnimType, callback, isDestroyAfterPerform)
    elseif pin3AnimType == Pin3AnimType.Lei then
        go = NewObject(Pin3Utils.GetGoByName(pin3AnimType.assetName), parent)
        UIUtil.SetLocalScale(go, 0.6, 0.6, 1)
        UIUtil.SetLocalPosition(go, 0, 0, 0)
        this.PlaySpinAnim(go, pin3AnimType, callback, isDestroyAfterPerform)
    elseif pin3AnimType == Pin3AnimType.Win then
        go = NewObject(Pin3Utils.GetGoByName(pin3AnimType.assetName), parent)
        UIUtil.SetLocalPosition(go, 0, 0, 0)
        this.InternalPlay(go, pin3AnimType, callback, isDestroyAfterPerform)
    elseif pin3AnimType == Pin3AnimType.Gzyz then
        go = NewObject(Pin3Utils.GetGoByName(pin3AnimType.assetName), parent)
        UIUtil.SetLocalPosition(go, 0, 0, 0)
        this.InternalPlay(go, pin3AnimType, callback, isDestroyAfterPerform)
    end
    if go ~= nil then
        return go.transform
    end
    return nil
end

function Pin3AnimManager.InternalPlay(go, pin3AnimType, callback, isDestroyAfterPerform)
    Log("播放动画1", go, pin3AnimType)
    local unityArmature = go.transform:GetComponent("UnityArmatureComponent")
    DragonBonesUtil.AddEventListener(unityArmature, DragonBonesEventObject.COMPLETE, function ()
        Log("==>Pin3AnimManager.InternalPlay执行完毕", go, pin3AnimType, isDestroyAfterPerform == nil, isDestroyAfterPerform)
        if isDestroyAfterPerform == nil or isDestroyAfterPerform == true then
            destroy(go)
        end
        if IsFunction(callback) then
            callback(go)
        end
    end)
    DragonBonesUtil.Play(unityArmature,pin3AnimType.animName, 1)
end

function Pin3AnimManager.PlayNodeAnim(go, pin3AnimType, callback, isDestroyAfterPerform)
    this.InternalPlay(go, pin3AnimType, callback, isDestroyAfterPerform)
end

--播放spin动画
function Pin3AnimManager.PlaySpinAnim(go, pin3AnimType, callback, isDestroyAfterPerform)
    local spineAnim = go.transform:Find("effect"):GetComponent(TypeSkeletonGraphic)
    spineAnim.AnimationState.Complete = spineAnim.AnimationState.Complete + HandlerByStaticArg2({item = go, callback = callback, isDestroyAfterPerform = isDestroyAfterPerform}, this.OnComplete)
    spineAnim.AnimationState:SetAnimation(0, pin3AnimType.animName, false)
end

function Pin3AnimManager.OnComplete(arg, str, eventObject)
    if IsFunction(arg.callback) then
        arg.callback(arg.item)
    end
    if arg.isDestroyAfterPerform == nil or arg.isDestroyAfterPerform == true then
        destroy(arg.item)
    end
end
