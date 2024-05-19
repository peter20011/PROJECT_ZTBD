-- Funkcja pomocnicza do pobierania person_id dla regionu USA w roku 1998, którzy nie zdobyli złotego medalu
local function get_usa_non_gold_medalists_1998()
    local persons = redis.call('SMEMBERS', 'region:USA')
    local valid_persons = {}
    for _, person_id in ipairs(persons) do
        local games = redis.call('SMEMBERS', 'person_games:' .. person_id)
        for _, game_id in ipairs(games) do
            local year = redis.call('HGET', 'game:' .. game_id, 'year')
            if tonumber(year) == 1998 then
                local medal_id = redis.call('HGET', 'person_medals:' .. person_id .. ':' .. game_id, 'medal_id')
                local medal_name = redis.call('HGET', 'medal:' .. medal_id, 'name')
                if medal_name ~= 'Gold' then
                    table.insert(valid_persons, person_id)
                    break
                end
            end
        end
    end
    return valid_persons
end

-- Główny skrypt aktualizujący wysokość
local function update_heights()
    local persons = get_usa_non_gold_medalists_1998()
    local updated_count = 0
    for _, person_id in ipairs(persons) do
        local height = redis.call('HGET', 'person:' .. person_id, 'height')
        if height then
            redis.call('HSET', 'person:' .. person_id, 'height', tonumber(height) + 1)
            updated_count = updated_count + 1
        end
    end
    return updated_count
end

return update_heights()
