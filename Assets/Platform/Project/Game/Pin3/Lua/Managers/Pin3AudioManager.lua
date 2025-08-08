Pin3AudioManager = {}
local this = Pin3AudioManager
Pin3AudioType = {
    AddGold = "add_gold",
    ShanDian = "compare_effect",
    BiPaiText = "compare_text",
    DuiZiText = "dui_zi_text",
    FaPai = "fa_pai",
    FeiJiText = "fei_ji_text",
    GenZhuText1 = "gen_zhu_text_1",
    GenZhuText2 = "gen_zhu_text_2",
    GenZhuText3 = "gen_zhu_text_3",
    JiaZhuText = "jia_zhu_text",
    KanPaiText = "look_card_text",
    QiPaiText = "qi_pai_text",
    SanPaiText = "san_pai_text",
    ShunZiText = "shun_zi_text",
    TongHuaShun = "tong_hua_shun_text",
    TongHua = "tong_hua_text",
    YaManText = "ya_man_text",
    Win = "win",
    Lost = "lose",
    StartGame = "gamestart",
    GuZhuYiZhi = "gzyz"
}

--播放音效
function Pin3AudioManager.PlayAudio(name)
    AudioManager.PlaySound(Pin3BundleNames.audioBundle, name)
end
--播放背景音乐
function Pin3AudioManager.PlayBGM()
    AudioManager.PlayBackgroud(Pin3BundleNames.musicBundle, "bgm")
end


function Pin3AudioManager.PlayByPin3AudioType(pin3AudioType)
    this.PlayAudio(pin3AudioType)
end