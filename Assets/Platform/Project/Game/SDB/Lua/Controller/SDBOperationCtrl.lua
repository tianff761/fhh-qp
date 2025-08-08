SDBOperationCtrl = ClassPanel("SDBOperationCtrl")
local this = SDBOperationCtrl

--所有下注item
local allBetStateItems = {}
--推注item
local tuiZhuItem = {}
--当前操作牌
local curCards = nil
--要牌点击时间
local OnClicktime = 0

local mSelf = nil

local isInitied = false

local rubOnComplete = nil

function SDBOperationCtrl:Awake()
    mSelf = self
end

-- 启动事件--
function SDBOperationCtrl:OnCreate()
    self:AddClickEvent()
    this.ResetOperation()
end

--添加点击事件
function SDBOperationCtrl:AddClickEvent()
    self:AddOnClick(self.panel.getCardsBtn.gameObject, this.OnClickGetCardsBtn)
    self:AddOnClick(self.panel.doneButton.gameObject, this.OnClickDoneButton)
    for i = -1, 4 do
        self:AddOnClick(self.panel.RobZhuangMulriple[i].gameObject, HandlerArgs(this.OnClickRubZhuangReslult, self.panel.RobZhuangMulriple[i].gameObject))
    end
end

--点击是否抢庄
function SDBOperationCtrl.OnClickRubZhuangReslult(obj)
    if SDBRoomData.isPlayback then
        return
    end
    local num = tonumber(obj.name)
    if num == 0 then
        SDBResourcesMgr.PlayGameOperSound(SDBGameSoundType.NOROB, SDBRoomData.mainId)
    else
        SDBResourcesMgr.PlayGameOperSound(SDBGameSoundType.ROB, SDBRoomData.mainId)
    end

    if num == -1 then
        num = 1
    end

    SDBApiExtend.SendRobBanker(num)
    SDBOperationCtrl.HideRobZhuangReslult()
end

--显示抢庄Reslult  --传入是否有倍数
function SDBOperationCtrl.ShowRobZhuangReslult(isMultiple, value)
    if isMultiple == false then
        return
    end
    local isNilValue = IsNil(value)
    for i = -1, #mSelf.panel.RobZhuangMulriple do
        --兼容不传value 值时，默认全显示
        local isActive = false
        if isNilValue then
            isActive = true
        else
            for _, v in ipairs(value) do
                if tostring(i) == v then
                    isActive = true
                end
            end
        end

        local item = mSelf.panel.RobZhuangMulripleGray[i]
        if not IsNil(item) then
            UIUtil.SetActive(item, not isActive)
        end
        UIUtil.SetActive(mSelf.panel.RobZhuangMulriple[i].gameObject, isActive)

        if i > SDBRoomData.multipleValue or i == -1 then
            UIUtil.SetActive(mSelf.panel.RobZhuangMulriple[i].gameObject, false)
        end
    end

    UIUtil.SetActive(mSelf.panel.RobZhuangMulriple.gameObject, true)
end

--隐藏抢庄Reslult
function SDBOperationCtrl.HideRobZhuangReslult()
    if mSelf.transform == nil then
        return
    end
    UIUtil.SetActive(mSelf.panel.RobZhuangMulriple.gameObject, false)
end

--显示下注按钮
function SDBOperationCtrl.ShowBetState(xiaZhuStr, tuiZhuStr, Restricts)
    --关闭所有的下注选项
    for i = 1, #allBetStateItems do
        UIUtil.SetActive(allBetStateItems[i], false)
    end
    --关闭所有的推注选项
    for i = 1, #tuiZhuItem do
        UIUtil.SetActive(tuiZhuItem[i], false)
    end

    mSelf.panel.SetBetState(true)
    --显示下注分数选项
    for i = 1, #xiaZhuStr do
        local item
        if allBetStateItems[i] == nil then
            item = CreateGO(mSelf.panel.BetStateItem.gameObject, mSelf.panel.BetState, i)
            item.transform.localPosition = Vector3.New(item.transform.localPosition.x, item.transform.localPosition.y, 0)
            allBetStateItems[i] = item
            this:AddOnClick(item, HandlerArgs(this.OnClickXiaZhu, item))
        else
            item = allBetStateItems[i]
        end
        if item ~= nil then
            --检查限制分数，取消点击事件
            this.CheckRestrict(item, xiaZhuStr[i], Restricts)
            --设置下注信息
            LogError("下注", xiaZhuStr[i], "底分", SDBRoomData.diFen)
            item.transform:Find("Text"):GetComponent("Text").text = xiaZhuStr[i] * SDBRoomData.diFen
            item.name = xiaZhuStr[i]
            UIUtil.SetActive(item.gameObject, true)
        end
    end

    this.ShowTuiZhu(tuiZhuStr, Restricts)
