--[[
    Interactive UI Version 2.0
]]

local UserInputService = game:GetService('UserInputService');
local TweenService = game:GetService('TweenService');
local RunService = game:GetService('RunService');
local TextService = game:GetService('TextService');
local Players = game.Players;
local LocalPlayer = Players.LocalPlayer;
local Mouse = LocalPlayer:GetMouse();


local Library = {};
local Page = {};
local Utility = {};

Library.__index = Library;
Page.__index = Page;

function TypeChecker(value: string, type: string | table | number): boolean
    return typeof(value) == type;
end

-- function Utility:Sort(table: table, pattern: string): Array
--     if (not TypeChecker(table, 'table') or not TypeChecker(pattern, 'string')) then return table end;

--     local result = {};
--     pattern = string.lower(pattern);

--     if (pattern == "" or #table == 0) then return table end;

--     for i,v in pairs (table) do
--         if (not TypeChecker(v, 'string')) then return end;

--         local lower = string.lower(v);

--         if (string.find(lower, pattern)) then
--             table.insert(result, lower);
--         end
--     end

--     return result;
-- end


function Utility:Create(instance: string, properties, child): Instance
    local Instance = Instance.new(instance);

    for i,v in pairs (properties) do
       Instance[i] = v
    end

    for i,v in pairs (child or {}) do
       v.Parent = Instance
    end

    return Instance
end

function Utility:Draggable(frame: Instance, parent: Instance)
    parent = parent or frame

    local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = parent.Position

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
            local delta = input.Position - mousePos
            parent.Position  = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

function Utility:Tween(instance: Instance,properties,duration: number, ...)
    TweenService:Create(instance,TweenInfo.new(duration, ...),properties):Play()
end

function Utility:InputInitalizer()
    self.ended = {};
    self.binds = {};

    UserInputService.InputBegan:Connect(function(key)
        if (self.binds[key.KeyCode]) then
            for _,v in pairs (self.binds[key.KeyCode]) do
                v();
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(key)
        if (key.UserInputType == Enum.UserInputType.MouseButton1) then
            for _,v in pairs(self.ended) do
                v();
            end
        end
    end)
end
function Utility:InsertBind(key, callback)
    self.binds[key.KeyCode] = self.binds[key.KeyCode] or {};

    table.insert(self.binds[key.KeyCode], callback);

    return {
        reset = function()
            for i,v in pairs (self.binds[key.KeyCode]) do
                if (v == callback) then
                    self.binds[key.KeyCode][i] = nil;
                end
            end
        end
    }
end

function Utility:DraggingEnded(callback)
    table.insert(self.ended, callback);
end

function Utility:ResetDraggingEnded()
    self.ended = {};
end

function Utility:HsvToRgb(h,s,v)
    local r,g,b,i,f,p,q,t;

    i = math.floor(h * 6)
    f = h * 6 - i
    p = v * (1 - s)
    q = v * ( 1 - f * s)
    t = v * (1 - (1 - f) * s)

    local newI = i % 6

    if (newI == 0) then
       r = v
       g = t
       b = p
    elseif newI == 1 then
       r = q
       g = v
       b = p
    elseif newI == 2 then
       r = p
       g = v
       b = t
    elseif newI == 3 then
       r = p
       g = q
       b = v
    elseif newI == 4 then
       r = t
       g = p
       b = v
    elseif newI == 5 then
       r = v
       g = p
       b = q
    end

    return {
       r = math.round(r * 255),
       g = math.round(g * 255),
       b = math.round(b * 255)
    }
end

function Utility:KeyDetector()
    local key = UserInputService.InputBegan:Wait();

    while (key.UserInputType ~= Enum.UserInputType.Keyboard) do
        key = UserInputService.InputBegan:Wait();
    end
    RunService.RenderStepped:Wait();

    return key;
end

function Library.new(Title: string)
    local ScreenGui = Utility:Create('ScreenGui', {
        Parent = game:GetService('CoreGui'),
        Name = 'Main'
    }, {
        Utility:Create('ImageLabel', {
            Name = 'Container',
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(27, 28, 33),
            ClipsDescendants = true,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 487, 0, 544),
            Image = "rbxassetid://3570695787",
            ImageColor3 = Color3.fromRGB(27, 28, 33),
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(100, 100, 100, 100),
            SliceScale = 0.02,
        }, {
            Utility:Create('ScrollingFrame', {
                Name = 'Side',
                BackgroundColor3 = Color3.fromRGB(31, 32, 38),
                Position = UDim2.new(0, 0, 0, 50),
                Size = UDim2.new(0, 125, 1, -50),
                ScrollBarThickness = 0,
                BorderSizePixel = 0,
            }, {
                Utility:Create('UIListLayout', {
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 5),
                })
            }),
            Utility:Create('ImageLabel', {
                Name = 'Top',
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 50),
                Image = "rbxassetid://3570695787",
                ImageColor3 = Color3.fromRGB(32, 34, 40),
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(100, 100, 100, 100),
                SliceScale = 0.04,
            }, {
                Utility:Create('TextLabel', {
                    Name = 'Title',
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.0268592276, 0, 0.247999877, 0),
                    Size = UDim2.new(0, 461, 0, 25),
                    Font = Enum.Font.SourceSansBold,
                    Text = Title,
                    TextColor3 = Color3.fromRGB(198, 198, 198),
                    TextSize = 18,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            }),
            Utility:Create('ImageLabel', {
                Name = 'Main',
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                Position = UDim2.new(0, 135, 0, 50),
                Size = UDim2.new(1, -135, 1, -50),
                Image = "rbxassetid://3570695787",
                ImageColor3 = Color3.fromRGB(27, 28, 33),
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(100, 100, 100, 100),
                SliceScale = 0.04,
            }),
            Utility:Create('Frame', {
                Name = 'hr',
                BackgroundColor3 = Color3.fromRGB(36, 37, 44),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 130, 0, 50),
                Size = UDim2.new(0, 1, 1, -50)
            })
        })
    })

    Utility:Draggable(ScreenGui.Container.Top, ScreenGui.Container);
    Utility:InputInitalizer();

    local Container = ScreenGui.Container;

    local ToolTip = Utility:Create('ImageLabel', {
        Name = 'ToolTip',
        Parent = ScreenGui,
        BackgroundTransparency = 1.000,
        Size = UDim2.new(0, 30, 0, 30),
        ZIndex = 100,
        Image = "rbxassetid://3570695787",
        ImageColor3 = Color3.fromRGB(43, 45, 54),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(100, 100, 100, 100),
        SliceScale = 0.02,
        Visible = false,
    }, {
        Utility:Create('TextLabel', {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1.000,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 101,
            Text = '',
            TextColor3 = Color3.fromRGB(186, 186, 186),
            TextSize = 14.000,
            Font = Enum.Font.SourceSans
        })
    });

    Library.ToolTip = ToolTip;

    return setmetatable({
        ScreenGui = ScreenGui,
        Library = self,
        Side = Container.Side,
        Main = Container.Main,
        pages = {},
    }, Library);
