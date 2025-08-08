PropsAnimationMgr = {}
local this = PropsAnimationMgr
local propsAssetBundleName = BundleName.Chargingprops

--道具资源缓存
local propsAnimationAsset = {}

--道具播放层级
local propsPlayLayer = nil

local timer = {}

-- arg = {
--     from = nil,
--     to = nil,
-- }
-- propType 播放道具type
function PropsAnimationMgr.PlayAni(propType, arg)
    if not ChatModule.GetIsInit() then
        return
    end
    this.LoadPropLayer(3)
    if propType.id == PropsAnimationName.wealthGod.id then
        this.PlayWealthGodAni(arg)
    elseif propType.id == PropsAnimationName.jiaTeLin.id then
        this.PlayJiaTeLinAni(arg)
        --播放子弹
        this.PlayJiaTeLinDanKongAni(arg)
    elseif propType.id == PropsAnimationName.dapao.id then
        this.PlayBarbetteAni(arg)
        this.PlayBarbetteBeBlownAni(arg)
    elseif propType.id == PropsAnimationName.feiJi.id then
        this.PlayDuiJiangJi(arg)
    elseif propType.id == PropsAnimationName.gongJian.id then
        this.PlayGongJianAni(arg)
        this.PlayGongJianBeiSheAni(arg)
    end
end

function PropsAnimationMgr.LoadPropLayer(num)
    if propsPlayLayer == nil then
        propsPlayLayer = uiMgr:GetUILayer(num)
    end
end

--加载道具资源
function PropsAnimationMgr.LoadAssetByPropName(name)
    if propsAnimationAsset[name] == nil then
        local asset = ResourcesManager.LoadPrefabBySynch(propsAssetBundleName, name)
        if not IsNil(asset) then
            propsAnimationAsset[name] = asset
        else
            Log(">>>>>>>>>>>>>> PropsAnimationMgr > LoadAssetByPropName > 加载资源不存在")
        end
    end
end

function PropsAnimationMgr.UnInit()
    this.Clear()
    local list = {}
    if propsPlayLayer ~= nil then
        for i = 0, propsPlayLayer.childCount - 1 do
            local obj = propsPlayLayer:GetChild(i)
            if obj.name == "dragonbone" then
                table.insert(list, obj)
            end
        end

        for i = 1, #list do
            destroy(list[i].gameObject)
        end
    end
end


--==========================================Util==============================
--获取旋转坐标
function PropsAnimationMgr.GetOtherRotationMaxAndMinPosition(arg)
    --上方向
    local p = Vector3(0, 1, 0)
    local p1 = arg.from.position

    local allRotate = {}
    for i = 1, #arg.to do
        local pp = arg.to[i].position
        local angle
        if pp.x >= p1.x then
            angle = 0 - Vector2.Angle(p, pp - p1) + 360
        else
            angle = Vector2.Angle(p, pp - p1)
        end
        table.insert(allRotate, angle)
    end
    local min = 1000
    local max = -1000
    for i = 1, #allRotate do
        if allRotate[i] < min then
            min = allRotate[i]
        end
        if allRotate[i] > max then
            max = allRotate[i]
        end
    end
    return Vector3(0, 0, min), Vector3(0, 0, max)
end
--=============================================财神动画================================
--播放财神动画
function PropsAnimationMgr.PlayWealthGodAni(arg)
    local assertData = PropsAnimationName.wealthGod

    this.LoadAssetByPropName(assertData.name)
    local asset = propsAnimationAsset[assertData.name]
    if asset ~= nil then
        local go = CreateGO(asset, propsPlayLayer, "dragonbone")
        UIUtil.SetLocalPosition(go, 0, 0, 0)

        local unityArmature = go.transform:Find("Armature"):GetComponent("UnityArmatureComponent")
        DragonBonesUtil.AddEventListener(unityArmature, DragonBonesEventObject.COMPLETE, HandlerByStaticArg2({ item = go, arg = arg }, this.OnCompleteWealthGod))
        DragonBonesUtil.Play(unityArmature, "newAnimation", 1)
        if not ChatModule.GetIsInit() then
            return
        end
        AudioManager.PlaySound(BundleName.Chargingprops, assertData.audio)
    end
