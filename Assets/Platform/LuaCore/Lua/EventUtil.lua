EventUtil = {}
local this = EventUtil

--为按钮添加点击事件
function EventUtil.AddOnClick(tran, callback, isPlayClickAudio, isRemoveAllListeners)
    if tran == nil or type(callback) ~= "function" then
        LogError(">> EventUtil.AddOnClick(tran, callback)：参数错误", tran, callback)
        return
    end
    local btn = tran:GetComponent(TypeButton)
    if btn ~= nil then
        if isRemoveAllListeners == nil or isRemoveAllListeners == true then
            btn.onClick:RemoveAllListeners()
        end
        btn.onClick:AddListener(function()
            if isPlayClickAudio == nil or isPlayClickAudio == true then
                if btnClickCallback ~= nil then
                    btnClickCallback()
                end
            end
            callback()
        end)
    else
        LogWarn(">> EventUtil:AddOnClick(tran, callback):tran 对象不包含Button组件")
    end
end

--为按钮添加点击事件
function EventUtil.AddClickListenter(buttton, callback, isPlayClickAudio, isRemoveAllListeners)
    if buttton == nil or type(callback) ~= "function" then
        LogError(">> EventUtil.AddClickListenter > 参数错误", buttton, callback)
        return
    end

    if isRemoveAllListeners == nil or isRemoveAllListeners == true then
        buttton.onClick:RemoveAllListeners()
    end
    buttton.onClick:AddListener(function()
        if isPlayClickAudio == nil or isPlayClickAudio == true then
            if btnClickCallback ~= nil then
                btnClickCallback()
            end
        end
        callback()
    end)
end

--为Toggle添加onValueChanged事件
function EventUtil.AddOnToggle(tran, callback, isRemoveAllListeners)
    if tran == nil or type(callback) ~= "function" then
        LogError(">> EventUtil:AddOnToggle(tran, callback)：参数错误", tran, type(callback))
        return
    end

    local toggle = tran:GetComponent(TypeToggle)
    if toggle ~= nil then
        if isRemoveAllListeners == nil or isRemoveAllListeners == true then
            toggle.onValueChanged:RemoveAllListeners()
        end
        toggle.onValueChanged:AddListener(callback)
    else
        LogWarn(">> EventUtil:AddOnToggle(tran, callback):Toggle 对象不包含Button组件")
    end
end

--为Toggle添加onValueChanged事件
function EventUtil.AddToggleListener(toggle, callback, isRemoveAllListeners)
    if toggle == nil or type(callback) ~= "function" then
        LogError(">> EventUtil.AddToggleListener > 参数错误", toggle, type(callback))
        return
    end

    if isRemoveAllListeners == nil or isRemoveAllListeners == true then
        toggle.onValueChanged:RemoveAllListeners()
    end
    toggle.onValueChanged:AddListener(callback)
end
