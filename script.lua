-- Keek Duel Hub (Dark UI + Red Bubbles + Fast Grab)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

-- SETTINGS FILE
local settingsFile = "KeekDuelSettings.json"

local Settings = {
	batAimbot = false,
	spinBot = false,
	spinSpeed = 20,
	infiniteJump = false,
	speedValue = 16,
	antiRagdoll = true,
	fastGrab = false
}

-- LOAD SETTINGS
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

local function SaveSettings()
	if writefile then
		writefile(settingsFile,HttpService:JSONEncode(Settings))
	end
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = player.PlayerGui
gui.ResetOnSpawn = false

-- DARK BACKGROUND
local background = Instance.new("Frame")
background.Parent = gui
background.Size = UDim2.new(1,0,1,0)
background.BackgroundColor3 = Color3.fromRGB(10,10,10)

-- BUBBLE HOLDER
local bubbleHolder = Instance.new("Frame")
bubbleHolder.Parent = background
bubbleHolder.Size = UDim2.new(1,0,1,0)
bubbleHolder.BackgroundTransparency = 1

-- BUBBLE FUNCTION
local function createBubble()

	local bubble = Instance.new("Frame")
	bubble.Parent = bubbleHolder

	local size = math.random(10,40)

	bubble.Size = UDim2.new(0,size,0,size)
	bubble.Position = UDim2.new(math.random(),0,1,0)
	bubble.BackgroundColor3 = Color3.fromRGB(255,0,0)
	bubble.BackgroundTransparency = 0.3

	local corner = Instance.new("UICorner",bubble)
	corner.CornerRadius = UDim.new(1,0)

	local tween = TweenService:Create(
		bubble,
		TweenInfo.new(math.random(6,12),Enum.EasingStyle.Linear),
		{
			Position = UDim2.new(math.random(),0,-0.1,0),
			BackgroundTransparency = 1
		}
	)

	tween:Play()

	tween.Completed:Connect(function()
		bubble:Destroy()
	end)

end

task.spawn(function()
	while true do
		createBubble()
		task.wait(0.3)
	end
end)

-- MAIN HUB
local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0,340,0,420)
main.Position = UDim2.new(0.5,-170,0.5,-210)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Active = false
main.Draggable = false
Instance.new("UICorner",main)

-- TITLE
local title = Instance.new("TextLabel")
title.Parent = main
title.Size = UDim2.new(1,0,0,45)
title.Text = "Keek Duel Hub"
title.BackgroundColor3 = Color3.fromRGB(35,35,35)
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
Instance.new("UICorner",title)

-- TAB BAR
local tabBar = Instance.new("Frame")
tabBar.Parent = main
tabBar.Size = UDim2.new(1,0,0,40)
tabBar.Position = UDim2.new(0,0,0,45)
tabBar.BackgroundTransparency = 1

local tabLayout = Instance.new("UIListLayout")
tabLayout.Parent = tabBar
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0,6)

-- PAGE HOLDER
local pages = Instance.new("Frame")
pages.Parent = main
pages.Size = UDim2.new(1,0,1,-90)
pages.Position = UDim2.new(0,0,0,85)
pages.BackgroundTransparency = 1

local function createPage()

	local page = Instance.new("ScrollingFrame")
	page.Parent = pages
	page.Size = UDim2.new(1,0,1,0)
	page.CanvasSize = UDim2.new(0,0,0,600)
	page.ScrollBarThickness = 6
	page.BackgroundTransparency = 1

	local layout = Instance.new("UIListLayout")
	layout.Parent = page
	layout.Padding = UDim.new(0,10)

	return page
end

local combatPage = createPage()
local movementPage = createPage()
local miscPage = createPage()

movementPage.Visible = false
miscPage.Visible = false

-- TAB FUNCTION
local function createTab(name,page)

	local btn = Instance.new("TextButton")
	btn.Parent = tabBar
	btn.Size = UDim2.new(0.33,0,1,0)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextScaled = true
	Instance.new("UICorner",btn)

	btn.MouseButton1Click:Connect(function()

		combatPage.Visible = false
		movementPage.Visible = false
		miscPage.Visible = false
		page.Visible = true

	end)

end

createTab("Combat",combatPage)
createTab("Movement",movementPage)
createTab("Misc",miscPage)

-- BUTTON
local function createButton(parent,text,setting)

	local btn = Instance.new("TextButton")
	btn.Parent = parent
	btn.Size = UDim2.new(0.95,0,0,40)
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextScaled = true
	Instance.new("UICorner",btn)

	local state = Settings[setting]
	btn.Text = text.." : "..(state and "ON" or "OFF")

	btn.MouseButton1Click:Connect(function()

		state = not state
		btn.Text = text.." : "..(state and "ON" or "OFF")

		Settings[setting] = state
		SaveSettings()

	end)

end

-- INPUT BOX
local function createInput(parent,text,min,max,setting)

	local frame = Instance.new("Frame")
	frame.Parent = parent
	frame.Size = UDim2.new(0.95,0,0,60)
	frame.BackgroundTransparency = 1

	local label = Instance.new("TextLabel")
	label.Parent = frame
	label.Size = UDim2.new(1,0,0,25)
	label.Text = text
	label.TextColor3 = Color3.new(1,1,1)
	label.BackgroundTransparency = 1
	label.TextScaled = true

	local box = Instance.new("TextBox")
	box.Parent = frame
	box.Size = UDim2.new(1,0,0,30)
	box.Position = UDim2.new(0,0,0,30)
	box.BackgroundColor3 = Color3.fromRGB(40,40,40)
	box.TextColor3 = Color3.new(1,1,1)
	box.TextScaled = true
	box.Text = tostring(Settings[setting])
	box.PlaceholderText = min.." - "..max
	Instance.new("UICorner",box)

	box.FocusLost:Connect(function()

		local num = tonumber(box.Text)

		if num then
			num = math.clamp(num,min,max)
			Settings[setting] = num
			box.Text = tostring(num)
			SaveSettings()
		else
			box.Text = tostring(Settings[setting])
		end

	end)

end

-- COMBAT
createButton(combatPage,"Bat Aimbot","batAimbot")

-- MOVEMENT
createButton(movementPage,"Spin Bot","spinBot")
createButton(movementPage,"Infinite Jump","infiniteJump")
createInput(movementPage,"Spin Speed",1,100,"spinSpeed")
createInput(movementPage,"Player Speed",1,100,"speedValue")

-- MISC
createButton(miscPage,"Anti Ragdoll","antiRagdoll")
createButton(miscPage,"Fast Grab","fastGrab")

-- CIRCLE TOGGLE BUTTON
local toggle = Instance.new("TextButton")
toggle.Parent = gui
toggle.Size = UDim2.new(0,60,0,60)
toggle.Position = UDim2.new(0,10,0.5,-30)
toggle.BackgroundColor3 = Color3.fromRGB(200,0,0)
toggle.Text = "X"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.TextScaled = true

local corner = Instance.new("UICorner")
corner.Parent = toggle
corner.CornerRadius = UDim.new(1,0)

local opened = true

toggle.MouseButton1Click:Connect(function()

	opened = not opened
	main.Visible = opened

	if opened then
		toggle.Text = "X"
	else
		toggle.Text = "O"
	end

end)

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

	if Settings.fastGrab then
		for _,tool in pairs(player.Character:GetChildren()) do
			if tool:IsA("Tool") then
				tool:Activate()
			end
		end
	end

end)

RunService.Stepped:Connect(function()

	if Settings.antiRagdoll and humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end

end)
