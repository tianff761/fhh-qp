ClubSettingPanel = ClassPanel("ClubSettingPanel")
ClubSettingPanel.closeBtn = nil
ClubSettingPanel.saveBtn = nil
ClubSettingPanel.shenHeToggle = nil
ClubSettingPanel.yinSiToggle = nil
ClubSettingPanel.daYangToggle = nil
ClubSettingPanel.titleInput = nil
ClubSettingPanel.noticeInput = nil
local this = ClubSettingPanel
function ClubSettingPanel:Awake()
    this = self
    local content = this:Find("Content")
    this.closeBtn = this:Find("Bgs/CloseBtn")
    this.saveBtn = content:Find("SaveBtn")
    this.shenHeToggle = content:Find("ShenHe/ShenHeToggle")
    this.yinSiToggle = content:Find("YinSi/YinSiToggle")
    this.daYangToggle = content:Find("DaYang/DaYangToggle")
    this.titleInput = content:Find("Title/TitleInputField")
    this.noticeInput = content:Find("Notice/NoticeInputField")
end

function ClubSettingPanel:OnOpened()
    this:AddOnClick(this.closeBtn, this.OnClickBackBtn)
    this:AddOnClick(this.saveBtn, this.OnClickSaveBtn)
    -- ClubManager.SendGetClubSetting()
    ClubSettingPanel.UpdatePanel()
end

function ClubSettingPanel.OnClickSaveBtn()
    Log("OnClickSaveBtn")
    local isOpenShenHe = UIUtil.GetToggle(this.shenHeToggle)
    local isOpenYinSi = UIUtil.GetToggle(this.yinSiToggle)
    local isOpenDaYang = UIUtil.GetToggle(this.daYangToggle)
    local title = UIUtil.GetInputText(this.titleInput)
    local notice = UIUtil.GetInputText(this.noticeInput)
    if string.IsNullOrEmpty(title) then
        Toast.Show("请输入俱乐部名称")
        return 
    end
    if isOpenShenHe == ClubData.isOpenShenHe and 
    isOpenYinSi == ClubData.isOpenYinSi and 
    isOpenDaYang == ClubData.isOpenDaYang and 
    title == ClubData.clubTitle and 
    notice == ClubData.clubNotice  then
        Toast.Show("没有改变设置")
        return 
    end
    Alert.Prompt("确定修改设置数据？", function ()
        ClubManager.SendSetClubSetting(isOpenShenHe, isOpenYinSi, isOpenDaYang, title, notice)
    end)
end

function ClubSettingPanel.OnClickBackBtn()
    PanelManager.Close(PanelConfig.ClubSetting, true)
end

function ClubSettingPanel.UpdatePanel()
    UIUtil.SetToggle(this.shenHeToggle, ClubData.isOpenShenHe)
    UIUtil.SetToggle(this.yinSiToggle, ClubData.isOpenYinSi)
    UIUtil.SetToggle(this.daYangToggle, ClubData.isOpenDaYang)
    if ClubData.clubTitle ~= nil then
        UIUtil.SetInputText(this.titleInput, tostring(ClubData.clubTitle))
    else
        UIUtil.SetInputText(this.titleInput, "")
    end

    if ClubData.clubNotice ~= nil then
        UIUtil.SetInputText(this.noticeInput, tostring(ClubData.clubNotice))
    else
        UIUtil.SetInputText(this.noticeInput, "")
    end
end
