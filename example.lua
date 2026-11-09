local LibraryURL = "https://raw.githubusercontent.com/WareSploit/DeepSeek-V4.1-Flash-Library/main/main.lua"

local success, Library = pcall(function()
    return loadstring(game:HttpGet(LibraryURL))()
end)

if not success then
    return warn("Failed to load library.")
end

local Window = Library:CreateWindow("DeepSeek V4.1-Flash")

local MainTab = Window:CreateTab("Main")
local VisualTab = Window:CreateTab("Visuals")
local ConfigTab = Window:CreateTab("Configs")

-- Main Tab
MainTab:CreateLabel(MainTab, "=== Main Functions ===")

MainTab:CreateToggle(MainTab, "Auto Farm", "AutoFarm", false, function(state)
    print("AutoFarm:", state)
end)

MainTab:CreateSlider(MainTab, "Walk Speed", "WalkSpeed", 16, 200, 16, function(val)
    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)

MainTab:CreateDropdown(MainTab, "Select Mode", "Mode", {"Legit", "Rage", "Silent"}, "Legit", function(opt)
    print("Mode:", opt)
end)

-- Visuals Tab
VisualTab:CreateLabel(VisualTab, "=== Visual Settings ===")

VisualTab:CreateKeybind(VisualTab, "Toggle ESP", "EspKey", Enum.KeyCode.RightShift, function(key)
    Library:Notify("ESP", "ESP Toggled", 2)
end)

-- Configs Tab
ConfigTab:CreateTextBox(ConfigTab, "Config Name", "ConfigNameBox", "default", function(text)
    print("Config name set to:", text)
end)

ConfigTab:CreateButton(ConfigTab, "Save Config", function()
    Library:SaveConfig("default")
end)

ConfigTab:CreateButton(ConfigTab, "Load Config", function()
    Library:LoadConfig("default")
end)

Library:Notify("Loaded", "DeepSeek UI is ready!", 5)
