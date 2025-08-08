UnionSettingNode4DarkRoom = ClassPanel("UnionSettingNode4DarkRoom")
local this = UnionSettingNode4DarkRoom

function UnionSettingNode4DarkRoom:Awake(transform)
    this = self
    this.pageIndex = 1
    this.pageTotal = 1
    this.sendTime = 0
    this.createTime = 0
    this.transform = transform
    LogError("<color=aqua>this.transform.name</color>", this.transform.name)
    local content = this.transform
    --this.closeBtn = content:Find("Background/CloseButton")

    local layout = content:Find("Layout")
    this.NilDataNotice = content:Find("NilDataNotice").gameObject
    this.items = {}
    for i = 1, 4 do
        local item = {}
        item.transform = layout:Find(tostring(i))
        item.gameObject = item.transform.gameObject
        item.titleLabel = item.transform:Find("TitleText"):GetComponent(TypeText)
        item.layout = item.transform:Find("ScrollView/Viewport/Content")
        item.itemPrefab = item.layout:Find("Item").gameObject
        item.data = nil
        item.items = {}
        UIClickListener.Get(item.gameObject).onClick = function()
            this.OnItemClick(item)
        end
        table.insert(this.items, item)
    end

    this.createBtn = content:Find("CreateBtn").gameObject
    this.lastBtn = content:Find("Page/LastBtn").gameObject
    this.nextBtn = content:Find("Page/NextBtn").gameObject
    this.pageLabel = content:Find("Page/PageText/Text"):GetComponent(TypeText)

    this.AddUIListenerEvent()
end

function UnionSettingNode4DarkRoom:OnOpened()
    this.AddListenerEvent()
    this.SendRequestPage(this.pageIndex)
end

function UnionSettingNode4DarkRoom:OnClosed()
    this.RemoveListenerEvent()
    this.pageIndex = 1
    this.pageTotal = 1
    this.sendTime = 0
end

function UnionSettingNode4DarkRoom.AddListenerEvent()
    AddEventListener(CMD.Tcp.Union.S2C_UNION_GET_BLACK_HOUSE_ALL, this.OnGetBlackHouseGroupList)
    AddEventListener(CMD.Tcp.Union.S2C_UNION_CREATE_BLACK_HOUSE, this.OnCreateBlackHouseGroup)
    --
    AddEventListener(CMD.Game.UnionUpdateBlackHouseGroupList, this.OnUnionUpdateBlackHouseGroupList)

end
--
function UnionSettingNode4DarkRoom.RemoveListenerEvent()
    RemoveEventListener(CMD.Tcp.Union.S2C_UNION_GET_BLACK_HOUSE_ALL, this.OnGetBlackHouseGroupList)
    RemoveEventListener(CMD.Tcp.Union.S2C_UNION_CREATE_BLACK_HOUSE, this.OnCreateBlackHouseGroup)
    --
    RemoveEventListener(CMD.Game.UnionUpdateBlackHouseGroupList, this.OnUnionUpdateBlackHouseGroupList)
end

function UnionSettingNode4DarkRoom.AddUIListenerEvent()
    --this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.createBtn, this.OnCreateBtnClick)
    this:AddOnClick(this.lastBtn, this.OnLastBtnClick)
    this:AddOnClick(this.nextBtn, this.OnNextBtnClick)
end

--================================================================
--
function UnionSettingNode4DarkRoom.OnCloseBtnClick()
    this.Close()
end

--
function UnionSettingNode4DarkRoom.OnCreateBtnClick()
    if this.createTime > Time.realtimeSinceStartup then
        Toast.Show("请稍后...")
        return
    end
    this.createTime = Time.realtimeSinceStartup + 2
    UnionManager.SendCreateBlackHouseGroup()
end

--
function UnionSettingNode4DarkRoom.OnLastBtnClick()
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
function UnionSettingNode4DarkRoom.OnNextBtnClick()
    if this.pageIndex < this.pageTotal then
        if this.sendTime > Time.realtimeSinceStartup then
            Toast.Show("请稍后...")
            return
        end
        this.sendTime = Time.realtimeSinceStartup + 2
        this.SendRequestPage(this.pageIndex + 1)
    end
end

--
function UnionSettingNode4DarkRoom.OnItemClick(item)
    --LogError("<color=aqua>OnItemClick</color>")
    if item.data ~= nil then
        PanelManager.Open(PanelConfig.UnionDarkRoomGroup, item.data)
    end
end

--================================================================
--
--{"cmd":4076,"code":0,"data":{"page":1,"houseList":[{"page":1,"totalNum":0,"id":1,"num":12,"userList":{},"totalPage":0}],"num":4,"totalNum":1,"totalPage":1}}
function UnionSettingNode4DarkRoom.OnGetBlackHouseGroupList(msgObj)
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
        this.list = data.houseList

        this.UpdateDisplay()
    else
        UnionManager.ShowError(msgObj.code)
    end
