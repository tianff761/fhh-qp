PdkDissRoomPanel = ClassPanel("PdkDissRoomPanel")
local this = PdkDissRoomPanel

function PdkDissRoomPanel:OnInitUI()
    this = self
    local content = this.transform:Find("Content")
    this.mainText = content:Find("MainText"):GetComponent("Text")
    this.timeText = content:Find("DaoJiShiText"):GetComponent("Text")
    this.agreeBtn = content:Find("AgreeBtn"):GetComponent("Button")
    this.refuseBtn = content:Find("RefuseBtn"):GetComponent("Button")

    this.players = {}
    local tran = nil
    for i = 1, 4 do
        local player = {}
        tran = content:Find("Content/User" .. i)
        player.obj = tran.gameObject
        player.nameText = tran:Find("Name"):GetComponent("Text")
        player.headImage = tran:Find("HeadIcon"):GetComponent("Image")
        player.headBox = tran:Find("HeadIcon/HeadBoard"):GetComponent("Image")
        player.operation = tran:Find("Operation"):GetComponent("Text")
        table.insert(this.players, player)
    end
    this:AddListener()
end

function PdkDissRoomPanel:OnOpened(data)
    this:Update(data)
end

function PdkDissRoomPanel:AddListener()
    this:AddOnClick(
        this.agreeBtn,
        function()
            PdkRoomModule.SendVoteAction(1)
        end
    )
    this:AddOnClick(
        this.refuseBtn,
        function()
            PdkRoomModule.SendVoteAction(0)
        end
    )
end

function PdkDissRoomPanel:Update(data)
    local allTy = true
    this:BeginDaoJiShi(data.countDown)
    this.mainText.text = "玩家" .. tostring(data.playerName) .. "申请解散房间，等待其他玩家选择"
    -- local temp = nil
    -- local player = nil
    -- local info = nil
    for i = 1, #data.list do
        local player = this.players[i]
        UIUtil.SetActive(player.obj,true)
        local temp = data.list[i]
        player.nameText.text = temp.playerName
        local playerData = PdkRoomModule.GetPlayerInfoById(temp.playerId)
        --self.players[i].headImage = headUrl
        if playerData ~= nil then
            Functions.SetHeadImage(player.headImage, playerData.playerHead)
            Functions.SetHeadFrame(player.headBox, playerData.playerTxk)
        else
            LogError("玩家信息不存在：", temp.playerId)
        end
        if temp.isAgree == -1 then
            player.operation.text = "投票中"
            player.operation.color = Color(1, 0, 0, 1)
            allTy = false
            if PdkRoomModule.IsSelfByID(temp.playerId) then
                UIUtil.SetActive(this.agreeBtn.gameObject, true)
                UIUtil.SetActive(this.refuseBtn.gameObject, true)
            end
        elseif temp.isAgree == 0 then
            player.operation.text = "拒绝解散"
            Toast.Show(temp.playerName .. "拒绝解散房间")
            this:Close()
            return
        elseif temp.isAgree == 1 then
            player.operation.text = "同意解散"
            player.operation.color = Color(0.07, 0.65, 0.12, 1)
            if PdkRoomModule.IsSelfByID(temp.playerId) then
                UIUtil.SetActive(this.agreeBtn.gameObject, false)
                UIUtil.SetActive(this.refuseBtn.gameObject, false)
            end
        end
    end
    if allTy then
        this:Close()
        -- Toast.Show("房间已解散")
    end
end

local countDownHandle = nil
function PdkDissRoomPanel:BeginDaoJiShi(countDown)
    this.countDown = countDown
    Scheduler.unscheduleGlobal(countDownHandle)
    if this.countDown > 0 then
        this.timeText.text = tostring(this.countDown) .. "秒"
        countDownHandle =
            Scheduler.scheduleGlobal(
            function()
                if not IsNull(this.timeText) then
                    this.countDown = this.countDown - 1
                    this.timeText.text = tostring(this.countDown) .. "秒"
                    if this.countDown <= 0 then
                        Scheduler.unscheduleGlobal(countDownHandle)
                    end
                end
            end,
            1
        )
    end
end

function PdkDissRoomPanel:OnClosed()
    Scheduler.unscheduleGlobal(countDownHandle)
    local player = nil
    for i = 1, #this.players do
        player = this.players[i]
        UIUtil.SetActive(player.obj, false)
    end
end
