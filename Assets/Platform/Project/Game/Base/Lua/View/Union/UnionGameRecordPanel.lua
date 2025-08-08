UnionGameRecordPanel = ClassPanel("UnionGameRecordPanel")
local this = UnionGameRecordPanel

--每页总数
local PageCount = 4

local ColorOnline = Color(29 / 255, 77 / 255, 123 / 255)
local ColorOffline = Color(100 / 255, 100 / 255, 100 / 255)
local RoomCodeLineHeight = 20

function UnionGameRecordPanel:Init()
    this.userId = 0
    this.isSearched = false
    this.searchId = 0
    this.pageIndex = 1
    this.pageTotal = 1
end

function UnionGameRecordPanel:OnInitUI()
    this = self
    this:Init()

    local node = this:Find("Node")

    this.closeBtn = node:Find("Background/CloseBtn").gameObject

    local content = node:Find("Content")
    this.mainItem = this.CreateMainItem(content:Find("MainItem").gameObject)

    this.itemContent = content:Find("Content")
    this.itemPrefab = this.itemContent:Find("Item").gameObject

    this.items = {}
    for i = 1, PageCount do
        local item = this.CreateItem(CreateGO(this.itemPrefab, this.itemContent, tostring(i)))
        UIUtil.SetActive(item.gameObject, false)
        table.insert(this.items, item)
    end

    local page = content:Find("Bottom/Page")
    this.lastBtn = page:Find("LastBtn").gameObject
    this.nextBtn = page:Find("NextBtn").gameObject
    this.pageLabel = page:Find("PageText/Text"):GetComponent(TypeText)

    this.searchBtn = content:Find("SearchBtn").gameObject
    this.input = content:Find("SearchInput"):GetComponent(TypeInputField)

    this.loading = content:Find("LoadingText").gameObject
    this.noData = content:Find("NoDataText").gameObject

    this.AddUIEventListener()
end

function UnionGameRecordPanel:OnOpened(args)
    this.userId = args
    this.AddEventListener()
    this.SendRequestList(this.pageIndex)
end

function UnionGameRecordPanel:OnClosed()
    this.RemoveEventListener()
    this.isSearched = false
    this.searchId = 0
    this.input.text = ""
    this.pageIndex = 1
    this.pageTotal = 1
end

------------------------------------------------------------------
--
--注册事件
function UnionGameRecordPanel.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_GameRecord, this.GetGameRecord)
end

--移除事件
function UnionGameRecordPanel.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.Union.S2C_GameRecord, this.GetGameRecord)
end

--UI相关事件
function UnionGameRecordPanel.AddUIEventListener()
    EventUtil.AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    EventUtil.AddOnClick(this.lastBtn, this.OnLastBtnClick)
    EventUtil.AddOnClick(this.nextBtn, this.OnNextBtnClick)
    EventUtil.AddOnClick(this.searchBtn, this.OnSearchBtnClick)
    this.input.onValueChanged:RemoveAllListeners()
    this.input.onValueChanged:AddListener(this.OnInputFieldValueChanged)
end

--================================================================
--
--关闭
function UnionGameRecordPanel.Close()
    PanelManager.Close(PanelConfig.UnionGameRecord)
end

--创建Item
function UnionGameRecordPanel.CreateMainItem(gameObject)
    local item = {}
    --
    item.gameObject = gameObject
    item.transform = item.gameObject.transform
    item.headIconGo = item.transform:Find("Head/Icon").gameObject
    item.headIcon = item.headIconGo:GetComponent(TypeImage)
    item.nameLabel = item.transform:Find("NameText"):GetComponent(TypeText)
    item.idLabel = item.transform:Find("IdText"):GetComponent(TypeText)
    item.label1 = item.transform:Find("Text1"):GetComponent(TypeText)
    item.label2 = item.transform:Find("Text2"):GetComponent(TypeText)
    item.label3 = item.transform:Find("Text3"):GetComponent(TypeText)
    item.label4 = item.transform:Find("Text4"):GetComponent(TypeText)
    return item
end

--创建Item
function UnionGameRecordPanel.CreateItem(gameObject)
    local item = {}
    --
    item.gameObject = gameObject
    item.transform = item.gameObject.transform
    item.label1 = item.transform:Find("Text1"):GetComponent(TypeText)
    item.label2 = item.transform:Find("Text2"):GetComponent(TypeText)
    item.label3 = item.transform:Find("Text3"):GetComponent(TypeText)
    item.label3LineRectTransform = item.transform:Find("Text3/Line"):GetComponent(TypeRectTransform)
    item.label4 = item.transform:Find("Text4"):GetComponent(TypeText)
    item.label5 = item.transform:Find("Text5"):GetComponent(TypeText)
    item.label6Go = item.transform:Find("Text6").gameObject
    item.bigWin = item.transform:Find("BigWin").gameObject

    UIClickListener.Get(item.label3.gameObject).onClick = function()
        this.OnRoomClick(item)
    end
    return item
end

