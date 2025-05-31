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

    -- ReplicatedStorage shortcuts
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local CombatRemote = ReplicatedStorage:WaitForChild("Combat")
    local spawnBossRemote = ReplicatedStorage:FindFirstChild("SpawnBoss")
    local takeQuestRemote = ReplicatedStorage:FindFirstChild("TakeQuest")
    local completeQuestRemote = ReplicatedStorage:FindFirstChild("CompleteQuest")
    local sellItemRemote = ReplicatedStorage:FindFirstChild("SellItem")
    local storeItemRemote = ReplicatedStorage:FindFirstChild("StoreItem")

    local player = game.Players.LocalPlayer

    -- NPC & Boss lists
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

    -- Selected variables
    local selectedNPC = npcList[1]
    local selectedBoss = bossList[1]
    local selectedQuest = nil
    local selectedStorageItem = nil
    local selectedSellException = nil
    local selectedTeleport = nil

    -- Teleport locations (islands only)
    local islandPositions = {
        ["Middle Island"] = Vector3.new(20, 10, 20),
        ["West Island"] = Vector3.new(-300, 15, 100),
        ["East Island"] = Vector3.new(350, 20, -50),
        ["South Island"] = Vector3.new(0, 5, -400),
        ["North Island"] = Vector3.new(0, 30, 400),
        -- Add more known island positions here
    }

    -- Quests list (example subset, expand as needed)
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
        -- add all other quests as needed
    }

    -- Items list (example, expand with full list)
    local allItems = {
        "Sukuna Finger",
        "Mythical Sword",
        "Legendary Shield",
        "Healing Potion",
        "Rare Mount",
        "Skill Crystal",
        -- add all known items here
    }

    -- Teleport function
    local function teleportTo(pos)
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        player.Character.HumanoidRootPart.CFrame = CFrame.new(pos) + Vector3.new(0, 3, 0)
    end

    -- UI Elements

    -- NPC Dropdown
    FarmTab:CreateDropdown({
        Name = "Select NPC to Farm",
        Options = npcList,
        CurrentOption = selectedNPC,
        Callback = function(option)
            selectedNPC = option
        end,
    })

    -- Boss Dropdown
    FarmTab:CreateDropdown({
        Name = "Select Boss to Farm",
        Options = bossList,
        CurrentOption = selectedBoss,
        Callback = function(option)
            selectedBoss = option
        end,
    })

    -- Quest Dropdown
    QuestTab:CreateDropdown({
        Name = "Select Quest",
        Options = allQuests,
        CurrentOption = allQuests[1],
        Callback = function(option)
            selectedQuest = option
        end,
    })

    -- Storage item dropdown
    StorageTab:CreateDropdown({
        Name = "Select Item to Store Automatically",
        Options = allItems,
        CurrentOption = allItems[1],
        Callback = function(option)
            selectedStorageItem = option
        end,
    })

    -- Auto Sell exception dropdown (items not to sell)
    SellTab:CreateDropdown({
        Name = "Select Item NOT to Sell",
        Options = allItems,
        CurrentOption = allItems[1],
        Callback = function(option)
            selectedSellException = option
        end,
    })

    -- Teleport dropdown (islands only)
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

    -- Toggles

    -- One-Shot Damage toggle (separate)
    FarmTab:CreateToggle({
        Name = "One-Shot Damage",
        CurrentValue = false,
        Callback = function(state)
            _G.OneShotNPC = state
        end,
    })

    -- Auto Farm NPC toggle
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
                            if npc.Name == selectedNPC and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                                npcObj = npc
                                break
                            end
                        end
                        if npcObj and npcObj:FindFirstChild("HumanoidRootPart") then
                            teleportTo(npcObj.HumanoidRootPart.Position)
                            local dmg = _G.OneShotNPC and 999999999999999999999999 or 1
                            pcall(function()
                                CombatRemote:FireServer(npcObj, "m1", dmg)
                            end)
                        end
                        task.wait(0.6)
                    end
                end)
            end
        end,
    })

    -- Auto Farm Boss toggle
    FarmTab:CreateToggle({
        Name = "Auto Farm Boss (with Teleport & Auto Spawn)",
        CurrentValue = false,
        Callback = function(state)
            _G.FarmingBoss = state
            if state and selectedBoss and spawnBossRemote then
                spawn(function()
                    while _G.FarmingBoss do
                        local bossObj = nil
                        for _, npc in pairs(workspace.Live:GetChildren()) do
                            if npc.Name == selectedBoss and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                                bossObj = npc
                                break
                            end
                        end
                        if not bossObj then
                            spawnBossRemote:FireServer(selectedBoss)
                        else
                            if bossObj:FindFirstChild("HumanoidRootPart") then
                                teleportTo(bossObj.HumanoidRootPart.Position)
                            end
                            local dmg = _G.OneShotNPC and 999999999999999999999999 or 1
                            pcall(function()
                                CombatRemote:FireServer(bossObj, "m1", dmg)
                            end)
                        end
                        task.wait(0.6)
                    end
                end)
            end
        end,
    })

    -- Auto Take & Complete Quests toggle
    QuestTab:CreateToggle({
        Name = "Auto Take & Complete Quests",
        CurrentValue = false,
        Callback = function(state)
            _G.AutoQuest = state
            if state and selectedQuest and takeQuestRemote and completeQuestRemote then
                spawn(function()
                    while _G.AutoQuest do
                        pcall(function()
                            takeQuestRemote:FireServer(selectedQuest)
                            completeQuestRemote:FireServer(selectedQuest)
                        end)
                        task.wait(5) -- Wait a bit longer to avoid spam
                    end
                end)
            end
        end,
    })

    -- Auto Store Item toggle
    StorageTab:CreateToggle({
        Name = "Auto Store Selected Item",
        CurrentValue = false,
        Callback = function(state)
            _G.AutoStore = state
            if state and selectedStorageItem and storeItemRemote then
                spawn(function()
                    while _G.AutoStore do
                        pcall(function()
                            storeItemRemote:FireServer(selectedStorageItem)
                        end)
                        task.wait(1)
                    end
                end)
            end
        end,
    })

    -- Auto Sell toggle
    SellTab:CreateToggle({
        Name = "Auto Sell Items (Except Selected Item)",
        CurrentValue = false,
        Callback = function(state)
            _G.AutoSell = state
            if state and sellItemRemote then
                spawn(function()
                    while _G.AutoSell do
                        -- Get player inventory here - example method, depends on game structure
                        -- This is a placeholder; adjust according to how inventory is stored
                        local backpack = player:FindFirstChild("Backpack")
                        if backpack then
                            for _, item in pairs(backpack:GetChildren()) do
                                if item.Name ~= selectedSellException then
                                    pcall(function()
                                        sellItemRemote:FireServer(item.Name)
                                    end)
                                end
                            end
                        end
                        task.wait(2)
                    end
                end)
            end
        end,
    })

end
