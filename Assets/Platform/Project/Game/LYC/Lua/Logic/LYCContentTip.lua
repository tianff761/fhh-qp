LYCContentTip = {}
local this = LYCContentTip
--倒计时类型
local countDownType = 0
--倒计时时间
local countDownTime = 0
--倒计时timer
local countDownTimer = nil
--是否暂停
local isPause = false

function LYCContentTip.UpdateData(type, time)
    -- LogError("捞腌菜倒计时type ", type)
    -- LogError("倒计时", time)
    LYCRoomPanel.SetClockActive(false)
    if time < 0 then
        time = 0
    end
    countDownType = type
    countDownTime = time
    if not isPause then
        this.UpdateImgTipsText("")
        this.UpdateGameCountDownText("")
        this.HandleGameProcess()
    end
    this.StopCountDown()
    this.CheckCountDown()
end

--更新提示文字
function LYCContentTip.UpdateImgTipsText(str)
    LYCRoomPanel.SetImgTipsText(str)
end

--更新上方倒计时
function LYCContentTip.UpdateGameCountDownText(str)
    LYCRoomPanel.SetGameCountDownText(tostring(str))
end

function LYCContentTip.UpdateClockText(countDown, label)
    LYCRoomPanel.UpdateClockText(countDown, label)
end

--暂停显示倒计时
function LYCContentTip.Pause()
    isPause = true
end

--继续显示倒计时
function LYCContentTip.Continue()
    isPause = false
end

--获取是否暂停显示倒计时
function LYCContentTip.GetIsPause()
    return isPause
end

--处理倒计时
function LYCContentTip.HandleGameProcess()
    if countDownType == LYCGameState.WAITTING then
        --准备倒计时
        this.HandleReady()
    elseif countDownType == LYCGameState.ROB_ZHUANG then
        --抢庄倒计时
        this.HandleRobBanker()
    elseif countDownType == LYCGameState.BETTING then
        --下注倒计时
        this.HandleBetScore()
    elseif countDownType == LYCGameState.WATCH_CARD_1 then
        --看牌1 等待庄家操作
        this.HandleWatchCardFirstStep()
    elseif countDownType == LYCGameState.WATCH_CARD_2 then
        --看牌2 等待闲家操作
        this.HandleWatchCardSecondStep()
    elseif countDownType == LYCGameState.COMPARE_CARD then
        --庄家捞牌 / 庄家比牌中
        this.HandleCompareCardTip()
    elseif countDownType == CountOperationType.Dismiss then
        --解散倒计时
        this.HandleDismiss()
    elseif countDownType == LYCGameState.CALCULATE then
        --开局倒计时
        this.HandleStart()
    elseif countDownType == CountOperationType.ReadyQuit then
        --准备倒计时
        this.HandleReadyQuit()
    end
end

--开始倒计时
function LYCContentTip.CheckCountDown(data)
    countDownTimer = Scheduler.scheduleGlobal(function()
        if countDownTime ~= nil and countDownTime > 0 and not LYCRoomData.isGameOver then
            countDownTime = countDownTime - 1
            if not isPause then
                this.HandleGameProcess()
            end

            if countDownTime <= 0 then
                this.StopCountDown()
            end
        end
    end, 1)
end

--停止倒计时
function LYCContentTip.StopCountDown()
    if not IsNil(countDownTimer) then
        Scheduler.unscheduleGlobal(countDownTimer)
        countDownTimer = nil
    end
end

--处理准备提示语
function LYCContentTip.HandleReady()
    --if not LYCRoomData.IsFangKaFlow() then
    --    this.UpdateImgTipsText("下一局即将开始：" .. countDownTime .. "秒")
    --else
    --    --if LYCRoomData.IsGameStarted() then
    --    this.UpdateImgTipsText("下一局即将开始：" .. countDownTime .. "秒")
    --    --else
    --    --    this.UpdateImgTipsText("等待玩家加入")
    --    --end
    --end
    -- this.UpdateClockText(countDownTime, "即将开始")
end

--清空倒计时
function LYCContentTip.ClearCountDown()
    countDownType = 0
    countDownTime = 0
    this.UpdateImgTipsText("")
    this.UpdateGameCountDownText("")
    this.StopCountDown()
end

