-- [[ VORTEX HUB V2 - MAIN LOADER ]]
-- Description: Central script to initialize UI and Module structure.
-- Language: Lua

-- 1. LOAD UI LIBRARY
-- Using Luna UI for a clean, professional look
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/luna"))()

-- 2. INITIALIZE TABLES
-- These will store our connections and drawing objects for the Unload function
_G.Vortex_Configs = {
    Aimbot = { Enabled = false, FOV = 150, Smoothness = 1 },
    ESP = { Enabled = false, Color = Color3.fromRGB(255, 0, 0) }
}
_G.Vortex_Cleanup = {
    Connections = {},
    Drawings = {}
}

-- 3. CREATE MAIN WINDOW
local Window = Luna:CreateWindow({
    Name = "Vortex Hub | Street Life",
    Subtitle = "Remastered V2",
    Color = Color3.fromRGB(170, 0, 0), -- Professional Dark Red theme
    LogoID = 0 -- You can add a custom asset ID here later
})

-- 4. CREATE TABS
local CombatTab = Window:CreateTab("Combat")
local VisualTab = Window:CreateTab("Visuals")
local SettingsTab = Window:CreateTab("Settings")

-- [[ COMBAT TAB ELEMENTS ]]
CombatTab:CreateToggle("Enable Aimbot", function(state)
    _G.Vortex_Configs.Aimbot.Enabled = state
    print("Aimbot state changed to: " .. tostring(state))
end)

-- [[ VISUAL TAB ELEMENTS ]]
VisualTab:CreateToggle("Enable Red Dot ESP", function(state)
    _G.Vortex_Configs.ESP.Enabled = state
    print("ESP state changed to: " .. tostring(state))
end)

-- [[ SETTINGS TAB ELEMENTS ]]
SettingsTab:CreateButton("Unload Script", function()
    -- We will call the specific cleanup functions here in the last step
    print("Starting Unload process...")
    -- (Placeholder for the actual Unload logic)
end)

print("Vortex Hub: UI Framework Loaded Successfully.")
