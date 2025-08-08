ClubInputNumberPanel = ClassPanel("ClubInputNumberPanel")
ClubInputNumberPanel.maxLen = 0
ClubInputNumberPanel.callback = nil
ClubInputNumberPanel.gridLayout = nil
ClubInputNumberPanel.tempItem = nil
ClubInputNumberPanel.joinClubTitle = nil
ClubInputNumberPanel.addPartnerTitle = nil
ClubInputNumberPanel.addMemberTitle = nil

local totalWidth = 500
local height = 48
local this = ClubInputNumberPanel
--UI初始化
function ClubInputNumberPanel:OnInitUI()
    this = self
    this.btnItems = {}
    this.inputItems = {}
    this.index = 0

    this.closeBtn = self:Find("Content/Background/CloseButton")
    this.joinClubTitle = self:Find("Content/Background/JoinClubTitle")
    this.addPartnerTitle = self:Find("Content/Background/AddPartnerTitle")
    this.addMemberTitle = self:Find("Content/Background/AddMemberTitle")
    
    --给按钮添加点击事件
    local nodeTrans = self:Find("Content/Node")
    this.tempItem = nodeTrans:Find("Item").gameObject
    
    --按钮
    local btnsTrans = nodeTrans:Find("Btns")
    for i = 1, 9 do
        this.btnItems[i] = btnsTrans:Find(tostring(i)).gameObject
    end
    table.insert(this.btnItems, btnsTrans:Find("0").gameObject)
    table.insert(this.btnItems, btnsTrans:Find("ClearBtn").gameObject)
    table.insert(this.btnItems, btnsTrans:Find("DeleteBtn").gameObject)

    this.AddUIListenerEvent()
end

function ClubInputNumberPanel:OnOpened(unionInputNumberPanelType, callback)
    this.maxLen = unionInputNumberPanelType.maxNum
    this.callback = callback
    --输入
    this.inputItems = {}
    local inputNumsTrans = self:Find("Content/Node/InputNums")
    this.gridLayout = inputNumsTrans:GetComponent(TypeGridLayoutGroup)
    this.gridLayout.cellSize = Vector2((totalWidth - (this.maxLen - 1) * this.gridLayout.spacing.x) / this.maxLen, height)
    ClearChildren(inputNumsTrans)
    for i = 1, this.maxLen do
       this.inputItems[i] = NewObject(this.tempItem, inputNumsTrans).transform:Find("Text"):GetComponent(TypeText)
    end

    UIUtil.SetActive(this.joinClubTitle, unionInputNumberPanelType == ClubInputNumberPanelType.JoinClub)
    UIUtil.SetActive(this.addPartnerTitle, unionInputNumberPanelType == ClubInputNumberPanelType.AddPartner)
    UIUtil.SetActive(this.addMemberTitle, unionInputNumberPanelType == ClubInputNumberPanelType.AddMember)

    this.ClearNums()
    this.AddListenerEvent()
end

function ClubInputNumberPanel:OnClosed()
    this.RemoveListenerEvent()
    this.ClearNums()
end

--================================================================
--关闭
function ClubInputNumberPanel.Close()
    PanelManager.Destroy(PanelConfig.ClubInputNumber, true)
end

--
function ClubInputNumberPanel.AddListenerEvent()
    AddEventListener(CMD.Game.CleanClubInputNumberPanel, this.OnJoinRoomClear)
end
--
function ClubInputNumberPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Game.CleanClubInputNumberPanel, this.OnJoinRoomClear)
end

--UI相关事件
function ClubInputNumberPanel.AddUIListenerEvent()
    local length = this.btnItems
    for i = 1, #length do
        UIClickListener.Get(this.btnItems[i]).onClick = this.OnBtnClick
    end
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
end

--================================================================
function ClubInputNumberPanel.OnBtnClick(listener)
    Audio.PlayClickAudio()
    this.InputNumClick(listener.name)
end

function ClubInputNumberPanel:OnCloseBtnClick()
    this.Close()
end

function ClubInputNumberPanel.OnJoinRoomClear()
    this.ClearNums()
end

--================================================================
function ClubInputNumberPanel.InputNumClick(name)
    if name == "ClearBtn" then
        this.ClearNums()
    elseif name == "DeleteBtn" then
        this.DeleteNum()
    else
        this.InputNum(name)
    end
end

function ClubInputNumberPanel.InputNum(name)
    if this.index < this.maxLen then
        this.index = this.index + 1
        this.inputItems[this.index].text = name
    end

    if this.index >= this.maxLen then
        local num = tonumber(this.GetInputNum())
        Scheduler.scheduleOnceGlobal(function ()
            if this.callback ~= nil then
                this.callback(num)
            end
            this.ClearNums()
        end, 0.3)
    end
end

function ClubInputNumberPanel.DeleteNum()
    if this.index > 0 and this.index <= this.maxLen then
        this.inputItems[this.index].text = ""
        this.index = this.index - 1
    end
end

function ClubInputNumberPanel.ClearNums()
    this.index = 0
    for i, txt in ipairs(this.inputItems) do
        txt.text = ""
    end
end

-- 返回string
function ClubInputNumberPanel.GetInputNum()
    local str = ""
    for i, txt in ipairs(this.inputItems) do
        str = str .. txt.text
    end
    return str
end