local unpack_fn = unpack or table.unpack
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local LibraryData = { game:HttpGet("https://raw.githubusercontent.com/p4020854-hub/Lb/refs/heads/main/X", true) }
local Library = loadstring(unpack_fn(LibraryData))
local UI = Library()

local Window = UI:AddWindow("Genesis Hub FULL DEOBUSCATED by xXDEATHKINGXx | Hello " .. LocalPlayer.DisplayName, {
    main_color = Color3.fromRGB(0, 0, 0),
    min_size = Vector2.new(680, 870),
    can_resize = true
})

local MainTab = Window:AddTab("Main")

local MainLabel = MainTab:AddLabel("Important:")
MainLabel.TextSize = 22

local function onAntiFling(enabled)
    local character = workspace:FindFirstChild(LocalPlayer.Name)
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if enabled then
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(100000, 0, 100000)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.P = 1250
        bv.Parent = hrp
    else
        local bv = hrp:FindFirstChild("BodyVelocity")
        if bv then bv:Destroy() end
    end
end

local AntiFlingSwitch = MainTab:AddSwitch("Anti Fling", onAntiFling)
AntiFlingSwitch:Set(true)

local lockConn = nil

local function onLockPosition(enabled)
    if enabled then
        lockConn = RunService.Heartbeat:Connect(function()
            local character = LocalPlayer.Character
            if not character then return end
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not hrp or not humanoid then return end
            if not humanoid:FindFirstChild("LockState") then
                humanoid.WalkSpeed = 0
                humanoid.JumpPower = 0
                humanoid.AutoRotate = false
                humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                local lockVal = Instance.new("BoolValue", humanoid)
                lockVal.Name = "LockState"
                lockVal.Value = true
                humanoid:SetAttribute("LockCFrame", hrp.CFrame)
            end
            local lockedCF = humanoid:GetAttribute("LockCFrame")
            if lockedCF then
                hrp.Velocity = Vector3.zero
                hrp.RotVelocity = Vector3.zero
                hrp.CFrame = lockedCF
            end
        end)
    else
        if lockConn then
            lockConn:Disconnect()
            lockConn = nil
        end
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 250
            humanoid.JumpPower = 50
            humanoid.AutoRotate = true
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            local lockState = humanoid:FindFirstChild("LockState")
            if lockState then lockState:Destroy() end
            humanoid:SetAttribute("LockCFrame", nil)
        end
    end
end

local LockSwitch = MainTab:AddSwitch("Lock Position", onLockPosition)
LockSwitch:Set(false)

local function onShowPets(enabled)
    local pc = LocalPlayer:FindFirstChild("hidePets")
    if pc then
        LocalPlayer.hidePets.Value = enabled
    end
end

local ShowPetsSwitch = MainTab:AddSwitch("Show Pets", onShowPets)
ShowPetsSwitch:Set(false)

local function onShowOtherPets(enabled)
    local pc = LocalPlayer:FindFirstChild("showOtherPetsOn")
    if pc then
        LocalPlayer.showOtherPetsOn.Value = enabled
    end
end

local OtherPetsSwitch = MainTab:AddSwitch("Show Other Pets", onShowOtherPets)
OtherPetsSwitch:Set(false)

local MiscLabel = MainTab:AddLabel("Misc:")
MiscLabel.TextSize = 22

local function onInfiniteJump(enabled)
    _G.InfiniteJump = enabled
    if enabled then
        UserInputService.JumpRequest:Connect(function()
            if _G.InfiniteJump then
                local character = Players.LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:ChangeState("Jumping")
                    end
                end
            end
        end)
    end
end

MainTab:AddSwitch("Infinite Jump", onInfiniteJump)

local TILE_SIZE = 2048
local WORLD_SIZE = 50000
local waterParts = {}
local baseOffset = Vector3.new(-2, -9.5, -2)

local function createWaterTile(position, name)
    local part = Instance.new("Part")
    part.Size = Vector3.new(TILE_SIZE, 1, TILE_SIZE)
    part.Position = position
    part.Name = name
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 0.5
    part.Material = Enum.Material.SmoothPlastic
    part.BrickColor = BrickColor.new("Cyan")
    part.Parent = workspace
    return part
end

