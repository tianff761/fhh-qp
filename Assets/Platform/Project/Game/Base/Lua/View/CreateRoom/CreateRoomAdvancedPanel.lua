CreateRoomAdvancedPanel = ClassPanel("CreateRoomAdvancedPanel")
local this = CreateRoomAdvancedPanel

function CreateRoomAdvancedPanel:OnInitUI()
    this = self

    local content = this:Find("Content/Content")
    this.content = content
    this.newContent = this:Find("Content/NewContent")

    this.diFenDropdown = content:Find("Dropdown"):GetComponent(TypeDropdown)
    this.baoDinput = content:Find("BaoDiInput"):GetComponent(TypeInputField)
    this.minInput = content:Find("MinInput"):GetComponent(TypeInputField)
    this.kickInput = content:Find("KickInput"):GetComponent(TypeInputField)
    this.noteInput = content:Find("NoteInput"):GetComponent(TypeInputField)
    this.OldKeepBaseSymbol = content:Find("BaoDiInput/KeepBaseSymbol")
    this.OldKeepBaseDropdown = content:Find("BaoDiInput/KeepBaseDropdown"):GetComponent(TypeDropdown)

    this.base = this.newContent:Find("BaseScore").gameObject
    this.enterLimit = this.newContent:Find("EnterLimit")
    this.kickLimit = this.newContent:Find("KickLimit")
    this.BaseDropdown = this.newContent:Find("BaseScore/Dropdown"):GetComponent(TypeDropdown)
    this.EnterInput = this.newContent:Find("EnterLimit/EnterInput"):GetComponent(TypeInputField)
    this.KickInput = this.newContent:Find("KickLimit/KickInput"):GetComponent(TypeInputField)
    this.RemarkInput = this.newContent:Find("Remark/RemarkInput"):GetComponent(TypeInputField)
    this.AllToggle = this.newContent:Find("GiveTypeLabel/AllToggle"):GetComponent(TypeToggle)
    this.BigToggle = this.newContent:Find("GiveTypeLabel/BigToggle"):GetComponent(TypeToggle)
    this.BigToggleLabel = this.newContent:Find("GiveTypeLabel/BigToggle/Label"):GetComponent(TypeText)

    --分配规则，捞腌菜才显示
    this.FaceTypeImg = this.newContent:Find("FaceTypeImg").gameObject
    this.FaceTypeLabel = this.newContent:Find("FaceTypeLabel").gameObject
    this.FaceAllToggle = this.newContent:Find("FaceTypeLabel/FaceAllToggle"):GetComponent(TypeToggle)
    this.FaceWinToggle = this.newContent:Find("FaceTypeLabel/FaceWinToggle"):GetComponent(TypeToggle)

    this.ExpressionInput = this.newContent:Find("Expression/ExpressionInput"):GetComponent(TypeInputField)
    this.KeepBaseInput = this.newContent:Find("KeepBase/KeepBaseInput"):GetComponent(TypeInputField)
    this.KeepBaseSymbol = this.newContent:Find("KeepBase/KeepBaseSymbol")
    this.KeepBaseDropdown = this.newContent:Find("KeepBase/KeepBaseDropdown"):GetComponent(TypeDropdown)
    this.RobLimitTrans = this.newContent:Find("RobLimit")
    this.RobLimitInput = this.newContent:Find("RobLimit/RobInput"):GetComponent(TypeInputField)

    local layout = content:Find("Layout")
    this.inputWins = {}
    this.inputCosts = {}
    for i = 1, 5 do
        table.insert(this.inputWins, layout:Find(tostring(i)):GetComponent(TypeInputField))
    end
    for i = 1, 4 do
        table.insert(this.inputCosts, layout:Find("Line" .. i .. "/Input"):GetComponent(TypeInputField))
    end

    this.okBtn = content:Find("OkButton").gameObject
    this.newConfirmBtn = this.newContent:Find("ConfirmBtn").gameObject
    this.closeBtn = this:Find("Content/Background/CloseBtn").gameObject

    this.AddUIListenerEvent()
