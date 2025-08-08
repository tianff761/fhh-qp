SDBCreateRoomPanel = ClassPanel("SDBCreateRoomPanel");
local this = SDBCreateRoomPanel;
local transform;
local mSelf = nil;
local curWanfa = 1

--初始化面板-- 只会调用一次
function SDBCreateRoomPanel:OnInitUI()
    mSelf = self
    self:InitPanel()
    self:AddClickMsg()
end

function SDBCreateRoomPanel:InitPanel()
    transform = self.transform
    local content = transform:Find("Content")
    local main = content:Find("Main")
    this.createRoomGo = main:Find("CreateButton").gameObject

    this.closeButton = content:Find("Top/CloseButton").gameObject
    --玩法
    local playMode = content:Find("Left/Buttons")
    local payMode1Go = playMode:Find("1").gameObject
    local payMode2Go = playMode:Find("2").gameObject
    local payMode3Go = playMode:Find("3").gameObject
    local payMode4Go = playMode:Find("4").gameObject
    this.playModeItems = { payMode1Go, payMode2Go, payMode3Go, payMode4Go }
    --规则选项
    local rule = main:Find("Content")
    --底分规则
    local DifenRules = rule:Find("Line1/Difen")
    local difen1 = DifenRules:Find("Type1").gameObject
    local difen2 = DifenRules:Find("Type2").gameObject
    this.DifenRuleItems = { difen1, difen2 }
    --人数规则
    local RenShuRules = rule:Find("Line2/RenShu")
    local renshu1 = RenShuRules:Find("Type1").gameObject
    local renshu2 = RenShuRules:Find("Type2").gameObject
    local renshu3 = RenShuRules:Find("Type3").gameObject
    this.RenShuRuleItems = { renshu1, renshu2, renshu3 }
    --局数规则
    local JuShuRules = rule:Find("Line3/JuShu")
    local jushu1 = JuShuRules:Find("Type1").gameObject
    local jushu2 = JuShuRules:Find("Type2").gameObject
    local jushu3 = JuShuRules:Find("Type3").gameObject
    this.JuShuRuleItems = { jushu1, jushu2, jushu3 }
    --房费规则
    local FangFeiRules = rule:Find("Line4/FangFei")
    local fangfei1 = FangFeiRules:Find("Type1").gameObject
    local fangfei2 = FangFeiRules:Find("Type2").gameObject
    this.FangFeiRuleItems = { fangfei1, fangfei2 }
    this.MasterPayText1 = fangfei1.transform:Find("Label1").gameObject:GetComponent("Text")
    this.MasterPayText2 = fangfei1.transform:Find("Label2").gameObject:GetComponent("Text")

    this.AAPayText1 = fangfei2.transform:Find("Label1").gameObject:GetComponent("Text")
    this.AAPayText2 = fangfei2.transform:Find("Label2").gameObject:GetComponent("Text")

    --模式规则
    local MoShiRules = rule:Find("Line5/MoShi")
    local moshi1 = MoShiRules:Find("ModeType1").gameObject
    local moshi2 = MoShiRules:Find("ModeType2").gameObject
    local moshi3 = MoShiRules:Find("ModeType3").gameObject
    this.MoShiRuleItems = { moshi1, moshi2,moshi3}
    --开始规则
    local KaiShiRules = rule:Find("Line6/KaiShi")
    local ks1 = KaiShiRules:Find("Type1").gameObject
    local ks2 = KaiShiRules:Find("Type2").gameObject
    local ks3 = KaiShiRules:Find("Type3").gameObject
    local ks4 = KaiShiRules:Find("Type4").gameObject
    this.KaiShiRuleItems = { ks1, ks2, ks3, ks4 }
    --推注规则
    local TuiZhuRules = rule:Find("Line7/TuiZhu")
    local tz1 = TuiZhuRules:Find("Type1").gameObject
    local tz2 = TuiZhuRules:Find("Type2").gameObject
    local tz3 = TuiZhuRules:Find("Type3").gameObject
    local tz4 = TuiZhuRules:Find("Type4").gameObject
    this.TuiZhuRuleItems = { tz1, tz2, tz3, tz4 }
    --抢庄规则
    local QiangZhuangRules = rule:Find("Line8/QiangZhuang")
    local qz1 = QiangZhuangRules:Find("Type1").gameObject
    local qz2 = QiangZhuangRules:Find("Type2").gameObject
    local qz3 = QiangZhuangRules:Find("Type3").gameObject
    local qz4 = QiangZhuangRules:Find("Type4").gameObject
    this.QiangZhuangRuleItems = { qz1, qz2, qz3, qz4 }
    --高级选项规则
    local Gaoji = rule:Find("Line9/GaoJi")
    local GaojiItem1 = Gaoji:Find("1").gameObject
    local GaojiItem2 = Gaoji:Find("2").gameObject
    local GaojiItem3 = Gaoji:Find("3").gameObject
    local GaojiItem4 = Gaoji:Find("4").gameObject
    local GaojiItem5 = Gaoji:Find("5").gameObject
    this.GaojiRuleItems = { GaojiItem1, GaojiItem2, GaojiItem3, GaojiItem4, GaojiItem5 }

    ---添加AddOnToggle
    this.AddToggle()
    self:AddOnClickMsg()
