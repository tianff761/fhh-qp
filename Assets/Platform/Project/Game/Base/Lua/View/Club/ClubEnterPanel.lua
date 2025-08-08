ClubEnterPanel = ClassPanel("ClubEnterPanel")
local this = ClubEnterPanel

this.clubItemPool = {}
this.clubItemGO = nil

function ClubEnterPanel:OnInitUI()
    this = self
    --初始化背景
    this.bg = self.transform:Find("BackGround")
    --UIUtil.SetBackgroundAdaptation(this.bg.gameObject)
    local content = this.transform:Find("Content")
    --上方信息显示
    local top = content:Find("Top")
    this.backBtn = top:Find("BackBtn"):GetComponent("Button")
    local clubList = content:Find("ClubList")
    this.tipText = clubList:Find("TipText"):GetComponent("Text")
    this.clubContent = clubList:Find("Viewport/Content")
    this.clubItemGO = clubList:Find("ClubItem").gameObject
    this.openCreateBtn = content:Find("OpenCreateBtn"):GetComponent("Button")
    this.openJoinBtn = content:Find("OpenJoinBtn"):GetComponent("Button")

    this.AddUIListenerEvent()
end

function ClubEnterPanel:OnOpened(clubId, gameType)
    if clubId ~= nil and clubId > 0 then
        this.autoInClubId = clubId
    end
    this.AddListenerEvent()
    ClubManager.SendGetClubList()
end

--关闭面板
function ClubEnterPanel:OnClosed()
    this.RemoveListenerEvent()
    for i = 1, #this.clubItemPool do
        UIUtil.SetActive(this.clubItemPool[i].gameObject, false)
    end
end

function ClubEnterPanel.AddListenerEvent()
    
end

function ClubEnterPanel.RemoveListenerEvent()
    
end

function ClubEnterPanel.AddUIListenerEvent()
    this:AddOnClick(this.backBtn, this.OnBackBtnClick)
    this:AddOnClick(this.openCreateBtn, this.OnOpenCreateBtnClick)
    this:AddOnClick(this.openJoinBtn, this.OnOpenJoinBtnClick)
end

--返回
function ClubEnterPanel.OnBackBtnClick()
    ClubManager.Close()
end

--打开创建俱乐部
function ClubEnterPanel.OnOpenCreateBtnClick()
    PanelManager.Open(PanelConfig.ClubCreate)
end

--打开加入俱乐部
function ClubEnterPanel.OnOpenJoinBtnClick()
    -- PanelManager.Open(PanelConfig.ClubJoin)
    PanelManager.Open(PanelConfig.ClubInputNumber, ClubInputNumberPanelType.JoinClub, function (num)
        ClubManager.SendApplyJoinClub(num)
        PanelManager.Close(PanelConfig.ClubInputNumber, true)
    end)
end

--更新俱乐部列表
function ClubEnterPanel.UpdateClubList()
    local list = ClubData.clubList
    local length = GetTableSize(list)
    UIUtil.SetActive(this.tipText.gameObject, length <= 0)
    if length > 0 then
        HideChildren(this.clubContent)
        for i = 1, length do
            local data = list[i]
            local item = this.GetClubItemByIndex(i)
            UIUtil.SetActive(item.gameObject, true)
            item.clubNameText.text = data.clubName
            item.clubIdText.text = data.clubId
            local bossInfo = data.boss
            item.bossNameText.text = bossInfo.bossName
            item.bossIdText.text = bossInfo.bossId
            Functions.SetHeadImage(item.headImage, bossInfo.bossIcon)
            item.myRoleText.text = ClubRoleName[data.role]
            HideChildren(item.roleIconTrans)
            UIUtil.SetActive(item.roleIcons[data.role + 1], true)
            item.tableNumText.text = data.tableNum
            this:AddOnClick(item.gameObject, function ()
                if ClubData.SetCurClubId(data.clubId) then
                    PanelManager.Open(PanelConfig.ClubRoom)
                else
                    Toast.Show("当前茶馆不存在")
                end
            end)
            this:AddOnClick(item.inviteBtn, function ()
                PanelManager.Open(PanelConfig.LobbyShare, data.key)
            end)
            if this.autoInClubId ~= nil and this.autoInClubId == data.clubId then
                if ClubData.SetCurClubId(data.clubId) then
                    PanelManager.Open(PanelConfig.ClubRoom)
                    this.autoInClubId = nil
                end
            end
        end
    end
end

--获取俱乐部Item
function ClubEnterPanel.GetClubItemByIndex(index)
    if IsNil(this.clubItemPool) then
        this.clubItemPool = {}
    end
    local item = this.clubItemPool[index]
    if IsNil(item) then
        local itemGO = CreateGO(this.clubItemGO, this.clubContent)
        item = {}
        item.gameObject = itemGO
        item.transform = itemGO.transform
        item.clubNameText = item.transform:Find("Title"):GetComponent("Text")
        item.clubIdText = item.transform:Find("Id"):GetComponent("Text")
        local bossInfo = item.transform:Find("BossInfo")
        item.headImage = bossInfo:Find("Head/Mask/HeadIcon"):GetComponent("Image")
        item.bossNameText = bossInfo:Find("NameText"):GetComponent("Text")
        item.bossIdText = bossInfo:Find("IDText"):GetComponent("Text")
        item.myRoleText = item.transform:Find("MyRole/Text"):GetComponent("Text")
        item.roleIconTrans = item.transform:Find("MyRole/RoleIcon")
        item.roleIcons = {}
        for i = 1, item.roleIconTrans.childCount do
            local icon = item.roleIconTrans:GetChild(i - 1).gameObject
            table.insert(item.roleIcons, icon)
        end
        item.tableNumText = item.transform:Find("TableNum/Text"):GetComponent("Text")
        item.inviteBtn = item.transform:Find("InviteBtn"):GetComponent("Button")
        this.clubItemPool[index] = item
    end
    UIUtil.SetActive(item.gameObject, true)
    item.transform:SetSiblingIndex(index)
    return item
end