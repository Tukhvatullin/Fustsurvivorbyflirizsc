-- ==============================================================================
-- Skeetparser by Fliriz | Randomizer REDUX + Fust Survival Integration
-- UI Library: LinoriaLib (Galaxy Night Mode, FullBright, Interactive ESP Preview)
-- ==============================================================================

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

pcall(function()
    RunService:UnbindFromRenderStep("FustNoShakeFix")
    RunService:UnbindFromRenderStep("FustLayCameraFix")
    RunService:UnbindFromRenderStep("FustZoomOverride")
end)

-- ==========================================
-- ГЛОБАЛЬНЫЕ НАСТРОЙКИ
-- ==========================================
local Settings = {
    Aimbot_Enabled = false,
    SilentAim_Enabled = false,
    SilentAimMethod = "Raycast",
    HitChance = 100,
    VisCheck_Enabled = false,
    TeamCheck = false,
    Aimbot_ShowFOV = false,
    Aimbot_FOV = 150,
    Aimbot_FOV_Color = Color3.fromRGB(0, 255, 150),
    Aimbot_Smoothness = 0.2,
    Aimbot_360 = false,
    Aimbot_HitPart = "Head",

    Aimbot_StickyAim = false,
    Aimbot_DistCheck_Enabled = true,
    Aimbot_MaxDistance = 800,
    
    SmartBallistics_Enabled = true,

    DistVector_Enabled = false,
    DistVector_UpScale = 1.5,
    DistVector_StrafeScale = 1.2,
    
    Prediction_Enabled = false,
    Prediction_Value = 0.135,
    
    Wallbang_Enabled = false,
    NoSpread_Enabled = false,
    NoRecoil_Enabled = false,
    InfAmmo_Enabled = false,
    
    Gun_Chams_Enabled = false,
    Gun_Chams_Color = Color3.fromRGB(0, 255, 128),
    Gun_Chams_Material = "Neon",
    
    Arm_Chams_Enabled = false,
    Arm_Chams_Color = Color3.fromRGB(0, 170, 255),
    Arm_Chams_Material = "Neon",
    
    Viewmodel_Offset_Enabled = false,
    Viewmodel_Offset_X = 0,
    Viewmodel_Offset_Y = 0,
    Viewmodel_Offset_Z = 0,
    
    Local_Chams_Enabled = false,
    Local_Chams_Color = Color3.fromRGB(200, 0, 255),
    Local_Chams_Material = "Neon",
    
    ESP_Enabled = false,
    ESP_Box = false,
    ESP_SkelHead = false,
    ESP_NeonHat = false,
    ESP_Name = false,
    ESP_HealthBar = false,
    ESP_HealthText = false,
    ESP_Color = Color3.fromRGB(255, 80, 80),
    ESP_TeamColor = Color3.fromRGB(0, 255, 100),
    ESP_Preview_Enabled = true,
    
    Tracers_Enabled = false,
    Tracer_Color = Color3.fromRGB(0, 170, 255),
    Tracer_Cooldown = 0.1,
    
    HitEffect_Enabled = false,
    HitEffect_Color = Color3.fromRGB(0, 255, 255),
    KillEffect_Enabled = false,
    KillEffect_Color = Color3.fromRGB(200, 220, 255),
    
    NightMode_Enabled = false,
    GalaxySky_Enabled = false,
    FullBright_Enabled = false,
    FullBright_Brightness = 2.5,
    Saturation_Value = 0,
    
    Crosshair_Enabled = false,
    Crosshair_RGB = false,
    Crosshair_Color = Color3.fromRGB(0, 255, 128),
    Crosshair_Size = 12,
    Crosshair_Speed = 4,
    
    HitSound_Enabled = false,
    HitSound_Type = "Skeet",
    HitSound_Volume = 100,
    HitSound_CustomID = "",
    
    Speed_Enabled = false,
    Speed_Value = 16,
    
    BhopRage_Enabled = false,
    BhopRage_Speed = 65,
    
    TP_Enabled = false,
    TP_Distance = 12,
    
    AA_Enabled = false,
    AA_Yaw = "None",
    AA_Pitch = "None",
    AA_Lean = "None",
    AA_SpinSpeed = 15,
    
    AACSP_Enabled = false,
    AACSP_Local_Enabled = false,
    SpinbotCS_Enabled = false,
    SpinbotCS_Speed = 25,
    
    Desync_Enabled = false,
    Desync_Distance = 5,
    Desync_Vis = false,
    Desync_AntiPredict = false,
    
    PeakKill_Enabled = false,
    PeakKill_Mode = "Вверх (Up)",
    PeakKill_Offset = 15,
    PeakKill_CycleKey = "X",

    Fust_Speed_Enabled = false,
    Fust_Speed_Mode = "Smooth",
    Fust_Speed_Power = 23,

    Fust_BulletTracer_Enabled = false,
    Fust_Lay_Enabled = false,
    Fust_Spider_Enabled = false,
    Fust_Spider_Speed = 40,
    Fust_InvCheck_Enabled = false,
    Fust_InvCheck_Size = 24,
    Fust_CarEsp_Enabled = false,
    Fust_NoShake_Enabled = false,
    Fust_NoFog_Enabled = false,
    Fust_Zoom_Enabled = false,
    Fust_Zoom_FOV = 20
}

local SOUND_PRESETS = {
    ["Skeet"] = "rbxassetid://4817809188",
    ["Rust"] = "rbxassetid://5043539486",
    ["COD"] = "rbxassetid://6607204501"
}

local Connections = {}
local espCache = {}

-- Все внутренние переменные и интерактивные смещения ESP упакованы в State
local State = {
    LockedTarget = nil,
    StickyTarget = nil,
    smoothedTargetVel = {},
    teamCheckCache = {},
    IsUnloaded = false,
    BulletCharge = 0,
    IsLMBDown = false,
    lastLocalClick = 0,
    lastHitSoundTime = 0,

    -- Интерактивные смещения элементов ESP (изменяются перетаскиванием в ESP Preview)
    ESP_Layout = {
        Name_X = 0,       -- Смещение относительно центра бокса (в долях ширины бокса)
        Name_Y = -0.09,   -- Смещение относительно верха бокса (в долях высоты бокса)
        HpBar_X = -0.56,  -- Смещение относительно центра бокса
        HpBar_Y = 0,      -- Смещение по высоте
        HpText_X = -0.76, -- Смещение текста HP относительно центра бокса
        HpText_Y = 0.13,  -- Смещение текста HP относительно верха бокса
        Inv_X = 0,        -- Смещение InvCheck по горизонтали
        Inv_Y = -0.30     -- Смещение InvCheck относительно верха бокса
    },

    modifiedParts = {},
    originalGrips = {},
    originalC0s = {},
    cachedAmmoTables = {},
    lastAmmoTool = nil,
    lastAmmoChar = nil,
    cs2SpinAngle = 0,
    cs2SwitchTimer = 0,
    cs2SwitchState = 1,
    currentAAYaw = 0,
    currentGhost = nil,
    realPosition = nil,
    targetYaw = 0,
    targetPitch = 0,
    doOverride = false,
    fakeCFrameServer = nil,
    storedVelocity = nil,
    isPeeking = false,
    peekOriginCFrame = nil,
    wasAACS2_Active = false,
    origProps = {},

    LAY_CAMERA_HEIGHT_BOOST = 2.6,
    fustRealCFrame = nil,
    fustRealVelocity = nil,
    fustIsSpoofed = false,
    speedAttachment = nil,
    speedLinearVel = nil,
    wasSittingLastFrame = false,
    wasThirdPersonActive = false,
    savedCameraMode = LocalPlayer.CameraMode,
    savedMinZoom = LocalPlayer.CameraMinZoomDistance,
    savedMaxZoom = LocalPlayer.CameraMaxZoomDistance,

    baseGameFOV = 70,
    currentZoomFOV = 70,
    isHoldingZoomKey = false,
    isZoomingProcess = false,
    savedBaseMouseSens = 1,

    trackedCars = {},
    espUpdateConn = nil,
    workspaceAddedConn = nil,

    invUIs = {},
    lastInvUpdate = 0,
    memoryInventory = {},

    tracerFolder = nil,
    lastFireTimestamp = 0,
    lastMuzzlePos = nil,
    lastFireDirection = nil,
    trackedProjectiles = {},
    candidateProjectiles = {},
    tracerWorkspaceConn = nil,
    weaponFireConns = {},
    hookedSounds = {},

    weaponBallisticsCache = {},
    learnedWeaponBallistics = {},
    savedAtmosphereData = {},
    OrigLighting = {
        ClockTime = Lighting.ClockTime,
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart
    }
}

do
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Atmosphere") and not State.savedAtmosphereData[child] then
            State.savedAtmosphereData[child] = {
                Density = child.Density,
                Haze = child.Haze,
                Glare = child.Glare
            }
        end
    end

    local oldTracerFolder = workspace:FindFirstChild("FustBulletTracers")
    if oldTracerFolder then oldTracerFolder:Destroy() end
    State.tracerFolder = Instance.new("Folder")
    State.tracerFolder.Name = "FustBulletTracers"
    State.tracerFolder.Parent = workspace

    State.fustOverlayGui = Instance.new("ScreenGui")
    State.fustOverlayGui.Name = "FustOverlayGui"
    State.fustOverlayGui.ResetOnSpawn = false
    if not pcall(function() State.fustOverlayGui.Parent = CoreGui end) then
        State.fustOverlayGui.Parent = PlayerGui
    end
end

local function tiltHeadDown(character)
    for _, desc in ipairs(character:GetDescendants()) do
        if desc:IsA("Motor6D") and (desc.Name == "Neck" or (desc.Part1 and desc.Part1.Name == "Head")) then
            desc.Transform = desc.Transform * CFrame.Angles(math.rad(-40), 0, 0)
        end
    end
end

local function isPlayerSittingInVehicle(humanoid)
    if not humanoid then return false end
    if humanoid.SeatPart ~= nil then return true end
    if humanoid.Sit then return true end
    if humanoid:GetState() == Enum.HumanoidStateType.Seated then return true end
    return false
end

local function getSeatedVehicleModel(character)
    if not character then return nil end
    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        local model = hum.SeatPart:FindFirstAncestorOfClass("Model")
        if model and model ~= workspace and model ~= character then
            return model
        end
        return hum.SeatPart.Parent
    end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local root = hrp.AssemblyRootPart
        if root and not root:IsDescendantOf(character) then
            local model = root:FindFirstAncestorOfClass("Model")
            if model and model ~= workspace then return model end
            return root
        end
    end
    return nil
end

local function cleanupSpeedConstraints()
    if State.speedLinearVel then State.speedLinearVel:Destroy() State.speedLinearVel = nil end
    if State.speedAttachment then State.speedAttachment:Destroy() State.speedAttachment = nil end
end

local function getOrCreateLinearVelocity(hrp)
    if not State.speedAttachment or State.speedAttachment.Parent ~= hrp or not State.speedLinearVel or State.speedLinearVel.Parent ~= hrp then
        cleanupSpeedConstraints()
        State.speedAttachment = Instance.new("Attachment")
        State.speedAttachment.Name = "FustSmoothAttachment"
        State.speedAttachment.Parent = hrp

        State.speedLinearVel = Instance.new("LinearVelocity")
        State.speedLinearVel.Name = "FustSmoothVelocity"
        State.speedLinearVel.Attachment0 = State.speedAttachment
        State.speedLinearVel.RelativeTo = Enum.ActuatorRelativeTo.World
        State.speedLinearVel.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
        State.speedLinearVel.PrimaryTangentAxis = Vector3.new(1, 0, 0)
        State.speedLinearVel.SecondaryTangentAxis = Vector3.new(0, 0, 1)
        State.speedLinearVel.MaxForce = 25000
        State.speedLinearVel.Enabled = false
        State.speedLinearVel.Parent = hrp
    end
    return State.speedLinearVel
end

local function startZoomHold()
    if not Settings.Fust_Zoom_Enabled or State.isHoldingZoomKey then return end
    Camera = workspace.CurrentCamera
    if not State.isZoomingProcess then
        local curFov = Camera and Camera.FieldOfView or 70
        State.baseGameFOV = (curFov > 35) and curFov or 70
        State.currentZoomFOV = curFov
        State.savedBaseMouseSens = math.clamp(UserInputService.MouseDeltaSensitivity, 0.05, 10)
    end
    State.isHoldingZoomKey = true
    State.isZoomingProcess = true
end

local function stopZoomHold()
    if not State.isHoldingZoomKey then return end
    State.isHoldingZoomKey = false
    UserInputService.MouseDeltaSensitivity = State.savedBaseMouseSens
end

RunService:BindToRenderStep("FustZoomOverride", Enum.RenderPriority.Last.Value + 50, function(dt)
    if State.IsUnloaded or not Settings.Fust_Zoom_Enabled or not State.isZoomingProcess then return end
    Camera = workspace.CurrentCamera
    if not Camera then return end

    if State.isHoldingZoomKey then
        State.currentZoomFOV = State.currentZoomFOV + (Settings.Fust_Zoom_FOV - State.currentZoomFOV) * math.clamp(dt * 18, 0, 1)
        Camera.FieldOfView = State.currentZoomFOV
        UserInputService.MouseDeltaSensitivity = State.savedBaseMouseSens * (State.currentZoomFOV / math.max(State.baseGameFOV, 1))
    else
        State.currentZoomFOV = State.currentZoomFOV + (State.baseGameFOV - State.currentZoomFOV) * math.clamp(dt * 20, 0, 1)
        Camera.FieldOfView = State.currentZoomFOV

        if math.abs(State.currentZoomFOV - State.baseGameFOV) < 0.25 then
            Camera.FieldOfView = State.baseGameFOV
            UserInputService.MouseDeltaSensitivity = State.savedBaseMouseSens
            State.isZoomingProcess = false
        end
    end
end)

RunService:BindToRenderStep("FustNoShakeFix", Enum.RenderPriority.Camera.Value + 1, function()
    if State.IsUnloaded or not Settings.Fust_NoShake_Enabled then return end
    local currentCF = Camera.CFrame
    local x, y, z = currentCF:ToOrientation()
    if math.abs(z) > 0.001 then
        Camera.CFrame = CFrame.new(currentCF.Position) * CFrame.fromOrientation(x, y, 0)
    end
end)

local function setFustLayState(state)
    Settings.Fust_Lay_Enabled = state
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

    if not state then
        if rootPart and State.fustIsSpoofed and State.fustRealCFrame then
            rootPart.CFrame = State.fustRealCFrame
            if State.fustRealVelocity then rootPart.AssemblyLinearVelocity = State.fustRealVelocity end
        end
        if humanoid then humanoid.CameraOffset = Vector3.zero end
        State.fustIsSpoofed = false
        State.fustRealCFrame = nil
        State.fustRealVelocity = nil
    else
        State.fustIsSpoofed = false
    end
end

RunService:BindToRenderStep("FustLayCameraFix", Enum.RenderPriority.Camera.Value + 10, function()
    if State.IsUnloaded or not Settings.Fust_Lay_Enabled then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or isPlayerSittingInVehicle(hum) then return end

    local basePos = (State.fustRealCFrame and State.fustRealCFrame.Position) or hrp.Position
    local minSafeCameraY = basePos.Y + 1.2

    if not Settings.TP_Enabled and Camera.CFrame.Position.Y < minSafeCameraY then
        local camRot = Camera.CFrame - Camera.CFrame.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position.X, minSafeCameraY, Camera.CFrame.Position.Z) * camRot
    end
end)

-- ЛОГИКА FUST BULLET TRACER
local function drawFustTracerSegment(p0, p1)
    local dist = (p1 - p0).Magnitude
    if dist < 0.05 or dist > 600 then return end

    local seg = Instance.new("Part")
    seg.Name = "FustTracerSeg"
    seg.Anchored = true
    seg.CanCollide = false
    seg.CanQuery = false
    seg.CanTouch = false
    seg.CastShadow = false
    seg.Material = Enum.Material.Neon
    seg.Color = Color3.fromRGB(0, 230, 255)
    seg.Size = Vector3.new(0.09, 0.09, dist)
    seg.CFrame = CFrame.lookAt((p0 + p1) * 0.5, p1)
    seg.Transparency = 0.05
    seg.Parent = State.tracerFolder

    task.spawn(function()
        local lifeTime = 1.8
        local elapsed = 0
        while elapsed < lifeTime and seg.Parent and not State.IsUnloaded do
            local dt = RunService.RenderStepped:Wait()
            elapsed = elapsed + dt
            local progress = elapsed / lifeTime
            seg.Transparency = 0.05 + (0.95 * progress)
            local thickness = math.max(0.02, 0.09 * (1 - progress * 0.6))
            seg.Size = Vector3.new(thickness, thickness, dist)
        end
        if seg and seg.Parent then
            seg:Destroy()
        end
    end)
end

local function isHoldingBowWeapon()
    local char = LocalPlayer.Character
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") or child:IsA("Model") then
                local n = child.Name:lower()
                if n:find("bow") or n:find("crossbow") or n:find("лук") or n:find("арбалет") then
                    return true
                end
            end
        end
    end
    if Camera then
        for _, child in ipairs(Camera:GetChildren()) do
            local n = child.Name:lower()
            if n:find("bow") or n:find("crossbow") then
                return true
            end
        end
    end
    return false
end

local function findWeaponMuzzlePosition()
    if Camera then
        for _, desc in ipairs(Camera:GetDescendants()) do
            if desc:IsA("BasePart") or desc:IsA("Attachment") then
                local n = desc.Name:lower()
                if n:find("muzzle") or n:find("fire") or n:find("barrel") or n:find("flash") or n:find("shoot") or n:find("spawn") then
                    return desc:IsA("Attachment") and desc.WorldPosition or desc.Position
                end
            end
        end
    end
    local char = LocalPlayer.Character
    if char then
        for _, desc in ipairs(char:GetDescendants()) do
            if desc:IsA("BasePart") or desc:IsA("Attachment") then
                local n = desc.Name:lower()
                if n:find("muzzle") or n:find("fire") or n:find("barrel") or n:find("flash") then
                    return desc:IsA("Attachment") and desc.WorldPosition or desc.Position
                end
            end
        end
        local head = char:FindFirstChild("Head")
        if head then
            return head.Position + Camera.CFrame.LookVector * 1.8
        end
    end
    return Camera.CFrame.Position + Camera.CFrame.LookVector * 1.5
end

local function simulateBallisticTrajectory(startPos, direction, initialSpeed, bulletDrop)
    task.spawn(function()
        local currentPos = startPos
        local velocity = direction.Unit * (initialSpeed or 850)
        local gravity = Vector3.new(0, -(bulletDrop or 65), 0)

        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera, State.tracerFolder}
        rayParams.FilterType = Enum.RaycastFilterType.Exclude

        local elapsed = 0
        while elapsed < 2.2 and Settings.Fust_BulletTracer_Enabled and not State.IsUnloaded do
            local dt = RunService.RenderStepped:Wait()
            elapsed = elapsed + dt

            if next(State.trackedProjectiles) ~= nil and elapsed < 0.25 then
                break
            end

            velocity = velocity + gravity * dt
            local stepVec = velocity * dt
            local hit = workspace:Raycast(currentPos, stepVec, rayParams)

            if hit then
                drawFustTracerSegment(currentPos, hit.Position)
                break
            else
                local nextPos = currentPos + stepVec
                drawFustTracerSegment(currentPos, nextPos)
                currentPos = nextPos
            end
        end
    end)
end

local function onFireDetected(customOrigin, customDir, customSpeed, isBowRelease)
    if not Settings.Fust_BulletTracer_Enabled or State.IsUnloaded then return end
    local now = tick()
    if now - State.lastFireTimestamp < 0.03 then return end
    State.lastFireTimestamp = now

    State.lastMuzzlePos = customOrigin or findWeaponMuzzlePosition()
    State.lastFireDirection = customDir or Camera.CFrame.LookVector

    local holdingBow = isBowRelease or isHoldingBowWeapon()
    local fireId = now

    local waitDelay = holdingBow and 0.075 or 0.035
    task.delay(waitDelay, function()
        if Settings.Fust_BulletTracer_Enabled and not State.IsUnloaded and State.lastFireTimestamp == fireId and next(State.trackedProjectiles) == nil then
            local spd = customSpeed or (holdingBow and 320 or 900)
            local drop = holdingBow and 85 or 55
            simulateBallisticTrajectory(State.lastMuzzlePos, State.lastFireDirection, spd, drop)
        end
    end)
end

local function isPartAttachedToPlayerOrWeapon(part)
    if not part or not part.Parent then return true end
    if LocalPlayer.Character and part:IsDescendantOf(LocalPlayer.Character) then return true end
    if Camera and part:IsDescendantOf(Camera) then return true end

    for _, child in ipairs(part:GetChildren()) do
        if (child:IsA("WeldConstraint") or child:IsA("JointInstance")) and child.Enabled then
            local p0, p1 = child.Part0, child.Part1
            local other = (p0 == part) and p1 or p0
            if other and ((LocalPlayer.Character and other:IsDescendantOf(LocalPlayer.Character)) or (Camera and other:IsDescendantOf(Camera))) then
                return true
            end
        end
    end

    local root = part.AssemblyRootPart
    if root and LocalPlayer.Character and root:IsDescendantOf(LocalPlayer.Character) then
        return true
    end

    return false
end