end

function CreateRoomAdvancedPanel:OnOpened(data, diFenList, diFenNameList, openByGameType, gameType)
    LogError("高级设置data", data)
    --LogError("高级设置diFenList", diFenList)
    --LogError("高级设置diFenNameList", diFenNameList)
    --LogError("高级设置isNewLayout", isNewLayout)
    this.openByGameType = openByGameType
    if openByGameType == GameType.TP then
        UIUtil.SetActive(this.base, false)
        UIUtil.SetAnchoredPosition(this.enterLimit.gameObject, 200, 195)
        UIUtil.SetAnchoredPosition(this.kickLimit.gameObject, 530, 195)
    end
    
    if openByGameType == GameType.LYC then
        this.BigToggleLabel.text = "所有玩家"
    else
        this.BigToggleLabel.text = "大赢家"
    end
    UIUtil.SetActive(this.FaceTypeImg, openByGameType == GameType.LYC)
    UIUtil.SetActive(this.FaceTypeLabel, openByGameType == GameType.LYC)
    UIUtil.SetActive(this.content, openByGameType == nil)
    UIUtil.SetActive(this.newContent, openByGameType ~= nil)
    this.InitPin5AdvancePanel(data, openByGameType)
    --this.InitPin3AdvancePanel(data, openByGameType)

    this.diFenList = diFenList
    this.diFenDropdown:ClearOptions()
    this.BaseDropdown:ClearOptions()
    if diFenNameList ~= nil then
        UIUtil.AddDropdownOptionsByString(this.diFenDropdown, diFenNameList)
        UIUtil.AddDropdownOptionsByString(this.BaseDropdown, diFenNameList)
    end
    local diFen = data and data.diFen or 0
    local diFenIndex = 0
    for i = 1, #diFenList do
        if diFenList[i] == diFen then
            diFenIndex = i - 1
            break
        end
    end
    this.diFenDropdown.value = diFenIndex
    --LogError("diFenIndex", diFenIndex)
    this.BaseDropdown.value = diFenIndex

    this:InitNewAdvancePanel(data, openByGameType)

    local winsTable = {}
    local costsTable = {}
    if data ~= nil then
        this.minInput.text = data.zhunRu or "0"
        this.kickInput.text = data.jieSanFenShu or "0"
        this.noteInput.text = data.note or ""
        this.baoDinput.text = data.baoDi or "0"
        this.OldKeepBaseDropdown.value = data.bdPer or 0
        if not string.IsNullOrEmpty(data.wins) then
            local temp = string.split(data.wins, "|")
            for i = 1, #temp do
                local temp2 = string.split(temp[i], ",")
                if #temp2 > 1 then
                    if i == 1 then
                        table.insert(winsTable, temp2[1])
                        table.insert(winsTable, temp2[2])
                    else
                        table.insert(winsTable, temp2[2])
                    end
                end
            end
        end

        if not string.IsNullOrEmpty(data.costs) then
            costsTable = string.split(data.costs, "|")
        end
    else
        this.minInput.text = "0"
        this.kickInput.text = "0"
        this.noteInput.text = ""
        this.baoDinput.text = "0"
    end

    local length = #winsTable
    if length > #this.inputWins then
        length = #this.inputWins
    end
    for i = 1, length do
        this.inputWins[i].text = winsTable[i]
    end
    for i = length + 1, #this.inputWins do
        this.inputWins[i].text = ""
    end

    length = #costsTable
    if length > #this.inputCosts then
        length = #this.inputCosts
    end
    for i = 1, length do
        this.inputCosts[i].text = costsTable[i]
    end
    for i = length + 1, #this.inputCosts do
        this.inputCosts[i].text = ""
    end
end

