-- NOT IN ANY WAY FULLY DEVELOPED USE AT OWN RISK

--[[

To Do
    - Fix autofarm so that it detects when it's done converting and then goes back farming and also delay and radius options
    - More features to autofarm (Auto ballon, Farm under cloud, farm bubbles, farm puffshrooms, farm sprouts, farm stickers, farm fireflies and etc.)
    - Server hopper for stickers?
    - Notify on discord when boss spawns with <@discordId> "Vicious Bee has Spawned in Daisy Field at 10:15 PM"
    - Advanced auto kill mobs and bosses
    - Auto quests both accept and complete
    - Updated values since last send webhook (E.g. +1m honey since last update)
    - More configs for webhook (Honey per hour, Pollen per hour, Item tracker or something along the lines of that)

Done
    - Auto claim hive if user hasn't already claimed a hive
    - Advanced configurable webhook stat tracker on discord with delay for when to send and with an option to ping user (optional) and for what to display (Honey, Pollen for now)
    - Tween Teleportation function to teleport smoothly for not flagging the anti-cheat
    - Auto "events" like honeystorm, dispenser or field boost
    - Function for updating honey and pollen

Useful links
    - https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes (Useless now)

]]

-- Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Window
local Window = OrionLib:MakeWindow({Name = "Bee Swarm", HidePremium = false, SaveConfig = true, ConfigFolder = "matjias bee swarm"})

--____   _________ __________.___   _____ __________.____     ___________ _________
--\   \ /   /  _  \\______   \   | /  _  \\______   \    |    \_   _____//   _____/
-- \   Y   /  /_\  \|       _/   |/  /_\  \|    |  _/    |     |    __)_ \_____  \
--  \     /    |    \    |   \   /    |    \    |   \    |___  |        \/        \
--   \___/\____|__  /____|_  /___\____|__  /______  /_______ \/_______  /_______  /
--                \/       \/            \/       \/        \/        \/        \/

-- Services
local workspace = Game:GetService("Workspace")
local players = Game:GetService("Players")
local ReplicatedStorage = Game:GetService("ReplicatedStorage")

-- Player
local player = players.LocalPlayer
local character = player.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

-- Backpack, honey and Pollen stuff
local honey = player.PlayerGui.ScreenGui.MeterHUD.HoneyMeter.Bar.TextLabel.Text:gsub(",","");
local honeyPerSec = player.PlayerGui.ScreenGui.MeterHUD.HoneyMeter.Bar.PerSecLabel.Text;

local pollen = player.PlayerGui.ScreenGui.MeterHUD.PollenMeter.Bar.TextLabel.Text:gsub(",","");
local pollenPerSec = player.PlayerGui.ScreenGui.MeterHUD.PollenMeter.Bar.PerSecLabel.Text;

local backpackFullPercent = 0.9

-- Paths and remotes
local collectiblesPath = workspace.Collectibles -- Folder with the collectibles as the direct children (Name: C; ClassName: Part)
-- ─ Collectibles
--   └─ Part (Name: C (Part Location); ClassName: Part)

