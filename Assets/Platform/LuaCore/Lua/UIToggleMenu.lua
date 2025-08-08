--
UIToggleMenu = {
    --
    transform = nil,
    gameObject = nil,
    rectTransform = nil,
    --速度
    speed = 0.3,
    --菜单的Item集合
    items = nil,
    --菜单的宽度
    width = 0,
    --菜单的高度
    height = 0,
    --
    updateTimer = nil,
    --时间统计
    time = 0,
}

UIToggleMenu.meta = { __index = UIToggleMenu }

function UIToggleMenu:New()
    local o = {}
    setmetatable(o, self.meta)
    o.items = {}
    return o
end

--初始化
function UIToggleMenu:Init(transform, width, height)
    self.transform = transform
    self.gameObject = transform.gameObject
    self.rectTransform = self.transform:GetComponent(TypeRectTransform)
    self.width = width
    self.height = height
    local length = transform.childCount
    local item = nil
    local listItem = nil
    local listLength = 0
    for i = 1, length do
        item = {}
        self.items[i] = item
        item.transform = transform:GetChild(i - 1)
        item.gameObject = item.transform.gameObject
        item.rectTransform = item.gameObject:GetComponent(TypeRectTransform)
        item.x = item.rectTransform.anchoredPosition.x
        item.isActive = item.gameObject.activeSelf
        item.toggle = item.transform:Find("Toggle"):GetComponent(TypeToggle)
        item.list = {}
        local listTrans = item.transform:Find("List")
        listLength = listTrans.childCount
        for j = 1, listLength do
            listItem = {}
            item.list[j] = listItem
            listItem.transform = listTrans:GetChild(j - 1)
            listItem.gameObject = listItem.transform.gameObject
            listItem.toggle = listItem.gameObject:GetComponent(TypeToggle)
            listItem.rectTransform = listItem.gameObject:GetComponent(TypeRectTransform)
        end
    end
end

--播放动画
function UIToggleMenu:PlayAnim(isOn, item)
    --item.transform:DOKill()
    if isOn then
        item.transform:DOSizeDelta(Vector2(self.width, self:GetItemHeight(item)), self.speed, false):SetEase(DG.Tweening.Ease.Linear)
        self:StartUpdateTimer()
    else
        item.transform:DOSizeDelta(Vector2(self.width, self.height), self.speed, false):SetEase(DG.Tweening.Ease.Linear)
    end
end

--获取菜单Item的高度
function UIToggleMenu:GetItemHeight(item)
    local height = 0
    local tempItem = nil
    for i = 1, #item.list do
        tempItem = item.list[i]
        if tempItem.gameObject.activeSelf then
            height = height + tempItem.rectTransform.sizeDelta.y
        end
    end
    height = height + self.height + 5
    return height
end

function UIToggleMenu:StartUpdateTimer()
    if self.updateTimer == nil then
        self.updateTimer = UpdateTimer.New(function()
            self:OnUpdateTimer()
        end)
    end
    self.time = Time.realtimeSinceStartup
    self.updateTimer:Start()
end

function UIToggleMenu:StopUpdateTimer()
    if self.updateTimer ~= nil then
        self.updateTimer:Stop()
    end
end

function UIToggleMenu:OnUpdateTimer()
    self:UpdateLayout()
    if Time.realtimeSinceStartup - self.time > (self.speed + 0.1) then
        self:StopUpdateTimer()
    end
end

--更新布局
function UIToggleMenu:UpdateLayout()
    local item = nil
    local y = 0
    for i = 1, #self.items do
        item = self.items[i]
        item.rectTransform.anchoredPosition = Vector2(item.x, y)
        y = y - item.rectTransform.sizeDelta.y
    end
    self.rectTransform.sizeDelta = Vector2(self.width, math.abs(y))
end