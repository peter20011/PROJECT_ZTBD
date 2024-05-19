-- Funkcja pomocnicza do znajdowania ID medalu dla złota
local function get_gold_medal_id()
    local gold_medal_id = redis.call('HGET', 'medal_ids', 'Gold')
    return gold_medal_id
end

-- Funkcja ustawiająca złoty medal dla wszystkich zawodników z Polski
local function set_gold_medals_for_poland()
    local gold_medal_id = get_gold_medal_id()
    local poland_competitors = redis.call('SMEMBERS', 'country_competitors:Poland')
    local updated_count = 0

    for _, person_id in ipairs(poland_competitors) do
        local events = redis.call('SMEMBERS', 'person_events:' .. person_id)
        for _, event_id in ipairs(events) do
            local competitor_event_key = 'competitor_events:' .. event_id
            redis.call('HSET', competitor_event_key, 'medal_id', gold_medal_id)
            updated_count = updated_count + 1
        end
    end
    return updated_count
end

return set_gold_medals_for_poland()
