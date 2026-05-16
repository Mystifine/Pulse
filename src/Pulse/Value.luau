local Signal = require(script.Parent.Signal);
local Runtime = require(script.Parent.Runtime);

local Value = {};
Value.__index = Value;
Value.__type = "PulseValue";

function Value:Get()

  if Runtime.currentObserver then
    Runtime.currentObserver:Add(self);
  end

  return self.Value;
end

function Value:Set(value : any)
  if value == self.Value then return end;

  self.Value = value;

  self.Changed:Fire(value);
end

function Value.new(value : any)
  local self = setmetatable({}, Value);
  self.Value = value;
  self.Changed = Signal.new();

  return self;
end

function Value:Destroy()
  self.Changed:Destroy();
  self.Value = nil;
end

return Value;