PdkClockTimer = ClassLuaComponent("PdkClockTimer")
local this = PdkClockTimer
this.totalTime = 20
this.countDown = 0
this.countDownHandle = nil
this.isOpenTiemr = false
-- this.curPointer = nil

function PdkClockTimer:Awake()
    self.timeText = self.transform:Find("Bg/Text"):GetComponent("Text")
    self.circleImage = self.transform:Find("Bg/CircleImage"):GetComponent("Image")
    -- self.pointers = {}
    -- local pointer = nil
    -- for i = 1, 4 do
    --     pointer = self.transform:Find(i)
    --     table.insert(self.pointers, pointer)
    -- end
end

--开始倒计时
function PdkClockTimer:BeginDaoJiShi(time)  
    --更新计时
    self.totalTime = time
    self.countDown = time
    self.circleImage.fillAmount = 1
    self.circleImage:DOKill()
    self.circleImage:DOFillAmount(0, time):SetEase(DG.Tweening.Ease.Linear)
    self.timeText.text = tostring(self.countDown)
    if not self.isOpenTiemr then
        self.isOpenTiemr = true
        self.countDownHandle =
        Scheduler.scheduleGlobal(
        function()
            if not IsNull(self.timeText) then
                self.countDown = self.countDown - 1
                if self.countDown <= 5 and self.countDown > 0 then
                    PdkAudioCtrl.PlayDownTime()
                end
                if self.countDown <= 0 then
                    self.countDown = 0
                end
                self.timeText.text = tostring(self.countDown)
                -- self.circleImage.fillAmount = self.countDown / self.totalTime
            end
        end,
        1
    )
    end
end

function PdkClockTimer:UpdateDaoJiShi(time)
    self.countDown = time
end

--停止倒计时
function PdkClockTimer:StopDaoJiShi()
    self.isOpenTiemr = false
    Scheduler.unscheduleGlobal(self.countDownHandle)
end

function PdkClockTimer:OnClosed()
    self:StopDaoJiShi()
end