end

function Library:moveToolTip(text: string, x, y)
    x,y = x or Mouse.X, y or Mouse.Y;

    local size = TextService:GetTextSize(text, 14, "SourceSans", Vector2.new(math.huge, 30));
    local tooltip: ImageLabel = self.ToolTip;

    tooltip.Size = UDim2.new(0, size.X + 20, 0, size.Y + 10);
    tooltip.Visible = true;
    tooltip.Position = UDim2.new(0, x, 0, y);
    tooltip.TextLabel.Text = text;

    spawn(function()
        wait(1.5);

        tooltip.Visible = false;
    end)
end

-- luau type is something strange
function Page.new(Library, Title: string)
    local PageButton: TextButton = Utility:Create('TextButton', {
        Name = 'Item',
        Parent = Library.Side,
        BorderColor3 = Color3.fromRGB(27, 42, 53),
        Size = UDim2.new(1, 0, 0, 25),
        Font = Enum.Font.GothamSemibold,
        TextColor3 = Color3.fromRGB(60, 62, 71),
        TextSize = 12.000,
        TextWrapped = true,
        Text = Title,
        BackgroundColor3 = Color3.fromRGB(31, 32, 38),
        AutoButtonColor = false,
        BorderSizePixel = 0,
    });

    local page = Utility:Create('ScrollingFrame', {
        Name = 'Page',
        Parent = Library.Main,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(25, 26, 31),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, -5, 0, 0),
        ScrollBarThickness = 1,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
    }, {
        Utility:Create('UIListLayout', {
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
        })
    });

    return setmetatable({
        container = page,
        button = PageButton,
        modules = {},
        Library = Library
    }, Page);
