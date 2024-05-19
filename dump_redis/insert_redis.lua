-- Funkcja do dodawania określonej liczby osób
local function add_persons(limit)
    local added_count = 0
    for i = 1, limit do
        -- Tworzenie unikalnego identyfikatora dla każdej osoby
        local person_id = redis.call('INCR', 'person_id')
        local key = 'person:' .. person_id
        
        -- Dodanie nowego rekordu osoby jako hash
        redis.call('HMSET', key, 
                   'full_name', 'John Doe', 
                   'gender', 'Male', 
                   'height', 180, 
                   'weight', 75)
        
        added_count = added_count + 1
    end
    return added_count
end

-- Wywołanie funkcji z limitem 100 osób
return add_persons(10000)
