--[[
    RIVALS AIM ASSIST + XRAY v3.0
    لـ Delta Executor - Mobile
    المميزات:
    ✅ Aim Assist مع Zone حوالين الرأس (ينجذب بس يفك بحركة قوية)
    ✅ Xray أحمر تلقائي لكل الأعداء
    ✅ سلايدر للتحكم في حجم الـ Zone
    ✅ Switch تشغيل/إيقاف
    ✅ واجهة تتحرك بالإصبع
    ✅ تحديث مستمر كل إطار
]]--

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==================== VARIABLES ====================
local aimAssistEnabled = false
local aimZoneRadius = 100 -- حجم الـ Zone الافتراضي (بالبكسل)
local aimStrength = 0.4 -- قوة الانجذاب (أقل من 1 عشان يفك بحركة قوية)
local xrayParts = {} -- تخزين أجزاء الـ Xray
local activeHighlight = nil -- الإطار اللي حوالين العدو المستهدف

-- ==================== XRAY SYSTEM ====================
local function addXrayToPlayer(targetPlayer)
    -- نتأكد إن اللاعب مش أنا وإنه بشري
    if targetPlayer == LocalPlayer or targetPlayer.UserId == 0 then return end
    
    local function applyXray(character)
        -- ننتظر شوية عشان الكاركتر يتحمل
        wait(0.5)
        
        -- نجيب كل الأجزاء في الكاركتر
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                -- نعمل Highlight لكل جزء
                local highlight = Instance.new("Highlight")
                highlight.Name = "XrayHighlight"
                highlight.FillColor = Color3.fromRGB(255, 0, 0) -- أحمر
                highlight.FillTransparency = 0.6
                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- دايمًا فوق (Xray)
                highlight.Parent = part
                table.insert(xrayParts, highlight)
            end
        end
    end
    
    -- نشغل الـ Xray على الكاركتر الحالي
    if targetPlayer.Character then
        applyXray(targetPlayer.Character)
    end
    
    -- نشغله كل ما اللاعب يعمل Respawn
    targetPlayer.CharacterAdded:Connect(applyXray)
end

local function removeAllXray()
    for _, highlight in pairs(xrayParts) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    xrayParts = {}
    if activeHighlight then
        activeHighlight:Destroy()
        activeHighlight = nil
    end
end

-- ==================== AIM ASSIST SYSTEM ====================
local function getClosestEnemyHead()
    local closestPlayer = nil
    local closestDistance = aimZoneRadius
    local closestHeadPosition = nil
    
    -- نجيب مكان علامة التصويب (نص الشاشة)
    local screenCenter = Camera.ViewportSize / 2
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.UserId > 0 and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                -- نحول مكان الرأس من 3D لـ 2D (على الشاشة)
                local headScreenPosition, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    -- نحسب المسافة بين العلامة والرأس على الشاشة
                    local distance = (Vector2.new(headScreenPosition.X, headScreenPosition.Y) - screenCenter).Magnitude
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                        closestHeadPosition = headScreenPosition
                    end
                end
            end
        end
    end
    
    return closestPlayer, closestHeadPosition
end

local function updateAimHighlight(targetPlayer)
    -- نشيل الإطار القديم
    if activeHighlight then
        activeHighlight:Destroy()
        activeHighlight = nil
    end
    
    -- نضيف إطار جديد لو فيه هدف
    if targetPlayer and targetPlayer.Character then
        local head = targetPlayer.Character:FindFirstChild("Head")
        if head then
            activeHighlight = Instance.new("Highlight")
            activeHighlight.Name = "AimTarget"
            activeHighlight.FillColor = Color3.fromRGB(255, 255, 0) -- أصفر للهدف
            activeHighlight.FillTransparency = 0.8
            activeHighlight.OutlineColor = Color3.fromRGB(255, 255, 0)
            activeHighlight.OutlineTransparency = 0
            activeHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            activeHighlight.Parent = head
        end
    end
end

-- ==================== GUI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimAssistGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- الإطار الرئيسي
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 260, 0, 170)
mainFrame.Position = UDim2.new(0.5, -130, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 120)
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = mainFrame

-- ==================== TITLE ====================
local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "🎯 AIM ASSIST + XRAY"
titleLabel.Size = UDim2.new(1, 0, 0, 28)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.Parent = mainFrame

-- ==================== SWITCH ====================
local switchFrame = Instance.new("Frame")
switchFrame.Size = UDim2.new(0, 52, 0, 28)
switchFrame.Position = UDim2.new(0.08, 0, 0.25, 0)
switchFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
switchFrame.BorderSizePixel = 0
switchFrame.Parent = mainFrame