function CreateRoomAdvancedPanel:InitNewAdvancePanel(data, openByGameType)
    if data then
        LogError("初始化")
        this.EnterInput.text = data.enterNum
        this.KickInput.text = data.kickNum
        this.RemarkInput.text = data.remarkStr
        this.ExpressionInput.text = data.expressionNum
        this.KeepBaseInput.text = data.keepBaseNum
        this.AllToggle.isOn = data.allToggle
        this.BigToggle.isOn = not data.allToggle
        this.KeepBaseDropdown.value = data.bdPer or 0
        if openByGameType == GameType.LYC then
            this.FaceAllToggle.isOn = data.faceAllToggle
            this.FaceWinToggle.isOn = not data.faceAllToggle
        end
        -- this.KeepBaseDropdown.value = data.bdPer or 0
    end
end

function CreateRoomAdvancedPanel.InitPin5AdvancePanel(data, openByGameType)
    this.IsPin5 = openByGameType == GameType.Pin5
    LogError("this.IsPin5", this.IsPin5)
    UIUtil.SetActive(this.RobLimitTrans, this.IsPin5)
    if this.IsPin5 and data then
        this.RobLimitInput.text = data.robNum
    end
end

---已弃用
function CreateRoomAdvancedPanel.InitPin3AdvancePanel(_, openByGameType)
    this.IsPin3 = openByGameType == GameType.Pin3
    LogError("this.IsPin5", this.IsPin3)
    UIUtil.SetActive(this.KeepBaseSymbol, this.IsPin3)
end

function CreateRoomAdvancedPanel:OnClosed()
    this.minInput.text = "0"
    this.kickInput.text = "0"
    this.noteInput.text = ""
    this.baoDinput.text = "0"
    for i = 1, #this.inputWins do
        this.inputWins[i].text = ""
    end
    for i = 1, #this.inputCosts do
        this.inputCosts[i].text = ""
    end
    this.EnterInput.text = "0"
    this.KickInput.text = "0"
    this.RemarkInput.text = "0"
    this.ExpressionInput.text = "0"
    this.KeepBaseInput.text = "0"

    this.diFenDropdown:ClearOptions()
    this.BaseDropdown:ClearOptions()
end

------------------------------------------------------------------
--
--注册事件
function CreateRoomAdvancedPanel.AddListenerEvent()

end

--移除事件
function CreateRoomAdvancedPanel.RemoveListenerEvent()

end

--UI相关事件
function CreateRoomAdvancedPanel.AddUIListenerEvent()
    this:AddOnClick(this.okBtn, this.OnOkBtnClick)
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.newConfirmBtn, this.OnNewConfirmBtnClick)
    this:AddOnDropdown(this.OldKeepBaseDropdown, this.OnOldKeepBaseDropdownValueChanged)
    this:AddOnDropdown(this.KeepBaseDropdown, this.OnKeepBaseDropdownValueChanged)
end

--================================================================
--
--关闭
function CreateRoomAdvancedPanel.Close()
    PanelManager.Destroy(PanelConfig.CreateRoomAdvanced)
end


--================================================================
--
function CreateRoomAdvancedPanel.OnOkBtnClick()
    local min = this.GetInputNumber(this.minInput)
    if min == nil then
        Toast.Show("请输入正确的进房最低积分")
        return
    end

    local baoDi = this.GetInputNumber(this.baoDinput)
    if baoDi == nil then
        Toast.Show("请输入正确的保底分数")
        return
    end

    local kick = this.GetInputNumber(this.kickInput)
    if kick == nil then
        Toast.Show("请输入正确的踢出分数")
        return
    end
    local note = this.noteInput.text
    if string.IsNullOrEmpty(note) then
        Toast.Show("请输入分组备注名")
        return
    end
    local wins = ""
    local temp = 0
    local temp2 = 0
    for i = 2, #this.inputWins do
        temp = this.GetInputNumber(this.inputWins[i - 1])
        temp2 = this.GetInputNumber(this.inputWins[i])
        if temp == nil or temp2 == nil or temp < 0 then
            break
        end
        if temp >= temp2 then
            break
        end
        if i > 2 then
            wins = wins .. "|"
        end
        wins = wins .. temp .. "," .. temp2
    end
    if string.IsNullOrEmpty(wins) then
        Toast.Show("请输入最少一项大赢家得分区间")
        return
    end

    local costs = ""
    for i = 1, #this.inputCosts do
        temp = this.GetInputNumber(this.inputCosts[i])
        if temp == nil or temp < 0 then
            break
        end
        if i > 1 then
            costs = costs .. "|"
        end
        costs = costs .. temp
    end
    if string.IsNullOrEmpty(costs) then
        Toast.Show("请输入最少一项表情赠送")
        return
    end

    local diFen = this.diFenList[this.diFenDropdown.value + 1]
    if diFen == nil then
        diFen = 0
    end

    local data = {}
    data.diFen = diFen
    data.zhunRu = min
    data.jieSanFenShu = kick
    data.note = note
    data.wins = wins
    data.costs = costs
    data.baoDi = baoDi
    data.bdPer = this.OldKeepBaseDropdown.value
    --LogError(data)
    SendEvent(CMD.Game.UpdateCreateRoomAdvanced, data)
    this.Close()
