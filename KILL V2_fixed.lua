-- KILL V2_fixed.lua
-- Wrapper que carga el KILL V2 original, reemplaza el primer rbxassetid no-cero
-- por el nuevo ID y fuerza el fondo de las ventanas a negro.

local NEW_LOGO = "rbxassetid://81773227739658"
local ORIGINAL_URL = "https://raw.githubusercontent.com/gg2065509-debug/Aleking-hub-v2/main/KILL V2"

local ok, source = pcall(function() return game:HttpGet(ORIGINAL_URL, true) end)
if not ok then error("Failed to fetch original script: " .. tostring(source)) end

-- Reemplaza la primera ocurrencia de rbxassetid://<id> que no sea 0 por NEW_LOGO
local replaced = source:gsub("rbxassetid://(%d+)", function(id)
    if id ~= "0" then
        return NEW_LOGO
    end
    return "rbxassetid://0"
end, 1)

-- Intento rápido de asegurar que la ventana use color negro (main_color)
-- Reemplaza una posible definición main_color dentro de la llamada AddWindow (best-effort)
replaced = replaced:gsub("AddWindow%((.-){(.-)main_color%s*=%s*Color3%.fromRGB%([^%)]-%)",
    function(a,b) return "AddWindow("..a.."{"..b.."main_color = Color3.fromRGB(0,0,0)" end)

-- Ejecutar el script modificado
local func, err = loadstring(replaced)
if not func then error("loadstring error: " .. tostring(err)) end
pcall(func)

-- Después de un breve retardo, forzamos backgrounds e imágenes dentro del PlayerGui para asegurar ventana negra y logo
task.spawn(function()
    task.wait(0.6)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then return end
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end

    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, obj in pairs(gui:GetDescendants()) do
                pcall(function()
                    if obj:IsA("Frame") then
                        obj.BackgroundTransparency = 0
                        obj.BackgroundColor3 = Color3.fromRGB(0,0,0)
                    elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                        if obj.Image and not obj.Image:match("rbxassetid://0") then
                            obj.Image = NEW_LOGO
                        end
                    end
                end)
            end
        end
    end
end)