end

--结束回调
function PropsAnimationMgr.OnCompleteWealthGod(arg, str, eventObject)
    destroy(arg.item)
end
--=============================================加特林=====================================
--播放加特林动画
function PropsAnimationMgr.PlayJiaTeLinAni(arg)
    local assertData = PropsAnimationName.jiaTeLin
    local goTab = PropsAnimationMgr.GetCreateGo(assertData, arg)
    if goTab == nil then
        return
    end
    local go = goTab.go
    local unityArmature = goTab.unityArmature
    UIUtil.SetPosition(go, arg.from.position)

    --目标数量
    if #arg.to > 1 then
        local min, max = this.GetOtherRotationMaxAndMinPosition(arg)
        Log(">>>>>>>>>>> min ", min, "   max  ", max)
        local tween = go.transform:Find("Arm"):GetComponent("TweenRotation")
        tween.from = max
        tween.to = min
        tween:Play(true)

        timer["jiaTeLin"] = Scheduler.scheduleOnceGlobal(function()
            go.transform.localEulerAngles = Vector3(0, 0, 0)
        end, 0.3)
        go.transform.localEulerAngles = max
    else
        this.SetRotationPosition(go.transform, arg.to[1].position)
    end

    DragonBonesUtil.Play(unityArmature, "Gun", 0)
    timer["jiaTeLinDelete"] = Scheduler.scheduleOnceGlobal(function()
        destroy(go)
    end, 3)

    if not ChatModule.GetIsInit() then
        return
    end
    AudioManager.PlaySound(BundleName.Chargingprops, assertData.audio)
end

--设置旋转
function PropsAnimationMgr.SetRotationPosition(tran, toPosition)
    local from = Vector3.New(0, 1, 0)
    local to = toPosition - tran.position
    tran.rotation = Quaternion.FromToRotation(from, to)
end

--创建并获取预设
function PropsAnimationMgr.GetCreateGo(assertData, arg)
    local goTab = {}
    this.LoadAssetByPropName(assertData.name)
    local asset = propsAnimationAsset[assertData.name]
    if asset ~= nil then
        if arg.from == nil or arg.to == nil then
            Log(">>>>>>>>>>>>>> PropsAnimationMgr > PlayJiaTeLinAni > 参数错误")
            return
        end
        local go = CreateGO(asset, propsPlayLayer, "dragonbone")
        local arm = go.transform:Find("Arm/Armature")
        local unityArmature = arm:GetComponent("UnityArmatureComponent")

        goTab.go = go
        goTab.arm = arm
        goTab.unityArmature = unityArmature
        return goTab
    end
end

--播放加特林子弹
function PropsAnimationMgr.PlayJiaTeLinDanKongAni(arg)
    local name = PropsAnimationName.dankong.name
    local list = {}
    local i = 1

    local CreatGO = function()
        local goTab = this.GetCreateGo(PropsAnimationName.dankong, arg)
        if goTab ~= nil then
            UIUtil.SetPosition(goTab.go, arg.to[i].position)
            DragonBonesUtil.Play(goTab.unityArmature, "newAnimation", 1)
            table.insert(list, goTab.go)
        end
        i = i + 1
    end

    for i = 1, #arg.to do
        CreatGO()
    end

    this.DeleteJiaTeLinDanKong(list)
end

--删除加特林弹孔
function PropsAnimationMgr.DeleteJiaTeLinDanKong(list)
    timer["jiaTeLinDanKongDelete"] = Scheduler.scheduleOnceGlobal(function()
        if (ChatModule.GetIsInit()) then
            for i = 1, #list do
                destroy(list[i])
            end
        end
    end, 3)
end

