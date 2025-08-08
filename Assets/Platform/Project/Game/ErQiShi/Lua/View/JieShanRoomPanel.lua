JieShanRoomPanel = ClassPanel("JieShanRoomPanel")
JieShanRoomPanel.agreeBtn = nil
JieShanRoomPanel.refuseBtn = nil
local this = JieShanRoomPanel

function JieShanRoomPanel:Awake()
    this = self
end


function JieShanRoomPanel:OnOpened(data)
    self.agreeBtn = self:Find("AgreeBtn")
    self.refuseBtn = self:Find("RefuseBtn")
    self:AddOnClick(self.agreeBtn, function ()
        BattleModule.SendTouPiaoJieShanRoom(1)
    end)

    self:AddOnClick(self.refuseBtn, function ()
        BattleModule.SendTouPiaoJieShanRoom(0)
    end)

    self:Update(data)
end

function JieShanRoomPanel:Update(data)
    local allTy = true
    local apyUserCtrl = BattleModule.GetUserInfoByUid(data.apyUid)
    if apyUserCtrl ~= nil then
        UIUtil.SetText(self:Find("MainText"), "玩家"..tostring(apyUserCtrl.name).."申请解散房间，等待其他玩家选择")
        self:BeginDaoJiShi(data.leftTime)
        local userCnt = self:Find("Content")
        HideChildren(userCnt)
        if IsTable(data.users) then
            for _, userData in pairs(data.users) do
                local userCtrl = BattleModule.GetUserInfoByUid(userData.uid)
                if userCtrl ~= nil then
                    local item = userCnt:Find("User"..tostring(userCtrl.uiIdx))
                    if item ~= nil then
                        UIUtil.SetActive(item, true)
                        
                        EqsTools.SetHeadIcon(item:Find("HeadIcon"), userCtrl.headIcon)

                        Functions.SetHeadFrame(item:Find("HeadIcon/HeadBoard"):GetComponent("Image"), userCtrl.frameId)
                        -- UIUtil.SetText(item:Find("Name"), userCtrl.name)
                        UIUtil.SetText(item:Find("Name"), tostring(userCtrl.uid))
                        local text = item:Find("Operation"):GetComponent("Text")
                        if userData.status == -1 then
                            text.text = "投票中"
                            text.color = Color(1, 0, 0, 1)
                            allTy = false
                            if userCtrl:IsSelf() then
                                UIUtil.SetActive(self.agreeBtn,  true)
                                UIUtil.SetActive(self.refuseBtn, true)
                            end
                        elseif userData.status == 1 then
                            text.text = "同意解散"
                            text.color = Color(0.07, 0.65, 0.12, 1)
                            if userCtrl:IsSelf() then
                                UIUtil.SetActive(self.agreeBtn,  false)
                                UIUtil.SetActive(self.refuseBtn, false)
                            end
                        elseif userData.status == 0 then
                            text.text = "拒绝解散"
                            Toast.Show( userCtrl.name..'拒绝解散房间')
                            self:Close()
                            return 
                        end
                    end
                end
            end
        end
    end

    if allTy then
        self:Close()
        Toast.Show("房间已解散")
    end
end

local leftTimeHandle = nil
function JieShanRoomPanel:BeginDaoJiShi(leftTime)
    this.leftTime = leftTime
    Scheduler.unscheduleGlobal(leftTimeHandle)
    Log("倒计时1111：", this.leftTime)
    if this.leftTime > 0 then
        this.daoJiShiText = self:Find("DaoJiShiText"):GetComponent("Text")
        this.daoJiShiText.text = tostring(this.leftTime) .. "秒"
        leftTimeHandle = Scheduler.scheduleGlobal(function()
            Log("倒计时：", this.leftTime)
            if not IsNull(this.daoJiShiText) then
                this.leftTime = this.leftTime - 1
                this.daoJiShiText.text = tostring(this.leftTime) .. "秒"
                if this.leftTime <= 0 then
                    Scheduler.unscheduleGlobal(leftTimeHandle)
                    self:Close()
                end
            end
        end, 1)
    else
        self:Close()
    end  
end

function JieShanRoomPanel:OnClosed()
    Log("JieShanRoomPanel:OnClosed")
    Scheduler.unscheduleGlobal(leftTimeHandle)
end