end

function SDBCreateRoomPanel:OnOpened()
    self:SetPanelInfo(curWanfa)
end

function SDBCreateRoomPanel:SetPanelInfo(wanfa)
    this.SetRule(this.DifenRuleItems, SDBCreateConfig[wanfa].difen)
    this.SetRule(this.RenShuRuleItems, SDBCreateConfig[wanfa].renshu)
    this.SetRule(this.JuShuRuleItems, SDBCreateConfig[wanfa].jushu)
    this.SetRule(this.FangFeiRuleItems, SDBCreateConfig[wanfa].zhifu)
    this.SetRule(this.MoShiRuleItems, SDBCreateConfig[wanfa].moshi)
    this.SetRule(this.KaiShiRuleItems, SDBCreateConfig[wanfa].kaishi)
    this.SetRule(this.TuiZhuRuleItems, SDBCreateConfig[wanfa].tuizhu)
    this.SetRule(this.QiangZhuangRuleItems, SDBCreateConfig[wanfa].qiangzhuang)
    this.SetHighLevelRule(SDBCreateConfig[wanfa].gaoji)
end

function SDBCreateRoomPanel:AddOnClickMsg()
    self:AddOnClick(this.closeButton, this.OnClickClose)
    for j=1, #this.playModeItems do
        mSelf:AddOnClick(this.playModeItems[j], HandlerByStaticArg1({args = j}, this.OnPlayModeChange))
    end
end

function SDBCreateRoomPanel.AddToggle()
    --添加人数选项选中事件
    for i =1,#this.RenShuRuleItems do
        mSelf:AddOnToggle(this.RenShuRuleItems[i], HandlerByStaticArg1({args = i}, this.OnPlayerCountChange))
    end
    --添加局数选项选中事件
    for j =1,#this.JuShuRuleItems do
        mSelf:AddOnToggle(this.JuShuRuleItems[j], HandlerByStaticArg1({args = j}, this.OnGameCountChange))
    end
end

function SDBCreateRoomPanel.OnPlayerCountChange(data, isOn)
    if isOn then
        local jushu = this.GetRule(this.JuShuRuleItems)
        local mPaystr,aaPaystr = this.GetPayNumber(jushu, data.args)
        --Log(">>>>>>>>>局数选项>>>",jushu,">>切换人数>>>>>>>>>>",data.args,">>>>>>>",mPaystr,"=======",aaPaystr)
        this.MasterPayText1.text = mPaystr
        this.MasterPayText2.text = mPaystr
    
        this.AAPayText1.text = aaPaystr
        this.AAPayText2.text = aaPaystr
    end
end

function SDBCreateRoomPanel.OnGameCountChange(data, isOn)
    if isOn then
        local pCount = this.GetRule(this.RenShuRuleItems)
        local mPaystr,aaPaystr = this.GetPayNumber(data.args, pCount)
        --Log(">>>>>>>>>人数选项>>>",pCount,">>切换局数>>>>>>>>>>",data.args,">>>>>>>",mPaystr,"=======",aaPaystr)
        this.MasterPayText1.text = mPaystr
        this.MasterPayText2.text = mPaystr
    
        this.AAPayText1.text = aaPaystr
        this.AAPayText2.text = aaPaystr
    end
end

