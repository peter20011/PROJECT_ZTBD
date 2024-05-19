-- Funkcja do pobrania wszystkich osób z Redis
local function select_all_persons()
    local result = {}

    -- Pobierz wszystkie klucze osób
    local person_keys = redis.call('KEYS', 'person:*')

    for _, person_key in ipairs(person_keys) do
        -- Sprawdź, czy klucz jest typu hash
        if redis.call('TYPE', person_key).ok == 'hash' then
            -- Pobierz wszystkie pola dla danego klucza osoby
            local person_data = redis.call('HGETALL', person_key)
            table.insert(result, person_data)
        end
    end

    return result
end

-- Wywołaj funkcję i zwróć wynik
return select_all_persons()
