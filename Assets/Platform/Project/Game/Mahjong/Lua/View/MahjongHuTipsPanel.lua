MahjongHuTipsPanel = ClassPanel("MahjongHuTipsPanel")
MahjongHuTipsPanel.Instance = nil
--
local this = nil
--
--初始属性数据
function MahjongHuTipsPanel:InitProperty()
    this.items = {}
    this.timer = nil
    this.allNum = 0
end

--UI初始化
function MahjongHuTipsPanel:OnInitUI()
    this = self
    this:InitProperty()
    this.closeBtn = self:Find("CloseMask").gameObject
    this.nodeTrans = self:Find("Node")
    this.itemPrefab = this.nodeTrans:Find("Item").gameObject

    this.allNumText = self:Find("AllNumText"):GetComponent(TypeText)
    
    this.gridLayoutGroup = this.nodeTrans:GetComponent("GridLayoutGroup")

    this.AddUIListenerEvent()
end

--当面板开启开启时
function MahjongHuTipsPanel:OnOpened(argData)
    MahjongHuTipsPanel.Instance = self
    this.AddListenerEvent()
    this.UpdateData(argData)
end

--当面板关闭时调用
function MahjongHuTipsPanel:OnClosed()
    MahjongHuTipsPanel.Instance = nil
    this.StopTimer()
    this.RemoveListenerEvent()
end

------------------------------------------------------------------
--
--关闭
function MahjongHuTipsPanel.Close()
    PanelManager.Close(MahjongPanelConfig.HuTips)
end

--
function MahjongHuTipsPanel.AddListenerEvent()

end

--
function MahjongHuTipsPanel.RemoveListenerEvent()

end

--UI相关事件
function MahjongHuTipsPanel.AddUIListenerEvent()
    UIButtonListener.AddListener(this.closeBtn, this.OnCloseBtnClick)
end

------------------------------------------------------------------
--
function MahjongHuTipsPanel.OnCloseBtnClick(listener)
    this.Close()
end

------------------------------------------------------------------
--更新显示
function MahjongHuTipsPanel.UpdateData(argData)
    --LogWarn(argData)

    local index = 0
    local itemsLength = #this.items
    local item = nil
    this.allNum = 0
    --
    if IsTable(argData) then
        --处理下牌张数量
        MahjongPlayCardMgr.HandleMingCardNum()

        --说明是客户端自己处理的数据
        local maxFanNum = 0
        local temp = nil
        for i = 1, #argData do
            temp = argData[i]
            index = index + 1
            if index <= itemsLength then
                item = this.items[index]
            else
                item = this.CreateItem(tostring(index))
            end
            this.SetItem(item, temp.key, temp.fanNum)
            --
            if temp.fanNum > maxFanNum then
                maxFanNum = temp.fanNum
            end
            this.SetItemMaskColor(item, MahjongMaskColorType.None)
        end
        --处理听用
        for k, v in pairs(MahjongDataMgr.tingYongCardDict) do
            index = index + 1
            if index <= itemsLength then
                item = this.items[index]
            else
                item = this.CreateItem(tostring(index))
            end
            this.SetItem(item, k, maxFanNum)
            this.SetItemMaskColor(item, MahjongMaskColorType.TingYong)
        end
    else
        --服务器的数据
        if string.IsNullOrEmpty(argData) then
            this.Close()
            return
        end
        local arr = string.split(argData, ";")
        local tempStr = nil
        for i = 1, #arr do
            tempStr = arr[i]
            if not string.IsNullOrEmpty(tempStr) then
                local tempArr = string.split(tempStr, ",")
                local length = #tempArr
                if tempArr ~= nil and length > 1 then
                    index = index + 1
                    if index <= itemsLength then
                        item = this.items[index]
                    else
                        item = this.CreateItem(tostring(index))
                    end
                    UIUtil.SetActive(item.gameObject, true)
                    item.cardIcon.sprite = MahjongResourcesMgr.GetCardSprite(tempArr[1])

                    item.surplusTxt.text = tempArr[2]
                    this.allNum = this.allNum + tempArr[2]
                    if length > 2 then
                        item.fanTxt.text = tempArr[3].."F"
                    else
                        item.fanTxt.text = "0F"
                    end
                    this.SetItemMaskColor(item, MahjongMaskColorType.None)
                end
            end
        end
    end

    this.allNumText.text = this.allNum.."Z"

    local colNum = 3
    if index <= 5 then
        colNum = index
    else
        colNum = math.ceil(index / 2)
    end
    this.gridLayoutGroup.constraintCount = colNum
    local pos_x = -100 - (colNum * 50)
    UIUtil.SetAnchoredPosition(this.allNumText.gameObject, pos_x, -50)

    --隐藏多余的Item
    if index < itemsLength then
        for i = index + 1, itemsLength do
            item = this.items[i]
            this.SetItemMaskColor(item, MahjongMaskColorType.None)
            UIUtil.SetActive(item.gameObject, false)
        end
    end
    this.StartTimer()
end

--设置Item信息
function MahjongHuTipsPanel.SetItem(item, key, fanNum)
    UIUtil.SetActive(item.gameObject, true)
    item.cardIcon.sprite = MahjongResourcesMgr.GetCardSprite(key)
    local cardNumObj = MahjongPlayCardMgr.mingCardNumDict[key]
    local num = 0
    if cardNumObj ~= nil then
        num = cardNumObj.num
        if num > 4 then
            num = 4
        end
    end
    this.allNum = this.allNum + (4 - num)
    item.surplusTxt.text = 4 - num
    item.fanTxt.text = fanNum.."F"
end

--设置显示项图片的遮罩颜色
function MahjongHuTipsPanel.SetItemMaskColor(item, maskColorType)
    if item.maskColorType ~= maskColorType then
        item.maskColorType = maskColorType
        -- UIUtil.SetActive(item.markGo, maskColorType == MahjongMaskColorType.TingYong)
    end
end

--创建Item
function MahjongHuTipsPanel.CreateItem(name)
    local gameObject = CreateGO(this.itemPrefab, this.nodeTrans, name)
    local item = {}
    local transform = gameObject.transform
    item.gameObject = gameObject
    item.cardFrame = transform:Find("Card/CardFrame"):GetComponent(TypeImage)
    item.cardIcon = transform:Find("Card/CardIcon"):GetComponent(TypeImage)
    item.markGo = transform:Find("Card/Mark").gameObject
    item.surplusTxt = transform:Find("SurplusText"):GetComponent(TypeText)
    item.fanTxt = transform:Find("FanText"):GetComponent(TypeText)
    table.insert(this.items, item)
    return item
end

function MahjongHuTipsPanel.StartTimer()
    if this.timer == nil then
        this.timer = Timing.New(this.OnTimer, 3)
    end
    this.timer:Restart()
end

function MahjongHuTipsPanel.StopTimer()
    if this.timer ~= nil then
        this.timer:Stop()
        this.timer = nil
    end
end

function MahjongHuTipsPanel.OnTimer()
    this.StopTimer()
    this.Close()
end