local function isPotentialProjectile(inst)
    if not inst:IsA("BasePart") then return false end
    if inst.Parent == State.tracerFolder then return false end
    if inst:IsA("Terrain") then return false end
    if LocalPlayer.Character and inst:IsDescendantOf(LocalPlayer.Character) then return false end
    if Camera and inst:IsDescendantOf(Camera) then return false end

    local model = inst:FindFirstAncestorOfClass("Model")
    if model and (Players:GetPlayerFromCharacter(model) or model:FindFirstChildOfClass("Humanoid")) then
        return false
    end

    local name = inst.Name:lower()
    local parentName = inst.Parent and inst.Parent.Name:lower() or ""

    if name:find("shell") or name:find("casing") or name:find("mag") or name:find("clip") or name:find("effect") or name:find("hole") then
        return false
    end

    local isNamedProj = name:find("bullet") or name:find("arrow") or name:find("proj") or name:find("bolt")
        or name:find("tracer") or name:find("round") or name:find("ammo") or name:find("slug") or name:find("pellet") or name:find("стрел")
        or parentName:find("bullet") or parentName:find("arrow") or parentName:find("proj") or parentName:find("cast") or parentName:find("debris")

    local isSmallPart = (inst.Size.X < 3.0 and inst.Size.Y < 3.0 and inst.Size.Z < 14.0)
    local camPos = Camera and Camera.CFrame.Position or Vector3.zero
    local muzzlePos = State.lastMuzzlePos or camPos
    local distFromShooter = math.min((inst.Position - muzzlePos).Magnitude, (inst.Position - camPos).Magnitude)

    if isNamedProj and distFromShooter < 50 then return true end
    if isSmallPart and distFromShooter < 22 and (tick() - State.lastFireTimestamp) < 0.55 then return true end
    return false
end

-- ==========================================
-- УМНЫЙ АВТО-ДЕТЕКТОР БАЛЛИСТИКИ
-- ==========================================
local WEAPON_CLASS_PRESETS = {
    Bow      = { Speed = 480,  Drop = 28, Drag = 0.015, FlatRange = 30,  IsProjectile = true  },
    Crossbow = { Speed = 550,  Drop = 24, Drag = 0.015, FlatRange = 35,  IsProjectile = true  },
    Nailgun  = { Speed = 250,  Drop = 90, Drag = 0.045, FlatRange = 10,  IsProjectile = true  },
    Shotgun  = { Speed = 850,  Drop = 12, Drag = 0.015, FlatRange = 65,  IsProjectile = false },
    Pistol   = { Speed = 1150, Drop = 6,  Drag = 0.005, FlatRange = 95,  IsProjectile = false },
    SMG      = { Speed = 1100, Drop = 8,  Drag = 0.006, FlatRange = 85,  IsProjectile = false },
    Rifle    = { Speed = 1350, Drop = 9,  Drag = 0.005, FlatRange = 110, IsProjectile = false },
    Sniper   = { Speed = 1800, Drop = 5,  Drag = 0.002, FlatRange = 160, IsProjectile = false }
}

local function getEquippedWeaponNameAndInstance()
    local char = LocalPlayer.Character
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") or (child:IsA("Model") and (child:FindFirstChild("Handle") or child:FindFirstChildWhichIsA("BasePart"))) then
                local n = child.Name:lower()
                if not (n:find("armor") or n:find("vest") or n:find("helmet") or n:find("bag") or n:find("backpack") or n:find("hat") or n:find("hair")) then
                    return child.Name, child
                end
            end
        end
    end
    if Camera then
        for _, child in ipairs(Camera:GetChildren()) do
            if child:IsA("Model") and child.Name ~= "CS2_FakeLag_Ghost" and child.Name ~= "FustBulletTracers" then
                return child.Name, child
            end
        end
    end
    return "DefaultGun", nil
end

local function classifyWeaponByName(name)
    local n = string.lower(name or "")
    if n:find("crossbow") or n:find("арбалет") or n:find("cross") then
        return WEAPON_CLASS_PRESETS.Crossbow
    elseif n:find("bow") or n:find("лук") or n:find("hunting") or n:find("compound") then
        return WEAPON_CLASS_PRESETS.Bow
    elseif n:find("nail") or n:find("гвозд") then
        return WEAPON_CLASS_PRESETS.Nailgun
    elseif n:find("revolver") or n:find("pistol") or n:find("python") or n:find("m92") or n:find("glock") or n:find("beretta") or n:find("deagle") or n:find("usp") or n:find("p250") or n:find("револьв") or n:find("пешк") or n:find("пистол") or n:find(" кольт") or n:find("макар") then
        return WEAPON_CLASS_PRESETS.Pistol
    elseif n:find("shotgun") or n:find("pipe") or n:find("double") or n:find("spas") or n:find("pump") or n:find("eoka") or n:find("saiga") or n:find("дроб") or n:find("пайп") or n:find("двуствол") then
        return WEAPON_CLASS_PRESETS.Shotgun
    elseif n:find("l96") or n:find("bolt") or n:find("sniper") or n:find("awp") or n:find("svd") or n:find("m24") or n:find("kar98") or n:find("болт") or n:find("снайп") or n:find("свд") then
        return WEAPON_CLASS_PRESETS.Sniper
    elseif n:find("smg") or n:find("thompson") or n:find("mp5") or n:find("uzi") or n:find("mac") or n:find("vector") or n:find("p90") or n:find("томпс") or n:find("смг") then
        return WEAPON_CLASS_PRESETS.SMG
    elseif n:find("ak") or n:find("assault") or n:find("lr") or n:find("m249") or n:find("sar") or n:find("semi") or n:find("rifle") or n:find("m4") or n:find("scar") or n:find("калаш") or n:find("бердан") or n:find("винтовк") or n:find("автомат") then
        return WEAPON_CLASS_PRESETS.Rifle
    end
    return nil
end

local function extractStatsFromInstance(inst)
    local foundSpeed, foundDrop = nil, nil
    if not inst then return nil, nil end

    pcall(function()
        for k, v in pairs(inst:GetAttributes()) do
            if type(v) == "number" and v > 0 then
                local kl = string.lower(k)
                if (kl:find("bulletspeed") or kl:find("projectilespeed") or kl:find("muzzlevelocity") or kl == "speed" or kl == "velocity") and v >= 120 and v <= 6000 then
                    foundSpeed = v
                elseif (kl:find("bulletdrop") or kl:find("gravity") or kl == "drop") and v >= 0 and v <= 300 then
                    foundDrop = v
                end
            end
        end
    end)

    for _, desc in ipairs(inst:GetDescendants()) do
        if desc:IsA("NumberValue") or desc:IsA("IntValue") then
            local nl = string.lower(desc.Name)
            local v = desc.Value
            if (nl:find("bulletspeed") or nl:find("projectilespeed") or nl:find("muzzlevelocity") or nl == "speed") and v >= 120 and v <= 6000 then
                foundSpeed = v
            elseif (nl:find("bulletdrop") or nl:find("gravity") or nl == "drop") and v >= 0 and v <= 300 then
                foundDrop = v
            end
        elseif desc:IsA("ModuleScript") then
            pcall(function()
                local data = require(desc)
                if type(data) == "table" then
                    for k, v in pairs(data) do
                        if type(v) == "number" then
                            local kl = string.lower(tostring(k))
                            if (kl:find("bulletspeed") or kl:find("projectilespeed") or kl:find("muzzlevelocity") or kl == "speed" or kl == "velocity") and v >= 120 and v <= 6000 then
                                foundSpeed = v
                            elseif (kl:find("bulletdrop") or kl:find("gravity") or kl == "drop") and v >= 0 and v <= 300 then
                                foundDrop = v
                            end
                        end
                    end
                end
            end)
        end
    end

    return foundSpeed, foundDrop
end

local function getActiveWeaponBallistics()
    local weaponName, activeTool = getEquippedWeaponNameAndInstance()

    if State.learnedWeaponBallistics[weaponName] then
        return State.learnedWeaponBallistics[weaponName]
    end

    if State.weaponBallisticsCache[weaponName] then
        return State.weaponBallisticsCache[weaponName]
    end

    local preset = classifyWeaponByName(weaponName)
    if not preset then
        if isHoldingBowWeapon() then
            preset = WEAPON_CLASS_PRESETS.Bow
        else
            preset = WEAPON_CLASS_PRESETS.Pistol
        end
    end

    local finalSpeed = preset.Speed
    local finalDrop = preset.Drop
    local finalDrag = preset.Drag
    local finalFlatRange = preset.FlatRange
    local isProj = preset.IsProjectile

    if activeTool then
        local s, d = extractStatsFromInstance(activeTool)
        if s then finalSpeed = s end
        if d then
            finalDrop = d
            if d > 40 then
                isProj = true
                finalFlatRange = 15
            end
        end
    end

    local result = {
        Speed = finalSpeed,
        Drop = finalDrop,
        Drag = finalDrag,
        FlatRange = finalFlatRange,
        IsProjectile = isProj
    }
    State.weaponBallisticsCache[weaponName] = result
    return result
end

local function registerCandidateProjectile(obj)
    if (not Settings.Fust_BulletTracer_Enabled and not Settings.SmartBallistics_Enabled) or State.IsUnloaded then return end
    local part = nil
    if obj:IsA("BasePart") then
        part = obj
    elseif obj:IsA("Model") then
        part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    end
    if not part or State.trackedProjectiles[part] or State.candidateProjectiles[part] then return end

    if isPotentialProjectile(part) then
        local wName = getEquippedWeaponNameAndInstance()
        State.candidateProjectiles[part] = {
            LastPos = part.Position,
            LastVelY = nil,
            SpawnTime = tick(),
            ConfirmedFrames = 0,
            WeaponName = wName
        }
    end
end

local function isActualFireSoundName(soundName, parentName)
    local s = soundName:lower()
    local p = parentName:lower()

    if s:find("draw") or s:find("pull") or s:find("charge") or s:find("aim") or s:find("reload") or s:find("equip") or s:find("empty") or s:find("click") or s:find("stretch") then
        return false
    end

    if s:find("fire") or s:find("shoot") or s:find("shot") or s:find("release") or s:find("loose") or s:find("bang") or s:find("gun") or s:find("bow") then
        return true
    end
    if (p:find("muzzle") or p:find("barrel") or p:find("fire") or p:find("weapon") or p:find("bow")) and (s:find("play") or s:find("sound") or s:find("sfx")) then
        return true
    end
    return false
end

local function hookSingleDescendant(desc)
    if not desc then return end
    if desc:IsA("Sound") and not State.hookedSounds[desc] then
        local pName = desc.Parent and desc.Parent.Name or ""
        if isActualFireSoundName(desc.Name, pName) then
            State.hookedSounds[desc] = true
            local c1 = desc.Played:Connect(function()
                if Settings.Fust_BulletTracer_Enabled then onFireDetected() end
            end)
            local c2 = desc:GetPropertyChangedSignal("Playing"):Connect(function()
                if Settings.Fust_BulletTracer_Enabled and desc.Playing then onFireDetected() end
            end)
            table.insert(State.weaponFireConns, c1)
            table.insert(State.weaponFireConns, c2)
        end
    elseif desc:IsA("ParticleEmitter") then
        local n = desc.Name:lower()
        local pName = desc.Parent and desc.Parent.Name:lower() or ""
        if pName:find("muzzle") or pName:find("fire") or n:find("flash") or n:find("muzzle") then
            local c = desc:GetPropertyChangedSignal("Enabled"):Connect(function()
                if Settings.Fust_BulletTracer_Enabled and desc.Enabled then onFireDetected() end
            end)
            table.insert(State.weaponFireConns, c)
        end
    end
end

local function hookWeaponFireEffects(rootContainer)
    if not rootContainer then return end
    for _, desc in ipairs(rootContainer:GetDescendants()) do
        hookSingleDescendant(desc)
    end

    local conn = rootContainer.DescendantAdded:Connect(function(desc)
        if not Settings.Fust_BulletTracer_Enabled or State.IsUnloaded then return end
        hookSingleDescendant(desc)

        local n = desc.Name:lower()
        local pName = desc.Parent and desc.Parent.Name:lower() or ""
        if desc:IsA("Sound") and isActualFireSoundName(n, pName) then
            task.defer(function()
                if desc and desc.Parent and (desc.IsPlaying or desc.Playing) then
                    onFireDetected()
                end
            end)
        elseif (desc:IsA("PointLight") or desc:IsA("SpotLight")) and (pName:find("muzzle") or pName:find("barrel") or n:find("flash")) then
            onFireDetected()
        end
    end)
    table.insert(State.weaponFireConns, conn)
end

local function setFustBulletTracerState(state)
    Settings.Fust_BulletTracer_Enabled = state

    for _, c in ipairs(State.weaponFireConns) do
        if c.Connected then c:Disconnect() end
    end
    table.clear(State.weaponFireConns)
    table.clear(State.hookedSounds)

    if not state and not Settings.SmartBallistics_Enabled then
        if State.tracerWorkspaceConn then State.tracerWorkspaceConn:Disconnect() State.tracerWorkspaceConn = nil end
    end
    table.clear(State.trackedProjectiles)
    table.clear(State.candidateProjectiles)

    if state or Settings.SmartBallistics_Enabled then
        if state then
            if LocalPlayer.Character then hookWeaponFireEffects(LocalPlayer.Character) end
            if Camera then hookWeaponFireEffects(Camera) end
        end
        if not State.tracerWorkspaceConn then
            State.tracerWorkspaceConn = workspace.DescendantAdded:Connect(function(desc)
                if (not Settings.Fust_BulletTracer_Enabled and not Settings.SmartBallistics_Enabled) or State.IsUnloaded then return end
                task.defer(registerCandidateProjectile, desc)
            end)
        end
    end
    if not state and State.tracerFolder then
        State.tracerFolder:ClearAllChildren()
    end
end

setFustBulletTracerState(Settings.Fust_BulletTracer_Enabled)

-- ЛОГИКА FUST CAR ESP
local function getRussianVehicleName(rawName)
    local lower = string.lower(rawName or "")
    if lower:find("atv") or lower:find("quad") or lower:find("квадр") or lower:find("wheeler") or lower:find("buggy") then
        return "Квадроцикл"
    elseif lower:find("boat") or lower:find("ship") or lower:find("raft") or lower:find("jetski") or lower:find("лодк") or lower:find("катер") then
        return "Лодка"
    elseif lower:find("heli") or lower:find("chopper") or lower:find("gyro") or lower:find("minicopter") then
        return "Вертолет"
    elseif lower:find("bike") or lower:find("moto") then
        return "Мотоцикл"
    elseif lower:find("car") or lower:find("sedan") or lower:find("truck") or lower:find("jeep") or lower:find("uaz") then
        return "Машина"
    end
    return rawName
end

local function isVehicleModel(model)
    if not model or not model:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    if model:FindFirstChildOfClass("Humanoid") then return false end
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("VehicleSeat") or (desc:IsA("Seat") and desc.Name:lower():find("driver")) then return true end
    end
    return false
end

local function createCarESP(carModel)
    if State.trackedCars[carModel] then return end
    local rootPart = carModel.PrimaryPart or carModel:FindFirstChildWhichIsA("VehicleSeat", true) or carModel:FindFirstChildWhichIsA("BasePart", true)
    if not rootPart then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "FustCarHighlight"
    highlight.Adornee = carModel
    highlight.FillColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = State.fustOverlayGui

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "FustCarBillboard"
    billboard.Adornee = rootPart
    billboard.Size = UDim2.new(0, 170, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 4.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = State.fustOverlayGui

    local displayName = getRussianVehicleName(carModel.Name)
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = displayName
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0.15
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 13
    textLabel.Parent = billboard

    State.trackedCars[carModel] = { Highlight = highlight, Billboard = billboard, Label = textLabel, Root = rootPart, RussianName = displayName }
end

local function clearAllCarESP()
    for _, data in pairs(State.trackedCars) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
    end
    table.clear(State.trackedCars)
end

local function scanWorkspaceForCars()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("VehicleSeat") then
            local carModel = obj:FindFirstAncestorOfClass("Model")
            if carModel and carModel ~= workspace then createCarESP(carModel) end
        elseif obj:IsA("Model") and isVehicleModel(obj) then
            createCarESP(obj)
        end
    end
end

local function setFustCarEspState(state)
    Settings.Fust_CarEsp_Enabled = state

    if state then
        scanWorkspaceForCars()
        State.workspaceAddedConn = workspace.DescendantAdded:Connect(function(desc)
            if not Settings.Fust_CarEsp_Enabled or State.IsUnloaded then return end
            task.defer(function()
                if desc:IsA("VehicleSeat") then
                    local carModel = desc:FindFirstAncestorOfClass("Model")
                    if carModel and carModel ~= workspace then createCarESP(carModel) end
                elseif desc:IsA("Model") and isVehicleModel(desc) then
                    createCarESP(desc)
                end
            end)
        end)

        State.espUpdateConn = RunService.RenderStepped:Connect(function()
            if State.IsUnloaded or not Settings.Fust_CarEsp_Enabled then return end
            local myChar = LocalPlayer.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local myPos = (State.fustRealCFrame and State.fustRealCFrame.Position) or (myHrp and myHrp.Position) or Camera.CFrame.Position

            for carModel, data in pairs(State.trackedCars) do
                if not carModel or not carModel.Parent or not data.Root or not data.Root.Parent then
                    if data.Highlight then data.Highlight:Destroy() end
                    if data.Billboard then data.Billboard:Destroy() end
                    State.trackedCars[carModel] = nil
                else
                    local dist = math.floor((data.Root.Position - myPos).Magnitude)
                    data.Label.Text = string.format("%s [%d м]", data.RussianName, dist)
                end
            end
        end)
    else
        if State.workspaceAddedConn then State.workspaceAddedConn:Disconnect() State.workspaceAddedConn = nil end
        if State.espUpdateConn then State.espUpdateConn:Disconnect() State.espUpdateConn = nil end
        clearAllCarESP()
    end
end

-- ЛОГИКА FUST INVENTORY ESP (С ПОДДЕРЖКОЙ ПЕРЕТАСКИВАНИЯ ИЗ ESP PREVIEW)
local function updateInvCheck()
    if not Settings.Fust_InvCheck_Enabled or State.IsUnloaded then
        for _, ui in pairs(State.invUIs) do if ui then ui:Destroy() end end
        table.clear(State.invUIs)
        table.clear(State.memoryInventory)
        return
    end

    local now = tick()
    if now - State.lastInvUpdate < 0.25 then return end
    State.lastInvUpdate = now

    local iconSize = Settings.Fust_InvCheck_Size or 24
    -- Конвертируем смещение из 2D превью в мировые координаты относительно головы игрока
    local studsX = State.ESP_Layout.Inv_X * 3.5
    local studsY = 0.5 - (State.ESP_Layout.Inv_Y * 6.5)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local ui = State.invUIs[plr]
            
            if not ui or ui.Parent ~= head then
                if ui then ui:Destroy() end
                ui = Instance.new("BillboardGui")
                ui.Name = "InvCheckUI"
                ui.Adornee = head
                ui.Size = UDim2.new(0, 220, 0, 70)
                ui.StudsOffsetWorldSpace = Vector3.new(0, studsY, 0)
                ui.StudsOffset = Vector3.new(studsX, 0, 0)
                ui.AlwaysOnTop = true

                local itemsContainer = Instance.new("Frame")
                itemsContainer.Name = "ItemsContainer"
                itemsContainer.Size = UDim2.new(1, 0, 1, 0)
                itemsContainer.Position = UDim2.new(0, 0, 0, 0)
                itemsContainer.BackgroundTransparency = 1
                itemsContainer.Parent = ui

                local gridLayout = Instance.new("UIGridLayout")
                gridLayout.Name = "Grid"
                gridLayout.CellSize = UDim2.new(0, iconSize, 0, iconSize)
                gridLayout.CellPadding = UDim2.new(0, 3, 0, 3)
                gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                gridLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
                gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
                gridLayout.Parent = itemsContainer
                
                ui.Parent = head
                State.invUIs[plr] = ui
            else
                ui.StudsOffsetWorldSpace = Vector3.new(0, studsY, 0)
                ui.StudsOffset = Vector3.new(studsX, 0, 0)
            end

            local container = ui.ItemsContainer
            local grid = container:FindFirstChild("Grid")
            if grid then
                grid.CellSize = UDim2.new(0, iconSize, 0, iconSize)
            end

            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("Frame") then child:Destroy() end
            end

            if not State.memoryInventory[plr] then
                State.memoryInventory[plr] = {}
            end

            local equippedTool = nil
            for _, child in ipairs(plr.Character:GetChildren()) do
                if child:IsA("Tool") then
                    equippedTool = child
                    State.memoryInventory[plr][child.Name] = true
                end
            end

            local bp = plr:FindFirstChild("Backpack")
            if bp then
                for _, child in ipairs(bp:GetChildren()) do
                    if child:IsA("Tool") then
                        State.memoryInventory[plr][child.Name] = true
                    end
                end
            end

            local allTools = {}
            if equippedTool then
                table.insert(allTools, equippedTool.Name)
            end
            
            for toolName, _ in pairs(State.memoryInventory[plr]) do
                if not equippedTool or toolName ~= equippedTool.Name then
                    table.insert(allTools, toolName)
                end
            end

            local cornerRadius = math.clamp(math.floor(iconSize * 0.18), 2, 6)

            for i, toolName in ipairs(allTools) do
                local isEquipped = equippedTool and (toolName == equippedTool.Name)
                
                local slot = Instance.new("Frame")
                slot.BackgroundColor3 = isEquipped and Color3.fromRGB(45, 115, 255) or Color3.fromRGB(28, 28, 34)
                slot.BackgroundTransparency = 0.2
                slot.BorderSizePixel = 0
                slot.LayoutOrder = isEquipped and 1 or (i + 1)
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, cornerRadius)
                corner.Parent = slot
                
                if isEquipped then
                    local stroke = Instance.new("UIStroke")
                    stroke.Color = Color3.fromRGB(130, 200, 255)
                    stroke.Thickness = 1.2
                    stroke.Parent = slot
                end

                local toolNameLabel = Instance.new("TextLabel")
                toolNameLabel.Size = UDim2.new(0.92, 0, 0.92, 0)
                toolNameLabel.Position = UDim2.new(0.04, 0, 0.04, 0)
                toolNameLabel.BackgroundTransparency = 1
                toolNameLabel.Text = toolName
                toolNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                toolNameLabel.TextStrokeTransparency = 0.3
                toolNameLabel.Font = Enum.Font.GothamSemibold
                toolNameLabel.TextScaled = true
                toolNameLabel.TextWrapped = true
                toolNameLabel.Parent = slot

                slot.Parent = container
            end
        end
    end
