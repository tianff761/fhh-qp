MahjongOperationPanel = ClassPanel("MahjongOperationPanel")
MahjongOperationPanel.Instance = nil
--
local this = MahjongOperationPanel
--
--初始属性数据
function MahjongOperationPanel:InitProperty()
    --是否初始化偏移
    self.isInitOffset = false
    --是否有换牌的多项提示
    self.isHuanTipsShow = false
    --是否有碰牌的多项提示
    self.isPengTipsShow = false
    --是否有杠牌的多项提示
    self.isGangTipsShow = false

    --换牌的Item列表
    self.huanTipsItems = {}
    --碰牌的Item列表
    self.pengTipsItems = {}
    --杠牌的Item列表
    self.gangTipsItems = {}
    --吃牌的Item列表
    self.chiTipsItems = {}

    --用于存储
    self.dingQueItems = {}
    --幺鸡换牌存储
    self.yaoJiTipsItem = nil
    --是否正在播放点击动画
    self.isClickAnim = false
    --
    self.sprites = {}
end

--UI初始化
function MahjongOperationPanel:OnInitUI()
    this = self
    --初始属性数据
    self:InitProperty()
    --取消按钮
    local cancelGroupTrans = self:Find("CancelGroup")
    this.cancelGroupGO = cancelGroupTrans.gameObject
    this.cancelBtn = cancelGroupTrans:Find("CancelButton/Button").gameObject
    this.cancelBtnAnim = cancelGroupTrans:Find("CancelButton/BtnAnim"):GetComponent(TypeSkeletonGraphic)


    --杠碰操作
    local operationGroupTrans = self:Find("OperationGroup")
    this.operationGroupGO = operationGroupTrans.gameObject

    this.guoGO = operationGroupTrans:Find("Guo").gameObject
    this.guoBtn = operationGroupTrans:Find("Guo/Button").gameObject
    this.guoBtnAnim = operationGroupTrans:Find("Guo/BtnAnim"):GetComponent(TypeSkeletonGraphic)

    this.huGO = operationGroupTrans:Find("Hu").gameObject
    this.huBtn = operationGroupTrans:Find("Hu/Button").gameObject
    this.huBtnAnim = operationGroupTrans:Find("Hu/BtnAnim"):GetComponent(TypeSkeletonGraphic)

    --杠处理、幺鸡麻将显示杠
    this.gangTrans = operationGroupTrans:Find("Gang")
    this.gangGO = this.gangTrans.gameObject
    this.gangBtn = this.gangTrans:Find("Button").gameObject
    this.gangTipsNodeTrans = this.gangTrans:Find("TipsNode")
    this.gangTipsNodeGO = this.gangTipsNodeTrans.gameObject
    this.gangTipsItemsNode = this.gangTipsNodeTrans:Find("Items")
    this.gangTipsItemPrefab = this.gangTipsItemsNode:Find("Item")
    this.gangGridLayoutGroup = this.gangTipsItemsNode:GetComponent("GridLayoutGroup")
    this.gangTipsInBtnPositionTrans = this.gangTrans:Find("InBtnPosition")
    this.gangBtnAnim = this.gangTrans:Find("BtnAnim"):GetComponent(TypeSkeletonGraphic)

    --碰处理
    this.pengTrans = operationGroupTrans:Find("Peng")
    this.pengGO = this.pengTrans.gameObject
    this.pengBtn = this.pengTrans:Find("Button").gameObject
    this.pengTipsNodeTrans = this.pengTrans:Find("TipsNode")
    this.pengTipsNodeGO = this.pengTipsNodeTrans.gameObject
    this.pengTipsItemsNode = this.pengTipsNodeTrans:Find("Items")
    this.pengTipsItemPrefab = this.pengTipsItemsNode:Find("Item")
    this.pengTipsInBtnPositionTrans = this.pengTrans:Find("InBtnPosition")
    this.pengBtnAnim = this.pengTrans:Find("BtnAnim"):GetComponent(TypeSkeletonGraphic)

    this.chiTrans = operationGroupTrans:Find("Chi")
    this.chiGO = this.chiTrans.gameObject
    this.chiBtn = this.chiTrans:Find("Button").gameObject
    this.chiTipsNodeTrans = this.chiTrans:Find("TipsNode")
    this.chiTipsNodeGO = this.chiTipsNodeTrans.gameObject
    this.chiTipsItemsNode = this.chiTipsNodeTrans:Find("Items")
    this.chiTipsItemPrefab = this.chiTipsItemsNode:Find("Item")
    this.chiGridLayoutGroup = this.chiTipsItemsNode:GetComponent("GridLayoutGroup")
    this.chiTipsInBtnPositionTrans = this.chiTrans:Find("InBtnPosition")
    this.chiBtnAnim = this.chiTrans:Find("BtnAnim"):GetComponent(TypeSkeletonGraphic)

    --换处理
    this.huanTrans = operationGroupTrans:Find("Huan")
    this.huanGO = this.huanTrans.gameObject
    this.huanBtn = this.huanTrans:Find("Button").gameObject
    this.huanTipsNodeTrans = this.huanTrans:Find("TipsNode")
    this.huanTipsNodeGO = this.huanTipsNodeTrans.gameObject
    this.huanTipsItemsNode = this.huanTipsNodeTrans:Find("Items")
    this.huanTipsItemPrefab = this.huanTipsItemsNode:Find("Item")
    this.huanTipsInBtnPositionTrans = this.huanTrans:Find("InBtnPosition")
    this.huanBtnAnim = this.huanTrans:Find("BtnAnim"):GetComponent(TypeSkeletonGraphic)

    --收放按钮
    this.tipsInBtnTrans = self:Find("InButton")
    this.tipsInBtnGO = self:Find("InButton").gameObject
    this.tipsInBtnInGO = this.tipsInBtnTrans:Find("In").gameObject
    this.tipsInBtnOutGO = this.tipsInBtnTrans:Find("Out").gameObject

    --------------------------------
    --定缺相关
    local dingQueGroupTrans = self:Find("DingQueGroup")
    this.dingQueGroupGO = dingQueGroupTrans.gameObject
    --万
    this.wanTrans = dingQueGroupTrans:Find("Wan")
    this.wanGO = this.wanTrans.gameObject
    this.wanBtn = this.wanGO:GetComponent("Button")
    this.wanBtnGayGO = this.wanTrans:Find("Gay").gameObject
    --条
    this.tiaoTrans = dingQueGroupTrans:Find("Tiao")
    this.tiaoGO = this.tiaoTrans.gameObject
    this.tiaoBtn = this.tiaoGO:GetComponent("Button")
    this.tiaoBtnGayGO = this.tiaoTrans:Find("Gay").gameObject
    --筒
    this.tongTrans = dingQueGroupTrans:Find("Tong")
    this.tongGO = this.tongTrans.gameObject
    this.tongBtn = this.tongGO:GetComponent("Button")
    this.tongBtnGayGO = this.tongTrans:Find("Gay").gameObject
    --------------------------------
    --换牌相关
    local changeCardGroupTrans = self:Find("ChangeCardGroup")
    this.changeCardGroupGO = changeCardGroupTrans.gameObject
    --成麻
    local normalTipsTrans = changeCardGroupTrans:Find("NormalTips")
    this.normalTipsGO = normalTipsTrans.gameObject
    this.normalTipsBtnGO = normalTipsTrans:Find("Button").gameObject
    this.normalTipsBtn = this.normalTipsBtnGO:GetComponent(TypeButton)
    this.normalTipsImage = normalTipsTrans:Find("TipsImage"):GetComponent(TypeImage)
    --幺鸡
    local yaoJiTipsTrans = changeCardGroupTrans:Find("YaoJiTips")
    this.yaoJiTipsGO = yaoJiTipsTrans.gameObject
    this.yaoJiTipsBtnTrans = yaoJiTipsTrans:Find("Button")
    this.yaoJiTipsBtnGO = this.yaoJiTipsBtnTrans.gameObject
    this.yaoJiTipsBtn = this.yaoJiTipsBtnGO:GetComponent(TypeButton)
    this.yaoJiTipsImage = yaoJiTipsTrans:Find("TipsImage"):GetComponent(TypeImage)

    this.LastCardSelectTrans = self:Find("LastCardSelect")
    this.LastCardSelectCard1 = this.LastCardSelectTrans:Find("Card1")
    this.LastCardSelectCard2 = this.LastCardSelectTrans:Find("Card2")
    this.LastCardSelectCardImg1 = this.LastCardSelectCard1:Find("CardIcon"):GetComponent(TypeImage)
    this.LastCardSelectCardImg2 = this.LastCardSelectCard2:Find("CardIcon"):GetComponent(TypeImage)

    local atlas = self:Find("Atlas"):GetComponent("UISpriteAtlas")
    local tempSprites = atlas.sprites:ToTable()
    local length = #tempSprites
    local sprite = nil
    for i = 1, length do
        sprite = tempSprites[i]
        this.sprites[sprite.name] = sprite
    end
    --------------------------------
    --回放指示手指
    this.handTrans = self:Find("Hand")
    this.handGO = this.handTrans.gameObject
    this.handTweener = this.handGO:GetComponent("TweenScale")

    --设置UI的偏移
    this.CheckAndUpdateUIOffset()
    --事件
    this.AddUIListenerEvent()
