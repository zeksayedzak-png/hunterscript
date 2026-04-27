--[[
    RIVALS - Smart Head Hitbox Aimbot
    لماب RIVALS - منفذ Delta
    الميزات: Hitbox متغير + Switch + Slider + واجهة متحركة
]]

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- ==================== الإعدادات ====================
local settings = {
    enabled = false,
    hitboxSize = 50, -- الحجم الافتراضي (0-100)
}

-- ==================== إنشاء Hitboxes ====================
local function createHitbox(targetPlayer)
    if not targetPlayer.Character then return end
    local head = targetPlayer.Character:FindFirstChild("Head")
    if not head then return end
    
    -- إزالة القديم
    local old = targetPlayer.Character:FindFirstChild("HitboxHead")
    if old then old:Destroy() end
    
    -- صنع كرة شفافة حول الرأس
    local hitbox = Instance.new("Part")
    hitbox.Name = "HitboxHead"
    hitbox.Shape = Enum.PartType.Ball
    hitbox.Material = Enum.Material.ForceField
    hitbox.Color = Color3.fromRGB(255, 0, 0)
    hitbox.Transparency = 0.6
    hitbox.Anchored = true
    hitbox.CanCollide = false
    hitbox.CanTouch = false
    hitbox.CanQuery = false
    hitbox.Massless = true
    hitbox.Parent = targetPlayer.Character
    
    -- تحديث الحجم والمكان
    local function updateHitbox()
        if not hitbox or not hitbox.Parent or not head or not head.Parent then
            if hitbox then hitbox:Destroy() end
            return
        end
        local size = settings.hitboxSize / 10 -- تحويل 0-100 إلى حجم
        hitbox.Size = Vector3.new(size, size, size)
        hitbox.Position = head.Position
    end
    
    -- ربط التحديث
    runService.Heartbeat:Connect(function()
        if settings.enabled and hitbox and hitbox.Parent then
            updateHitbox()
        end
    end)
    
    return hitbox
end

-- تحديث كل الهيتبوكسات
local function refreshAllHitboxes()
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            createHitbox(plr)
        end
    end
end

-- عند دخول لاعب جديد
game.Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        wait(1)
        if settings.enabled then
            createHitbox(plr)
        end
    end)
end)

-- ==================== الواجهة (GUI) ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RivalsAimbot"
screenGui.Parent = player:PlayerGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- الحاوية الرئيسية (قابلة للسحب)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 180, 0, 80)
mainFrame.Position = UDim2.new(0.5, -90, 0.5, -40)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- زوايا دائرية
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- ==================== نظام السحب ====================
local dragging = false
local dragStart = nil
local startPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

uis.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

uis.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ==================== الـ SWITCH ====================
local switchButton = Instance.new("TextButton")
switchButton.Name = "Switch"
switchButton.Size = UDim2.new(0, 44, 0, 24)
switchButton.Position = UDim2.new(0, 10, 0, 10)
switchButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- أحمر = متوقف
switchButton.Text = ""
switchButton.BorderSizePixel = 0
switchButton.AutoButtonColor = false
switchButton.Parent = mainFrame

local switchCorner = Instance.new("UICorner")
switchCorner.CornerRadius = UDim.new(1, 0)
switchCorner.Parent = switchButton

-- الدائرة اللي بتتحرك داخل السويتش
local switchKnob = Instance.new("Frame")
switchKnob.Name = "Knob"
switchKnob.Size = UDim2.new(0, 20, 0, 20)
switchKnob.Position = UDim2.new(0, 2, 0, 2) -- يبدأ يسار
switchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
switchKnob.BorderSizePixel = 0
switchKnob.Parent = switchButton

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = switchKnob

-- وظيفة السويتش
local function toggleAimbot()
    settings.enabled = not settings.enabled
    
    if settings.enabled then
        -- أخضر = شغال، الدائرة تروح يمين
        switchButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        switchKnob:TweenPosition(
            UDim2.new(0, 22, 0, 2),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.2,
            true
        )
        refreshAllHitboxes()
    else
        -- أحمر = متوقف، الدائرة ترجع يسار
        switchButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        switchKnob:TweenPosition(
            UDim2.new(0, 2, 0, 2),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.2,
            true
        )
        -- تدمير كل الهيتبوكسات
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local hb = plr.Character:FindFirstChild("HitboxHead")
                if hb then hb:Destroy() end
            end
        end
    end
end

switchButton.MouseButton1Click:Connect(toggleAimbot)

-- ==================== الـ SLIDER ====================
local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(0, 160, 0, 14)
sliderLabel.Position = UDim2.new(0, 10, 0, 40)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "Hitbox: 50"
sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
sliderLabel.TextSize = 12
sliderLabel.Font = Enum.Font.SourceSansBold
sliderLabel.TextXAlignment = Enum.TextXAlignment.Center
sliderLabel.Parent = mainFrame

-- خط السلايدر
local sliderTrack = Instance.new("Frame")
sliderTrack.Name = "Track"
sliderTrack.Size = UDim2.new(0, 160, 0, 6)
sliderTrack.Position = UDim2.new(0, 10, 0, 56)
sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
sliderTrack.BorderSizePixel = 0
sliderTrack.Parent = mainFrame

local trackCorner = Instance.new("UICorner")
trackCorner.CornerRadius = UDim.new(1, 0)
trackCorner.Parent = sliderTrack

-- دائرة السلايدر
local sliderKnob = Instance.new("Frame")
sliderKnob.Name = "SliderKnob"
sliderKnob.Size = UDim2.new(0, 18, 0, 18)
sliderKnob.Position = UDim2.new(0.5, -9, 0, -6)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderTrack

local sliderKnobCorner = Instance.new("UICorner")
sliderKnobCorner.CornerRadius = UDim.new(1, 0)
sliderKnobCorner.Parent = sliderKnob

-- ملء السلايدر (الجزء الأخضر)
local sliderFill = Instance.new("Frame")
sliderFill.Name = "Fill"
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.Position = UDim2.new(0, 0, 0, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderTrack

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = sliderFill

-- منطق السلايدر
local function updateSlider(input)
    local trackAbsPos = sliderTrack.AbsolutePosition
    local trackWidth = sliderTrack.AbsoluteSize.X
    local relativeX = math.clamp(input.Position.X - trackAbsPos.X, 0, trackWidth)
    local percent = relativeX / trackWidth
    local value = math.floor(percent * 100)
    
    settings.hitboxSize = value
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderKnob.Position = UDim2.new(percent, -9, 0, -6)
    sliderLabel.Text = "Hitbox: " .. value
end

local sliderDragging = false

sliderTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = true
        updateSlider(input)
    end
end)

sliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = true
    end
end)

uis.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        updateSlider(input)
    end
end)

uis.InputEnded:Connect(function(input)
    sliderDragging = false
end)

-- ==================== إعادة تهيئة عند الموت ====================
player.CharacterAdded:Connect(function()
    wait(1)
    if settings.enabled then
        refreshAllHitboxes()
    end
end)

-- ==================== رسالة جاهزية ====================
print("✅ RIVALS Aimbot جاهز | Switch + Slider + Hitbox متصل بالرأس")
