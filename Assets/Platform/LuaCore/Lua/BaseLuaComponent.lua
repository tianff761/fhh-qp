--所有LuaComponent的基类
BaseLuaComponent = Class("BaseLuaComponent")
BaseLuaComponent.transform = nil    --C#自动设置
BaseLuaComponent.gameObject = nil   --C#自动设置
BaseLuaComponent.luaComponent = nil --C#自动设置
BaseLuaComponent.isValid = false    --C#自动设置

BaseLuaComponent.allSchedulers = nil

--点击按钮时调用，全局变量
btnClickCallback = nil 

function BaseLuaComponent:_Reset()
    self:UnscheduleAll()
    self.allSchedulers = nil
end

function BaseLuaComponent:Awake()
    -- LogWarn("Awake:",tostring(self:IsValid()), self.gameObject.name)
end

function BaseLuaComponent:IsValid()
    return self.isValid
end

function BaseLuaComponent:Start()
    --  LogWarn("Start:",self.gameObject.name,tostring(self:IsValid()))
end

function BaseLuaComponent:OnEnable()
    --  LogWarn("OnEnable:", self.gameObject.name, tostring(self:IsValid()))
end

--注：删除对应gameObject时，在此函数中访问gameObject和transform会异常
function BaseLuaComponent:OnDisable()
    -- LogWarn("OnDisable:", self.gameObject.name, tostring(IsNull(self.gameObject)), tostring(self:IsValid()))
end

--销毁，注：不能在此函数中访问gameObject和transform
function BaseLuaComponent:OnDestroy()
    -- LogWarn("OnDestroy:", tostring(type(self.gameObject)), tostring(self:IsValid()))
    self:_Reset()
end

--为按钮添加点击事件
function BaseLuaComponent:AddOnClick(tran, handle, playAudio, removeOtherHandle)
    if tran == nil or type(handle) ~= "function" then
        LogError("function BaseLuaComponent:AddOnClick(tran, handle)：参数错误", tran, handle)
        return
    end
    local btn = tran:GetComponent("Button")
    if btn ~= nil then
        if removeOtherHandle == nil or removeOtherHandle == true then
            btn.onClick:RemoveAllListeners()
        end
        -- btn.onClick:AddListener(handle)
        btn.onClick:AddListener(function()
            if playAudio == nil or playAudio == true then
                if btnClickCallback ~= nil then
                    btnClickCallback()
                end
            end
            handle()
        end)
    else
        LogWarn("function BaseLuaComponent:AddOnClick(tran, handle):tran 对象不包含Button组件")
    end
end

--为Toggle添加onValueChanged事件
function BaseLuaComponent:AddOnToggle(tran, handle, removeOtherHandle)
    if tran == nil or type(handle) ~= "function" then
        LogError("function BaseLuaComponent:AddOnClick(tran, handle)：参数错误", tran, type(handle))
        return
    end

    local toggle = tran:GetComponent("Toggle")
    if toggle ~= nil then
        if removeOtherHandle == nil or removeOtherHandle == true then
            toggle.onValueChanged:RemoveAllListeners()
        end
        toggle.onValueChanged:AddListener(handle)
    else
        LogWarn("function BaseLuaComponent:AddOnClick(tran, handle):Toggle 对象不包含Button组件")
    end
end

function BaseLuaComponent:AddOnDropdown(tran, handle, removeOtherHandle)
    if tran == nil or type(handle) ~= "function" then
        LogError("function BaseLuaComponent:AddOnDropdown(tran, handle)：参数错误", tran, type(handle))
        return
    end
    local Dropdown = tran:GetComponent(TypeDropdown)
    if Dropdown ~= nil then
        if removeOtherHandle == nil or removeOtherHandle == true then
            Dropdown.onValueChanged:RemoveAllListeners()
        end
        Dropdown.onValueChanged:AddListener(handle)
    else
        LogWarn("function BaseLuaComponent:AddOnDropdown(tran, handle):Dropdown 对象不包含Dropdown组件")
    end
end

function BaseLuaComponent:Find(path)
    if self.isValid then
        return self.transform:Find(path)
    else
        return nil
    end
end

function BaseLuaComponent:GetComponent(component)
    if self.isValid then
        return self.transform:GetComponent(component)
    else
        return nil
    end
end

function BaseLuaComponent:GetComponentsInChildren(component)
    if self.isValid then
        return self.transform:GetComponentsInChildren(component, true):ToTable()
    else
        return nil
    end
end

--callback:回调，只能是当前类的类方法  delayTime：延时时间，单位s
function BaseLuaComponent:ScheduleOnce(callback, delayTime, args)
    if IsFunction(callback) and IsNumber(delayTime) and self:IsValid() then
        local handle = HandlerArgs(callback, args)
        local scheduler = Scheduler.scheduleOnceGlobal(handle, delayTime)
        self:_AddScheduler(callback, scheduler)
    else
        LogWarn("function BaseLuaComponent:ScheduleOnce(callback, delayTime) 参数错误", type(callback), type(delayTime))
    end
end

--callback:回调，只能是当前类的类方法  delayTime：延时时间，单位s
function BaseLuaComponent:Schedule(callback, interval)
    if IsFunction(callback) and IsNumber(interval) and self:IsValid() then
        --Log("开始调度：", self.gameObject.name)
        local scheduler = Scheduler.scheduleGlobal(callback, interval)
        self:_AddScheduler(callback, scheduler)
    else
        LogWarn("function BaseLuaComponent:ScheduleOnce(callback, delayTime) 参数错误", type(callback), type(interval))
    end
end

function BaseLuaComponent:GetScheduler(callback)
    if IsFunction(callback) and not IsNil(self.allSchedulers) then
        return self.allSchedulers[self:_GetSchedulerKey(callback)]
    end
    return nil
end

function BaseLuaComponent:UnscheduleAll()
    if GetTableSize(self.allSchedulers) > 0 then
        for _, scheduler in pairs(self.allSchedulers) do
            Scheduler.unscheduleGlobal(scheduler)
        end
    end
    --LogWarn("注销所有scheduler")
    self.allSchedulers = {}
end

function BaseLuaComponent:Unschedule(callback)
    local schedule = self:GetScheduler(callback)
    if schedule ~= nil then
        Scheduler.unscheduleGlobal(schedule)
        self:_RemoveScheduler(callback)
    end
end

function BaseLuaComponent:_AddScheduler(callback, scheduler)
    if IsNil(self.allSchedulers) then
        self.allSchedulers = {}
    end
    if IsFunction(callback) and not IsNil(scheduler) then
        self.allSchedulers[self:_GetSchedulerKey(callback)] = scheduler
    else
        LogWarn("BaseLuaComponent:_AddScheduler(callback, scheduler) 参数错误")
    end
end

function BaseLuaComponent:_RemoveScheduler(callback)
    self.allSchedulers[self:_GetSchedulerKey(callback)] = nil
end

function BaseLuaComponent:_GetSchedulerKey(callback)
    if IsFunction(callback) then
        return tostring(self) .. self.gameObject.name .. ":" .. tostring(callback)
    end
    return nil
end
