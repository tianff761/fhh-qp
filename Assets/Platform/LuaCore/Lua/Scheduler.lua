--
--  Author: colin(colnlin@foxmail.com)
--  Copyright (C) 2017 Coln Lin. All rights reserved.
--
--  @module Scheduler
--
--  Scheduler.
--
Timing = {
    time = 0,
    func = nil,
    interval = 0
}
local mt = {}
mt.__index = Timing

function Timing.New(func, interval)
    local timer = {}
    setmetatable(timer, mt)
    timer:Reset(func, interval)
    return timer
end

function Timing:Reset(func, interval)
    self.func = func
    self.interval = interval
    self.times = interval
end

function Timing:Restart()
    self.times = self.interval
    self:Start()
end

function Timing:Start()
    if self.running then return end
    self.running = true
    self.handler = UpdateBeat:Add(self.Update, self)
end

function Timing:Stop()
    if self.running == false then return end
    self.running = false
    UpdateBeat:Remove(self.Update, self)
end

function Timing:Update()
    if not self.running then
        return
    end
    self.times = self.times - Time.deltaTime
    if self.times <= 0 then
        self.times = self.interval
        self.func()
    end
end

function Timing:scheduleScriptFunc(listener, interval)
    local timing = Timing.New(listener, interval)
    timing:Start()
    return timing
end

function Timing:unscheduleScriptEntry(handler)
    if handler ~= nil then
        handler:Stop()
    end
end

--==================================================================================
--Update方法更新，需要自行Stop
UpdateTimer = {
    running    = false,
    func    = nil,
}

local mUpdateTimer = {}
mUpdateTimer.__index = UpdateTimer

--每帧在Update中调用
function UpdateTimer.New(func)
    local timer = {}
    setmetatable(timer, mUpdateTimer)
    timer:Reset(func)
    return timer
end

function UpdateTimer:Start()
    if not self.running then
        self.running = true
        UpdateBeat:Add(self.Update, self)
    end
end

function UpdateTimer:Reset(func)
    self.func = func
end

function UpdateTimer:Stop()
    if self.running then
        self.running = false
        UpdateBeat:Remove(self.Update, self)
    end
end

function UpdateTimer:Update()
    if not self.running then
        return
    end

    self.func()
end
--
-------------------------------------------------------------------------------
---@class Scheduler
Scheduler = {}


---! 计划一个全局帧事件回调，并返回该计划的句柄
--- @param listener function @回调函数
function Scheduler.scheduleUpdateGlobal(listener)
    return Timing:scheduleScriptFunc(listener, 0)
end

---! 计划一个以指定时间间隔执行的全局事件回调，并返回该计划的句柄.
--- @param listener function @回调函数
--- @param interval number @执行间隔
function Scheduler.scheduleGlobal(listener, interval)
    return Timing:scheduleScriptFunc(listener, interval)
end

---! 取消一个全局计划
--- @param handle function @schedule句柄
function Scheduler.unscheduleGlobal(handle)
    Timing:unscheduleScriptEntry(handle)
end

---! 计划一个全局延时回调，并返回该计划的句柄。会在等待指定时间后执行一次回调函数，然后自动取消该计划。
--- @param listener function @回调函数
--- @param time number @延迟时间
function Scheduler.scheduleOnceGlobal(listener, time)
    local handle
    if tonumber(time) < 0.005 then
        TryCatchCall(listener)
    else
        handle = Timing:scheduleScriptFunc(function()
            Scheduler.unscheduleGlobal(handle)
            listener()
        end, time)
    end

    return handle
end

return Scheduler