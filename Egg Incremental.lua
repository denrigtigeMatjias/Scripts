local library = loadstring(game:HttpGet(('https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wall%20v3')))()

local eggWin = library:CreateWindow("Egg Inc.")
local eggFolder = eggWin:CreateFolder("Collection")
local eggMisc = eggWin:CreateFolder("Misc")

-- Variables
local workspace = game:GetService("Workspace")
local player = game.Players.LocalPlayer
local folderName = "Eggs"
local eggsFolder = workspace:WaitForChild(folderName)

local walkspeed;

-- Functions
local function teleportToPlayer(part)
    if part:IsA("BasePart") then
        part.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position)
    end
end

local toggle1 = false
eggFolder:Toggle("Egg Autofarm",function(bool)
toggle1 = bool
end)

spawn(function()
    while wait() do
        if toggle1 then
            for _, eggPart in ipairs(eggsFolder:GetChildren()) do
                teleportToPlayer(eggPart)
                task.wait(0.001)
            end
        end
    end
end)

local toggle2 = false
eggMisc:Toggle("Walkspeed",function(bool1)
toggle2 = bool1
end)

spawn(function()
    while wait() do
        if toggle2 then
            local Char = game.Players.LocalPlayer.Character or workspace:FindFirstChild(game.Players.LocalPlayer.Name)
            local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")

            local function WalkSpeedChange()
                if Char and Human then
                    Human.WalkSpeed = walkspeed
                end
            end

            WalkSpeedChange()
            HumanModCons.wsLoop = (HumanModCons.wsLoop and HumanModCons.wsLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
            HumanModCons.wsCA = (HumanModCons.wsCA and HumanModCons.wsCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
                Char, Human = nChar, nChar:WaitForChild("Humanoid")
                WalkSpeedChange()
                HumanModCons.wsLoop = (HumanModCons.wsLoop and HumanModCons.wsLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
            end)
        else
            HumanModCons.wsLoop = (HumanModCons.wsLoop and HumanModCons.wsLoop:Disconnect() and false) or nil
            HumanModCons.wsCA = (HumanModCons.wsCA and HumanModCons.wsCA:Disconnect() and false) or nil
        end
    end
end)

eggMisc:Slider("Walkspeed",{
    min = 16; -- min value of the slider
    max = 300; -- max value of the slider
    precise = true; -- max 2 decimals
},function(value)
    walkspeed = value
    print(walkspeed)
end)