task.spawn(function()
    local tileCount = math.ceil(WORLD_SIZE / TILE_SIZE)
    for x = 0, tileCount - 1 do
        for z = 0, tileCount - 1 do
            local positions = {
                Vector3.new(x * TILE_SIZE, 0, z * TILE_SIZE),
                Vector3.new(-x * TILE_SIZE, 0, z * TILE_SIZE),
                Vector3.new(-x * TILE_SIZE, 0, -z * TILE_SIZE),
                Vector3.new(x * TILE_SIZE, 0, -z * TILE_SIZE),
            }
            local names = {
                "Part_Side_" .. x .. "_" .. z,
                "Part_LeftRight_" .. x .. "_" .. z,
                "Part_UpLeft_" .. x .. "_" .. z,
                "Part_UpRight_" .. x .. "_" .. z,
            }
            for i = 1, 4 do
                local part = createWaterTile(baseOffset + positions[i], names[i])
                table.insert(waterParts, part)
            end
        end
    end
end)

local function onWalkOnWater(enabled)
    for _, part in ipairs(waterParts) do
        if part then
            part.CanCollide = enabled
        end
    end
end

local WalkWaterSwitch = MainTab:AddSwitch("Walk on Water", onWalkOnWater)
WalkWaterSwitch:Set(true)

local function onChangeTime(value)
    if value == "Night" then
        Lighting.ClockTime = 0
    elseif value == "Day" then
        Lighting.ClockTime = 12
    elseif value == "Midnight" then
        Lighting.ClockTime = 6
    end
end

local TimeDropdown = MainTab:AddDropdown("Change Time", onChangeTime)
TimeDropdown:Add("Night")
TimeDropdown:Add("Day")
TimeDropdown:Add("Midnight")

local FarmTab = Window:AddTab("Farm Op")

getgenv()._AutoRepFarmEnabled = false

local function onStrengthOp(enabled)
    getgenv()._AutoRepFarmEnabled = enabled
end

FarmTab:AddSwitch("Strength Op", onStrengthOp)

local REP_COUNT = 40
local REP_WAIT = 0.01
local HIGH_PING_THRESHOLD = 5000
local LOW_PING_THRESHOLD = 300

