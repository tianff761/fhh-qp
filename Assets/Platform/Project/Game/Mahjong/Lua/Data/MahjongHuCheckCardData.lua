
--麻将牌数据
MahjongHuCheckCardData = {
	--麻将牌的ID，如101、102等
	id = 0,
	--麻将牌的Key，如1、11、21等
	key = 0,
	--麻将类型，区分筒条万
	type = 0,
	--麻将数字，如1、2、3...
	num = 0,
	--排序字段，如果是定缺牌的话，就用ID加上一个固定值，否则就是ID
	sort = 0,
	--是否是听用
	isTing = false,
	--用于左手牌key对象时，标记是否为根
	isGang = false,
	--处理使用
	isUse = false,
}

local meta = {__index = MahjongHuCheckCardData}

function MahjongHuCheckCardData.New()
	local obj = {}
	setmetatable(obj, meta)
	return obj
end

--设置ID
--101-104表示1万、201-204表示2万
--1101-1104表示1条、1201-1204表示2条
--2101-2104表示1同、2201-2204表示2筒
function MahjongHuCheckCardData:SetId(id)
	self.id = id
	self.key = math.floor(self.id / 100)
	self.type = math.floor(self.id / 1000) + 1
	self.num = self.key % 10
	--处理排序
	if MahjongUtil.IsTingYongCard(self.key) then
		self.sort = self.id - 10000
		self.isTing = true
	else
		self.sort = self.id
		self.isTing = false
	end
end 