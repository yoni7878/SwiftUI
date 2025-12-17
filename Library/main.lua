-- SwiftHub Library v2.0
-- Modern UI library for Roblox scripts
-- Repository: https://github.com/yourusername/swifthub

-- Core Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Library Initialization
local SwiftHub = {
    Version = "2.0.0",
    Theme = "Dark",
    CurrentTab = nil,
    Tabs = {},
    Options = {},
    Unloaded = false
}

-- Default Themes
SwiftHub.Themes = {
    Dark = {
        Background = Color3.fromRGB(20, 20, 25),
        Primary = Color3.fromRGB(0, 100, 255),
        Secondary = Color3.fromRGB(30, 30, 40),
        Accent = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(180, 180, 200),
        Border = Color3.fromRGB(50, 50, 60),
        Success = Color3.fromRGB(0, 200, 100),
        Warning = Color3.fromRGB(255, 150, 0),
        Danger = Color3.fromRGB(255, 50, 50)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        Primary = Color3.fromRGB(0, 120, 255),
        Secondary = Color3.fromRGB(220, 220, 230),
        Accent = Color3.fromRGB(0, 150, 255),
        Text = Color3.fromRGB(30, 30, 40),
        SubText = Color3.fromRGB(100, 100, 120),
        Border = Color3.fromRGB(200, 200, 210),
        Success = Color3.fromRGB(0, 180, 80),
        Warning = Color3.fromRGB(230, 120, 0),
        Danger = Color3.fromRGB(220, 40, 40)
    }
}

-- Utility Functions
function SwiftHub:Create(class, props)
    local instance = Instance.new(class)
    for prop, value in pairs(props) do
        if prop ~= "Parent" then
            if pcall(function() return instance[prop] end) then
                instance[prop] = value
            end
        end
    end
    if props.Parent then
        instance.Parent = props.Parent
    end
    return instance
end

function SwiftHub:Round(num, decimalPlaces)
    local mult = 10^(decimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Notification System
function SwiftHub:Notify(options)
    local notification = {
        Title = options.Title or "Notification",
        Content = options.Content or "",
        SubContent = options.SubContent,
        Duration = options.Duration or 5
    }
    
    -- Create notification UI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SwiftNotification"
    screenGui.Parent = game:GetService("CoreGui")
    
    local frame = Instance.new("Frame")
    frame.Name = "Notification"
    frame.Size = UDim2.new(0, 300, 0, 120)
    frame.Position = UDim2.new(1, 10, 1, -130)
    frame.BackgroundColor3 = self.Themes[self.Theme].Secondary
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = notification.Title
    title.TextColor3 = self.Themes[self.Theme].Text
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    
    local content = Instance.new("TextLabel")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 0, 40)
    content.Position = UDim2.new(0, 10, 0, 45)
    content.BackgroundTransparency = 1
    content.Text = notification.Content
    content.TextColor3 = self.Themes[self.Theme].Text
    content.TextSize = 14
    content.Font = Enum.Font.Gotham
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.TextWrapped = true
    content.Parent = frame
    
    -- Animate in
    frame.Position = UDim2.new(1, 310, 1, -130)
    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, 10, 1, -130)
    }):Play()
    
    -- Auto-dismiss if duration is set
    if notification.Duration then
        task.spawn(function()
            task.wait(notification.Duration)
            TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, 310, 1, -130)
            }):Play()
            task.wait(0.3)
            screenGui:Destroy()
        end)
    end
end

