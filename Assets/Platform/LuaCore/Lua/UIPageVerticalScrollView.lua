--Lua中的UIPageVerticalScrollView，只针对单行或者单列，多行或者多列需要另行添加
--Content的锚点为左上对齐
UIPageVerticalScrollView = {
    --ScrollRect组件
    scrollRect = nil,

    --滚动区域的高度
    scrollViewHeight = 100,
    --检测顶部Y
    pageCheckTopY = 0,
    --检测底部Y
    pageCheckBottomY = 0,
    --显示对象
    itemPrefab = nil,
    --item的高度
    itemHeight = 100,
    --item间的y间隙
    itemGapY = 10,
    --页面高度
    pageHeight = 0,
    --滑动检测的间隔
    scrollCheckGap = 5,
    --------------------------------------------------------
    --------------------------------------------------------
    --每页的总数，总共的高度应该大于滑动区域
    pageCount = 10,
    --当前页数
    pageIndex = 1,
    --总页数
    pageTotal = 0,
    --页面回调间隔，即滑动时，需要处理上下页时的回调间隔，单位秒
    pageCallbackInterval = 5,
    --数据总数
    dataTotal = 0,

    --离顶上的距离
    top = 0,
    --离底部的距离
    bottom = 0,
    --Item的间隔
    itemGapY = 10,
    --Item的高度
    itemHeight = 100,
    --正文高度
    contentHeight = 0,
    --上一次滑动的Y值
    lastScrollY = 0,
    --上一次处理的Y值
    lastHandleY = 0,
    --检测快速滑动的值
    quickScrollGap = 30,
    --是否快速滑动
    isQuickScroll = false,
    --临时的差值
    tempDelta = 0,
    --临时的差值绝对值
    tempAbsDelta = 0,
    --临时的滑动的绝对值
    tempAbsScrollY = 0,
    --
    tempIndex = 0,
    --
    tempStartY = 0,
    --
    tempContentY = 0,
    --
    tempItemY = 0,

    --------------------------------------------------------
    --显示项开始的索引
    startIndex = -1,
    --显示项集合
    items = nil,
    --显示项
    item = nil,
    --显示项长度
    itemLength = 0,
    --------------------------------------------------------
    --设置Item的方法
    onSetItemCallback = nil,
    --更新Item的方法
    onUpdateItemCallback = nil,
    --处理需求页回调
    onNeedPageCallback = nil,
    --------------------------------------------------------
    --需求的上一页数
    needPrevPageIndex = -1,
    --需求页的时间，用于超时
    needPrevPageTime = 0,
    --需求的下一页数
    needNextPageIndex = -1,
    --需求页的时间，用于超时
    needNextPageTime = 0,
}

UIPageVerticalScrollView.meta = { __index = UIPageVerticalScrollView }

function UIPageVerticalScrollView.New()
    local o = {}
    setmetatable(o, UIPageVerticalScrollView.meta)
    o.items = {}
    return o
end


--================================================================
--初始化，如果有其他参数设置，可以单独在该方法调用后设置
function UIPageVerticalScrollView:Init(transform, pageCount, top, bottom, itemHeight, itemGapY)
    self.transform = transform
    self.pageCount = pageCount
    self.top = top
    self.bottom = bottom
    self.itemHeight = itemHeight
    self.itemGapY = itemGapY

    self.scrollRect = transform:GetComponent("ScrollRect")
    self.rectTransform = transform:GetComponent(TypeRectTransform)
    self.scrollViewHeight = self.rectTransform.rect.height

    local content = transform:Find("Viewport/Content")
    self.itemContent = content:GetComponent(TypeRectTransform)
    self.itemContentInitX = self.itemContent.anchoredPosition.x
    self.itemContentInitWidth = self.itemContent.sizeDelta.x
    self.itemPrefab = content:Find("Item").gameObject

    self.pageHeight = (self.itemHeight + self.itemGapY) * self.pageCount
    self.scrollCheckGap = self.pageHeight / 30
    if self.scrollCheckGap < 5 then
        self.scrollCheckGap = 5
    end

    self.updateTimer = transform:GetComponent("UIUpdateHelper")
    self.updateTimer.onUpdate = function() self:OnUpdate() end
    self:CheckAndCreateItems()
