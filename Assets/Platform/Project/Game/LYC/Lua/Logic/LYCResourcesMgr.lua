--资源初始化状态类型
LYCResourcesInitStateType = {
    --没有初始化
    None = 0,
    --初始化中
    Initializing = 1,
    --已经初始化
    Initialized = 2,
}

--资源管理
LYCResourcesMgr = {
    --初始化完成标识
    initState = 0,
    --资源初始化完成的回调
    onInitCompleted = nil,
}

local this = LYCResourcesMgr

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

local isLoadLYCDeskPanel = false
local isLoadRoomPanel = false
local isLoadOperPanel = false
local isLoadResPanel = false

local isOpenRoom = false

local loadFacePrefabsPrefab = nil

local showImage = {}  --特效

local cardAnis = {}

local ResultBgSprites = {}

--牌局操作音效
LYCGameSoundType = {
    --抢庄
    ROB = 0,
    --不抢庄
    NOROB = 1,
    --准备
    READY = 2,
}

--牌局音效
LYCGameEffSoundType = {
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
function LYCResourcesMgr.Initialize(isShow)
    isOpenRoom = isShow
    if this.initState == LYCResourcesInitStateType.Initialized then
        if this.onInitCompleted ~= nil then
            this.onInitCompleted()
        end
        return
    elseif this.initState == LYCResourcesInitStateType.Initializing then
        return
    end

    this.initState = LYCResourcesInitStateType.Initializing

    this.LoadPanels()
end

--设置普通扑克牌值
function LYCResourcesMgr.LoadPokerCards(sprites)
    local mSprites = sprites:ToTable()
    for i = 1, #mSprites do
        cardSprites[mSprites[i].name] = mSprites[i]
    end
end

--设置搓牌扑克牌值
function LYCResourcesMgr.LoadRubPokerCards(sprites)
    local mSprites = sprites:ToTable()
    for i = 1, #mSprites do
        rubCardSprites[mSprites[i].name] = mSprites[i]
    end
end

--设置结算点数资源
function LYCResourcesMgr.LoadResultSprites(sprites)
    local mSprites = sprites:ToTable()
    for i = 1, #mSprites do
        resultSprites[mSprites[i].name] = mSprites[i]
    end
end

--设置表情动画父物体
function LYCResourcesMgr.LoadFacePrefabsParent(Prefab)
    loadFacePrefabsPrefab = Prefab
end

function LYCResourcesMgr.LoadShowImage(sprites)
    local mSprites = sprites:ToTable()
    for i = 1, #mSprites do
        showImage[mSprites[i].name] = mSprites[i]
    end
end

function LYCResourcesMgr.LoadCardAni(objects)
    local mObjects = objects:ToTable()
    for i = 1, #mObjects do
        cardAnis[mObjects[i].name] = mObjects[i]
    end
end

function LYCResourcesMgr.LoadResultBg(LoadResultBgSprites)
    ResultBgSprites = LoadResultBgSprites
end

--清空资源信息
function LYCResourcesMgr.Clear()
    this.onInitCompleted = nil
    faceAniPrefab = {}
    resultSprites = {}
    deskSprite = {}
    flyGoldGos = {}
    flyCards = {}
    cardSprites = {}
    rubCardSprites = {}
    showImage = {}
    cardAnis = {}
    isLoadLYCDeskPanel = false
    isLoadRoomPanel = false
    isLoadOperPanel = false
    isLoadResPanel = false
end

--加载面板
function LYCResourcesMgr.LoadPanels()
    ResourcesManager.PreloadPrefabs(LYCPanelConfig.Room.bundleName, { LYCPanelConfig.Room.assetName }, this.OnRoomPanelLoadCompleted, {})
    ResourcesManager.PreloadPrefabs(LYCPanelConfig.Operation.bundleName, { LYCPanelConfig.Operation.assetName }, this.OnisLoadOperPanelLoadCompleted, {})
    ResourcesManager.PreloadPrefabs(LYCPanelConfig.LYCDesk.bundleName, { LYCPanelConfig.LYCDesk.assetName }, this.OnLYCDeskPanelLoadCompleted, {})
    ResourcesManager.PreloadPrefabs(LYCPanelConfig.LoadRes.bundleName, { LYCPanelConfig.LoadRes.assetName }, this.OnLYCLoadResPanelLoadCompleted, {})
end

--加载桌面
function LYCResourcesMgr.LoadDesk(type, panelImage)
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

function LYCResourcesMgr.OnLYCDeskPanelLoadCompleted(objs)
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> OnLYCDeskPanelLoadCompleted")
    isLoadLYCDeskPanel = true
    this.HandlePanelsLoadCompleted()
end

function LYCResourcesMgr.OnRoomPanelLoadCompleted(objs)
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> OnRoomPanelLoadCompleted")
    isLoadRoomPanel = true
    this.HandlePanelsLoadCompleted()
end

function LYCResourcesMgr.OnisLoadOperPanelLoadCompleted(objs)
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> OnisLoadOperPanelLoadCompleted")
    isLoadOperPanel = true
    this.HandlePanelsLoadCompleted()
end

function LYCResourcesMgr.OnLYCLoadResPanelLoadCompleted()
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> OnLYCLoadResPanelLoadCompleted")
    isLoadResPanel = true
    this.HandlePanelsLoadCompleted()
end

function LYCResourcesMgr.HandlePanelsLoadCompleted()
    this.initState = LYCResourcesInitStateType.Initialized
    if isLoadLYCDeskPanel and isLoadRoomPanel and isLoadOperPanel and isLoadResPanel and isOpenRoom then
        if this.onInitCompleted ~= nil then
            this.onInitCompleted()
        end
    end
end

--==========================================================================
--获取手牌
function LYCResourcesMgr.GetHandleCardSprite(assetName)
    return cardSprites[tostring(assetName)]
end

--获取搓牌扑克牌值
function LYCResourcesMgr.GetRubCardSprite(assetName)
    return rubCardSprites[tostring(assetName)]
end

--获取搓牌牌背 --传入牌背颜色
function LYCResourcesMgr.GetRubCardBack()
    return this.GetRubCardSprite("card_sh_b_" .. LYCRoomData.cardColor)
end

--获取牌背 --传入牌背颜色
function LYCResourcesMgr.GetCardBack()
    return this.GetHandleCardSprite("card_sh_b_" .. LYCRoomData.cardColor)
end

--获取结算点数
function LYCResourcesMgr.GetResultSprite(assetName)
    return resultSprites[assetName]
end

function LYCResourcesMgr.GetResultBgSprite(resultSpriteName)
    local strArr = string.split(resultSpriteName, "_")
    --local pointType = tonumber(strArr[3])
    --if pointType == 0 then
    --    return ResultBgSprites:GetSpriteByName("niun_scorebg1")
    --elseif pointType >= 1 and pointType <= 7 then
    --    return ResultBgSprites:GetSpriteByName("niun_scorebg2")
    --elseif pointType >= 8 and pointType <= 10 then
    --    return ResultBgSprites:GetSpriteByName("niun_scorebg3")
    --else
    --    return ResultBgSprites:GetSpriteByName("niun_scorebg4")
    --end
end

--
function LYCResourcesMgr.GetShowPng(name)
    return showImage[name]
end

--
function LYCResourcesMgr.GetCardAni(name)
    return cardAnis[name]
end


--播放玩家操作音效
function LYCResourcesMgr.PlayGameOperSound(type, playerId)
    ---不播放语音

    --Log("开始播放操作音效>>>>>>>>>>>>>", type)
    --local asset = "f0_"
    --
    --local playerData = LYCRoomData.GetPlayerDataById(playerId)
    --
    --if type == LYCGameSoundType.ROB then
    --    asset = asset .. "qiangzhuang"
    --elseif type == LYCGameSoundType.NOROB then
    --    asset = asset .. "buqiang"
    --elseif type == LYCGameSoundType.READY then
    --    asset = asset .. "ready"
    --end
    --
    --AudioManager.PlaySound(LYCBundleName.lycsound, asset)
end

--播放流程音效
function LYCResourcesMgr.PlayGameSound(type)
    AudioManager.PlaySound(LYCBundleName.lycsound, type)
end

--播放流程音效
function LYCResourcesMgr.PlayFaPaiGameSound()
    this.PlayGameSound(LYCGameEffSoundType.EFFDEAL)
end

--手牌结果
function LYCResourcesMgr.PlayCardPointSound(playerId, type)
    local asset;
    local playerData = LYCRoomData.GetPlayerDataById(playerId)
    -- if playerData.sex == 1 then
    --     asset = "f0_"
    -- else
    --     asset = "f1_"
    -- end
    asset = "f0_"

    asset = asset .. "nn" .. type
    AudioManager.PlaySound(LYCBundleName.lycsound, asset)
end

function LYCResourcesMgr.PlayCardPointMaleSound(type)
    --LogError("<color=aqua>type</color>", type)
    local asset = "f0_nn" .. type
    AudioManager.PlaySound(LYCBundleName.lycsound, asset)
end

function LYCResourcesMgr.PlayCardPointFeMaleSound(type)
    --LogError("<color=aqua>type</color>", type)
    local asset = "female_nn" .. type
    AudioManager.PlaySound(LYCBundleName.lycsound, asset)
end

---@param point number 点数
---@param special number LYC特殊牌型 COMM = 0,-- 无   SHUANGYAN = 1, -- 双腌    SANYAN = 2, -- 三腌    ZHADAN = 3,-- 炸弹
function LYCResourcesMgr.PlayLYCCardTypeSound(point, special)
    local assetName = ""
    if special == 0 then
        assetName = "dan" .. point
    elseif special == 1 then
        assetName = "2yan" .. point
    elseif special == 2 then
        assetName = "3yan" .. point
    elseif special == 3 then
        assetName = "ZhaDan"
    end
    AudioManager.PlaySound(LYCBundleName.lycsound, assetName)
end

function LYCResourcesMgr.PlayLYCGameSound(assetName)
    AudioManager.PlaySound(LYCBundleName.lycsound, assetName)
end

--播放道具音效
function LYCResourcesMgr.PlayPropSound(fileId)
    local asset = "MoveItem" .. fileId
    AudioManager.PlaySound(LYCBundleName.faceSound, asset)
end

--获取表情动画
function LYCResourcesMgr.GetFaceAni(assertName, backFuns)
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
function LYCResourcesMgr.GetFlyGoldItem(perfab, parent, name)
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
function LYCResourcesMgr.RecycleFlyGoldItem(item)
    UIUtil.SetActive(item.gameObject, false)
    table.insert(flyGoldGos, item)
end

--获取飞牌的克隆体
function LYCResourcesMgr.GetFlyCardItem(perfab, parent, name)
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
function LYCResourcesMgr.RecycleFlyCardsItem(item)
    UIUtil.SetActive(item, false)
    table.insert(flyCards, item)
end