-- Skrypt Lua do ustawienia złotego medalu dla wszystkich zawodników z Polski

local batch_size = 100000  -- Rozmiar partii kluczy do przetworzenia
local cursor = "0"
local updated_count = 0  -- Zmienna do liczenia zaktualizowanych kluczy
local processed_count = 0  -- Zmienna do liczenia przetworzonych kluczy

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
    local result = redis.call("SCAN", cursor, "MATCH", "person:*", "COUNT", batch_size)
    cursor = result[1]
    local person_keys = result[2]

    for _, person_key in ipairs(person_keys) do
        if person_key:match('person:%d+$') and redis.call('TYPE', person_key).ok == 'hash' then
            local person_id = person_key:match('person:(%d+)')

            -- Sprawdź, czy osoba jest z Polski
            local regions_key = 'person:' .. person_id .. ':regions'
            local regions = redis.call('SMEMBERS', regions_key)
            local is_poland = false

            for _, region_id in ipairs(regions) do
                if region_id == poland_region_id then
                    is_poland = true
                    break
                end
            end

            if is_poland then
                -- Pobierz wszystkie powiązania osoby z igrzyskami
                local competitors_key = 'person:' .. person_id .. ':competitors'
                local competitor_ids = redis.call('SMEMBERS', competitors_key)
                for _, competitor_id in ipairs(competitor_ids) do
                    local competitor_event_keys = redis.call('KEYS', 'competitor_event:competitor:' .. competitor_id .. ':event:*')
                    for _, ce_key in ipairs(competitor_event_keys) do
                        redis.call('HSET', ce_key, 'medal_id', gold_medal_id)
                        updated_count = updated_count + 1
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
