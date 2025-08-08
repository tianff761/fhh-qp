--资源初始化状态类型
SDBResourcesInitStateType = {
    --没有初始化
    None = 0,
    --初始化中
    Initializing = 1,
    --已经初始化
    Initialized = 2,
}

--资源管理
SDBResourcesMgr = {
    --初始化完成标识
    initState = 0,
    --资源初始化完成的回调
    onInitCompleted = nil,
}

local this = SDBResourcesMgr

--手牌资源
local cardSprites = {}
--点数，结果资源
local resultSprites = {}
--桌面资源
local deskSprite = {}
--表情动画预设体
local faceAniPrefab = {}

--飞金币的克隆体
local flyGoldGos = {}
--飞牌的克隆体
local flyCards = {}

local isLoadSdbDeskPanel = false
local isLoadRoomPanel = false
local isLoadOperPanel = false
local isLoadResPanel = false

local isOpenRoom = false

local loadFacePrefabsPrefab = nil

local showImage = {}  --特效

--牌局操作音效
SDBGameSoundType = {
    --抢庄
    ROB = 0,
    --不抢庄
    NOROB = 1,
    --准备
    READY = 2,
    --要牌
    DEALCARD = 3,
    --不要牌
    PASS = 4
}

--牌局音效
SDBGameEffSoundType = {
    --请抢庄
    EFFCALLROB = "qiangzhuang",
    --请下注
    EFFCallBET = "xiazhu",
    --爆炸
    EFFBOOBM = "baozha",
    --飞金币
    EFFFLYCOINS = "coins_fly",
    --倒计时
    EFFCOUNTDOWN = "daojishi",
    --发牌
    EFFDEAL = "fapai",
    --游戏开始
    EFFSTART = "gamestart",
    --赢
    EFFWIN = "win",
    --输
    EFFLOSE = "lose",
    --平手
    EFFDRAW = "pingju",
    --抢庄轮播
    EFFRANDOMBANKER = "random_banker",
    --坐下
    EFFSIT = "sit",
    --通杀
    EFFALLKILL = "tongsha"
}

--资源初始化
function SDBResourcesMgr.Initialize(isShow)
    isOpenRoom = isShow
    if this.initState == SDBResourcesInitStateType.Initialized then
        if this.onInitCompleted ~= nil then
            this.onInitCompleted()
        end
        return
    elseif this.initState == SDBResourcesInitStateType.Initializing then
        return
    end

    this.initState = SDBResourcesInitStateType.Initializing

    this.LoadPanels()
end

--设置普通扑克牌值
function SDBResourcesMgr.LoadPokerCards(sprites)
    local mSprites = sprites:ToTable()
    for i = 1, #mSprites do
        cardSprites[mSprites[i].name] = mSprites[i]
    end
end

--设置结算点数资源
function SDBResourcesMgr.LoadResultSprites(sprites)
    local mSprites = sprites:ToTable()
    for i = 1, #mSprites do
        resultSprites[mSprites[i].name] = mSprites[i]
    end
end

--设置表情动画父物体
function SDBResourcesMgr.LoadFacePrefabsParent(Prefab)
    loadFacePrefabsPrefab = Prefab
end

function SDBResourcesMgr.LoadShowImage(sprites)
    local mSprites = sprites:ToTable()
    for i = 1, #mSprites do
        showImage[mSprites[i].name] = mSprites[i]
    end
end

--清空资源信息
function SDBResourcesMgr.Clear()
    this.onInitCompleted = nil
    faceAniPrefab = {}
    resultSprites = {}
    deskSprite = {}
    flyGoldGos = {}
    flyCards = {}
    cardSprites = {}
    isLoadSdbDeskPanel = false
    isLoadRoomPanel = false
    isLoadOperPanel = false
    isLoadResPanel = false
end

--加载面板
function SDBResourcesMgr.LoadPanels()
    ResourcesManager.PreloadPrefabs(SDBPanelConfig.Room.bundleName, { SDBPanelConfig.Room.assetName }, this.OnRoomPanelLoadCompleted, {})
    ResourcesManager.PreloadPrefabs(SDBPanelConfig.Operation.bundleName, { SDBPanelConfig.Operation.assetName }, this.OnisLoadOperPanelLoadCompleted, {})
    ResourcesManager.PreloadPrefabs(SDBPanelConfig.SdbDesk.bundleName, { SDBPanelConfig.SdbDesk.assetName }, this.OnSdbDeskPanelLoadCompleted, {})
    ResourcesManager.PreloadPrefabs(SDBPanelConfig.LoadRes.bundleName, { SDBPanelConfig.LoadRes.assetName }, this.OnSDBLoadResPanelLoadCompleted, {})
end

--加载桌面
function SDBResourcesMgr.LoadDesk(type, panelImage)
    if deskSprite[type] ~= nil then
        if not IsNil(panelImage) then
            panelImage.sprite = deskSprite[type]
        end
    else
        local desktype = "bg_zhuomian"
        local path = desktype .. type
        local abname = BundleName.RoomDesk .. type

        ResourcesManager.LoadSprite(abname, path, function(sprite)
            if not IsNil(panelImage) then
                panelImage.sprite = sprite
            end
            deskSprite[type] = sprite
        end)
    end
end

function SDBResourcesMgr.OnSdbDeskPanelLoadCompleted(objs)
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> OnSdbDeskPanelLoadCompleted")
    isLoadSdbDeskPanel = true
    this.HandlePanelsLoadCompleted()
end

