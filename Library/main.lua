-- Swift Hub - Modular UI Framework
-- Features: Easy tab creation, toggle buttons, sliders, keybinds, ESP system, and more

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

-- Player
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- Swift Hub Framework
local SwiftHub = {
    Config = {
        Keybind = Enum.KeyCode.RightControl,
        Open = false,
        ChangingKeybind = false,
        CurrentKeybindToChange = nil
    },
    
    Themes = {
        Background = Color3.fromRGB(15, 15, 20),
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
    
    -- Modules storage
    Tabs = {},
    Elements = {},
    Callbacks = {}
}

-- Rainbow color generator
SwiftHub.Rainbow = {
    Hue = 0,
    Update = function(self, speed)
        self.Hue = (self.Hue + speed * 0.01) % 1
        return Color3.fromHSV(self.Hue, 1, 1)
    end
}

-- Keybind manager
SwiftHub.Keybinds = {
    Active = {},
    Pressed = {},
    
    Bind = function(self, key, callback)
        self.Active[key] = callback
    end,
    
    Unbind = function(self, key)
        self.Active[key] = nil
    end
}

-- Drawing utilities
SwiftHub.Drawing = {
    Circle = function(properties)
        local drawing = Drawing.new("Circle")
        for prop, value in pairs(properties) do
            drawing[prop] = value
        end
        return drawing
    end,
    
    Line = function(properties)
        local drawing = Drawing.new("Line")
        for prop, value in pairs(properties) do
            drawing[prop] = value
        end
        return drawing
    end,
    
    Text = function(properties)
        local drawing = Drawing.new("Text")
        for prop, value in pairs(properties) do
            drawing[prop] = value
        end
        return drawing
    end
}

-- Math utilities
SwiftHub.Math = {
    Clamp = function(value, min, max)
        return math.max(min, math.min(max, value))
    end,
    
    Lerp = function(a, b, t)
        return a + (b - a) * SwiftHub.Math.Clamp(t, 0, 1)
    end,
    
    Round = function(num, decimalPlaces)
        local mult = 10^(decimalPlaces or 0)
        return math.floor(num * mult + 0.5) / mult
    end
}

-- ====================
-- CORE UI FRAMEWORK
-- ====================

-- Create a new tab
function SwiftHub:CreateTab(name)
    if self.Tabs[name] then return self.Tabs[name] end
    
    local tabData = {
        Name = name,
        Elements = {},
        Callbacks = {}
    }
    
    self.Tabs[name] = tabData
    return tabData
end

-- Create a section (header) in tab
function SwiftHub:CreateSection(parent, name)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Name = name .. "Section"
    SectionFrame.Size = UDim2.new(1, 0, 0, 40)
    SectionFrame.BackgroundTransparency = 1
    SectionFrame.LayoutOrder = #parent:GetChildren()
    SectionFrame.Parent = parent
    
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Name = "Label"
    SectionLabel.Size = UDim2.new(1, 0, 1, 0)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Text = name
    SectionLabel.TextColor3 = self.Themes.SubText
    SectionLabel.TextSize = 14
    SectionLabel.Font = Enum.Font.GothamSemibold
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.Parent = SectionFrame
    
    return SectionFrame
end

-- Create a toggle button
function SwiftHub:CreateToggle(parent, name, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name .. "Toggle"
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.LayoutOrder = #parent:GetChildren()
    ToggleFrame.Parent = parent
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "Label"
    ToggleLabel.Size = UDim2.new(0, 200, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = self.Themes.Text
    ToggleLabel.TextSize = 16
    ToggleLabel.Font = Enum.Font.GothamSemibold
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "Button"
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(1, -50, 0.5, -10)
    ToggleButton.BackgroundColor3 = default and self.Themes.Success or self.Themes.Secondary
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    ToggleButton.Parent = ToggleFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleButton
    
    local ToggleDot = Instance.new("Frame")
    ToggleDot.Name = "Dot"
    ToggleDot.Size = UDim2.new(0, 16, 0, 16)
    ToggleDot.Position = UDim2.new(0, default and 22 or 2, 0, 2)
    ToggleDot.BackgroundColor3 = self.Themes.Text
    ToggleDot.Parent = ToggleButton
    
    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = ToggleDot
    
    local state = default
    
    local function updateToggle()
        TweenService:Create(ToggleDot, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, state and 22 or 2, 0, 2)
        }):Play()
        
        TweenService:Create(ToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = state and self.Themes.Success or self.Themes.Secondary
        }):Play()
        
        if callback then
            callback(state)
        end
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
    end)
    
    updateToggle()
    
    -- Store element
    local elementId = #self.Elements + 1
    self.Elements[elementId] = {
        Type = "Toggle",
        Name = name,
        Get = function() return state end,
        Set = function(newState)
            state = newState
            updateToggle()
        end,
        Toggle = function()
            state = not state
            updateToggle()
        end
    }
    
    return self.Elements[elementId]
