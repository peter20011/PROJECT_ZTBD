-- Funkcja do usuwania określonej liczby kluczy dla osób
local function delete_persons(limit)
    local count = 0
    local cursor = "0"  -- Startujemy skanowanie od początku
    repeat
        local result = redis.call('SCAN', cursor, 'MATCH', 'person:*', 'COUNT', 1000)
        cursor = result[1]
        local keys = result[2]
        for i, key in ipairs(keys) do
            redis.call('DEL', key)
            count = count + 1
            if count >= limit then
                return count
            end
        end
    until cursor == "0"
    return count
end

-- Zmieniamy limit zgodnie z wymaganiami
-- Możesz zdefiniować różne wartości limitu tutaj
local limit = 1000  -- Możesz zmieniać na 1000, 10000, 20000, 30000, 40000, 50000

return delete_persons(limit)
