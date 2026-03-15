-- KEEK DUEL HUB (FULL)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local PlayerGui = lp:WaitForChild("PlayerGui")

-- SETTINGS

local grabRadius = 25
local MELEE_RANGE = 45
local SPEED_VALUE = 57

local autoStealEnabled = false
local meleeEnabled = false
local speedEnabled = false
local autoLR = false

_G.EgoInfJumpOn = false

--------------------------------------------------
-- AUTO STEAL
--------------------------------------------------

local function findNearestSteal(root)

	local nearest
	local dist = math.huge

	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("ProximityPrompt") and v.ActionText == "Steal" and v.Enabled then

			local part = v.Parent:IsA("BasePart") and v.Parent or v:FindFirstAncestorWhichIsA("BasePart")

			if part then
				local d = (part.Position - root.Position).Magnitude

				if d < dist and d <= grabRadius then
					dist = d
					nearest = v
				end
			end
		end
	end

	return nearest
end

local function startAutoSteal()

	task.spawn(function()

		while autoStealEnabled do

			local char = lp.Character
			if char then

				local root = char:FindFirstChild("HumanoidRootPart")

				if root then
					local prompt = findNearestSteal(root)

					if prompt then
						pcall(fireproximityprompt,prompt)
						task.wait(0.1)
						pcall(fireproximityprompt,prompt)
					end
				end
			end

			task.wait(0.3)

		end

	end)

end

function ToggleAutoSteal(state)

	autoStealEnabled = state

	if state then
		startAutoSteal()
	end

end

--------------------------------------------------
-- MELEE AIMBOT
--------------------------------------------------

local meleeConnection
local meleeAlign
local meleeAttach

local function getClosestTarget(hrp)

	local closest
	local minDist = MELEE_RANGE

	for _,p in pairs(Players:GetPlayers()) do

		if p ~= lp then

			local char = p.Character
			if char then

				local hum = char:FindFirstChildOfClass("Humanoid")
				local root = char:FindFirstChild("HumanoidRootPart")

				if hum and root and hum.Health > 0 then

					local dist = (root.Position - hrp.Position).Magnitude

					if dist < minDist then
						minDist = dist
						closest = root
					end

				end
			end
		end
	end

	return closest
end

local function createAimbot(char)

	local hrp = char:WaitForChild("HumanoidRootPart")
	local humanoid = char:WaitForChild("Humanoid")

	meleeAttach = Instance.new("Attachment")
	meleeAttach.Parent = hrp

	meleeAlign = Instance.new("AlignOrientation")
	meleeAlign.Attachment0 = meleeAttach
	meleeAlign.Mode = Enum.OrientationAlignmentMode.OneAttachment
	meleeAlign.MaxTorque = 100000
	meleeAlign.Responsiveness = 200
	meleeAlign.Parent = hrp

	meleeConnection = RunService.RenderStepped:Connect(function()

		if not meleeEnabled then return end

		local target = getClosestTarget(hrp)

		if target then
			humanoid.AutoRotate = false

			local pos = Vector3.new(target.Position.X,hrp.Position.Y,target.Position.Z)
			meleeAlign.CFrame = CFrame.lookAt(hrp.Position,pos)
			meleeAlign.Enabled = true

		else
			meleeAlign.Enabled = false
			humanoid.AutoRotate = true
		end

	end)

end

function ToggleMeleeAimbot(state)

	meleeEnabled = state

	if state then
		local char = lp.Character or lp.CharacterAdded:Wait()
		createAimbot(char)
	else
		if meleeConnection then
			meleeConnection:Disconnect()
		end
	end

end

--------------------------------------------------
-- SPEED BOOST
--------------------------------------------------

local speedConnection

function ToggleSpeed(state)

	speedEnabled = state

	if state then

		speedConnection = RunService.Heartbeat:Connect(function()

			local char = lp.Character
			if not char then return end

			local hrp = char:FindFirstChild("HumanoidRootPart")
			local hum = char:FindFirstChildOfClass("Humanoid")

			if not hrp or not hum then return end

			local moveDir = hum.MoveDirection

			if moveDir.Magnitude > 0 then

				local vel = moveDir * SPEED_VALUE

				hrp.AssemblyLinearVelocity = Vector3.new(
					vel.X,
					hrp.AssemblyLinearVelocity.Y,
					vel.Z
				)

			end

		end)

	else

		if speedConnection then
			speedConnection:Disconnect()
		end

	end

end

--------------------------------------------------
-- AUTO LEFT / RIGHT PATH
--------------------------------------------------

local lrConnection
local phase = 1

local function getHRP()
	local char = lp.Character
	if char then
		return char:FindFirstChild("HumanoidRootPart")
	end
end

local function getHum()
	local char = lp.Character
	if char then
		return char:FindFirstChildOfClass("Humanoid")
	end
end

local L1 = Vector3.new(-20,0,0)
local LEND = Vector3.new(-40,0,0)
local R1 = Vector3.new(20,0,0)
local REND = Vector3.new(40,0,0)

