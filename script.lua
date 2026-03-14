-- Keek Hub Ultimate UI

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- SETTINGS
local Settings = {
	spinBot = false,
	infiniteJump = false,
	speedValue = 16,
	fpsBoost = false,
	batAimbot = false,
	spinSpeed = 20
}

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = player.PlayerGui
gui.ResetOnSpawn = false

-- MAIN FRAME
local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0,360,0,450)
main.Position = UDim2.new(0.5,-180,0.5,-225)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
local mainCorner = Instance.new("UICorner")
mainCorner.Parent = main
mainCorner.CornerRadius = UDim.new(0,16)

-- TITLE
local title = Instance.new("TextLabel")
title.Parent = main
title.Size = UDim2.new(1,0,0,50)
title.BackgroundColor3 = Color3.fromRGB(35,35,35)
title.Text = "Keek Hub"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
local titleCorner = Instance.new("UICorner")
titleCorner.Parent = title
titleCorner.CornerRadius = UDim.new(0,16)

-- TAB BAR
local tabBar = Instance.new("Frame")
tabBar.Parent = main
tabBar.Size = UDim2.new(1,0,0,45)
tabBar.Position = UDim2.new(0,0,0,50)
tabBar.BackgroundTransparency = 1
local tabLayout = Instance.new("UIListLayout")
tabLayout.Parent = tabBar
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0,6)

-- PAGE HOLDER
local pages = Instance.new("Frame")
pages.Parent = main
pages.Size = UDim2.new(1,0,1,-95)
pages.Position = UDim2.new(0,0,0,95)
pages.BackgroundTransparency = 1

-- CREATE PAGES
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

-- TAB CREATOR
local function createTab(name,page)
	local btn = Instance.new("TextButton")
	btn.Parent = tabBar
	btn.Size = UDim2.new(0.33,0,1,0)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextScaled = true
	local corner = Instance.new("UICorner")
	corner.Parent = btn
	corner.CornerRadius = UDim.new(0,8)

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn,TweenInfo.new(0.2),{BackgroundColor3 = Color3.fromRGB(60,60,60)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn,TweenInfo.new(0.2),{BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		combatPage.Visible = false
		movementPage.Visible = false
		miscPage.Visible = false
		page.Visible = true
		for _,b in pairs(tabBar:GetChildren()) do
			if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(40,40,40) end
		end
		btn.BackgroundColor3 = Color3.fromRGB(0,200,0)
	end)
end

createTab("Combat",combatPage)
createTab("Movement",movementPage)
createTab("Misc",miscPage)

-- NOTIFICATIONS
local function Notify(text)
	local msg = Instance.new("TextLabel")
	msg.Parent = gui
	msg.Size = UDim2.new(0,180,0,30)
	msg.Position = UDim2.new(1,200,1,-50)
	msg.BackgroundColor3 = Color3.fromRGB(30,30,30)
	msg.TextColor3 = Color3.new(1,1,1)
	msg.TextScaled = true
	msg.Text = text
	local corner = Instance.new("UICorner")
	corner.Parent = msg
	corner.CornerRadius = UDim.new(0,8)
	TweenService:Create(msg, TweenInfo.new(0.3), {Position = UDim2.new(1,-190,1,-50)}):Play()
	task.delay(2,function()
		TweenService:Create(msg, TweenInfo.new(0.3), {BackgroundTransparency=1,TextTransparency=1}):Play()
		task.delay(0.3,function() msg:Destroy() end)
	end)
end

-- TOGGLE BUTTONS
local function createButton(parent,text,setting)
	local btn = Instance.new("TextButton")
	btn.Parent = parent
	btn.Size = UDim2.new(0.95,0,0,40)
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextScaled = true
	btn.Text = text.." : "..(Settings[setting] and "ON" or "OFF")
	local corner = Instance.new("UICorner")
	corner.Parent = btn
	corner.CornerRadius = UDim.new(0,8)
	local state = Settings[setting]

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(65,65,65)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(50,50,50)}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		state = not state
		Settings[setting] = state
		btn.Text = text.." : "..(state and "ON" or "OFF")
		Notify(text.." "..(state and "Enabled" or "Disabled"))
		TweenService:Create(btn,TweenInfo.new(0.1),{Size=UDim2.new(0.94,0,0,38)}):Play()
		task.delay(0.1,function()
			TweenService:Create(btn,TweenInfo.new(0.1),{Size=UDim2.new(0.95,0,0,40)}):Play()
		end)
	end)