-- UI Element: Toggle
local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(name, options, parent)
    local self = setmetatable({}, Toggle)
    self.Name = name
    self.Value = options.Default or false
    self.Callback = options.Callback
    self.Parent = parent
    
    -- Create UI
    self.Container = Instance.new("Frame")
    self.Container.Name = name .. "Toggle"
    self.Container.Size = UDim2.new(1, 0, 0, 40)
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = options.Title
    label.TextColor3 = SwiftHub.Themes[SwiftHub.Theme].Text
    label.TextSize = 16
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = self.Container
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle"
    toggleFrame.Size = UDim2.new(0, 50, 0, 24)
    toggleFrame.Position = UDim2.new(1, -60, 0.5, -12)
    toggleFrame.BackgroundColor3 = self.Value and SwiftHub.Themes[SwiftHub.Theme].Success or SwiftHub.Themes[SwiftHub.Theme].Secondary
    toggleFrame.Parent = self.Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = toggleFrame
    
    self.Dot = Instance.new("Frame")
    self.Dot.Name = "Dot"
    self.Dot.Size = UDim2.new(0, 18, 0, 18)
    self.Dot.Position = UDim2.new(0, self.Value and 30 or 2, 0, 3)
    self.Dot.BackgroundColor3 = SwiftHub.Themes[SwiftHub.Theme].Text
    self.Dot.Parent = toggleFrame
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = self.Dot
    
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = self.Container
    
    button.MouseButton1Click:Connect(function()
        self:SetValue(not self.Value)
    end)
    
    return self
end

function Toggle:SetValue(value)
    self.Value = value
    TweenService:Create(self.Dot, TweenInfo.new(0.2), {
        Position = UDim2.new(0, value and 30 or 2, 0, 3)
    }):Play()
    
    TweenService:Create(self.Dot.Parent, TweenInfo.new(0.2), {
        BackgroundColor3 = value and SwiftHub.Themes[SwiftHub.Theme].Success or SwiftHub.Themes[SwiftHub.Theme].Secondary
    }):Play()
    
    if self.Callback then
        self.Callback(value)
    end
    
    -- Update in options table
    if SwiftHub.Options[self.Name] then
        SwiftHub.Options[self.Name].Value = value
    end
end

function Toggle:OnChanged(callback)
    self.Callback = callback
end

-- UI Element: Button
local Button = {}
Button.__index = Button

function Button.new(options, parent)
    local self = setmetatable({}, Button)
    self.Title = options.Title
    self.Callback = options.Callback
    self.Parent = parent
    
    self.Button = Instance.new("TextButton")
    self.Button.Name = options.Title .. "Button"
    self.Button.Size = UDim2.new(1, 0, 0, 40)
    self.Button.BackgroundColor3 = SwiftHub.Themes[SwiftHub.Theme].Secondary
    self.Button.Text = options.Title
    self.Button.TextColor3 = SwiftHub.Themes[SwiftHub.Theme].Text
    self.Button.TextSize = 16
    self.Button.Font = Enum.Font.GothamSemibold
    self.Button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = self.Button
    
    self.Button.MouseButton1Click:Connect(function()
        if self.Callback then
            self.Callback()
        end
    end)
    
    -- Hover effects
    self.Button.MouseEnter:Connect(function()
        TweenService:Create(self.Button, TweenInfo.new(0.2), {
            BackgroundColor3 = SwiftHub.Themes[SwiftHub.Theme].Primary
        }):Play()
    end)
    
    self.Button.MouseLeave:Connect(function()
        TweenService:Create(self.Button, TweenInfo.new(0.2), {
            BackgroundColor3 = SwiftHub.Themes[SwiftHub.Theme].Secondary
        }):Play()
    end)
    
    return self
end

-- UI Element: Slider
local Slider = {}
Slider.__index = Slider