end

--当面板开启开启时
function MahjongOperationPanel:OnOpened()
    MahjongOperationPanel.Instance = self
    this.AddListenerEvent()
    this.HidePlaybackHand()
    this.UpdateOperationData()
end

--当面板关闭时调用
function MahjongOperationPanel:OnClosed()
    if this.animClickTimer ~= nil then
        this.animClickTimer:Stop()
    end
    MahjongOperationPanel.Instance = nil
    this.isClickAnim = false
    this.HideAll()
    this.RemoveListenerEvent()
    this.HidePlaybackHand()
end

--根据屏幕是否为2比1设置偏移
function MahjongOperationPanel.CheckAndUpdateUIOffset()
    if this.isInitOffset == false then
        this.isInitOffset = true

        local offsetX = Global.GetOffsetX()

        UIUtil.AddAnchoredPositionX(this.cancelGroupGO, -offsetX)
        UIUtil.AddAnchoredPositionX(this.operationGroupGO, -offsetX)
    end
end

------------------------------------------------------------------
--
--关闭
function MahjongOperationPanel.Close()
    PanelManager.Close(MahjongPanelConfig.Operation)
end

--
function MahjongOperationPanel.AddListenerEvent()
    AddEventListener(CMD.Game.Mahjong.UpdateChangeCardButton, this.OnUpdateChangeCardButton)
    AddEventListener(CMD.Game.Mahjong.PlaybackOperate, this.OnPlaybackOperate)
end

--
function MahjongOperationPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Game.Mahjong.UpdateChangeCardButton, this.OnUpdateChangeCardButton)
    RemoveEventListener(CMD.Game.Mahjong.PlaybackOperate, this.OnPlaybackOperate)
end

--UI相关事件
function MahjongOperationPanel.AddUIListenerEvent()
    UIButtonListener.AddListener(this.guoBtn, this.OnGuoBtnClick)
    UIButtonListener.AddListener(this.cancelBtn, this.OnCancelBtnClick)

    UIButtonListener.AddListener(this.gangBtn, this.OnGangBtnClick)
    UIButtonListener.AddListener(this.pengBtn, this.OnPengBtnClick)
    UIButtonListener.AddListener(this.chiBtn, this.OnChiBtnClick)
    UIButtonListener.AddListener(this.huanBtn, this.OnHuanBtnClick)
    UIButtonListener.AddListener(this.huBtn, this.OnHuBtnClick)

    UIButtonListener.AddListener(this.normalTipsBtnGO, this.OnChangeCardBtnClick)
    UIButtonListener.AddListener(this.yaoJiTipsBtnGO, this.OnChangeCardBtnClick)

    UIButtonListener.AddListener(this.wanGO, this.OnWanBtnClick)
    UIButtonListener.AddListener(this.tiaoGO, this.OnTiaoBtnClick)
    UIButtonListener.AddListener(this.tongGO, this.OnTongBtnClick)
    UIButtonListener.AddListener(this.tipsInBtnGO, this.OnInBtnClick)

    UIButtonListener.AddListener(this.LastCardSelectCard1.gameObject, this.OnLastCardSelectCard1Click)
    UIButtonListener.AddListener(this.LastCardSelectCard2.gameObject, this.OnLastCardSelectCard2Click)

    this.handTweener:AddLuaFinished(this.OnHandTweenerCompleted)
end

------------------------------------------------------------------
--
--更新换牌按钮状态
function MahjongOperationPanel.OnUpdateChangeCardButton(isPlay)
    this.SetChangeCardAnimPlay(isPlay)
end

--回放操作
function MahjongOperationPanel.OnPlaybackOperate()
    this.HandlePlaybackOperate()
end

------------------------------------------------------------------
--
--检测获取牌ID
function MahjongOperationPanel.CheckGetCardId(data)
    local length = #data
    local id = nil
    for i = 1, length do
        id = this.CheckGetCardIdByData(data[i])
        if id ~= nil then
            return id
        end
    end
end

--检测获取牌ID
function MahjongOperationPanel.CheckGetCardIdByData(data)
    if not MahjongUtil.IsTingYongCard(data.k1) then
        if this.IsValidCardId(data.k1) then
            return data.k1
        end
    end
    return nil
end

--是否有效的牌ID
function MahjongOperationPanel.IsValidCardId(id)
    return id ~= nil and id > 0
end

