UnionDarkRoomGroupPanel = ClassPanel("UnionDarkRoomGroupPanel")
local this = UnionDarkRoomGroupPanel

function UnionDarkRoomGroupPanel:Awake()
    this = self
    this.selectItem = nil
    this.sendTime = 0
    this.pageIndex = 1
    this.pageTotal = 1
    this.isUpdateGroupList = false

    local content = this:Find("Content")
    this.closeBtn = content:Find("Background/CloseBtn")

    this.items = {}
    this.layout = content:Find("Layout")
    this.itemPrefab = this.layout:Find("PlayerItem").gameObject

    this.nameInput = content:Find("NameInput"):GetComponent(TypeInputField)

    this.modifyBtn = content:Find("ModifyBtn").gameObject
    this.deleteBtn = content:Find("DeleteBtn").gameObject
    this.addPlayerBtn = content:Find("AddPlayerBtn").gameObject
    this.deletePlayerBtn = content:Find("DeletePlayerBtn").gameObject

    this.lastBtn = content:Find("LastBtn").gameObject
    this.nextBtn = content:Find("NextBtn").gameObject
    this.pageLabel = content:Find("PageText/Text"):GetComponent(TypeText)

    this.AddUIListenerEvent()
end

function UnionDarkRoomGroupPanel:OnOpened(args)
    this.AddListenerEvent()
    this.houseId = args.id
    this.houseName = args.name
    this.nameInput.text = args.name
    this.SendRequestPage(this.pageIndex)
end

function UnionDarkRoomGroupPanel:OnClosed()
    this.RemoveListenerEvent()
end

function UnionDarkRoomGroupPanel.AddListenerEvent()
    AddEventListener(CMD.Tcp.Union.S2C_UNION_MODIFY_BLACK_HOUSE, this.OnModifyBlackHouseGroup)
    AddEventListener(CMD.Tcp.Union.S2C_UNION_CREATE_BLACK_HOUSE, this.OnDeleteBlackHouseGroup)
    AddEventListener(CMD.Tcp.Union.S2C_UNION_GET_BLACK_HOUSE, this.OnGetBlackHouseGroup)
    AddEventListener(CMD.Tcp.Union.S2C_UNION_ADD_BLACK_HOUSE, this.OnAddBlackHousePlayer)
    --
    AddEventListener(CMD.Game.UnionUpdateBlackHouseGroup, this.OnUnionUpdateBlackHouseGroup)

end

--
function UnionDarkRoomGroupPanel.RemoveListenerEvent()
    RemoveEventListener(CMD.Tcp.Union.S2C_UNION_MODIFY_BLACK_HOUSE, this.OnModifyBlackHouseGroup)
    RemoveEventListener(CMD.Tcp.Union.S2C_UNION_CREATE_BLACK_HOUSE, this.OnDeleteBlackHouseGroup)
    RemoveEventListener(CMD.Tcp.Union.S2C_UNION_GET_BLACK_HOUSE, this.OnGetBlackHouseGroup)
    RemoveEventListener(CMD.Tcp.Union.S2C_UNION_ADD_BLACK_HOUSE, this.OnAddBlackHousePlayer)
    --
    RemoveEventListener(CMD.Game.UnionUpdateBlackHouseGroup, this.OnUnionUpdateBlackHouseGroup)
end

function UnionDarkRoomGroupPanel.AddUIListenerEvent()
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.modifyBtn, this.OnModifyBtnClick)
    this:AddOnClick(this.deleteBtn, this.OnDeleteBtnClick)
    this:AddOnClick(this.addPlayerBtn, this.OnAddPlayerBtnClick)
    this:AddOnClick(this.deletePlayerBtn, this.OnDeletePlayerBtnClick)
    this:AddOnClick(this.lastBtn, this.OnLastBtnClick)
    this:AddOnClick(this.nextBtn, this.OnNextBtnClick)
end

--================================================================
--
function UnionDarkRoomGroupPanel.OnCloseBtnClick()
    this.Close()
end

