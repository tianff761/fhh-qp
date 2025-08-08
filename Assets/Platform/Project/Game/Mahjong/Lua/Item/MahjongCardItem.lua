--单张牌
MahjongCardItem = {
    enabled = false,

    -----------------------------------------------
    seatIndex = 0,
    gameObject = nil,
    transform = nil,
    rectTransform = nil,
    type = -1,
    image = nil,
    tweener = nil,
    --数字型
    cardKey = MahjongConst.INVALID_CARD_KEY,
    --牌对象
    cardData = nil,
    --是否是摸起的牌
    isNewCard = false,
    --是否是听用牌
    isTingYong = false,
    --提起类型
    upType = MahjongCardUpType.None,
    --用于存储按下时牌的状态，是否为提起状态
    isPressLastUp = false,
    x = 0,
    y = 0,
    --点击开启状态
    clickEnabled = true,
    --是否是定缺的牌，只会给位置为1的玩家使用
    isDingQueCard = false,
    --遮罩颜色类型
    maskColorType = MahjongMaskColorType.None,
    --是否需要重置SiblingIndex，用于拖动处理
    isResetSiblingIndex = false,
    --transform中的排序序号
    siblingIndex = nil,
}

local meta = { __index = MahjongCardItem }

function MahjongCardItem.New()
    local o = {}
    setmetatable(o, meta)
    o.enabled = false
    o.isNewCard = false
    o.isTingYong = false
    o.upType = MahjongCardUpType.None
    o.clickEnabled = true
    o.isDingQueCard = false
    o.isResetSiblingIndex = false
    return o
end

function MahjongCardItem:Init(gameObject, type, seatIndex)
    self.seatIndex = seatIndex
    self.type = type
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.rectTransform = self.gameObject:GetComponent("RectTransform")
    local temp = self.transform:Find("Mark")
    if temp ~= nil then
        self.markGo = temp.gameObject
        self.markImage = temp:GetComponent("ShapeImage")
    end

    self.cardFrame = self.gameObject.transform:Find("CardFrame"):GetComponent("Image")
    self.cardIcon = self.gameObject.transform:Find("CardIcon"):GetComponent("ShapeImage")
    self.cardIconGo = self.gameObject.transform:Find("CardIcon").gameObject
    self.maskGo = self.gameObject.transform:Find("Mask")
    if self.seatIndex == MahjongSeatIndex.Seat1 and self.maskGo ~= nil then
        self.maskImage = self.maskGo:GetComponent("Image")
    end
end

function MahjongCardItem:Clear()
    self.isNewCard = false
    self.isTingYong = false
    self.clickEnabled = true
    self.cardKey = MahjongConst.INVALID_CARD_KEY
    self.upType = MahjongCardUpType.None
    self.isResetSiblingIndex = false
    self.siblingIndex = nil
    self.cardData = nil
    if self.enabled == false then
        return
    end
    self.enabled = false
    self:UpdateMarkDisplay(false)
    if self.gameObject ~= nil then
        UIUtil.SetActive(self.gameObject, false)
    end
end

function MahjongCardItem:Destroy()

end

