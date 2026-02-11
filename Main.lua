-- [[ VORTEX HUB V2 - ALL-IN-ONE ]]
-- English: Integrated Script with Aimbot, ESP, and Clean Unload logic.

-- 1. SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- 2. GLOBAL TABLES (The "Brain" and the "Bucket")
_G.Vortex_Configs = {
    Aimbot = { Enabled = false, FOV = 150, Smoothness = 2 },
    ESP = { Enabled = false, Color = Color3.fromRGB(255, 0, 0) }
}

_G.Vortex_Cleanup = {
    Connections = {}, -- English: Stores loops and events
    Drawings = {}     -- English: Stores ESP dots and FOV circles
}

-- 3. LOAD LUNA UI
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/luna"))()

-- 4. CORE FUNCTIONS (Aimbot & ESP Logic)

-- English: Finds the nearest player to the mouse
local function GetClosestPlayer()
    local nearestPlayer = nil
    local shortestDistance = _G.Vortex_Configs.Aimbot.FOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local mouseLocation = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(pos.X, pos.Y) - mouseLocation).Magnitude
                if distance < shortestDistance then
                    nearestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return nearestPlayer
end

-- 5. INITIALIZING MODULES

-- [ FOV CIRCLE ]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
table.insert(_G.Vortex_Cleanup.Drawings, FOVCircle)

-- [ ESP DOTS ]
local ESP_Objects = {}
local function CreateDot(player)
    local circle = Drawing.new("Circle")
    circle.Visible = false
    circle.Color = _G.Vortex_Configs.ESP.Color
    circle.Radius = 4
    circle.Filled = true
    circle.NumSides = 12
    ESP_Objects[player] = circle
    table.insert(_G.Vortex_Cleanup.Drawings, circle)
end

-- 6. MAIN RENDER LOOP (The Heart of the Script)
local MainLoop = RunService.RenderStepped:Connect(function()
    -- FOV Circle Update
    FOVCircle.Visible = _G.Vortex_Configs.Aimbot.Enabled
    FOVCircle.Radius = _G.Vortex_Configs.Aimbot.FOV
    FOVCircle.Position = UserInputService:GetMouseLocation()

    -- Aimbot Execution
    if _G.Vortex_Configs.Aimbot.Enabled then
        local target = GetClosestPlayer()
        if target and target.Character then
            local targetPos = target.Character.HumanoidRootPart.Position
            local targetLookAt = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetLookAt, 1 / _G.Vortex_Configs.Aimbot.Smoothness)
        end
    end

    -- ESP Execution
    for player, dot in pairs(ESP_Objects) do
        if _G.Vortex_Configs.ESP.Enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                dot.Position = Vector2.new(pos.X, pos.Y)
                dot.Visible = true
            else
                dot.Visible = false
            end
        else
            dot.Visible = false
        end
    end
end)
table.insert(_G.Vortex_Cleanup.Connections, MainLoop)

-- 7. UI SETUP (Luna)
local Window = Luna:CreateWindow({ Name = "Vortex Hub | Street Life", Subtitle = "V2", Color = Color3.fromRGB(170, 0, 0) })
local CombatTab = Window:CreateTab("Combat")
local VisualTab = Window:CreateTab("Visuals")
local SettingsTab = Window:CreateTab("Settings")

CombatTab:CreateToggle("Enable Aimbot", function(state) _G.Vortex_Configs.Aimbot.Enabled = state end)
CombatTab:CreateSlider("Aimbot FOV", 50, 500, function(v) _G.Vortex_Configs.Aimbot.FOV = v end)
CombatTab:CreateSlider("Smoothness", 1, 10, function(v) _G.Vortex_Configs.Aimbot.Smoothness = v end)

VisualTab:CreateToggle("Red Dot ESP", function(state) _G.Vortex_Configs.ESP.Enabled = state end)

-- 8. UNLOAD LOGIC
SettingsTab:CreateButton("Unload Script", function()
    -- Stop all connections
    for _, conn in pairs(_G.Vortex_Cleanup.Connections) do conn:Disconnect() end
    -- Remove all drawings
    for _, draw in pairs(_G.Vortex_Cleanup.Drawings) do draw:Remove() end
    -- Destroy UI
    local CoreGui = game:GetService("CoreGui")
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name:find("Luna") then v:Destroy() end
    end
    _G.Vortex_Configs = nil
    _G.Vortex_Cleanup = nil
end)

-- Initial player check for ESP
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateDot(p) end end
table.insert(_G.Vortex_Cleanup.Connections, Players.PlayerAdded:Connect(CreateDot))
