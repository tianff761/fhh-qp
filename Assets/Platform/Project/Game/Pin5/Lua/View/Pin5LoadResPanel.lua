
-------------名字------------
Pin5LoadResPanel = ClassPanel("Pin5LoadResPanel")
local this = Pin5LoadResPanel
local mSelf = nil
-----------------------------
function Pin5LoadResPanel:OnInitUI()
    mSelf = self
    mSelf:InitPanel()
    Log(">>>>>>>>>>>>>>>>>>>       加载游戏资源结束")
end

function Pin5LoadResPanel:InitPanel()
    local transform = self.transform
    local loadCardsTrans = transform:Find("LoadCards")
    local loadCardSprites = loadCardsTrans:Find("LoadCardSprites"):GetComponent("UISpriteAtlas")
    local loadRubSprites = loadCardsTrans:Find("LoadRubSprites"):GetComponent("UISpriteAtlas")
	local loadResultSprites = loadCardsTrans:Find("LoadResultSprites"):GetComponent("UISpriteAtlas")
	local loadResultBgAtlas = loadCardsTrans:Find("LoadResultBgSprites"):GetComponent("UISpriteAtlas")
    local loadShowImage = transform:Find("LoadShowImage"):GetComponent("UISpriteAtlas")
    local loadCardAni = transform:Find("ResultsEffects"):GetComponent("GameObjectsHelper")

	--设置扑克牌值资源
    Pin5ResourcesMgr.LoadPokerCards(loadCardSprites.sprites)
    Pin5ResourcesMgr.LoadRubPokerCards(loadRubSprites.sprites)
	Pin5ResourcesMgr.LoadResultSprites(loadResultSprites.sprites)
    Pin5ResourcesMgr.LoadShowSprites(loadShowImage.sprites)
    Pin5ResourcesMgr.LoadCardAni(loadCardAni.objects)
    Pin5ResourcesMgr.LoadResultBgSprites(loadResultBgAtlas)
    ------------------------------玩家特效--------------------------
    local playerEffs = transform:Find("PlayerEff")
    local SixPlayerEff = playerEffs:Find("SixPlayer")
    self.SixWinEff = SixPlayerEff:Find("Win")
    
    self.SixBankerEff = SixPlayerEff:Find("Banker")
    self.SixYaoPaiZhongEff = SixPlayerEff:Find("YaoPaiZhong")
    self.blastCardEff = playerEffs:Find("BlastCardEff")
    self.dianShuEff = playerEffs:Find("DianShuEff")
end 

--===========================================================================道具
--获取赢动画
function Pin5LoadResPanel.GetWinEff()
    return mSelf.SixWinEff
end

--获取庄家动画
function Pin5LoadResPanel.GetBankerEff()
    return mSelf.SixBankerEff
end

--获取要牌中动画
function Pin5LoadResPanel.GetYaoPaiZhongEff()
    return mSelf.SixYaoPaiZhongEff
end

--获取爆牌动画
function Pin5LoadResPanel.GetBlastCardEff()
    return mSelf.blastCardEff
end

--获取亮牌动画
function Pin5LoadResPanel.GetDianShuEff()
    return mSelf.dianShuEff
end

function Pin5LoadResPanel:OnDestroy(  )
    mSelf = nil
end

function Pin5LoadResPanel.CreateResultGoldItem()
    local prefab = Pin5ResourcesMgr.GetCardAni("AnimGold")
    local item = {}
    item.gameObject = CreateGO(prefab, mSelf.transform)
    item.transform = item.gameObject.transform
    UIUtil.SetLocalScale(item.transform, 1, 1, 1)
    return item
end