--================================================================
--设置牌的数据
--牌数据 / 牌类型 / 手牌顺序 / 碰刚吃盖 牌顺序
function MahjongCardItem:SetData(cardData, newType, handIndex, layIndex)
    if cardData == nil then
        Log(">> MahjongCardItem:SetData > self.seatIndex = ", self.seatIndex)
    end

    self.cardData = cardData
    self.isDingQueCard = false
    self.isTingYong = MahjongUtil.IsTingYongCard(cardData.key)

    if self.cardKey ~= cardData.key then
        self.cardKey = cardData.key
        
        local tempType = self.type
        if newType ~= nil then
            tempType = newType
        end
        local xScale = 1
        if tempType == MahjongCardDisplayType.Hand then
            self:SetCardFrameScale(handIndex)
        elseif tempType == MahjongCardDisplayType.Cover or tempType == MahjongCardDisplayType.Operate then
            if self.seatIndex == MahjongSeatIndex.Seat1 then
                xScale = handIndex > 3 and -1 or 1
            elseif self.seatIndex == MahjongSeatIndex.Seat3 then
                --胡牌,盖牌
                if layIndex == nil then
                    -- xScale = 1
                    if handIndex > 6 and tempType == MahjongCardDisplayType.Cover then
                        xScale = -1
                    end
                else
                    xScale = handIndex < 4 and -1 or 1
                    --3号位第3手碰杠吃盖牌，Card_2底框为Card_1底框镜像翻转，Card_1 xScale为1，则Card_2 xScale为-1
                    if handIndex == 3 and layIndex == 2 then
                        xScale = 1
                    end
                end
            end
        elseif tempType == MahjongCardDisplayType.Hu_Hand or tempType == MahjongCardDisplayType.Hu_Operation then

            if self.seatIndex == MahjongSeatIndex.Seat1 then
                if tempType == MahjongCardDisplayType.Hu_Operation then
                    xScale = -1
                end

            elseif self.seatIndex == MahjongSeatIndex.Seat2 then
                xScale = -1
            elseif self.seatIndex == MahjongSeatIndex.Seat4 then
                xScale = -1
            end

        end
        if tempType ~= MahjongCardDisplayType.Hand  then
            self.cardFrame.gameObject.transform.localScale = Vector3.New(xScale, 1, 1)
        end

        self.cardFrame.sprite = MahjongResourcesMgr.GetCardFrameSprite(tempType, self.seatIndex, 1, handIndex, layIndex)
        self.cardFrame:SetNativeSize()

        UIUtil.SetActive(self.cardIconGo, false)
        if self.seatIndex == MahjongSeatIndex.Seat1 or tempType ~= MahjongCardDisplayType.Hand then
            UIUtil.SetActive(self.cardIconGo, true)
            self.cardIcon.sprite = MahjongResourcesMgr.GetCardSprite(self.cardKey)

            --盖牌
            if tempType == MahjongCardDisplayType.Cover then
                UIUtil.SetActive(self.cardIconGo, layIndex ~= nil and layIndex > 3)
            end
        end

        self:SetCardIconPosition(tempType, self.seatIndex, handIndex, layIndex)
    end
    if self.seatIndex == MahjongSeatIndex.Seat1 then
        self:SetClickEnabled(true)
    end
    self:UpdateMaskColor(newType, handIndex, layIndex)
    self:Show()
end

function MahjongCardItem:SetCardFrameScale(handIndex)
    if self.seatIndex == MahjongSeatIndex.Seat3 then
        local xScale = 1
        if handIndex >= 7 and handIndex < 14 then
            xScale = -1
        end
        self.cardFrame.gameObject.transform.localScale = Vector3.New(xScale, 1, 1)
    end
end

--设置摸牌底框切换
function MahjongCardItem:SetCardFrameSprite(handIndex)
    self.cardFrame.sprite = MahjongResourcesMgr.GetCardFrameSprite(MahjongCardDisplayType.Hand, self.seatIndex, 1, handIndex)
    self:SetCardFrameScale(handIndex)
end

