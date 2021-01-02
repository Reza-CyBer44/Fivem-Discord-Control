local lastdata = nil
ESX = nil
if Config.ESX then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

function DiscordRequest(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/" .. endpoint,
                       function(errorCode, resultData, resultHeaders)
        data = {data = resultData, code = errorCode, headers = resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bot " .. Config.BotToken
    })

    while data == nil do Citizen.Wait(0) end

    return data
end



function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

function mysplit(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function GetRealPlayerName(playerId)
    if Config.ESX then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        return xPlayer.getName()
    else
        return "ESX NOT ENABLED"
    end
end

function ExecuteCOMM(command)
    if string.starts(command, Config.Prefix) then

        -- Get Player Count
        if string.starts(command, Config.Prefix .. "playercount") then

            sendToDiscord("Player Counts", "Current players in server : " ..
                              GetNumPlayerIndices(), 16711680)

            -- Kick Someone

        elseif string.starts(command, Config.Prefix .. "kick") then

            local t = mysplit(command, " ")

            if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then
                sendToDiscord("KICKED Succesfully",
                              "Succesfuly Kicked " .. GetPlayerName(t[2]),
                              16711680)
                DropPlayer(t[2], "KICKED FROM DISCORD CONSOLE")

            else

                sendToDiscord("Could Not Find",
                              "Could Not Find An ID. Make Sure To Input Valid ID",
                              16711680)

            end

            -- Slay Someone

        elseif string.starts(command, Config.Prefix .. "slay") then

            local t = mysplit(command, " ")

            if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then

                TriggerClientEvent("discordc:kill", t[2])
                TriggerEvent('chat:addMessage', t[2], {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {
                        "Discord Console",
                        "^1 You Have Been Slayed By Discord Console"
                    }
                })
                sendToDiscord("KILLED Succesfully",
                              "Succesfuly KILLED " .. GetPlayerName(t[2]),
                              16711680)

            else

                sendToDiscord("Could Not Find",
                              "Could Not Find An ID. Make Sure To Input Valid ID",
                              16711680)

            end

            -- Return Player List
        elseif string.starts(command, Config.Prefix .. "playerlist") then

           if Config.ESX then
                local count = 0
                local xPlayers = ESX.GetPlayers()
                local players = "Players: "
                for i = 1, #xPlayers, 1 do
                    local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
                    local job = xPlayer.getJob()
                    discord = "Not Found"
                    for _, id in ipairs(GetPlayerIdentifiers(xPlayers[i])) do
                        if string.match(id, "discord:") then
                            discord = string.gsub(id, "discord:", "")
                            break
                        end
                    end

                    count = count + 1
                    local players = players .. GetPlayerName(xPlayers[i]) ..
                                        " | " .. GetRealPlayerName(xPlayers[i]) ..
                                        "|ID " .. xPlayers[i] .. "His Job: " ..
                                        job.name .. " |"

                end
                if count == 0 then
                    sendToDiscord("PLAYER LIST", "There is 0 Player In Server",
                                  16711680)
                else
                    PerformHttpRequest(Config.WebHook,
                                       function(err, text, headers) end, 'POST',
                                       json.encode(
                                           {
                            username = 'Current Player Counts : ' .. count,
                            content = players,
                            avatar_url = Config.AvatarURL
                        }), {['Content-Type'] = 'application/json'})
                end

            else

                sendToDiscord("Discord BOT", "ESX Is not enable", 16711680)

            end

            -- revive
        elseif string.starts(command, Config.Prefix .. "revive") then

            if Config.ESX then

                local t = mysplit(command, " ")
                if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then
                    TriggerClientEvent("esx_ambulancejob:revive", t[2])
                    sendToDiscord("Revived Succesfully",
                                  "Succesfuly Revived " .. GetPlayerName(t[2]),
                                  16711680)

                else

                    sendToDiscord("Could Not Find",
                                  "Could Not Find An ID. Make Sure To Input Valid ID",
                                  16711680)

                end

            else

                sendToDiscord("Discord BOT", "ESX Is not enable", 16711680)

            end
            -- setjob
        elseif string.starts(command, Config.Prefix .. "setjob") then

            if Config.ESX then

                local t = mysplit(command, " ")
                if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then
                    local xPlayer = ESX.GetPlayerFromId(t[2])
                    if xPlayer then

                        if t[3] and t[4] then
                            xPlayer.setJob(tostring(t[3]),t[4])
                            sendToDiscord("Discord BOT",
                                          "You Succesfuly Changed " ..
                                              xPlayer.getName() .. ' Job',
                                          16711680)
                        else
                            sendToDiscord("Discord BOT",
                                          "JOB name OR Job Grade was Invalid. Make sure you are typing like this: \n prefix + setjob + id + job_name + grade_number",
                                          16711680)
                        end

                    end

                else

                    sendToDiscord("Could Not Find",
                                  "Could Not Find An ID. Make Sure To Input Valid ID",
                                  16711680)

                end

            else

                sendToDiscord("Discord BOT", "ESX Is not enable", 16711680)

            end

            -- getjob

        elseif string.starts(command, Config.Prefix .. "getjob") then

            if Config.ESX then

                local t = mysplit(command, " ")
                if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then
                    local xPlayer = ESX.GetPlayerFromId(t[2])
                    if xPlayer then

                        job = xPlayer.getJob()
                        if job then
                            sendToDiscord("Discord Bot",
                                          "Target Job : " .. job.name ..
                                              " \n Target Grade : " .. job.grade ..
                                              " " .. job.grade_label, 16711680)

                        end
                    end

                else

                    sendToDiscord("Could Not Find",
                                  "Could Not Find An ID. Make Sure To Input Valid ID",
                                  16711680)

                end

            else

                sendToDiscord("Discord BOT", "ESX Is not enable", 16711680)

            end

            -- getmoney

        elseif string.starts(command, Config.Prefix .. "getmoney") then

            if Config.ESX then

                local t = mysplit(command, " ")
                if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then
                    local xPlayer = ESX.GetPlayerFromId(t[2])
                    if xPlayer then

                        money = xPlayer.getMoney()
                        if money then
                            sendToDiscord("Discord Bot",
                                          "Target Currently Has : " .. money ..
                                              "$ in their pocket", 16711680)

                        end
                    end

                else

                    sendToDiscord("Could Not Find",
                                  "Could Not Find An ID. Make Sure To Input Valid ID",
                                  16711680)

                end

            else

                sendToDiscord("Discord BOT", "ESX Is not enable", 16711680)

            end

            -- getbank
        elseif string.starts(command, Config.Prefix .. "getbank") then

            if Config.ESX then

                local t = mysplit(command, " ")
                if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then
                    local xPlayer = ESX.GetPlayerFromId(t[2])
                    if xPlayer then

                        money = xPlayer.getAccount('bank')
                        if money then
                            sendToDiscord("Discord Bot",
                                          "Target Currently Has : " ..
                                              money.money ..
                                              "$ in their bank account",
                                          16711680)

                        end
                    end

                else

                    sendToDiscord("Could Not Find",
                                  "Could Not Find An ID. Make Sure To Input Valid ID",
                                  16711680)

                end

            else

                sendToDiscord("Discord BOT", "ESX Is not enable", 16711680)

            end

            -- removeMoney 

        elseif string.starts(command, Config.Prefix .. "removemoney") then

            if Config.ESX then

                local t = mysplit(command, " ")
                if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then
                    local xPlayer = ESX.GetPlayerFromId(t[2])
                    if xPlayer then

                        if t[3] then
                            xPlayer.removeMoney(tonumber(t[3]))
                            sendToDiscord("Discord BOT",
                                          "You Succesfuly removed " ..
                                              xPlayer.getName() .. ' money',
                                          16711680)
                        else
                            sendToDiscord("Discord BOT",
                                          "ID OR Money Input is invalid make sure you are writing like this: \n prefix + removemoney + id + money",
                                          16711680)
                        end

                    end

                else

                    sendToDiscord("Could Not Find",
                                  "Could Not Find An ID. Make Sure To Input Valid ID",
                                  16711680)

                end

            else

                sendToDiscord("Discord BOT", "ESX Is not enable", 16711680)

            end

            -- addMoney

        elseif string.starts(command, Config.Prefix .. "addmoney") then

            if Config.ESX then

                local t = mysplit(command, " ")
                if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then
                    local xPlayer = ESX.GetPlayerFromId(t[2])
                    if xPlayer then

                        if t[3] then
                            xPlayer.addMoney(tonumber(t[3]))
                            sendToDiscord("Discord BOT",
                                          "You Succesfuly added to " ..
                                              xPlayer.getName() .. ' money',
                                          16711680)
                        else
                            sendToDiscord("Discord BOT",
                                          "ID OR Money Input is invalid make sure you are writing like this: \n prefix + addmoney + id + money",
                                          16711680)
                        end

                    end

                else

                    sendToDiscord("Could Not Find",
                                  "Could Not Find An ID. Make Sure To Input Valid ID",
                                  16711680)

                end

            else

                sendToDiscord("Discord BOT", "ESX Is not enable", 16711680)

            end

            -- add to bank account

        elseif string.starts(command, Config.Prefix .. "addbank") then

            if Config.ESX then

                local t = mysplit(command, " ")
                if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then
                    local xPlayer = ESX.GetPlayerFromId(t[2])
                    if xPlayer then

                        if t[3] then
                            xPlayer.addAccountMoney('bank', tonumber(t[3]))
                            sendToDiscord("Discord BOT",
                                          "You Succesfuly added to " ..
                                              xPlayer.getName() .. ' bank money',
                                          16711680)
                        else
                            sendToDiscord("Discord BOT",
                                          "ID OR Money Input is invalid make sure you are writing like this: \n prefix + addbank + id + money",
                                          16711680)
                        end

                    end

                else

                    sendToDiscord("Could Not Find",
                                  "Could Not Find An ID. Make Sure To Input Valid ID",
                                  16711680)

                end

            else

                sendToDiscord("Discord BOT", "ESX Is not enable", 16711680)

            end

            -- remove bank money

        elseif string.starts(command, Config.Prefix .. "removebank") then

            if Config.ESX then

                local t = mysplit(command, " ")
                if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then
                    local xPlayer = ESX.GetPlayerFromId(t[2])
                    if xPlayer then

                        if t[3] then
                            xPlayer.removeAccountMoney('bank',
                                                            tonumber(t[3]))
                            sendToDiscord("Discord BOT",
                                          "You Succesfuly removed from " ..
                                              xPlayer.getName() .. ' bank money',
                                          16711680)
                        else
                            sendToDiscord("Discord BOT",
                                          "ID OR Money Input is invalid make sure you are writing like this: \n prefix + removebank + id + money",
                                          16711680)
                        end

                    end

                else

                    sendToDiscord("Could Not Find",
                                  "Could Not Find An ID. Make Sure To Input Valid ID",
                                  16711680)

                end

            else

                sendToDiscord("Discord BOT", "ESX Is not enable", 16711680)

            end

            -- notific

        elseif string.starts(command, Config.Prefix .. "notific") then

            local safecom = command
            local t = mysplit(command, " ")
            if t[2] ~= nil and GetPlayerName(t[2]) ~= nil and t[3] ~= nil then

                TriggerClientEvent('chat:addMessage', t[2], {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {
                        "Discord Console",
                        "^1 " ..
                            string.gsub(safecom, "!notific " .. t[2] .. " ", "")
                    }
                })

                sendToDiscord("Sended Succesfully",
                              "Succesfuly Sended " ..
                                  string.gsub(safecom,
                                              "!notific " .. t[2] .. " ", "") ..
                                  " To " .. GetPlayerName(t[2]), 16711680)

            else

                sendToDiscord("Could Not Find", "Invalid InPut", 16711680)
            end

            -- announce

        elseif string.starts(command, Config.Prefix .. "announce") then

            local safecom = command
            local t = mysplit(command, " ")
            if t[2] ~= nil then

                TriggerClientEvent('chat:addMessage', -1, {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {
                        "Discord Console",
                        "^1 " ..
                            string.gsub(safecom, Config.Prefix .. "announce", "")
                    }
                })
                sendToDiscord("Sended Succesfully",
                              "Succesfuly Sended : " ..
                                  string.gsub(safecom,
                                              Config.Prefix .. "announce", "") ..
                                  " | To " .. GetNumPlayerIndices() ..
                                  " Player in The Server", 16711680)

            else

                sendToDiscord("Could Not Find", "Invalid InPut", 16711680)
            end

            -- Command Not Found
        else

            sendToDiscord("Discord Command",
                          "Command Not Found. Please Make Sure You Are Entering A Valid Command",
                          16711680)

        end
    end

end

Citizen.CreateThread(function()

    PerformHttpRequest(Config.WebHook, function(err, text, headers) end, 'POST',
                       json.encode({
        username = Config.ReplyUserName,
        content = "Discord Bot Is Now Online",
        avatar_url = Config.AvatarURL
    }), {['Content-Type'] = 'application/json'})
    while true do

        local chanel =
            DiscordRequest("GET", "channels/" .. Config.ChannelID, {})
        if chanel.data then
            local data = json.decode(chanel.data)
            local lst = data.last_message_id
            local lastmessage = DiscordRequest("GET", "channels/" ..
                                                   Config.ChannelID ..
                                                   "/messages/" .. lst, {})
            if lastmessage.data then
                local lstdata = json.decode(lastmessage.data)
                if lastdata == nil then lastdata = lstdata.id end

                if lastdata ~= lstdata.id and lstdata.author.username ~=
                    Config.ReplyUserName then

                    ExecuteCOMM(lstdata.content)
                    lastdata = lstdata.id
                    --	sendToDiscord('New Message Recived',lstdata.content,16711680)

                end
            end
        end
        Citizen.Wait(Config.WaitEveryTick)
    end
end)

function sendToDiscord(name, message, color)
    local connect = {
        {
            ["color"] = color,
            ["title"] = "**" .. name .. "**",
            ["description"] = message,
            ["footer"] = {["text"] = "Developed By RezaCYBER"}
        }
    }
    PerformHttpRequest(Config.WebHook, function(err, text, headers) end, 'POST',
                       json.encode({
        username = Config.ReplyUserName,
        embeds = connect,
        avatar_url = Config.AvatarURL
    }), {['Content-Type'] = 'application/json'})
end