end

--显示推注信息
function SDBOperationCtrl.ShowTuiZhu(tuiZhuStr, Restricts)
    for i = 1, #tuiZhuStr do
        local item
        if tuiZhuItem[i] == nil then
            item = CreateGO(mSelf.panel.pushNoitItem.gameObject, mSelf.panel.BetState, i)
            item.transform.localPosition = Vector3.New(item.transform.localPosition.x, item.transform.localPosition.y, 0)
            tuiZhuItem[i] = item
            this:AddOnClick(item, HandlerArgs(this.OnClickXiaZhu, item))
        else
            item = tuiZhuItem[i]
        end

        if item ~= nil then
            --设置下注信息
            --检查限制分数，取消点击事件
            this.CheckRestrict(item, tuiZhuStr[i], Restricts)
            item.transform:Find("Text"):GetComponent("Text").text = tuiZhuStr[i] * SDBRoomData.diFen
            item.name = tuiZhuStr[i]
            UIUtil.SetActive(item.gameObject, true)
        end
    end
end

--检查是否时被限制的分数
function SDBOperationCtrl.CheckRestrict(item, betScore, Restricts)
    if Restricts == nil or item == nil or betScore == nil then
        return
    end
    for i = 1, #Restricts do
        if tonumber(Restricts[i]) == tonumber(betScore) then
            item:GetComponent("Button").interactable = false
            return
        end
    end
    item:GetComponent("Button").interactable = true
end

--隐藏下注按钮
function SDBOperationCtrl.HideBetState()
    if mSelf == nil then
        LogError("<<<<<<<<<<<<             SDBOperationCtrl.HideBetState  mself is nil")
        return
    end
    mSelf.panel.SetBetState(false)
end

--显示操作面板
function SDBOperationCtrl.Show()
    if mSelf.gameObject == nil then
        return
    end
    UIUtil.SetActive(mSelf.gameObject, true)
end

--点击下注
function SDBOperationCtrl.OnClickXiaZhu(item)
    if SDBRoomData.isPlayback then
        return
    end
    OnClicktime = Time.realtimeSinceStartup
    SDBApiExtend.SendBetState(tonumber(item.name))
end

-- 点击要
function SDBOperationCtrl.OnClickGetCardsBtn(go)
    if SDBRoomData.isPlayback then
        return
    end
    local time = Time.realtimeSinceStartup - OnClicktime
    if SDBRoomAnimator.IsOnClick() and time > 0.8 then
        OnClicktime = 0
        --发送要牌行为
        SDBRoomData.isGetCard = false
        SDBApiExtend.SendGetCard(SDBOperationCardType.GetCard)
    end
end

--点击不要
function SDBOperationCtrl.OnClickDoneButton(go)
    if SDBRoomData.isPlayback then
        return
    end
    local time = Time.realtimeSinceStartup - OnClicktime
    if SDBRoomAnimator.IsOnClick() and time > 0.8 then
        OnClicktime = 0
        --发送不要行为
        SDBRoomData.isGetCard = false
        SDBApiExtend.SendGetCard(SDBOperationCardType.NoGet)
    end
end

--重置操作界面
function SDBOperationCtrl.ResetOperation()
    if mSelf == nil then
        return
    end
    this.HideBetState()
    this.HideRobZhuangReslult()
    OnClicktime = 0
end

--小局重置
function SDBOperationCtrl.Reset()
    --关闭比牌
    SDBOperationPanel.HideCompareCardTongSha()
    OnClicktime = 0
end

function SDBOperationCtrl:OnDestroy()
    allBetStateItems = {}
    tuiZhuItem = {}
    curCards = nil
    mSelf = nil
    isInitied = false
    OnClicktime = 0
end

return SDBOperationCtrl