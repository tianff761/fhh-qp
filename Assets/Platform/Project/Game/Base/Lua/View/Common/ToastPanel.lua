ToastPanel = ClassPanel("ToastPanel")
ToastPanel.Instance = nil
ToastPanel.datas = nil
ToastPanel.lastData = nil
ToastPanel.updateDataTimer = nil

local this = nil

function ToastPanel:OnInitUI()
    this = self
    this.datas = {}
    this.content = self:Find("Content")
    this.msgTxtTrans = this.content:Find("MsgTxt")
    this.msgTxt = this.msgTxtTrans:GetComponent(TypeText)
    this.tweener = this.content:GetComponent(typeof(TweenAlpha))
    this.tweener.onFinished = this.OnTweenerFinished
end

function ToastPanel:OnOpened(data)
    ToastPanel.Instance = self
    this.UpdateData(data)
end

function ToastPanel:OnClosed()
    ToastPanel.Instance = nil
    this.StopUpdateDataTimer()
end

------------------------------------------------------------------
--
function ToastPanel.AddListenerEvent()

end

function ToastPanel.RemoveListenerEvent()

end

--================================================================
--更新数据
function ToastPanel.UpdateData(data)
    if data == nil then
        if not this.IsPlaying() then
            this:Close()
        end
        return
    end

    table.insert(this.datas, data)

    --  Log(">> ToastPanel.UpdateData > this.datas length = " .. #this.datas)

    if this.lastData == nil then
        this.UpdateDisplay()
        this.StartUpdateDataTimer()
    else
        this.CheckUpdateDataTimer()
    end
end

--是否在播放中
function ToastPanel.IsPlaying()
    return this.lastData ~= nil or #this.datas > 0
end

function ToastPanel.StartUpdateDataTimer()
    if this.updateDataTimer == nil then
        this.updateDataTimer = Timing.New(this.OnUpdateDataTimer, 0.4)
    end
    this.updateDataTimer:Restart()
end

function ToastPanel.CheckUpdateDataTimer()
    if this.updateDataTimer == nil then
        this.StartUpdateDataTimer()
    else
        this.updateDataTimer:Start()
    end
end

function ToastPanel.OnUpdateDataTimer()
    if #this.datas < 1 and this.lastData == nil then
        this:Close()
    else
        this.UpdateDisplay()
    end
end

function ToastPanel.StopUpdateDataTimer()
    if this.updateDataTimer ~= nil then
        this.updateDataTimer:Stop()
    end
end

------------------------------------------------------------------
--
function ToastPanel.UpdateDisplay()
    if #this.datas > 0 then
        this.lastData = this.datas[1]
        table.remove(this.datas, 1)

        --  Log(">> ToastPanel.UpdateDisplay > this.datas surplus length = " .. #this.datas)

        this.msgTxt.text = this.lastData.message
        -- local msgTxtWidth = this.msgTxt.preferredWidth
        -- if msgTxtWidth < 240 then
        --     msgTxtWidth = 240
        -- elseif msgTxtWidth > 800 then
        --     msgTxtWidth = 800
        -- end
        -- UIUtil.SetWidth(this.msgTxtTrans, msgTxtWidth + 20)
        -- UIUtil.SetWidth(this.background, msgTxtWidth + 140)

        this.tweener:ResetToBeginning()
        this.tweener:PlayForward()
    end
end

function ToastPanel.OnTweenerFinished()
    this.lastData = nil
    if #this.datas < 1 then
        this:Close()
    end
end
