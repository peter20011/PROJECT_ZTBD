-- Skrypt Lua do aktualizacji wagi każdej osoby o +5
local keys = redis.call('KEYS', 'person:*')  -- Pobierz wszystkie klucze pasujące do wzorca 'person:*'
local updated_count = 0  -- Zmienna do liczenia zaktualizowanych kluczy

for _, key in ipairs(keys) do
    if redis.call('TYPE', key).ok == 'hash' then  -- Sprawdź, czy klucz jest typu hash
        local weight = redis.call('HGET', key, 'weight')  -- Pobierz aktualną wartość wagi
        if weight then
            local new_weight = tonumber(weight) + 5  -- Zwiększ wagę o 5
            redis.call('HSET', key, 'weight', new_weight)  -- Zaktualizuj wartość wagi
            updated_count = updated_count + 1  -- Zwiększ licznik zaktualizowanych kluczy
        end
    end
end

return updated_count  -- Zwróć liczbę faktycznie zaktualizowanych kluczy
