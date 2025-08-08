-------------名字------------
CheckInPanel = ClassPanel("CheckInPanel")
CheckInPanel.Instance = nil


CheckInAwardTypeName = {
    [PropType.FangKa] = "钻石",
    [PropType.Gold] = "元宝",
    [PropType.Gift] = "礼券",
-- [CheckInAwardType.Kuang] = "头像框"
}

CheckInConfig = {
    [1] = {
        type = PropType.Gold,
        count = 50
    },
    [2] = {
        type = PropType.Gold,
        count = 60
    },
    [3] = {
        type = PropType.Gold,
        count = 70
    },
    [4] = {
        type = PropType.Gold,
        count = 80
    },
    [5] = {
        type = PropType.Gold,
        count = 90
    },
    [6] = {
        type = PropType.Gold,
        count = 100
    },
    [7] = {
        type = PropType.Gold,
        count = 200
    }
}

--最低分享时间（毫秒）
local shareMinTime = 1 * 1000

--签到领取天数
local AcceptNumbers = {[2] = 1, [5] = 2, [7] = 3 }
-----------------------------
--是否签到过
local isSign = false
--累计签到天数
local signCount = 0
--当前签到天数
local curSignCount = 0
--礼物items
local giftItems = {}

local this = nil
function CheckInPanel:OnInitUI()
    this = self
    self:IninUI()
    self:InitPanelValue()
    self:AddMsg()
end

function CheckInPanel:IninUI()
    local content = self.transform:Find("Content")
    self.signContent = content
    self.closeBtn = content:Find("Background/CloseButton")
    local tContent = content:Find("Content")

    self.days = {}
    for i = 1, 7 do
        self.days[i] = {}
        self.days[i].transform = tContent:Find("Days/" .. i)
        self.days[i].gameObject = self.days[i].transform.gameObject
        self.days[i].selectGO = self.days[i].transform:Find("Selected")
        self.days[i].coinGO = self.days[i].transform:Find("Coin").gameObject
        self.days[i].countText = self.days[i].transform:Find("Count"):GetComponent(TypeText)
        self.days[i].isReceiveGO = self.days[i].transform:Find("IsReceive")
    end

    self.awards = {}
    for i = 1, 3 do
        self.awards[i] = {}
        self.awards[i].transform = tContent:Find("Bottom/Award/" .. i)
        local item = self.awards[i].transform
        self.awards[i].bgBtnGO = item:Find("Bg").gameObject
        self.awards[i].lightGO = item:Find("Light").gameObject
        self.awards[i].isReceiveGO = item:Find("IsReceive")
        self.awards[i].awardName = item:Find("AwardName"):GetComponent(TypeText)
        self.awards[i].maskGO = item:Find("Mask")
    end

    self.checkInBtn = tContent:Find("CheckInBtn")
    self.checkInedBtnName = self.checkInBtn:Find("CheckIned")
    self.checkInBtnName = self.checkInBtn:Find("CheckIn")

    self.accumulatedCountText = tContent:Find("RightBottom/Bubble/Text"):GetComponent(TypeText)


    --===========================   ShareContent
    self.shareSignIn = self.transform:Find("ShareSignIn")
    self.closeShareBtn = self.shareSignIn:Find("Background/CloseBtn")
    self.weChatText = self.shareSignIn:Find("Content/WeChatText/Text"):GetComponent(TypeText)
    self.shareBtn = self.shareSignIn:Find("Content/ShareBtn")
    self.giftViwe = self.shareSignIn:Find("Content/GiftViwe")
    self.giftItem = self.giftViwe:Find("Item")
end

function CheckInPanel:AddMsg()
    self:AddOnClick(self.closeBtn, this.OnClickCloseBtn)
    self:AddOnClick(self.checkInBtn, this.OnClickCheckInBtn)

    self:AddOnClick(self.closeShareBtn, this.OnClickCloseShare)
    self:AddOnClick(self.shareBtn, this.OnClickShareBtn)
