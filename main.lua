local Icons = {
    crosshairs = "rbxassetid://96677288280405", ghost = "rbxassetid://95400397758754", mouse = "rbxassetid://74350468513068",
    user = "rbxassetid://97066657594742", pallet = "rbxassetid://83365140694071", hammer = "rbxassetid://118512898552101",
    code = "rbxassetid://100793810819046", save = "rbxassetid://136566823798983", feather = "rbxassetid://130188814728078",
    crown = "rbxassetid://73317911385704", dagger = "rbxassetid://133081986539088", baby = "rbxassetid://127135446273067",
    ad = "rbxassetid://134916447199398", axe_battle = "rbxassetid://91285868461583",
}

local HttpService      = game:GetService("HttpService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local Lighting         = game:GetService("Lighting")
local RunService       = game:GetService("RunService")
local LP               = Players.LocalPlayer

local Library = {}
Library.__index = Library
Library.Flags = {}
Library.Registry = {}
Library.Connections = {}
Library.ThemeListeners = {}
Library.Icons = Icons

Library.Themes = {
    Blue = {
        BG = Color3.fromRGB(0, 50, 149), Panel = Color3.fromRGB(4, 51, 111), Player = Color3.fromRGB(5, 68, 144),
        Button = Color3.fromRGB(4, 48, 105), Element = Color3.fromRGB(6, 80, 155), ElementHover = Color3.fromRGB(10, 105, 185),
        ElementActive = Color3.fromRGB(20, 130, 210), Stroke = Color3.fromRGB(0, 39, 114), Accent = Color3.fromRGB(120, 195, 255),
        Text = Color3.fromRGB(255, 255, 255), TextDim = Color3.fromRGB(180, 205, 235),
        GradientA = Color3.fromRGB(4, 42, 87), GradientB = Color3.fromRGB(255, 255, 255)
    },
    Red = {
        BG = Color3.fromRGB(150, 0, 20), Panel = Color3.fromRGB(111, 4, 20), Player = Color3.fromRGB(144, 5, 30),
        Button = Color3.fromRGB(105, 4, 20), Element = Color3.fromRGB(155, 6, 40), ElementHover = Color3.fromRGB(185, 10, 60),
        ElementActive = Color3.fromRGB(210, 20, 80), Stroke = Color3.fromRGB(114, 0, 20), Accent = Color3.fromRGB(255, 120, 120),
        Text = Color3.fromRGB(255, 255, 255), TextDim = Color3.fromRGB(235, 180, 180),
        GradientA = Color3.fromRGB(87, 4, 20), GradientB = Color3.fromRGB(255, 255, 255)
    },
    Green = {
        BG = Color3.fromRGB(0, 100, 50), Panel = Color3.fromRGB(4, 80, 40), Player = Color3.fromRGB(5, 120, 60),
        Button = Color3.fromRGB(4, 70, 30), Element = Color3.fromRGB(6, 130, 70), ElementHover = Color3.fromRGB(10, 160, 90),
        ElementActive = Color3.fromRGB(20, 190, 110), Stroke = Color3.fromRGB(0, 70, 30), Accent = Color3.fromRGB(120, 255, 160),
        Text = Color3.fromRGB(255, 255, 255), TextDim = Color3.fromRGB(180, 235, 200),
        GradientA = Color3.fromRGB(4, 70, 30), GradientB = Color3.fromRGB(255, 255, 255)
    },
    Dark = {
        BG = Color3.fromRGB(15, 15, 20), Panel = Color3.fromRGB(25, 25, 30), Player = Color3.fromRGB(35, 35, 40),
        Button = Color3.fromRGB(45, 45, 50), Element = Color3.fromRGB(55, 55, 65), ElementHover = Color3.fromRGB(70, 70, 80),
        ElementActive = Color3.fromRGB(90, 90, 100), Stroke = Color3.fromRGB(50, 50, 60), Accent = Color3.fromRGB(200, 200, 200),
        Text = Color3.fromRGB(255, 255, 255), TextDim = Color3.fromRGB(150, 150, 160),
        GradientA = Color3.fromRGB(30, 30, 35), GradientB = Color3.fromRGB(80, 80, 90)
    }
}

Library.Theme = Library.Themes.Blue

function Library:SetTheme(themeName)
    if not self.Themes[themeName] then return end
    for k, v in pairs(self.Themes[themeName]) do
        self.Theme[k] = v
    end
    for _, listener in ipairs(self.ThemeListeners) do
        pcall(listener, self.Theme)
    end
end

local function New(class, props, children)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then pcall(function() o[k] = v end) end
    end
    for _, c in ipairs(children or {}) do c.Parent = o end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end

local function Corner(r) return New("UICorner", { CornerRadius = UDim.new(0, r or 4) }) end

local function Stroke(color, trans, thick)
    local s = New("UIStroke", { Color = color or Library.Theme.Stroke, Transparency = trans or 0, Thickness = thick or 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
    table.insert(Library.ThemeListeners, function(t) s.Color = t.Stroke end)
    return s
end

local function Gradient()
    local g = New("UIGradient", { Rotation = 123 })
    local function update(t)
        g.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, t.GradientA), ColorSequenceKeypoint.new(1, t.GradientB) })
    end
    update(Library.Theme)
    table.insert(Library.ThemeListeners, update)
    return g
end