local switchFrameCorner = Instance.new("UICorner")
switchFrameCorner.CornerRadius = UDim.new(1, 0)
switchFrameCorner.Parent = switchFrame

local switchKnob = Instance.new("TextButton")
switchKnob.Size = UDim2.new(0, 26, 0, 26)
switchKnob.Position = UDim2.new(0, 1, 0, 1)
switchKnob.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
switchKnob.Text = ""
switchKnob.BorderSizePixel = 0
switchKnob.Parent = switchFrame

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = switchKnob

local switchLabel = Instance.new("TextLabel")
switchLabel.Text = "AIM: OFF"
switchLabel.Size = UDim2.new(0, 70, 0, 20)
switchLabel.Position = UDim2.new(0.38, 0, 0.25, 0)
switchLabel.BackgroundTransparency = 1
switchLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
switchLabel.Font = Enum.Font.GothamBold
switchLabel.TextSize = 12
switchLabel.Parent = mainFrame

-- ==================== ZONE SLIDER ====================
local zoneLabel = Instance.new("TextLabel")
zoneLabel.Text = "ZONE:"
zoneLabel.Size = UDim2.new(0, 40, 0, 20)
zoneLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
zoneLabel.BackgroundTransparency = 1
zoneLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
zoneLabel.Font = Enum.Font.Gotham
zoneLabel.TextSize = 11
zoneLabel.Parent = mainFrame

local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(0.52, 0, 0, 8)
sliderFrame.Position = UDim2.new(0.22, 0, 0.53, 0)
sliderFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
sliderFrame.BorderSizePixel = 0
sliderFrame.Parent = mainFrame

local sliderFrameCorner = Instance.new("UICorner")
sliderFrameCorner.CornerRadius = UDim.new(1, 0)
sliderFrameCorner.Parent = sliderFrame

local sliderKnob = Instance.new("TextButton")
sliderKnob.Size = UDim2.new(0, 22, 0, 22)
sliderKnob.Position = UDim2.new(0.3, -11, 0, -7)
sliderKnob.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
sliderKnob.Text = ""
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderFrame

local sliderKnobCorner = Instance.new("UICorner")
sliderKnobCorner.CornerRadius = UDim.new(1, 0)
sliderKnobCorner.Parent = sliderKnob

local sliderValueText = Instance.new("TextLabel")
sliderValueText.Text = "100px"
sliderValueText.Size = UDim2.new(0, 50, 0, 20)
sliderValueText.Position = UDim2.new(0.78, 0, 0.5, 0)
sliderValueText.BackgroundTransparency = 1
sliderValueText.TextColor3 = Color3.fromRGB(0, 200, 255)
sliderValueText.Font = Enum.Font.GothamBold
sliderValueText.TextSize = 12
sliderValueText.Parent = mainFrame

-- ==================== INFO TEXT ====================
local infoLabel = Instance.new("TextLabel")
infoLabel.Text = "🔴 Xray Active | 🟡 Target"
infoLabel.Size = UDim2.new(1, 0, 0, 20)
infoLabel.Position = UDim2.new(0, 0, 0.78, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 10
infoLabel.Parent = mainFrame

-- ==================== CLOSE BUTTON ====================
local closeButton = Instance.new("TextButton")
closeButton.Text = "✕"
closeButton.Size = UDim2.new(0, 28, 0, 28)
closeButton.Position = UDim2.new(1, -30, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 45, 45)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.BorderSizePixel = 0
closeButton.Parent = mainFrame

local closeButtonCorner = Instance.new("UICorner")
closeButtonCorner.CornerRadius = UDim.new(1, 0)
closeButtonCorner.Parent = closeButton

-- ==================== LOGIC EVENTS ====================
-- Switch
switchKnob.MouseButton1Click:Connect(function()
    aimAssistEnabled = not aimAssistEnabled
    
    if aimAssistEnabled then
        switchKnob.Position = UDim2.new(1, -27, 0, 1)
        switchKnob.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        switchFrame.BackgroundColor3 = Color3.fromRGB(0, 140, 60)
        switchLabel.Text = "AIM: ON"
        switchLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        switchKnob.Position = UDim2.new(0, 1, 0, 1)
        switchKnob.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        switchFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        switchLabel.Text = "AIM: OFF"
        switchLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        updateAimHighlight(nil)
    end
end)

-- Slider
local sliderDragging = false

local function updateSliderFromInput(inputPosition)
    local sliderPosX = sliderFrame.AbsolutePosition.X
    local sliderWidth = sliderFrame.AbsoluteSize.X
    local relativeX = math.clamp((inputPosition.X - sliderPosX) / sliderWidth, 0, 1)
    
    sliderKnob.Position = UDim2.new(relativeX, -11, 0, -7)
    aimZoneRadius = math.floor(30 + (relativeX * 270)) -- من 30px لـ 300px
    sliderValueText.Text = aimZoneRadius .. "px"
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
        updateSliderFromInput(input.Position)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)

