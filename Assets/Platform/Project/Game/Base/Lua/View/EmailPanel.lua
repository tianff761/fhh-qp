-------------名字------------
EmailPanel = ClassPanel("EmailPanel")
-----------------------------
local this = EmailPanel
EmailPanel.emailListContent = nil
EmailPanel.emailDetailContent = nil
EmailPanel.noEmailText = nil
EmailPanel.scrollExt = nil
EmailPanel.closeEmailPanelBtn = nil
EmailPanel.closeEmailDetailBtn = nil
EmailPanel.quickRemoveBtn = nil
EmailPanel.quickGetRewardBtn = nil
EmailPanel.getRewardBtn = nil
EmailPanel.removeEmailBtn = nil
EmailPanel.curGetPage = 0   --当前获取页码  从0开始

--邮件详细界面
EmailPanel.typeText = nil
EmailPanel.titleText = nil
EmailPanel.contentText = nil
EmailPanel.contentTitleText = nil
EmailPanel.rewardsTran = {}
EmailPanel.rewardsParent = nil

EmailPanel.curEmailId = 0
EmailPanel.curEmailList = nil

--type:1系统2后台3功能（签到，抽奖等）     status:0未读取 1已读取
--data:{"title":"toitle97","emailId":"10031342888733350","status":0,"time":"2019-02-20 18:37:22","notice":"notice97","type":1}
EmailPanel.emailInfos = {}      --{idx, emailInfo}
EmailPanel.countPerPage = 15
EmailPanel.totalDataCount = 0
function EmailPanel:OnInitUI()
    this = self
    this.emailListContent = this:Find("Content/EmailListContent")
    this.emailDetailContent = this:Find("Content/EmailDetailContent")

    this.noEmailText = this.emailListContent:Find("NoEmailText")
    this.scrollExt = this.emailListContent:Find("EmailScrollView"):GetComponent("ScrollRectExtension")

    this.closeEmailPanelBtn = this.emailListContent:Find("CloseEmailPanelBtn")
    this.closeEmailDetailBtn = this.emailDetailContent:Find("CloseEmailDetailBtn")

    this.quickGetRewardBtn = this.emailListContent:Find("QuickGetRewardsBtn")
    this.quickRemoveBtn = this.emailListContent:Find("QuickRemoveBtn")

    this.getRewardBtn = this.emailDetailContent:Find("GetRewardBtn")
    this.removeEmailBtn = this.emailDetailContent:Find("RemoveEmailBtn")

    this.typeText = this.emailDetailContent:Find("TypeText")
    this.titleText = this.emailDetailContent:Find("TitleText")
    this.contentText = this.emailDetailContent:Find("Content")
    this.contentTitleText = this.emailDetailContent:Find("ContentTile")

    this.rewardsParent = this.emailDetailContent:Find("RewardInfo")

    local rewards = this.emailDetailContent:Find("RewardInfo/Rewards")
    this.rewardsTran[1] = rewards:Find("Reward1")
    this.rewardsTran[2] = rewards:Find("Reward2")
    this.rewardsTran[3] = rewards:Find("Reward3")
end

function EmailPanel:OnOpened()
    this.AddUIEvent()
    this.AddNetEvent()
    this.InitScrollRect()
end

function EmailPanel:OnClosed()
    Log(">>>>>>>>>>>>>>>>>>>>>>>>      关闭面板")
    this.RemoveNetEvent()
end

function EmailPanel.Close()
    PanelManager.Destroy(PanelConfig.Email, true)
end

function EmailPanel.InitScrollRect()
    UIUtil.SetActive(this.emailDetailContent, false)
    UIUtil.SetActive(this.emailListContent, true)
    this.scrollExt:SetMaxDataCount(0)
    this.scrollExt:InitItems()
    this.scrollExt.onUpdateItemAction = this.OnUpdateItem
    this.scrollExt.onGetNextPageDataAction = this.SendGetEmailList
    this.scrollExt.onGetLastPageDataAction = function(page)
        this.curGetPage = page
    end
    this.SendGetEmailList(0)
end

