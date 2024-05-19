-- Funkcja do pobrania wszystkich zawodników, którzy zdobyli medal
local function select_medalists()
    local result = {}
    local medalists = {}

    -- Pobierz wszystkie klucze konkurencji
    local competitor_keys = redis.call('KEYS', 'competitor_event:competitor:*:event:*')

    for _, competitor_key in ipairs(competitor_keys) do
        -- Pobierz medal_id dla każdej konkurencji
        local medal_id = redis.call('HGET', competitor_key, 'medal_id')
        
        if medal_id then
            local medal_name = redis.call('HGET', 'medal:' .. medal_id, 'name')
            
            if medal_name and medal_name ~= 'NA' then
                -- Wyodrębnij identyfikatory osoby i konkurencji z klucza
                local _, _, competitor_id, _, event_id = string.match(competitor_key, '(competitor_event):competitor:(%d+):event:(%d+)')
                local person_id = redis.call('HGET', 'competitor:' .. competitor_id, 'person_id')
                local full_name = redis.call('HGET', 'person:' .. person_id, 'full_name')
                
                if full_name then
                    -- Inicjalizuj licznik medali, jeśli nie istnieje
                    if not medalists[full_name] then
                        medalists[full_name] = 0
                    end
                    
                    -- Zwiększ licznik medali
                    medalists[full_name] = medalists[full_name] + 1
                end
            end
        end
    end

    -- Konwersja tabeli do formatu listy dla sortowania
    for full_name, total_medals in pairs(medalists) do
        table.insert(result, {full_name, total_medals})
    end

    -- Sortowanie wyników według liczby medali malejąco
    table.sort(result, function(a, b) return a[2] > b[2] end)

    -- Przygotowanie wyniku do zwrócenia
    local flat_result = {}
    for _, row in ipairs(result) do
        table.insert(flat_result, row[1])
        table.insert(flat_result, row[2])
    end

    return flat_result
end

-- Wywołaj funkcję i zwróć wynik
return select_medalists()
