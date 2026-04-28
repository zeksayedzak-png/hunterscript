-- Rivals Head Hitbox Expander V2.0 for Delta Executor
-- With Real-time Update (0.2s Loop) & Proper Head Attachment

--[[
✅ Hitbox كروي متصل مباشرة برأس كل عدو
✅ تحديث كل 0.2 ثانية (يموتوا، يتحركوا، يسباون)
✅ يشتغل على اللاعبين الحقيقيين (البشر) فقط
✅ Switch لتشغيل/إيقاف
✅ سلايدر حجم من 1x لـ 10x
✅ زر شفافية كاملة / شبه شفافة
✅ واجهة متحركة بالإصبع
]]--

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ==================== VARIABLES ====================
local hitboxEnabled = false
local hitboxTransparent = false
local hitboxMultiplier = 2.0
local hitboxParts = {}
local updateConnection = nil

-- ==================== HITBOX CORE ====================
local function getRealPlayers()
    local realPlayers = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.UserId > 0 then -- لاعبين حقيقيين فقط (بشر)
            table.insert(realPlayers, p)
        end
    end
    return realPlayers
end

local function createHitboxForPlayer(targetPlayer)
    local character = targetPlayer.Character
    if not character then return nil end
    
    local head = character:FindFirstChild("Head")
    if not head then return nil end
    
    -- حذف الهيتبوكس القديم إذا موجود
    local oldHitbox = character:FindFirstChild("HeadHitbox")
    if oldHitbox then
        oldHitbox:Destroy()
    end
    
    -- إنشاء هيتبوكس جديد
    local hitbox = Instance.new("Part")
    hitbox.Name = "HeadHitbox"
    hitbox.Size = Vector3.new(hitboxMultiplier, hitboxMultiplier, hitboxMultiplier)
    hitbox.Shape = Enum.PartType.Ball -- دائري كروي
    hitbox.Anchored = false
    hitbox.CanCollide = false
    hitbox.Massless = true
    hitbox.CanQuery = false
    hitbox.CastShadow = false
    
    if hitboxTransparent then
        hitbox.Transparency = 1.0 -- شفاف تماماً
    else
        hitbox.Transparency = 0.65 -- شبه شفاف
    end
    
    hitbox.Material = Enum.Material.ForceField
    hitbox.Color = Color3.fromRGB(255, 30, 30)
    
    -- توصيل الهيتبوكس بالرأس باستخدام WeldConstraint
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hitbox
    weld.Part1 = head
    weld.Parent = hitbox
    
    hitbox.Parent = character
    
    return hitbox
end

local function clearAllHitboxes()
    for _, hitbox in pairs(hitboxParts) do
        if hitbox then
            pcall(function()
                hitbox:Destroy()
            end)
        end
    end
    hitboxParts = {}
end

local function updateAllHitboxes()
    -- مسح كل الهيتبوكسات القديمة أولاً
    clearAllHitboxes()
    
    if not hitboxEnabled then return end
    
    -- إنشاء هيتبوكسات جديدة لجميع اللاعبين الحقيقيين
    local realPlayers = getRealPlayers()
    for _, targetPlayer in pairs(realPlayers) do
        local hitbox = createHitboxForPlayer(targetPlayer)
        if hitbox then
            table.insert(hitboxParts, hitbox)
        end
    end
end

local function startUpdating()
    if updateConnection then
        updateConnection:Disconnect()
    end
    
    -- حلقة تحديث مستمرة كل 0.2 ثانية
    updateConnection = RunService.Heartbeat:Connect(function()
        if hitboxEnabled then
            -- استخدام عداد للتحكم في التوقيت
            if not updateConnection._lastUpdate then
                updateConnection._lastUpdate = tick()
            end
            
            if tick() - updateConnection._lastUpdate >= 0.2 then
                updateConnection._lastUpdate = tick()
                updateAllHitboxes()
            end
        end
    end)
end

local function stopUpdating()
    if updateConnection then
        updateConnection:Disconnect()
        updateConnection = nil
    end
    clearAllHitboxes()
end

