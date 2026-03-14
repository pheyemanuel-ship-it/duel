-- Keek Duel Hub (With Save Settings)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

-- SETTINGS FILE
local settingsFile = "KeekDuelSettings.json"

-- Default settings
local Settings = {
	batAimbot = false,
	spinBot = false,
	spinSpeed = 20,
	infiniteJump = false,
	speedValue = 16,
	antiRagdoll = true
}

-- Load settings
if isfile and isfile(settingsFile) then
	local success,data = pcall(function()
		return HttpService:JSONDecode(readfile(settingsFile))
	end)

	if success and data then
		for i,v in pairs(data) do
			Settings[i] = v
		end
	end
end

-- Save function
local function SaveSettings()
	if writefile then
		writefile(settingsFile,HttpService:JSONEncode(Settings))
	end
end

-- GUI
local gui = Instance.new("ScreenGui",player.PlayerGui)
gui.Name = "KeekDuel"

local main = Instance.new("Frame",gui)
main.Size = UDim2.new(0,320,0,260)
main.Position = UDim2.new(0.1,0,0.1,0)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active = true
main.Draggable = true
Instance.new("UICorner",main)

local title = Instance.new("TextLabel",main)
title.Size = UDim2.new(1,0,0,35)
title.Text = "Keek Duel"
title.BackgroundColor3 = Color3.fromRGB(35,35,35)
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
Instance.new("UICorner",title)

-- TAB BAR
local tabBar = Instance.new("Frame",main)
tabBar.Size = UDim2.new(1,0,0,30)
tabBar.Position = UDim2.new(0,0,0,35)
tabBar.BackgroundTransparency = 1

local pages = Instance.new("Frame",main)
pages.Size = UDim2.new(1,0,1,-65)
pages.Position = UDim2.new(0,0,0,65)
pages.BackgroundTransparency = 1

local combatPage = Instance.new("Frame",pages)
combatPage.Size = UDim2.new(1,0,1,0)
combatPage.BackgroundTransparency = 1

local movementPage = combatPage:Clone()
movementPage.Parent = pages
movementPage.Visible = false

local miscPage = combatPage:Clone()
miscPage.Parent = pages
miscPage.Visible = false

-- TAB CREATOR
local function createTab(name,pos,page)

	local btn = Instance.new("TextButton",tabBar)
	btn.Size = UDim2.new(0.33,0,1,0)
	btn.Position = UDim2.new(pos,0,0,0)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.TextColor3 = Color3.new(1,1,1)

	btn.MouseButton1Click:Connect(function()
		combatPage.Visible = false
		movementPage.Visible = false
		miscPage.Visible = false
		page.Visible = true
	end)

end

createTab("Combat",0,combatPage)
createTab("Movement",0.33,movementPage)
createTab("Misc",0.66,miscPage)

-- BUTTON CREATOR
local function createButton(parent,text,posY,setting)

	local btn = Instance.new("TextButton",parent)
	btn.Size = UDim2.new(0.9,0,0,30)
	btn.Position = UDim2.new(0.05,0,0,posY)
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.TextColor3 = Color3.new(1,1,1)

	local state = Settings[setting]
	btn.Text = text.." : "..(state and "ON" or "OFF")

	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = text.." : "..(state and "ON" or "OFF")

		Settings[setting] = state
		SaveSettings()
	end)

end

-- SLIDER CREATOR
local function createSlider(parent,text,posY,min,max,setting)

	local value = Settings[setting]

	local label = Instance.new("TextLabel",parent)
	label.Size = UDim2.new(0.9,0,0,20)
	label.Position = UDim2.new(0.05,0,0,posY)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1,1,1)
	label.Text = text..": "..value

	local bar = Instance.new("Frame",parent)
	bar.Size = UDim2.new(0.9,0,0,8)
	bar.Position = UDim2.new(0.05,0,0,posY+20)
	bar.BackgroundColor3 = Color3.fromRGB(50,50,50)

	local fill = Instance.new("Frame",bar)
	fill.Size = UDim2.new(value/max,0,1,0)
	fill.BackgroundColor3 = Color3.fromRGB(200,0,0)

	local dragging = false

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging then

			local pos = math.clamp((input.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
			fill.Size = UDim2.new(pos,0,1,0)

			local newValue = math.floor(min + (max-min)*pos)
			label.Text = text..": "..newValue

			Settings[setting] = newValue
			SaveSettings()

		end
	end)

end

-- COMBAT TAB
createButton(combatPage,"Bat Aimbot",20,"batAimbot")

-- MOVEMENT TAB
createButton(movementPage,"Spin Bot",20,"spinBot")
createButton(movementPage,"Infinite Jump",60,"infiniteJump")

createSlider(movementPage,"Spin Speed",110,1,100,"spinSpeed")
createSlider(movementPage,"Player Speed",160,1,100,"speedValue")

-- MISC TAB
createButton(miscPage,"Anti Ragdoll",20,"antiRagdoll")

-- FEATURES

UIS.JumpRequest:Connect(function()
	if Settings.infiniteJump then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

RunService.RenderStepped:Connect(function()

	humanoid.WalkSpeed = Settings.speedValue

	if Settings.spinBot then
		root.CFrame = root.CFrame * CFrame.Angles(0,math.rad(Settings.spinSpeed),0)
	end

end)

RunService.Stepped:Connect(function()
	if Settings.antiRagdoll and humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end)

-- NEAREST PLAYER
local function getNearestPlayer()

	local nearest
	local dist = math.huge

	for _,v in pairs(Players:GetPlayers()) do
		if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then

			local d = (root.Position - v.Character.HumanoidRootPart.Position).Magnitude

			if d < dist then
				dist = d
				nearest = v
			end

		end
	end

	return nearest
end

-- BAT AIMBOT
task.spawn(function()

	while true do
		task.wait(0.2)

		if Settings.batAimbot then

			local target = getNearestPlayer()

			if target and target.Character then
				humanoid:MoveTo(target.Character.HumanoidRootPart.Position)
			end

		end

	end

end)
