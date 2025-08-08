
--打牌提示显示项
MahjongPlayCardArrowItem = {
	enabled = false,
	-----------------------------------------------
	gameObject = nil,
	x = 0,
	y = 0,
}

local meta = {__index = MahjongPlayCardArrowItem}

function MahjongPlayCardArrowItem.New()
	local o = {}
	setmetatable(o, meta)
	return o
end

function MahjongPlayCardArrowItem:Init(gameObject)
	self.gameObject = gameObject
end

function MahjongPlayCardArrowItem:Clear()
	if self.enabled == false then
		return
	end
	self.enabled = false
	
	if self.gameObject ~= nil then
		UIUtil.SetActive(self.gameObject, false)
	end
end

function MahjongPlayCardArrowItem:Destroy()
	
end

------------------------------------------------------------------------------
function MahjongPlayCardArrowItem:Show()
	if self.enabled == true then
		return
	end
	self.enabled = true
	if self.gameObject ~= nil then
		UIUtil.SetActive(self.gameObject, true)
	end
end

function MahjongPlayCardArrowItem:Hide()
	if self.enabled == false then
		return
	end
	self.enabled = false
	if self.gameObject ~= nil then
		UIUtil.SetActive(self.gameObject, false)
	end
end

function MahjongPlayCardArrowItem:SetPosition(x, y)
	if self.gameObject ~= nil then
		self.x = x + 24
		self.y = y
		UIUtil.SetAnchoredPosition(self.gameObject, self.x, self.y)
	end
end
