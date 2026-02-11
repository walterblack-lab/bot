-- [[ AIMBOT MODULE - PRECISION TARGETING ]]
-- Description: Calculates the nearest player to the cursor and locks the camera.

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- 1. FOV CIRCLE VISUALIZATION
-- Drawing the circle that shows the aimbot's reach
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.5
FOVCircle.Filled = false
FOVCircle.Visible = false
table.insert(_G.Vortex_Cleanup.Drawings, FOVCircle)

-- 2. FUNCTION: GET NEAREST PLAYER
-- English: Finds the player closest to the mouse cursor within FOV range.
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

-- 3. MAIN AIMBOT LOOP
-- English: Runs every frame to update camera position if target is found.
local AimbotLoop = RunService.RenderStepped:Connect(function()
    -- Update FOV Circle appearance
    FOVCircle.Visible = _G.Vortex_Configs.Aimbot.Enabled
    FOVCircle.Radius = _G.Vortex_Configs.Aimbot.FOV
    FOVCircle.Position = UserInputService:GetMouseLocation()

    if _G.Vortex_Configs.Aimbot.Enabled then
        local target = GetClosestPlayer()
        
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            
            -- Smoothness calculation: 1 = Instant, higher = slower
            local lerpAmount = 1 / _G.Vortex_Configs.Aimbot.Smoothness
            local targetLookAt = CFrame.new(Camera.CFrame.Position, targetPos)
            
            Camera.CFrame = Camera.CFrame:Lerp(targetLookAt, lerpAmount)
        end
    end
end)

table.insert(_G.Vortex_Cleanup.Connections, AimbotLoop)
