--Lua中的UIScrollView，只针对单行或者单列，多行或者多列需要另行添加
--Content的锚点为左上对齐
UIScrollView = {
    --是否初始化标识
    isInited = false,
    --UIScrollViewHelper对象
    scrollViewHelper = nil,
    --是否是竖的滚动
    isScrollVertical = false,
    --滚动区域的宽度
    scrollViewWidth = 100,
    --滚动区域的高度
    scrollViewHeight = 100,
    --显示对象
    itemPrefab = nil,
    --显示对象父节点
    itemParentNode = nil,
    --item的宽度
    itemWidth = 100,
    --item的高度
    itemHeight = 100,
    --item间的x间隙
    itemGapX = 10,
    --item间的y间隙
    itemGapY = 10,
    --滚动区域的宽度或者高度，根据滚动方向来定
    scrollViewSize = 100,
    --item的宽度或者高度，根据滚动方向来定
    itemSize = 100,
    --item间的间隙大小，根据滚动方向来定
    itemGapSize = 10,
    --item的x
    itemPositionX = 0,
    --item的y
    itemPositionY = 0,
    --列数
    itemCellSizeX = 1,
    --行数
    itemCellSizeY = 1,
    --行数或者列数，根据滚动方向来定
    itemCellSize = 1,
    --------------------------------------------------------
    --显示项开始的索引
    startIndex = -1,
    --显示项集合
    items = nil,
    --内容节点的宽度或者高度，根据滚动方向来定
    contentSize = 100,
    --数据长度
    dataLength = 0,
    --------------------------------------------------------
    --设置Item的方法
    onSetItemCallback = nil,
    --更新Item的方法
    onUpdateItemCallback = nil,
}

UIScrollView.meta = { __index = UIScrollView }

function UIScrollView:New()
    local o = {}
    setmetatable(o, self.meta)
    o.items = {}
    return o
end


--================================================================
--初始化，如果有其他参数设置，可以单独在该方法调用后设置
function UIScrollView:Init(scrollViewHelper)
    self.scrollViewHelper = scrollViewHelper
    self.scrollViewHelper:Init()
    self.scrollViewHelper:AddContentPositionChangedLuaFunction(UIScrollView.OnContentPositionChanged, self)
    self.isScrollVertical = self.scrollViewHelper:IsScrollVertical()
    local scrollRectTrans = self.scrollViewHelper:GetScrollTransform()
    local rect = scrollRectTrans.rect
    self.scrollViewWidth = rect.width
    self.scrollViewHeight = rect.height
    self.itemPrefab = self.scrollViewHelper.itemPrefab
    self.itemParentNode = self.scrollViewHelper:GetItemParentNode()
    local v = self.scrollViewHelper.itemSize
    self.itemWidth = v.x
    self.itemHeight = v.y
    v = self.scrollViewHelper.itemGap
    self.itemGapX = v.x
    self.itemGapY = v.y

    v = self.scrollViewHelper.cellSize
    self.itemCellSizeX = v.x
    self.itemCellSizeY = v.y

    if self.isScrollVertical then
        self.scrollViewSize = self.scrollViewHeight
        self.itemSize = self.itemHeight
        self.itemGapSize = self.itemGapY
        self.itemCellSize = self.itemCellSizeX
    else
        self.scrollViewSize = self.scrollViewWidth
        self.itemSize = self.itemWidth
        self.itemGapSize = self.itemGapX
        self.itemCellSize = self.itemCellSizeY
    end

    v = self.scrollViewHelper:GetItemPosition()
    self.itemPositionX = v.x
    self.itemPositionY = v.y
    self:CheckAndCreateItems()

    self.isInited = true
end

--
function UIScrollView:Clear()
    local length = #self.items
    for i = 1, length do
        destroy(self.items[i].gameObject)
    end
    self.items = {}
    self:ResetContentPosition()
end

--
function UIScrollView:Destoy()
    self:Clear()
    --清除UI、GameObject对象
end

--================================================================
--坐标改变
function UIScrollView.OnContentPositionChanged(scrollView, x, y)
    scrollView:UpdateItemsDisplay(x, y)
end

--================================================================
--创建Item
function UIScrollView:CreateItem(name)
    local item = {}
    local obj = CreateGO(self.itemPrefab, self.itemParentNode, name)
    item.name = name
    item.gameObject = obj
    item.transform = obj.transform
    item.index = #self.items + 1
    table.insert(self.items, item)

    return item
end

