--资源初始化状态类型
TpResourcesMgr = {
    --没有初始化
    None = 0,
    --初始化中
    Initializing = 1,
    --已经初始化
    Initialized = 2,
}

--资源管理
TpResourcesMgr = {
    --初始化完成标识
    state = 0,
    --资源初始化完成的回调
    onInitCompleted = nil,
    --牌的图片精灵
    cardSprites = {},
    --特效从AB包加载出来的Prefab
    effectAssetPrefabs = {},
    --加载中的
    loadingTable = {},
    --房间的图片
    sprites = {},
    --状态图片
    statusSprites = {},
}

local this = TpResourcesMgr

--开始加载时间用于处理加载时长
local startLoadTime = 0

--资源初始化
function TpResourcesMgr.Initialize()
    Log(">> TpResourcesMgr.Initialize > Start.")
    if this.state == TpResourcesMgr.Initialized then
        if this.onInitCompleted ~= nil then
            this.onInitCompleted()
        end
        return
    elseif this.state == TpResourcesMgr.Initializing then
        return
    end

    startLoadTime = os.timems()
    this.state = TpResourcesMgr.Initializing

    ResourcesManager.PreloadPrefabs(TpBundleName.Panel, { "TpRoomPanel" }, this.OnPreLoadCompleted)
end

--清理，用于退出房间
function TpResourcesMgr.Clear()
    this.onInitCompleted = nil
end

--销毁，用于完全卸载
function TpResourcesMgr.Destroy()
    this.onInitCompleted = nil
    this.cardSprites = {}
    this.sprites = {}
    this.statusSprites = {}
    this.ClearEffect()
    this.state = TpResourcesMgr.None
end

--资源预加载完成回调
function TpResourcesMgr.OnPreLoadCompleted(objs)
    Log(">> TpResourcesMgr.OnPreLoadCompleted > Load total time = " .. (os.timems() - startLoadTime))

    this.state = TpResourcesMgr.Initialized

    if this.onInitCompleted ~= nil then
        this.onInitCompleted()
    end
end

--==========================================================================
--设置图片精灵
function TpResourcesMgr.SetCardSprites(sprites)
    local tempSprites = sprites:ToTable()

    local sprite = nil
    for i = 1, #tempSprites do
        sprite = tempSprites[i]
        if sprite ~= nil then
            this.cardSprites[sprite.name] = sprite
        else
            LogWarn(">> TpResourcesMgr > sprite == nil > index = " .. i)
        end
    end
end

--打牌获取牌Sprite
function TpResourcesMgr.GetCardSprite(id)
    local name = tostring(id)
    local sprite = this.cardSprites[name]
    if sprite == nil then
        LogWarn(">> TpResourcesMgr > GetCardSprite > sprite == nil > key = " .. name)
        return nil
    else
        return sprite
    end
end

--获取UI使用的Sprite
function TpResourcesMgr.GetUICardSprite(name)
    local sprite = this.cardSprites[name]

    if sprite == nil then
        LogWarn(">> TpResourcesMgr > GetUICardSprite> sprite == nil > key = " .. name)
        return nil
    else
        return sprite
    end
end


--==========================================================================
--设置状态图片
function TpResourcesMgr.SetStatusSprites(sprites)
    this.statusSprites = sprites:ToTable()
end

--获取状态图片
function TpResourcesMgr.GetStatusSprite(index)
    local sprite = this.statusSprites[index]
    if sprite == nil then
        LogWarn(">> TpResourcesMgr > GetStatusSprite > sprite == nil > index = " .. index)
        return nil
    else
        return sprite
    end
end

--==========================================================================
--设置房间图片精灵
function TpResourcesMgr.SetSprites(sprites)
    local tempSprites = sprites:ToTable()

    local sprite = nil
    for i = 1, #tempSprites do
        sprite = tempSprites[i]
        if sprite ~= nil then
            this.sprites[sprite.name] = sprite
        else
            LogWarn(">> TpResourcesMgr > SetSprites > sprite == nil > index = " .. i)
        end
    end
end

--获取房间图片精灵Sprite
function TpResourcesMgr.GetSprite(name)
    local sprite = this.sprites[name]
    if sprite == nil then
        LogWarn(">> TpResourcesMgr > GetSprite > sprite == nil > key = " .. name)
        return nil
    else
        return sprite
    end
end

--==========================================================================
--特效资源管理
--获取特效
function TpResourcesMgr.GetEffectPrefab(effectName, callback, arg)
    local prefab = this.effectAssetPrefabs[effectName]
    if prefab ~= nil then
        if callback ~= nil then
            callback(prefab, arg)
        end
    else
        local loadingObj = this.loadingTable[effectName]
        local callbackObj = { callback = callback, arg = arg }

        if loadingObj == nil then
            loadingObj = {}
            loadingObj.callbackObjs = {}
            table.insert(loadingObj.callbackObjs, callbackObj)

            local abName = TpBundleName.Effect

            if abName ~= nil then
                this.loadingTable[effectName] = loadingObj
                local arg = { name = effectName }
                ResourcesManager.LoadPrefab(abName, effectName, this.OnEffectLoadCompleted, arg)
            else
                Log(">> TpResourcesMgr.GetEffectPrefab > effectName = " .. tostring(effectName))
            end
        else
            table.insert(loadingObj.callbackObjs, callbackObj)
        end
    end
end

--特效加载完成
function TpResourcesMgr.OnEffectLoadCompleted(asset, arg)
    if arg == nil or arg.name == nil then
        return
    end

    local loadingObj = this.loadingTable[arg.name]
    this.loadingTable[arg.name] = nil

    if asset == nil then
        return
    end
    this.effectAssetPrefabs[arg.name] = asset

    local callbackObj = nil
    for i = 1, #loadingObj.callbackObjs do
        callbackObj = loadingObj.callbackObjs[i]
        if callbackObj.callback ~= nil then
            callbackObj.callback(asset, callbackObj.arg)
        end
    end
end

--清除特效
function TpResourcesMgr.ClearEffect()
    this.effectAssetPrefabs = {}
    this.loadingTable = {}
end