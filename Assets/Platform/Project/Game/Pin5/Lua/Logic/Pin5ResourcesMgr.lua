--资源初始化状态类型
Pin5ResourcesInitStateType = {
    --没有初始化
    None = 0,
    --初始化中
    Initializing = 1,
    --已经初始化
    Initialized = 2,
}

--资源管理
Pin5ResourcesMgr = {
    --初始化完成标识
    initState = 0,
    --资源初始化完成的回调
    onInitCompleted = nil,
}

local this = Pin5ResourcesMgr

--手牌资源
local cardSprites = {}
--搓牌资源
local rubCardSprites = {}
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

local isLoadPin5DeskPanel = false
local isLoadRoomPanel = false
local isLoadOperPanel = false
local isLoadResPanel = false

local isOpenRoom = false

local loadFacePrefabsPrefab = nil

local showSprites = {}

local cardAnis = {}

local resultBgAtlas = {}

--牌局操作音效
Pin5GameSoundType = {
    --抢庄
    ROB = 0,
    --不抢庄
    NOROB = 1,
    --准备
    READY = 2,
}

--牌局音效
Pin5GameEffSoundType = {
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
    --旧发牌
    OldEFFDEAL = "fapai",
    --发牌
    EFFDEAL = "faxuanpai",
    --成为庄家
    BecomeBanker = "zhuangjiaziyang",
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
function Pin5ResourcesMgr.Initialize(isShow)
    isOpenRoom = isShow
    if this.initState == Pin5ResourcesInitStateType.Initialized then
        if this.onInitCompleted ~= nil then
            this.onInitCompleted()
        end
        return
    elseif this.initState == Pin5ResourcesInitStateType.Initializing then
        return
    end

    this.initState = Pin5ResourcesInitStateType.Initializing

    this.LoadPanels()
end

--设置普通扑克牌值
function Pin5ResourcesMgr.LoadPokerCards(sprites)
    local mSprites = sprites:ToTable()
    for i = 1, #mSprites do
        cardSprites[mSprites[i].name] = mSprites[i]
    end
end

--设置搓牌扑克牌值
function Pin5ResourcesMgr.LoadRubPokerCards(sprites)
    local mSprites = sprites:ToTable()
    for i = 1, #mSprites do
        rubCardSprites[mSprites[i].name] = mSprites[i]
    end
end

--设置结算点数资源
function Pin5ResourcesMgr.LoadResultSprites(sprites)
    local mSprites = sprites:ToTable()
    for i = 1, #mSprites do
        resultSprites[mSprites[i].name] = mSprites[i]
    end
end

--设置表情动画父物体
function Pin5ResourcesMgr.LoadFacePrefabsParent(Prefab)
    loadFacePrefabsPrefab = Prefab
end

function Pin5ResourcesMgr.LoadShowSprites(sprites)
    local mSprites = sprites:ToTable()
    for i = 1, #mSprites do
        showSprites[mSprites[i].name] = mSprites[i]
    end
end

function Pin5ResourcesMgr.LoadCardAni(objects)
    local mObjects = objects:ToTable()
    for i = 1, #mObjects do
        cardAnis[mObjects[i].name] = mObjects[i]
    end
end

function Pin5ResourcesMgr.LoadResultBgSprites(atlas)
    resultBgAtlas = atlas
end

--清空资源信息
function Pin5ResourcesMgr.Clear()
    this.onInitCompleted = nil
    faceAniPrefab = {}
    resultSprites = {}
    deskSprite = {}
    flyGoldGos = {}
    flyCards = {}
    cardSprites = {}
    rubCardSprites = {}
    showSprites = {}
    cardAnis = {}
    isLoadPin5DeskPanel = false
    isLoadRoomPanel = false
    isLoadOperPanel = false
    isLoadResPanel = false
end

--加载面板
function Pin5ResourcesMgr.LoadPanels()
    ResourcesManager.PreloadPrefabs(Pin5PanelConfig.Room.bundleName, { Pin5PanelConfig.Room.assetName }, this.OnRoomPanelLoadCompleted, {})
    ResourcesManager.PreloadPrefabs(Pin5PanelConfig.Operation.bundleName, { Pin5PanelConfig.Operation.assetName }, this.OnisLoadOperPanelLoadCompleted, {})
    ResourcesManager.PreloadPrefabs(Pin5PanelConfig.Pin5Desk.bundleName, { Pin5PanelConfig.Pin5Desk.assetName }, this.OnPin5DeskPanelLoadCompleted, {})
    ResourcesManager.PreloadPrefabs(Pin5PanelConfig.LoadRes.bundleName, { Pin5PanelConfig.LoadRes.assetName }, this.OnPin5LoadResPanelLoadCompleted, {})
end

--加载桌面
function Pin5ResourcesMgr.LoadDesk(type, panelImage)
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

function Pin5ResourcesMgr.OnPin5DeskPanelLoadCompleted(objs)
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> OnPin5DeskPanelLoadCompleted")
    isLoadPin5DeskPanel = true
    this.HandlePanelsLoadCompleted()
end

function Pin5ResourcesMgr.OnRoomPanelLoadCompleted(objs)
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> OnRoomPanelLoadCompleted")
    isLoadRoomPanel = true
    this.HandlePanelsLoadCompleted()
end

function Pin5ResourcesMgr.OnisLoadOperPanelLoadCompleted(objs)
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> OnisLoadOperPanelLoadCompleted")
    isLoadOperPanel = true
    this.HandlePanelsLoadCompleted()
end

function Pin5ResourcesMgr.OnPin5LoadResPanelLoadCompleted()
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> OnPin5LoadResPanelLoadCompleted")
    isLoadResPanel = true
    this.HandlePanelsLoadCompleted()
end

function Pin5ResourcesMgr.HandlePanelsLoadCompleted()
    this.initState = Pin5ResourcesInitStateType.Initialized
    if isLoadPin5DeskPanel and isLoadRoomPanel and isLoadOperPanel and isLoadResPanel and isOpenRoom then
        if this.onInitCompleted ~= nil then
            this.onInitCompleted()
        end
    end
end

--==========================================================================
--获取手牌
function Pin5ResourcesMgr.GetHandleCardSprite(assetName)
    return cardSprites[tostring(assetName)]
end

--获取搓牌扑克牌值
function Pin5ResourcesMgr.GetRubCardSprite(assetName)
    return rubCardSprites[tostring(assetName)]
end

--获取搓牌牌背 --传入牌背颜色
function Pin5ResourcesMgr.GetRubCardBack()
    return this.GetRubCardSprite("pai2_bg")
    -- return this.GetRubCardSprite("pin5-cardback-" .. Pin5RoomData.cardColor)
end

--获取牌背 --传入牌背颜色
function Pin5ResourcesMgr.GetCardBack()
    return this.GetHandleCardSprite("bg-" .. Pin5RoomData.cardColor)
end

--获取结算点数
function Pin5ResourcesMgr.GetResultSprite(assetName)
    return resultSprites[assetName]
end

function Pin5ResourcesMgr.GetResultBgSprite(resultSpriteName)
    local strArr = string.split(resultSpriteName, "_")
    local pointType = tonumber(strArr[3])
    if pointType == 0 then
        return resultBgAtlas:GetSpriteByName("pin5-DN_NN_DiBan1")
    elseif pointType >= 1 and pointType <= 7 then
        return resultBgAtlas:GetSpriteByName("pin5-DN_NN_DiBan2")
    elseif pointType >= 8 and pointType <= 10 then
        return resultBgAtlas:GetSpriteByName("pin5-DN_NN_DiBan3")
    else
        return resultBgAtlas:GetSpriteByName("pin5-DN_NN_DiBan4")
    end
end

--获取结果的动画名称
function Pin5ResourcesMgr.GetResultAnimName(point)
    local temp = Pin5CardTypeAnimName[Pin5RoomData.fanBeiRuleValue]
    if temp ~= nil then
        return temp[point]
    end
    return nil
end

--获取显示的图片精灵
function Pin5ResourcesMgr.GetShowSprite(name)
    return showSprites[name]
end

--
function Pin5ResourcesMgr.GetCardAni(name)
    return cardAnis[name]
end


--播放玩家操作音效
function Pin5ResourcesMgr.PlayGameOperSound(type, playerId)
    ---不播放语音

    --Log("开始播放操作音效>>>>>>>>>>>>>", type)
    --local asset = "f0_"
    --
    --local playerData = Pin5RoomData.GetPlayerDataById(playerId)
    --
    --if type == Pin5GameSoundType.ROB then
    --    asset = asset .. "qiangzhuang"
    --elseif type == Pin5GameSoundType.NOROB then
    --    asset = asset .. "buqiang"
    --elseif type == Pin5GameSoundType.READY then
    --    asset = asset .. "ready"
    --end
    --
    --AudioManager.PlaySound(Pin5BundleName.pin5sound, asset)
end

--播放流程音效
function Pin5ResourcesMgr.PlayGameSound(type)
    AudioManager.PlaySound(Pin5BundleName.pin5sound, type)
end

--播放流程音效
function Pin5ResourcesMgr.PlayFaPaiGameSound()
    this.PlayGameSound(Pin5GameEffSoundType.EFFDEAL)
end

--手牌结果
function Pin5ResourcesMgr.PlayCardPointSound(playerId, type)
    local asset;
    local playerData = Pin5RoomData.GetPlayerDataById(playerId)
    -- if playerData.sex == 1 then
    --     asset = "f0_"
    -- else
    --     asset = "f1_"
    -- end
    asset = "f0_"

    asset = asset .. "nn" .. type
    AudioManager.PlaySound(Pin5BundleName.pin5sound, asset)
end

function Pin5ResourcesMgr.PlayCardPointMaleSound(type)
    --LogError("<color=aqua>type</color>", type)
    local asset = "f0_nn" .. type
    AudioManager.PlaySound(Pin5BundleName.pin5sound, asset)
end

function Pin5ResourcesMgr.PlayCardPointFeMaleSound(type)
    --LogError("<color=aqua>type</color>", type)
    local asset = "female_nn" .. type
    AudioManager.PlaySound(Pin5BundleName.pin5sound, asset)
end

--播放道具音效
function Pin5ResourcesMgr.PlayPropSound(fileId)
    local asset = "MoveItem" .. fileId
    AudioManager.PlaySound(Pin5BundleName.faceSound, asset)
end

--获取表情动画
function Pin5ResourcesMgr.GetFaceAni(assertName, backFuns)
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
function Pin5ResourcesMgr.GetFlyGoldItem(perfab, parent, name)
    local item
    if #flyGoldGos > 0 then
        item = flyGoldGos[1]
        item.transform:SetParent(parent)
        UIUtil.SetActive(item.gameObject, true)
        table.remove(flyGoldGos, 1)
    else
        item = {}
        item.gameObject = CreateGO(perfab, parent, name or "item")
        item.transform = item.gameObject.transform
        item.image = item.transform:GetComponent(TypeImage)
    end
    return item
end

--回收金币克隆体
function Pin5ResourcesMgr.RecycleFlyGoldItem(item)
    UIUtil.SetActive(item.gameObject, false)
    table.insert(flyGoldGos, item)
end

--获取飞牌的克隆体
function Pin5ResourcesMgr.GetFlyCardItem(perfab, parent, name)
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
function Pin5ResourcesMgr.RecycleFlyCardsItem(item)
    UIUtil.SetActive(item, false)
    table.insert(flyCards, item)
end