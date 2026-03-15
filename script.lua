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

local function startAutoLeft()
    if autoLeftConnection then autoLeftConnection:Disconnect() end
    autoLeftPhase = 1
    autoLeftConnection = RunService.Heartbeat:Connect(function()
        if not AutoLeftEnabled then return end
        local c = LocalPlayer.Character
        if not c then return end
        local rp = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not rp or not hum then return end
        
        local spd = NORMAL_SPEED
        if autoLeftPhase == 1 then
            local tgt = Vector3.new(POSITION_L1.X, rp.Position.Y, POSITION_L1.Z)
            if (tgt - rp.Position).Magnitude < 1 then
                autoLeftPhase = 2
                local d = (POSITION_L2 - rp.Position)
                local mv = Vector3.new(d.X, 0, d.Z).Unit
                hum:Move(mv, false)
                rp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, rp.AssemblyLinearVelocity.Y, mv.Z * spd)
                return
            end
            local d = (POSITION_L1 - rp.Position)
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            rp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, rp.AssemblyLinearVelocity.Y, mv.Z * spd)

        elseif autoLeftPhase == 2 then
            local tgt = Vector3.new(POSITION_L2.X, rp.Position.Y, POSITION_L2.Z)
            if (tgt - rp.Position).Magnitude < 1 then
                hum:Move(Vector3.zero, false)
                rp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                AutoLeftEnabled = false
                Enabled.AutoLeftEnabled = false

                if autoLeftConnection then
                    autoLeftConnection:Disconnect()
                    autoLeftConnection = nil
                end

                autoLeftPhase = 1

                if _G_AL_swBg and _G_AL_swCircle then
                    _G_AL_swBg.BackgroundColor3 = C_SW_OFF
                    _G_AL_swCircle.Position = UDim2.new(0, 3, 0.5, -8)
                end

                if MobileButtons["A.LEFT"] then
                    MobileButtons["A.LEFT"].setState(false)
                end

                faceSouth()
                return
            end

            local d = (POSITION_L2 - rp.Position)
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            rp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, rp.AssemblyLinearVelocity.Y, mv.Z * spd)
        end
    end)
end


local function startAutoRight()
    if autoRightConnection then autoRightConnection:Disconnect() end
    autoRightPhase = 1
    autoRightConnection = RunService.Heartbeat:Connect(function()
        if not AutoRightEnabled then return end
        local c = LocalPlayer.Character
        if not c then return end
        local rp = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not rp or not hum then return end
        
        local spd = NORMAL_SPEED

        if autoRightPhase == 1 then
            local tgt = Vector3.new(POSITION_R1.X, rp.Position.Y, POSITION_R1.Z)
            if (tgt - rp.Position).Magnitude < 1 then
                autoRightPhase = 2
                local d = (POSITION_R2 - rp.Position)
                local mv = Vector3.new(d.X, 0, d.Z).Unit
                hum:Move(mv, false)
                rp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, rp.AssemblyLinearVelocity.Y, mv.Z * spd)
                return
            end

            local d = (POSITION_R1 - rp.Position)
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            rp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, rp.AssemblyLinearVelocity.Y, mv.Z * spd)

        elseif autoRightPhase == 2 then
            local tgt = Vector3.new(POSITION_R2.X, rp.Position.Y, POSITION_R2.Z)
            if (tgt - rp.Position).Magnitude < 1 then
                hum:Move(Vector3.zero, false)
                rp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

                AutoRightEnabled = false
                Enabled.AutoRightEnabled = false

                if autoRightConnection then
                    autoRightConnection:Disconnect()
                    autoRightConnection = nil
                end

                autoRightPhase = 1

                if _G_AR_swBg and _G_AR_swCircle then
                    _G_AR_swBg.BackgroundColor3 = C_SW_OFF
                    _G_AR_swCircle.Position = UDim2.new(0, 3, 0.5, -8)
                end

                if MobileButtons["A.RIGHT"] then
                    MobileButtons["A.RIGHT"].setState(false)
                end

                faceNorth()
                return
            end

            local d = (POSITION_R2 - rp.Position)
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            rp.AssemblyLinearVelocity = Vector3.new(mv.X * spd, rp.AssemblyLinearVelocity.Y, mv.Z * spd)
        end
    end)
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
