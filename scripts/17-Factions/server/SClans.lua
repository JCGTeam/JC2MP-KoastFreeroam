class "ClanSystem"

msgColors = {
    ["err"] = Color.DarkGray,
    ["info"] = Color(0, 255, 0),
    ["warn"] = Color(185, 215, 255)
}

function ClanSystem:__init()
    self.getclantag = ""

    self.LastTick = 0
    self.playerList = {}
    self.clans = {}
    self.clanMembers = {}
    self.playerClan = {}
    self.steamIDToPlayer = {}
    self.invitations = {}
    self.clanMessages = {}
    self.permissions = {
        ["Основатель"] = {
            kick = true,
            invite = true,
            motd = true,
            setRank = true,
            changeSettings = true,
            delete = true,
            clearLog = true
        },
        ["Главный"] = {
            kick = true,
            invite = true,
            motd = true,
            setRank = true,
            changeSettings = true,
            delete = false,
            clearLog = true
        },
        ["Заместитель"] = {
            kick = true,
            invite = true,
            motd = true,
            setRank = false,
            changeSettings = false,
            delete = false,
            clearLog = false
        },
        ["Редактор"] = {
            kick = false,
            invite = true,
            motd = true,
            setRank = false,
            changeSettings = false,
            delete = false,
            clearLog = false
        },
        ["Участник"] = {
            kick = false,
            invite = true,
            motd = false,
            setRank = false,
            changeSettings = false,
            delete = false,
            clearLog = false
        }
    }

    for player in Server:GetPlayers() do
        self.steamIDToPlayer[player:GetSteamId().id] = player
    end

    Network:Subscribe("Clans:Create", self, self.AddClan)
    Network:Subscribe("Clans:Remove", self, self.RemoveClan)
    Network:Subscribe("Clans:GetData", self, self.GetData)
    Network:Subscribe("Clans:Leave", self, self.LeaveClan)
    Network:Subscribe("Clans:Invite", self, self.InvitePlayer)
    Network:Subscribe("Clans:Invitations", self, self.GetInvitations)
    Network:Subscribe("Clans:AcceptInvite", self, self.AcceptInvite)
    Network:Subscribe("Clans:GetClans", self, self.GetClans)
    Network:Subscribe("Clans:JoinClan", self, self.JoinClan)
    Network:Subscribe("Clans:Kick", self, self.KickPlayer)
    Network:Subscribe("Clans:SetRank", self, self.SetPlayerRank)
    Network:Subscribe("Clans:RequestSyncList", self, self.SendPlayerList)
    Network:Subscribe("Clans:UpdateClanSettings", self, self.UpdateClanSettings)
    Network:Subscribe("Clans:UpdateClanNews", self, self.UpdateClanNews)
    Network:Subscribe("Clans:ClearLog", self, self.ClearLog)
    Events:Subscribe("PlayerChat", self, self.FactionChat)
    Events:Subscribe("PostTick", self, self.SyncPlayers)
    Events:Subscribe("PlayerJoin", self, self.PlayerJoin)
    Events:Subscribe("PlayerQuit", self, self.PlayerQuit)

    SQL:Execute("CREATE TABLE IF NOT EXISTS clans ( name VARCHAR UNIQUE, steamID VARCHAR, creator VARCHAR, description VARCHAR, colour VARCHAR, creationDate VARCHAR, type VARCHAR, clannews VARCHAR )")
    SQL:Execute("CREATE TABLE IF NOT EXISTS clan_members ( steamID VARCHAR UNIQUE, clan VARCHAR, name VARCHAR, rank VARCHAR, joinDate VARCHAR )")
    SQL:Execute("CREATE TABLE IF NOT EXISTS clan_messages ( clan VARCHAR, type VARCHAR, message VARCHAR, date VARCHAR )")

    local query = SQL:Query("SELECT * FROM clans")
    local result = query:Execute()
    if (#result > 0) then
        for _, clan in ipairs(result) do
            self.clans[clan.name] = {
                name = clan.name,
                steamID = clan.steamID,
                creator = clan.creator,
                description = clan.description,
                colour = clan.colour,
                creationDate = clan.creationDate,
                type = clan.type,
                clannews = clan.clannews
            }
            self.clanMembers[clan.name] = {}
            self.clanMessages[clan.name] = {}
        end
    end
    print(tostring(#result) .. " faction(s) loaded!")

    local query = SQL:Query("SELECT * FROM clan_members")
    local result = query:Execute()
    if (#result > 0) then
        for _, member in ipairs(result) do
            if (self.clanMembers[member.clan]) then
                table.insert(self.clanMembers[member.clan], {
                    steamID = member.steamID,
                    clan = member.clan,
                    name = member.name,
                    rank = member.rank,
                    joinDate = member.joinDate
                })
                self.playerClan[member.steamID] = {member.clan, #self.clanMembers[member.clan]}
            end
        end
    end
    print(tostring(#result) .. " faction member(s) loaded!")

    local query = SQL:Query("SELECT * FROM clan_messages")
    local result = query:Execute()
    if (#result > 0) then
        for _, msg in ipairs(result) do
            if (self.clanMessages[msg.clan]) then
                table.insert(self.clanMessages[msg.clan], {
                    clan = msg.clan,
                    type = msg.type,
                    message = msg.message,
                    date = msg.date
                })
            end
        end
    end
    print(tostring(#result) .. " faction message(s) loaded!")
end

function ClanSystem:PlayerJoin(args)
    local clan = self:GetPlayerClan(args.player)

    if clan then
        local steamId = args.player:GetSteamId().id
        local memberRank = self:GetMemberData({steamID = steamId, data = "rank"})

        if memberRank then
            if memberRank == "Основатель" then
                local transaction = SQL:Transaction()
                local query = SQL:Command("UPDATE clans SET steamID = ?, creator = ? WHERE name = (?)")
                query:Bind(1, steamId)
                query:Bind(2, args.player:GetName())
                query:Bind(3, clan)
                query:Execute()
                transaction:Commit()
            end
        end
    end
end

function ClanSystem:PlayerQuit(args)
    self.playerList[args.player:GetId()] = nil
end

function ClanSystem:SendPlayerList(player)
    if IsValid(player) then
        Network:Send(player, "Clans:SyncPlayers", self.playerList)
    end
end

function ClanSystem:SyncPlayers()
    if Server:GetElapsedSeconds() - self.LastTick >= 4 then
        local playerList = self.playerList
        local clans = self.clans

        for player in Server:GetPlayers() do
            local clan = self:GetPlayerClan(player)

            playerList[player:GetId()] = clan

            if clan then
                local colour = clans[clan].colour:split(",") or {255, 255, 255}
                local r, g, b = table.unpack(colour)
                local finalColor = Color(tonumber(r), tonumber(g), tonumber(b))

                if player:GetValue("ClanColor") ~= finalColor then
                    player:SetNetworkValue("ClanColor", finalColor)
                end
            end

            if player:GetValue("ClanTag") ~= clan then
                player:SetNetworkValue("ClanTag", clan)
            end
        end

        self.LastTick = Server:GetElapsedSeconds()
    end
end

function ClanSystem:AddClan(args, player)
    local clan = self:GetPlayerClan(player)

    if clan then
        player:Message("Вы уже являетесь частью клана.", "err")
        return false
    end

    if not self:Exists(args.name) then
        local money = player:GetMoney()

        if money >= Prices.CreateClan then
            player:SetMoney(money - Prices.CreateClan)
        else
            player:Message("Требуется $" .. formatNumber(Prices.CreateClan) .. ", чтобы создать клан.", "err")
            return false
        end

        local steamId = player:GetSteamId().id
        local theDate = os.date("%d/%m/%y %X")
        local newsdefault = "Поздравляем, клан успешно создан! Здесь будут отображаться новости для всех участников клана. Зайдите в настройки клана, чтобы изменить это сообщение."

        local cmd = SQL:Command("INSERT INTO clans ( name, steamID, creator, description, colour, creationDate, type, clannews ) VALUES ( ?, ?, ?, ?, ?, ?, ?, ? )")
        cmd:Bind(1, args.name)
        cmd:Bind(2, steamId)
        cmd:Bind(3, player:GetName())
        cmd:Bind(4, args.description)
        cmd:Bind(5, args.colour)
        cmd:Bind(6, theDate)
        cmd:Bind(7, args.type)
        cmd:Bind(8, newsdefault)
        cmd:Execute()

        self.clans[args.name] = {
            name = args.name,
            steamID = steamId,
            creator = player:GetName(),
            description = args.description,
            colour = args.colour,
            creationDate = theDate,
            type = args.type,
            clannews = newsdefault
        }

        self.clanMembers[args.name] = {}

        Chat:Broadcast("[Кланы] ", Color.White, player:GetName() .. " создал клан " .. tostring(args.name) .. "!", Color.DarkGray)
        player:Message("Вы создали клан!", "info")
        print(player:GetName() .. " created a clan " .. tostring(args.name) .. "!")
        Events:Fire("ToDiscordConsole", {text = player:GetName() .. " created a clan " .. tostring(args.name) .. "!"})
        self:AddMember({player = player, clan = args.name, rank = "Основатель"})
    else
        player:Message("Клан с таким названием уже существует!", "err")
    end
end

function ClanSystem:RemoveClan(_, player)
    local name = self:GetPlayerClan(player)

    if name then
        if self:IsPlayerAllowedTo({player = player, action = "delete"}) then
            if self:Exists(name) then
                local cmd = SQL:Command("DELETE FROM clans WHERE name = ( ? )")
                cmd:Bind(1, name)
                cmd:Execute()

                local cmd = SQL:Command("DELETE FROM clan_members WHERE clan = ( ? )")
                cmd:Bind(1, name)
                cmd:Execute()

                self.clans[name] = nil

                for _, member in ipairs(self.clanMembers[name]) do
                    self.playerClan[member.steamID] = nil
                end

                self.clanMembers[name] = nil
                player:Message("Вы удалили клан!", "warn")
                print(player:GetName() .. " removed clan " .. tostring(name) .. "!")
                Events:Fire("ToDiscordConsole", {text = player:GetName() .. " removed clan " .. tostring(name) .. "!"})
            else
                player:Message("Клан не существует.", "err")
            end
        else
            player:Message("Вы не можете использовать эту функцию.", "err")
        end
    else
        player:Message("Вы не в клане.", "err")
    end
end

function ClanSystem:AddMember(args)
    local steamId = args.player:GetSteamId().id
    local theDate = os.date("%d/%m/%y %X")

    local cmd = SQL:Command("INSERT INTO clan_members ( steamID, clan, name, rank, joinDate ) VALUES ( ?, ?, ?, ?, ? )")
    cmd:Bind(1, steamId)
    cmd:Bind(2, args.clan)
    cmd:Bind(3, args.player:GetName())
    cmd:Bind(4, args.rank)
    cmd:Bind(5, theDate)
    cmd:Execute()

    table.insert(self.clanMembers[args.clan], {
        steamID = steamId,
        clan = args.clan,
        name = args.player:GetName(),
        rank = args.rank,
        joinDate = theDate
    })

    self.playerClan[args.player:GetSteamId().id] = {args.clan, #self.clanMembers[args.clan]}
    args.player:Message("Вы добавлены в " .. tostring(args.clan) .. "!", "info")
    self:AddMessage(args.clan, "log", args.player:GetName() .. " присоединился к клану.")

    local clan = self:GetPlayerClan(args.player)
    if clan then
        local pName = args.player:GetName()
        local colour = (self.clans[clan].colour:split(",") or {255, 255, 255})
        local r, g, b = table.unpack(colour)

        for player in Server:GetPlayers() do
            local pClan = self:GetPlayerClan(player)

            if pClan and ( pClan == clan ) then
				player:SendChatMessage("[" .. tostring(clan) .. "] ", Color(tonumber(r), tonumber(g), tonumber(b)), tostring(pName), args.player:GetColor(), " присоеденился к клану", Color.White)
            end
        end
    end
end

function ClanSystem:RemoveMember(args)
    local cmd = SQL:Command("DELETE FROM clan_members WHERE clan = ( ? ) AND steamID = ( ? )")
    cmd:Bind(1, args.clan)
    cmd:Bind(2, args.steamID)
    cmd:Execute()

    local data = self.playerClan[args.steamID]
    if data then
        table.remove(self.clanMembers[args.clan], data[2])
    end

    self.playerClan[args.steamID] = nil
end

function ClanSystem:Exists(name)
    return (self.clans[name] and true or false)
end

function ClanSystem:GetPlayerClan(player)
    if type(player) == "userdata" then
        if self.playerClan[player:GetSteamId().id] then
            return self.playerClan[player:GetSteamId().id][1], self.playerClan[player:GetSteamId().id][2]
        else
            return false
        end
    else
        return false
    end
end

function ClanSystem:GetData(_, player)
    local clan = self:GetPlayerClan(player)

    if clan then
        local args = {}
        args.members = self.clanMembers[clan]
        args.clanData = self.clans[clan]
        args.messages = self.clanMessages[clan]
        args.newstext = self.clans[clan].clannews
        Network:Send(player, "Clans:ReceiveData", args)
    else
        player:Message("Вы не в клане!", "err")
    end
end

function ClanSystem:LeaveClan(_, player)
    local clan, index = self:GetPlayerClan(player)

    if clan and index then
        local steamID = player:GetSteamId().id
        local member = self.clanMembers[clan][index]

        if member then
            if member.steamID == steamID then
                if (member.rank ~= "Основатель") or player:GetValue("Tag") == "Creator" or
                    player:GetValue("Tag") == "GlAdmin" or player:GetValue("Tag") == "Admin" then
                    local args = {}
                    args.clan = clan
                    args.steamID = steamID
                    self:RemoveMember(args)
                    player:Message("Вы покинули клан!", "warn")
                    self:AddMessage(clan, "log", player:GetName() .. " покинул клан.")
                else
                    player:Message("Вы не можете покинуть клан, поскольку вы его лидер!", "err")
                end
            else
                player:Message("Произошла ошибка, обратитесь к администратору. Код ошибки: 1", "err")
            end
        else
            player:Message("Произошла ошибка, обратитесь к администратору. Код ошибки: 2", "err")
        end
    else
        player:Message("Вы не в клане!", "err")
    end
end

function ClanSystem:InvitePlayer(target, player)
    local clan, index = self:GetPlayerClan(player)

    if clan and index then
        if type(target) == "userdata" then
            if self:IsPlayerAllowedTo({player = player, action = "invite"}) then
                local tClan = self:GetPlayerClan(target)

                if not tClan then
                    self:AddInvitation(target, clan)
                    player:Message("Вы пригласили " .. target:GetName() .. " в клан.", "info")
                    self:AddMessage(clan, "log", player:GetName() .. " пригласил " .. tostring(target:GetName()) .. ".")
                else
                    player:Message("Этот игрок уже находится в клане!", "err")
                end
            else
                player:Message("Вы не можете использовать эту функцию!", "err")
            end
        else
            player:Message("Недопустимый игрок.", "err")
        end
    else
        player:Message("Вы не в клане!", "err")
    end
end

function ClanSystem:GetClanData(clan, data)
    local clanData = self.clans[clan]

    if type(clanData) == "table" then
        return clanData[data]
    end

    return false
end

function ClanSystem:SetClanData(clan, data, value)
    local clanData = self.clans[clan]
    if type(clanData) == "table" then
        self.clans[clan][data] = value
        return true
    end

    return false
end

function ClanSystem:AddInvitation(player, clan)
    if type(player) == "userdata" then
        if self:Exists(clan) then
            if not self.invitations[player:GetId()] then
                self.invitations[player:GetId()] = {}
            end

            player:Message("Вы были приглашены в " .. tostring(clan) .. "!", "info")
            table.insert(self.invitations[player:GetId()], clan)
        end
    end
end

function ClanSystem:GetInvitations(_, player)
    Network:Send(player, "Clans:ReceiveInvitations", self.invitations[player:GetId()])
end

function ClanSystem:AcceptInvite(args, player)
    if self:Exists(args.clan) then
        local clan = self:GetPlayerClan(player)

        if not clan then
            self:AddMember({player = player, clan = args.clan, rank = "Участник"})
            table.remove(self.invitations[player:GetId()], args.index)
        else
            player:Message("Ты уже часть клана.", "err")
        end
    else
        player:Message("Клана больше не существует.", "err")
    end
end

function ClanSystem:GetClans(_, player)
    Network:Send(player, "Clans:ReceiveClans", {clans = self.clans, clanMembers = self.clanMembers})
end

function ClanSystem:JoinClan(clan, player)
    if self:Exists(clan) then
        local pClan = self:GetPlayerClan(player)

        if not pClan then
            if (self.clans[clan].type == "0") or player:GetValue("Tag") == "Creator" or player:GetValue("Tag") == "GlAdmin" or player:GetValue("Tag") == "Admin" then
                if player:GetValue("Tag") == "Creator" or player:GetValue("Tag") == "GlAdmin" or player:GetValue("Tag") == "Admin" then
                    self:AddMember({player = player, clan = clan, rank = "Основатель"})
                else
                    self:AddMember({player = player, clan = clan, rank = "Участник"})
                end
            else
                player:Message("Этот клан только для приглашений.", "err")
            end
        else
            player:Message("Вы уже являетесь частью клана.", "err")
        end
    else
        player:Message("Клан больше не существует.", "err")
    end
end

function ClanSystem:KickPlayer(args, player)
    local clan = self:GetPlayerClan(player)

    if clan then
        if self:IsPlayerAllowedTo({player = player, action = "kick"}) then
            local member = self.playerClan[args.steamID]

            if member then
                if args.rank ~= "Основатель" then
                    local margs = {}
                    margs.clan = clan
                    margs.steamID = args.steamID
                    self:RemoveMember(margs)
                    player:Message("Вас выгнал из клана " .. tostring(args.name) .. "!", "warn")
                    self:GetData(nil, player)
                    self:AddMessage(clan, "log", player:GetName() .. " выгнал " .. tostring(args.name) .. ".")
                else
                    player:Message("Основатель клана не может быть выгнан.", "err")
                end
            else
                player:Message("Участник не найден.", "err")
            end
        else
            player:Message("Вы не можете использовать эту функцию!", "err")
        end
    else
        player:Message("Вы не в клане!", "err")
    end
end

function ClanSystem:SetPlayerRank(args, player)
    local clan = self:GetPlayerClan(player)

    if clan then
        local myRank = self:GetMemberData({steamID = player:GetSteamId().id, data = "rank"})

        if self:IsPlayerAllowedTo({player = player, action = "setRank"}) then
            local memberRank = self:GetMemberData({steamID = args.steamID, data = "rank"})

            if memberRank then
                if (memberRank ~= "Основатель") or player:GetValue("Tag") == "Creator" or
                    player:GetValue("Tag") == "GlAdmin" or player:GetValue("Tag") == "Admin" then
                    if (memberRank ~= myRank) or player:GetValue("Tag") == "Creator" or player:GetValue("Tag") == "GlAdmin" or player:GetValue("Tag") == "Admin" then
                        if memberRank ~= args.rank then
                            if self:SetMemberData({steamID = args.steamID, data = "rank", value = args.rank}) then
                                self:GetData(nil, player)
                                player:Message("Вы установили " .. tostring(args.name) .. " ранг на " .. tostring(args.rank) .. "!", "info")
                                self:AddMessage(clan, "log", player:GetName() .. " изменил " .. tostring(args.name) .. " ранг на " .. tostring(args.rank) .. ".")
                            else
                                player:Message("Не удалось установить ранг, свяжитесь с администратором.", "err")
                            end
                        else
                            player:Message(tostring(args.name) .. "'s ранг is already " .. tostring(args.rank) .. "!", "err")
                        end
                    else
                        player:Message("Вы не можете установить ранг участника того же ранга, что и ваш.", "err")
                    end
                else
                    player:Message("Вы не можете установить ранг основателя!", "err")
                end
            else
                player:Message("Участник не найден.", "err")
            end
        else
            player:Message("Вы не можете использовать эту функцию!", "err")
        end
    else
        player:Message("Вы не в клане!", "err")
    end
end

function ClanSystem:GetMemberData(args)
    local clan = self.playerClan[args.steamID]

    if clan then
        local clanName = clan[1]
        local index = clan[2]
        local members = self.clanMembers[clanName]

        if members then
            local member = members[index]

            if type(member) == "table" then
                return member[args.data]
            else
                return false
            end
        else
            return false
        end
    else
        return false
    end
end

function ClanSystem:SetMemberData(args)
    local clan = self.playerClan[args.steamID]

    if clan then
        local clanName = clan[1]
        local index = clan[2]
        local members = self.clanMembers[clanName]

        if members then
            local member = members[index]

            if type(member) == "table" then
                self.clanMembers[clanName][index][args.data] = args.value
                local transaction = SQL:Transaction()
                local query = SQL:Command("UPDATE clan_members SET " .. tostring(args.data) .. " = ? WHERE clan = ? and steamID = ?")
                query:Bind(1, args.value)
                query:Bind(2, clanName)
                query:Bind(3, args.steamID)
                query:Execute()
                transaction:Commit()

                return true
            else
                return false
            end
        else
            return false
        end
    else
        return false
    end
end

function ClanSystem:IsPlayerAllowedTo(args)
    local clan = self:GetPlayerClan(args.player)

    if clan then
        local rank = self:GetMemberData({steamID = args.player:GetSteamId().id, data = "rank"})
        if rank then
            return self.permissions[rank][args.action]
        else
            return false
        end
    else
        return false
    end
end

function Player:Message(msg, color)
    self:SendChatMessage("[Кланы] ", Color.White, msg, msgColors[color])
end

function ClanSystem:AddMessage(clan, type, msg)
    if self:Exists(clan) then
        local cmd = SQL:Command("INSERT INTO clan_messages ( clan, type, message, date ) VALUES ( ?, ?, ?, ? )")
        cmd:Bind(1, clan)
        cmd:Bind(2, type)
        cmd:Bind(3, msg)
        cmd:Bind(4, os.date("%d/%m/%y %X"))
        cmd:Execute()

        if not self.clanMessages[clan] then
            self.clanMessages[clan] = {}
        end

        table.insert(self.clanMessages[clan], {
            clan = clan,
            type = type,
            message = msg,
            date = os.date("%d/%m/%y %X")
        })
    end
end

function ClanSystem:FactionChat(args)
    if args.player:GetValue("ChatMode") == 2 then
        local text = args.text

        if string.sub(text, 1, 1) ~= "/" then
            local clan = self:GetPlayerClan(args.player)

            if clan then
                local pName = args.player:GetName()
                local pColor = args.player:GetColor()
                local colour = (self.clans[clan].colour:split(",") or {255, 255, 255})
                local r, g, b = table.unpack(colour)

                for player in Server:GetPlayers() do
                    local pClan = self:GetPlayerClan(player)

                    if pClan and (pClan == clan) then
                        player:SendChatMessage("[" .. tostring(clan) .. "] ", Color(tonumber(r), tonumber(g), tonumber(b)), tostring(pName), pColor, ": " .. text, Color.White)
                    end
                end
            end
        end
    end
end

function ClanSystem:UpdateClanSettings(args, player)
    local clan = self:GetPlayerClan(player)

    if clan then
        if self:IsPlayerAllowedTo({player = player, action = "changeSettings"}) then
            if player:GetMoney() >= Prices.ChangeClan then
                player:SetMoney(player:GetMoney() - Prices.ChangeClan)
            else
                player:Message("Требуется $" .. formatNumber(Prices.ChangeClan) .. ", чтобы изменить настройки клана.", "err")
                return false
            end

            local transaction = SQL:Transaction()
            local query = SQL:Command("UPDATE clans SET description = ?, colour = ?, type = ? WHERE name = (?)")
            query:Bind(1, args.description)
            query:Bind(2, args.colour)
            query:Bind(3, args.type)
            query:Bind(4, clan)
            query:Execute()
            transaction:Commit()

            self:SetClanData(clan, "description", args.description)
            self:SetClanData(clan, "colour", args.colour)
            self:SetClanData(clan, "type", args.type)
            player:Message("Настройки клана успешно изменены.", "info")
            self:AddMessage(clan, "log", player:GetName() .. " обновил настройки клана.")
        else
            player:Message("Вы не можете использовать эту функцию!", "err")
        end
    else
        player:Message("Вы не в клане!", "err")
    end
end

function ClanSystem:UpdateClanNews(args, player)
    local clan = self:GetPlayerClan(player)

    if clan then
        if self:IsPlayerAllowedTo({player = player, action = "motd"}) then
            local transaction = SQL:Transaction()
            local query = SQL:Command("UPDATE clans SET clannews = ? WHERE name = (?)")
            query:Bind(1, args.clannews)
            query:Bind(2, clan)
            query:Execute()
            transaction:Commit()

            self:SetClanData(clan, "clannews", args.clannews)
            player:Message("Сообщение дня успешно изменено.", "info")
            self:AddMessage(clan, "log", player:GetName() .. " обновил сообщение дня.")
        else
            player:Message("Вы не можете использовать эту функцию!", "err")
        end
    else
        player:Message("Вы не в клане!", "err")
    end
end

function ClanSystem:ClearLog(_, player)
    local clan = self:GetPlayerClan(player)

    if clan then
        if self:IsPlayerAllowedTo({player = player, action = "clearLog" }) then
            local cmd = SQL:Command("DELETE FROM clan_messages WHERE clan = ( ? )")
            cmd:Bind(1, clan)
            cmd:Execute()

            self.clanMessages[clan] = {}
            player:Message("Логи успешно очищены.", "info")
            self:AddMessage(clan, "log", player:GetName() .. " очистил логи клана.")
        else
            player:Message("Вы не можете использовать эту функцию!", "err")
        end
    else
        player:Message("Вы не в клане!", "err")
    end
end

local clanSystem = ClanSystem()

function convertNumberToString(value)
    if value and tonumber(value) then
        local value = tostring(value)

        if string.sub(value, 1, 1) == "-" then
            return "-" .. setCommasInNumber(string.sub(value, 2, #value))
        else
            return setCommasInNumber(value)
        end
    end

    return false
end

function setCommasInNumber(value)
    if (#value > 3) then
        return setCommasInNumber(string.sub(value, 1, #value - 3)) .. "," .. string.sub(value, #value - 2, #value)
    else
        return value
    end
end