--设置碰杠吃牌icon坐标、大小、偏移
function MahjongCardItem:SetCardIconPosition(tempType, seatIndex, handIndex, layIndex)
    if tempType ~= MahjongCardDisplayType.Operate and tempType ~= MahjongCardDisplayType.Hu_Hand and tempType ~= MahjongCardDisplayType.Hu_Operation then
        return
    end
    local pos_x = nil
    local pos_y = nil
    local scale_x = nil
    local scale_y = nil
    local rotation_z = 0
    local offset = nil
    local config = nil

    --胡牌-手牌， 胡牌-操作牌
    if tempType == MahjongCardDisplayType.Hu_Hand or tempType == MahjongCardDisplayType.Hu_Operation then
        if tempType == MahjongCardDisplayType.Hu_Hand then
            --1号位玩家是正面摆放，不需要调整坐标、大小、偏移
            if seatIndex == MahjongSeatIndex.Seat1 then
                return
            end

            local type_idx = seatIndex == MahjongSeatIndex.Seat4 and 2 or seatIndex
            config = MahjongHuCardIconPosConfigDicts_Hand[type_idx]
            if config == nil then
                LogError("玩家 胡牌 手牌明牌Icon坐标配置错误")
                return
            end

            local temp_idx = handIndex
            local value = 1
            if seatIndex == MahjongSeatIndex.Seat4 then
                temp_idx = 14 - handIndex
                value = -1
            end
            
            pos_x = config.pos[temp_idx][1]
            pos_y = config.pos[temp_idx][2]
            rotation_z = value * config.RotationZ

            if seatIndex == MahjongSeatIndex.Seat3 then
                scale_x = config.scale
                scale_y = config.scale
                offset = config.offset[temp_idx]
            else
                scale_x = value * config.scaleX[temp_idx]
                scale_y = config.scaleY[temp_idx]
                offset = value * config.offset
            end


        elseif tempType == MahjongCardDisplayType.Hu_Operation then --最后胡的牌，只有一张

            config = MahjongHuCardIconPosConfigDicts_Operation[seatIndex]
            if config == nil then
                LogError("玩家 胡牌 操作牌Icon坐标配置错误")
                return
            end
            pos_x = config.posX
            pos_y = config.posY
            scale_x =  config.scale[1]
            scale_y =  config.scale[2]
            offset = config.offset
            rotation_z = config.RotationZ
        end
    else

        if layIndex == nil then
            LogError("玩家 碰杠吃盖牌 放置索引为空")
            return
        end
        config = MahjongOperateCardIconPosConfigDicts[seatIndex][handIndex]
        if config == nil then
            LogError("玩家 碰杠吃盖牌 Icon坐标配置错误")
            return
        end
        if seatIndex == MahjongSeatIndex.Seat1 or seatIndex == MahjongSeatIndex.Seat3 then
            pos_x = config.posX[layIndex]
            pos_y = config.posY
            scale_x =  config.scale[1]
            scale_y =  config.scale[2]
            offset = config.offset[layIndex]
        else
            pos_x = config.posX
            pos_y = config.posY
            scale_x =  config.scale[layIndex][1]
            scale_y =  config.scale[layIndex][2]
            offset = config.offset
        end
        rotation_z = config.RotationZ
    end
    -- Log("  设置碰杠吃牌icon坐标、大小、偏移 +++++++++++++++++++++++++++++++++++  ", offset)
    self.cardIcon.offset = offset
    UIUtil.SetAnchoredPosition(self.cardIconGo, pos_x, pos_y)
    UIUtil.SetRotation(self.cardIconGo, 0, 0, rotation_z)
    UIUtil.SetLocalScale(self.cardIconGo, scale_x, scale_y, 1)
end

--设置是否为摸起的牌
function MahjongCardItem:SetIsNewCard(isNewCard)
    self.isNewCard = isNewCard
end

function MahjongCardItem:SetCardScale(scale)
    self.transform.localScale = Vector3.New(scale, scale, 1)
end

function MahjongCardItem:SetPosition(x, y)
    if self.seatIndex == MahjongSeatIndex.Seat1 then
        self.upType = MahjongCardUpType.None
        self:StopMoveTweener()
    end
    if self.gameObject ~= nil then
        self.x = x
        self.y = y
        UIUtil.SetAnchoredPosition(self.gameObject, x, y)
    end
end

--重置坐标
function MahjongCardItem:ResetPosition()
    if self.gameObject ~= nil then
        UIUtil.SetAnchoredPosition(self.gameObject, self.x, self.y)
    end
    if self.seatIndex == MahjongSeatIndex.Seat1 then
        self.upType = MahjongCardUpType.None
        self:StopMoveTweener()
        self:ResetSiblingIndex()
    end
end

function MahjongCardItem:Show()
    if self.enabled == true then
        return
    end
    self.enabled = true
    if self.gameObject ~= nil then
        UIUtil.SetActive(self.gameObject, true)
    end
end

function MahjongCardItem:Hide()
    if self.enabled == false then
        return
    end
    self.enabled = false
    if self.gameObject ~= nil then
        UIUtil.SetActive(self.gameObject, false)
    end
end

function MahjongCardItem:IsActive()
    if self.gameObject ~= nil then
        return self.gameObject.activeSelf
    end
    return false
end

--是否有效
function MahjongCardItem:IsValid()
    return self.cardKey ~= nil and self.cardKey ~= MahjongConst.INVALID_CARD_KEY
end

--是否提起的牌
function MahjongCardItem:IsUp()
    return self.upType ~= MahjongCardUpType.None
end

--设置点击启用
function MahjongCardItem:SetClickEnabled(value)
    if self.clickEnabled ~= value then
        --Log(">> MahjongCardItem:SetClickEnabled > value = " .. tostring(value))
        self.clickEnabled = value
    end
