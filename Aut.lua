if game.PlaceId == 5130598377 then

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "lava ware",
    LoadingTitle = "welcome to lava ware",
    LoadingSubtitle = "by preet",
    Theme = "DarkBlue",
    ToggleUIKeybind = "K",
})

local MainTab = Window:CreateTab("Home", 4483362458)

local npcList = {}
local bossList = {}

local selectedNPC = nil
local selectedBoss = nil

for _, npc in pairs(workspace.Live:GetChildren()) do
    table.insert(npcList, npc.Name)
end

for _, npc in pairs(workspace.Live:GetChildren()) do
    if npc.Name:match("Boss") then
        table.insert(bossList, npc.Name)
    end
end

local function unique(tbl)
    local hash = {}
    local res = {}
    for _,v in ipairs(tbl) do
        if not hash[v] then
            res[#res+1] = v
            hash[v] = true
        end
    end
    return res
end

npcList = unique(npcList)
bossList = unique(bossList)

local npcDropdown = MainTab:CreateDropdown({
    Name = "Select NPC to Farm",
    Options = npcList,
    CurrentOption = npcList[1],
    Callback = function(option)
        selectedNPC = option
    end,
})

local bossDropdown = MainTab:CreateDropdown({
    Name = "Select Boss to Farm",
    Options = bossList,
    CurrentOption = bossList[1],
    Callback = function(option)
        selectedBoss = option
    end,
})

local player = game.Players.LocalPlayer

local function teleportTo(targetPos)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos) + Vector3.new(0, 3, 0)
end

MainTab:CreateToggle({
    Name = "Auto Farm NPC (with Teleport)",
    CurrentValue = false,
    Callback = function(state)
        _G.FarmingNPC = state
        if state and selectedNPC then
            spawn(function()
                while _G.FarmingNPC do
                    local npc = nil
                    for _, v in pairs(workspace.Live:GetChildren()) do
                        if v.Name == selectedNPC and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            npc = v
                            break
                        end
                    end
                    if npc and npc:FindFirstChild("HumanoidRootPart") then
                        teleportTo(npc.HumanoidRootPart.Position)
                        game:GetService("ReplicatedStorage").Combat:FireServer(npc, "m1", 1)
                    end
                    task.wait(0.5)
                end
            end)
        end
    end,
})

MainTab:CreateToggle({
    Name = "Auto Farm Boss (with Teleport & Auto Spawn)",
    CurrentValue = false,
    Callback = function(state)
        _G.FarmingBoss = state
        local spawnBossRemote = game:GetService("ReplicatedStorage"):FindFirstChild("SpawnBoss")
        if state and selectedBoss and spawnBossRemote then
            spawn(function()
                while _G.FarmingBoss do
                    local boss = nil
                    for _, npc in pairs(workspace.Live:GetChildren()) do
                        if npc.Name == selectedBoss and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                            boss = npc
                            break
                        end
                    end
                    if not boss then
                        spawnBossRemote:FireServer(selectedBoss)
                    else
                        if boss:FindFirstChild("HumanoidRootPart") then
                            teleportTo(boss.HumanoidRootPart.Position)
                        end
                        game:GetService("ReplicatedStorage").Combat:FireServer(boss, "m1", 1)
                    end
                    task.wait(0.5)
                end
            end)
        end
    end,
})

MainTab:CreateToggle({
    Name = "Auto Complete Quest",
    CurrentValue = false,
    Callback = function(state)
        _G.AutoQuest = state
        local CompleteQuestRemote = game:GetService("ReplicatedStorage"):FindFirstChild("CompleteQuest")
        if not CompleteQuestRemote then
            Rayfield:Notify({
                Title = "Auto Quest",
                Content = "CompleteQuest remote not found!",
                Duration = 5,
                Image = 0,
            })
            return
        end
        if state then
            spawn(function()
                while _G.AutoQuest do
                    CompleteQuestRemote:FireServer("QuestName")
                    task.wait(5)
                end
            end)
        end
    end,
})

MainTab:CreateToggle({
    Name = "Auto Roll Mythical, Unusual & Legendary Skins",
    CurrentValue = false,
    Callback = function(state)
        _G.AutoRollSkins = state
        local rollRemote = game:GetService("ReplicatedStorage"):FindFirstChild("RollSkin")
        if not rollRemote then
            Rayfield:Notify({
                Title = "Auto Roll Skins",
                Content = "RollSkin remote not found!",
                Duration = 5,
                Image = 0,
            })
            return
        end
        if state then
            spawn(function()
                while _G.AutoRollSkins do
                    rollRemote:FireServer("Mythical")
                    task.wait(1)
                    rollRemote:FireServer("Unusual")
                    task.wait(1)
                    rollRemote:FireServer("Legendary")
                    task.wait(1)
                end
            end)
        end
    end,
})

end