--=============================================炮台=====================================
--初始化炮台资源数据
function PropsAnimationMgr.InitBarBetteAniRes(arg)
    local time = 0
    local asset
    if #arg.to == 1 then
        this.LoadAssetByPropName(PropsAnimationName.dapao.name)
        asset = propsAnimationAsset[PropsAnimationName.dapao.name]
    elseif #arg.to == 2 then
        this.LoadAssetByPropName(PropsAnimationName.dapao.twoName)
        asset = propsAnimationAsset[PropsAnimationName.dapao.twoName]
        time = 0.8
    elseif #arg.to >= 3 then
        this.LoadAssetByPropName(PropsAnimationName.dapao.threeName)
        asset = propsAnimationAsset[PropsAnimationName.dapao.threeName]
        time = 0.8
    end
    return asset, time
end

--播放炮台动画
function PropsAnimationMgr.PlayBarbetteAni(arg)
    local asset, time = this.InitBarBetteAniRes(arg)
    if asset ~= nil then
        if IsNil(arg.from) then
            Log(">>>>>>>>>>>>>> PropsAnimationMgr > PlayJiaTeLinAni > 参数错误")
            return
        end
        local go = CreateGO(asset, propsPlayLayer, "dragonbone")
        UIUtil.SetPosition(go, arg.from.position)

        if #arg.to == 1 then
            this.PlayBarbetteAniSingle(go, arg, time)
        elseif #arg.to > 1 then
            this.PlayBarbetteAniMulti(go, arg, time)
        end
    end
end
-----------------
--播放单人大炮动画
function PropsAnimationMgr.PlayBarbetteAniSingle(go, arg, time)
    if IsNil(arg.to[1]) or IsNil(go) then
        return
    end

    local arm = go.transform:Find("Armature")
    local from = Vector3.New(0, 1, 0)
    local to = arg.to[1].position - go.transform.position
    go.transform.rotation = Quaternion.FromToRotation(from, to)

    local unityArmature = arm:GetComponent("UnityArmatureComponent")
    DragonBonesUtil.AddEventListener(unityArmature, DragonBonesEventObject.COMPLETE, HandlerByStaticArg2({ item = go, arg = arg }, this.OnCompleteBarbette))
    DragonBonesUtil.Play(unityArmature, "newAnimation", 1)
    --播放音效
    timer["BarbettePlaySound"] = Scheduler.scheduleOnceGlobal(function()
        if ChatModule.GetIsInit() then
            AudioManager.PlaySound(BundleName.Chargingprops, PropsAnimationName.dapao.audio)
        end
    end, 2.15)
end