function SDBCreateRoomPanel.OnPlayModeChange(data , isOn)

    if curWanfa == data.args then
        return
    end
    curWanfa = data.args
    if curWanfa == 4 then
        UIUtil.SetActive(this.MoShiRuleItems[3],true)
    else
        UIUtil.SetActive(this.MoShiRuleItems[3],false)
        if this.GetRule(this.MoShiRuleItems) == 3 then
           this.SetRule(this.MoShiRuleItems,1)
        end
    end         
    mSelf:SetPanelInfo(data.args)
end

--添加点击事件
function SDBCreateRoomPanel:AddClickMsg()
    mSelf:AddOnClick(this.createRoomGo, this.OnCreateRoomBtn)
end

--点击创建房间按钮
function SDBCreateRoomPanel.OnCreateRoomBtn()

    
    local wanfa = this.GetplayMode()
    SDBCreateConfig[wanfa].wanfa = wanfa
    --获取勾选项
    SDBCreateConfig[wanfa].difen = this.GetRule(this.DifenRuleItems)
    SDBCreateConfig[wanfa].renshu = this.GetRule(this.RenShuRuleItems)
    SDBCreateConfig[wanfa].jushu = this.GetRule(this.JuShuRuleItems)
    SDBCreateConfig[wanfa].zhifu = this.GetRule(this.FangFeiRuleItems)
    SDBCreateConfig[wanfa].moshi = this.GetRule(this.MoShiRuleItems)
    SDBCreateConfig[wanfa].kaishi = this.GetRule(this.KaiShiRuleItems)
    SDBCreateConfig[wanfa].tuizhu = this.GetRule(this.TuiZhuRuleItems)
    SDBCreateConfig[wanfa].qiangzhuang = this.GetRule(this.QiangZhuangRuleItems)
    SDBCreateConfig[wanfa].gaoji = this.GetHighLevelRule()

    if wanfa == SDBGameType.TAKE_TURNS_BANKER or wanfa == SDBGameType.OWNERS_BANKER then
        SDBCreateConfig[wanfa].qiangzhuang = 1
    end

    if wanfa ~= SDBGameType.MINGPAI_ROB_BANKER then
        SDBCreateConfig[wanfa].gaoji.XiaZhu = 0
    end

    --是否是代开房
    if CreateInfo.ClubId == 0 then
        Global.createRoomType = 1
        --1.配置 2.游戏ID 3.
        --(rulesObj, maxPlayerCount, gameId, maxjs, paytype, roomCardNum, roomtype, clubId)
        BaseHttpApi.SendCreateRoom(SDBCreateConfig[wanfa], 10, GameType.SDB, 15, SDBCreateConfig[wanfa].zhifu, GetCreateRoomCardCount(SDBCreateConfig[wanfa].jushu,SDBCreateConfig[wanfa].renshu), 1, CreateInfo.ClubId)
        Waiting.Show("正在创建房间,请耐心等待")
    else
        Global.createRoomType = 2
        --3.俱乐部支付
        if SDBCreateConfig[wanfa].zhifu == 2 then
            SDBCreateConfig[wanfa].zhifu = 3
        end
        
        local data = {
        rule = SDBCreateConfig[wanfa],
        maxPlayerNum = 10,
        maxjs = 15,
        zhifu = SDBCreateConfig[wanfa].zhifu,
        roomCard = GetCreateRoomCardCount(SDBCreateConfig[wanfa].jushu,SDBCreateConfig[wanfa].renshu),
        roomtype = 2,}

        HttpApi.ReqCommomCreate(data,CreateInfo.ClubId)
    end
    
    Log("============开房发送参数",Global.createRoomType,CreateInfo.ClubId,SDBCreateConfig[wanfa].zhifu)
end

--当面板隐藏或者销毁
function SDBCreateRoomPanel:OnClosed()
    this.RemoveMsg()
end
--获取高级选项
function SDBCreateRoomPanel.GetHighLevelRule()
    local gaoji = {
        canJoin = 0,
        canCuoPai = 0,
        ZhuangFanBei = 0,
        ZhuangWin = 0,
        XiaZhu = 0
    }

    for i = 1, #this.GaojiRuleItems do
        local item = this.GaojiRuleItems[i]
        if item.gameObject.activeSelf then
            if i < 3 then
                if item:GetComponent("Toggle").isOn then
                    if i == 1 then
                        gaoji.canJoin = 1
                    elseif i == 2 then
                        gaoji.canCuoPai = 1
                    end
                end
            else
                if item.transform:Find("Toggle").gameObject:GetComponent("Toggle").isOn then
                    if i == 3 then
                        gaoji.ZhuangFanBei = 1
                    elseif i == 4 then
                        gaoji.ZhuangWin = 1
                    elseif i == 5 then
                        gaoji.XiaZhu = 1
                    end
                end
            end
        end
    end
    return gaoji
