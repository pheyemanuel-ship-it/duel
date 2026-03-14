local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "keekduel"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

-- PANEL
local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0,0,0,0)
Panel.Position = UDim2.new(0.5,0,0.5,0)
Panel.AnchorPoint = Vector2.new(0.5,0.5)
Panel.BackgroundColor3 = Color3.fromRGB(15,15,20)
Panel.BorderSizePixel = 0
Panel.Parent = Gui
Instance.new("UICorner",Panel).CornerRadius = UDim.new(0,12)

-- RED OUTLINE
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255,0,0)
Stroke.Thickness = 3
Stroke.Parent = Panel

-- TITLE BAR
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,35)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = Panel

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,1,0)
Title.BackgroundTransparency = 1
Title.Text = "keek duel"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Parent = TitleBar

-- TAB BAR
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,0,0,30)
TabBar.Position = UDim2.new(0,0,0,35)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Panel

local MainTab = Instance.new("TextButton")
MainTab.Size = UDim2.new(0.5,0,1,0)
MainTab.BackgroundColor3 = Color3.fromRGB(25,30,35)
MainTab.Text = "Main"
MainTab.TextColor3 = Color3.new(1,1,1)
MainTab.Parent = TabBar
Instance.new("UICorner",MainTab)

local SettingsTab = Instance.new("TextButton")
SettingsTab.Size = UDim2.new(0.5,0,1,0)
SettingsTab.Position = UDim2.new(0.5,0,0,0)
SettingsTab.BackgroundColor3 = Color3.fromRGB(25,30,35)
SettingsTab.Text = "Settings"
SettingsTab.TextColor3 = Color3.new(1,1,1)
SettingsTab.Parent = TabBar
Instance.new("UICorner",SettingsTab)

-- PAGES
local MainPage = Instance.new("Frame")
MainPage.Size = UDim2.new(1,0,1,-65)
MainPage.Position = UDim2.new(0,0,0,65)
MainPage.BackgroundTransparency = 1
MainPage.Parent = Panel

local SettingsPage = Instance.new("Frame")
SettingsPage.Size = UDim2.new(1,0,1,-65)
SettingsPage.Position = UDim2.new(0,0,0,65)
SettingsPage.BackgroundTransparency = 1
SettingsPage.Visible = false
SettingsPage.Parent = Panel

-- BUTTON CREATOR
local function CreateButton(text,y,parent)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.85,0,0,30)
    b.Position = UDim2.new(0.075,0,0,y)
    b.BackgroundColor3 = Color3.fromRGB(30,30,35)
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    b.Parent = parent
    Instance.new("UICorner",b)
    return b
end

-- MAIN BUTTONS
CreateButton("Feature Button 1",10,MainPage)
CreateButton("Feature Button 2",45,MainPage)
CreateButton("Feature Button 3",80,MainPage)

-- SETTINGS BUTTONS
CreateButton("Save Settings",10,SettingsPage)
CreateButton("Reset Settings",45,SettingsPage)

-- TAB SWITCHING
MainTab.MouseButton1Click:Connect(function()
    MainPage.Visible = true
    SettingsPage.Visible = false
end)

SettingsTab.MouseButton1Click:Connect(function()
    MainPage.Visible = false
    SettingsPage.Visible = true
end)

-- DRAGGING
local dragging
local dragStart
local startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Panel.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Panel.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- OPEN ANIMATION
TweenService:Create(
    Panel,
    TweenInfo.new(0.4,Enum.EasingStyle.Quint),
    {Size = UDim2.fromScale(0.2,0.55)}
):Play()