end

function CheckInPanel:AddEventMsg()
    AddMsg(CMD.Game.LogoutAndOpenLogin, this.OnLogoutAndOpenLogin)
    AddMsg(CMD.Game.ShareComplete, this.OnShareComplete)
    AddMsg(CMD.Tcp_S2C_GetSignIn, this.OnGetSignIn)
    AddMsg(CMD.Tcp_S2C_SignIn, this.OnSinIn)
    AddMsg(CMD.Game.Reauthentication, this.OnReauthentication)
end

function CheckInPanel:RemoveEventMsg()
    RemoveMsg(CMD.Game.LogoutAndOpenLogin, this.OnLogoutAndOpenLogin)
    RemoveMsg(CMD.Tcp_S2C_GetSignIn, this.OnGetSignIn)
    RemoveMsg(CMD.Tcp_S2C_SignIn, this.OnSinIn)
    RemoveMsg(CMD.Game.ShareComplete, this.OnShareComplete)
    RemoveMsg(CMD.Game.Reauthentication, this.OnReauthentication)
end

function CheckInPanel:OnOpened()
    this = self
    self:AddEventMsg()
    CheckInPanel.Instance = self
    BaseTcpApi.SendGetSignIn()

    UIUtil.SetActive(this.signContent, true)
    UIUtil.SetActive(this.shareSignIn, false)
    this.SetInfo()
end

function CheckInPanel:OnClosed()
    self:RemoveEventMsg()
    this.CloseAllGiftItems()
    this = nil
end

function CheckInPanel:OnDestroy()
    giftItems = {}
end

function CheckInPanel.Close()
    PanelManager.Destroy(PanelConfig.CheckIn, true)
end

function CheckInPanel.OnClickCloseShare()
    UIUtil.SetActive(this.signContent, true)
    UIUtil.SetActive(this.shareSignIn, false)
end
--初始化奖励
function CheckInPanel:InitPanelValue()
    --初始化上方签到奖励
    for i = 1, #CheckInConfig do
        local day = self.days[i]
        local config = CheckInConfig[i]
        day.countText.text = config.count
        Functions.SetPropIcon(day.coinGO, config.type, true)

    end
end

function CheckInPanel.OnClickCloseBtn()
    this.Close()
end

function CheckInPanel:OnClickCheckInBtn()
    if not isSign then
        UIUtil.SetActive(this.signContent, false)
        local gifts = {
            [1] = CheckInConfig[curSignCount + 1]
        }
        CheckInPanel.SetGiftsItem(gifts)
        UIUtil.SetActive(this.shareSignIn, true)
    else
        Toast.Show("今天已签到，请明天再来签到")
    end
end

--设置签到天奖励
function CheckInPanel:SetCheckInDays()
    local curDay = curSignCount + 1
    for i = 1, #self.days do
        UIUtil.SetActive(self.days[i].isReceiveGO, i < curDay)
        UIUtil.SetActive(self.days[i].selectGO, i == curDay and not isSign)
    end
end

--设置累计签到奖励
function CheckInPanel:SetAccumulatedCheckIn()
    for i = 1, 7 do
        if AcceptNumbers[i] ~= nil then
            UIUtil.SetActive(self.awards[AcceptNumbers[i]].isReceiveGO, i <= signCount)
            UIUtil.SetActive(self.awards[AcceptNumbers[i]].lightGO, false)
            UIUtil.SetActive(self.awards[AcceptNumbers[i]].maskGO, i > signCount)
        end
    end
end

--设置累计签到天数
function CheckInPanel:SetAccumulatedCheckInDaysCount()
    self.accumulatedCountText.text = signCount
end

--设置是否签到 1 签到过，0未签到
function CheckInPanel:SetIsSign()
    UIUtil.SetActive(this.checkInedBtnName, isSign)
    UIUtil.SetActive(this.checkInBtnName, not isSign)
end

