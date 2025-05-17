-- Move & Place Macro v1 – executor-friendly
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

-- Replace with correct Remote if needed
local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("PlaceUnit")

local path = {}
local recording = false
local playing = false
local unitName = "YourUnitNameHere" -- Change this to your unit's actual name

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "MacroGui"

local function button(name, y, callback)
    local b = Instance.new("TextButton", gui)
    b.Size = UDim2.new(0, 140, 0, 28)
    b.Position = UDim2.new(0, 10, 0, y)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.MouseButton1Click:Connect(callback)
    return b
end

button("Start Recording", 40, function()
    recording = true
    path = {}
end)

button("Stop Recording", 80, function()
    recording = false
end)

button("Play Loop", 120, function()
    if playing or #path == 0 then return end
    playing = true
    while playing do
        for _, step in ipairs(path) do
            if not playing then break end
            root.CFrame = step
            if remote then
                remote:FireServer(unitName, step.Position)
            end
            task.wait(0.25)
        end
    end
end)

button("Stop", 160, function()
    playing = false
end)

RunService.Heartbeat:Connect(function()
    if recording then
        table.insert(path, root.CFrame)
    end
end)
