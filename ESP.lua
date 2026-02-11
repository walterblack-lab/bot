-- [[ ESP MODULE - HIGH PERFORMANCE RED DOTS ]]
-- Description: Handles 3D to 2D projection and drawing of player markers.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- TABLE TO STORE DRAWING OBJECTS
local ESP_Objects = {}

-- [[ FUNCTION: CREATE DRAWING ]]
-- English: Creates a new circle for a specific player.
local function CreateDot(player)
    local circle = Drawing.new("Circle")
    circle.Visible = false
    circle.Color = _G.Vortex_Configs.ESP.Color
    circle.Thickness = 1
    circle.Radius = 4
    circle.Filled = true
    circle.NumSides = 12 -- Optimization: lower sides = less GPU usage
    
    ESP_Objects[player] = circle
    table.insert(_G.Vortex_Cleanup.Drawings, circle) -- Add to global cleanup
end

-- [[ FUNCTION: UPDATE POSITIONS ]]
-- English: Updates dot positions on every frame.
local function UpdateESP()
    for player, dot in pairs(ESP_Objects) do
        -- Only process if the toggle is ON and the player character exists
        if _G.Vortex_Configs.ESP.Enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

            if onScreen then
                dot.Position = Vector2.new(screenPos.X, screenPos.Y)
                dot.Visible = true
            else
                dot.Visible = false
            end
        else
            dot.Visible = false
        end
    end
end

-- [[ INITIALIZATION & EVENTS ]]
-- English: Handle existing and joining players.
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateDot(player)
    end
end

local PlayerAddedConn = Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreateDot(player)
    end
end)

local PlayerRemovingConn = Players.PlayerRemoving:Connect(function(player)
    if ESP_Objects[player] then
        ESP_Objects[player]:Remove()
        ESP_Objects[player] = nil
    end
end)

-- Connect to RenderStepped for smooth movement
local ESPLoopConn = RunService.RenderStepped:Connect(UpdateESP)

-- Store connections for Unload
table.insert(_G.Vortex_Cleanup.Connections, PlayerAddedConn)
table.insert(_G.Vortex_Cleanup.Connections, PlayerRemovingConn)
table.insert(_G.Vortex_Cleanup.Connections, ESPLoopConn)
