PdkAudioCtrl = {}
local this = PdkAudioCtrl

PdkAudioCtrl.CardType = {
    [PdkPokerType.Single] = "single_",
    [PdkPokerType.Double] = "pair_",
    [PdkPokerType.Three] = "sanzhang",
    --[PdkPokerType.ThreeAndOne] = "3dai1",
    [PdkPokerType.ThreeAndTwo] = "sandaier",
    [PdkPokerType.Straight] = "shunzi",
    [PdkPokerType.DoubleStraight] = "liandui",
    [PdkPokerType.Airplane] = "feiji",
    [PdkPokerType.AirplaneAndOne] = "feiji_cb",
    [PdkPokerType.AirplaneAndTwo] = "feiji_cb",
    [PdkPokerType.Bomb] = "bomb",
    [PdkPokerType.BombAndSingle] = "4dai2",
    [PdkPokerType.BombAndDouble] = "4dai2",
    [PdkPokerType.BombAndThree] = "4dai2",
    [PdkPokerType.Four] = "sizhang"
}
PdkAudioCtrl.OperateGender = {
    Man = "M_",
    Woman = "W_"
}

function PdkAudioCtrl.PlayAudio(name)
    AudioManager.PlaySound(PdkBundleName.Audio, name)
end

--选择牌
function PdkAudioCtrl.PlaySelectCard()
    this.PlayAudio("poker_select")
end

--播放出牌音效
function PdkAudioCtrl.PlayOutCard()
    this.PlayAudio("cardOut")
end

--播放飞机音效
function PdkAudioCtrl.PlayAirplane()
    this.PlayAudio("airplane")
end

--播放顺子音效
function PdkAudioCtrl.PlayStraight()
    this.PlayAudio("shunzi")
end

--播放炸弹音效
function PdkAudioCtrl.PlayBomb()
    this.PlayAudio("bomb")
end

--播放Pass
function PdkAudioCtrl.PlayPass(gender)
    if gender == Global.GenderType.Male then
        this.PlayAudio("M_deal_pass_yaobuqi")
    else
        this.PlayAudio("W_deal_pass_yaobuqi")
    end
end

--报单
function PdkAudioCtrl.PlayBaoDan(gender)
    if gender == Global.GenderType.Male then
        this.PlayAudio("M_deal_last_one")
    else
        this.PlayAudio("W_deal_last_one")
    end
end

--播放背景音乐
function PdkAudioCtrl.PlayBgMusic()
    AudioManager.PlayBackgroud(PdkBundleName.Music, "bgm2")
end

--播放背景音乐（报单）
function PdkAudioCtrl.PlayBgMusicBaoDan()
    AudioManager.PlayBackgroud(PdkBundleName.Music, "bgm1")
end

--播放胜利音效
function PdkAudioCtrl.PlayWin()
    this.PlayAudio("bgm_win")
end

--播放失败音效
function PdkAudioCtrl.PlayLoss()
    this.PlayAudio("bgm_lose")
end

--播放显示庄家
function PdkAudioCtrl.PlayBanker()
    this.PlayAudio("poker_showB_start")
end

--发牌
function PdkAudioCtrl.PlayDealCard()
    this.PlayAudio("poker_distribute")
end

--翻牌
function PdkAudioCtrl.PlayShowCard()
    -- this.PlayAudio("poker_reverseback")
end

--炸弹加分
function PdkAudioCtrl.PlayBombCoin()
    this.PlayAudio("bomb_coin")
end

--倒计时
function PdkAudioCtrl.PlayDownTime()
    this.PlayAudio("pdk_djs")
end

--先出
function PdkAudioCtrl.PlayFirstOutCard(gender)
    if gender == Global.GenderType.Male then
        this.PlayAudio("M_tip_deal_first")
    else
        this.PlayAudio("W_tip_deal_first")
    end
end

--播放牌音效
function PdkAudioCtrl.PlayCardSound(gender, cardType, value)
    if IsNil(PdkAudioCtrl.CardType[cardType]) then
        return
    end
    local assetName = ""
    local genderStr = ""

    --性别
    if gender == Global.GenderType.Male then
        genderStr = PdkAudioCtrl.OperateGender.Man
    else
        genderStr = PdkAudioCtrl.OperateGender.Woman
    end
    if value ~= nil then
        assetName = genderStr .. PdkAudioCtrl.CardType[cardType] .. value
    else
        assetName = genderStr .. PdkAudioCtrl.CardType[cardType]
    end
    this.PlayAudio(assetName)
    
    if cardType == PdkPokerType.Straight or cardType == PdkPokerType.DoubleStraight then
        this.PlayStraight()
    elseif cardType == PdkPokerType.Airplane or cardType == PdkPokerType.AirplaneAndOne or cardType == PdkPokerType.AirplaneAndTwo then
        this.PlayAirplane()
    elseif cardType == PdkPokerType.Bomb then
        this.PlayBomb()
    else
        PdkAudioCtrl.PlayOutCard()
    end
end