--================================================================
--
--返回信息
function UnionGameRecordPanel.GetGameRecord(data)
    if data.code == 0 then
        this.UpdateDataList(data.data)
    end
end

--================================================================
--
--查看个人记录
function UnionGameRecordPanel.OnRoomClick(item)
    if item.data ~= nil then
        PanelManager.Open(PanelConfig.UnionRoomDetails, { userId = this.userId, roomId = item.data.roomId, roomNum = item.data.roomNum })
    end
end

--
function UnionGameRecordPanel.OnCloseBtnClick()
    this.Close()
end


--
function UnionGameRecordPanel.OnLastBtnClick()
    if this.pageIndex <= 1 then
        Toast.Show("当前已是首页")
    else
        this.SendRequestList(this.pageIndex - 1)
    end
end

--
function UnionGameRecordPanel.OnNextBtnClick()
    if this.pageIndex >= this.pageTotal then
        Toast.Show("当前已是尾页")
    else
        this.SendRequestList(this.pageIndex + 1)
    end
end

--
function UnionGameRecordPanel.OnSearchBtnClick()
    local text = this.input.text
    if not string.IsNullOrEmpty(text) and string.len(text) == 6 then
        local num = tonumber(text)
        if num ~= nil then
            LockScreen(0.5)
            this.isSearched = true
            this.searchId = num
            this.SendRequestList(1)
        else
            Toast.Show("请输入正确的玩家ID")
        end
    else
        Toast.Show("请输入正确的玩家ID")
    end
end

--监听文本框输入
function UnionGameRecordPanel.OnInputFieldValueChanged(text)
    if this.isSearched then
        if string.IsNullOrEmpty(text) then
            this.isSearched = false
            this.searchId = 0
            this.SendRequestList(1)
        end
    end
end

--================================================================
--
--请求数据
function UnionGameRecordPanel.SendRequestList(pageIndex)
    UnionManager.SendGetGameRecord(this.userId, pageIndex, PageCount)
end

--
--更新数据
--4216->{"code":0,"data":{"allzj":20.8,"icon":"1","name":"测试342395","list":[],"userId":342395,"bigwin":1,"gamecount":2,"isonline":false},"cmd":4216}->
function UnionGameRecordPanel.UpdateDataList(data)
    this.pageIndex = data.pageIndex
    this.pageTotal = Functions.CheckPageTotal(data.allPage)
    this.SetMainItem(this.mainItem, data)

    this.pageLabel.text = tostring(this.pageIndex) .. "/" .. tostring(this.pageTotal)
    --
    local list = data.list
    if GetTableSize(list) > 0 then
        UIUtil.SetActive(this.loading, false)
        UIUtil.SetActive(this.noData, false)

        local item = nil
        local itemData = nil
        for i = 1, PageCount do
            itemData = list[i]
            item = this.items[i]
            if itemData ~= nil then
                this.SetItem(item, itemData)
            else
                if item.data ~= nil then
                    item.data = nil
                    UIUtil.SetActive(item.gameObject, false)
                end
            end
        end
    else
        UIUtil.SetActive(this.loading, false)
        UIUtil.SetActive(this.noData, true)
        local item = nil
        for i = 1, PageCount do
            item = this.items[i]
            if item.data ~= nil then
                item.data = nil
                UIUtil.SetActive(item.gameObject, false)
            end
        end
    end
end

--设置Item数据
function UnionGameRecordPanel.SetMainItem(item, data)
    item.data = data
    --
    UIUtil.SetActive(item.gameObject, true)
    if item.icon ~= data.icon then
        item.icon = data.icon
        Functions.SetHeadImage(item.headIcon, data.icon)
    end
    item.nameLabel.text = tostring(data.name)
    item.idLabel.text = "ID:" .. UnionData.GetUidString(data.userId)

    if data.isonline == true then
        item.label1.text = "在线"
        item.label1.color = ColorOnline
    else
        item.label1.text = "离线"
        item.label1.color = ColorOffline
    end
    item.label2.text = data.gamecount
    item.label3.text = math.ToRound(data.allzj, 2)
    item.label4.text = data.bigwin
end

--设置Item数据
function UnionGameRecordPanel.SetItem(item, data)
    --LogError("<color=aqua>data</color>", data)
    item.data = data
    --
    UIUtil.SetActive(item.gameObject, true)
    item.label1.text = Functions.GetGameNameText(data.gameId)
    item.label2.text = os.date("%y-%m-%d %H:%M", data.time / 1000)
    item.label3.text = tostring(data.roomNum)
    item.label3LineRectTransform.sizeDelta = Vector2.New(item.label3.preferredWidth, RoomCodeLineHeight)
    item.label4.text = tostring(data.js)
    item.label5.text = tostring(math.ToRound(data.zj, 2))

    if data.isWin == true then
        UIUtil.SetActive(item.bigWin, true)
        UIUtil.SetActive(item.label6Go, false)
    else
        UIUtil.SetActive(item.bigWin, false)
        UIUtil.SetActive(item.label6Go, true)
    end
end