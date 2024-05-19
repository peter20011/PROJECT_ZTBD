-- Skrypt Lua do zwiększenia wzrostu o 1 dla zawodników z USA, którzy nie zdobyli złotego medalu w 1998 roku

local cursor = "0"
local updated_count = 0  -- Zmienna do liczenia zaktualizowanych kluczy
local processed_count = 0 -- Zmienna do liczenia przetworzonych kluczy
local batch_size = 10000  -- Ograniczenie do 10 000 rekordów
local year = "1998"

-- Pobierz ID złotego medalu
local gold_medal_id = nil
local medal_keys = redis.call('KEYS', 'medal:*')
for _, key in ipairs(medal_keys) do
    local medal_name = redis.call('HGET', key, 'medal_name')
    if medal_name == 'Gold' then
        gold_medal_id = key:match('medal:(%d+)')
        break
    end
end

if not gold_medal_id then
    return 'Gold medal not found'
end

-- Pobierz ID regionu USA
local usa_region_id = nil
local region_keys = redis.call('KEYS', 'noc_region:*')
for _, key in ipairs(region_keys) do
    local region_name = redis.call('HGET', key, 'region_name')
    if region_name == 'USA' then
        usa_region_id = key:match('noc_region:(%d+)')
        break
    end
end

if not usa_region_id then
    return 'USA region not found'
end

while cursor ~= "0" and processed_count < batch_size do
    -- Skanowanie kluczy partii
    local result = redis.call("SCAN", cursor, "MATCH", "person:*", "COUNT", 1000)
    cursor = result[1]
    local person_keys = result[2]

    for _, person_key in ipairs(person_keys) do
        if person_key:match('person:%d+$') and redis.call('TYPE', person_key).ok == 'hash' then
            local person_id = person_key:match('person:(%d+)')

            -- Sprawdź, czy osoba jest z USA
            local regions_key = 'person:' .. person_id .. ':regions'
            local regions = redis.call('SMEMBERS', regions_key)
            local is_usa = false

            for _, region_id in ipairs(regions) do
                if region_id == usa_region_id then
                    is_usa = true
                    break
                end
            end

            if is_usa then
                -- Pobierz wszystkie powiązania osoby z igrzyskami
                local games_competitor_keys = redis.call('KEYS', 'games_competitor:*')
                for _, gc_key in ipairs(games_competitor_keys) do
                    if redis.call('TYPE', gc_key).ok == 'hash' then
                        local gc_person_id = redis.call('HGET', gc_key, 'person_id')
                        if gc_person_id == person_id then
                            local games_id = redis.call('HGET', gc_key, 'games_id')
                            local games_year = redis.call('HGET', 'games:' .. games_id, 'games_year')

                            if games_year == year then
                                local competitor_id = gc_key:match('games_competitor:(%d+)')
                                local competitor_event_keys = redis.call('KEYS', 'competitor_event:competitor:' .. competitor_id .. ':event:*')

                                local won_gold = false
                                for _, ce_key in ipairs(competitor_event_keys) do
                                    local medal_id = redis.call('HGET', ce_key, 'medal_id')
                                    if medal_id then
                                        if medal_id == gold_medal_id then
                                            won_gold = true
                                            break
                                        end
                                    end
                                end

                                if not won_gold then
                                    local height = redis.call('HGET', person_key, 'height')
                                    if height then
                                        local new_height = tonumber(height) + 1
                                        redis.call('HSET', person_key, 'height', new_height)
                                        updated_count = updated_count + 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        processed_count = processed_count + 1
        if processed_count >= batch_size then
            break
        end
    end
end

return updated_count  -- Zwróć liczbę faktycznie zaktualizowanych kluczy