-- ==================== GUI CREATION ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HitboxController"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- الإطار الرئيسي
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 270, 0, 200)
mainFrame.Position = UDim2.new(0.5, -135, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(80, 80, 100)
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = mainFrame

-- ==================== TITLE ====================
local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "🎯 RIVALS HITBOX v2.0"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 15
titleLabel.Parent = mainFrame

-- ==================== SWITCH BUTTON ====================
local switchFrame = Instance.new("Frame")
switchFrame.Size = UDim2.new(0, 56, 0, 30)
switchFrame.Position = UDim2.new(0.08, 0, 0.22, 0)
switchFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
switchFrame.BorderSizePixel = 0
switchFrame.Parent = mainFrame

local switchFrameCorner = Instance.new("UICorner")
switchFrameCorner.CornerRadius = UDim.new(1, 0)
switchFrameCorner.Parent = switchFrame

local switchKnob = Instance.new("TextButton")
switchKnob.Size = UDim2.new(0, 28, 0, 28)
switchKnob.Position = UDim2.new(0, 1, 0, 1)
switchKnob.BackgroundColor3 = Color3.fromRGB(255, 55, 55)
switchKnob.Text = ""
switchKnob.BorderSizePixel = 0
switchKnob.Parent = switchFrame

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = switchKnob

local switchStatusLabel = Instance.new("TextLabel")
switchStatusLabel.Text = "OFF"
switchStatusLabel.Size = UDim2.new(0, 45, 0, 22)
switchStatusLabel.Position = UDim2.new(0.35, 0, 0.22, 0)
switchStatusLabel.BackgroundTransparency = 1
switchStatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
switchStatusLabel.Font = Enum.Font.GothamBold
switchStatusLabel.TextSize = 13
switchStatusLabel.Parent = mainFrame

-- ==================== SLIDER ====================
local sliderLabel = Instance.new("TextLabel")
sliderLabel.Text = "Size:"
sliderLabel.Size = UDim2.new(0, 35, 0, 20)
sliderLabel.Position = UDim2.new(0.05, 0, 0.45, 0)
sliderLabel.BackgroundTransparency = 1
sliderLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.TextSize = 12
sliderLabel.Parent = mainFrame

local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(0.55, 0, 0, 8)
sliderFrame.Position = UDim2.new(0.2, 0, 0.48, 0)
sliderFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
sliderFrame.BorderSizePixel = 0
sliderFrame.Parent = mainFrame

local sliderFrameCorner = Instance.new("UICorner")
sliderFrameCorner.CornerRadius = UDim.new(1, 0)
sliderFrameCorner.Parent = sliderFrame

local sliderKnob = Instance.new("TextButton")
sliderKnob.Size = UDim2.new(0, 22, 0, 22)
sliderKnob.Position = UDim2.new(0.1, -11, 0, -7)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderKnob.Text = ""
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderFrame

local sliderKnobCorner = Instance.new("UICorner")
sliderKnobCorner.CornerRadius = UDim.new(1, 0)
sliderKnobCorner.Parent = sliderKnob

local sliderValueText = Instance.new("TextLabel")
sliderValueText.Text = "2.0x"
sliderValueText.Size = UDim2.new(0, 50, 0, 20)
sliderValueText.Position = UDim2.new(0.78, 0, 0.45, 0)
sliderValueText.BackgroundTransparency = 1
sliderValueText.TextColor3 = Color3.fromRGB(255, 255, 255)
sliderValueText.Font = Enum.Font.GothamBold
sliderValueText.TextSize = 13
sliderValueText.Parent = mainFrame

-- ==================== TRANSPARENCY TOGGLE ====================
local transparencyButton = Instance.new("TextButton")
transparencyButton.Size = UDim2.new(0, 42, 0, 42)
transparencyButton.Position = UDim2.new(0.08, 0, 0.65, 0)
transparencyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
transparencyButton.Text = ""
transparencyButton.BorderSizePixel = 1
transparencyButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
transparencyButton.Parent = mainFrame

local transButtonCorner = Instance.new("UICorner")
transButtonCorner.CornerRadius = UDim.new(0, 6)
transButtonCorner.Parent = transparencyButton

local checkMark = Instance.new("TextLabel")
checkMark.Text = ""
checkMark.Size = UDim2.new(1, 0, 1, 0)
checkMark.BackgroundTransparency = 1
checkMark.TextColor3 = Color3.fromRGB(0, 255, 80)
checkMark.Font = Enum.Font.GothamBold
checkMark.TextSize = 26
checkMark.Parent = transparencyButton

local transLabel = Instance.new("TextLabel")
transLabel.Text = "شفاف تماماً"
transLabel.Size = UDim2.new(0, 80, 0, 20)
transLabel.Position = UDim2.new(0.3, 0, 0.7, 0)
transLabel.BackgroundTransparency = 1
transLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
transLabel.Font = Enum.Font.Gotham
transLabel.TextSize = 11
transLabel.Parent = mainFrame

-- ==================== CLOSE BUTTON ====================
local closeButton = Instance.new("TextButton")
closeButton.Text = "✕"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -32, 0, 2)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 45, 45)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.BorderSizePixel = 0
closeButton.Parent = mainFrame