end

-- Create a toggle with keybind
function SwiftHub:CreateToggleWithKeybind(parent, name, defaultState, defaultKey, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name .. "Toggle"
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.LayoutOrder = #parent:GetChildren()
    ToggleFrame.Parent = parent
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "Label"
    ToggleLabel.Size = UDim2.new(0, 200, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = self.Themes.Text
    ToggleLabel.TextSize = 16
    ToggleLabel.Font = Enum.Font.GothamSemibold
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "Button"
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(0.7, -20, 0.5, -10)
    ToggleButton.BackgroundColor3 = defaultState and self.Themes.Success or self.Themes.Secondary
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    ToggleButton.Parent = ToggleFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleButton
    
    local ToggleDot = Instance.new("Frame")
    ToggleDot.Name = "Dot"
    ToggleDot.Size = UDim2.new(0, 16, 0, 16)
    ToggleDot.Position = UDim2.new(0, defaultState and 22 or 2, 0, 2)
    ToggleDot.BackgroundColor3 = self.Themes.Text
    ToggleDot.Parent = ToggleButton
    
    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = ToggleDot
    
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Name = "Keybind"
    KeybindButton.Size = UDim2.new(0, 60, 0, 20)
    KeybindButton.Position = UDim2.new(1, -70, 0.5, -10)
    KeybindButton.BackgroundColor3 = self.Themes.Secondary
    KeybindButton.Text = tostring(defaultKey.Name):gsub("Enum.UserInputType.", "")
    KeybindButton.TextColor3 = self.Themes.Text
    KeybindButton.TextSize = 12
    KeybindButton.Font = Enum.Font.Gotham
    KeybindButton.Parent = ToggleFrame
    
    local KeybindCorner = Instance.new("UICorner")
    KeybindCorner.CornerRadius = UDim.new(0, 4)
    KeybindCorner.Parent = KeybindButton
    
    local state = defaultState
    local key = defaultKey
    
    local function updateToggle()
        TweenService:Create(ToggleDot, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, state and 22 or 2, 0, 2)
        }):Play()
        
        TweenService:Create(ToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = state and self.Themes.Success or self.Themes.Secondary
        }):Play()
        
        if callback then
            callback(state, key)
        end
    end
    
    local function updateKeybind(newKey)
        key = newKey
        KeybindButton.Text = tostring(key.Name):gsub("Enum.UserInputType.", "")
        updateToggle()
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
    end)
    
    KeybindButton.MouseButton1Click:Connect(function()
        if self.Config.ChangingKeybind then
            self.Config.ChangingKeybind = false
            KeybindButton.BackgroundColor3 = self.Themes.Secondary
            return
        end
        
        self.Config.ChangingKeybind = true
        self.Config.CurrentKeybindToChange = {
            SetKey = function(newKey)
                updateKeybind(newKey)
            end
        }
        KeybindButton.BackgroundColor3 = self.Themes.Warning
        KeybindButton.Text = "PRESS KEY..."
    end)
    
    -- Bind the key
    self.Keybinds:Bind(key, function()
        state = not state
        updateToggle()
    end)
    
    updateToggle()
    
    -- Store element
    local elementId = #self.Elements + 1
    self.Elements[elementId] = {
        Type = "ToggleWithKeybind",
        Name = name,
        GetState = function() return state end,
        SetState = function(newState)
            state = newState
            updateToggle()
        end,
        GetKey = function() return key end,
        SetKey = function(newKey)
            updateKeybind(newKey)
        end
    }
    
    return self.Elements[elementId]
end

