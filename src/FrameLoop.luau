local RunService = game:GetService("RunService");

local FrameLoop = {};

local tickers = {}; -- For frame based updates
local queuedComputations = {}; -- For computation based updates
local queuedEffects = {}; -- For effect based updates 

local connection = nil;

function FrameLoop.flush(dt)
  
  -- First update ticked based updates
  for ticker, _ in tickers do
    local ok, err = xpcall(function()
      ticker:_onHeartbeat(dt); -- Required method call
    end, debug.traceback)

    if not ok then
      warn("[FrameLoop] Error in Ticker:", err);
    end
  end

  -- Next do comptuations first
  local computations = queuedComputations;
  queuedComputations = {};
  for computation, _ in computations do
    if computation._Destroyed then continue end;

    local ok, err = xpcall(function()
      computation:Get();
    end, debug.traceback)
    
    if not ok then
      warn("[FrameLoop] Error in Computation:", err);
    end
  end

  -- Run Effects
  local effects = queuedEffects;
  queuedEffects = {};
  for effect, _ in effects do
    if effect._Destroyed then continue end;

    local ok, err = xpcall(function()
      effect:Run();
    end, debug.traceback)
    
    if not ok then
      warn("[FrameLoop] Error in Effect:", err)
    end
  end

  if not next(tickers) and not next(queuedComputations) and not next(queuedEffects) then
    if connection then
      connection:Disconnect();
      connection = nil;
    end
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