SettingMgr = {}
local this = SettingMgr

local KeyBgMusicIndex = "KeyBgMusicIndex"
local KeyBackgroundIndex = "KeyBackgroundIndex"
--
function SettingMgr.Init()
    this.bgMusicIndex = tonumber(GetLocal(KeyBgMusicIndex, 1))
    this.backgroundIndex = tonumber(GetLocal(KeyBackgroundIndex, 1))
end

--设置背景音乐序号
function SettingMgr.SetBgMusicIndex(index)
    this.bgMusicIndex = index
    SetLocal(KeyBgMusicIndex, this.bgMusicIndex)
end

--获取背景音乐序号
function SettingMgr.GetBgMusicIndex()
    return this.bgMusicIndex
end

--设置大厅背景序号
function SettingMgr.SetBackgroundIndex(index)
    this.backgroundIndex = index
    SetLocal(KeyBackgroundIndex, this.backgroundIndex)
end

--获取大厅背景序号
function SettingMgr.GetBackgroundIndex()
    return this.backgroundIndex
end