-- Create a slider
function SwiftHub:CreateSlider(parent, name, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = name .. "Slider"
    SliderFrame.Size = UDim2.new(1, 0, 0, 60)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.LayoutOrder = #parent:GetChildren()
    SliderFrame.Parent = parent
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Name = "Label"
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = name .. ": " .. tostring(default)
    SliderLabel.TextColor3 = self.Themes.Text
    SliderLabel.TextSize = 16
    SliderLabel.Font = Enum.Font.GothamSemibold
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Name = "Track"
    SliderTrack.Size = UDim2.new(1, 0, 0, 6)
    SliderTrack.Position = UDim2.new(0, 0, 0, 30)
    SliderTrack.BackgroundColor3 = self.Themes.Secondary
    SliderTrack.Parent = SliderFrame
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = SliderTrack
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "Fill"
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = self.Themes.Accent
    SliderFill.Parent = SliderTrack
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SliderFill
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Name = "Button"
    SliderButton.Size = UDim2.new(0, 20, 0, 20)
    SliderButton.Position = UDim2.new((default - min) / (max - min), -10, 0, -7)
    SliderButton.BackgroundColor3 = self.Themes.Text
    SliderButton.Text = ""
    SliderButton.AutoButtonColor = false
    SliderButton.Parent = SliderFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(1, 0)
    ButtonCorner.Parent = SliderButton
    
    local dragging = false
    local currentValue = default
    
    local function updateValue(value)
        currentValue = math.clamp(value, min, max)
        local percent = (currentValue - min) / (max - min)
        
        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
        SliderButton.Position = UDim2.new(percent, -10, 0, -7)
        SliderLabel.Text = name .. ": " .. string.format("%.0f", currentValue)
        
        if callback then
            callback(currentValue)
        end
    end
    
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    SliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local percent = (input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
            updateValue(min + (max - min) * math.clamp(percent, 0, 1))
        end
    end)
    
    Mouse.Move:Connect(function()
        if dragging then
            local percent = (Mouse.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
            updateValue(min + (max - min) * math.clamp(percent, 0, 1))
        end
    end)
    
    updateValue(default)
    
    -- Store element
    local elementId = #self.Elements + 1
    self.Elements[elementId] = {
        Type = "Slider",
        Name = name,
        Get = function() return currentValue end,
        Set = function(value)
            updateValue(value)
        end
    }
    
    return self.Elements[elementId]
end

-- Create a button
function SwiftHub:CreateButton(parent, name, callback)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Name = name .. "Button"
    ButtonFrame.Size = UDim2.new(1, 0, 0, 40)
    ButtonFrame.BackgroundTransparency = 1
    ButtonFrame.LayoutOrder = #parent:GetChildren()
    ButtonFrame.Parent = parent
    
    local Button = Instance.new("TextButton")
    Button.Name = "Button"
    Button.Size = UDim2.new(0.5, 0, 1, 0)
    Button.Position = UDim2.new(0.25, 0, 0, 0)
    Button.BackgroundColor3 = self.Themes.Primary
    Button.Text = name
    Button.TextColor3 = self.Themes.Text
    Button.TextSize = 16
    Button.Font = Enum.Font.GothamSemibold
    Button.AutoButtonColor = false
    Button.Parent = ButtonFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(
                math.floor(self.Themes.Primary.R * 255 * 1.2),
                math.floor(self.Themes.Primary.G * 255 * 1.2),
                math.floor(self.Themes.Primary.B * 255 * 1.2)
            )
        }):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Themes.Primary
        }):Play()
    end)
    
    -- Store element
    local elementId = #self.Elements + 1
    self.Elements[elementId] = {
        Type = "Button",
        Name = name,
        Fire = function()
            if callback then
                callback()
            end
        end
    }
    
    return self.Elements[elementId]
end

