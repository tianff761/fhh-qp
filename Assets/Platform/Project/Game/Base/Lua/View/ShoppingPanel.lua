ShoppingPanel = ClassPanel("ShoppingPanel")
local this = ShoppingPanel
--购买商品ID配置
local shoppingConfig = {}
shoppingConfig[6] = "jzlsqp006"
shoppingConfig[45] = "jzlsqp045"
shoppingConfig[68] = "jzlsqp068"
shoppingConfig[118] = "jzlsqp118"
shoppingConfig[198] = "jzlsqp198"
shoppingConfig[348] = "jzlsqp348"
local currBuyID = 6
function ShoppingPanel:OnOpened()
    self:AddOnClick(self:Find("Content/Background/CloseButton"), function() this.Close() end)
    self:AddOnClick(self:Find("Items/Item6/BuyBtn"), HandlerArgs(ShoppingPanel.Buy, 6))
    self:AddOnClick(self:Find("Items/Item45/BuyBtn"), HandlerArgs(ShoppingPanel.Buy, 45))
    self:AddOnClick(self:Find("Items/Item68/BuyBtn"), HandlerArgs(ShoppingPanel.Buy, 68))
    self:AddOnClick(self:Find("Items/Item118/BuyBtn"), HandlerArgs(ShoppingPanel.Buy, 118))
    self:AddOnClick(self:Find("Items/Item196/BuyBtn"), HandlerArgs(ShoppingPanel.Buy, 198))
    self:AddOnClick(self:Find("Items/Item348/BuyBtn"), HandlerArgs(ShoppingPanel.Buy, 348))
end

function ShoppingPanel.Close()
    PanelManager.Destroy(PanelConfig.Shopping, true)
end

function ShoppingPanel.Buy(num)
    local playerID = UserData.GetUserId()
    local lastPay = DataPool.GetLocal("PAY_VERIFY" .. playerID)
    if lastPay == nil or lastPay == "" then
    else
        Alert.Prompt("上一次支付还未验证完成，是否重新验证？", this.SendPay)
        return
    end

    currBuyID = shoppingConfig[num]
    Alert.Prompt("确定要购买此商品？", this.BuyAlert)
    -- if Application.platform == RuntimePlatform.IPhonePlayer then
    --     print(">> 苹果 > " .. tostring(currBuyID))
    --     Alert.Prompt("确定要购买此商品？", this.BuyAlert)
    -- else
    --     print(">> 安卓购买 > " .. tostring(currBuyID))
    -- end
end

function ShoppingPanel.BuyAlert()
    LockScreen(5)
    this.BuyProduct(currBuyID)
end

---! 购买商品
function ShoppingPanel.BuyProduct(productId)
    print("---->购买商品：" .. productId)
    local target = GameObject.Find("GameManager"):GetComponent("Shopping")
    target:BuyProductID(productId)
end

---! 回调
function ShoppingPanel.OnBuy_Cb(args)
    print("==========>支付成功订单收据" .. args)
    this.SendPay(args)
end

--向服务器发送支付验证
function ShoppingPanel.SendPay(code)
    --将购买凭证保存到本地，验证结束后再清空，避免网络问题导致验证失败
    local playerID = UserData.GetUserId()
    local key = "PAY_VERIFY" .. playerID
    if code == nil then
        local lastPay = DataPool.GetLocal(key)
        if lastPay == nil or lastPay == "" then
            return
        else
            local strs = string.split(lastPay, "@")
            currBuyID = strs[2]
            code = strs[3]
        end
    end
    DataPool.SetLocal(key, playerID .. "@" .. currBuyID .. "@" .. code)
    print("==========>发送支付验证当前购买商品ID" .. currBuyID)
    print("==========>发送支付验证当前购买订单号" .. code)
    BaseTcpApi.SendReceipt(playerID, currBuyID, code)
end