--
function UnionDarkRoomGroupPanel.OnModifyBtnClick()
    local houseName = this.nameInput.text
    if string.IsNullOrEmpty(houseName) then
        Alert.Show("请输入关系组的名称")
        return
    end
    if houseName == this.houseName then
        return
    end
    if this.sendTime > Time.realtimeSinceStartup then
        Toast.Show("请稍后...")
        return
    end
    this.sendTime = Time.realtimeSinceStartup + 2
    UnionManager.SendModifyBlackHouseGroup(this.houseId, houseName)
end

--
function UnionDarkRoomGroupPanel.OnDeleteBtnClick()
    Alert.Prompt("是否删除当前隔离区关系组？", this.OnDeleteAlertCallback)
end

function UnionDarkRoomGroupPanel.OnDeleteAlertCallback()
    if this.sendTime > Time.realtimeSinceStartup then
        Toast.Show("请稍后...")
        return
    end
    this.sendTime = Time.realtimeSinceStartup + 2
    UnionManager.SendDeleteBlackHouseGroup(this.houseId)
end

--
function UnionDarkRoomGroupPanel.OnAddPlayerBtnClick()
    PanelManager.Open(PanelConfig.UnionDarkRoomAdd, this.houseId)
end

--
function UnionDarkRoomGroupPanel.OnDeletePlayerBtnClick()
    if this.selectItem == nil then
        Alert.Show("请选择需要从关系组中删除的玩家")
        return
    end
    if this.sendTime > Time.realtimeSinceStartup then
        Toast.Show("请稍后...")
        return
    end
    this.sendTime = Time.realtimeSinceStartup + 2
    UnionManager.SendAddBlackHousePlayer(this.houseId, 1, this.selectItem.data.userId)
end

--
function UnionDarkRoomGroupPanel.OnLastBtnClick()
    if this.pageIndex > 1 then
        if this.sendTime > Time.realtimeSinceStartup then
            Toast.Show("请稍后...")
            return
        end
        this.sendTime = Time.realtimeSinceStartup + 2
        this.SendRequestPage(this.pageIndex - 1)
    end
end

--
function UnionDarkRoomGroupPanel.OnNextBtnClick()
    if this.pageIndex < this.pageTotal then
        if this.sendTime > Time.realtimeSinceStartup then
            Toast.Show("请稍后...")
            return
        end
        this.sendTime = Time.realtimeSinceStartup + 2
        this.SendRequestPage(this.pageIndex + 1)
    end
end
--================================================================
--
--
function UnionDarkRoomGroupPanel.OnModifyBlackHouseGroup(msgObj)
    this.sendTime = 0
    if msgObj.code == 0 then
        this.isUpdateGroupList = true
        Toast.Show("修改隔离区关系组名称成功")
    else
        UnionManager.ShowError(msgObj.code)
    end
end

--
function UnionDarkRoomGroupPanel.OnDeleteBlackHouseGroup(msgObj)
    this.sendTime = 0
    if msgObj.code == 0 then
        --不处理错误码，因为小黑屋面板在监听处理，这里只处理成功
        this.DirectClose()
    end
end

--获取关系组数据
--{"cmd":4104,"code":0,"data":{"page":1,"num":30,"id":1,"totalNum":0,"userList":{},"name":"第一组2","totalPage":0}}
function UnionDarkRoomGroupPanel.OnGetBlackHouseGroup(msgObj)
    LogError(msgObj)
    this.sendTime = 0
    if msgObj.code == 0 then
        local data = msgObj.data
        this.pageIndex = data.pageIndex
        if this.pageIndex < 1 then
            this.pageIndex = 1
        end
        this.pageTotal = data.allPage
        if this.pageTotal < 1 then
            this.pageTotal = 1
        end
        if this.pageIndex > this.pageTotal then
            this.pageIndex = this.pageTotal
        end
        this.list = data.userList
        this.UpdateDisplay()
    else
        UnionManager.ShowError(msgObj.code)
    end
end

