local RunService = game:GetService("RunService");

local TweenScheduler = {};
local activeTweens = {};
local heartbeatConnection = nil;

function TweenScheduler._onHeartbeat()
  for tween in activeTweens do
    tween:_onHeartbeat()
  end

  if next(activeTweens) == nil and heartbeatConnection then
    heartbeatConnection:Disconnect();
    heartbeatConnection = nil;
  end
end

function TweenScheduler.add(tween)
  activeTweens[tween] = true;
  if not heartbeatConnection then
    heartbeatConnection = RunService.Heartbeat:Connect(TweenScheduler._onHeartbeat);
  end
end

function TweenScheduler.remove(tween)
  activeTweens[tween] = nil;
end

return TweenScheduler;