-- Rivals Head Hitbox Expander for Delta Executor
-- Mobile Optimized GUI with Full Controls

--[[
المميزات:
✅ Hitbox دائري شفاف متصل برأس كل لاعب
✅ زر Switch للتشغيل/الإيقاف (أخضر = شغال / أحمر = مقفول)
✅ سلايدر من 0 لـ 100 للتحكم بحجم الـ Hitbox
✅ زر Toggle للشفافية الكاملة أو الشبه شفافة
✅ واجهة قابلة للسحب بالإصبع
✅ مخصص للعبة Rivals
]]--

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ==================== VARIABLES ====================
local hitboxEnabled = false
local hitboxTransparent = false
local hitboxMultiplier = 2.0 -- القيمة الافتراضية (السلايدر يتحكم فيها)
local hitboxParts = {} -- جدول لتخزين أجزاء الهيتبوكس

-- ==================== FUNCTIONS ====================
local function createHitbox(targetPlayer)
    local character = targetPlayer.Character
    if not character then return end
    
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    -- التحقق من عدم وجود Hitbox سابق
    local existing = character:FindFirstChild("HeadHitbox")
    if existing then
        existing:Destroy()
    end
    
    -- إنشاء Hitbox
    local hitbox = Instance.new("Part")
    hitbox.Name = "HeadHitbox"
    hitbox.Size = Vector3.new(hitboxMultiplier, hitboxMultiplier, hitboxMultiplier)
    hitbox.Shape = Enum.PartType.Ball -- دائري
    hitbox.Anchored = false
    hitbox.CanCollide = false
    hitbox.Massless = true
    
    if hitboxTransparent then
        hitbox.Transparency = 1 -- شفاف تماماً
        hitbox.Material = Enum.Material.ForceField
        hitbox.Color = Color3.fromRGB(255, 0, 0)
    else
        hitbox.Transparency = 0.7 -- شبه شفاف
        hitbox.Material = Enum.Material.ForceField
        hitbox.Color = Color3.fromRGB(255, 0, 0)
    end
    
    -- توصيل بالرأس
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hitbox
    weld.Part1 = head
    weld.Parent = hitbox
    
    hitbox.Parent = character
    table.insert(hitboxParts, hitbox)
end

local function removeAllHitboxes()
    for _, hitbox in pairs(hitboxParts) do
        if hitbox and hitbox.Parent then
            hitbox:Destroy()
        end
    end
    hitboxParts = {}
end

local function updateAllHitboxes()
    removeAllHitboxes()
    if hitboxEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                createHitbox(p)
            end
        end
    end
end

-- ==================== GUI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HitboxController"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- الإطار الرئيسي
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 260, 0, 180)
mainFrame.Position = UDim2.new(0.5, -130, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 120)
mainFrame.Parent = screenGui

-- عنوان
local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "🎯 Rivals Hitbox"
titleLabel.Size = UDim2.new(1, 0, 0, 28)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Parent = mainFrame

-- زر التشغيل/الإيقاف
local toggleSwitch = Instance.new("TextButton")
toggleSwitch.Name = "ToggleSwitch"
toggleSwitch.Size = UDim2.new(0, 50, 0, 50)
toggleSwitch.Position = UDim2.new(0.05, 0, 0.2, 0)
toggleSwitch.BackgroundColor3 = Color3.fromRGB(255, 60, 60) -- أحمر = مقفول
toggleSwitch.Text = ""
toggleSwitch.BorderSizePixel = 0
toggleSwitch.Parent = mainFrame

local switchCorner = Instance.new("UICorner")
switchCorner.CornerRadius = UDim.new(1, 0)
switchCorner.Parent = toggleSwitch

local switchLabel = Instance.new("TextLabel")
switchLabel.Text = "OFF"
switchLabel.Size = UDim2.new(1, 0, 1, 0)
switchLabel.BackgroundTransparency = 1
switchLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
switchLabel.Font = Enum.Font.GothamBold
switchLabel.TextSize = 14
switchLabel.Parent = toggleSwitch

-- سلايدر التحكم بالحجم
local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(0.6, 0, 0, 8)
sliderFrame.Position = UDim2.new(0.35, 0, 0.28, 0)
sliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
sliderFrame.BorderSizePixel = 0
sliderFrame.Parent = mainFrame

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = sliderFrame

local sliderKnob = Instance.new("TextButton")
sliderKnob.Size = UDim2.new(0, 24, 0, 24)
sliderKnob.Position = UDim2.new(0.5, -12, 0, -8)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderKnob.Text = ""
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderFrame

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = sliderKnob

local sliderValueText = Instance.new("TextLabel")
sliderValueText.Text = "2.0x"
sliderValueText.Size = UDim2.new(0.6, 0, 0, 20)
sliderValueText.Position = UDim2.new(0.35, 0, 0.45, 0)
sliderValueText.BackgroundTransparency = 1
sliderValueText.TextColor3 = Color3.fromRGB(200, 200, 200)
sliderValueText.Font = Enum.Font.Gotham
sliderValueText.TextSize = 12
sliderValueText.Parent = mainFrame

