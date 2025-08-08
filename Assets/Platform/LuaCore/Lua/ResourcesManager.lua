--资源加载状态
AssetLoadState = {
    --未处理
    None = 0,
    --加载中
    Loading = 1,
    --加载完成
    Loaded = 2,
}

--资源缓存管理器，Lua层使用的资源都应该从该处获取
ResourcesManager = {
    --预加载对象
    preloads = {},
    --资源包对象，AB包分类
    bundles = {},
    --检测处理的时间
    lastGCTime = 0,
    --检测GC的Timer
    checkGCTimer = nil,
}
local this = ResourcesManager
--gc的间隔时间，单位秒
local GC_INTERVAL = 150

--直接获取资源，如果有预加载，或者认为已经加载了的，可以直接使用该方法获取
function ResourcesManager.GetAsset(abName, assetName)
    local bundleObj = this.bundles[abName]
    if bundleObj == nil then
        return nil
    end

    local assetObj = bundleObj[assetName]
    if assetObj == nil then
        return nil
    end

    return assetObj.asset
end

--清除资源，主要是AB包的卸载
function ResourcesManager.Clear()
    this.Release()
    this.StopCheckGCTimer()
end

------------------------------------------------------------------
--获取BundleObj
function ResourcesManager.GetBundleObj(abName)
    local bundleObj = this.bundles[abName]
    if bundleObj == nil then
        bundleObj = {}
        this.bundles[abName] = bundleObj
    end
    return bundleObj
end

--新建一个Asset存储对象
function ResourcesManager.NewAssetObj(assetName)
    local assetObj = {
        --资源名称
        assetName = assetName,
        --回调集合
        callbacks = {},
        --加载状态
        loadState = AssetLoadState.None,
        --资源
        asset = nil,
    }
    return assetObj
end

--================================================================
--异步加载Prefab
function ResourcesManager.LoadPrefab(abName, assetName, callback, args)
    this.LoadAsset(AssetType.GAME_OBJECT, abName, assetName, callback, args)
end

--异步加载Sprite
function ResourcesManager.LoadSprite(abName, assetName, callback, args)
    this.LoadAsset(AssetType.SPRITE, abName, assetName, callback, args)
end

--异步加载AudioClip
function ResourcesManager.LoadAudioClip(abName, assetName, callback, args)
    this.LoadAsset(AssetType.AUDIO_CLIP, abName, assetName, callback, args)
end

--异步加载单个资源
function ResourcesManager.LoadAsset(type, abName, assetName, callback, args)
    if string.IsNullOrEmpty(abName) or string.IsNullOrEmpty(assetName) then
        LogWarn(">> ResourcesManager.LoadAsset > All NullOrEmpty.")
        return
    end

    local bundleObj = this.GetBundleObj(abName)
    local assetObj = bundleObj[assetName]
    if assetObj == nil then
        assetObj = this.NewAssetObj(assetName)
        bundleObj[assetName] = assetObj
    end

    if assetObj.loadState == AssetLoadState.Loaded then
        if callback ~= nil then
            callback(assetObj.asset, args)
        end
    elseif assetObj.loadState == AssetLoadState.Loading then
        if callback ~= nil then
            local isExist = false
            for k, callbackObj in pairs(assetObj.callbacks) do
                if callbackObj.callback == callback then
                    LogWarn(">> ResourcesManager.LoadAsset > Exist callback > " .. tostring(callback))
                    isExist = true
                end
            end

            if not isExist then
                table.insert(assetObj.callbacks, { callback = callback, args = args })
            end
        end
    else
        if callback ~= nil then
            table.insert(assetObj.callbacks, { callback = callback, args = args })
        end
        assetObj.loadState = AssetLoadState.Loading
        resMgr:LoadAsset(type, abName, assetName, this.OnLoadAssetCompleted, assetObj)
    end
end

