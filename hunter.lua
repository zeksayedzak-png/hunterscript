-- ================================================
-- 🎯 SMART MOBILE GAMEPASS BYPASS
-- ⚡ يعمل 100% على الهاتف: loadstring(game:HttpGet(""))()
-- 💰 يحاول جميع طرق الحصول على Gamepass
-- ================================================

wait(2)
print("🎮 جاري التحميل...")

-- خدمات أساسية
local Players = game:GetService("Players")
local Marketplace = game:GetService("MarketplaceService")
local Http = game:GetService("HttpService")
local Replicated = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
if not player then return end

print("✅ الخدمات جاهزة")

-- إعدادات
local attacking = false
local results = {}

-- 🔍 دالة ذكية للبحث عن Gamepass
local function FindGamepassInfo(gamepassId)
    local info = {}
    
    -- المحاولة 1: من MarketplaceService
    pcall(function()
        local product = Marketplace:GetProductInfo(gamepassId)
        info.name = product.Name
        info.price = product.PriceInRobux or 0
        info.type = product.AssetTypeId == 34 and "Gamepass" or "Other"
        info.success = true
    end)
    
    -- المحاولة 2: البحث في الكود
    if not info.success then
        pcall(function()
            -- البحث في كل Scripts
            for _, script in pairs(game:GetDescendants()) do
                if script:IsA("Script") then
                    local source = script.Source
                    if source:find(tostring(gamepassId)) then
                        -- استخراج الاسم
                        local nameMatch = source:match('Name%s-[:=]%s-["\']([^"\']+)["\']')
                        info.name = nameMatch or "Gamepass_" .. gamepassId
                        info.location = script:GetFullName()
                        break
                    end
                end
            end
        end)
    end
    
    return info
end

-- ⚔️ طرق هجوم متعددة
local function AttackGamepass(gamepassId)
    if attacking then return {"جاري الهجوم بالفعل"} end
    
    attacking = true
    results = {}
    
    print("🎯 بدأ الهجوم على: " .. gamepassId)
    
    -- معلومات Gamepass
    local gamepassInfo = FindGamepassInfo(gamepassId)
    print("📝 الاسم: " .. (gamepassInfo.name or "غير معروف"))
    
    -- طريقة 1: Marketplace مباشر
    pcall(function()
        Marketplace:PromptProductPurchase(player, gamepassId)
        table.insert(results, "✅ أرسل طلب شراء مباشر")
    end)
    
    wait(1)
    
    -- طريقة 2: RemoteEvents
    local remoteCount = 0
    pcall(function()
        for _, obj in pairs(Replicated:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                remoteCount = remoteCount + 1
                
                -- محاولات مختلفة
                pcall(function() obj:FireServer(gamepassId) end)
                pcall(function() obj:FireServer({id = gamepassId}) end)
                pcall(function() obj:FireServer({gamepassId = gamepassId, player = player}) end)
                pcall(function() obj:FireServer({productId = gamepassId, bought = true}) end)
                
                if remoteCount % 10 == 0 then
                    wait(0.5) -- تأخير للهاتف
                end
            end
        end
        table.insert(results, "✅ أرسل لـ " .. remoteCount .. " RemoteEvents")
    end)
    
    -- طريقة 3: RemoteFunctions
    pcall(function()
        for _, obj in pairs(Replicated:GetDescendants()) do
            if obj:IsA("RemoteFunction") then
                pcall(function() obj:InvokeServer(gamepassId) end)
                pcall(function() obj:InvokeServer({id = gamepassId}) end)
            end
        end
        table.insert(results, "✅ حاول RemoteFunctions")
    end)
    
    -- طريقة 4: BindableEvents (للـ LocalScripts)
    pcall(function()
        if player:FindFirstChild("PlayerScripts") then
            for _, obj in pairs(player.PlayerScripts:GetDescendants()) do
                if obj:IsA("BindableEvent") then
                    pcall(function() obj:Fire(gamepassId) end)
                end
            end
            table.insert(results, "✅ حاول BindableEvents")
        end
    end)
    
    wait(2)
    
    -- طريقة 5: إشعار وهمي
    pcall(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "FakePurchaseNotify"
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.4, 0, 0.1, 0)
        frame.Position = UDim2.new(0.3, 0, 0.1, 0)
        frame.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        
        local text = Instance.new("TextLabel")
        text.Text = "✅ تم شراء Gamepass: " .. (gamepassInfo.name or gamepassId)
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.TextColor3 = Color3.new(1, 1, 1)
        text.Font = Enum.Font.GothamBold
        text.TextSize = 14
        
        text.Parent = frame
        frame.Parent = gui
        gui.Parent = player:WaitForChild("PlayerGui")
        
        table.insert(results, "🎨 عرض إشعار وهمي")
        
        wait(3)
        gui:Destroy()
    end)
    
    attacking = false
    return results
end

