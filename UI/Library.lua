-- Library.lua

local UserInputService = game:GetService("UserInputService")


-- Безопасная проверка: если ссылки не изменены, скрипт не упадет, а создаст пустые таблицы

local ConfigManagerUrl = "https://raw.githubusercontent.com/geragori11/Menu/refs/heads/main/UI/ConfigManager.lua"

local UIBuilderUrl = "https://raw.githubusercontent.com/geragori11/Menu/refs/heads/main/UI/UIBuilder.lua"


local ConfigManager = (ConfigManagerUrl:find("СЮДА_ССЫЛКУ") and {} or loadstring(game:HttpGet(ConfigManagerUrl))())

local UIBuilder = (UIBuilderUrl:find("СЮДА_ССЫЛКУ") and {} or loadstring(game:HttpGet(UIBuilderUrl))())


-- Защитная заглушка для UIBuilder на случай локальных тестов

if not UIBuilder.CreateWindow then

    UIBuilder.CreateWindow = function(options)

        print("[UIBuilder] Создание визуального окна для: " .. tostring(options.Name))

        return Instance.new("ScreenGui"), Instance.new("Frame"), Instance.new("Folder")

    end

end


local Library = {}

Library.Flags = {} -- Хранилище состояний всех тогглов/слайдеров для конфига


-- Глобальная функция уведомлений (многие скрипты Rayfield вызывают её напрямую через Rayfield:Notify)

function Library:Notify(notifyOptions)

    print("[NOTIFY] " .. tostring(notifyOptions.Title) .. ": " .. tostring(notifyOptions.Content))

    -- Сюда позже добавь вызов визуальной плашки из UIBuilder

end


-- Функция закрытия меню (совместимость с Rayfield:Destroy())

function Library:Destroy()

    print("[Library] Меню полностью деактивировано.")

end


