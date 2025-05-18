-- SERVICES
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local runService = game:GetService("RunService")

-- STATE
local recording = false
local replaying = false
local movementLog = {}
local unitPlacements = {}

-- GUI SETUP
local gui = Instance.new("ScreenGui")
gui.Name = "MovementRecorderGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 300)
frame.Position = UDim2.new(1, -240, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 10)
uiList.FillDirection = Enum.FillDirection.Vertical
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiList.VerticalAlignment = Enum.VerticalAlignment.Top
uiList.Parent = frame

local function createButton(text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 50)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 22
	btn.Text = text
	btn.AutoButtonColor = true
	btn.Parent = frame
	return btn
end

-- BUTTONS
local startBtn = createButton("▶ Start Recording")
local stopBtn = createButton("⏹ Stop Recording")
local placeBtn = createButton("➕ Place Minion")
local replayBtn = createButton("🔁 Replay Movement")

-- FUNCTIONALITY
startBtn.MouseButton1Click:Connect(function()
	recording = true
	movementLog = {}
	unitPlacements = {}
	print("Recording started.")
end)

stopBtn.MouseButton1Click:Connect(function()
	recording = false
	print("Recording stopped.")
end)

placeBtn.MouseButton1Click:Connect(function()
	if recording then
		local pos = root.Position
		table.insert(unitPlacements, pos)

		-- Simulate "minion"
		local minion = Instance.new("Part")
		minion.Size = Vector3.new(2, 2, 2)
		minion.Position = pos
		minion.Anchored = true
		minion.Shape = Enum.PartType.Ball
		minion.Material = Enum.Material.Neon
		minion.Color = Color3.fromRGB(255, 50, 50)
		minion.Name = "Minion"
		minion.Parent = workspace
	end
end)

replayBtn.MouseButton1Click:Connect(function()
	if not replaying then
		replaying = true
		print("Replaying movement...")
		for _, pos in ipairs(movementLog) do
			root.CFrame = CFrame.new(pos)
			task.wait(0.05)
		end

		print("Replaying minion placements...")
		for _, pos in ipairs(unitPlacements) do
			local clone = Instance.new("Part")
			clone.Size = Vector3.new(2, 2, 2)
			clone.Position = pos
			clone.Anchored = true
			clone.Shape = Enum.PartType.Ball
			clone.Material = Enum.Material.Neon
			clone.Color = Color3.fromRGB(50, 255, 50)
			clone.Name = "MinionClone"
			clone.Parent = workspace
		end

		print("Replay complete.")
		replaying = false
	end
end)

-- RECORD MOVEMENT EVERY FRAME
runService.RenderStepped:Connect(function()
	if recording then
		table.insert(movementLog, root.Position)
	end
end)
