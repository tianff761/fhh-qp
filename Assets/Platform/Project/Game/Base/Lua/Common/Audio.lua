Audio = {}

--播放声音
function Audio.PlaySound(bundle, name)
    AudioManager.PlaySound(bundle, name)
end

--播放点击音效
function Audio.PlayClickAudio()
    Audio.PlaySound("base/sound", "ButtonClick")
end

--播放大厅音效
function Audio.PlayLobbyMusic()
    local index = SettingMgr.GetBgMusicIndex()
    local temp = "LobbyMusic" .. index
    AudioManager.PlayBackgroud("base/" .. string.lower(temp), temp)
end
