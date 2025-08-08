MahjongScreenshotPanel = ClassPanel("MahjongScreenshotPanel")
local this = MahjongScreenshotPanel
local mSelf = nil
local curImage = nil
local ran = 1
local sharePlatformType = 1
local shareType = 1
local Prioritys = nil
local cardItemPrefab
local operationItemPrefab

local isLoadend = true

function MahjongScreenshotPanel:OnInitUI()
    mSelf = self
    local rootLayer = GameObject.Find("UIRoot").transform
    self.transform:SetParent(rootLayer)
    self.transform.position = Vector3(0, 0, 0)
    self:InitPanel()
end

function MahjongScreenshotPanel:InitPanel()
    self.canvas = self.transform:Find("Canvas")
    self.canvasRect = self.canvas:GetComponent("RectTransform")
    local bg = self.canvas:Find("Background")
    self.bg = bg

    self.camera = self.transform:Find("MahjongScreenshotCamera"):GetComponent("Camera")
    self.mjShareImage = bg:Find("MahjongShareImageBg"):GetComponent(TypeImage)
    self.mahjongItem = bg:Find("Item")
    self.Images = {}
    for i = 1, 3 do
        local image = {}
        image.transform = bg:Find("MahjongShareImage" .. i)
        image.gameObject = image.transform.gameObject
        image.fanshuTxt = image.transform:Find("FanShu"):GetComponent(TypeText)
        image.cardTypes = image.transform:Find("CardTypes")
        image.cardItem = image.cardTypes:Find("CardTypeItem")
        image.cardsTrans = image.transform:Find("Cards")
        image.cardItems = {}
        image.cardTypeItems = {}
        table.insert(self.Images, image)
    end

    UIUtil.SetLocalScale(self.transform, 1, 1, 1);

    this.CheckScale()
end