function ResourcesManager.OnLoadAssetCompleted(objs, assetObj)
    assetObj.loadState = AssetLoadState.Loaded

    local temp = objs:ToTable()
    if temp ~= nil and temp[1] ~= nil then
        assetObj.asset = temp[1]
    end
    for k, callbackObj in pairs(assetObj.callbacks) do
        if callbackObj.callback ~= nil then
            callbackObj.callback(assetObj.asset, callbackObj.args)
            callbackObj.callback = nil
        end
    end

    --清除回调
    assetObj.callbacks = {}
end

--================================================================
--异步预加载Prefab
function ResourcesManager.PreloadPrefabs(abName, assetNames, callback, args)
    this.PreloadAssets(AssetType.GAME_OBJECT, abName, assetNames, callback, args)
end

--异步预加载Sprite
function ResourcesManager.PreloadSprites(abName, assetNames, callback, args)
    this.PreloadAssets(AssetType.SPRITE, abName, assetNames, callback, args)
end

--异步预加载AudioClip
function ResourcesManager.PreloadAudioClips(abName, assetNames, callback, args)
    this.PreloadAssets(AssetType.AUDIO_CLIP, abName, assetNames, callback, args)
end

--预加载多个资源，只回调，不返回资源数据
function ResourcesManager.PreloadAssets(type, abName, assetNames, callback, args)
    if string.IsNullOrEmpty(abName) or not IsTable(assetNames) or #assetNames < 1 then
        LogWarn(">> ResourcesManager.PreloadAssets > All NullOrEmpty.")
        return
    end

    local tempArgs = { abName = abName, assetNames = assetNames, callback = callback, args = args }
    resMgr:LoadAssets(type, abName, assetNames, this.OnPreloadAssetsCompleted, tempArgs)
end

--预加载回调
function ResourcesManager.OnPreloadAssetsCompleted(objs, args)
    local temp = objs:ToTable()
    if temp ~= nil and temp[1] == nil then
        LogWarn(">> ResourcesManager.OnPreloadAssetsCompleted > load failure.")
        return
    end

    local bundleObj = this.GetBundleObj(args.abName)
    --存储资源
    local asset = nil
    local assetName = nil
    local assetObj = nil
    for i = 1, #args.assetNames do
        asset = temp[i]
        assetName = args.assetNames[i]
        if asset ~= nil and assetName ~= nil then
            assetObj = bundleObj[assetName]
            if assetObj == nil then
                assetObj = this.NewAssetObj(assetName)
                bundleObj[assetName] = assetObj
            end
            assetObj.asset = asset
            assetObj.loadState = AssetLoadState.Loaded
        end
    end
    if args.callback ~= nil then
        args.callback(args.args)
    end
end

--================================================================
--同步加载Prefab
function ResourcesManager.LoadPrefabBySynch(abName, assetName)
    return this.LoadAssetBySynch(AssetType.GAME_OBJECT, abName, assetName)
end

--同步加载Sprite
function ResourcesManager.LoadSpriteBySynch(abName, assetName)
    return this.LoadAssetBySynch(AssetType.SPRITE, abName, assetName)
end

--同步加载AudioClip
function ResourcesManager.LoadAudioClipBySynch(abName, assetNames)
    return this.LoadAssetBySynch(AssetType.AUDIO_CLIP, abName, assetNames)
end

--同步加载资源
function ResourcesManager.LoadAssetBySynch(type, abName, assetName)
    local asset = this.GetAsset(abName, assetName)
    if asset ~= nil then
        return asset
    end

    asset = resMgr:LoadAssetBySynch(type, abName, assetName)

    if asset ~= nil then
        local bundleObj = this.bundles[abName]
        if bundleObj == nil then
            bundleObj = {}
            this.bundles[abName] = bundleObj
        end
        local assetObj = bundleObj[assetName]
        if assetObj == nil then
            assetObj = this.NewAssetObj(assetName)
            bundleObj[assetName] = assetObj
        end
        assetObj.asset = asset
        assetObj.loadState = AssetLoadState.Loaded
    end
    return asset
