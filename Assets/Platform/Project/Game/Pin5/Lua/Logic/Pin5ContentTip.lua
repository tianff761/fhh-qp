Pin5ContentTip = {}
local this = Pin5ContentTip
--倒计时类型
local countDownType = 0
--倒计时时间
local countDownTime = 0
--倒计时timer
local countDownTimer = nil
--是否暂停
local isPause = false

function Pin5ContentTip.UpdateData(type, time)
    --LogError("倒计时type", type)
    --LogError("倒计时", time)
    Pin5RoomPanel.SetTipsDisplay(false)
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
function Pin5ContentTip.UpdateImgTipsText(str)
    Pin5RoomPanel.SetImgTipsText(str)
end

--更新上方倒计时
function Pin5ContentTip.UpdateGameCountDownText(str)
    Pin5RoomPanel.SetGameCountDownText(tostring(str))
end

function Pin5ContentTip.UpdateClockText(countDown, label)
    Pin5RoomPanel.UpdateClockText(countDown, label)
end

--暂停显示倒计时
function Pin5ContentTip.Pause()
    isPause = true
end

--继续显示倒计时
function Pin5ContentTip.Continue()
    isPause = false
end

--获取是否暂停显示倒计时
function Pin5ContentTip.GetIsPause()
    return isPause
end

--处理倒计时
function Pin5ContentTip.HandleGameProcess()
    if countDownType == Pin5GameState.WAITTING then
        --准备倒计时
        this.HandleReady()
    elseif countDownType == Pin5GameState.ROB_ZHUANG then
        --抢庄倒计时
        this.HandleRobBanker()
    elseif countDownType == Pin5GameState.BETTING then
        --下注倒计时
        this.HandleBetScore()
    elseif countDownType == Pin5GameState.WATCH_CARD then
        --要牌倒计时
        this.HandleGetCard()
    elseif countDownType == CountOperationType.Dismiss then
        --解散倒计时
        this.HandleDismiss()
    elseif countDownType == Pin5GameState.CALCULATE then
        --开局倒计时
        this.HandleStart()
    elseif countDownType == CountOperationType.ReadyQuit then
        --准备倒计时
        this.HandleReadyQuit()
    end

    if countDownType == Pin5GameState.ROB_ZHUANG then
        if Pin5RoomPanel.zhuangAnimGo == nil then
            Pin5RoomPanel.PlayZhuangAnim()
        end
    else
        if Pin5RoomPanel.zhuangAnimGo ~= nil then
            Pin5RoomPanel.StopZhuangAnim()
        end
    end
end

--开始倒计时
function Pin5ContentTip.CheckCountDown(data)
    countDownTimer = Scheduler.scheduleGlobal(function()
        if countDownTime ~= nil and countDownTime > 0 and not Pin5RoomData.isGameOver then
            countDownTime = countDownTime - 1
            if not isPause then
                this.HandleGameProcess()
            end

            if countDownTime < 0 then
                this.StopCountDown()
            end
        end
    end, 1)
end

--停止倒计时
function Pin5ContentTip.StopCountDown()
    if not IsNil(countDownTimer) then
        Scheduler.unscheduleGlobal(countDownTimer)
        countDownTimer = nil
    end
end

--处理准备提示语
function Pin5ContentTip.HandleReady()
    --if not Pin5RoomData.IsFangKaFlow() then
    --    this.UpdateImgTipsText("下一局即将开始：" .. countDownTime .. "秒")
    --else
    --    --if Pin5RoomData.IsGameStarted() then
    --    this.UpdateImgTipsText("下一局即将开始：" .. countDownTime .. "秒")
    --    --else
    --    --    this.UpdateImgTipsText("等待玩家加入")
    --    --end
    --end
    this.UpdateClockText(countDownTime, "下一局准备：")
end

--清空倒计时
function Pin5ContentTip.ClearCountDown()
    countDownType = 0
    countDownTime = 0
    this.UpdateImgTipsText("")
    this.UpdateGameCountDownText("")
    this.StopCountDown()
end

--清空提示的文字
function Pin5ContentTip.ClearTipText()
    this.UpdateImgTipsText("")
    this.UpdateGameCountDownText("")
end

--- ------------------------------------------------------
--处理抢庄提示语
function Pin5ContentTip.HandleRobBanker()
    local str = "抢庄：" .. countDownTime .. "秒"
    --this.UpdateImgTipsText(str)
    this.UpdateClockText(countDownTime, "请选择抢庄倍数：")
end

--处理下注提示语
function Pin5ContentTip.HandleBetScore()
    local str = "下注：" .. countDownTime .. "秒"
    --this.UpdateImgTipsText(str)
    this.UpdateClockText(countDownTime, "请选择下注分数：")
end

--处理要牌提示语
function Pin5ContentTip.HandleGetCard()
    local str = "亮牌：" .. countDownTime .. "秒"
    --this.UpdateImgTipsText(str)
    this.UpdateClockText(countDownTime, "请亮牌：")
end

--处理要牌提示语
function Pin5ContentTip.HandleDismiss()
    local dispanel = PanelManager.GetPanel(Pin5PanelConfig.Dismiss)
    if not IsNil(dispanel) then
        dispanel:UpdateTimeText(countDownTime)
    end
end

--处理开始提示语
function Pin5ContentTip.HandleStart()
    -- local str = ""
    -- if countDownTime == 0 then
    --     this.UpdateGameCountDownText("")
    -- else
    --     this.UpdateGameCountDownText(countDownTime)
    --     str = "游戏即将开始，未准备的玩家将被踢出房间"
    -- end
    -- this.UpdateImgTipsText(str)

    this.UpdateClockText(countDownTime, "下一局准备：")
end

--处理准备退出提示语
function Pin5ContentTip.HandleReadyQuit()
    local str = ""
    if countDownTime == 0 then
        this.UpdateGameCountDownText("")
    else
        this.UpdateGameCountDownText(countDownTime)
        str = "未准备的玩家将被踢出房间"
    end
    this.UpdateImgTipsText(str)
end
---------------------------------- 不存在倒计时的 ---------------------------------
--处理观战状态提示语
function Pin5ContentTip.HandleLookOn()
    if Pin5RoomData.isCardGameStarted then
        this.UpdateImgTipsText("旁观中...")
    else
        if Pin5RoomData.MainIsOwner() then
            this.UpdateImgTipsText("等待其他玩家加入")
        end
    end
end

--处理检测到自己未准备时提示语 站立（未准备）
function Pin5ContentTip.HandleSelfNoReady()
    if not Pin5RoomData.isCardGameStarted and not Pin5RoomData.isGameOver then
        if Pin5RoomData.IsGoldGame() then
            this.UpdateImgTipsText("准备中...")
        end
    end
end

--处理小结算时提示语
function Pin5ContentTip.HandleXiaoJieSuan()
    if not Pin5RoomData.isCardGameStarted then
        if countDownType ~= CountOperationType.Start and countDownType ~= CountOperationType.ReadyQuit then
            if countDownType ~= CountOperationType.Dismiss and Pin5RoomData.IsGoldGame() then
                this.ClearCountDown()
                this.UpdateImgTipsText("比牌中...")
            end
        end
    end
end

--处理总结算时提示语
function Pin5ContentTip.HandleZongJieSuan()
    if not Pin5RoomData.isCardGameStarted then
        if countDownType ~= CountOperationType.Start and countDownType ~= CountOperationType.ReadyQuit then
            if countDownType ~= CountOperationType.Dismiss then
                this.ClearCountDown()
            end
            this.UpdateImgTipsText("")
        end
    end
end

return Pin5ContentTip