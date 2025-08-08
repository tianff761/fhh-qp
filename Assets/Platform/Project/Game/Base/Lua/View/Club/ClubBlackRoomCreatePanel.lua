ClubBlackRoomCreatePanel = ClassPanel("ClubBlackRoomCreatePanel")
local this = ClubBlackRoomCreatePanel

this.playerDatas = {}

function ClubBlackRoomCreatePanel:OnInitUI()
    this = self
    local content = self:Find("Content")
    this.playerItems = {}
    local playerNode = content:Find("Players")
    for i = 1, 2 do
        local item = {}
        item.transform = playerNode:Find("Player" .. i)
        item.gameObject = item.transform.gameObject
        local headMask = item.transform:Find("Head/Mask")
        item.defaultHeadImage = headMask:Find("DefaultHeadIcon")
        item.headImage = headMask:Find("HeadIcon"):GetComponent("Image")
        item.nameText = item.transform:Find("NameText"):GetComponent("Text")
        item.idText = item.transform:Find("IdText"):GetComponent("Text")
        item.tips = item.transform:Find("Tips")
        this:AddOnClick(item.gameObject, function()
            PanelManager.Open(PanelConfig.ClubBlackRoomMember, i)
        end)
        table.insert(this.playerItems, item)
    end
    this.bindBtn = content:Find("BindBtn")
    this.cancelBtn = content:Find("CancelBtn")
    this.AddUIListenerEvent()
end

function ClubBlackRoomCreatePanel:OnOpened()
    
end

function ClubBlackRoomCreatePanel:OnClosed()
    this.Reset()
end

function ClubBlackRoomCreatePanel.AddUIListenerEvent()
    this:AddOnClick(this.bindBtn, this.OnClickBindBtn)
    this:AddOnClick(this.cancelBtn, this.OnClickCancelBtn)
end


function ClubBlackRoomCreatePanel.OnClickBindBtn()
    local playerData1 = this.playerDatas[1]
    local playerData2 = this.playerDatas[2]
    if playerData1 ~= nil and playerData2 ~= nil and playerData1.uid ~= playerData2.uid then
        ClubManager.SendBlackRoomBind(0, playerData1.uid, playerData2.uid)
        PanelManager.Close(PanelConfig.ClubBlackRoomCreate)
    else
        Toast.Show("请选择两个玩家绑定")
    end
end

function ClubBlackRoomCreatePanel.OnClickCancelBtn()
    PanelManager.Close(PanelConfig.ClubBlackRoomCreate)
end

function ClubBlackRoomCreatePanel.UpdatePlayerInfo(index, playerData)
    if not IsTable(this.playerDatas) then
        this.playerDatas = {}
    end
    this.playerDatas[index] = playerData
    local playerItem = this.playerItems[index]
    if playerItem ~= nil then
        UIUtil.SetActive(playerItem.defaultHeadImage, false)
        UIUtil.SetActive(playerItem.tips, false)
        UIUtil.SetActive(playerItem.nameText.gameObject, true)
        UIUtil.SetActive(playerItem.idText.gameObject, true)
        
        Functions.SetHeadImage(playerItem.headImage, playerData.headIcon)
        playerItem.nameText.text = playerData.name
        playerItem.idText.text = playerData.uid
    end
end

function ClubBlackRoomCreatePanel.Reset()
    this.playerDatas = {}
    for i = 1, #this.playerItems do
        local playerItem = this.playerItems[i]
        UIUtil.SetActive(playerItem.defaultHeadIcon, true)
        UIUtil.SetActive(playerItem.tips, true)
        UIUtil.SetActive(playerItem.nameText.gameObject, false)
        UIUtil.SetActive(playerItem.idText.gameObject, false)
    end
end

