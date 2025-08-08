UnionPlayableGamePanel = ClassPanel("UnionPlayableGamePanel")
local this = UnionPlayableGamePanel
--是否更新显示，用于在更新显示过程中，不处理Toggle的设置相应
this.isUpdateDisplay = false

--显示配置
local DisplayConfigs = {
    [GameType.Mahjong] = { isOn = true },
    [GameType.ErQiShi] = { isOn = true },
    [GameType.PaoDeKuai] = { isOn = true },
    [GameType.Pin5] = { isOn = true },
    [GameType.Pin3] = { isOn = true },
    [GameType.SDB] = { isOn = false },
    [GameType.LYC] = { isOn = true },
    [GameType.TP] = { isOn = true },
}

function UnionPlayableGamePanel:Awake()
    this = self
    local content = this:Find("Content")

    this.closeBtn = content:Find("Background/CloseBtn").gameObject
    this.okBtn = content:Find("OkButton").gameObject

    this.itemContent = content:Find("Games")
    this.itemPrefab = this.itemContent:Find("Item").gameObject
    this.items = {}
    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.okBtn, this.OnOkBtnClick)
end

function UnionPlayableGamePanel:OnOpened(args)
    this.playerId = args
    this.AddEventListener()
    this.SendGetPlayableGame()
end

function UnionPlayableGamePanel:OnClosed()
    this.RemoveEventListener()
end

--注册事件
function UnionPlayableGamePanel.AddEventListener()
    AddEventListener(CMD.Tcp.Union.S2C_ModifyPlayableGame, this.OnModifyPlayableGame)
    AddEventListener(CMD.Tcp.Union.S2C_GetPlayableGame, this.OnGetPlayableGame)
end

--移除事件
function UnionPlayableGamePanel.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.Union.S2C_ModifyPlayableGame, this.OnModifyPlayableGame)
    RemoveEventListener(CMD.Tcp.Union.S2C_GetPlayableGame, this.OnGetPlayableGame)
end

--================================================================
--
function UnionPlayableGamePanel.OnCloseBtnClick()
    this:Close()
end

--
function UnionPlayableGamePanel.OnOkBtnClick()
    this:Close()
end

--================================================================
--
-- unionId 联盟id
-- playerId 玩家id
-- gameId 游戏id 
-- op 操作 1禁止玩家玩这个游戏 2 允许玩家玩
function UnionPlayableGamePanel.SendModifyPlayableGame(gameId, op)
    local args = {
        unionId = UnionData.curUnionId,
        playerId = this.playerId,
        gameId = gameId,
        op = op,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_ModifyPlayableGame, args)
end

function UnionPlayableGamePanel.SendGetPlayableGame()
    local args = {
        unionId = UnionData.curUnionId,
        playerId = this.playerId,
    }
    SendTcpMsg(CMD.Tcp.Union.C2S_GetPlayableGame, args)
end

function UnionPlayableGamePanel.OnModifyPlayableGame(data)
    if data.code == 0 then
        --无
    else
        UnionManager.ShowError(data.code)
        this.SendGetPlayableGame()
    end
end

function UnionPlayableGamePanel.OnGetPlayableGame(data)
    if data.code == 0 then
        this.UpdateDisplay(data.data.list)
    else
        UnionManager.ShowError(data.code)
        this.UpdateDisplay({})
    end
end

--================================================================
--
function UnionPlayableGamePanel.UpdateDisplay(list)
    this.isUpdateDisplay = true

    local data = nil
    local config = nil
    local index = 0
    local item = nil
    local dataLength = #list
    for i = 1, dataLength do
        data = list[i]
        config = DisplayConfigs[data.gameId]
        if config ~= nil and config.isOn then
            index = index + 1
            item = this.items[index]
            if item == nil then
                item = this.CreateItem(index)
            end
            item.data = data
            item.label.text = GameConfig[data.gameId].Text
            item.toggle.isOn = data.can == 1
        end
    end

    for i = dataLength + 1, #this.items do
        item = this.items[i]
        if item.data ~= nil then
            item.data = nil
            UIUtil.SetActive(item.gameObject, false)
        end
    end

    this.isUpdateDisplay = false
end

function UnionPlayableGamePanel.CreateItem(index)
    local item = {}
    item.gameObject = CreateGO(this.itemPrefab, this.itemContent, tostring(index))
    item.transform = item.gameObject.transform
    item.label = item.transform:Find("Label"):GetComponent(TypeText)
    item.toggle = item.gameObject:GetComponent(TypeToggle)
    this:AddOnToggle(item.toggle, function(isOn) this.OnItemValueChanged(item, isOn) end)

    table.insert(this.items, item)
    return item
end

function UnionPlayableGamePanel.OnItemValueChanged(item, isOn)
    if this.isUpdateDisplay then
        return
    end
    local op = 1
    if isOn then
        op = 2
    end
    this.SendModifyPlayableGame(item.data.gameId, op)
end