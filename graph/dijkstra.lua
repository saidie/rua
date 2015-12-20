local function getcost(key, nnode, from, to)
   return redis.call('HGET', key, nnode*from + to)
end

local function zremtop(key)
   local res = redis.call('ZRANGE', key, 0, 0, 'WITHSCORES')
   redis.call('ZREMRANGEBYRANK', key, 0, 0)
   return res[1], res[2]
end

local function zaddlt(key, score, member)
   local s = redis.call('ZSCORE', key, member)
   if not s or s+0 > score then
      redis.call('ZADD', key, score, member)
   end
end

local graph = KEYS[1]
local mincost = KEYS[2]
local n = ARGV[1]
local from = ARGV[2]
local to = ARGV[3]

local visited = {}

redis.call('DEL', mincost)

redis.call('ZADD', mincost, 0, from)
for i = 1, n do visited[i] = false end

local cur, total = zremtop(mincost)
while cur do
   visited[cur+1] = true
   if cur == to then return total end

   for i = 0, n-1 do
      if not visited[i+1] then
         local cost = getcost(graph, n, cur, i)
         if cost and cost+0 > 0 then zaddlt(mincost, total+cost, i) end
      end
   end

   cur, total = zremtop(mincost)
end

return nil
