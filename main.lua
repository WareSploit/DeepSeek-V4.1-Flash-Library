--[[
================================================================================
    DeepSeek V4.1-Flash UI Library
    Version: 3.5.0 (Ultimate Full Release)
    Author: WareSploit & DeepSeek
    Description: Полноценная, многофункциональная UI-библиотека с поддержкой 
                 перетаскивания, конфигов, уведомлений, ColorPicker и всех 
                 базовых элементов интерфейса. Без иконок и эмодзи.
================================================================================
]]

-- ============================================================================
-- СЕРВИСЫ
-- ============================================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================================================
-- КОНФИГУРАЦИЯ И ПЕРЕМЕННЫЕ
-- ============================================================================
local Library = {}
Library.Flags = {}
Library.ConfigFolder = "DeepSeek_Configs"
Library.Connections = {}
Library.Notifications = {}

-- Палитра цветов (основана на исходном дизайне)
local Theme = {
    MainBg = Color3.fromRGB(0, 50, 149),
    MainBgTrans = 0.15,
    TopBarBg = Color3.fromRGB(4, 51, 111),
    TopBarTrans = 0.5,
    ElementBg = Color3.fromRGB(4, 48, 105),
    ElementTrans = 0.6,
    PlayerInfoBg = Color3.fromRGB(5, 68, 144),
    Stroke = Color3.fromRGB(0, 39, 114),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(170, 170, 170),
    Accent = Color3.fromRGB(0, 150, 255),
    Red = Color3.fromRGB(200, 50, 50),
    Green = Color3.fromRGB(50, 200, 50)
}

-- ============================================================================
-- УТИЛИТЫ ДЛЯ СОЗДАНИЯ ОБЪЕКТОВ
-- ============================================================================
local function Create(className, properties, parent)
    local obj = Instance.new(className)
    for k, v in pairs(properties) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    obj.Parent = parent
    return obj
end

local function AddStroke(obj, color, thickness)
    return Create("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, obj)
end

local function AddCorner(obj, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 4)
    }, obj)
end

local function AddGradient(obj, rotation, color1, color2)
    return Create("UIGradient", {
        Rotation = rotation or 123,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, color1 or Color3.fromRGB(4, 42, 87)),
            ColorSequenceKeypoint.new(1, color2 or Color3.fromRGB(255, 255, 255))
        }
    }, obj)
end

local function Tween(obj, time, props)
    local tweenInfo = TweenInfo.new(
        time or 0.2,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(obj, tweenInfo, props)
    tween:Play()
    return tween
end

-- ============================================================================
-- УТИЛИТА ДЛЯ DRAG & DROP (ПЕРЕТАСКИВАНИЕ)
-- ============================================================================
local function MakeDraggable(frame, dragArea)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================================================
-- СИСТЕМА УВЕДОМЛЕНИЙ (NOTIFICATIONS)
-- ============================================================================
local NotifGui = Create("ScreenGui", {
    Name = "DeepSeekNotifications",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, CoreGui or LocalPlayer:WaitForChild("PlayerGui"))

local NotifFrame = Create("Frame", {
    Size = UDim2.new(0, 250, 1, -20),
    Position = UDim2.new(1, -260, 0, 10),
    BackgroundTransparency = 1
}, NotifGui)

Create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Padding = UDim.new(0, 8)
}, NotifFrame)

function Library:Notify(title, text, duration)
    duration = duration or 3
    
    local notif = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = Theme.MainBg,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 260, 0, 0)
    }, NotifFrame)
    
    AddCorner(notif)
    AddStroke(notif)
    AddGradient(notif)

    Create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    }, notif)

    Create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 30),
        Position = UDim2.new(0, 5, 0, 25),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left
    }, notif)

    Tween(notif, 0.3, { Position = UDim2.new(0, 0, 0, 0) })

    task.delay(duration, function()
        local outTween = Tween(notif, 0.3, {
            Position = UDim2.new(1, 260, 0, 0),
            BackgroundTransparency = 1
        })
        outTween.Completed:Connect(function()
            notif:Destroy()
        end)
    end)
end