-- Create a keybind button
function SwiftHub:CreateKeybind(parent, name, defaultKey, callback)
    local KeybindFrame = Instance.new("Frame")
    KeybindFrame.Name = name .. "Keybind"
    KeybindFrame.Size = UDim2.new(1, 0, 0, 40)
    KeybindFrame.BackgroundTransparency = 1
    KeybindFrame.LayoutOrder = #parent:GetChildren()
    KeybindFrame.Parent = parent
    
    local KeybindLabel = Instance.new("TextLabel")
    KeybindLabel.Name = "Label"
    KeybindLabel.Size = UDim2.new(0, 200, 1, 0)
    KeybindLabel.BackgroundTransparency = 1
    KeybindLabel.Text = name
    KeybindLabel.TextColor3 = self.Themes.Text
    KeybindLabel.TextSize = 16
    KeybindLabel.Font = Enum.Font.GothamSemibold
    KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeybindLabel.Parent = KeybindFrame
    
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Name = "Button"
    KeybindButton.Size = UDim2.new(0, 80, 0, 30)
    KeybindButton.Position = UDim2.new(1, -90, 0.5, -15)
    KeybindButton.BackgroundColor3 = self.Themes.Secondary
    KeybindButton.Text = tostring(defaultKey.Name):gsub("Enum.KeyCode.", "")
    KeybindButton.TextColor3 = self.Themes.Text
    KeybindButton.TextSize = 14
    KeybindButton.Font = Enum.Font.Gotham
    KeybindButton.Parent = KeybindFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = KeybindButton
    
    local function updateKeybind(key)
        KeybindButton.Text = tostring(key.Name):gsub("Enum.KeyCode.", "")
        if callback then
            callback(key)
        end
    end
    
    KeybindButton.MouseButton1Click:Connect(function()
        if self.Config.ChangingKeybind then
            self.Config.ChangingKeybind = false
            KeybindButton.BackgroundColor3 = self.Themes.Secondary
            return
        end
        
        self.Config.ChangingKeybind = true
        self.Config.CurrentKeybindToChange = {
            SetKey = function(key)
                updateKeybind(key)
            end
        }
        KeybindButton.BackgroundColor3 = self.Themes.Warning
        KeybindButton.Text = "PRESS KEY..."
    end)
    
    updateKeybind(defaultKey)
    
    -- Store element
    local elementId = #self.Elements + 1
    self.Elements[elementId] = {
        Type = "Keybind",
        Name = name,
        Get = function() return defaultKey end,
        Set = function(key)
            updateKeybind(key)
        end
    }
    
    return self.Elements[elementId]
end

-- Create a label
function SwiftHub:CreateLabel(parent, text)
    local LabelFrame = Instance.new("Frame")
    LabelFrame.Name = "LabelFrame"
    LabelFrame.Size = UDim2.new(1, 0, 0, 30)
    LabelFrame.BackgroundTransparency = 1
    LabelFrame.LayoutOrder = #parent:GetChildren()
    LabelFrame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = self.Themes.SubText
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextYAlignment = Enum.TextYAlignment.Center
    Label.TextWrapped = true
    Label.Parent = LabelFrame
    
    -- Store element
    local elementId = #self.Elements + 1
    self.Elements[elementId] = {
        Type = "Label",
        Text = text,
        SetText = function(newText)
            Label.Text = newText
        end
    }
    
    return self.Elements[elementId]
end

-- Create a dropdown
function SwiftHub:CreateDropdown(parent, name, options, default, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = name .. "Dropdown"
    DropdownFrame.Size = UDim2.new(1, 0, 0, 40)
    DropdownFrame.BackgroundTransparency = 1
    DropdownFrame.LayoutOrder = #parent:GetChildren()
    DropdownFrame.ClipsDescendants = true
    DropdownFrame.Parent = parent
    
    local DropdownLabel = Instance.new("TextLabel")
    DropdownLabel.Name = "Label"
    DropdownLabel.Size = UDim2.new(0, 200, 1, 0)
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Text = name
    DropdownLabel.TextColor3 = self.Themes.Text
    DropdownLabel.TextSize = 16
    DropdownLabel.Font = Enum.Font.GothamSemibold
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    DropdownLabel.Parent = DropdownFrame
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Name = "Button"
    DropdownButton.Size = UDim2.new(0, 150, 0, 30)
    DropdownButton.Position = UDim2.new(1, -160, 0.5, -15)
    DropdownButton.BackgroundColor3 = self.Themes.Secondary
    DropdownButton.Text = default
    DropdownButton.TextColor3 = self.Themes.Text
    DropdownButton.TextSize = 14
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.AutoButtonColor = false
    DropdownButton.Parent = DropdownFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = DropdownButton
    
    local OptionsFrame = Instance.new("Frame")
    OptionsFrame.Name = "Options"
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 0, 1, 5)
    OptionsFrame.BackgroundColor3 = self.Themes.Secondary
    OptionsFrame.Visible = false
    OptionsFrame.Parent = DropdownFrame
    
    local OptionsCorner = Instance.new("UICorner")
    OptionsCorner.CornerRadius = UDim.new(0, 6)
    OptionsCorner.Parent = OptionsFrame
    
    local OptionsList = Instance.new("UIListLayout")
    OptionsList.SortOrder = Enum.SortOrder.LayoutOrder
    OptionsList.Parent = OptionsFrame
    
    local open = false
    local selected = default
    
    local function toggleOptions()
        open = not open
        
        if open then
            OptionsFrame.Visible = true
            TweenService:Create(OptionsFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(1, 0, 0, #options * 30)
            }):Play()
        else
            TweenService:Create(OptionsFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
            wait(0.3)
            OptionsFrame.Visible = false
        end
    end
    
    local function selectOption(option)
        selected = option
        DropdownButton.Text = option
        toggleOptions()
        
        if callback then
            callback(option)
        end
    end
    
    DropdownButton.MouseButton1Click:Connect(toggleOptions)
    
    -- Create option buttons
    for _, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Name = option
        OptionButton.Size = UDim2.new(1, 0, 0, 30)
        OptionButton.BackgroundColor3 = self.Themes.Secondary
        OptionButton.Text = option
        OptionButton.TextColor3 = self.Themes.Text
        OptionButton.TextSize = 14
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.AutoButtonColor = false
        OptionButton.LayoutOrder = _
        OptionButton.Parent = OptionsFrame
        
        OptionButton.MouseButton1Click:Connect(function()
            selectOption(option)
        end)
        
        OptionButton.MouseEnter:Connect(function()
            TweenService:Create(OptionButton, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Themes.Primary
            }):Play()
        end)
        
        OptionButton.MouseLeave:Connect(function()
            TweenService:Create(OptionButton, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Themes.Secondary
            }):Play()
        end)
    end
    
    -- Store element
    local elementId = #self.Elements + 1
    self.Elements[elementId] = {
        Type = "Dropdown",
        Name = name,
        Get = function() return selected end,
        Set = function(option)
            selectOption(option)
        end,
        Options = options
    }
    
    return self.Elements[elementId]