end

function Library:addPage(...)
    local page = Page.new(self, ...);
    local button = page.button;

    table.insert(self.pages, page);

    button.MouseButton1Click:Connect(function()
        --todo: change page.
        self:SelectPage(page, true);
    end)
    button.MouseEnter:Connect(function()
        if (page.Library.CurrentPage ~= page) then
            Utility:Tween(button, { BackgroundColor3 = Color3.fromRGB(38, 39, 47) }, 0.2);
        end
    end)
    button.MouseLeave:Connect(function()
        Utility:Tween(button, { BackgroundColor3 = Color3.fromRGB(31, 32, 38) }, 0.2);
    end)

    return page;
end


function Library:SelectPage(page, toggle)
    self.CurrentPage = self.CurrentPage or nil;

    if (toggle and self.CurrentPage == page) then return end;

    if toggle then
        local Toggledpage = self.CurrentPage;
        self.CurrentPage = page;
        if (Toggledpage) then
            self:SelectPage(Toggledpage, false);
        end

        wait(.2)
        page.container.Visible = true;
        page.button.TextColor3 = Color3.fromRGB(70, 76, 98);
        Utility:Tween(page.button, { BackgroundColor3 = Color3.fromRGB(40, 41, 49) }, .2);

        if (Toggledpage) then
            Toggledpage.container.Visible = false;
        end

        wait(.05);

        Utility:Tween(page.container, { Size = UDim2.new(1, -5, 1, -10) }, .2);
        page:Resize(true);
    else
        page.button.TextColor3 = Color3.fromRGB(60, 62, 71);
        Utility:Tween(page.button, { BackgroundColor3 = Color3.fromRGB(31, 32, 38) }, .2);
        self.lastPosition = page.container.CanvasPosition.Y;

        Utility:Tween(page.container, { Size = UDim2.new(1, -5, 0, 0) }, .2);

        wait(.3);
        page:Resize(false);
    end
end

function Page:Resize(scroll)
    local size = self.container.UIListLayout.AbsoluteContentSize.Y;
    self.container.CanvasSize = UDim2.new(0, 0, 0, size);

    if (scroll) then
        Utility:Tween(self.container, { CanvasPosition = self.lastposition or Vector2.new(0, 0)}, .3);
    end
end

function Library:setTheme(ObjectType: string, color: Color3)

end

function Page:addButton(Title: string, ButtonText: string, description: string?, callback: Function)
    local Container: ImageLabel = Utility:Create('ImageLabel', {
        Name = 'Button',
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 40),
        Image = "rbxassetid://3570695787",
        ImageColor3 = Color3.fromRGB(34, 36, 47),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(100, 100, 100, 100),
        SliceScale = 0.04,
        Parent = self.container
    }, {
        Utility:Create('TextLabel', {
            Name = 'Title',
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -100, 0, 20),
            Font = Enum.Font.SourceSans,
            Text = Title,
            TextColor3 = Color3.fromRGB(143, 143, 143),
            TextSize = 17,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        Utility:Create('TextLabel', {
            Name = 'Extra',
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0.5, 0),
            Size = UDim2.new(0, 230, 0, 20),
            Font = Enum.Font.SourceSans,
            Text = description or 'no description.',
            TextColor3 = Color3.fromRGB(84, 84, 84),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        }),
        Utility:Create('TextButton', {
            BackgroundColor3 = Color3.fromRGB(22, 24, 31),
            BorderSizePixel = 0,
            Position = UDim2.new(1, -90, 0.125, 0),
            Size = UDim2.new(0, 80, 0, 30),
            AutoButtonColor = false,
            ZIndex = 2,
            Font = Enum.Font.Gotham,
            Text = ButtonText or 'Execute',
            TextColor3 = Color3.fromRGB(186, 186, 186),
            TextSize = 13
        }, {
            Utility:Create('UICorner', {
               CornerRadius = UDim.new(0, 2)
            })
        })
    })

    local debounce = false;

    local callback = function()
        if (callback) then
            callback()
        end
    end

    local button: TextButton = Container.TextButton;

    button.MouseButton1Click:Connect(function()
        if (debounce) then return end;

        debounce = true;

        Utility:Tween(button, { TextSize = 10 }, .1);
        wait(.1);
        Utility:Tween(button, { TextSize = 13 }, .1);

        debounce = false;
        callback();
    end)

    return Container;