local function getPing()
    local ok, result = pcall(function()
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if ok then return result end
    return 0
end

task.spawn(function()
    while true do
        if getgenv()._AutoRepFarmEnabled then
            local muscleEvent = LocalPlayer:FindFirstChild("muscleEvent")
            if muscleEvent then
                for i = 1, REP_COUNT do
                    muscleEvent:FireServer("rep")
                end
            end
        end
        task.wait(REP_WAIT)
    end
end)

local autoEatEnabled = false

local function eatEgg()
    local char = LocalPlayer.Character
    if not char then
        LocalPlayer.CharacterAdded:Wait()
        char = LocalPlayer.Character
    end
    local backpack = LocalPlayer:WaitForChild("Backpack")
    local egg = backpack:FindFirstChild("Protein Egg")
    if egg then
        egg.Parent = char
        pcall(function() end)
    end
end

task.spawn(function()
    while true do
        if autoEatEnabled then
            eatEgg()
            task.wait(1800)
        else
            task.wait(1)
        end
    end
end)

local function onAutoEatEgg(enabled)
    autoEatEnabled = enabled
end

FarmTab:AddSwitch("Auto Eat Egg 30 Minuts", onAutoEatEgg)

local function onAutoSpinWheel(enabled)
    _G.AutoSpinWheel = enabled
    if enabled then
        task.spawn(function()
            task.wait(0.1)
            while _G.AutoSpinWheel do
                local rs = game:GetService("ReplicatedStorage")
                pcall(function()
                    rs.rEvents.openFortuneWheelRemote:InvokeServer("openFortuneWheel", rs.fortuneWheelChances["Fortune Wheel"])
                end)
                task.wait(0.1)
            end
        end)
    end
end

FarmTab:AddSwitch("Spin Fortune Wheel", onAutoSpinWheel)

local function onHideAllFrames(enabled)
    local rs = game:GetService("ReplicatedStorage")
    for _, v in ipairs(rs:GetDescendants()) do
        if v:IsA("GuiObject") then
            v.Visible = not enabled
        end
    end
    if enabled then
        if _G.HideFramesConn then _G.HideFramesConn:Disconnect() end
        _G.HideFramesConn = rs.DescendantAdded:Connect(function(obj)
            if obj:IsA("GuiObject") then
                obj.Visible = false
            end
        end)
    else
        if _G.HideFramesConn then
            _G.HideFramesConn:Disconnect()
            _G.HideFramesConn = nil
        end
    end
end

FarmTab:AddSwitch("Hide All Frames", onHideAllFrames)

local function onAntiLag()
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            v.Enabled = false
        end
    end
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 0
    settings().Rendering.QualityLevel = 1
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChildOfClass("Humanoid") then
            pcall(function() v.Material = Enum.Material.SmoothPlastic end)
        end
    end
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
            v.Enabled = false
        end
    end
    StarterGui:SetCore("SendNotification", { Title = "Anti Lag", Text = "Full optimization applied!", Duration = 5 })
end

FarmTab:AddButton("Anti Lag", onAntiLag)

local function onFullOptimization()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(playerGui:GetChildren()) do
        if v:IsA("ScreenGui") then v:Destroy() end
    end
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("Sky") then v:Destroy() end
    end
    local sky = Instance.new("Sky")
    sky.Name = "DarkSky"
    sky.SkyboxBk = "rbxassetid://0"
    sky.SkyboxDn = "rbxassetid://0"
    sky.SkyboxFt = "rbxassetid://0"
    sky.SkyboxLf = "rbxassetid://0"
    sky.SkyboxRt = "rbxassetid://0"
    sky.SkyboxUp = "rbxassetid://0"
    sky.Parent = Lighting
    Lighting.Brightness = 0
    Lighting.ClockTime = 0
    Lighting.TimeOfDay = "00:00:00"
    Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    Lighting.Ambient = Color3.new(0, 0, 0)
    Lighting.FogColor = Color3.new(0, 0, 0)
    Lighting.FogEnd = 100
    task.spawn(function()
        wait(5)
        if not Lighting:FindFirstChild("DarkSky") then
            local clone = sky:Clone()
            clone.Parent = Lighting
        end
        Lighting.Brightness = 0
        Lighting.ClockTime = 0
        Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.FogColor = Color3.new(0, 0, 0)
        Lighting.FogEnd = 100
    end)
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") then v:Destroy() end
    end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then v:Destroy() end
    end
end

FarmTab:AddButton("Full Optimization", onFullOptimization)

local function unequipAllPets()
    local petsFolder = LocalPlayer:FindFirstChild("petsFolder")
    if not petsFolder then return end
    for _, folder in ipairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in ipairs(folder:GetChildren()) do
                ReplicatedStorage.rEvents.equipPetEvent:FireServer("unequipPet", pet)
            end
        end
    end
    task.wait(0.1)
end

local function equipPetByName(petName)
    local petsFolder = LocalPlayer:FindFirstChild("petsFolder")
    if not petsFolder then return end
    for _, folder in ipairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in ipairs(folder:GetChildren()) do
                if pet.Name == petName then
                    ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
                end
            end
        end
    end
end

local function onEquipSwiftSamurai()
    unequipAllPets()
    task.wait(0.1)
    local equipped = 0
    local petsFolder = LocalPlayer:FindFirstChild("petsFolder")
    if not petsFolder then return end
    for _, folder in ipairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in ipairs(folder:GetChildren()) do
                if pet.Name == "Swift Samurai" and equipped < 8 then
                    ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
                    equipped = equipped + 1
                end
            end
        end
    end
    print("Equipped " .. equipped .. " Swift Samurai")
end

FarmTab:AddButton("Equip Swift Samurai", onEquipSwiftSamurai)

local function teleportCharacter(pos)
    local char = LocalPlayer.Character
    if not char then
        LocalPlayer.CharacterAdded:Wait()
        char = LocalPlayer.Character
    end
    local hrp = char:WaitForChild("HumanoidRootPart")
    if typeof(pos) == "CFrame" then
        hrp.CFrame = pos
    else
        hrp.CFrame = CFrame.new(pos)
    end
end

local function sendTeleportNotif(text)
    StarterGui:SetCore("SendNotification", { Title = "Teleport", Text = text, Duration = 3 })
end

local function onJungleSquat()
    teleportCharacter(Vector3.new(-8371.4336, 6.7981, 2858.8853))
    local char = LocalPlayer.Character
    if char then
        local uis = game:GetService("UserInputService")
        fireproximityprompt = fireproximityprompt or function() end
        pcall(function()
            char.HumanoidRootPart.CFrame = CFrame.new(-8371.4336, 6.7981, 2858.8853)
        end)
    end
end

FarmTab:AddButton("Jungle Squat", onJungleSquat)

local function onJungleLift()
    teleportCharacter(Vector3.new(-8652.8672, 29.2667, 2089.2617))
end

FarmTab:AddButton("Jungle lift", onJungleLift)

local RebirthsLabel = FarmTab:AddLabel("Rebirths Gained")
RebirthsLabel.TextSize = 23

local FastRebirthFolder = FarmTab:AddFolder("Fast Rebirths Functions")

local startTime = tick()

local TimerLabel = FastRebirthFolder:AddLabel("0d 0h 0m 0s")
TimerLabel.TextSize = 18

local RebirthsCountLabel = FastRebirthFolder:AddLabel("Rebirths: 0")
RebirthsCountLabel.TextSize = 18

local RebirthsGainedLabel = FastRebirthFolder:AddLabel("Rebirths Gained: 0")
RebirthsGainedLabel.TextSize = 18

task.spawn(function()
    while true do
        local elapsed = tick() - startTime
        local days = math.floor(elapsed / 86400)
        local hours = math.floor((elapsed % 86400) / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = math.floor(elapsed % 60)
        TimerLabel.Text = string.format("%dd %dh %dm %ds", days, hours, minutes, seconds)
        task.wait(1)
    end
end)

local leaderstats = LocalPlayer:WaitForChild("leaderstats")
local Rebirths = leaderstats:WaitForChild("Rebirths")
local initialRebirths = Rebirths.Value

local function updateRebirthLabels()
    RebirthsCountLabel.Text = "Rebirths: " .. Rebirths.Value
    RebirthsGainedLabel.Text = "Rebirths Gained: " .. (Rebirths.Value - initialRebirths)
end

Rebirths.Changed:Connect(updateRebirthLabels)
updateRebirthLabels()

getgenv().AutoFarming = false

local SWIFT_SAMURAI = "Swift Samurai"
local TRIBAL_OVERLORD = "Tribal Overlord"

local function getRebirthThreshold()
    local ultimatesFolder = LocalPlayer:FindFirstChild("ultimatesFolder")
    local hasGoldenRebirth = ultimatesFolder and ultimatesFolder:FindFirstChild("Golden Rebirth")
    local multiplier = hasGoldenRebirth and (hasGoldenRebirth.Value >= 1) and 1 or 0
    return 10000 + 5000 * LocalPlayer.leaderstats.Rebirths.Value
end

local function onFastRebirth(enabled)
    getgenv().AutoFarming = enabled
    if enabled then
        task.spawn(function()
            while getgenv().AutoFarming do
                local threshold = getRebirthThreshold()
                print("Required for rebirth:", threshold)
                unequipAllPets()
                equipPetByName(SWIFT_SAMURAI)
                while LocalPlayer.leaderstats.Strength.Value < threshold and getgenv().AutoFarming do
                    local muscleEvent = LocalPlayer:FindFirstChild("muscleEvent")
                    if muscleEvent then
                        for i = 1, 10 do
                            muscleEvent:FireServer("rep")
                        end
                    end
                    task.wait()
                end
                if not getgenv().AutoFarming then break end
                unequipAllPets()
                equipPetByName(TRIBAL_OVERLORD)
                local prevRebirths = LocalPlayer.leaderstats.Rebirths.Value
                ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                task.wait(0.1)
                local timeout = 0
                while LocalPlayer.leaderstats.Rebirths.Value <= prevRebirths and timeout < 50 do
                    task.wait(0.1)
                    timeout = timeout + 1
                end
                print("Rebirth done. Restarting cycle.")
            end
        end)
    end
end

FastRebirthFolder:AddSwitch("Fast Rebirth", onFastRebirth)

local RebirthsWithoutPacksFolder = FarmTab:AddFolder("Rebiths Without Packs")

local targetRebirthValue = 0
local targetSwitch = nil

local function onRebirthTargetBox(input)
    local val = tonumber(input)
    if val and val > 0 then
        targetRebirthValue = val
        StarterGui:SetCore("SendNotification", { Title = "Target Updated", Text = "New target: " .. val .. " rebirths", Duration = 3 })
    else
        StarterGui:SetCore("SendNotification", { Title = "Error", Text = "Put a number larger than 0", Duration = 3 })
    end
end

RebirthsWithoutPacksFolder:AddTextBox("Rebirth Target", onRebirthTargetBox)

local function onAutoRebirthTarget(enabled)
    _G.targetRebirthActive = enabled
    if enabled then
        if _G.infiniteRebirthActive then
            if targetSwitch then targetSwitch:Set(false) end
            _G.infiniteRebirthActive = false
        end
        task.spawn(function()
            task.wait(0.1)
            while _G.targetRebirthActive do
                if LocalPlayer.leaderstats.Rebirths.Value >= targetRebirthValue then
                    if targetSwitch then targetSwitch:Set(false) end
                    _G.targetRebirthActive = false
                    StarterGui:SetCore("SendNotification", { Title = "Goal Reached!", Text = "You reached " .. targetRebirthValue .. " rebirths", Duration = 5 })
                    return
                end
                ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                task.wait(0.1)
            end
        end)
    end
end

targetSwitch = RebirthsWithoutPacksFolder:AddSwitch("Auto Rebirth Target", onAutoRebirthTarget)

local infiniteSwitch = nil

local function onAutoRebirthInfinite(enabled)
    _G.infiniteRebirthActive = enabled
    if enabled then
        if _G.targetRebirthActive then
            if targetSwitch then targetSwitch:Set(false) end
            _G.targetRebirthActive = false
        end
        task.spawn(function()
            task.wait(0.1)
            while _G.infiniteRebirthActive do
                ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                task.wait(0.1)
            end
        end)
    end
end

infiniteSwitch = RebirthsWithoutPacksFolder:AddSwitch("Auto Rebirth (Infinitely)", onAutoRebirthInfinite)

local function onAutoSize2(enabled)
    _G.autoSizeActive = enabled
    if enabled then
        task.spawn(function()
            task.wait()
            while _G.autoSizeActive do
                ReplicatedStorage.rEvents.changeSpeedSizeRemote:InvokeServer("changeSize", 2)
                task.wait(0.1)
            end
        end)
    end
end

RebirthsWithoutPacksFolder:AddSwitch("Auto Size 2", onAutoSize2)

local function onAutoTeleportMK(enabled)
    _G.teleportActive = enabled
    if enabled then
        task.spawn(function()
            task.wait()
            while _G.teleportActive do
                if LocalPlayer.Character then
                    LocalPlayer.Character:MoveTo(Vector3.new(-8646, 17, -5738))
                end
                task.wait(0.5)
            end
        end)
    end
end

RebirthsWithoutPacksFolder:AddSwitch("Auto Teleport to Muscle King", onAutoTeleportMK)

local RockToolsFolder = FarmTab:AddFolder("Rock + Tools")

local function onGamepassAutoLift()
    local gamepassIds = ReplicatedStorage:FindFirstChild("gamepassIds")
    if not gamepassIds then return end
    for _, value in ipairs(gamepassIds:GetChildren()) do
        local iv = Instance.new("IntValue")
        iv.Name = value.Name
        iv.Value = value.Value
        iv.Parent = LocalPlayer.ownedGamepasses
    end
end

RockToolsFolder:AddButton("Gamepass AutoLift", onGamepassAutoLift)

local selectedTool = nil
local farmingActive = false
local selectedRock = nil

local ToolSelectLabel = RockToolsFolder:AddLabel("Select the tool you will use:")
ToolSelectLabel.TextSize = 22

local function onSelectTool(value)
    selectedTool = value
end

local ToolDropdown = RockToolsFolder:AddDropdown("Select Tool", onSelectTool)
ToolDropdown:Add("Weight")
ToolDropdown:Add("Pushups")
ToolDropdown:Add("Situps")
ToolDropdown:Add("Handstands")
ToolDropdown:Add("Fast Punch")
ToolDropdown:Add("Stomp")
ToolDropdown:Add("Ground Slam")

local rockDurabilityMap = { ["Jungle Rock"] = 10000000 }

local function onSelectRock(value)
    selectedRock = value
end

local RockDropdown = RockToolsFolder:AddDropdown("Select Rock", onSelectRock)
for rockName in pairs(rockDurabilityMap) do
    RockDropdown:Add(rockName)
end

local function fastPunch()
    local muscleEvent = LocalPlayer:FindFirstChild("muscleEvent")
    if muscleEvent then
        muscleEvent:FireServer("punch", "leftHand")
        muscleEvent:FireServer("punch", "rightHand")
    end
end

local function doToolAction()
    local char = LocalPlayer.Character
    if not char then return end
    if selectedTool == "Weight" then
        local tool = char:FindFirstChild("Weight") or LocalPlayer.Backpack:FindFirstChild("Weight")
        if tool then
            pcall(function() tool.Parent = char end)
        end
    elseif selectedTool == "Fast Punch" then
        fastPunch()
    elseif selectedTool == "Stomp" then
        local tool = LocalPlayer.Backpack:FindFirstChild("Stomp")
        if tool then
            pcall(function()
                tool.Parent = char
                local attackTime = tool:FindFirstChild("attackTime")
                if attackTime then attackTime.Value = 0 end
            end)
            pcall(function()
                local stomp = char:FindFirstChild("Stomp")
                if stomp then stomp:Activate() end
            end)
        end
    elseif selectedTool == "Ground Slam" then
        local tool = LocalPlayer.Backpack:FindFirstChild("Ground Slam")
        if tool then
            pcall(function()
                tool.Parent = char
                local attackTime = tool:FindFirstChild("attackTime")
                if attackTime then attackTime.Value = 0 end
            end)
            pcall(function()
                local slam = char:FindFirstChild("Ground Slam")
                if slam then slam:Activate() end
            end)
        end
    end
end

local function onFarmStart(enabled)
    farmingActive = enabled
    if enabled then
        task.spawn(function()
            while farmingActive do
                local char = LocalPlayer.Character
                if not char then
                    LocalPlayer.CharacterAdded:Wait()
                    char = LocalPlayer.Character
                end
                doToolAction()
                if selectedRock and rockDurabilityMap[selectedRock] then
                    local durabilityNeeded = rockDurabilityMap[selectedRock]
                    local durability = LocalPlayer:FindFirstChild("Durability") and LocalPlayer.Durability.Value or 0
                    if durability >= durabilityNeeded then
                        for _, machine in ipairs(workspace.machinesFolder:GetDescendants()) do
                            if machine.Name == selectedRock then
                                fastPunch()
                            end
                        end
                    end
                end
                task.wait()
            end
        end)
    else
        if selectedTool then
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChild(selectedTool)
                if tool then
                    pcall(function() tool.Parent = LocalPlayer.Backpack end)
                end
            end
        end
    end
end

RockToolsFolder:AddSwitch("Start", onFarmStart)

local AutoEquipFolder = FarmTab:AddFolder("Auto Equip tools")

local function onUnlockGamepassAutoLift()
    local gamepassIds = ReplicatedStorage:FindFirstChild("gamepassIds")
    if not gamepassIds then return end
    for _, value in ipairs(gamepassIds:GetChildren()) do
        local iv = Instance.new("IntValue")
        iv.Name = value.Name
        iv.Value = value.Value
        iv.Parent = LocalPlayer.ownedGamepasses
    end
end

AutoEquipFolder:AddButton("unlock Gamepass AutoLift", onUnlockGamepassAutoLift)

local function makeAutoEquipSwitch(toolName, genvKey)
    return function(enabled)
        _G[genvKey] = enabled
        if enabled then
            local tool = LocalPlayer.Backpack:FindFirstChild(toolName)
            if tool then
                local char = LocalPlayer.Character
                if char then
                    char.Humanoid:EquipTool(tool)
                end
            end
            task.spawn(function()
                while _G[genvKey] do
                    local muscleEvent = LocalPlayer:FindFirstChild("muscleEvent")
                    if muscleEvent then
                        muscleEvent:FireServer("rep")
                    end
                    task.wait(0.1)
                end
            end)
        else
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChild(toolName)
                if tool then
                    tool.Parent = LocalPlayer.Backpack
                end
            end
        end
    end
end

AutoEquipFolder:AddSwitch("Auto Weight", makeAutoEquipSwitch("Weight", "AutoWeightPro"))
AutoEquipFolder:AddSwitch("Auto Pushups", makeAutoEquipSwitch("Pushups", "AutoPushupsPro"))
AutoEquipFolder:AddSwitch("Auto Handstands", makeAutoEquipSwitch("Handstands", "AutoHandstandsPro"))
AutoEquipFolder:AddSwitch("Auto Situps", makeAutoEquipSwitch("Situps", "AutoSitupsPro"))

local function onAutoPunch(enabled)
    _G.fastHitActivePro = enabled
    if enabled then
        task.spawn(function()
            while _G.fastHitActivePro do
                local punch = LocalPlayer.Backpack:FindFirstChild("Punch")
                if punch then
                    punch.Parent = LocalPlayer.Character
                    local attackTime = punch:FindFirstChild("attackTime")
                    if attackTime then attackTime.Value = 0 end
                end
                task.wait(0.1)
            end
        end)
        task.spawn(function()
            while _G.fastHitActivePro do
                local muscleEvent = LocalPlayer:FindFirstChild("muscleEvent")
                if muscleEvent then
                    muscleEvent:FireServer("punch", "rightHand")
                    muscleEvent:FireServer("punch", "leftHand")
                end
                local char = LocalPlayer.Character
                if char then
                    local punch = char:FindFirstChild("Punch")
                    if punch then punch:Activate() end
                end
                task.wait()
            end
        end)
    else
        local char = LocalPlayer.Character
        if char then
            local punch = char:FindFirstChild("Punch")
            if punch then
                punch.Parent = LocalPlayer.Backpack
            end
        end
    end
end

AutoEquipFolder:AddSwitch("Auto Punch", onAutoPunch)

local function onFastTools(enabled)
    _G.FastToolsPro = enabled
    local backpack = LocalPlayer:WaitForChild("Backpack")
    local toolSettings = {
        { "Punch", "attackTime", enabled and 0 or 0.35 },
        { "Ground Slam", "attackTime", enabled and 0 or 6 },
        { "Stomp", "attackTime", enabled and 0 or 7 },
        { "Handstands", "repTime", enabled and 0 or 1 },
        { "Pushups", "repTime", enabled and 0 or 1 },
        { "Weight", "repTime", enabled and 0 or 1 },
        { "Situps", "repTime", enabled and 0 or 1 },
    }
    for _, setting in ipairs(toolSettings) do
        local tool = backpack:FindFirstChild(setting[1])
        if tool then
            local val = tool:FindFirstChild(setting[2])
            if val then
                val.Value = setting[3]
            end
        end
    end
end

AutoEquipFolder:AddSwitch("Fast Tools", onFastTools)

local StatsTab = Window:AddTab("Stats")

local function formatNumber(n)
    local suffixes = { "", "K", "M", "B", "T", "Qa", "Qi" }
    local index = 1
    while n >= 1000 and index < #suffixes do
        n = n / 1000
        index = index + 1
    end
    return string.format("%.2f%s", n, suffixes[index])
end

local selectedPlayer = nil

local function onSelectPlayer(name)
    selectedPlayer = name
end

local PlayerDropdown = StatsTab:AddDropdown("Select Player", onSelectPlayer)
for _, player in ipairs(game.Players:GetPlayers()) do
    PlayerDropdown:Add(player.Name)
end

game.Players.PlayerAdded:Connect(function(player)
    PlayerDropdown:Add(player.Name)
end)

local statLabels = {}

local statDefs = {
    "Strength", "Gems", "Rebirth", "Agility", "Durability",
    "Kills", "Muscle King Time", "Current Map", "Custom Size",
    "Custom Speed", "Evil Karma", "Good Karma",
    "Enemy life", "Your damage", "Blows to kill him", "Wild Wizard equipped"
}

for _, name in ipairs(statDefs) do
    local lbl = StatsTab:AddLabel(name .. ": N/A")
    lbl.TextSize = 18
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    statLabels[name] = lbl
end

local function getEquippedPetCount(player)
    local equipped = player:FindFirstChild("equippedPets")
    if not equipped then return 0 end
    local count = 0
    for _, pet in ipairs(equipped:GetChildren()) do
        if pet:FindFirstChild("petReference") then
            count = count + 1
        end
    end
    return count
end

local function getEffectiveDurability(player)
    if not player then return 0 end
    local durVal = player:FindFirstChild("Durability")
    local dur = durVal and durVal.Value or 0
    local ultimates = player:FindFirstChild("ultimatesFolder")
    local multiplier = 1
    if ultimates then
        local infernal = ultimates:FindFirstChild("Infernal Health")
        if infernal then multiplier = multiplier + infernal.Value end
    end
    return dur * multiplier
end

local function getWildWizardBonus(player)
    local ls = player:FindFirstChild("leaderstats")
    if not ls then return 0 end
    local str = ls:FindFirstChild("Strength")
    if not str then return 0 end
    local bonus = math.floor((str.Value * 0.1) * (str.Value * str.Value))
    return bonus
end

local function blowsToKill(enemyHp, playerDmg)
    if not playerDmg or playerDmg <= 0 then return "N/A" end
    return math.ceil(enemyHp / playerDmg)
end

local function updateStats(player)
    if not player then
        for _, name in ipairs(statDefs) do
            statLabels[name].Text = name .. ": N/A"
        end
        return
    end

    local function getStat(obj, path)
        local cur = obj
        for _, key in ipairs(path) do
            if cur then cur = cur:FindFirstChild(key) end
        end
        if cur and cur.Value ~= nil then
            return formatNumber(cur.Value)
        end
        return "N/A"
    end

    statLabels["Strength"].Text = "Strength: " .. getStat(player, {"leaderstats", "Strength"})
    statLabels["Gems"].Text = "Gems: " .. getStat(player, {"Gems"})
    statLabels["Rebirth"].Text = "Rebirth: " .. getStat(player, {"leaderstats", "Rebirths"})
    statLabels["Agility"].Text = "Agility: " .. getStat(player, {"Agility"})
    statLabels["Durability"].Text = "Durability: " .. getStat(player, {"Durability"})
    statLabels["Kills"].Text = "Kills: " .. getStat(player, {"leaderstats", "Kills"})
    statLabels["Muscle King Time"].Text = "Muscle King Time: " .. getStat(player, {"muscleKingTime"})
    local cm = player:FindFirstChild("currentMap")
    statLabels["Current Map"].Text = "Current Map: " .. (cm and tostring(cm.Value) or "N/A")
    statLabels["Custom Size"].Text = "Custom Size: " .. getStat(player, {"customSize"})
    statLabels["Custom Speed"].Text = "Custom Speed: " .. getStat(player, {"customSpeed"})
    statLabels["Evil Karma"].Text = "Evil Karma: " .. getStat(player, {"evilKarma"})
    statLabels["Good Karma"].Text = "Good Karma: " .. getStat(player, {"goodKarma"})

    local enemyHp = getEffectiveDurability(player)
    local playerDmg = getEquippedPetCount(LocalPlayer)
    local blows = blowsToKill(enemyHp, playerDmg)
    local wwBonus = getWildWizardBonus(player)

    statLabels["Enemy life"].Text = "Enemy life: " .. (enemyHp > 0 and formatNumber(enemyHp) or "N/A")
    statLabels["Your damage"].Text = "Your damage: " .. (playerDmg > 0 and formatNumber(playerDmg) or "N/A")
    statLabels["Blows to kill him"].Text = "Blows to kill him: " .. tostring(blows)
    statLabels["Wild Wizard equipped"].Text = "Wild Wizard equipped: " .. wwBonus .. " bonus"
end

task.spawn(function()
    while true do
        task.wait()
        if selectedPlayer then
            local target = game.Players:FindFirstChild(selectedPlayer)
            updateStats(target)
        end
    end
end)

local TeleportTab = Window:AddTab("Teleport")

local teleportPoints = {
    { name = "Spawn",          pos = Vector3.new(2, 8, 115) },
    { name = "Secret Area",    pos = Vector3.new(1947, 2, 6191) },
    { name = "Tiny Island",    pos = Vector3.new(-34, 7, 1903) },
    { name = "Frozen Island",  pos = CFrame.new(-2600.00244, 3.67686558, -403.884369, 0.0873617008, 1.0482899e-09, 0.99617666, 3.07204253e-08, 1, -3.7464023e-09, -0.99617666, 3.09302628e-08, 0.0873617008) },
    { name = "Mythical Island", pos = Vector3.new(2255, 7, 1071) },
    { name = "Hell Island",    pos = Vector3.new(-6768, 7, -1287) },
    { name = "Legend Island",  pos = Vector3.new(4604, 991, -3887) },
    { name = "Muscle King",    pos = Vector3.new(-8646, 17, -5738) },
    { name = "Jungle Island",  pos = Vector3.new(-8659, 6, 2384) },
    { name = "Brawl Lava",     pos = Vector3.new(4471, 119, -8836) },
    { name = "Brawl Desert",   pos = Vector3.new(960, 17, -7398) },
    { name = "Brawl Regular",  pos = Vector3.new(-1849, 20, -6335) },
}

for _, tp in ipairs(teleportPoints) do
    local tpName = tp.name
    local tpPos = tp.pos
    TeleportTab:AddButton("Teleport to " .. tpName, function()
        local char = LocalPlayer.Character
        if not char then
            LocalPlayer.CharacterAdded:Wait()
            char = LocalPlayer.Character
        end
        local hrp = char:WaitForChild("HumanoidRootPart")
        if typeof(tpPos) == "CFrame" then
            hrp.CFrame = tpPos
        else
            hrp.CFrame = CFrame.new(tpPos)
        end
        sendTeleportNotif("Teleported to " .. tpName)
    end)
end
