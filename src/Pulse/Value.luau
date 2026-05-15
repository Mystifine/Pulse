local Signal = require(script.Parent.Signal);

local Value = {};
Value.__index = Value;
Value.__type = "PulseValue";

function Value:Get()
  return self.Value;
end

function Value:Set(value : any)
  self.Value = value;

  self.Changed:Fire(value);
end

function Value.new(value : any)
  local self = setmetatable({}, Value);
  self.Value = value;
  self.Changed = Signal.new();

  return self;
end

return Value;