end

function Page:addToggle(Title: string, description: string, default: boolean, callback: Function)
    local Container = Utility:Create('ImageLabel', {
        Name = "Toggle",
        BackgroundTransparency = 1.000,
        Size = UDim2.new(1, -20, 0, 40),
        Image = "rbxassetid://3570695787",
        ImageColor3 = Color3.fromRGB(34, 36, 47),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(100, 100, 100, 100),
        SliceScale = 0.04,
        Parent = self.container
    }, {
        Utility:Create('TextLabel', {
            Name = 'Title',
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -100, 0, 20),
            Font = Enum.Font.SourceSans,
            Text = Title,
            TextColor3 = Color3.fromRGB(143, 143, 143),
            TextSize = 17,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        Utility:Create('TextLabel', {
            Name = 'Extra',
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0.5, 0),
            Size = UDim2.new(0, 230, 0, 20),
            Font = Enum.Font.SourceSans,
            Text = description or 'no description.',
            TextColor3 = Color3.fromRGB(84, 84, 84),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        }),
        Utility:Create('TextButton', {
            Name = "ToggleButton",
            BackgroundColor3 = Color3.fromRGB(22, 24, 31),
            Size = UDim2.new(0, 35, 0, 25),
            AutoButtonColor = false,
            Text = "",
            Position = UDim2.new(1, -45, 0.174999997, 0),
        }, {
            Utility:Create('UICorner', {
                CornerRadius = UDim.new(0, 2),
            }),
            Utility:Create('TextLabel', {
                Name = 'Fake',
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1.000,
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(1, 0, 1, 0),
                Text = "✓",
                Font = Enum.Font.SourceSans,
                TextColor3 = Color3.fromRGB(197, 197, 197),
                TextSize = 18.000,
                TextWrapped = true,
            })
        })
    });

    local button: TextButton = Container.ToggleButton;
    local active = default or false;
    local callback = function(value)
        if (callback) then
            callback(value);
        end
    end

    self:UpdateToggle(Container, active);

    button.MouseButton1Click:Connect(function()
        active = not active;
        self:UpdateToggle(Container, active);
        callback(active);
    end)

    return {
        app = Container,
        UpdateToggle = function(...)
            return self:UpdateToggle(Container, ...);
        end
    }
end

function Page:UpdateToggle(toggle, boolean)
    if (toggle) then
        local properties = {"✓", "×"};
        local t = boolean and properties[1] or properties[2];

        local button: TextButton = toggle.ToggleButton;
        local label: TextLabel = button.Fake;

        -- i want to make this code more professional.
        label.AnchorPoint = Vector2.new(1, 0.5);
        label.Position = UDim2.new(1, 0, 0.5, 0);
        Utility:Tween(label, { Size = UDim2.new(0, 0, 1, 0) }, .2);
        wait(.2);
        label.Text = t;
        label.AnchorPoint = Vector2.new(0, 0.5);
        label.Position = UDim2.new(0, 0, 0.5, 0);
        Utility:Tween(label, { Size = UDim2.new(1, 0, 1, 0) }, .2);
    end
end

