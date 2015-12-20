local function setcost(key, nnode, from, to, cost)
   redis.call('HSET', key, nnode*from + to, cost)
end

local n = ARGV[1]
local argc = table.getn(ARGV)

for i = 2, argc, 3 do
   setcost(KEYS[1], n, ARGV[i], ARGV[i+1], ARGV[i+2])
end