end


--设置高级选项
function SDBCreateRoomPanel.SetHighLevelRule(gaoji)
    Log(">>>>>>>>>>>>>>>>>>>>>> 设置 gaoji ",gaoji)
    for i = 1, #this.GaojiRuleItems do
        local item = this.GaojiRuleItems[i]
        if i < 3 then
            local isTo = false
            if i == 1 then
                if gaoji.canJoin == 1 then
                    isTo = true
                else
                    isTo = false
                end
            elseif i == 2 then
                if gaoji.canCuoPai == 1 then
                    isTo = true
                else
                    isTo = false
                end
            end
            item:GetComponent("Toggle").isOn = isTo
        else
            local isTo = false
            if i == 3 then
                if gaoji.ZhuangFanBei == 1 then
                    isTo = true
                else
                    isTo = false
                end
            elseif i == 4 then
                if gaoji.ZhuangWin == 1 then
                    isTo = true
                else
                    isTo = false
                end
            elseif i == 5 then
                if gaoji.XiaZhu == 1 then
                    isTo = true
                else
                    isTo = false
                end
            end
            item.transform:Find("Toggle"):GetComponent("Toggle").isOn = isTo
        end
    end
end

--获取单选选项
function SDBCreateRoomPanel.GetRule(Items)
    local rule = 1
    for i = 1, #Items do
        local item = Items[i]
        if item.activeSelf then
            if item:GetComponent('Toggle').isOn then
                rule = i
                break
            end
        end
    end
    return rule
end

--设置单选选项
function SDBCreateRoomPanel.SetRule(Items, index)
    for k,v in pairs(Items) do
        if k == index then
            Items[index]:GetComponent("Toggle").isOn = true
        else
            Items[index]:GetComponent("Toggle").isOn = false
        end
    end
end

--获取玩法
function SDBCreateRoomPanel.GetplayMode()
    local mode = 1
    for i = 1, #this.playModeItems do
        local item = this.playModeItems[i].transform:Find("on").gameObject
        if item.activeSelf then
            mode = i
            break
        end
    end
    return mode
end

function SDBCreateRoomPanel:OnClosed()

end

function SDBCreateRoomPanel:OnDestroy()
    mSelf = nil
    transform = nil
    curWanfa = 1
end


--根据人数与局数显示房卡消耗数量
function SDBCreateRoomPanel.GetPayNumber(gameCount, playerCount)
    local mPaystr = "房主支付"
    local aaPaystr = "AA支付"
    if gameCount == 1 then
        if playerCount == 1 then
            mPaystr = mPaystr.."(3张房卡)"
            aaPaystr = aaPaystr.."(每人1张房卡)"
        elseif playerCount == 2 then
            mPaystr = mPaystr.."(5张房卡)"
            aaPaystr = aaPaystr.."(每人1张房卡)"
        else
            mPaystr = mPaystr.."(7张房卡)"
            aaPaystr = aaPaystr.."(每人1张房卡)"
        end
    elseif gameCount == 2 then
        if playerCount == 1 then
            mPaystr = mPaystr.."(4张房卡)"
            aaPaystr = aaPaystr.."(每人2张房卡)"
        elseif playerCount == 2 then
            mPaystr = mPaystr.."(6张房卡)"
            aaPaystr = aaPaystr.."(每人2张房卡)"
        else
            mPaystr = mPaystr.."(9张房卡)"
            aaPaystr = aaPaystr.."(每人2张房卡)"
        end
    else
        if playerCount == 1 then
            mPaystr = mPaystr.."(5张房卡)"
            aaPaystr = aaPaystr.."(每人3张房卡)"
        elseif playerCount == 2 then
            mPaystr = mPaystr.."(8张房卡)"
            aaPaystr = aaPaystr.."(每人3张房卡)"
        else
            mPaystr = mPaystr.."(12张房卡)"
            aaPaystr = aaPaystr.."(每人3张房卡)"
        end
    end
    return mPaystr,aaPaystr
end

function SDBCreateRoomPanel.OnClickClose()

    mSelf:Close()
end
