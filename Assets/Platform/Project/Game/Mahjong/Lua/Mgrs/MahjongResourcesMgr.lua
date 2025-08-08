--资源初始化状态类型
MahjongResourcesState = {
    --没有初始化
    None = 0,
    --初始化中
    Initializing = 1,
    --已经初始化
    Initialized = 2,
}

--麻将资源管理
MahjongResourcesMgr = {
    --初始化完成标识
    state = 0,
    --资源初始化完成的回调
    onInitCompleted = nil,
    --麻将牌的图片精灵
    mahjongCardSprites = {},
    --麻将牌的图片精灵  --最新版
    mahjongCardSprites_new = {},
    --麻将牌底框的图片精灵  --最新版
    mahjongCardFrames = {},
    --特效从AB包加载出来的Prefab
    effectAssetPrefabs = {},
    --加载中的
    loadingTable = {},
    --房间的图片
    sprites = {},
}

local this = MahjongResourcesMgr

--开始加载时间用于处理加载时长
local startLoadTime = 0

--资源初始化
function MahjongResourcesMgr.Initialize()
    Log(">> MahjongResourcesMgr.Initialize > Start.")
    if this.state == MahjongResourcesState.Initialized then
        if this.onInitCompleted ~= nil then
            this.onInitCompleted()
        end
        return
    elseif this.state == MahjongResourcesState.Initializing then
        return
    end

    startLoadTime = os.timems()
    this.state = MahjongResourcesState.Initializing

    ResourcesManager.PreloadPrefabs(MahjongBundleName.Panel, { "MahjongRoomPanel" }, this.OnPreLoadCompleted)
end

--清理，用于退出房间
function MahjongResourcesMgr.Clear()
    this.onInitCompleted = nil
end

--销毁，用于完全卸载
function MahjongResourcesMgr.Destroy()
    this.onInitCompleted = nil
    this.mahjongCardSprites = {}
    this.mahjongCardSprites_new = {}
    this.mahjongCardFrames = {}
    this.sprites = {}
    this.ClearEffect()
    this.state = MahjongResourcesState.None
end

--资源预加载完成回调
function MahjongResourcesMgr.OnPreLoadCompleted(objs)
    Log(">> MahjongResourcesMgr.OnPreLoadCompleted > Load total time = " .. (os.timems() - startLoadTime))

    this.state = MahjongResourcesState.Initialized

    if this.onInitCompleted ~= nil then
        this.onInitCompleted()
    end
end

--========================================================================== --最新版资源
--设置图片精灵 麻将牌 
function MahjongResourcesMgr.SetCardSprites(sprites)
    local tempSprites = sprites:ToTable()

    local sprite = nil
    for i = 1, #tempSprites do
        sprite = tempSprites[i]
        if sprite ~= nil then
            this.mahjongCardSprites_new[sprite.name] = sprite
        else
            LogWarn(">> MahjongResourcesMgr > sprite == nil > index = " .. i)
        end
    end
end

--打牌获取麻将牌Sprite --最新版
function MahjongResourcesMgr.GetCardSprite(cardKey)
    local name = "mahjong_"..cardKey
    local sprite = this.mahjongCardSprites_new[name]

    if sprite == nil then
        LogWarn(">> MahjongResourcesMgr > GetCardSprite > sprite == nil > key = " .. name)
        return nil
    else
        return sprite
    end
end

--设置图片精灵 麻将牌底框 --最新版
function MahjongResourcesMgr.SetCardFrameSprite(sprites)
    local tempSprites = sprites:ToTable()

    local sprite = nil
    for i = 1, #tempSprites do
        sprite = tempSprites[i]
        if sprite ~= nil then
            this.mahjongCardFrames[sprite.name] = sprite
        else
            LogWarn(">> MahjongResourcesMgr > sprite == nil > index = " .. i)
        end
    end
end

--打牌获取麻将牌底框Sprite --最新版
--type, seatIndex, row, index， layIndex 牌类型、几号位玩家、牌行数、第几张牌(第几次碰杠吃盖)、碰杠吃盖牌顺序
function MahjongResourcesMgr.GetCardFrameSprite(type, seatIndex, row, index, layIndex)
    local name = MahjongUtil.GetCardFrameName(type, seatIndex, row, index, layIndex)
    
    local sprite = this.mahjongCardFrames[name]

    if sprite == nil then
        LogWarn(">> MahjongResourcesMgr > GetCardSprite > sprite == nil > key = " .. name)
        return nil
    else
        return sprite
    end
end

--获取指定资源底框
function MahjongResourcesMgr.GetSingleCardFrameSprite(name)
    return this.mahjongCardFrames[name]
end


--==================================================================================================旧版本资源，已弃用

-- --设置图片精灵
-- function MahjongResourcesMgr.SetCardSprites(sprites)
--     local tempSprites = sprites:ToTable()

--     local sprite = nil
--     for i = 1, #tempSprites do
--         sprite = tempSprites[i]
--         if sprite ~= nil then
--             this.mahjongCardSprites[sprite.name] = sprite
--         else
--             LogWarn(">> MahjongResourcesMgr > sprite == nil > index = " .. i)
--         end
--     end
-- end

-- --打牌获取麻将牌Sprite
-- function MahjongResourcesMgr.GetCardSprite(type, index, cardKey)
--     local name = MahjongUtil.GetCardName(type, index, cardKey)

--     local sprite = this.mahjongCardSprites[name]

--     if sprite == nil then
--         LogWarn(">> MahjongResourcesMgr > GetCardSprite > sprite == nil > key = " .. name)
--         return nil
--     else
--         return sprite
--     end
-- end

-- --获取UI使用的Sprite
-- function MahjongResourcesMgr.GetUICardSprite(name)
--     local sprite = this.mahjongCardSprites[name]

--     if sprite == nil then
--         LogWarn(">> MahjongResourcesMgr > GetUICardSprite> sprite == nil > key = " .. name)
--         return nil
--     else
--         return sprite
--     end
-- end

--==========================================================================
--设置房间图片精灵
function MahjongResourcesMgr.SetSprites(sprites)
    local tempSprites = sprites:ToTable()

    local sprite = nil
    for i = 1, #tempSprites do
        sprite = tempSprites[i]
        if sprite ~= nil then
            this.sprites[sprite.name] = sprite
        else
            LogWarn(">> MahjongResourcesMgr > SetSprites > sprite == nil > index = " .. i)
        end
    end
end

--获取房间图片精灵Sprite
function MahjongResourcesMgr.GetSprite(name)
    local sprite = this.sprites[name]
    if sprite == nil then
        LogWarn(">> MahjongResourcesMgr > GetSprite > sprite == nil > key = " .. name)
        return nil
    else
        return sprite
    end
end

--==========================================================================
--特效资源管理
--获取特效
function MahjongResourcesMgr.GetEffectPrefab(effectName, callback, arg)
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

            local abName = MahjongBundleName.Effect

            if abName ~= nil then
                this.loadingTable[effectName] = loadingObj
                local arg = { name = effectName }
                ResourcesManager.LoadPrefab(abName, effectName, this.OnEffectLoadCompleted, arg)
            else
                Log(">> MahjongResourcesMgr.GetEffectPrefab > effectName = " .. tostring(effectName))
            end
        else
            table.insert(loadingObj.callbackObjs, callbackObj)
        end
    end
end

--特效加载完成
function MahjongResourcesMgr.OnEffectLoadCompleted(asset, arg)
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
function MahjongResourcesMgr.ClearEffect()
    this.effectAssetPrefabs = {}
    this.loadingTable = {}
end