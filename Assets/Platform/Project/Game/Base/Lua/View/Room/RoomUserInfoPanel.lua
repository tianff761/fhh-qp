RoomUserInfoPanel = ClassPanel("RoomUserInfoPanel")
local this = RoomUserInfoPanel
local mSelf
local userInfo = nil

--全屏发送时间
local fullSendPropTime = 5
--普通发送时间
local sendPropTime = 3

local lastSendTime = 0

--不免费道具收费元宝数量
local NoFreePropConfig = {
    [10001] = { name = "财神", price = 20, isFull = true },
    [10002] = { name = "加特林", price = 10 },
    [10003] = { name = "大炮", price = 10 },
}

--初始化面板--
function RoomUserInfoPanel:OnInitUI()
    mSelf = self
    self:InitPanel()
    self:AddOnClickMsg()
end

function RoomUserInfoPanel:InitPanel()
    self.closeBtn = self.transform:Find("Mask")
    self.closeBtn2 = self.transform:Find("Content/Background/CloseBtn")
    local content = self.transform:Find("Content/Content")
    self.headImage = content:Find("Head/Mask/Icon"):GetComponent("Image")

    self.nameText = content:Find("Name/Text"):GetComponent("Text")
    self.idText = content:Find("ID/Text"):GetComponent("Text")
    self.selfTipTra = content:Find("SelfTip")
    self.OtherTipTra = content:Find("OtherTip")
    self.coinTra = content:Find("Coin")
    self.coinText = content:Find("Coin/CountText"):GetComponent("Text")

    self.propBottomTra = content:Find("Prop/Bottom")
    self.propBottomScroll = self.propBottomTra:GetComponent("ScrollRect")
    self.propBottomContent = self.propBottomTra:Find("Viewport/Content")

    self.propTopTra = content:Find("Prop/Top")
    self.propTopScroll = self.propTopTra:GetComponent("ScrollRect")
    self.propTopContent = self.propTopTra:Find("Viewport/Content")

    self.sexTran = content:Find("Sex")
    self.female = self.sexTran:Find("Female")
    self.male = self.sexTran:Find("Male")

    self.shieldPropToggle = content:Find("ShieldProp")

    self.bottomProps = {}
    for i = 1001, 1008 do
        table.insert(self.bottomProps, self.propBottomContent:Find(i))
    end

    self.topProps = {}
    for k, v in pairs(PropsAnimationType) do
        table.insert(self.topProps, self.propTopContent:Find(k))
    end

    self.shieldPropToggle:GetComponent("Toggle").isOn = toboolean(GetLocal(CMD.Game.ShieldProp, false))
end

function RoomUserInfoPanel:AddOnClickMsg()
    for i = 1, #self.bottomProps do
        self:AddOnClick(self.bottomProps[i], HandlerArgs(this.OnClickProp, self.bottomProps[i].name))
    end

    for i = 1, #self.topProps do
        self:AddOnClick(self.topProps[i], HandlerArgs(this.OnClickNoFreeProp, self.topProps[i].name))
    end

    self:AddOnClick(self.closeBtn, function()
        self:Close()
    end)
    self:AddOnClick(self.closeBtn2, function()
        self:Close()
    end)

    self:AddOnToggle(self.shieldPropToggle, this.OnChangeToggleShieldProp)
end

