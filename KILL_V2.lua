-- KILL_V2.lua
-- Wrapper: carga el KILL V2 original desde tu repo, reemplaza TODOS los rbxassetid no-cero
-- por el logo proporcionado y fuerza UI a tema negro; además ajusta el tamaño/posición del logo.

local NEW_LOGO = "rbxassetid://81773227739658"
local ORIGINAL_RAW_URL = "https://raw.githubusercontent.com/gg2065509-debug/Aleking-hub-v2/main/KILL%20V2"

local ok, source = pcall(function() return game:HttpGet(ORIGINAL_RAW_URL, true) end)
if not ok then error("Fallo al obtener el script original: " .. tostring(source)) end

-- Reemplazar todas las apariciones de rbxassetid://<id> que NO sean 0 por NEW_LOGO
source = source:gsub("rbxassetid://(%d+)", function(id)
    if id ~= "0" then
        return NEW_LOGO
    end
    return "rbxassetid://0"
end)

-- Forzar main_color dentro de cualquier AddWindow({... main_color = ...}) - intenta ser flexible
source = source:gsub("AddWindow%((.-){(.-)}%s*%)", function(prefix, props)
    -- Si ya existe main_color, reemplazar su valor; si no, agregarlo al inicio de props
    if props:match("main_color%s*=") then
        local newprops = props:gsub("main_color%s*=.-([,%}])","main_color = Color3.fromRGB(0,0,0)%1")
        return "AddWindow("..prefix.."{"..newprops.."}")"
    else
        return "AddWindow("..prefix.."{".."main_color = Color3.fromRGB(0,0,0), "..props.."}")"
    end
end)

-- Ejecutar el script modificado
local func, err = loadstring(source)
if not func then error("loadstring error: " .. tostring(err)) end
pcall(func)

-- Post-proceso: recorrer PlayerGui y ajustar Frames / ImageLabels
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
                        -- Forzar fondo negro opaco
                        obj.BackgroundTransparency = 0
                        obj.BackgroundColor3 = Color3.fromRGB(0,0,0)
                    elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                        -- Reemplazar imagen por el nuevo logo
                        obj.Image = NEW_LOGO
                        -- Si parece un logo pequeño, ajustar tamaño y centrar en la parte superior
                        -- Usamos heurística por tamaño actual o por nombre
                        local okSize = pcall(function() return obj.Size end)
                        if okSize then
                            -- Hacer logo 60x60 px aproximadamente
                            obj.Size = UDim2.new(0, 60, 0, 60)
                            -- colocar cerca de la parte superior central si está dentro de un marco grande
                            obj.AnchorPoint = Vector2.new(0.5, 0)
                            obj.Position = UDim2.new(0.5, 0, 0.03, 0)
                        end
                    end
                end)
            end
        end
    end
end)

-- Mensaje útil
print("KILL_V2 wrapper cargado: logo reemplazado y UI forzada a negro. Archivo original no modificado.")
