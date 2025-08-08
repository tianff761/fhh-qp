
-------------名字------------
LYCLoadResPanel = ClassPanel("LYCLoadResPanel")
local this = LYCLoadResPanel
local mSelf = nil
-----------------------------
function LYCLoadResPanel:OnInitUI()
    mSelf = self
    mSelf:InitPanel()
    Log(">>>>>>>>>>>>>>>>>>>       加载游戏资源结束")
end

function LYCLoadResPanel:InitPanel()
    local transform = self.transform
    local loadCardsTrans = transform:Find("LoadCards")
    local loadCardSprites = loadCardsTrans:Find("LoadCardSprites"):GetComponent("UISpriteAtlas")
    local loadRubSprites = loadCardsTrans:Find("LoadRubSprites"):GetComponent("UISpriteAtlas")
	local loadResultSprites = loadCardsTrans:Find("LoadResultSprites"):GetComponent("UISpriteAtlas")
	local LoadResultBgSprites = loadCardsTrans:Find("LoadResultBgSprites"):GetComponent("UISpriteAtlas")
    local loadShowImage = transform:Find("LoadShowImage"):GetComponent("UISpriteAtlas")
    local loadCardAni = transform:Find("ResultsEffects"):GetComponent("GameObjectsHelper")

	--设置扑克牌值资源
    LYCResourcesMgr.LoadPokerCards(loadCardSprites.sprites)
    LYCResourcesMgr.LoadRubPokerCards(loadRubSprites.sprites)
	LYCResourcesMgr.LoadResultSprites(loadResultSprites.sprites)
    LYCResourcesMgr.LoadShowImage(loadShowImage.sprites)
    LYCResourcesMgr.LoadCardAni(loadCardAni.objects)
    LYCResourcesMgr.LoadResultBg(LoadResultBgSprites)
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
function LYCLoadResPanel.GetWinEff()
    return mSelf.SixWinEff
end

--获取庄家动画
function LYCLoadResPanel.GetBankerEff()
    return mSelf.SixBankerEff
end

--获取要牌中动画
function LYCLoadResPanel.GetYaoPaiZhongEff()
    return mSelf.SixYaoPaiZhongEff
end

--获取爆牌动画
function LYCLoadResPanel.GetBlastCardEff()
    return mSelf.blastCardEff
end

--获取亮牌动画
function LYCLoadResPanel.GetDianShuEff()
    return mSelf.dianShuEff
end

function LYCLoadResPanel:OnDestroy()
    mSelf = nil
end