-- Close
closeButton.MouseButton1Click:Connect(function()
    removeAllXray()
    screenGui:Destroy()
end)

-- GUI Dragging
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

-- ==================== MAIN AIM ASSIST LOOP ====================
local lastTarget = nil
local movementThreshold = 15 -- عتبة الحركة القوية اللي تفك الانجذاب (بالبكسل)
local previousTouchPosition = nil

RunService.RenderStepped:Connect(function()
    -- Xray دائم (حتى لو Aim Assist مقفول)
    -- بنشيك كل فترة بسيطة
    if not xrayParts._lastCheck then
        xrayParts._lastCheck = tick()
    end
    
    if tick() - xrayParts._lastCheck > 3 then
        xrayParts._lastCheck = tick()
        -- نتأكد إن كل الأعداء عليهم Xray
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.UserId > 0 then
                -- نشيك لو عنده Xray ولا لا
                local hasXray = false
                if player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        for _, child in pairs(head:GetChildren()) do
                            if child.Name == "XrayHighlight" then
                                hasXray = true
                                break
                            end
                        end
                    end
                end
                if not hasXray then
                    addXrayToPlayer(player)
                end
            end
        end
    end
    
    -- Aim Assist
    if not aimAssistEnabled then
        lastTarget = nil
        updateAimHighlight(nil)
        return
    end
    
    -- نجيب أقرب عدو
    local target, headPos = getClosestEnemyHead()
    
    if target and headPos then
        -- نجيب موقع اللمس الحالي
        local touchPositions = UserInputService:GetTouchPositions()
        local currentTouch = nil
        
        if #touchPositions > 0 then
            currentTouch = touchPositions[1] -- أول إصبع
        elseif UserInputService.MouseEnabled then
            -- لو على كمبيوتر (للاختبار)
            currentTouch = UserInputService:GetMouseLocation()
        end
        
        if currentTouch then
            -- نحسب المسافة بين اللمس الحالي وآخر لمسة
            if previousTouchPosition then
                local touchMovement = (currentTouch - previousTouchPosition).Magnitude
                
                -- لو الحركة قوية، نفك الانجذاب
                if touchMovement > movementThreshold then
                    lastTarget = nil
                    updateAimHighlight(nil)
                    previousTouchPosition = currentTouch
                    return
                end
            end
            
            -- نحسب الانجذاب الناعم
            local screenCenter = Camera.ViewportSize / 2
            local targetScreenPos = Vector2.new(headPos.X, headPos.Y)
            local pullDirection = targetScreenPos - screenCenter
            
            -- قوة الانجذاب (مش كاملة - عشان يفك بحركة قوية)
            local pullStrength = aimStrength
            
            -- نحرك العلامة ناحية الرأس شوية
            local newTouchPos = currentTouch + (pullDirection * pullStrength * 0.1)
            
            -- نحدث آخر موقع
            previousTouchPosition = currentTouch
            
            -- نظهر الإطار على الهدف
            if lastTarget ~= target then
                lastTarget = target
                updateAimHighlight(target)
            end
        end
    else
        -- مفيش هدف قريب
        if lastTarget then
            lastTarget = nil
            updateAimHighlight(nil)
        end
    end
end)

-- ==================== INITIALIZATION ====================
-- نشغل Xray على كل اللاعبين الموجودين
for _, player in pairs(Players:GetPlayers()) do
    addXrayToPlayer(player)
end

-- نشغل Xray على أي لاعب جديد يدخل
Players.PlayerAdded:Connect(function(player)
    addXrayToPlayer(player)
end)

-- ==================== PRINT SUCCESS ====================
print("="):rep(55)
print("✅ RIVALS AIM ASSIST + XRAY v3.0 LOADED!")
print("🎯 Aim Assist: Dynamic Zone with Soft Lock")
print("🔴 Xray: Always ON - All Enemies Red")
print("📱 Mobile Optimized - Touch Draggable GUI")
print("🎚️ Zone Range: 30px - 300px")
print("💡 Tip: Move finger hard to break aim lock")
print("="):rep(55)
