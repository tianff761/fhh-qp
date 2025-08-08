PanelManager = {}
local this = PanelManager

--面板对象集合
local panelObjs = {}

--初始化
function PanelManager.Init()

end

------------------------------------------------------------------
--
--获取UI层级
function PanelManager.GetLayer(config)
    if config.layer == nil or not IsNumber(config.layer) then
        LogWarn(">> PanelManager.GetLayer > 未配置layer层级 > ", config)
        return uiMgr:GetUILayer(1)
    end
    return uiMgr:GetUILayer(config.layer)
end

--获取面板配置的key
function PanelManager.GetConfigKey(config)
    if IsTable(config) then
        return tostring(config.bundleName) .. "_" .. tostring(config.assetName)
    else
        LogWarn(">> PanelManager.GetConfigKey > 配置错误 > ", config)
        return "NotTable_" .. tostring(config)
    end
end

--获取或者新建面板对象，如果为nil就新建一个返回
function PanelManager.GetOrNewPanelObj(config)
    local key = this.GetConfigKey(config)
    local panelObj = panelObjs[key]
    if panelObj == nil then
        panelObj = {}
        panelObj.config = config   --保存配置
        panelObj.panel = nil       --面板脚本对象
        panelObj.isCtating = false --是否创建中
        panelObj.isOpened = false  --是否开启
        panelObj.key = key
        panelObjs[key] = panelObj
    end
    return panelObj
end

--获取面板对象，如果不存在返回nil
function PanelManager.GetPanelObj(config)
    local key = this.GetConfigKey(config)
    return panelObjs[key]
end

--获取面板脚本对象，如果不存在返回nil
function PanelManager.GetPanel(config)
    local panelObj = PanelManager.GetPanelObj(config)
    if panelObj ~= nil then
        return panelObj.panel
    else
        return nil
    end
end

------------------------------------------------------------------
--
--打开
function PanelManager.Open(config, ...)
    if config == nil or not IsTable(config) then
        LogError(">> PanelManager.Open > 配置错误 > ", config)
        return
    end
    -- if config.assetName ~= nil and config.assetName == "RoomUserInfoPanel" then
    --     LogError(" 游戏内不显示点击玩家头像界面 ")
    --     return
    -- end
    Log(">> PanelManager.Open > 打开面板 > ", config)
    local panelObj = this.GetOrNewPanelObj(config)
    panelObj.isOpened = true
    if panelObj.panel == nil then
        this.InternalCreate(panelObj, ...)
    else
        this.InternalOpen(panelObj, ...)
    end
end

--内部创建面板
function PanelManager.InternalCreate(panelObj, ...)
    if panelObj.isCtating == true then
        LogWarn(">> PanelManager.InternalCreate > 正在打开 > ", panelObj.config)
        return
    end
    panelObj.isCtating = true
    local config = panelObj.config
    local args = { ... }
    ResourcesManager.LoadPrefab(config.bundleName, config.assetName, function(asset)
        this.InternalCreateGameObject(asset, panelObj, unpack(args))
    end)
end

--内部创建面板的GameObject
function PanelManager.InternalCreateGameObject(asset, panelObj, ...)
    panelObj.isCtating = false
    --资源未加载完成时，关闭了界面
    if panelObj.isOpened == false then
        return
    end

    local config = panelObj.config

    if config == nil or asset == nil then
        LogWarn(">> PanelManager.InternalCreateGameObject > X == nil > ", config)
        return
    end

    if config.path ~= nil then
        local luaName = ""
        if not string.IsNullOrEmpty(config.luaName) then
            luaName = config.path .. config.luaName
        else
            luaName = config.path .. config.assetName
        end

        if config.isRequire ~= nil and config.isRequire == true then
            require(luaName)
        else
            dofile(luaName)
        end
    else
        LogWarn(">> PanelManager.InternalCreateGameObject > 未配置path路径 > ", config)
        return
    end

    local panelLayer = this.GetLayer(config)
    if not IsNull(panelLayer) then
        local panelGameObject = NewObject(asset, panelLayer)
        local panelTransform = panelGameObject.transform
        panelGameObject.name = config.assetName
        panelTransform.localScale = Vector3.one
        panelTransform.localRotation = Quaternion.Euler(0, 0, 0)

        local name = config.assetName
        if not string.IsNullOrEmpty(config.luaName) then
            name = config.luaName
        end

        local panel = AddLuaComponent(panelGameObject, name)
        panelObj.panel = panel

        if IsTable(panel) then
            panel.panelConfig = config
            local args = { ... }
            this.InternalOpen(panelObj, unpack(args))
        else
            LogWarn(">> PanelManager.InternalCreateGameObject > panel == nil > ", config)
        end
    else
        LogWarn(">> PanelManager.InternalCreateGameObject > panelLayer == nil > ", config)
    end
end

