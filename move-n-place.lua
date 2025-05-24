-- Anime Fantasy Movement & Unit Recorder GUI (Toggleable)
-- Made by BatmanOg

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local workspace = game:GetService("Workspace")

-- Data
local recording = false
local movementData = {}
local unitLog = {}

-- GUI Setup
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BatmanOgRecorderGUI"

-- Toggle Button
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 100, 0, 30)
toggleBtn.Position = UDim2.new(0, 20, 0, 20)
toggleBtn.Text = "Toggle GUI"
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

-- Main Frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 0)
frame.Position = UDim2.new(0, 140, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Visible = false
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

-- Credit Label
local credit = Instance.new("TextLabel", frame)
credit.Size = UDim2.new(0, 200, 0, 20)
credit.Position = UDim2.new(0, 0, 1, -20)
credit.BackgroundTransparency = 1
credit.Text = "Made by BatmanOg"
credit.TextColor3 = Color3.fromRGB(200, 200, 200)
credit.TextSize = 14
credit.Font = Enum.Font.Gotham

-- Toggle behavior
local isOpen = false
toggleBtn.MouseButton1Click:Connect(function()
	if isOpen then
		TweenService:Create(frame, TweenInfo.new(0.4), {
			Size = UDim2.new(0, 200, 0, 0)
		}):Play()
		task.wait(0.4)
		frame.Visible = false
	else
		frame.Visible = true
		TweenService:Create(frame, TweenInfo.new(0.4), {
			Size = UDim2.new(0, 200, 0, 220)
		}):Play()
	end
	isOpen = not isOpen
end)

-- Create button helper
local function createButton(text, posY)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0, 180, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, posY)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

-- Buttons
local startBtn = createButton("Start Recording", 0.05)
local stopBtn = createButton("Stop Recording", 0.25)
local playBtn = createButton("Play Replay", 0.45)
local clearBtn = createButton("Clear", 0.65)

-- Unit Placement Tracking
local unitFolder = workspace:FindFirstChild("Units") or workspace
local unitConnection

unitConnection = unitFolder.ChildAdded:Connect(function(child)
	if recording and child:IsA("Model") and not child:IsDescendantOf(character) then
		task.wait(0.1)
		local root = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChildWhichIsA("BasePart")
		if root then
			table.insert(unitLog, {
				time = tick(),
				name = child.Name,
				cframe = root.CFrame
			})
		end
	end
end)

-- Start Recording
startBtn.MouseButton1Click:Connect(function()
	if recording then return end
	movementData = {}
	unitLog = {}
	recording = true
	startBtn.Text = "Recording..."

	coroutine.wrap(function()
		while recording do
			table.insert(movementData, {
				tick = tick(),
				cframe = humanoidRootPart.CFrame
			})
			wait(0.2)
		end
	end)()
end)

-- Stop Recording
stopBtn.MouseButton1Click:Connect(function()
	recording = false
	startBtn.Text = "Start Recording"
end)

-- Replay
playBtn.MouseButton1Click:Connect(function()
	if #movementData < 2 then return end
	local startTime = movementData[1].tick

	-- Replay movement
	for _, data in ipairs(movementData) do
		local delayTime = data.tick - startTime
		task.delay(delayTime, function()
			humanoidRootPart.CFrame = data.cframe
		end)
	end

	-- Replay units (dummy)
	for _, unit in ipairs(unitLog) do
		local delay = unit.time - startTime
		task.delay(delay, function()
			local fakeUnit = Instance.new("Part")
			fakeUnit.Name = unit.name .. "_Replay"
			fakeUnit.Size = Vector3.new(2, 2, 2)
			fakeUnit.Anchored = true
			fakeUnit.CFrame = unit.cframe
			fakeUnit.Color = Color3.fromRGB(255, 200, 100)
			fakeUnit.Material = Enum.Material.Neon
			fakeUnit.CanCollide = false
			fakeUnit.Parent = workspace
		end)
	end
end)

-- Clear Data
clearBtn.MouseButton1Click:Connect(function()
	movementData = {}
	unitLog = {}
end)