local cloudsPath = workspace.Clouds
-- ─ Clouds
--   └─ CloudInstance (One for each field that there's an active cloud in; ClassName: Folder)
--      ├─ Part (Name: Plane (Cloud main part); ClassName: Part)
--      └─ Part (Name: Root (Field Location); ClassName: Part)

local gatesPath = workspace.Gates
-- ─ 
--   ├─
--   └─

local happeningsPath = workspace.Happenings
-- ─ Happening (Folder)
--   └─ Puffshrooms (Folder)
--      └─ PuffballMushroomModelCommon (Model)

local toyEvent = ReplicatedStorage.Events.ToyEvent -- Remote to start events (Honeystorm, Dispensers and Field boosts)

-- Position For Important Locations
local areaPos = {
    HivePosition = CFrame.new(Vector3.new(0,0,0)),
    DandelionField = CFrame.new(Vector3.new(-51.185562, 4.887609, 220.577744)),
    SunflowerField = CFrame.new(Vector3.new(-212.886124, 4.887609, 182.218491)),
    MushroomField = CFrame.new(Vector3.new(-86.605019, 4.887610, 123.764465)),
    CloverField = CFrame.new(Vector3.new(153.403610, 34.387608, 191.926361)),
    BlueflowerField = CFrame.new(Vector3.new(144.383118, 4.887609, 100.749161)),
}

-- Tracking variables
local area; -- Selected area
local hive; -- Hive of player

-- Version
local version = "0.01"; -- Current version of script

-- Autofarm
local moveDelay = 5; -- Delay between moving when farming
local farmRadius = 20; -- How big of a radius to farm in

-- Webhook stuff
local sendWebhook = false; -- Whether to send an update or not to the webhook

local webhookUrl = ""; -- Url of discord webhook
local webhookDelay = 600; -- How many seconds delay before giving an update

local discordId = ""; -- Discord it to tag user
local discordTag = ""; -- Variable for discord tag <@discordId>

local showHoney = false; -- Show honey in webhook message
local showPollen = false; -- Show pollen in webhook message

-- **Toggle booleans**
--Autofarm toggles
local autofarmToggle = false; -- Toggle for autofarm
local sprinkleToggle = false; -- Toggle for sprinkle
local autodigToggle = false; -- Toggle for auto dig
local autoCollectTokens = false;

--Mob toggles
local autoKillSpider = false;

--Event toggles
local autoHoneystorm = false;
local autoDispense = false;
local autoBoosts = false;
local autoClock = false;
local autoAntPass = false;

--_______________ __________  ____________________.___________    _______    _________
--\_   _____/    |   \      \ \_   ___ \__    ___/|   \_____  \   \      \  /   _____/
-- |    __) |    |   /   |   \/    \  \/ |    |   |   |/   |   \  /   |   \ \_____  \ 
-- |     \  |    |  /    |    \     \____|    |   |   /    |    \/    |    \/        \
-- \___  /  |______/\____|__  /\______  /|____|   |___\_______  /\____|__  /_______  /
--     \/                   \/        \/                      \/         \/        \/ 

-- Update Honey and Pollen values
local function updateValues()
    local honeyPerSecText = player.PlayerGui.ScreenGui.MeterHUD.HoneyMeter.Bar.TextLabel.Text:gsub(',', '')
    honeyPerSec = tonumber(honeyPerSecText) -- Calculates how much honey im getting per second
    local honeyText = player.PlayerGui.ScreenGui.MeterHUD.HoneyMeter.Bar.TextLabel.Text:gsub(',', '')
    honey = tonumber(honeyText); -- Returns the value of how much honey i currently have in int

    local pollenPerSecText = player.PlayerGui.ScreenGui.MeterHUD.PollenMeter.Bar.TextLabel.Text:gsub(',', '')
    pollenPerSec = tonumber(pollenPerSecText) -- Calculates how much pollen im getting per second
    local pollenText = player.PlayerGui.ScreenGui.MeterHUD.PollenMeter.Bar.TextLabel.Text:gsub(',', '')
    pollen = tonumber(pollenText); -- Returns the value of how much pollen i currently have
end

-- Function to perform tweening teleport
local function TweeningTeleport(pos, time)
    game:GetService("TweenService"):Create(humanoidRootPart, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = pos}):Play()
    task.wait(time)
end

-- Function to walk to a random position in a circle
local function WalkToRandomPositionInCircle(radius, delay)
    while autofarmToggle do
        if humanoid then
            local centerPosition = areaPos[area]
            local randomAngle = math.rad(math.random(0, 360))
            local randomX = centerPosition.X + radius * math.cos(randomAngle)
            local randomZ = centerPosition.Z + radius * math.sin(randomAngle)
            local randomPosition = Vector3.new(randomX, centerPosition.Y, randomZ)

            humanoid.WalkToPoint = randomPosition

            print("Walking to random position:", randomPosition)
        else
            warn("Humanoid not found.")
        end

        task.wait(delay)
    end
end

-- Function to scan for the hive and set the hive variable
local function ScanAndCheckForHive()
    for _, descendant in pairs(workspace.Honeycombs:GetDescendants()) do
        local ownerValue = descendant:FindFirstChild("Owner")

        if ownerValue and ownerValue:IsA("ObjectValue") then
            if ownerValue.Value == player then
                hive = ownerValue.Parent.Name -- Save name of the hive
                areaPos.HivePosition = CFrame.new(ownerValue.Parent.SpawnPos.Value.Position) -- Save CFrame position of hive

                print(areaPos.HivePosition) -- Print it to make sure it hasn't been set to nil
                print("Hive set to:", hive) -- Print what hive was already claimed

                return
            elseif ownerValue.Value == nil then
                hive = ownerValue.Parent.Name -- Save name of hive
                TweeningTeleport(CFrame.new(ownerValue.Parent.SpawnPos.Value.Position), 3) -- Teleport to unclaimed hive
                
                local claimHiveArg = hive:gsub("Hive", "") -- Args for claiming

                local claimHive = {
                    [1] = tonumber(claimHiveArg)
                }

                ReplicatedStorage:WaitForChild("Events"):WaitForChild("ClaimHive"):FireServer(unpack(claimHive)) -- Claim hive

                areaPos.HivePosition = CFrame.new(ownerValue.Parent.SpawnPos.Value.Position) -- Save CFrame position of hive

                print(areaPos.HivePosition) -- Print it to make sure it hasn't been set to nil
                print("Hive set to:", hive) -- Print what hive was selected

                return
            end
        end
    end
    
    print("No hive found.") -- If no hive was found, print a message