function RoomUserInfoPanel.OnClickNoFreeProp(name)
    local id = tonumber(name)
    local sendTime = sendPropTime
    if NoFreePropConfig[id].isFull then
        sendTime = fullSendPropTime
    end

    local time = os.time()
    if time - lastSendTime > sendTime then
        local limitScore = userInfo.limitScore
        if limitScore == nil then
            limitScore = 0
        end
        local num = UserData.GetGold() - limitScore
        local price = NoFreePropConfig[id].price
        if num < 0 then
            num = 0
        end
        if num < price then
            Alert.Show("本次消耗" .. price .. "元宝\r\n您的元宝数量为:" .. num .. "，无法购买该道具")
        else
            local name = NoFreePropConfig[id].name

            local count = ChatModule.GetPlayerInfoCount()
            --当前房间内人数为一，只有自己。而且是高级道具，并且高级道具不是全屏的，那么就拦截掉
            if count <= 1 and PropsAnimationType[id] ~= nil and not PropsAnimationType[id].isFull then
                Toast.Show("未有选中对象，无法发送该道具")
                return
            end

            Alert.Prompt("购买" .. name .. "需要" .. price .. "元宝", HandlerArgs(this.SendProp, id))
        end

    else
        Toast.Show("请不要频繁操作")
    end
end


--点击道具
function RoomUserInfoPanel.OnClickProp(name)
    local count = ChatModule.GetPlayerInfoCount()
    if count <= 1 then
        Toast.Show("未有选中对象，无法发送该道具")
        return
    end
    local time = os.time()
    if time - lastSendTime > sendPropTime then
        this.SendProp(name)
    else
        Toast.Show("请不要频繁操作")
    end
end

function RoomUserInfoPanel.SendProp(name)
    lastSendTime = os.time()
    ChatModule.SendFreePropChatData(tonumber(name), userInfo.id)
    mSelf:Close()
end

--[[    arg = {
        name = "", --姓名
        sex = "", --性别 1男 2 女
        id = 0, --玩家id
        gold = 0, --元宝数量
        moneyType = 0, --货币类型
        limitScore = 0,--元宝场准入分数
        headUrl = "", --头像链接
        headFrame = "", --头像框
    }
]]
function RoomUserInfoPanel:OnOpened(arg)
    userInfo = arg
    self:InitUserInfoUI()
end

function RoomUserInfoPanel:InitUserInfoUI()
    if userInfo == nil then
        LogError(">>>>>>> RoomUserInfoPanel > InitUserInfoUI > userInfo is nil")
        return
    end

    self.nameText.text = userInfo.name --SubStringName(userInfo.name)
    self.idText.text = Functions.GetUserIdString(userInfo.id)
    local surplusGold = userInfo.gold
    LogError("surplusGold", surplusGold)
    if tonumber(surplusGold) < 0 then
        surplusGold = 0
    end

    self.coinText.text = tostring(surplusGold)
    Functions.SetHeadImage(self.headImage, Functions.CheckJoinPlayerHeadUrl(userInfo.headUrl))

    -- Functions.SetHeadFrame(self.headFrame, userInfo.headFrame)
    UIUtil.SetActive(self.male, userInfo.sex == Global.GenderType.Male)
    UIUtil.SetActive(self.female, userInfo.sex == Global.GenderType.Female)

    -- UIUtil.SetActive(self.selfTipTra, userInfo.id == UserData.GetUserId())
    -- UIUtil.SetActive(self.OtherTipTra, userInfo.id ~= UserData.GetUserId())
    UIUtil.SetActive(self.selfTipTra, false)
    UIUtil.SetActive(self.OtherTipTra, false)

    for i = 1, #self.topProps do
        local num = tonumber(self.topProps[i].name)
        -- if PropsAnimationType[num].isSingle and userInfo.id == UserData.GetUserId() then
        --     UIUtil.SetActive(self.topProps[i], false)
        -- else
        UIUtil.SetActive(self.topProps[i], true)
        -- end
        if NoFreePropConfig[num] ~= nil then
            local price = NoFreePropConfig[num].price
            if price ~= nil then
                self.topProps[i].transform:Find("PriceText"):GetComponent("Text").text = "x" .. price
            end
        end
    end
end

function RoomUserInfoPanel.OnChangeToggleShieldProp(isBool)
    SendEvent(CMD.Game.ShieldProp, isBool)
    SetLocal(CMD.Game.ShieldProp, isBool)
end

function RoomUserInfoPanel:OnClosed()

end

function RoomUserInfoPanel:OnDestroy()
    mSelf = nil
end