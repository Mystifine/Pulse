local RunService = game:GetService("RunService");

local ComputationScheduler = {};

local queuedComputations = {};
local heartbeatConnection;

function ComputationScheduler._onHeartbeat()
  local queueToProcess = queuedComputations;
  queuedComputations = {};
  for computation, _ in queueToProcess do
    computation:Get();
  end

  if next(queuedComputations) == nil then
    heartbeatConnection:Disconnect();
    heartbeatConnection = nil;
  end
end

function ComputationScheduler.schedule(computation)
  if queuedComputations[computation] then return end;
  queuedComputations[computation] = true;

  if not heartbeatConnection then
    heartbeatConnection = RunService.Heartbeat:Connect(ComputationScheduler._onHeartbeat);
  end
end

return ComputationScheduler;