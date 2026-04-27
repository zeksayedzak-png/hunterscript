local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local settings = {
    enabled = false,
    hitboxSize = 50,
}

-- HITBOX
local function createHitbox(targetPlayer)
    if not targetPlayer.Character then return end
    local head = targetPlayer.Character:FindFirstChild("Head")
    if not head then return end
    pcall(function()
        local old = targetPlayer.Character:FindFirstChild("HitboxHead")
        if old then old:Destroy() end
    end)
    local hitbox = Instance.new("Part")
    hitbox.Name = "HitboxHead"
    hitbox.Shape = Enum.PartType.Ball
    hitbox.Material = Enum.Material.ForceField
    hitbox.Color = Color3.fromRGB(255, 0, 0)
    hitbox.Transparency = 0.5
    hitbox.Anchored = true
    hitbox.CanCollide = false
    hitbox.CanTouch = false
    hitbox.CanQuery = false
    hitbox.Massless = true
    hitbox.Size = Vector3.new(5, 5, 5)
    hitbox.Parent = targetPlayer.Character
    runService.Heartbeat:Connect(function()
        pcall(function()
            if hitbox and hitbox.Parent and head and head.Parent then
                if settings.enabled then
                    local size = settings.hitboxSize / 10
                    hitbox.Size = Vector3.new(size, size, size)
                    hitbox.Position = head.Position
                    hitbox.Transparency = 0.5
                else
                    hitbox.Transparency = 1
                end
            end
        end)
    end)
end

local function refreshAll()
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            createHitbox(plr)
        end
    end
end

refreshAll()

game.Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        createHitbox(plr)
    end)
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    refreshAll()
end)

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RivalsAimbot"
screenGui.Parent = player:PlayerGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 170, 0, 75)
mainFrame.Position = UDim2.new(0.5, -85, 0.5, -37)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BackgroundTransparency = 0.25
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- سحب
local dragActive = false
local frameStart = nil

local dragDetector = Instance.new("TextButton")
dragDetector.Size = UDim2.new(1, 0, 1, 0)
dragDetector.BackgroundTransparency = 1
dragDetector.Text = ""
dragDetector.AutoButtonColor = false
dragDetector.ZIndex = 10
dragDetector.Parent = mainFrame

dragDetector.TouchPan:Connect(function(touchPositions, totalTranslation, velocity, state)
    if state == Enum.UserInputState.Begin then
        dragActive = true
        frameStart = mainFrame.Position
    elseif state == Enum.UserInputState.Change and dragActive then
        mainFrame.Position = UDim2.new(
            frameStart.X.Scale,
            frameStart.X.Offset + totalTranslation.X,
            frameStart.Y.Scale,
            frameStart.Y.Offset + totalTranslation.Y
        )
    elseif state == Enum.UserInputState.End then
        dragActive = false
    end
end)

-- SWITCH
local switchButton = Instance.new("TextButton")
switchButton.Size = UDim2.new(0, 40, 0, 22)
switchButton.Position = UDim2.new(0, 8, 0, 8)
switchButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
switchButton.Text = ""
switchButton.BorderSizePixel = 0
switchButton.AutoButtonColor = false
switchButton.ZIndex = 5
switchButton.Parent = mainFrame
Instance.new("UICorner", switchButton).CornerRadius = UDim.new(1, 0)

local switchKnob = Instance.new("Frame")
switchKnob.Size = UDim2.new(0, 18, 0, 18)
switchKnob.Position = UDim2.new(0, 2, 0, 2)
switchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
switchKnob.BorderSizePixel = 0
switchKnob.ZIndex = 6
switchKnob.Parent = switchButton
Instance.new("UICorner", switchKnob).CornerRadius = UDim.new(1, 0)

switchButton.Tap:Connect(function()
    settings.enabled = not settings.enabled
    if settings.enabled then
        switchButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        switchKnob:TweenPosition(UDim2.new(0, 20, 0, 2), "Out", "Quad", 0.15, true)
    else
        switchButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        switchKnob:TweenPosition(UDim2.new(0, 2, 0, 2), "Out", "Quad", 0.15, true)
    end
end)

-- SLIDER
local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(0, 150, 0, 12)
sliderLabel.Position = UDim2.new(0, 10, 0, 35)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "Hitbox: 50"
sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
sliderLabel.TextSize = 11
sliderLabel.Font = Enum.Font.SourceSansBold
sliderLabel.TextXAlignment = Enum.TextXAlignment.Center
sliderLabel.ZIndex = 5
sliderLabel.Parent = mainFrame

local sliderTrack = Instance.new("TextButton")
sliderTrack.Size = UDim2.new(0, 150, 0, 5)
sliderTrack.Position = UDim2.new(0, 10, 0, 50)
sliderTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
sliderTrack.BorderSizePixel = 0
sliderTrack.Text = ""
sliderTrack.AutoButtonColor = false
sliderTrack.ZIndex = 5
sliderTrack.Parent = mainFrame
Instance.new("UICorner", sliderTrack).CornerRadius = UDim.new(1, 0)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
sliderFill.BorderSizePixel = 0
sliderFill.ZIndex = 6
sliderFill.Parent = sliderTrack
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0, 16, 0, 16)
sliderKnob.Position = UDim2.new(0.5, -8, 0, -5)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderKnob.BorderSizePixel = 0
sliderKnob.ZIndex = 7
sliderKnob.Parent = sliderTrack
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

local function updateSlider(touchPos)
    local absPos = sliderTrack.AbsolutePosition
    local absSize = sliderTrack.AbsoluteSize
    local relX = math.clamp(touchPos.X - absPos.X, 0, absSize.X)
    local pct = relX / absSize.X
    local val = math.floor(pct * 100)
    settings.hitboxSize = val
    sliderFill.Size = UDim2.new(pct, 0, 1, 0)
    sliderKnob.Position = UDim2.new(pct, -8, 0, -5)
    sliderLabel.Text = "Hitbox: " .. val
end

sliderTrack.Tap:Connect(function(input)
    updateSlider(input.Position)
end)

sliderKnob.TouchPan:Connect(function(touchPositions, totalTranslation, velocity, state)
    local absPos = sliderTrack.AbsolutePosition
    local absSize = sliderTrack.AbsoluteSize
    local touchX = touchPositions[1].Position.X
    local relX = math.clamp(touchX - absPos.X, 0, absSize.X)
    local pct = relX / absSize.X
    local val = math.floor(pct * 100)
    settings.hitboxSize = val
    sliderFill.Size = UDim2.new(pct, 0, 1, 0)
    sliderKnob.Position = UDim2.new(pct, -8, 0, -5)
    sliderLabel.Text = "Hitbox: " .. val
end)