end

-- Autofarm Functions
-- Function to check if the backpack is full
local function IsBackpackFull()
    local fractionString = player.PlayerGui.ScreenGui.MeterHUD.PollenMeter.Bar.TextLabel.Text:gsub(",", ""); -- Backpack string
    local numerator, denominator = fractionString:match("(%d+)/(%d+)"); -- Saves the numerator (pollen), and denominator (Max capacity)
    local backpackFullness = tonumber(numerator) / tonumber(denominator) or 0.01; -- Calculate how full the backpack is in percent

    print("Backpack Fullness:", backpackFullness)  -- Add this line for debugging

    print(backpackFullness >= backpackFullPercent)

    return backpackFullness >= backpackFullPercent
end

-- Loop for autofarm
local function AutofarmLoop()
    while autofarmToggle do
        if IsBackpackFull() and autofarmToggle then
            print("Backpack is full, converting honey...")

            -- ConvertHoney
            TweeningTeleport(areaPos.HivePosition, 4) -- Teleport to hive

            -- Update values inside the loop
            local fractionString = player.PlayerGui.ScreenGui.MeterHUD.PollenMeter.Bar.TextLabel.Text:gsub(",", "") -- (example 3,500/3,500)
            local numerator, denominator = fractionString:match("(%d+)/(%d+)")
            updateValues() -- Update honey and pollen variables

            print("Converting honey") -- Print to make sure we reach this far

            ReplicatedStorage.Events.PlayerHiveCommand:FireServer("ToggleHoneyMaking") -- Begin converting pollen -> honey

            -- Wait for honey to be converted
            repeat
                task.wait(4)
                fractionString = player.PlayerGui.ScreenGui.MeterHUD.PollenMeter.Bar.TextLabel.Text:gsub(",", "")
                numerator, denominator = fractionString:match("(%d+)/(%d+)")
                print("Waiting")
            until tonumber(numerator) == 0

            print("Resuming autofarm...")

            task.wait(6)
        elseif not IsBackpackFull() and autofarmToggle then
            WalkToRandomPositionInCircle(farmRadius, moveDelay)
        end
    end
end

-- Start Autofarm
local function StartAutofarm()
    if not autofarmToggle then
        return
    elseif IsBackpackFull() then
        print("Backpack is full, converting honey...")

        -- ConvertHoney
        TweeningTeleport(areaPos.HivePosition, 4) -- Teleport to hive
        -- Get the numerator and denominator of the backpack
        local fractionString = player.PlayerGui.ScreenGui.MeterHUD.PollenMeter.Bar.TextLabel.Text:gsub(",","");
        local numerator, denominator = fractionString:match("(%d+)/(%d+)");

        updateValues() -- Update honey and pollen variables

        print("Converting honey") -- Print to make sure we reach this far

        ReplicatedStorage.Events.PlayerHiveCommand:FireServer("ToggleHoneyMaking") -- Begin converting pollen -> honey

        -- Wait for honey to be converted
        repeat task.wait(4)
            fractionString = player.PlayerGui.ScreenGui.MeterHUD.PollenMeter.Bar.TextLabel.Text:gsub(",","");
            numerator, denominator = fractionString:match("(%d+)/(%d+)");
            print(numerator)
            print("Waiting")
        until tonumber(numerator) == 0

        wait(6)

        print("Resuming autofarm...")

        TweeningTeleport(areaPos[area], 4) -- Tween to the selected area
        AutofarmLoop() -- Start The Loop
    else
        TweeningTeleport(areaPos[area], 4) -- Tween to the selected area
        AutofarmLoop() -- Start The Loop
    end
end