--type:1系统2后台3签到4抽奖     status:0未读取 1已读取
--data:{"title":"toitle97","emailId":"10031342888733350","status":0,"time":"2019-02-20 18:37:22","notice":"notice97","type":1, "things":[]}
function EmailPanel.OnUpdateItem(item, idx)
    local data = this.emailInfos[idx + 1]
    local detailReaded = item:Find('ReadedInfo')
    local detaiDontRead = item:Find('DontReadInfo')
    local loadingTag = item:Find("LoadingTag")
    UIUtil.SetActive(detailReaded, false)
    UIUtil.SetActive(detaiDontRead, false)
    UIUtil.SetActive(loadingTag, false)

    if IsTable(data) then
        --取消已读状态
        data.status = 0
        UIUtil.SetActive(item, true)
        local targetTran = nil
        if data.status == 0 then
            targetTran = detaiDontRead
        elseif data.status == 1 then
            targetTran = detailReaded
        end
        if targetTran ~= nil then
            UIUtil.SetActive(targetTran, true)
            UIUtil.SetText(targetTran:Find("Title"), data.title)
            UIUtil.SetText(targetTran:Find("Data"), data.time)
        end
        this:AddOnClick(item, function()
            this.ShowEmailDetailInfo(data)
        end)
    else
        UIUtil.SetActive(loadingTag, true)
        Log("没有数据", item, idx, GetTableSize(this.emailInfos), this.emailInfos)
    end
end

function EmailPanel.AddUIEvent()
    this:AddOnClick(this.closeEmailPanelBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.closeEmailDetailBtn, this.HideEmailDetailInfo)
    this:AddOnClick(this.quickGetRewardBtn, this.OnQuickGetEmailsBtnClick)
    this:AddOnClick(this.quickRemoveBtn, this.OnQuickRemoveEmailsBtnClick)
    this:AddOnClick(this.getRewardBtn, this.OnGetEmailRewardBtnClick)
    this:AddOnClick(this.removeEmailBtn, this.OnRemoveEmailBtnClick)
end

function EmailPanel.AddNetEvent()
    AddEventListener(CMD.Tcp.S2C_GetEmailList, this.OnTcpGetEmailList)
    AddEventListener(CMD.Tcp.S2C_RemoveEmail, this.OnTcpRemoveEmail)
    AddEventListener(CMD.Tcp.S2C_GetEmailReward, this.OnTcpGetEmailReward)
end

function EmailPanel.RemoveNetEvent()
    RemoveEventListener(CMD.Tcp.S2C_GetEmailList, this.OnTcpGetEmailList)
    RemoveEventListener(CMD.Tcp.S2C_RemoveEmail, this.OnTcpRemoveEmail)
    RemoveEventListener(CMD.Tcp.S2C_GetEmailReward, this.OnTcpGetEmailReward)
end

--type:1系统2后台3签到4抽奖     status:0未读取 1已读取
--data:{"title":"toitle97","emailId":"10031342888733350","status":0,"time":"2019-02-20 18:37:22","notice":"notice97","type":1, "things":[{"2":4}]}
function EmailPanel.ShowEmailDetailInfo(data)
    UIUtil.SetActive(this.emailListContent, false)
    UIUtil.SetActive(this.emailDetailContent, true)
    this.curEmailId = data.emailId
    if data.type == 1 then
        UIUtil.SetText(this.typeText, "*系统邮件")
    elseif data.type == 2 then
        UIUtil.SetText(this.typeText, "*后台赠送")
    elseif data.type == 3 then
        UIUtil.SetText(this.typeText, "*签到奖励")
    elseif data.type == 4 then
        UIUtil.SetText(this.typeText, "*抽奖奖励")
    end

    UIUtil.SetText(this.titleText, data.title)
    UIUtil.SetText(this.contentText, "　　" .. data.notice)
    UIUtil.SetText(this.contentTitleText, "亲爱的玩家" .. UserData.GetName() .. "：")
    local listRewards = data.things
    for k, item in pairs(this.rewardsTran) do
        UIUtil.SetActive(item, false)
    end
    --有道具
    if GetTableSize(listRewards) > 0 then
        --设置按钮及事件
        UIUtil.SetActive(this.getRewardBtn, true)
        UIUtil.SetActive(this.removeEmailBtn, false)
        UIUtil.SetActive(this.rewardsParent, true)
        --设置道具显示
        for idx, reward in pairs(listRewards) do
            local tran = this.rewardsTran[idx]
            if tran ~= nil then
                UIUtil.SetActive(tran.parent, true)
                UIUtil.SetActive(tran, true)
                for propType, num in pairs(reward) do
                    Functions.SetPropIcon(tran:Find("Icon"), propType, true)
                    UIUtil.SetText(tran:Find("Num"), "x" .. tostring(num))
                end
            end
        end
    else
        UIUtil.SetActive(this.rewardsParent, false)
        UIUtil.SetActive(this.getRewardBtn, false)
        UIUtil.SetActive(this.removeEmailBtn, true)
    end