function Page:addSlider(Title: string, description: string, default: number?, min: number?, max: number?, callback: Function)
    local Container = Utility:Create('ImageLabel', {
        Name = 'Slider',
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Size = UDim2.new(1, -20, 0, 40),
        Image = "rbxassetid://3570695787",
        ImageColor3 = Color3.fromRGB(34, 36, 47),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(100, 100, 100, 100),
        SliceScale = 0.02,
        Parent = self.container
    }, {
        Utility:Create('ImageLabel', {
            Name = 'Inner',
            BackgroundTransparency = 1.000,
            Size = UDim2.new(1, 0, 0, 40),
            Image = "rbxassetid://3570695787",
            ImageColor3 = Color3.fromRGB(34, 36, 47),
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(100, 100, 100, 100),
            SliceScale = 0.02,
        }, {
            Utility:Create('TextLabel', {
                Name = 'Title',
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -100, 0, 20),
                Font = Enum.Font.SourceSans,
                Text = Title,
                TextColor3 = Color3.fromRGB(143, 143, 143),
                TextSize = 17,
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
            Utility:Create('TextLabel', {
                Name = 'Extra',
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0.5, 0),
                Size = UDim2.new(0, 230, 0, 20),
                Font = Enum.Font.SourceSans,
                Text = description or 'no description.',
                TextColor3 = Color3.fromRGB(84, 84, 84),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top
            }),
            Utility:Create('TextBox', {
                Name = 'Box',
                BackgroundColor3 = Color3.fromRGB(41, 44, 57),
                BorderSizePixel = 0,
                Size = UDim2.new(0, 60, 0, 23),
                Font = Enum.Font.SourceSans,
                TextColor3 = Color3.fromRGB(130, 130, 130),
                Text = "",
                TextWrapped = true,
                Position = UDim2.new(0.75757575, 0, 0.200000003, 0),
                TextSize = 16
            }, {
                Utility:Create('UICorner', {
                    CornerRadius = UDim.new(0, 2)
                })
            }),
            Utility:Create('ImageButton', {
                BackgroundTransparency = 1.000,
                Name = 'Open',
                Position = UDim2.new(0.933333516, 0, 0.25, 0),
                Size = UDim2.new(0, 22, 0, 20),
                Image = "rbxassetid://5012539403",
            })
        }),
        Utility:Create('TextButton', {
            Name = 'SliderButton',
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(26, 27, 36),
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0, 60),
            Size = UDim2.new(1, -20, 0, 6),
            AutoButtonColor = false,
            Text = "",
        }, {
            Utility:Create('UICorner', {
                CornerRadius = UDim.new(0, 2)
            }),
            Utility:Create('ImageLabel', {
                Name = 'Bar',
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1.000,
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(0, 0, 1, 0),
                Image = "rbxassetid://3570695787",
                ImageColor3 = Color3.fromRGB(46, 48, 65),
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(100, 100, 100, 100),
                SliceScale = 0.04,
            }, {
                Utility:Create('ImageLabel', {
                    Name = 'Ball',
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1.000,
                    Position = UDim2.new(1, -10, 0.5, 0),
                    Size = UDim2.new(0, 20, 0, 20),
                    Image = "rbxassetid://3570695787",
                    ImageColor3 = Color3.fromRGB(42, 43, 59),
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(100, 100, 100, 100),
                    SliceScale = 0.1,
                })
            })
        })
    });

    local SliderButton: TextButton = Container.SliderButton;
    local box: TextBox = Container.Inner.Box;
    local Open: ImageButton = Container.Inner.Open;
    local Ball: ImageLabel = SliderButton.Bar.Ball;
    local callback = function(v)
        if (callback) then
            callback(v);
        end
    end

    local active = false;
    local dragging = false;

    Utility:DraggingEnded(function()
        dragging = false;
        Utility:Tween(Ball, { ImageColor3 = Color3.fromRGB(42, 43, 59) }, .2);
    end)

    local value = default or min;

    self:UpdateSlider(Container, value, min, max);

    Open.MouseButton1Click:Connect(function()
        active = not active;
        local ySize = active and 80 or 40;
        local rotation = active and 180 or 0;

        Utility:Tween(Container, { Size = UDim2.new(1, -20, 0, ySize) }, .2);
        Utility:Tween(Open, { Rotation = rotation }, .2);
    end)

    SliderButton.MouseButton1Down:Connect(function()
        dragging = true;
        Utility:Tween(Ball, { ImageColor3 = Color3.fromRGB(37, 39, 59) }, .2);
        while dragging do
            local cbValue = self:UpdateSlider(Container, nil, min , max);
            callback(math.clamp(cbValue, min, max));

            box.Text = tostring(cbValue);
            self.Library:moveToolTip('Value: ' .. tostring(cbValue), Ball.AbsolutePosition.X, Ball.AbsolutePosition.Y - 20);
            RunService.RenderStepped:Wait();
        end
    end)

    box:GetPropertyChangedSignal('Text'):Connect(function()
        if (tonumber(box.Text) ~= nil) then
            local cbValue = self:UpdateSlider(Container, box.Text, min, max);
            callback(cbValue);
        else
            --todo: show error that only number is allowed in slider.
            box.Text = '';
        end
    end)

    Container:GetPropertyChangedSignal('Size'):Connect(function()
        self:Resize();
    end)

    return {
        app = Container,
        UpdateSlider = function(...)
            return self:UpdateSlider(Container, ...);
        end
    }
