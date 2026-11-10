local Icons = {
    crosshairs = "rbxassetid://96677288280405",
    ghost      = "rbxassetid://95400397758754",
    mouse      = "rbxassetid://74350468513068",
    user       = "rbxassetid://97066657594742",
    pallet     = "rbxassetid://83365140694071",
    hammer     = "rbxassetid://118512898552101",
    code       = "rbxassetid://100793810819046",
    save       = "rbxassetid://136566823798983",
    feather    = "rbxassetid://130188814728078",
    crown      = "rbxassetid://73317911385704",
    dagger     = "rbxassetid://133081986539088",
    baby       = "rbxassetid://127135446273067",
    ad         = "rbxassetid://134916447199398",
    axe_battle = "rbxassetid://91285868461583",
}

local HttpService      = game:GetService("HttpService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local Lighting         = game:GetService("Lighting")

local LP = Players.LocalPlayer

local Theme = {
    Accent         = Color3.fromRGB(80, 132, 255),
    AccentSoft     = Color3.fromRGB(80, 132, 255),
    Background     = Color3.fromRGB(12, 14, 22),
    Panel          = Color3.fromRGB(18, 20, 30),
    Sidebar        = Color3.fromRGB(16, 18, 26),
    Element        = Color3.fromRGB(26, 30, 42),
    ElementHover   = Color3.fromRGB(34, 40, 56),
    ElementActive  = Color3.fromRGB(46, 54, 78),
    Text           = Color3.fromRGB(236, 240, 248),
    TextDim        = Color3.fromRGB(138, 146, 168),
    Border         = Color3.fromRGB(40, 46, 64),
    Danger         = Color3.fromRGB(255, 88, 108),
    Success        = Color3.fromRGB(80, 220, 140),
}

local Library = {}
Library.__index = Library
Library.Flags = {}
Library.Registry = {}
Library.Connections = {}
Library.Icons = Icons
Library.Theme = Theme

local function New(class, props, children)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then o[k] = v end
    end
    for _, c in ipairs(children or {}) do c.Parent = o end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end

local function Corner(r)
    return New("UICorner", { CornerRadius = UDim.new(0, r) })
end

local function Stroke(color, trans, thick)
    return New("UIStroke", {
        Color = color or Theme.Border,
        Transparency = trans or 0,
        Thickness = thick or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function Tween(obj, t, props)
    local tw = TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function Label(props)
    props.BackgroundTransparency = 1
    props.Font = props.Font or Enum.Font.GothamMedium
    props.TextSize = props.TextSize or 13
    props.TextColor3 = props.TextColor3 or Theme.Text
    props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    return New("TextLabel", props)
end

local function GetParentGui()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local ok2, core = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and core then
        local test = pcall(function()
            local f = Instance.new("Folder")
            f.Parent = core
            f:Destroy()
        end)
        if test then return core end
    end
    return LP:WaitForChild("PlayerGui")
end

local function Connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(Library.Connections, c)
    return c
end

local function RegisterFlag(flag, setter)
    if flag then Library.Registry[flag] = setter end
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Connect(UserInputService.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        Title = cfg.Title or "DeepSeek V4.1-Flash",
        Subtitle = cfg.Subtitle or "flash build",
    }

    local gui = New("ScreenGui", {
        Name = "DeepSeekV41Flash",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        IgnoreGuiInset = true,
        DisplayOrder = 999,
        Parent = GetParentGui(),
    })
    Window.Gui = gui

    local blur = New("BlurEffect", { Name = "DSBlur", Size = 0, Parent = Lighting })
    Window.Blur = blur

    local openFrame = New("Frame", {
        Name = "OpenFrame",
        Size = UDim2.fromOffset(200, 44),
        Position = UDim2.new(0.5, -100, 0, 14),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Parent = gui,
    }, {
        Corner(22),
        Stroke(Theme.Border, 0.2),
    })
    Window.OpenFrame = openFrame

    New("ImageLabel", {
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.new(0, 16, 0.5, -11),
        BackgroundTransparency = 1,
        Image = Icons.crown,
        ImageColor3 = Theme.Accent,
        Parent = openFrame,
    })
    Label({
        Text = "Open Menu",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Position = UDim2.fromOffset(46, 0),
        Size = UDim2.new(1, -54, 1, 0),
        Parent = openFrame,
    })
    local openBtn = New("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        Parent = openFrame,
    })

    local mainFrame = New("Frame", {
        Name = "MainFrame",
        Size = UDim2.fromOffset(700, 460),
        Position = UDim2.new(0.5, -350, 0.5, -230),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        Parent = gui,
    }, { Corner(14), Stroke(Theme.Border, 0.1) })
    Window.MainFrame = mainFrame

    local sidebar = New("Frame", {
        Size = UDim2.new(0, 168, 1, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })

    Label({
        Text = Window.Title,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        Position = UDim2.fromOffset(18, 16),
        Size = UDim2.new(1, -30, 0, 18),
        Parent = sidebar,
    })
    Label({
        Text = Window.Subtitle,
        TextSize = 11,
        TextColor3 = Theme.TextDim,
        Position = UDim2.fromOffset(18, 34),
        Size = UDim2.new(1, -30, 0, 14),
        Parent = sidebar,
    })

    local tabList = New("Frame", {
        Size = UDim2.new(1, -16, 1, -130),
        Position = UDim2.fromOffset(8, 60),
        BackgroundTransparency = 1,
        Parent = sidebar,
    }, {
        New("UIListLayout", {
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    local userBox = New("Frame", {
        Size = UDim2.new(1, -16, 0, 44),
        Position = UDim2.new(0, 8, 1, -52),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        Parent = sidebar,
    }, { Corner(8), Stroke(Theme.Border, 0.5) })
    New("ImageLabel", {
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.fromOffset(8, 8),
        BackgroundColor3 = Theme.ElementActive,
        Image = "",
        Parent = userBox,
    }, { Corner(14) })
    Label({
        Text = LP.Name,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Position = UDim2.fromOffset(44, 8),
        Size = UDim2.new(1, -52, 0, 14),
        Parent = userBox,
    })
    Label({
        Text = "Lifetime",
        TextSize = 11,
        TextColor3 = Theme.Accent,
        Position = UDim2.fromOffset(44, 22),
        Size = UDim2.new(1, -52, 0, 14),
        Parent = userBox,
    })

    local topBar = New("Frame", {
        Size = UDim2.new(1, -168, 0, 52),
        Position = UDim2.new(0, 168, 0, 0),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    MakeDraggable(mainFrame, topBar)

    Label({
        Text = "Dashboard",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Position = UDim2.fromOffset(20, 0),
        Size = UDim2.new(1, -80, 1, 0),
        Parent = topBar,
    })

    local closeBtn = New("TextButton", {
        Size = UDim2.fromOffset(28, 28),
        Position = UDim2.new(1, -38, 0.5, -14),
        BackgroundColor3 = Theme.Element,
        AutoButtonColor = false,
        Text = "✕",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.TextDim,
        Parent = topBar,
    }, { Corner(6) })
    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, 0.15, { BackgroundColor3 = Theme.Danger, TextColor3 = Theme.Text })
    end)
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, 0.15, { BackgroundColor3 = Theme.Element, TextColor3 = Theme.TextDim })
    end)
    closeBtn.MouseButton1Click:Connect(function()
        Window:SetVisible(false)
    end)

    local pageFrame = New("Frame", {
        Size = UDim2.new(1, -168, 1, -52),
        Position = UDim2.new(0, 168, 0, 52),
        BackgroundTransparency = 1,
        Parent = mainFrame,
    }, { New("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    }) })
    Window.PageFrame = pageFrame

    local notifyHolder = New("Frame", {
        Size = UDim2.fromOffset(300, 420),
        Position = UDim2.new(1, -320, 0, 70),
        BackgroundTransparency = 1,
        Parent = gui,
    }, {
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Top,
        }),
    })
    Library.NotifyHolder = notifyHolder

    MakeDraggable(openFrame, openFrame)

    function Window:SetVisible(v)
        mainFrame.Visible = v
        Tween(blur, 0.35, { Size = v and 10 or 0 })
        if v then
            mainFrame.Size = UDim2.fromOffset(700, 460)
            mainFrame.Position = UDim2.new(0.5, -350, 0.5, -230)
            mainFrame.BackgroundTransparency = 1
            Tween(mainFrame, 0.3, { BackgroundTransparency = 0 })
        end
    end

    openBtn.MouseButton1Click:Connect(function()
        Window:SetVisible(not mainFrame.Visible)
    end)

    function Window:AddTab(name, icon)
        local Tab = { Name = name, Icon = icon, Sections = {} }

        local btn = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Text = "",
            LayoutOrder = #Window.Tabs + 1,
            Parent = tabList,
        }, { Corner(8) })

        local indicator = New("Frame", {
            Size = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Visible = false,
            Parent = btn,
        }, { Corner(2) })

        local ico = New("ImageLabel", {
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.fromOffset(14, 9),
            BackgroundTransparency = 1,
            Image = icon or "",
            ImageColor3 = Theme.TextDim,
            Parent = btn,
        })
        local lbl = Label({
            Text = name,
            TextSize = 13,
            TextColor3 = Theme.TextDim,
            Position = UDim2.fromOffset(40, 0),
            Size = UDim2.new(1, -48, 1, 0),
            Parent = btn,
        })
        Tab.Button = btn
        Tab.Indicator = indicator
        Tab.TabIcon = ico
        Tab.TabLabel = lbl

        local page = New("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = pageFrame,
        }, {
            New("UIListLayout", {
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })
        Tab.Page = page

        function Tab:Select()
            if Window.CurrentTab == Tab then return end
            for _, t in ipairs(Window.Tabs) do
                t.Indicator.Visible = false
                t.TabIcon.ImageColor3 = Theme.TextDim
                t.TabLabel.TextColor3 = Theme.TextDim
                Tween(t.Button, 0.2, { BackgroundTransparency = 1 })
                if t.Page then t.Page.Visible = false end
            end
            Window.CurrentTab = Tab
            indicator.Visible = true
            ico.ImageColor3 = Theme.Accent
            lbl.TextColor3 = Theme.Text
            Tween(btn, 0.2, { BackgroundTransparency = 0.55 })
            page.Visible = true
        end

        btn.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(btn, 0.15, { BackgroundTransparency = 0.85 })
                lbl.TextColor3 = Theme.Text
                ico.ImageColor3 = Theme.Text
            end
        end)
        btn.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(btn, 0.15, { BackgroundTransparency = 1 })
                lbl.TextColor3 = Theme.TextDim
                ico.ImageColor3 = Theme.TextDim
            end
        end)
        btn.MouseButton1Click:Connect(function() Tab:Select() end)

        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then Tab:Select() end

        function Tab:AddSection(title, icon, side)
            local Section = { Name = title }

            local holder = New("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Panel,
                BorderSizePixel = 0,
                LayoutOrder = #Tab.Sections + 1,
                Parent = page,
            }, { Corner(10), Stroke(Theme.Border, 0.5) })

            local header = New("Frame", {
                Size = UDim2.new(1, 0, 0, 34),
                BackgroundTransparency = 1,
                Parent = holder,
            })
            if icon then
                New("ImageLabel", {
                    Size = UDim2.fromOffset(14, 14),
                    Position = UDim2.fromOffset(14, 10),
                    BackgroundTransparency = 1,
                    Image = icon,
                    ImageColor3 = Theme.Accent,
                    Parent = header,
                })
            end
            Label({
                Text = title,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                Position = UDim2.fromOffset(icon and 34 or 14, 0),
                Size = UDim2.new(1, -50, 1, 0),
                Parent = header,
            })

            local content = New("Frame", {
                Size = UDim2.new(1, -28, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.fromOffset(14, 34),
                BackgroundTransparency = 1,
                Parent = holder,
            }, {
                New("UIListLayout", {
                    Padding = UDim.new(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                }),
                New("UIPadding", { PaddingBottom = UDim.new(0, 14) }),
            })
            Section.Holder = holder
            Section.Content = content

            local order = 0
            local function nextRow(h)
                order += 1
                return New("Frame", {
                    Size = UDim2.new(1, 0, 0, h or 24),
                    BackgroundTransparency = 1,
                    LayoutOrder = order,
                    Parent = content,
                })
            end

            table.insert(Tab.Sections, Section)
            Section.AddToggle = function(_, o) return addToggle(Section, nextRow, o) end
            Section.AddSlider = function(_, o) return addSlider(Section, nextRow, o) end
            Section.AddDropdown = function(_, o) return addDropdown(Section, nextRow, o) end
            Section.AddButton = function(_, o) return addButton(Section, nextRow, o) end
            Section.AddTextBox = function(_, o) return addTextBox(Section, nextRow, o) end
            Section.AddKeybind = function(_, o) return addKeybind(Section, nextRow, o) end
            Section.AddColorPicker = function(_, o) return addColorPicker(Section, nextRow, o) end
            Section.AddLabel = function(_, text)
                local row = nextRow(18)
                return Label({
                    Text = text,
                    TextColor3 = Theme.TextDim,
                    TextSize = 12,
                    Size = UDim2.fromScale(1, 1),
                    Parent = row,
                })
            end
            Section.AddSeparator = function()
                local row = nextRow(1)
                row.BackgroundColor3 = Theme.Border
                row.BackgroundTransparency = 0.4
            end

            return Section
        end

        return Tab
    end

    function Window:Destroy()
        for _, c in ipairs(Library.Connections) do
            pcall(function() c:Disconnect() end)
        end
        Library.Connections = {}
        if blur then blur:Destroy() end
        if gui then gui:Destroy() end
    end

    return Window
end

local function addToggle(Section, nextRow, o)
    o = type(o) == "string" and { Name = o } or o
    local state = o.Default or false
    local row = nextRow(28)
    local lbl = Label({
        Text = o.Name,
        Size = UDim2.new(1, -50, 1, 0),
        TextColor3 = state and Theme.Text or Theme.TextDim,
        Parent = row,
    })
    local switch = New("TextButton", {
        Size = UDim2.fromOffset(34, 18),
        Position = UDim2.new(1, -34, 0.5, -9),
        BackgroundColor3 = state and Theme.Accent or Theme.Element,
        AutoButtonColor = false,
        Text = "",
        Parent = row,
    }, { Corner(9) })
    local knob = New("Frame", {
        Size = UDim2.fromOffset(14, 14),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, state and 18 or 2, 0.5, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = switch,
    }, { Corner(7) })

    local subHolder = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Visible = state,
        LayoutOrder = order and (row.LayoutOrder + 1) or 1,
        Parent = Section.Content,
    }, {
        New("UIListLayout", {
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
        New("UIPadding", { PaddingLeft = UDim.new(0, 16) }),
    })
    row.Parent = Section.Content

    local obj = { SubHolder = subHolder }

    local function apply(v)
        state = v
        Tween(switch, 0.2, { BackgroundColor3 = v and Theme.Accent or Theme.Element })
        Tween(knob, 0.2, { Position = UDim2.new(0, v and 18 or 2, 0.5, 0) })
        lbl.TextColor3 = v and Theme.Text or Theme.TextDim
        subHolder.Visible = v
        if o.Flag then Library.Flags[o.Flag] = v end
        if o.Callback then task.spawn(o.Callback, v) end
    end
    function obj:Set(v) apply(v) end
    function obj:Get() return state end
    switch.MouseButton1Click:Connect(function() apply(not state) end)
    if o.Flag then Library.Flags[o.Flag] = state end
    RegisterFlag(o.Flag, function(v) obj:Set(v) end)

    local subOrder = 0
    function obj:AddSubToggle(so)
        subOrder += 1
        local sr = New("Frame", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            LayoutOrder = subOrder,
            Parent = subHolder,
        })
        Label({
            Text = so.Name,
            TextSize = 12,
            TextColor3 = Theme.TextDim,
            Size = UDim2.new(1, -44, 1, 0),
            Parent = sr,
        })
        local ss = so.Default or false
        local ssw = New("TextButton", {
            Size = UDim2.fromOffset(28, 14),
            Position = UDim2.new(1, -28, 0.5, -7),
            BackgroundColor3 = ss and Theme.Accent or Theme.Element,
            AutoButtonColor = false,
            Text = "",
            Parent = sr,
        }, { Corner(7) })
        local sknob = New("Frame", {
            Size = UDim2.fromOffset(10, 10),
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, ss and 16 or 2, 0.5, 0),
            BackgroundColor3 = Color3.new(1, 1, 1),
            Parent = ssw,
        }, { Corner(5) })
        local function applySub(v)
            ss = v
            Tween(ssw, 0.2, { BackgroundColor3 = v and Theme.Accent or Theme.Element })
            Tween(sknob, 0.2, { Position = UDim2.new(0, v and 16 or 2, 0.5, 0) })
            if so.Flag then Library.Flags[so.Flag] = v end
            if so.Callback then task.spawn(so.Callback, v) end
        end
        ssw.MouseButton1Click:Connect(function() applySub(not ss) end)
        if so.Flag then Library.Flags[so.Flag] = ss end
        RegisterFlag(so.Flag, applySub)
    end

    return obj
end

local function addSlider(Section, nextRow, o)
    local min = o.Min or 0
    local max = o.Max or 100
    local dec = o.Decimals or 0
    local suffix = o.Suffix or ""
    local val = math.clamp(o.Default or min, min, max)
    local row = nextRow(34)
    Label({ Text = o.Name, Size = UDim2.new(1, -60, 0, 14), Parent = row })
    local vLabel = Label({
        Text = "",
        TextXAlignment = Enum.TextXAlignment.Right,
        TextColor3 = Theme.Accent,
        TextSize = 12,
        Size = UDim2.new(1, -60, 0, 14),
        Parent = row,
    })
    local track = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = Theme.Element,
        AutoButtonColor = false,
        Text = "",
        Parent = row,
    }, { Corner(3) })
    local fill = New("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = track,
    }, { Corner(3) })
    local grab = New("Frame", {
        Size = UDim2.fromOffset(12, 12),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = track,
    }, { Corner(6), Stroke(Theme.Accent, 0, 2) })

    local function format(v)
        if dec == 0 then
            return tostring(math.floor(v))
        end
        return string.format("%." .. dec .. "f", v)
    end
    local function apply(v, instant)
        v = math.clamp(v, min, max)
        if dec == 0 then
            v = math.floor(v + 0.5)
        else
            v = math.floor(v * 10 ^ dec + 0.5) / 10 ^ dec
        end
        val = v
        local p = (v - min) / math.max(max - min, 0.0001)
        local t = instant and 0 or 0.12
        Tween(fill, t, { Size = UDim2.new(p, 0, 1, 0) })
        Tween(grab, t, { Position = UDim2.new(p, 0, 0.5, 0) })
        vLabel.Text = format(v) .. suffix
        if o.Flag then Library.Flags[o.Flag] = v end
        if o.Callback then task.spawn(o.Callback, v) end
    end
    local obj = {}
    function obj:Set(v) apply(v) end
    function obj:Get() return val end
    local sliding = false
    local function updateFromX(x)
        local a = track.AbsolutePosition.X
        local w = math.max(track.AbsoluteSize.X, 1)
        local p = math.clamp((x - a) / w, 0, 1)
        apply(min + (max - min) * p)
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateFromX(i.Position.X)
        end
    end)
    Connect(UserInputService.InputChanged, function(i)
        if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(i.Position.X)
        end
    end)
    Connect(UserInputService.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    apply(val, true)
    RegisterFlag(o.Flag, function(v) obj:Set(v) end)
    return obj
end

local function addDropdown(Section, nextRow, o)
    local multi = o.Multi or false
    local items = o.Items or {}
    local selected
    if multi then
        selected = {}
        if o.Default then
            if type(o.Default) == "table" then
                for _, v in ipairs(o.Default) do selected[v] = true end
            else
                selected[o.Default] = true
            end
        end
    else
        selected = o.Default or items[1]
    end

    local row = nextRow(24)
    Label({ Text = o.Name, Size = UDim2.new(1, -140, 1, 0), Parent = row })
    local box = New("TextButton", {
        Size = UDim2.fromOffset(130, 22),
        Position = UDim2.new(1, -130, 0.5, -11),
        BackgroundColor3 = Theme.Element,
        AutoButtonColor = false,
        Text = "",
        Parent = row,
    }, { Corner(6) })
    local preview = Label({
        Text = "",
        TextSize = 12,
        TextColor3 = Theme.Text,
        ClipsDescendants = true,
        Size = UDim2.new(1, -22, 1, 0),
        Position = UDim2.fromOffset(8, 0),
        Parent = box,
    })
    Label({
        Text = "▼",
        TextSize = 8,
        TextColor3 = Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Center,
        Size = UDim2.fromOffset(16, 22),
        Position = UDim2.new(1, -18, 0, 0),
        Parent = box,
    })

    local gui = Section.Holder.Parent.Parent.Parent
    local popup = New("ScrollingFrame", {
        Visible = false,
        ZIndex = 100,
        Size = UDim2.fromOffset(130, 0),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = gui,
    }, {
        Corner(6),
        Stroke(Theme.Border, 0.2),
        New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
    })

    local searchBox
    if o.Search then
        local sh = New("Frame", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundTransparency = 1,
            LayoutOrder = 0,
            Parent = popup,
        })
        searchBox = New("TextBox", {
            Size = UDim2.new(1, -12, 0, 20),
            Position = UDim2.fromOffset(6, 3),
            BackgroundColor3 = Theme.Element,
            PlaceholderText = "Search...",
            PlaceholderColor3 = Theme.TextDim,
            ClearTextOnFocus = false,
            Text = "",
            TextSize = 12,
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamMedium,
            Parent = sh,
        }, { Corner(4) })
    end

    local obj = {}
    local open = false

    local function collectSelected()
        local list = {}
        for _, v in ipairs(items) do
            if multi and selected[v] then table.insert(list, v) end
        end
        return list
    end
    local function updatePreview()
        if multi then
            local parts = collectSelected()
            preview.Text = #parts > 0 and table.concat(parts, ", ") or "None"
        else
            preview.Text = tostring(selected or "None")
        end
    end
    local function fire()
        if multi then
            local list = collectSelected()
            if o.Flag then Library.Flags[o.Flag] = list end
            if o.Callback then task.spawn(o.Callback, list) end
        else
            if o.Flag then Library.Flags[o.Flag] = selected end
            if o.Callback then task.spawn(o.Callback, selected) end
        end
    end

    local function build()
        for _, c in ipairs(popup:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local q = searchBox and searchBox.Text:lower() or ""
        local idx = searchBox and 0 or 0
        for _, it in ipairs(items) do
            local txt = tostring(it)
            if q == "" or txt:lower():find(q, 1, true) then
                idx += 1
                local isSel = multi and selected[it] or (not multi and selected == it)
                local b = New("TextButton", {
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundColor3 = isSel and Theme.Accent or Theme.Element,
                    BackgroundTransparency = isSel and 0.65 or 1,
                    AutoButtonColor = false,
                    Text = (multi and (isSel and "☑ " or "☐ ") or "") .. txt,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextSize = 12,
                    TextColor3 = isSel and Theme.Text or Theme.TextDim,
                    Font = Enum.Font.GothamMedium,
                    LayoutOrder = idx,
                    Parent = popup,
                })
                New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = b })
                b.MouseEnter:Connect(function()
                    if not isSel then b.TextColor3 = Theme.Text end
                end)
                b.MouseLeave:Connect(function()
                    if not isSel then b.TextColor3 = Theme.TextDim end
                end)
                b.MouseButton1Click:Connect(function()
                    if multi then
                        selected[it] = not selected[it]
                        updatePreview()
                        build()
                        fire()
                    else
                        selected = it
                        updatePreview()
                        fire()
                        obj:Close()
                    end
                end)
            end
        end
    end

    function obj:Close()
        open = false
        local tw = Tween(popup, 0.15, { Size = UDim2.fromOffset(130, 0) })
        tw.Completed:Connect(function()
            if not open then popup.Visible = false end
        end)
    end
    function obj:Open()
        open = true
        build()
        local ap = box.AbsolutePosition
        popup.Position = UDim2.fromOffset(ap.X, ap.Y + 24)
        popup.Visible = true
        local rows = math.min(#items + (searchBox and 1 or 0), 8)
        local h = rows * 22 + (searchBox and 26 or 0)
        Tween(popup, 0.2, { Size = UDim2.fromOffset(130, h) })
        if searchBox then searchBox.Text = "" end
    end
    function obj:Set(v)
        if multi then
            selected = {}
            if type(v) == "table" then
                for _, x in ipairs(v) do selected[x] = true end
            end
        else
            selected = v
        end
        updatePreview()
        fire()
    end
    function obj:Get()
        if multi then return collectSelected() end
        return selected
    end
    function obj:Refresh(newItems)
        items = newItems
        if open then build() end
    end

    if searchBox then
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            if open then build() end
        end)
    end
    box.MouseButton1Click:Connect(function()
        if open then obj:Close() else obj:Open() end
    end)
    Connect(UserInputService.InputBegan, function(i)
        if open and i.UserInputType == Enum.UserInputType.MouseButton1 then
            local m, p, sz = i.Position, popup.AbsolutePosition, popup.AbsoluteSize
            local b = box.AbsolutePosition
            local inPop = m.X >= p.X and m.X <= p.X + sz.X and m.Y >= p.Y and m.Y <= p.Y + sz.Y
            local inBox = m.X >= b.X and m.X <= b.X + 130 and m.Y >= b.Y and m.Y <= b.Y + 22
            if not inPop and not inBox then obj:Close() end
        end
    end)
    updatePreview()
    fire()
    RegisterFlag(o.Flag, function(v) obj:Set(v) end)
    return obj