end

-- TYPABLE INPUT
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
	local corner = Instance.new("UICorner")
	corner.Parent = box
	corner.CornerRadius = UDim.new(0,8)
	box.FocusLost:Connect(function()
		local num = tonumber(box.Text)
		if num then
			num = math.clamp(num,min,max)
			Settings[setting] = num
			box.Text = tostring(num)
		else
			box.Text = tostring(Settings[setting])
		end
	end)
end

-- MOVEMENT PAGE
createButton(movementPage,"Spin Bot","spinBot")
createButton(movementPage,"Infinite Jump","infiniteJump")
createInput(movementPage,"Player Speed",1,100,"speedValue")
createInput(movementPage,"Spin Speed",1,200,"spinSpeed")

-- COMBAT PAGE
createButton(combatPage,"Bat Aimbot","batAimbot")

-- MISC PAGE
createButton(miscPage,"FPS Boost","fpsBoost")

-- FROG TOGGLE BUTTON
local toggle = Instance.new("TextButton")
toggle.Parent = gui
toggle.Size = UDim2.new(0,50,0,50)
toggle.Position = UDim2.new(0,10,0.5,-25)
toggle.BackgroundColor3 = Color3.fromRGB(0,200,0)
toggle.Text = "-"
toggle.TextScaled = true
toggle.Active = true
toggle.Draggable = true
local corner = Instance.new("UICorner")
corner.Parent = toggle
corner.CornerRadius = UDim.new(1,0)
local opened = true

toggle.MouseButton1Click:Connect(function()
	opened = not opened
	if opened then
		TweenService:Create(main,TweenInfo.new(0.3),{Position=UDim2.new(0.5,-180,0.5,-225)}):Play()
		toggle.Text = "-"
	else
		TweenService:Create(main,TweenInfo.new(0.3),{Position=UDim2.new(0.5,-180,0.5,-300)}):Play()
		toggle.Text = "🐸"
	end
end)

toggle.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local screenCenter = workspace.CurrentCamera.ViewportSize.X / 2
		local buttonX = toggle.AbsolutePosition.X
		if buttonX < screenCenter then
			toggle.Position = UDim2.new(0,10,toggle.Position.Y.Scale,toggle.Position.Y.Offset)
		else
			toggle.Position = UDim2.new(1,-60,toggle.Position.Y.Scale,toggle.Position.Y.Offset)
		end
	end
end)

-- FEATURES LOGIC

-- Spinbot
RunService.RenderStepped:Connect(function()
	if Settings.spinBot then
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local hrp = character.HumanoidRootPart
			hrp.CFrame = hrp.CFrame * CFrame.Angles(0,math.rad(Settings.spinSpeed),0)
		end
	end
end)

-- Infinite Jump
UIS.JumpRequest:Connect(function()
	if Settings.infiniteJump then
		local character = player.Character
		if character and character:FindFirstChild("Humanoid") then
			character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- Player Speed
RunService.RenderStepped:Connect(function()
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid.WalkSpeed = Settings.speedValue
	end
end)

-- Bat Aimbot + Auto Swing
RunService.RenderStepped:Connect(function()
	if Settings.batAimbot then
		local character = player.Character
		if not character then return end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not hrp or not humanoid then return end
		local closest
		local distance = math.huge
		for _,v in pairs(Players:GetPlayers()) do
			if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
				local mag = (hrp.Position - v.Character.HumanoidRootPart.Position).Magnitude
				if mag < distance then
					distance = mag
					closest = v
				end
			end
		end
		if closest then
			hrp.CFrame = closest.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
			local tool = character:FindFirstChildOfClass("Tool")
			if tool then tool:Activate() end
		end
	end
end)