end

function Page:UpdateSlider(Slider, value, min, max)
    if (Slider) then
        local SliderButton: TextButton = Slider.SliderButton;
        local percentage = ( Mouse.X - SliderButton.AbsolutePosition.X ) / SliderButton.AbsoluteSize.X;

        if (value) then
            percentage = (value - min) / (max - min);
        end

        percentage = math.clamp(percentage, 0, 1);
        value = value or math.floor(min + (max-min) * percentage);

        Utility:Tween(SliderButton.Bar, { Size = UDim2.new(percentage, 0, 1, 0)}, .07);

        return value;
    end
end

function Page:addDropdown(Title: string, description: string, items: table, callback: Function)
    local Container = Utility:Create('ImageLabel', {
        Name = 'Dropdown',
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Size = UDim2.new(1, -20, 0, 40),
        Image = "rbxassetid://3570695787",
        ImageColor3 = Color3.fromRGB(34, 36, 47),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(100, 100, 100, 100),
        SliceScale = 0.02,
        Parent = self.container
    }, {
        Utility:Create('ImageLabel', {
            Name = 'Inner',
            BackgroundTransparency = 1.000,
            Size = UDim2.new(1, 0, 0, 40),
            Image = "rbxassetid://3570695787",
            ImageColor3 = Color3.fromRGB(34, 36, 47),
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(100, 100, 100, 100),
            SliceScale = 0.02,
        }, {
            Utility:Create('TextLabel', {
                Name = 'Title',
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -100, 0, 20),
                Font = Enum.Font.SourceSans,
                Text = Title,
                TextColor3 = Color3.fromRGB(143, 143, 143),
                TextSize = 17,
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
            Utility:Create('TextLabel', {
                Name = 'Extra',
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0.5, 0),
                Size = UDim2.new(0, 230, 0, 20),
                Font = Enum.Font.SourceSans,
                Text = description or 'no description.',
                TextColor3 = Color3.fromRGB(84, 84, 84),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top
            }),
            Utility:Create('ImageButton', {
                BackgroundTransparency = 1.000,
                Name = 'Open',
                Position = UDim2.new(0.933333516, 0, 0.25, 0),
                Size = UDim2.new(0, 22, 0, 20),
                Image = "rbxassetid://5012539403",
            })
        }),
        Utility:Create('ScrollingFrame', {
            Name = 'List',
            BackgroundTransparency = 1.000,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 40),
            Size = UDim2.new(1, 0, 1, -40),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 1,
        }, {
            Utility:Create('UIListLayout', {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2)
            })
        })
    });

    local Button: ImageButton = Container.Inner.Open;

    Button.MouseButton1Click:Connect(function()
        if (Button.Rotation == 180) then
            self:UpdateDropdown(Container, nil, callback);
        else
            self:UpdateDropdown(Container, items, callback);
        end
    end)

    Container:GetPropertyChangedSignal('Size'):Connect(function()
        self:Resize();
    end)

    return {
        app = Container,
        UpdateDropdown = function(...)
            return self:UpdateDropdown(Container, ...);
        end
    }
end

