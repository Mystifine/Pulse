local Signal = require(script.Parent.Signal);
local Runtime = require(script.Parent.Runtime);
local FrameLoop = require(script.Parent.FrameLoop);
local Adapter = require(script.Adapter);

export type SpringConfig = {
  Frequency : number?,
  Damping : number?,
}

local Spring = {};
Spring.__index = Spring;
Spring.__type = "Spring";

function Spring:Destroy()
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

function Spring:_onHeartbeat(dt)

  local T = self.Type;
  local f = self.Frequency * 2 * math.pi
  local d = self.Damping

  local offset = T.sub(self.Target, self.Value)
  local acceleration = T.mul(offset, f * f)
  self.Velocity = T.add(self.Velocity, T.mul(acceleration, dt))
  self.Velocity = T.mul(self.Velocity, math.exp(-d * f * dt))

  local previous = self.Value
  local newValue = T.add(previous, T.mul(self.Velocity, dt))

  local settled =
    T.isClose(offset, T.zero)
    and T.isClose(self.Velocity, T.zero)

  if settled then

    self.Value = self.Target
    self.Velocity = self.Type.zero

    FrameLoop.removeTicker(self)

    self.Changed:Fire(self.Value)

    return
  end

  self.Value = newValue

  if not T.isClose(newValue, previous) then
    self.Changed:Fire(newValue)
  end
end

function Spring:Get()
  local observer = Runtime.getCurrentObserver();
  if observer then
    observer:Add(self);
  end

  return self.Value;
end

function Spring:Set(value, resetVelocity)
  if typeof(value) ~= typeof(self.Value) then
    error("Spring type mismatch")
  end

  self.Target = value;
  
  if resetVelocity then
    self.Velocity = self.Type.zero;
  end

  FrameLoop.queueTicker(self);
end

function Spring.new(source, config : SpringConfig?)
  local springConfig = config or {};
  local self = setmetatable({}, Spring);

  self.Type = Adapter.resolve(source:Get());
  self.Source = source;
  self.Value = source:Get();
  self.Target = self.Value;
  self.Velocity = self.Type.zero;
  self.Frequency = springConfig.Frequency or 6;
  self.Damping = springConfig.Damping or 1;
  self.Changed = Signal.new();

  self._Connection = source.Changed:Connect(function(newValue)
    self.Target = newValue;
    FrameLoop.queueTicker(self);
  end)
  
  return self;
end

return Spring;