-- https://www.roblox.com/games/109686116036889/DANGEROUS-NIGHT-FURNISH-THE-BUNKER
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/RexxHayanasi/RexxHayanasilibv1/refs/heads/main/Source.lua"))()

local m = lib:Window("Main")
local t = lib:Window("Teleport")
local s = lib:Window("Settings")

local players = game:GetService("Players")
local plr = players.LocalPlayer
local bunkerName = plr:GetAttribute("AssignedBunkerName")

m:Toggle("Noclip", false, function (b)
    getgenv().noclip = b
    if noclip then
        local function NoclipLoop()
            if plr.Character ~= nil then
                for _, child in pairs(plr.Character:GetDescendants()) do
                    if child:IsA("BasePart") and child.CanCollide == true then
                        child.CanCollide = false
                    end
                end
            end
        end
        Noclipping = game:GetService("RunService").Stepped:Connect(NoclipLoop)
    else
        if Noclipping then
            Noclipping:Disconnect()
            Noclipping = nil
        end
    end
end)
m:Box("WalkSpeed", function (ws)
    if tonumber(ws) then
        plr.Character:FindFirstChild("Humanoid").WalkSpeed = tonumber(ws)
    end
end)
local lastPos = nil
m:Button("Collect All Food", function ()
    lastPos = plr.Character:FindFirstChild("HumanoidRootPart").CFrame
    for _, food in pairs(game:GetService("Workspace"):GetChildren()) do
        if food:IsA("Tool") then
            local handle = food:FindFirstChild("Handle")
            local prompt = handle:FindFirstChildOfClass("ProximityPrompt")
            if handle and prompt then
                plr.Character:FindFirstChild("HumanoidRootPart").CFrame = handle.CFrame * CFrame.new(0,5,0)
                task.wait(.25)
                fireproximityprompt(prompt, prompt.MaxActivationDistance)
            end
        end
    end
    task.wait(.25)
    plr.Character:FindFirstChild("HumanoidRootPart").CFrame = lastPos
end)
m:Button("Drop All Food", function ()
    lastPos = plr.Character:FindFirstChild("HumanoidRootPart").CFrame
    for _, food in pairs(plr.Backpack:GetChildren()) do
        food.Parent = plr.Character
    end
    task.wait(.25)
    plr.Character:FindFirstChildOfClass("Humanoid").Health = 0

    task.spawn(function()
        local function onCharacterAdded(char)
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if hrp and lastPos then
                task.wait(0.5)
                hrp.CFrame = lastPos
            end
        end

        if not plr.Character or plr.Character:FindFirstChildOfClass("Humanoid").Health == 0 then
            plr.CharacterAdded:Wait()
            onCharacterAdded(plr.Character)
        end
    end)
end)
-- thx to moligrafi - https://rscripts.net/script/bring-items-and-bring-food-o7rP
local selected = nil
local function ReturnFurniture()
  local Names = {}
  
  for _, item in pairs(workspace.Wyposazenie:GetChildren()) do
    if item:IsA("Folder") then
      for _, interno in pairs(item:GetChildren()) do
        if interno:IsA("Model") and not table.find(Names, interno.Name) then
          table.insert(Names, interno.Name)
        end
      end
    elseif item:IsA("Model") and not table.find(Names, item.Name) then
      table.insert(Names, item.Name)
    end
  end
  
  return Names
end
local function GetFurniture()
  for _, furniture in pairs(workspace.Wyposazenie:GetChildren()) do
    if furniture:IsA("Folder") then
      for _, interno in pairs(furniture:GetChildren()) do
        if interno:IsA("Model") and interno.Name == selected then
          game:GetService("ReplicatedStorage").PickupItemEvent:FireServer(interno)
          return true
        end
      end
    elseif furniture:IsA("Model") and furniture.Name == selected then
      game:GetService("ReplicatedStorage").PickupItemEvent:FireServer(furniture)
      return true
    end
  end
  
  return false
end
m:Dropdown("Selected Furniture", ReturnFurniture(), function(option)
    selected = option
end)
m:Button("Bring Selected Furniture", function ()
    if selected ~= nil then
        GetFurniture()
    end
end)
m:Toggle("Sound Spam", false, function (b)
    getgenv().sound_spam = b
    task.spawn(function ()
        while sound_spam do
            game:GetService("ReplicatedStorage"):WaitForChild("SoundEvent"):FireServer("Drink")
            game:GetService("ReplicatedStorage"):WaitForChild("SoundEvent"):FireServer("Eat")
            task.wait()
        end
    end)
end)
local lurkerNight
m:Toggle("Monsters ESP", false, function (b)
    getgenv().lurker_esp = b

    local function findNightFolder()
        for _, obj in pairs(game:GetService("Workspace"):GetChildren()) do
            if obj:IsA("Folder") and string.find(obj.Name, "Night") then
                return obj
            end
        end
        return nil
    end

    if lurker_esp then
        task.spawn(function ()
            while lurker_esp do
                local nightFolder = findNightFolder()
                if nightFolder then
                    for _, lurker in pairs(nightFolder:GetChildren()) do
                        if lurker:IsA("Model") and lurker:FindFirstChild("HumanoidRootPart") then
                            local highlight = lurker:FindFirstChild("Highlight")
                            if not highlight then
                                highlight = Instance.new("Highlight")
                                highlight.Name = "Highlight"
                                highlight.Parent = lurker
                            end
                        end
                    end
                else
                    repeat task.wait() until findNightFolder() ~= nil or not lurker_esp
                end
                task.wait(1)
            end
        end)
    else
        local nightFolder = findNightFolder()
        if nightFolder then
            for _, lurker in pairs(nightFolder:GetChildren()) do
                if lurker:IsA("Model") and lurker:FindFirstChild("HumanoidRootPart") then
                    local highlight = lurker:FindFirstChild("Highlight")
                    if highlight then
                        highlight:Destroy()
                    end
                end
            end
        end
    end
end)

t:Button("to Bunker", function ()
    plr.Character:FindFirstChild("HumanoidRootPart").CFrame = game:GetService("Workspace"):FindFirstChild("Bunkers")[bunkerName]:FindFirstChild("SpawnLocation").CFrame
end)
t:Button("to Market", function ()
    plr.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(143, 5, -118)
end)
t:Box("to Player", function (name, focuslost)
    if focuslost then
        local lowerName = name:lower()
        for _, player in pairs(players:GetPlayers()) do
            if string.find(player.Name:lower(), lowerName) or string.find(player.DisplayName:lower(), lowerName) then
                plr.Character:FindFirstChild("HumanoidRootPart").CFrame = player.Character:FindFirstChild("HumanoidRootPart").CFrame
                return
            end
        end
    end
end)

s:Label("Press LeftControl to Hide UI", Color3.fromRGB(127, 143, 166))
s:Label("~ t.me/arceusxscripts", Color3.fromRGB(127, 143, 166))
s:Button("Destroy Gui", function ()
	lib:Destroy()
end)
lib:Keybind("LeftControl")