end

-- ==============================================================================
-- ДВИЖОК ОСВЕЩЕНИЯ
-- ==============================================================================
local function updateLighting()
    pcall(function()
        if Settings.NightMode_Enabled or Settings.GalaxySky_Enabled then
            if not Lighting:FindFirstChild("CustomSky") then
                local sky = Instance.new("Sky")
                sky.Name = "CustomSky"
                sky.SkyboxBk = "rbxassetid://159454299"
                sky.SkyboxDn = "rbxassetid://159454296"
                sky.SkyboxFt = "rbxassetid://159454293"
                sky.SkyboxLf = "rbxassetid://159454286"
                sky.SkyboxRt = "rbxassetid://159454300"
                sky.SkyboxUp = "rbxassetid://159454288"
                sky.StarCount = 5000
                sky.Parent = Lighting
            end
        else
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("Sky") and v.Name == "CustomSky" then
                    v:Destroy()
                end
            end
        end

        if Settings.FullBright_Enabled then
            Lighting.ClockTime = 14
            Lighting.Brightness = Settings.FullBright_Brightness
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000
        elseif Settings.NightMode_Enabled then
            Lighting.ClockTime = 14
            Lighting.Brightness = 0.5
            Lighting.Ambient = Color3.fromRGB(25, 25, 45)
            Lighting.OutdoorAmbient = Color3.fromRGB(25, 25, 45)
            Lighting.GlobalShadows = true
            Lighting.FogEnd = Settings.Fust_NoFog_Enabled and 1000000 or State.OrigLighting.FogEnd
        else
            Lighting.ClockTime = State.OrigLighting.ClockTime
            Lighting.Brightness = State.OrigLighting.Brightness
            Lighting.Ambient = State.OrigLighting.Ambient
            Lighting.OutdoorAmbient = State.OrigLighting.OutdoorAmbient
            Lighting.GlobalShadows = State.OrigLighting.GlobalShadows
            Lighting.FogEnd = Settings.Fust_NoFog_Enabled and 1000000 or State.OrigLighting.FogEnd
            Lighting.FogStart = Settings.Fust_NoFog_Enabled and 999999 or State.OrigLighting.FogStart
        end

        if not Settings.Fust_NoFog_Enabled then
            for atm, data in pairs(State.savedAtmosphereData) do
                if atm and atm.Parent then
                    atm.Density = data.Density
                    atm.Haze = data.Haze
                    atm.Glare = data.Glare
                end
            end
        end
    end)
end

-- ==============================================================================
-- ДВИЖОК WALLBANG
-- ==============================================================================
local function restoreWalls()
    for part, origData in pairs(State.modifiedParts) do
        if part and part.Parent then
            part.CanCollide = origData.CanCollide
            part.Transparency = origData.Transparency
        end
    end
    State.modifiedParts = {}
end

local function GetClosestTargetWallbang()
    local target = nil
    local shortestDist = 160
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local rootPart = player.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        target = rootPart
                    end
                end
            end
        end
    end
    return target
end

-- ==============================================================================
-- БОЕВЫЕ ЭФФЕКТЫ
-- ==============================================================================
local function PlayCombatEffect(effectType, targetData)
    if State.IsUnloaded then return end

    task.spawn(function()
        pcall(function()
            if effectType == "Hit" and Settings.HitEffect_Enabled then
                local pos = typeof(targetData) == "Vector3" and targetData or (targetData and targetData.Position)
                if not pos then return end

                for _ = 1, 14 do
                    local shard = Instance.new("Part")
                    shard.Name = "HitParticleShard"
                    local shardSize = math.random(30, 45) / 100
                    shard.Size = Vector3.new(shardSize, shardSize, shardSize)
                    shard.Material = Enum.Material.Neon
                    shard.Color = Settings.HitEffect_Color
                    shard.CFrame = CFrame.new(pos) * CFrame.Angles(
                        math.rad(math.random(0, 360)),
                        math.rad(math.random(0, 360)),
                        math.rad(math.random(0, 360))
                    )
                    shard.Anchored = true
                    shard.CanCollide = false
                    shard.CanQuery = false
                    shard.CanTouch = false
                    shard.CastShadow = false
                    shard.Parent = workspace

                    local randomDir = Vector3.new(
                        math.random(-100, 100),
                        math.random(-60, 100),
                        math.random(-100, 100)
                    ).Unit * (math.random(30, 55) / 10)

                    local targetCF = CFrame.new(pos + randomDir) * CFrame.Angles(
                        math.rad(math.random(0, 360)),
                        math.rad(math.random(0, 360)),
                        math.rad(math.random(0, 360))
                    )

                    local dur = math.random(40, 55) / 100
                    TweenService:Create(shard, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        CFrame = targetCF,
                        Size = Vector3.new(0.04, 0.04, 0.04),
                        Transparency = 1
                    }):Play()

                    Debris:AddItem(shard, dur + 0.05)
                end

            elseif effectType == "Kill" and Settings.KillEffect_Enabled then
                local char = typeof(targetData) == "Instance" and (targetData:IsA("Model") and targetData or targetData:FindFirstAncestorOfClass("Model")) or nil
                if not char then return end

                local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                if not root then return end

                local ghostModel = Instance.new("Model")
                ghostModel.Name = "AscendingKillGhost"

                local highlight = Instance.new("Highlight")
                highlight.FillColor = Settings.KillEffect_Color
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.2
                highlight.OutlineTransparency = 0.1
                highlight.Adornee = ghostModel
                highlight.Parent = ghostModel

                local partsToTween = {}
                for _, p in pairs(char:GetChildren()) do
                    if p:IsA("BasePart") and p.Transparency < 1 and p.Name ~= "HumanoidRootPart" then
                        local clone = p:Clone()
                        for _, ch in pairs(clone:GetChildren()) do
                            if not ch:IsA("SpecialMesh") then ch:Destroy() end
                        end
                        clone.Anchored = true
                        clone.CanCollide = false
                        clone.CanQuery = false
                        clone.CanTouch = false
                        clone.CastShadow = false
                        clone.Material = Enum.Material.Neon
                        clone.Color = Settings.KillEffect_Color
                        clone.Transparency = 0.15
                        clone.Parent = ghostModel
                        table.insert(partsToTween, {Part = clone, OrigCF = clone.CFrame})
                    end
                end

                ghostModel.Parent = workspace

                local ascendStuds = 24
                local ascendDuration = 1.45
                local twistAngle = math.rad(50)

                for _, item in ipairs(partsToTween) do
                    local targetCF = item.OrigCF * CFrame.Angles(0, twistAngle, 0) + Vector3.new(0, ascendStuds, 0)
                    TweenService:Create(item.Part, TweenInfo.new(ascendDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        CFrame = targetCF,
                        Transparency = 1
                    }):Play()
                end

                TweenService:Create(highlight, TweenInfo.new(ascendDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    FillTransparency = 1,
                    OutlineTransparency = 1
                }):Play()

                Debris:AddItem(ghostModel, ascendDuration + 0.3)
            end
        end)
    end)
end

-- ==========================================
-- ФИЗИЧЕСКИЙ РЕШАТЕЛЬ ТРАЕКТОРИИ
-- ==========================================
local function CalculateChance(Percentage)
    Percentage = math.floor(Percentage)
    local chance = math.floor(Random.new():NextNumber(0, 1) * 100) / 100
    return chance <= Percentage / 100
end

local function getDirection(Origin, Position)
    return (Position - Origin).Unit * 1000
end

local function getSmoothTargetVelocity(targetPart)
    if not targetPart then return Vector3.zero end
    local rawVel = targetPart.AssemblyLinearVelocity or Vector3.zero
    local model = targetPart:FindFirstAncestorOfClass("Model") or targetPart
    local prevVel = State.smoothedTargetVel[model] or rawVel
    local filteredVel = prevVel:Lerp(rawVel, 0.18)
    State.smoothedTargetVel[model] = filteredVel
    return filteredVel
end

local function getPredictedTargetPosition(targetPart, originPos)
    if not targetPart then return Vector3.zero end
    local targetPos = targetPart.Position
    local targetVel = getSmoothTargetVelocity(targetPart)
    local startPos = originPos or (Camera and Camera.CFrame.Position) or Vector3.zero

    if Settings.SmartBallistics_Enabled then
        local stats = getActiveWeaponBallistics()
        local projSpeed = math.max(stats.Speed or 1150, 60)
        local projDrop = stats.Drop or 6
        local drag = stats.Drag or 0.005
        local flatRange = stats.FlatRange or 90

        local dist = (targetPos - startPos).Magnitude

        local horizSpeed = Vector3.new(targetVel.X, 0, targetVel.Z).Magnitude
        local effectiveVel = Vector3.zero
        if horizSpeed > 1.2 then
            effectiveVel = Vector3.new(
                targetVel.X,
                math.clamp(targetVel.Y * 0.2, -10, 10),
                targetVel.Z
            )
        end

        local flightTime = dist / projSpeed
        local predictedPos = targetPos

        for _ = 1, 3 do
            predictedPos = targetPos + (effectiveVel * flightTime)
            local newDist = (predictedPos - startPos).Magnitude
            local avgSpeed = projSpeed / (1 + drag * flightTime)
            flightTime = newDist / math.max(avgSpeed, 50)
        end

        if not stats.IsProjectile and dist <= flatRange then
            return predictedPos
        end

        local effectiveFlightTime = flightTime
        if not stats.IsProjectile then
            local excessDist = math.max(0, dist - flatRange)
            effectiveFlightTime = excessDist / projSpeed
        end

        local gravityCompensation = 0.5 * projDrop * (effectiveFlightTime ^ 2)
        return predictedPos + Vector3.new(0, gravityCompensation, 0)

    elseif Settings.DistVector_Enabled then
        local distance = (targetPos - startPos).Magnitude
        local distFactor = distance / 100
        local heightOffset = (distFactor * 1.2 + (distFactor ^ 1.85) * 3.8) * Settings.DistVector_UpScale
        local horizontalVel = Vector3.new(targetVel.X, targetVel.Y * 0.2, targetVel.Z)
        local leadTime = (distFactor * 0.28 + (distFactor ^ 1.35) * 0.18) * Settings.DistVector_StrafeScale
        local strafeOffset = horizontalVel * leadTime

        return targetPos + strafeOffset + Vector3.new(0, heightOffset, 0)

    elseif Settings.Prediction_Enabled then
        return targetPos + (targetVel * Settings.Prediction_Value)
    end

    return targetPos
end

local function IsPlayerVisible(Player)
    local PlayerCharacter = Player.Character
    local LocalPlayerCharacter = LocalPlayer.Character
    if not (PlayerCharacter and LocalPlayerCharacter) then return false end

    local PlayerRoot = PlayerCharacter:FindFirstChild(Settings.Aimbot_HitPart) or PlayerCharacter:FindFirstChild("HumanoidRootPart")
    if not PlayerRoot then return false end

    local origin = Camera.CFrame.Position
    local direction = PlayerRoot.Position - origin

    local IgnoreList = {LocalPlayerCharacter, PlayerCharacter, Camera, State.tracerFolder}

    local myVeh = getSeatedVehicleModel(LocalPlayerCharacter)
    if myVeh then table.insert(IgnoreList, myVeh) end

    local targetVeh = getSeatedVehicleModel(PlayerCharacter)
    if targetVeh then table.insert(IgnoreList, targetVeh) end

    for carModel, _ in pairs(State.trackedCars) do
        if carModel and carModel.Parent then
            table.insert(IgnoreList, carModel)
        end
    end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = IgnoreList
    rayParams.IgnoreWater = true

    local result = workspace:Raycast(origin, direction, rayParams)
    if not result then
        return true
    end
    if result.Instance and result.Instance:IsDescendantOf(PlayerCharacter) then
        return true
    end
    return false
end

local function getTargetPart(character)
    if not character then return nil end
    local partName = Settings.Aimbot_HitPart or "Head"
    local targetPart = character:FindFirstChild(partName)
    
    if not targetPart then
        if character:FindFirstChild("Head") then targetPart = character.Head
        elseif character:FindFirstChild("UpperTorso") then targetPart = character.UpperTorso
        elseif character:FindFirstChild("Torso") then targetPart = character.Torso
        else targetPart = character:FindFirstChild("HumanoidRootPart") end
    end
    return targetPart
end

-- ОПТИМИЗИРОВАННЫЙ TEAM CHECK С КЭШИРОВАНИЕМ
local clanKeys = {"Clan", "ClanTag", "ClanName", "Party", "PartyId", "Squad", "TeamId", "Group", "Faction"}

local function checkIsTeammateRaw(player)
    if not player or player == LocalPlayer then return false end

    for i = 1, #clanKeys do
        local key = clanKeys[i]
        local myVal = LocalPlayer:GetAttribute(key)
        local theirVal = player:GetAttribute(key)
        if myVal ~= nil and theirVal ~= nil and myVal == theirVal then
            local s = tostring(myVal)
            if s ~= "" and s ~= "None" and s ~= "0" then
                return true
            end
        end
    end

    for i = 1, #clanKeys do
        local key = clanKeys[i]
        local myObj = LocalPlayer:FindFirstChild(key)
        local theirObj = player:FindFirstChild(key)
        if myObj and theirObj and myObj:IsA("ValueBase") and theirObj:IsA("ValueBase") then
            local mv = tostring(myObj.Value)
            if mv ~= "" and mv ~= "None" and mv ~= "0" and myObj.Value == theirObj.Value then
                return true
            end
        end
    end

    if LocalPlayer.Team ~= nil and player.Team ~= nil and not LocalPlayer.Neutral and not player.Neutral then
        if LocalPlayer.Team == player.Team then
            local allPlayers = Players:GetPlayers()
            local sameTeamCount = 0
            for i = 1, #allPlayers do
                if allPlayers[i].Team == LocalPlayer.Team then
                    sameTeamCount = sameTeamCount + 1
                end
            end
            if #allPlayers > 1 and sameTeamCount < #allPlayers * 0.8 then
                return true
            end
        end
    end

    local char = player.Character
    local head = char and char:FindFirstChild("Head")
    if head then
        local children = head:GetChildren()
        for i = 1, #children do
            local b = children[i]
            if b:IsA("BillboardGui") and b.Name ~= "InvCheckUI" and b.Name ~= "FustCarBillboard" then
                local bChildren = b:GetChildren()
                for j = 1, #bChildren do
                    local desc = bChildren[j]
                    if desc:IsA("TextLabel") or desc:IsA("ImageLabel") then
                        local col = desc:IsA("TextLabel") and desc.TextColor3 or desc.ImageColor3
                        if col.G > 0.75 and col.R < 0.35 and col.B < 0.35 then
                            return true
                        end
                    end
                end
            end
        end
    end

    return false
end

local function isPlayerTeammateCached(player)
    if not player or player == LocalPlayer then return false end
    local now = tick()
    local cached = State.teamCheckCache[player]
    if cached and (now - cached.Time) < 0.5 then
        return cached.Result
    end
    local res = checkIsTeammateRaw(player)
    State.teamCheckCache[player] = { Result = res, Time = now }
    return res
end

local function isTeammate(player)
    if not Settings.TeamCheck then return false end
    return isPlayerTeammateCached(player)
end

local function getClosestToMouse()
    local originPos = (Camera and Camera.CFrame.Position) or Vector3.zero
    local isHoldingAimKey = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)

    if Settings.Aimbot_StickyAim and State.StickyTarget then
        if isHoldingAimKey then
            local char = State.StickyTarget.Parent
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local plr = char and Players:GetPlayerFromCharacter(char)
            if char and hum and hum.Health > 0 and plr then
                if not isTeammate(plr) then
                    local worldDist = (State.StickyTarget.Position - originPos).Magnitude
                    if not Settings.Aimbot_DistCheck_Enabled or worldDist <= Settings.Aimbot_MaxDistance then
                        if not Settings.VisCheck_Enabled or IsPlayerVisible(plr) then
                            local refreshedPart = getTargetPart(char) or State.StickyTarget
                            State.StickyTarget = refreshedPart
                            return refreshedPart
                        end
                    end
                end
            end
            State.StickyTarget = nil
        else
            State.StickyTarget = nil
        end
    elseif not isHoldingAimKey then
        State.StickyTarget = nil
    end

    local target = nil
    local maxScreenDist = Settings.Aimbot_360 and 99999 or Settings.Aimbot_FOV
    local mouseLoc = UserInputService:GetMouseLocation()

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if isTeammate(p) then continue end
                
                local tPart = getTargetPart(p.Character)
                if tPart then
                    local worldDist = (tPart.Position - originPos).Magnitude
                    if Settings.Aimbot_DistCheck_Enabled and worldDist > Settings.Aimbot_MaxDistance then
                        continue
                    end

                    local targetVisible = true
                    if Settings.VisCheck_Enabled then
                        targetVisible = IsPlayerVisible(p)
                    end
                    
                    if targetVisible then
                        local pos, onScreen = Camera:WorldToViewportPoint(tPart.Position)
                        if onScreen or Settings.Aimbot_360 then
                            local screenDist = (Vector2.new(pos.X, pos.Y) - mouseLoc).Magnitude
                            if screenDist < maxScreenDist then
                                maxScreenDist = screenDist
                                target = tPart
                            end
                        end
                    end
                end
            end
        end
    end

    if Settings.Aimbot_StickyAim and isHoldingAimKey and target then
        State.StickyTarget = target
    end

    return target
end

