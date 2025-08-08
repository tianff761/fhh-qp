TpTotalSettlementPanel = ClassPanel("TpTotalSettlementPanel")
TpTotalSettlementPanel.Instance = nil
--
local this = TpTotalSettlementPanel
this.againBtnClickTime = 0

local color1 = Color(1, 161/255, 18/255)
local color2 = Color(33/255, 178/255, 1)

--
--初始属性数据
function TpTotalSettlementPanel:InitProperty()
    self.items = {}
end

--UI初始化
function TpTotalSettlementPanel:OnInitUI()
    this = self
    this:InitProperty()

    local node = self:Find("Node")
    local content = node:Find("Content")

    this.infoLabel = content:Find("InfoTxt"):GetComponent(TypeText)
    this.againBtn = content:Find("Layout/AgainBtn").gameObject
    this.backBtn = content:Find("Layout/BackBtn").gameObject

    this.itemContent = content:Find("ScrollView/Viewport/Content")
    this.itemContentRectTransform = this.itemContent:GetComponent(TypeRectTransform)
    this.layoutElement = this.itemContent:GetComponent(TypeLayoutElement)
    this.layoutElement.minWidth = UIConst.uiCanvasWidth
    this.itemPrefab = this.itemContent:Find("Item").gameObject

    this.AddUIListenerEvent()
end

--当面板开启开启时
function TpTotalSettlementPanel:OnOpened()
    self:AddListenerEvent()

    this.data = TpDataMgr.settlementData
    if this.data == nil then
        this.data = {}
        Alert.Show("请到战绩界面查看结算数据")
    end
    this.UpdateDataDisplay()

    UIUtil.SetActive(this.againBtn, TpDataMgr.groupId ~= 0 and not TpDataMgr.isPlayback)
end

--当面板关闭时调用
function TpTotalSettlementPanel:OnClosed()
    self:RemoveListenerEvent()
end

------------------------------------------------------------------
--
--关闭
function TpTotalSettlementPanel.Close()
    PanelManager.Close(TpPanelConfig.TotalSettlement)
end

--
function TpTotalSettlementPanel.AddListenerEvent()

end

--
function TpTotalSettlementPanel.RemoveListenerEvent()

end

--UI相关事件
function TpTotalSettlementPanel.AddUIListenerEvent()
    this:AddOnClick(this.againBtn, this.OnAgainBtnClick)
    this:AddOnClick(this.backBtn, this.OnBackBtnClick)
end

------------------------------------------------------------------
--
--再来一局
function TpTotalSettlementPanel.OnAgainBtnClick()
    if Time.realtimeSinceStartup - this.againBtnClickTime > 2 then
        this.againBtnClickTime = Time.realtimeSinceStartup
        if TpDataMgr.groupId ~= 0 and TpDataMgr.settlementData ~= nil then
            LogError(">> TpTotalSettlementPanel.OnAgainBtnClick", TpDataMgr.groupId, GameType.Tp, TpDataMgr.settlementData.note, TpDataMgr.baseScore)
            UnionManager.SendPlayAgain(TpDataMgr.groupId, GameType.Tp, TpDataMgr.settlementData.note, TpDataMgr.baseScore)
            Waiting.Show("加入游戏中，请等待...", nil, 2)
        else
            Toast.Show("加入游戏失败，请重新选择房间")
        end
    else
        Toast.Show("请稍后...")
    end
end

--返回大厅按钮点击
function TpTotalSettlementPanel.OnBackBtnClick()
    TpRoomMgr.ExitRoom()
end

------------------------------------------------------------------
--

