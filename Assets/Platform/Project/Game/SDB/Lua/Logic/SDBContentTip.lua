SDBContentTip = {}
local this = SDBContentTip
--倒计时类型
local countDownType = 0
--倒计时时间
local countDownTime = 0
--倒计时操作人员
local countDownOId = 0
--倒计时timer
local countDownTimer = nil
--是否暂停
local isPause = false

function SDBContentTip.UpdateData(type, time, oId)
    countDownType = type
    countDownTime = time
    countDownOId = oId
    if not isPause then
        this.UpdateImgTipsText("")
        this.UpdateGameCountDownText("")
        this.HandleGameProcess()
    end
    this.StopCountDown()
    this.CheckCountDown()
end

--更新提示文字
function SDBContentTip.UpdateImgTipsText(str)
    SDBRoomPanel.SetImgTipsText(str)
end

--更新上方倒计时
function SDBContentTip.UpdateGameCountDownText(str)
    SDBRoomPanel.SetGameCountDownText(str)
end

--暂停显示倒计时
function SDBContentTip.Pause()
    isPause = true
end

--继续显示倒计时
function SDBContentTip.Continue()
    isPause = false
end

--获取是否暂停显示倒计时
function SDBContentTip.GetIsPause()
    return isPause
end

--处理倒计时
function SDBContentTip.HandleGameProcess()
    if countDownTime < 0 then
        countDownTime = 0
    end
    if countDownType == CountOperationType.Ready then --准备倒计时
        this.HandleReady()
    elseif countDownType == CountOperationType.RobBanker then --抢庄倒计时
        this.HandleRobBanker()
    elseif countDownType == CountOperationType.BetScore then --下注倒计时
        this.HandleBetScore()
    elseif countDownType == CountOperationType.GetCard then --要牌倒计时
        this.HandleGetCard()
    elseif countDownType == CountOperationType.Dismiss then --解散倒计时
        this.HandleDismiss()
    elseif countDownType == CountOperationType.Start then --开局倒计时
        this.HandleStart()
    elseif countDownType == CountOperationType.ReadyQuit then --准备倒计时
        this.HandleReadyQuit()
    end
end

--开始倒计时
function SDBContentTip.CheckCountDown(data)
    countDownTimer = Scheduler.scheduleGlobal(function()
        if countDownTime ~= nil and countDownTime > 0 then
            countDownTime = countDownTime - 1
            if not isPause then
                this.HandleGameProcess()
            end
        end
    end, 1)
end

--停止倒计时
function SDBContentTip.StopCountDown()
    if not IsNil(countDownTimer) then
        Scheduler.unscheduleGlobal(countDownTimer)
        countDownTimer = nil
    end
end

--处理准备提示语
function SDBContentTip.HandleReady()
    this.UpdateImgTipsText("下一局即将开始：" .. countDownTime .. "秒")
end

--清空倒计时
function SDBContentTip.ClearCountDown()
    countDownType = 0
    countDownTime = 0
    countDownOId = 0
    this.UpdateImgTipsText("")
    this.UpdateGameCountDownText("")
    this.StopCountDown()
end

--清空提示的文字
function SDBContentTip.ClearTipText()
    this.UpdateImgTipsText("")
    this.UpdateGameCountDownText("")
end

--- ------------------------------------------------------
--处理抢庄提示语
function SDBContentTip.HandleRobBanker()
    local str = ""
    local mainPlayerData = SDBRoomData.GetSelfData()
    if not SDBRoomData.GetSelfIsLook() and mainPlayerData.robZhuangState == RobZhuangNumType.None then
        str = "请操作抢庄：" .. countDownTime .. "秒"
    else
        str = "请等待其他玩家抢庄：" .. countDownTime .. "秒"
    end
    this.UpdateImgTipsText(str)
end

--处理下注提示语
function SDBContentTip.HandleBetScore()
    local str = ""
    if countDownTime <= 10 then
        --有操作人员
        if not IsNil(countDownOId) and countDownOId > 0 then
            if countDownOId ~= SDBRoomData.mainId then
                local playerData = SDBRoomData.GetPlayerDataById(countDownOId)
                if IsNil(playerData) then
                    str = "请等待其他玩家下注：" .. countDownTime .. "秒"
                else
                    str = "请等待" .. playerData.name .. "下注：" .. countDownTime .. "秒"
                end
            else
                str = "请选择下注分：" .. countDownTime .. "秒"
            end
        else
            local mainPlayerData = SDBRoomData.GetSelfData()
            if SDBRoomData.MainIsBanker() or SDBRoomData.GetSelfIsLook() or (not IsNil(mainPlayerData.xiaZhuScore) and mainPlayerData.xiaZhuScore > 0) then
                str = "请等待其他玩家下注：" .. countDownTime .. "秒"
            else
                str = "请选择下注分：" .. countDownTime .. "秒"
            end
        end
    end
    this.UpdateImgTipsText(str)
