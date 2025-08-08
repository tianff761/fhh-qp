--奖池数字显示想
TpJackpotItem = Class("TpJackpotItem")

--================================================================
--
--初始
function TpJackpotItem:Init(transform)
    self.transform = transform
    self.gameObject = transform.gameObject
    self.label = transform:Find("Text"):GetComponent(TypeText)
    self.duration = 0.5
    self.number = 0
    self.running = false
    self.time = 0
    self.nextUpdateTime = 0
    self.lastNumber = 0
    self.interval = 0
    self.tempNumber = 0
end

--播放
function TpJackpotItem:Play(number)
    self.number = number
    self.time = 0
    self.nextUpdateTime = 0
    self.interval = 0
    self.running = true
end

--直接设置数据
function TpJackpotItem:Set(number)
    self.number = number
    self.lastNumber = 0
    self.label.text = tostring(self.number)
end

--每帧更新
function TpJackpotItem:Update(deltaTime)
    if self.running then
        self.time = self.time + deltaTime

        if self.time > self.duration then
            self.running = false
            self.label.text = tostring(self.number)
        else
            if self.time > self.nextUpdateTime then
                self.tempNumber = math.random(0, 9)
                if self.tempNumber == self.number then
                    self.tempNumber = self.tempNumber + 1
                    self.tempNumber = self.tempNumber % 10
                end
                if self.tempNumber == self.lastNumber then
                    self.tempNumber = self.tempNumber + 1
                    self.tempNumber = self.tempNumber % 10
                end
                self.lastNumber = self.tempNumber
                self.label.text = tostring(self.tempNumber)

                self.interval = self.interval + 0.01
                if self.interval > 0.2 then
                    self.interval = 0.2
                end
                self.nextUpdateTime = self.time + self.interval
            end
        end
    end
end

--隐藏
function TpJackpotItem:Hide()
    UIUtil.SetActive(self.gameObject, false)
end

--销毁
function TpJackpotItem:Destroy()
    UIUtil.SetActive(self.gameObject, false)
    GameObject.Destroy(self.gameObject)
end