local function Tween(obj, t, props)
    if not obj then return end
    local ok, tw = pcall(TweenService.Create, TweenService, obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    if ok and tw then tw:Play() return tw end
end

local function Label(props)
    props = props or {}
    props.BackgroundTransparency = 1
    props.Font = props.Font or Enum.Font.GothamMedium
    props.TextSize = props.TextSize or 13
    props.TextColor3 = props.TextColor3 or Library.Theme.Text
    props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    return New("TextLabel", props)
end

local function GetParentGui()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local ok2, core = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and core then
        local test = pcall(function() local f = Instance.new("Folder"); f.Parent = core; f:Destroy() end)
        if test then return core end
    end
    return LP:WaitForChild("PlayerGui")
end

local function Connect(sig, fn)
    local c = sig:Connect(fn)
    table.insert(Library.Connections, c)
    return c
end

local function RegisterFlag(flag, setter)
    if flag then Library.Registry[flag] = setter end
end

local function SafeExecutor()
    local n = "Unknown"
    pcall(function()
        if type(identifyexecutor) == "function" then
            local r = identifyexecutor()
            if type(r) == "string" then n = r end
        end
    end)
    return n
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    if not handle then return end
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Connect(UserInputService.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

local function AddToggle(Section, nextRow, o)
    o = type(o) == "string" and { Name = o } or o
    local state = o.Default or false
    local row = nextRow(26)
    local lbl = Label({ Text = o.Name, Size = UDim2.new(1, -50, 1, 0), TextColor3 = state and Library.Theme.Text or Library.Theme.TextDim, Parent = row })
    local switch = New("TextButton", { Size = UDim2.fromOffset(34, 18), Position = UDim2.new(1, -34, 0.5, -9), BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.Element, AutoButtonColor = false, Text = "", Parent = row }, { Corner(9), Stroke(Library.Theme.Stroke, 0.3, 1) })
    local knob = New("Frame", { Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, state and 18 or 2, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1), Parent = switch }, { Corner(7) })
    
    local subRows, obj = {}, {}
    table.insert(Library.ThemeListeners, function(t)
        switch.BackgroundColor3 = state and t.Accent or t.Element
        lbl.TextColor3 = state and t.Text or t.TextDim
    end)
    
    local function apply(v)
        state = v
        Tween(switch, 0.2, { BackgroundColor3 = v and Library.Theme.Accent or Library.Theme.Element })
        Tween(knob, 0.2, { Position = UDim2.new(0, v and 18 or 2, 0.5, 0) })
        lbl.TextColor3 = v and Library.Theme.Text or Library.Theme.TextDim
        for _, sr in ipairs(subRows) do sr.Visible = v end
        if o.Flag then Library.Flags[o.Flag] = v end
        if o.Callback then task.spawn(o.Callback, v) end
    end
    function obj:Set(v) apply(v) end
    function obj:Get() return state end
    switch.MouseButton1Click:Connect(function() apply(not state) end)
    if o.Flag then Library.Flags[o.Flag] = state end
    RegisterFlag(o.Flag, function(v) obj:Set(v) end)
    
    function obj:AddSubToggle(so)
        local sr = nextRow(22)
        sr.Visible = state; sr.Size = UDim2.new(1, -16, 0, 22); sr.Position = UDim2.fromOffset(16, 0)
        table.insert(subRows, sr)
        Label({ Text = so.Name, TextSize = 12, TextColor3 = Library.Theme.TextDim, Size = UDim2.new(1, -40, 1, 0), Parent = sr })
        local ss = so.Default or false
        local ssw = New("TextButton", { Size = UDim2.fromOffset(28, 14), Position = UDim2.new(1, -28, 0.5, -7), BackgroundColor3 = ss and Library.Theme.Accent or Library.Theme.Element, AutoButtonColor = false, Text = "", Parent = sr }, { Corner(7) })
        local sknob = New("Frame", { Size = UDim2.fromOffset(10, 10), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, ss and 16 or 2, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1), Parent = ssw }, { Corner(5) })
        
        table.insert(Library.ThemeListeners, function(t) ssw.BackgroundColor3 = ss and t.Accent or t.Element end)

        local function applySub(v)
            ss = v
            Tween(ssw, 0.2, { BackgroundColor3 = v and Library.Theme.Accent or Library.Theme.Element })
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

