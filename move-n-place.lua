local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local UIS = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local recording = false
local replaying = false
local movementLog = {}
local unitPlacements = {}

-- Simulated unit placement (e.g., pressing "P")
UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.P and recording then
		local pos = humanoidRootPart.Position
		table.insert(unitPlacements, pos)
		print("Placed unit at:", pos)

		-- Simulate unit (a red part)
		local part = Instance.new("Part")
		part.Size = Vector3.new(2, 2, 2)
		part.Position = pos
		part.Anchored = true
		part.BrickColor = BrickColor.Red()
		part.Parent = workspace
	end
end)

-- Start recording with "R"
UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.R then
		print("Started recording")
		recording = true
		movementLog = {}
		unitPlacements = {}
	end
end)

-- Stop recording with "T"
UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.T then
		print("Stopped recording")
		recording = false
	end
end)

-- Start replay with "Y"
UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Y then
		if not replaying then
			replaying = true
			print("Replaying...")
			for i, pos in ipairs(movementLog) do
				humanoidRootPart.CFrame = CFrame.new(pos)
				task.wait(0.05)
			end

			for _, pos in ipairs(unitPlacements) do
				local part = Instance.new("Part")
				part.Size = Vector3.new(2, 2, 2)
				part.Position = pos
				part.Anchored = true
				part.BrickColor = BrickColor.Green()
				part.Parent = workspace
			end

			print("Replay finished")
			replaying = false
		end
	end
end)

-- Record movement every frame
runService.RenderStepped:Connect(function()
	if recording then
		table.insert(movementLog, humanoidRootPart.Position)
	end
end)
