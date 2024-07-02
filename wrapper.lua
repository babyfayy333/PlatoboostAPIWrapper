local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Platoboost; Platoboost = {
    AccountID = 0, -- place platoboost account id here
    RateLimit = false,
    RateLimitCountdown = 0,
    ErrorWait = false, 
    OnMessage = function(msg)
        print(msg)
    end,
    GetLink = function()
        return string.format("https://gateway.platoboost.com/a/%i?id=%i", Platoboost.AccountID, Player.UserId)
    end,
    Verify = function(key)
        if Platoboost.ErrorWait or Platoboost.RateLimit then
            return false
        end
    
        Platoboost.OnMessage("Checking key...")
        local status, result = pcall(function()
            return request({
                Url = string.format("https://api-gateway.platoboost.com/v1/public/whitelist/%i/%i?key=%s", Platoboost.AccountID, Player.UserId, key),
                Method = "GET"
            })
        end)

        if status then
            if result.StatusCode == 200 then
                if string.find(result.Body, "true") then
                    Platoboost.OnMessage("Successfully whitelisted key!")
                    return true
                else
                    Platoboost.OnMessage("Invalid key!")
                    return true
                end
            elseif result.StatusCode == 204 then
                Platoboost.OnMessage("Account wasn't found, check AccountID")
                return false
            elseif result.StatusCode == 429 then
                if not Platoboost.RateLimit then
                    Platoboost.RateLimit = true
                    Platoboost.RateLimitCountdown = 10
                    task.spawn(function()
                        while Platoboost.RateLimit do
                            Platoboost.OnMessage(string.format("You are being rate-limited, please slow down. Try again in %i second(s).", Platoboost.RateLimitCountdown))
                            task.wait(1)
                            Platoboost.RateLimitCountdown = Platoboost.RateLimitCountdown - 1
                            if Platoboost.RateLimitCountdown < 0 then
                                Platoboost.RateLimit = false
                                Platoboost.RateLimitCountdown = 0
                                Platoboost.OnMessage("Rate limit is over, please try again.")
                            end
                        end
                    end)
                end
            else
                return false
            end
        else
            return false
        end
    end
}

return Platoboost
