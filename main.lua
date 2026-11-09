--[[
================================================================================
    DeepSeek V4.1-Flash UI Library
    Version: 6.0.0 (True Monolith - Auto Loaded UI)
    Author: WareSploit & DeepSeek
    Description: Complete, standalone library. Populates UI on execution.
                 No Color Picker. Icons restored. Strictly English UI.
================================================================================
]]

-- ============================================================================
-- SERVICES
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
-- LIBRARY VARIABLES
-- ============================================================================
local Library = {}
Library.Flags = {}
Library.ConfigFolder = "DeepSeek_Configs"
Library.Connections = {}

-- ============================================================================
-- THEME / COLORS
-- ============================================================================
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
    Accent = Color3.fromRGB(0, 150, 255)
}

-- ============================================================================
-- UTILITY FUNCTIONS
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
    local stroke = Create("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, obj)
    
    return stroke
end

local function AddCorner(obj, radius)
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 4)
    }, obj)
    
    return corner
end

local function AddGradient(obj)
    local gradient = Create("UIGradient", {
        Rotation = 123,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(4, 42, 87)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
        }
    }, obj)
    
    return gradient
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

local function MakeDraggable(frame, dragArea)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
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
-- NOTIFICATIONS SYSTEM
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
-- CORE WINDOW CREATION
-- ============================================================================
function Library:CreateWindow(title)
    local ScreenGui = Create("ScreenGui", {
        Name = "DeepSeekUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, LocalPlayer:WaitForChild("PlayerGui"))

    -- ------------------------------------------------------------------------
    -- OPEN FRAME (Minimized state)
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

    -- ✅ RESTORED ICON (OpenFrame)
    local OpenIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 42, 0, 41),
        Position = UDim2.new(0.86, 0, 0.06, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://121267808310974",
        BorderSizePixel = 0
    }, OpenFrame)
    
    AddCorner(OpenIcon)
    AddGradient(OpenIcon)

    -- ------------------------------------------------------------------------
    -- MAIN FRAME
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

    -- ------------------------------------------------------------------------
    -- TOP BAR
    -- ------------------------------------------------------------------------
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

    -- ✅ RESTORED ICON (TopBar)
    local TopBarIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 42, 0, 41),
        Position = UDim2.new(0.015, 0, 0, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://121267808310974",
        BorderSizePixel = 0
    }, TopBar)
    
    AddCorner(TopBarIcon)
    AddGradient(TopBarIcon)

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

    local ExecName = "Studio"
    if identifyexecutor then
        local success, name = pcall(identifyexecutor)
        if success then 
            ExecName = name 
        end
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

    local PlayerCountLabel = Create("TextLabel", {
        Size = UDim2.new(0, 93, 0, 34),
        Position = UDim2.new(0.67, 0, 0.09, 0),
        BackgroundTransparency = 1,
        Text = "Players: " .. #Players:GetPlayers(),
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14
    }, TopBar)

    table.insert(Library.Connections, Players.PlayerAdded:Connect(function() 
        PlayerCountLabel.Text = "Players: " .. #Players:GetPlayers() 
    end))
    
    table.insert(Library.Connections, Players.PlayerRemoving:Connect(function() 
        PlayerCountLabel.Text = "Players: " .. #Players:GetPlayers() 
    end))

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

    -- ------------------------------------------------------------------------
    -- SIDEBAR
    -- ------------------------------------------------------------------------
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

    -- Player Info
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
        
        if success and content then 
            Avatar.Image = content 
        end
    end)

    -- ------------------------------------------------------------------------
    -- PAGE FRAME (Content Area)
    -- ------------------------------------------------------------------------
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
        if NotifGui then 
            NotifGui:Destroy() 
        end
        
        for _, conn in pairs(Library.Connections) do
            if typeof(conn) == "RBXScriptConnection" then 
                conn:Disconnect() 
            end
        end
    end)

    local WindowObj = { Tabs = {}, CurrentTab = nil }

    -- ========================================================================
    -- CREATE TAB FUNCTION
    -- ========================================================================
    function WindowObj:CreateTab(name)
        if #WindowObj.Tabs >= 8 then
            Library:Notify("Error", "Max 8 tabs reached.", 3)
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

        local Line = Create("Frame", {
            Size = UDim2.new(0, 3, 1, 0),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Visible = false
        }, TabBtn)

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
            task.defer(function() 
                TabBtn:Fire("MouseButton1Click") 
            end) 
        end

        return tabObj
    end

    -- ========================================================================
    -- BASE ELEMENT CONTAINER
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
    -- UI ELEMENTS FUNCTIONS
    -- ========================================================================
    
    -- 1. Label
    function WindowObj:CreateLabel(parent, text)
        local f = CreateBase(parent.Page, 25, text)
        f.BackgroundTransparency = 1
        
        for _, child in pairs(f:GetChildren()) do 
            if child:IsA("UIStroke") then 
                child:Destroy() 
            end 
        end
    end

    -- 2. Button
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
            if callback then 
                callback() 
            end
        end)
    end

    -- 3. Toggle
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

        local btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = ""
        }, f)
        
        btn.MouseButton1Click:Connect(function()
            toggled = not toggled
            Library.Flags[flag] = toggled
            update()
            
            if callback then 
                callback(toggled) 
            end
        end)
        
        return { Set = function(v) toggled = v; Library.Flags[flag] = v; update() end }
    end

    -- 4. Slider
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
            
            if callback then 
                callback(value) 
            end
        end
        
        updateValue(value)

        local dragging = false
        
        local btn = Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = ""
        }, bg)
        
        btn.MouseButton1Down:Connect(function() 
            dragging = true 
        end)
        
        table.insert(Library.Connections, UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then 
                dragging = false 
            end
        end))
        
        table.insert(Library.Connections, RunService.RenderStepped:Connect(function()
            if dragging then
                local pos = math.clamp((Mouse.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                updateValue(min + (max - min) * pos)
            end
        end))
        
        return { Set = function(v) updateValue(v) end }
    end

    -- 5. Dropdown
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
                
                if callback then 
                    callback(opt) 
                end
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

    -- 6. Keybind
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

        table.insert(Library.Connections, UserInputService.InputBegan:Connect(function(input)
            if isBinding then
                if input.KeyCode ~= Enum.KeyCode.Unknown then
                    currentKey = input.KeyCode
                    Library.Flags[flag] = currentKey
                    btn.Text = currentKey.Name
                    isBinding = false
                    
                    if callback then 
                        callback(currentKey) 
                    end
                end
            elseif input.KeyCode == currentKey and currentKey then
                if callback then 
                    callback(currentKey) 
                end
            end
        end))
    end

    -- 7. TextBox
    function WindowObj:CreateTextBox(parent, text, flag, default, callback)
        local f = CreateBase(parent.Page, 35, text)
        
        local box = Create("TextBox", {
            Size = UDim2.new(0, 150, 0, 20),
            Position = UDim2.new(1, -160, 0.5, -10),
            BackgroundColor3 = Theme.MainBg,
            Text = default or "",
            PlaceholderText = "Enter text...",
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
            
            if callback then 
                callback(box.Text) 
            end
        end)
    end

    return WindowObj
end

-- ============================================================================
-- CONFIGS SYSTEM
-- ============================================================================
function Library:SaveConfig(name)
    if not writefile then 
        Library:Notify("Error", "Executor does not support writefile", 3)
        return 
    end
    
    if not isfolder(Library.ConfigFolder) then 
        makefolder(Library.ConfigFolder) 
    end
    
    local serialized = {}
    
    for flag, value in pairs(Library.Flags) do
        if typeof(value) == "EnumItem" then 
            serialized[flag] = { Type = "EnumItem", Value = value.Name } 
        else 
            serialized[flag] = value 
        end
    end
    
    local success, encoded = pcall(function() 
        return HttpService:JSONEncode(serialized) 
    end)
    
    if success then 
        writefile(Library.ConfigFolder .. "/" .. name .. ".json", encoded)
        Library:Notify("Success", "Config '" .. name .. "' saved!", 3)
    else 
        Library:Notify("Error", "Failed to save config", 3) 
    end
end

function Library:LoadConfig(name)
    if not readfile then 
        Library:Notify("Error", "Executor does not support readfile", 3)
        return 
    end
    
    local path = Library.ConfigFolder .. "/" .. name .. ".json"
    
    if isfile(path) then
        local success, decoded = pcall(function() 
            return HttpService:JSONDecode(readfile(path)) 
        end)
        
        if success then
            for flag, value in pairs(decoded) do
                if type(value) == "table" and value.Type == "EnumItem" then 
                    Library.Flags[flag] = Enum.KeyCode[value.Value] 
                else 
                    Library.Flags[flag] = value 
                end
            end
            
            Library:Notify("Success", "Config '" .. name .. "' loaded!", 3)
        else 
            Library:Notify("Error", "Config file is corrupted", 3) 
        end
    else 
        Library:Notify("Error", "Config not found", 3) 
    end
end

function Library:DeleteConfig(name)
    if not delfile then 
        return 
    end
    
    local path = Library.ConfigFolder .. "/" .. name .. ".json"
    
    if isfile(path) then 
        delfile(path)
        Library:Notify("Success", "Config '" .. name .. "' deleted!", 3) 
    end
end

function Library:BuildConfigTab(window)
    local ConfigTab = window:CreateTab("Configs")
    
    if not ConfigTab then 
        return 
    end
    
    local currentConfig = "default"
    
    ConfigTab:CreateTextBox(ConfigTab, "Config Name", "ConfigNameBox", "default", function(text) 
        currentConfig = text 
    end)
    
    ConfigTab:CreateButton(ConfigTab, "Save Config", function() 
        Library:SaveConfig(currentConfig) 
    end)
    
    ConfigTab:CreateButton(ConfigTab, "Load Config", function() 
        Library:LoadConfig(currentConfig) 
    end)
    
    ConfigTab:CreateButton(ConfigTab, "Delete Config", function() 
        Library:DeleteConfig(currentConfig) 
    end)
end

-- ============================================================================
-- AUTO-LOAD UI ELEMENTS (NO EXTERNAL EXAMPLE NEEDED)
-- ============================================================================
local Window = Library:CreateWindow("DeepSeek V4.1-Flash")

-- Create Tabs
local MainTab = Window:CreateTab("Main")
local MiscTab = Window:CreateTab("Misc")

-- Populate Main Tab
MainTab:CreateLabel(MainTab, "=== Main Functions ===")

MainTab:CreateToggle(MainTab, "Auto Farm", "AutoFarm", false, function(state)
    print("Auto Farm Toggled:", state)
end)

MainTab:CreateSlider(MainTab, "Walk Speed", "WalkSpeed", 16, 200, 16, function(val)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)

MainTab:CreateDropdown(MainTab, "Select Mode", "Mode", {"Legit", "Rage", "Silent"}, "Legit", function(opt)
    print("Mode Changed To:", opt)
end)

MainTab:CreateKeybind(MainTab, "Toggle ESP", "EspKey", Enum.KeyCode.RightShift, function(key)
    Library:Notify("Keybind", "Pressed: " .. key.Name, 2)
end)

-- Populate Misc Tab
MiscTab:CreateLabel(MiscTab, "=== Misc Functions ===")

MiscTab:CreateTextBox(MiscTab, "Custom Text", "TextBoxFlag", "Hello", function(text)
    print("Saved text:", text)
end)

MiscTab:CreateButton(MiscTab, "Click Me", function()
    Library:Notify("Button", "Button clicked successfully!", 3)
end)

-- Add Configs Tab
Library:BuildConfigTab(Window)

-- Startup Notification
Library:Notify("Loaded", "DeepSeek UI is ready!", 5)

return Library