local closeButtonCorner = Instance.new("UICorner")
closeButtonCorner.CornerRadius = UDim.new(1, 0)
closeButtonCorner.Parent = closeButton

-- ==================== EVENTS ====================
-- Switch Toggle
switchKnob.MouseButton1Click:Connect(function()
    hitboxEnabled = not hitboxEnabled
    
    if hitboxEnabled then
        switchKnob.Position = UDim2.new(1, -29, 0, 1)
        switchKnob.BackgroundColor3 = Color3.fromRGB(0, 210, 80)
        switchFrame.BackgroundColor3 = Color3.fromRGB(0, 150, 60)
        switchStatusLabel.Text = "ON"
        switchStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        updateAllHitboxes()
        startUpdating()
    else
        switchKnob.Position = UDim2.new(0, 1, 0, 1)
        switchKnob.BackgroundColor3 = Color3.fromRGB(255, 55, 55)
        switchFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        switchStatusLabel.Text = "OFF"
        switchStatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        stopUpdating()
    end
end)

-- Slider
local sliderDragging = false

local function updateSliderFromPosition(inputPosition)
    local sliderPosX = sliderFrame.AbsolutePosition.X
    local sliderWidth = sliderFrame.AbsoluteSize.X
    local relativeX = math.clamp((inputPosition.X - sliderPosX) / sliderWidth, 0, 1)
    
    sliderKnob.Position = UDim2.new(relativeX, -11, 0, -7)
    hitboxMultiplier = 1 + (relativeX * 9)
    sliderValueText.Text = string.format("%.1fx", hitboxMultiplier)
    
    if hitboxEnabled then
        updateAllHitboxes()
    end
end

sliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                           input.UserInputType == Enum.UserInputType.Touch) then
        updateSliderFromPosition(input.Position)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)

-- Transparency Toggle
transparencyButton.MouseButton1Click:Connect(function()
    hitboxTransparent = not hitboxTransparent
    
    if hitboxTransparent then
        checkMark.Text = "✓"
        transLabel.Text = "شبه شفاف"
        transparencyButton.BorderColor3 = Color3.fromRGB(0, 255, 80)
    else
        checkMark.Text = ""
        transLabel.Text = "شفاف تماماً"
        transparencyButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
    end
    
    if hitboxEnabled then
        updateAllHitboxes()
    end
end)

-- Close Button
closeButton.MouseButton1Click:Connect(function()
    stopUpdating()
    screenGui:Destroy()
end)

-- Dragging
local dragging = false
local dragStart = nil
local frameStartPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        frameStartPos = mainFrame.Position
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            frameStartPos.X.Scale,
            frameStartPos.X.Offset + delta.X,
            frameStartPos.Y.Scale,
            frameStartPos.Y.Offset + delta.Y
        )
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ==================== INITIAL SETUP ====================
-- تحديث عند دخول لاعبين جدد
Players.PlayerAdded:Connect(function(newPlayer)
    if hitboxEnabled and newPlayer ~= player and newPlayer.UserId > 0 then
        newPlayer.CharacterAdded:Connect(function(char)
            wait(0.3)
            if hitboxEnabled then
                updateAllHitboxes()
            end
        end)
    end
end)

print("="):rep(50)
print("✅ RIVALS HEAD HITBOX v2.0 LOADED!")
print("🔄 Real-time Update: Every 0.2 seconds")
print("👤 Real Players Only (Human Detection)")
print("🎮 Mobile Drag Support")
print("📐 Ball Shape Hitbox on Enemy Heads")
print("="):rep(50)
