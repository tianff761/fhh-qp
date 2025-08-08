Pin3JieSuanPanel = ClassPanel("Pin3JieSuanPanel")
local this = Pin3JieSuanPanel
this.againBtnClickTime = 0

local winColor = Color(183 / 255, 134 / 255, 65 / 255, 1)
local lostColor = Color(81 / 255, 114 / 255, 174 / 255, 1)

--args:101721协议data.data对象
function Pin3JieSuanPanel:OnOpened(args)
    local node = self:Find("Content/Node")
    this.btnLayout = node:Find("BtnLayout")
    self:AddOnClick(this.btnLayout:Find("BackBtn"), this.OnClickBackBtn)
    this.PlayAgainBtn = this.btnLayout:Find("PlayAgainBtn").gameObject
    UIUtil.SetText(node:Find("Time"), os.date("%Y-%m-%d %H:%M:%S", math.floor(args.endTime)))
    UIUtil.SetText(node:Find("RoomCode"), tostring(Pin3Data.roomId))
    UIUtil.SetText(node:Find("JuShu"), tostring(Pin3Data.curJuShu) .. '/' .. tostring(Pin3Data.GetRule(Pin3RuleType.juShu)))
    UIUtil.SetText(node:Find("DiFen"), tostring(Pin3Data.parsedRules.baseScore))
    this.OpenAction(node, args)
    this.Note = args.note
    self:AddOnClick(self.PlayAgainBtn, this.OnPlayAgainBtnClick)
    self:AddListenerEvent()
end

function Pin3JieSuanPanel.OpenAction(node, args)
    local itemTran = nil
    local itemData = nil
    local bg = nil
    local maxIndex = 0
    this.playerBGItems = {}
    for i = 1, 8 do
        itemTran = node:Find("PlayerItems/" .. tostring(i))
        if args.list ~= nil and args.list[i] ~= nil then
            itemData = args.list[i]
            UIUtil.SetActive(itemTran, true)
            bg = itemTran:Find("BG")
            UIUtil.SetText(bg:Find("Name"), tostring(Pin3Data.GetUserName(itemData.pId)))
            UIUtil.SetText(bg:Find("ID/Text"), tostring(itemData.pId))
            UIUtil.SetText(bg:Find("WinText"), tostring(itemData.winNum))
            UIUtil.SetText(bg:Find("LostText"), tostring(itemData.loseNum))

            if tonumber(itemData.winGold) >= 0 then
                UIUtil.SetText(bg:Find("AddScore"), "+"..tostring(itemData.winGold))
            else
                UIUtil.SetText(bg:Find("SubScore"), tostring(itemData.winGold))
            end

            UIUtil.SetActive(bg:Find("WinImage"), tonumber(itemData.winGold) >= 0)
            UIUtil.SetActive(bg:Find("LostImage"), tonumber(itemData.winGold) < 0)
            UIUtil.SetActive(bg:Find("AddScore"), tonumber(itemData.winGold) >= 0)
            UIUtil.SetActive(bg:Find("Self"), itemData.pId == Pin3Data.uid)
            UIUtil.SetActive(bg:Find("SubScore"), tonumber(itemData.winGold) < 0)
            UIUtil.SetActive(bg:Find("Background"), tonumber(itemData.winGold) < 0)
            UIUtil.SetActive(bg:Find("BigWiner"), itemData.isBigWin == 1)
            UIUtil.SetActive(bg:Find("Tyrant"), itemData.isBigLose == 1)
            Functions.SetHeadImage(bg:Find("Head/HeadMask/Image"):GetComponent(typeof(Image)), Pin3Data.GetHeadIcon(itemData.pId))
            if tonumber(itemData.winGold) < 0 then
                bg:Find("WinText"):GetComponent(TypeText).color = lostColor
                bg:Find("WinText/Text"):GetComponent(TypeText).color = lostColor
                bg:Find("LostText"):GetComponent(TypeText).color = lostColor
                bg:Find("LostText/Text"):GetComponent(TypeText).color = lostColor
            else
                bg:Find("WinText"):GetComponent(TypeText).color = winColor
                bg:Find("WinText/Text"):GetComponent(TypeText).color = winColor
                bg:Find("LostText"):GetComponent(TypeText).color = winColor
                bg:Find("LostText/Text"):GetComponent(TypeText).color = winColor
            end
            maxIndex = maxIndex + 1
            UIUtil.SetActive(bg.gameObject, false)
            table.insert(this.playerBGItems, bg)
        else
            UIUtil.SetActive(itemTran, false)
        end
    end
    this.SetMoveAnim(maxIndex)
end


--启动倒计时Timer,设置移动动画
function Pin3JieSuanPanel.SetMoveAnim(maxIndex)
    UIUtil.SetLocalScale(this.btnLayout.gameObject, 0, 0, 1)
    local startIndex = 0
    if this.bgMoveTimer == nil then
        this.bgMoveTimer = Timing.New(
        function ()
            if startIndex >= maxIndex then
                this.StopBGMoveTimer()
                return
            end
            startIndex = startIndex + 1
            local item = this.playerBGItems[startIndex]
            if item == nil then
                return
            end
            UIUtil.SetActive(item.gameObject, true)
            UIUtil.SetAnchoredPosition(item.gameObject, -50, 0)
            item.transform:DOLocalMoveX(0, 0.25, true):OnComplete(function ()
                if startIndex >= maxIndex then
                    this.btnLayout:DOScale(Vector3(1, 1, 1), 0.25)
                end
            end)
        end,
        0.15)
    end
    this.bgMoveTimer:Restart()
end

--停止倒计时Timer
function Pin3JieSuanPanel.StopBGMoveTimer()
    if this.bgMoveTimer ~= nil then
        this.bgMoveTimer:Stop()
        this.bgMoveTimer = nil
    end
end

function Pin3JieSuanPanel.OnPlayAgainBtnClick()
    if Time.realtimeSinceStartup - this.againBtnClickTime > 2 then
        this.againBtnClickTime = Time.realtimeSinceStartup
        if Pin3Data.groupId ~= 0 then
            this.StopBGMoveTimer()
            UnionManager.SendPlayAgain(Pin3Data.groupId, GameType.Pin3, this.Note, Pin3Data.parsedRules.baseScore)
        else
            Toast.Show("联盟不存在，加入游戏失败")
        end
    else
        Toast.Show("请稍后...")
    end
end

function Pin3JieSuanPanel:AddListenerEvent()
    AddEventListener(CMD.Tcp.Union.S2C_AGAIN, this.OnGetPlayAgainCallBack)
end

function Pin3JieSuanPanel.OnGetPlayAgainCallBack(data)
    if data.code == 0 then
        Pin3Manager.QuitRoom()
        this:Close()
    else
        UnionManager.ShowError(data.code)
    end
end

function Pin3JieSuanPanel.OnClickBackBtn()
    this.StopBGMoveTimer()
    Pin3Manager.QuitRoom()
end