-- Call Webhook Simplification Function
local function SendWebhookMessage(text)
    local response = request({
        Url = webhookUrl,
        Method = "POST",
        Headers = {
            ['Content-Type'] = 'application/json'
        },
        Body = game:GetService('HttpService'):JSONEncode({content = text})
    })

    print(response.StatusCode .. " - " .. response.StatusMessage) --> 200 - HTTP/1.1 200 OK
end

-- Example use of function SendWebhookEmbed("", "Bee Swarm", true, "Here\'s an update on your progress "..player.DisplayName, tonumber(0xffffff), true, true)
-- Would send this embed to discord https://imgur.com/a/wHxI1NK
local function SendWebhookEmbed(Content, Title, isBold, Description, Color)
    -- Set discordTag to <@discordId> to notify the user which is "global value" to be used in other parts of the script
    if discordId ~= "" then
        discordTag = "<@"..discordId..">"
        Content = discordTag
    end
    
    if isBold then
        Title = "**" .. Title .. "**"
    end

    local fields = {}

    if showHoney then
        table.insert(fields, {
            ["name"] = "Honey:",
            ["value"] = player.PlayerGui.ScreenGui.MeterHUD.HoneyMeter.Bar.TextLabel.Text,
            ["inline"] = true
        })
    end

    if showPollen then
        table.insert(fields, {
            ["name"] = "Pollen:",
            ["value"] = player.PlayerGui.ScreenGui.MeterHUD.PollenMeter.Bar.TextLabel.Text,
            ["inline"] = true
        })
    end

    local response = request({
        Url = webhookUrl,
        Method = "POST",
        Headers = {
            ['Content-Type'] = 'application/json'
        },
        Body = game:GetService('HttpService'):JSONEncode({
            ["content"] = Content or "",
            ["embeds"] = {{
                ["title"] = Title,
                ["description"] = Description,
                ["type"] = 'rich',
                ["color"] = Color,
                ["fields"] = fields
            }}
        })
    })

    print(response.StatusCode .. " - " .. response.StatusMessage) --> 200 - HTTP/1.1 200 OK
end

--________________ __________       ____ 
--\__    ___/  _  \\______   \     /_   |
--  |    | /  /_\  \|    |  _/      |   |
--  |    |/    |    \    |   \      |   |
--  |____|\____|__  /______  /      |___|
--                \/       \/            


-- Home
local Tab1 = Window:MakeTab({Name = "Home", Icon = "rbxassetid://4483362458", PremiumOnly = false})
local HomeSection = Tab1:AddSection({Name = "Change Logs"})

Tab1:AddLabel("Current version: "..version)
Tab1:AddLabel("Made everything from scratch")
Tab1:AddLabel("Now it just needs thorough testing for everything")

-- Stats
local StatsSection = Tab1:AddSection({Name = "Stats Tracker"})

Tab1:AddLabel("Current hive: ".."hive")
Tab1:AddLabel("Current honey: "..honey)
Tab1:AddLabel("Current pollen: "..pollen)

-- More
local MoreSection = Tab1:AddSection({Name = "More"})

Tab1:AddButton({
	Name = "Discord Link",
	Callback = function()
		setclipboard("https://discord.gg/vs68vhZ7nY")
	end,
})

--________________ __________      ________  
--\__    ___/  _  \\______   \     \_____  \ 
--  |    | /  /_\  \|    |  _/      /  ____/ 
--  |    |/    |    \    |   \     /       \ 
--  |____|\____|__  /______  /     \_______ \
--                \/       \/              \/

-- Autofarm
local Tab2 = Window:MakeTab({Name = "Autofarm", Icon = "rbxassetid://4483362458", PremiumOnly = false})
local AutofarmSection = Tab2:AddSection({Name = "Autofarm"})

Tab2:AddDropdown({
	Name = "Farming Field",
    Default = "Dandelion Field",
	Options = {"Dandelion Field", "Sunflower Field", "Mushroom Field", "Clover Field", "Blueflower Field", "Spider Field", "Bamboo Field", "Strawberry Field", "Pineapple Patch", "Cactus Field", "Pumpkin Patch", "Pine Tree Forest", "Rose Field", "Mountain Top Field", "Coconut Field", "Pepper Patch", "Snail Field"},
	Callback = function(Option)
        area = Option:gsub(' ', '')
        print("New Area Selected: "..area)
	end,
})

-- Autofarm toggle
Tab2:AddToggle({
    Name = "Autofarm",
    Default = false,
    Callback = function(Value)
        autofarmToggle = Value
        if autofarmToggle then
            StartAutofarm()
        end
    end,
})

