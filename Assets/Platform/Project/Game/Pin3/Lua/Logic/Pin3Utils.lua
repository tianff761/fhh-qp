Pin3Utils = {}
local this = Pin3Utils
Pin3Utils.gos = {}
Pin3Utils.spHelper = {}

function Pin3Utils.Init(tran)
    local goHelper = tran:GetComponent("GameObjectsHelper")
    local objects = goHelper.objects:ToTable()
    for _, go in pairs(objects) do
        this.gos[go.name] = go
    end

    this.spHelper = tran:GetComponent("UISpriteAtlas")
end

function Pin3Utils.Uninit()
    this.gos = {}
    this.spHelper = {}
end

--获取玩家信息对象
function Pin3Utils.GetUserInfoGoByUiIdx(uiIdx)
    if uiIdx == 1 then
        return this.gos["UserInfoSelf"]
    end
    if uiIdx == 2 or uiIdx == 3 or uiIdx == 4 then
        return this.gos["UserInfoRight"]
    end

    if uiIdx == 5 or uiIdx == 6 or uiIdx == 7 or uiIdx == 8 then
        return this.gos["UserInfoLeft"]
    end
end

--获取牌对象
function Pin3Utils.GetCardGo()
    return this.GetGoByName("CardNode")
end

--通过名字获取对象
function Pin3Utils.GetGoByName(name)
    if not string.IsNullOrEmpty(name) then
        return this.gos[name]
    end
    return nil
end

--新建玩家信息对象
function Pin3Utils.NewUserInfoGo(parent, uiIdx)
    local tempGo = this.GetUserInfoGoByUiIdx(uiIdx)
    local go = NewObject(tempGo, parent)
    local userInfoCtrl = AddLuaComponent(go, "Pin3UserInfoCtrl")
    userInfoCtrl:Init(uiIdx)
    go.name = "UserInfo"
    UIUtil.SetAnchoredPosition(go, 0, 0)
    return userInfoCtrl
end

function Pin3Utils.NewCard(parent)
    local tempGo = this.GetCardGo()
    local go = NewObject(tempGo, parent)
    UIUtil.SetAnchoredPosition(go, 0, 0)
    local card = AddLuaComponent(go, "Pin3Card")
    card:Init()
    return card
end

function Pin3Utils.SetCardIdSprite(cardObj)
    local id = cardObj.id
    if id ~= nil then
        local point = math.floor(id / 10)
        local color = id % 10
        local spName = tostring(point * 100 + color + 1)
        cardObj.forwardImg.sprite = this.spHelper:GetSpriteByName(spName)
    end
end

function Pin3Utils.ShowError(code)
    local tipStr = Pin3Error[code]
    LogError("ShowError", code, tipStr)
    if string.IsNullOrEmpty(tipStr) then
        Toast.Show("操作异常")
    else
        Toast.Show(tipStr)
    end
end


--处理时间戳，单位秒
function Pin3Utils.GetDateByTimeStamp(timeStamp)
    return os.date("%Y-%m-%d %H:%M:%S", timeStamp)
end