--播放多人大炮音效
function PropsAnimationMgr.PlayBarbetteAniMulti(go, arg, time)
    if IsNil(go) then
        return
    end

    local arm = go.transform:Find("Arm/Armature")
    local unityArmature = arm:GetComponent("UnityArmatureComponent")
    DragonBonesUtil.AddEventListener(unityArmature, DragonBonesEventObject.COMPLETE, HandlerByStaticArg2({ item = go, arg = arg }, this.OnCompleteBarbette))
    DragonBonesUtil.Play(unityArmature, "newAnimation", 1)

    local min, max = this.GetOtherRotationMaxAndMinPosition(arg)
    local tween = go.transform:Find("Arm"):GetComponent("TweenRotation")
    tween.from = max
    tween.to = min
    timer["BarbetteMulti"] = Scheduler.scheduleOnceGlobal(function()
        go.transform.localEulerAngles = Vector3.zero
        tween:Play(true)
    end, 2)

    go.transform.localEulerAngles = max

    --播放音效
    timer["BarbettePlaySound"] = Scheduler.scheduleOnceGlobal(HandlerArgs(this.PlayBarbetteAudio, time, #arg.to - 1), 2.15)
end

function PropsAnimationMgr.PlayBarbetteAudio(time, count)
    if not ChatModule.GetIsInit() then
        return
    end

    AudioManager.PlaySound(BundleName.Chargingprops, PropsAnimationName.dapao.audio)
    if count - 1 > 0 then
        local timer = Timer.New(function()
            if not ChatModule.GetIsInit() then
                return
            end
            AudioManager.PlaySound(BundleName.Chargingprops, PropsAnimationName.dapao.audio)
        end,
        time + 0.2, count)
        timer:Start()
    end
end

--结束回调
function PropsAnimationMgr.OnCompleteBarbette(arg, str, eventObject)
    destroy(arg.item)
end

--播放炮弹弹孔
function PropsAnimationMgr.PlayBarbetteBeBlownAni(arg)
    if not ChatModule.GetIsInit() then
        return
    end

    local name = PropsAnimationName.beBlown.name
    this.LoadAssetByPropName(name)
    local asset = propsAnimationAsset[name]
    if asset ~= nil then
        local time = 3
        if #arg.to == 2 then
            time = 4
        elseif #arg.to >= 3 then
            time = 5
        end
        timer["BarbetteBeDanKong"] = Scheduler.scheduleOnceGlobal(function()
            if not ChatModule.GetIsInit() then
                return
            end
            for i = 1, #arg.to do
                this.PlayBarbetteBeBlown(asset, arg, i)
            end
        end, time)
    end
end

function PropsAnimationMgr.PlayBarbetteBeBlown(asset, arg, index)
    if not ChatModule.GetIsInit() then
        return
    end

    if IsNil(arg.to[index]) or IsNil(arg.from) then
        return
    end

    local go = CreateGO(asset, propsPlayLayer, "dragonbone")
    UIUtil.SetPosition(go, arg.to[index].position)
    local unityArmature = go.transform:Find("Armature"):GetComponent("UnityArmatureComponent")
    DragonBonesUtil.AddEventListener(unityArmature, DragonBonesEventObject.COMPLETE, HandlerByStaticArg2({ item = go, arg = arg }, this.OnCompletePlayBarbetteBeBlownAni))
    DragonBonesUtil.Play(unityArmature, "newAnimation", 1)
    if not ChatModule.GetIsInit() then
        return
    end
    AudioManager.PlaySound(BundleName.Chargingprops, PropsAnimationName.beBlown.audio)
end

--结束回调
function PropsAnimationMgr.OnCompletePlayBarbetteBeBlownAni(arg, str, eventObject)
    destroy(arg.item)
end
--=============================================轰炸机=====================================
--播放轰炸机动画
function PropsAnimationMgr.PlayFeiJiAni(arg)
    this.LoadAssetByPropName(PropsAnimationName.feiJi.name)
    local asset = propsAnimationAsset[PropsAnimationName.feiJi.name]
    if asset ~= nil then
        if arg.from == nil or arg.to == nil then
            Log(">>>>>>>>>>>>>> PropsAnimationMgr > PlayJiaTeLinAni > 参数错误")
            return
        end
        local go = CreateGO(asset, propsPlayLayer, "dragonbone")

        UIUtil.SetLocalPosition(go, 0, 0, 0)

        Log(">>>>>>>>>>>>>>>>>>>>>>", go.transform.position)
        local arm = go.transform:Find("Armature")

        local unityArmature = arm:GetComponent("UnityArmatureComponent")
        DragonBonesUtil.AddEventListener(
        unityArmature,
        DragonBonesEventObject.COMPLETE,
        function()
            destroy(go)
        end
        )
        DragonBonesUtil.Play(unityArmature, "newAnimation", 1)

        -- AudioManager.PlaySound(BundleName.Chargingprops,PropsAnimationName.feiJi.audio)
    end
end

--飞机被轰
function PropsAnimationMgr.PlayFeiJiBeiHong(arg)
    this.LoadAssetByPropName(PropsAnimationName.feiJiBeiHong.name)
    local asset = propsAnimationAsset[PropsAnimationName.feiJiBeiHong.name]
    if asset ~= nil then
        if arg.from == nil or arg.to == nil then
            Log(">>>>>>>>>>>>>> PropsAnimationMgr > PlayJiaTeLinAni > 参数错误")
            return
        end
        local go = CreateGO(asset, propsPlayLayer, "dragonbone")
        UIUtil.SetPosition(go, arg.to.position)

        local arm = go.transform:Find("Armature")
        local unityArmature = arm:GetComponent("UnityArmatureComponent")

        DragonBonesUtil.AddEventListener(
        unityArmature,
        DragonBonesEventObject.COMPLETE,
        function()
            destroy(go)
        end
        )
        DragonBonesUtil.Play(unityArmature, "newAnimation", 1)

        -- Scheduler.scheduleOnceGlobal(function ()
        --     AudioManager.PlaySound(BundleName.Chargingprops, PropsAnimationName.feiJiBeiHong.audio)
        -- end,0.5)
    end
end

--对讲机
function PropsAnimationMgr.PlayDuiJiangJi(arg)
    this.LoadAssetByPropName(PropsAnimationName.duiJiangJi.name)
    local asset = propsAnimationAsset[PropsAnimationName.duiJiangJi.name]
    if asset ~= nil then
        if arg.from == nil or arg.to == nil then
            Log(">>>>>>>>>>>>>> PropsAnimationMgr > PlayJiaTeLinAni > 参数错误")
            return
        end
        local go = CreateGO(asset, propsPlayLayer, "dragonbone")
        UIUtil.SetPosition(go, arg.from.position)

        local arm = go.transform:Find("Armature")
        local unityArmature = arm:GetComponent("UnityArmatureComponent")

        DragonBonesUtil.AddEventListener(unityArmature, DragonBonesEventObject.COMPLETE, function()
            destroy(go)
            this.PlayFeiJiAni(arg)
            timer["DuiJiangJi"] = Scheduler.scheduleOnceGlobal(HandlerArgs(this.PlayFeiJiBeiHong, arg), 1.5)
        end)
        DragonBonesUtil.Play(unityArmature, "newAnimation", 1)
    end
end

--=============================================弓箭=====================================
--播放弓箭动画
function PropsAnimationMgr.PlayGongJianAni(arg)
    this.LoadAssetByPropName(PropsAnimationName.gongJian.name)
    local asset = propsAnimationAsset[PropsAnimationName.gongJian.name]
    if asset ~= nil then
        if arg.from == nil or arg.to == nil then
            Log(">>>>>>>>>>>>>> PropsAnimationMgr > PlayJiaTeLinAni > 参数错误")
            return
        end
        local go = CreateGO(asset, propsPlayLayer, "dragonbone")
        UIUtil.SetPosition(go, arg.from.position)
        local arm = go.transform:Find("Armature")
        local from = Vector3.New(0, 1, 0)
        local to = arg.to.position - arm.position
        arm.rotation = Quaternion.FromToRotation(from, to)
        local unityArmature = arm:GetComponent("UnityArmatureComponent")
        DragonBonesUtil.AddEventListener(
        unityArmature,
        DragonBonesEventObject.COMPLETE,
        function()
            destroy(go)
        end
        )
        DragonBonesUtil.Play(unityArmature, "newAnimation", 1)
    end
end

--播放弓箭被射
function PropsAnimationMgr.PlayGongJianBeiSheAni(arg)
    local name = PropsAnimationName.gongJianBeiShe.name
    this.LoadAssetByPropName(name)
    local asset = propsAnimationAsset[name]
    if asset ~= nil then
        timer["PlayGongJianBeiSheAni"] = Scheduler.scheduleOnceGlobal(function()
            local go = CreateGO(asset, propsPlayLayer, "dragonbone")
            UIUtil.SetPosition(go, arg.to.position)
            local unityArmature = go.transform:Find("Armature"):GetComponent("UnityArmatureComponent")
            DragonBonesUtil.AddEventListener(unityArmature, DragonBonesEventObject.COMPLETE, function()
                destroy(go)
            end)
            DragonBonesUtil.Play(unityArmature, "newAnimation", 1)
        end, 1.5)
    end
end

function PropsAnimationMgr.Clear()
    for k, v in pairs(timer) do
        Scheduler.unscheduleGlobal(v)
    end
    timer = {}
end

return PropsAnimationMgr