end

-- Create a color picker
function SwiftHub:CreateColorPicker(parent, name, defaultColor, callback)
    local ColorFrame = Instance.new("Frame")
    ColorFrame.Name = name .. "Color"
    ColorFrame.Size = UDim2.new(1, 0, 0, 40)
    ColorFrame.BackgroundTransparency = 1
    ColorFrame.LayoutOrder = #parent:GetChildren()
    ColorFrame.Parent = parent
    
    local ColorLabel = Instance.new("TextLabel")
    ColorLabel.Name = "Label"
    ColorLabel.Size = UDim2.new(0, 200, 1, 0)
    ColorLabel.BackgroundTransparency = 1
    ColorLabel.Text = name
    ColorLabel.TextColor3 = self.Themes.Text
    ColorLabel.TextSize = 16
    ColorLabel.Font = Enum.Font.GothamSemibold
    ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    ColorLabel.Parent = ColorFrame
    
    local ColorButton = Instance.new("TextButton")
    ColorButton.Name = "Button"
    ColorButton.Size = UDim2.new(0, 60, 0, 30)
    ColorButton.Position = UDim2.new(1, -70, 0.5, -15)
    ColorButton.BackgroundColor3 = defaultColor
    ColorButton.Text = ""
    ColorButton.AutoButtonColor = false
    ColorButton.Parent = ColorFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = ColorButton
    
    local currentColor = defaultColor
    
    local function openColorPicker()
        -- This is a simplified color picker
        -- You can extend this with a proper color picker UI
        local newColor = Color3.new(math.random(), math.random(), math.random())
        ColorButton.BackgroundColor3 = newColor
        currentColor = newColor
        
        if callback then
            callback(newColor)
        end
    end
    
    ColorButton.MouseButton1Click:Connect(openColorPicker)
    
    -- Store element
    local elementId = #self.Elements + 1
    self.Elements[elementId] = {
        Type = "ColorPicker",
        Name = name,
        Get = function() return currentColor end,
        Set = function(color)
            ColorButton.BackgroundColor3 = color
            currentColor = color
            if callback then
                callback(color)
            end
        end
    }
    
    return self.Elements[elementId]
end

-- ====================
-- ESP SYSTEM
-- ====================

