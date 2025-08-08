UnionNodeScoreGet = {}
local this = UnionNodeScoreGet

function UnionNodeScoreGet.Init(transform)
    this.transform = transform
    this.gameObject = transform.gameObject
    this.isInitUI = false
    this.ItemList = {}
end

function UnionNodeScoreGet.CheckUI()
    if this.isInitUI then
        return
    end
    this.isInitUI = true
    this.content = this.transform:Find("ScrollView/Viewport/Content")
    this.item = this.content:Find("Item").gameObject
    this.Score = this.transform:Find("ScoreLabel/Score"):GetComponent(TypeText)
    this.GetBtn = this.transform:Find("GetBtn"):GetComponent(TypeButton)
    this.AddUIEventListener()
end

function UnionNodeScoreGet.Open()
    this.CheckUI()
    this.AddEventListener()
    this.SendInfoReq()
end

function UnionNodeScoreGet.Close()
    this.RemoveEventListener()
end

function UnionNodeScoreGet.SendInfoReq()
    SendTcpMsg(CMD.Tcp.C2S_GetLeftLuckyValue, { groupId = UnionData.curUnionId, isBD = 0 })
end

------------------------------------------------------------------
--
--注册事件
function UnionNodeScoreGet.AddEventListener()
    AddEventListener(CMD.Tcp.S2C_GetLeftLuckyValue, this.OnTcpGetCurLuckyValue)
    AddEventListener(CMD.Tcp.S2C_SaveAndGetLuckyValue, this.UpdatePanel)
end

--移除事件
function UnionNodeScoreGet.RemoveEventListener()
    RemoveEventListener(CMD.Tcp.S2C_GetLeftLuckyValue, this.OnTcpGetCurLuckyValue)
    RemoveEventListener(CMD.Tcp.S2C_SaveAndGetLuckyValue, this.UpdatePanel)
end

--UI相关事件
function UnionNodeScoreGet.AddUIEventListener()
    EventUtil.AddOnClick(this.GetBtn, this.OnClickGetLuckValue)
end

function UnionNodeScoreGet.OnTcpGetCurLuckyValue(data)
    if data.code == 0 then
        this.curLuckyValue = data.data.luckyNum
        this.poolLuckValue = tonumber(math.PreciseDecimal(data.data.luckyPool, 2))
        this.ScoreList = data.data.list
        this.Score.text = tonumber(math.PreciseDecimal(data.data.luckyPool, 2))
        local dataLength = #this.ScoreList
        local item = nil
        local itemData = nil
        for i = 1, dataLength do
            item = this.GetItem(i)
            itemData = this.ScoreList[i]
            item.data = itemData
            --
            item.timeLabel.text = os.date("%Y-%m-%d", itemData.time / 1000)
            local active = not itemData.draw
            item.btnLabel.text = active and "领取" or "已领取"
            item.button.interactable = active
            item.scoreLabel.text = tostring(itemData.face)
            UIUtil.SetActive(item.gameObject, true)
        end
        for i = dataLength + 1, #this.ItemList do
            item = this.ItemList[i]
            if item.data ~= nil then
                item.data = nil
                UIUtil.SetActive(item.gameObject, false)
            end
        end
    else
        UnionManager.ShowError(data.code)
    end
end

function UnionNodeScoreGet.GetItem(index)
    local result = this.ItemList[index]
    if result == nil then
        local item = {}
        item.index = index
        table.insert(this.ItemList, item)
        item.gameObject = CreateGO(this.item, this.content, tostring(index))
        item.transform = item.gameObject.transform
        item.timeLabel = item.transform:Find("time"):GetComponent(TypeText)
        local btn = item.transform:Find("GetBtn")
        item.btnLabel = btn:Find("Text"):GetComponent(TypeText)
        item.button = btn:GetComponent(TypeButton)
        item.scoreLabel = item.transform:Find("score"):GetComponent(TypeText)

        EventUtil.AddOnClick(btn, function() this.OnItemGetBtnClick(item) end)

        result = item
    end
    return result
end

--
function UnionNodeScoreGet.OnItemGetBtnClick(item)
    this.SendPutAndGetLuckyValue(2, item.data.face, UnionData.curUnionId, item.index - 1, 0)
end

function UnionNodeScoreGet.OnClickGetLuckValue()
    Alert.Prompt("是否取出全部积分？", function()
        this.SendPutAndGetLuckyValue(2, this.poolLuckValue, UnionData.curUnionId)
    end)
end

---@param opDay number 0 表示今天 1 表示昨天 2 表示前天
function UnionNodeScoreGet.SendPutAndGetLuckyValue(type, num, groupId, opDay, isBD)
    local args = {
        opType = type,
        opNum = num,
        groupId = groupId,
        opDay = opDay,
        isBD = isBD,
    }
    SendTcpMsg(CMD.Tcp.C2S_SaveAndGetLuckyValue, args)
end

function UnionNodeScoreGet.UpdatePanel(data)
    if data.code == 0 then
        Toast.Show("操作成功")
        this.SendInfoReq()
    else
        UnionManager.ShowError(data.code)
    end
end