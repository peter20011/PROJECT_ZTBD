local batch_size = 20000  -- Rozmiar partii kluczy do przetworzenia
local cursor = "0"
local total_medals = 0  -- Zmienna do liczenia medali
local processed_count = 0  -- Zmienna do liczenia przetworzonych kluczy

-- Pobierz ID regionu Polski
local poland_region_id = nil
local region_keys = redis.call('KEYS', 'noc_region:*')
for _, key in ipairs(region_keys) do
    local region_name = redis.call('HGET', key, 'region_name')
    if region_name == 'Poland' then
        poland_region_id = key:match('noc_region:(%d+)')
        break
    end
end

if not poland_region_id then
    return 'Poland region not found'
end

while cursor ~= "0" or processed_count < batch_size do
    -- Skanowanie kluczy partii
    local result = redis.call("SCAN", cursor, "MATCH", "person:*:regions", "COUNT", batch_size)
    cursor = result[1]
    local person_keys = result[2]

    for _, person_key in ipairs(person_keys) do
        local person_id = person_key:match("person:(%d+):regions")
        if person_id then
            local regions = redis.call('SMEMBERS', person_key)
            for _, region_id in ipairs(regions) do
                if region_id == poland_region_id then
                    -- Pobierz wszystkie powiązania osoby z igrzyskami
                    local competitors_key = 'person:' .. person_id .. ':competitors'
                    local competitor_ids = redis.call('SMEMBERS', competitors_key)
                    for _, competitor_id in ipairs(competitor_ids) do
                        local competitor_event_keys = redis.call('KEYS', 'competitor_event:competitor:' .. competitor_id .. ':event:*')
                        for _, ce_key in ipairs(competitor_event_keys) do
                            local medal_id = redis.call('HGET', ce_key, 'medal_id')
                            if medal_id and medal_id ~= "4" then
                                local games_id = redis.call('HGET', 'games_competitor:' .. competitor_id, 'games_id')
                                local games_year = redis.call('HGET', 'games:' .. games_id, 'games_year')
                                if games_year == '2000' then
                                    local medal_name = redis.call('HGET', 'medal:' .. medal_id, 'medal_name')
                                    if medal_name and medal_name ~= 'NA' then
                                        total_medals = total_medals + 1
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

return total_medals  -- Zwróć liczbę faktycznie zdobytych medali