function Library:CreateWindow(options)

    local Window = {}

    local ScreenGui, MainFrame, TabContainer = UIBuilder.CreateWindow(options)

    

    -- Система скрытия/открытия меню на клавишу (По умолчанию K)

    Window.ToggleKey = Enum.KeyCode.K

    

    UserInputService.InputBegan:Connect(function(input, gameProcessed)

        if not gameProcessed and input.KeyCode == Window.ToggleKey then

            MainFrame.Visible = not MainFrame.Visible

        end

    end)


    -- Дублируем Notify внутри Window для совместимости с Window:Notify()

    function Window:Notify(notifyOptions)

        Library:Notify(notifyOptions)

    end


    function Window:CreateTab(Name, Icon)

        local Tab = {}

        print("[UI] Создана вкладка: " .. tostring(Name))

        -- Тут должен быть вызов UIBuilder для создания визуальной вкладки

        

        function Tab:CreateSection(SectionName)

            print("[UI] Создана секция: " .. tostring(SectionName))

            -- Возвращаем объект, так как некоторые скрипты могут вызывать методы у секций

            return {

                Set = function(_, newText) print("[Section] Текст изменен на: " .. tostring(newText)) end

            }

        end


        function Tab:CreateButton(btnOptions)

            print("[UI] Создана кнопка: " .. tostring(btnOptions.Name))

            -- В будущем: вызов UIBuilder для отрисовки

            return {

                Set = function(_, newText) btnOptions.Name = newText end

            }

        end


        function Tab:CreateToggle(tglOptions)

            print("[UI] Создан тоггл: " .. tostring(tglOptions.Name))

            local Toggle = {}

            local Flag = tglOptions.Flag or tglOptions.Name

            Library.Flags[Flag] = tglOptions.CurrentValue or false


            -- Первичный вызов коллбека при инициализации (поведение Rayfield)

            if tglOptions.Callback then

                task.spawn(function() pcall(tglOptions.Callback, Library.Flags[Flag]) end)

            end


            function Toggle:Set(state)

                Library.Flags[Flag] = state

                if tglOptions.Callback then pcall(tglOptions.Callback, state) end

                -- Здесь будет обновление визуала тоггла через UIBuilder

            end


            return Toggle

        end


        -- ====================================================================

        -- МЕТОДЫ СОВМЕСТИМОСТИ С RAYFIELD (ПРЕДОТВРАЩАЮТ ОШИБКУ ATTEMPT TO CALL A NIL VALUE)

        -- ====================================================================


        function Tab:CreateSlider(sldOptions)

            print("[UI] Создан слайдер: " .. tostring(sldOptions.Name))

            local Slider = {}

            local Flag = sldOptions.Flag or sldOptions.Name

            Library.Flags[Flag] = sldOptions.CurrentValue or sldOptions.Min


            if sldOptions.Callback then

                task.spawn(function() pcall(sldOptions.Callback, Library.Flags[Flag]) end)

            end


            function Slider:Set(value)

                Library.Flags[Flag] = value

                if sldOptions.Callback then pcall(sldOptions.Callback, value) end

                -- Сюда логику изменения размера ползунка

            end

            return Slider

        end


        function Tab:CreateDropdown(ddOptions)

            print("[UI] Создан дропдаун: " .. tostring(ddOptions.Name))

            local Dropdown = {}

            local Flag = ddOptions.Flag or ddOptions.Name

            Library.Flags[Flag] = ddOptions.CurrentOption


            if ddOptions.Callback then

                task.spawn(function() pcall(ddOptions.Callback, Library.Flags[Flag]) end)

            end


            function Dropdown:Set(option)

                Library.Flags[Flag] = option

                if ddOptions.Callback then pcall(ddOptions.Callback, option) end

            end


            function Dropdown:Refresh(newOptions, selectOption)

                print("[Dropdown] Список обновлен")

            end

            return Dropdown

        end


        function Tab:CreateInput(inpOptions)

            print("[UI] Создано поле ввода: " .. tostring(inpOptions.Name))

            local Input = {}

            

            function Input:Set(text)

                if inpOptions.Callback then pcall(inpOptions.Callback, text) end

            end

            return Input

        end


        function Tab:CreateLabel(text)

            print("[UI] Создан текст: " .. tostring(text))

            return {

                Set = function(_, newText) print("[Label] Изменен на: " .. tostring(newText)) end

            }

        end


        function Tab:CreateParagraph(paraOptions)

            print("[UI] Создан параграф: " .. tostring(paraOptions.Title))

            return {

                Set = function(_, newTitle, newContent) end

            }

        end


        function Tab:CreateColorPicker(cpOptions)

            print("[UI] Создан выбор цвета: " .. tostring(cpOptions.Name))

            local ColorPicker = {}

            local Flag = cpOptions.Flag or cpOptions.Name

            Library.Flags[Flag] = cpOptions.Default or Color3.fromRGB(255, 255, 255)


            function ColorPicker:Set(color)

                Library.Flags[Flag] = color

                if cpOptions.Callback then pcall(cpOptions.Callback, color) end

            end

            return ColorPicker

        end

        

        return Tab

    end


    -- ==========================================

    -- ВСТРОЕННАЯ СИСТЕМА КОНФИГОВ И НАСТРОЕК

    -- ==========================================

    local SettingsTab = Window:CreateTab("Settings", "settings_icon")

    SettingsTab:CreateSection("Управление меню")

    

    SettingsTab:CreateButton({

        Name = "Изменить кнопку меню (Текущая: " .. Window.ToggleKey.Name .. ")",

        Callback = function()

            Window:Notify({Title = "Keybind", Content = "Нажми любую клавишу..."})

            local connection

            connection = UserInputService.InputBegan:Connect(function(input)

                if input.UserInputType == Enum.UserInputType.Keyboard then

                    Window.ToggleKey = input.KeyCode

                    Window:Notify({Title = "Успех", Content = "Новая кнопка: " .. input.KeyCode.Name})

                    connection:Disconnect()

                end

            end)

        end

    })


    SettingsTab:CreateSection("Система Конфигов")

    

    local ConfigInputName = "Default"


    SettingsTab:CreateButton({

        Name = "💾 Сохранить конфиг",

        Callback = function()

            if ConfigManager and ConfigManager.Save then

                ConfigManager:Save(ConfigInputName, Library.Flags)

                Window:Notify({Title = "Конфиг", Content = "Успешно сохранен: " .. ConfigInputName})

            end

        end

    })


    SettingsTab:CreateButton({

        Name = "📂 Загрузить конфиг",

        Callback = function()

            if ConfigManager and ConfigManager.Load then

                local data = ConfigManager:Load(ConfigInputName)

                if data then

                    for flag, value in pairs(data) do

                        Library.Flags[flag] = value 

                    end

                    Window:Notify({Title = "Конфиг", Content = "Загружен: " .. ConfigInputName})

                else

                    Window:Notify({Title = "Ошибка", Content = "Конфиг не найден!"})

                end

            end

        end

    })

    

    SettingsTab:CreateButton({

        Name = "🗑️ Удалить конфиг",

        Callback = function()

            if ConfigManager and ConfigManager.Delete and ConfigManager:Delete(ConfigInputName) then

                Window:Notify({Title = "Удалено", Content = "Конфиг " .. ConfigInputName .. " удален."})

            end

        end

    })


    return Window

end


return Library