--更新数据
--{"cmd":105121,"code":0,"data":{"endTime":1723432630.198,"list":[{"pId":302053,"isBigWin":0,"isBigLose":1,"winGold":"-10","tieNum":"0","loseNum":"7","winNum":"1"},{"pId":302050,"isBigWin":1,"isBigLose":0,"winGold":"14","tieNum":"0","loseNum":"3","winNum":"5"},{"pId":302051,"isBigWin":0,"isBigLose":0,"winGold":"-4","tieNum":"0","loseNum":"6","winNum":"2"}],"note":"dz7"}}
function TpTotalSettlementPanel.UpdateDataDisplay()
    LogError(">> TpTotalSettlementPanel.UpdateDataDisplay", this.data)
    --
    local list = this.data.list or {}

    local dataLength = #list
    local item = nil
    local data = nil
    local selfIndex = 1
    for i = 1, dataLength do
        data = list[i]
        item = this.GetItem(i)
        --
        if data.pId == TpDataMgr.userId then
            selfIndex = i
        end
        --
        local winGold = tonumber(data.winGold)
        if winGold > 0 then
            UIUtil.SetActive(item.bgWinGo, true)
            UIUtil.SetActive(item.bgLoseGo, false)
            UIUtil.SetActive(item.winLabelGo, true)
            UIUtil.SetActive(item.loseLabelGo, false)

            item.winLabel.text = "+" .. winGold
            item.nameLabel.color = color1
            item.idLabel.color = color1
        else
            UIUtil.SetActive(item.bgWinGo, false)
            UIUtil.SetActive(item.bgLoseGo, true)
            UIUtil.SetActive(item.winLabelGo, false)
            UIUtil.SetActive(item.loseLabelGo, true)
            item.loseLabel.text = tostring(winGold)
            item.nameLabel.color = color2
            item.idLabel.color = color2
        end

        Functions.SetHeadImage(item.headImage, data.img)
        item.nameLabel.text = data.name
        item.idLabel.text = "ID:" .. data.pId


        item.label1.text = data.winNum
        item.label2.text = data.loseNum
        item.label3.text = data.tieNum
        --
        item.data = data
        UIUtil.SetActive(item.gameObject, true)
    end

    for i = dataLength + 1, #this.items do
        item = this.items[i]
        if item.data ~= nil then
            item.data = nil
            UIUtil.SetActive(item.gameObject, false)
        end
    end

    local temp = math.floor(UIConst.uiCanvasWidth / (178 + 20))
    if selfIndex > temp then
        local tempWidth = (selfIndex - temp) * (178 + 20)
        this.itemContentRectTransform.anchoredPosition = Vector2(-tempWidth, 0)
    else
        this.itemContentRectTransform.anchoredPosition = Vector2.zero
    end

    --显示规则
    local gameName = GameConfig[GameType.TP].Text
    local time = os.date("%m/%d %H:%M", data.endTime)
    local qianZhu = TpConfig.GetQianZhuByRule(TpDataMgr.rules)
    local roomCode = TpDataMgr.roomId
    this.infoLabel.text =  string.format("%s　%s　前注：%s　房间号：%s", gameName, time, qianZhu, roomCode)
end

--获得显示项
function TpTotalSettlementPanel.GetItem(index)
    local item = this.items[index]
    if item == nil then
        item = {}
        item.gameObject = CreateGO(this.itemPrefab, this.itemContent, tostring(index))
        item.transform = item.gameObject.transform
        item.bgWinGo = item.transform:Find("BgWin").gameObject
        item.bgLoseGo = item.transform:Find("BgLose").gameObject
        item.headImage = item.transform:Find("HeadMask/Head"):GetComponent(TypeImage)
        item.nameLabel = item.transform:Find("NameText"):GetComponent(TypeText)
        item.idLabel = item.transform:Find("IdText"):GetComponent(TypeText)

        item.label1 = item.transform:Find("Text1/Text"):GetComponent(TypeText)
        item.label2 = item.transform:Find("Text2/Text"):GetComponent(TypeText)
        item.label3 = item.transform:Find("Text3/Text"):GetComponent(TypeText)

        item.loseLabelGo = item.transform:Find("TextLose").gameObject
        item.loseLabel = item.loseLabelGo:GetComponent(TypeText)
        item.winLabelGo = item.transform:Find("TextWin").gameObject
        item.winLabel = item.winLabelGo:GetComponent(TypeText)

        table.insert(this.items, item)
    end
    return item
end