------------------------------------------------------------------
--
--过
function MahjongOperationPanel.OnGuoBtnClick()
    if MahjongDataMgr.isPlayback or this.isClickAnim then
        return
    end
    Audio.PlayClickAudio()
    if MahjongPlayCardMgr.IsNewCardValid() then
        UIUtil.SetActive(this.cancelGroupGO, true)
        UIUtil.SetActive(this.operationGroupGO, false)
        this.SetPlayEffect(this.cancelBtnAnim, "Quxiao_loop", true)
        return
    end
    this.SetPlayEffect(this.guoBtnAnim, "Guo_click", false)
    this.isClickAnim = true
    if this.animClickTimer == nil then
        this.animClickTimer = Timing.New(this.OnGuoBtnClickCallBack, 0.5)
    else
        this.animClickTimer:Reset(this.OnGuoBtnClickCallBack, 0.5)
    end
    this.animClickTimer:Start()
end

--过 按钮点击回调方法
function MahjongOperationPanel.OnGuoBtnClickCallBack()
    Toast.Show("您已选择过操作")
    this.animClickTimer:Stop()
    this.isClickAnim = false
    local cardId = nil
    if MahjongDataMgr.Operation.huData ~= nil then
        cardId = this.CheckGetCardIdByData(MahjongDataMgr.Operation.huData)
    end

    if cardId == nil and MahjongDataMgr.Operation.pengDatas ~= nil then
        cardId = this.CheckGetCardId(MahjongDataMgr.Operation.pengDatas)
    end

    if cardId == nil and MahjongDataMgr.Operation.gangDatas ~= nil then
        cardId = this.CheckGetCardId(MahjongDataMgr.Operation.gangDatas)
    end

    if cardId == nil and MahjongDataMgr.Operation.chiDatas ~= nil then
        cardId = this.CheckGetCardId(MahjongDataMgr.Operation.chiDatas)
    end

    if cardId == nil then
        cardId = 0
    end

    --过的牌作为K1发送到服务器
    MahjongCommand.SendOperate(MahjongOperateCode.GUO, 0, cardId, 0, 0, 0)
    this.Close()
end


--取消
function MahjongOperationPanel.OnCancelBtnClick()
    Audio.PlayClickAudio()
    this.SetPlayEffect(this.cancelBtnAnim, "Quxiao_click", false)
    this.isClickAnim = true
    if this.animClickTimer == nil then
        this.animClickTimer = Timing.New(
            function ()
                this.animClickTimer:Stop()
                this.isClickAnim = false
                UIUtil.SetActive(this.cancelGroupGO, false)
                UIUtil.SetActive(this.operationGroupGO, true)
            end
        , 0.5)
    else
        this.animClickTimer:Reset(
            function ()
                this.animClickTimer:Stop()
                this.isClickAnim = false
                UIUtil.SetActive(this.cancelGroupGO, false)
                UIUtil.SetActive(this.operationGroupGO, true)
            end
        , 0.5)
    end
    this.animClickTimer:Start()
end

--特效按钮点击（杠、碰、吃、胡）
function MahjongOperationPanel.OnBtnAnimClick(itemAnim, animName, data)
    --操作点击特效不播放
    if data ~= nil then
        this.HandleOperateDataClick(data)
        return
    end

    this.SetPlayEffect(itemAnim, animName, false)
    this.isClickAnim = true
    if this.animClickTimer == nil then
        this.animClickTimer = Timing.New(
            function ()
                this.animClickTimer:Stop()
                this.isClickAnim = false
                this.HandleOperateDataClick(data)
            end
        , 0.5)
    else
        this.animClickTimer:Reset(
            function ()
                this.animClickTimer:Stop()
                this.isClickAnim = false
                this.HandleOperateDataClick(data)
            end
        , 0.5)
    end
    this.animClickTimer:Start()
end

--杠
function MahjongOperationPanel.OnGangBtnClick()
    if MahjongDataMgr.isPlayback or this.isClickAnim then
        return
    end
    Audio.PlayClickAudio()
    local gangDatas = MahjongDataMgr.Operation.gangDatas
    local length = #gangDatas
    if length < 1 then
        Toast.Show("杠操作错误...")
        return
    end

    --只有一个数据的时候，才可以点击
    if length == 1 then
        -- this.HandleOperateDataClick(gangDatas[1])
        this.OnBtnAnimClick(this.gangBtnAnim, "Gang_click", gangDatas[1])
    end
end

--碰
function MahjongOperationPanel.OnPengBtnClick()
    if MahjongDataMgr.isPlayback or this.isClickAnim then
        return
    end
    Audio.PlayClickAudio()
    local pengDatas = MahjongDataMgr.Operation.pengDatas
    local length = #pengDatas
    if length < 1 then
        Toast.Show("碰操作错误...")
        return
    end

    if length == 1 then
        -- this.HandleOperateDataClick(pengDatas[1])
        this.OnBtnAnimClick(this.pengBtnAnim, "Peng_click", pengDatas[1])
    end
end

---吃
function MahjongOperationPanel.OnChiBtnClick()
    if MahjongDataMgr.isPlayback or this.isClickAnim then
        return
    end
    Audio.PlayClickAudio()
    local chiDatas = MahjongDataMgr.Operation.chiDatas
    local length = #chiDatas
    if length < 1 then
        Toast.Show("吃操作错误...")
        return
    end

    --只有一个数据的时候，才可以点击
    if length == 1 then
        -- this.HandleOperateDataClick(chiDatas[1])
        this.OnBtnAnimClick(this.chiBtnAnim, "Chi_click", chiDatas[1])
    end
end

--换
function MahjongOperationPanel.OnHuanBtnClick()
    if MahjongDataMgr.isPlayback then
        return
    end
    Audio.PlayClickAudio()
    local huanDatas = MahjongDataMgr.Operation.huanDatas
    local length = #huanDatas
    if length < 1 then
        Toast.Show("换操作错误...")
        return
    end

    if length == 1 then
        -- this.HandleOperateDataClick(huanDatas[1])
        this.OnBtnAnimClick(this.huanBtnAnim, "Huanpai_click", huanDatas[1])
    end
end

--胡
function MahjongOperationPanel.OnHuBtnClick()
    if MahjongDataMgr.isPlayback or this.isClickAnim then
        return
    end
    Audio.PlayClickAudio()
    local huData = MahjongDataMgr.Operation.huData
    if huData == nil then
        Toast.Show("胡操作错误...")
        return
    end

    -- this.HandleOperateDataClick(huData)
    this.OnBtnAnimClick(this.huBtnAnim, "Hu_click", huData)
end

--换牌
function MahjongOperationPanel.OnChangeCardBtnClick()
    if MahjongDataMgr.isPlayback then
        return
    end
    Audio.PlayClickAudio()
    --换牌
    if MahjongPlayCardMgr.SendChangeCards() then
        this.Close()
    end
end

--万
function MahjongOperationPanel.OnWanBtnClick()
    if MahjongDataMgr.isPlayback then
        return
    end
    Audio.PlayClickAudio()
    this.HandleDingQueSelected(MahjongColorType.Wan, MahjongPlayCardMgr.wanCardNum)
