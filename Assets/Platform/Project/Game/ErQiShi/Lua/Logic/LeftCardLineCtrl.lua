LeftCardLineCtrl = ClassLuaComponent("LeftCardLineCtrl")
LeftCardLineCtrl.oper        = 0         --当前行操作类型
LeftCardLineCtrl.targetCard  = 0         --当前行目标牌
LeftCardLineCtrl.targetFrom  = 0         --目标牌来源
LeftCardLineCtrl.card1       = 0         --第一张牌
LeftCardLineCtrl.card2       = 0         --第二张牌
LeftCardLineCtrl.card3       = 0         --第二张牌
LeftCardLineCtrl.cardCell1   = nil
LeftCardLineCtrl.cardCell2   = nil
LeftCardLineCtrl.cardCell3   = nil
LeftCardLineCtrl.cardCell4   = nil
LeftCardLineCtrl.userCtrl    = nil

function LeftCardLineCtrl:Init()
    self:Reset()
    self.cardCell1 = self:Find("Cell1")
    self.cardCell2 = self:Find("Cell2")
    self.cardCell3 = self:Find("Cell3")
    self.cardCell4 = self:Find("Cell4")
end

--group:{"id2":522,"targetId":521,"id3":0,"from":2,"id1":511,"oper":46}
function LeftCardLineCtrl:AddOperationGroup(group, settingUserInfoCtrl)
    self.userCtrl = settingUserInfoCtrl
 --   Log('添加右手牌组：', group, settingUserInfoCtrl.uid, BattleModule.userNum)
    local isEqaul = false
    if group.oper == self.oper and group.targetCard == self.targetId and group.id1 == self.card1 then
        isEqaul = true
    end
    if not isEqaul and group.oper == EqsOperation.BaYu then
        Log("*********从左手牌解析巴雨并执行", group, settingUserInfoCtrl.uid)
        if not UserData.IsReconnect() then
            settingUserInfoCtrl:PerformOperation(group)
        end
        BattleModule.AddYuCardUid(group.targetId)
    end
    self.oper       = EqsTools.GetOperationType(group)
    self.targetCard = EqsTools.GetTargetId(group)
    self.targetFrom = EqsTools.GetFrom(group)
    self.card1      = EqsTools.GetCardUid1(group)
    self.card2      = EqsTools.GetCardUid2(group)
    self.card3      = EqsTools.GetCardUid3(group)
    self:ClearCells()
    local bottomSamllCard
    if self.oper == EqsOperation.Dui or self.oper == EqsOperation.Chi or self.oper == EqsOperation.BaiPai then
        EqsTools.AddSmallCardToCell(self.targetCard,  self.cardCell3)
        EqsTools.AddSmallCardToCell(self.card1,       self.cardCell2)
        bottomSamllCard = EqsTools.AddSmallCardToCell(self.card2,       self.cardCell1)
    elseif self.oper == EqsOperation.Kai then
        bottomSamllCard = EqsTools.AddSmallCardToCell(self.targetCard, self.cardCell1)
        EqsTools.AddSmallCardToCell(self.card1,       self.cardCell2)
        EqsTools.AddSmallCardToCell(self.card2,       self.cardCell3)
        EqsTools.AddSmallCardToCell(self.card3,       self.cardCell4)
    elseif self.oper == EqsOperation.BaYu then
        bottomSamllCard = EqsTools.AddSmallCardToCell(self.targetCard,  self.cardCell1)
        EqsTools.AddSmallCardToCell(self.card1,       self.cardCell2)
        EqsTools.AddSmallCardToCell(self.card2,       self.cardCell3)
        --巴雨显示一张相同的牌
        local topSamllCard = EqsTools.AddSmallCardToCell(self.card2, self.cardCell4)
        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.YuTag)
        EqsCardsManager.SetSmallCardEffect(topSamllCard, EqsCardDefine.SmallCardEffectType.Hei)
        BattleModule.AddYuCardUid(self.targetCard)
    end

    if self.oper == EqsOperation.Kai or self.oper == EqsOperation.Dui then
        --处理箭头
        local fromUser = BattleModule.GetUserInfoBySeatId(self.targetFrom)
        if fromUser ~= nil then
            --总人数为3人
            if BattleModule.userNum == 3 then
                if settingUserInfoCtrl:IsSelf() then
                    if fromUser.uiIdx == 2 then
                        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.Right)
                    elseif fromUser.uiIdx == 3 then
                        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.Up)
                    end
                elseif settingUserInfoCtrl.uiIdx == 2 then
                    if fromUser.uiIdx == 1 then
                        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.Down)
                    elseif fromUser.uiIdx == 3 then
                        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.Left)
                    end
                elseif settingUserInfoCtrl.uiIdx == 3 then
                    if fromUser.uiIdx == 1 then
                        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.Down)
                    elseif fromUser.uiIdx == 2 then
                        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.Right)
                    end
                end
            --总人数为2人
            elseif BattleModule.userNum == 2 then
                if settingUserInfoCtrl:IsSelf() then
                    if fromUser.uiIdx == 2 then
                        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.Up)
                    end
                else
                    if fromUser.uiIdx == 1 then
                        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.Down)
                    end
                end
            --总人数为4人
            elseif BattleModule.userNum == 4 then
                if settingUserInfoCtrl:IsSelf() then
                    if fromUser.uiIdx == 2 then
                        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.Right)
                    elseif fromUser.uiIdx == 3 then
                        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.Up)
                    elseif fromUser.uiIdx == 4 then
                        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.Left)
                    end
                elseif settingUserInfoCtrl.uiIdx == 2 then
                    if fromUser.uiIdx == 1 then
                        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.Down)
                    elseif fromUser.uiIdx == 3 then
                        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.Up)
                    elseif fromUser.uiIdx == 4 then
                        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.Left)
                    end
                elseif settingUserInfoCtrl.uiIdx == 3 then
                    if fromUser.uiIdx == 1 then
                        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.Down)
                    elseif fromUser.uiIdx == 2 then
                        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.Right)
                    elseif fromUser.uiIdx == 4 then
                        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.Left)
                    end
                elseif settingUserInfoCtrl.uiIdx == 4 then
                    if fromUser.uiIdx == 1 then
                        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.Down)
                    elseif fromUser.uiIdx == 2 then
                        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.Right)
                    elseif fromUser.uiIdx == 3 then
                        EqsCardsManager.SetSmallCardEffect(bottomSamllCard, EqsCardDefine.SmallCardEffectType.Up)
                    end
                end
            end
        end
    end