SwiftHub.ESP = {
    Instances = {},
    Drawings = {},
    Enabled = false,
    
    CreateDrawing = function(self, type, properties)
        local drawing = Drawing.new(type)
        for prop, value in pairs(properties) do
            drawing[prop] = value
        end
        return drawing
    end,
    
    ClearESP = function(self, player)
        if self.Instances[player] then
            for _, drawing in pairs(self.Instances[player]) do
                if drawing and drawing.Remove then
                    drawing:Remove()
                end
            end
            self.Instances[player] = nil
        end
    end,
    
    ClearAllESP = function(self)
        for player, drawings in pairs(self.Instances) do
            self:ClearESP(player)
        end
        self.Instances = {}
    end,
    
    UpdateESP = function(self)
        if not self.Enabled then
            self:ClearAllESP()
            return
        end
        
        -- Clear old ESP for players no longer in game
        for player, _ in pairs(self.Instances) do
            if not Players:FindFirstChild(player.Name) then
                self:ClearESP(player)
            end
        end
        
        -- Draw ESP for all players
        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            if player ~= LocalPlayer and character then
                -- Add your ESP drawing logic here
                -- Example: self:DrawBox(player, character)
            end
        end
    end,
    
    Enable = function(self)
        self.Enabled = true
    end,
    
    Disable = function(self)
        self.Enabled = false
        self:ClearAllESP()
    end,
    
    Toggle = function(self)
        self.Enabled = not self.Enabled
        if not self.Enabled then
            self:ClearAllESP()
        end
        return self.Enabled
    end
}

-- ====================
-- CORE UI CREATION
-- ====================

function SwiftHub:CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SwiftHub"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 500, 0, 600)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    MainFrame.BackgroundColor3 = SwiftHub.Themes.Background
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Name = "DropShadow"
    DropShadow.Size = UDim2.new(1, 20, 1, 20)
    DropShadow.Position = UDim2.new(0, -10, 0, -10)
    DropShadow.BackgroundTransparency = 1
    DropShadow.Image = "rbxassetid://1316045217"
    DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow.ImageTransparency = 0.5
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(10, 10, 118, 118)
    DropShadow.ZIndex = 0
    DropShadow.Parent = MainFrame

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "SWIFT HUB"
    Title.TextColor3 = SwiftHub.Themes.Accent
    Title.TextSize = 24
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(0, 200, 0, 20)
    Subtitle.Position = UDim2.new(0, 20, 0, 30)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "modular ui framework • v2.0"
    Subtitle.TextColor3 = SwiftHub.Themes.SubText
    Subtitle.TextSize = 14
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = Header
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -40, 0, 10)
    CloseButton.BackgroundColor3 = SwiftHub.Themes.Secondary
    CloseButton.Text = "×"
    CloseButton.TextColor3 = SwiftHub.Themes.Text
    CloseButton.TextSize = 24
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = Header
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(1, 0)
    CloseCorner.Parent = CloseButton

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -40, 0, 30)
    TabContainer.Position = UDim2.new(0, 20, 0, 60)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 10)
    TabListLayout.Parent = TabContainer

    SwiftHub.TabButtons = {}
    SwiftHub.TabFrames = {}
    
    local TabFrameContainer = Instance.new("Frame")
    TabFrameContainer.Name = "TabFrameContainer"
    TabFrameContainer.Size = UDim2.new(1, -40, 1, -150)
    TabFrameContainer.Position = UDim2.new(0, 20, 0, 100)
    TabFrameContainer.BackgroundTransparency = 1
    TabFrameContainer.Parent = MainFrame
    
    local KeybindToggle = Instance.new("TextButton")
    KeybindToggle.Name = "KeybindToggle"
    KeybindToggle.Size = UDim2.new(0, 120, 0, 30)
    KeybindToggle.Position = UDim2.new(0.5, -60, 1, -40)
    KeybindToggle.BackgroundColor3 = SwiftHub.Themes.Primary
    KeybindToggle.Text = "Toggle UI: RCTRL"
    KeybindToggle.TextColor3 = SwiftHub.Themes.Text
    KeybindToggle.TextSize = 14
    KeybindToggle.Font = Enum.Font.GothamSemibold
    KeybindToggle.Parent = MainFrame
    
    local KeybindCorner = Instance.new("UICorner")
    KeybindCorner.CornerRadius = UDim.new(0, 6)
    KeybindCorner.Parent = KeybindToggle

    SwiftHub.UI = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        Header = Header,
        CloseButton = CloseButton,
        KeybindToggle = KeybindToggle,
        TabContainer = TabContainer,
        TabFrameContainer = TabFrameContainer
    }
    
    CloseButton.MouseButton1Click:Connect(function()
        SwiftHub:ToggleUI()
    end)
    
    KeybindToggle.MouseButton1Click:Connect(function()
        SwiftHub:ToggleUI()
    end)
    
    return ScreenGui
end