end

--条
function MahjongOperationPanel.OnTiaoBtnClick()
    if MahjongDataMgr.isPlayback then
        return
    end
    Audio.PlayClickAudio()
    this.HandleDingQueSelected(MahjongColorType.Tiao, MahjongPlayCardMgr.tiaoCardNum)
end

--筒
function MahjongOperationPanel.OnTongBtnClick()
    if MahjongDataMgr.isPlayback then
        return
    end
    Audio.PlayClickAudio()
    this.HandleDingQueSelected(MahjongColorType.Tong, MahjongPlayCardMgr.tongCardNum)
end

---杠选牌1
function MahjongOperationPanel.OnLastCardSelectCard1Click()
    Audio.PlayClickAudio()
    local data = {
        MahjongOperateCode.BU_PAI, 0, MahjongDataMgr.LastShowCard1.id
    }
    MahjongPlayCardHelper.CacheSendOperation(data)
    MahjongCommand.SendOperate(MahjongOperateCode.BU_PAI, 0, MahjongDataMgr.LastShowCard1.id)
    UIUtil.SetActive(this.LastCardSelectTrans, false)
    this.Close()
end

---杠选牌2
function MahjongOperationPanel.OnLastCardSelectCard2Click()
    Audio.PlayClickAudio()
    local data = {
        MahjongOperateCode.BU_PAI, 0, MahjongDataMgr.LastShowCard2.id
    }
    MahjongPlayCardHelper.CacheSendOperation(data)
    MahjongCommand.SendOperate(MahjongOperateCode.BU_PAI, 0, MahjongDataMgr.LastShowCard2.id)
    UIUtil.SetActive(this.LastCardSelectTrans, false)
    this.Close()
end

--收放
function MahjongOperationPanel.OnInBtnClick()
    Audio.PlayClickAudio()
    --显示，则收起
    if this.tipsInBtnInGO.activeSelf then
        this.SwitchInBtn(false)
        this.SwitchTipsNode(false)
    else
        this.SwitchInBtn(true)
        this.SwitchTipsNode(true)
    end
end

--手动画播放完成
function MahjongOperationPanel.OnHandTweenerCompleted()
    --完成后检测
    this.UpdateOperationData()
    this.HidePlaybackHand()
end

--================================================================
--
--隐藏所有
function MahjongOperationPanel.HideAll()
    this.HideOperation()
    this.HideDingQue()
    this.HideChangeCard()
    this.HideCancel()
    this.HidePlaybackHand()
end

--更新操作项数据
function MahjongOperationPanel.UpdateOperationData()
    this.HideAll()

    Log(">> MahjongOperationPanel.UpdateOperationData 更新操作项数据", MahjongDataMgr.Operation.state)
    local state = MahjongDataMgr.Operation.state
    if state == MahjongOperatePanelState.Operation then
        this.HandleOperation()
    elseif state == MahjongOperatePanelState.Change then
        this.HandleChangeCard()
    elseif state == MahjongOperatePanelState.DingQue then
        this.HandleDingQue()
    else
        --没有操作，直接关闭
        this.Close()
    end
end

------------------------------------------------------------------
--缩放按钮相关
--设置坐标
function MahjongOperationPanel.SetInBtnPosition(targetTrans)
    this.tipsInBtnTrans:SetParent(targetTrans)
    UIUtil.SetActive(this.tipsInBtnGO, true)
    UIUtil.SetAnchoredPosition(this.tipsInBtnGO, 0, 0)

    this.SwitchInBtn(true)
end

--切换TipsNode的显示处理
function MahjongOperationPanel.SwitchTipsNode(isShow)
    if this.isHuanTipsShow then
        UIUtil.SetActive(this.huanTipsNodeGO, isShow)
    end
    if this.isPengTipsShow then
        UIUtil.SetActive(this.pengTipsNodeGO, isShow)
    end
    if this.isGangTipsShow then
        UIUtil.SetActive(this.gangTipsNodeGO, isShow)
    end
end

--收起按钮处理
function MahjongOperationPanel.SwitchInBtn(isShow)
    UIUtil.SetActive(this.tipsInBtnInGO, isShow)
    UIUtil.SetActive(this.tipsInBtnOutGO, not isShow)
end

------------------------------------------------------------------
--换牌相关
--隐藏换牌组
function MahjongOperationPanel.HideChangeCard()
    UIUtil.SetActive(this.changeCardGroupGO, false)
end

--处理换牌
function MahjongOperationPanel.HandleChangeCard()
    local data = MahjongDataMgr.Operation.changeCardsData

    if data == nil then
        LogWarn(">> MahjongOperationPanel.HandleChangeCard > data = nil.")
        return
    end
    UIUtil.SetActive(this.changeCardGroupGO, true)
    this.SetChangeCardAnimPlay(MahjongPlayCardMgr.CheckChangeCardsNum())
    --图片设置
    if MahjongDataMgr.isYaoJiPlayWay then
        UIUtil.SetActive(this.yaoJiTipsGO, true)
        UIUtil.SetActive(this.normalTipsGO, false)
        local assetName = nil
        if MahjongDataMgr.changeCardTotal == 4 then
            if MahjongDataMgr.changeCardType == MahjongChangeCardType.SingleColor then
                assetName = MahjongHuanPaiTipsName.YaojiSingleColorSiZhang
            else
                assetName = MahjongHuanPaiTipsName.YaojiArbitrarySiZhang
            end
        else
            if MahjongDataMgr.changeCardType == MahjongChangeCardType.SingleColor then
                assetName = MahjongHuanPaiTipsName.YaojiSingleColorSanZhang
            else
                assetName = MahjongHuanPaiTipsName.YaojiArbitrarySanZhang
            end
        end
        this.yaoJiTipsImage.sprite = this.sprites[assetName]
        this.yaoJiTipsImage:SetNativeSize()
    else
        UIUtil.SetActive(this.yaoJiTipsGO, false)
        UIUtil.SetActive(this.normalTipsGO, true)
        local assetName = nil
        if MahjongDataMgr.changeCardTotal == 4 then
            if MahjongDataMgr.changeCardType == MahjongChangeCardType.SingleColor then
                assetName = MahjongHuanPaiTipsName.SingleColorSiZhang
            else
                assetName = MahjongHuanPaiTipsName.ArbitrarySiZhang
            end
        else
            if MahjongDataMgr.changeCardType == MahjongChangeCardType.SingleColor then
                assetName = MahjongHuanPaiTipsName.SingleColorSanZhang
            else
                assetName = MahjongHuanPaiTipsName.ArbitrarySanZhang
            end
        end
        this.normalTipsImage.sprite = this.sprites[assetName]
        this.normalTipsImage:SetNativeSize()
    end
end

