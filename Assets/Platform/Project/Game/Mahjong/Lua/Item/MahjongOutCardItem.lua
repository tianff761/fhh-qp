--打出去的牌
MahjongOutCardItem = {
    enabled = false,
    -----------------------------------------------
    seatIndex = 0,
    gameObject = nil,
    type = -1,
    image = nil,
    ------------------清除的数据
    --牌数据
    cardData = nil,
    --key值存储
    lastCardKey = MahjongConst.INVALID_CARD_KEY,
    --牌是否选中
    isSelected = false,
    x = 0,
    y = 0,
    --行数
    row = 0,
    --列数
    column = 0
}

local meta = { __index = MahjongOutCardItem }

function MahjongOutCardItem.New()
    local obj = {}
    setmetatable(obj, meta)
    obj.cardData = nil
    return obj
end

function MahjongOutCardItem:Init(gameObject, type, seatIndex)
    self.seatIndex = seatIndex
    self.type = type
    self.gameObject = gameObject
    self.isSelected = false
    
    self.cardFrame = self.gameObject.transform:Find("CardFrame"):GetComponent("Image")
    self.cardIcon = self.gameObject.transform:Find("CardIcon"):GetComponent("ShapeImage")
    self.cardIconGo = self.gameObject.transform:Find("CardIcon").gameObject
end

function MahjongOutCardItem:Clear()
    self.cardData = nil
    self.lastCardKey = MahjongConst.INVALID_CARD_KEY
    --目的是显示的时候便于重新更新下选中
    self.isSelected = true
    self:Hide()
end

function MahjongOutCardItem:Destroy()

end

--================================================================
--
--设置牌
--牌数据 / 牌类型 / 行数 / 第几张牌
function MahjongOutCardItem:SetData(cardData, newType, row, index)
    self.cardData = cardData
   
    if self.lastCardKey ~= self.cardData.key then
        self.lastCardKey = self.cardData.key

        local tempType = self.type
        if newType ~= nil then
            tempType = newType
        end

        self.cardFrame.sprite = MahjongResourcesMgr.GetCardFrameSprite(tempType, self.seatIndex, row, index)
        self.cardIcon.sprite = MahjongResourcesMgr.GetCardSprite(self.lastCardKey)

        if (self.seatIndex == MahjongSeatIndex.Seat1 and index > 5) or (self.seatIndex == MahjongSeatIndex.Seat3 and index < 6) then
            self.cardFrame.gameObject.transform.localScale = Vector3.New(-1, 1, 1)
        end

        self:SetCardIconPosition(tempType, self.seatIndex, row, index)
    end
    self:SetSelected(false)
    self:Show()
    local alpha = cardData.id < 0 and 0.7 or 1
    UIUtil.SetImageAlpha(self.cardIcon, alpha)

    -- self:SetCardItemSort(row, index)
end

--设置出牌icon坐标、大小、偏移
function MahjongOutCardItem:SetCardIconPosition(tempType, seatIndex, row, index)
    if tempType ~= MahjongCardDisplayType.Display then
        return
    end
    row = row > 4 and 4 or row
    self.row = row
    self.column = index
    local config = MahjongOutCardIconPosConfigDicts[seatIndex][row]
    if config == nil then
        LogError(seatIndex.." 号位玩家当前出牌配置错误 ")
        return
    end
    local pos_x = nil
    local pos_y = nil
    local scale_x = nil
    local scale_y = nil
    local rotation_z = config.RotationZ
    if seatIndex == MahjongSeatIndex.Seat1 or seatIndex == MahjongSeatIndex.Seat3 then

        --二人麻将单行11张牌 1 ==> 1 / 11 ==> 9 / 2--10 ==> 1--9
        if MahjongDataMgr.playerTotal == 2 then
            if index == 1 then
                index = 1
            elseif index == 11 then
                index = 9
            else
                index = index - 1
            end
        end
        pos_x = config.posX[index]
        pos_y = config.posY
        scale_x =  config.scaleX
        scale_y =  config.scaleY
        self.cardIcon.offset = config.offset[index]
    else
        pos_x = config.posX
        pos_y = config.posY
        scale_x =  config.scaleX[index]
        scale_y =  config.scaleY[index]
        self.cardIcon.offset = config.offset
    end
    UIUtil.SetAnchoredPosition(self.cardIconGo, pos_x, pos_y)
    UIUtil.SetRotation(self.cardIconGo, 0, 0, rotation_z)
    UIUtil.SetLocalScale(self.cardIconGo, scale_x, scale_y, 1)
end

function MahjongOutCardItem:SetPosition(x, y)
    if self.gameObject ~= nil then
        self.x = x
        self.y = y
        UIUtil.SetAnchoredPosition(self.gameObject, x, y)
    end
end

function MahjongOutCardItem:Show()
    if self.enabled == true then
        return
    end
    self.enabled = true
    if self.gameObject ~= nil then
        UIUtil.SetActive(self.gameObject, true)
    end
end

function MahjongOutCardItem:Hide()
    if self.enabled == false then
        return
    end
    self.enabled = false
    if self.gameObject ~= nil then
        UIUtil.SetActive(self.gameObject, false)
    end
end

function MahjongOutCardItem.IsActive()
    if self.gameObject ~= nil then
        return self.gameObject.activeSelf
    end
    return false
end

--设置点击选中
function MahjongOutCardItem:SetSelected(value)
    if self.enabled == false then
        return
    end
    if self.isSelected ~= value then
        self.isSelected = value
        if value then
            UIUtil.SetImageColor(self.cardIcon, 1, 0.549, 0.549)
        else
            UIUtil.SetImageColor(self.cardIcon, 1, 1, 1)
        end
    end
end

--================================================================
