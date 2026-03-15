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

local antiRagdollEnabled = false
local autoBatEnabled = false
local autoStealEnabled = false
local meleeEnabled = false
local speedEnabled = false
local autoLeft = false
local autoRight = false

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
-- AUTO BAT
--------------------------------------------------

local function getClosestPlayer()

    local closest
    local dist = math.huge

    local char = lp.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _,p in pairs(Players:GetPlayers()) do
        if p ~= lp then

            local c = p.Character
            if c then

                local root = c:FindFirstChild("HumanoidRootPart")
                local hum = c:FindFirstChildOfClass("Humanoid")

                if root and hum and hum.Health > 0 then

                    local d = (root.Position - hrp.Position).Magnitude

                    if d < dist then
                        dist = d
                        closest = p
                    end

                end
            end
        end
    end

    return closest, dist
end

RunService.Heartbeat:Connect(function()

    if not autoBatEnabled then return end

    local target, dist = getClosestPlayer()

    if target and dist and dist < 6 then
        mouse1click() -- swing bat
    end

end)

function ToggleAutoBat(state)
    autoBatEnabled = state
end

--------------------------------------------------
-- AUTO LEFT / RIGHT (REAL MAP COORDS)
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

-- REAL MAP POSITIONS
local POSITION_L1 = Vector3.new(-476.48, -6.28, 92.73)
local POSITION_L2 = Vector3.new(-483.12, -4.95, 94.80)

local POSITION_R1 = Vector3.new(-476.16, -6.52, 25.62)
local POSITION_R2 = Vector3.new(-483.04, -5.09, 23.14)

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

        local target

        if phase == 1 then
            target = POSITION_L1
        elseif phase == 2 then
            target = POSITION_L2
        elseif phase == 3 then
            target = POSITION_R1
        elseif phase == 4 then
            target = POSITION_R2
        end

        local d = Vector3.new(
            target.X - hrp.Position.X,
            0,
            target.Z - hrp.Position.Z
        )

        if d.Magnitude < 2 then
            phase = phase + 1
            if phase > 4 then
                phase = 1
            end
            return
        end

        local md = d.Unit

-- detect wall
local hit, normal = detectWall(hrp, md)

if hit then
    -- slide along wall
    local slide = Vector3.new(normal.Z,0,-normal.X).Unit
    md = slide
end

hum:Move(md,false)

hrp.AssemblyLinearVelocity = Vector3.new(
    md.X * FSPD,
    hrp.AssemblyLinearVelocity.Y,
    md.Z * FSPD
)

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
function ToggleAutoLeft(state)
    autoLR = state
    phase = 1
    if state then
        startAutoLR()
    else
        stopAutoLR()
    end
end

function ToggleAutoRight(state)
    autoLR = state
    phase = 3
    if state then
        startAutoLR()
    else
        stopAutoLR()
    end
end
--------------------------------------------------
-- WALL DETECTION
--------------------------------------------------

local function detectWall(hrp, dir)

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {lp.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist

    local ray = workspace:Raycast(hrp.Position, dir * 6, rayParams)

    if ray then
        return true, ray.Normal
    end

    return false
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
-- ANTI RAGDOLL
--------------------------------------------------

RunService.Heartbeat:Connect(function()

    if not antiRagdollEnabled then return end

    local char = lp.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if not hum then return end

    local state = hum:GetState()

    if state == Enum.HumanoidStateType.Ragdoll
    or state == Enum.HumanoidStateType.FallingDown
    or state == Enum.HumanoidStateType.Physics then

        hum:ChangeState(Enum.HumanoidStateType.GettingUp)

        if root then
            root.Velocity = Vector3.new(0,0,0)
            root.RotVelocity = Vector3.new(0,0,0)
        end
    end

end)

function ToggleAntiRagdoll(state)
    antiRagdollEnabled = state
end

--------------------------------------------------
-- UI / GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "KeekHubUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

-- MAIN FRAME
local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0,260,0,300)
frame.Position = UDim2.new(0.5,-130,0.5,-150)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

-- CORNERS
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,8)
corner.Parent = frame

-- TITLE BAR
local titleBar = Instance.new("Frame")
titleBar.Parent = frame
titleBar.Size = UDim2.new(1,0,0,35)
titleBar.BackgroundColor3 = Color3.fromRGB(35,35,35)
titleBar.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0,8)
titleCorner.Parent = titleBar

-- TITLE TEXT
local title = Instance.new("TextLabel")
title.Parent = titleBar
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "KEEK DUEL HUB"
title.TextColor3 = Color3.fromRGB(255,80,80)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20

-- BUTTON CONTAINER
local container = Instance.new("Frame")
container.Parent = frame
container.Position = UDim2.new(0,0,0,40)
container.Size = UDim2.new(1,0,1,-40)
container.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout")
layout.Parent = container
layout.Padding = UDim.new(0,6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

--------------------------------------------------
-- BUTTON CREATOR
--------------------------------------------------

local function createToggle(text,callback)

    local btn = Instance.new("TextButton")
    btn.Parent = container
    btn.Size = UDim2.new(0.9,0,0,32)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    btn.Text = text.." : OFF"

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,6)
    btnCorner.Parent = btn

    local state = false

    btn.MouseButton1Click:Connect(function()

        state = not state

        if state then
            btn.Text = text.." : ON"
            btn.BackgroundColor3 = Color3.fromRGB(80,40,40)
        else
            btn.Text = text.." : OFF"
            btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        end

        callback(state)

    end)

end

--------------------------------------------------
-- FEATURE BUTTONS
--------------------------------------------------

createToggle("Auto Steal",ToggleAutoSteal)
createToggle("Melee Aimbot",ToggleMeleeAimbot)
createToggle("Speed Boost",ToggleSpeed)
createToggle("Infinite Jump",ToggleInfJump)
createToggle("Auto Bat",ToggleAutoBat)
createToggle("Anti Ragdoll",ToggleAntiRagdoll)
createToggle("Auto Left / Right", ToggleAutoLR)