--设置换牌按钮动画播放
function MahjongOperationPanel.SetChangeCardAnimPlay(isPlay)
    if MahjongDataMgr.isYaoJiPlayWay then
        local item = nil
        if this.yaoJiTipsItem == nil then
            item = {}
            this.yaoJiTipsItem = item
            -- item.btnAnimGO = this.yaoJiTipsBtnTrans:Find("BtnAnim").gameObject
            --item.btnAnim = item.btnAnimGO:GetComponent("Animator")
            -- item.btnImg = item.btnAnimGO:GetComponent("Image")
            --item.lightAnimGO = this.yaoJiTipsBtnTrans:Find("LightAnim").gameObject
            --item.lightAnim = item.lightAnimGO:GetComponent("Animator")
            --item.lightImg = item.lightAnimGO:GetComponent("Image")
        end
        item = this.yaoJiTipsItem
        --if isPlay == false then
        --    --UIUtil.SetLocalScale(item.btnAnimGO, 1, 1, 1)
        --    --UIUtil.SetImageColor(item.btnImg, 1, 1, 1, 1)
        --    UIUtil.SetActive(item.btnAnimGO, false)
        --else
        --    UIUtil.SetActive(item.btnAnimGO, true)
        --end
        --item.btnAnim.enabled = isPlay
        --item.lightAnim.enabled = isPlay
        -- UIUtil.SetActive(item.btnAnimGO, isPlay)
        this.yaoJiTipsBtn.interactable = isPlay
    else
        -- local btnAnimGO = this.normalTipsBtnGO.transform:Find("BtnAnim").gameObject
        -- UIUtil.SetActive(btnAnimGO, isPlay)
        this.normalTipsBtn.interactable = isPlay
    end
end

------------------------------------------------------------------
--定缺相关
--隐藏定缺组
function MahjongOperationPanel.HideDingQue()
    UIUtil.SetActive(this.dingQueGroupGO, false)
end

--设置定缺动画播放
function MahjongOperationPanel.SetDingQueAnimPlay(type, trans, isPlay)
    local item = this.dingQueItems[type]
    if item == nil then
        item = {}
        this.dingQueItems[type] = item
        item.btnAnimGO = trans:Find("BtnAnim").gameObject
        --item.btnAnim = item.btnAnimGO:GetComponent("Animator")
        --item.btnImg = item.btnAnimGO:GetComponent("Image")
        --item.lightAnimGO = trans:Find("LightAnim").gameObject
        --item.lightAnim = item.lightAnimGO:GetComponent("Animator")
        --item.lightImg = item.lightAnimGO:GetComponent("Image")
    end
    UIUtil.SetActive(item.btnAnimGO, isPlay)

    --if isPlay == false then
    --    UIUtil.SetLocalScale(item.btnAnimGO, 1, 1, 1)
    --    UIUtil.SetLocalScale(item.lightAnimGO, 1, 1, 1)
    --    UIUtil.SetImageColor(item.btnImg, 1, 1, 1, 1)
    --    UIUtil.SetImageColor(item.lightImg, 1, 1, 1, 1)
    --    UIUtil.SetActive(item.lightAnimGO, false)
    --else
    --UIUtil.SetActive(item.lightAnimGO, true)
    --end
    --item.btnAnim.enabled = isPlay
    --item.lightAnim.enabled = isPlay
end

--处理定缺
function MahjongOperationPanel.HandleDingQue()
    local data = MahjongDataMgr.Operation.dingQueData

    if data == nil then
        LogWarn(">> MahjongOperationPanel.HandleDingQue > data = nil.")
        return
    end

    UIUtil.SetActive(this.dingQueGroupGO, true)

    local key1 = data.k1
    local key2 = data.k2

    --处理推荐动画
    this.SetDingQueAnimPlay(MahjongColorType.Wan, this.wanTrans,
        key1 == MahjongColorType.Wan or key2 == MahjongColorType.Wan)
    this.SetDingQueAnimPlay(MahjongColorType.Tiao, this.tiaoTrans,
        key1 == MahjongColorType.Tiao or key2 == MahjongColorType.Tiao)
    this.SetDingQueAnimPlay(MahjongColorType.Tong, this.tongTrans,
        key1 == MahjongColorType.Tong or key2 == MahjongColorType.Tong)

    if MahjongPlayCardMgr.wanCardNum >= 8 then
        this.wanBtn.interactable = false
        UIUtil.SetActive(this.wanBtnGayGO, true)
    else
        this.wanBtn.interactable = true
        UIUtil.SetActive(this.wanBtnGayGO, false)
    end

    if MahjongPlayCardMgr.tiaoCardNum >= 8 then
        this.tiaoBtn.interactable = false
        UIUtil.SetActive(this.tiaoBtnGayGO, true)
    else
        this.tiaoBtn.interactable = true
        UIUtil.SetActive(this.tiaoBtnGayGO, false)
    end

    if MahjongPlayCardMgr.tongCardNum >= 8 then
        this.tongBtn.interactable = false
        UIUtil.SetActive(this.tongBtnGayGO, true)
    else
        this.tongBtn.interactable = true
        UIUtil.SetActive(this.tongBtnGayGO, false)
    end
end

------------------------------------------------------------------
--取消相关
function MahjongOperationPanel.HideCancel()
    UIUtil.SetActive(this.cancelGroupGO, false)
end

--================================================================
--隐藏操作组
function MahjongOperationPanel.HideOperation()
    UIUtil.SetActive(this.operationGroupGO, false)
end

--隐藏操作按钮
function MahjongOperationPanel.HideOperationBtns()
    UIUtil.SetActive(this.guoGO, false)
    UIUtil.SetActive(this.gangGO, false)
    UIUtil.SetActive(this.pengGO, false)
    UIUtil.SetActive(this.huanGO, false)
    UIUtil.SetActive(this.huGO, false)

    this.CloseAllOperationTips()
end

--关闭所有操作提示界面
function MahjongOperationPanel.CloseAllOperationTips()
    UIUtil.SetActive(this.gangTipsNodeGO, false)
    UIUtil.SetActive(this.pengTipsNodeGO, false)
    UIUtil.SetActive(this.huanTipsNodeGO, false)
    UIUtil.SetActive(this.tipsInBtnGO, false)
end

