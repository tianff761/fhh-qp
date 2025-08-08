ScrollRectHelper = {
    scrollRect = nil,
    --下箭头图标GameObject
    downArrowsGo = nil,
    --上一次ScrollRect.velocity的Y值
    lastVelocityY = 0,
    content = nil
}

local meta = { __index = ScrollRectHelper }
function ScrollRectHelper.New(scrollRect, downArrowsGo)
    local o = {}
    setmetatable(o, meta)
    o.scrollRect = scrollRect
    o.downArrowsGo = downArrowsGo
    o:InitValue()
    return o
end

function ScrollRectHelper:InitValue()
    self.content = self.scrollRect.content
    self:AddMsg()

    Scheduler.scheduleOnceGlobal(function() 
        self.scrollRect.velocity = Vector2(0, 1)
    end, 0.03)
end

function ScrollRectHelper:AddMsg()
    self.scrollRect.onValueChanged:AddListener(function(v2)
        self:OnScrollRectValueChange(v2)
    end)
end

function ScrollRectHelper:OnScrollRectValueChange(v2)
    if not self.scrollRect.gameObject.activeSelf then
        UIUtil.SetActive(self.downArrowsGo, false)
        return
    end

    if math.abs(v2.y - self.lastVelocityY) < 0.1 then
        return
    end
    self.lastVelocityY = v2.y
    local h1 = self.scrollRect.transform.rect.height
    local h2 = UIUtil.GetHeight(self.content)
    if h2 >= h1 then
        UIUtil.SetActive(self.downArrowsGo, v2.y >= 0.1)
    else
        UIUtil.SetActive(self.downArrowsGo, false)
    end
end

return ScrollRectHelper