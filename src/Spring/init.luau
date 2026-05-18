local Signal = require(script.Parent.Signal);
local Runtime = require(script.Parent.Runtime);
local SpringScheduler = require(script.SpringScheduler);
local Adapter = require(script.Adapter);

local Spring = {};
Spring.__index = Spring;
Spring.__type = "Spring";

function Spring:Destroy()
  SpringScheduler.remove(self);
  self._Connection:Disconnect();
  self.Changed:Destroy();
end

function Spring:_onStep(dt)

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

    SpringScheduler.remove(self)

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

  SpringScheduler.add(self);
end

function Spring.new(source, config)
  local self = setmetatable({}, Spring);

  self.Type = Adapter.resolve(source:Get());
  self.Source = source;
  self.Value = source:Get();
  self.Target = self.Value;
  self.Velocity = self.Type.zero;
  self.Frequency = config.Frequency or 6;
  self.Damping = config.Damping or 1;
  self.Changed = Signal.new();

  self._Connection = source.Changed:Connect(function(newValue)
    self.Target = newValue;
    SpringScheduler.add(self);
  end)
  
  return self;
end

return Spring;