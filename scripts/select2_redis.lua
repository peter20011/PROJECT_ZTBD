-- Skrypt Lua do wyboru wszystkich zawodników, którzy zdobyli medal

local cursor = "0"
local result = {}
local medal_name_na = 'NA'

repeat
    -- Skanowanie kluczy partii
    local scan_result = redis.call("SCAN", cursor, "MATCH", "competitor_event:competitor:*:event:*", "COUNT", 1000)
    cursor = scan_result[1]
    local keys = scan_result[2]

    for _, key in ipairs(keys) do
        local medal_id = redis.call('HGET', key, 'medal_id')
        if medal_id then
            local medal_name = redis.call('HGET', 'medal:' .. medal_id, 'medal_name')
            if medal_name and medal_name ~= medal_name_na then
                local competitor_id = key:match('competitor_event:competitor:(%d+):event:%d+')
                if competitor_id then
                    local person_id = redis.call('HGET', 'games_competitor:' .. competitor_id, 'person_id')
                    if person_id then
                        local full_name = redis.call('HGET', 'person:' .. person_id, 'full_name')
                        if full_name then
                            if not result[full_name] then
                                result[full_name] = 0
                            end
                            result[full_name] = result[full_name] + 1
                        end
                    end
                end
            end
        end
    end
until cursor == "0"

-- Konwersja wyniku do tablicy
local result_list = {}
for full_name, total_medals in pairs(result) do
    table.insert(result_list, {full_name, total_medals})
end

-- Funkcja sortująca po liczbie medali malejąco
table.sort(result_list, function(a, b)
    return b[2] < a[2]
end)

-- Przygotowanie wyniku do zwrócenia
local response = {}
for i, row in ipairs(result_list) do
    table.insert(response, row[1] .. ": " .. row[2])
end

return response
