MahjongAudioMgr = {}
local this = MahjongAudioMgr

function MahjongAudioMgr.PlayAudio(name)
    AudioManager.PlaySound(MahjongBundleName.Audio, name)
end

--准备音效
function MahjongAudioMgr.PlayReady()
    this.PlayAudio("audio_ready")
end

--出牌音效
function MahjongAudioMgr.PlayCard()
    this.PlayAudio("audio_play_card")
end

--点击牌音效
function MahjongAudioMgr.ClickCard()
    this.PlayAudio("audio_click_card")
end

--掷骰子音效
function MahjongAudioMgr.PlayDice()
    this.PlayAudio("audio_dice")
end

--分数音效
function MahjongAudioMgr.PlayCoin()
    this.PlayAudio("audio_coin")
end

--播放背景音乐
function MahjongAudioMgr.PlayBgMusic()
    AudioManager.PlayBackgroud(MahjongBundleName.Music, "bgMusic1")
end


------------------------------------------------------------------
--操作语音性别前缀
MahjongAudioMgr.OperateGenderPrefix = {
    Male = "m_",
    Female = "f_"
}
--多个语音
MahjongAudioMgr.CardVoiceMultiple = {
    --男
    ["m_12"] = 2,
    ["m_13"] = 2,
    ["m_17"] = 2,
    ["m_18"] = 2,
    ["m_21"] = 2,
    ["m_22"] = 2,
    ["m_23"] = 2,
    ["m_25"] = 2,
    ["m_27"] = 2,
    ["m_28"] = 2,
    ["m_1"] = 2,
    --女
    ["f_12"] = 2,
    ["f_17"] = 2,
    ["f_18"] = 2,
    ["f_23"] = 2,
    ["f_25"] = 2,
    ["f_28"] = 2,
}
--多个操作语音
MahjongAudioMgr.OperateVoiceMultiple = {
    --男
    ["m_gang"] = 2,
    ["m_hu"] = 3,
    ["m_peng"] = 3,
    ["m_zimo"] = 2,
}

--播放牌音效
function MahjongAudioMgr.PlayCardSound(gender, cardKey, language)
    if not IsNumber(cardKey) then
        return
    end

    local assetName = ""
    local genderStr = ""

    --性别
    if gender == Global.GenderType.Male then
        genderStr = MahjongAudioMgr.OperateGenderPrefix.Male
    else
        genderStr = MahjongAudioMgr.OperateGenderPrefix.Female
    end

    assetName = genderStr .. cardKey

    --乐山方言随机播放不同语音
    -- local maxNum = MahjongAudioMgr.CardVoiceMultiple[assetName]
    -- if maxNum ~= nil then
    --     local temp = math.random(1, 1000)
    --     temp = temp % maxNum
    --     if temp == 1 then
    --         assetName = assetName .. "_2"
    --     end
    -- end
    this.PlayAudio(assetName)
end

--播放麻将操作语音
function MahjongAudioMgr.PlayOperateSound(gender, operateCode, language)

    --Log(">> MahjongAudioMgr.PlayOperateSound > operateCode = ", operateCode)

    local operateAudioConfig = nil
    local genderStr = ""
    --性别
    if gender == Global.GenderType.Male then
        operateAudioConfig = MahjongOperateAudio[Global.GenderType.Male]
        genderStr = MahjongAudioMgr.OperateGenderPrefix.Male
    else
        operateAudioConfig = MahjongOperateAudio[Global.GenderType.Female]
        genderStr = MahjongAudioMgr.OperateGenderPrefix.Female
    end

    local key = operateAudioConfig[operateCode]

    if key == nil then
        return
    end

    local assetName = genderStr .. key

    local maxNum = nil--MahjongAudioMgr.OperateVoiceMultiple[assetName]
    if maxNum ~= nil then
        local temp = math.random(1, 1000)
        temp = temp % maxNum
        assetName = assetName .. "_" .. temp
    else
        assetName = assetName .. "_0"
    end

    --Log(">> MahjongAudioMgr.PlayOperateSound > assetName = ", assetName)

    this.PlayAudio(assetName)
end