-- ============================================================================
-- СОЗДАНИЕ ГЛАВНОГО ОКНА
-- ============================================================================
function Library:CreateWindow(title)
    local ScreenGui = Create("ScreenGui", {
        Name = "DeepSeekUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, LocalPlayer:WaitForChild("PlayerGui"))

    -- ------------------------------------------------------------------------
    -- OPEN FRAME (Свернутое состояние)
    -- ------------------------------------------------------------------------
    local OpenFrame = Create("Frame", {
        Name = "OpenFrame",
        Size = UDim2.new(0, 304, 0, 47),
        Position = UDim2.new(0.5, -152, 0, 10),
        BackgroundColor3 = Theme.MainBg,
        BackgroundTransparency = Theme.MainBgTrans,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 10
    }, ScreenGui)
    AddCorner(OpenFrame)
    AddStroke(OpenFrame)
    AddGradient(OpenFrame)
    MakeDraggable(OpenFrame, OpenFrame)

    Create("TextLabel", {
        Size = UDim2.new(0, 185, 0, 42),
        Position = UDim2.new(0.19, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    }, OpenFrame)

    local OpenBtn = Create("TextButton", {
        Size = UDim2.new(0, 26, 0, 27),
        Position = UDim2.new(0.05, 0, 0.2, 0),
        BackgroundColor3 = Theme.ElementBg,
        BackgroundTransparency = Theme.ElementTrans,
        Text = "+",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16
    }, OpenFrame)
    AddCorner(OpenBtn)
    AddStroke(OpenBtn)

    -- ------------------------------------------------------------------------
    -- MAIN FRAME (Основное окно)
    -- ------------------------------------------------------------------------
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 550, 0, 349),
        Position = UDim2.new(0.5, -275, 0.5, -174.5),
        BackgroundColor3 = Theme.MainBg,
        BackgroundTransparency = Theme.MainBgTrans,
        BorderSizePixel = 0
    }, ScreenGui)
    AddCorner(MainFrame)
    AddStroke(MainFrame)
    AddGradient(MainFrame)

    -- TopBar
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.TopBarBg,
        BackgroundTransparency = Theme.TopBarTrans,
        BorderSizePixel = 0,
        ZIndex = 3
    }, MainFrame)
    AddCorner(TopBar)
    AddStroke(TopBar)
    MakeDraggable(MainFrame, TopBar)

    Create("TextLabel", {
        Size = UDim2.new(0, 150, 1, 0),
        Position = UDim2.new(0.12, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    }, TopBar)

    -- Инфо о экзекуторе
    local ExecName = "Studio"
    if identifyexecutor then
        local success, name = pcall(identifyexecutor)
        if success then ExecName = name end
    end

    Create("TextLabel", {
        Size = UDim2.new(0, 100, 0, 34),
        Position = UDim2.new(0.48, 0, 0.09, 0),
        BackgroundTransparency = 1,
        Text = "Exec: " .. ExecName,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14
    }, TopBar)

    -- Инфо об игроках
    local PlayerCountLabel = Create("TextLabel", {
        Size = UDim2.new(0, 93, 0, 34),
        Position = UDim2.new(0.67, 0, 0.09, 0),
        BackgroundTransparency = 1,
        Text = "Players: " .. #Players:GetPlayers(),
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14
    }, TopBar)
    
    local pAddConn = Players.PlayerAdded:Connect(function() 
        PlayerCountLabel.Text = "Players: " .. #Players:GetPlayers() 
    end)
    local pRemConn = Players.PlayerRemoving:Connect(function() 
        PlayerCountLabel.Text = "Players: " .. #Players:GetPlayers() 
    end)
    table.insert(Library.Connections, pAddConn)
    table.insert(Library.Connections, pRemConn)

    -- Кнопки управления окном
    local MinBtn = Create("TextButton", {
        Size = UDim2.new(0, 26, 0, 27),
        Position = UDim2.new(1, -65, 0.16, 0),
        BackgroundColor3 = Theme.ElementBg,
        BackgroundTransparency = Theme.ElementTrans,
        Text = "-",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        ZIndex = 4
    }, TopBar)
    AddCorner(MinBtn)
    AddStroke(MinBtn)

    local CloseBtn = Create("TextButton", {
        Size = UDim2.new(0, 26, 0, 27),
        Position = UDim2.new(1, -35, 0.16, 0),
        BackgroundColor3 = Theme.ElementBg,
        BackgroundTransparency = Theme.ElementTrans,
        Text = "X",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        ZIndex = 4
    }, TopBar)
    AddCorner(CloseBtn)
    AddStroke(CloseBtn)

    -- SideBar
    local SideBar = Create("Frame", {
        Name = "SideBar",
        Size = UDim2.new(0, 120, 0, 307),
        Position = UDim2.new(0, 0, 0.12, 0),
        BackgroundColor3 = Theme.TopBarBg,
        BackgroundTransparency = Theme.TopBarTrans,
        BorderSizePixel = 0
    }, MainFrame)
    AddCorner(SideBar)
    AddStroke(SideBar)

    local TabList = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 250),
        BackgroundTransparency = 1
    }, SideBar)
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    }, TabList)

    -- Инфо об игроке (внизу сайдбара)
    local PlayerInfoFrame = Create("Frame", {
        Size = UDim2.new(0, 120, 0, 58),
        Position = UDim2.new(0, 0, 0.81, 0),
        BackgroundColor3 = Theme.PlayerInfoBg,
        BackgroundTransparency = Theme.TopBarTrans,
        BorderSizePixel = 0
    }, SideBar)
    AddCorner(PlayerInfoFrame)
    AddStroke(PlayerInfoFrame)
    AddGradient(PlayerInfoFrame)

    local Avatar = Create("ImageLabel", {
        Size = UDim2.new(0, 39, 0, 39),
        Position = UDim2.new(0.06, 0, 0.15, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
        BorderSizePixel = 0
    }, PlayerInfoFrame)
    AddCorner(Avatar, 9999)
    AddStroke(Avatar)
    
    Create("TextLabel", {
        Size = UDim2.new(0, 61, 0, 40),
        Position = UDim2.new(0.41, 0, 0.15, 0),
        BackgroundTransparency = 1,
        Text = "Welcome,\n" .. LocalPlayer.Name,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    }, PlayerInfoFrame)

    task.spawn(function()
        local success, content = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if success and content then Avatar.Image = content end
    end)

    -- PageFrame (Рабочая область)
    local PageFrame = Create("Frame", {
        Name = "PageFrame",
        Size = UDim2.new(0, 429, 0, 307),
        Position = UDim2.new(0.218, 0, 0.12, 0),
        BackgroundColor3 = Theme.TopBarBg,
        BackgroundTransparency = Theme.TopBarTrans,
        BorderSizePixel = 0
    }, MainFrame)
    AddCorner(PageFrame)
    AddStroke(PageFrame)

    -- Логика сворачивания / закрытия
    MinBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        OpenFrame.Visible = true
    end)
    
    OpenBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        OpenFrame.Visible = false
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        if NotifGui then NotifGui:Destroy() end
        for _, conn in pairs(Library.Connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
    end)

    local WindowObj = { Tabs = {}, CurrentTab = nil }

    -- ========================================================================
    -- ЛОГИКА СОЗДАНИЯ ВКЛАДОК
    -- ========================================================================
    function WindowObj:CreateTab(name)
        if #WindowObj.Tabs >= 8 then
            Library:Notify("Ошибка", "Достигнут лимит вкладок (максимум 8).", 3)
            return nil
        end

        local TabBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 31),
            BackgroundColor3 = Theme.ElementBg,
            BackgroundTransparency = Theme.ElementTrans,
            Text = "  " .. name,
            TextColor3 = Theme.TextDim,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        }, TabList)
        AddCorner(TabBtn)
        AddStroke(TabBtn)

        -- Линия подсветки (активная вкладка)
        local Line = Create("Frame", {
            Size = UDim2.new(0, 3, 1, 0),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Visible = false
        }, TabBtn)

        -- Контейнер контента
        local Page = Create("ScrollingFrame", {
            Size = UDim2.new(1, -10, 1, -10),
            Position = UDim2.new(0, 5, 0, 5),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Stroke,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        }, PageFrame)
        
        local PageLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6)
        }, Page)
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)

        local tabObj = { Button = TabBtn, Page = Page, Line = Line }

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(WindowObj.Tabs) do
                t.Page.Visible = false
                t.Line.Visible = false
                t.Button.TextColor3 = Theme.TextDim
                t.Button.BackgroundTransparency = Theme.ElementTrans
            end
            Page.Visible = true
            Line.Visible = true
            TabBtn.TextColor3 = Theme.Text
            TabBtn.BackgroundTransparency = 0.3
            WindowObj.CurrentTab = tabObj
        end)

        table.insert(WindowObj.Tabs, tabObj)
        
        if #WindowObj.Tabs == 1 then
            task.defer(function() TabBtn:Fire("MouseButton1Click") end)
        end

        return tabObj
    end

    -- ========================================================================
    -- БАЗОВЫЙ КОНТЕЙНЕР ДЛЯ ЭЛЕМЕНТОВ
    -- ========================================================================
    local function CreateBase(parent, height, text)
        local f = Create("Frame", {
            Size = UDim2.new(1, 0, 0, height),
            BackgroundColor3 = Theme.ElementBg,
            BackgroundTransparency = Theme.ElementTrans,
            BorderSizePixel = 0
        }, parent)
        AddCorner(f)
        AddStroke(f)
        
        if text then
            Create("TextLabel", {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            }, f)
        end
        return f
    end

    -- ========================================================================
    -- ЭЛЕМЕНТЫ ИНТЕРФЕЙСА
    -- ========================================================================

    -- 1. Label (Текст)
    function WindowObj:CreateLabel(parent, text)
        local f = CreateBase(parent.Page, 25, text)
        f.BackgroundTransparency = 1
        for _, child in pairs(f:GetChildren()) do
            if child:IsA("UIStroke") then child:Destroy() end
        end
    end

    -- 2. Button (Кнопка)
    function WindowObj:CreateButton(parent, text, callback)
        local f = CreateBase(parent.Page, 35, "")
        local btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 14
        }, f)
        btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
    end

    -- 3. Toggle (Тумблер)
    function WindowObj:CreateToggle(parent, text, flag, default, callback)
        local f = CreateBase(parent.Page, 35, text)
        local bg = Create("Frame", {
            Size = UDim2.new(0, 40, 0, 20),
            Position = UDim2.new(1, -50, 0.5, -10),
            BackgroundColor3 = Theme.MainBg,
            BorderSizePixel = 0
        }, f)
        AddCorner(bg, 10)
        AddStroke(bg)
        
        local circle = Create("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = Theme.TextDim,
            BorderSizePixel = 0
        }, bg)
        AddCorner(circle, 10)

        local toggled = default or false
        Library.Flags[flag] = toggled
        
        local function update()
            if toggled then
                Tween(circle, 0.1, { Position = UDim2.new(0, 22, 0.5, -8) })
                circle.BackgroundColor3 = Theme.Accent
            else
                Tween(circle, 0.1, { Position = UDim2.new(0, 2, 0.5, -8) })
                circle.BackgroundColor3 = Theme.TextDim
            end
        end
        update()

        Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = ""
        }, f).MouseButton1Click:Connect(function()
            toggled = not toggled
            Library.Flags[flag] = toggled
            update()
            if callback then callback(toggled) end
        end)
        
        return { Set = function(v) toggled = v; Library.Flags[flag] = v; update() end }
    end

    -- 4. Slider (Ползунок)
    function WindowObj:CreateSlider(parent, text, flag, min, max, default, callback)
        local f = CreateBase(parent.Page, 45, text)
        
        local valLabel = Create("TextLabel", {
            Size = UDim2.new(0, 50, 0, 20),
            Position = UDim2.new(1, -60, 0, 5),
            BackgroundTransparency = 1,
            Text = tostring(default),
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right
        }, f)
        
        local bg = Create("Frame", {
            Size = UDim2.new(1, -20, 0, 6),
            Position = UDim2.new(0, 10, 0, 28),
            BackgroundColor3 = Theme.MainBg,
            BorderSizePixel = 0
        }, f)
        AddCorner(bg, 3)
        AddStroke(bg)
        
        local fill = Create("Frame", {
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0
        }, bg)
        AddCorner(fill, 3)
        
        local circle = Create("Frame", {
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0, 0, 0.5, -7),
            BackgroundColor3 = Theme.Text,
            BorderSizePixel = 0
        }, bg)
        AddCorner(circle, 10)
        AddStroke(circle)

        local value = default or min
        Library.Flags[flag] = value
        
        local function updateValue(val)
            value = math.clamp(val, min, max)
            Library.Flags[flag] = value
            valLabel.Text = tostring(math.floor(value))
            
            local percent = (value - min) / (max - min)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            circle.Position = UDim2.new(percent, -7, 0.5, -7)
            
            if callback then callback(value) end
        end
        updateValue(value)

        local dragging = false
        Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = ""
        }, bg).MouseButton1Down:Connect(function() dragging = true end)
        
        local inputEndConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        table.insert(Library.Connections, inputEndConn)
        
        local renderConn = RunService.RenderStepped:Connect(function()
            if dragging then
                local pos = math.clamp((Mouse.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                updateValue(min + (max - min) * pos)
            end
        end)
        table.insert(Library.Connections, renderConn)

        return { Set = function(v) updateValue(v) end }
    end

    -- 5. Dropdown (Выпадающий список)
    function WindowObj:CreateDropdown(parent, text, flag, options, default, callback)
        local f = CreateBase(parent.Page, 35, text)
        
        local btn = Create("TextButton", {
            Size = UDim2.new(0, 100, 0, 20),
            Position = UDim2.new(1, -110, 0.5, -10),
            BackgroundColor3 = Theme.MainBg,
            Text = default or "Select",
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 12
        }, f)
        AddCorner(btn)
        AddStroke(btn)
        
        local list = Create("ScrollingFrame", {
            Size = UDim2.new(0, 100, 0, 0),
            Position = UDim2.new(1, -110, 1, 2),
            BackgroundColor3 = Theme.TopBarBg,
            Visible = false,
            ZIndex = 10,
            ScrollBarThickness = 2
        }, f)
        AddCorner(list)
        AddStroke(list)
        
        local layout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder
        }, list)

        Library.Flags[flag] = default or options[1]

        for _, opt in pairs(options) do
            local optBtn = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundColor3 = Theme.TopBarBg,
                Text = tostring(opt),
                TextColor3 = Theme.TextDim,
                Font = Enum.Font.Gotham,
                TextSize = 12
            }, list)
            optBtn.MouseButton1Click:Connect(function()
                Library.Flags[flag] = opt
                btn.Text = tostring(opt)
                list.Visible = false
                list.Size = UDim2.new(0, 100, 0, 0)
                if callback then callback(opt) end
            end)
        end
        list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 4)

        btn.MouseButton1Click:Connect(function()
            list.Visible = not list.Visible
            if list.Visible then
                Tween(list, 0.2, { Size = UDim2.new(0, 100, 0, math.min(#options * 20 + 4, 100)) })
            else
                Tween(list, 0.2, { Size = UDim2.new(0, 100, 0, 0) })
            end
        end)
    end

    -- 6. Keybind (Бинд клавиши)
    function WindowObj:CreateKeybind(parent, text, flag, default, callback)
        local f = CreateBase(parent.Page, 35, text)
        
        local btn = Create("TextButton", {
            Size = UDim2.new(0, 80, 0, 20),
            Position = UDim2.new(1, -90, 0.5, -10),
            BackgroundColor3 = Theme.MainBg,
            Text = tostring(default) or "None",
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 12
        }, f)
        AddCorner(btn)
        AddStroke(btn)
        
        local currentKey = default
        Library.Flags[flag] = currentKey
        local isBinding = false
        
        btn.MouseButton1Click:Connect(function()
            isBinding = true
            btn.Text = "..."
        end)

        local inputConn = UserInputService.InputBegan:Connect(function(input)
            if isBinding then
                if input.KeyCode ~= Enum.KeyCode.Unknown then
                    currentKey = input.KeyCode
                    Library.Flags[flag] = currentKey
                    btn.Text = currentKey.Name
                    isBinding = false
                    if callback then callback(currentKey) end
                end
            elseif input.KeyCode == currentKey and currentKey then
                if callback then callback(currentKey) end
            end
        end)
        table.insert(Library.Connections, inputConn)
    end

    -- 7. TextBox (Поле ввода)
    function WindowObj:CreateTextBox(parent, text, flag, default, callback)
        local f = CreateBase(parent.Page, 35, text)
        
        local box = Create("TextBox", {
            Size = UDim2.new(0, 150, 0, 20),
            Position = UDim2.new(1, -160, 0.5, -10),
            BackgroundColor3 = Theme.MainBg,
            Text = default or "",
            PlaceholderText = "Введите...",
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            ClearTextOnFocus = false
        }, f)
        AddCorner(box)
        AddStroke(box)
        
        Library.Flags[flag] = default or ""
        
        box.FocusLost:Connect(function()
            Library.Flags[flag] = box.Text
            if callback then callback(box.Text) end
        end)
    end

    -- 8. ColorPicker (Выбор цвета)
    function WindowObj:CreateColorPicker(parent, text, flag, default, callback)
        local f = CreateBase(parent.Page, 35, text)
        
        local btn = Create("TextButton", {
            Size = UDim2.new(0, 50, 0, 20),
            Position = UDim2.new(1, -60, 0.5, -10),
            BackgroundColor3 = default or Color3.new(1,1,1),
            Text = "",
            TextColor3 = Theme.Text
        }, f)
        AddCorner(btn)
        AddStroke(btn)
        
        Library.Flags[flag] = default or Color3.new(1,1,1)

        local pickerFrame = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 100),
            BackgroundColor3 = Theme.MainBg,
            Visible = false,
            ZIndex = 10,
            BorderSizePixel = 0
        }, f)
        AddCorner(pickerFrame)
        AddStroke(pickerFrame)

        -- Hue полоса
        local hueBar = Create("Frame", {
            Size = UDim2.new(1, -20, 0, 15),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundColor3 = Color3.new(1,0,0),
            BorderSizePixel = 0
        }, pickerFrame)
        AddCorner(hueBar)
        
        Create("UIGradient", {
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.new(1,0,0)),
                ColorSequenceKeypoint.new(0.16, Color3.new(1,1,0)),
                ColorSequenceKeypoint.new(0.33, Color3.new(0,1,0)),
                ColorSequenceKeypoint.new(0.5, Color3.new(0,1,1)),
                ColorSequenceKeypoint.new(0.66, Color3.new(0,0,1)),
                ColorSequenceKeypoint.new(0.83, Color3.new(1,0,1)),
                ColorSequenceKeypoint.new(1, Color3.new(1,0,0))
            }
        }, hueBar)

        local hueCircle = Create("Frame", {
            Size = UDim2.new(0, 10, 0, 20),
            Position = UDim2.new(0, 0, 0.5, -10),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0
        }, hueBar)
        AddCorner(hueCircle)

        -- Saturation/Value квадрат
        local svFrame = Create("Frame", {
            Size = UDim2.new(1, -20, 0, 50),
            Position = UDim2.new(0, 10, 0, 35),
            BackgroundColor3 = Color3.new(1,0,0),
            BorderSizePixel = 0
        }, pickerFrame)
        AddCorner(svFrame)
        
        Create("UIGradient", {
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                ColorSequenceKeypoint.new(1, Color3.new(1,0,0))
            },
            Rotation = 0
        }, svFrame)
        
        Create("UIGradient", {
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
                ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
            },
            Rotation = 90
        }, svFrame)
        
        local svCircle = Create("Frame", {
            Size = UDim2.new(0, 10, 0, 10),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0
        }, svFrame)
        AddCorner(svCircle, 10)

        local function updateColor()
            local h = hueCircle.Position.X.Scale
            local s = svCircle.Position.X.Scale
            local v = 1 - svCircle.Position.Y.Scale
            
            local color = Color3.fromHSV(h, s, v)
            btn.BackgroundColor3 = color
            Library.Flags[flag] = color
            if callback then callback(color) end
        end

        -- Hue Drag
        local hueDrag = false
        Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = ""
        }, hueBar).MouseButton1Down:Connect(function() hueDrag = true end)
        
        local hueEnd = UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = false end
        end)
        table.insert(Library.Connections, hueEnd)
        
        local hueRender = RunService.RenderStepped:Connect(function()
            if hueDrag then
                local p = math.clamp((Mouse.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                hueCircle.Position = UDim2.new(p, 0, 0.5, -10)
                updateColor()
            end
        end)
        table.insert(Library.Connections, hueRender)

        -- SV Drag
        local svDrag = false
        Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = ""
        }, svFrame).MouseButton1Down:Connect(function() svDrag = true end)
        
        local svEnd = UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then svDrag = false end
        end)
        table.insert(Library.Connections, svEnd)
        
        local svRender = RunService.RenderStepped:Connect(function()
            if svDrag then
                local x = math.clamp((Mouse.X - svFrame.AbsolutePosition.X) / svFrame.AbsoluteSize.X, 0, 1)
                local y = math.clamp((Mouse.Y - svFrame.AbsolutePosition.Y) / svFrame.AbsoluteSize.Y, 0, 1)
                svCircle.Position = UDim2.new(x, -5, y, -5)
                updateColor()
            end
        end)
        table.insert(Library.Connections, svRender)

        btn.MouseButton1Click:Connect(function()
            pickerFrame.Visible = not pickerFrame.Visible
            if pickerFrame.Visible then
                f.Size = UDim2.new(1, 0, 0, 135)
            else
                f.Size = UDim2.new(1, 0, 0, 35)
            end
        end)
    end

    return WindowObj
