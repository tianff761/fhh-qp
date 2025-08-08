
-------------名字------------
SDBLoadResPanel = ClassPanel("SDBLoadResPanel")
local this = SDBLoadResPanel
local mSelf = nil
-----------------------------
function SDBLoadResPanel:OnInitUI()
    mSelf = self
    mSelf:InitPanel()
    Log(">>>>>>>>>>>>>>>>>>>       加载游戏资源结束")
end

function SDBLoadResPanel:InitPanel()
    local transform = self.transform
    local loadCardsTrans = transform:Find("LoadCards")
	local loadCardSprites = loadCardsTrans:Find("LoadCardSprites"):GetComponent("UISpriteAtlas")
	local loadResultSprites = loadCardsTrans:Find("LoadResultSprites"):GetComponent("UISpriteAtlas")
    local loadShowImage = transform:Find("LoadShowImage"):GetComponent("UISpriteAtlas")
	--设置扑克牌值资源
    SDBResourcesMgr.LoadPokerCards(loadCardSprites.sprites)
	SDBResourcesMgr.LoadResultSprites(loadResultSprites.sprites)
    SDBResourcesMgr.LoadShowImage(loadShowImage.sprites)

	-- local loadFacePerfabs = transform:Find("LoadFacePerfabs")
    -- SDBResourcesMgr.LoadFacePrefabsParent(loadFacePerfabs)
    
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
function SDBLoadResPanel.GetWinEff()
    return mSelf.SixWinEff
end

--获取庄家动画
function SDBLoadResPanel.GetBankerEff()
    return mSelf.SixBankerEff
end

--获取要牌中动画
function SDBLoadResPanel.GetYaoPaiZhongEff()
    return mSelf.SixYaoPaiZhongEff
end

--获取爆牌动画
function SDBLoadResPanel.GetBlastCardEff()
    return mSelf.blastCardEff
end

--获取亮牌动画
function SDBLoadResPanel.GetDianShuEff()
    return mSelf.dianShuEff
end

function SDBLoadResPanel:OnDestroy(  )
    mSelf = nil
end