local function AddSlider(Section, nextRow, o)
    local min, max = o.Min or 0, o.Max or 100
    local dec = o.Decimals or 0
    local suffix = o.Suffix or ""
    local val = math.clamp(o.Default or min, min, max)
    local row = nextRow(36)
    Label({ Text = o.Name, Size = UDim2.new(1, -60, 0, 14), Parent = row })
    local vLabel = Label({ Text = "", TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = Library.Theme.Accent, TextSize = 12, Size = UDim2.new(1, -60, 0, 14), Parent = row })
    local track = New("TextButton", { Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 24), BackgroundColor3 = Library.Theme.Element, AutoButtonColor = false, Text = "", Parent = row }, { Corner(3), Stroke(Library.Theme.Stroke, 0.4, 1) })
    local fill = New("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0, Parent = track }, { Corner(3) })
    local grab = New("Frame", { Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1), Parent = track }, { Corner(6), Stroke(Library.Theme.Accent, 0, 2) })

    table.insert(Library.ThemeListeners, function(t)
        fill.BackgroundColor3 = t.Accent
        vLabel.TextColor3 = t.Accent
        local s = grab:FindFirstChildOfClass("UIStroke")
        if s then s.Color = t.Accent end
        track.BackgroundColor3 = t.Element
    end)

    local function format(v)
        if dec == 0 then return tostring(math.floor(v)) end
        return string.format("%." .. dec .. "f", v)
    end
    local function apply(v, instant)
        v = math.clamp(v, min, max)
        if dec == 0 then v = math.floor(v + 0.5) else v = math.floor(v * 10 ^ dec + 0.5) / 10 ^ dec end
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
        local p = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        apply(min + (max - min) * p)
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sliding = true; updateFromX(i.Position.X)
        end
    end)
    Connect(UserInputService.InputChanged, function(i)
        if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(i.Position.X)
        end
    end)
    Connect(UserInputService.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
    apply(val, true)
    RegisterFlag(o.Flag, function(v) obj:Set(v) end)
    return obj
end

local function AddDropdown(Section, nextRow, o)
    local multi = o.Multi or false
    local items = o.Items or {}
    local selected
    if multi then
        selected = {}
        if o.Default then
            if type(o.Default) == "table" then for _, v in ipairs(o.Default) do selected[v] = true end
            else selected[o.Default] = true end
        end
    else selected = o.Default or items[1] end
    local row = nextRow(24)
    Label({ Text = o.Name, Size = UDim2.new(1, -140, 1, 0), Parent = row })
    local box = New("TextButton", { Size = UDim2.fromOffset(130, 22), Position = UDim2.new(1, -130, 0.5, -11), BackgroundColor3 = Library.Theme.Element, AutoButtonColor = false, Text = "", Parent = row }, { Corner(4), Stroke(Library.Theme.Stroke, 0.4, 1) })
    local preview = Label({ Text = "", TextSize = 12, TextColor3 = Library.Theme.Text, ClipsDescendants = true, Size = UDim2.new(1, -22, 1, 0), Position = UDim2.fromOffset(8, 0), Parent = box })
    Label({ Text = "v", TextSize = 10, TextColor3 = Library.Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromOffset(16, 22), Position = UDim2.new(1, -18, 0, 0), Parent = box })
    local gui = Section.Window and Section.Window.Gui
    local popup = New("ScrollingFrame", { Visible = false, ZIndex = 100, Size = UDim2.fromOffset(130, 0), BackgroundColor3 = Library.Theme.Panel, BackgroundTransparency = 0.15, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Library.Theme.Accent, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = gui }, { Corner(4), Stroke(Library.Theme.Stroke, 0, 2), New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }) })

    table.insert(Library.ThemeListeners, function(t)
        box.BackgroundColor3 = t.Element
        popup.BackgroundColor3 = t.Panel
        popup.ScrollBarImageColor3 = t.Accent
    end)

    local searchBox
    if o.Search then
        local sh = New("Frame", { Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, LayoutOrder = 0, Parent = popup })
        searchBox = New("TextBox", { Size = UDim2.new(1, -12, 0, 20), Position = UDim2.fromOffset(6, 3), BackgroundColor3 = Library.Theme.Element, PlaceholderText = "Search...", PlaceholderColor3 = Library.Theme.TextDim, ClearTextOnFocus = false, Text = "", TextSize = 12, TextColor3 = Library.Theme.Text, Parent = sh }, { Corner(4) })
        table.insert(Library.ThemeListeners, function(t) searchBox.BackgroundColor3 = t.Element end)
    end
    local obj, open = {}, false
    local function collectSelected()
        local list = {}
        for _, v in ipairs(items) do if multi and selected[v] then table.insert(list, v) end end
        return list
    end
    local function updatePreview()
        if multi then
            local parts = collectSelected()
            preview.Text = #parts > 0 and table.concat(parts, ", ") or "None"
        else preview.Text = tostring(selected or "None") end
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
        for _, c in ipairs(popup:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        local q = searchBox and searchBox.Text:lower() or ""
        local idx = 0
        for _, it in ipairs(items) do
            local txt = tostring(it)
            if q == "" or txt:lower():find(q, 1, true) then
                idx += 1
                local isSel = multi and selected[it] or (not multi and selected == it)
                local b = New("TextButton", { Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = isSel and Library.Theme.Accent or Library.Theme.Element, BackgroundTransparency = isSel and 0.6 or 1, AutoButtonColor = false, Text = (multi and (isSel and "[x] " or "[ ] ") or "") .. txt, TextXAlignment = Enum.TextXAlignment.Left, TextSize = 12, TextColor3 = isSel and Library.Theme.Text or Library.Theme.TextDim, LayoutOrder = idx, Parent = popup })
                New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = b })
                b.MouseEnter:Connect(function() if not isSel then b.TextColor3 = Library.Theme.Text end end)
                b.MouseLeave:Connect(function() if not isSel then b.TextColor3 = Library.Theme.TextDim end end)
                b.MouseButton1Click:Connect(function()
                    if multi then selected[it] = not selected[it]; updatePreview(); build(); fire()
                    else selected = it; updatePreview(); fire(); obj:Close() end
                end)
            end
        end
    end
    function obj:Close()
        open = false
        local tw = Tween(popup, 0.15, { Size = UDim2.fromOffset(130, 0) })
        if tw then tw.Completed:Connect(function() if not open then popup.Visible = false end end) end
    end
    function obj:Open()
        open = true; build()
        local ap = box.AbsolutePosition
        popup.Position = UDim2.fromOffset(ap.X, ap.Y + 24)
        popup.Visible = true
        local rows = math.min(#items + (searchBox and 1 or 0), 8)
        Tween(popup, 0.2, { Size = UDim2.fromOffset(130, rows * 22 + (searchBox and 26 or 0)) })
        if searchBox then searchBox.Text = "" end
    end
    function obj:Set(v)
        if multi then
            selected = {}
            if type(v) == "table" then for _, x in ipairs(v) do selected[x] = true end end
        else selected = v end
        updatePreview(); fire()
    end
    function obj:Get() if multi then return collectSelected() end return selected end
    function obj:Refresh(newItems) items = newItems; if open then build() end end
    if searchBox then searchBox:GetPropertyChangedSignal("Text"):Connect(function() if open then build() end end) end
    box.MouseButton1Click:Connect(function() if open then obj:Close() else obj:Open() end end)
    Connect(UserInputService.InputBegan, function(i)
        if open and i.UserInputType == Enum.UserInputType.MouseButton1 then
            local m, p, sz = i.Position, popup.AbsolutePosition, popup.AbsoluteSize
            local b = box.AbsolutePosition
            local inPop = m.X >= p.X and m.X <= p.X + sz.X and m.Y >= p.Y and m.Y <= p.Y + sz.Y
            local inBox = m.X >= b.X and m.X <= b.X + 130 and m.Y >= b.Y and m.Y <= b.Y + 22
            if not inPop and not inBox then obj:Close() end
        end
    end)
    updatePreview(); fire()
    RegisterFlag(o.Flag, function(v) obj:Set(v) end)
    return obj
end

local function AddButton(Section, nextRow, o)
    o = type(o) == "string" and { Name = o } or o
    local row = nextRow(28)
    local b = New("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Library.Theme.Element, AutoButtonColor = false, Text = o.Name, TextSize = 12, TextColor3 = Library.Theme.Text, Parent = row }, { Corner(4), Stroke(Library.Theme.Stroke, 0.4, 1) })
    b.MouseEnter:Connect(function() Tween(b, 0.15, { BackgroundColor3 = Library.Theme.ElementHover }) end)
    b.MouseLeave:Connect(function() Tween(b, 0.15, { BackgroundColor3 = Library.Theme.Element }) end)
    b.MouseButton1Down:Connect(function() Tween(b, 0.1, { BackgroundColor3 = Library.Theme.ElementActive }) end)
    b.MouseButton1Up:Connect(function() Tween(b, 0.1, { BackgroundColor3 = Library.Theme.ElementHover }) end)
    b.MouseButton1Click:Connect(function() if o.Callback then task.spawn(o.Callback) end end)
    table.insert(Library.ThemeListeners, function(t) b.BackgroundColor3 = t.Element; b.TextColor3 = t.Text end)
    return b
end

local function AddTextBox(Section, nextRow, o)
    local row = nextRow(24)
    Label({ Text = o.Name, Size = UDim2.new(1, -140, 1, 0), Parent = row })
    local frame = New("Frame", { Size = UDim2.fromOffset(130, 22), Position = UDim2.new(1, -130, 0.5, -11), BackgroundColor3 = Library.Theme.Element, Parent = row }, { Corner(4), Stroke(Library.Theme.Stroke, 0.4, 1) })
    local tb = New("TextBox", { Size = UDim2.new(1, -12, 1, 0), Position = UDim2.fromOffset(6, 0), BackgroundTransparency = 1, Text = o.Default or "", PlaceholderText = o.Placeholder or "", ClearTextOnFocus = false, TextSize = 12, TextColor3 = Library.Theme.Text, PlaceholderColor3 = Library.Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
    tb.Focused:Connect(function() Tween(frame, 0.15, { BackgroundColor3 = Library.Theme.ElementHover }) end)
    tb.FocusLost:Connect(function(enter)
        Tween(frame, 0.15, { BackgroundColor3 = Library.Theme.Element })
        if o.Flag then Library.Flags[o.Flag] = tb.Text end
        if o.Callback then task.spawn(o.Callback, tb.Text, enter) end
    end)
    if o.Flag then Library.Flags[o.Flag] = tb.Text end
    local obj = {}
    function obj:Set(v) tb.Text = v; if o.Flag then Library.Flags[o.Flag] = v end end
    function obj:Get() return tb.Text end
    RegisterFlag(o.Flag, function(v) obj:Set(v) end)
    table.insert(Library.ThemeListeners, function(t) frame.BackgroundColor3 = t.Element; tb.TextColor3 = t.Text end)
    return obj
end

local function AddKeybind(Section, nextRow, o)
    local key = o.Default
    local mode = o.Mode or "Toggle"
    local state = false
    local row = nextRow(24)
    Label({ Text = o.Name, Size = UDim2.new(1, -100, 1, 0), Parent = row })
    local b = New("TextButton", { Size = UDim2.fromOffset(60, 22), Position = UDim2.new(1, -94, 0.5, -11), BackgroundColor3 = Library.Theme.Element, AutoButtonColor = false, Text = key and key.Name or "None", TextSize = 12, TextColor3 = Library.Theme.Text, Parent = row }, { Corner(4), Stroke(Library.Theme.Stroke, 0.4, 1) })
    local modeBtn = New("TextButton", { Size = UDim2.fromOffset(28, 22), Position = UDim2.new(1, -28, 0.5, -11), BackgroundColor3 = Library.Theme.Element, AutoButtonColor = false, Text = mode:sub(1, 1), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Library.Theme.Accent, Parent = row }, { Corner(4), Stroke(Library.Theme.Stroke, 0.4, 1) })
    table.insert(Library.ThemeListeners, function(t) b.BackgroundColor3 = t.Element; modeBtn.BackgroundColor3 = t.Element; modeBtn.TextColor3 = t.Accent; b.TextColor3 = t.Text end)

    local listening = false
    b.MouseButton1Click:Connect(function() listening = true; b.Text = "..."; b.TextColor3 = Library.Theme.Accent end)
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
            b.Text = key and key.Name or "None"; b.TextColor3 = Library.Theme.Text
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
    function obj:Set(v) key = v; b.Text = v and v.Name or "None"; if o.Flag then Library.Flags[o.Flag] = v end end
    function obj:Get() return key end
    RegisterFlag(o.Flag, function(v) obj:Set(v) end)
    return obj
end

local function AddColorPicker(Section, nextRow, o)
    local h, s, v = (o.Default or Color3.new(1, 1, 1)):ToHSV()
    local alpha = o.Alpha or 1
    local row = nextRow(22)
    Label({ Text = o.Name, Size = UDim2.new(1, -30, 1, 0), Parent = row })
    local prev = New("TextButton", { Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -20, 0.5, -10), BackgroundColor3 = Color3.fromHSV(h, s, v), AutoButtonColor = false, Text = "", Parent = row }, { Corner(4), Stroke(Library.Theme.Stroke, 0, 2) })
    local gui = Section.Window and Section.Window.Gui
    local popup = New("Frame", { Visible = false, ZIndex = 100, Size = UDim2.fromOffset(180, 200), BackgroundColor3 = Library.Theme.Panel, BackgroundTransparency = 0.1, Parent = gui }, { Corner(4), Stroke(Library.Theme.Stroke, 0, 2) })
    local sv = New("ImageButton", { ZIndex = 101, Size = UDim2.fromOffset(164, 130), Position = UDim2.fromOffset(8, 8), BackgroundColor3 = Color3.fromHSV(h, 1, 1), AutoButtonColor = false, Image = "", Parent = popup }, { Corner(4) })
    New("Frame", { ZIndex = 102, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), Parent = sv }, { Corner(4), New("UIGradient", { Transparency = NumberSequence.new(0, 1) }) })
    New("Frame", { ZIndex = 103, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), Parent = sv }, { Corner(4), New("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }) })
    local svKnob = New("Frame", { ZIndex = 104, Size = UDim2.fromOffset(8, 8), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Parent = sv }, { Corner(4), Stroke(Color3.new(1, 1, 1), 0, 2) })
    local hue = New("ImageButton", { ZIndex = 101, Size = UDim2.fromOffset(164, 10), Position = UDim2.fromOffset(8, 146), BackgroundColor3 = Color3.new(1, 1, 1), AutoButtonColor = false, Image = "", Parent = popup }, { Corner(3), New("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)), ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6, 1, 1)), ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6, 1, 1)), ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6, 1, 1)), ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6, 1, 1)), ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6, 1, 1)), ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)) }) }) })
    local hueKnob = New("Frame", { ZIndex = 102, Size = UDim2.fromOffset(10, 10), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(h, 0, 0.5, 0), BackgroundColor3 = Color3.fromHSV(h, 1, 1), Parent = hue }, { Corner(5), Stroke(Color3.new(1, 1, 1), 0, 2) })
    local abar = New("ImageButton", { ZIndex = 101, Size = UDim2.fromOffset(164, 10), Position = UDim2.fromOffset(8, 166), BackgroundColor3 = Color3.fromHSV(h, s, v), AutoButtonColor = false, Image = "", Parent = popup }, { Corner(3), New("UIGradient", { Transparency = NumberSequence.new(1, 0) }) })
    local aKnob = New("Frame", { ZIndex = 102, Size = UDim2.fromOffset(10, 10), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(alpha, 0, 0.5, 0), BackgroundColor3 = Color3.fromHSV(h, s, v), Parent = abar }, { Corner(5), Stroke(Color3.new(1, 1, 1), 0, 2) })
    table.insert(Library.ThemeListeners, function(t) popup.BackgroundColor3 = t.Panel end)

    local obj = {}
    local function fire()
        local c = Color3.fromHSV(h, s, v)
        if o.Flag then Library.Flags[o.Flag] = c end
        if o.Callback then task.spawn(o.Callback, c, alpha) end
    end
    local function refresh()
        local c = Color3.fromHSV(h, s, v)
        prev.BackgroundColor3 = c; sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        svKnob.Position = UDim2.fromScale(s, 1 - v)
        hueKnob.Position = UDim2.new(h, 0, 0.5, 0); hueKnob.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        abar.BackgroundColor3 = c; aKnob.Position = UDim2.new(alpha, 0, 0.5, 0); aKnob.BackgroundColor3 = c
        fire()
    end
    function obj:Set(c, a) h, s, v = c:ToHSV(); if a then alpha = a end; refresh() end
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
                mode = m; drag(i.Position)
            end
        end)
    end
    Connect(UserInputService.InputChanged, function(i)
        if mode and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then drag(i.Position) end
    end)
    Connect(UserInputService.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then mode = nil end
    end)
    prev.MouseButton1Click:Connect(function()
        popup.Visible = not popup.Visible
        local ap = prev.AbsolutePosition
        popup.Position = UDim2.fromOffset(math.max(ap.X - 160, 8), ap.Y + 22)
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

local function CreateSection(parentContent, title, icon, Window, order)
    local Section = { Name = title, Window = Window }
    local holder = New("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Library.Theme.Player, BackgroundTransparency = 0.4, BorderSizePixel = 0, LayoutOrder = order or 1, Parent = parentContent }, { Corner(4), Stroke(Library.Theme.Stroke, 0, 2) })
    New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = holder })
    New("UIPadding", { PaddingBottom = UDim.new(0, 12), PaddingTop = UDim.new(0, 0), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = holder })
    
    table.insert(Library.ThemeListeners, function(t) holder.BackgroundColor3 = t.Player end)

    local header = New("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = 1, Parent = holder })
    if icon then
        local hIcon = New("ImageLabel", { Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(0, 8), BackgroundTransparency = 1, Image = icon, ImageColor3 = Library.Theme.Accent, Parent = header })
        table.insert(Library.ThemeListeners, function(t) hIcon.ImageColor3 = t.Accent end)
    end
    Label({ Text = title, Font = Enum.Font.GothamBold, TextSize = 13, Position = UDim2.fromOffset(icon and 22 or 0, 0), Size = UDim2.new(1, -30, 1, 0), Parent = header })
    
    local content = New("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 2, Parent = holder }, { New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }) })
    Section.Holder, Section.Content = holder, content
    local rOrder = 0
    local function nextRow(h)
        rOrder += 1
        return New("Frame", { Size = UDim2.new(1, 0, 0, h or 24), BackgroundTransparency = 1, LayoutOrder = rOrder, Parent = content })
    end
    
    Section.AddToggle = function(_, o) return AddToggle(Section, nextRow, o) end
    Section.AddSlider = function(_, o) return AddSlider(Section, nextRow, o) end
    Section.AddDropdown = function(_, o) return AddDropdown(Section, nextRow, o) end
    Section.AddButton = function(_, o) return AddButton(Section, nextRow, o) end
    Section.AddTextBox = function(_, o) return AddTextBox(Section, nextRow, o) end
    Section.AddKeybind = function(_, o) return AddKeybind(Section, nextRow, o) end
    Section.AddColorPicker = function(_, o) return AddColorPicker(Section, nextRow, o) end
    Section.AddLabel = function(_, text)
        local row = nextRow(18)
        return Label({ Text = text, TextColor3 = Library.Theme.TextDim, TextSize = 12, Size = UDim2.fromScale(1, 1), Parent = row })
    end
    Section.AddSeparator = function()
        local row = nextRow(1)
        row.BackgroundColor3 = Library.Theme.Stroke
        row.BackgroundTransparency = 0.3
    end
    return Section
end

local winCounter = 0

local function BuildWindow(self, cfg)
    cfg = cfg or {}
    winCounter += 1
    local parentGui = GetParentGui()

    local Window = {
        Tabs = {}, CurrentTab = nil, Minimized = false,
        Title = cfg.Title or "DeepSeek V4.1-Flash",
    }

    local gui = New("ScreenGui", {
        Name = "DeepSeekUI_" .. winCounter, ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true,
        DisplayOrder = 9999999 + winCounter, Parent = parentGui,
    })
    Window.Gui = gui

    local blur = Lighting:FindFirstChild("DSBlur")
    if not blur then blur = New("BlurEffect", { Name = "DSBlur", Size = 0, Parent = Lighting }) end
    Window.Blur = blur

    local openFrame = New("Frame", { Name = "OpenFrame", Size = UDim2.fromOffset(304, 47), Position = UDim2.new(0.5, -152 - (winCounter * 20), 0, 14 + (winCounter * 15)), BackgroundColor3 = Library.Theme.BG, BackgroundTransparency = 0.15, BorderSizePixel = 0, Parent = gui }, { Corner(4), Stroke(Library.Theme.Stroke, 0, 2), Gradient() })
    Window.OpenFrame = openFrame
    table.insert(Library.ThemeListeners, function(t) openFrame.BackgroundColor3 = t.BG end)

    Label({ Name = "UiTitle", Text = Window.Title, TextSize = 20, Size = UDim2.fromOffset(185, 42), Position = UDim2.new(0, 60, 0, 2), TextWrapped = true, Parent = openFrame })
    New("ImageLabel", { Name = "IconUI", Image = "rbxassetid://121267808310974", BackgroundTransparency = 1, Size = UDim2.fromOffset(42, 41), Position = UDim2.new(1, -48, 0, 3), Parent = openFrame }, { Corner(4), Gradient() })

    local openBtn = New("TextButton", { Name = "OpenMainFrame", Size = UDim2.fromOffset(26, 27), Position = UDim2.fromOffset(20, 10), BackgroundColor3 = Library.Theme.Button, BackgroundTransparency = 0.6, Text = "+", TextColor3 = Library.Theme.Text, TextSize = 14, AutoButtonColor = false, Parent = openFrame }, { Corner(4), Stroke(Library.Theme.Stroke, 0, 2) })
    table.insert(Library.ThemeListeners, function(t) openBtn.BackgroundColor3 = t.Button; openBtn.TextColor3 = t.Text end)
    MakeDraggable(openFrame, openFrame)

    local mainFrame = New("Frame", { Name = "MainFrame", Size = UDim2.fromOffset(550, 349), Position = UDim2.new(0.5, -275 + (winCounter * 20), 0.5, -175 + (winCounter * 20)), BackgroundColor3 = Library.Theme.BG, BackgroundTransparency = 0.15, BorderSizePixel = 0, Visible = false, ClipsDescendants = true, Parent = gui }, { Corner(4), Stroke(Library.Theme.Stroke, 0, 2), Gradient() })
    Window.MainFrame = mainFrame
    table.insert(Library.ThemeListeners, function(t) mainFrame.BackgroundColor3 = t.BG end)

    local topBar = New("Frame", { Name = "TopBar", Size = UDim2.new(0, 550, 0, 42), BackgroundColor3 = Library.Theme.Panel, BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 3, Parent = mainFrame }, { Corner(4), Stroke(Library.Theme.Stroke, 0, 2) })
    table.insert(Library.ThemeListeners, function(t) topBar.BackgroundColor3 = t.Panel end)
    MakeDraggable(mainFrame, topBar)

    Label({ Name = "UiTitle", Text = Window.Title, TextSize = 20, Size = UDim2.fromOffset(178, 42), Position = UDim2.new(0, 66, 0, 0), TextWrapped = true, Parent = topBar })
    New("ImageLabel", { Name = "IconUI", Image = "rbxassetid://121267808310974", BackgroundTransparency = 1, Size = UDim2.fromOffset(42, 41), Position = UDim2.fromOffset(8, 0), Parent = topBar }, { Corner(4), Gradient() })
    Label({ Name = "ExecutorInfo", Text = "Executor: " .. SafeExecutor(), TextSize = 14, Size = UDim2.fromOffset(120, 34), Position = UDim2.new(0, 255, 0, 4), TextWrapped = true, Parent = topBar })

    local playersLabel = Label({ Name = "PlayerInGameInfo", Text = "Players: " .. #Players:GetPlayers(), TextSize = 14, Size = UDim2.fromOffset(93, 34), Position = UDim2.new(0, 372, 0, 4), TextWrapped = true, Parent = topBar })
    Players.PlayerAdded:Connect(function() playersLabel.Text = "Players: " .. #Players:GetPlayers() end)
    Players.PlayerRemoving:Connect(function() playersLabel.Text = "Players: " .. #Players:GetPlayers() end)

    local miniBtn = New("TextButton", { Name = "minisize", Size = UDim2.fromOffset(26, 27), Position = UDim2.new(0, 483, 0, 7), BackgroundColor3 = Library.Theme.Button, BackgroundTransparency = 0.6, Text = "-", TextColor3 = Library.Theme.Text, TextSize = 16, AutoButtonColor = false, Parent = topBar }, { Corner(4), Stroke(Library.Theme.Stroke, 0, 2) })
    local closeBtn = New("TextButton", { Name = "close", Size = UDim2.fromOffset(26, 27), Position = UDim2.new(0, 516, 0, 7), BackgroundColor3 = Library.Theme.Button, BackgroundTransparency = 0.6, Text = "X", TextColor3 = Library.Theme.Text, TextSize = 14, AutoButtonColor = false, Parent = topBar }, { Corner(4), Stroke(Library.Theme.Stroke, 0, 2) })
    table.insert(Library.ThemeListeners, function(t) miniBtn.BackgroundColor3 = t.Button; closeBtn.BackgroundColor3 = t.Button end)

    local sidebar = New("Frame", { Name = "SideBar", Size = UDim2.new(0, 120, 0, 307), Position = UDim2.new(0, 0, 0, 42), BackgroundColor3 = Library.Theme.Panel, BackgroundTransparency = 0.5, BorderSizePixel = 0, Parent = mainFrame }, { Corner(4), Stroke(Library.Theme.Stroke, 0, 2) })
    table.insert(Library.ThemeListeners, function(t) sidebar.BackgroundColor3 = t.Panel end)

    local tabList = New("Frame", { Size = UDim2.new(1, -8, 1, -66), Position = UDim2.fromOffset(4, 4), BackgroundTransparency = 1, Parent = sidebar }, { New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })
    local playerInfo = New("Frame", { Name = "PlayerInfo", Size = UDim2.new(1, 0, 0, 58), Position = UDim2.new(0, 0, 1, -58), BackgroundColor3 = Library.Theme.Player, BackgroundTransparency = 0.5, BorderSizePixel = 0, Parent = sidebar }, { Corner(4), Stroke(Library.Theme.Stroke, 0, 2), Gradient() })
    table.insert(Library.ThemeListeners, function(t) playerInfo.BackgroundColor3 = t.Player end)

    local avatar = New("ImageLabel", { Name = "PlayerIconAvatar", Image = "rbxasset://textures/ui/GuiImagePlaceholder.png", BackgroundColor3 = Library.Theme.Panel, Size = UDim2.fromOffset(39, 39), Position = UDim2.fromOffset(8, 9), BorderSizePixel = 0, Parent = playerInfo }, { Corner(20), Stroke(Library.Theme.Stroke, 0, 2) })
    pcall(function() avatar.Image = Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
    Label({ Name = "UiTitle", Text = "Welcome, " .. LP.UserId, TextSize = 13, Size = UDim2.fromOffset(64, 40), Position = UDim2.fromOffset(52, 9), TextWrapped = true, Parent = playerInfo })

    local pageFrame = New("Frame", { Name = "PageFrame", Size = UDim2.new(0, 429, 0, 307), Position = UDim2.new(0, 120, 0, 42), BackgroundColor3 = Library.Theme.Panel, BackgroundTransparency = 0.5, BorderSizePixel = 0, ClipsDescendants = true, Parent = mainFrame }, { Corner(4), Stroke(Library.Theme.Stroke, 0, 2) })
    Window.PageFrame = pageFrame
    table.insert(Library.ThemeListeners, function(t) pageFrame.BackgroundColor3 = t.Panel end)

    local pageHolder = New("Frame", { Size = UDim2.new(1, -16, 1, -16), Position = UDim2.fromOffset(8, 8), BackgroundTransparency = 1, Parent = pageFrame })

    local notifyHolder = New("Frame", { Name = "NotifyHolder", Size = UDim2.fromOffset(300, 420), Position = UDim2.new(1, -320, 0, 70), BackgroundTransparency = 1, Parent = gui }, { New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Top }) })
    if not Library.NotifyHolder then Library.NotifyHolder = notifyHolder end

    function Window:SetVisible(v)
        mainFrame.Visible = v
        Tween(blur, 0.35, { Size = v and 10 or 0 })
    end

    openBtn.MouseButton1Click:Connect(function() Window:SetVisible(not mainFrame.Visible) end)
    closeBtn.MouseButton1Click:Connect(function() Window:SetVisible(false) end)
    miniBtn.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized
        miniBtn.Text = Window.Minimized and "+" or "-"
        Tween(mainFrame, 0.25, { Size = UDim2.fromOffset(550, Window.Minimized and 42 or 349) })
    end)

    function Window:AddTab(name, icon)
        local Tab = { Name = name, Sections = {}, Window = Window }
        local btn = New("TextButton", { Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Library.Theme.Button, BackgroundTransparency = 1, AutoButtonColor = false, Text = "", LayoutOrder = #Window.Tabs + 1, Parent = tabList }, { Corner(4) })
        local indicator = New("Frame", { Size = UDim2.new(0, 3, 1, -8), Position = UDim2.fromOffset(0, 4), BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0, Visible = false, Parent = btn }, { Corner(2) })
        local ico = New("ImageLabel", { Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(12, 6), BackgroundTransparency = 1, Image = icon or "", ImageColor3 = Library.Theme.TextDim, Parent = btn })
        local lbl = Label({ Text = name, TextSize = 12, TextColor3 = Library.Theme.TextDim, Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -38, 1, 0), Parent = btn })
        Tab.Button, Tab.Indicator, Tab.TabIcon, Tab.TabLabel = btn, indicator, ico, lbl

        table.insert(Library.ThemeListeners, function(t)
            indicator.BackgroundColor3 = t.Accent
            if Window.CurrentTab ~= Tab then
                ico.ImageColor3 = t.TextDim; lbl.TextColor3 = t.TextDim
            else
                ico.ImageColor3 = t.Accent; lbl.TextColor3 = t.Text
            end
        end)

        local page = New("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Library.Theme.Accent, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = pageHolder }, { Corner(4) })
        Tab.Page = page
        table.insert(Library.ThemeListeners, function(t) page.ScrollBarImageColor3 = t.Accent end)

        local subBar = New("Frame", { Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Library.Theme.Panel, BackgroundTransparency = 0.5, Visible = false, Position = UDim2.fromOffset(0, 0), Parent = page }, { Corner(4), Stroke(Library.Theme.Stroke, 0, 2) })
        New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), Parent = subBar })
        New("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = subBar })
        table.insert(Library.ThemeListeners, function(t) subBar.BackgroundColor3 = t.Panel end)

        local contentContainer = New("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, subBar.Visible and 34 or 0), Parent = page })
        local leftCol = New("Frame", { Size = UDim2.new(0.5, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 0), Parent = contentContainer }, { New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })
        local rightCol = New("Frame", { Size = UDim2.new(0.5, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Position = UDim2.new(0.5, 4, 0, 0), Parent = contentContainer }, { New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })

        function Tab:AddSubTab(name)
            if not Tab._subTabs then Tab._subTabs = {}; subBar.Visible = true; contentContainer.Position = UDim2.fromOffset(0, 34) end
            local SubTab = { Name = name, Sections = {}, Tab = Tab }
            local sbtn = New("TextButton", { Size = UDim2.new(0, 80, 1, 0), BackgroundColor3 = Library.Theme.Element, BackgroundTransparency = 1, Text = name, TextColor3 = Library.Theme.TextDim, TextSize = 12, LayoutOrder = #Tab._subTabs + 1, Parent = subBar }, { Corner(4) })
            local content = New("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Visible = false, LayoutOrder = #Tab._subTabs + 1, Parent = contentContainer }, { New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })
            SubTab.Content, SubTab.Button = content, sbtn
            function SubTab:Select()
                for _, st in ipairs(Tab._subTabs) do
                    st.Content.Visible = false; st.Button.TextColor3 = Library.Theme.TextDim; Tween(st.Button, 0.2, { BackgroundTransparency = 1 })
                end
                content.Visible = true; sbtn.TextColor3 = Library.Theme.Text; Tween(sbtn, 0.2, { BackgroundTransparency = 0.5 })
            end
            sbtn.MouseButton1Click:Connect(function() SubTab:Select() end)
            table.insert(Tab._subTabs, SubTab)
            if #Tab._subTabs == 1 then SubTab:Select() end
            function SubTab:AddSection(title, icon) return CreateSection(content, title, icon, Window, #SubTab.Sections + 1) end
            return SubTab
        end

        function Tab:Select()
            if Window.CurrentTab == Tab then return end
            for _, t in ipairs(Window.Tabs) do
                t.Indicator.Visible = false; t.TabIcon.ImageColor3 = Library.Theme.TextDim; t.TabLabel.TextColor3 = Library.Theme.TextDim
                Tween(t.Button, 0.2, { BackgroundTransparency = 1 }); if t.Page then t.Page.Visible = false end
            end
            Window.CurrentTab = Tab; indicator.Visible = true; ico.ImageColor3 = Library.Theme.Accent; lbl.TextColor3 = Library.Theme.Text
            Tween(btn, 0.2, { BackgroundTransparency = 0.55 }); page.Visible = true
        end

        btn.MouseEnter:Connect(function() if Window.CurrentTab ~= Tab then Tween(btn, 0.15, { BackgroundTransparency = 0.85 }); lbl.TextColor3 = Library.Theme.Text; ico.ImageColor3 = Library.Theme.Text end end)
        btn.MouseLeave:Connect(function() if Window.CurrentTab ~= Tab then Tween(btn, 0.15, { BackgroundTransparency = 1 }); lbl.TextColor3 = Library.Theme.TextDim; ico.ImageColor3 = Library.Theme.TextDim end end)
        btn.MouseButton1Click:Connect(function() Tab:Select() end)
        
        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then Tab:Select() end

        function Tab:AddSection(title, icon, side)
            local col = (side == "Right") and rightCol or leftCol
            return CreateSection(col, title, icon, Window, #Tab.Sections + 1)
        end
        return Tab
    end

    function Window:Destroy()
        if blur then blur:Destroy() end
        if gui then gui:Destroy() end
    end
    return Window
end

function Library:Notify(o)
    if type(o) == "string" then o = { Title = "Notification", Text = o } end
    if not o or not Library.NotifyHolder then return end
    local title = o.Title or "Notification"
    local text = o.Text or ""
    local duration = o.Duration or 5
    local ntype = o.Type or "Info"
    local color = Library.Theme.Accent
    if ntype == "Success" then color = Color3.fromRGB(80, 220, 140)
    elseif ntype == "Warning" then color = Color3.fromRGB(255, 200, 80)
    elseif ntype == "Error" then color = Color3.fromRGB(255, 88, 108) end
    
    local wrapper = New("Frame", { Size = UDim2.fromOffset(280, 60), BackgroundTransparency = 1, Parent = Library.NotifyHolder })
    local frame = New("Frame", { Size = UDim2.fromScale(1, 1), Position = UDim2.new(0, 300, 0, 0), BackgroundColor3 = Library.Theme.Panel, BackgroundTransparency = 0.1, Parent = wrapper }, { Corner(4), Stroke(Library.Theme.Stroke, 0, 2), Gradient() })
    local line = New("Frame", { Size = UDim2.new(0, 3, 1, -8), Position = UDim2.fromOffset(0, 4), BackgroundColor3 = color, BorderSizePixel = 0, Parent = frame }, { Corner(2) })
    table.insert(Library.ThemeListeners, function(t) frame.BackgroundColor3 = t.Panel; if ntype == "Info" then line.BackgroundColor3 = t.Accent end end)
    Label({ Text = title, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Library.Theme.Text, Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -20, 0, 16), Parent = frame })
    Label({ Text = text, TextSize = 12, TextColor3 = Library.Theme.TextDim, Position = UDim2.fromOffset(14, 26), Size = UDim2.new(1, -20, 0, 28), TextWrapped = true, Parent = frame })
    Tween(frame, 0.3, { Position = UDim2.new(0, 0, 0, 0) })
    task.delay(duration, function()
        local tw = Tween(frame, 0.3, { Position = UDim2.new(0, 300, 0, 0) })
        if tw then tw.Completed:Connect(function() pcall(function() wrapper:Destroy() end) end)
        else pcall(function() wrapper:Destroy() end) end
    end)
end

local CONFIG_FOLDER = "DeepSeekV41Flash"

local function ensureConfigFolder()
    if not (isfolder and isfile and writefile and readfile and makefolder) then return false end
    return pcall(function()
        if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
        if not isfolder(CONFIG_FOLDER .. "/configs") then makefolder(CONFIG_FOLDER .. "/configs") end
    end)
end

function Library:SaveConfig(name)
    if not ensureConfigFolder() then self:Notify({ Title = "Config", Text = "File IO unsupported", Type = "Error" }); return false end
    local data = {}
    for flag, val in pairs(Library.Flags) do
        if typeof(val) == "Color3" then data[flag] = { __t = "c3", r = val.R, g = val.G, b = val.B }
        elseif typeof(val) == "EnumItem" then data[flag] = { __t = "e", enum = val.EnumType.Name, name = val.Name }
        else data[flag] = val end
    end
    local ok, err = pcall(function() writefile(CONFIG_FOLDER .. "/configs/" .. name .. ".json", HttpService:JSONEncode(data)) end)
    if ok then self:Notify({ Title = "Config", Text = "Saved: " .. name, Type = "Success" }); return true end
    self:Notify({ Title = "Config Error", Text = tostring(err), Type = "Error" }); return false
end

function Library:LoadConfig(name)
    if not ensureConfigFolder() then self:Notify({ Title = "Config", Text = "File IO unsupported", Type = "Error" }); return false end
    local path = CONFIG_FOLDER .. "/configs/" .. name .. ".json"
    if not isfile(path) then self:Notify({ Title = "Config", Text = "Not found: " .. name, Type = "Warning" }); return false end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if not ok then self:Notify({ Title = "Config Error", Text = tostring(data), Type = "Error" }); return false end
    for flag, val in pairs(data) do
        if type(val) == "table" and val.__t == "c3" then Library.Flags[flag] = Color3.new(val.r, val.g, val.b)
        elseif type(val) == "table" and val.__t == "e" then
            local enum = Enum[val.enum]
            if enum and enum[val.name] then Library.Flags[flag] = enum[val.name] end
        else Library.Flags[flag] = val end
    end
    for flag, setter in pairs(Library.Registry) do
        if Library.Flags[flag] ~= nil then pcall(setter, Library.Flags[flag]) end
    end
    self:Notify({ Title = "Config", Text = "Loaded: " .. name, Type = "Success" }); return true
end

function Library:DeleteConfig(name)
    if not ensureConfigFolder() then self:Notify({ Title = "Config", Text = "File IO unsupported", Type = "Error" }); return false end
    local path = CONFIG_FOLDER .. "/configs/" .. name .. ".json"
    if not isfile(path) then self:Notify({ Title = "Config", Text = "Not found: " .. name, Type = "Warning" }); return false end
    local ok = pcall(function() delfile(path) end)
    if ok then self:Notify({ Title = "Config", Text = "Deleted: " .. name, Type = "Success" }); return true end
    self:Notify({ Title = "Config Error", Text = "Delete failed", Type = "Error" }); return false
end

function Library:CreateWindow(cfg)
    return BuildWindow(self, cfg)
end

return Library
