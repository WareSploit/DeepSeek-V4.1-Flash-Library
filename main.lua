--[[
================================================================================
    DeepSeek V4.1-Flash UI Library
    Version: 10.0.0 (Full Uncompressed Engine)
    Author: WareSploit & DeepSeek
    Description: Fully detailed UI engine with all visual elements, gradients,
                 strokes, and animations expanded line-by-line.
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
-- ПЕРЕМЕННЫЕ БИБЛИОТЕКИ
-- ============================================================================
local Library = {}
Library.Flags = {}
Library.ConfigFolder = "DeepSeek_Configs"
Library.Connections = {}

-- ============================================================================
-- ЦВЕТОВАЯ ПАЛИТРА
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
-- УТИЛИТА: СОЗДАНИЕ ОБЪЕКТА
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

-- ============================================================================
-- УТИЛИТА: ДОБАВЛЕНИЕ UIStroke
-- ============================================================================
local function AddStroke(obj, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Stroke
    stroke.Thickness = thickness or 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = obj
    return stroke
end

-- ============================================================================
-- УТИЛИТА: ДОБАВЛЕНИЕ UICorner
-- ============================================================================
local function AddCorner(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 4)
    corner.Parent = obj
    return corner
end

-- ============================================================================
-- УТИЛИТА: ДОБАВЛЕНИЕ UIGradient
-- ============================================================================
local function AddGradient(obj)
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 123
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(4, 42, 87)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    }
    gradient.Parent = obj
    return gradient
end

-- ============================================================================
-- УТИЛИТА: TWEEN АНИМАЦИЯ
-- ============================================================================
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
-- УТИЛИТА: ПЕРЕТАСКИВАНИЕ (DRAG)
-- ============================================================================
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
-- СИСТЕМА УВЕДОМЛЕНИЙ
-- ============================================================================
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "DeepSeekNotifications"
NotifGui.ResetOnSpawn = false
NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotifGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local NotifFrame = Instance.new("Frame")
NotifFrame.Size = UDim2.new(0, 250, 1, -20)
NotifFrame.Position = UDim2.new(1, -260, 0, 10)
NotifFrame.BackgroundTransparency = 1
NotifFrame.Parent = NotifGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.Parent = NotifFrame

function Library:Notify(title, text, duration)
    duration = duration or 3
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 60)
    notif.BackgroundColor3 = Theme.MainBg
    notif.BackgroundTransparency = 0.1
    notif.BorderSizePixel = 0
    notif.Position = UDim2.new(1, 260, 0, 0)
    notif.Parent = NotifFrame
    
    AddCorner(notif)
    AddStroke(notif)
    AddGradient(notif)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 0, 20)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notif

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 0, 30)
    textLabel.Position = UDim2.new(0, 5, 0, 25)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Theme.TextDim
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 12
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = notif

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
    -- Основной ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DeepSeekUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- ------------------------------------------------------------------------
    -- OPEN FRAME (Свернутое состояние)
    -- ------------------------------------------------------------------------
    local OpenFrame = Instance.new("Frame")
    OpenFrame.Name = "OpenFrame"
    OpenFrame.Size = UDim2.new(0, 304, 0, 47)
    OpenFrame.Position = UDim2.new(0.5, -152, 0, 10)
    OpenFrame.BackgroundColor3 = Theme.MainBg
    OpenFrame.BackgroundTransparency = Theme.MainBgTrans
    OpenFrame.BorderSizePixel = 0
    OpenFrame.Visible = false
    OpenFrame.ZIndex = 10
    OpenFrame.Parent = ScreenGui
    
    AddCorner(OpenFrame)
    AddStroke(OpenFrame)
    AddGradient(OpenFrame)
    MakeDraggable(OpenFrame, OpenFrame)

    local OpenTitle = Instance.new("TextLabel")
    OpenTitle.Size = UDim2.new(0, 185, 0, 42)
    OpenTitle.Position = UDim2.new(0.19, 0, 0, 0)
    OpenTitle.BackgroundTransparency = 1
    OpenTitle.Text = title
    OpenTitle.TextColor3 = Theme.Text
    OpenTitle.Font = Enum.Font.Gotham
    OpenTitle.TextSize = 18
    OpenTitle.TextXAlignment = Enum.TextXAlignment.Left
    OpenTitle.Parent = OpenFrame

    local OpenBtn = Instance.new("TextButton")
    OpenBtn.Size = UDim2.new(0, 26, 0, 27)
    OpenBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
    OpenBtn.BackgroundColor3 = Theme.ElementBg
    OpenBtn.BackgroundTransparency = Theme.ElementTrans
    OpenBtn.Text = "+"
    OpenBtn.TextColor3 = Theme.Text
    OpenBtn.Font = Enum.Font.GothamBold
    OpenBtn.TextSize = 16
    OpenBtn.Parent = OpenFrame
    
    AddCorner(OpenBtn)
    AddStroke(OpenBtn)

    local OpenIcon = Instance.new("ImageLabel")
    OpenIcon.Size = UDim2.new(0, 42, 0, 41)
    OpenIcon.Position = UDim2.new(0.86, 0, 0.06, 0)
    OpenIcon.BackgroundTransparency = 1
    OpenIcon.Image = "rbxassetid://121267808310974"
    OpenIcon.BorderSizePixel = 0
    OpenIcon.Parent = OpenFrame
    
    AddCorner(OpenIcon)
    AddGradient(OpenIcon)

    -- ------------------------------------------------------------------------
    -- MAIN FRAME (Основное окно)
    -- ------------------------------------------------------------------------
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 349)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -174.5)
    MainFrame.BackgroundColor3 = Theme.MainBg
    MainFrame.BackgroundTransparency = Theme.MainBgTrans
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    AddCorner(MainFrame)
    AddStroke(MainFrame)
    AddGradient(MainFrame)

    -- ------------------------------------------------------------------------
    -- TOP BAR
    -- ------------------------------------------------------------------------
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 42)
    TopBar.BackgroundColor3 = Theme.TopBarBg
    TopBar.BackgroundTransparency = Theme.TopBarTrans
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 3
    TopBar.Parent = MainFrame
    
    AddCorner(TopBar)
    AddStroke(TopBar)
    MakeDraggable(MainFrame, TopBar)

    local TopBarIcon = Instance.new("ImageLabel")
    TopBarIcon.Size = UDim2.new(0, 42, 0, 41)
    TopBarIcon.Position = UDim2.new(0.015, 0, 0, 0)
    TopBarIcon.BackgroundTransparency = 1
    TopBarIcon.Image = "rbxassetid://121267808310974"
    TopBarIcon.BorderSizePixel = 0
    TopBarIcon.Parent = TopBar
    
    AddCorner(TopBarIcon)
    AddGradient(TopBarIcon)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 150, 1, 0)
    TitleLabel.Position = UDim2.new(0.12, 0, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.Font = Enum.Font.Gotham
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    local ExecName = "Studio"
    if identifyexecutor then
        local success, name = pcall(identifyexecutor)
        if success then 
            ExecName = name 
        end
    end

    local ExecLabel = Instance.new("TextLabel")
    ExecLabel.Size = UDim2.new(0, 100, 0, 34)
    ExecLabel.Position = UDim2.new(0.48, 0, 0.09, 0)
    ExecLabel.BackgroundTransparency = 1
    ExecLabel.Text = "Exec: " .. ExecName
    ExecLabel.TextColor3 = Theme.Text
    ExecLabel.Font = Enum.Font.Gotham
    ExecLabel.TextSize = 14
    ExecLabel.Parent = TopBar

    local PlayerCountLabel = Instance.new("TextLabel")
    PlayerCountLabel.Size = UDim2.new(0, 93, 0, 34)
    PlayerCountLabel.Position = UDim2.new(0.67, 0, 0.09, 0)
    PlayerCountLabel.BackgroundTransparency = 1
    PlayerCountLabel.Text = "Players: " .. #Players:GetPlayers()
    PlayerCountLabel.TextColor3 = Theme.Text
    PlayerCountLabel.Font = Enum.Font.Gotham
    PlayerCountLabel.TextSize = 14
    PlayerCountLabel.Parent = TopBar

    local pAddConn = Players.PlayerAdded:Connect(function() 
        PlayerCountLabel.Text = "Players: " .. #Players:GetPlayers() 
    end)
    table.insert(Library.Connections, pAddConn)
    
    local pRemConn = Players.PlayerRemoving:Connect(function() 
        PlayerCountLabel.Text = "Players: " .. #Players:GetPlayers() 
    end)
    table.insert(Library.Connections, pRemConn)

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 26, 0, 27)
    MinBtn.Position = UDim2.new(1, -65, 0.16, 0)
    MinBtn.BackgroundColor3 = Theme.ElementBg
    MinBtn.BackgroundTransparency = Theme.ElementTrans
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Theme.Text
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 16
    MinBtn.ZIndex = 4
    MinBtn.Parent = TopBar
    
    AddCorner(MinBtn)
    AddStroke(MinBtn)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 26, 0, 27)
    CloseBtn.Position = UDim2.new(1, -35, 0.16, 0)
    CloseBtn.BackgroundColor3 = Theme.ElementBg
    CloseBtn.BackgroundTransparency = Theme.ElementTrans
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Theme.Text
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.ZIndex = 4
    CloseBtn.Parent = TopBar
    
    AddCorner(CloseBtn)
    AddStroke(CloseBtn)

    -- ------------------------------------------------------------------------
    -- SIDEBAR
    -- ------------------------------------------------------------------------
    local SideBar = Instance.new("Frame")
    SideBar.Name = "SideBar"
    SideBar.Size = UDim2.new(0, 120, 0, 307)
    SideBar.Position = UDim2.new(0, 0, 0.12, 0)
    SideBar.BackgroundColor3 = Theme.TopBarBg
    SideBar.BackgroundTransparency = Theme.TopBarTrans
    SideBar.BorderSizePixel = 0
    SideBar.Parent = MainFrame
    
    AddCorner(SideBar)
    AddStroke(SideBar)

    local TabList = Instance.new("Frame")
    TabList.Size = UDim2.new(1, 0, 0, 250)
    TabList.BackgroundTransparency = 1
    TabList.Parent = SideBar
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.Parent = TabList

    -- Player Info
    local PlayerInfoFrame = Instance.new("Frame")
    PlayerInfoFrame.Size = UDim2.new(0, 120, 0, 58)
    PlayerInfoFrame.Position = UDim2.new(0, 0, 0.81, 0)
    PlayerInfoFrame.BackgroundColor3 = Theme.PlayerInfoBg
    PlayerInfoFrame.BackgroundTransparency = Theme.TopBarTrans
    PlayerInfoFrame.BorderSizePixel = 0
    PlayerInfoFrame.Parent = SideBar
    
    AddCorner(PlayerInfoFrame)
    AddStroke(PlayerInfoFrame)
    AddGradient(PlayerInfoFrame)

    local Avatar = Instance.new("ImageLabel")
    Avatar.Size = UDim2.new(0, 34, 0, 34)
    Avatar.Position = UDim2.new(0, 6, 0.5, -17)
    Avatar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    Avatar.BorderSizePixel = 0
    Avatar.Parent = PlayerInfoFrame
    
    AddCorner(Avatar, 9999)
    AddStroke(Avatar)
    
    local WelcomeText = Instance.new("TextLabel")
    WelcomeText.Size = UDim2.new(1, -47, 0, 42)
    WelcomeText.Position = UDim2.new(0, 44, 0.5, -21)
    WelcomeText.BackgroundTransparency = 1
    WelcomeText.Text = "Welcome,\n" .. LocalPlayer.DisplayName
    WelcomeText.TextColor3 = Theme.Text
    WelcomeText.Font = Enum.Font.Gotham
    WelcomeText.TextSize = 10
    WelcomeText.TextWrapped = false
    WelcomeText.TextTruncate = Enum.TextTruncate.AtEnd
    WelcomeText.TextXAlignment = Enum.TextXAlignment.Left
    WelcomeText.TextYAlignment = Enum.TextYAlignment.Center
    WelcomeText.Parent = PlayerInfoFrame

    task.spawn(function()
        local success, content = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        
        if success and content then 
            Avatar.Image = content 
        end
    end)

    -- ------------------------------------------------------------------------
    -- PAGE FRAME
    -- ------------------------------------------------------------------------
    local PageFrame = Instance.new("Frame")
    PageFrame.Name = "PageFrame"
    PageFrame.Size = UDim2.new(0, 429, 0, 307)
    PageFrame.Position = UDim2.new(0.218, 0, 0.12, 0)
    PageFrame.BackgroundColor3 = Theme.TopBarBg
    PageFrame.BackgroundTransparency = 0.18
    PageFrame.BorderSizePixel = 0
    PageFrame.ClipsDescendants = true
    PageFrame.Parent = MainFrame
    
    AddCorner(PageFrame)
    AddStroke(PageFrame)

    -- ------------------------------------------------------------------------
    -- ЛОГИКА КНОПОК ОКНА
    -- ------------------------------------------------------------------------
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
    -- ФУНКЦИЯ: СОЗДАНИЕ ВКЛАДКИ
    -- ========================================================================
    function WindowObj:CreateTab(name)
        if #WindowObj.Tabs >= 8 then
            Library:Notify("Error", "Max 8 tabs reached.", 3)
            return nil
        end

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 31)
        TabBtn.BackgroundColor3 = Theme.ElementBg
        TabBtn.BackgroundTransparency = Theme.ElementTrans
        TabBtn.Text = "  " .. name
        TabBtn.TextColor3 = Theme.TextDim
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.TextSize = 14
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Parent = TabList
        
        AddCorner(TabBtn)
        AddStroke(TabBtn)

        local Line = Instance.new("Frame")
        Line.Size = UDim2.new(0, 3, 1, 0)
        Line.BackgroundColor3 = Theme.Accent
        Line.BorderSizePixel = 0
        Line.Visible = false
        Line.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -10, 1, -10)
        Page.Position = UDim2.new(0, 5, 0, 5)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Theme.Stroke
        Page.Visible = false
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.None
        Page.Parent = PageFrame
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 6)
        PageLayout.Parent = Page
        
        local function UpdateCanvas()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 12)
        end

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
        UpdateCanvas()

        local tabObj = { Button = TabBtn, Page = Page, Line = Line }

        local function SelectTab()
            for _, t in ipairs(WindowObj.Tabs) do
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
        end

        tabObj.Select = SelectTab
        TabBtn.MouseButton1Click:Connect(SelectTab)
        table.insert(WindowObj.Tabs, tabObj)

        -- Select the first tab immediately. TextButton does not have :Fire().
        if #WindowObj.Tabs == 1 then
            SelectTab()
        end

        return tabObj
    end

    -- ========================================================================
    -- ФУНКЦИЯ: БАЗОВЫЙ КОНТЕЙНЕР ЭЛЕМЕНТА
    -- ========================================================================
    local function CreateBase(parent, height, text)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, height)
        f.BackgroundColor3 = Theme.ElementBg
        f.BackgroundTransparency = Theme.ElementTrans
        f.BorderSizePixel = 0
        f.Parent = parent
        
        AddCorner(f)
        AddStroke(f)
        
        if text then
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -20, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = Theme.Text
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = f
        end
        
        return f
    end

    -- ========================================================================
    -- ФУНКЦИЯ: LABEL
    -- ========================================================================
    function WindowObj:CreateLabel(parent, text)
        local f = CreateBase(parent.Page, 25, text)
        f.BackgroundTransparency = 1
        
        for _, child in pairs(f:GetChildren()) do 
            if child:IsA("UIStroke") then 
                child:Destroy() 
            end 
        end
    end

    -- ========================================================================
    -- ФУНКЦИЯ: BUTTON
    -- ========================================================================
    function WindowObj:CreateButton(parent, text, callback)
        local f = CreateBase(parent.Page, 35, "")
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = text
        btn.TextColor3 = Theme.Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Parent = f
        
        btn.MouseButton1Click:Connect(function()
            if callback then 
                callback() 
            end
        end)
    end

    -- ========================================================================
    -- ФУНКЦИЯ: TOGGLE
    -- ========================================================================
    function WindowObj:CreateToggle(parent, text, flag, default, callback)
        local f = CreateBase(parent.Page, 35, text)
        
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(0, 40, 0, 20)
        bg.Position = UDim2.new(1, -50, 0.5, -10)
        bg.BackgroundColor3 = Theme.MainBg
        bg.BorderSizePixel = 0
        bg.Parent = f
        
        AddCorner(bg, 10)
        AddStroke(bg)
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 16, 0, 16)
        circle.Position = UDim2.new(0, 2, 0.5, -8)
        circle.BackgroundColor3 = Theme.TextDim
        circle.BorderSizePixel = 0
        circle.Parent = bg
        
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

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = f
        
        btn.MouseButton1Click:Connect(function()
            toggled = not toggled
            Library.Flags[flag] = toggled
            update()
            
            if callback then 
                callback(toggled) 
            end
        end)
        
        return { 
            Set = function(v) 
                toggled = v
                Library.Flags[flag] = v
                update() 
            end 
        }
    end

    -- ========================================================================
    -- ФУНКЦИЯ: SLIDER
    -- ========================================================================
    function WindowObj:CreateSlider(parent, text, flag, min, max, default, callback)
        local f = CreateBase(parent.Page, 45, text)
        
        local valLabel = Instance.new("TextLabel")
        valLabel.Size = UDim2.new(0, 50, 0, 20)
        valLabel.Position = UDim2.new(1, -60, 0, 5)
        valLabel.BackgroundTransparency = 1
        valLabel.Text = tostring(default)
        valLabel.TextColor3 = Theme.Text
        valLabel.Font = Enum.Font.GothamBold
        valLabel.TextSize = 14
        valLabel.TextXAlignment = Enum.TextXAlignment.Right
        valLabel.Parent = f
        
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, -20, 0, 6)
        bg.Position = UDim2.new(0, 10, 0, 28)
        bg.BackgroundColor3 = Theme.MainBg
        bg.BorderSizePixel = 0
        bg.Parent = f
        
        AddCorner(bg, 3)
        AddStroke(bg)
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = Theme.Accent
        fill.BorderSizePixel = 0
        fill.Parent = bg
        
        AddCorner(fill, 3)
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 14, 0, 14)
        circle.Position = UDim2.new(0, 0, 0.5, -7)
        circle.BackgroundColor3 = Theme.Text
        circle.BorderSizePixel = 0
        circle.Parent = bg
        
        AddCorner(circle, 10)
        AddStroke(circle)

        local value = default or min
        Library.Flags[flag] = value
        
        local function updateValue(val)
            value = math.clamp(val, min, max)
            Library.Flags[flag] = value
            valLabel.Text = tostring(math.floor(value))
            
            local range = max - min
            local percent = range == 0 and 0 or (value - min) / range
            fill.Size = UDim2.new(percent, 0, 1, 0)
            circle.Position = UDim2.new(percent, -7, 0.5, -7)
            
            if callback then 
                callback(value) 
            end
        end
        
        updateValue(value)

        local dragging = false
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = bg
        
        btn.MouseButton1Down:Connect(function() 
            dragging = true 
        end)
        
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

    -- ========================================================================
    -- ФУНКЦИЯ: DROPDOWN
    -- ========================================================================
    function WindowObj:CreateDropdown(parent, text, flag, options, default, callback)
        local f = CreateBase(parent.Page, 35, text)
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 0, 20)
        btn.Position = UDim2.new(1, -110, 0.5, -10)
        btn.BackgroundColor3 = Theme.MainBg
        btn.Text = default or "Select"
        btn.TextColor3 = Theme.Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = f
        
        AddCorner(btn)
        AddStroke(btn)
        
        local list = Instance.new("ScrollingFrame")
        list.Size = UDim2.new(0, 100, 0, 0)
        list.Position = UDim2.new(1, -110, 1, 2)
        list.BackgroundColor3 = Theme.TopBarBg
        list.Visible = false
        list.ZIndex = 20
        list.ScrollBarThickness = 2
        list.BorderSizePixel = 0
        list.Parent = f
        
        AddCorner(list)
        AddStroke(list)
        
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = list

        Library.Flags[flag] = default or options[1]

        for _, opt in pairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 20)
            optBtn.BackgroundColor3 = Theme.TopBarBg
            optBtn.Text = tostring(opt)
            optBtn.TextColor3 = Theme.TextDim
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = 12
            optBtn.ZIndex = 21
            optBtn.BorderSizePixel = 0
            optBtn.Parent = list
            
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

    -- ========================================================================
    -- ФУНКЦИЯ: KEYBIND
    -- ========================================================================
    function WindowObj:CreateKeybind(parent, text, flag, default, callback)
        local f = CreateBase(parent.Page, 35, text)
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 80, 0, 20)
        btn.Position = UDim2.new(1, -90, 0.5, -10)
        btn.BackgroundColor3 = Theme.MainBg
        btn.Text = default and tostring(default) or "None"
        btn.TextColor3 = Theme.Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = f
        
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
                    
                    if callback then 
                        callback(currentKey) 
                    end
                end
            elseif input.KeyCode == currentKey and currentKey then
                if callback then 
                    callback(currentKey) 
                end
            end
        end)
        
        table.insert(Library.Connections, inputConn)
    end

    -- ========================================================================
    -- ФУНКЦИЯ: TEXTBOX
    -- ========================================================================
    function WindowObj:CreateTextBox(parent, text, flag, default, callback)
        local f = CreateBase(parent.Page, 35, text)
        
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0, 150, 0, 20)
        box.Position = UDim2.new(1, -160, 0.5, -10)
        box.BackgroundColor3 = Theme.MainBg
        box.Text = default or ""
        box.PlaceholderText = "Enter text..."
        box.TextColor3 = Theme.Text
        box.Font = Enum.Font.Gotham
        box.TextSize = 12
        box.ClearTextOnFocus = false
        box.Parent = f
        
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
-- СИСТЕМА КОНФИГОВ
-- ============================================================================
function Library:SaveConfig(name)
    if not writefile then 
        Library:Notify("Error", "No writefile support", 3)
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
        Library:Notify("Success", "Config saved!", 3)
    else 
        Library:Notify("Error", "Failed to save", 3) 
    end
end

function Library:LoadConfig(name)
    if not readfile then 
        Library:Notify("Error", "No readfile support", 3)
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
            
            Library:Notify("Success", "Config loaded!", 3)
        else 
            Library:Notify("Error", "File corrupted", 3) 
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
        Library:Notify("Success", "Config deleted!", 3) 
    end
end

return Library
