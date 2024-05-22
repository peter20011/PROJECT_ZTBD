-- Skrypt Lua do obliczenia średniej wagi zawodniczek w zależności od roku

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
            local gender = redis.call('HGET', key, 'gender')
            if gender == 'F' then
                local person_id = key:match('person:(%d+)$')
                if person_id then
                    local weight = redis.call('HGET', key, 'weight')
                    if weight then
                        local games_competitor_keys = redis.call('SMEMBERS', 'person:' .. person_id .. ':competitors')
                        for _, gc_key in ipairs(games_competitor_keys) do
                            local games_id = redis.call('HGET', 'games_competitor:' .. gc_key, 'games_id')
                            if games_id then
                                local games_year = redis.call('HGET', 'games:' .. games_id, 'games_year')
                                if games_year then
                                    if not result[games_year] then
                                        result[games_year] = {total_weight = 0, count = 0}
                                    end
                                    result[games_year].total_weight = result[games_year].total_weight + tonumber(weight)
                                    result[games_year].count = result[games_year].count + 1
                                end
                            end
                        end
                    end
                end
            end
        end
    end
until cursor == "0"

-- Obliczenie średniej wagi dla każdego roku
local response = {}
for games_year, data in pairs(result) do
    local average_weight = data.total_weight / data.count
    table.insert(response, games_year .. ": " .. average_weight)
end

-- Sortowanie wyników według roku
table.sort(response, function(a, b)
    return tonumber(a:match('^%d+')) < tonumber(b:match('^%d+'))
end)

return response
