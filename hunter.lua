--[[
    RIVALS AIM ASSIST + XRAY v4.0 - SIMPLE VERSION
    Delta Executor Mobile
    ✅ Aim Assist: الكاميرا تتحرك تلقائي نحو رأس أقرب عدو
    ✅ Xray أحمر لكل الأعداء
    ✅ سلايدر للتحكم في مدى الـ Aim
    ✅ Switch تشغيل/إيقاف
    ✅ واجهة تتحرك بالإصبع
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==================== إعدادات ====================
local aimEnabled = false
local aimRange = 150 -- مدى الـ Aim بالبكسل
local aimSmoothness = 8 -- نعومة الحركة (أكبر = أنعم)
local xrayParts = {}

-- ==================== XRAY ====================
local function addXray(player)
    if player == LocalPlayer or player.UserId == 0 then return end
    
    local function onCharacter(character)
        wait(0.3)
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                local h = Instance.new("Highlight")
                h.Name = "Xray"
                h.FillColor = Color3.fromRGB(255, 0, 0)
                h.FillTransparency = 0.6
                h.OutlineColor = Color3.fromRGB(255, 0, 0)
                h.OutlineTransparency = 0
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent = part
                table.insert(xrayParts, h)
            end
        end
    end
    
    if player.Character then onCharacter(player.Character) end
    player.CharacterAdded:Connect(onCharacter)
end

local function clearXray()
    for _, h in pairs(xrayParts) do
        if h and h.Parent then h:Destroy() end
    end
    xrayParts = {}
end

-- ==================== AIM ASSIST ====================
local function getTarget()
    local best = nil
    local bestDist = aimRange
    local center = Camera.ViewportSize / 2
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.UserId > 0 and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        best = head
                    end
                end
            end
        end
    end
    
    return best
end

-- ==================== GUI ====================
local gui = Instance.new("ScreenGui")
gui.Name = "AimXray"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 160)
frame.Position = UDim2.new(0.5, -120, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(80, 80, 100)
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Text = "🎯 AIM + XRAY v4"
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.Parent = frame

-- Switch
local switchBg = Instance.new("Frame")
switchBg.Size = UDim2.new(0, 48, 0, 26)
switchBg.Position = UDim2.new(0.08, 0, 0.28, 0)
switchBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
switchBg.BorderSizePixel = 0
switchBg.Parent = frame

local switchBgCorner = Instance.new("UICorner")
switchBgCorner.CornerRadius = UDim.new(1, 0)
switchBgCorner.Parent = switchBg

local switchKnob = Instance.new("TextButton")
switchKnob.Size = UDim2.new(0, 24, 0, 24)
switchKnob.Position = UDim2.new(0, 1, 0, 1)
switchKnob.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
switchKnob.Text = ""
switchKnob.BorderSizePixel = 0
switchKnob.Parent = switchBg

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = switchKnob

local switchText = Instance.new("TextLabel")
switchText.Text = "AIM: OFF"
switchText.Size = UDim2.new(0, 65, 0, 20)
switchText.Position = UDim2.new(0.38, 0, 0.28, 0)
switchText.BackgroundTransparency = 1
switchText.TextColor3 = Color3.fromRGB(255, 80, 80)
switchText.Font = Enum.Font.GothamBold
switchText.TextSize = 12
switchText.Parent = frame

-- Slider
local sliderLabel = Instance.new("TextLabel")
sliderLabel.Text = "Range:"
sliderLabel.Size = UDim2.new(0, 40, 0, 20)
sliderLabel.Position = UDim2.new(0.05, 0, 0.55, 0)
sliderLabel.BackgroundTransparency = 1
sliderLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.TextSize = 11
sliderLabel.Parent = frame

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(0.5, 0, 0, 8)
sliderBg.Position = UDim2.new(0.24, 0, 0.58, 0)
sliderBg.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = frame

local sliderBgCorner = Instance.new("UICorner")
sliderBgCorner.CornerRadius = UDim.new(1, 0)
sliderBgCorner.Parent = sliderBg

local sliderKnob = Instance.new("TextButton")
sliderKnob.Size = UDim2.new(0, 20, 0, 20)
sliderKnob.Position = UDim2.new(0.3, -10, 0, -6)
sliderKnob.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
sliderKnob.Text = ""
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderBg

local sliderKnobCorner = Instance.new("UICorner")
sliderKnobCorner.CornerRadius = UDim.new(1, 0)
sliderKnobCorner.Parent = sliderKnob

local sliderValue = Instance.new("TextLabel")
sliderValue.Text = "150px"
sliderValue.Size = UDim2.new(0, 50, 0, 20)
sliderValue.Position = UDim2.new(0.78, 0, 0.55, 0)
sliderValue.BackgroundTransparency = 1
sliderValue.TextColor3 = Color3.fromRGB(0, 200, 255)
sliderValue.Font = Enum.Font.GothamBold
sliderValue.TextSize = 12
sliderValue.Parent = frame

-- Info
local info = Instance.new("TextLabel")
info.Text = "🔴 Xray Active"
info.Size = UDim2.new(1, 0, 0, 20)
info.Position = UDim2.new(0, 0, 0.8, 0)
info.BackgroundTransparency = 1
info.TextColor3 = Color3.fromRGB(140, 140, 140)
info.Font = Enum.Font.Gotham
info.TextSize = 10
info.Parent = frame

-- Close
local close = Instance.new("TextButton")
close.Text = "✕"
close.Size = UDim2.new(0, 26, 0, 26)
close.Position = UDim2.new(1, -28, 0, 3)
close.BackgroundColor3 = Color3.fromRGB(255, 45, 45)
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Font = Enum.Font.GothamBold
close.TextSize = 13
close.BorderSizePixel = 0
close.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = close

-- ==================== EVENTS ====================
switchKnob.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    if aimEnabled then
        switchKnob.Position = UDim2.new(1, -25, 0, 1)
        switchKnob.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        switchBg.BackgroundColor3 = Color3.fromRGB(0, 140, 60)
        switchText.Text = "AIM: ON"
        switchText.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        switchKnob.Position = UDim2.new(0, 1, 0, 1)
        switchKnob.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        switchBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        switchText.Text = "AIM: OFF"
        switchText.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

-- Slider Drag
local dragging = false
sliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local pos = sliderBg.AbsolutePosition.X
        local width = sliderBg.AbsoluteSize.X
        local rel = math.clamp((input.Position.X - pos) / width, 0, 1)
        sliderKnob.Position = UDim2.new(rel, -10, 0, -6)
        aimRange = math.floor(30 + rel * 270)
        sliderValue.Text = aimRange .. "px"
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Close
close.MouseButton1Click:Connect(function()
    clearXray()
    gui:Destroy()
end)

-- Frame Drag
local fDragging = false
local fStart = nil
local fPos = nil

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        fDragging = true
        fStart = input.Position
        fPos = frame.Position
    end
end)

frame.InputChanged:Connect(function(input)
    if fDragging and input.UserInputType == Enum.UserInputType.Touch then
        local d = input.Position - fStart
        frame.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + d.X, fPos.Y.Scale, fPos.Y.Offset + d.Y)
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        fDragging = false
    end
end)

-- ==================== AIM LOOP ====================
RunService.RenderStepped:Connect(function()
    if not aimEnabled then return end
    
    local target = getTarget()
    if target then
        -- نحرك الكاميرا نحو الرأس بنعومة
        local targetPos = target.Position
        local camPos = Camera.CFrame.Position
        local direction = (targetPos - camPos).Unit
        local lookAt = camPos + direction * 10
        
        Camera.CFrame = Camera.CFrame:Lerp(
            CFrame.new(camPos, targetPos),
            1 / aimSmoothness
        )
    end
end)

-- ==================== INIT ====================
for _, p in pairs(Players:GetPlayers()) do
    addXray(p)
end

Players.PlayerAdded:Connect(addXray)

print("✅ RIVALS AIM + XRAY v4 LOADED")
