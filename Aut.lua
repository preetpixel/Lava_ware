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
    local FarmTab = Window:CreateTab("Farming", 4483362458)
    local TeleportTab = Window:CreateTab("Teleport", 4483362458)
    local StorageTab = Window:CreateTab("Storage", 4483362458)
    local SellTab = Window:CreateTab("Auto Sell", 4483362458)
    local QuestTab = Window:CreateTab("Quest", 4483362458)
    local PlayerTab = Window:CreateTab("Player", 4483362458)

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local CombatRemote = ReplicatedStorage:WaitForChild("Combat")
    local spawnBossRemote = ReplicatedStorage:FindFirstChild("SpawnBoss")
    local takeQuestRemote = ReplicatedStorage:FindFirstChild("TakeQuest")
    local completeQuestRemote = ReplicatedStorage:FindFirstChild("CompleteQuest")
    local sellItemRemote = ReplicatedStorage:FindFirstChild("SellItem")
    local storeItemRemote = ReplicatedStorage:FindFirstChild("StoreItem")

    local player = game.Players.LocalPlayer

    local npcList = {}
    local bossList = {}

    local function unique(tbl)
        local hash = {}
        local res = {}
        for _, v in ipairs(tbl) do
            if not hash[v] then
                res[#res + 1] = v
                hash[v] = true
            end
        end
        return res
    end

    for _, npc in pairs(workspace.Live:GetChildren()) do
        table.insert(npcList, npc.Name)
        if npc.Name:match("Boss") then
            table.insert(bossList, npc.Name)
        end
    end

    npcList = unique(npcList)
    bossList = unique(bossList)

    local selectedNPC = npcList[1]
    local selectedBoss = bossList[1]
    local selectedQuest = nil
    local selectedStorageItem = nil
    local selectedSellException = nil
    local selectedTeleport = nil

    local islandPositions = {
        ["Middle Island"] = Vector3.new(20, 10, 20),
        ["West Island"] = Vector3.new(-300, 15, 100),
        ["East Island"] = Vector3.new(350, 20, -50),
        ["South Island"] = Vector3.new(0, 5, -400),
        ["North Island"] = Vector3.new(0, 30, 400),
    }

    local allQuests = {
        "Standless Questline",
        "Umbra Questline",
        "Yasuo & Yone Questline",
        "Sol & Nocturnus Questline",
        "The Way to Heaven Questline",
        "Killua Questline",
        "Star Platinum: The World Questline",
        "Dawn Questline",
        "D4C: Love Train Questline",
        "Brickbattle Questline",
        "Reaper Questline",
        "Base Hamon Questline",
        "Hamon Informants Questline",
        "Joseph Hamon Questline",
        "Jonathan Hamon Questline",
        "Shadow Questline",
        "Shadow Quest Finale NPC",
        "Hito Hito No Mi Questline",
        "Gomu Gomu No Mi Questline",
        "Ope Ope No Mi Questline",
        "Gryphon Questline",
        "Gomu Gomu Gear 2 Questline",
        "Suna Suna No Mi Finale Questline",
        "Tusk Act 1 Questline",
        "Tusk Act 2 Questline",
        "Tusk Act 4 Questline",
        "The Strongest Questline",
        "The Mercenaries Questline",
        "Santa Claus Questline",
        "Skeleton Questline",
        "Sorcerers and Curses Questline",
        "Stand User Questline",
        "StuckDucks Questline",
        "Sword Disciple Questline",
        "The Sovereign Questline",
        "The Umbra Questline",
        "Thug Questline",
        "Umbra Clone Questline",
        "Valcure Questline",
        "Vampire Questline",
        "Werewolf Questline",
        "Z4 Questline",
        "Zombie Questline",
        "Zoro Questline",
        "Shadows Demands Questline",
        "Sakuya Questline",
        "Godspeed Questline",
        "Same Type Of Stand Questline",
        "C-Moon Questline",
        "Made In Heaven Questline",
        "The World Over Heaven Questline",
        "Nostalgic Belongings Questline",
        "Dark Side of Dawn Questline",
        "Power of the Saints Corpse Questline",
        "Master of Swords Questline",
        "Remnants of The Mercenaries Questline",
    }

    local allItems = {
        "Sukuna Finger",
        "Mythical Sword",
        "Legendary Shield",
        "Healing Potion",
        "Rare Mount",
        "Skill Crystal",
    }

    local function teleportTo(pos)
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        player.Character.HumanoidRootPart.CFrame = CFrame.new(pos) + Vector3.new(0, 3, 0)
    end

    FarmTab:CreateDropdown({
        Name = "Select NPC to Farm",
        Options = npcList,
        CurrentOption = selectedNPC,
        Callback = function(option)
            selectedNPC = option
        end,
    })

    FarmTab:CreateDropdown({
        Name = "Select Boss to Farm",
        Options = bossList,
        CurrentOption = selectedBoss,
        Callback = function(option)
            selectedBoss = option
        end,
    })

    QuestTab:CreateDropdown({
        Name = "Select Quest",
        Options = allQuests,
        CurrentOption = allQuests[1],
        Callback = function(option)
            selectedQuest = option
        end,
    })

    StorageTab:CreateDropdown({
        Name = "Select Item to Store Automatically",
        Options = allItems,
        CurrentOption = allItems[1],
        Callback = function(option)
            selectedStorageItem = option
        end,
    })

    SellTab:CreateDropdown({
        Name = "Select Item NOT to Sell",
        Options = allItems,
        CurrentOption = allItems[1],
        Callback = function(option)
            selectedSellException = option
        end,
    })

    TeleportTab:CreateDropdown({
        Name = "Select Island to Teleport",
        Options = (function()
            local keys = {}
            for k in pairs(islandPositions) do table.insert(keys, k) end
            return keys
        end)(),
        CurrentOption = (function()
            local keys = {}
            for k in pairs(islandPositions) do table.insert(keys, k) end
            return keys[1]
        end)(),
        Callback = function(option)
            selectedTeleport = option
            teleportTo(islandPositions[option])
        end,
    })

    FarmTab:CreateToggle({
        Name = "One-Shot Damage",
        CurrentValue = false,
        Callback = function(state)
            _G.OneShotNPC = state
        end,
    })

    FarmTab:CreateToggle({
        Name = "Auto Farm NPC (with Teleport)",
        CurrentValue = false,
        Callback = function(state)
            _G.FarmingNPC = state
            if state and selectedNPC then
                spawn(function()
                    while _G.FarmingNPC do
                        local npcObj = nil
                        for _, npc in pairs(workspace.Live:GetChildren()) do
                            if npc.Name == selectedNPC then
                                npcObj = npc
                                break
                            end
                        end
                        if npcObj and npcObj:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            player.Character.HumanoidRootPart.CFrame = npcObj.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                            if _G.OneShotNPC then
                                CombatRemote:FireServer("Damage", npcObj, math.huge)
                            else
                                CombatRemote:FireServer("Damage", npcObj)
                            end
                        end
                        wait(0.3)
                    end
                end)
            end
        end,
    })

    FarmTab:CreateToggle({
        Name = "Auto Farm Boss (with Teleport)",
        CurrentValue = false,
        Callback = function(state)
            _G.FarmingBoss = state
            if state and selectedBoss then
                spawn(function()
                    while _G.FarmingBoss do
                        local bossObj = nil
                        for _, boss in pairs(workspace.Live:GetChildren()) do
                            if boss.Name == selectedBoss then
                                bossObj = boss
                                break
                            end
                        end
                        if bossObj and bossObj:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            player.Character.HumanoidRootPart.CFrame = bossObj.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                            CombatRemote:FireServer("Damage", bossObj)
                        end
                        wait(0.3)
                    end
                end)
            end
        end,
    })

    FarmTab:CreateToggle({
        Name = "Auto Farm Boundless Tower",
        CurrentValue = false,
        Callback = function(state)
            _G.FarmingBoundless = state
            if state then
                spawn(function()
                    while _G.FarmingBoundless do
                        -- Assuming Boundless Tower NPC is named "Boundless Tower"
                        local boundlessNPC = nil
                        for _, npc in pairs(workspace.Live:GetChildren()) do
                            if npc.Name == "Boundless Tower" then
                                boundlessNPC = npc
                                break
                            end
                        end
                        if boundlessNPC and boundlessNPC:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            player.Character.HumanoidRootPart.CFrame = boundlessNPC.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                            CombatRemote:FireServer("Damage", boundlessNPC)
                        end
                        wait(0.3)
                    end
                end)
            end
        end,
    })

    QuestTab:CreateButton({
        Name = "Take Quest",
        Callback = function()
            if selectedQuest and takeQuestRemote then
                takeQuestRemote:FireServer(selectedQuest)
            end
        end,
    })

    QuestTab:CreateButton({
        Name = "Complete Quest",
        Callback = function()
            if selectedQuest and completeQuestRemote then
                completeQuestRemote:FireServer(selectedQuest)
            end
        end,
    })

    StorageTab:CreateButton({
        Name = "Store Item",
        Callback = function()
            if selectedStorageItem and storeItemRemote then
                storeItemRemote:FireServer(selectedStorageItem)
            end
        end,
    })

    SellTab:CreateToggle({
        Name = "Auto Sell",
        CurrentValue = false,
        Callback = function(state)
            _G.AutoSell = state
            spawn(function()
                while _G.AutoSell do
                    local backpack = player.Backpack
                    for _, item in pairs(backpack:GetChildren()) do
                        if item:IsA("Tool") and item.Name ~= selectedSellException then
                            if sellItemRemote then
                                sellItemRemote:FireServer(item.Name)
                            end
                        end
                    end
                    wait(1)
                end
            end)
        end,
    })

    -- God Mode Toggle
    local humanoid = nil
    local godModeEnabled = false

    local function enableGodMode()
        if humanoid then
            humanoid.MaxHealth = math.huge
            humanoid.Health = humanoid.MaxHealth
            humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if godModeEnabled and humanoid.Health < humanoid.MaxHealth then
                    humanoid.Health = humanoid.MaxHealth
                end
            end)
        end
    end

    local function disableGodMode()
        if humanoid then
            humanoid.MaxHealth = 100
            humanoid.Health = 100
        end
    end

    local function setupHumanoid()
        local char = player.Character or player.CharacterAdded:Wait()
        humanoid = char:WaitForChild("Humanoid")
        if godModeEnabled then
            enableGodMode()
        end
    end

    player.CharacterAdded:Connect(function()
        wait(1)
        setupHumanoid()
    end)

    setupHumanoid()

    PlayerTab:CreateToggle({
        Name = "God Mode",
        CurrentValue = false,
        Callback = function(state)
            godModeEnabled = state
            if state then
                enableGodMode()
            else
                disableGodMode()
            end
        end,
    })

end