end

--处理要牌提示语
function SDBContentTip.HandleGetCard()
    local str = ""
    --操作者是自己的情况
    if countDownOId == SDBRoomData.mainId then
        str = "要牌中：" .. countDownTime .. "秒"
    else
        local playerData = SDBRoomData.GetPlayerDataById(countDownOId)
        if playerData ~= nil then
            str = playerData.name .. "要牌中：" .. countDownTime .. "秒"
        end
    end
    this.UpdateImgTipsText(str)
end

--处理要牌提示语
function SDBContentTip.HandleDismiss()
    local dispanel = PanelManager.GetPanel(SDBPanelConfig.Dismiss)
    if not IsNil(dispanel) then
        dispanel:UpdateTimeText(countDownTime)
    end
    return
end

--处理开始提示语
function SDBContentTip.HandleStart()
    local str = ""
    -- if SDBRoomData.GetSelfIsLook() then
    --     return
    -- end
    if countDownTime == 0 then
        this.UpdateGameCountDownText("")
    else
        this.UpdateGameCountDownText(countDownTime)
        str = "游戏即将开始，未准备的玩家将被踢出房间"
    end
    this.UpdateImgTipsText(str)
end

--处理准备退出提示语
function SDBContentTip.HandleReadyQuit()
    local str = ""
    -- if SDBRoomData.GetSelfIsLook() then
    --     return
    -- end
    if countDownTime == 0 then
        this.UpdateGameCountDownText("")
    else
        this.UpdateGameCountDownText(countDownTime)
        str = "未准备的玩家将被踢出房间"
    end
    this.UpdateImgTipsText(str)
end

---------------------------------- 不存在倒计时的 ---------------------------------
--处理已坐下提示语 --只处理房卡场 --金币场有自己的提示
function SDBContentTip.HandleSitDown()
    if not SDBRoomData.IsGoldGame() then
        if SDBRoomData.gameIndex == 0 and not SDBRoomData.IsGoldGame() and not SDBRoomData.MainIsOwner() then
            local playerData = SDBRoomData.GetPlayerDataById(SDBRoomData.owner)
            if playerData ~= nil then
                this.UpdateImgTipsText("等待房主" .. playerData.name .. "开始...")
            end
        else
            this.UpdateImgTipsText("准备中...")
        end
    end
end

--处理观战状态提示语
function SDBContentTip.HandleLookOn()
    if SDBRoomData.isCardGameStarted then
        this.UpdateImgTipsText("旁观中...")
    else
        if SDBRoomData.MainIsOwner() then
            this.UpdateImgTipsText("等待其他玩家加入")
        end
    end
end

--处理检测到自己未准备时提示语 站立（未准备）
function SDBContentTip.HandleSelfNoReady()
    if not SDBRoomData.isCardGameStarted then
        if SDBRoomData.IsGoldGame() and countDownType ~= CountOperationType.Start and countDownType ~= CountOperationType.ReadyQuit then
            this.UpdateImgTipsText("准备中...")
        end
    end
end

--处理小结算时提示语
function SDBContentTip.HandleXiaoJieSuan()
    if not SDBRoomData.isCardGameStarted then
        if countDownType ~= CountOperationType.Start and countDownType ~= CountOperationType.ReadyQuit then
            if countDownType ~= CountOperationType.Dismiss and SDBRoomData.IsGoldGame() then
                this.ClearCountDown()
                this.UpdateImgTipsText("比牌中...")
            end
        end
    end
end

--处理总结算时提示语
function SDBContentTip.HandleZongJieSuan()
    if not SDBRoomData.isCardGameStarted then
        if countDownType ~= CountOperationType.Start and countDownType ~= CountOperationType.ReadyQuit then
            if countDownType ~= CountOperationType.Dismiss then
                this.ClearCountDown()
            end
            this.UpdateImgTipsText("")
        end
    end
end

return SDBContentTip