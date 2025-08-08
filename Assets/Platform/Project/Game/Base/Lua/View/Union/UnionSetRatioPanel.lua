--设置比例
UnionSetRatioPanel = ClassPanel("UnionSetRatioPanel")
--调整的玩家Id
UnionSetRatioPanel.adjustUid = 0

local this = UnionSetRatioPanel
--
function UnionSetRatioPanel:Awake()
    this = self
    local content = this:Find("Content")
    this.closeBtn = content:Find("Background/CloseBtn")

    this.menuContent = content:Find("Menus/Viewport/Content")
    this.RatioToggle = this.menuContent:Find("RatioToggle")
    this.KeepBaseToggle = this.menuContent:Find("KeepBaseToggle")
    this.CordonToggle = this.menuContent:Find("CordonToggle")

    this.RatioContent = content:Find("RatioContent")
    this.okBtn = content:Find("RatioContent/OkBtn")
    this.input = content:Find("RatioContent/InputField"):GetComponent(TypeInputField)

    this.CordonContent = content:Find("CordonContent")
    this.okBtn1 = content:Find("CordonContent/OkBtn")
    this.maxLabel = content:Find("CordonContent/MaxText"):GetComponent(TypeText)
    this.inputField = content:Find("CordonContent/InputField"):GetComponent(TypeInputField)

    this.KeepBaseContent = content:Find("KeepBaseContent")
    local layout = this.KeepBaseContent:Find("Viewport/Content")
    this.Pin5 = layout:Find("Pin5")
    this.Pin3 = layout:Find("Pin3")
    this.Mahjong = layout:Find("Mahjong")
    this.PDK = layout:Find("PDK")
    this.LYC = layout:Find("LYC")
    this.Eqs = layout:Find("Eqs")

    this.Pin5AdjustBtn = layout:Find("Pin5/BtnGreen")
    this.Pin3AdjustBtn = layout:Find("Pin3/BtnGreen")
    this.MahjongAdjustBtn = layout:Find("Mahjong/BtnGreen")
    this.PDKAdjustBtn = layout:Find("PDK/BtnGreen")
    this.LYCAdjustBtn = layout:Find("LYC/BtnGreen")
    this.EqsAdjustBtn = layout:Find("Eqs/BtnGreen")

    this.Pin5Percent = layout:Find("Pin5/Label/KeepBase")
    this.Pin3Percent = layout:Find("Pin3/Label/KeepBase")
    this.MahjongPercent = layout:Find("Mahjong/Label/KeepBase")
    this.PDKPercent = layout:Find("PDK/Label/KeepBase")
    this.LYCPercent = layout:Find("LYC/Label/KeepBase")
    this.EqsPercent = layout:Find("Eqs/Label/KeepBase")

    this.PercentTable = {
        [GameType.Pin5] = { gameObject = this.Pin5, label = this.Pin5Percent, key = 0 },
        [GameType.Pin3] = { gameObject = this.Pin3, label = this.Pin3Percent, key = 0 },
        [GameType.Mahjong] = { gameObject = this.Mahjong, label = this.MahjongPercent, key = 0 },
        [GameType.PaoDeKuai] = { gameObject = this.PDK, label = this.PDKPercent, key = 0 },
        [GameType.LYC] = { gameObject = this.LYC, label = this.LYCPercent, key = 0 },
        [GameType.ErQiShi] = { gameObject = this.Eqs, label = this.EqsPercent, key = 0 },
    }

    this:AddOnToggle(this.RatioToggle, this.RatioToggleOnClick)
    this:AddOnToggle(this.KeepBaseToggle, this.KeepBaseToggleOnClick)
    this:AddOnToggle(this.CordonToggle, this.CordonToggleOnClick)

    this:AddOnClick(this.okBtn1, this.OnClickOkBtn)
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.okBtn, this.OnOkBtnClick)
    this:AddOnClick(this.Pin5AdjustBtn, this.OnPin5AdjustBtnClick)
    this:AddOnClick(this.Pin3AdjustBtn, this.OnPin3AdjustBtnClick)
    this:AddOnClick(this.MahjongAdjustBtn, this.OnMahjongAdjustBtnClick)
    this:AddOnClick(this.PDKAdjustBtn, this.OnPDKAdjustBtnClick)
    this:AddOnClick(this.LYCAdjustBtn, this.OnLYCAdjustBtnClick)
    this:AddOnClick(this.EqsAdjustBtn, this.OnEqsAdjustBtnClick)
end

function UnionSetRatioPanel:OnOpened(uid, ratio, args)
    this.AddEventListener()
    this.adjustUid = uid
    this.input.text = ratio
    UnionManager.SendRequestKeepBasePercent(this.adjustUid)

    this.pId = args.pId
    this.totalScore = math.ToRound(tonumber(args.totalScore), 2)
    this.warnScore = math.ToRound(args.warnScore, 2)

    this.inputField.text = args.warnScore
    this.maxLabel.text = args.totalScore

    UIUtil.SetActive(this.KeepBaseToggle.gameObject, UnionData.IsUnionLeader())
end

function UnionSetRatioPanel:OnClosed()
    this.RemoveEventListener()
end

