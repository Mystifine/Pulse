local Value = require(script.Parent.Value);

local Scope = {};
Scope.__index = Scope;

function Scope:Value(value : any)
  local valueObj = Value.new(value);

  table.insert(self.signals, valueObj.Changed);

  return valueObj;
end

function Scope:Add(cleanupFunction : () -> ())
  table.insert(self.signals, cleanupFunction);
end

function Scope:Destroy()
  for _, signal in self.signals do
    signal:Destroy();
  end

  table.clear(self.signals);
  setmetatable(self, nil);
end

function Scope.new()
  local self = setmetatable({}, Scope);
  self.signals = {};

  return self;
end

return Scope;