function Slider.new(name, options, parent)
    local self = setmetatable({}, Slider)
    self.Name = name
    self.Value = options.Default or options.Min or 0
    self.Min = options.Min or 0
    self.Max = options.Max or 100
    self.Rounding = options.Rounding or 1
    self.Callback = options.Callback
    self.Parent = parent
    
    self.Container = Instance.new("Frame")
    self.Container.Name = name .. "Slider"
    self.Container.Size = UDim2.new(1, 0, 0, 60)
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = parent
    
    self.Label = Instance.new("TextLabel")
    self.Label.Name = "Label"
    self.Label.Size = UDim2.new(1, 0, 0, 20)
    self.Label.BackgroundTransparency = 1
    self.Label.Text = options.Title .. ": " .. tostring(self.Value)
    self.Label.TextColor3 = SwiftHub.Themes[SwiftHub.Theme].Text
    self.Label.TextSize = 16
    self.Label.Font = Enum.Font.GothamSemibold
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Parent = self.Container
    
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 35)
    track.BackgroundColor3 = SwiftHub.Themes[SwiftHub.Theme].Secondary
    track.Parent = self.Container
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    self.Fill = Instance.new("Frame")
    self.Fill.Name = "Fill"
    self.Fill.Size = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), 0, 1, 0)
    self.Fill.BackgroundColor3 = SwiftHub.Themes[SwiftHub.Theme].Accent
    self.Fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = self.Fill
    
    self.Thumb = Instance.new("TextButton")
    self.Thumb.Name = "Thumb"
    self.Thumb.Size = UDim2.new(0, 20, 0, 20)
    self.Thumb.Position = UDim2.new((self.Value - self.Min) / (self.Max - self.Min), -10, 0, -7)
    self.Thumb.BackgroundColor3 = SwiftHub.Themes[SwiftHub.Theme].Text
    self.Thumb.Text = ""
    self.Thumb.Parent = self.Container
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = self.Thumb
    
    -- Drag functionality
    local dragging = false
    
    local function updateValue(x)
        local percent = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = self.Min + (self.Max - self.Min) * percent
        value = SwiftHub:Round(value, self.Rounding)
        
        self.Value = value
        self.Fill.Size = UDim2.new(percent, 0, 1, 0)
        self.Thumb.Position = UDim2.new(percent, -10, 0, -7)
        self.Label.Text = options.Title .. ": " .. tostring(value)
        
        if self.Callback then
            self.Callback(value)
        end
        
        -- Update options table
        if SwiftHub.Options[self.Name] then
            SwiftHub.Options[self.Name].Value = value
        end
    end
    
    self.Thumb.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    track.MouseButton1Down:Connect(function(x, y)
        updateValue(x)
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            updateValue(input.Position.X)
        end
    end)
    
    return self
end

function Slider:SetValue(value)
    value = math.clamp(value, self.Min, self.Max)
    value = SwiftHub:Round(value, self.Rounding)
    
    self.Value = value
    local percent = (value - self.Min) / (self.Max - self.Min)
    self.Fill.Size = UDim2.new(percent, 0, 1, 0)
    self.Thumb.Position = UDim2.new(percent, -10, 0, -7)
    self.Label.Text = self.Label.Text:gsub(": .+$", ": " .. tostring(value))
    
    if self.Callback then
        self.Callback(value)
    end
end

function Slider:OnChanged(callback)
    self.Callback = callback
end

-- Tab Class
local Tab = {}
Tab.__index = Tab

function Tab.new(title, icon, window)
    local self = setmetatable({}, Tab)
    self.Title = title
    self.Icon = icon
    self.Window = window
    self.Elements = {}
    
    -- Create tab button
    self.Button = Instance.new("TextButton")
    self.Button.Name = title .. "Tab"
    self.Button.Size = UDim2.new(0, window.Config.TabWidth, 0, 40)
    self.Button.BackgroundColor3 = SwiftHub.Themes[SwiftHub.Theme].Secondary
    self.Button.Text = icon .. " " .. title
    self.Button.TextColor3 = SwiftHub.Themes[SwiftHub.Theme].SubText
    self.Button.TextSize = 14
    self.Button.Font = Enum.Font.GothamSemibold
    self.Button.AutoButtonColor = false
    self.Button.Parent = window.TabContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = self.Button
    
    -- Create tab content
    self.Content = Instance.new("ScrollingFrame")
    self.Content.Name = title .. "Content"
    self.Content.Size = UDim2.new(1, -40, 1, -120)
    self.Content.Position = UDim2.new(0, 20, 0, 100)
    self.Content.BackgroundTransparency = 1
    self.Content.ScrollBarThickness = 3
    self.Content.ScrollBarImageColor3 = SwiftHub.Themes[SwiftHub.Theme].Border
    self.Content.Visible = false
    self.Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.Content.Parent = window.MainFrame
    
    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 10)
    list.Parent = self.Content
    
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Content.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y)
    end)
    
    -- Button click handler
    self.Button.MouseButton1Click:Connect(function()
        self.Window:SelectTab(self)
    end)
    
    return self