--处理操作项
function MahjongOperationPanel.HandleOperation()
    Log(">> MahjongOperationPanel.UpdateOperationData1 > ", MahjongDataMgr.Operation.state)

    UIUtil.SetActive(this.operationGroupGO, true)

    UIUtil.SetActive(this.guoGO, true)
    UIUtil.SetActive(this.huGO, MahjongDataMgr.Operation.huData ~= nil)

    this.SetPlayEffect(this.guoBtnAnim, "Guo_loop", true)
    if MahjongDataMgr.Operation.huData ~= nil then
        this.SetPlayEffect(this.huBtnAnim, "Hu_loop", true) 
    end

    this.isHuanTipsShow = false
    this.isPengTipsShow = false
    this.isGangTipsShow = false

    if MahjongDataMgr.Operation.huanDatas ~= nil and #MahjongDataMgr.Operation.huanDatas > 0 then
        UIUtil.SetActive(this.huanGO, true)
        this.HandleHuanTips()
        this.SetPlayEffect(this.huanBtnAnim, "Huanpai_loop", true)
    else
        UIUtil.SetActive(this.huanGO, false)
    end

    if MahjongDataMgr.Operation.pengDatas ~= nil and #MahjongDataMgr.Operation.pengDatas > 0 then
        UIUtil.SetActive(this.pengGO, true)
        this.HandlePengTips()
        this.SetPlayEffect(this.pengBtnAnim, "Peng_loop", true)
    else
        UIUtil.SetActive(this.pengGO, false)
    end

    if MahjongDataMgr.Operation.chiDatas ~= nil and #MahjongDataMgr.Operation.chiDatas > 0 then
        UIUtil.SetActive(this.chiGO, true)
        this.HandleChiTips()
        this.SetPlayEffect(this.chiBtnAnim, "Chi_loop", true)
    else
        UIUtil.SetActive(this.chiGO, false)
    end

    if MahjongDataMgr.Operation.gangDatas ~= nil and #MahjongDataMgr.Operation.gangDatas > 0 then
        UIUtil.SetActive(this.gangGO, true)
        this.HandleGangTips()
        this.SetPlayEffect(this.gangBtnAnim, "Gang_loop", true)
    else
        UIUtil.SetActive(this.gangGO, false)
    end

    if MahjongDataMgr.Operation.buPaiDatas ~= nil and #MahjongDataMgr.Operation.buPaiDatas > 0 then
        this.HandleGangCanChoose()
    else
        UIUtil.SetActive(this.LastCardSelectTrans, false)
    end

    --非幺鸡玩法不显示收缩按钮
    if MahjongDataMgr.isYaoJiPlayWay == false then
        UIUtil.SetActive(this.tipsInBtnGO, false)
        return
    end

    if this.isHuanTipsShow then
        this.SetInBtnPosition(this.huanTipsInBtnPositionTrans)
        return
    end

    if this.isPengTipsShow then
        this.SetInBtnPosition(this.pengTipsInBtnPositionTrans)
        return
    end

    if this.isGangTipsShow then
        this.SetInBtnPosition(this.gangTipsInBtnPositionTrans)
        return
    end
end

function MahjongOperationPanel.SetPlayEffect(item, animName, loop)
    local temp = item.SkeletonData:FindAnimation(animName)
    if temp ~= nil then
        item.AnimationState:SetAnimation(0, animName, loop)
    end
end

--处理换牌
function MahjongOperationPanel.HandleHuanTips()
    local huanDatas = MahjongDataMgr.Operation.huanDatas
    local length = #huanDatas

    if MahjongDataMgr.isYaoJiPlayWay == false then
        if length < 2 then
            UIUtil.SetActive(this.huanTipsNodeGO, false)
            return
        end
    end
    --换牌暂时只有幺鸡麻将出现，且一出现就要显示Tips，所以不处理宽度
    UIUtil.SetActive(this.huanTipsNodeGO, true)
    this.isHuanTipsShow = true

    local itemsLength = #this.huanTipsItems
    local item = nil
    local operationData = nil
    for i = 1, length do
        operationData = huanDatas[i]
        if i <= itemsLength then
            item = this.huanTipsItems[i]
        else
            item = this.CreateHuanTipsItem(tostring(i))
        end
        UIUtil.SetActive(item.gameObject, true)
        item.data = operationData
        this.SetItemMahjongImage(item)
    end

    --牌的数量小于item数量，隐藏多余的Item
    if length < itemsLength then
        for i = length + 1, itemsLength do
            item = this.huanTipsItems[i]
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

--创建换牌的显示项
function MahjongOperationPanel.CreateHuanTipsItem(name)
    local obj = CreateGO(this.huanTipsItemPrefab, this.huanTipsItemsNode, name)
    local item = {}
    item.gameObject = obj
    item.images = {}
    local objTrans = obj.transform
    for i = 1, 4 do
        local tempTrans = objTrans:Find("mj" .. i)
        item.images[i] = {
            gameObject = tempTrans.gameObject,
            cardIcon = tempTrans:Find("CardIcon"):GetComponent(TypeImage),
            markGo = tempTrans:Find("Mark").gameObject,
            isActive = true
        }
    end
    table.insert(this.huanTipsItems, item)
    UIButtonListener.AddListener(item.gameObject, this.OnHuanItemClick)
    return item
end

--处理杠牌
function MahjongOperationPanel.HandleGangTips()
    local gangDatas = MahjongDataMgr.Operation.gangDatas
    local length = #gangDatas

    --幺鸡类型时，都要显示Tips
    if MahjongDataMgr.isYaoJiPlayWay == false then
        if length < 2 then
            UIUtil.SetActive(this.gangTipsNodeGO, false)
            UIUtil.SetWidth(this.gangGO, 150)
            return
        end
    end

    UIUtil.SetActive(this.gangTipsNodeGO, true)
    UIUtil.SetWidth(this.gangGO, 240)
    this.isGangTipsShow = true

    --动态设置Layout的列数限制
    local constraintCount = math.ceil(length / 4)
    this.gangGridLayoutGroup.constraintCount = constraintCount

    local itemsLength = #this.gangTipsItems
    local item = nil
    local operationData = nil
    for i = 1, length do
        operationData = gangDatas[i]
        if i <= itemsLength then
            item = this.gangTipsItems[i]
        else
            item = this.CreateGangTipsItem(tostring(i))
        end
        UIUtil.SetActive(item.gameObject, true)
        item.data = operationData
        if MahjongDataMgr.playWayType == Mahjong.PlayWayType.FlyChicken then
            this.GetChiTipItemSprite(item)
        else
            this.SetItemMahjongImage(item)
        end
    end

    --牌的数量小于item数量，隐藏多余的Item
    if length < itemsLength then
        for i = length + 1, itemsLength do
            item = this.gangTipsItems[i]
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

--创建杠牌的显示项
function MahjongOperationPanel.CreateGangTipsItem(name)
    local obj = CreateGO(this.gangTipsItemPrefab, this.gangTipsItemsNode, name)
    local item = {}
    item.gameObject = obj
    item.images = {}
    local objTrans = obj.transform
    for i = 1, 4 do
        local tempTrans = objTrans:Find("mj" .. i)
        item.images[i] = {
            gameObject = tempTrans.gameObject,
            cardIcon = tempTrans:Find("CardIcon"):GetComponent(TypeImage),
            markGo = tempTrans:Find("Mark").gameObject,
            isActive = true
        }
    end
    table.insert(this.gangTipsItems, item)
    UIButtonListener.AddListener(item.gameObject, this.OnGangItemClick)
    return item
end

