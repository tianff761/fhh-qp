SensitiveWordsManager = {}
local this = SensitiveWordsManager
--是否初始化
local isInit = false
--移除屏蔽字库的词
local removeSensitiveWords = {
}
--增加的屏蔽字库的词
local addSensitiveWords = {
}

function SensitiveWordsManager.Init()
    if not isInit then
        SensitiveWordsMgr:ReadSensitiveWordsByAssetBunld("base/sensitivewordstxt","SensitiveWords", this.OnLoadFinshCallback)
        isInit = true
    end
end

function SensitiveWordsManager.OnLoadFinshCallback()
    this.RemoveSensitive()
    this.AddSensitive()
end

--增加屏蔽词库词
function SensitiveWordsManager.AddSensitive()
    for i = 1, #addSensitiveWords do 
        SensitiveWordsMgr:AddWord(addSensitiveWords[i])
    end
end

--移除屏蔽字库
function SensitiveWordsManager.RemoveSensitive()
    for i = 1, #removeSensitiveWords do
        SensitiveWordsMgr:RemoveWord(removeSensitiveWords[i])
    end
end

return SensitiveWordsManager