-- ==========================================
-- ЛОГИКА HITSOUND
-- ==========================================
local function playHitSound()
    if not Settings.HitSound_Enabled or State.IsUnloaded then return end
    local now = tick()
    if now - State.lastHitSoundTime < 0.16 then return end
    State.lastHitSoundTime = now

    task.spawn(function()
        local soundId = SOUND_PRESETS[Settings.HitSound_Type]
        if Settings.HitSound_Type == "Custom" or (Settings.HitSound_CustomID and #Settings.HitSound_CustomID > 3) then
            local num = Settings.HitSound_CustomID:gsub("%D", "")
            if #num > 3 then soundId = "rbxassetid://" .. num end
        end
        if not soundId then soundId = SOUND_PRESETS["Skeet"] end

        local snd = Instance.new("Sound")
        snd.Name = "CustomHitSoundEffect"
        snd.SoundId = soundId
        snd.Volume = math.clamp(Settings.HitSound_Volume / 100, 0, 4.0)
        snd.Parent = SoundService
        snd:Play()
        Debris:AddItem(snd, 1.5)
    end)
end

local function onHitMarkerTriggered()
    playHitSound()
    if Settings.HitEffect_Enabled then
        local targetPos = nil
        if State.LockedTarget then
            targetPos = State.LockedTarget.Position
        elseif Mouse.Hit then
            targetPos = Mouse.Hit.Position
        end
        if targetPos then
            PlayCombatEffect("Hit", targetPos)
        end
    end
end

local function isHitMarkerUI(inst)
    if not inst:IsA("GuiObject") then return false end
    local name = inst.Name:lower()
    if name:find("chat") or name:find("frame") or name:find("button") or name:find("list") or name:find("bar") then
        return false
    end
    return name == "hitmarker" or name == "hit" or name == "hit_marker" or name:find("hitmark") ~= nil
end

local function hookGuiElement(elem)
    if not isHitMarkerUI(elem) then return end
    if elem.Parent and isHitMarkerUI(elem.Parent) then return end

    table.insert(Connections, elem:GetPropertyChangedSignal("Visible"):Connect(function()
        if elem.Visible then onHitMarkerTriggered() end
    end))

    if elem:IsA("ImageLabel") or elem:IsA("TextLabel") then
        local prop = elem:IsA("ImageLabel") and "ImageTransparency" or "TextTransparency"
        table.insert(Connections, elem:GetPropertyChangedSignal(prop):Connect(function()
            if elem[prop] < 0.4 then onHitMarkerTriggered() end
        end))
    end
end

for _, v in pairs(PlayerGui:GetDescendants()) do hookGuiElement(v) end
table.insert(Connections, PlayerGui.DescendantAdded:Connect(function(inst)
    if isHitMarkerUI(inst) then
        if inst.Parent and isHitMarkerUI(inst.Parent) then return end
        onHitMarkerTriggered()
        hookGuiElement(inst)
    end
end))

local function hookEnemyDeath(pl)
    if pl == LocalPlayer then return end
    local function hookChar(char)
        task.spawn(function()
            local hum = char:WaitForChild("Humanoid", 4)
            if not hum then return end

            table.insert(Connections, hum.Died:Connect(function()
                if Settings.KillEffect_Enabled and (tick() - State.lastLocalClick < 1.0 or tick() - State.lastHitSoundTime < 1.0) then
                    PlayCombatEffect("Kill", char)
                end
            end))
        end)
    end
    if pl.Character then hookChar(pl.Character) end
    table.insert(Connections, pl.CharacterAdded:Connect(hookChar))
end

for _, p in pairs(Players:GetPlayers()) do hookEnemyDeath(p) end
table.insert(Connections, Players.PlayerAdded:Connect(hookEnemyDeath))

-- ==========================================
-- ИНДИКАТОР PEAK KILL И ЭФФЕКТЫ КАМЕРЫ
-- ==========================================
local showPeakIndicator
do
    State.peakGui = Instance.new("ScreenGui")
    State.peakGui.Name = "HubPeakIndicator"
    State.peakGui.ResetOnSpawn = false
    if not pcall(function() State.peakGui.Parent = CoreGui end) then
        State.peakGui.Parent = PlayerGui
    end

    local peakFrame = Instance.new("Frame")
    peakFrame.Size = UDim2.new(0, 220, 0, 40)
    peakFrame.Position = UDim2.new(0.5, -110, 0.85, 0)
    peakFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    peakFrame.BackgroundTransparency = 1
    peakFrame.BorderSizePixel = 0
    peakFrame.Parent = State.peakGui

    local peakCorner = Instance.new("UICorner")
    peakCorner.CornerRadius = UDim.new(0, 6)
    peakCorner.Parent = peakFrame

    local peakText = Instance.new("TextLabel")
    peakText.Size = UDim2.new(1, 0, 1, 0)
    peakText.BackgroundTransparency = 1
    peakText.Text = "PEAK: ВВЕРХ"
    peakText.TextColor3 = Color3.fromRGB(0, 255, 128)
    peakText.TextTransparency = 1
    peakText.Font = Enum.Font.GothamBold
    peakText.TextSize = 14
    peakText.Parent = peakFrame

    local hidePeakTick = 0
    showPeakIndicator = function(modeStr)
        peakText.Text = "СТОРОНА PEAK: " .. string.upper(modeStr)
        TweenService:Create(peakFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.2, Position = UDim2.new(0.5, -110, 0.78, 0)}):Play()
        TweenService:Create(peakText, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        
        hidePeakTick = tick() + 1.5
        task.defer(function()
            local currentTick = hidePeakTick
            task.wait(1.5)
            if hidePeakTick == currentTick and not State.IsUnloaded then
                TweenService:Create(peakFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1, Position = UDim2.new(0.5, -110, 0.85, 0)}):Play()
                TweenService:Create(peakText, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
            end
        end)
    end

    local cc = Lighting:FindFirstChild("HubColorCorrection")
    if not cc or not cc:IsA("ColorCorrectionEffect") then
        cc = Instance.new("ColorCorrectionEffect")
        cc.Name = "HubColorCorrection"
        cc.Parent = Lighting
    end
    State.colorCorrection = cc
end

-- ==========================================
-- СИСТЕМА CHAMS
-- ==========================================
local function applyViewmodelChams(model)
    if not model then return end
    if not State.origProps[model] then State.origProps[model] = {} end
    
    local descendants = model:IsA("Model") and model:GetDescendants() or {model}
    if not model:IsA("Model") then
        for _, d in pairs(model:GetDescendants()) do table.insert(descendants, d) end
    end
    
    for _, part in pairs(descendants) do
        local partName = string.lower(part.Name)
        local isArm = string.find(partName, "arm") or string.find(partName, "hand") or string.find(partName, "glove")
        local isEnabled = isArm and Settings.Arm_Chams_Enabled or Settings.Gun_Chams_Enabled
        local color = isArm and Settings.Arm_Chams_Color or Settings.Gun_Chams_Color
        local mat = isArm and Settings.Arm_Chams_Material or Settings.Gun_Chams_Material
        
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if not State.origProps[model][part] then
                State.origProps[model][part] = {Color = part.Color, Material = part.Material, Transparency = part.Transparency}
                if part:IsA("MeshPart") then State.origProps[model][part].TextureID = part.TextureID end
            end
            if isEnabled then
                if part.Color ~= color then part.Color = color end
                if part.Material ~= Enum.Material[mat] then part.Material = Enum.Material[mat] end
                if part.Transparency > 0.1 and part.Transparency < 1 then part.Transparency = 0 end
                if part:IsA("MeshPart") and part.TextureID ~= "" then part.TextureID = "" end
            else
                local props = State.origProps[model][part]
                if part.Color ~= props.Color then part.Color = props.Color end
                if part.Material ~= props.Material then part.Material = props.Material end
                if part.Transparency ~= props.Transparency then part.Transparency = props.Transparency end
                if part:IsA("MeshPart") and part.TextureID ~= props.TextureID then part.TextureID = props.TextureID end
            end
        elseif part:IsA("SpecialMesh") then
            if not State.origProps[model][part] then State.origProps[model][part] = {TextureId = part.TextureId} end
            if isEnabled then
                if part.TextureId ~= "" then part.TextureId = "" end
            else
                if part.TextureId ~= State.origProps[model][part].TextureId then part.TextureId = State.origProps[model][part].TextureId end
            end
        elseif part:IsA("SurfaceAppearance") or part:IsA("Decal") or part:IsA("Clothing") or part:IsA("ShirtGraphic") then
            if not State.origProps[model][part] then State.origProps[model][part] = {Parent = part.Parent} end
            if isEnabled then
                if part.Parent ~= nil then part.Parent = nil end
            else
                if part.Parent ~= State.origProps[model][part].Parent then part.Parent = State.origProps[model][part].Parent end
            end
        end
    end
end

local function applyChamsRobust(model, color, mat, isEnabled)
    if not model then return end
    if not State.origProps[model] then State.origProps[model] = {} end
    
    if isEnabled then
        local descendants = model:IsA("Model") and model:GetDescendants() or {model}
        if not model:IsA("Model") then
            for _, d in pairs(model:GetDescendants()) do table.insert(descendants, d) end
        end
        for _, part in pairs(descendants) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                if not State.origProps[model][part] then
                    State.origProps[model][part] = {Color = part.Color, Material = part.Material, Transparency = part.Transparency}
                    if part:IsA("MeshPart") then State.origProps[model][part].TextureID = part.TextureID end
                end
                if part.Color ~= color then part.Color = color end
                if part.Material ~= Enum.Material[mat] then part.Material = Enum.Material[mat] end
                if part.Transparency > 0.1 and part.Transparency < 1 then part.Transparency = 0 end
                if part:IsA("MeshPart") and part.TextureID ~= "" then part.TextureID = "" end
            elseif part:IsA("SpecialMesh") then
                if not State.origProps[model][part] then State.origProps[model][part] = {TextureId = part.TextureId} end
                if part.TextureId ~= "" then part.TextureId = "" end
            elseif part:IsA("Decal") and part.Name == "face" then
                if not State.origProps[model][part] then State.origProps[model][part] = {Transparency = part.Transparency} end
                if part.Transparency ~= 1 then part.Transparency = 1 end
            elseif part:IsA("Clothing") or part:IsA("ShirtGraphic") or part:IsA("SurfaceAppearance") then
                if not State.origProps[model][part] then State.origProps[model][part] = {Parent = part.Parent} end
                if part.Parent ~= nil then part.Parent = nil end
            end
        end
    else
        if State.origProps[model] then
            for part, props in pairs(State.origProps[model]) do
                if part and (part.Parent or props.Parent) then
                    if part:IsA("BasePart") then
                        if props.Color and part.Color ~= props.Color then part.Color = props.Color end
                        if props.Material and part.Material ~= props.Material then part.Material = props.Material end
                        if props.Transparency and part.Transparency ~= props.Transparency then part.Transparency = props.Transparency end
                        if part:IsA("MeshPart") and props.TextureID and part.TextureID ~= props.TextureID then part.TextureID = props.TextureID end
                    elseif part:IsA("SpecialMesh") then
                        if props.TextureId and part.TextureId ~= props.TextureId then part.TextureId = props.TextureId end
                    elseif part:IsA("Decal") then
                        if props.Transparency and part.Transparency ~= props.Transparency then part.Transparency = props.Transparency end
                    elseif part:IsA("Clothing") or part:IsA("ShirtGraphic") or part:IsA("SurfaceAppearance") then
                        if part.Parent ~= props.Parent then part.Parent = props.Parent end
                    end
                end
            end
            State.origProps[model] = nil
        end
    end
end

local function updateAllChams()
    if State.IsUnloaded then return end
    local char = LocalPlayer.Character
    if char then
        applyChamsRobust(char, Settings.Local_Chams_Color, Settings.Local_Chams_Material, Settings.Local_Chams_Enabled)
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            applyChamsRobust(tool, Settings.Gun_Chams_Color, Settings.Gun_Chams_Material, Settings.Gun_Chams_Enabled)
        end
    end
    for _, v in pairs(Camera:GetChildren()) do
        if v.Name ~= "CS2_FakeLag_Ghost" and (v:IsA("Model") or v:IsA("BasePart")) then
            applyViewmodelChams(v)
        end
    end
end

table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function(char)
    cleanupSpeedConstraints()
    State.wasSittingLastFrame = false
    State.isHoldingZoomKey = false
    State.isZoomingProcess = false
    State.StickyTarget = nil
    if Settings.Fust_Lay_Enabled then
        setFustLayState(false)
        pcall(function()
            if Library.Toggles and Library.Toggles.Fust_Lay_Enabled then
                Library.Toggles.Fust_Lay_Enabled:SetValue(false)
            end
        end)
    end
    if Settings.Fust_BulletTracer_Enabled then
        task.defer(hookWeaponFireEffects, char)
    end

    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait(0.1)
            updateAllChams()
        end
    end)
    task.wait(0.2)
    updateAllChams()
end))

if LocalPlayer.Character then
    LocalPlayer.Character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait(0.1)
            updateAllChams()
        end
    end)
end

table.insert(Connections, Camera.ChildAdded:Connect(function(child)
    if child.Name ~= "CS2_FakeLag_Ghost" then
        task.wait(0.1)
        updateAllChams()
    end
end))

-- ==========================================
-- ЛОГИКА PEAK KILL
-- ==========================================
local function getPeakOffset()
    local offsetVal = Settings.PeakKill_Offset
    if Settings.PeakKill_Mode == "Вверх (Up)" then return Vector3.new(0, offsetVal, 0) end
    if Settings.PeakKill_Mode == "Вниз (Down)" then return Vector3.new(0, -offsetVal, 0) end
    
    local camRight = Camera.CFrame.RightVector
    local flatRight = Vector3.new(camRight.X, 0, camRight.Z).Unit
    
    if Settings.PeakKill_Mode == "Влево (Left)" then return flatRight * -offsetVal end
    if Settings.PeakKill_Mode == "Вправо (Right)" then return flatRight * offsetVal end
    return Vector3.new(0, 0, 0)
end

local function startPeek()
    if not State.isPeeking and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        State.isPeeking = true
        local hrp = LocalPlayer.Character.HumanoidRootPart
        State.peekOriginCFrame = hrp.CFrame
        
        State.wasAACS2_Active = Settings.AACSP_Enabled
        if Settings.AACSP_Enabled then
            Settings.AACSP_Enabled = false
            pcall(function()
                if Library.Toggles and Library.Toggles.AACSP_Enabled then
                    Library.Toggles.AACSP_Enabled:SetValue(false)
                end
            end)
        end
    end
end

local function stopPeek()
    if State.isPeeking and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        State.isPeeking = false
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if State.peekOriginCFrame then
            hrp.CFrame = State.peekOriginCFrame
            hrp.AssemblyLinearVelocity = Vector3.zero
            State.peekOriginCFrame = nil
        end
        
        if State.wasAACS2_Active then
            Settings.AACSP_Enabled = true
            pcall(function()
                if Library.Toggles and Library.Toggles.AACSP_Enabled then
                    Library.Toggles.AACSP_Enabled:SetValue(true)
                end
            end)
            State.wasAACS2_Active = false
        end
    end
end

-- ==========================================
-- ПЛАЗМЕННЫЕ ТРЕЙСЕРЫ
-- ==========================================
local function DrawPlasmaTracer(origin, target)
    local distance = (target - origin).Magnitude
    if distance < 5 then return end 

    local mainCFrame = CFrame.lookAt(origin, target) * CFrame.new(0, 0, -distance / 2)

    local glow = Instance.new("Part")
    glow.Name = "CustomTracerFX"
    glow.Size = Vector3.new(0.6, 0.6, distance)
    glow.CFrame = mainCFrame
    glow.Anchored = true
    glow.CanCollide = false
    glow.CanQuery = false
    glow.CanTouch = false
    glow.Material = Enum.Material.Neon
    glow.Color = Settings.Tracer_Color
    glow.Transparency = 0.4
    glow.Parent = workspace

    local glowTween = TweenService:Create(glow, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 1,
        Size = Vector3.new(0.05, 0.05, distance)
    })
    glowTween:Play()
    Debris:AddItem(glow, 0.4)

    task.spawn(function()
        for _ = 1, 3 do 
            if not glow.Parent then break end

            local segmentCount = math.clamp(math.floor(distance / 15), 4, 15)
            local zigzagSize = 0.2 
            local direction = (target - origin).Unit
            local points = {origin}

            for i = 1, segmentCount - 1 do
                local idealPosition = origin + direction * (distance * (i / segmentCount))
                local randomOffset = Vector3.new(
                    (math.random() - 0.5) * 2,
                    (math.random() - 0.5) * 2,
                    (math.random() - 0.5) * 2
                ) * zigzagSize
                table.insert(points, idealPosition + randomOffset)
            end
            table.insert(points, target)

            local coreParts = {}
            for i = 1, #points - 1 do
                local p1 = points[i]
                local p2 = points[i+1]
                local segLength = (p2 - p1).Magnitude
                local segCFrame = CFrame.lookAt(p1, p2) * CFrame.new(0, 0, -segLength / 2)

                local core = Instance.new("Part")
                core.Name = "CustomTracerFX"
                core.Size = Vector3.new(0.12, 0.12, segLength)
                core.CFrame = segCFrame
                core.Anchored = true
                core.CanCollide = false
                core.CanQuery = false
                core.Material = Enum.Material.Neon
                core.Color = Color3.fromRGB(255, 255, 255)
                core.Transparency = 0
                core.Parent = workspace
                table.insert(coreParts, core)
                
                Debris:AddItem(core, 0.1)
            end

            for _, corePart in ipairs(coreParts) do
                TweenService:Create(corePart, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {Transparency = 1}):Play()
            end

            task.wait(0.06)
        end
    end)
end

table.insert(Connections, workspace.DescendantAdded:Connect(function(child)
    if not Settings.Tracers_Enabled then return end
    if child.Name == "CustomTracerFX" or child.Name == "FustTracerSeg" or child.Name:find("HitParticle") then return end
    
    task.defer(function()
        if child:IsA("BasePart") and child.Size.Magnitude < 5 then
            if child:IsDescendantOf(LocalPlayer.Character) then return end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool or not tool:FindFirstChild("Handle") then return end

            local distFromGun = (child.Position - tool.Handle.Position).Magnitude
            
            if distFromGun < 10 then 
                child.Transparency = 1
                for _, effect in pairs(child:GetDescendants()) do
                    if effect:IsA("Trail") or effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
                        effect.Enabled = false
                    end
                end
                
                local fireOrigin = tool:FindFirstChild("FirePoint") or tool:FindFirstChild("Muzzle") or tool.Handle
                local targetPos = nil
                
                if State.LockedTarget then
                    targetPos = getPredictedTargetPosition(State.LockedTarget, fireOrigin.Position)
                elseif Mouse.Hit then
                    targetPos = Mouse.Hit.Position
                else
                    targetPos = Mouse.Origin.Position + (Mouse.UnitRay.Direction * 1000)
                end
                
                if fireOrigin and targetPos then
                    DrawPlasmaTracer(fireOrigin.Position, targetPos)
                end
            end
        end
    end)
end))

-- ==============================================================================
-- БЕЗОПАСНЫЕ И ОПТИМИЗИРОВАННЫЕ МЕТАМЕТОДЫ
-- ==============================================================================
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index
local oldNewIndex = mt.__newindex
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    if State.IsUnloaded then return oldNamecall(self, ...) end

    local method = getnamecallmethod()

    if Settings.SilentAim_Enabled and not checkcaller() then
        if method == "Raycast" and Settings.SilentAimMethod == "Raycast" and self == workspace then
            local origin, dir, params = ...
            if typeof(origin) == "Vector3" and typeof(dir) == "Vector3" and State.LockedTarget then
                local chance = CalculateChance(Settings.HitChance)
                if chance then
                    local targetPos = getPredictedTargetPosition(State.LockedTarget, origin)
                    dir = getDirection(origin, targetPos)
                    State.BulletCharge = 1
                    return oldNamecall(self, origin, dir, params)
                end
            end
        end
    end

    return oldNamecall(self, ...)
end)

mt.__index = newcclosure(function(t, k)
    if State.IsUnloaded then return oldIndex(t, k) end

    if not checkcaller() then
        if t == Mouse and Settings.SilentAim_Enabled and Settings.SilentAimMethod == "Mouse.Hit/Target" then
            local k_lower = string.lower(tostring(k))
            if (k_lower == "target" or k_lower == "hit" or k_lower == "x" or k_lower == "y" or k_lower == "unitray") and State.LockedTarget then
                local chance = CalculateChance(Settings.HitChance)
                if chance then
                    local originPos = (Settings.SmartBallistics_Enabled and findWeaponMuzzlePosition()) or (Camera and Camera.CFrame.Position) or Vector3.zero
                    local targetPos = getPredictedTargetPosition(State.LockedTarget, originPos)

                    if k_lower == "target" then 
                        return State.LockedTarget
                    elseif k_lower == "hit" then 
                        return CFrame.new(targetPos)
                    elseif k_lower == "x" then 
                        return targetPos.X 
                    elseif k_lower == "y" then 
                        return targetPos.Y 
                    elseif k_lower == "unitray" then 
                        return Ray.new(t.Origin, (targetPos - t.Origin).Unit)
                    end
                end
            end
        end

        if Settings.NoRecoil_Enabled and (k == "Recoil" or k == "CameraKick" or k == "Kick" or k == "RecoilData") then
            local orig = oldIndex(t, k)
            return typeof(orig) == "number" and 0 or typeof(orig) == "Vector3" and Vector3.new(0,0,0) or orig
        end
        if Settings.NoSpread_Enabled and (k == "Spread" or k == "MinSpread" or k == "MaxSpread" or k == "Accuracy") then
            return 0
        end
    end
    
    return oldIndex(t, k)
end)

mt.__newindex = newcclosure(function(t, k, v)
    if not State.IsUnloaded and not checkcaller() then
        if t == Camera and k == "FieldOfView" and Settings.Fust_Zoom_Enabled and State.isZoomingProcess then
            if type(v) == "number" and v > 35 then
                State.baseGameFOV = v
            end
            return oldNewIndex(t, k, State.currentZoomFOV)
        end
    end
    return oldNewIndex(t, k, v)
end)

setreadonly(mt, true)

-- ==========================================
-- СЕРВЕРНЫЙ, ЛОКАЛЬНЫЙ АНТИ-АИМ, WALLBANG, FUST MOVEMENTS
-- ==========================================
table.insert(Connections, RunService.Stepped:Connect(function()
    if State.IsUnloaded then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    if Settings.Desync_AntiPredict and State.storedVelocity and not State.isPeeking then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = State.storedVelocity
            State.storedVelocity = nil
        end
    end
end))

