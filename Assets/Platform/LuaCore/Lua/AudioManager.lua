AudioManager = {}
local this = AudioManager

AudioManager.bgAudioSource = nil
AudioManager.soundAudioSource = {}
AudioManager.bgVolume = 0.7
AudioManager.soundVolume = 0.7
--背景音乐系数
AudioManager.bgVolumeXiShu = 0.3

local KeyBgVolume = "KeyBgVolume"
local KeySoundVolume = "KeySoundVolume"

function AudioManager.Init()
    this.bgVolume = tonumber(GetLocal(KeyBgVolume, 0.7))
    this.soundVolume = tonumber(GetLocal(KeySoundVolume, 0.7))

    local go = GameObject.New()
    go.name = "TempBgAudioSource"
    go:AddComponent(typeof(AudioSource))
    this.bgAudioSource = go:GetComponent(typeof(AudioSource))

    -- --每隔60s回收一次soundAudioSource
    -- Scheduler.scheduleGlobal(function ()
    --     if #this.soundAudioSource > 3 then
    --         local notPlayingAudioSource = {}
    --         for _, audioSource in pairs(this.soundAudioSource) do
    --             if audioSource.clip == nil or audioSource.isPlaying == false then
    --                 table.insert(notPlayingAudioSource, audioSource)
    --             end
    --         end
    --         local size = #notPlayingAudioSource
    --         if size > 3 then
    --             for i = 4, size do
    --                 DestroyObj(notPlayingAudioSource[i].gameObject)
    --             end
    --         end
    --     end
    -- end, 60)
end

function AudioManager.GetSoundAudioSource()
    local idleAudioSource = nil
    for k, audioSource in pairs(this.soundAudioSource) do
        idleAudioSource = audioSource
        table.remove(this.soundAudioSource, k)
        break
    end
    if idleAudioSource == nil then
        local go = GameObject.New()
        go.name = "TempSoundAudioSource"
        go:AddComponent(typeof(AudioSource))
        idleAudioSource = go:GetComponent(typeof(AudioSource))
    end
    return idleAudioSource
end

function AudioManager.RecycelAudioSource(audioSource)
    if audioSource ~= nil then
        -- Log("播放声音 回收", audioSource.name)
        if GetTableSize(this.soundAudioSource) < 9 then
            audioSource:Stop()
            audioSource.clip = nil
            table.insert(this.soundAudioSource, audioSource)
        else
            DestroyObj(audioSource.gameObject)
        end
    end
end

--设置背景音乐音量大小
function AudioManager.SetBackgroudVolume(volume)
    if volume < 0 then
        this.bgVolume = 0
    elseif volume > 1 then
        this.bgVolume = 1
    else
        this.bgVolume = volume
    end
    SetLocal(KeyBgVolume, this.bgVolume)
    if this.bgAudioSource.clip then
        this.bgAudioSource.volume = this.bgVolume * this.bgVolumeXiShu
    end
end

--获取背景音量
function AudioManager.GetBackgroundVolume()
    return this.bgVolume
end

--设置音效音量大小
function AudioManager.SetSoundVolume(volume)
    if volume < 0 then
        this.soundVolume = 0
    elseif volume > 1 then
        this.soundVolume = 1
    else
        this.soundVolume = volume
    end
    --Log("设置音量", volume)
    SetLocal(KeySoundVolume, this.soundVolume)
end

--获取音效音量
function AudioManager.GetSoundVolume()
    return this.soundVolume
end

--播放音效
function AudioManager.PlaySound(bundle, name, callback, loop)
    if this.soundVolume <= 0 and loop ~= true then
        return nil
    end

    local audioSource = this.GetSoundAudioSource()
    local clip = ResourcesManager.GetAsset(bundle, name)
    if clip ~= nil then
        audioSource.volume = this.soundVolume
        audioSource.clip = clip
        audioSource:Play()

        if loop == true then
            audioSource.loop = true
        else
            audioSource.loop = false
            Scheduler.scheduleOnceGlobal(function()
                    this.RecycelAudioSource(audioSource)
                    if IsFunction(callback) then
                        callback(name)
                    end
                end,
                clip.length + 0.05)
        end
    else
        ResourcesManager.LoadAudioClip(bundle, name, function(clip)
            if clip ~= nil then
                audioSource.volume = this.soundVolume
                audioSource.clip = clip
                audioSource:Play()

                if loop == true then
                    audioSource.loop = true
                else
                    audioSource.loop = false
                    Scheduler.scheduleOnceGlobal(function()
                            this.RecycelAudioSource(audioSource)
                            if IsFunction(callback) then
                                callback(name)
                            end
                        end,
                        clip.length + 0.05)
                end
            else
                this.RecycelAudioSource(audioSource)
            end
        end)
    end
    return audioSource
end

--停止播放
function AudioManager.StopSound(audioSource)
    this.RecycelAudioSource(audioSource)
end

--================================播放背景音乐相关================================
local bgClipSchedule = nil
local currPlayMusicBundleName = nil
local currPlayMusicAssetName = nil
function AudioManager.PlayBackgroud(bundle, name)
    if currPlayMusicBundleName == bundle and currPlayMusicAssetName == name then
        --LogWarn(">> AudioManager.PlayBackgroud > repeat play > name = " .. tostring(name))
        return
    end
    currPlayMusicBundleName = bundle
    currPlayMusicAssetName = name

    local clip = ResourcesManager.GetAsset(bundle, name)
    if clip ~= nil then
        this.bgAudioSource.volume = this.bgVolume * this.bgVolumeXiShu
        this.bgAudioSource.clip = clip
        this.bgAudioSource:Play()
        Scheduler.unscheduleGlobal(bgClipSchedule)
        bgClipSchedule = Scheduler.scheduleGlobal(function()
            this.bgAudioSource:Play()
        end, clip.length)
    else
        ResourcesManager.LoadAudioClip(bundle, name, function(clip)
            this.bgAudioSource.volume = this.bgVolume * this.bgVolumeXiShu
            this.bgAudioSource.clip = clip
            this.bgAudioSource:Play()
            Scheduler.unscheduleGlobal(bgClipSchedule)
            bgClipSchedule = Scheduler.scheduleGlobal(function()
                this.bgAudioSource:Play()
            end, clip.length)
        end)
    end
end

--暂停BGM
function AudioManager.PauseBackgroud()
    if this.bgAudioSource ~= nil then
        if this.bgAudioSource.clip ~= nil then
            this.bgAudioSource.volume = 0
        end
    end
end

--继续BGM
function AudioManager.UnPauseBackgroud()
    if this.bgAudioSource ~= nil then
        this.SetBackgroudVolume(this.bgVolume)
    end
end
