UIHScrollView = {
    --C# ScrollRect组件
    scrollRect = nil,

    --滚动区域的高度
    scrollViewWidth = 100,
    --检测顶部Y
    pageCheckTopX = 0,
    --检测底部Y
    pageCheckBottomX = 0,
    --显示对象
    itemPrefab = nil,
    --item的高度
    itemWidth = 100,
    --item间的y间隙
    itemGap = 10,
    --页面高度
    pageWidth = 0,
    --滑动检测的间隔
    scrollCheckGap = 5,
    --------------------------------------------------------
    --------------------------------------------------------
    --行数
    row = 2,

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
    itemGap = 10,
    --Item的高度
    itemWidth = 100,
    --正文高度
    contentWidth = 0,
    --上一次滑动的Y值
    lastScrollX = 0,
    --上一次处理的Y值
    lastHandleX = 0,
    --检测快速滑动的值
    quickScrollGap = 30,
    --是否快速滑动
    isQuickScroll = false,
    --临时的差值
    tempDelta = 0,
    --临时的差值绝对值
    tempAbsDelta = 0,
    --临时的滑动的绝对值
    tempAbsScrollX = 0,
    --
    tempIndex = 0,
    --
    tempStartX = 0,
    --
    tempContentX = 0,
    --
    tempItemX = 0,
    --
    tempItemY = 0,
    --显示项的Index
    itemIndex = 0,
    --数据的Index
    dataIndex = 0,
    --------------------------------------------------------
    --显示项开始的索引
    startIndex = -1,
    --
    lastIndex = -1,
    --显示项集合
    items = nil,
    --显示项
    item = nil,
    --显示项的列数
    itemCols = 0,
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

UIHScrollView.meta = { __index = UIHScrollView }

function UIHScrollView.New()
    local o = {}
    setmetatable(o, UIHScrollView.meta)
    o.items = {}
    return o
end


--================================================================
--初始化，如果有其他参数设置，可以单独在该方法调用后设置
function UIHScrollView:Init(transform, row, pageCol, left, right, itemWidth, itemHeight, itemGap)
    self.transform = transform
    self.row = row
    self.pageCol = pageCol
    self.pageCount = row * pageCol
    self.left = left
    self.right = right
    self.itemWidth = itemWidth
    self.itemHeight = itemHeight
    self.itemGap = itemGap

    self.scrollRect = transform:GetComponent(TypeScrollRect)
    self.rectTransform = transform:GetComponent(TypeRectTransform)
    self.scrollViewWidth = self.rectTransform.rect.width

    local content = transform:Find("Viewport/Content")
    self.itemContent = content:GetComponent(TypeRectTransform)
    self.itemContentInitY = self.itemContent.anchoredPosition.y
    self.itemContentInitHeight = self.itemContent.sizeDelta.y
    self.itemPrefab = content:Find("Item").gameObject

    --每页宽度
    self.pageWidth = (self.itemWidth + self.itemGap) * self.pageCol
    self.scrollCheckGap = self.pageWidth / 30
    if self.scrollCheckGap < 5 then
        self.scrollCheckGap = 5
    end

    self.scrollRect.onValueChanged:AddListener(function() self:OnUpdate() end)
    self:CheckAndCreateItems()
end

--
function UIHScrollView:Clear()
    local length = #self.items
    for i = 1, length do
        GameObject.Destroy(self.items[i].gameObject)
    end
    self.items = {}
    self:Reset()
end

--
function UIHScrollView:Destoy()
    self:Clear()
    --清除UI、GameObject对象
end


--================================================================
--创建Item
function UIHScrollView:CreateItem(index)
    local item = {}
    local name = tostring(index)
    local obj = CreateGO(self.itemPrefab, self.itemContent, name)
    item.index = index
    item.gameObject = obj
    item.transform = obj.transform
    item.rectTransform = obj:GetComponent(TypeRectTransform)
    --数据索引
    item.dataIndex = 0
    --处理索引
    item.handleIndex = 0
    UIUtil.SetActive(item.gameObject, false)
    table.insert(self.items, item)
    return item
end

--检测或者创建Item
function UIHScrollView:CheckAndCreateItems()
    self.itemCols = math.ceil(self.scrollViewWidth / (self.itemWidth + self.itemGap)) + 1
    local itemTotal = self.itemCols * self.row

    for i = #self.items + 1, itemTotal do
        local item = self:CreateItem(i)
        if self.onSetItemCallback ~= nil then
            self.onSetItemCallback(item)
        end
    end
end

--隐藏Item
function UIHScrollView:HideAllItem()
    for i = 1, #self.items do
        UIUtil.SetActive(self.items[i].gameObject, false)
    end
end

--================================================================
--
--坐标改变
function UIHScrollView:OnUpdate()
    self:UpdateItemsDisplay()
end

--================================================================
--
--重置
function UIHScrollView:Reset()
    self.pageTotal = 0
    self.dataTotal = 0
    --
    self.pageIndex = 1
    --
    self.lastIndex = -1
    --
    self.needPrevPageIndex = -1
    self.needPrevPageTime = 0
    self.needNextPageIndex = -1
    self.needNextPageTime = 0
    --
    self.scrollRect:StopMovement()
    self.itemContent.anchoredPosition = Vector2(0, self.itemContentInitY)
    self.itemContent.sizeDelta = Vector2(self.scrollViewWidth, self.itemContentInitHeight)
    --
    self.lastScrollX = 0
    --
    self:HideAllItem()
end

--设置总数据
function UIHScrollView:Set(dataTotal)
    self.lastIndex = -1

    self.pageTotal = math.ceil(dataTotal / self.pageCount)
    self.dataTotal = dataTotal
    self.col = math.ceil(self.dataTotal / self.row)
    self.contentWidth = self.left + self.right + self.col * (self.itemWidth + self.itemGap)
    if self.col > 0 then
        self.contentWidth = self.contentWidth - self.itemGap
    end
    if self.contentWidth < self.scrollViewWidth then
        self.contentWidth = self.scrollViewWidth
    end
    self.itemContent.sizeDelta = Vector2(self.contentWidth, self.itemContentInitHeight)
    --
    self:HandleItemsDisplay()
end

--================================================================
--更新Item的显示
function UIHScrollView:UpdateItemsDisplay()
    --横向滑动的时候取反
    self.tempContentX = -self.itemContent.anchoredPosition.x

    if self.tempContentX < 0 then
        self.tempContentX = 0
    elseif self.tempContentX > self.contentWidth - self.scrollViewWidth then
        self.tempContentX = self.contentWidth - self.scrollViewWidth
    end

    self.tempAbsScrollX = math.abs(self.tempContentX - self.lastScrollX)
    self.lastScrollX = self.tempContentX

    self.tempDelta = self.tempContentX - self.lastHandleX
    self.tempAbsDelta = math.abs(self.tempDelta)

    --当前页计算
    self.pageIndex = math.floor((self.tempContentX + self.left) / self.pageWidth) + 1

    self:HandleItemsDisplay()

    self.isQuickScroll = self.tempAbsScrollX > self.quickScrollGap
    if not self.isQuickScroll then
        --处理的时候才记录该值
        self.lastHandleX = self.tempContentX
        --

        --处理页数需求，小于0向右滑，表示减页数，大于0表示向左滑，加页数
        if self.tempDelta < 0 then
            self.pageCheckTopX = self.left + (self.pageIndex - 1) * self.pageWidth + self.pageWidth * 0.2

            --LogError(self.tempDelta, self.pageIndex, self.tempContentX , self.pageCheckTopX)

            --请求上一页
            if self.pageIndex > 1 and self.tempContentX < self.pageCheckTopX then
                self:CheckNeedPrevPageCallback(self.pageIndex, Time.realtimeSinceStartup)
            end
        else
            self.pageCheckBottomX = self.left + (self.pageIndex - 1) * self.pageWidth + self.pageWidth * 0.8 - self.scrollViewWidth

            --LogError(self.pageWidth, self.tempDelta, self.pageIndex, self.pageTotal, self.tempContentX , self.pageCheckBottomX)
            if self.pageIndex <= self.pageTotal and self.tempContentX > self.pageCheckBottomX then
                self:CheckNeedNextPageCallback(self.pageIndex, Time.realtimeSinceStartup)
            end
        end
    end
end

--获取当前页
function UIHScrollView:GetPageIndex()
    return self.pageIndex
end

--检测需求页的请求
function UIHScrollView:CheckNeedPrevPageCallback(pageIndex, time)
    if pageIndex ~= self.needPrevPageIndex then
        self.needPrevPageIndex = pageIndex
        self.needPrevPageTime = time
        if self.onNeedPageCallback ~= nil then
            self.onNeedPageCallback(pageIndex)
        end
    end
end

--检测需求页的请求
function UIHScrollView:CheckNeedNextPageCallback(pageIndex, time)
    if pageIndex ~= self.needNextPageIndex then
        self.needNextPageIndex = pageIndex
        self.needNextPageTime = time
        if self.onNeedPageCallback ~= nil then
            self.onNeedPageCallback(pageIndex)
        end
    end
end

--处理显示
function UIHScrollView:HandleItemsDisplay()
    self.tempContentX = -self.itemContent.anchoredPosition.x
    self.startIndex = (self.tempContentX + self.left) / (self.itemWidth + self.itemGap)
    self.startIndex = math.floor(self.startIndex)
    if self.startIndex < 0 then
        self.startIndex = 0
    end

    if self.startIndex == self.lastIndex then
        return
    end
    self.lastIndex = self.startIndex

    local tempColIndex = 0
    local tempDataColInex = 0
    for i = 1, self.itemCols do
        tempColIndex = self.startIndex + i - 1
        self.tempItemX = self.left + tempColIndex * (self.itemWidth + self.itemGap)
        tempDataColInex = tempColIndex * self.row

        self.tempIndex =  (i - 1) * self.row
        for j = 1, self.row do
            self.itemIndex = self.tempIndex + j
            self.dataIndex = tempDataColInex + j
            self.item = self.items[self.itemIndex]
            if self.dataIndex > self.dataTotal then
                self.item.dataIndex = 0
                UIUtil.SetActive(self.item.gameObject, false)
            else
                self.tempItemY = -(j - 1) * self.itemHeight
                --数据索引
                self.item.rectTransform.anchoredPosition = Vector2(self.tempItemX, self.tempItemY)
                self.item.dataIndex = self.dataIndex
                UIUtil.SetActive(self.item.gameObject, true)
                if self.onUpdateItemCallback ~= nil then
                    self.onUpdateItemCallback(self.item)
                end
            end
        end
    end
end

--根据数据索引获取指定Item
function UIHScrollView:GetItemByDataIndex(dataIndex)
    local item = nil
    for i = 1, #self.items do
        item = self.items[i]
        if item.dataIndex == dataIndex then
            return item
        end
    end
    return nil
end

--置顶
function UIHScrollView:MoveToTop()
    self.scrollRect:StopMovement()
    self.itemContent.anchoredPosition = Vector2(0, self.itemContentInitY)
end

--置底
function UIHScrollView:MoveToBottom()
    self.scrollRect:StopMovement()
    local x = self.contentWidth - self.scrollViewWidth
    self.itemContent.anchoredPosition = Vector2(x, self.itemContentInitY)
end

--移动到指定位置
function UIHScrollView:MoveTo(index)
    local x = (self.itemWidth + self.itemGap) * (index - 1)
    if x < 0 then
        x = 0
    elseif x > self.contentWidth - self.scrollViewWidth then
        x = self.contentWidth - self.scrollViewWidth
    end
    self.scrollRect:StopMovement()
    self.itemContent.anchoredPosition = Vector2(x, self.itemContentInitY)
end