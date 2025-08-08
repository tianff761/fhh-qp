ZongJieSuanPanel = ClassPanel("ZongJieSuanPanel")
local this = ZongJieSuanPanel

function ZongJieSuanPanel:Awake()
    this = self
end
function ZongJieSuanPanel:OnClosed()
    self.StopBGMoveTimer()
end


function ZongJieSuanPanel:OnOpened()
    --self:AddOnClick(self:Find('BtnLayout/ShareBtn'), this.OnClickShareBtn)
    local node = self:Find('Node')
    this.btnLayout = node:Find('BtnLayout')
    self:AddOnClick(node:Find('BtnLayout/BackButton'), function()
        EqsTools.ReturnToLobby()
    end)
    self:AddOnClick(node:Find('BtnLayout/PlayAgainBtn'), this.OnPlayAgainBtnClick)

    --图标
    local atlas = node:Find("Atlas"):GetComponent("UISpriteAtlas")
    local tempSprites = atlas.sprites:ToTable()
    local sprite = nil
    self.sprites = {}
    for i = 1, #tempSprites do
        sprite = tempSprites[i]
        if sprite ~= nil then
            self.sprites[sprite.name] = sprite
        else
            LogWarn(">> MahjongTotalSettlementPanel > sprite == nil > index = " .. i)
        end
    end
    BattleModule.zongJieSuanData = nil

    -- local data = BattleModule.zongJieSuanData
    -- this.Note = data.note
    -- BattleModule.zongJieSuanData = nil
    -- if not IsNumber(data.endTime) then
    --     data.endTime = os.time()
    -- end

    -- local playWayConfig = EqsConfig.GetPlayWayConfig(BattleModule.GetRule(EqsRuleType.RType))
    -- local playWayName = ""
    -- if playWayConfig ~= nil then
    --     playWayName = playWayConfig.name
    -- end
    
    -- --设置牌局基本描述
    -- local text = os.date("%y-%m-%d %H:%M:%S ", data.endTime)
    -- text = text .. playWayName
    -- text = text .. " 房号:" .. tostring(BattleModule.roomId)
    -- text = text .. " 圈" .. BattleModule.GetRule(EqsRuleType.QuanShu)
    -- UIUtil.SetText(self:Find("RoomInfo/TitleText"), text)

    --设置结算数据
    -- HideChildren(node:Find("Users"))
    local maxScore        = 0
    local maxDianPao        = 0
    local maxDianPaoTran    = nil
    local maxScoreTran    = nil

    this.itemBGList = {}
    local itemNode = node:Find('ItemNode')
    local idx = 1
    local maxIndex = 0
    for _, data in pairs(data.users) do
        data.score = tonumber(data.score)
        local uid = data.uid
        local userInfoCtrl = BattleModule.GetUserInfoByUid(uid)
        local item = itemNode:Find(tostring(idx))
        idx = idx + 1
        if userInfoCtrl ~= nil and item ~= nil then
            userInfoCtrl:SetScore(data.score)
            UIUtil.SetActive(item, true)
        
            local isMain = data.score >= 0
            local bg = item:Find('Bg')
            local bgImage = bg:GetComponent(TypeImage)
            local bgName = isMain and "ui_js_lb_2" or "ui_js_lb_1"
            bgImage.sprite = this.sprites[bgName]
            bgImage:SetNativeSize()

            EqsTools.SetHeadIcon(bg:Find("Head/HeadMask/Icon"), userInfoCtrl.headIcon)
            -- Functions.SetHeadFrame(unit.transform:Find("HeadIcon/Icon"):GetComponent("Image"), userInfoCtrl.frameId)

            UIUtil.SetActive(bg:Find('Self'), uid == BattleModule.uid)
            UIUtil.SetActive(bg:Find('IconWin'), false)
            UIUtil.SetActive(bg:Find('IconZjps'), false)
            UIUtil.SetActive(bg:Find('Owner'), userInfoCtrl:IsCreator())

            UIUtil.SetText(bg.transform:Find("Name"),            SubStringName(userInfoCtrl.name))
            UIUtil.SetText(bg.transform:Find("ID"),            tostring(userInfoCtrl.uid))

            -- UIUtil.SetText(unit.transform:Find("HuPai/HuPaiCiShu"),    tostring(item.hp))  --胡牌次数
            -- UIUtil.SetText(unit.transform:Find("DianPao/DianPaoCiShu"),    tostring(item.dp))  --点炮次数
            -- UIUtil.SetText(unit.transform:Find("HuShu/ZuiDaHuShu"),    tostring(item.mh))  --最大胡数
            -- UIUtil.SetText(unit.transform:Find("LianZhuang/ZuiDaLianZhuang"), tostring(item.lz))  --最大连庄


            local color = isMain and Color(183 / 255, 134 / 255, 65 / 255, 1) or Color(81 / 255, 114 / 255, 174 / 255, 1)
            local lineName = isMain and "ui_js_lb_2_fgx" or "ui_js_lb_1_fgx"

            local descNode = bg:Find("DescNode")
            local descList = {}
            for i = 1, 4, 1 do
                local list = {}
                list.tips = descNode:Find("Desc"..i.."/Tips"):GetComponent(TypeText)
                list.txt = descNode:Find("Desc"..i.."/Text"):GetComponent(TypeText)
                list.line = descNode:Find("Desc"..i.."/Line"):GetComponent(TypeImage)

                list.tips.color = color
                list.txt.color = color
                list.line.sprite = this.sprites[lineName]
                table.insert(descList, list)
            end

            --处理次数
            descList[1].txt.text = tostring(data.hp)
            descList[2].txt.text = tostring(data.dp)
            descList[3].txt.text = tostring(data.mh)
            descList[4].txt.text = tostring(data.lz)


            local shuText = bg.transform:Find("Score/SubTxt"):GetComponent(typeof(Text))
            local yinText = bg.transform:Find("Score/AddTxt"):GetComponent(typeof(Text))
            local scoreText = ""
            if data.score > 0 then
                scoreText = "+" .. tostring(data.score)
            else
                scoreText = tostring(data.score)
            end
            shuText.text = scoreText
            yinText.text = scoreText
            yinText.gameObject:SetActive(data.score >= 0)
            shuText.gameObject:SetActive(data.score < 0)

            --大赢家计算
            if maxScore < data.score then
                maxScore = data.score
                maxScoreTran = bg
            end

            --炮手计算
            if maxDianPao < data.dp then
                maxDianPao = data.dp
                maxDianPaoTran = bg
            end
            maxIndex = idx
            table.insert(this.itemBGList, bg)            
        else
            Log("结算时，不存在玩家：", uid)
        end
    end

    local dyjCount = 0
    local dpCount = 0
    for _, item in pairs(data.users) do
        if item.score == maxScore then
            dyjCount = dyjCount + 1
        end
        if item.dp == maxDianPao then
            dpCount = dpCount + 1
        end
    end
   
    if maxScoreTran then
        UIUtil.SetActive(maxScoreTran:Find('IconWin'), dyjCount == 1)
    end
    if maxDianPaoTran then
        UIUtil.SetActive(maxDianPaoTran:Find('IconZjps'), dpCount == 1)
    end
    this.SetMoveAnim(maxIndex)