Tab2:AddSlider({
	Name = "Delay between moving",
	Min = 1,
	Max = 30,
	Default = 10,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "Seconds Delay",
	Callback = function(movingDelay)
		moveDelay = movingDelay
	end
})

Tab2:AddSlider({
	Name = "Farming Radius",
	Min = 1,
	Max = 30,
	Default = 15,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "Radius",
	Callback = function(circleRadius)
		farmRadius = circleRadius;
	end
})

-- Sprinkle toggle
Tab2:AddToggle({
	Name = "Auto sprinkle",
	Default = false,
	Callback = function(Value2)
		sprinkleToggle = Value2
	end,
})

task.spawn(function()
    while task.wait() do
        if sprinkleToggle then
            print("Auto sprinkle is on!")
            task.wait(1)
            --ReplicatedStorage:WaitForChild("Events"):WaitForChild("SprinklePlace"):FireServer()
        end
    end
end)

-- Auto dig
Tab2:AddToggle({
	Name = "Auto dig",
	Default = false,
	Callback = function(Value3)
		autodigToggle = Value3
	end,
})

task.spawn(function()
    while task.wait(0.1) do
        if autodigToggle then
            ReplicatedStorage:WaitForChild("Events"):WaitForChild("ToolCollect"):FireServer()
        end
    end
end)

-- Collect honey tokens
Tab2:AddToggle({
	Name = "Collect honey tokens",
	Default = false,
	Callback = function(Value30)
		autoCollectTokens = Value30
	end,
})

task.spawn(function()
    while task.wait(0.1) do
        if autoCollectTokens then
            local playerPosition = character and humanoidRootPart
            if not playerPosition then
                warn("Player position not found.")
                return
            end

            for _, collectible in pairs(collectiblesPath:GetChildren()) do
                if collectible:IsA("Part") and collectible.Name == "C" then
                    while collectible.Transparency == 0 do
                        playerPosition.CFrame = collectible.CFrame
                        wait(.1)
                    end
                end
            end
        end
    end
end)

