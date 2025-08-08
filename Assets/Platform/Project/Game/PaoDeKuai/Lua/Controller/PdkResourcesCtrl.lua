PdkResourcesCtrl = ClassLuaComponent("PdkResourcesCtrl")
local this = PdkResourcesCtrl
PdkResourcesCtrl.pokerList = {}
PdkResourcesCtrl.pokerPrefab = {}
PdkResourcesCtrl.pokerAtlas = {} --牌组的集合


function PdkResourcesCtrl:Awake()
    this = self
    this.resources = self.transform
    local selfHandPoker = self.transform:Find("SelfHandPoker").gameObject
    local playerOutCard = self.transform:Find("PlayerOutCard").gameObject
    local playerHandPoker = self.transform:Find("PlayerHandPoker").gameObject
    local playerRemainCard = self.transform:Find("PlayerRemainCard").gameObject
    this.Init(PdkPrefabName.SelfHandPoker, selfHandPoker)
    this.Init(PdkPrefabName.PlayerOutPoker, playerOutCard)
    this.Init(PdkPrefabName.PlayerHandPoker, playerHandPoker)
    this.Init(PdkPrefabName.PlayerRemainCard, playerRemainCard)

    --初始化所有牌面图片
    local spriteAtlas = self.transform:Find("PokerAtlas"):GetComponent("UISpriteAtlas")
    local tempSprites = spriteAtlas.sprites:ToTable()
    local sprite = nil
    for i = 1, #tempSprites do
        sprite = tempSprites[i]
        this.pokerAtlas[tonumber(sprite.name)] = sprite
    end
end

--初始化预制体
function PdkResourcesCtrl.Init(name, prefab)
    this.pokerPrefab[name] = prefab
end

--获取预制体
function PdkResourcesCtrl.GetPoker(name, parentTrans)
    if IsNil(this.pokerPrefab[name]) then
        Log("<<<<<<<<<<<<<<<<<<<<<<<<加载的预制体不存在<<<<<<<<<<", name)
        return
    end
    local poker = nil
    if IsNil(this.pokerList[name]) then
        this.pokerList[name] = {}
    end
    if GetTableSize(this.pokerList[name]) > 0 then
        poker = table.remove(this.pokerList[name], 1)
        poker.transform:SetParent(parentTrans)
    else
        poker = CreateGO(this.pokerPrefab[name], parentTrans, name)
    end
    UIUtil.SetActive(poker, true)
    UIUtil.SetAsLastSibling(poker.transform)
    return poker
end

--放入
function PdkResourcesCtrl.PutPoker(poker)
    local name = poker.name
    if IsNil(this.pokerList[name]) then
        this.pokerList[name] = {}
    end
    table.insert(this.pokerList[name], poker)
    poker.transform:SetParent(this.resources)
    UIUtil.SetActive(poker, false)
end

-- --从对象池里取对象
-- function PdkResourcesCtrl.GetHandPoker(parentTrans)
--     local poker = nil
--     if GetTableSize(this.handPokerList) > 0 then
--         poker = table.remove(this.handPokerList, 1)
--         poker.transform:SetParent(parentTrans)
--     else
--         poker = CreateGO(this.handPokerPrefab, parentTrans)
--     end
--     return poker
-- end

-- --放入扑克到对象池
-- function PdkResourcesCtrl.PutHandPoker(poker)
--     table.insert(this.handPokerList, poker)
-- end

-- --从对象池里取出打出的牌
-- function PdkResourcesCtrl.GetOutPoker(parentTrans)
--     local poker = nil
--     if GetTableSize(this.outPokerList) > 0 then
--         poker = table.remove(this.outPokerList, 1)
--         poker.transform:SetParent(parentTrans)
--     else
--         poker = CreateGO(this.handPokerPrefab, parentTrans)
--     end
--     return poker
-- end

-- --放入打出的牌
-- function PdkResourcesCtrl.PutOutPoker(poker)
--     table.insert(this.outPokerList, poker)
-- end