end

local function addButton(Section, nextRow, o)
    o = type(o) == "string" and { Name = o } or o
    local row = nextRow(28)
    local b = New("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.Element,
        AutoButtonColor = false,
        Text = o.Name,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Theme.Text,
        Parent = row,
    }, { Corner(6) })
    b.MouseEnter:Connect(function() Tween(b, 0.15, { BackgroundColor3 = Theme.ElementHover }) end)
    b.MouseLeave:Connect(function() Tween(b, 0.15, { BackgroundColor3 = Theme.Element }) end)
    b.MouseButton1Down:Connect(function() Tween(b, 0.1, { BackgroundColor3 = Theme.ElementActive }) end)
    b.MouseButton1Up:Connect(function() Tween(b, 0.1, { BackgroundColor3 = Theme.ElementHover }) end)
    b.MouseButton1Click:Connect(function()
        if o.Callback then task.spawn(o.Callback) end
    end)
    return b
end

local function addTextBox(Section, nextRow, o)
    local row = nextRow(24)
    Label({ Text = o.Name, Size = UDim2.new(1, -140, 1, 0), Parent = row })
    local frame = New("Frame", {
        Size = UDim2.fromOffset(130, 22),
        Position = UDim2.new(1, -130, 0.5, -11),
        BackgroundColor3 = Theme.Element,
        Parent = row,
    }, { Corner(6), Stroke(Theme.Border, 0.5) })
    local tb = New("TextBox", {
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.fromOffset(6, 0),
        BackgroundTransparency = 1,
        Text = o.Default or "",
        PlaceholderText = o.Placeholder or "",
        ClearTextOnFocus = false,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })
    tb.Focused:Connect(function()
        Tween(frame, 0.15, { BackgroundColor3 = Theme.ElementHover })
    end)
    tb.FocusLost:Connect(function(enter)
        Tween(frame, 0.15, { BackgroundColor3 = Theme.Element })
        if o.Flag then Library.Flags[o.Flag] = tb.Text end
        if o.Callback then task.spawn(o.Callback, tb.Text, enter) end
    end)
    if o.Flag then Library.Flags[o.Flag] = tb.Text end
    local obj = {}
    function obj:Set(v)
        tb.Text = v
        if o.Flag then Library.Flags[o.Flag] = v end
    end
    function obj:Get() return tb.Text end
    RegisterFlag(o.Flag, function(v) obj:Set(v) end)
    return obj