end

--
function UnionSettingNode4DarkRoom.OnCreateBlackHouseGroup(msgObj)
    LogError(msgObj)
    if msgObj.code == 0 then
        local data = msgObj.data
        if data.option == 0 then
            Alert.Show("创建关系组成功")
        end
        this.SendRequestPage(this.pageIndex)
    else
        UnionManager.ShowError(msgObj.code)
    end
end

--刷新当前页
function UnionSettingNode4DarkRoom.OnUnionUpdateBlackHouseGroupList()
    this.SendRequestPage(this.pageIndex)
end

--================================================================
--
--
function UnionSettingNode4DarkRoom.Close()
    PanelManager.Close(PanelConfig.UnionDarkRoom)
end

--
function UnionSettingNode4DarkRoom.SendRequestPage(pageIndex)
    if pageIndex < 1 then
        pageIndex = 1
    end
    UnionManager.SendGetBlackHouseGroupList(pageIndex, 4)
end

--================================================================
--
--更新显示
function UnionSettingNode4DarkRoom.UpdateDisplay()
    this.pageLabel.text = this.pageIndex .. "/" .. this.pageTotal
    local dataLength = #this.list
    local itemLength = #this.items
    local item = nil
    local data = nil

    --LogError("<color=aqua>dataLength</color>", dataLength)
    for i = 1, dataLength do
        data = this.list[i]
        item = this.items[i]
        if item ~= nil then
            this.SetItem(item, data)
        end
    end

    for i = dataLength + 1, itemLength do
        item = this.items[i]
        this.ClearItem(item)
    end

    UIUtil.SetActive(this.NilDataNotice, dataLength == 0)
end

--设置
--{"page":1,"totalNum":0,"id":1,"num":12,"userList":{},"totalPage":0}
function UnionSettingNode4DarkRoom.SetItem(item, data)
    --LogError("<color=aqua>data</color>", data)
    item.data = data
    if string.IsNullOrEmpty(data.name) then
        data.name = "未设置名称"--没有设置服务器就不传这个值
    end

    item.titleLabel.text = data.name
    local playerItem = nil
    local playerData = nil
    local itemLength = #item.items
    local dataLength = #data.userList
    if dataLength > 12 then
        dataLength = 12
    end
    UIUtil.SetActive(item.gameObject, true)
    for i = 1, dataLength do
        playerData = data.userList[i]
        playerItem = item.items[i]
        if playerItem == nil then
            playerItem = this.CreatePlayerItem(item, i)
        end
        this.SetPlayerItem(playerItem, playerData)
    end
    for i = dataLength + 1, itemLength do
        playerItem = item.items[i]
        if playerItem.data ~= nil then
            playerItem.data = nil
            playerItem.playerId = nil
            UIUtil.SetActive(playerItem.gameObject, false)
        end
    end
end

--创建玩家显示项
function UnionSettingNode4DarkRoom.CreatePlayerItem(groupItem, index)
    local item = {}
    table.insert(groupItem.items, item)
    item.gameObject = CreateGO(groupItem.itemPrefab, groupItem.layout, tostring(index))
    item.transform = item.gameObject.transform
    item.bg = item.transform:Find("Bg").gameObject
    item.headIcon = item.transform:Find("Head/Icon"):GetComponent(TypeImage)
    item.data = nil
    item.playerId = nil
    return item
end

--设置玩家显示项
--{"icon":"5","userId":342312,"userName":"纪涵润"}
function UnionSettingNode4DarkRoom.SetPlayerItem(item, data)
    item.data = data
    item.playerId = data.userId
    local arg = { playerItem = item, playerId = data.userId }
    UIUtil.SetActive(item.gameObject, true)
    Functions.SetHeadImage(item.headIcon, data.icon, this.OnHeadImageLoadCompleted, arg)
end

--加载头像图片完成
function UnionSettingNode4DarkRoom.OnHeadImageLoadCompleted(arg)
    if arg.playerItem ~= nil and arg.playerItem.playerId == arg.playerId then
        netImageMgr:SetImage(arg.playerItem.headIcon, arg.headUrl)
    end
end

--清除
function UnionSettingNode4DarkRoom.ClearItem(item)
    if item.data ~= nil then
        item.data = nil
        item.titleLabel.text = ""
        local temp = nil
        for i = 1, #item.items do
            temp = item.items[i]
            if temp.data ~= nil then
                temp.data = nil
                UIUtil.SetActive(temp.gameObject, false)
            end
        end
    end
    UIUtil.SetActive(item.gameObject, false)
end