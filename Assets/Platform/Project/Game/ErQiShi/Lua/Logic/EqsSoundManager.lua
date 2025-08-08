EqsAudioNames = {}
EqsAudioNames.BtnClick                  = "clickbtn"                --按钮点击
EqsAudioNames.FaPai2                    = "sendcard_2"              --发2张
EqsAudioNames.FaPai14                   = "sendcard_14"             --发14张
EqsAudioNames.FaPai20                   = "sendcard_21"             --发21张

EqsSoundManager = {}
local this = EqsSoundManager

local bgBundleName = "erqishi/eqssound"
local audioBundleName = "erqishi/eqsaudios"
local audioType = ""        --为""时，有两种声音，命名末尾为_1和_2，随机播放。为1_时，只有一种声音
function EqsSoundManager.Init()
    this.SetAudioType(GetLocal(EqsLocalKey.MusicType))
end

function EqsSoundManager.SetAudioType(eqsAudioType)
    audioType = eqsAudioType
    if audioType == nil then
        audioType = EqsAudioType.FangYan1
    end
end

--获取音效bundle
function EqsSoundManager.GetAudioBundleName()
    return audioBundleName
end

--播放出牌声音
function EqsSoundManager.PlayChuPaiAudio(cardId, sex)
    local name = audioType
    local cardPoint = EqsTools.GetEqsCardPoint(cardId)
    local cardType = EqsTools.GetEqsCardType(cardId)
    if sex == Global.GenderType.Female then
        name = name.."nv"
    else
        name = name.."nan"
    end

    if cardType == EqsCardDefine.CardType.Da then
        name = name.."_red_"..tostring(cardPoint)
    elseif cardType == EqsCardDefine.CardType.Xiao then
        name = name.."_black_"..tostring(cardPoint)
    end
    --为""时，有两种声音，命名末尾为_1和_2
    if audioType == "" then
        if cardPoint == 10 then
            name = name.."_2"
        else
            local num = GetRandom(1, 2)
            name = name.."_"..tostring(num)
        end
    elseif audioType == "1_" then--为1_时，只有一种声音 
    end
    Log("PlayChuPaiAudio:", audioBundleName, name, audioType, sex, cardType)
    AudioManager.PlaySound(audioBundleName,name)
end
--kuai: 8,12,16,20
function EqsSoundManager.PlayBaKuai(kuai, sex)
    local name = audioType
    if sex == Global.GenderType.Female then
        name = name.."nv_"
    else
        name = name.."nan_"
    end
    name = name..tostring(kuai).."kuai"
    --Log("PlayBaKuai:", audioBundleName, name)
    AudioManager.PlaySound(audioBundleName,name)
end

function EqsSoundManager.PlayOperationAudio(operType, sex)
    local name = audioType
    if sex == Global.GenderType.Female then
        name = name.."nv"
    else
        name = name.."nan"
    end
    if operType == EqsOperation.Chi then
        name = name.."_chi"
    elseif operType == EqsOperation.Dui then
        name = name.."_dui"
    elseif operType == EqsOperation.Kai then
        name = name.."_kai"
         --为""时，有两种声音，命名末尾为_1和_2
        if audioType == "" then
            local num = GetRandom(1, 2)
            name = name.."_"..tostring(num)
        elseif audioType == "1_" then--为1_时，只有一种声音 
        end
    elseif operType == EqsOperation.Hu then
        name = name.."_hu"
    else--其他操作没有声音
        return 
    end
    AudioManager.PlaySound(audioBundleName,name)
end

function EqsSoundManager.PlayAudio(name)
    AudioManager.PlaySound(audioBundleName,name)
end

function EqsSoundManager.PlayAudioByFull(bundle, name)
    if not string.IsNullOrEmpty(bundle) and not string.IsNullOrEmpty(name) then
        AudioManager.PlaySound(bundle, name)
    end
end

function EqsSoundManager.PlayBg()
    AudioManager.PlayBackgroud(bgBundleName,"music_game")
end

function EqsSoundManager.Uninit()
    ResourcesManager.Unload(bgBundleName)
    ResourcesManager.Unload(audioBundleName)
end