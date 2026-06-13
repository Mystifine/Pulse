local RunService = game:GetService("RunService");

local SpringScheduler = {};
local activeSprings = {};
local heartbeatConnection = nil;

function SpringScheduler._onHeartbeat(dt)
  for spring in pairs(activeSprings) do
    spring:_onHeartbeat(dt);
  end

  if next(activeSprings) == nil and heartbeatConnection then
    heartbeatConnection:Disconnect();
    heartbeatConnection = nil;
  end
end

function SpringScheduler.add(spring)
  activeSprings[spring] = true;
  if not heartbeatConnection then
    heartbeatConnection = RunService.Heartbeat:Connect(SpringScheduler._onHeartbeat);
  end
end

function SpringScheduler.remove(spring)
  activeSprings[spring] = nil;
end


return SpringScheduler;