end

--设置麻将遮罩颜色
function MahjongCardItem:SetMaskColor(colorType)
    if self.maskColorType ~= colorType then
        self.maskColorType = colorType
        MahjongUtil.SetMaskColor(self.cardFrame, self.maskColorType)  
    end
end

--==============================
--
--直接设置提起的坐标
function MahjongCardItem:SetUpPosition()
    self.MahjongCardUpType = MahjongCardUpType.Selected
    UIUtil.SetAnchoredPosition(self.gameObject, self.x, self.y + MahjongConst.HandCardUpY)
end

--==============================
--
--当前坐标移动到指定坐标，距离小于指定值时有时间比，大于则为最大时间
function MahjongCardItem:Move(positionY)
    self:CheckMoveTweener()
    if self.tweener == nil then
        return
    end

    local position = self.rectTransform.anchoredPosition
    if self.x == position.x and positionY == position.y then
        --坐标相同，不需要移动，就停止动画
        self.tweener.enabled = false
        return
    end

    local deltaY = math.abs(positionY - position.y)

    local duration = 0.1
    --每秒移动160，最大时间定为0.2秒
    if deltaY > 32 then
        duration = 0.2
    else
        duration = deltaY / 160
    end

    self.tweener.from = position
    self.tweener.to = Vector3.New(self.x, positionY, 0)
    self.tweener.duration = duration
    self.tweener:ResetToBeginning()
    self.tweener:PlayForward()
end

--播放鼠标按下时移动到提起的坐标
function MahjongCardItem:PlayMovePressDownPosition()
    self.upType = MahjongCardUpType.PressDown
    self:Move(self.y + MahjongConst.HandCardPressDownY)
end

--播放鼠标放开时移动到初始的坐标
function MahjongCardItem:PlayMoveResetPosition()
    self.upType = MahjongCardUpType.None
    self:Move(self.y)
end

--播放到提起的坐标
function MahjongCardItem:PlayMoveUpPosition()
    self.upType = MahjongCardUpType.Selected
    self:Move(self.y + MahjongConst.HandCardUpY)
end

--播放放下牌，即位置播放到初始位置
function MahjongCardItem:PlayMoveReset()
    if self.upType ~= MahjongCardUpType.None then
        self:PlayMoveResetPosition()
    end
end

--检测Tweener
function MahjongCardItem:CheckMoveTweener()
    if self.tweener == nil then
        self.tweener = self.gameObject:GetComponent("TweenPosition")
        self.tweener.onFinished = HandlerByStatic(self, self.OnTweenerFinished)
    end
end

--停止Tweener
function MahjongCardItem:StopMoveTweener()
    if self.tweener ~= nil and self.tweener.enabled then
        self.tweener.enabled = false
    end
end

--播放换牌
function MahjongCardItem:PlayChangeCard()
    self:CheckMoveTweener()
    self.upType = MahjongCardUpType.None
    if self.tweener == nil then
        return
    end
    UIUtil.SetAnchoredPosition(self.gameObject, self.x, self.y + MahjongConst.HandCardChangeY)
    self.tweener.from = self.tweener.value
    self.tweener.to = Vector3.New(self.x, self.y, 0)
    self.tweener.duration = 0.5
    self.tweener:ResetToBeginning()
    self.tweener:PlayForward()
end

--Tween完成回调
function MahjongCardItem:OnTweenerFinished(tweener)
    if self.isResetSiblingIndex == true then
        self:ResetSiblingIndex()
    end
end

--================================================================
--保存当前的序号
function MahjongCardItem:SaveSiblingIndex()
    self.siblingIndex = self.transform:GetSiblingIndex()
end

--设置层级，1号玩家使用
function MahjongCardItem:SetAsLastSibling()
    self.isResetSiblingIndex = true
    UIUtil.SetAsLastSibling(self.transform)
end

--重置层级
function MahjongCardItem:ResetSiblingIndex()
    self.isResetSiblingIndex = false
    if self.siblingIndex ~= nil then
        self.transform:SetSiblingIndex(self.siblingIndex)
    end
end
--================================================================
--
--设置点击选中，用于其他3个玩家碰杠牌选中处理
function MahjongCardItem:SetSelected(value)
    if self.enabled == false then
        return
    end
    if value then
        self:SetMaskColor(MahjongMaskColorType.Selected)
    else
        self:UpdateMaskColor()
    end
