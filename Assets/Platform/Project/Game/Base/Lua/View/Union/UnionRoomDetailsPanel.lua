UnionRoomDetailsPanel = ClassPanel("UnionRoomDetailsPanel")
local this = UnionRoomDetailsPanel

function UnionRoomDetailsPanel:Init()
    this.roomId = 0
    this.items = {}
    this.data = nil
end

function UnionRoomDetailsPanel:OnInitUI()
    this = self
    this:Init()

    local node = this:Find("Node")

    this.closeBtn = node:Find("Background/CloseBtn").gameObject
    local content = node:Find("Content")

    local left = content:Find("Left")
    this.roomCodeLabel = left:Find("RoomCode/Text"):GetComponent(TypeText)
    this.playWayLabel = left:Find("PlayWayTxt"):GetComponent(TypeText)
    this.juShuLabel = left:Find("JuShuTxt"):GetComponent(TypeText)
    this.timeLabel = left:Find("TimeTxt"):GetComponent(TypeText)

    this.itemContent = content:Find("Right/ScrollView/Viewport/Content")
    this.itemPrefab = this.itemContent:Find("Item").gameObject

    this.playbackBtn = content:Find("PlaybackBtn").gameObject
    this.copyBtn = content:Find("CopyBtn").gameObject

    this.AddUIEventListener()
end

function UnionRoomDetailsPanel:OnOpened(args)
    LogError("args.roomId", args.roomNum)
    this.userId = args.userId
    this.roomId = args.roomNum--args.roomId
    this.AddEventListener()
    this.Clear()
    UnionManager.SendGetRoomDetails(this.userId, args.roomId)
end

function UnionRoomDetailsPanel:OnClosed()
    this.data = nil
    this.RemoveEventListener()
end

------------------------------------------------------------------
--
--注册事件
function UnionRoomDetailsPanel.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_RoomDetails, this.OnGetRoomDetails)
end

--移除事件
function UnionRoomDetailsPanel.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.Union.S2C_RoomDetails, this.OnGetRoomDetails)
end

--UI相关事件
function UnionRoomDetailsPanel.AddUIEventListener()
    EventUtil.AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    EventUtil.AddOnClick(this.playbackBtn, this.OnPlaybackBtnClick)
    EventUtil.AddOnClick(this.copyBtn, this.OnCopyBtnClick)
end

--================================================================
--
--关闭
function UnionRoomDetailsPanel.Close()
    PanelManager.Close(PanelConfig.UnionRoomDetails)
end

--清除
function UnionRoomDetailsPanel.Clear()
    this.roomCodeLabel.text = ""
    this.playWayLabel.text = ""
    this.juShuLabel.text = ""
    this.timeLabel.text = ""
end

--================================================================
--
--返回信息
function UnionRoomDetailsPanel.OnGetRoomDetails(data)
    if data.code == 0 then
        this.UpdateData(data.data)
    end
end

--================================================================
--
function UnionRoomDetailsPanel.OnCloseBtnClick()
    this.Close()
end

--
function UnionRoomDetailsPanel.OnPlaybackBtnClick()
    UnionData.searchType = 1
    UnionData.searchId = this.roomId
    --2表示联盟菜单
    PanelManager.Open(PanelConfig.Record, RoomType.Tea, UnionData.curUnionId, UnionData.isOpenYinSi, 2)
end

--拷贝的格式
local CopyFormat = [[[]
房间号：%s
结束时间:%s
成绩：
%s
竞技成绩仅供娱乐，禁止赌博！]]

--玩家数量格式
local PlayerNumForamt = [[%s
%s]]

--
function UnionRoomDetailsPanel.OnCopyBtnClick()
    -- [乐山幺鸡麻将]
    -- 房间号：804035
    -- 结束时间:2021-07-07 15:51
    -- 成绩：
    -- [土豆丝丝儿] -14分
    -- [玩家949631] 43分
    -- [Dar。] -126分
    -- [雨] 97分
    -- 竞技成绩仅供娱乐，禁止赌博！
    local tempResult = nil
    if this.data ~= nil then
        local length = #this.data.list
        if length > 1 then
            local tempData = nil
            local tempStr = nil

            tempData = this.data.list[1]
            tempStr = "[" .. tempData.name .. "] " .. tostring(math.ToRound(tempData.sore, 2)) .. "分"
            local playerInfoStr = tempStr
            for i = 2, length do
                tempData = this.data.list[i]
                tempStr = "[" .. tempData.name .. "] " .. tostring(math.ToRound(tempData.sore, 2)) .. "分"
                playerInfoStr = Functions.GetS(PlayerNumForamt, playerInfoStr, tempStr)
            end
            tempResult = playerInfoStr
        end
    end
    if tempResult == nil then
        tempResult = ""
    end
    local text = Functions.GetS(CopyFormat, this.roomId, os.date("%y-%m-%d %H:%M", this.data.time / 1000), tempResult)
    Log(text)
    AppPlatformHelper.CopyText(text)
end

--================================================================
--
--更新数据
--{"cmd":4218,"code":0,"data":{"gameId":1001,"js":1,"list":[{"name":"fff","icon":"22","userId":342312,"sore":8},{"name":"fff","icon":"22","userId":342312,"sore":-8}],"unionId":666666,"gamename":"幺鸡麻将","time":1625912701120,"unionname":"测试2","roomId":488703}}->
function UnionRoomDetailsPanel.UpdateData(data)
    this.data = data
    this.gameId = data.gameId
    this.time = data.time
    --
    --LogError("<color=aqua>data</color>", data)
    this.roomCodeLabel.text = "房间号:\n" .. this.roomId
    this.playWayLabel.text = Functions.GetGameNameText(data.gameId)
    this.juShuLabel.text = data.js .. "局"
    this.timeLabel.text = os.date("%y-%m-%d %H:%M", data.time / 1000)

    --
    local list = data.list
    local length = GetTableSize(list)
    local item = nil
    local itemData = nil
    for i = 1, length do
        itemData = list[i]
        item = this.items[i]
        if item == nil then
            item = this.CreateItem(i)
        end
        this.SetItem(item, itemData)
    end
    local itemLength = #this.items
    for i = length + 1, itemLength do
        item = this.items[i]
        if item.data ~= nil then
            item.data = nil
            UIUtil.SetActive(item.gameObject, false)
        end
    end
end

--创建Item
function UnionRoomDetailsPanel.CreateItem(index)
    local item = {}
    --
    item.gameObject = CreateGO(this.itemPrefab, this.itemContent, tostring(index))
    item.transform = item.gameObject.transform
    item.headIconGo = item.transform:Find("Head/Icon").gameObject
    item.headIcon = item.headIconGo:GetComponent(TypeImage)
    item.nameLabel = item.transform:Find("NameText"):GetComponent(TypeText)
    item.idLabel = item.transform:Find("IdText"):GetComponent(TypeText)
    item.label1 = item.transform:Find("Text1"):GetComponent(TypeText)
    --
    table.insert(this.items, item)
    --
    return item
end

--设置Item数据
function UnionRoomDetailsPanel.SetItem(item, data)
    item.data = data
    --
    UIUtil.SetActive(item.gameObject, true)
    if item.icon ~= data.icon then
        item.icon = data.icon
        Functions.SetHeadImage(item.headIcon, data.icon)
    end
    item.nameLabel.text = tostring(data.name)
    item.idLabel.text = "ID:" .. UnionData.GetUidString(data.userId)
    local temp = math.ToRound(data.sore, 2)
    if temp > 0 then
        temp = "+" .. tostring(temp)
    else
        temp = tostring(temp)
    end
    item.label1.text = temp
end