end

local function addKeybind(Section, nextRow, o)
    local key = o.Default
    local mode = o.Mode or "Toggle"
    local state = false
    local row = nextRow(24)
    Label({ Text = o.Name, Size = UDim2.new(1, -100, 1, 0), Parent = row })
    local b = New("TextButton", {
        Size = UDim2.fromOffset(60, 22),
        Position = UDim2.new(1, -94, 0.5, -11),
        BackgroundColor3 = Theme.Element,
        AutoButtonColor = false,
        Text = key and key.Name or "None",
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Theme.Text,
        Parent = row,
    }, { Corner(6) })
    local modeBtn = New("TextButton", {
        Size = UDim2.fromOffset(28, 22),
        Position = UDim2.new(1, -28, 0.5, -11),
        BackgroundColor3 = Theme.Element,
        AutoButtonColor = false,
        Text = mode:sub(1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Theme.Accent,
        Parent = row,
    }, { Corner(6) })
    local listening = false
    b.MouseButton1Click:Connect(function()
        listening = true
        b.Text = "..."
        b.TextColor3 = Theme.Accent
    end)
    modeBtn.MouseButton1Click:Connect(function()
        if mode == "Toggle" then mode = "Hold"
        elseif mode == "Hold" then mode = "Always"
        else mode = "Toggle" end
        modeBtn.Text = mode:sub(1, 1)
    end)
    Connect(UserInputService.InputBegan, function(i, gp)
        if listening and i.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            key = (i.KeyCode ~= Enum.KeyCode.Escape) and i.KeyCode or nil
            b.Text = key and key.Name or "None"
            b.TextColor3 = Theme.Text
            if o.Flag then Library.Flags[o.Flag] = key end
            if o.Callback then task.spawn(o.Callback, key, "bind") end
        elseif not gp and key and not listening and i.KeyCode == key then
            if mode == "Toggle" then
                state = not state
                if o.Callback then task.spawn(o.Callback, state, "toggle") end
            elseif mode == "Hold" then
                state = true
                if o.Callback then task.spawn(o.Callback, true, "hold") end
            elseif mode == "Always" then
                if o.Callback then task.spawn(o.Callback, true, "always") end
            end
        end
    end)
    Connect(UserInputService.InputEnded, function(i)
        if mode == "Hold" and key and i.KeyCode == key and state then
            state = false
            if o.Callback then task.spawn(o.Callback, false, "release") end
        end
    end)
    if o.Flag then Library.Flags[o.Flag] = key end
    local obj = {}
    function obj:Set(v)
        key = v
        b.Text = v and v.Name or "None"
        if o.Flag then Library.Flags[o.Flag] = v end
    end
    function obj:Get() return key end
    RegisterFlag(o.Flag, function(v) obj:Set(v) end)
    return obj
end

local function addColorPicker(Section, nextRow, o)
    local h, s, v = (o.Default or Color3.new(1, 1, 1)):ToHSV()
    local alpha = o.Alpha or 1
    local row = nextRow(22)
    Label({ Text = o.Name, Size = UDim2.new(1, -30, 1, 0), Parent = row })
    local prev = New("TextButton", {
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.new(1, -20, 0.5, -10),
        BackgroundColor3 = Color3.fromHSV(h, s, v),
        AutoButtonColor = false,
        Text = "",
        Parent = row,
    }, { Corner(4), Stroke(Theme.Border, 0.5) })

    local gui = Section.Holder.Parent.Parent.Parent
    local popup = New("Frame", {
        Visible = false,
        ZIndex = 100,
        Size = UDim2.fromOffset(180, 200),
        BackgroundColor3 = Theme.Panel,
        Parent = gui,
    }, { Corner(8), Stroke(Theme.Border, 0.3) })

    local sv = New("ImageButton", {
        ZIndex = 101,
        Size = UDim2.fromOffset(164, 130),
        Position = UDim2.fromOffset(8, 8),
        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        AutoButtonColor = false,
        Image = "",
        Parent = popup,
    }, { Corner(6) })
    New("Frame", {
        ZIndex = 102,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = sv,
    }, { Corner(6), New("UIGradient", { Transparency = NumberSequence.new(0, 1) }) })
    New("Frame", {
        ZIndex = 103,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        Parent = sv,
    }, { Corner(6), New("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }) })
    local svKnob = New("Frame", {
        ZIndex = 104,
        Size = UDim2.fromOffset(8, 8),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Parent = sv,
    }, { Corner(4), Stroke(Color3.new(1, 1, 1), 0, 2) })

    local hue = New("ImageButton", {
        ZIndex = 101,
        Size = UDim2.fromOffset(164, 10),
        Position = UDim2.fromOffset(8, 146),
        BackgroundColor3 = Color3.new(1, 1, 1),
        AutoButtonColor = false,
        Image = "",
        Parent = popup,
    }, { Corner(5), New("UIGradient", { Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
        ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6, 1, 1)),
        ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6, 1, 1)),
        ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6, 1, 1)),
        ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6, 1, 1)),
        ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
    }) }) })
    local hueKnob = New("Frame", {
        ZIndex = 102,
        Size = UDim2.fromOffset(10, 10),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(h, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        Parent = hue,
    }, { Corner(5), Stroke(Color3.new(1, 1, 1), 0, 2) })

    local abar = New("ImageButton", {
        ZIndex = 101,
        Size = UDim2.fromOffset(164, 10),
        Position = UDim2.fromOffset(8, 166),
        BackgroundColor3 = Color3.fromHSV(h, s, v),
        AutoButtonColor = false,
        Image = "",
        Parent = popup,
    }, { Corner(5), New("UIGradient", { Transparency = NumberSequence.new(1, 0) }) })
    local aKnob = New("Frame", {
        ZIndex = 102,
        Size = UDim2.fromOffset(10, 10),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(alpha, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromHSV(h, s, v),
        Parent = abar,
    }, { Corner(5), Stroke(Color3.new(1, 1, 1), 0, 2) })

    local obj = {}
    local function fire()
        local c = Color3.fromHSV(h, s, v)
        if o.Flag then Library.Flags[o.Flag] = c end
        if o.Callback then task.spawn(o.Callback, c, alpha) end
    end
    local function refresh()
        local c = Color3.fromHSV(h, s, v)
        prev.BackgroundColor3 = c
        sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        svKnob.Position = UDim2.fromScale(s, 1 - v)
        hueKnob.Position = UDim2.new(h, 0, 0.5, 0)
        hueKnob.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        abar.BackgroundColor3 = c
        aKnob.Position = UDim2.new(alpha, 0, 0.5, 0)
        aKnob.BackgroundColor3 = c
        fire()
    end
    function obj:Set(c, a)
        h, s, v = c:ToHSV()
        if a then alpha = a end
        refresh()
    end
    function obj:Get() return Color3.fromHSV(h, s, v), alpha end

    local mode
    local function drag(pos)
        if mode == "sv" then
            s = math.clamp((pos.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((pos.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
        elseif mode == "h" then
            h = math.clamp((pos.X - hue.AbsolutePosition.X) / hue.AbsoluteSize.X, 0, 0.999)
        elseif mode == "a" then
            alpha = math.clamp((pos.X - abar.AbsolutePosition.X) / abar.AbsoluteSize.X, 0, 1)
        end
        refresh()
    end
    for el, m in pairs({ [sv] = "sv", [hue] = "h", [abar] = "a" }) do
        el.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                mode = m
                drag(i.Position)
            end
        end)
    end
    Connect(UserInputService.InputChanged, function(i)
        if mode and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            drag(i.Position)
        end
    end)
    Connect(UserInputService.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            mode = nil
        end
    end)
    prev.MouseButton1Click:Connect(function()
        popup.Visible = not popup.Visible
        local ap = prev.AbsolutePosition
        popup.Position = UDim2.fromOffset(ap.X - 160, ap.Y + 22)
    end)
    Connect(UserInputService.InputBegan, function(i)
        if popup.Visible and i.UserInputType == Enum.UserInputType.MouseButton1 then
            local m, p, sz = i.Position, popup.AbsolutePosition, popup.AbsoluteSize
            local b = prev.AbsolutePosition
            local inPop = m.X >= p.X and m.X <= p.X + sz.X and m.Y >= p.Y and m.Y <= p.Y + sz.Y
            local inPrev = m.X >= b.X and m.X <= b.X + 20 and m.Y >= b.Y and m.Y <= b.Y + 20
            if not inPop and not inPrev then popup.Visible = false end
        end
    end)
    refresh()
    RegisterFlag(o.Flag, function(v) obj:Set(v) end)
    return obj
end

function Library:Notify(o)
    o = type(o) == "string" and { Title = "Notification", Text = o } or o
    if not Library.NotifyHolder then return end
    local title = o.Title or "Notification"
    local text = o.Text or ""
    local duration = o.Duration or 5

    local wrapper = New("Frame", {
        Size = UDim2.fromOffset(280, 60),
        BackgroundTransparency = 1,
        Parent = Library.NotifyHolder,
    })
    local frame = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.new(0, 300, 0, 0),
        BackgroundColor3 = Theme.Panel,
        Parent = wrapper,
    }, { Corner(8), Stroke(Theme.Border, 0.3) })
    New("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = frame,
    }, { Corner(2) })
    Label({
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        Position = UDim2.fromOffset(14, 8),
        Size = UDim2.new(1, -20, 0, 16),
        Parent = frame,
    })
    Label({
        Text = text,
        TextSize = 12,
        TextColor3 = Theme.TextDim,
        Position = UDim2.fromOffset(14, 26),
        Size = UDim2.new(1, -20, 0, 28),
        TextWrapped = true,
        Parent = frame,
    })
    Tween(frame, 0.3, { Position = UDim2.new(0, 0, 0, 0) })
    task.delay(duration, function()
        local tw = Tween(frame, 0.3, { Position = UDim2.new(0, 300, 0, 0) })
        tw.Completed:Connect(function()
            pcall(function() wrapper:Destroy() end)
        end)
    end)
end

local CONFIG_FOLDER = "DeepSeekV41Flash"

local function ensureConfigFolder()
    if not (isfolder and isfile and writefile and readfile and makefolder) then
        return false
    end
    local ok = pcall(function()
        if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
        if not isfolder(CONFIG_FOLDER .. "/configs") then makefolder(CONFIG_FOLDER .. "/configs") end
    end)
    return ok
end

function Library:SaveConfig(name)
    if not ensureConfigFolder() then return false, "file io unsupported" end
    local data = {}
    for flag, val in pairs(Library.Flags) do
        if typeof(val) == "Color3" then
            data[flag] = { __t = "c3", r = val.R, g = val.G, b = val.B }
        elseif typeof(val) == "EnumItem" then
            data[flag] = { __t = "e", enum = val.EnumType.Name, name = val.Name }
        else
            data[flag] = val
        end
    end
    local ok, err = pcall(function()
        writefile(CONFIG_FOLDER .. "/configs/" .. name .. ".json", HttpService:JSONEncode(data))
    end)
    if ok then
        self:Notify({ Title = "Config", Text = "Saved: " .. name })
        return true
    end
    self:Notify({ Title = "Config Error", Text = tostring(err) })
    return false, err
end

function Library:LoadConfig(name)
    if not ensureConfigFolder() then return false, "file io unsupported" end
    local path = CONFIG_FOLDER .. "/configs/" .. name .. ".json"
    if not isfile(path) then return false, "config not found" end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if not ok then return false, tostring(data) end
    for flag, val in pairs(data) do
        if type(val) == "table" and val.__t == "c3" then
            Library.Flags[flag] = Color3.new(val.r, val.g, val.b)
        elseif type(val) == "table" and val.__t == "e" then
            local enum = Enum[val.enum]
            if enum and enum[val.name] then Library.Flags[flag] = enum[val.name] end
        else
            Library.Flags[flag] = val
        end
    end
    for flag, setter in pairs(Library.Registry) do
        if Library.Flags[flag] ~= nil then
            pcall(setter, Library.Flags[flag])
        end
    end
    self:Notify({ Title = "Config", Text = "Loaded: " .. name })
    return true
end

function Library:DeleteConfig(name)
    if not ensureConfigFolder() then return false, "file io unsupported" end
    local path = CONFIG_FOLDER .. "/configs/" .. name .. ".json"
    if not isfile(path) then return false, "config not found" end
    local ok = pcall(function() delfile(path) end)
    if ok then
        self:Notify({ Title = "Config", Text = "Deleted: " .. name })
        return true
    end
    return false
end

function Library:ListConfigs()
    if not ensureConfigFolder() then return {} end
    local ok, list = pcall(function() return listfiles(CONFIG_FOLDER .. "/configs") end)
    if not ok or not list then return {} end
    local names = {}
    for _, p in ipairs(list) do
        local n = p:match("([^/\\]+)%.json$")
        if n then table.insert(names, n) end
    end
    return names
end

return Library