-- Add a tab to the UI
function SwiftHub:AddTab(name)
    if self.TabFrames[name] then return self.TabFrames[name] end
    
    -- Create tab button
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(0, 100, 1, 0)
    TabButton.BackgroundColor3 = #self.TabButtons == 0 and self.Themes.Primary or self.Themes.Secondary
    TabButton.Text = name
    TabButton.TextColor3 = #self.TabButtons == 0 and self.Themes.Text or self.Themes.SubText
    TabButton.TextSize = 14
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.LayoutOrder = #self.TabButtons + 1
    TabButton.AutoButtonColor = false
    TabButton.Parent = self.UI.TabContainer
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabButton
    
    -- Create tab frame
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Name = name .. "Frame"
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.ScrollBarThickness = 3
    TabFrame.ScrollBarImageColor3 = self.Themes.Border
    TabFrame.Visible = #self.TabFrames == 0
    TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabFrame.Parent = self.UI.TabFrameContainer
    
    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 10)
    TabList.Parent = TabFrame
    
    TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabFrame.CanvasSize = UDim2.new(0, 0, 0, TabList.AbsoluteContentSize.Y + 10)
    end)
    
    TabButton.MouseButton1Click:Connect(function()
        self:SwitchTab(name)
    end)
    
    self.TabButtons[name] = TabButton
    self.TabFrames[name] = TabFrame
    
    -- Create tab data
    self:CreateTab(name)
    
    return TabFrame
end

-- Switch between tabs
function SwiftHub:SwitchTab(tabName)
    for name, button in pairs(self.TabButtons) do
        if name == tabName then
            button.BackgroundColor3 = self.Themes.Primary
            button.TextColor3 = self.Themes.Text
        else
            button.BackgroundColor3 = self.Themes.Secondary
            button.TextColor3 = self.Themes.SubText
        end
    end
    
    for name, frame in pairs(self.TabFrames) do
        frame.Visible = (name == tabName)
    end
end

-- Toggle UI visibility
function SwiftHub:ToggleUI()
    if not self.UI then return end
    
    self.Config.Open = not self.Config.Open
    self.UI.MainFrame.Visible = self.Config.Open
    
    if self.Config.Open then
        self.UI.MainFrame.BackgroundTransparency = 1
        TweenService:Create(self.UI.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.1
        }):Play()
    end
end

-- ====================
-- EXAMPLE USAGE
-- ====================

function SwiftHub:CreateExampleTabs()
    -- Example: Combat Tab
    local CombatTab = self:AddTab("Combat")
    
    self:CreateSection(CombatTab, "AIMBOT")
    local aimbotToggle = self:CreateToggle(CombatTab, "Enable Aimbot", false, function(state)
        print("Aimbot:", state)
    end)
    
    local aimbotKey = self:CreateToggleWithKeybind(CombatTab, "Aimbot Key", false, Enum.UserInputType.MouseButton2, function(state, key)
        print("Aimbot Key:", state, key)
    end)
    
    local smoothSlider = self:CreateSlider(CombatTab, "Smoothing", 0, 1, 0.2, function(value)
        print("Smoothing:", value)
    end)
    
    self:CreateSection(CombatTab, "TRIGGERBOT")
    self:CreateToggle(CombatTab, "Triggerbot", false, function(state)
        print("Triggerbot:", state)
    end)
    
    -- Example: Visuals Tab
    local VisualsTab = self:AddTab("Visuals")
    
    self:CreateSection(VisualsTab, "ESP")
    local espToggle = self:CreateToggle(VisualsTab, "Enable ESP", false, function(state)
        self.ESP.Enabled = state
        print("ESP:", state)
    end)
    
    self:CreateToggle(VisualsTab, "Box ESP", true, function(state)
        print("Box ESP:", state)
    end)
    
    self:CreateToggle(VisualsTab, "Tracers", true, function(state)
        print("Tracers:", state)
    end)
    
    self:CreateToggle(VisualsTab, "Names", true, function(state)
        print("Names:", state)
    end)
    
    self:CreateSection(VisualsTab, "CHAMS")
    self:CreateToggle(VisualsTab, "Chams", false, function(state)
        print("Chams:", state)
    end)
    
    -- Example: Misc Tab
    local MiscTab = self:AddTab("Misc")
    
    self:CreateSection(MiscTab, "MOVEMENT")
    self:CreateButton(MiscTab, "Teleport to Spawn", function()
        print("Teleporting to spawn...")
    end)
    
    local speedSlider = self:CreateSlider(MiscTab, "WalkSpeed", 16, 100, 16, function(value)
        print("WalkSpeed:", value)
    end)
    
    self:CreateSection(MiscTab, "UTILITIES")
    self:CreateDropdown(MiscTab, "Auto Farm", {"Off", "Coins", "Gems", "Both"}, "Off", function(option)
        print("Auto Farm:", option)
    end)
    
    local colorPicker = self:CreateColorPicker(MiscTab, "ESP Color", Color3.fromRGB(255, 0, 0), function(color)
        print("ESP Color:", color)
    end)
    
    self:CreateSection(MiscTab, "INFORMATION")
    self:CreateLabel(MiscTab, "Welcome to Swift Hub!")
    self:CreateLabel(MiscTab, "A modular UI framework for Roblox")
    
    -- Example: Settings Tab
    local SettingsTab = self:AddTab("Settings")
    
    self:CreateSection(SettingsTab, "CONFIGURATION")
    local uiKeybind = self:CreateKeybind(SettingsTab, "UI Toggle Key", Enum.KeyCode.RightControl, function(key)
        self.Config.Keybind = key
        self.UI.KeybindToggle.Text = "Toggle UI: " .. tostring(key.Name):gsub("Enum.KeyCode.", "")
    end)
    
    self:CreateToggle(SettingsTab, "Rainbow Mode", false, function(state)
        print("Rainbow Mode:", state)
    end)
    
    self:CreateButton(SettingsTab, "Save Config", function()
        print("Configuration saved!")
    end)
    
    self:CreateButton(SettingsTab, "Load Config", function()
        print("Configuration loaded!")
    end)
    
    self:CreateSection(SettingsTab, "ABOUT")
    self:CreateLabel(SettingsTab, "Swift Hub v2.0")
    self:CreateLabel(SettingsTab, "Created for modular UI development")