end

--
function UIPageVerticalScrollView:Clear()
    local length = #self.items
    for i = 1, length do
        destroy(self.items[i].gameObject)
    end
    self.items = {}
    self:Reset()
end

--
function UIPageVerticalScrollView:Destoy()
    self:Clear()
    --清除UI、GameObject对象
end


--================================================================
--创建Item
function UIPageVerticalScrollView:CreateItem(name)
    local item = {}
    local obj = CreateGO(self.itemPrefab, self.itemContent, name)
    item.name = name
    item.gameObject = obj
    item.transform = obj.transform
    item.rectTransform = obj:GetComponent(TypeRectTransform)
    item.index = #self.items + 1
    --数据索引
    item.dataIndex = 0
    --处理索引
    item.handleIndex = 0
    UIUtil.SetActive(item.gameObject, false)
    table.insert(self.items, item)
    return item
end

--检测或者创建Item
function UIPageVerticalScrollView:CheckAndCreateItems()
    local itemTotal = self.scrollViewHeight / (self.itemHeight + self.itemGapY)
    itemTotal = math.ceil(itemTotal) + 1

    for i = #self.items + 1, itemTotal do
        local item = self:CreateItem(tostring(i))
        if self.onSetItemCallback ~= nil then
            self.onSetItemCallback(item)
        end
    end
    self.itemLength = #self.items
end

--隐藏Item
function UIPageVerticalScrollView:HideAllItem()
    for i = 1, #self.items do
        UIUtil.SetActive(self.items[i].gameObject, false)
    end
end

--================================================================
--
--坐标改变
function UIPageVerticalScrollView:OnUpdate()
    self:UpdateItemsDisplay()
end

--================================================================
--
--重置
function UIPageVerticalScrollView:Reset()
    self.pageTotal = 0
    self.dataTotal = 0
    --
    self.pageIndex = 1
    --
    self.needPrevPageIndex = -1
    self.needPrevPageTime = 0
    self.needNextPageIndex = -1
    self.needNextPageTime = 0
    --
    self.scrollRect:StopMovement()
    self.itemContent.anchoredPosition = Vector2(self.itemContentInitX, 0)
    self.itemContent.sizeDelta = Vector2(self.itemContentInitWidth, self.scrollViewHeight)
    --
    self.lastScrollY = 0
    --
    self:HideAllItem()
end

--设置一页数据
function UIPageVerticalScrollView:Set(pageTotal, dataTotal)
    self.pageTotal = pageTotal
    self.dataTotal = dataTotal

    self.contentHeight = self.top + self.bottom + self.dataTotal * (self.itemHeight + self.itemGapY)
    if self.dataTotal > 0 then
        self.contentHeight = self.contentHeight - self.itemGapY
    end
    if self.contentHeight < self.scrollViewHeight then
        self.contentHeight = self.scrollViewHeight
    end
    self.itemContent.sizeDelta = Vector2(self.itemContentInitWidth, self.contentHeight)
    --
    self:HandleItemsDisplay()
end