table.insert(Connections, RunService.Heartbeat:Connect(function(dt)
    if State.IsUnloaded then return end
    
    if Settings.Fust_InvCheck_Enabled then
        updateInvCheck()
    end

    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not Settings.Wallbang_Enabled then
        restoreWalls()
    else
        pcall(function()
            local target = GetClosestTargetWallbang()
            if target and hrp then
                restoreWalls()
                
                local origin = Camera.CFrame.Position
                local direction = target.Position - origin
                local distance = direction.Magnitude
                
                if distance > 1 then
                    local scanPart = Instance.new("Part")
                    scanPart.Size = Vector3.new(6, 6, distance)
                    scanPart.CFrame = CFrame.new(origin, target.Position) * CFrame.new(0, 0, -distance / 2)
                    scanPart.Transparency = 1
                    scanPart.CanCollide = false
                    scanPart.Anchored = true
                    scanPart.Parent = workspace
                    
                    local partsInPath = workspace:GetPartsInPart(scanPart)
                    scanPart:Destroy()
                    
                    for _, part in ipairs(partsInPath) do
                        if part and part:IsA("BasePart") and not part:IsDescendantOf(char) and not part:IsDescendantOf(target.Parent) then
                            if part.Size.Magnitude > 1 and part.Anchored then
                                local isFloor = (part.Position.Y < hrp.Position.Y - 2) and (part.Size.Y < part.Size.X or part.Size.Y < part.Size.Z)
                                
                                if not isFloor then
                                    if not State.modifiedParts[part] then
                                        State.modifiedParts[part] = {CanCollide = part.CanCollide, Transparency = part.Transparency}
                                    end
                                    part.CanCollide = false
                                    part.Transparency = 0.85
                                end
                            end
                        end
                    end
                end
            else
                restoreWalls()
            end
        end)
    end

    if Settings.InfAmmo_Enabled then
        pcall(function()
            if char ~= State.lastAmmoChar then
                State.lastAmmoChar = char
                State.lastAmmoTool = nil
                State.cachedAmmoTables = {}
                
                if hum then
                    hum.Died:Connect(function()
                        State.lastAmmoTool = nil
                        State.cachedAmmoTables = {}
                    end)
                end
            end
            
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then
                State.lastAmmoTool = nil
                State.cachedAmmoTables = {}
            else
                if tool ~= State.lastAmmoTool then
                    State.lastAmmoTool = tool
                    State.cachedAmmoTables = {}
                    
                    if getgc then
                        for _, obj in ipairs(getgc(true)) do
                            if type(obj) == "table" then
                                pcall(function()
                                    if rawget(obj, "Ammo") or rawget(obj, "Clip") then
                                        table.insert(State.cachedAmmoTables, obj)
                                    end
                                end)
                            end
                        end
                    end
                end
                
                for _, tbl in ipairs(State.cachedAmmoTables) do
                    pcall(function()
                        if rawget(tbl, "Ammo") and type(tbl.Ammo) == "number" then
                            tbl.Ammo = 999
                        end
                        if rawget(tbl, "Clip") and type(tbl.Clip) == "number" then
                            tbl.Clip = 999
                        end
                    end)
                end
            end
        end)
    end

    if hum and hrp and hum.Health > 0 then
        local currentlySitting = isPlayerSittingInVehicle(hum)
        if State.wasSittingLastFrame and not currentlySitting then
            cleanupSpeedConstraints()
            if hum.Sit then hum.Sit = false end
        end
        State.wasSittingLastFrame = currentlySitting

        if Settings.Fust_Spider_Enabled and not currentlySitting and not UserInputService:GetFocusedTextBox() then
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {char, Camera, State.tracerFolder}
                rayParams.FilterType = Enum.RaycastFilterType.Exclude

                local fwdRay = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 2.5, rayParams)
                if fwdRay then
                    local vel = hrp.AssemblyLinearVelocity
                    hrp.AssemblyLinearVelocity = Vector3.new(vel.X, Settings.Fust_Spider_Speed, vel.Z)
                end
            end
        end

        if Settings.Fust_Speed_Enabled and not currentlySitting and not UserInputService:GetFocusedTextBox() then
            local moveDir = hum.MoveDirection
            local flatDir = Vector3.new(moveDir.X, 0, moveDir.Z)
            if flatDir.Magnitude < 0.05 then
                if State.speedLinearVel then State.speedLinearVel.Enabled = false end
            else
                flatDir = flatDir.Unit
                local wave = math.sin(tick() * 7) * 1.1
                local targetSpd = Settings.Fust_Speed_Power + wave

                if Settings.Fust_Speed_Mode == "Smooth" then
                    local lv = getOrCreateLinearVelocity(hrp)
                    lv.PlaneVelocity = Vector2.new(flatDir.X * targetSpd, flatDir.Z * targetSpd)
                    lv.Enabled = true
                else
                    if State.speedLinearVel then State.speedLinearVel.Enabled = false end
                    if hum.FloorMaterial ~= Enum.Material.Air and not Settings.Fust_Lay_Enabled then
                        hum.Jump = true
                    end
                    local curVel = hrp.AssemblyLinearVelocity
                    local currentHoriz = Vector3.new(curVel.X, 0, curVel.Z)
                    local nextHoriz = currentHoriz:Lerp(flatDir * targetSpd, math.clamp(dt * 14, 0, 1))
                    hrp.AssemblyLinearVelocity = Vector3.new(nextHoriz.X, curVel.Y, nextHoriz.Z)
                end
            end
        else
            if State.speedLinearVel then State.speedLinearVel.Enabled = false end
        end

        if Settings.BhopRage_Enabled and not State.isPeeking then
            local isAir = (hum.FloorMaterial == Enum.Material.Air) or (hum:GetState() == Enum.HumanoidStateType.Freefall) or (hum:GetState() == Enum.HumanoidStateType.Jumping)
            if isAir then
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0.05 then
                    hrp.AssemblyLinearVelocity = Vector3.new(
                        moveDir.X * Settings.BhopRage_Speed,
                        hrp.AssemblyLinearVelocity.Y,
                        moveDir.Z * Settings.BhopRage_Speed
                    )
                end
            end
        end

        if Settings.Fust_Lay_Enabled then
            if currentlySitting then
                State.fustIsSpoofed = false
            else
                State.fustRealCFrame = hrp.CFrame
                State.fustRealVelocity = hrp.AssemblyLinearVelocity

                tiltHeadDown(char)

                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {char, Camera, State.tracerFolder}
                rayParams.FilterType = Enum.RaycastFilterType.Exclude

                local rayResult = workspace:Raycast(State.fustRealCFrame.Position, Vector3.new(0, -4, 0), rayParams)
                local targetY = rayResult and (rayResult.Position.Y + 0.55) or (State.fustRealCFrame.Position.Y - 1.5)

                local camLook = Camera.CFrame.LookVector
                local flatLook = Vector3.new(camLook.X, 0, camLook.Z)
                if flatLook.Magnitude > 0.01 then flatLook = flatLook.Unit else flatLook = Vector3.new(0, 0, -1) end

                local layPos = Vector3.new(State.fustRealCFrame.Position.X, targetY, State.fustRealCFrame.Position.Z)
                hrp.CFrame = CFrame.new(layPos, layPos + flatLook) * CFrame.Angles(math.rad(-90), 0, 0)
                State.fustIsSpoofed = true
                return
            end
        end

        if currentlySitting then
            return
        end

        if State.isPeeking and State.peekOriginCFrame then
            local aimPos = State.LockedTarget and getPredictedTargetPosition(State.LockedTarget, State.peekOriginCFrame.Position) or (Camera.CFrame.Position + Camera.CFrame.LookVector * 1000)
            local targetPeakPos = State.peekOriginCFrame.Position + getPeakOffset()
            
            local lookVector = Vector3.new(aimPos.X - targetPeakPos.X, 0, aimPos.Z - targetPeakPos.Z)
            
            if lookVector.Magnitude > 0.001 then
                hrp.CFrame = CFrame.lookAt(targetPeakPos, targetPeakPos + lookVector)
            else
                hrp.CFrame = CFrame.new(targetPeakPos) * Camera.CFrame.Rotation
            end
            
            hrp.AssemblyLinearVelocity = Vector3.zero
            hum.AutoRotate = false
            return 
        end
        
        if Settings.Desync_AntiPredict then
            State.storedVelocity = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(
                math.random(-5000, 5000),
                State.storedVelocity.Y,
                math.random(-5000, 5000)
            )
        end

        State.realPosition = hrp.Position
        local camLook = Camera.CFrame.LookVector
        State.targetYaw = math.atan2(-camLook.X, -camLook.Z)
        State.targetPitch = 0
        State.doOverride = false

        if Settings.AA_Enabled and Settings.AA_Yaw ~= "None" then
            if Settings.AA_Yaw == "Backward" then State.targetYaw = State.targetYaw + math.pi
            elseif Settings.AA_Yaw == "Spinbot" then
                State.currentAAYaw = (State.currentAAYaw or 0) + math.rad(Settings.AA_SpinSpeed * (dt * 60))
                State.targetYaw = State.currentAAYaw
            elseif Settings.AA_Yaw == "Jitter" then State.targetYaw = State.targetYaw + math.rad(math.random(-180, 180)) end
            State.doOverride = true
        end

        if Settings.AACSP_Enabled then
            local moveDir = hum.MoveDirection
            local offsetAngle = 0
            if moveDir.Magnitude > 0.1 then
                local moveAngle = math.atan2(-moveDir.X, -moveDir.Z)
                local diff = moveAngle - State.targetYaw
                if diff > math.pi then diff = diff - math.pi * 2 end
                if diff < -math.pi then diff = diff + math.pi * 2 end
                
                if diff > 0.2 then offsetAngle = math.rad(-90)
                elseif diff < -0.2 then offsetAngle = math.rad(90)
                else
                    State.cs2SwitchTimer = State.cs2SwitchTimer + dt
                    if State.cs2SwitchTimer >= 0.25 then
                        State.cs2SwitchTimer = 0
                        State.cs2SwitchState = State.cs2SwitchState * -1
                    end
                    offsetAngle = State.cs2SwitchState == 1 and math.rad(110) or math.rad(-110)
                end
            else
                offsetAngle = math.rad(180)
            end
            State.targetYaw = State.targetYaw + offsetAngle
            State.targetPitch = math.rad(-55) 
            State.doOverride = true
        end

        if Settings.SpinbotCS_Enabled then
            State.cs2SpinAngle = State.cs2SpinAngle + math.rad(Settings.SpinbotCS_Speed * (dt * 60))
            State.targetYaw = State.cs2SpinAngle
            State.doOverride = true
        end

        local fakePosition = State.realPosition
        if Settings.Desync_Enabled then
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0.1 then
                fakePosition = State.realPosition - (moveDir * Settings.Desync_Distance)
                State.doOverride = true
            else
                fakePosition = State.realPosition
            end
        end

        if State.doOverride then
            hum.AutoRotate = false
            State.fakeCFrameServer = CFrame.new(fakePosition) * CFrame.Angles(0, State.targetYaw, 0) * CFrame.Angles(State.targetPitch, 0, 0)
            hrp.CFrame = State.fakeCFrameServer
        elseif Settings.TP_Enabled then
            hum.AutoRotate = true
            State.fakeCFrameServer = nil
            local yaw = math.atan2(-camLook.X, -camLook.Z)
            hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, yaw, 0)
        else
            hum.AutoRotate = true
            State.fakeCFrameServer = CFrame.new(State.realPosition) * CFrame.Angles(0, State.targetYaw, 0)
        end
    end
end))

-- ==========================================
-- DESYNC GHOST VISUALIZER
-- ==========================================
local function updateDesyncGhost(dt)
    local isAnyAA = Settings.Desync_Enabled or Settings.AACSP_Enabled or Settings.SpinbotCS_Enabled or Settings.AA_Enabled or Settings.AACSP_Local_Enabled
    if not Settings.Desync_Vis or not isAnyAA or State.isPeeking or State.IsUnloaded then
        if State.currentGhost then
            State.currentGhost:Destroy()
            State.currentGhost = nil
        end
        return
    end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        if State.currentGhost then State.currentGhost:Destroy(); State.currentGhost = nil end
        return
    end

    local targetCF = State.fakeCFrameServer or char.HumanoidRootPart.CFrame

    if not State.currentGhost or not State.currentGhost.Parent then
        if State.currentGhost then State.currentGhost:Destroy() end
        char.Archivable = true
        State.currentGhost = Instance.new("Model")
        State.currentGhost.Name = "CS2_FakeLag_Ghost"
        
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Transparency < 1 then
                local clone = part:Clone()
                for _, child in pairs(clone:GetChildren()) do
                    if not child:IsA("SpecialMesh") then
                        child:Destroy()
                    end
                end
                clone.Anchored = true
                clone.CanCollide = false
                clone.CanQuery = false
                clone.CanTouch = false
                clone.CastShadow = false
                clone.Material = Enum.Material.ForceField
                clone.Color = Color3.fromRGB(0, 255, 255)
                clone.Transparency = 0.4
                clone.Parent = State.currentGhost
            end
        end
        State.currentGhost.Parent = workspace
    end

    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local ghostPart = State.currentGhost:FindFirstChild(part.Name)
            if ghostPart then
                local offset = char.HumanoidRootPart.CFrame:ToObjectSpace(part.CFrame)
                local destCF = targetCF * offset
                if (ghostPart.Position - destCF.Position).Magnitude > 25 then
                    ghostPart.CFrame = destCF
                else
                    ghostPart.CFrame = ghostPart.CFrame:Lerp(destCF, math.clamp(dt * 25, 0, 1))
                end
            end
        end
    end
end

-- ==========================================
-- DRAWING API
-- ==========================================
do
    State.fovCircle = Drawing.new("Circle")
    State.fovCircle.Thickness = 1.5
    State.fovCircle.Filled = false
    State.fovCircle.NumSides = 64
    State.fovCircle.Transparency = 1
    State.fovCircle.Visible = false

    State.crosshairLines = {}
    for _ = 1, 4 do
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Transparency = 1
        line.Visible = false
        table.insert(State.crosshairLines, line)
    end

    State.crosshairText = Drawing.new("Text")
    State.crosshairText.Text = "Fliriz cambek)"
    State.crosshairText.Size = 16
    State.crosshairText.Center = true
    State.crosshairText.Outline = true
    State.crosshairText.Transparency = 1
    State.crosshairText.Visible = false
end

local function createNeonHat(character)
    if character:FindFirstChild("ClientNeonHat") then return character.ClientNeonHat end
    local head = character:FindFirstChild("Head")
    if not head then return end

    local hatPart = Instance.new("Part")
    hatPart.Name = "ClientNeonHat"
    hatPart.Size = Vector3.new(2, 1, 2)
    hatPart.Material = Enum.Material.Neon
    hatPart.CanCollide = false
    hatPart.Massless = true
    hatPart.CastShadow = false
    local mesh = Instance.new("SpecialMesh", hatPart)
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://1033714"
    mesh.Scale = Vector3.new(1.5, 1.5, 1.5)
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hatPart
    weld.Part1 = head
    weld.Parent = hatPart
    hatPart.CFrame = head.CFrame * CFrame.new(0, (head.Size.Y / 2) + 0.3, 0)
    hatPart.Parent = character
    return hatPart
end

local function setupESP(player)
    if player == LocalPlayer then return end
    local function cLine()
        local l = Drawing.new("Line"); l.Visible = false; l.Thickness = 1.5; l.Transparency = 1; return l
    end
    local function cSq()
        local s = Drawing.new("Square"); s.Visible = false; s.Thickness = 1.5; s.Filled = false; s.Transparency = 1; return s
    end
    local function cTxt()
        local t = Drawing.new("Text"); t.Visible = false; t.Size = 13; t.Center = true; t.Outline = true; t.Transparency = 1; return t
    end
    espCache[player] = {
        MainBox = cSq(), HeadBox = cSq(),
        Spine = cLine(), LeftArm = cLine(), RightArm = cLine(),
        LeftLeg = cLine(), RightLeg = cLine(),
        NameText = cTxt(), HealthBarBg = cSq(), HealthBarFill = cSq(), HealthText = cTxt()
    }
end

for _, p in pairs(Players:GetPlayers()) do setupESP(p) end
table.insert(Connections, Players.PlayerAdded:Connect(setupESP))
table.insert(Connections, Players.PlayerRemoving:Connect(function(player)
    if espCache[player] then
        for _, obj in pairs(espCache[player]) do pcall(function() obj:Remove() end) end
        espCache[player] = nil
    end
    if State.invUIs[player] then
        State.invUIs[player]:Destroy()
        State.invUIs[player] = nil
    end
    State.memoryInventory[player] = nil
    State.teamCheckCache[player] = nil
end))

-- ==============================================================================
-- LINORIALIB ИНТЕРФЕЙС И ИНТЕРАКТИВНЫЙ 2D ESP PREVIEW (С DRAG & DROP)
-- ==============================================================================
local Window = Library:CreateWindow({
    Title = 'Skeetparser by Fliriz',
    Center = true,
    AutoShow = true,
    TabPadding = 2,
    MenuFadeTime = 0.2
})

local Preview = {
    dummyParts = {},
    bones = {},
    draggingElem = nil,
    dragStartMouse = Vector2.zero,
    dragStartOffset = Vector2.zero,
    -- Координаты референсного бокса внутри превью: CenterX = 99, TopY = 78, Width = 108, Height = 196
    RefCenterX = 99,
    RefTopY = 78,
    RefW = 108,
    RefH = 196
}

local function applyPreviewPositionsFromLayout()
    local L = State.ESP_Layout
    -- 1. Никнейм
    local nameCenterX = Preview.RefCenterX + (L.Name_X * Preview.RefW)
    local nameTopY = Preview.RefTopY + (L.Name_Y * Preview.RefH)
    Preview.NameText.Position = UDim2.fromOffset(nameCenterX - 70, nameTopY)

    -- 2. Полоска HP
    local hpBarX = Preview.RefCenterX + (L.HpBar_X * Preview.RefW)
    local hpBarY = Preview.RefTopY + (L.HpBar_Y * Preview.RefH)
    Preview.HpBg.Position = UDim2.fromOffset(hpBarX, hpBarY)

    -- 3. Текст HP
    local hpTxtX = Preview.RefCenterX + (L.HpText_X * Preview.RefW)
    local hpTxtY = Preview.RefTopY + (L.HpText_Y * Preview.RefH)
    Preview.HpText.Position = UDim2.fromOffset(hpTxtX - 18, hpTxtY)

    -- 4. Иконки инвентаря (Inv ESP)
    local invCenterX = Preview.RefCenterX + (L.Inv_X * Preview.RefW)
    local invTopY = Preview.RefTopY + (L.Inv_Y * Preview.RefH)
    Preview.InvContainer.Position = UDim2.fromOffset(invCenterX - 90, invTopY)
end

local function resetEspPositions()
    State.ESP_Layout.Name_X = 0
    State.ESP_Layout.Name_Y = -0.09
    State.ESP_Layout.HpBar_X = -0.56
    State.ESP_Layout.HpBar_Y = 0
    State.ESP_Layout.HpText_X = -0.76
    State.ESP_Layout.HpText_Y = 0.13
    State.ESP_Layout.Inv_X = 0
    State.ESP_Layout.Inv_Y = -0.30
    applyPreviewPositionsFromLayout()
    State.lastInvUpdate = 0
end

