local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "KeekHub"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- MAIN FRAME
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,270,0,380)
frame.Position = UDim2.new(0.5,-135,0.5,-190)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Parent = gui
frame.Active = true
frame.Draggable = true

Instance.new("UICorner",frame)

-- RED OUTLINE
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255,0,0)
stroke.Thickness = 3
stroke.Parent = frame

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "KEEK HUB"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.Parent = frame

-- TAB BUTTONS
local mainTabBtn = Instance.new("TextButton")
mainTabBtn.Size = UDim2.new(0.5,0,0,30)
mainTabBtn.Position = UDim2.new(0,0,0,35)
mainTabBtn.Text = "Main"
mainTabBtn.Parent = frame

local settingsTabBtn = Instance.new("TextButton")
settingsTabBtn.Size = UDim2.new(0.5,0,0,30)
settingsTabBtn.Position = UDim2.new(0.5,0,0,35)
settingsTabBtn.Text = "Settings"
settingsTabBtn.Parent = frame

-- PAGES
local mainPage = Instance.new("Frame")
mainPage.Size = UDim2.new(1,0,1,-65)
mainPage.Position = UDim2.new(0,0,0,65)
mainPage.BackgroundTransparency = 1
mainPage.Parent = frame

local settingsPage = Instance.new("Frame")
settingsPage.Size = mainPage.Size
settingsPage.Position = mainPage.Position
settingsPage.BackgroundTransparency = 1
settingsPage.Visible = false
settingsPage.Parent = frame

-- LAYOUT
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,6)
layout.Parent = mainPage

-- WALKSPEED INPUT
local wsBox = Instance.new("TextBox")
wsBox.Size = UDim2.new(1,0,0,35)
wsBox.PlaceholderText = "WalkSpeed"
wsBox.Text = ""
wsBox.Parent = mainPage

local wsBtn = Instance.new("TextButton")
wsBtn.Size = UDim2.new(1,0,0,35)
wsBtn.Text = "Set WalkSpeed"
wsBtn.Parent = mainPage

-- SPIN SPEED INPUT
local spinBox = Instance.new("TextBox")
spinBox.Size = UDim2.new(1,0,0,35)
spinBox.PlaceholderText = "Spin Speed"
spinBox.Text = ""
spinBox.Parent = mainPage

local spinBtn = Instance.new("TextButton")
spinBtn.Size = UDim2.new(1,0,0,35)
spinBtn.Text = "Toggle Spin"
spinBtn.Parent = mainPage

-- INFINITE JUMP BUTTON
local infJumpBtn = Instance.new("TextButton")
infJumpBtn.Size = UDim2.new(1,0,0,35)
infJumpBtn.Text = "Infinite Jump"
infJumpBtn.Parent = mainPage

-- AUTO GO NEAREST PLAYER
local autoNearestBtn = Instance.new("TextButton")
autoNearestBtn.Size = UDim2.new(1,0,0,35)
autoNearestBtn.Text = "Auto Go Nearest"
autoNearestBtn.Parent = mainPage

-- 8 EMPTY BUTTONS
for i = 1,8 do
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,0,0,35)
	b.Text = ""
	b.Parent = mainPage
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,8)
	corner.Parent = b
end

-- TAB SWITCH
mainTabBtn.MouseButton1Click:Connect(function()
	mainPage.Visible = true
	settingsPage.Visible = false
end)

settingsTabBtn.MouseButton1Click:Connect(function()
	mainPage.Visible = false
	settingsPage.Visible = true
end)

-- WALKSPEED
wsBtn.MouseButton1Click:Connect(function()
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	local val = tonumber(wsBox.Text)

	if hum and val then
		hum.WalkSpeed = val
	end
end)

-- SPIN SYSTEM
local spinning = false
local spinSpeed = 50

spinBtn.MouseButton1Click:Connect(function()
	spinning = not spinning
	spinSpeed = tonumber(spinBox.Text) or 5
end)

RunService.RenderStepped:Connect(function()
	if spinning and player.Character then
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		if root then
			root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
		end
	end
end)

-- INFINITE JUMP
local infJump = false

infJumpBtn.MouseButton1Click:Connect(function()
	infJump = not infJump
end)

UIS.JumpRequest:Connect(function()
	if infJump and player.Character then
		local hum = player.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- AUTO GO NEAREST PLAYER
local autoNearest = false

autoNearestBtn.MouseButton1Click:Connect(function()
	autoNearest = not autoNearest
end)

local function getNearest()
	local closest = nil
	local dist = math.huge

	if not player.Character then return end
	local root = player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	for _,v in pairs(Players:GetPlayers()) do
		if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			local d = (v.Character.HumanoidRootPart.Position - root.Position).Magnitude
			if d < dist then
				dist = d
				closest = v
			end
		end
	end

	return closest
end

RunService.RenderStepped:Connect(function()
	if autoNearest then
		local target = getNearest()
		if target and target.Character then
			local root = player.Character:FindFirstChild("HumanoidRootPart")
			local troot = target.Character:FindFirstChild("HumanoidRootPart")

			if root and troot then
				root.CFrame = CFrame.new(root.Position, troot.Position)
				root.Position = root.Position:Lerp(troot.Position,0.05)
			end
		end
	end
end)