function CheckInPanel.OnGetSignIn(arg)
    local data = arg.data
    if arg.code == 0 then
        curSignCount = data.current
        isSign = data.isSign == 1
        signCount = data.signCount
        this.SetInfo()
    end
end

function CheckInPanel.OnSinIn(arg)
    local data = arg.data
    if arg.code == 0 then
        isSign = data.isSign == 1
        curSignCount = data.current
        signCount = data.signCount
        this.SetInfo()
        Alert.Show("签到成功，奖励请到邮件领取")
    elseif arg.code == 18102 then
        Toast.Show("今天已签到，请明天再来签到")
    end

    UIUtil.SetActive(this.signContent, true)
    UIUtil.SetActive(this.shareSignIn, false)
end

function CheckInPanel.OnLogoutAndOpenLogin()
    --是否签到过
    isSign = false
    --签到天数
    signCount = 0
end

function CheckInPanel.OnShareComplete()
    local lastTime = GlobalData.lastShareTime
    if this == nil or lastTime == 0 then
        GlobalData.lastShareTime = 0
        return
    end
    local curTime = os.timems()
    if curTime - lastTime < shareMinTime then
        Toast.Show("分享失败")
        GlobalData.lastShareTime = 0
        return
    end
    local isConnected = Network.CheckNetworkIsConnected()
    Log(" Network.CheckNetworkIsConnected() = ", isConnected)
    if isConnected then
        BaseTcpApi.SendSignIn()
        GlobalData.lastShareTime = 0
    end
end

--重连
function CheckInPanel.OnReauthentication()
    this.OnShareComplete()
end

function CheckInPanel.SetInfo()
    this:SetCheckInDays()
    this:SetAccumulatedCheckIn()
    this:SetAccumulatedCheckInDaysCount()
    this:SetIsSign()
end

function CheckInPanel.SetGiftsItem(gifts)
    for i = 1, #gifts do
        if giftItems[i] == nil then
            local tab = {}
            tab.gameObject = CreateGO(this.giftItem, this.giftViwe, i)
            tab.transform = tab.gameObject.transform
            tab.coinGO = tab.transform:Find("Coin").gameObject
            tab.countText = tab.transform:Find("Count"):GetComponent(TypeText)
            table.insert(giftItems, tab)
        end
        local item = giftItems[i]
        Functions.SetPropIcon(item.coinGO, gifts[i].type, true)
        item.countText.text = gifts[i].count
        UIUtil.SetActive(item.gameObject, true)
    end
end

function CheckInPanel.CloseAllGiftItems()
    for i = 1, #giftItems do
        UIUtil.SetActive(giftItems[i].gameObject, false)
    end
end

--分享
function CheckInPanel.OnClickShareBtn()
    if IsEditorOrPcPlatform() then
        BaseTcpApi.SendSignIn()
    else
        local data = {
            platformType = PlatformType.WECHAT,
            shareSceneType = ShareSceneType.Timeline
        }
        this.Share(data)
    end
end

function CheckInPanel.Share(data)
    local guildId = UserData.GetGuildId()
    if guildId ~= 0 then
        Waiting.Show("准备签到...")
        BaseResourcesMgr.GetShareImageByFileName(guildId, HandlerByStaticArg2(data, this.OnGetGuildCodeImage))
    else
        BaseResourcesMgr.GetShareImage(HandlerByStaticArg1(data, this.GetShareImageCallback))
    end
end

function CheckInPanel.OnGetGuildCodeImage(data, code, path)
    if code == 0 then
        GlobalData.lastShareTime = os.timems()
        PlatformHelper.Share(data.platformType, data.shareSceneType, "", "", path, "", "")
    else
        Alert.Show("签到失败，请稍后重试")
    end
end

function CheckInPanel.GetShareImageCallback(data, path)
    GlobalData.lastShareTime = os.timems()
    PlatformHelper.Share(data.platformType, data.shareSceneType, "", "", path, "")
end