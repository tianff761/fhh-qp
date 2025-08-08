TpAudioMgr = {}
local this = TpAudioMgr

function TpAudioMgr.PlayAudio(name)
    AudioManager.PlaySound(TpBundleName.Audio, name)
end

--准备音效
function TpAudioMgr.PlayReady()
    this.PlayAudio("audio_ready")
end

--点击牌音效
function TpAudioMgr.ClickCard()
    this.PlayAudio("audio_click_card")
end

--掷骰子音效
function TpAudioMgr.PlayDice()
    this.PlayAudio("audio_dice")
end

--分数音效
function TpAudioMgr.PlayCoin()
    this.PlayAudio("audio_coin")
end

--播放背景音乐
function TpAudioMgr.PlayBgMusic()
    --AudioManager.PlayBackground(TpBundleName.Music, "bgMusic1")
end

--下注音效，跟、大、下局下筹码
function TpAudioMgr.PlayBet()
    this.PlayAudio("audio_bet")
end

--操作丢音效
function TpAudioMgr.PlayDiu()
    this.PlayAudio("audio_diu")
end

--操作敲音效
function TpAudioMgr.PlayQiao()
    this.PlayAudio("audio_qiao")
end

--操作休音效
function TpAudioMgr.PlayXiu()
    this.PlayAudio("audio_xiu")
end

--大赢家
function TpAudioMgr.PlayBigWin()
    this.PlayAudio("audio_bigwin")
end

--发牌
function TpAudioMgr.PlayFaPai()
    this.PlayAudio("audio_fapai")
end

--结算收筹码
function TpAudioMgr.PlayJieSuan()
    this.PlayAudio("audio_jiesuan")
end


------------------------------------------------------------------
--操作语音性别前缀
TpAudioMgr.OperateGenderPrefix = {
    Male = "m_",
    Female = "f_"
}

--播放牌音效
function TpAudioMgr.PlayCardSound(gender, cardKey, language)
    if not IsNumber(cardKey) then
        return
    end

    local assetName = ""
    local genderStr = ""

    --性别
    if gender == Global.GenderType.Male then
        genderStr = TpAudioMgr.OperateGenderPrefix.Male
    else
        genderStr = TpAudioMgr.OperateGenderPrefix.Female
    end

    assetName = genderStr .. cardKey

    this.PlayAudio(assetName)
end

--播放操作语音
function TpAudioMgr.PlayOperateSound(gender, operateCode, language)

    LogError(">> TpAudioMgr.PlayOperateSound > operateCode = ", gender, operateCode, language)

    --性别
    -- if gender == Global.GenderType.Male then

    -- else

    -- end

    -- local key = operateAudioConfig[operateCode]

    -- if key == nil then
    --     return
    -- end

    -- local assetName = genderStr .. key .. "_0"
    -- Log(">> TpAudioMgr.PlayOperateSound > assetName = ", assetName)
    -- this.PlayAudio(assetName)
end