--注册事件
function UnionSetRatioPanel.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_AdjustPartnerPercent, this.OnTcpAdjustPartnerPercent)
    AddEventListener(CMD.Tcp.Union.S2C_RequestKeepBasePercent, this.OnTcpRequestKeepBase)
    AddEventListener(CMD.Tcp.Union.S2C_AdjustKeepBasePercent, this.OnTcpAdjustKeepBase)
    AddEventListener(CMD.Tcp.Union.S2C_UNION_SET_WARRING_SCORE, this.OnSetWarringScore)

end

--移除事件
function UnionSetRatioPanel.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.Union.S2C_AdjustPartnerPercent, this.OnTcpAdjustPartnerPercent)
    RemoveEventListener(CMD.Tcp.Union.S2C_RequestKeepBasePercent, this.OnTcpRequestKeepBase)
    RemoveEventListener(CMD.Tcp.Union.S2C_AdjustKeepBasePercent, this.OnTcpAdjustKeepBase)
    RemoveEventListener(CMD.Tcp.Union.S2C_UNION_SET_WARRING_SCORE, this.OnSetWarringScore)

end

--================================================================
--
--关闭
function UnionSetRatioPanel.Close()
    PanelManager.Close(PanelConfig.UnionSetRatio)
end
--================================================================
--
function UnionSetRatioPanel.OnCloseBtnClick()
    this.Close()
end

function UnionSetRatioPanel.RatioToggleOnClick(isOn)
    if isOn then
        UIUtil.SetActive(this.RatioContent, true)
        UIUtil.SetActive(this.KeepBaseContent, false)
        UIUtil.SetActive(this.CordonContent, false)
    end
end

function UnionSetRatioPanel.KeepBaseToggleOnClick(isOn)
    if isOn then
        UIUtil.SetActive(this.RatioContent, false)
        UIUtil.SetActive(this.KeepBaseContent, true)
        UIUtil.SetActive(this.CordonContent, false)
    end
end

function UnionSetRatioPanel.CordonToggleOnClick(isOn)
    if isOn then
        UIUtil.SetActive(this.RatioContent, false)
        UIUtil.SetActive(this.KeepBaseContent, false)
        UIUtil.SetActive(this.CordonContent, true)
    end
end

function UnionSetRatioPanel.OnOkBtnClick()
    local value = tonumber(this.input.text)
    if IsNumber(value) then
        UnionManager.SendSetRatio(this.adjustUid, value)
    else
        Toast.Show("请输入正确的比例")
    end
end

function UnionSetRatioPanel.OnPin5AdjustBtnClick()
    this.OnGameAdjustBtnClick(GameType.Pin5)
end
function UnionSetRatioPanel.OnPin3AdjustBtnClick()
    this.OnGameAdjustBtnClick(GameType.Pin3)
end
function UnionSetRatioPanel.OnMahjongAdjustBtnClick()
    this.OnGameAdjustBtnClick(GameType.Mahjong)
end
function UnionSetRatioPanel.OnPDKAdjustBtnClick()
    this.OnGameAdjustBtnClick(GameType.PaoDeKuai)
end
function UnionSetRatioPanel.OnLYCAdjustBtnClick()
    this.OnGameAdjustBtnClick(GameType.LYC)
end
function UnionSetRatioPanel.OnEqsAdjustBtnClick()
    this.OnGameAdjustBtnClick(GameType.ErQiShi)
end
function UnionSetRatioPanel.OnGameAdjustBtnClick(gameId)
    PanelManager.Open(PanelConfig.UnionSetKeepBase, this.adjustUid, gameId, this.PercentTable[gameId].key)
end

--================================================================
--
--
function UnionSetRatioPanel.OnTcpAdjustPartnerPercent(data)
    if data.code == 0 then
        Toast.Show("比例调整成功")
        SendEvent(CMD.Game.UnionSetRatioRefresh)
        this.Close()
    else
        UnionManager.ShowError(data.code)
    end
end

function UnionSetRatioPanel.OnTcpRequestKeepBase(data)
    if data.code == 0 then
        local playerInfos = data.data.list
        for _, v in pairs(this.PercentTable) do
            UIUtil.SetActive(v.gameObject, false)
        end
        for i = 1, #playerInfos do
            local data = playerInfos[i]
            local item = this.PercentTable[data.gameId]
            if item ~= nil then
                UIUtil.SetActive(item.gameObject, true)
                item.key = data.per
                UIUtil.SetText(item.label, tostring(data.per))
            end
        end
    else
        UnionManager.ShowError(data.code)
    end
end

function UnionSetRatioPanel.OnTcpAdjustKeepBase(data)
    if data.code == 0 then
        UnionManager.SendRequestKeepBasePercent(this.adjustUid)
    else
        UnionManager.ShowError(data.code)
    end
end

function UnionSetRatioPanel.OnClickOkBtn()
    if this.pId == UserData.GetUserId() then
        this.Close()
        return
    end

    local value = tonumber(this.inputField.text)
    if value ~= nil then
        --if value > this.totalScore then
        --    Toast.Show("输入分数不能大于总分")
        --else
            UnionManager.SendSetWarringScore(this.pId, value)
        --end
    else
        Toast.Show("请输入正确的分数")
    end
end

--设置警戒线返回
function UnionSetRatioPanel.OnSetWarringScore(data)
    if data.code == 0 then
        Toast.Show("设置警戒线成功")
        SendEvent(CMD.Game.UnionSetWarnScoreRefresh)
        this.Close()
    else
        UnionManager.ShowError(data.code)
    end
end
