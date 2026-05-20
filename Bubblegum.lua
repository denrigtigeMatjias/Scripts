local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

--//Variables\\--
local previousPosition = nil
local player = game.Players.LocalPlayer
local team = nil
local rebirthSkips = nil
local rSkips
local int = tonumber
local str = tostring
local doorParent = nil;

--//Display Stats\\--
local money = nil;
local rebirths = nil;
local rTokens = nil;

if player.Team == nil then
    OrionLib:MakeNotification({
    	Name = "Choose a team!",
    	Content = "The GUI won't load before you pick a team",
    	Image = "rbxassetid://4483345998",
    	Time = 15
    })
    
    while player.Team == nil do
        wait(0.1)
    end
    
    team = player.Team;

    coroutine.wrap(function()
        while wait(0.05) do
            money = game:GetService("Players").math5051.leaderstats.Money.Value
            rebirths = game:GetService("Players").math5051.leaderstats.Rebirths.Value
            rTokens = game:GetService("Players").math5051.PlayerGui.GameGUI.Shop.Currency.Tokens.Text
        end
    end)()

    for i,v in pairs(game:GetService("Workspace").Tycoons[str(team)].Interact.Factory:GetDescendants()) do
        if v.Name == "Door" and v.ClassName == "ProximityPrompt" then
            doorParent = v.Parent
        end
    end
else
    team = player.Team;

    coroutine.wrap(function()
        while wait(0.05) do
            money = game:GetService("Players").math5051.leaderstats.Money.Value
            rebirths = game:GetService("Players").math5051.leaderstats.Rebirths.Value
            rTokens = game:GetService("Players").math5051.PlayerGui.GameGUI.Shop.Currency.Tokens.Text
        end
    end)()

    for i,v in pairs(game:GetService("Workspace").Tycoons[str(team)].Interact.Factory:GetDescendants()) do
        if v.Name == "Door" and v.ClassName == "ProximityPrompt" then
            doorParent = v.Parent
        end
    end
end

local Window = OrionLib:MakeWindow({Name = "Gumball Factory Tycoon", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

local Tab = Window:MakeTab({
	Name = "Main",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Autofarm"
})

Tab:AddToggle({
	Name = "Auto Open",
	Default = false,
    Callback = function(Value)
    getgenv().autoOpen = Value;

    while getgenv().autoOpen and wait() do
        pcall(function()
            for i,v in pairs(game:GetService("Workspace").Tycoons[str(team)].Interact.Factory:GetDescendants()) do
                if v.Name == "Door" and v.ClassName == "ProximityPrompt" then
                    if v.Parent.Color == Color3.fromRGB(79, 190, 86) then
                        previousPosition = player.Character:FindFirstChild('HumanoidRootPart').CFrame
                        player.Character:FindFirstChild('HumanoidRootPart').CFrame = v.Parent.CFrame
                        wait(0.5)
                        fireproximityprompt(v)
                        wait(0.2)
                        player.Character:FindFirstChild('HumanoidRootPart').CFrame = previousPosition
                    end
                end
            end
        end)
    end
end})

Tab:AddToggle({
	Name = "Auto Load",
	Default = false,
    Callback = function(Value)
    getgenv().autoLoad = Value;

    while getgenv().autoLoad and wait() do
        pcall(function()
            for i,v in pairs(game:GetService("Workspace").Tycoons[str(team)].Interact:GetDescendants()) do
                if v.Name == "Click" and v.ClassName == "ProximityPrompt" then
                    if doorParent.Color == Color3.fromRGB(220, 76, 76) then 
                        player.Character:FindFirstChild('HumanoidRootPart').CFrame = v.Parent.CFrame
                        wait(0.05)
                        fireproximityprompt(v)
                    else
                        return;
                    end
                end
            end
        end)
    end
end})

-- Very Bad (Remake it)
Tab:AddToggle({
	Name = "Auto Upgrade",
	Default = false,
	Callback = function(Value)
    getgenv().autoUpgrade = Value;

    while getgenv().autoUpgrade and wait() do
        pcall(function()
            for i,v in pairs(game:GetService("Workspace").Tycoons[str(team)].Buttons:GetDescendants()) do
                if v.ClassName == "TouchTransmitter" then
                    if int(v.Parent.Parent.Value.Value) > 0 then
                        firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, v.Parent, 0)
                        firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, v.Parent, 1)
                        wait(0.05)
                    end
                end
            end
        end)
    end
end})

Tab:AddToggle({
	Name = "Auto Rebirth",
	Default = false,
	Callback = function(Value)
    getgenv().autoRebirth = Value;

    while getgenv().autoRebirth and wait() do
        pcall(function()
            for i,v in pairs(game:GetService("Workspace").Tycoons[str(team)].Buttons:GetDescendants()) do
                if game:GetService("Workspace").Tycoons[str(team)].Buttons.Rebirth then
                    rSkips = str(game:GetService("Workspace").Tycoons[str(team)].Buttons.Rebirth.Button.BillboardGui.Product.text:gsub("Rebirth ", ""))
                    rSkips = str(rSkips:gsub(" time%(s%)", ""))
                    print(rSkips)
                    if int(rSkips) >= int(rebirthSkips) then
                        wait(5)
                        firetouchinterest(game:GetService("Workspace").Tycoons[str(team)].Buttons.Rebirth:FindFirstChildOfClass("Part"))
                        wait(0.1)
                        for i,v in pairs(getconnections(game:GetService("Players").LocalPlayer.PlayerGui.GameGUI["Rebirth now?"].YesNo.Yes.MouseButton1Click)) do
                            v.Function()
                        end
                    end
                end
            end
        end)
	end
end})

Tab:AddSlider({
	Name = "How many times do you want to rebirth",
	Min = 0,
	Max = 25,
	Default = 5,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "Rebirth(s)",
	Callback = function(Value)
		rebirthSkips = int(Value)
	end    
})

local Section = Tab:AddSection({
	Name = "Other"
})

Tab:AddToggle({
	Name = "Auto Parkour",
	Default = false,
	Flag = "parkour",
	Callback = function(Value)
    getgenv().parkour = Value;

    while getgenv().parkour and wait() do
        pcall(function()
            for i,v in pairs(game:GetService("Workspace").Obbies:GetDescendants()) do
                if v:IsA("TouchTransmitter") and v.Name == "TouchInterest" and v.Parent.Name == "Win" then
                    firetouchinterest(v.Parent)
                    wait(0.25)
                end
            end
        end)
    end
end})

local Tab2 = Window:MakeTab({
	Name = "Information",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab2:AddSection({
	Name = "Stats"
})

-- Example (Team: "Orange Gum")
local teamParagraph = Tab2:AddParagraph("Team",str(team))

-- Example (Money: e.x "69")
local moneyParagraph = Tab2:AddParagraph("Money",str(money))

-- Example (Rebirths: e.x "420")
local rebirthsParagraph = Tab2:AddParagraph("Rebirths",str(rebirths))

-- Example (Rebirth Tokens: e.x "42069")
local rTokensParagraph = Tab2:AddParagraph("Rebirth Tokens",str(rTokens))

--[[Reload Stats
coroutine.wrap(function()
    while wait(1) do
        teamParagraph:Set("Team",str(team))
        moneyParagraph:Set("Money",str(money))
        rebirthsParagraph:Set("Rebirths",str(rebirths))
        rTokensParagraph:Set("Rebirth Tokens",str(rTokens))
    end
end)()
]]

--[[
local Tab3 = Window:MakeTab({
	Name = "Test",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab3:AddSection({
	Name = "Test"
})
]]

OrionLib:Init()
