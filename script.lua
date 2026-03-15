-- KEEK DUEL HUB (FULL)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local PlayerGui = lp:WaitForChild("PlayerGui")

---

-- SETTINGS

local grabRadius = 25
local MELEE_RANGE = 45
local SPEED_VALUE = 57

local autoStealEnabled = false
local meleeEnabled = false
local speedEnabled = false
local autoLR = false

---

-- AUTO STEAL

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

---

-- MELEE AIMBOT

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

---

-- NEW SPEED BOOSTER

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

---

-- NEW AUTO LEFT / RIGHT

local lrConnection

function ToggleAutoLR(state)

autoLR = state

if state then

lrConnection = RunService.Heartbeat:Connect(function()

local char = lp.Character
if not char then return end

local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end

local sideMove = math.sin(tick()*6) * 45

root.AssemblyLinearVelocity = Vector3.new(
sideMove,
root.AssemblyLinearVelocity.Y,
root.AssemblyLinearVelocity.Z
)

end)

else

if lrConnection then
lrConnection:Disconnect()
end

end

end

---

-- GUI

local gui = Instance.new("ScreenGui")
gui.Name = "KeekDuel"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0,200,0,180)
frame.Position = UDim2.new(0.5,-100,0.5,-90)
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

---

-- SCROLL FRAME

local scroll = Instance.new("ScrollingFrame")
scroll.Parent = frame
scroll.Position = UDim2.new(0,0,0,25)
scroll.Size = UDim2.new(1,0,1,-25)
scroll.CanvasSize = UDim2.new(0,0,0,300)
scroll.ScrollBarThickness = 4
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout")
layout.Parent = scroll
layout.Padding = UDim.new(0,5)

---

-- BUTTON FUNCTION

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

---

-- GUI BUTTONS

makeButton("Auto Steal",ToggleAutoSteal)
makeButton("Melee Aimbot",ToggleMeleeAimbot)
makeButton("Speed Boost",ToggleSpeed)
makeButton("Auto Left/Right",ToggleAutoLR)
