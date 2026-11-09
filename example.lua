--[[
    DeepSeek V4.1-Flash - Example Script
    Author: WareSploit
]]

-- ✅ Твоя прямая raw-ссылка на GitHub
local LibraryURL = "https://raw.githubusercontent.com/WareSploit/DeepSeek-V4.1-Flash-Library/main/main.lua"

local success, Library = pcall(function()
    return loadstring(game:HttpGet(LibraryURL))()
end)

if not success then
    return warn("Не удалось загрузить библиотеку. Проверь ссылку и наличие файла main.lua в репозитории.")
end

local Window = Library:CreateWindow("DeepSeek V4.1-Flash")

Library:Notify("DeepSeek", "Библиотека успешно загружена!", 5)

local MainTab = Window:CreateTab("Main")
local VisualTab = Window:CreateTab("Visuals")
local MiscTab = Window:CreateTab("Misc")

-- ==========================================
-- MAIN TAB
-- ==========================================
MainTab:CreateLabel(MainTab, "Настройки игрока")

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

-- ==========================================
-- VISUALS TAB
-- ==========================================
VisualTab:CreateLabel(VisualTab, "Визуальные настройки")

VisualTab:CreateKeybind(VisualTab, "Toggle ESP", "EspKey", Enum.KeyCode.RightShift, function()
    Library:Notify("ESP", "ESP переключен!", 2)
end)

VisualTab:CreateColorPicker(VisualTab, "ESP Color", "EspColor", Color3.fromRGB(255, 0, 0), function(color)
    print("Новый цвет:", color)
end)

-- ==========================================
-- MISC TAB
-- ==========================================
MiscTab:CreateLabel(MiscTab, "Разное")

MiscTab:CreateTextBox(MiscTab, "Custom Text", "TextBoxFlag", "Hello", function(text)
    print("Текст сохранен:", text)
end)

MiscTab:CreateButton(MiscTab, "Нажми меня", function()
    Library:Notify("Кнопка", "Ты нажал кнопку!", 3)
end)

-- ==========================================
-- CONFIGS TAB
-- ==========================================
Library:BuildConfigTab(Window)