end

-- ============================================================================
-- СИСТЕМА КОНФИГОВ (СОХРАНЕНИЕ / ЗАГРУЗКА)
-- ============================================================================
function Library:SaveConfig(name)
    if not writefile then
        Library:Notify("Ошибка", "Executor doesn't support writefile", 3)
        return
    end
    
    if not isfolder(Library.ConfigFolder) then
        makefolder(Library.ConfigFolder)
    end
    
    local serializedFlags = {}
    for flag, value in pairs(Library.Flags) do
        if typeof(value) == "Color3" then
            serializedFlags[flag] = { Type = "Color3", R = value.R, G = value.G, B = value.B }
        elseif typeof(value) == "EnumItem" then
            serializedFlags[flag] = { Type = "EnumItem", Value = value.Name }
        else
            serializedFlags[flag] = value
        end
    end
    
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(serializedFlags)
    end)
    
    if success then
        writefile(Library.ConfigFolder .. "/" .. name .. ".json", encoded)
        Library:Notify("Успех", "Конфиг '" .. name .. "' сохранен!", 3)
    else
        Library:Notify("Ошибка", "Не удалось сохранить конфиг", 3)
    end
end

function Library:LoadConfig(name)
    if not readfile then
        Library:Notify("Ошибка", "Executor doesn't support readfile", 3)
        return
    end
    
    local path = Library.ConfigFolder .. "/" .. name .. ".json"
    if isfile(path) then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        
        if success then
            for flag, value in pairs(decoded) do
                if type(value) == "table" and value.Type == "Color3" then
                    Library.Flags[flag] = Color3.new(value.R, value.G, value.B)
                elseif type(value) == "table" and value.Type == "EnumItem" then
                    Library.Flags[flag] = Enum.KeyCode[value.Value]
                else
                    Library.Flags[flag] = value
                end
            end
            Library:Notify("Успех", "Конфиг '" .. name .. "' загружен!", 3)
        else
            Library:Notify("Ошибка", "Файл конфига поврежден", 3)
        end
    else
        Library:Notify("Ошибка", "Конфиг не найден", 3)
    end
