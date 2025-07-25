-- Utility function to safely destroy instances
local function safeDestroy(obj)
    if obj and typeof(obj) == "Instance" and obj:IsA("Instance") and obj.Destroy then
        local success, err = pcall(function()
            obj:Destroy()
        end)
        if not success then
            warn("Couldn't destroy:", obj:GetFullName(), "|", err)
        end
    end
end

-- 1. Lighting optimization
local Lighting = game:GetService("Lighting")
Lighting.EnvironmentDiffuseScale = 0
Lighting.Brightness = 0

-- 2. Remove all GUIs and add a fullscreen black overlay
local Players = game:GetService("Players")
local player = Players.LocalPlayer

if player then
    local gui = player:FindFirstChild("PlayerGui")
    if gui then
        gui:ClearAllChildren()
    end

    -- Fullscreen black UI with white centered text
    local screenGui = Instance.new("ScreenGui")
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Name = "BlackoutUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local textLabel = Instance.new("TextLabel")
    textLabel.Text = "⚠️ NumaOpti ⚠️"
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextScaled = true
    textLabel.Size = UDim2.new(0.8, 0, 0.2, 0)
    textLabel.Position = UDim2.new(0.1, 0, 0.4, 0)
    textLabel.Parent = frame
end

-- 3. Safe deletions from workspace
local toDelete = {
    "Camera",
    "Jetpacks",
    "Gifts",
    "TopDonatedHistory",
    "TopRaisedHistory",
    "Sound",
    "Particles"
}

for _, name in ipairs(toDelete) do
    safeDestroy(workspace:FindFirstChild(name))
end

-- 4. Terrain (cannot be destroyed, just cleared)
if workspace:FindFirstChild("Terrain") then
    workspace.Terrain:Clear()
end

-- 5. Map cleanup
local map = workspace:FindFirstChild("Map")
if map then
    local mapTargets = {
        "Adverts", "Buildings", "ClubIsland", "Decoration",
        "EasterEggs", "Functional", "NukeIsland", "ParticleEmitters",
        "Structures", "Ramps"
    }

    for _, name in ipairs(mapTargets) do
        safeDestroy(map:FindFirstChild(name))
    end

    local env = map:FindFirstChild("Environment")
    if env then
        safeDestroy(env:FindFirstChild("Rocks"))
        safeDestroy(env:FindFirstChild("Path"))

        local foliage = env:FindFirstChild("Foliage")
        if foliage then
            safeDestroy(foliage:FindFirstChild("Trees"))
            safeDestroy(foliage:FindFirstChild("Grass"))
        end

        local terrain = env:FindFirstChild("Terrain")
        if terrain then
            safeDestroy(terrain:FindFirstChild("GrassHill"))
            safeDestroy(terrain:FindFirstChild("Hills"))
            safeDestroy(terrain:FindFirstChild("RaisedGrass"))
            safeDestroy(terrain:FindFirstChild("GroundPatches"))
        end
    end
end

-- 6. Disable all accessible CoreGui elements
local StarterGui = game:GetService("StarterGui")
for _, guiType in ipairs(Enum.CoreGuiType:GetEnumItems()) do
    pcall(function()
        StarterGui:SetCoreGuiEnabled(guiType, false)
    end)
end

-- 7. Disable .Enabled GUI objects in CoreGui (e.g., imgui)
local CoreGui = game:GetService("CoreGui")
for _, child in ipairs(CoreGui:GetDescendants()) do
    if pcall(function() return child.Enabled end) then
        pcall(function()
            child.Enabled = false
        end)
    end
end