--________________ __________      ________  
--\__    ___/  _  \\______   \     \_____  \ 
--  |    | /  /_\  \|    |  _/       _(__  < 
--  |    |/    |    \    |   \      /       \
--  |____|\____|__  /______  /     /______  /
--                \/       \/             \/ 

-- Quest
local Tab3 = Window:MakeTab({Name = "Quest", Icon = "rbxassetid://4483362458", PremiumOnly = false})
local QuestSection = Tab3:AddSection({Name = "Quest"})

Tab3:AddButton({
	Name = "Quest",
	Callback = function()
		print("Pressed")
	end,
})

--________________ __________         _____
--\__    ___/  _  \\______   \       /  |  |
--  |    | /  /_\  \|    |  _/      /   |  |_
--  |    |/    |    \    |   \     /    ^   /
--  |____|\____|__  /______  /     \____   |
--                \/       \/           |__|

-- Combat
local Tab4 = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483362458", PremiumOnly = false})
local MobSection = Tab4:AddSection({Name = "Mobs"})

Tab4:AddToggle({
	Name = "Kill Spider",
	Default = false,
	Callback = function(spiderKill)
        autoHoneystorm = spiderKill
	end,
})

task.spawn(function()
    while autoKillSpider do
        print("Auto kill spider")
    end
end)

--________________ __________       .________
--\__    ___/  _  \\______   \      |   ____/
--  |    | /  /_\  \|    |  _/      |____  \
--  |    |/    |    \    |   \      /       \
--  |____|\____|__  /______  /     /______  /
--                \/       \/             \/

-- Events
local Tab5 = Window:MakeTab({Name = "Events", Icon = "rbxassetid://4483362458", PremiumOnly = false})
local EventSection = Tab5:AddSection({Name = "Events"})

Tab5:AddToggle({
	Name = "Start honeystorm",
	Default = false,
	Callback = function(Value10)
        autoHoneystorm = Value10
	end,
})

task.spawn(function()
    while autoHoneystorm do
        toyEvent:FireServer("Honeystorm")
        task.wait(100)
    end
end)

Tab5:AddToggle({
	Name = "Auto dispensers",
	Default = false,
	Callback = function(Value11)
        autoDispense = Value11
	end,
})

task.spawn(function()
    while autoDispense do
        toyEvent:FireServer("Free Royal Jelly Dispenser")
        toyEvent:FireServer("Blueberry Dispenser")
        toyEvent:FireServer("Strawberry Dispenser")
        toyEvent:FireServer("Treat Dispenser")
        toyEvent:FireServer("Coconut Dispenser")
        toyEvent:FireServer("Glue Dispenser")
        task.wait(100)
    end
end)

--________________ __________        ______  
--\__    ___/  _  \\______   \      /  __  \ 
--  |    | /  /_\  \|    |  _/      >      < 
--  |    |/    |    \    |   \     /   --   \
--  |____|\____|__  /______  /     \______  /
--                \/       \/             \/ 

-- Settings
local Tab8 = Window:MakeTab({Name = "Settings", Icon = "rbxassetid://4483362458", PremiumOnly = false})
local AutofarmSettingsSection = Tab8:AddSection({Name = "Autofarm Settings"})

local SafetySettingsSection = Tab8:AddSection({Name = "Safety Settings"})

Tab8:AddDropdown({
	Name = "Teleportation Method",
    Default = "Tweeening",
	Options = {"Tweening", "Instant"},
	Callback = function(Option)
        area = Option:gsub(' ', '')
        print("New Area Selected: "..area)
	end,
})

--________________ __________       ________ 
--\__    ___/  _  \\______   \     /   __   \
--  |    | /  /_\  \|    |  _/     \____    /
--  |    |/    |    \    |   \        /    / 
--  |____|\____|__  /______  /       /____/  
--                \/       \/                

-- Webhook
local Tab9 = Window:MakeTab({Name = "Webhook", Icon = "rbxassetid://4483362458", PremiumOnly = false})
local WebhookSection = Tab9:AddSection({Name = "Webhook Settings"})

Tab9:AddToggle({
	Name = "Send webhook",
	Default = false,
	Callback = function(Value10)
        sendWebhook = Value10
	end,
})

Tab9:AddTextbox({
	Name = "Webhook Link",
	Default = "",
	TextDisappear = false,
	Callback = function(webhooklink)
		webhookUrl = webhooklink
	end
})

Tab9:AddTextbox({
	Name = "Discord ID for ping (Optional)",
	Default = "",
	TextDisappear = false,
	Callback = function(discordUserId)
		discordId = discordUserId
        discordTag = "<@"..discordId..">"
        print(discordId)
	end
})

Tab9:AddButton({
	Name = "Test webhook by sending 'Text'",
	Callback = function()
		SendWebhookMessage("text")
	end,
})

Tab9:AddSlider({
	Name = "Webhook notification delay",
	Min = 60,
	Max = 3600,
	Default = 600,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "Seconds",
	Callback = function(seconds)
		webhookDelay = seconds
	end
})

local startTime = os.clock()

task.spawn(function()
    if sendWebhook then
        while webhookUrl ~= "" or nil do
            local elapsedTime = os.clock() - startTime
            local remainingTime = webhookDelay - elapsedTime
    
            if remainingTime > 0 then
                task.wait(remainingTime)
            elseif remainingTime <= 0 then
                -- Update Values before sending
                updateValues()

                -- Send webhook when the remaning time is equal to one or less than one
                SendWebhookEmbed("", "Bee Swarm", true, "Here\'s an update on your progress "..player.DisplayName, tonumber(0x0D69AC), showHoney, showPollen)

                -- Update start time for the next iteration
                startTime = os.clock()
            else
                task.wait(0.01)  -- This prevents the loop from consuming too much CPU
            end
        end
    end
end)

--________________ __________       ___________
--\__    ___/  _  \\______   \     /_   \   _  \
--  |    | /  /_\  \|    |  _/      |   /  /_\  \
--  |    |/    |    \    |   \      |   \  \_/   \
--  |____|\____|__  /______  /      |___|\_____  /
--                \/       \/                  \/

--Misc
local Tab10 = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://4483362458", PremiumOnly = false})
local MiscSection = Tab10:AddSection({Name = "Misc"}) 

--   _____  .___  __________________
--  /     \ |   |/   _____/\_   ___ \
-- /  \ /  \|   |\_____  \ /    \  \/
--/    Y    \   |/        \\     \____
--\____|__  /___/_______  / \______  /
--        \/            \/         \/

Tab10:AddBind({
	Name = "Bind",
	Default = Enum.KeyCode.E,
	Hold = false,
	Callback = function()
		print("press")
	end,
})

Tab10:AddButton({
	Name = "Destroy UI",
	Callback = function()
		Window:Destroy()
	end,
})

OrionLib:Init()

ScanAndCheckForHive()