--添加删除成员
function UnionDarkRoomGroupPanel.OnAddBlackHousePlayer(msgObj)
    LogError(msgObj)
    this.sendTime = 0
    if msgObj.code == 0 then
        local data = msgObj.data
        this.SendRequestPage(this.pageIndex)
    else
        UnionManager.ShowError(msgObj.code)
    end
end

--刷新数据
function UnionDarkRoomGroupPanel.OnUnionUpdateBlackHouseGroup()
    this.isUpdateGroupList = true
    this.SendRequestPage(this.pageIndex)
end

--================================================================
--
--
function UnionDarkRoomGroupPanel.Close()
    if this.isUpdateGroupList then
        SendEvent(CMD.Game.UnionUpdateBlackHouseGroupList)
    end
    PanelManager.Close(PanelConfig.UnionDarkRoomGroup)
end

--直接关闭面板
function UnionDarkRoomGroupPanel.DirectClose()
    PanelManager.Close(PanelConfig.UnionDarkRoomGroup)
end

--请求数据
function UnionDarkRoomGroupPanel.SendRequestPage(pageIndex)
    UnionManager.SendGetBlackHouseGroup(this.houseId, pageIndex, 30)
end

--================================================================
--
--更新显示
function UnionDarkRoomGroupPanel.UpdateDisplay()
    this.pageLabel.text = this.pageIndex .. "/" .. this.pageTotal
    local dataLength = #this.list
    local itemLength = #this.items
    local item = nil
    local data = nil
    for i = 1, dataLength do
        data = this.list[i]
        item = this.items[i]
        if item == nil then
            item = this.CreatePlayerItem(i)
        end
        this.SetPlayerItem(item, data)
    end

    for i = dataLength + 1, itemLength do
        item = this.items[i]
        this.ClearPlayerItem(item)
    end

    if this.selectItem ~= nil then
        UIUtil.SetActive(this.selectItem.selected, false)
        this.selectItem = nil
    end
end

--创建玩家显示项
function UnionDarkRoomGroupPanel.CreatePlayerItem(index)
    local item = {}
    table.insert(this.items, item)
    item.gameObject = CreateGO(this.itemPrefab, this.layout, tostring(index))
    item.transform = item.gameObject.transform
    item.headIcon = item.transform:Find("Head/Icon"):GetComponent(TypeImage)
    item.nameLabel = item.transform:Find("NameText"):GetComponent(TypeText)
    item.selected = item.transform:Find("Selected").gameObject
    item.data = nil
    item.playerId = nil
    UIClickListener.Get(item.gameObject).onClick = function() this.OnPlayerItemClick(item) end
    return item
end

--
function UnionDarkRoomGroupPanel.OnPlayerItemClick(item)
    if this.selectItem ~= item then
        if this.selectItem ~= nil then
            UIUtil.SetActive(this.selectItem.selected, false)
            this.selectItem = nil
        end

        this.selectItem = item
        UIUtil.SetActive(this.selectItem.selected, true)
    end
end

--设置玩家显示项
--{"icon":"5","userId":342312,"userName":"纪涵润"}
function UnionDarkRoomGroupPanel.SetPlayerItem(item, data)
    UIUtil.SetActive(item.gameObject, true)
    item.data = data
    item.playerId = data.userId
    item.nameLabel.text = SubStringName(data.userName, 4)
    local arg = { playerItem = item, playerId = data.userId }
    Functions.SetHeadImage(item.headIcon, data.icon, this.OnHeadImageLoadCompleted, arg)
end

--加载头像图片完成
function UnionDarkRoomGroupPanel.OnHeadImageLoadCompleted(arg)
    if arg.playerItem ~= nil and arg.playerItem.playerId == arg.playerId then
        netImageMgr:SetImage(arg.playerItem.headIcon, arg.headUrl)
    end
end

--清除
function UnionDarkRoomGroupPanel.ClearPlayerItem(item)
    if item.data ~= nil then
        item.data = nil
        item.playerId = nil
        UIUtil.SetActive(item.gameObject, false)
    end
end