end

--更新遮罩颜色
function MahjongCardItem:UpdateMaskColor(newType, handIndex, layIndex)
    if self.isDingQueCard then
        self:SetMaskColor(MahjongMaskColorType.Gray)
        self:UpdateMarkDisplay(false)
    elseif self.isTingYong then
        self:SetMaskColor(MahjongMaskColorType.None)
        self:UpdateMarkDisplay(true, newType, handIndex, layIndex)
    else
        self:SetMaskColor(MahjongMaskColorType.None)
        self:UpdateMarkDisplay(false)
    end
end

--更新标记图标显示
function MahjongCardItem:UpdateMarkDisplay(isDisplay, newType, handIndex, layIndex)
    if self.markGo ~= nil then
        if self.lastMarkDisplay ~= isDisplay then
            self.lastMarkDisplay = isDisplay
            UIUtil.SetActive(self.markGo, isDisplay)

            --只要碰刚吃盖牌才设置 癞 image坐标大小
            if isDisplay then
                self:SetCardMarkPosition(newType, handIndex, layIndex)
            end
        end
    end
end

--设置碰杠吃牌 / 胡牌-手牌明牌 / 胡牌操作牌  癞 image坐标、大小、偏移
function MahjongCardItem:SetCardMarkPosition(tempType, handIndex, layIndex)
    --牌类型和手牌索引不能为空
    if tempType == nil or handIndex == nil then
        LogError("设置碰杠吃牌 癞 image坐标、大小、偏移 牌类型和手牌索引不能为空")
        return
    end

    if tempType ~= MahjongCardDisplayType.Cover and tempType ~= MahjongCardDisplayType.Operate and 
    tempType ~= MahjongCardDisplayType.Hu_Hand and tempType ~= MahjongCardDisplayType.Hu_Operation then
        return
    end

    local config = nil

    local pos_x = nil
    local pos_y = nil
    local scale_x = nil
    local scale_y = nil
    local rotation_z = 0
    local offset = nil
    if tempType == MahjongCardDisplayType.Hu_Hand or tempType == MahjongCardDisplayType.Hu_Operation then
        config = MahjongHuCardMarkConfigDicts[self.seatIndex]
        if config == nil then
            LogError("玩家 回放 胡牌 Mark坐标配置错误")
            return
        end
        if handIndex == 14 or tempType == MahjongCardDisplayType.Hu_Operation then
            handIndex = 1
        end
        if self.seatIndex == MahjongSeatIndex.Seat3 then
            pos_x = config.pos[1]
            pos_y = config.pos[2]
            scale_x = config.scale
            scale_y = config.scale
            offset = config.offset[handIndex]
        else
            pos_x = config.pos[handIndex][1]
            pos_y = config.pos[handIndex][2]
            scale_x = config.scale[handIndex]
            scale_y = config.scale[handIndex]
            if self.seatIndex == MahjongSeatIndex.Seat2 then
                scale_x = -scale_x
            end
            offset = config.offset
        end
        rotation_z = config.RotationZ
    else
        --碰刚吃盖牌，放置索引不能空
        if layIndex == nil then
            return
        end
        config = MahjongOperateCardMarkConfigDicts[self.seatIndex][handIndex]
        if config == nil then
            LogError("玩家 碰杠吃盖牌 Mark坐标配置错误")
            return
        end
        pos_x = config.pos[layIndex][1]
        pos_y = config.pos[layIndex][2]
        scale_x = config.scale
        scale_y = config.scale
        rotation_z = config.RotationZ
        offset = nil
        if self.seatIndex == MahjongSeatIndex.Seat1 or self.seatIndex == MahjongSeatIndex.Seat3 then
            offset = config.offset[layIndex]
        else
            if self.seatIndex == MahjongSeatIndex.Seat2 then
                scale_x = -scale_x
            end
            offset = config.offset
        end
    end

    self.markImage.offset = offset
    UIUtil.SetAnchoredPosition(self.markGo, pos_x, pos_y)
    UIUtil.SetRotation(self.markGo, 0, 0, rotation_z)
    UIUtil.SetLocalScale(self.markGo, scale_x, scale_y, 1)
end