end

function CreateRoomAdvancedPanel.OnNewConfirmBtnClick()
    local enterNum = this.CheckNumInputField(this.EnterInput, "请输入正确的进房最低积分")
    local kickNum = this.CheckNumInputField(this.KickInput, "请输入正确的进房最低积分")
    local remarkStr = this.CheckStrInputFiled(this.RemarkInput, "请输入分组备注名")
    local expressionNum = this.CheckNumInputField(this.ExpressionInput, "请输入表情比例")
    local keepBaseNum = this.CheckNumInputField(this.KeepBaseInput, "请输入保底")
    local keepBaseType = this.KeepBaseDropdown.value
    local checkResult = enterNum and kickNum and remarkStr and expressionNum and keepBaseNum
    local RobLimitNum
    if this.IsPin5 then
        RobLimitNum = this.CheckNumInputField(this.RobLimitInput, "请输入抢庄最低积分")
        checkResult = checkResult and RobLimitNum
    end
    if checkResult then
        local data = {}
        data.diFen = this.diFenList[this.BaseDropdown.value + 1]
        data.enterNum = enterNum
        data.kickNum = kickNum
        data.remarkStr = remarkStr
        data.expressionNum = expressionNum
        data.keepBaseNum = keepBaseNum
        data.allToggle = this.AllToggle.isOn
        data.bdPer = keepBaseType
        if this.IsPin5 then
            data.robNum = RobLimitNum
        end
        if this.openByGameType == GameType.LYC then
            data.faceAllToggle = this.FaceAllToggle.isOn
        end

        LogError(data)
        SendEvent(CMD.Game.UpdateNewCreateRoomAdvanced, data)
        this.Close()
    end
end

function CreateRoomAdvancedPanel.CheckNumInputField(InputField, showTip)
    local inputNum = this.GetInputNumber(InputField)
    if inputNum == nil then
        Toast.Show(showTip)
        return false
    end
    return inputNum
end

function CreateRoomAdvancedPanel.CheckStrInputFiled(InputField, showTip)
    local str = InputField.text
    if string.IsNullOrEmpty(str) then
        Toast.Show(showTip)
        return
    end
    return str
end

function CreateRoomAdvancedPanel.OnCloseBtnClick()
    this.Close()
end

--
function CreateRoomAdvancedPanel.GetInputNumber(input)
    local temp = input.text
    if string.IsNullOrEmpty(temp) then
        return nil
    end
    temp = tonumber(temp)
    if temp == nil then
        return nil
    end
    return temp
end

function CreateRoomAdvancedPanel.OnOldKeepBaseDropdownValueChanged(value)
    if value == 0 then
        UIUtil.SetText(this.OldKeepBaseSymbol, "分")
    else
        UIUtil.SetText(this.OldKeepBaseSymbol, "%")
    end
end

function CreateRoomAdvancedPanel.OnKeepBaseDropdownValueChanged(value)
    if value == 0 then
        UIUtil.SetText(this.KeepBaseSymbol, "分")
    else
        UIUtil.SetText(this.KeepBaseSymbol, "%")
    end
end

