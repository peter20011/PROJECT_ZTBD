-- Skrypt Lua do wyboru zawodników o wzroście powyżej 180 cm

local cursor = "0"
local result = {}

repeat
    -- Skanowanie kluczy partii
    local scan_result = redis.call("SCAN", cursor, "MATCH", "person:*", "COUNT", 1000)
    cursor = scan_result[1]
    local keys = scan_result[2]

    for _, key in ipairs(keys) do
        -- Sprawdzanie, czy klucz jest hash
        if redis.call('TYPE', key).ok == 'hash' then
            local height = redis.call('HGET', key, 'height')
            if height and tonumber(height) > 180 then
                local full_name = redis.call('HGET', key, 'full_name')
                if full_name then
                    table.insert(result, {full_name, height})
                end
            end
        end
    end
until cursor == "0"

-- Przygotowanie wyniku do zwrócenia
local response = {}
for i, row in ipairs(result) do
    table.insert(response, row[1] .. ": " .. row[2])
end

return response
