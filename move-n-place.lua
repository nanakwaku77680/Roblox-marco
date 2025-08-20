-- Universal Hitbox Expander GUI (Movable)
-- Made by Batman Your Homie

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

local hitboxes = {}
local playerHitbox
local expanded = false

-- Function to attach hitbox to NPC/mob
local function attachHitbox(npc)
    if hitboxes[npc] then return end
    local npcRoot = npc:FindFirstChild("HumanoidRootPart")
    if not npcRoot then return end

    local hitbox = Instance.new("Part")
    hitbox.Size = Vector3.new(4,4,4)
    hitbox.Transparency = 0.5
    hitbox.Anchored = false
    hitbox.CanCollide = false
    hitbox.Name = npc.Name.."_Hitbox"
    hitbox.Parent = workspace

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = npcRoot
    weld.Part1 = hitbox
    weld.Parent = hitbox

    hitbox.Touched:Connect(function(part)
        local hum = part.Parent:FindFirstChild("Humanoid")
        if hum then
            print("NPC Hitbox touched by:", hum.Parent.Name)
        end
    end)

    hitboxes[npc] = hitbox
end

-- Attach to existing NPCs
for _, npc in ipairs(workspace:GetChildren()) do
    if npc:FindFirstChild("Humanoid") then
        attachHitbox(npc)
    end
end

-- Attach to new NPCs
workspace.ChildAdded:Connect(function(child)
    if child:FindFirstChild("Humanoid") then
        attachHitbox(child)
    end
end)

-- Create player hitbox
playerHitbox = Instance.new("Part")
playerHitbox.Size = root.Size
playerHitbox.Transparency = 0.5
playerHitbox.Anchored = false
playerHitbox.CanCollide = false
playerHitbox.Name = "PlayerHitbox"
playerHitbox.Parent = workspace

local playerWeld = Instance.new("WeldConstraint")
playerWeld.Part0 = root
playerWeld.Part1 = playerHitbox
playerWeld.Parent = playerHitbox

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UniversalHitboxGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 100)
frame.Position = UDim2.new(0,20,0,20)
frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
frame.BorderSizePixel = 0
frame.Parent = screenGui
frame.Active = true
frame.Draggable = true  -- ✅ Makes the GUI movable

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "Hitbox Expander"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1,0,0,20)
sub.Position = UDim2.new(0,0,0,30)
sub.BackgroundTransparency = 1
sub.Text = "Made by Batman Your Homie"
sub.TextColor3 = Color3.fromRGB(200,200,200)
sub.Font = Enum.Font.SourceSans
sub.TextSize = 14
sub.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(0,200,0,30)
button.Position = UDim2.new(0,10,0,60)
button.BackgroundColor3 = Color3.fromRGB(70,70,70)
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Text = "Toggle Hitboxes"
button.Font = Enum.Font.SourceSansBold
button.TextSize = 16
button.Parent = frame

-- Toggle function
button.MouseButton1Click:Connect(function()
    expanded = not expanded
    -- Toggle NPCs
    for _, hitbox in pairs(hitboxes) do
        hitbox.Size = expanded and Vector3.new(8,8,8) or Vector3.new(4,4,4)
    end
    -- Toggle player hitbox 3x normal
    playerHitbox.Size = expanded and root.Size * 3 or root.Size
    print("📦 All hitboxes "..(expanded and "expanded" or "reset"))
end)