--内部打开面板
function PanelManager.InternalOpen(panelObj, ...)
    local panel = panelObj.panel
    panel.isOpened = true

    if not IsNull(panel.gameObject) then
        UIUtil.SetActive(panel.gameObject, true)
        UIUtil.SetAsLastSibling(panel.gameObject)
        if panelObj.tweener == nil then
            panelObj.tweener = panelObj.panel.gameObject:GetComponentInChildren(TypeWindowTweener)
        end
        if panelObj.tweener ~= nil and panelObj.isPlayAnimAtOpened ~= true then
            panelObj.isPlayAnimAtOpened = true
            panelObj.tweener:PlayOpenAnim()
        end
    end

    panel:OnOpened(...)
end

------------------------------------------------------------------
--
--关闭隐藏Panel，isDestroy是否销毁面板，isUnloadAsset是否卸载面板使用的Prefab(只有在isDestroy为true时才有效)
function PanelManager.Close(config, isDestroy, isUnloadAsset)
    if not IsTable(config) then
        LogError(">> PanelManager.Close > 参数错误 > ", config)
        return
    end
    Log(">> PanelManager.Close > 关闭面板 > ", config)
    if isDestroy ~= nil then
        this.InternalClose(config, isDestroy, isUnloadAsset)
    else
        this.InternalClose(config, config.isDestroy, config.isUnloadAsset)
    end
end

--销毁Panel，外部调用，会检测播放关闭动画
function PanelManager.Destroy(config, isUnloadAsset)
    if not IsTable(config) then
        LogError(">> PanelManager.Destroy > 参数错误 > ", config)
        return
    end
    Log(">> PanelManager.Destroy > 销毁面板 > ", config)
    this.InternalClose(config, true, isUnloadAsset)
end

--内部关闭
function PanelManager.InternalClose(config, isDestroy, isUnloadAsset)
    local panelObj = this.GetPanelObj(config)
    if panelObj ~= nil then
        panelObj.isDestroy = isDestroy
        panelObj.isUnloadAsset = isUnloadAsset
        panelObj.isOpened = false
        if not IsNil(panelObj.panel) then
            if panelObj.panel.isOpened then
                panelObj.panel.isOpened = false
                TryCatchCall(function()
                    panelObj.panel:OnClosed()
                end)
            end
            if not IsNull(panelObj.panel.gameObject) then
                if panelObj.tweener == nil then
                    panelObj.tweener = panelObj.panel.gameObject:GetComponentInChildren(TypeWindowTweener)
                end
                if panelObj.tweener ~= nil then
                    panelObj.isPlayAnimAtOpened = false
                    panelObj.tweener:PlayCloseAnim(function() this.OnCloseAnimCompleted(panelObj) end)
                else
                    this.OnCloseAnimCompleted(panelObj)
                end
            end
        end
    end
end

--关闭动画播放完成后执行的逻辑
function PanelManager.OnCloseAnimCompleted(panelObj)
    if panelObj.isOpened ~= true then
        if panelObj.isDestroy == true then
            this.InternalDestroy(panelObj, panelObj.isUnloadAsset)
        else
            this.InternalHide(panelObj)
            UIUtil.SetActive(panelObj.panel.gameObject, false)
        end
    end
end

--内部处理隐藏
function PanelManager.InternalHide(panelObj)
    if panelObj.OnHide ~= nil then
        panelObj:OnHide()
    end
end

--销毁
function PanelManager.InternalDestroy(panelObj, isUnloadAsset)
    if panelObj == nil then
        Log(">> PanelManager.InternalDestroy > 销毁面板 > panelObj = nil")
        return
    end
    panelObjs[panelObj.key] = nil
    --
    local panel = panelObj.panel
    local config = panelObj.config
    --
    panelObj.isOpened = false
    panelObj.config = nil
    panelObj.panel = nil
    --
    if not IsNil(panel) then
        if not IsNull(panel.gameObject) then
            DestroyObj(panel.gameObject)
        end
        if isUnloadAsset ~= nil and isUnloadAsset == true then
            ResourcesManager.ReleaseAsset(config.bundleName, config.assetName)
        end
        --推动GC的检测
        ResourcesManager.CheckGC()
    end
end

--面板是否打开
function PanelManager.IsOpened(config)
    local panelObj = this.GetPanelObj(config)
    if panelObj ~= nil and panelObj.panel ~= nil then
        return panelObj.panel.isOpened == true
    else
        return false
    end
end

--关闭所有的面板，除去特殊面板，比如登录，大厅等标记为特殊面板的
function PanelManager.CloseAll()
    local temp = {}
    for i, v in pairs(panelObjs) do
        if v ~= nil and v.config ~= nil and not (v.config.isSpecial == true) then
            table.insert(temp, v.config)
        end
    end
    for i = 1, #temp do
        this.Close(temp[i])
    end
end