function Page:UpdateDropdown(Dropdown, list, callback)
    if (Dropdown) then
        local objects = 0;

        for _,v in pairs (Dropdown.List:GetChildren()) do
            if (v:IsA('TextButton')) then
                v:Destroy();
            end
        end

        for _,v in pairs (list or {}) do
            local Button: TextButton = Utility:Create('TextButton', {
                BackgroundColor3 = Color3.fromRGB(45, 48, 63),
                Parent = Dropdown.List,
                Size = UDim2.new(1, -10, 0, 20),
                AutoButtonColor = false,
                Font = Enum.Font.GothamSemibold,
                TextColor3 = Color3.fromRGB(170, 170, 170),
                TextSize = 12.000,
                Text = v,
                BorderSizePixel = 0,
            });

            Button.MouseButton1Click:Connect(function()
                if (callback) then
                    callback(v);
                end
                self:UpdateDropdown(Dropdown, nil, callback)
            end)
            objects = objects + 1;
        end

        Dropdown.List.CanvasSize = UDim2.new(0, 0, 0, Dropdown.List.UIListLayout.AbsoluteContentSize.Y);

        Utility:Tween(Dropdown, { Size = UDim2.new(1, -20, 0, ( objects == 0 and 40) or math.clamp(objects, 0, 6) * 20 + 40 ) }, 0.2)
        Utility:Tween(Dropdown.Inner.Open, { Rotation = ( list and 180 or 0 ) }, .2);
    end
end

function Page:addColorpicker(Title: string, description: string, default: Color3, callback: Function)
    local Container = Utility:Create('ImageLabel', {
        Name = 'Colorpicker',
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Size = UDim2.new(1, -20, 0, 40),
        Image = "rbxassetid://3570695787",
        ImageColor3 = Color3.fromRGB(34, 36, 47),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(100, 100, 100, 100),
        SliceScale = 0.02,
        Parent = self.container
    }, {
        Utility:Create('ImageLabel', {
            Name = 'Inner',
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Size = UDim2.new(1, 0, 0, 40),
            Image = "rbxassetid://3570695787",
            ImageColor3 = Color3.fromRGB(34, 36, 47),
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(100, 100, 100, 100),
            SliceScale = 0.02,
            Parent = self.container
        }, {
            Utility:Create('TextLabel', {
                Name = 'Title',
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -100, 0, 20),
                Font = Enum.Font.SourceSans,
                Text = Title,
                TextColor3 = Color3.fromRGB(143, 143, 143),
                TextSize = 17,
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
            Utility:Create('TextLabel', {
                Name = 'Extra',
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0.5, 0),
                Size = UDim2.new(0, 230, 0, 20),
                Font = Enum.Font.SourceSans,
                Text = description or 'no description.',
                TextColor3 = Color3.fromRGB(84, 84, 84),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top
            }),
            Utility:Create('ImageButton', {
                BackgroundTransparency = 1.000,
                Name = 'Open',
                Position = UDim2.new(0.933333516, 0, 0.25, 0),
                Size = UDim2.new(0, 22, 0, 20),
                Image = "rbxassetid://5012539403",
            }),
            Utility:Create('ImageLabel', {
                Name = 'Preview',
                BackgroundTransparency = 1,
                Position = UDim2.new(0.80122304, 0, 0.125, 0),
                Size = UDim2.new(0, 30, 0, 30),
                Image = "rbxassetid://3570695787",
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(100, 100, 100, 100),
                SliceScale = 0.04,
            }),
        }),
        Utility:Create('Frame', {
            Name = 'SV',
            BackgroundColor3 = Color3.fromRGB(255, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0.150000006, 0, 0, 50),
            Size = UDim2.new(0, 95, 0, 95)
        }, {
            Utility:Create('Frame', {
                Name = 'White',
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(1, 0, 1, 0),
            }, {
                Utility:Create('UIGradient', {
                    Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(1.00, 1.00)}
                })
            }),
            Utility:Create('Frame', {
                Name = 'Black',
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BorderSizePixel = 0,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(1, 0, 1, 0),
            }, {
                Utility:Create('UIGradient', {
                    Rotation = -90,
                    Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(1.00, 1.00)}
                })
            }),
            Utility:Create('ImageLabel', {
                Name = 'Mover',
                BackgroundTransparency = 1.000,
                Position = UDim2.new(0.468468457, 0, 0.468468487, 0),
                Size = UDim2.new(0, 11, 0, 11),
                Image = "rbxassetid://5100115962",
                AnchorPoint = Vector2.new(0.5, 0.5),
            })
        }),
        Utility:Create('Frame', {
            Name = 'Hue',
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Position = UDim2.new(0.5, 0, 0, 50),
            Size = UDim2.new(0, 16, 0, 95)
        }, {
            Utility:Create('UIGradient', {
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))},
                Rotation = 90
            }),
            Utility:Create('ImageLabel', {
                Name = 'Mover',
                BackgroundTransparency = 1.000,
                Position = UDim2.new(0.167873219, 0, -0.00464978814, 0),
                Size = UDim2.new(0, 11, 0, 11),
                Image = "rbxassetid://5100115962",
                ImageColor3 = Color3.fromRGB(21, 21, 21)
            })
        })
    });

    local SVDown = false;
    local HueDown = false;

    local color = {1, 1, 1};

    Utility:DraggingEnded(function()
        SVDown = false;
        HueDown = false;
    end)

    local Hue: Frame = Container.Hue;
    local SV: Frame = Container.SV;
    local Button: ImageButton = Container.Inner.Open;

    Button.MouseButton1Click:Connect(function()
        if (Button.Rotation == 180) then
            self:UpdateColorpicker(Container, nil, false);
        else
            self:UpdateColorpicker(Container, nil, true);
        end
    end)

    Hue.InputBegan:Connect(function(key)
        if (key.UserInputType == Enum.UserInputType.MouseButton1) then
           HueDown = true
        end
    end)

    SV.InputBegan:Connect(function(key)
        if (key.UserInputType == Enum.UserInputType.MouseButton1) then
           SVDown = true
        end
    end)

    SV.BackgroundColor3 = Color3.fromHSV(color[1],1,1)

    if (default) then
        self:UpdateColorpicker(Container, nil, default);
        color = { Color3.toHSV(default) };
    end

    RunService.RenderStepped:Connect(function()
        if HueDown then
            local Y = math.clamp((Mouse.Y - Hue.AbsolutePosition.Y) / Hue.AbsoluteSize.Y,0,1);

            self:UpdateColorpicker(Container, color, nil);

            color = { Y, color[2], color[3] }

            local res = Utility:HsvToRgb(unpack(color));

            callback(Color3.new(res.r,res.g,res.b));
        end

        if SVDown then
            local X = math.clamp((Mouse.X - SV.AbsolutePosition.X) / SV.AbsoluteSize.X,0,1);
            local Y = math.clamp((Mouse.Y - SV.AbsolutePosition.Y) / SV.AbsoluteSize.Y,0,1);

            color = {color[1], X, Y};

            self:UpdateColorpicker(Container, color, nil);

            local res = Utility:HsvToRgb(unpack(color));

            callback(Color3.new(res.r,res.g,res.b));
        end

        RunService.RenderStepped:Wait()
    end)

    return {
        app = Container,
        UpdateColorpicker = function(...)
            return self:UpdateColorpicker(Container, ...);
        end
    }