--处理碰牌
function MahjongOperationPanel.HandlePengTips()
    local pengDatas = MahjongDataMgr.Operation.pengDatas
    local length = #pengDatas

    if MahjongDataMgr.isYaoJiPlayWay == false then
        if length < 2 then
            UIUtil.SetActive(this.pengTipsNodeGO, false)
            UIUtil.SetWidth(this.pengGO, 150)
            return
        end
    end

    UIUtil.SetActive(this.pengTipsNodeGO, true)
    UIUtil.SetWidth(this.pengGO, 176)
    this.isPengTipsShow = true

    local itemsLength = #this.pengTipsItems
    local item = nil
    local operationData = nil
    for i = 1, length do
        operationData = pengDatas[i]
        if i <= itemsLength then
            item = this.pengTipsItems[i]
        else
            item = this.CreatePengTipsItem(tostring(i))
        end
        UIUtil.SetActive(item.gameObject, true)
        item.data = operationData
        this.SetItemMahjongImage(item)
    end

    --牌的数量小于item数量，隐藏多余的Item
    if length < itemsLength then
        for i = length + 1, itemsLength do
            item = this.pengTipsItems[i]
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

--创建碰牌的显示项
function MahjongOperationPanel.CreatePengTipsItem(name)
    local obj = CreateGO(this.pengTipsItemPrefab, this.pengTipsItemsNode, name)
    local item = {}
    item.gameObject = obj
    item.images = {}
    local objTrans = obj.transform
    for i = 1, 3 do
        local tempTrans = objTrans:Find("mj" .. i)
        item.images[i] = {
            gameObject = tempTrans.gameObject,
            cardIcon = tempTrans:Find("CardIcon"):GetComponent(TypeImage),
            markGo = tempTrans:Find("Mark").gameObject,
            isActive = true
        }
    end
    table.insert(this.pengTipsItems, item)
    UIButtonListener.AddListener(item.gameObject, this.OnPengItemClick)
    return item
end

---处理吃牌
function MahjongOperationPanel.HandleChiTips()
    local chiDatas = MahjongDataMgr.Operation.chiDatas
    local length = #chiDatas

    --幺鸡类型时，都要显示Tips
    if MahjongDataMgr.isYaoJiPlayWay == false then
        if length < 2 then
            UIUtil.SetActive(this.chiTipsNodeGO, false)
            UIUtil.SetWidth(this.chiGO, 140)
            return
        end
    end

    UIUtil.SetActive(this.chiTipsNodeGO, true)
    UIUtil.SetWidth(this.chiGO, 240)
    this.ischiTipsShow = true

    --动态设置Layout的列数限制
    local constraintCount = math.ceil(length / 4)
    this.chiGridLayoutGroup.constraintCount = constraintCount

    local itemsLength = #this.chiTipsItems
    local item = nil
    local operationData = nil
    for i = 1, length do
        operationData = chiDatas[i]
        if i <= itemsLength then
            item = this.chiTipsItems[i]
        else
            item = this.CreateChiTipsItem(tostring(i))
        end
        UIUtil.SetActive(item.gameObject, true)
        item.data = operationData
        this.GetChiTipItemSprite(item)
    end

    --牌的数量小于item数量，隐藏多余的Item
    if length < itemsLength then
        for i = length + 1, itemsLength do
            item = this.chiTipsItems[i]
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

--创建吃牌的显示项
function MahjongOperationPanel.CreateChiTipsItem(name)
    local obj = CreateGO(this.chiTipsItemPrefab, this.chiTipsItemsNode, name)
    local item = {}
    item.gameObject = obj
    item.images = {}
    local objTrans = obj.transform
    for i = 1, 3 do
        local tempTrans = objTrans:Find("mj" .. i)
        item.images[i] = {
            gameObject = tempTrans.gameObject,
            cardIcon = tempTrans:Find("CardIcon"):GetComponent(TypeImage),
            markGo = tempTrans:Find("Mark").gameObject,
            isActive = true
        }
    end
    table.insert(this.chiTipsItems, item)
    UIButtonListener.AddListener(item.gameObject, this.OnChiItemClick)
    return item
end

--设置显示项麻将牌
function MahjongOperationPanel.SetItemMahjongImage(item)
    --处理key
    local cardIds = { item.data.k1, item.data.k2, item.data.k3, item.data.k4 }
    local length = #cardIds
    local cardData = nil
    local cardId = nil
    local cardKeys = {}
    for i = 1, length do
        cardId = cardIds[i]
        if cardId ~= nil and cardId > 0 then
            cardData = MahjongDataMgr.GetCardData(cardId)
            table.insert(cardKeys, cardData.key)
        end
    end

    length = #item.images
    local keyLength = #cardKeys
    local tempKey = nil
    local imageItem = nil
    if MahjongDataMgr.isYaoJiPlayWay then
        for i = 1, length do
            tempKey = cardKeys[i]
            imageItem = item.images[i]
            if tempKey ~= nil then
                local isTingYong = MahjongUtil.IsTingYongCard(tempKey)

                if not imageItem.isActive then
                    imageItem.isActive = true
                    UIUtil.SetActive(imageItem.gameObject, true)
                end
                if isTingYong then
                    this.SetCardMaskColor(imageItem, MahjongMaskColorType.TingYong)
                else
                    this.SetCardMaskColor(imageItem, MahjongMaskColorType.None)
                end
                imageItem.cardIcon.sprite = MahjongResourcesMgr.GetCardSprite(tempKey)
            else
                if imageItem.isActive then
                    imageItem.isActive = false
                    UIUtil.SetActive(imageItem.gameObject, false)
                end
            end
        end
    else
        tempKey = cardKeys[1]
        for i = 1, length do
            imageItem = item.images[i]
            if i <= keyLength then
                if not imageItem.isActive then
                    imageItem.isActive = true
                    UIUtil.SetActive(imageItem.gameObject, true)
                end
                this.SetCardMaskColor(imageItem, MahjongMaskColorType.None)
                imageItem.cardIcon.sprite = MahjongResourcesMgr.GetCardSprite(tempKey)
            else
                if imageItem.isActive then
                    imageItem.isActive = false
                    UIUtil.SetActive(imageItem.gameObject, false)
                end
            end
        end
    end
end

--设置牌的遮罩颜色
function MahjongOperationPanel.SetCardMaskColor(item, maskColorType)
    if item.maskColorType ~= maskColorType then
        item.maskColorType = maskColorType
        UIUtil.SetActive(item.markGo, maskColorType == MahjongMaskColorType.TingYong)
    end
end