end

function Library:DeleteConfig(name)
    if not delfile then
        Library:Notify("Ошибка", "delfile не поддерживается", 3)
        return
    end
    
    local path = Library.ConfigFolder .. "/" .. name .. ".json"
    if isfile(path) then
        delfile(path)
        Library:Notify("Успех", "Конфиг '" .. name .. "' удален!", 3)
    else
        Library:Notify("Ошибка", "Конфиг не найден", 3)
    end
end

function Library:GetConfigs()
    if not listfiles then return {} end
    local files = listfiles(Library.ConfigFolder)
    local configs = {}
    
    for _, file in pairs(files) do
        local name = file:match("([^/]+)%.json$")
        if name then
            table.insert(configs, name)
        end
    end
    
    return configs
end

-- ============================================================================
-- АВТОМАТИЧЕСКИЙ КОНСТРУКТОР ВКЛАДКИ КОНФИГОВ
-- ============================================================================
function Library:BuildConfigTab(window)
    local ConfigTab = window:CreateTab("Configs")
    if not ConfigTab then return end
    
    local currentConfig = "default"
    
    ConfigTab:CreateTextBox(ConfigTab, "Имя конфига", "ConfigNameBox", "default", function(text)
        currentConfig = text
    end)

    ConfigTab:CreateButton(ConfigTab, "Сохранить конфиг", function()
        Library:SaveConfig(currentConfig)
    end)

    ConfigTab:CreateButton(ConfigTab, "Загрузить конфиг", function()
        Library:LoadConfig(currentConfig)
    end)

    ConfigTab:CreateButton(ConfigTab, "Удалить конфиг", function()
        Library:DeleteConfig(currentConfig)
    end)
end

-- ============================================================================
-- ВОЗВРАЩАЕМ БИБЛИОТЕКУ
-- ============================================================================
return Library
