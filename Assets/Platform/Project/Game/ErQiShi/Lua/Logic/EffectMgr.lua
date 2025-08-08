EffectMgr = {}
EffectType = {
    EqsDui      = "EqsDui", --对
    EqsEat      = "EqsEat", --吃
    EqsHu       = "EqsHu", --胡
    EqsKai      = "EqsKai", --开 
    EqsYu       = "EqsYu", --雨
    EqsBai      = "EqsBai", --摆
}

--播放特效
function EffectMgr.PlayEffect(effecttype, effectPosTran)
    TryCatchCall(function ()
        if string.IsNullOrEmpty(effecttype) or effectPosTran == nil then
            LogError("错误的特效类型：", effectPosTran)
            return
        end
       
        ResourcesManager.LoadPrefab(EqsPanels.bundleName,effecttype,function (obj)
            local go = NewObject(obj.gameObject)
            go.transform:SetParent(effectPosTran)
            go.transform.localPosition = Vector3.zero
            go.transform.localScale = Vector3.one
            go:SetActive(false)
            go:SetActive(true)
            Scheduler.scheduleOnceGlobal(function()
                DestroyObj(go)
            end,
            0.8)
        end)
    end)
end
