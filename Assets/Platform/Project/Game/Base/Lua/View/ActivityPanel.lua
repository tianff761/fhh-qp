ActivityPanel = ClassPanel("ActivityPanel")
local this = nil

function ActivityPanel:OnInitUI()
    this = self
    this.activity1GO = this:Find("Content/Activity1").gameObject
    this.activity2GO = this:Find("Content/Activity2").gameObject
    this.activity1CloseBtn = this:Find("Content/Activity1/CloseBtn").gameObject
    this.activity2CloseBtn = this:Find("Content/Activity2/CloseBtn").gameObject
    this.activity1Image = this:Find("Content/Activity1/Image"):GetComponent("Image")
    this.activity2Image = this:Find("Content/Activity2/Image"):GetComponent("Image")
    this.activity1TxtGO = this:Find("Content/Activity1/Text").gameObject
    this.activity2TxtGO = this:Find("Content/Activity2/Text").gameObject

    this:AddOnClick(this.activity1CloseBtn, this.OnActivity1CloseBtnClick)
    this:AddOnClick(this.activity2CloseBtn, this.OnActivity2CloseBtnClick)
end

--每次打开都调用一次
function ActivityPanel:OnOpened(data)
    this.SetActivityImage(data)
end

function ActivityPanel:OnClosed()

end

function ActivityPanel.SetActivityImage(data)
    local type2ActivityData = data[1]
    local type3ActivityData = data[2]
    if type2ActivityData == nil and type3ActivityData ~= nil then
        this.SetActivity1(type3ActivityData)
    else
        if type2ActivityData ~= nil then
            this.SetActivity1(type2ActivityData)
        end
        if type3ActivityData ~= nil then
            this.SetActivity2(type3ActivityData)
        else
            UIUtil.SetActive(this.activity2GO, false)
        end
    end
    --Functions.SetHeadImage(this.activityImage, data., callback, arg)
end

--设置数据
function ActivityPanel.SetActivity1(activityData)
    UIUtil.SetActive(this.activity1GO, true)
    this.CheckLocal("1", activityData.msg)
    Functions.SetImage(this.activity1Image, activityData.msg, function(arg)
        Functions.OnPlayerImageLoadCompleted(arg)
        UIUtil.SetActive(this.activity1TxtGO, false)
    end)
end

function ActivityPanel.SetActivity2(activityData)
    UIUtil.SetActive(this.activity2GO, true)
    this.CheckLocal("2", activityData.msg)
    Functions.SetImage(this.activity2Image, activityData.msg, function(arg)
        Functions.OnPlayerImageLoadCompleted(arg)
        UIUtil.SetActive(this.activity2TxtGO, false)
    end)
end

--关闭按钮方法
function ActivityPanel.OnActivity1CloseBtnClick(obj)
    this.Close()
end

function ActivityPanel.OnActivity2CloseBtnClick(obj)
    UIUtil.SetActive(this.activity2GO, false)
end

function ActivityPanel.Close()
    PanelManager.Destroy(PanelConfig.Activity, true)
end

--检测资源，如果当前资源和存储的不一样，则进行删除
function ActivityPanel.CheckLocal(name, url)
    local localName = "Activity" .. name
    local lastUrl = GetLocal(localName, nil)
    if lastUrl == nil then
        SetLocal(localName, url)
    else
        if lastUrl ~= url then
            netImageMgr:DeleteLocal(lastUrl)
            SetLocal(localName, url)
        end
    end
end