do
    Preview.Gui = Instance.new("ScreenGui")
    Preview.Gui.Name = "SkeetEspPreviewGui"
    Preview.Gui.ResetOnSpawn = false
    Preview.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if not pcall(function() Preview.Gui.Parent = CoreGui end) then
        Preview.Gui.Parent = PlayerGui
    end

    Preview.Panel = Instance.new("Frame")
    Preview.Panel.Name = "PreviewPanel"
    Preview.Panel.Size = UDim2.fromOffset(215, 380)
    Preview.Panel.Position = UDim2.new(0.5, 350, 0.5, -190)
    Preview.Panel.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
    Preview.Panel.BorderSizePixel = 0
    Preview.Panel.Parent = Preview.Gui

    local outerStroke = Instance.new("UIStroke")
    outerStroke.Color = Color3.fromRGB(50, 50, 55)
    outerStroke.Thickness = 1
    outerStroke.Parent = Preview.Panel

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    accent.BorderSizePixel = 0
    accent.Parent = Preview.Panel

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 20)
    title.Position = UDim2.fromOffset(0, 3)
    title.BackgroundTransparency = 1
    title.Text = "ESP PREVIEW (DRAG ELEMENTS)"
    title.TextColor3 = Color3.fromRGB(220, 220, 225)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 11
    title.Parent = Preview.Panel

    Preview.Canvas = Instance.new("Frame")
    Preview.Canvas.Size = UDim2.new(1, -16, 1, -34)
    Preview.Canvas.Position = UDim2.fromOffset(8, 26)
    Preview.Canvas.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
    Preview.Canvas.BorderSizePixel = 0
    Preview.Canvas.ClipsDescendants = true
    Preview.Canvas.Parent = Preview.Panel

    local canvasStroke = Instance.new("UIStroke")
    canvasStroke.Color = Color3.fromRGB(35, 35, 40)
    canvasStroke.Thickness = 1
    canvasStroke.Parent = Preview.Canvas

    local function makeLimb(name, x, y, w, h, cr)
        local f = Instance.new("Frame")
        f.Name = name
        f.Position = UDim2.fromOffset(x, y)
        f.Size = UDim2.fromOffset(w, h)
        f.BackgroundColor3 = Color3.fromRGB(95, 98, 110)
        f.BorderSizePixel = 0
        if cr and cr > 0 then
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, cr)
            c.Parent = f
        end
        f.Parent = Preview.Canvas
        table.insert(Preview.dummyParts, f)
    end

    makeLimb("Head", 82, 85, 34, 34, 6)
    makeLimb("Torso", 75, 123, 48, 68, 3)
    makeLimb("LeftArm", 51, 123, 20, 66, 3)
    makeLimb("RightArm", 127, 123, 20, 66, 3)
    makeLimb("LeftLeg", 75, 195, 22, 72, 3)
    makeLimb("RightLeg", 101, 195, 22, 72, 3)

    Preview.Hat = Instance.new("Frame")
    Preview.Hat.Position = UDim2.fromOffset(73, 73)
    Preview.Hat.Size = UDim2.fromOffset(52, 12)
    Preview.Hat.BackgroundColor3 = Settings.ESP_Color
    Preview.Hat.BorderSizePixel = 0
    Preview.Hat.Visible = false
    Preview.Hat.Parent = Preview.Canvas
    local hc1 = Instance.new("UICorner"); hc1.CornerRadius = UDim.new(0, 4); hc1.Parent = Preview.Hat
    local topCone = Instance.new("Frame")
    topCone.Position = UDim2.fromOffset(12, -8)
    topCone.Size = UDim2.fromOffset(28, 10)
    topCone.BackgroundColor3 = Settings.ESP_Color
    topCone.BorderSizePixel = 0
    topCone.Parent = Preview.Hat
    local hc2 = Instance.new("UICorner"); hc2.CornerRadius = UDim.new(0, 4); hc2.Parent = topCone

    Preview.Box = Instance.new("Frame")
    Preview.Box.Position = UDim2.fromOffset(45, 78)
    Preview.Box.Size = UDim2.fromOffset(108, 196)
    Preview.Box.BackgroundTransparency = 1
    Preview.Box.Visible = false
    Preview.Box.Parent = Preview.Canvas
    Preview.BoxStroke = Instance.new("UIStroke")
    Preview.BoxStroke.Color = Settings.ESP_Color
    Preview.BoxStroke.Thickness = 1.5
    Preview.BoxStroke.Parent = Preview.Box

    Preview.HeadBox = Instance.new("Frame")
    Preview.HeadBox.Position = UDim2.fromOffset(80, 83)
    Preview.HeadBox.Size = UDim2.fromOffset(38, 38)
    Preview.HeadBox.BackgroundTransparency = 1
    Preview.HeadBox.Visible = false
    Preview.HeadBox.Parent = Preview.Canvas
    Preview.HeadBoxStroke = Instance.new("UIStroke")
    Preview.HeadBoxStroke.Color = Settings.ESP_Color
    Preview.HeadBoxStroke.Thickness = 1.5
    Preview.HeadBoxStroke.Parent = Preview.HeadBox

    local function makeBone(x1, y1, x2, y2)
        local line = Instance.new("Frame")
        local dx, dy = x2 - x1, y2 - y1
        local len = math.sqrt(dx * dx + dy * dy)
        local cx, cy = (x1 + x2) / 2, (y1 + y2) / 2
        line.Size = UDim2.fromOffset(len, 2)
        line.Position = UDim2.fromOffset(cx - len / 2, cy - 1)
        line.Rotation = math.deg(math.atan2(dy, dx))
        line.BackgroundColor3 = Settings.ESP_Color
        line.BorderSizePixel = 0
        line.Visible = false
        line.Parent = Preview.Canvas
        table.insert(Preview.bones, line)
    end

    makeBone(99, 121, 99, 185)
    makeBone(99, 130, 61, 155)
    makeBone(99, 130, 137, 155)
    makeBone(99, 185, 86, 240)
    makeBone(99, 185, 112, 240)

    -- Перетаскиваемый Никнейм
    Preview.NameText = Instance.new("TextLabel")
    Preview.NameText.Size = UDim2.fromOffset(140, 18)
    Preview.NameText.BackgroundTransparency = 1
    Preview.NameText.Text = LocalPlayer.Name
    Preview.NameText.TextColor3 = Settings.ESP_Color
    Preview.NameText.TextStrokeTransparency = 0
    Preview.NameText.Font = Enum.Font.GothamBold
    Preview.NameText.TextSize = 12
    Preview.NameText.Active = true
    Preview.NameText.Visible = false
    Preview.NameText.Parent = Preview.Canvas

    -- Перетаскиваемая Полоска HP
    Preview.HpBg = Instance.new("Frame")
    Preview.HpBg.Size = UDim2.fromOffset(6, 196)
    Preview.HpBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Preview.HpBg.BorderSizePixel = 0
    Preview.HpBg.Active = true
    Preview.HpBg.Visible = false
    Preview.HpBg.Parent = Preview.Canvas

    local hpFill = Instance.new("Frame")
    hpFill.Position = UDim2.fromOffset(1, 30)
    hpFill.Size = UDim2.fromOffset(4, 166)
    hpFill.BackgroundColor3 = Color3.fromRGB(40, 255, 60)
    hpFill.BorderSizePixel = 0
    hpFill.Parent = Preview.HpBg

    -- Перетаскиваемый Текст HP
    Preview.HpText = Instance.new("TextLabel")
    Preview.HpText.Size = UDim2.fromOffset(36, 16)
    Preview.HpText.BackgroundTransparency = 1
    Preview.HpText.Text = "85 HP"
    Preview.HpText.TextColor3 = Color3.fromRGB(255, 255, 255)
    Preview.HpText.TextStrokeTransparency = 0
    Preview.HpText.Font = Enum.Font.GothamBold
    Preview.HpText.TextSize = 10
    Preview.HpText.Active = true
    Preview.HpText.Visible = false
    Preview.HpText.Parent = Preview.Canvas

    -- Перетаскиваемый контейнер Inv ESP
    Preview.InvContainer = Instance.new("Frame")
    Preview.InvContainer.Size = UDim2.fromOffset(180, 42)
    Preview.InvContainer.BackgroundTransparency = 1
    Preview.InvContainer.Active = true
    Preview.InvContainer.Visible = false
    Preview.InvContainer.Parent = Preview.Canvas

    Preview.InvGrid = Instance.new("UIGridLayout")
    Preview.InvGrid.CellSize = UDim2.fromOffset(24, 24)
    Preview.InvGrid.CellPadding = UDim2.fromOffset(3, 3)
    Preview.InvGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Preview.InvGrid.VerticalAlignment = Enum.VerticalAlignment.Bottom
    Preview.InvGrid.Parent = Preview.InvContainer

    for idx, itemName in ipairs({"AK47", "Bow", "Med"}) do
        local slot = Instance.new("Frame")
        slot.BackgroundColor3 = (idx == 1) and Color3.fromRGB(45, 115, 255) or Color3.fromRGB(28, 28, 34)
        slot.BackgroundTransparency = 0.2
        slot.BorderSizePixel = 0
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 4)
        c.Parent = slot
        if idx == 1 then
            local st = Instance.new("UIStroke")
            st.Color = Color3.fromRGB(130, 200, 255)
            st.Thickness = 1.2
            st.Parent = slot
        end
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.9, 0, 0.9, 0)
        lbl.Position = UDim2.new(0.05, 0, 0.05, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = itemName
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.Font = Enum.Font.GothamSemibold
        lbl.TextScaled = true
        lbl.Parent = slot
        slot.Parent = Preview.InvContainer
    end

    applyPreviewPositionsFromLayout()

    -- Обработчики перетаскивания (Drag & Drop) для элементов ESP Preview
    local function bindDraggable(guiObj, elemKey)
        guiObj.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Preview.draggingElem = elemKey
                Preview.dragStartMouse = UserInputService:GetMouseLocation()
                Preview.dragStartOffset = Vector2.new(guiObj.Position.X.Offset, guiObj.Position.Y.Offset)
            end
        end)
    end

    bindDraggable(Preview.NameText, "Name")
    bindDraggable(Preview.HpBg, "HpBar")
    bindDraggable(Preview.HpText, "HpText")
    bindDraggable(Preview.InvContainer, "Inv")

    table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
        if Preview.draggingElem and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = UserInputService:GetMouseLocation() - Preview.dragStartMouse
            local newX = Preview.dragStartOffset.X + delta.X
            local newY = Preview.dragStartOffset.Y + delta.Y
            local L = State.ESP_Layout

            if Preview.draggingElem == "Name" then
                newX = math.clamp(newX, -40, 130)
                newY = math.clamp(newY, 5, 320)
                Preview.NameText.Position = UDim2.fromOffset(newX, newY)
                L.Name_X = ((newX + 70) - Preview.RefCenterX) / Preview.RefW
                L.Name_Y = (newY - Preview.RefTopY) / Preview.RefH

            elseif Preview.draggingElem == "HpBar" then
                newX = math.clamp(newX, 4, 190)
                newY = math.clamp(newY, 10, 140)
                Preview.HpBg.Position = UDim2.fromOffset(newX, newY)
                L.HpBar_X = (newX - Preview.RefCenterX) / Preview.RefW
                L.HpBar_Y = (newY - Preview.RefTopY) / Preview.RefH

            elseif Preview.draggingElem == "HpText" then
                newX = math.clamp(newX, 2, 165)
                newY = math.clamp(newY, 5, 320)
                Preview.HpText.Position = UDim2.fromOffset(newX, newY)
                L.HpText_X = ((newX + 18) - Preview.RefCenterX) / Preview.RefW
                L.HpText_Y = (newY - Preview.RefTopY) / Preview.RefH

            elseif Preview.draggingElem == "Inv" then
                newX = math.clamp(newX, -60, 100)
                newY = math.clamp(newY, 2, 300)
                Preview.InvContainer.Position = UDim2.fromOffset(newX, newY)
                L.Inv_X = ((newX + 90) - Preview.RefCenterX) / Preview.RefW
                L.Inv_Y = (newY - Preview.RefTopY) / Preview.RefH
                State.lastInvUpdate = 0
            end
        end
    end))

    table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Preview.draggingElem = nil
        end
    end))
end

-- Точная проверка открытости меню LinoriaLib
local function isLinoriaMenuOpen()
    local mainFrame = (Window and Window.Holder) or (Window and Window.Root)
    if mainFrame then
        local sg = mainFrame:FindFirstAncestorOfClass("ScreenGui")
        if sg and not sg.Enabled then return false end
        return mainFrame.Visible
    end
    if Library.ScreenGui and not Library.ScreenGui.Enabled then
        return false
    end
    if Library.Toggled ~= nil then return Library.Toggled end
    return false
end

local function updateEspPreview()
    if State.IsUnloaded or not Preview.Gui or not Preview.Gui.Parent then return end

    local menuOpen = isLinoriaMenuOpen()
    Preview.Panel.Visible = menuOpen and Settings.ESP_Preview_Enabled
    if not Preview.Panel.Visible then
        Preview.draggingElem = nil
        return
    end

    pcall(function()
        local mainFrame = (Window and Window.Holder) or (Window and Window.Root)
        if mainFrame and mainFrame.AbsoluteSize.X > 0 then
            local absPos = mainFrame.AbsolutePosition
            local absSize = mainFrame.AbsoluteSize
            Preview.Panel.Position = UDim2.fromOffset(absPos.X + absSize.X + 8, absPos.Y)
        end
    end)

    local espCol = Settings.ESP_Color
    local chamsOn = Settings.Local_Chams_Enabled
    local chamsCol = chamsOn and Settings.Local_Chams_Color or Color3.fromRGB(95, 98, 110)

    for _, part in ipairs(Preview.dummyParts) do
        part.BackgroundColor3 = chamsCol
        part.BackgroundTransparency = chamsOn and 0.15 or 0
    end

    local espActive = Settings.ESP_Enabled
    Preview.Box.Visible = espActive and Settings.ESP_Box
    Preview.BoxStroke.Color = espCol

    Preview.HeadBox.Visible = espActive and Settings.ESP_SkelHead
    Preview.HeadBoxStroke.Color = espCol
    for _, b in ipairs(Preview.bones) do
        b.Visible = espActive and Settings.ESP_SkelHead
        b.BackgroundColor3 = espCol
    end

    Preview.Hat.Visible = espActive and Settings.ESP_NeonHat
    Preview.Hat.BackgroundColor3 = espCol
    for _, ch in ipairs(Preview.Hat:GetChildren()) do
        if ch:IsA("Frame") then ch.BackgroundColor3 = espCol end
    end

    Preview.NameText.Visible = espActive and Settings.ESP_Name
    Preview.NameText.TextColor3 = espCol

    Preview.HpBg.Visible = espActive and Settings.ESP_HealthBar
    Preview.HpText.Visible = espActive and Settings.ESP_HealthText

    Preview.InvContainer.Visible = Settings.Fust_InvCheck_Enabled
    local sz = math.clamp(Settings.Fust_InvCheck_Size or 24, 14, 38)
    Preview.InvGrid.CellSize = UDim2.fromOffset(sz, sz)
end

-- Рендер-цикл
table.insert(Connections, RunService.RenderStepped:Connect(function(dt)
    if State.IsUnloaded then return end
    
    Camera = workspace.CurrentCamera or Camera
    local mouseLoc = UserInputService:GetMouseLocation()

    updateEspPreview()
    
    if Settings.Fust_Lay_Enabled then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and hum then
            if isPlayerSittingInVehicle(hum) then
                if State.fustIsSpoofed and State.fustRealCFrame then hrp.CFrame = State.fustRealCFrame State.fustIsSpoofed = false end
                hum.CameraOffset = Vector3.zero
            else
                hum.CameraOffset = Vector3.new(0, State.LAY_CAMERA_HEIGHT_BOOST, 0)
                if State.fustIsSpoofed and State.fustRealCFrame then
                    hrp.CFrame = State.fustRealCFrame
                    if State.fustRealVelocity then hrp.AssemblyLinearVelocity = State.fustRealVelocity end
                    State.fustIsSpoofed = false
                end
            end
        end
    end

    if Settings.Fust_BulletTracer_Enabled or Settings.SmartBallistics_Enabled then
        local now = tick()
        local safeDt = math.max(dt, 0.001)

        for part, cData in pairs(State.candidateProjectiles) do
            if not part or not part.Parent or (now - cData.SpawnTime) > 4.0 then
                State.candidateProjectiles[part] = nil
            else
                local curPos = part.Position
                local stepVec = curPos - cData.LastPos
                local stepDist = stepVec.Magnitude
                local instantSpeed = stepDist / safeDt
                local physVel = part.AssemblyLinearVelocity
                local physSpeed = physVel.Magnitude

                if isPartAttachedToPlayerOrWeapon(part) then
                    cData.LastPos = curPos
                    cData.ConfirmedFrames = 0
                else
                    local measuredSpeed = math.max(instantSpeed, physSpeed)
                    if measuredSpeed > 35 then
                        cData.ConfirmedFrames = cData.ConfirmedFrames + 1
                        if cData.ConfirmedFrames >= 1 then
                            State.trackedProjectiles[part] = {
                                LastPos = cData.LastPos,
                                LastVelY = (stepVec / safeDt).Y,
                                SpeedSample = math.clamp(measuredSpeed, 150, 3000),
                                WeaponName = cData.WeaponName or getEquippedWeaponNameAndInstance(),
                                SpawnTime = now
                            }
                            State.candidateProjectiles[part] = nil
                            State.lastFireTimestamp = now

                            if Settings.Fust_BulletTracer_Enabled and stepDist >= 0.15 and stepDist < 80 then
                                drawFustTracerSegment(cData.LastPos, curPos)
                                State.trackedProjectiles[part].LastPos = curPos
                            end
                        end
                    else
                        cData.LastPos = curPos
                    end
                end
            end
        end

        for part, data in pairs(State.trackedProjectiles) do
            if not part or not part.Parent or (now - data.SpawnTime) > 3.8 then
                State.trackedProjectiles[part] = nil
            else
                local curPos = part.Position
                local stepVec = curPos - data.LastPos
                local stepDist = stepVec.Magnitude
                if stepDist >= 0.15 and stepDist < 140 then
                    local curVelY = (stepVec / safeDt).Y
                    if data.LastVelY and data.WeaponName then
                        local measuredDrop = math.clamp(-(curVelY - data.LastVelY) / safeDt, 0, 150)
                        local basePreset = classifyWeaponByName(data.WeaponName) or WEAPON_CLASS_PRESETS.Pistol
                        State.learnedWeaponBallistics[data.WeaponName] = {
                            Speed = data.SpeedSample * 0.6 + basePreset.Speed * 0.4,
                            Drop = measuredDrop > 35 and (measuredDrop * 0.5 + basePreset.Drop * 0.5) or basePreset.Drop,
                            Drag = basePreset.Drag,
                            FlatRange = basePreset.FlatRange,
                            IsProjectile = basePreset.IsProjectile
                        }
                    end
                    data.LastVelY = curVelY

                    if Settings.Fust_BulletTracer_Enabled then
                        drawFustTracerSegment(data.LastPos, curPos)
                    end
                    data.LastPos = curPos
                end
            end
        end
    end

    if Settings.FullBright_Enabled then
        Lighting.Brightness = Settings.FullBright_Brightness
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.GlobalShadows = false
    end

    if Settings.Fust_NoFog_Enabled then
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 999999
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Atmosphere") then
                child.Density = 0
                child.Haze = 0
                child.Glare = 0
            end
        end
    end

    if Settings.Aimbot_Enabled or Settings.SilentAim_Enabled or Settings.Aimbot_ShowFOV or Settings.Crosshair_Enabled then
        State.LockedTarget = getClosestToMouse()
    else
        State.LockedTarget = nil
        State.StickyTarget = nil
    end

    local char = LocalPlayer.Character
    local isTP_or_AA = Settings.TP_Enabled or Settings.AACSP_Enabled or Settings.AACSP_Local_Enabled or Settings.SpinbotCS_Enabled or Settings.AA_Enabled or Settings.Desync_Enabled

    pcall(function()
        if Settings.Viewmodel_Offset_Enabled then
            local offsetCF = CFrame.new(Settings.Viewmodel_Offset_X, Settings.Viewmodel_Offset_Y, Settings.Viewmodel_Offset_Z)

            for _, child in ipairs(Camera:GetChildren()) do
                if child:IsA("Model") then
                    for _, m in ipairs(child:GetDescendants()) do
                        if m:IsA("Motor6D") and (m.Name:lower():find("root") or m.Name:lower():find("shoulder") or m.Name:lower():find("grip") or m.Name:lower():find("gun")) then
                            if not State.originalC0s[m] then State.originalC0s[m] = m.C0 end
                            m.C0 = State.originalC0s[m] * offsetCF
                        end
                    end
                end
            end
        end
    end)

    if isLinoriaMenuOpen() then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    else
        if isTP_or_AA then
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        end
    end

    if Settings.TP_Enabled then
        pcall(function()
            if not State.wasThirdPersonActive then
                State.savedCameraMode = LocalPlayer.CameraMode
                State.savedMinZoom = LocalPlayer.CameraMinZoomDistance
                State.savedMaxZoom = LocalPlayer.CameraMaxZoomDistance
                State.wasThirdPersonActive = true
            end

            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            Camera.CameraType = Enum.CameraType.Custom
            LocalPlayer.CameraMinZoomDistance = Settings.TP_Distance
            LocalPlayer.CameraMaxZoomDistance = Settings.TP_Distance

            if char and char:FindFirstChild("Humanoid") and Camera.CameraSubject ~= char.Humanoid then
                Camera.CameraSubject = char.Humanoid
            end
        end)
    elseif State.wasThirdPersonActive then
        pcall(function()
            State.wasThirdPersonActive = false

            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMaxZoomDistance = 0.5
            LocalPlayer.CameraMode = State.savedCameraMode or Enum.CameraMode.LockFirstPerson

            task.delay(0.05, function()
                if not Settings.TP_Enabled then
                    LocalPlayer.CameraMinZoomDistance = (State.savedMinZoom and State.savedMinZoom < 5) and State.savedMinZoom or 0.5
                    LocalPlayer.CameraMaxZoomDistance = (State.savedMaxZoom and State.savedMaxZoom > 0.5) and State.savedMaxZoom or 128
                end
            end)

            if char and char:FindFirstChild("Humanoid") and Camera.CameraSubject ~= char.Humanoid then
                Camera.CameraSubject = char.Humanoid
            end
        end)
    end
    
    if State.colorCorrection then
        State.colorCorrection.Saturation = Settings.Saturation_Value
    end

    if State.BulletCharge > 0 then
        State.BulletCharge = math.clamp(State.BulletCharge - (dt * 3), 0, 1)
    end

    updateDesyncGhost(dt)

    pcall(function()
        if State.fovCircle then
            local shouldShowFOV = Settings.Aimbot_ShowFOV and not Settings.Aimbot_360
            State.fovCircle.Visible = shouldShowFOV
            if shouldShowFOV then
                State.fovCircle.Position = mouseLoc
                State.fovCircle.Radius = Settings.Aimbot_FOV
                State.fovCircle.Color = Settings.Aimbot_FOV_Color or Color3.fromRGB(0, 255, 150)
            end
        end
    end)

    if Settings.Aimbot_Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and State.LockedTarget then
        pcall(function()
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and isPlayerSittingInVehicle(hum) then
                if Camera.CameraType ~= Enum.CameraType.Custom and Camera.CameraType ~= Enum.CameraType.Scriptable then
                    Camera.CameraType = Enum.CameraType.Custom
                end
            end

            local muzzleOrig = Settings.SmartBallistics_Enabled and findWeaponMuzzlePosition() or Camera.CFrame.Position
            local aimPos = getPredictedTargetPosition(State.LockedTarget, muzzleOrig)
            local targetCF = CFrame.lookAt(Camera.CFrame.Position, aimPos)

            local alpha
            if Settings.Aimbot_Smoothness >= 0.99 then
                alpha = 1
            else
                local speed = (Settings.Aimbot_Smoothness ^ 1.35) * 42
                alpha = 1 - math.exp(-speed * math.clamp(dt, 0.001, 0.1))
            end

            Camera.CFrame = Camera.CFrame:Lerp(targetCF, math.clamp(alpha, 0.01, 1))
        end)
    end

    pcall(function()
        if Settings.Crosshair_Enabled then
            local basePos = mouseLoc
            local currentSize = Settings.Crosshair_Size

            if (Settings.Aimbot_Enabled or Settings.SilentAim_Enabled) and State.LockedTarget then
                local muzzleOrig = Settings.SmartBallistics_Enabled and findWeaponMuzzlePosition() or Camera.CFrame.Position
                local predWorldPos = getPredictedTargetPosition(State.LockedTarget, muzzleOrig)
                local tPos, tOnScreen = Camera:WorldToViewportPoint(predWorldPos)
                if tOnScreen then
                    basePos = Vector2.new(tPos.X, tPos.Y)
                    currentSize = currentSize * 2
                end
            end

            local cColor = Settings.Crosshair_RGB and Color3.fromHSV((tick() % 3) / 3, 1, 1) or Settings.Crosshair_Color
            State.crosshairText.Visible = true
            State.crosshairText.Position = basePos + Vector2.new(0, currentSize + 10)
            State.crosshairText.Color = cColor

            local rotationAngle = tick() * Settings.Crosshair_Speed
            for i = 1, 4 do
                local line = State.crosshairLines[i]
                line.Visible = true
                line.Color = cColor
                local angle = math.rad((i * 90) + math.deg(rotationAngle))
                line.From = basePos + Vector2.new(math.cos(angle), math.sin(angle)) * (currentSize * 0.3)
                line.To = basePos + Vector2.new(math.cos(angle), math.sin(angle)) * currentSize
            end
        else
            State.crosshairText.Visible = false
            for i = 1, 4 do State.crosshairLines[i].Visible = false end
        end
    end)

    if Settings.Speed_Enabled and char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = Settings.Speed_Value
    end

    local L = State.ESP_Layout

    -- ESP отрисовка на живых игроках (с учетом перетащенных позиций из ESP Preview)
    for player, drawings in pairs(espCache) do
        local character = player.Character
        local isVisible = false

        pcall(function()
            if Settings.ESP_Enabled and character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 and character:FindFirstChild("Head") and character:FindFirstChild("HumanoidRootPart") then
                local head, root = character.Head, character.HumanoidRootPart
                local humanoid = character.Humanoid
                local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15
                local torso = isR15 and character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
                
                if torso then
                    local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)

                    if onScreen then
                        isVisible = true
                        
                        local playerEspColor = isPlayerTeammateCached(player) and Settings.ESP_TeamColor or Settings.ESP_Color

                        local hat = character:FindFirstChild("ClientNeonHat")
                        if Settings.ESP_NeonHat then
                            if not hat then hat = createNeonHat(character) end
                            if hat then hat.Color = playerEspColor; hat.Transparency = 0 end
                        elseif hat then hat.Transparency = 1 end

                        local topPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local bottomPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                        local boxHeight = math.abs(topPos.Y - bottomPos.Y)
                        local boxWidth = boxHeight / 2

                        drawings.MainBox.Size = Vector2.new(boxWidth, boxHeight)
                        drawings.MainBox.Position = Vector2.new(topPos.X - boxWidth / 2, topPos.Y)
                        drawings.MainBox.Visible = Settings.ESP_Box
                        drawings.MainBox.Color = playerEspColor

                        if Settings.ESP_Name then
                            drawings.NameText.Visible = true
                            drawings.NameText.Text = player.Name
                            drawings.NameText.Position = Vector2.new(
                                topPos.X + (L.Name_X * boxWidth),
                                topPos.Y + (L.Name_Y * boxHeight)
                            )
                            drawings.NameText.Color = playerEspColor
                        else
                            drawings.NameText.Visible = false
                        end

                        local maxHp = humanoid.MaxHealth > 0 and humanoid.MaxHealth or 100
                        local healthPercent = math.clamp(humanoid.Health / maxHp, 0, 1)

                        if Settings.ESP_HealthBar then
                            local barHeight = boxHeight
                            local barWidth = 3
                            local barX = topPos.X + (L.HpBar_X * boxWidth)
                            local barY = topPos.Y + (L.HpBar_Y * boxHeight)

                            drawings.HealthBarBg.Size = Vector2.new(barWidth, barHeight)
                            drawings.HealthBarBg.Position = Vector2.new(barX, barY)
                            drawings.HealthBarBg.Filled = true
                            drawings.HealthBarBg.Color = Color3.fromRGB(20, 20, 20)
                            drawings.HealthBarBg.Visible = true

                            local fillHeight = barHeight * healthPercent
                            drawings.HealthBarFill.Size = Vector2.new(barWidth - 1, fillHeight)
                            drawings.HealthBarFill.Position = Vector2.new(barX + 1, barY + (barHeight - fillHeight))
                            drawings.HealthBarFill.Filled = true
                            drawings.HealthBarFill.Color = Color3.fromRGB(0, 255, 0):Lerp(Color3.fromRGB(255, 0, 0), 1 - healthPercent)
                            drawings.HealthBarFill.Visible = true
                        else
                            drawings.HealthBarBg.Visible = false
                            drawings.HealthBarFill.Visible = false
                        end

                        if Settings.ESP_HealthText then
                            drawings.HealthText.Visible = true
                            drawings.HealthText.Text = math.floor(humanoid.Health) .. " HP"
                            drawings.HealthText.Position = Vector2.new(
                                topPos.X + (L.HpText_X * boxWidth),
                                topPos.Y + (L.HpText_Y * boxHeight)
                            )
                            drawings.HealthText.Color = Color3.fromRGB(255, 255, 255)
                        else
                            drawings.HealthText.Visible = false
                        end

                        local hSizeOffset = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, head.Size.Y / 2, 0))
                        local hBoxHeight = math.abs(headPos.Y - hSizeOffset.Y) * 2
                        
                        drawings.HeadBox.Size = Vector2.new(hBoxHeight, hBoxHeight)
                        drawings.HeadBox.Position = Vector2.new(headPos.X - hBoxHeight / 2, headPos.Y - hBoxHeight / 2)
                        drawings.HeadBox.Visible = Settings.ESP_SkelHead
                        drawings.HeadBox.Color = playerEspColor

                        local function drawBone(line, p1, p2, connectOffset)
                            if p1 and p2 and Settings.ESP_SkelHead then
                                local pos1, vis1 = Camera:WorldToViewportPoint(p1.Position)
                                local pos2, vis2 = Camera:WorldToViewportPoint(p2.Position)
                                if vis1 or vis2 then
                                    line.From = connectOffset and Vector2.new(headPos.X, headPos.Y + hBoxHeight / 2) or Vector2.new(pos1.X, pos1.Y)
                                    line.To = Vector2.new(pos2.X, pos2.Y)
                                    line.Visible = true
                                    line.Color = playerEspColor
                                    return
                                end
                            end
                            line.Visible = false
                        end

                        drawBone(drawings.Spine, head, torso, Settings.ESP_SkelHead)
                        drawBone(drawings.LeftArm, torso, isR15 and character:FindFirstChild("LeftLowerArm") or character:FindFirstChild("Left Arm"), false)
                        drawBone(drawings.RightArm, torso, isR15 and character:FindFirstChild("RightLowerArm") or character:FindFirstChild("Right Arm"), false)
                        drawBone(drawings.LeftLeg, isR15 and character:FindFirstChild("LowerTorso") or torso, isR15 and character:FindFirstChild("LeftLowerLeg") or character:FindFirstChild("Left Leg"), false)
                        drawBone(drawings.RightLeg, isR15 and character:FindFirstChild("LowerTorso") or torso, isR15 and character:FindFirstChild("RightLowerLeg") or character:FindFirstChild("Right Leg"), false)
                    end
                end
            end
        end)

        if not isVisible then
            for _, drawing in pairs(drawings) do drawing.Visible = false end
            if character and character:FindFirstChild("ClientNeonHat") then character.ClientNeonHat.Transparency = 1 end
        end
    end