end

function Tab:AddToggle(name, options)
    local toggle = Toggle.new(name, options, self.Content)
    self.Elements[#self.Elements + 1] = toggle
    SwiftHub.Options[name] = {Type = "Toggle", Value = toggle.Value, Object = toggle}
    return toggle
end

function Tab:AddButton(options)
    local button = Button.new(options, self.Content)
    self.Elements[#self.Elements + 1] = button
    return button
end

function Tab:AddSlider(name, options)
    local slider = Slider.new(name, options, self.Content)
    self.Elements[#self.Elements + 1] = slider
    SwiftHub.Options[name] = {Type = "Slider", Value = slider.Value, Object = slider}
    return slider
end

function Tab:AddParagraph(options)
    local container = Instance.new("Frame")
    container.Name = "Paragraph"
    container.Size = UDim2.new(1, 0, 0, 60)
    container.BackgroundTransparency = 1
    container.Parent = self.Content
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = options.Title
    title.TextColor3 = SwiftHub.Themes[SwiftHub.Theme].Text
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = container
    
    local content = Instance.new("TextLabel")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0, 40)
    content.Position = UDim2.new(0, 0, 0, 20)
    content.BackgroundTransparency = 1
    content.Text = options.Content
    content.TextColor3 = SwiftHub.Themes[SwiftHub.Theme].SubText
    content.TextSize = 14
    content.Font = Enum.Font.Gotham
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.TextWrapped = true
    content.Parent = container
    
    self.Elements[#self.Elements + 1] = container
    return container
end

-- Window Class
local Window = {}
Window.__index = Window

function Window:CreateWindow(config)
    local self = setmetatable({}, Window)
    self.Config = config
    self.Tabs = {}
    
    -- Apply theme
    if config.Theme then
        SwiftHub.Theme = config.Theme
    end
    
    -- Create screen GUI
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SwiftHub"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Create main frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = config.Size or UDim2.new(0, 580, 0, 460)
    self.MainFrame.Position = UDim2.new(0.5, -self.MainFrame.Size.X.Offset/2, 0.5, -self.MainFrame.Size.Y.Offset/2)
    self.MainFrame.BackgroundColor3 = SwiftHub.Themes[SwiftHub.Theme].Background
    self.MainFrame.BackgroundTransparency = 0.1
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Visible = false
    self.MainFrame.Parent = self.ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.MainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundTransparency = 1
    header.Parent = self.MainFrame
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -100, 0, 30)
    title.Position = UDim2.new(0, 20, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Swift Hub"
    title.TextColor3 = SwiftHub.Themes[SwiftHub.Theme].Accent
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, -100, 0, 20)
    subtitle.Position = UDim2.new(0, 20, 0, 35)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = config.SubTitle or "v" .. SwiftHub.Version
    subtitle.TextColor3 = SwiftHub.Themes[SwiftHub.Theme].SubText
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = header
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 15)
    closeBtn.BackgroundColor3 = SwiftHub.Themes[SwiftHub.Theme].Secondary
    closeBtn.Text = "×"
    closeBtn.TextColor3 = SwiftHub.Themes[SwiftHub.Theme].Text
    closeBtn.TextSize = 24
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Tab container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, config.TabWidth or 160, 1, -120)
    self.TabContainer.Position = UDim2.new(0, 10, 0, 70)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.Parent = self.MainFrame
    
    local tabList = Instance.new("UIListLayout")
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Padding = UDim.new(0, 5)
    tabList.Parent = self.TabContainer
    
    -- Make draggable
    self:Draggable(header)
    
    -- Minimize keybind
    if config.MinimizeKey then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == config.MinimizeKey then
                self.MainFrame.Visible = not self.MainFrame.Visible
            end
        end)
    end
    
    return self
