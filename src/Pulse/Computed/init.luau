local Runtime = require(script.Parent.Runtime)
local Signal = require(script.Parent.Signal);
local ComputedScheduler = require(script.ComputedScheduler);

local Computed = {};
Computed.__index = Computed;

function Computed:Clear()
  local connections = self._Connections;
  self._Connections = {};
  
  for _, connection in pairs(connections) do
    connection:Disconnect();
  end

  self._Seen = {};
end

function Computed:Get()
  if self._Computing then return end;
  self._Computing = true;

  -- Need to begin tracking
  self:Clear();
  Runtime.pushObserver(self);

  -- Computes value and removes observer
  local sucess, result = xpcall(self.Callback, debug.traceback);
  Runtime.popObserver();

  if not sucess then 
    self._Computing = false;
    error(result) 
  end;

  -- Commit values
  if self.Value ~= result then
    self.Value = result;
    self.Changed:Fire(result);
  end
  self._Computing = false;

  return result;
end

function Computed:Add(value : any)

  if self._Seen[value] then return end;
  self._Seen[value] = true;

  table.insert(self._Connections, value.Changed:Connect(function()
    ComputedScheduler.schedule(self);
  end))
end

function Computed:Destroy()
  self:Clear(); -- Clears the connections
  self.Changed:Destroy();
  self.Value = nil;
  self.Callback = nil;
  self._Seen = nil;
  self._Connections = nil;
end

function Computed.new(fn : () -> any)
  local computed = setmetatable({}, Computed);
  computed.Callback = fn;
  computed._Seen = {};
  computed._Connections = {};
  computed.Value = nil;
  computed.Changed = Signal.new();
  computed._Computing = false;

  computed:Get();

  return computed;
end

return Computed;
