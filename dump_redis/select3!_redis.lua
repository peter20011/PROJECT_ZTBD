-- Skrypt Lua do wyboru liczby zawodników w każdym regionie

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
            local person_id = key:match('person:(%d+)$')
            if person_id then
                local regions_key = 'person:' .. person_id .. ':regions'
                local regions = redis.call('SMEMBERS', regions_key)
                for _, region_id in ipairs(regions) do
                    local region_name = redis.call('HGET', 'noc_region:' .. region_id, 'region_name')
                    if region_name then
                        if not result[region_name] then
                            result[region_name] = 0
                        end
                        result[region_name] = result[region_name] + 1
                    end
                end
            end
        end
    end
until cursor == "0"

-- Konwersja wyniku do tablicy
local result_list = {}
for region_name, total_players in pairs(result) do
    table.insert(result_list, {region_name, total_players})
end

-- Funkcja sortująca po liczbie zawodników malejąco
table.sort(result_list, function(a, b)
    return b[2] > a[2]
end)

-- Przygotowanie wyniku do zwrócenia
local response = {}
for i, row in ipairs(result_list) do
    table.insert(response, row[1] .. ": " .. row[2])
end

return response