end

function Window:AddTab(options)
    local tab = Tab.new(options.Title, options.Icon or "", self)
    self.Tabs[#self.Tabs + 1] = tab
    
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    return tab
end

function Window:SelectTab(tab)
    for _, t in ipairs(self.Tabs) do
        t.Content.Visible = false
        t.Button.BackgroundColor3 = SwiftHub.Themes[SwiftHub.Theme].Secondary
        t.Button.TextColor3 = SwiftHub.Themes[SwiftHub.Theme].SubText
    end
    
    tab.Content.Visible = true
    tab.Button.BackgroundColor3 = SwiftHub.Themes[SwiftHub.Theme].Primary
    tab.Button.TextColor3 = SwiftHub.Themes[SwiftHub.Theme].Text
    
    SwiftHub.CurrentTab = tab
end

function Window:Draggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Window:Destroy()
    self.ScreenGui:Destroy()
    SwiftHub.Unloaded = true
end

function Window:Dialog(options)
    local dialog = Instance.new("Frame")
    dialog.Name = "Dialog"
    dialog.Size = UDim2.new(0, 300, 0, 200)
    dialog.Position = UDim2.new(0.5, -150, 0.5, -100)
    dialog.BackgroundColor3 = SwiftHub.Themes[SwiftHub.Theme].Secondary
    dialog.BorderSizePixel = 0
    dialog.Parent = self.MainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = dialog
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = options.Title
    title.TextColor3 = SwiftHub.Themes[SwiftHub.Theme].Text
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = dialog
    
    local content = Instance.new("TextLabel")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 0, 80)
    content.Position = UDim2.new(0, 10, 0, 60)
    content.BackgroundTransparency = 1
    content.Text = options.Content
    content.TextColor3 = SwiftHub.Themes[SwiftHub.Theme].Text
    content.TextSize = 14
    content.Font = Enum.Font.Gotham
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.TextWrapped = true
    content.Parent = dialog
    
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "Buttons"
    buttonContainer.Size = UDim2.new(1, -20, 0, 40)
    buttonContainer.Position = UDim2.new(0, 10, 1, -50)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = dialog
    
    local buttonList = Instance.new("UIListLayout")
    buttonList.FillDirection = Enum.FillDirection.Horizontal
    buttonList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    buttonList.SortOrder = Enum.SortOrder.LayoutOrder
    buttonList.Padding = UDim.new(0, 10)
    buttonList.Parent = buttonContainer
    
    for i, btnOptions in ipairs(options.Buttons) do
        local btn = Instance.new("TextButton")
        btn.Name = btnOptions.Title
        btn.Size = UDim2.new(0, 80, 0, 30)
        btn.BackgroundColor3 = i == 1 and SwiftHub.Themes[SwiftHub.Theme].Primary or SwiftHub.Themes[SwiftHub.Theme].Secondary
        btn.Text = btnOptions.Title
        btn.TextColor3 = SwiftHub.Themes[SwiftHub.Theme].Text
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamSemibold
        btn.LayoutOrder = i
        btn.Parent = buttonContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            dialog:Destroy()
            if btnOptions.Callback then
                btnOptions.Callback()
            end
        end)
    end
    
    return dialog
end

-- Main Library Function
function SwiftHub:CreateWindow(config)
    local window = Window:CreateWindow(config)
    SwiftHub.CurrentWindow = window
    window.MainFrame.Visible = true
    
    -- Send welcome notification
    task.spawn(function()
        task.wait(0.5)
        self:Notify({
            Title = "Swift Hub",
            Content = "Library loaded successfully!",
            Duration = 3
        })
    end)
    
    return window
end

-- Export the library
return SwiftHub
