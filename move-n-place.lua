-- Move & Place Macro v1 – executor-friendly + draggable GUI
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local char   = player.Character or player.CharacterAdded:Wait()
local root   = char:WaitForChild("HumanoidRootPart")

-- Remote that places units (edit if your game uses a different one)
local remote = ReplicatedStorage:FindFirstChild("Remotes")
             and ReplicatedStorage.Remotes:FindFirstChild("PlaceUnit")

------------------------------------------------------------------
-- ░░ STATE ░░
------------------------------------------------------------------
local path      = {}
local recording = false
local playing   = false
local unitName  = "YourUnitNameHere" -- <-- change to your tower/unit
local delay     = 0.25               -- seconds between steps

------------------------------------------------------------------
-- ░░ DRAGGABLE GUI ░░
------------------------------------------------------------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "MacroGui"
gui.ResetOnSpawn = false

-- main draggable container
local frame = Instance.new("Frame", gui)
frame.Size             = UDim2.new(0, 180, 0, 230)
frame.Position         = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.Active           = true      -- make clickable
frame.Draggable        = true      -- enable drag

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", frame)
title.Size               = UDim2.new(1, 0, 0, 22)
title.Position           = UDim2.new(0, 0, 0, 4)
title.BackgroundTransparency = 1
title.TextColor3         = Color3.new(1,1,1)
title.Font               = Enum.Font.SourceSansBold
title.TextSize           = 20
title.Text               = "Move-n-Place"

-- helper to create buttons inside the frame
local function newButton(text, y, onClick)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0, 160, 0, 28)
    b.Position = UDim2.new(0, 10, 0, y)
    b.Text = text
    b.Font = Enum.Font.SourceSans
    b.TextSize = 18
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(55,55,55)
    b.MouseButton1Click:Connect(onClick)
    return b
end

------------------------------------------------------------------
-- ░░ BUTTONS ░░
------------------------------------------------------------------
local statusLbl = Instance.new("TextLabel", frame)
statusLbl.Size = UDim2.new(0, 160, 0, 20)
statusLbl.Position = UDim2.new(0,10,0,32)
statusLbl.BackgroundTransparency = 1
statusLbl.TextColor3 = Color3.new(1,1,1)
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.Text = "Idle"

newButton("Set Unit", 60, function()
    unitName = player:GetMouse().Target and player:GetMouse().Target.Name or unitName
    statusLbl.Text = "Unit → "..unitName
end)

newButton("Start Record", 94, function()
    if playing then return end
    recording = true
    path = {}
    statusLbl.Text = "Recording"
end)

newButton("Stop Record", 128, function()
    recording = false
    statusLbl.Text = "Recorded "..#path.." steps"
end)

newButton("Play Loop", 162, function()
    if recording or playing or #path==0 then return end
    playing = true
    statusLbl.Text = "Playing"
    task.spawn(function()
        while playing do
            for _,cf in ipairs(path) do
                if not playing then break end
                root.CFrame = cf
                if remote and unitName~="" then
                    remote:FireServer(unitName, cf.Position)
                end
                task.wait(delay)
            end
        end
        statusLbl.Text = "Idle"
    end)
end)

newButton("Stop Play", 196, function()
    playing = false
end)

------------------------------------------------------------------
-- ░░ RECORD MOVEMENT ░░
------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    if recording then
        table.insert(path, root.CFrame)
    end
end)
