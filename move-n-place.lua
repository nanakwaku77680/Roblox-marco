-- Anime Fantasy-style Movement Recorder with Unit Replay and Opening Animation
-- Executor-supported

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- --- GUI Setup ---
local gui = Instance.new("ScreenGui")
gui.Name = "MovementUnitGUI"
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
-- Start hidden (zero size and transparent)
frame.Size = UDim2.new(0, 0, 0, 0)
frame.Position = UDim2.new(0.4, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 1
frame.Active = true
frame.Draggable = false  -- Draggable after tween
frame.Parent = gui

-- Rounded corners
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = frame

-- Tween the GUI open
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local targetSize = UDim2.new(0, 200, 0, 140)
local targetTransparency = 0
local openTween = TweenService:Create(frame, tweenInfo, {Size = targetSize, BackgroundTransparency = targetTransparency})
openTween:Play()
openTween.Completed:Connect(function()
    -- Enable dragging after open animation
    frame.Draggable = true
    -- Credit label at bottom
    local credit = Instance.new("TextLabel")
    credit.Name = "CreditLabel"
    credit.Parent = frame
    credit.Size = UDim2.new(1, 0, 0, 20)
    credit.Position = UDim2.new(0, 0, 1, -20)
    credit.BackgroundTransparency = 1
    credit.Text = "Made by BatmanOg"
    credit.TextColor3 = Color3.fromRGB(255, 255, 255)
    credit.Font = Enum.Font.GothamBold
    credit.TextSize = 12
    credit.TextYAlignment = Enum.TextYAlignment.Center
end)

-- --- Helper: Create Button ---
local function createButton(text, posY)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(0, 180, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    return btn
end

local recordButton = createButton("Start Recording", 10)
local replayButton = createButton("Summon Unit", 50)
local clearButton  = createButton("Clear", 90)

-- --- Movement Recording ---
local recording = false
local movementData = {}

recordButton.MouseButton1Click:Connect(function()
    if not recording then
        movementData = {}
        recording = true
        recordButton.Text = "Stop Recording"
        coroutine.wrap(function()
            while recording do
                table.insert(movementData, {tick = tick(), cframe = humanoidRootPart.CFrame})
                wait(0.2)
            end
        end)()
    else
        recording = false
        recordButton.Text = "Start Recording"
    end
end)

-- --- Replay via Dummy Clone (Unit) ---
replayButton.MouseButton1Click:Connect(function()
    if #movementData < 2 then return end

    -- Clone player as dummy
    local dummy = character:Clone()
    dummy.Name = "ReplayUnit"
    dummy.Parent = workspace

    -- Remove scripts
    for _, obj in pairs(dummy:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            obj:Destroy()
        end
    end

    local root = dummy:FindFirstChild("HumanoidRootPart")
    if not root then return end

    root.Anchored = true
    root.CFrame = movementData[1].cframe

    local startTime = movementData[1].tick
    for _, data in ipairs(movementData) do
        local delayTime = data.tick - startTime
        task.delay(delayTime, function()
            if root then root.CFrame = data.cframe end
        end)
    end
end)

-- --- Clear Data ---
clearButton.MouseButton1Click:Connect(function()
    movementData = {}
end)