end

function LeftCardLineCtrl:ClearCells()
    EqsTools.RecycleSmallCardCell(self.cardCell1)
    EqsTools.RecycleSmallCardCell(self.cardCell2)
    EqsTools.RecycleSmallCardCell(self.cardCell3)
    EqsTools.RecycleSmallCardCell(self.cardCell4)
end

function LeftCardLineCtrl:SetYuTag()
    if self.oper ~= EqsOperation.BaYu then
        EqsTools.SetCellCardYuTag(self.cardCell1)
        EqsTools.SetCellCardYuTag(self.cardCell2)
        EqsTools.SetCellCardYuTag(self.cardCell3)
        EqsTools.SetCellCardYuTag(self.cardCell4)
    end
end

function LeftCardLineCtrl:SetEffect(smallCardEffect, cardid)
    EqsTools.SetCellCardEffect(self.cardCell1, smallCardEffect, cardid)
    EqsTools.SetCellCardEffect(self.cardCell2, smallCardEffect, cardid)
    EqsTools.SetCellCardEffect(self.cardCell3, smallCardEffect, cardid)
    EqsTools.SetCellCardEffect(self.cardCell4, smallCardEffect, cardid)
end

function LeftCardLineCtrl:Reset()
    self.oper           = 0
    self.targetCard     = 0
    self.targetFrom     = 0
    self.card1          = 0
    self.card2          = 0
    self.card3          = 0
    self.userCtrl       = nil
    self:ClearCells()
end
