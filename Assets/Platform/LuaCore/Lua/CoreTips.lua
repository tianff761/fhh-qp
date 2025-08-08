CoreTips = {}
CoreTips.showWaitingFun = nil
CoreTips.hideWaitingFun = nil
CoreTips.forcehideWaitingFun = nil
CoreTips.showAlertFun = nil

CoreTips.showHttpWaiting = nil
CoreTips.hideHttpWaiting = nil

CoreTips.showToast = nil


function CoreTips.Init(showWaitingFun, hideWaitingFun, forcehideWaitingFun, alertFun, toastFun)
    CoreTips.showWaitingFun = showWaitingFun
    CoreTips.hideWaitingFun = hideWaitingFun
    CoreTips.forcehideWaitingFun = forcehideWaitingFun
    CoreTips.showAlertFun = alertFun
    CoreTips.showToast = toastFun
end

function CoreTips.SetHttpWaiting(showWaitingFun, hideWaitingFun)
    CoreTips.showHttpWaiting = showWaitingFun
    CoreTips.hideHttpWaiting = hideWaitingFun
end

function CoreTips.ShowWaiting(message, level)
    if CoreTips.showWaitingFun ~= nil then
        CoreTips.showWaitingFun(message, level)
    end
end

function CoreTips.HideWaiting()
    if CoreTips.hideWaitingFun ~= nil then
        CoreTips.hideWaitingFun()
    end
end

function CoreTips.ShowHttpWaiting(text)
    if IsFunction(CoreTips.showHttpWaiting) then
        CoreTips.showHttpWaiting(text)
    end
end

function CoreTips.HideHttpWaiting()
    if IsFunction(CoreTips.hideHttpWaiting) then
        CoreTips.hideHttpWaiting()
    end
end

function CoreTips.ForceHideWaiting()
    if CoreTips.forcehideWaitingFun ~= nil then
        CoreTips.forcehideWaitingFun()
    end
end

function CoreTips.ShowToast(msg)
    if CoreTips.showToast ~= nil then
        CoreTips.showToast(msg)
    end
end

function CoreTips.ShowAlert(message, okCallback, cancelCallback)
    if CoreTips.showAlertFun ~= nil then
        CoreTips.showAlertFun(message, okCallback,cancelCallback)
    end
end



