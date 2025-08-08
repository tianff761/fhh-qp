UnionInputNumberPanel = ClassPanel("UnionInputNumberPanel")

local this = UnionInputNumberPanel
local InputMax = 6

--UI初始化
function UnionInputNumberPanel:OnInitUI()
    this = self
    this.btnItems = {}
    this.inputItems = {}
    this.index = 0

    this.closeBtn = this:Find("Content/Background/CloseBtn").gameObject
    this.titleJoinUnion = this:Find("Content/Background/Title").gameObject
    this.titleAddPartner = this:Find("Content/Background/Title1").gameObject
    this.titleAddMember = this:Find("Content/Background/Title2").gameObject

    --给按钮添加点击事件
    local nodeTrans = this:Find("Content/Node")
    --按钮
    local btnsTrans = nodeTrans:Find("Btns")
    for i = 1, 9 do
        this.btnItems[i] = btnsTrans:Find(tostring(i)).gameObject
    end
    table.insert(this.btnItems, btnsTrans:Find("0").gameObject)
    table.insert(this.btnItems, btnsTrans:Find("ClearBtn").gameObject)
    table.insert(this.btnItems, btnsTrans:Find("DeleteBtn").gameObject)
    --输入
    local inputNumsTrans = nodeTrans:Find("InputNums")
    for i = 1, 6 do
        this.inputItems[i] = inputNumsTrans:Find("Item" .. tostring(i) .. "/Text"):GetComponent(TypeText)
    end
    this.AddUIListenerEvent()
end

function UnionInputNumberPanel:OnOpened(unionInputNumberPanelType, callback)
    this.type = unionInputNumberPanelType
    this.callback = callback
    this.AddListenerEvent()
    UIUtil.SetActive(this.titleJoinUnion, this.type == UnionInputNumberPanelType.JoinUnion)
    UIUtil.SetActive(this.titleAddPartner, this.type == UnionInputNumberPanelType.AddPartner)
    UIUtil.SetActive(this.titleAddMember, this.type == UnionInputNumberPanelType.AddMember)
    this.ClearNums()
end

function UnionInputNumberPanel:OnClosed()
    this.RemoveListenerEvent()
end

function UnionInputNumberPanel:OnHide()
    this.ClearNums()
end

--================================================================
--关闭
function UnionInputNumberPanel.Close()
    PanelManager.Destroy(PanelConfig.UnionInputNumber, true)
end

--
function UnionInputNumberPanel.AddListenerEvent()

end

--
function UnionInputNumberPanel.RemoveListenerEvent()

end

--UI相关事件
function UnionInputNumberPanel.AddUIListenerEvent()
    local length = this.btnItems
    for i = 1, #length do
        UIClickListener.Get(this.btnItems[i]).onClick = this.OnBtnClick
    end
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
end

--================================================================
--
function UnionInputNumberPanel.OnBtnClick(listener)
    Audio.PlayClickAudio()
    this.InputNumClick(listener.name)
end

function UnionInputNumberPanel:OnCloseBtnClick()
    this.Close()
end

--================================================================
function UnionInputNumberPanel.InputNumClick(name)
    if name == "ClearBtn" then
        this.ClearNums()
    elseif name == "DeleteBtn" then
        this.DeleteNum()
    else
        this.InputNum(name)
    end
end

function UnionInputNumberPanel.InputNum(name)
    if this.index < InputMax then
        this.index = this.index + 1
        this.inputItems[this.index].text = name
    end

    if this.index >= InputMax then
        local num = tonumber(this.GetInputNum())
        if this.callback ~= nil then
            this.callback(num)
        end
        this.ClearNums()
    end
end

function UnionInputNumberPanel.DeleteNum()
    if this.index > 0 and this.index <= InputMax then
        this.inputItems[this.index].text = ""
        this.index = this.index - 1
    end
end

function UnionInputNumberPanel.ClearNums()
    this.index = 0
    for i, txt in ipairs(this.inputItems) do
        txt.text = ""
    end
end

-- 返回string
function UnionInputNumberPanel.GetInputNum()
    local str = ""
    for i, txt in ipairs(this.inputItems) do
        str = str .. txt.text
    end
    return str
end