end

function ZongJieSuanPanel.OnClickShareBtn()
    --分享截图
    local data = {
        roomCode = BattleModule.roomId,
        type = 2,
        ScreenshotScale = { w = 1226 - 26, h = 690 - 26 }
    }
    PanelManager.Open(PanelConfig.RoomInvite, data)
end

function ZongJieSuanPanel.OnPlayAgainBtnClick()
    --UnionManager.SendPlayAgain(GameType.ErQiShi, this.Note, BattleModule.GetRule(EqsRuleType.TeaBaseScore))
end

function ZongJieSuanPanel:AddListenerEvent()
    AddEventListener(CMD.Tcp.Union.S2C_AGAIN, this.OnGetPlayAgainCallBack)
end

function ZongJieSuanPanel.OnGetPlayAgainCallBack(data)
    if data.code == 0 then
        EqsTools.ReturnToLobby()
        this.Close()
    else
        UnionManager.ShowError(data.code)
    end
end


--启动倒计时Timer,设置移动动画
function ZongJieSuanPanel.SetMoveAnim(maxIndex)
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
            local itemBG = this.itemBGList[startIndex]
            if itemBG == nil then
                return
            end
            UIUtil.SetActive(itemBG.gameObject, true)
            UIUtil.SetAnchoredPosition(itemBG.gameObject, -50, 0)
            itemBG.bg.transform:DOLocalMoveX(0, 0.25, true):OnComplete(function ()
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
function ZongJieSuanPanel.StopBGMoveTimer()
    if this.bgMoveTimer ~= nil then
        this.bgMoveTimer:Stop()
        this.bgMoveTimer = nil
    end
end