function MahjongOperationPanel.GetChiTipItemSprite(item)
    local cardIds = { item.data.k1, item.data.k2, item.data.k3, item.data.k4 }
    local length = #cardIds
    local cardData
    local cardId
    local cardKeys = {}
    for i = 1, length do
        cardId = cardIds[i]
        if cardId ~= nil and cardId > 0 then
            cardData = MahjongDataMgr.GetCardData(cardId)
            table.insert(cardKeys, cardData.key)
        end
    end

    length = #item.images
    local keyLength = #cardKeys
    local imageItem
    for i = 1, length do
        imageItem = item.images[i]
        if i <= keyLength then
            if not imageItem.isActive then
                imageItem.isActive = true
                UIUtil.SetActive(imageItem.gameObject, true)
            end
            imageItem.cardIcon.sprite = MahjongResourcesMgr.GetCardSprite(cardKeys[i])
        else
            if imageItem.isActive then
                imageItem.isActive = false
                UIUtil.SetActive(imageItem.gameObject, false)
            end
        end
    end
end

function MahjongOperationPanel.CheckHandCard()

end

------------------------------------------------------------------
--
--换牌的点击
function MahjongOperationPanel.OnHuanItemClick(listener)
    if MahjongDataMgr.isPlayback then
        return
    end
    Audio.PlayClickAudio()
    local index = tonumber(listener.name)
    local item = this.huanTipsItems[index]
    if item ~= nil and item.data ~= nil then
        this.HandleOperateDataClick(item.data)
    else
        Toast.Show("换选项操作错误...")
    end
end

--杠牌的点击
function MahjongOperationPanel.OnGangItemClick(listener)
    if MahjongDataMgr.isPlayback then
        return
    end
    Audio.PlayClickAudio()
    local index = tonumber(listener.name)
    local item = this.gangTipsItems[index]
    if item ~= nil and item.data ~= nil then
        this.HandleOperateDataClick(item.data)
    else
        Toast.Show("杠选项操作错误...")
    end
end

--碰牌的点击
function MahjongOperationPanel.OnPengItemClick(listener)
    if MahjongDataMgr.isPlayback then
        return
    end
    Audio.PlayClickAudio()
    local index = tonumber(listener.name)
    local item = this.pengTipsItems[index]
    if item ~= nil and item.data ~= nil then
        this.HandleOperateDataClick(item.data)
    else
        Toast.Show("碰选项操作错误...")
    end
end

--吃牌的点击
function MahjongOperationPanel.OnChiItemClick(listener)
    if MahjongDataMgr.isPlayback then
        return
    end
    Audio.PlayClickAudio()
    local index = tonumber(listener.name)
    local item = this.chiTipsItems[index]
    if item ~= nil and item.data ~= nil then
        this.HandleOperateDataClick(item.data)
    else
        Toast.Show("吃选项操作错误...")
    end
end

--================================================================
--
--处理操作数据点击
function MahjongOperationPanel.HandleOperateDataClick(data)
    MahjongPlayCardHelper.CacheSendOperation(data)
    MahjongCommand.SendOperate(data.type, data.from, data.k1, data.k2, data.k3, data.k4)
    this.Close()
end

--处理定缺房选择，类型跟手牌数量
function MahjongOperationPanel.HandleDingQueSelected(type, cardNum)
    if cardNum >= 6 then
        Alert.Prompt("选择该房的牌张数量较多，是否定缺该房牌？", HandlerArgs(this.HandleDingQueClick, type))
    else
        this.HandleDingQueClick(type)
    end
end

--处理定缺点击
function MahjongOperationPanel.HandleDingQueClick(type)
    local data = {
        type = MahjongOperateCode.DING_QUE,
        from = -2,
        k1 = type,
        k2 = 0,
        k3 = 0,
        k4 = 0
    }
    MahjongPlayCardHelper.CacheSendOperation(data)
    MahjongCommand.SendOperate(data.type, data.from, data.k1, data.k2, data.k3, data.k4)
    this.Close()
end

--================================================================
--
--处理回放的操作
function MahjongOperationPanel.HandlePlaybackOperate()
    --Log(">> MahjongOperationPanel.HandlePlaybackOperate > type = " .. MahjongDataMgr.Operation.type)
    if MahjongDataMgr.isPlayback == false then
        return
    end

    local type = MahjongDataMgr.Operation.type
    local tempType = MahjongPlaybackCardMgr.ConvertPlaybackOperate(type)

    if tempType == MahjongOperateCode.HU then
        this.ShowPlaybackHand(this.huBtn)
    elseif tempType == MahjongOperateCode.GANG then
        this.ShowPlaybackHand(this.gangBtn)
    elseif tempType == MahjongOperateCode.PENG then
        this.ShowPlaybackHand(this.pengBtn)
    elseif tempType == MahjongOperateCode.FlyChickenChi then
        this.ShowPlaybackHand(this.chiBtn)
    elseif tempType == MahjongOperateCode.HUAN_PAI then
        this.ShowPlaybackHand(this.huanBtn)
    elseif tempType == MahjongOperateCode.GUO then
        this.ShowPlaybackHand(this.guoBtn)
    elseif tempType == MahjongOperateCode.HUAN_ZHANG then
        this.HandlePlaybackHuanZhang()
    elseif tempType == MahjongOperateCode.DING_QUE then
        this.HandlePlaybackDingQue()
    elseif tempType == MahjongOperateCode.BU_PAI then
        --this.HandleGangCanChoose()
    end
end

--处理回放换张选择
function MahjongOperationPanel.HandlePlaybackHuanZhang()
    if MahjongDataMgr.isYaoJiPlayWay then
        this.ShowPlaybackHand(this.yaoJiTipsBtnGO)
    else
        this.ShowPlaybackHand(this.normalTipsBtnGO)
    end
end

--处理回放定缺选择
function MahjongOperationPanel.HandlePlaybackDingQue()
    local dingQueType = MahjongDataMgr.Operation.card
    if dingQueType == MahjongColorType.Wan then
        this.ShowPlaybackHand(this.wanGO)
    elseif dingQueType == MahjongColorType.Tiao then
        this.ShowPlaybackHand(this.tiaoGO)
    elseif dingQueType == MahjongColorType.Tong then
        this.ShowPlaybackHand(this.tongGO)
    else
        this.OnHandTweenerCompleted()
    end
end

--处理杠选牌
function MahjongOperationPanel.HandleGangCanChoose()
    LogError("处理杠选牌操作")
    UIUtil.SetActive(this.LastCardSelectTrans, true)
    this.LastCardSelectCardImg1.sprite = MahjongResourcesMgr.GetCardSprite(MahjongDataMgr.LastShowCard1.key)
    this.LastCardSelectCardImg2.sprite = MahjongResourcesMgr.GetCardSprite(MahjongDataMgr.LastShowCard2.key)
end

--显示回放手
function MahjongOperationPanel.ShowPlaybackHand(targetGameObject)
    UIUtil.SetActive(this.handGO, true)
    UIUtil.SetPosition(this.handGO, targetGameObject.transform.position)
    this.handTweener:ResetToBeginning()
    this.handTweener:PlayForward()
end

--手引导相关
function MahjongOperationPanel.HidePlaybackHand()
    UIUtil.SetActive(this.handGO, false)
end
