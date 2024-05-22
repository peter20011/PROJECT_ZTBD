-- Skrypt Lua do wyświetlania zawodników, którzy zdobyli medal w konkretnym wydarzeniu, uporządkowane według nazwiska

local event_name_target = 'Sailing Mixed Two Person Heavyweight Dinghy'
local cursor = "0"
local result = {}

-- Funkcja pomocnicza do skanowania kluczy
local function scan_keys(pattern)
    local cursor = "0"
    local keys = {}
    repeat
        local scan_result = redis.call("SCAN", cursor, "MATCH", pattern, "COUNT", 1000)
        cursor = scan_result[1]
        for _, key in ipairs(scan_result[2]) do
            table.insert(keys, key)
        end
    until cursor == "0"
    return keys
end

-- Pobieranie event_id dla docelowego event_name
local event_id = nil
local event_keys = scan_keys("event:*")
for _, key in ipairs(event_keys) do
    if redis.call('TYPE', key).ok == 'hash' then
        local event_name = redis.call("HGET", key, "event_name")
        if event_name == event_name_target then
            event_id = key:match("event:(%d+)")
            break
        end
    end
end

if not event_id then
    return "Event not found"
end

-- Pobieranie kluczy zawodników dla danego eventu
local competitors_key = 'event:' .. event_id .. ':competitors'
local competitors = redis.call('SMEMBERS', competitors_key)

-- Skanowanie wszystkich kluczy competitor_event
for _, competitor_id in ipairs(competitors) do
    local competitor_event_keys = scan_keys('competitor_event:competitor:' .. competitor_id .. ':event:*')
    for _, ce_key in ipairs(competitor_event_keys) do
        if redis.call('TYPE', ce_key).ok == 'hash' then
            local event_id_check = redis.call('HGET', ce_key, 'event_id')
            if event_id_check == event_id then
                local medal_id = redis.call('HGET', ce_key, 'medal_id')
                if medal_id and medal_id ~= "4" then
                    local medal_name = redis.call('HGET', 'medal:' .. medal_id, 'medal_name')
                    if medal_name and medal_name ~= 'NA' then
                        -- Pobieranie osoby, aby znaleźć odpowiedniego zawodnika
                        local person_key = 'person:' .. redis.call('HGET', ce_key, 'competitor_id')
                        local full_name = redis.call('HGET', person_key, 'full_name')
                        if full_name then
                            table.insert(result, {full_name, event_name_target, medal_name})
                        end
                    end
                end
            end
        end
    end
end

-- Sortowanie wyników według nazwiska
table.sort(result, function(a, b)
    return a[1] < b[1]
end)

-- Przygotowanie wyniku do zwrócenia
local response = {}
for i, row in ipairs(result) do
    table.insert(response, row[1] .. ": " .. row[2] .. ", " .. row[3])
end

return response