local FSPD = 60

local function stopAutoLR()

	if lrConnection then
		lrConnection:Disconnect()
		lrConnection = nil
	end

	phase = 1

	local hum = getHum()
	if hum then
		hum:Move(Vector3.zero,false)
	end

end

local function startAutoLR()

	lrConnection = RunService.Heartbeat:Connect(function()

		if not autoLR then return end

		local hrp = getHRP()
		local hum = getHum()

		if not hrp or not hum then return end

		if phase == 1 then

			local d = Vector3.new(L1.X - hrp.Position.X,0,L1.Z - hrp.Position.Z)

			if d.Magnitude < 1 then
				phase = 2
				return
			end

			local md = d.Unit
			hum:Move(md,false)

			hrp.AssemblyLinearVelocity = Vector3.new(md.X*FSPD,hrp.AssemblyLinearVelocity.Y,md.Z*FSPD)

		elseif phase == 2 then

			local d = Vector3.new(LEND.X - hrp.Position.X,0,LEND.Z - hrp.Position.Z)

			if d.Magnitude < 1 then
				phase = 3
				return
			end

			local md = d.Unit
			hum:Move(md,false)

			hrp.AssemblyLinearVelocity = Vector3.new(md.X*FSPD,hrp.AssemblyLinearVelocity.Y,md.Z*FSPD)

		elseif phase == 3 then

			local d = Vector3.new(R1.X - hrp.Position.X,0,R1.Z - hrp.Position.Z)

			if d.Magnitude < 1 then
				phase = 4
				return
			end

			local md = d.Unit
			hum:Move(md,false)

			hrp.AssemblyLinearVelocity = Vector3.new(md.X*FSPD,hrp.AssemblyLinearVelocity.Y,md.Z*FSPD)

		elseif phase == 4 then

			local d = Vector3.new(REND.X - hrp.Position.X,0,REND.Z - hrp.Position.Z)

			if d.Magnitude < 1 then
				phase = 1
				return
			end

			local md = d.Unit
			hum:Move(md,false)

			hrp.AssemblyLinearVelocity = Vector3.new(md.X*FSPD,hrp.AssemblyLinearVelocity.Y,md.Z*FSPD)

		end

	end)

end

function ToggleAutoLR(state)

	autoLR = state

	if state then
		startAutoLR()
	else
		stopAutoLR()
	end

end

--------------------------------------------------
-- INFINITE JUMP
--------------------------------------------------

local IJF, IJC = 50, 80

RunService.Heartbeat:Connect(function()

	if not _G.EgoInfJumpOn then return end

	local char = lp.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if hrp.AssemblyLinearVelocity.Y < -IJC then
		hrp.AssemblyLinearVelocity = Vector3.new(
			hrp.AssemblyLinearVelocity.X,
			-IJC,
			hrp.AssemblyLinearVelocity.Z
		)
	end

end)

UIS.JumpRequest:Connect(function()

	if not _G.EgoInfJumpOn then return end

	local char = lp.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	hrp.AssemblyLinearVelocity = Vector3.new(
		hrp.AssemblyLinearVelocity.X,
		IJF,
		hrp.AssemblyLinearVelocity.Z
	)

end)

function ToggleInfJump(state)
	_G.EgoInfJumpOn = state
end

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "KeekDuel"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0,200,0,200)
frame.Position = UDim2.new(0.5,-100,0.5,-100)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderColor3 = Color3.fromRGB(255,0,0)
frame.BorderSizePixel = 2
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1,0,0,25)
title.BackgroundTransparency = 1
title.Text = "Keek Duel"
title.TextColor3 = Color3.fromRGB(255,0,0)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local scroll = Instance.new("ScrollingFrame")
scroll.Parent = frame
scroll.Position = UDim2.new(0,0,0,25)
scroll.Size = UDim2.new(1,0,1,-25)
scroll.CanvasSize = UDim2.new(0,0,0,350)
scroll.ScrollBarThickness = 4
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout")
layout.Parent = scroll
layout.Padding = UDim.new(0,5)

local function makeButton(text,callback)

	local btn = Instance.new("TextButton")
	btn.Parent = scroll
	btn.Size = UDim2.new(0.9,0,0,30)
	btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
	btn.BorderColor3 = Color3.fromRGB(255,0,0)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Text = text.." : OFF"

	local state = false

	btn.MouseButton1Click:Connect(function()

		state = not state

		if state then
			btn.Text = text.." : ON"
		else
			btn.Text = text.." : OFF"
		end

		callback(state)

	end)

end

makeButton("Auto Steal",ToggleAutoSteal)
makeButton("Melee Aimbot",ToggleMeleeAimbot)
makeButton("Speed Boost",ToggleSpeed)
makeButton("Auto Left/Right",ToggleAutoLR)
makeButton("Infinite Jump",ToggleInfJump)