end

function Page:UpdateColorpicker(Colorpicker, color, active)
    if (Colorpicker) then
        if (active ~= nil) then
            local size = active and 150 or 40;
            local rotation = active and 180 or 0;

            Utility:Tween(Colorpicker.Inner.Open, { Rotation = rotation }, .2);
            Utility:Tween(Colorpicker, { Size = UDim2.new(1, -20, 0, size)}, .2);
        end

        if (color) then
            local Hue: Frame = Colorpicker.Hue;
            local SV: Frame = Colorpicker.SV;
            local HueMover: ImageLabel = Hue.Mover;
            local SVMover: ImageLabel = SV.Mover;

            local h,s,v
            local color3

            if (TypeChecker(color, 'table')) then
                h,s,v = unpack(color);
            else
                color3 = color
                h,s,v = Color3.toHSV(color3)
            end

            Utility:Tween(Colorpicker.Inner.Preview ,{ ImageColor3 = Color3.fromHSV(h,s,1 - v) }, 0.2);
            Utility:Tween(HueMover,{Position = UDim2.new(0.23, 0, h, 0)}, 0.2);
            Utility:Tween(SVMover,{Position = UDim2.new(s, 0, v, 0)}, 0.2);
            Utility:Tween(SV,{BackgroundColor3 = Color3.fromHSV(h, 1, 1)}, 0.2);
        end
    end
end

return Library;