--================================================================
--更新Item的显示
function UIPageVerticalScrollView:UpdateItemsDisplay()
    self.tempContentY = self.itemContent.anchoredPosition.y

    if self.tempContentY < 0 then
        self.tempContentY = 0
    elseif self.tempContentY > self.contentHeight - self.scrollViewHeight then
        self.tempContentY = self.contentHeight - self.scrollViewHeight
    end

    self.tempAbsScrollY = math.abs(self.tempContentY - self.lastScrollY)
    self.lastScrollY = self.tempContentY

    self.tempDelta = self.tempContentY - self.lastHandleY
    self.tempAbsDelta = math.abs(self.tempDelta)
    if self.tempAbsDelta < self.scrollCheckGap then
        return
    end

    --当前页计算
    self.pageIndex = math.floor((self.tempContentY - self.top) / self.pageHeight) + 1

    self:HandleItemsDisplay()

    self.isQuickScroll = self.tempAbsScrollY > self.quickScrollGap
    if not self.isQuickScroll then
        --处理的时候才记录该值
        self.lastHandleY = self.tempContentY
        --
        --处理页数需求，小于0向上滑
        if self.tempDelta < 0 then
            self.pageCheckTopY = self.top + (self.pageIndex - 1) * self.pageHeight + self.pageHeight * 0.2
            --请求上一页
            if self.pageIndex > 1 and self.tempContentY < self.pageCheckTopY then
                self:CheckNeedPrevPageCallback(self.pageIndex, self.pageIndex - 1, Time.realtimeSinceStartup)
            end
        else
            self.pageCheckBottomY = self.top + (self.pageIndex - 1) * self.pageHeight + self.pageHeight * 0.8 - self.scrollViewHeight
            if self.pageIndex <= self.pageTotal and self.tempContentY > self.pageCheckBottomY then
                self:CheckNeedNextPageCallback(self.pageIndex, self.pageIndex + 1, Time.realtimeSinceStartup)
            end
        end
    end
end

--获取当前页
function UIPageVerticalScrollView:GetPageIndex()
    return self.pageIndex
end

--检测需求页的请求
function UIPageVerticalScrollView:CheckNeedPrevPageCallback(pageIndex, needPage, time)
    if needPage ~= self.needPrevPageIndex then
        self.needPrevPageIndex = needPage
        self.needPrevPageTime = time
        if self.onNeedPageCallback ~= nil then
            self.onNeedPageCallback(pageIndex, needPage)
        end
    end
end

--检测需求页的请求
function UIPageVerticalScrollView:CheckNeedNextPageCallback(pageIndex, needPage, time)
    if needPage ~= self.needNextPageIndex then
        self.needNextPageIndex = needPage
        self.needNextPageTime = time
        if self.onNeedPageCallback ~= nil then
            self.onNeedPageCallback(pageIndex, needPage)
        end
    end
end

--处理显示
function UIPageVerticalScrollView:HandleItemsDisplay()
    self.tempContentY = self.itemContent.anchoredPosition.y
    self.startIndex = (self.tempContentY - self.top) / (self.itemHeight + self.itemGapY)
    self.startIndex = math.floor(self.startIndex)
    if self.startIndex < 0 then
        self.startIndex = 0
    end
    self.tempStartY = -self.top - self.startIndex * (self.itemHeight + self.itemGapY)

    for i = 1, self.itemLength do
        self.tempItemY = self.tempStartY - (i - 1) * (self.itemHeight + self.itemGapY)

        self.tempIndex = self.startIndex + i
        self.item = self.items[i]

        if self.tempIndex > self.dataTotal then
            self.item.dataIndex = 0
            UIUtil.SetActive(self.item.gameObject, false)
        else
            --数据索引
            self.item.rectTransform.anchoredPosition = Vector2(0, self.tempItemY)
            self.item.dataIndex = self.tempIndex
            UIUtil.SetActive(self.item.gameObject, true)
            if self.onUpdateItemCallback ~= nil then
                self.onUpdateItemCallback(self.item)
            end
        end
    end
end

--根据索引获取指定Item
function UIPageVerticalScrollView:GetItemByIndex(index)
    local item = nil
    for i = 1, #self.items do
        item = self.items[i]
        if item.dataIndex == index then
            break
        end
    end
    return item
end

function UIPageVerticalScrollView:GetFirstItem()
    for i = 1, #self.items do
        return self.items[i]
    end
    return nil
end