-- arg = {
--     cards = {},
--     cardType = nil,
-- }
function MahjongScreenshotPanel:OnOpened(arg)
    mSelf = self
    Waiting.Show("准备分享")

    sharePlatformType = arg.sharePlatformType
    shareType = arg.shareType
    cardItemPrefab = arg.cardItemPrefab
    operationItemPrefab = arg.operationItemPrefab
    ran = math.ceil(Util.Random(0, #self.Images))
    curImage = self.Images[ran]
    for i = 1, #self.Images do
        UIUtil.SetActive(self.Images[i].gameObject, i == ran)
    end

    self:InitShareImage(arg, function()
        Scheduler.scheduleOnceGlobal(this.CheckScreenshot, 0.3)
    end)
    this.SetFanShu(arg.itemData)
    this.SetTextInfo(arg.itemData)
end

function MahjongScreenshotPanel.CheckScreenshot()
    if not isLoadend then
        Scheduler.scheduleOnceGlobal(this.CheckScreenshot, 0.3)
    else
        this.ShareScreenshotImageByCamera()
    end
end

function MahjongScreenshotPanel:OnClosed()

end

function MahjongScreenshotPanel:OnDestroy()

end
--============================================
function MahjongScreenshotPanel.SetTextInfo(itemData)
    --信息处理
    local infoStr = nil
    local length = 0
    if itemData.huRules ~= nil then
        length = #itemData.huRules
        local huRuleIndexs = {}

        for i = 1, length do
            local v = itemData.huRules[i]
            if not this.CheckSameValue(huRuleIndexs, v) then
                if MahjongHuRuleShareImageName[v] ~= nil then
                    table.insert(huRuleIndexs, v)
                end
            end
        end

        Prioritys = MahjongChengMaPriorityImageName
        local curPlayWayType = MahjongDataMgr.playWayType
        local playWayType = Mahjong.PlayWayType
        if curPlayWayType == playWayType.YaoJiErRen or curPlayWayType == playWayType.YaoJiSanRen or curPlayWayType == playWayType.YaoJiSiRen then
            Prioritys = MahjongPriorityImageName
        end

        table.sort(huRuleIndexs, function(x, y)
            return this.GetPriorityIndex(x) > this.GetPriorityIndex(y)
        end)

        local huRuleNs = {}
        for i = 1, #huRuleIndexs do
            if #huRuleNs >= 3 then
                break
            end
            table.insert(huRuleNs, MahjongHuRuleShareImageName[huRuleIndexs[i]])
        end

        for i = 1, #curImage.cardTypeItems do
            UIUtil.SetActive(curImage.cardTypeItems[i], false)
        end
        isLoadend = false
        local loadCount = 0
        for i = 1, #huRuleNs do
            if curImage.cardTypeItems[i] == nil then
                curImage.cardTypeItems[i] = CreateGO(curImage.cardItem, curImage.cardTypes)
                curImage.cardTypeItems[i].transform.localEulerAngles = Vector3.New(0, 0, 0)
            end
            loadCount = loadCount + 1
            ResourcesManager.LoadSprite(MahjongBundleName.Share, huRuleNs[i], function(sprite)
                UIUtil.SetActive(curImage.cardTypeItems[i], true)
                curImage.cardTypeItems[i]:GetComponent(TypeImage).sprite = sprite
                curImage.cardTypeItems[i]:GetComponent(TypeImage):SetNativeSize()
                loadCount = loadCount - 1

                if loadCount == 0 then
                    isLoadend = true
                end
            end, {})
        end
    end
end

function MahjongScreenshotPanel.SetFanShu(itemData)
    curImage.fanshuTxt.text = itemData.fan .. "f"
end

function MahjongScreenshotPanel.UpdateCards(itemData)
    this.CheckUpdateCards(curImage, itemData)
    for i, v in ipairs(curImage.cardItems) do
        local trans = v.transform
        UIUtil.SetLocalPosition(v, trans.localPosition.x, trans.localPosition.y, 0)
        trans.localEulerAngles = Vector3.New(0, 0, 0)
    end
end
--============================================
function MahjongScreenshotPanel:InitShareImage(arg, callback)
    ResourcesManager.LoadSprite("mahjong/sharesettlement" .. ran, "MahjongShareImage" .. ran, function(sprite)
        self.mjShareImage.sprite = sprite
        this.UpdateCards(arg.itemData)
        callback()
    end)
end

--============================================
--分享通过相机截图
function MahjongScreenshotPanel.ShareScreenshotImageByCamera()
    this.CheckScale()
    PlatformHelper.ShareScreenshotImageByCamera(sharePlatformType, shareType, "", "MahjongScreenshotCamera", 0, 0, 1280, 720)
    Waiting.ForceHide()
    mSelf:Close()
end

function MahjongScreenshotPanel.CheckScale()
    local uW = UnityEngine.Screen.width
    local uH = UnityEngine.Screen.height

    local w = UIUtil.GetWidth(mSelf.canvas)
    local h = UIUtil.GetHeight(mSelf.canvas)

    if h < 720 then
        local scaleX = w / 1280
        local scaleY = h / 720
        local te = scaleX < scaleY and scaleX or scaleY
        mSelf.bg.localScale = Vector2.New(te, te)
        local revScaleX = 1280 / w
        local revScaleY = 720 / h
        mSelf.camera.rect = UnityEngine.Rect.New(0, 0, revScaleX, revScaleY);
    else
        mSelf.bg.localScale = Vector2.New(1, 1)
        mSelf.camera.rect = UnityEngine.Rect.New(0, 0, 1, 1);
    end
end

function MahjongScreenshotPanel.GetPriorityIndex(value)
    for i, v in ipairs(Prioritys) do
        if v == value then
            return i
        end
    end
    return 0
end


function MahjongScreenshotPanel.CheckUpdateCards(item, itemData)
    if item.cardItems ~= nil then
        item.cardItems = ClearObjList(item.cardItems)
    else
        item.cardItems = {}
    end
    local x = 0
    local data = nil
    local gameObject = nil
    --左手牌
    if itemData.left ~= nil then
        for i = 1, #itemData.left do
            data = itemData.left[i]
            gameObject = this.CreateOperationCards(i, data, item.cardsTrans)
            table.insert(item.cardItems, gameObject)
            UIUtil.SetAnchoredPosition(gameObject, x, 0)
            x = x + 110 + 10
        end
    end

    local playerCardData = MahjongPlayCardMgr.GetPlayerCardDataById(itemData.id)
    --手牌
    if itemData.mid ~= nil and playerCardData ~= nil then
        local result = playerCardData:CheckMidCards(itemData.mid)
        for i = 1, #result do
            data = result[i]
            gameObject = this.CreateCards(data, item.cardsTrans, true)
            table.insert(item.cardItems, gameObject)
            UIUtil.SetAnchoredPosition(gameObject, x, 0)
            x = x + 40
        end
    end

    --摸牌或者胡牌
    x = x + 12
    if IsNumber(itemData.right) and itemData.right > 0 then
        local cardData = MahjongDataMgr.GetCardData(itemData.right)
        gameObject = this.CreateCards(cardData, item.cardsTrans, true)
        table.insert(item.cardItems, gameObject)
        UIUtil.SetAnchoredPosition(gameObject, x, 0)
    end
end

--创建操作牌
function MahjongScreenshotPanel.CreateCards(cardData, parent, isDisplay)
    if not isDisplay then
        --处理不显示的牌
        cardData = MahjongDataMgr.UnknownCardData
    end

    local go = CreateGO(cardItemPrefab, parent, tostring(cardData.id))
    -- local keyName = nil
    --处理听用，由于暂时不使用该面板，就不写逻辑了，以后需要再添加
    -- local sprite = MahjongResourcesMgr.GetCardSprite(keyName)
    -- this.SetImage(go, sprite, cardData.isDingQue)
    return go
end

--创建操作牌
function MahjongScreenshotPanel.CreateOperationCards(index, data, parent)
    local go = CreateGO(operationItemPrefab, parent, tostring(index))
    local trans = go.transform

    local itemGO = nil
    local cardItems = {}
    for i = 1, 4 do
        local name = tostring(i)
        itemGO = trans:Find(name).gameObject
        table.insert(cardItems, itemGO)
    end

    local cardData = nil
    local frameSprite = nil
    local iconsprite = nil
    if data.type == MahjongOperateCode.PENG then
        cardData = MahjongDataMgr.GetCardData(data.k1)
        frameSprite = MahjongResourcesMgr.GetSingleCardFrameSprite("op_1_-1")
        iconsprite = MahjongResourcesMgr.GetCardSprite(cardData.key)
        for i = 1, 3 do
            this.SetImage(cardItems[i], frameSprite, iconsprite)
        end
    elseif data.type == MahjongOperateCode.GANG or data.type == MahjongOperateCode.GANG_IN then
        cardData = MahjongDataMgr.GetCardData(data.k1)
        frameSprite = MahjongResourcesMgr.GetSingleCardFrameSprite("op_1_-1")
        iconsprite = MahjongResourcesMgr.GetCardSprite(cardData.key)
        for i = 1, 4 do
            this.SetImage(cardItems[i], frameSprite, iconsprite)
        end
        UIUtil.SetActive(cardItems[4], true)
    elseif data.type == MahjongOperateCode.GANG_ALL_IN then--暗杠，背面3张，明第4张
        frameSprite = MahjongResourcesMgr.GetSingleCardFrameSprite("op_1_0")
        for i = 1, 3 do
            this.SetImage(cardItems[i], frameSprite, iconsprite)
        end
        this.SetCardItemById(cardItems[4], data.k1)
        UIUtil.SetActive(cardItems[4], true)
    elseif data.type == MahjongOperateCode.SPC_PENG then--幺鸡碰
        this.SetCardItemById(cardItems[1], data.k1)
        this.SetCardItemById(cardItems[2], data.k2)
        this.SetCardItemById(cardItems[3], data.k3)
    elseif data.type == MahjongOperateCode.SPC_GANG_ALL_IN then--幺鸡杠，包括暗杠，所有的牌都是明牌
        --幺鸡玩法，第一个幺鸡放第一个位置，第二个幺鸡放第3个位置，第三个幺鸡放第2位置，主牌放第4个位置
        this.HandleYaoJiGang(cardItems, data, false)
    else--其他幺鸡杠全是明牌
        this.HandleYaoJiGang(cardItems, data, false)
    end

    return go
end


--设置图片
function MahjongScreenshotPanel.SetImage(gameObject, frameSprite, iconsprite, isDingQue)
    local cardFrame = gameObject.transform:Find("CardFrame"):GetComponent(TypeImage)
    local cardIcon = gameObject.transform:Find("CardIcon"):GetComponent("ShapeImage")
    UIUtil.SetActive(cardIcon.gameObject, iconsprite ~= nil)
    if cardFrame ~= nil then
        cardFrame.sprite = frameSprite
    end
    if iconsprite ~= nil then
        cardIcon.sprite = iconsprite
    end
    
    --处理定缺牌的颜色
    if isDingQue then
        UIUtil.SetImageColor(cardIcon, 0.572, 0.572, 0.572)
    end
end

-- --============================================
-- --分享通过相机截图
-- function MahjongScreenshotPanel.ShareScreenshotImageByCamera()
--     PlatformHelper.ShareScreenshotImageByCamera(sharePlatformType, shareType, "", "MahjongScreenshotCamera", this.x, this.y, this.actualWidth, this.actualHeight) Waiting.ForceHide()
-- end
-- function MahjongScreenshotPanel.CheckScreenshot()
--     local temp = Functions.GetScreenshotSize(1920, 1080)
--     this.actualWidth = temp.width
--     this.actualHeight = temp.height
--     this.x = temp.x
--     this.y = temp.y
-- end
function MahjongScreenshotPanel.CheckSameValue(tab, value)
    for i = 1, #tab do
        if tab[i] == value then
            return true
        end
    end
    return false
end

return MahjongScreenshotPanel