ModifyHeadIconPanel = ClassPanel("ModifyHeadIconPanel")
ModifyHeadIconPanel.headImage = nil
ModifyHeadIconPanel.headIconScrollView = nil
ModifyHeadIconPanel.viewContent = nil
ModifyHeadIconPanel.headIconTemp = nil
ModifyHeadIconPanel.modifyHeadIconBtn = nil
ModifyHeadIconPanel.uploadHeadIconBtn = nil
ModifyHeadIconPanel.curSelectHeadUrl = ""
local this = ModifyHeadIconPanel

function ModifyHeadIconPanel:OnInitUI()
    this = self

    local content = this:Find("Content")
    this.closeBtn = content:Find("Background/CloseButton")
    this.modifyHeadIconBtn = content:Find("QueryModifyBtn")
    this.uploadHeadIconBtn = content:Find("ModifyHeadIconBtn")

    this.headImage = content:Find("Head/Mask/Icon"):GetComponent(TypeImage)

    this.headIconScrollView = content:Find("HeadScrollView")
    this.viewContent = this.headIconScrollView:Find("Viewport/Content")
    this.headIconTemp = this.headIconScrollView:Find("TempToggle")

    this:AddOnClick(this.closeBtn, this.OnCloseBtnClick)
    this:AddOnClick(this.modifyHeadIconBtn, this.OnClickModifyHeadIcon)
    this:AddOnClick(this.uploadHeadIconBtn, this.OnClickUploadHeadIcon)
end

function ModifyHeadIconPanel:OnOpened(option)
    UIUtil.SetActive(this.headIconTemp, false)
    local tempTran = nil
    local headNum = UserData.GetHeadUrl()
    for i = 1, 40 do
        tempTran = NewObject(this.headIconTemp.gameObject, this.viewContent).transform
        tempTran.gameObject.name = tostring(i)
        Functions.SetHeadImage(tempTran:Find("Head/Icon"):GetComponent(TypeImage), tostring(i))
        UIUtil.SetActive(tempTran, true)
        this:AddOnToggle(tempTran, function(isOn)
            this.OnClickToggle(isOn, tostring(i))
        end)
        if headNum ~= nil and i == headNum then
            UIUtil.SetToggle(tempTran, true)
        end
    end
    Functions.SetHeadImage(this.headImage, UserData.GetHeadUrl())

    AddMsg(CMD.Tcp.S2C_PlayerHead, this.OnTcpModifyHeadIcon)
end


function ModifyHeadIconPanel:OnClosed()
    RemoveMsg(CMD.Tcp.S2C_PlayerHead, this.OnTcpModifyHeadIcon)
end

function ModifyHeadIconPanel.OnClickToggle(isOn, headUrl)
    if isOn then
        Functions.SetHeadImage(this.headImage, headUrl)
        this.curSelectHeadUrl = headUrl
    else
        Functions.SetHeadImage(this.headImage, UserData.GetHeadUrl())
    end
end
------------------------------------------------------------------
--
function ModifyHeadIconPanel.Close()
    PanelManager.Destroy(PanelConfig.ModifyHeadIcon, true)
end

------------------------------------------------------------------
--
function ModifyHeadIconPanel.OnCloseBtnClick()
    this.Close()
end

function ModifyHeadIconPanel.OnClickModifyHeadIcon()
    if string.IsNullOrEmpty(this.curSelectHeadUrl) then
        Toast.Show("请选择要修改的头像")
    elseif this.curSelectHeadUrl == UserData.GetUserId() then
        Toast.Show("选择头像与当前头像相同")
    else
        SendTcpMsg(CMD.Tcp.C2S_PlayerHead, { newTx = this.curSelectHeadUrl })
    end
end

--点击上传头像功能
function ModifyHeadIconPanel.OnClickUploadHeadIcon()
    --if IsEditorOrPcPlatform() then
    --    Log("IsEditorOrPcPlatform")
    --    return
    --end
    --AppPlatformHelper.GetImagePathByPhoto(function(imagePath)
    --    AppPlatformHelper.UploadImage(imagePath, function(fileName)
    --        SendTcpMsg(CMD.Tcp.C2S_PlayerHead, { newTx = fileName })
    --    end)
    --end)
    Toast.Show("头像设置成功")
end

function ModifyHeadIconPanel.OnTcpModifyHeadIcon(data)
    if data.code == 0 then
        Toast.Show("头像设置成功")
        Functions.SetHeadImage(this.headImage, UserData.GetHeadUrl())
        this.Close()
    end
end

------------------------------------------------------------------