--清空提示的文字
function LYCContentTip.ClearTipText()
    this.UpdateImgTipsText("")
    this.UpdateGameCountDownText("")
end

--- ------------------------------------------------------
--处理抢庄提示语
function LYCContentTip.HandleRobBanker()
    local str = "抢庄：" .. countDownTime .. "秒"
    --this.UpdateImgTipsText(str)
    this.UpdateClockText(countDownTime, "抢庄")
end

--处理下注提示语
function LYCContentTip.HandleBetScore()
    local str = "下注：" .. countDownTime .. "秒"
    --this.UpdateImgTipsText(str)
    this.UpdateClockText(countDownTime, "下注")
end

--处理看牌提示语1
function LYCContentTip.HandleWatchCardFirstStep()
    --其他玩家正在捞牌，隐藏倒计时
    if LYCRoomPanel.GetPlaySelfLaoEffect() and countDownTime > 15 then
        LYCRoomPanel.SetClockActive(false)
        return
    end
    this.UpdateClockText(countDownTime, "等待玩家操作")
end

--处理看牌提示语2
function LYCContentTip.HandleWatchCardSecondStep()
    --其他玩家正在捞牌，隐藏倒计时
    if LYCRoomPanel.GetPlaySelfLaoEffect() and countDownTime > 15 then
        LYCRoomPanel.SetClockActive(false)
        return
    end
    this.UpdateClockText(countDownTime, "等待闲家操作")
end

---处理比牌阶段提示
function LYCContentTip.HandleCompareCardTip()
    --其他玩家正在捞牌，隐藏倒计时
    if LYCRoomPanel.GetPlaySelfLaoEffect() and countDownTime > 15 then
        LYCRoomPanel.SetClockActive(false)
        return
    end
    this.UpdateClockText(countDownTime, "等待庄家操作")
end

--处理要牌提示语
function LYCContentTip.HandleDismiss()
    local dispanel = PanelManager.GetPanel(LYCPanelConfig.Dismiss)
    if not IsNil(dispanel) then
        dispanel:UpdateTimeText(countDownTime)
    end
end

--处理开始提示语
function LYCContentTip.HandleStart()
    local str = ""
    if countDownTime == 0 then
        this.UpdateGameCountDownText("")
    else
        --this.UpdateGameCountDownText(countDownTime)
        str = "游戏即将开始，未准备的玩家将被踢出房间"
    end
    this.UpdateImgTipsText(str)
end

--处理准备退出提示语
function LYCContentTip.HandleReadyQuit()
    local str = ""
    if countDownTime == 0 then
        this.UpdateGameCountDownText("")
    else
        --this.UpdateGameCountDownText(countDownTime)
        str = "未准备的玩家将被踢出房间"
    end
    this.UpdateImgTipsText(str)
end
---------------------------------- 不存在倒计时的 ---------------------------------
--处理观战状态提示语
function LYCContentTip.HandleLookOn()
    if LYCRoomData.isCardGameStarted then
        this.UpdateImgTipsText("旁观中...")
    else
        if LYCRoomData.MainIsOwner() then
            this.UpdateImgTipsText("等待其他玩家加入")
        end
    end
end

--处理检测到自己未准备时提示语 站立（未准备）
function LYCContentTip.HandleSelfNoReady()
    if not LYCRoomData.isCardGameStarted and not LYCRoomData.isGameOver then
        if LYCRoomData.IsGoldGame() then
            this.UpdateImgTipsText("准备中...")
        end
    end
end

--处理小结算时提示语
function LYCContentTip.HandleXiaoJieSuan()
    if not LYCRoomData.isCardGameStarted then
        if countDownType ~= CountOperationType.Start and countDownType ~= CountOperationType.ReadyQuit then
            if countDownType ~= CountOperationType.Dismiss and LYCRoomData.IsGoldGame() then
                this.ClearCountDown()
                this.UpdateImgTipsText("比牌中...")
            end
        end
    end
end

--处理总结算时提示语
function LYCContentTip.HandleZongJieSuan()
    if not LYCRoomData.isCardGameStarted then
        if countDownType ~= CountOperationType.Start and countDownType ~= CountOperationType.ReadyQuit then
            if countDownType ~= CountOperationType.Dismiss then
                this.ClearCountDown()
            end
            this.UpdateImgTipsText("")
        end
    end
end

return LYCContentTip