end))

-- ==========================================
-- ИНПУТЫ И БИНДЫ МЫШИ / КЛАВИАТУРЫ
-- ==========================================
table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if State.IsUnloaded then return end

    if not UserInputService:GetFocusedTextBox() then
        local zoomKeyName = "Z"
        pcall(function()
            if Library.Options and Library.Options.Fust_Zoom_Key then
                zoomKeyName = Library.Options.Fust_Zoom_Key.Value
            end
        end)
        if input.KeyCode.Name == zoomKeyName and Settings.Fust_Zoom_Enabled then
            startZoomHold()
        end
    end

    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        State.IsLMBDown = true
        State.lastLocalClick = tick()
        if Settings.PeakKill_Enabled then startPeek() end
    end

    local targetCycleKey = Settings.PeakKill_CycleKey
    pcall(function()
        if Library.Options and Library.Options.PeakKill_CycleKey then
            targetCycleKey = Library.Options.PeakKill_CycleKey.Value
        end
    end)
    if input.KeyCode.Name == targetCycleKey then
        local modes = {"Вверх (Up)", "Вниз (Down)", "Влево (Left)", "Вправо (Right)"}
        local currentIndex = 1
        for i, v in ipairs(modes) do
            if v == Settings.PeakKill_Mode then currentIndex = i break end
        end
        currentIndex = currentIndex + 1
        if currentIndex > #modes then currentIndex = 1 end
        
        Settings.PeakKill_Mode = modes[currentIndex]
        pcall(function()
            if Library.Options and Library.Options.PeakKill_Mode then
                Library.Options.PeakKill_Mode:SetValue(Settings.PeakKill_Mode)
            end
        end)
        showPeakIndicator(Settings.PeakKill_Mode)
    end
end))

table.insert(Connections, UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if State.IsUnloaded then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        State.IsLMBDown = false
        if Settings.PeakKill_Enabled then stopPeek() end
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        State.StickyTarget = nil
    end

    local zoomKeyName = "Z"
    pcall(function()
        if Library.Options and Library.Options.Fust_Zoom_Key then
            zoomKeyName = Library.Options.Fust_Zoom_Key.Value
        end
    end)
    if input.KeyCode.Name == zoomKeyName then
        stopZoomHold()
    end
end))

local function destroyLinoriaUI()
    pcall(function()
        if Preview.Gui then Preview.Gui:Destroy() end
    end)
    pcall(function()
        if Window and Window.Holder then
            local sg = Window.Holder:FindFirstAncestorOfClass("ScreenGui")
            if sg then sg:Destroy() end
        end
    end)
    pcall(function()
        if Window and Window.Root then
            local sg = Window.Root:FindFirstAncestorOfClass("ScreenGui")
            if sg then sg:Destroy() end
        end
    end)
    pcall(function()
        if Library.ScreenGui then Library.ScreenGui:Destroy() end
    end)
    pcall(function()
        if Library.KeybindFrame then
            local sg = Library.KeybindFrame:FindFirstAncestorOfClass("ScreenGui")
            if sg then sg:Destroy() end
        end
    end)
    pcall(function()
        if Library.Watermark then
            local sg = Library.Watermark:FindFirstAncestorOfClass("ScreenGui")
            if sg then sg:Destroy() end
        end
    end)
    pcall(function()
        local containers = {gethui and gethui(), CoreGui, PlayerGui}
        for _, c in ipairs(containers) do
            if c then
                for _, obj in ipairs(c:GetChildren()) do
                    if obj:IsA("ScreenGui") and (obj.Name:find("Linoria") or obj.Name == "Skeetparser" or obj.Name:find("Library")) then
                        obj:Destroy()
                    end
                end
            end
        end
    end)
end

