-- core.lua
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {
    CurrentTab = nil,
    TooltipDelay = 0.6 -- Время в секундах, через которое появится описание
}

-- Функция для создания плавных анимаций
function Library:Tween(object, info, properties)
    local tween = TweenService:Create(object, TweenInfo.new(unpack(info)), properties)
    tween:Play()
    return tween
end

-- Создание главного окна
function Library:CreateWindow(config)
    local WindowName = config.Name or "Xeno Menu"
    
    -- Корневой GUI элемент
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RayfieldStyleMenu"
    ScreenGui.Parent = game:CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Главный фрейм
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    MainFrame.Size = UDim2.new(0, 550, 0, 350)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    -- Тултип (Всплывающее описание)
    local Tooltip = Instance.new("TextLabel")
    Tooltip.Name = "Tooltip"
    Tooltip.Size = UDim2.new(0, 180, 0, 'auto')
    Tooltip.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Tooltip.TextColor3 = Color3.fromRGB(200, 200, 200)
    Tooltip.Font = Enum.Font.Gotham
    Tooltip.TextSize = 12
    Tooltip.TextWrapped = true
    Tooltip.Visible = false
    Tooltip.ZIndex = 10
    Tooltip.Parent = ScreenGui
    
    local TooltipPadding = Instance.new("UIPadding")
    TooltipPadding.PaddingTop = UDim.new(0, 6)
    TooltipPadding.PaddingBottom = UDim.new(0, 6)
    TooltipPadding.PaddingLeft = UDim.new(0, 6)
    TooltipPadding.PaddingRight = UDim.new(0, 6)
    TooltipPadding.Parent = Tooltip

    -- Логика перетаскивания окна (Drag)
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Боковое меню для Вкладок (Tabs)
    local SideBar = Instance.new("Frame")
    SideBar.Name = "SideBar"
    SideBar.Size = UDim2.new(0, 150, 1, 0)
    SideBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SideBar.BorderSizePixel = 0
    SideBar.Parent = MainFrame

    local SideCorner = Instance.new("UICorner")
    SideCorner.CornerRadius = UDim.new(0, 8)
    SideCorner.Parent = SideBar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = SideBar
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)

    -- Контейнер для страниц
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Position = UDim2.new(0, 160, 0, 10)
    Container.Size = UDim2.new(1, -170, 1, -20)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    -- Функция добавления описания к элементам
    function Library:AddTooltip(element, text)
        local hoverToken = 0
        element.MouseEnter:Connect(function()
            hoverToken = hoverToken + 1
            local currentToken = hoverToken
            task.wait(Library.TooltipDelay)
            if currentToken == hoverToken then
                Tooltip.Text = text
                Tooltip.Visible = true
                
                -- Движение тултипа за мышкой
                local connection
                connection = game:GetService("RunService").RenderStepped:Connect(function()
                    if not Tooltip.Visible then connection:Disconnect() return end
                    Tooltip.Position = UDim2.new(0, Mouse.X + 15, 0, Mouse.Y + 15)
                end)
            end
        end)
        element.MouseLeave:Connect(function()
            hoverToken = hoverToken + 1
            Tooltip.Visible = false
        end)
    end

    -- Метод создания вкладки (Tab) как в Rayfield
    local WindowAPI = {}
    function WindowAPI:CreateTab(tabName)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, -10, 0, 35)
        TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.Text = tabName
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.TextSize = 14
        TabButton.Parent = SideBar

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 4
        Page.Parent = Container

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = Page
        PageLayout.Padding = UDim.new(0, 8)
        
        PageLayout.AttributeChanged:Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)

        TabButton.MouseButton1Click:Connect(function()
            if Library.CurrentTab then
                Library.CurrentTab.Page.Visible = false
            end
            Page.Visible = true
            Library.CurrentTab = {Page = Page, Button = TabButton}
        end)

        if not Library.CurrentTab then
            Page.Visible = true
            Library.CurrentTab = {Page = Page, Button = TabButton}
        end

        -- Подгружаем модули и передаем им контекст страницы
        local TabAPI = {}
        
        -- Сюда будут инжектиться функции из папки options/
        -- Для локальных тестов можно подключить их напрямую:
        
        function TabAPI:AddText(text)
            -- Ссылка на options/text.lua
            return loadstring(game:HttpGet("ссылка_на_github/options/text.lua"))()(Page, text, Library)
        end

        function TabAPI:AddKeybind(config)
            return loadstring(game:HttpGet("ссылка_на_github/options/keybind.lua"))()(Page, config, Library)
        end

        function TabAPI:AddSlider(config)
            return loadstring(game:HttpGet("ссылка_на_github/options/slidermove.lua"))()(Page, config, Library)
        end

        function TabAPI:AddColorpicker(config)
            return loadstring(game:HttpGet("ссылка_на_github/options/colorpicker.lua"))()(Page, config, Library)
        end

        return TabAPI
    end

    return WindowAPI
end

return Library