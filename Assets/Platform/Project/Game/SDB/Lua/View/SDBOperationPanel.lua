SDBOperationPanel = ClassPanel("SDBOperationPanel");
local this = SDBOperationPanel
local compareCardTimer = nil
local mSelf = nil
local tongShaTimer = nil
--启动事件--
function SDBOperationPanel:OnInitUI()
    mSelf = self
    self:InitPanel()
    require(SDBCtrlNames.Operation)
    self.ctrl = AddLuaComponent(self.gameObject, "SDBOperationCtrl")
    self.ctrl.panel = self
    SendMsg(SDBAction.SDBLoadEnd, 3)
    Log(">>>>>>>>>>>>>>>>>>>       加载操作结束")
end

function SDBOperationPanel:InitPanel()
    local transform = self.transform
    --下注界面
    self.BetState = transform:Find("BetState")
    self.BetStateItem = self.BetState:Find("betItem").gameObject
    self.pushNoitItem = self.BetState:Find("pushItem").gameObject
    self.BetStateDouble = self.BetState:Find("Double")
    self.BetStateBolusitem = self.BetState:Find("bolusitem")

    --操作按钮
    self.OperationBtns = transform:Find("OperationBtns")
    self.doneButton = self.OperationBtns:Find("DoneButton").gameObject
    self.getCardsBtn = self.OperationBtns:Find("GetCardButton").gameObject

    --抢庄倍数
    self.RobZhuangMulriple = {}
    self.RobZhuangMulriple.transform = transform:Find("RobZhuangMulriple")
    self.RobZhuangMulriple.gameObject = self.RobZhuangMulriple.transform.gameObject
    for i = -1, 4 do
        local item = self.RobZhuangMulriple.transform:Find(i)
        self.RobZhuangMulriple[i] = item
    end

    --抢庄倍数
    self.RobZhuangMulripleGray = {}
    --置灰的倍数按钮
    for i = 1, 4 do
        local item = self.RobZhuangMulriple.transform:Find(i .. "-1")
        self.RobZhuangMulripleGray[i] = item
    end

    self.compareCard = transform:Find("CompareCard").gameObject
    self.tongSha = transform:Find("TongSha").gameObject
    self.tongShaEffect = transform:Find("TongSha/Effect").gameObject

end

--初始化面板--
function SDBOperationPanel:OnOpened()
    self.ctrl:OnCreate()
end


--开关操作按钮界面
function SDBOperationPanel.SetOperationBtnActive(isShow)
    if not isShow then
        Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>> 关闭要牌操作按钮")
    end
    UIUtil.SetActive(mSelf.OperationBtns.gameObject, isShow)
end

--设置推注面板的激活状态
function SDBOperationPanel.SetBolusActive(isShow)
    UIUtil.SetActive(mSelf.Bolus.gameObject, isShow)
end

--设置下注激活状态
function SDBOperationPanel.SetBetState(isShow)
    Log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>     下注激活状态变更")
    UIUtil.SetActive(mSelf.BetState.gameObject, isShow)
end

--显示比牌
function SDBOperationPanel.ShowCompareCard(funs)
    if mSelf == nil then
        return
    end

    if compareCardTimer ~= nil then
        return
    end
    compareCardTimer = Timer.New(function()
        compareCardTimer = nil
        UIUtil.SetActive(mSelf.compareCard, false)
        if funs ~= nil then
            funs()
        end
    end, 2, 1)
    compareCardTimer:Start()
    UIUtil.SetActive(mSelf.compareCard, true)
end

--显示通杀
function SDBOperationPanel.ShowTongSha()
    if mSelf ~= nil then
        if tongShaTimer ~= nil then
            return
        end
        tongShaTimer = Timer.New(function()
            tongShaTimer = nil
            UIUtil.SetActive(mSelf.tongSha, false)
        end, 1, 1)
        tongShaTimer:Start()
        UIUtil.SetActive(mSelf.tongSha, true)
        UIUtil.SetActive(mSelf.tongShaEffect, true)
    end
end

--关闭比牌通杀界面
function SDBOperationPanel.HideCompareCardTongSha()
    UIUtil.SetActive(mSelf.compareCard, false)
    UIUtil.SetActive(mSelf.tongSha, false)
    UIUtil.SetActive(mSelf.tongShaEffect, false)
end


--销毁时自动调用
function SDBOperationPanel:OnDestroy()
    if compareCardTimer ~= nil then
        compareCardTimer:Stop()
    end
    compareCardTimer = nil

    mSelf = nil

    if tongShaTimer ~= nil then
        tongShaTimer:Stop()
    end
    tongShaTimer = nil
end