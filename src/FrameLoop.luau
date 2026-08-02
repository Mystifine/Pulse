local RunService = game:GetService("RunService");

local FrameLoop = {};

local tickers = {}; -- For frame based updates
local queuedComputations = {}; -- For computation based updates
local queuedEffects = {}; -- For effect based updates 

local connection = nil;

function FrameLoop.flush(dt)
  
  -- First update ticked based updates
  for ticker in tickers do
    ticker:_onHeartbeat(dt); -- Required method call
  end

  -- Next do comptuations first
  local computations = queuedComputations;
  queuedComputations = {};
  for computation, _ in computations do
    computation:Get();
  end

  -- Run Effects
  local effects = queuedEffects;
  queuedEffects = {};
  for effect, _ in effects do
    effect:Run();
  end

  if not next(tickers) and not next(queuedComputations) and not next(queuedEffects) then
    connection:Disconnect();
    connection = nil;
  end
end

function FrameLoop.connectLoop()
  if not connection then
    connection = RunService.Heartbeat:Connect(FrameLoop.flush);
  end
end

function FrameLoop.queueTicker(obj)
  tickers[obj] = true;
  FrameLoop.connectLoop();
end

function FrameLoop.removeTicker(obj)
  tickers[obj] = nil;
end

function FrameLoop.queueComputation(computation)
  queuedComputations[computation] = true;
  FrameLoop.connectLoop();
end

function FrameLoop.queueEffect(effect)
  queuedEffects[effect] = true;
  FrameLoop.connectLoop();
end

return FrameLoop;