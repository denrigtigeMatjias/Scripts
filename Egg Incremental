local library = loadstring(game:HttpGet(('https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wall%20v3')))()

local eggWin = library:CreateWindow("Egg Inc.")
local eggFolder = eggWin:CreateFolder("Collection")

-- Variables
local workspace = game:GetService("Workspace")
local player = game.Players.LocalPlayer
local folderName = "Eggs"
local eggsFolder = workspace:WaitForChild(folderName)

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
            end
        end
    end
end)
