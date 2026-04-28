-- Only here so the stupid warning banner doesn't overwrite our flags, I'm going to include this method of implementation in my upcoming library so stay tuned I guess.
loadstring([[
--!native
--!optimize 2
if game.GameId == 6035872082 then
	local Run = game:GetService("RunService")
	local Players = game:GetService("Players")
	local Workspace = game:GetService("Workspace")
	local Storage = game:GetService("ReplicatedStorage")
	local Items = require(Storage.Modules.ItemLibrary).Items

	local player = Players.LocalPlayer
	local camera = Workspace.CurrentCamera

	local ray = Ray.new
	local vec = Vector2.new
	local color = Color3.fromRGB
	local convert = camera.WorldToViewportPoint
	local byte = string.byte
	local caller = checkcaller
	local hookmetamethod = hookmetamethod

	local target = nil
	local distance = 1000
	local visibility = false

	local parent = Instance.new("ScreenGui", (gethui and gethui()) or game:GetService("CoreGui"))
	local label = Instance.new("TextLabel", parent)
	label.Size, label.Position = UDim2.fromOffset(250, 25), UDim2.new(1, -260, 0, 10)
	label.BackgroundTransparency, label.TextColor3 = 1, color(255, 255, 255)
	label.Font, label.TextSize = Enum.Font.Code, 12
	label.TextXAlignment = Enum.TextXAlignment.Right
	label.Text = "READY"

	local exceptions = {
		["Sniper"] = true,
		["Crossbow"] = true,
		["Bow"] = true,
		["RPG"] = true,
	}

	for name, data in pairs(Items) do
		if typeof(data) == "table" and not exceptions[name] then
			if data.ShootSpread then data.ShootSpread = 0 end
			if data.ShootAccuracy then data.ShootAccuracy = 0 end
			if data.ShootRecoil then data.ShootRecoil = 0 end
			if data.ShootCooldown then data.ShootCooldown = 0.05 end
			if data.ShootBurstCooldown then data.ShootBurstCooldown = 0.05 end
		end
	end

	local function bite(attr)
		return byte(attr or "\0")
	end

	local function visible(targetPart, cam)
		if not visibility then return true end
		
		local dir = (targetPart.Position - cam)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { player.Character, targetPart.Parent, Workspace:FindFirstChild("Debris") }
		local result = Workspace:Raycast(cam, dir.Unit * distance, params)

		return result == nil or result.Instance:IsDescendantOf(targetPart.Parent)
	end

	local function valid(plr, cam)
		local char = plr.Character
		if not char then return false end

		local hum = char:FindFirstChildOfClass("Humanoid")
		local head = char:FindFirstChild("Head")
		if not (hum and head and hum.Health > 0) then return false end

		local mag = (head.Position - cam).Magnitude
		if mag > distance then return false end

		local ours, theirs = player:GetAttribute("EnvironmentID"), plr:GetAttribute("EnvironmentID")
		if ours and theirs and bite(ours) ~= bite(theirs) then return false end

		local ours, theirs = player:GetAttribute("TeamID"), plr:GetAttribute("TeamID")
		if ours and theirs and bite(ours) == bite(theirs) then return false end

		return visible(head, cam)
	end

	Run.Heartbeat:Connect(function()
		camera = Workspace.CurrentCamera
		local cam = camera.CFrame.Position
		local best, distance = nil, math.huge
		local center = camera.ViewportSize / 2

		for _, plr in Players:GetPlayers() do
			if plr ~= player and valid(plr, cam) then
				local pos, on = convert(camera, plr.Character.Head.Position)
				if on then
					local d = (vec(pos.X, pos.Y) - center).Magnitude
					if d < distance then
						distance, best = d, plr
					end
				end
			end
		end

		target = best and best.Character.Head.Position or nil
		label.Text = best and "LOCKED: " .. best.Name:upper() or "SCANNING..."
		label.TextColor3 = best and color(0, 255, 150) or color(255, 80, 80)
	end)

	local _idx
	_idx = hookmetamethod(game, "__index", newcclosure(function(self, idx, ...)
		if target and not caller() and idx == "ViewportSize" and self == camera then
			local pos, on = convert(self, target)
			if on then
				return vec(pos.X * 2, pos.Y * 2)
			end
		end
		return _idx(self, idx, ...)
	end))
end
]])()