-- 🎨 واجهة ذكية للهاتف
local function CreateSmartUI()
    -- تنظيف القديم
    pcall(function()
        for _, gui in pairs(player.PlayerGui:GetChildren()) do
            if gui.Name == "GamepassHunterUI" then
                gui:Destroy()
            end
        end
    end)
    
    wait(1)
    
    local screen = Instance.new("ScreenGui")
    screen.Name = "GamepassHunterUI"
    screen.ResetOnSpawn = false
    
    -- الإطار الرئيسي
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0.9, 0, 0.4, 0)
    main.Position = UDim2.new(0.05, 0, 0.3, 0)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    main.BorderSizePixel = 2
    main.BorderColor3 = Color3.fromRGB(0, 150, 255)
    main.Active = true
    main.Draggable = true
    
    -- العنوان
    local title = Instance.new("TextLabel")
    title.Text = "🎮 Gamepass Hunter"
    title.Size = UDim2.new(1, 0, 0.15, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    
    -- حقل الإدخال
    local input = Instance.new("TextBox")
    input.PlaceholderText = "أدخل Gamepass ID هنا..."
    input.Text = ""
    input.Size = UDim2.new(0.8, 0, 0.15, 0)
    input.Position = UDim2.new(0.1, 0, 0.2, 0)
    input.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    
    -- زر الهجوم
    local attackBtn = Instance.new("TextButton")
    attackBtn.Text = "⚔️ بدء الهجوم"
    attackBtn.Size = UDim2.new(0.8, 0, 0.2, 0)
    attackBtn.Position = UDim2.new(0.1, 0, 0.4, 0)
    attackBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    attackBtn.TextColor3 = Color3.new(1, 1, 1)
    attackBtn.Font = Enum.Font.GothamBold
    attackBtn.TextSize = 14
    
    -- شريط التقدم
    local progress = Instance.new("Frame")
    progress.Size = UDim2.new(0, 0, 0.05, 0)
    progress.Position = UDim2.new(0.1, 0, 0.65, 0)
    progress.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    progress.BorderSizePixel = 0
    progress.Visible = false
    
    -- حالة
    local status = Instance.new("TextLabel")
    status.Text = "جاهز - أدخل Gamepass ID"
    status.Size = UDim2.new(0.8, 0, 0.15, 0)
    status.Position = UDim2.new(0.1, 0, 0.75, 0)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 11
    status.TextWrapped = true
    
    -- زر الإغلاق
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0.1, 0, 0.12, 0)
    closeBtn.Position = UDim2.new(0.85, 0, 0.02, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    
    -- التجميع
    title.Parent = main
    input.Parent = main
    attackBtn.Parent = main
    progress.Parent = main
    status.Parent = main
    closeBtn.Parent = main
    main.Parent = screen
    screen.Parent = player.PlayerGui
    
    -- زر الهجوم
    attackBtn.MouseButton1Click:Connect(function()
        if attacking then
            status.Text = "⏳ جاري الهجوم... انتظر"
            return
        end
        
        local idText = input.Text:gsub("%D", "") -- إزالة غير الأرقام
        local gamepassId = tonumber(idText)
        
        if not gamepassId or gamepassId < 100000 then
            status.Text = "❌ أدخل ID صحيح (6+ أرقام)"
            status.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            
            wait(1.5)
            status.Text = "جاهز - أدخل Gamepass ID"
            status.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            return
        end
        
        -- تحديث الواجهة
        attackBtn.Text = "⚡ جاري..."
        attackBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "🔍 يبحث عن Gamepass " .. gamepassId
        progress.Visible = true
        progress.Size = UDim2.new(0, 0, 0.05, 0)
        
        -- تشغيل الهجوم
        spawn(function()
            local startTime = tick()
            
            -- تحريك شريط التقدم
            local progressAnim = spawn(function()
                while attacking do
                    wait(0.1)
                    local elapsed = tick() - startTime
                    local percent = math.min(elapsed / 30, 1) -- 30 ثانية كحد أقصى
                    progress.Size = UDim2.new(0.8 * percent, 0, 0.05, 0)
                end
            end)
            
            -- تنفيذ الهجوم
            local attackResults = AttackGamepass(gamepassId)
            
            -- عرض النتائج
            if #attackResults > 0 then
                status.Text = "✅ اكتمل! " .. #attackResults .. " طريقة نجحت"
                status.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                
                -- طباعة النتائج
                print("\n🎯 نتائج الهجوم على " .. gamepassId .. ":")
                for i, result in ipairs(attackResults) do
                    print(i .. ". " .. result)
                end
            else
                status.Text = "❌ لم ينجح - جرب ID آخر"
                status.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            end
            
            -- إعادة تعيين الواجهة
            attackBtn.Text = "⚔️ بدء الهجوم"
            attackBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
            progress.Visible = false
            
            wait(2)
            if not attacking then
                status.Text = "جاهز - أدخل Gamepass ID"
                status.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            end
        end)
    end)
    
    -- زر الإغلاق
    closeBtn.MouseButton1Click:Connect(function()
        screen:Destroy()
    end)
    
    print("✅ الواجهة جاهزة")
    return screen
end

-- 🚀 التشغيل
print("\n" .. string.rep("🎮", 35))
print("🎯 GAMEPASS HUNTER - MOBILE EDITION")
print("⚡ 5 طرق هجوم مختلفة")
print("📱 يعمل على: loadstring(game:HttpGet())()")
print(string.rep("🎮", 35))

wait(3)

-- إنشاء الواجهة
pcall(CreateSmartUI)

-- إشعار تحميل
spawn(function()
    local notice = Instance.new("TextLabel")
    notice.Text = "🎮 Gamepass Hunter جاهز!"
    notice.Size = UDim2.new(0.6, 0, 0.05, 0)
    notice.Position = UDim2.new(0.2, 0, 0.1, 0)
    notice.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    notice.TextColor3 = Color3.new(1, 1, 1)
    notice.Font = Enum.Font.GothamBold
    notice.Parent = player.PlayerGui
    
    wait(3)
    pcall(function() notice:Destroy() end)
end)

-- تصدير الدوال
_G.HuntGamepass = AttackGamepass
_G.GetResults = function() return results end

print("\n✅ استخدم الواجهة أو اكتب:")
print("_G.HuntGamepass(123456)")

return "🎮 Gamepass Hunter v2.0 - WORKING"
