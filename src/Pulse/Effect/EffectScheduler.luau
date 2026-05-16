local RunService = game:GetService("RunService");

local EffectScheduler = {};

local queuedEffects = {};
local heartbeatConnection;

function EffectScheduler._onHeartbeat()
  local queueToProcess = queuedEffects;
  queuedEffects = {};
  for effect, _ in queueToProcess do
    effect:Run();
  end

  if next(queuedEffects) == nil then
    heartbeatConnection:Disconnect();
    heartbeatConnection = nil;
  end
end

function EffectScheduler.schedule(effect)
  if queuedEffects[effect] then return end;
  queuedEffects[effect] = true;

  if not heartbeatConnection then
    heartbeatConnection = RunService.Heartbeat:Connect(EffectScheduler._onHeartbeat);
  end
end

return EffectScheduler;