end

function EmailPanel.HideEmailDetailInfo()
    UIUtil.SetActive(this.emailListContent, true)
    UIUtil.SetActive(this.emailDetailContent, false)
    this.curEmailId = 0
end

function EmailPanel.OnCloseBtnClick()
    this.Close()
    this.emailInfos = {}
end

function EmailPanel.OnQuickRemoveEmailsBtnClick()
    if GetTableSize(this.curEmailList) > 0 then
        Alert.Prompt("确定删除所有没有附件的邮件？", function()
            this.SendRemoveEmail(0)
        end)
    else
        Toast.Show("您没有任何邮件")
    end

end

function EmailPanel.OnQuickGetEmailsBtnClick()
    if GetTableSize(this.curEmailList) > 0 then
        Alert.Prompt("确定领取所有邮件附件，并删除邮件？", function()
            this.SendGetRewaid(0)
        end)
    else
        Toast.Show("您没有任何邮件")
    end
end

function EmailPanel.OnRemoveEmailBtnClick()
    Alert.Prompt("确定删除当前邮件？", function()
        this.SendRemoveEmail(this.curEmailId)
    end)
end

function EmailPanel.OnGetEmailRewardBtnClick()
    Alert.Prompt("确定领取当前邮件附件并删除邮件？", function()
        this.SendGetRewaid(this.curEmailId)
    end)
end

--pageIdx: 0开始, 服务器从1开始
function EmailPanel.SendGetEmailList(pageIdx)
    this.curGetPage = pageIdx
    if pageIdx < 0 then
        pageIdx = 1
    else
        pageIdx = pageIdx + 1
    end
    SendTcpMsg(CMD.Tcp.C2S_GetEmailList, { userId = UserData.GetUserId(), pageIndex = pageIdx, count = this.countPerPage })
end

--emailId:0 快速删除      emailId > 0 删除指定邮件
function EmailPanel.SendRemoveEmail(emailId)
    SendTcpMsg(CMD.Tcp.C2S_RemoveEmail, { userId = UserData.GetUserId(), emailId = emailId })
end

--emailId:0 快速领取      emailId > 0 删除指定邮件
function EmailPanel.SendGetRewaid(emailId)
    SendTcpMsg(CMD.Tcp.C2S_GetEmailReward, { userId = UserData.GetUserId(), emailId = emailId })
end

function EmailPanel.OnTcpGetEmailList(data)
    if data.code == 0 then
        local totalDataCount = data.data.allSize
        local curPage = data.data.pageIndex
        local list = data.data.list
        this.curEmailList = list
        if GetTableSize(list) > 0 then
            for k, item in pairs(list) do
                this.emailInfos[(curPage - 1) * this.countPerPage + k] = item
            end
            this.scrollExt:SetMaxDataCount(totalDataCount)
            this.scrollExt:UpdateAllItems()
            UIUtil.SetActive(this.scrollExt.transform, true)
            UIUtil.SetActive(this.noEmailText, false)

            local tempSize = GetTableSize(this.emailInfos)
            for i = totalDataCount + 1, tempSize do
                this.emailInfos[i] = nil
            end
        else
            UIUtil.SetActive(this.scrollExt.transform, false)
            UIUtil.SetActive(this.noEmailText, true)
        end
    end
end

function EmailPanel.OnTcpRemoveEmail(data)
    if data.code == 0 and data.data.status == 0 then
        Toast.Show("删除邮件成功")
        this.HideEmailDetailInfo()
        this.SendGetEmailList(this.curGetPage)
    end
end

function EmailPanel.OnTcpGetEmailReward(data)
    if data.code == 0 and data.data.status == 0 then
        if GetTableSize(data.data.list) > 0 then
            PanelManager.Open(PanelConfig.GetReward, data.data.list, function()
                this.SendGetEmailList(this.curGetPage)
                this.HideEmailDetailInfo()
            end)
            --UserData.SyschUserData()
        else
            Toast.Show("没有获取到任何附件")
        end
    end
end