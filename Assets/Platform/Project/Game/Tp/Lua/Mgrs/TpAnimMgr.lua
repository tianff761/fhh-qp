TpAnimMgr = {
    --发牌点的屏幕坐标
    dealCardPosition = Vector2.zero,
    --下注的屏幕坐标，飞筹码的坐标
    betPosition = Vector2.zero,
}

local this = TpAnimMgr

--重置，用于房间重置
function TpAnimMgr.Reset()
    this.ClearChip()
end

--清除，用于退出房间
function TpAnimMgr.Clear()
end

--销毁，用于完全卸载
function TpAnimMgr.Destroy()
    this.DestroyChip()
end

--================================================================
--
--初始筹码
function TpAnimMgr.InitChip(chip)
    this.chipRectTransform = chip:GetComponent(TypeRectTransform)
    this.chip1Prefab = chip:Find("Chip1").gameObject
    this.chip2Prefab = chip:Find("Chip2").gameObject
    this.chip3Prefab = chip:Find("Chip3").gameObject
    this.chip1Items = {}
    this.chip2Items = {}
    this.chip3Items = {}
    this.chipCount = 0
end

--删除
function TpAnimMgr.DestroyChip()
    this.chip1Items = {}
    this.chip2Items = {}
    this.chip3Items = {}
    this.chipCount = 0
end

--清除筹码
function TpAnimMgr.ClearChip()
    LogError(">> TpAnimMgr.ClearChip")
    this.chipCount = 0
    if this.chip1Items ~= nil then
        this.ClearChipItems(this.chip1Items)
        this.ClearChipItems(this.chip2Items)
        this.ClearChipItems(this.chip3Items)
    end
end

--
function TpAnimMgr.ClearChipItems(items)
    local item = nil
    for i = 1, #items do
        item = items[i]
        if item.isActive == true then
            item.isActive = false
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

--获取筹码
function TpAnimMgr.GetChipItem(type)
    local items = nil
    local itemPrefab = nil
    if type == 2 then
        items = this.chip2Items
        itemPrefab = this.chip2Prefab
    elseif type == 3 then
        items = this.chip3Items
        itemPrefab = this.chip3Prefab
    else
        items = this.chip1Items
        itemPrefab = this.chip1Prefab
    end
    local length = #items
    local item = nil
    for i = 1, length do
        item = items[i]
        if not item.isActive then
            item.isActive = true
            UIUtil.SetActive(item.gameObject, true)
            item.transform:SetAsLastSibling()
            return item
        end
    end
    --创建一个新的
    item = {}
    item.gameObject = CreateGO(itemPrefab, this.chipRectTransform, tostring(length + 1))
    item.transform = item.gameObject.transform
    item.rectTransform = item.gameObject:GetComponent(TypeRectTransform)
    item.label = item.transform:Find("Text"):GetComponent(TypeText)
    item.isActive = true
    UIUtil.SetActive(item.gameObject, true)
    table.insert(items, item)
    --
    return item
end

--获取类型
function TpAnimMgr.GetChipType(chip)
    local temp = chip / TpDataMgr.baseScore
    if temp > 10 then
        return 3
    elseif temp > 2 then
        return 2
    else
        return 1
    end
end

--播放下注筹码动画
function TpAnimMgr.PlayBetChipAnim(chip, position)
    local item = this.GetChipItem(this.GetChipType(chip))
    if item ~= nil then
        position = UIUtil.ScreenToLocalPosition(this.chipRectTransform, position, UIConst.uiCamera)
        item.rectTransform.anchoredPosition = position
        item.label.text = chip

        this.chipCount = this.chipCount + 1
        local x = 100 * (this.chipCount / 8)
        local y = 100 * (this.chipCount / 8)
        if x > 80 then
            x = 80
        end
        if y > 80 then
            y = 80
        end
        item.rectTransform:DOAnchorPos(Vector2(Util.Random(-x, x), Util.Random(-y, y)), 0.1):SetEase(DG.Tweening.Ease.Linear)
    end
end

--播放赢筹码动画
function TpAnimMgr.PlayWinChipAnim(chip, position)
    LogError(">> TpAnimMgr.PlayWinChipAnim", chip)
    local item = this.GetChipItem(this.GetChipType(chip))
    if item ~= nil then
        position = UIUtil.ScreenToLocalPosition(this.chipRectTransform, position, UIConst.uiCamera)
        item.rectTransform.anchoredPosition = Vector2.zero
        item.label.text = chip

        local tweener = item.rectTransform:DOAnchorPos(position, 0.3)
        tweener:SetEase(DG.Tweening.Ease.Linear)
        tweener.onComplete = function() this.OnChipAnimPlayCompleted(item) end
    end
end

--播放完成
function TpAnimMgr.OnChipAnimPlayCompleted(item)
    item.isActive = false
    UIUtil.SetActive(item.gameObject, false)
end
