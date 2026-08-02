local TweenService = game:GetService("TweenService");

local Runtime = require(script.Parent.Runtime);
local Signal = require(script.Parent.Signal);
local FrameLoop = require(script.Parent.FrameLoop);

local Tween = {};
Tween.__index = Tween;
Tween.__type = "Tween";

local function lerpValue(a, b, alpha)
  if type(a) == "number" then
    return a + ((b - a) * alpha);
  elseif typeof(a) == typeof(b) and a.Lerp then
    return a:Lerp(b, alpha);
  else
    error("Tween failed: Unsupported type or mismatch");
  end
end

function Tween:_onHeartbeat()
  local elapsedTime = os.clock() - self.StartTime;

  local alpha = 0;
  if self.TweenInfo.Time == 0 then
    alpha = 1
  else
    alpha = math.clamp(elapsedTime / self.TweenInfo.Time, 0, 1);
  end

  local easedAlpha = TweenService:GetValue(alpha, self.TweenInfo.EasingStyle, self.TweenInfo.EasingDirection);
  
  self.Value = lerpValue(self.StartValue, self.TargetValue, easedAlpha);
  self.Changed:Fire(self.Value);

  if alpha >= 1 then
    FrameLoop.removeTicker(self);
  end
end

function Tween:Destroy()
  FrameLoop.removeTicker(self);

  if self._Connection then
    self._Connection:Disconnect();
    self._Connection = nil;
  end

  if self.Changed then 
    self.Changed:Destroy();
    self.Changed = nil;
  end
end

function Tween:Get()
  local observer = Runtime.getCurrentObserver();
  if observer then
    observer:Add(self);
  end

  return self.Value;  
end

function Tween.new(source, tweenInfo : TweenInfo)
  local self = setmetatable({}, Tween);

  self.Source = source;
  self.Value = source:Get();

  self.StartTime = os.clock();
  self.StartValue = source:Get();
  self.TargetValue = source:Get();
  self.TweenInfo = tweenInfo;

  self.Changed = Signal.new();

  self._Connection = source.Changed:Connect(function(newValue)
    self.StartTime = os.clock();
    self.StartValue = self.Value;
    self.TargetValue = newValue;

    FrameLoop.queueTicker(self);
  end)

  return self;
end


return Tween;