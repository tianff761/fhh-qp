RoomSpeechPanel = ClassPanel("RoomSpeechPanel") 
local this = RoomSpeechPanel;

local animTimer = nil;
local animStep = 1;
local animFrame = 0.25;
local animHeights = {};
local noticeActive = false;
local mSelf = nil
--启动事件--
function RoomSpeechPanel:OnInitUI()
    mSelf = self
    self:InitPanel()
    self:AddOnClick(self.maskBtn, this.OnClickBtn)
    animTimer = Timer.New(this.Animation, animFrame, -1)
end


--初始化面板--
function RoomSpeechPanel:InitPanel()
	local transform = self.transform
	self.maskBtn = transform:Find("Mask")
    self.imgAnim = transform:Find("PressNode/maskObj").gameObject;
	self.imgCancelNotice = transform:Find("PressNode").gameObject;
	self.imgCancelConfirm = transform:Find("CancelCode").gameObject;
	self.lineImage = transform:Find("Line/Image"):GetComponent(TypeImage)

	local animInitHeight = UIUtil.GetHeight(self.imgAnim);
	animHeights[1] = animInitHeight * 10 / 133;
	for i = 2, 8 do
		animHeights[i] = animInitHeight * (10 + (i - 1) * 18) / 133;
	end
	UIUtil.SetHeight(self.imgAnim, animHeights[animStep]);
end

function RoomSpeechPanel:OnOpened(time)
    self:Show()
    self:ShowLine(time)
end

function RoomSpeechPanel:ShowLine(time)
	self.lineImage.fillAmount = 0
	self.lineImage:DOFillAmount(1, time - 0.5):SetEase(DG.Tweening.Ease.Linear)
end

function RoomSpeechPanel.OnClickBtn()
	ChatVoice.RecordCancel()
	if mSelf ~= nil then
		mSelf:Close()
	end
	Toast.Show("已取消发送语音")
end

function RoomSpeechPanel:Show()
	if self.gameObject then
		animStep = 1;
		this.SetNoticeActive(true);
		if self.imgCancelConfirm then
			UIUtil.SetActive(self.imgCancelConfirm, false)
		end
		
		animTimer:Stop();
		animTimer:Reset(this.Animation, animFrame, -1);
		animTimer:Start();

		UIUtil.SetHeight(mSelf.imgAnim, animHeights[animStep]);
	end
end

function RoomSpeechPanel.Hide()
	if animTimer ~= nil then animTimer:Stop(); end
	this.SetNoticeActive(false);
	if mSelf.imgCancelConfirm then
		UIUtil.SetActive(mSelf.imgCancelConfirm,false)
	end
end

function RoomSpeechPanel:Notice()
	this.SetNoticeActive(true);

	UIUtil.SetActive(mSelf.imgCancelConfirm,false)
end

function RoomSpeechPanel:Confirm()
	this.SetNoticeActive(false);
	UIUtil.SetActive(mSelf.imgCancelConfirm,true)
end

function RoomSpeechPanel.Animation()
	if noticeActive then
		animStep = animStep + 1;
		if animStep > #animHeights then
			animStep = 1;
		end
		UIUtil.SetHeight(mSelf.imgAnim, animHeights[animStep]);
	end
end

function RoomSpeechPanel.SetNoticeActive(active)
    noticeActive = active
    if mSelf.imgCancelNotice then
        UIUtil.SetActive(mSelf.imgCancelNotice, noticeActive)
    end
    return noticeActive
end

function RoomSpeechPanel:OnClosed()
	this.Hide();
	mSelf.lineImage:DOKill(false)
end

--单击事件--
function RoomSpeechPanel.OnDestroy()
	
end