end

-- ====================
-- INPUT HANDLING
-- ====================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- UI toggle
    if input.KeyCode == SwiftHub.Config.Keybind then
        SwiftHub:ToggleUI()
    end
    
    -- Keybind manager
    if input.UserInputType == Enum.UserInputType.Keyboard then
        SwiftHub.Keybinds.Pressed[input.KeyCode] = true
        if SwiftHub.Keybinds.Active[input.KeyCode] then
            SwiftHub.Keybinds.Active[input.KeyCode]()
        end
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.MouseButton2 then
        SwiftHub.Keybinds.Pressed[input.UserInputType] = true
        if SwiftHub.Keybinds.Active[input.UserInputType] then
            SwiftHub.Keybinds.Active[input.UserInputType]()
        end
    end
    
    -- Keybind changing mode
    if SwiftHub.Config.ChangingKeybind then
        if input.KeyCode ~= Enum.KeyCode.Escape then
            if SwiftHub.Config.CurrentKeybindToChange then
                SwiftHub.Config.CurrentKeybindToChange:SetKey(input.KeyCode)
            end
        end
        SwiftHub.Config.ChangingKeybind = false
        SwiftHub.Config.CurrentKeybindToChange = nil
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        SwiftHub.Keybinds.Pressed[input.KeyCode] = false
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.MouseButton2 then
        SwiftHub.Keybinds.Pressed[input.UserInputType] = false
    end
end)

-- ====================
-- INITIALIZATION
-- ====================

function SwiftHub:Init()
    self:CreateUI()
    self:CreateExampleTabs() -- Remove this line if you don't want example tabs
    
    -- Start ESP update loop
    RunService.RenderStepped:Connect(function()
        self.ESP:UpdateESP()
    end)
    
    print("======================================")
    print("🚀 Swift Hub v2.0 - Modular UI Framework")
    print("======================================")
    print("📌 Press RIGHT CONTROL to toggle UI")
    print("🎯 Features:")
    print("   - Create tabs dynamically")
    print("   - Toggle buttons with/without keybinds")
    print("   - Sliders, buttons, labels")
    print("   - Dropdowns and color pickers")
    print("   - Built-in ESP system")
    print("   - Rainbow color generator")
    print("======================================")
    print("💡 Usage:")
    print("   local CombatTab = SwiftHub:AddTab('Combat')")
    print("   SwiftHub:CreateToggle(CombatTab, 'Aimbot', false, callback)")
    print("   SwiftHub:CreateSlider(CombatTab, 'FOV', 10, 120, 90, callback)")
    print("======================================")
    
    return self
end

-- Start the hub
SwiftHub:Init()

-- Export for external use
return SwiftHub