-- Инициализация вкладок меню в отдельных блоках do ... end
do
    task.defer(function()
        if Window.Holder then
            Window.Holder.Size = UDim2.fromOffset(680, 560)
        elseif Window.Root then
            Window.Root.Size = UDim2.fromOffset(680, 560)
        end
    end)

    local Tabs = {
        Combat = Window:AddTab('Combat'),
        Weapon = Window:AddTab('Weapon'),
        Visuals = Window:AddTab('Visuals'),
        Crosshair = Window:AddTab('Crosshair'),
        AntiAim = Window:AddTab('Anti-Aim'),
        Exploits = Window:AddTab('Exploits'),
        HitSounds = Window:AddTab('HitSounds'),
        ['Settings'] = Window:AddTab('Settings')
    }

    -- 1. COMBAT
    do
        local aimbox = Tabs.Combat:AddLeftGroupbox('Aimbot')
        aimbox:AddToggle('Aimbot_Enabled', {
            Text = 'Enable Vector Aimbot (RMB)',
            Default = false,
            Callback = function(v) Settings.Aimbot_Enabled = v end
        })
        aimbox:AddToggle('Aimbot_StickyAim', {
            Text = '🔒 Stick Aim (Не отпускать цель)',
            Default = false,
            Callback = function(v)
                Settings.Aimbot_StickyAim = v
                if not v then State.StickyTarget = nil end
            end
        })
        aimbox:AddToggle('SilentAim_Enabled', {
            Text = 'Silent Aim',
            Default = false,
            Callback = function(v) Settings.SilentAim_Enabled = v end
        })
        aimbox:AddDropdown('SilentAimMethod', {
            Values = {"Raycast", "Mouse.Hit/Target"},
            Default = 1,
            Multi = false,
            Text = 'Silent Aim Method',
            Callback = function(v) Settings.SilentAimMethod = v end
        })
        aimbox:AddToggle('VisCheck_Enabled', {
            Text = 'Visible Check',
            Default = false,
            Callback = function(v) Settings.VisCheck_Enabled = v end
        })
        aimbox:AddToggle('TeamCheck', {
            Text = 'Team Check (Green Team ESP)',
            Default = false,
            Callback = function(v)
                Settings.TeamCheck = v
                table.clear(State.teamCheckCache)
            end
        })
        aimbox:AddDivider()
        aimbox:AddToggle('Aimbot_DistCheck_Enabled', {
            Text = '📏 Distance Check',
            Default = true,
            Callback = function(v) Settings.Aimbot_DistCheck_Enabled = v end
        })
        aimbox:AddSlider('Aimbot_MaxDistance', {
            Text = 'Max Target Distance (Studs)',
            Default = 800,
            Min = 10,
            Max = 2500,
            Rounding = 0,
            Callback = function(v) Settings.Aimbot_MaxDistance = v end
        })

        local fovToggle = aimbox:AddToggle('Aimbot_ShowFOV', {
            Text = 'Show FOV Circle',
            Default = false,
            Callback = function(v) Settings.Aimbot_ShowFOV = v end
        })
        fovToggle:AddColorPicker('Aimbot_FOV_Color', {
            Default = Color3.fromRGB(0, 255, 150),
            Title = 'FOV Circle Color',
            Callback = function(c) Settings.Aimbot_FOV_Color = c end
        })

        aimbox:AddToggle('Aimbot_360', {
            Text = '360 Degree FOV',
            Default = false,
            Callback = function(v) Settings.Aimbot_360 = v end
        })
        aimbox:AddDropdown('Aimbot_HitPart', {
            Values = {'Head', 'UpperTorso', 'HumanoidRootPart'},
            Default = 1,
            Multi = false,
            Text = 'Target Hitbox',
            Callback = function(v) Settings.Aimbot_HitPart = v end
        })

        local aimcfg = Tabs.Combat:AddRightGroupbox('Distance Vector & Prediction')
        aimcfg:AddSlider('HitChance', {
            Text = 'Hit Chance',
            Default = 100,
            Min = 0,
            Max = 100,
            Rounding = 1,
            Callback = function(v) Settings.HitChance = v end
        })
        aimcfg:AddSlider('Aimbot_FOV', {
            Text = 'FOV Radius',
            Default = 150,
            Min = 10,
            Max = 800,
            Rounding = 0,
            Callback = function(v) Settings.Aimbot_FOV = v end
        })
        aimcfg:AddSlider('Aimbot_Smoothness', {
            Text = 'Vector Smoothness (1 = Instant)',
            Default = 0.2,
            Min = 0.05,
            Max = 1,
            Rounding = 2,
            Callback = function(v) Settings.Aimbot_Smoothness = v end
        })
        aimcfg:AddDivider()
        aimcfg:AddToggle('SmartBallistics_Enabled', {
            Text = '🏹 Smart Auto-Ballistics (Auto Weapon)',
            Default = true,
            Callback = function(v)
                Settings.SmartBallistics_Enabled = v
                setFustBulletTracerState(Settings.Fust_BulletTracer_Enabled)
            end
        })
        aimcfg:AddDivider()
        aimcfg:AddToggle('DistVector_Enabled', {
            Text = '🎯 Distance Vector (Manual)',
            Default = false,
            Callback = function(v) Settings.DistVector_Enabled = v end
        })
        aimcfg:AddSlider('DistVector_UpScale', {
            Text = 'Upward Scale (Выше от дистанции)',
            Default = 1.5,
            Min = 0,
            Max = 10,
            Rounding = 2,
            Callback = function(v) Settings.DistVector_UpScale = v end
        })
        aimcfg:AddSlider('DistVector_StrafeScale', {
            Text = 'Strafe Scale (Вбок от дистанции)',
            Default = 1.2,
            Min = 0,
            Max = 10,
            Rounding = 2,
            Callback = function(v) Settings.DistVector_StrafeScale = v end
        })
        aimcfg:AddDivider()
        aimcfg:AddToggle('Prediction_Enabled', {
            Text = 'Simple Linear Prediction',
            Default = false,
            Callback = function(v) Settings.Prediction_Enabled = v end
        })
        aimcfg:AddSlider('Prediction_Value', {
            Text = 'Linear Multiplier',
            Default = 0.135,
            Min = 0.01,
            Max = 0.5,
            Rounding = 3,
            Callback = function(v) Settings.Prediction_Value = v end
        })
    end

    -- 2. WEAPON
    do
        local wpnbox = Tabs.Weapon:AddLeftGroupbox('Weapon Exploits')
        wpnbox:AddToggle('Wallbang_Enabled', {
            Text = 'Wallbang',
            Default = false,
            Callback = function(v)
                Settings.Wallbang_Enabled = v
                if not v then restoreWalls() end
            end
        })
        wpnbox:AddToggle('NoRecoil_Enabled', {
            Text = 'No Recoil',
            Default = false,
            Callback = function(v) Settings.NoRecoil_Enabled = v end
        })
        wpnbox:AddToggle('NoSpread_Enabled', {
            Text = 'No Spread',
            Default = false,
            Callback = function(v) Settings.NoSpread_Enabled = v end
        })
        wpnbox:AddToggle('InfAmmo_Enabled', {
            Text = 'Inf Ammo (999)',
            Default = false,
            Callback = function(v) Settings.InfAmmo_Enabled = v end
        })

        local chamsbox = Tabs.Weapon:AddRightGroupbox('Viewmodel Chams')
        local armToggle = chamsbox:AddToggle('Arm_Chams_Enabled', {
            Text = 'Arm Chams',
            Default = false,
            Callback = function(v) Settings.Arm_Chams_Enabled = v; updateAllChams() end
        })
        armToggle:AddColorPicker('Arm_Chams_Color', {
            Default = Color3.fromRGB(0, 170, 255),
            Title = 'Arm Color',
            Callback = function(c) Settings.Arm_Chams_Color = c; updateAllChams() end
        })
        chamsbox:AddDropdown('Arm_Chams_Material', {
            Values = {'Neon', 'ForceField', 'Glass', 'Plastic', 'Foil'},
            Default = 1,
            Multi = false,
            Text = 'Arm Material',
            Callback = function(v) Settings.Arm_Chams_Material = v; updateAllChams() end
        })

        local gunToggle = chamsbox:AddToggle('Gun_Chams_Enabled', {
            Text = 'Gun Chams',
            Default = false,
            Callback = function(v) Settings.Gun_Chams_Enabled = v; updateAllChams() end
        })
        gunToggle:AddColorPicker('Gun_Chams_Color', {
            Default = Color3.fromRGB(0, 255, 128),
            Title = 'Gun Color',
            Callback = function(c) Settings.Gun_Chams_Color = c; updateAllChams() end
        })
        chamsbox:AddDropdown('Gun_Chams_Material', {
            Values = {'Neon', 'ForceField', 'Glass', 'Plastic', 'Foil'},
            Default = 1,
            Multi = false,
            Text = 'Gun Material',
            Callback = function(v) Settings.Gun_Chams_Material = v; updateAllChams() end
        })

        local offsetbox = Tabs.Weapon:AddRightGroupbox('Viewmodel Offset')
        offsetbox:AddToggle('Viewmodel_Offset_Enabled', {
            Text = 'Enable Offset',
            Default = false,
            Callback = function(v) 
                Settings.Viewmodel_Offset_Enabled = v 
                if not v then
                    for motor, c0 in pairs(State.originalC0s) do
                        if motor and motor.Parent then motor.C0 = c0 end
                    end
                end
            end
        })
        offsetbox:AddSlider('Viewmodel_Offset_X', {
            Text = 'Offset X (Left/Right)',
            Default = 0,
            Min = -5,
            Max = 5,
            Rounding = 1,
            Callback = function(v) Settings.Viewmodel_Offset_X = v end
        })
        offsetbox:AddSlider('Viewmodel_Offset_Y', {
            Text = 'Offset Y (Up/Down)',
            Default = 0,
            Min = -5,
            Max = 5,
            Rounding = 1,
            Callback = function(v) Settings.Viewmodel_Offset_Y = v end
        })
        offsetbox:AddSlider('Viewmodel_Offset_Z', {
            Text = 'Offset Z (Forward/Back)',
            Default = 0,
            Min = -5,
            Max = 5,
            Rounding = 1,
            Callback = function(v) Settings.Viewmodel_Offset_Z = v end
        })
    end

    -- 3. VISUALS
    do
        local espbox = Tabs.Visuals:AddLeftGroupbox('Player ESP')
        local espToggle = espbox:AddToggle('ESP_Enabled', {
            Text = 'Enable ESP',
            Default = false,
            Callback = function(v) Settings.ESP_Enabled = v end
        })
        espToggle:AddColorPicker('ESP_Color', {
            Default = Color3.fromRGB(255, 80, 80),
            Title = 'ESP Visual Color',
            Callback = function(c) Settings.ESP_Color = c end
        })

        espbox:AddToggle('ESP_Preview_Enabled', {
            Text = 'Show 2D ESP Preview Window',
            Default = true,
            Callback = function(v) Settings.ESP_Preview_Enabled = v end
        })

        espbox:AddButton('Reset ESP Positions', function()
            resetEspPositions()
        end)

        espbox:AddToggle('ESP_Box', {
            Text = '2D Box',
            Default = false,
            Callback = function(v) Settings.ESP_Box = v end
        })
        espbox:AddToggle('ESP_SkelHead', {
            Text = 'Skeleton & Head Circle',
            Default = false,
            Callback = function(v) Settings.ESP_SkelHead = v end
        })
        espbox:AddToggle('ESP_NeonHat', {
            Text = 'Neon Hat',
            Default = false,
            Callback = function(v) Settings.ESP_NeonHat = v end
        })
        espbox:AddToggle('ESP_Name', {
            Text = 'Nicknames (Draggable)',
            Default = false,
            Callback = function(v) Settings.ESP_Name = v end
        })
        espbox:AddToggle('ESP_HealthBar', {
            Text = 'Health Bar (Draggable)',
            Default = false,
            Callback = function(v) Settings.ESP_HealthBar = v end
        })
        espbox:AddToggle('ESP_HealthText', {
            Text = 'Health Text (Draggable)',
            Default = false,
            Callback = function(v) Settings.ESP_HealthText = v end
        })
        espbox:AddDivider()
        espbox:AddToggle('Fust_InvCheck_Enabled', {
            Text = 'Inv ESP (Draggable Icons)',
            Default = false,
            Callback = function(v)
                Settings.Fust_InvCheck_Enabled = v
                State.lastInvUpdate = 0
                updateInvCheck()
            end
        })
        espbox:AddSlider('Fust_InvCheck_Size', {
            Text = 'Inv Icon Size (Размер иконок)',
            Default = 24,
            Min = 14,
            Max = 50,
            Rounding = 0,
            Callback = function(v)
                Settings.Fust_InvCheck_Size = v
                State.lastInvUpdate = 0
                if Settings.Fust_InvCheck_Enabled then
                    updateInvCheck()
                end
            end
        })

        local fustVisBox = Tabs.Visuals:AddLeftGroupbox('Fust Survival Visuals & Zoom')
        fustVisBox:AddToggle('Fust_CarEsp_Enabled', {
            Text = 'Vehicle ESP (Транспорт)',
            Default = false,
            Callback = function(v) setFustCarEspState(v) end
        })
        fustVisBox:AddDivider()
        local zoomToggle = fustVisBox:AddToggle('Fust_Zoom_Enabled', {
            Text = 'Hold Zoom',
            Default = false,
            Callback = function(v)
                Settings.Fust_Zoom_Enabled = v
                if not v then
                    State.isHoldingZoomKey = false
                    State.isZoomingProcess = false
                    if Camera then Camera.FieldOfView = State.baseGameFOV end
                    UserInputService.MouseDeltaSensitivity = State.savedBaseMouseSens
                end
            end
        })
        zoomToggle:AddKeyPicker('Fust_Zoom_Key', { Default = 'Z', Mode = 'Hold', Text = 'Hold Zoom Key' })
        fustVisBox:AddSlider('Fust_Zoom_FOV', {
            Text = 'Zoom Target FOV',
            Default = 20,
            Min = 5,
            Max = 60,
            Rounding = 0,
            Callback = function(v) Settings.Fust_Zoom_FOV = v end
        })

        local envbox = Tabs.Visuals:AddRightGroupbox('World & Local Player')
        local tracerToggle = envbox:AddToggle('Tracers_Enabled', {
            Text = 'Plasma Tracers',
            Default = false,
            Callback = function(v) Settings.Tracers_Enabled = v end
        })
        tracerToggle:AddColorPicker('Tracer_Color', {
            Default = Color3.fromRGB(0, 170, 255),
            Title = 'Tracer Color',
            Callback = function(c) Settings.Tracer_Color = c end
        })

        envbox:AddToggle('Fust_BulletTracer_Enabled', {
            Text = 'bullet tracr (fust sv by fliriz)',
            Default = false,
            Callback = function(v) setFustBulletTracerState(v) end
        })

        envbox:AddToggle('NightMode_Enabled', {
            Text = '🌙 Night Mode + Galaxy',
            Default = false,
            Callback = function(v)
                Settings.NightMode_Enabled = v
                updateLighting()
            end
        })

        envbox:AddToggle('GalaxySky_Enabled', {
            Text = '🌌 Galaxy Sky Only (With FullBright)',
            Default = false,
            Callback = function(v)
                Settings.GalaxySky_Enabled = v
                updateLighting()
            end
        })

        envbox:AddToggle('FullBright_Enabled', {
            Text = '☀️ FullBright',
            Default = false,
            Callback = function(v)
                Settings.FullBright_Enabled = v
                updateLighting()
            end
        })

        envbox:AddSlider('FullBright_Brightness', {
            Text = 'FullBright Intensity',
            Default = 2.5,
            Min = 0.5,
            Max = 10,
            Rounding = 1,
            Callback = function(v)
                Settings.FullBright_Brightness = v
                if Settings.FullBright_Enabled then
                    updateLighting()
                end
            end
        })

        envbox:AddToggle('Fust_NoFog_Enabled', {
            Text = 'No Fog (Fust)',
            Default = false,
            Callback = function(v)
                Settings.Fust_NoFog_Enabled = v
                updateLighting()
            end
        })

        envbox:AddToggle('Fust_NoShake_Enabled', {
            Text = 'No Camera Shake',
            Default = false,
            Callback = function(v) Settings.Fust_NoShake_Enabled = v end
        })

        envbox:AddSlider('Saturation_Value', {
            Text = 'Color Saturation',
            Default = 0,
            Min = -1,
            Max = 3,
            Rounding = 1,
            Callback = function(v)
                Settings.Saturation_Value = v
                if State.colorCorrection then State.colorCorrection.Saturation = v end
            end
        })

        local localChamsToggle = envbox:AddToggle('Local_Chams_Enabled', {
            Text = 'Local Player Chams',
            Default = false,
            Callback = function(v) Settings.Local_Chams_Enabled = v; updateAllChams() end
        })
        localChamsToggle:AddColorPicker('Local_Chams_Color', {
            Default = Color3.fromRGB(200, 0, 255),
            Title = 'Local Player Color',
            Callback = function(c) Settings.Local_Chams_Color = c; updateAllChams() end
        })
        envbox:AddDropdown('Local_Chams_Material', {
            Values = {'Neon', 'ForceField', 'Glass', 'Plastic', 'Foil'},
            Default = 1,
            Multi = false,
            Text = 'Local Chams Material',
            Callback = function(v) Settings.Local_Chams_Material = v; updateAllChams() end
        })

        local fxbox = Tabs.Visuals:AddRightGroupbox('Hit & Kill Effects')
        local hitFxToggle = fxbox:AddToggle('HitEffect_Enabled', {
            Text = 'Enable Hit Effect',
            Default = false,
            Callback = function(v) Settings.HitEffect_Enabled = v end
        })
        hitFxToggle:AddColorPicker('HitEffect_Color', {
            Default = Color3.fromRGB(0, 255, 255),
            Title = 'Hit Particles Color',
            Callback = function(c) Settings.HitEffect_Color = c end
        })

        local killFxToggle = fxbox:AddToggle('KillEffect_Enabled', {
            Text = 'Enable Kill Effect',
            Default = false,
            Callback = function(v) Settings.KillEffect_Enabled = v end
        })
        killFxToggle:AddColorPicker('KillEffect_Color', {
            Default = Color3.fromRGB(200, 220, 255),
            Title = 'Ghost Color',
            Callback = function(c) Settings.KillEffect_Color = c end
        })
    end

    -- 4. CROSSHAIR
    do
        local crossbox = Tabs.Crosshair:AddLeftGroupbox('Crosshair')
        local crossToggle = crossbox:AddToggle('Crosshair_Enabled', {
            Text = 'Spinning Crosshair',
            Default = false,
            Callback = function(v) Settings.Crosshair_Enabled = v end
        })
        crossToggle:AddColorPicker('Crosshair_Color', {
            Default = Color3.fromRGB(0, 255, 128),
            Title = 'Crosshair Color',
            Callback = function(c) Settings.Crosshair_Color = c end
        })

        crossbox:AddToggle('Crosshair_RGB', {
            Text = 'RGB Chroma Mode',
            Default = false,
            Callback = function(v) Settings.Crosshair_RGB = v end
        })
        crossbox:AddSlider('Crosshair_Size', {
            Text = 'Size',
            Default = 12,
            Min = 6,
            Max = 30,
            Rounding = 0,
            Callback = function(v) Settings.Crosshair_Size = v end
        })
        crossbox:AddSlider('Crosshair_Speed', {
            Text = 'Rotation Speed',
            Default = 4,
            Min = 1,
            Max = 10,
            Rounding = 0,
            Callback = function(v) Settings.Crosshair_Speed = v end
        })
    end

    -- 5. ANTI-AIM
    do
        local cs2aabox = Tabs.AntiAim:AddLeftGroupbox('CS2 Anti-Aim')
        cs2aabox:AddToggle('AACSP_Enabled', {
            Text = 'AA CS2 (Server Sync)',
            Default = false,
            Callback = function(v) Settings.AACSP_Enabled = v end
        })
        cs2aabox:AddToggle('AACSP_Local_Enabled', {
            Text = 'AA CS2 (Local Client Only)',
            Default = false,
            Callback = function(v) Settings.AACSP_Local_Enabled = v end
        })
        cs2aabox:AddToggle('SpinbotCS_Enabled', {
            Text = 'Spinbot CS2',
            Default = false,
            Callback = function(v) Settings.SpinbotCS_Enabled = v end
        })
        cs2aabox:AddSlider('SpinbotCS_Speed', {
            Text = 'Spinbot Speed',
            Default = 25,
            Min = 5,
            Max = 60,
            Rounding = 0,
            Callback = function(v) Settings.SpinbotCS_Speed = v end
        })

        local legacybox = Tabs.AntiAim:AddRightGroupbox('Legacy & Camera')
        local tpToggle = legacybox:AddToggle('TP_Enabled', {
            Text = 'Third Person',
            Default = false,
            Callback = function(v) Settings.TP_Enabled = v end
        })
        tpToggle:AddKeyPicker('TP_Key', { Default = 'V', SyncToggleState = true, Mode = 'Toggle', Text = 'Third Person' })

        legacybox:AddSlider('TP_Distance', {
            Text = 'Third Person Distance',
            Default = 12,
            Min = 5,
            Max = 50,
            Rounding = 0,
            Callback = function(v) Settings.TP_Distance = v end
        })
        legacybox:AddToggle('AA_Enabled', {
            Text = 'Legacy Anti-Aim',
            Default = false,
            Callback = function(v) Settings.AA_Enabled = v end
        })
        legacybox:AddDropdown('AA_Yaw', {
            Values = {'None', 'Backward', 'Spinbot', 'Jitter'},
            Default = 1,
            Multi = false,
            Text = 'Yaw Angle',
            Callback = function(v) Settings.AA_Yaw = v end
        })
        legacybox:AddDropdown('AA_Pitch', {
            Values = {'None', 'Down', 'Up', 'Crazy'},
            Default = 1,
            Multi = false,
            Text = 'Pitch Angle',
            Callback = function(v) Settings.AA_Pitch = v end
        })
        legacybox:AddDropdown('AA_Lean', {
            Values = {'None', 'Left', 'Right', 'Jitter'},
            Default = 1,
            Multi = false,
            Text = 'Lean Angle',
            Callback = function(v) Settings.AA_Lean = v end
        })
        legacybox:AddSlider('AA_SpinSpeed', {
            Text = 'Legacy Spin Speed',
            Default = 15,
            Min = 5,
            Max = 50,
            Rounding = 0,
            Callback = function(v) Settings.AA_SpinSpeed = v end
        })
    end

    -- 6. EXPLOITS
    do
        local peakexbox = Tabs.Exploits:AddLeftGroupbox('Peak Kill (Resolver)')
        local peakToggle = peakexbox:AddToggle('PeakKill_Enabled', {
            Text = 'Enable Peak Kill',
            Default = false,
            Callback = function(v)
                Settings.PeakKill_Enabled = v
                if v then
                    State.wasAACS2_Active = Settings.AACSP_Enabled
                    if Settings.AACSP_Enabled then
                        Settings.AACSP_Enabled = false
                        pcall(function()
                            if Library.Toggles and Library.Toggles.AACSP_Enabled then
                                Library.Toggles.AACSP_Enabled:SetValue(false)
                            end
                        end)
                    end
                else
                    stopPeek()
                    if State.wasAACS2_Active then
                        Settings.AACSP_Enabled = true
                        pcall(function()
                            if Library.Toggles and Library.Toggles.AACSP_Enabled then
                                Library.Toggles.AACSP_Enabled:SetValue(true)
                            end
                        end)
                        State.wasAACS2_Active = false
                    end
                end
            end
        })
        peakToggle:AddKeyPicker('PeakKill_Key', { Default = 'Z', SyncToggleState = true, Mode = 'Toggle', Text = 'Peak Kill' })

        peakexbox:AddDropdown('PeakKill_Mode', {
            Values = {'Вверх (Up)', 'Вниз (Down)', 'Влево (Left)', 'Вправо (Right)'},
            Default = 1,
            Multi = false,
            Text = 'Peak Direction',
            Callback = function(v) Settings.PeakKill_Mode = v end
        })

        peakexbox:AddLabel('Cycle Direction Key'):AddKeyPicker('PeakKill_CycleKey', { Default = 'X', Mode = 'Toggle', Text = 'Cycle Peak Direction' })
        peakexbox:AddSlider('PeakKill_Offset', {
            Text = 'Peak Offset Distance',
            Default = 15,
            Min = 5,
            Max = 50,
            Rounding = 0,
            Callback = function(v) Settings.PeakKill_Offset = v end
        })

        local fustMoveBox = Tabs.Exploits:AddLeftGroupbox('Fust Survival Movement')
        local fustSpdToggle = fustMoveBox:AddToggle('Fust_Speed_Enabled', {
            Text = 'speed (fust sv by fliriz)',
            Default = false,
            Callback = function(v)
                Settings.Fust_Speed_Enabled = v
                if not v then cleanupSpeedConstraints() end
            end
        })
        fustSpdToggle:AddKeyPicker('Fust_Speed_Key', { Default = 'LeftAlt', SyncToggleState = true, Mode = 'Toggle', Text = 'speed (fust sv by fliriz)' })

        fustMoveBox:AddDropdown('Fust_Speed_Mode', {
            Values = {'Smooth', 'Slide'},
            Default = 1,
            Multi = false,
            Text = 'Fust Speed Mode',
            Callback = function(v) Settings.Fust_Speed_Mode = v end
        })

        fustMoveBox:AddSlider('Fust_Speed_Power', {
            Text = 'Fust Target Spd',
            Default = 23,
            Min = 17,
            Max = 36,
            Rounding = 0,
            Callback = function(v) Settings.Fust_Speed_Power = v end
        })

        fustMoveBox:AddDivider()
        local fustLayToggle = fustMoveBox:AddToggle('Fust_Lay_Enabled', {
            Text = 'Lay (Лечь)',
            Default = false,
            Callback = function(v) setFustLayState(v) end
        })
        fustLayToggle:AddKeyPicker('Fust_Lay_Key', { Default = 'None', SyncToggleState = true, Mode = 'Toggle', Text = 'Lay (Лечь)' })

        fustMoveBox:AddToggle('Fust_Spider_Enabled', {
            Text = 'Spider (Стены на W)',
            Default = false,
            Callback = function(v) Settings.Fust_Spider_Enabled = v end
        })

        fustMoveBox:AddSlider('Fust_Spider_Speed', {
            Text = 'Spider Climb Speed',
            Default = 40,
            Min = 10,
            Max = 150,
            Rounding = 0,
            Callback = function(v) Settings.Fust_Spider_Speed = v end
        })

        local desyncbox = Tabs.Exploits:AddRightGroupbox('Movement & Desync')
        desyncbox:AddToggle('Speed_Enabled', {
            Text = 'Speedhack',
            Default = false,
            Callback = function(v)
                Settings.Speed_Enabled = v
                if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = 16
                end
            end
        })
        desyncbox:AddSlider('Speed_Value', {
            Text = 'WalkSpeed',
            Default = 50,
            Min = 16,
            Max = 250,
            Rounding = 0,
            Callback = function(v) Settings.Speed_Value = v end
        })

        desyncbox:AddToggle('BhopRage_Enabled', {
            Text = 'Bhop-rage (Air Speed)',
            Default = false,
            Callback = function(v) Settings.BhopRage_Enabled = v end
        })
        desyncbox:AddSlider('BhopRage_Speed', {
            Text = 'Bhop-rage Speed',
            Default = 65,
            Min = 20,
            Max = 250,
            Rounding = 0,
            Callback = function(v) Settings.BhopRage_Speed = v end
        })

        desyncbox:AddToggle('Desync_Enabled', {
            Text = 'CS2 Desync (Lag Behind)',
            Default = false,
            Callback = function(v) Settings.Desync_Enabled = v end
        })
        desyncbox:AddSlider('Desync_Distance', {
            Text = 'Lag Behind Distance',
            Default = 5,
            Min = 1,
            Max = 15,
            Rounding = 0,
            Callback = function(v) Settings.Desync_Distance = v end
        })
        desyncbox:AddToggle('Desync_Vis', {
            Text = 'Desync Ghost Visualizer',
            Default = false,
            Callback = function(v) Settings.Desync_Vis = v end
        })
        desyncbox:AddToggle('Desync_AntiPredict', {
            Text = 'Velocity Spoof (Anti-Predict)',
            Default = false,
            Callback = function(v) Settings.Desync_AntiPredict = v end
        })
    end

    -- 7. HITSOUNDS & 8. SETTINGS
    do
        local sndbox = Tabs.HitSounds:AddLeftGroupbox('HitSound Controls')
        sndbox:AddToggle('HitSound_Enabled', {
            Text = 'Enable HitSounds',
            Default = false,
            Callback = function(v) Settings.HitSound_Enabled = v end
        })
        sndbox:AddDropdown('HitSound_Type', {
            Values = {'Skeet', 'Rust', 'COD', 'Custom'},
            Default = 1,
            Multi = false,
            Text = 'Preset',
            Callback = function(v) Settings.HitSound_Type = v end
        })
        sndbox:AddSlider('HitSound_Volume', {
            Text = 'Volume (%)',
            Default = 100,
            Min = 0,
            Max = 400,
            Rounding = 0,
            Callback = function(v) Settings.HitSound_Volume = v end
        })

        local sndtest = Tabs.HitSounds:AddRightGroupbox('Custom Sound & Test')
        sndtest:AddInput('HitSound_CustomID', {
            Default = '',
            Numeric = false,
            Finished = false,
            Text = 'Custom Sound ID',
            Placeholder = 'e.g. 4817809188',
            Callback = function(v) Settings.HitSound_CustomID = v end
        })
        sndtest:AddButton('Test HitSound', function() playHitSound() end)

        local menubox = Tabs['Settings']:AddRightGroupbox('Menu Controls')
        menubox:AddLabel('Menu Keybind'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu Keybind' })

        menubox:AddButton('Unload Script', function()
            pcall(function() Library:Unload() end)
            destroyLinoriaUI()
        end)

        pcall(function()
            if Library.Options and Library.Options.MenuKeybind then
                Library.ToggleKeybind = Library.Options.MenuKeybind
            end
        end)

        ThemeManager:SetLibrary(Library)
        SaveManager:SetLibrary(Library)

        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ 'MenuKeybind', 'PeakKill_Key', 'TP_Key', 'PeakKill_CycleKey', 'Fust_Speed_Key', 'Fust_Lay_Key', 'Fust_Zoom_Key' })

        ThemeManager:SetFolder('Skeetparser')
        SaveManager:SetFolder('Skeetparser/RandomizerRedux')

        SaveManager:BuildConfigSection(Tabs['Settings'])
        ThemeManager:ApplyToTab(Tabs['Settings'])
    end
end

-- Обработка Unload
Library:OnUnload(function()
    State.IsUnloaded = true
    
    pcall(function()
        RunService:UnbindFromRenderStep("FustZoomOverride")
        RunService:UnbindFromRenderStep("FustNoShakeFix")
        RunService:UnbindFromRenderStep("FustLayCameraFix")
    end)

    local m = getrawmetatable(game)
    setreadonly(m, false)
    m.__namecall = oldNamecall
    m.__index = oldIndex
    m.__newindex = oldNewIndex
    setreadonly(m, true)
    
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    UserInputService.MouseDeltaSensitivity = 1
    if Camera then Camera.FieldOfView = 70 end

    for _, conn in pairs(Connections) do conn:Disconnect() end
    Connections = {}
    for _, c in ipairs(State.weaponFireConns) do if c.Connected then c:Disconnect() end end
    table.clear(State.weaponFireConns)
    if State.espUpdateConn then State.espUpdateConn:Disconnect() end
    if State.workspaceAddedConn then State.workspaceAddedConn:Disconnect() end
    if State.tracerWorkspaceConn then State.tracerWorkspaceConn:Disconnect() end

    setFustLayState(false)
    cleanupSpeedConstraints()
    clearAllCarESP()
    for _, ui in pairs(State.invUIs) do if ui then ui:Destroy() end end
    table.clear(State.invUIs)
    table.clear(State.memoryInventory)
    table.clear(State.teamCheckCache)
    if State.tracerFolder then State.tracerFolder:Destroy() end
    if State.fustOverlayGui then State.fustOverlayGui:Destroy() end
    if Preview.Gui then Preview.Gui:Destroy() end
    
    restoreWalls()
    Settings.NightMode_Enabled = false
    Settings.GalaxySky_Enabled = false
    Settings.FullBright_Enabled = false
    Settings.Fust_NoFog_Enabled = false
    updateLighting()
    
    for motor, c0 in pairs(State.originalC0s) do
        if motor and motor.Parent then motor.C0 = c0 end
    end
    for tool, grip in pairs(State.originalGrips) do
        if tool and tool.Parent then tool.Grip = grip end
    end
    
    if State.colorCorrection then State.colorCorrection:Destroy() end
    stopPeek()
    
    if State.currentGhost then State.currentGhost:Destroy() end
    if State.peakGui then State.peakGui:Destroy() end
    
    local char = LocalPlayer.Character
    if char then
        pcall(function()
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMaxZoomDistance = 128
            if char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = 16
                char.Humanoid.AutoRotate = true
                char.Humanoid.CameraOffset = Vector3.zero
            end
        end)
        applyChamsRobust(char, nil, nil, false)
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then applyChamsRobust(tool, nil, nil, false) end
    end
    
    for model, _ in pairs(State.origProps) do
        if model and typeof(model) == "Instance" then applyChamsRobust(model, nil, nil, false) end
    end

    pcall(function() State.fovCircle:Remove() end)
    pcall(function() State.crosshairText:Remove() end)
    
    for _, line in pairs(State.crosshairLines) do pcall(function() line:Remove() end) end
    for _, drawings in pairs(espCache) do
        for _, obj in pairs(drawings) do pcall(function() obj:Remove() end) end
    end
    espCache = {}

    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("ClientNeonHat") then
            p.Character.ClientNeonHat:Destroy()
        end
    end

    destroyLinoriaUI()
end)

SaveManager:LoadAutoloadConfig()
