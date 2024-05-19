-- Assume we are looking for the medal_name of medal:1
local medal_key = 'medal:1'
-- Use HGET to fetch the medal_name from the hash
local medal_name = redis.call('HGET', medal_key, 'medal_name')
-- Return the result
return medal_name