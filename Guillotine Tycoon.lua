local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

--//Variables--
local plot;
local str = tostring

local Window = OrionLib:MakeWindow({Name = "Gumball Factory Tycoon", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

local Tab = Window:MakeTab({
	Name = "Autofarm",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Autofarm"
})

Tab:AddDropdown({
	Name = "Choose your plot",
	Default = "1",
	Options = {"1", "2", "3", "4", "5"},
	Callback = function(Value)
		plot = "Plot"..Value
	end    
})

Tab:AddToggle({
	Name = "Auto Deposit",
	Default = false,
    Callback = function(Value)
    getgenv().autoDeposit = Value;
    
    while getgenv().autoDeposit and wait() do
        pcall(function()
            firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, game:GetService("Workspace").Plots[str(plot)].DepositStep, 0)
            firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, game:GetService("Workspace").Plots[str(plot)].DepositStep, 1)
            wait(.01)
        end)
    end
end})

Tab:AddToggle({
    Name = "Auto Collect",
    Default = false,
    Callback = function(Value)
    getgenv().autoCollect = Value;

    while getgenv().autoCollect and wait() do
        pcall(function()
            game:GetService("Workspace").Plots[str(plot)].Heads.Head.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            wait(0.001)
        end)
    end
end})

Tab:AddToggle({
    Name = "Auto Compact",
    Default = false,
    Callback = function(Value)
    getgenv().autoCompact = Value;

    while getgenv().autoCompact and wait() do
        pcall(function()
            game:GetService("ReplicatedStorage").GoldenGuillotine:FireServer()
            wait(1)
        end)
    end  
end})

Tab:AddToggle({
    Name = "Auto Collect Prize",
    Default = false,
    Callback = function(Value)
    getgenv().autoPrize = Value;

    while getgenv().autoPrize and wait() do
        pcall(function()
            firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, game:GetService("Workspace").Plots[str(plot)].SuperPrize.TouchPart, 0)
            firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, game:GetService("Workspace").Plots[str(plot)].SuperPrize.TouchPart, 1)
            wait(.01)
        end)
    end  
end})

Tab:AddButton({
	Name = "Destroy Popups",
	Callback = function()
        game:GetService("Players").LocalPlayer.PlayerGui.PopupAlerts:Destroy()
  	end    
})

--

local Tab = Window:MakeTab({
	Name = "Upgrade",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Upgrades"
})

Tab:AddToggle({
	Name = "Upgrade tick (+1)",
	Default = false,
    Callback = function(Value)
    getgenv().autoTick = Value;
    
    while getgenv().autoTick and wait() do
        pcall(function()
            firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, game:GetService("Workspace").Plots[str(plot)].IncreaseTick, 0)
            firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, game:GetService("Workspace").Plots[str(plot)].IncreaseTick, 1)
            wait(.01)
        end)
    end
end})

Tab:AddToggle({
	Name = "Upgrade Guillotine",
	Default = false,
    Callback = function(Value)
    getgenv().autoGuillotine = Value;
    
    while getgenv().autoGuillotine and wait() do
        pcall(function()
            firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, game:GetService("Workspace").Plots[str(plot)].PurchaseButton, 0)
            firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, game:GetService("Workspace").Plots[str(plot)].PurchaseButton, 1)
            wait(.01)
        end)
    end
end})