-- زر الشفافية
local transparencyToggle = Instance.new("TextButton")
transparencyToggle.Size = UDim2.new(0, 40, 0, 40)
transparencyToggle.Position = UDim2.new(0.05, 0, 0.62, 0)
transparencyToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
transparencyToggle.Text = ""
transparencyToggle.BorderSizePixel = 1
transparencyToggle.BorderColor3 = Color3.fromRGB(100, 100, 100)
transparencyToggle.Parent = mainFrame

local transCorner = Instance.new("UICorner")
transCorner.CornerRadius = UDim.new(0.2, 0)
transCorner.Parent = transparencyToggle

local checkMark = Instance.new("TextLabel")
checkMark.Text = ""
checkMark.Size = UDim2.new(1, 0, 1, 0)
checkMark.BackgroundTransparency = 1
checkMark.TextColor3 = Color3.fromRGB(0, 255, 0)
checkMark.Font = Enum.Font.GothamBold
checkMark.TextSize = 24
checkMark.Parent = transparencyToggle

local transLabel = Instance.new("TextLabel")
transLabel.Text = "شفاف"
transLabel.Size = UDim2.new(0.4, 0, 0, 20)
transLabel.Position = UDim2.new(0.3, 0, 0.68, 0)
transLabel.BackgroundTransparency = 1
transLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
transLabel.Font = Enum.Font.Gotham
transLabel.TextSize = 11
transLabel.Parent = mainFrame

-- زر الإغلاق
local closeButton = Instance.new("TextButton")
closeButton.Text = "✕"
closeButton.Size = UDim2.new(0, 28, 0, 28)
closeButton.Position = UDim2.new(1, -28, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.BorderSizePixel = 0
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeButton

-- ==================== INTERACTIONS ====================
-- Toggle Switch
toggleSwitch.MouseButton1Click:Connect(function()
    hitboxEnabled = not hitboxEnabled
    
    if hitboxEnabled then
        toggleSwitch.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        toggleSwitch.Position = UDim2.new(0.15, 0, 0.2, 0) -- يروح لليمين
        switchLabel.Text = "ON"
        updateAllHitboxes()
    else
        toggleSwitch.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        toggleSwitch.Position = UDim2.new(0.05, 0, 0.2, 0) -- يرجع لليسار
        switchLabel.Text = "OFF"
        removeAllHitboxes()
    end
end)

-- Slider Dragging
local sliderDragging = false

sliderKnob.MouseButton1Down:Connect(function()
    sliderDragging = true
end)

sliderKnob.MouseButton1Up:Connect(function()
    sliderDragging = false
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                           input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos = UserInputService:GetMouseLocation()
        local sliderPos = sliderFrame.AbsolutePosition.X
        local sliderWidth = sliderFrame.AbsoluteSize.X
        
        local relativeX = math.clamp((mousePos.X - sliderPos) / sliderWidth, 0, 1)
        sliderKnob.Position = UDim2.new(relativeX, -12, 0, -8)
        
        hitboxMultiplier = 1 + (relativeX * 9) -- 1x لـ 10x
        sliderValueText.Text = string.format("%.1fx", hitboxMultiplier)
        
        if hitboxEnabled then
            updateAllHitboxes()
        end
    end
end)

-- Transparency Toggle
transparencyToggle.MouseButton1Click:Connect(function()
    hitboxTransparent = not hitboxTransparent
    
    if hitboxTransparent then
        checkMark.Text = "✓"
        transLabel.Text = "مرئي"
        if hitboxEnabled then
            updateAllHitboxes()
        end
    else
        checkMark.Text = ""
        transLabel.Text = "شفاف"
        if hitboxEnabled then
            updateAllHitboxes()
        end
    end
end)

-- Close Button
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    removeAllHitboxes()
end)

-- Dragging main frame
local dragActive = false
local dragStart = nil
local startPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragActive = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if dragActive and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragActive = false
    end
end)

-- تحديث الهيتبوكس عند دخول لاعب جديد
Players.PlayerAdded:Connect(function(newPlayer)
    if hitboxEnabled and newPlayer ~= player then
        newPlayer.CharacterAdded:Connect(function()
            wait(0.5)
            if hitboxEnabled then
                createHitbox(newPlayer)
            end
        end)
    end
end)

-- تحديث لجميع اللاعبين الموجودين
for _, p in pairs(Players:GetPlayers()) do
    if p ~= player then
        p.CharacterAdded:Connect(function()
            wait(0.5)
            if hitboxEnabled then
                createHitbox(p)
            end
        end)
    end
end

print("✅ Rivals Hitbox Script Loaded Successfully!")
print("🎯 Controls: Switch | Slider (1x-10x) | Transparency | Draggable")
