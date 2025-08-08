--输入
InputBtnIem = {
    --最小值
    min = 0,
    --最大值
    max = 1,
    --步数
    step = 1,
    --默认值
    default = 0,
    --当前值
    value = 0,
    --显示后缀
    suffix = nil,
    --
    interactable = true,
    --
    onValueChanged = nil,
}

local meta = { __index = InputBtnIem }

function InputBtnIem.New()
    local o = {}
    setmetatable(o, meta)
    return o
end

function InputBtnIem:Init(gameObject)
    self.gameObject = gameObject
    self.transform = gameObject.transform
    local input = self.transform:Find("Label/Input")
    self.label = self.transform:Find("Label"):GetComponent(TypeText)
    self.valueLabel = input:Find("Text"):GetComponent(TypeText)
    self.subGo = input:Find("Sub").gameObject
    self.addGo = input:Find("Add").gameObject
    self.toggle = gameObject:GetComponent(TypeToggle)

    EventUtil.AddOnClick(self.subGo, function() self:OnSubClick() end)
    EventUtil.AddOnClick(self.addGo, function() self:OnAddClick() end)
end

function InputBtnIem:OnSubClick()
    local temp = self.value - self.step
    if temp >= self.min then
        self.value = temp
        self:UpdateValueDisplay()
    end
end

function InputBtnIem:OnAddClick()
    local temp = self.value + self.step
    if temp <= self.max then
        self.value = temp
        self:UpdateValueDisplay()
    end
end

--设置
function InputBtnIem:Set(min, max, step, default, suffix)
    self.min = min
    self.max = max
    self.step = step
    self.default = default
    self.suffix = suffix
end

--更新显示
function InputBtnIem:UpdateValueDisplay()
    if self.valueLabel ~= nil and self.lastValue ~= self.value then
        self.lastValue = self.value
        if self.suffix ~= nil then
            self.valueLabel.text = tostring(self.value) .. self.suffix
        else
            self.valueLabel.text = tostring(self.value)
        end
        if self.onValueChanged ~= nil and self.toggle.isOn then
            self.onValueChanged()
        end
    end
end

function InputBtnIem:SetValue(value)
    LogError(">> InputBtnIem:SetValue", value)
    self.value = value
    self:UpdateValueDisplay()
end