end

--================================================================
--
--卸载单个Asset资源
function ResourcesManager.ReleaseAsset(abName, assetName)
    local bundleObj = this.bundles[abName]
    if bundleObj ~= nil then
        local assetObj = bundleObj[assetName]
        if assetObj ~= nil then
            bundleObj[assetName] = nil
            assetObj.callbacks = {}
            assetObj.asset = nil
        end
    end
end

--卸载AB包下面的所有Asset资源
function ResourcesManager.ReleaseAssets(abName)
    local bundleObj = this.bundles[abName]
    if bundleObj ~= nil then
        for k, assetObj in pairs(bundleObj) do
            if assetObj ~= nil then
                assetObj.callbacks = {}
                assetObj.asset = nil
            end
        end
    end
end

--释放资源
function ResourcesManager.Release()
    for abName, bundleObj in pairs(this.bundles) do
        if bundleObj ~= nil then
            this.UnloadBundles(abName, bundleObj)
        end
    end
    this.bundles = {}
end

--卸载单个AB包资源
function ResourcesManager.Unload(abName, isThorough)
    local bundleObj = this.bundles[abName]
    if bundleObj ~= nil then
        this.bundles[abName] = nil
        this.UnloadBundles(abName, bundleObj, isThorough)
    end
end

--卸载资源
function ResourcesManager.UnloadBundles(abName, bundleObj, isThorough)
    for k, assetObj in pairs(bundleObj) do
        --清除回调，如果正在下载的资源被清除了，防止Lua层回调
        if assetObj ~= nil then
            assetObj.callbacks = {}
            assetObj.asset = nil
        end
    end
    if isThorough == nil then
        isThorough = false
    end
    resMgr:UnloadAssetBundle(abName, isThorough)
end


--================================================================
--
--预加载
function ResourcesManager.Preload(gameType, abName, assetNames, callback, args)
    local temp = this.preloads[gameType]
    if temp == nil then
        temp = {}
        this.preloads[gameType] = temp
    end

    if temp[abName] ~= nil then
        --已经预加载了AB包，就不在预加载了
        return
    else
        temp[abName] = abName
    end
    this.PreloadPrefabs(abName, assetNames, callback, args)
end

--卸载预加载的AB包，更新游戏资源的时候需要卸载
function ResourcesManager.UnloadPreload(gameType)
    local temp = this.preloads[gameType]
    this.preloads[gameType] = nil
    if temp ~= nil then
        for k, v in pairs(temp) do
            this.Unload(k)
        end
    end
end

--================================================================
--
--检测GC，isImmediately为立即执行
function ResourcesManager.CheckGC(isImmediately)
    if isImmediately then
        this.HandleGC()
    else
        if Time.realtimeSinceStartup - this.lastGCTime > GC_INTERVAL then
            this.HandleGC()
        else
            this.StartCheckGCTimer()
        end
    end
end

--处理GC
function ResourcesManager.HandleGC()
    this.lastGCTime = Time.realtimeSinceStartup
    this.StopCheckGCTimer()
    ClearMemory()
end

--启动检测GC
function ResourcesManager.StartCheckGCTimer()
    if this.checkGCTimer == nil then
        this.checkGCTimer = Timing.New(this.OnCheckGCTimer, 10)
    end
    if not this.checkGCTimer.running then
        this.lastGCTime = Time.realtimeSinceStartup
        this.checkGCTimer:Start()
    end
end

--停止检测GC
function ResourcesManager.StopCheckGCTimer()
    if this.checkGCTimer ~= nil then
        this.checkGCTimer:Stop()
    end
end

--处理检测GC
function ResourcesManager.OnCheckGCTimer()
    if Time.realtimeSinceStartup - this.lastGCTime > GC_INTERVAL then
        this.HandleGC()
    end
end