--检测或者创建Item
function UIScrollView:CheckAndCreateItems()
    local itemTotal = 0

    itemTotal = self.scrollViewSize / (self.itemSize + self.itemGapSize)
    itemTotal = math.floor(itemTotal) + 2

    if self.isScrollVertical then
        itemTotal = itemTotal * self.itemCellSizeX
    else
        itemTotal = itemTotal * self.itemCellSizeY
    end

    for i = #self.items + 1, itemTotal do
        local item = self:CreateItem(tostring(i))
        if self.onSetItemCallback ~= nil then
            self.onSetItemCallback(item)
        end
    end
end

--================================================================
--更新Item的显示
function UIScrollView:UpdateItemsDisplay(x, y)
    local position = 0
    --item位置符号
    local itemPositionSign = -1
    if self.isScrollVertical then
        --y为正值
        if y + self.scrollViewSize > self.contentSize then
            return
        end
        if y < 0 then
            return
        end
        position = y
    else
        --X为负值
        if x - self.scrollViewSize < -self.contentSize then
            return
        end
        if x > 0 then
            return
        end
        position = -x
        itemPositionSign = 1
    end

    local index = math.floor(position / (self.itemSize + self.itemGapSize))
    --startIndex从0开始
    if self.startIndex == index then
        return
    end
    self.startIndex = index

    local startPosition = self.startIndex * itemPositionSign * (self.itemSize + self.itemGapSize)
    local itemLength = #self.items
    local item = nil
    local tempIndex = 1
    local tempRow = 0
    local temoCol = 0
    local tempX = 0
    local tempY = 0
    local tempStartIndex = 0
    for i = 1, itemLength do
        item = self.items[i]
        if self.isScrollVertical then
            tempRow = math.floor((i - 1) / self.itemCellSizeX)
            temoCol = i - 1 - tempRow * self.itemCellSizeX
            tempX = temoCol * (self.itemGapX + self.itemWidth)
            tempY = startPosition + tempRow * itemPositionSign * (self.itemSize + self.itemGapSize)
            tempStartIndex = self.startIndex * self.itemCellSizeX
        else
            temoCol = math.floor((i - 1) / self.itemCellSizeY)
            tempRow = i - 1 - temoCol * self.itemCellSizeY
            tempX = startPosition + tempRow * itemPositionSign * (self.itemSize + self.itemGapSize)
            tempY = tempRow * (self.itemGapY + self.itemHeight)
            tempStartIndex = self.startIndex * self.itemCellSizeY
        end

        UIUtil.SetAnchoredPosition(item.gameObject, tempX, tempY)

        tempIndex = tempStartIndex + i
        if tempIndex > self.dataLength then
            UIUtil.SetActive(item.gameObject, false)
        else
            --数据索引
            item.dataIndex = tempIndex
            UIUtil.SetActive(item.gameObject, true)
            if self.onUpdateItemCallback ~= nil then
                self.onUpdateItemCallback(item)
            end
        end
    end

end

--================================================================
--重新设置Content的坐标
function UIScrollView:ResetContentPosition()
    if self.scrollViewHelper ~= nil then
        self.scrollViewHelper:Reset()
    end
    self.startIndex = -1
end

--设置数据
function UIScrollView:SetDatas(datas)
    if datas == nil then
        datas = {}
    end

    self.dataLength = #datas
    local temp = 0
    if self.isScrollVertical then
        temp = math.ceil(self.dataLength / self.itemCellSizeX)
    else
        temp = math.ceil(self.dataLength / self.itemCellSizeY)
    end

    self.contentSize = temp * (self.itemSize + self.itemGapSize) - self.itemGapSize
    if self.contentSize < self.scrollViewSize then
        self.contentSize = self.scrollViewSize
    end

    local v = self.scrollViewHelper:GetContentPosition()
    if self.isScrollVertical then
        self.scrollViewHelper:SetContentHeight(self.contentSize)
        if v.y < 0 then
            v.y = 0
            self.scrollViewHelper:Reset()
        elseif self.contentSize - v.y < self.scrollViewSize then
            v.y = self.contentSize - self.scrollViewSize
            self.scrollViewHelper:SetContentY(v.y)
        end
    else
        self.scrollViewHelper:SetContentWidth(self.contentSize)
        if v.x > 0 then
            v.x = 0
            self.scrollViewHelper:Reset()
        elseif v.x + self.contentSize < self.scrollViewSize then
            v.x = -self.contentSize + self.scrollViewSize
            self.scrollViewHelper:SetContentX(v.x)
        end
    end
    self.startIndex = -1
    self:UpdateItemsDisplay(v.x, v.y)
end