function SDBResourcesMgr.OnRoomPanelLoadCompleted(objs)
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> OnRoomPanelLoadCompleted")
    isLoadRoomPanel = true
    this.HandlePanelsLoadCompleted()
end

function SDBResourcesMgr.OnisLoadOperPanelLoadCompleted(objs)
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> OnisLoadOperPanelLoadCompleted")
    isLoadOperPanel = true
    this.HandlePanelsLoadCompleted()
end

function SDBResourcesMgr.OnSDBLoadResPanelLoadCompleted()
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> OnSDBLoadResPanelLoadCompleted")
    isLoadResPanel = true
    this.HandlePanelsLoadCompleted()
end

function SDBResourcesMgr.HandlePanelsLoadCompleted()
    this.initState = SDBResourcesInitStateType.Initialized
    if isLoadSdbDeskPanel and isLoadRoomPanel and isLoadOperPanel and isLoadResPanel and isOpenRoom then
        if this.onInitCompleted ~= nil then
            this.onInitCompleted()
        end
    end
end

--==========================================================================
--获取手牌
function SDBResourcesMgr.GetHandleCardSprite(assetName)
    local assetN = tonumber(assetName)
    if assetN ~= nil then
        assetName = SDBCardMap[assetN]
    end
    return cardSprites[tostring(assetName)]
end

--获取牌背 --传入牌背颜色
function SDBResourcesMgr.GetCardBack()
    return this.GetHandleCardSprite("card_sh_b_" .. SDBRoomData.cardColor)
end

--获取结算点数
function SDBResourcesMgr.GetResultSprite(assetName)
    return resultSprites[assetName]
end

--
function SDBResourcesMgr.GetShowPng(name)
    return showImage[name]
end

--播放玩家操作音效
function SDBResourcesMgr.PlayGameOperSound(type, playerId)
    Log("开始播放操作音效>>>>>>>>>>>>>", type)
    local asset;
    local playerData = SDBRoomData.GetPlayerDataById(playerId)
    if playerData.sex == 1 then
        asset = "nm_"
    else
        asset = "nw_"
    end

    if type == SDBGameSoundType.ROB then
        asset = asset .. "qiangzhuang"
    elseif type == SDBGameSoundType.NOROB then
        asset = asset .. "sdb_buqiang"
    elseif type == SDBGameSoundType.READY then
        asset = asset .. "ready"
    elseif type == SDBGameSoundType.DEALCARD then
        asset = asset .. "sdb_yao_2"
    elseif type == SDBGameSoundType.PASS then
        asset = asset .. "sdb_buyao_1"
    end

    AudioManager.PlaySound(SDBBundleName.sdbsound, asset)
end

--播放流程音效
function SDBResourcesMgr.PlayGameSound(type)
    AudioManager.PlaySound(SDBBundleName.sdbsound, type)
end

--播放流程音效
function SDBResourcesMgr.PlayFaPaiGameSound()
    this.PlayGameSound(SDBGameEffSoundType.EFFDEAL)
end

--手牌结果
function SDBResourcesMgr.PlayCardPointSound(playerId, point, type)
    local asset;
    local playerData = SDBRoomData.GetPlayerDataById(playerId)
    if playerData.sex == 1 then
        asset = "nm_"
    else
        asset = "nw_"
    end

    if type ~= 2 then
        asset = asset .. SDBCardType[type]
        AudioManager.PlaySound(SDBBundleName.sdbsound, asset)
    else
        --平点暂时不播放音效
        --asset = asset ..SDBPointType[point]
    end
end

--播放道具音效
function SDBResourcesMgr.PlayPropSound(fileId)
    local asset = "MoveItem" .. fileId
    AudioManager.PlaySound(SDBBundleName.faceSound, asset)
end

--获取表情动画
function SDBResourcesMgr.GetFaceAni(assertName, backFuns)
    if faceAniPrefab[assertName] == nil then
        if loadFacePrefabsPrefab == nil then
            LogError(">>>>>>>>>>>>>>>>>>    表情动画父物体为空")
            return
        end
        local faceTra = loadFacePrefabsPrefab:Find(assertName)
        faceAniPrefab[assertName] = faceTra
        if backFuns ~= nil then
            backFuns(faceTra)
        end
    else
        if backFuns ~= nil then
            backFuns(faceAniPrefab[assertName])
        end
    end
end

--获取飞金币的克隆体
function SDBResourcesMgr.GetFlyGoldItem(perfab, parent, name)
    local item
    if #flyGoldGos > 0 then
        item = flyGoldGos[1]
        item.transform:SetParent(parent)
        UIUtil.SetActive(item, true)
        table.remove(flyGoldGos, 1)
    else
        item = CreateGO(perfab, parent, name or "item")
    end
    return item
end

--回收金币克隆体
function SDBResourcesMgr.RecycleFlyGoldItem(item)
    UIUtil.SetActive(item, false)
    table.insert(flyGoldGos, item)
end

--获取飞牌的克隆体
function SDBResourcesMgr.GetFlyCardItem(perfab, parent, name)
    local item
    if #flyCards > 0 then
        item = flyCards[1]
        item.transform:SetParent(parent)
        UIUtil.SetActive(item, true)
        table.remove(flyCards, 1)
    else
        item = CreateGO(perfab.gameObject, parent, name or "item")
    end
    return item
end

--回收飞牌克隆体
function SDBResourcesMgr.RecycleFlyCardsItem(item)
    UIUtil.SetActive(item, false)
    table.insert(flyCards, item)
end